/**
 * scripts/migrate.js
 * ---------------------------------------------------------------------------
 *   node scripts/migrate.js           apply anything not yet applied
 *   node scripts/migrate.js --check   report only, change nothing
 *
 * QuickInfo shares the serverpe database and its schema_migrations table.
 * QuickInfo migrations are numbered from 200 and every table is prefixed
 * quickinfo_, so they never collide with another product's migrations.
 * Only files in this repo's migrations/ folder are considered; rows that other
 * products recorded are left alone.
 *
 * Each migration carries its own BEGIN/COMMIT and is recorded by filename, so
 * running this twice is safe. There is deliberately no --fresh flag.
 * ---------------------------------------------------------------------------
 */

require("dotenv").config({ quiet: true });
const fs = require("fs");
const path = require("path");
const { Client } = require("pg");

const CHECK = process.argv.includes("--check");
const DIR = path.join(__dirname, "..", "migrations");

(async () => {
  const c = new Client({
    host: process.env.PGHOST,
    port: Number(process.env.PGPORT) || 5432,
    user: process.env.PGUSER,
    password: process.env.PGPASSWORD,
    database: process.env.PGDATABASEMAIN,
  });
  await c.connect();
  console.log(`\nquickinfo migrations — ${process.env.PGUSER}@${process.env.PGHOST}/${process.env.PGDATABASEMAIN}`);
  console.log(`  mode: ${CHECK ? "check" : "apply"}\n`);

  await c.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      filename    text PRIMARY KEY,
      applied_at  timestamptz NOT NULL DEFAULT now()
    )`);

  const done = new Set(
    (await c.query("SELECT filename FROM schema_migrations")).rows.map((r) => r.filename),
  );

  const files = fs.existsSync(DIR)
    ? fs.readdirSync(DIR).filter((f) => f.endsWith(".sql")).sort()
    : [];

  let applied = 0;
  let pending = 0;
  for (const f of files) {
    if (done.has(f)) { console.log(`  ok        ${f}`); continue; }
    if (CHECK) { console.log(`  PENDING   ${f}`); pending++; continue; }

    const sql = fs.readFileSync(path.join(DIR, f), "utf8");
    try {
      await c.query(sql);
      await c.query("INSERT INTO schema_migrations (filename) VALUES ($1)", [f]);
      console.log(`  applied   ${f}`);
      applied++;
    } catch (e) {
      // Leave the connection usable if the file's own transaction is still open.
      await c.query("ROLLBACK").catch(() => {});
      console.error(`\n  FAILED    ${f}\n            ${e.message}\n`);
      await c.end();
      process.exit(1);
    }
  }

  console.log(
    `\n  ${CHECK ? (pending ? `${pending} migration(s) pending.` : "Schema is up to date.") : `${applied} migration(s) applied.`}\n`,
  );
  await c.end();
})().catch((e) => { console.error("\nmigrate failed:", e.message, "\n"); process.exit(1); });
