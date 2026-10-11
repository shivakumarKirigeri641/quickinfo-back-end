const { connectDB } = require("../../database/connectDB");
const pool = connectDB();

/* Table names cannot be bound as query parameters, so only these two are allowed. */
const DOCUMENTS = {
  privacy: { table: "quickinfo_privacy_policy", label: "Privacy policy" },
  terms: { table: "quickinfo_terms_conditions", label: "Terms and conditions" },
};

/**
 * Returns { last_updated, sections: [{ id, title, description }] }.
 * last_updated is the newest updated_at among active sections, so editing any
 * section in the database moves the date shown on the page.
 */
const getLegalDocument = async (kind) => {
  const doc = DOCUMENTS[kind];
  if (!doc) throw new Error(`Unknown legal document: ${kind}`);
  try {
    const result = await pool.query(
      `SELECT id, title, description, updated_at
         FROM ${doc.table}
        WHERE is_active = true
        ORDER BY display_order ASC, id ASC`,
    );
    const lastUpdated = result.rows.reduce(
      (max, r) => (!max || r.updated_at > max ? r.updated_at : max),
      null,
    );
    return {
      statuscode: 200,
      successstatus: true,
      message: `${doc.label} fetched successfully`,
      data: {
        last_updated: lastUpdated,
        sections: result.rows.map(({ id, title, description }) => ({ id, title, description })),
      },
    };
  } catch (err) {
    console.error(`getLegalDocument(${kind}):`, err.message);
    return { statuscode: 500, successstatus: false, message: `Error fetching ${doc.label.toLowerCase()}` };
  }
};

const getPrivacyPolicy = () => getLegalDocument("privacy");
const getTermsAndConditions = () => getLegalDocument("terms");

module.exports = { getLegalDocument, getPrivacyPolicy, getTermsAndConditions };
