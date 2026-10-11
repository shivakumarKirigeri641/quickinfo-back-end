const fail = (message) => ({ statuscode: 400, successstatus: false, message });

const isPositiveInt = (v) => Number.isInteger(Number(v)) && Number(v) > 0;
const str = (v) => (typeof v === "string" ? v.trim() : "");

/**
 * Validates the contact form and returns the cleaned values in `data`, so the
 * insert never touches raw request input.
 */
const validateForContactUs = (req) => {
  const body = req.body && typeof req.body === "object" ? req.body : {};

  const user_name = str(body.user_name);
  const mobile_number = str(body.mobile_number);
  const email = str(body.email);
  const business_name = str(body.business_name);
  const message = str(body.message);

  if (!user_name) return fail("Name is required");
  if (user_name.length < 2 || user_name.length > 100)
    return fail("Name must be between 2 and 100 characters");

  if (!mobile_number) return fail("Mobile number is required");
  if (!/^[6-9]\d{9}$/.test(mobile_number))
    return fail("Enter a valid 10-digit Indian mobile number");

  if (email) {
    if (email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
      return fail("Enter a valid email address");
  }

  if (business_name.length > 120)
    return fail("Business name must be at most 120 characters");

  if (!isPositiveInt(body.query_type_id)) return fail("Query type is required");

  const hasService = body.service_id !== undefined && body.service_id !== null && body.service_id !== "";
  if (hasService && !isPositiveInt(body.service_id)) return fail("Select a valid solution");

  if (!message) return fail("Message is required");
  if (message.length < 10 || message.length > 1000)
    return fail("Message must be between 10 and 1000 characters");

  if (body.accept_policies !== true)
    return fail("Please accept the Privacy Policy and Terms & Conditions");

  return {
    statuscode: 200,
    successstatus: true,
    message: "Validation passed",
    data: {
      user_name,
      mobile_number,
      email: email || null,
      business_name: business_name || null,
      query_type_id: Number(body.query_type_id),
      service_id: hasService ? Number(body.service_id) : null,
      message,
      whatsapp_opt_in: body.whatsapp_opt_in === true,
    },
  };
};

module.exports = validateForContactUs;
