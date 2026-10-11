const { connectDB } = require("../../database/connectDB");
const pool = connectDB();

const getServices = async () => {
  try {
    const result = await pool.query(
      `SELECT id, slug, name, channel, summary, features
         FROM quickinfo_services
        WHERE is_active = true
        ORDER BY display_order ASC, id ASC`,
    );
    return {
      statuscode: 200,
      successstatus: true,
      message: "Services fetched successfully",
      data: result.rows,
    };
  } catch (err) {
    console.error("getServices:", err.message);
    return { statuscode: 500, successstatus: false, message: "Error fetching services" };
  }
};

module.exports = getServices;
