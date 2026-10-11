const { Pool, types } = require("pg");
require("dotenv").config({ quiet: true });

// Keep DATE as string (no timezone changes)
types.setTypeParser(1082, (val) => val);

let pool = null;

/* ============================================
   MAIN DB (PGDATABASEMAIN)
   The same database serverpe-back-end uses. QuickInfo only owns the
   quickinfo_* tables in it, and reads the shared contact_query_types list.
============================================ */
const connectDB = () => {
  if (!pool) {
    pool = new Pool({
      host: process.env.PGHOST,
      database: process.env.PGDATABASEMAIN,
      user: process.env.PGUSER,
      password: process.env.PGPASSWORD,
      port: process.env.PGPORT,
      max: 10,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 5000,
      keepAlive: true,
    });

    // An idle client dropping its connection must not crash the process.
    pool.on("error", (err) => console.error("PostgreSQL pool error:", err.message));

    pool
      .query("SELECT NOW()")
      .then(() => console.log("✅ PostgreSQL connected: quickinfo (shared serverpe DB)"))
      .catch((err) => console.error("❌ PostgreSQL connection failed:", err.message));
  }
  return pool;
};

module.exports = { connectDB };
