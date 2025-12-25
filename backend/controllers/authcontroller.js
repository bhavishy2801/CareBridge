const User = require("../models/user");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

// ✅ SIGNUP
exports.signup = async (req, res) => {
  try {
    const {
      name,
      email,
      password,
      role,
      gender,
      age,
      bloodGroup,
      specialization
    } = req.body;

    // Basic validation
    if (!name || !email || !password || !role || !gender) {
      return res.status(400).json({
        msg: "Missing required fields"
      });
    }

    // Role-specific validation
    if (role === "patient") {
      if (!age || !bloodGroup) {
        return res.status(400).json({
          msg: "Patient must provide age and blood group"
        });
      }
    }

    if (role === "doctor") {
      if (!specialization) {
        return res.status(400).json({
          msg: "Doctor must provide specialization"
        });
      }
    }

    // Check existing user
    const existing = await User.findOne({ email });
    if (existing) {
      return res.status(409).json({
        msg: "User already exists"
      });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user
    const user = await User.create({
      name,
      email,
      password: hashedPassword,
      role,
      gender,
      age: role === "patient" ? age : undefined,
      bloodGroup: role === "patient" ? bloodGroup : undefined,
      specialization: role === "doctor" ? specialization : undefined
    });

    res.status(201).json({
      msg: "User registered successfully",
      userId: user._id
    });
  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
};

// ✅ LOGIN
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        msg: "Email and password required"
      });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        msg: "Invalid credentials"
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        msg: "Invalid credentials"
      });
    }

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        role: user.role,
        age: user.age,
        bloodGroup: user.bloodGroup,
        gender: user.gender,
        specialization: user.specialization
      }
    });
  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
};
