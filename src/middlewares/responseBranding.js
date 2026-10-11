/* Inject platform branding into every JSON response (before encryption). */
const branding = () => ({
  powered_by: process.env.POWERED_BY || "ServerPe App Solutions",
  platform: process.env.PLATFORM_NAME || "QuickInfo",
  website: process.env.PUBLIC_WEBSITE || "www.quickinfo.in",
});

function responseBranding(req, res, next) {
  const originalJson = res.json.bind(res);

  res.json = function (body) {
    if (body && typeof body === "object" && !Array.isArray(body)) {
      return originalJson({ ...body, ...branding() });
    }
    return originalJson({ ...branding(), data: body });
  };

  next();
}

module.exports = responseBranding;
