require("dotenv").config({ quiet: true });
const express = require("express");
const cors = require("cors");
const cookieParser = require("cookie-parser");
const { connectDB } = require("./database/connectDB");
const { globalLimiter } = require("./middlewares/rateLimiter");
const responseBranding = require("./middlewares/responseBranding");
const encryptResponse = require("./middlewares/encryptResponse");
const publicRouter = require("./routers/publicRouter");

const PORT = Number(process.env.PORT) || 7788;
const app = express();

if (!process.env.SECRET_KEY) {
  console.warn("⚠️  SECRET_KEY is not set: responses will be sent unencrypted.");
}

/* 🔐 MUST be before CORS & cookies: req.ip then honours the proxy's X-Forwarded-For */
app.set("trust proxy", 1);
app.disable("x-powered-by");

app.use(express.json({ limit: "20kb" }));

/* ✅ CORS: front-end origins come from CORS_ORIGINS (comma separated) */
const allowedOrigins = (process.env.CORS_ORIGINS || "http://localhost:5180")
  .split(",")
  .map((o) => o.trim())
  .filter(Boolean);
app.use(cors({ origin: allowedOrigins, credentials: true }));
app.use(cookieParser());

/* 🛡️ Global rate limiter – 200 requests/min per IP */
app.use(globalLimiter);

/* Each of these wraps res.json, and the one registered LAST runs FIRST.
   Encryption is registered first so it runs last: branding is added to the
   body and then the whole body, branding included, is encrypted. */
/* 🔐 Encrypt all JSON responses (the front end decrypts with the same key) */
app.use(encryptResponse);

/* Inject platform branding into every JSON response */
app.use(responseBranding);

/* Health check */
app.get("/", (req, res) => {
  res.status(200).json({
    status: "OK",
    service: "QuickInfo API",
    message: "API is running successfully 🚀",
  });
});

/* Routes */
app.use("/api", publicRouter);

/* Unknown route */
app.use((req, res) => {
  res.status(404).json({ statuscode: 404, successstatus: false, message: "Route not found" });
});

/* Malformed JSON and anything thrown outside a route handler */
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  if (err.type === "entity.parse.failed" || err.type === "entity.too.large") {
    return res.status(400).json({ statuscode: 400, successstatus: false, message: "Invalid request body" });
  }
  console.error(err);
  return res.status(500).json({ statuscode: 500, successstatus: false, message: "Internal server error" });
});

/* DB connection (shared with serverpe-back-end) */
connectDB();

app.listen(PORT, () => {
  console.log(`QuickInfo API is listening on port ${PORT}`);
});

module.exports = app;
