const { connectDB } = require("../../database/connectDB");
const { sendMail } = require("../../utils/email/sendMail");
const {
  contactThankYouTemplate,
  contactAdminAlertTemplate,
} = require("../../utils/email/templates");
const sendWhatsAppAck = require("../comms/sendWhatsAppMessage");
const clientIp = require("../../utils/clientIp");
const pool = connectDB();

/**
 * Emails and WhatsApp run after the response is sent. A slow or failing SMTP
 * server must not turn a saved enquiry into an error for the visitor.
 */
const notify = (q) => {
  const platformName = process.env.PLATFORM_NAME || "QuickInfo";
  const jobs = [];

  if (q.email) {
    jobs.push(
      sendMail({
        to: q.email,
        subject: `Thank you for contacting ${platformName}`,
        html: contactThankYouTemplate(q),
        text: `Hi ${q.user_name}, we have received your query and will get back to you shortly.`,
      }),
    );
  }

  if (process.env.ADMINMAIL) {
    jobs.push(
      sendMail({
        to: process.env.ADMINMAIL,
        subject: `New ${platformName} enquiry #${q.id}: ${q.query_type}`,
        html: contactAdminAlertTemplate(q),
        text: `New enquiry #${q.id} from ${q.user_name} (${q.mobile_number}).`,
      }),
    );
  }

  if (q.whatsapp_opt_in) {
    jobs.push(sendWhatsAppAck(q.mobile_number, q.user_name));
  }

  Promise.allSettled(jobs).then((results) =>
    results
      .filter((r) => r.status === "rejected")
      .forEach((r) =>
        console.error(
          `contact #${q.id} notification failed:`,
          r.reason?.response?.data || r.reason?.message || r.reason,
        ),
      ),
  );
};

/** @param {object} input cleaned values from validateForContactUs */
const insertContactQuery = async (req, input) => {
  try {
    const queryType = await pool.query(
      `SELECT query_type FROM contact_query_types WHERE id = $1 AND is_active = true`,
      [input.query_type_id],
    );
    if (queryType.rowCount === 0) {
      return { statuscode: 400, successstatus: false, message: "Select a valid query type" };
    }

    let serviceName = null;
    if (input.service_id) {
      const service = await pool.query(
        `SELECT name FROM quickinfo_services WHERE id = $1 AND is_active = true`,
        [input.service_id],
      );
      if (service.rowCount === 0) {
        return { statuscode: 400, successstatus: false, message: "Select a valid solution" };
      }
      serviceName = service.rows[0].name;
    }

    const result = await pool.query(
      `INSERT INTO quickinfo_contact_queries
         (user_name, mobile_number, email, business_name, query_type_id, service_id,
          message, whatsapp_opt_in, policy_accepted_at, ip_address, user_agent)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, now(), $9, $10)
       RETURNING id, created_at`,
      [
        input.user_name,
        input.mobile_number,
        input.email,
        input.business_name,
        input.query_type_id,
        input.service_id,
        input.message,
        input.whatsapp_opt_in,
        clientIp(req),
        (req.headers["user-agent"] || "").slice(0, 500) || null,
      ],
    );

    const saved = result.rows[0];
    notify({
      ...input,
      id: saved.id,
      query_type: queryType.rows[0].query_type,
      service_name: serviceName,
    });

    return {
      statuscode: 201,
      successstatus: true,
      message: "Thank you! Your query has been submitted. We will get back to you soon.",
      // Only the reference goes back to the browser, not the stored record.
      data: { reference_id: saved.id, created_at: saved.created_at },
    };
  } catch (err) {
    console.error("insertContactQuery:", err.message);
    return {
      statuscode: 500,
      successstatus: false,
      message: "We could not submit your query right now. Please try again later.",
    };
  }
};

module.exports = insertContactQuery;
