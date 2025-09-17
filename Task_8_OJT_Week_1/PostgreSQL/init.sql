CREATE TABLE IF NOT EXISTS history (
    id SERIAL PRIMARY KEY,
    emp_id TEXT NOT NULL,
    week TEXT NOT NULL,
    data JSONB NOT NULL,
    UNIQUE(emp_id, week)
);
