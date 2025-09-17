const test = require("node:test");
const assert = require("node:assert");
const request = require("supertest");

// Import app (it already exports Express app)
const app = require("../server.js");

// Monkey-patch pool.query from inside server.js
// We need to reach it via app.locals
app.locals.pool = { query: async () => ({ rows: [] }) };

test("GET / should serve index.html", async () => {
  const res = await request(app).get("/");
  assert.strictEqual(res.statusCode, 200);
  assert.match(res.text, /<!DOCTYPE html>/);
});

test("GET /input/names.json should return JSON", async () => {
  const res = await request(app).get("/input/names.json");
  assert.strictEqual(res.statusCode, 200);
  assert.ok(res.type.includes("json"));
});

test("POST /save-history should insert into DB", async () => {
  app.locals.pool.query = async () => ({});
  const body = { emp1: { week1: { status: "Office" } } };
  const res = await request(app).post("/save-history").send(body);
  assert.strictEqual(res.statusCode, 200);
  assert.strictEqual(res.text, "Saved all history to DB");
});

test("POST /save-history should fail if DB errors", async () => {
  app.locals.pool.query = async () => {
    throw new Error("DB error");
  };
  const body = { emp1: { week1: { status: "Remote" } } };
  const res = await request(app).post("/save-history").send(body);
  assert.strictEqual(res.statusCode, 500);
});

test("GET /history should return rows", async () => {
  app.locals.pool.query = async () => ({
    rows: [{ emp_id: "emp1", week: "week1", data: { status: "Office" } }],
  });
  const res = await request(app).get("/history");
  assert.strictEqual(res.statusCode, 200);
  assert.deepStrictEqual(res.body, [
    { emp_id: "emp1", week: "week1", data: { status: "Office" } },
  ]);
});

test("GET /history should return 500 on DB failure", async () => {
  app.locals.pool.query = async () => {
    throw new Error("DB error");
  };
  const res = await request(app).get("/history");
  assert.strictEqual(res.statusCode, 500);
});
