const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const {
  scanQrCode,
  getMyAssociations,
  deactivateAssociation,
  getPatientByQr,
  canCommunicate,
  updateLastVisit,
} = require("../controllers/associationController");

// Scan QR code to create association (POST /api/associations/scan)
router.post("/scan", auth, scanQrCode);

// Get all associations for current user (GET /api/associations)
router.get("/", auth, getMyAssociations);

// Get patient preview by QR code (GET /api/associations/patient/:qrCodeId)
router.get("/patient/:qrCodeId", auth, getPatientByQr);

// Check if two users can communicate (POST /api/associations/can-communicate)
router.post("/can-communicate", auth, canCommunicate);

// Deactivate an association (PATCH /api/associations/:associationId/deactivate)
router.patch("/:associationId/deactivate", auth, deactivateAssociation);

// Update last visit for a patient (PATCH /api/associations/visit/:patientId)
router.patch("/visit/:patientId", auth, updateLastVisit);

module.exports = router;
