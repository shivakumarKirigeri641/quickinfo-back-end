/* The visitor's IP. app.js sets "trust proxy", so req.ip already honours
   X-Forwarded-For from the reverse proxy and cannot be spoofed past it. */
const clientIp = (req) => {
  const ip = req.ip || req.socket?.remoteAddress || null;
  // Strip the IPv4-mapped IPv6 prefix so Postgres stores a plain IPv4 inet.
  return ip ? ip.replace(/^::ffff:/, "") : null;
};

module.exports = clientIp;
