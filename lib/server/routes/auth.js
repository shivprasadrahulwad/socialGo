const express = require("express");
const User = require("../models/user");
const bcryptjs = require("bcryptjs");
const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");
const auth = require("../middleware/auth");
const { modelName } = require("../models/chat");
const authRouter = express.Router();

authRouter.post("/api/signup", async (req, res) => {
  try {
    console.log('🔵 Received signup request');
    console.log('📥 Request Body:', req.body);
    console.log('📥 Request Body:', JSON.stringify(req.body, null, 2));

    const { username, email, number, password ,name} = req.body;

    console.log('🛠️ Extracted Data:', { username, email, number, password ,name});

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      console.log('⚠️ User already exists with this email');
      return res
        .status(400)
        .json({ msg: "User with the same email already exists!" });
    }

    console.log('🔑 Hashing password...');
    const hashedPassword = await bcryptjs.hash(password, 8);

    let user = new User({
      email,
      number,
      username,
      name,
      password: hashedPassword,
    });

    console.log('💾 Saving user to database...');
    user = await user.save();

    console.log('✅ User saved successfully:', user);
    res.json(user);
  } catch (e) {
    console.error('❌ Error occurred during signup:', e.message);
    res.status(500).json({ error: e.message });
  }
});

authRouter.post("/api/signin", async (req, res) => {
  try {
    const { email, password, number, username } = req.body;

    // Query object initialization based on available parameters
    let query = {};

    console.log("Received sign-in request with the following data: ", { email, number, username, password });  // Debug: Check received data  

    // Check if email is valid
    if (email && email.includes('@')) {
      query.email = email;
    } else if (number) {
      query.number = number;
    } else if (username) {
      query.username = username;
    } else {
      return res.status(400).json({ msg: "No valid credential provided." });
    }
    

    console.log("Query object being used: ", query);  // Debug: Check query object

    // Try to find a user matching any of the provided parameters
    const user = await User.findOne(query);

    if (!user) {
      return res.status(400).json({ msg: "User with the provided credentials does not exist!" });
    }

    // Compare provided password with the stored hashed password
    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: "Incorrect password." });
    }

    // Generate JWT token after successful authentication
    const token = jwt.sign({ id: user._id }, "passwordKey");

    // Send the response with the token and user data
    res.json({ token, ...user._doc });
  } catch (e) {
    console.error("Error during sign-in:", e);  // Log the error
    res.status(500).json({ error: e.message });
  }
});




authRouter.post("/tokenIsValid", async (req, res) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) return res.json(false);
    const verified = jwt.verify(token, "passwordKey");
    if (!verified) return res.json(false);

    const user = await User.findById(verified.id);
    if (!user) return res.json(false);
    res.json(true);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

authRouter.get("/", auth, async (req, res) => {
  const user = await User.findById(req.user);
  res.json({ ...user._doc, token: req.token });
});

module.exports = authRouter;
