const Patient = require("../models/patient");
const Doctor = require("../models/doctor");
const Caretaker = require("../models/caretaker");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// Helper to get model by role
const getModelByRole = (role) => {
  switch (role) {
    case "patient":
      return Patient;
    case "doctor":
      return Doctor;
    case "caretaker":
      return Caretaker;
    default:
      return null;
  }
};

// Helper to get user type string for JWT
const getUserType = (role) => {
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
};

// Check if email exists in any collection
const checkEmailExists = async (email) => {
  const patient = await Patient.findOne({ email });
  if (patient) return { exists: true, role: "patient" };

  const doctor = await Doctor.findOne({ email });
  if (doctor) return { exists: true, role: "doctor" };

  const caretaker = await Caretaker.findOne({ email });
  if (caretaker) return { exists: true, role: "caretaker" };

  return { exists: false };
};

// ✅ SIGNUP
exports.signup = async (req, res) => {
  try {
    const {
      name,
      email,
      password,
      role,
      gender,
      phone,
      // Patient specific
      age,
      bloodGroup,
      address,
      emergencyContact,
      medicalHistory,
      // Doctor specific
      specialization,
      qualifications,
      experience,
      clinicAddress,
      consultationFee,
      availableSlots,
      // Caretaker specific
      qualification,
      specializations,
      availability,
    } = req.body;

    // Basic validation
    if (!name || !email || !password || !role || !gender) {
      return res.status(400).json({
        msg: "Missing required fields: name, email, password, role, and gender are required",
      });
    }

    // Validate role
    if (!["patient", "doctor", "caretaker"].includes(role)) {
      return res.status(400).json({
        msg: "Invalid role. Must be patient, doctor, or caretaker",
      });
    }

    // Role-specific validation
    if (role === "patient") {
      if (!age || !bloodGroup) {
        return res.status(400).json({
          msg: "Patient must provide age and blood group",
        });
      }
    }

    if (role === "doctor") {
      if (!specialization) {
        return res.status(400).json({
          msg: "Doctor must provide specialization",
        });
      }
    }

    // Check existing user across all collections
    const emailCheck = await checkEmailExists(email);
    if (emailCheck.exists) {
      return res.status(409).json({
        msg: "User with this email already exists",
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    let user;
    let responseData = {};

    // Create user based on role
    if (role === "patient") {
      user = await Patient.create({
        name,
        email,
        password: hashedPassword,
        gender,
        phone,
        age,
        bloodGroup,
        address,
        emergencyContact,
        medicalHistory,
      });

      responseData = {
        msg: "Patient registered successfully",
        userId: user._id,
        qrCodeId: user.qrCodeId, // Important for generating QR code on frontend
      };
    } else if (role === "doctor") {
      user = await Doctor.create({
        name,
        email,
        password: hashedPassword,
        gender,
        phone,
        specialization,
        qualifications,
        experience,
        clinicAddress,
        consultationFee,
        availableSlots,
      });

      responseData = {
        msg: "Doctor registered successfully",
        userId: user._id,
      };
    } else if (role === "caretaker") {
      user = await Caretaker.create({
        name,
        email,
        password: hashedPassword,
        gender,
        phone,
        qualification,
        experience,
        specializations,
        availability,
      });

      responseData = {
        msg: "Caretaker registered successfully",
        userId: user._id,
      };
    }

    res.status(201).json(responseData);
  } catch (err) {
    console.error("Signup error:", err);
    res.status(500).json({
      error: err.message,
    });
  }
};

// ✅ LOGIN
exports.login = async (req, res) => {
  try {
    const { email, password, role } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        msg: "Email and password required",
      });
    }

    let user = null;
    let userRole = role;

    // If role is provided, search in specific collection
    if (role) {
      const Model = getModelByRole(role);
      if (!Model) {
        return res.status(400).json({
          msg: "Invalid role",
        });
      }
      user = await Model.findOne({ email });
    } else {
      // Search across all collections
      user = await Patient.findOne({ email });
      if (user) {
        userRole = "patient";
      } else {
        user = await Doctor.findOne({ email });
        if (user) {
          userRole = "doctor";
        } else {
          user = await Caretaker.findOne({ email });
          if (user) {
            userRole = "caretaker";
          }
        }
      }
    }

    if (!user) {
      return res.status(401).json({
        msg: "Invalid credentials",
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        msg: "Invalid credentials",
      });
    }

    // Create JWT with user type for WebSocket auth
    const token = jwt.sign(
      {
        id: user._id,
        role: userRole,
        userType: getUserType(userRole),
      },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    // Build response based on role
    let userData = {
      id: user._id,
      name: user.name,
      email: user.email,
      role: userRole,
      gender: user.gender,
      phone: user.phone,
    };

    if (userRole === "patient") {
      userData = {
        ...userData,
        qrCodeId: user.qrCodeId,
        age: user.age,
        bloodGroup: user.bloodGroup,
        address: user.address,
        associatedDoctors: user.associatedDoctors,
        associatedCaretakers: user.associatedCaretakers,
      };
    } else if (userRole === "doctor") {
      userData = {
        ...userData,
        specialization: user.specialization,
        qualifications: user.qualifications,
        experience: user.experience,
        clinicAddress: user.clinicAddress,
        associatedPatients: user.associatedPatients,
      };
    } else if (userRole === "caretaker") {
      userData = {
        ...userData,
        qualification: user.qualification,
        experience: user.experience,
        specializations: user.specializations,
        associatedPatients: user.associatedPatients,
      };
    }

    res.json({
      token,
      user: userData,
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({
      error: err.message,
    });
  }
};

// ✅ GET CURRENT USER PROFILE
exports.getProfile = async (req, res) => {
  try {
    const { id, role } = req.user;
    const Model = getModelByRole(role);

    if (!Model) {
      return res.status(400).json({ msg: "Invalid user type" });
    }

    const user = await Model.findById(id).select("-password");
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    res.json({ user, role });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ✅ UPDATE PROFILE
exports.updateProfile = async (req, res) => {
  try {
    const { id, role } = req.user;
    const Model = getModelByRole(role);

    if (!Model) {
      return res.status(400).json({ msg: "Invalid user type" });
    }

    // Remove fields that shouldn't be updated directly
    const { password, email, qrCodeId, ...updateData } = req.body;

    const user = await Model.findByIdAndUpdate(
      id,
      { $set: updateData },
      { new: true }
    ).select("-password");

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    res.json({ msg: "Profile updated successfully", user });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ✅ CHANGE PASSWORD
exports.changePassword = async (req, res) => {
  try {
    const { id, role } = req.user;
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        msg: "Current password and new password are required",
      });
    }

    const Model = getModelByRole(role);
    const user = await Model.findById(id);

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(401).json({ msg: "Current password is incorrect" });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    user.password = hashedPassword;
    await user.save();

    res.json({ msg: "Password changed successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
