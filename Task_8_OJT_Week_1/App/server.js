const express = require('express');
// const fs = require('fs');
const { Pool } = require("pg");
const path = require('path');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

// Middleware
app.use(bodyParser.json());

// Serve static frontend
app.use(express.static(path.join(__dirname, 'public')));

// Serve input JSON files
app.use('/input', express.static(path.join(__dirname, 'input')));

// Serve output folder (for history.json)
app.use('/output', express.static(path.join(__dirname, 'output')));

// API to save history data
// app.post('/save-history', (req, res) => {
//   const historyPath = path.join(__dirname, 'output', 'history.json');
//   const json = JSON.stringify(req.body, null, 2);

//   fs.writeFile(historyPath, json, 'utf8', (err) => {
//     if (err) {
//       console.error('Error saving history.json:', err);
//       res.status(500).send('Failed to save history.json');
//     } else {
//       console.log('History successfully saved.');
//       res.status(200).send('Saved');
//     }
//   });
// });

// Initialize DB pool ONLY in production or normal mode
if (process.env.NODE_ENV !== "test") {
  const pool = new Pool({
    user: process.env.PGUSER,
    host: process.env.PGHOST,
    database: process.env.PGDATABASE,
    password: process.env.PGPASSWORD,
    port: process.env.PGPORT,
  });

  app.locals.pool = pool;
}

app.post("/save-history", async (req, res) => {
  const pool = app.locals.pool; // get pool from app.locals
  if (!pool) {
    // No DB connection (e.g., during tests)
    return res.status(500).send("DB not initialized");
  }

  const historyObj = req.body;
  try {
    for (const emp_id in historyObj) {
      for (const week in historyObj[emp_id]) {
        const data = historyObj[emp_id][week];
        await pool.query(
          `INSERT INTO history (emp_id, week, data)
           VALUES ($1, $2, $3)
           ON CONFLICT (emp_id, week) 
           DO UPDATE SET data = EXCLUDED.data`,
          [emp_id, week, data]
        );
      }
    }
    res.status(200).send("Saved all history to DB");
  } catch (err) {
    console.error("Error saving history:", err);
    res.status(500).send("DB insert failed");
  }
});

// Route to fetch history
app.get("/history", async (req, res) => {
  const pool = app.locals.pool;
  if (!pool) {
    return res.status(500).send("DB not initialized");
  }

  try {
    const result = await pool.query("SELECT emp_id, week, data FROM history");
    res.json(result.rows);
  } catch (err) {
    console.error("Error fetching history:", err);
    res.status(500).send("DB fetch failed");
  }
});

// Start server
if (process.env.NODE_ENV !== "test") {
  app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
  });
}

module.exports = app;
// export default app;