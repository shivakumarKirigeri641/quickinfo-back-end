const { connectDB } = require("../../database/connectDB");
const pool = connectDB();

/* contact_query_types is shared with serverpe-back-end: read only. */
const getQueryTypes = async () => {
  try {
    const result = await pool.query(
      `SELECT id, query_type, description
         FROM contact_query_types
        WHERE is_active = true
        ORDER BY display_order ASC, id ASC`,
    );
    return {
      statuscode: 200,
      successstatus: true,
      message: "Query types fetched successfully",
      data: result.rows,
    };
  } catch (err) {
    console.error("getQueryTypes:", err.message);
    return { statuscode: 500, successstatus: false, message: "Error fetching query types" };
  }
};

module.exports = getQueryTypes;
