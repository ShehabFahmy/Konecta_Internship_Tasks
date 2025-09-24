// Use AWS SDK v3 (pre-installed in Lambda Node.js 18 runtime)
const { S3Client, GetObjectCommand, PutObjectCommand } = require("@aws-sdk/client-s3");
const s3 = new S3Client();
const BUCKET = process.env.BUCKET;
const KEY = "history.json";

// Needed because your frontend (on GitHub Pages) is making cross-origin requests to API Gateway.
// Ensures the browser doesn’t block requests.
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type",
  "Access-Control-Allow-Methods": "OPTIONS,GET,POST"
};

// Utility: convert S3 stream -> string
const streamToString = (stream) =>
  new Promise((resolve, reject) => {
    const chunks = [];
    stream.on("data", (chunk) => chunks.push(chunk));
    stream.on("end", () => resolve(Buffer.concat(chunks).toString("utf-8")));
    stream.on("error", reject);
  });

async function getHistory() {
  try {
    const res = await s3.send(new GetObjectCommand({ Bucket: BUCKET, Key: KEY }));
    return await streamToString(res.Body);
  } catch (err) {
    if (err.name === "NoSuchKey") return "{}"; // Return empty object if file doesn’t exist
    throw err;
  }
}

async function putHistory(body) {
  await s3.send(new PutObjectCommand({
    Bucket: BUCKET,
    Key: KEY,
    Body: body,
    ContentType: "application/json"
  }));
}

// event: payload from API Gateway.
exports.handler = async (event) => {
  try {
    // Extract HTTP method (GET, POST, etc.) and request path.
    const method = event.requestContext?.http?.method;
    const path = event.rawPath || event.requestContext?.http?.path || event.path || "";

    // Handle OPTIONS requests for CORS preflight
    if (method === "OPTIONS") {
      return { statusCode: 200, headers: corsHeaders, body: "" };
    }

    // Read history from S3 and return it to frontend
    if (method === "GET" && path.endsWith("/history")) {
      const body = await getHistory();
      return { statusCode: 200, headers: corsHeaders, body };
    }

    // Read body from the request and save it to history.json in S3
    if (method === "POST" && path.endsWith("/save-history")) {
      const payload = event.body || "{}";
      await putHistory(payload);
      return { statusCode: 200, headers: corsHeaders, body: JSON.stringify({ ok: true }) };
    }

    // Fallback for any unsupported route
    return { statusCode: 404, headers: corsHeaders, body: "Not Found" };
  } catch (err) {
    console.error(err);
    // Fallback for unexpected errors (also logged to CloudWatch)
    return { statusCode: 500, headers: corsHeaders, body: JSON.stringify({ error: err.message }) };
  }
};
