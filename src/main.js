import pool from "./database.js";
import express, { json } from "express";

const app = express();
app.use(json());

try {
  const result = await pool.query("SELECT NOW()");
  console.log("Database connected successfully!");
  console.log(result.rows[0]);
} catch (err) {
  console.error("Database connection failed:", err.message);
}

app.post("/tickets/:id", async (req, res) => {
  try {
    const ticketBody = req.body;
    const id = req.params.id;

    const insert_query =
      "INSERT INTO tickets (user_id, category, status) VALUES ($1, $2, $3) RETURNING *";

    const result = await pool.query(insert_query, [
      id,
      ticketBody.category,
      ticketBody.status,
    ]);

    res.status(201).json({
      message: "CREATED",
      ticket: result.rows[0],
    });
  } catch (err) {
    console.error(err);

    res.status(500).json({
      message: "Something went wrong",
    });
  }
});

app.get("/tickets", async (req, res) => {
  try {
    const query = `SELECT 
   t.id AS ticket_id,
    t.category,
    t.status,
    u.name
     FROM tickets t 
     join users u on u.id = t.user_id`;

    const result = await pool.query(query);
    res.status(200).json({
      ticket: result.rows,
    });
  } catch (err) {
    console.error(err);

    res.status(500).json({
      message: "Something went wrong",
    });
  }
});

app.delete("/users/:id", async (req, res) => {
  try {
    const id = req.params.id;

    const delete_query = "DELETE from users WHERE id=$1 RETURNING *";

    const result = await pool.query(delete_query, [id]);

    res.status(204);
  } catch (err) {
    console.error(err);

    res.status(500).json({
      message: "Something went wrong",
    });
  }
});

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});
