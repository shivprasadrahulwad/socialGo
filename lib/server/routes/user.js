const express = require("express");
const User = require("../models/user");
const userRouter = express.Router();

userRouter.get("/api/users", async (req, res) => {
    try {
      console.log("Received request to fetch all users."); // Debugging log
  
      // Retrieve all users from the database
      const users = await User.find();
  
      // Respond with the list of users
      res.status(200).json(users);
    } catch (e) {
      console.error("Error fetching users:", e); // Log the error
      res.status(500).json({ error: e.message });
    }
  });

  module.exports = userRouter;  
  