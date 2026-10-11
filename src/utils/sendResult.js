/* One place that turns a repo/validator result into an HTTP response. */
const sendResult = (res, result) => {
  const body = {
    statuscode: result.statuscode,
    successstatus: result.successstatus,
    message: result.message,
  };
  if (result.data !== undefined) body.data = result.data;
  return res.status(result.statuscode).json(body);
};

const serverError = (res, err) => {
  console.error(err);
  // Never leak internal error text (SQL, stack details) to the browser.
  return res.status(500).json({
    statuscode: 500,
    successstatus: false,
    message: "Internal server error. Please try again later.",
  });
};

module.exports = { sendResult, serverError };
