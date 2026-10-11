const axios = require("axios");

/**
 * Sends the contact acknowledgement template on WhatsApp.
 *
 * Off unless QUICKINFO_WA_ACK_ENABLED=true, and only called when the visitor
 * ticked the WhatsApp consent box. A template that Meta has not approved, or a
 * message to a number that never opted in, hurts the business number's quality
 * rating, so both gates matter.
 */
const sendWhatsAppAck = async (mobile_number, user_name) => {
  if (process.env.QUICKINFO_WA_ACK_ENABLED !== "true") return { skipped: true };

  const response = await axios.post(
    `https://graph.facebook.com/v25.0/${process.env.WHATSAPP_PHONE_NUMBER_ID}/messages`,
    {
      messaging_product: "whatsapp",
      to: `91${mobile_number}`,
      type: "template",
      template: {
        name: (process.env.QUICKINFO_WA_ACK_TEMPLATE || "").trim(),
        language: { code: "en" },
        components: [
          { type: "body", parameters: [{ type: "text", text: user_name }] },
        ],
      },
    },
    {
      headers: {
        Authorization: `Bearer ${process.env.WHATSAPP_ACCESS_TOKEN}`,
        "Content-Type": "application/json",
      },
      timeout: 10000,
    },
  );
  return response.data;
};

module.exports = sendWhatsAppAck;
