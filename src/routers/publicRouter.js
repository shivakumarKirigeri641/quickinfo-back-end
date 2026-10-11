const express = require("express");
const publicRouter = express.Router();
const { sensitiveOpLimiter } = require("../middlewares/rateLimiter");
const { sendResult, serverError } = require("../utils/sendResult");
const getQueryTypes = require("../repos/gets/getQueryTypes");
const getServices = require("../repos/gets/getServices");
const {
  getPrivacyPolicy,
  getTermsAndConditions,
} = require("../repos/gets/getLegalDocument");
const validateForContactUs = require("../validators/validateForContactUs");
const insertContactQuery = require("../repos/insertions/insertContactQuery");

/* Every public route lives under this prefix, mounted at /api in app.js. */
const BASE = "/quickinfo/platform/public";

/* Wraps a handler that returns a repo result, so each route is one line. */
const handle = (fn) => async (req, res) => {
  try {
    return sendResult(res, await fn(req));
  } catch (err) {
    return serverError(res, err);
  }
};

// ======================================================
//                SERVICES (solutions catalogue)
// ======================================================
publicRouter.get(`${BASE}/services`, handle(() => getServices()));

// ======================================================
//                QUERY-TYPES (shared with ServerPe)
// ======================================================
publicRouter.get(`${BASE}/query-types`, handle(() => getQueryTypes()));

// ======================================================
//                PRIVACY-POLICY
// ======================================================
publicRouter.get(`${BASE}/privacy-policy`, handle(() => getPrivacyPolicy()));

// ======================================================
//                TERMS-AND-CONDITIONS
// ======================================================
publicRouter.get(`${BASE}/terms-and-conditions`, handle(() => getTermsAndConditions()));

// ======================================================
//                CONTACT-US
// ======================================================
publicRouter.post(
  `${BASE}/contact-us`,
  sensitiveOpLimiter,
  handle(async (req) => {
    const validation = validateForContactUs(req);
    if (!validation.successstatus) return validation;
    return insertContactQuery(req, validation.data);
  }),
);

module.exports = publicRouter;
