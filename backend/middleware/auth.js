const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ msg: "No token provided" });
  }

  const token = authHeader.split(" ")[1];

  if (!token) {
    return res.status(401).json({ msg: "Token format invalid" });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = {
      id: decoded.id,
      role: decoded.role,
      userType: decoded.userType || getUserTypeFromRole(decoded.role),
    };
    next();
  } catch (err) {
    if (err.name === "TokenExpiredError") {
      return res.status(401).json({ msg: "Token expired" });
    }
    res.status(401).json({ msg: "Invalid token" });
  }
};

// Helper for backward compatibility with old tokens
function getUserTypeFromRole(role) {
  switch (role) {
    case "patient":
      return "Patient";
    case "doctor":
      return "Doctor";
    case "caretaker":
      return "Caretaker";
    default:
      return null;
  }
}
