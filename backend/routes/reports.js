const express = require("express");
const router = express.Router();
const reportController = require("../controllers/reportController");

const auth = require("../middleware/auth");
const role = require("../middleware/role");

// POST /reports - Submit a new report
router.post("/", reportController.submitReport);

// GET /reports/doctor - Get all reports for patients associated with the doctor
router.get("/doctor", auth, role("doctor"), reportController.getReportsForDoctor);

module.exports = router;
