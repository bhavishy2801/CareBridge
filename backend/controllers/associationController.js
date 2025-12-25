const Association = require("../models/association");
const Patient = require("../models/patient");
const Doctor = require("../models/doctor");
const Caretaker = require("../models/caretaker");

// ✅ SCAN QR CODE - Create association between doctor/caretaker and patient
exports.scanQrCode = async (req, res) => {
  try {
    const { qrCodeId, notes } = req.body;
    const { id: scannerId, userType } = req.user;

    // Validate scanner is doctor or caretaker
    if (!["Doctor", "Caretaker"].includes(userType)) {
      return res.status(403).json({
        msg: "Only doctors and caretakers can scan patient QR codes",
      });
    }

    if (!qrCodeId) {
      return res.status(400).json({
        msg: "QR code ID is required",
      });
    }

    // Create association via the static method
    const result = await Association.createFromQrScan(
      qrCodeId,
      scannerId,
      userType,
      notes
    );

    // Get patient details for response
    const patient = await Patient.findOne({ qrCodeId }).select("-password");

    res.status(result.isNew ? 201 : 200).json({
      msg: result.message,
      association: result.association,
      patient: {
        id: patient._id,
        name: patient.name,
        age: patient.age,
        bloodGroup: patient.bloodGroup,
        gender: patient.gender,
      },
    });
  } catch (err) {
    console.error("QR Scan error:", err);
    res.status(500).json({
      error: err.message,
    });
  }
};

// ✅ GET MY ASSOCIATIONS - Get all associations for current user
exports.getMyAssociations = async (req, res) => {
  try {
    const { id, userType, role } = req.user;
    let associations = [];

    if (userType === "Patient" || role === "patient") {
      // Get patient's doctors and caretakers
      const patient = await Patient.findById(id)
        .populate(
          "associatedDoctors.doctorId",
          "name specialization phone email clinicAddress"
        )
        .populate(
          "associatedCaretakers.caretakerId",
          "name phone email specializations"
        );

      associations = {
        doctors: patient.associatedDoctors.filter((a) => a.isActive),
        caretakers: patient.associatedCaretakers.filter((a) => a.isActive),
      };
    } else if (userType === "Doctor" || role === "doctor") {
      // Get doctor's patients
      const doctor = await Doctor.findById(id).populate(
        "associatedPatients.patientId",
        "name age bloodGroup gender phone email"
      );

      associations = {
        patients: doctor.associatedPatients.filter((a) => a.isActive),
      };
    } else if (userType === "Caretaker" || role === "caretaker") {
      // Get caretaker's patients
      const caretaker = await Caretaker.findById(id).populate(
        "associatedPatients.patientId",
        "name age bloodGroup gender phone email"
      );

      associations = {
        patients: caretaker.associatedPatients.filter((a) => a.isActive),
      };
    }

    res.json({ associations });
  } catch (err) {
    console.error("Get associations error:", err);
    res.status(500).json({ error: err.message });
  }
};

// ✅ DEACTIVATE ASSOCIATION
exports.deactivateAssociation = async (req, res) => {
  try {
    const { associationId } = req.params;
    const { id: userId, userType } = req.user;

    const association = await Association.findById(associationId);

    if (!association) {
      return res.status(404).json({ msg: "Association not found" });
    }

    // Check if user is part of this association
    const isPatient = association.patientId.toString() === userId.toString();
    const isAssociatedUser =
      association.associatedUserId.toString() === userId.toString();

    if (!isPatient && !isAssociatedUser) {
      return res
        .status(403)
        .json({ msg: "Not authorized to modify this association" });
    }

    // Deactivate in Association model
    association.status = "inactive";
    association.deactivatedAt = Date.now();
    await association.save();

    // Update in respective user models
    if (association.associatedUserType === "Doctor") {
      await Doctor.findByIdAndUpdate(
        association.associatedUserId,
        {
          $set: { "associatedPatients.$[elem].isActive": false },
        },
        {
          arrayFilters: [{ "elem.patientId": association.patientId }],
        }
      );

      await Patient.findByIdAndUpdate(
        association.patientId,
        {
          $set: { "associatedDoctors.$[elem].isActive": false },
        },
        {
          arrayFilters: [{ "elem.doctorId": association.associatedUserId }],
        }
      );
    } else if (association.associatedUserType === "Caretaker") {
      await Caretaker.findByIdAndUpdate(
        association.associatedUserId,
        {
          $set: { "associatedPatients.$[elem].isActive": false },
        },
        {
          arrayFilters: [{ "elem.patientId": association.patientId }],
        }
      );

      await Patient.findByIdAndUpdate(
        association.patientId,
        {
          $set: { "associatedCaretakers.$[elem].isActive": false },
        },
        {
          arrayFilters: [{ "elem.caretakerId": association.associatedUserId }],
        }
      );
    }

    res.json({ msg: "Association deactivated successfully" });
  } catch (err) {
    console.error("Deactivate association error:", err);
    res.status(500).json({ error: err.message });
  }
};

// ✅ GET PATIENT BY QR CODE (Preview before association)
exports.getPatientByQr = async (req, res) => {
  try {
    const { qrCodeId } = req.params;
    const { userType } = req.user;

    if (!["Doctor", "Caretaker"].includes(userType)) {
      return res.status(403).json({
        msg: "Only doctors and caretakers can look up patients by QR code",
      });
    }

    const patient = await Patient.findOne({ qrCodeId }).select(
      "name age gender bloodGroup medicalHistory"
    );

    if (!patient) {
      return res.status(404).json({ msg: "Patient not found" });
    }

    res.json({ patient });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ✅ CHECK IF CAN COMMUNICATE
exports.canCommunicate = async (req, res) => {
  try {
    const { targetUserId, targetUserType } = req.body;
    const { id: userId, userType } = req.user;

    const canChat = await Association.canCommunicate(
      userId,
      userType,
      targetUserId,
      targetUserType
    );

    res.json({ canCommunicate: canChat });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ✅ UPDATE LAST VISIT (for doctors)
exports.updateLastVisit = async (req, res) => {
  try {
    const { patientId } = req.params;
    const { diagnosis, notes } = req.body;
    const { id: doctorId, userType } = req.user;

    if (userType !== "Doctor") {
      return res
        .status(403)
        .json({ msg: "Only doctors can update visit records" });
    }

    const doctor = await Doctor.findById(doctorId);
    const patientAssoc = doctor.associatedPatients.find(
      (p) => p.patientId.toString() === patientId && p.isActive
    );

    if (!patientAssoc) {
      return res.status(404).json({ msg: "Patient association not found" });
    }

    patientAssoc.lastVisit = Date.now();
    if (diagnosis) patientAssoc.diagnosis = diagnosis;
    if (notes) patientAssoc.notes = notes;

    await doctor.save();

    res.json({ msg: "Visit record updated successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
