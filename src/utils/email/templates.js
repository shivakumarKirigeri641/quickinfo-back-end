const escapeHtml = require("../escapeHtml");

const platform = () => escapeHtml(process.env.PLATFORM_NAME || "QuickInfo");
const poweredBy = () => escapeHtml(process.env.POWERED_BY || "ServerPe App Solutions");

/* A plain, table-based layout: renders the same in Gmail, Outlook and phones. */
const layout = (heading, inner) => `<!doctype html>
<html><body style="margin:0;padding:0;background:#f4f4f5;font-family:Arial,Helvetica,sans-serif;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f4f4f5;padding:24px 0;">
<tr><td align="center">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:560px;background:#ffffff;border:1px solid #e4e4e7;">
<tr><td style="background:#0f766e;padding:20px 28px;color:#ffffff;font-size:20px;font-weight:bold;">${platform()}</td></tr>
<tr><td style="padding:28px;color:#18181b;font-size:15px;line-height:1.6;">
<h2 style="margin:0 0 16px;font-size:18px;color:#0a0a0a;">${heading}</h2>
${inner}
</td></tr>
<tr><td style="padding:16px 28px;border-top:1px solid #e4e4e7;color:#71717a;font-size:12px;">
${platform()} is operated by ${poweredBy()}. This is an automated message; please do not reply to it.
</td></tr>
</table>
</td></tr>
</table>
</body></html>`;

const row = (label, value) =>
  `<tr><td style="padding:6px 12px 6px 0;color:#71717a;vertical-align:top;white-space:nowrap;">${label}</td>` +
  `<td style="padding:6px 0;color:#18181b;">${escapeHtml(value || "-")}</td></tr>`;

/* Sent to the visitor when they left an email address. */
const contactThankYouTemplate = ({ user_name, query_type, message }) =>
  layout(
    `Thank you, ${escapeHtml(user_name)}`,
    `<p style="margin:0 0 16px;">We have received your query and our team will get back to you shortly.</p>
<table role="presentation" cellpadding="0" cellspacing="0" style="font-size:14px;">
${row("Query type", query_type)}
${row("Your message", message)}
</table>`,
  );

/* Sent to ADMINMAIL for every new lead. */
const contactAdminAlertTemplate = (q) =>
  layout(
    "New QuickInfo enquiry",
    `<table role="presentation" cellpadding="0" cellspacing="0" style="font-size:14px;">
${row("Reference", `#${q.id}`)}
${row("Name", q.user_name)}
${row("Mobile", q.mobile_number)}
${row("Email", q.email)}
${row("Business", q.business_name)}
${row("Query type", q.query_type)}
${row("Solution", q.service_name)}
${row("WhatsApp opt-in", q.whatsapp_opt_in ? "Yes" : "No")}
${row("Message", q.message)}
</table>`,
  );

module.exports = { contactThankYouTemplate, contactAdminAlertTemplate };
