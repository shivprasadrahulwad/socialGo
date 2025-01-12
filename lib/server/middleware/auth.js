const jwt = require("jsonwebtoken");

// Middleware for authenticating JWT tokens
const auth = async (req, res, next) => {
  try {
    // Retrieve token from request headers
    const token = req.header("x-auth-token");
    if (!token) {
      return res.status(401).json({ msg: "No auth token, access denied" });
    }

    // Verify the token using a secure secret
    const verified = jwt.verify(token, process.env.JWT_SECRET || "passwordKey"); // Use environment variable
    if (!verified) {
      return res.status(401).json({ msg: "Token verification failed, authorization denied." });
    }

    // Attach user ID and token to the request object
    req.user = verified.id;
    req.token = token;

    next(); // Proceed to the next middleware or route handler
  } catch (err) {
    console.error(err); // Log the error for debugging
    res.status(500).json({ error: "Server error, please try again later." });
  }
};

module.exports = auth;
