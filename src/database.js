import { Pool } from "pg";
import dotenv from "dotenv";
dotenv.config();

const pool = new Pool({
  host: "localhost",
  user: "postgres",
  port: 5432,
  password: process.env.DATABASE_PASSWORD,
  database: "hostelfix-pg",
});

pool.on("connect", () => {
  console.log("Database client connected");
});

pool.on("error", (err) => {
  console.error("Unexpected database pool error:", err);
});

export default pool;
