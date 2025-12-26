const Report = require("../models/report");

// POST /reports - Submit a new report
exports.submitReport = async (req, res) => {
  try {
    const { patient, symptoms, customMessage } = req.body;
    if (!patient || !Array.isArray(symptoms) || symptoms.length === 0) {
      return res
        .status(400)
        .json({ message: "Patient ID and symptoms are required." });
    }
    const report = new Report({
      patient,
      symptoms,
      customMessage,
    });
    await report.save();
    res.status(201).json({ message: "Report submitted successfully", report });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error submitting report", error: error.message });
  }
};

const Association = require("../models/association");

// GET /reports/doctor - Get all reports for patients associated with the doctor
exports.getReportsForDoctor = async (req, res) => {
  try {
    const doctorId = req.user.id;
    // Find all active associations for this doctor
    const associations = await Association.find({
      associatedUserId: doctorId,
      associatedUserType: "Doctor",
      status: "active",
    });
    const patientIds = associations.map((assoc) => assoc.patientId);
    if (!patientIds.length) {
      return res.status(200).json({ reports: [] });
    }
    // Find all reports for these patients
    const reports = await Report.find({ patient: { $in: patientIds } })
      .populate("patient", "name email")
      .sort({ createdAt: -1 });
    res.status(200).json({ reports });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error fetching reports", error: error.message });
  }
};
