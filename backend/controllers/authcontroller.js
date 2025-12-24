const User=require("../models/user");
const bcrypt=require("bcryptjs");
const jwt=require("jsonwebtoken");

exports.signup=async (req,res)=>{
    try {
        const { name,email,password,role,language }=req.body;

        const existingUser=await User.findOne({ email });
        if (existingUser)
            return res.status(400).json({ msg: "User already exists" });

        const salt=await bcrypt.genSalt(10);
        const hashedPassword=await bcrypt.hash(password,salt);

        const user=await User.create({
            name,
            email,
            password: hashedPassword,
            role,
            language
        });

        res.status(201).json({ msg: "User registered successfully" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

exports.login=async (req,res)=>{
    try {
        const { email,password }=req.body;

        const user=await User.findOne({ email });
        if (!user)
            return res.status(400).json({ msg: "Invalid credentials" });

        const isMatch=await bcrypt.compare(password,user.password);
        if (!isMatch)
            return res.status(400).json({ msg: "Invalid credentials" });

        const token=jwt.sign(
            { id: user._id,role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: "7d" }
        );

        res.json({
            token,
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
                language: user.language
            }
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
