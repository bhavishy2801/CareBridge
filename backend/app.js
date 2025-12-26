const express = require("express");
const cors = require("cors");

const app = express();

// Middleware
app.use(
  cors({
    origin: "*", // Configure this based on your needs
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);
app.use(express.json());

// API Routes
app.use("/api/auth", require("./routes/auth"));
app.use("/api/dashboard", require("./routes/dashboard"));
app.use("/api/appointments", require("./routes/appointments"));
app.use("/api/previsit", require("./routes/previsit"));
app.use("/api/careplan", require("./routes/careplan"));
app.use("/api/dailylog", require("./routes/dailylog"));
app.use("/api/notifications", require("./routes/notifications"));
app.use("/api/sync", require("./routes/sync"));

// Route for patient reports
app.use("/api/reports", require("./routes/reports"));

// New routes for associations and chat
app.use("/api/associations", require("./routes/associations"));
app.use("/api/chat", require("./routes/chat"));

// Health check
app.get("/", (req, res) => {
  res.json({
    message: "CareBridge API Running",
    version: "2.0.0",
    features: [
      "Patient-Doctor-Caretaker Associations",
      "QR Code Based Patient Identification",
      "Real-time Chat via WebSocket",
    ],
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ msg: "Route not found" });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ msg: "Something went wrong!", error: err.message });
});

module.exports = app;
