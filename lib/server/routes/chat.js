const express = require("express");
const mongoose = require('mongoose');
const Chat = require("../models/chat");

const chatRouter = express.Router();
const {
  createOrGetChat,
//   getUserChats,
  getChatMessages,
  sendMessage,
  messageController,
  getUsersByPhoneNumbers,
  markMessagesAsRead,
  deleteMessage,
} = require("../controllers/chatController");
const auth = require("../middleware/auth");

chatRouter.get("/api/chats", async (req, res) => {
    try {
      const { userId } = req.query;  // userId passed as a string in the query
      console.log('\n=== Starting Chat Search ===');
      console.log('Looking for userId:', userId);
      console.log('userId type:', typeof userId);
      console.log('userId length:', userId.length);
  
      if (!userId) {
        console.log('No userId provided in request');
        return res.status(400).json({ error: "userId is required" });
      }
  
      // First find all chats to check their structure
      const allChats = await Chat.find({});
      console.log('\n=== All Chats in Database ===');
      allChats.forEach(chat => {
        console.log('\nChat ID:', chat._id);
        console.log('Participants:');
        chat.participants.forEach((participant, index) => {
          console.log(`  Participant ${index + 1}:`);
          console.log(`    userId: ${participant.userId}`);
          console.log(`    userId type: ${typeof participant.userId}`);
          console.log(`    Matches requested userId: ${participant.userId === userId}`);
        });
      });
  
      // Now perform the actual search with string comparison
      const query = {
        "participants": {
          $elemMatch: {
            "userId": userId  // String comparison
          }
        }
      };
      console.log('Query:', JSON.stringify(query, null, 2));
  
      const matchingChats = await Chat.find(query);
      console.log('\n=== Search Results ===');
      console.log('Number of matching chats found:', matchingChats.length);
  
      if (!matchingChats || matchingChats.length === 0) {
        console.log('No matching chats found');
        return res.status(404).json({ error: "No chats found for this user" });
      }
  
      console.log('\n=== Sending Response ===');
      res.status(200).json(matchingChats);
  
    } catch (e) {
      console.error("\n=== Error in Chat Search ===");
      console.error("Error details:", e);
      res.status(500).json({ error: e.message });
    }
  });
  

  chatRouter.post("/api/cchats", async (req, res) => {
    try {
      const { type, participants, name, description, groupPicture, createdBy, settings } = req.body;
  
      // Validate input
      if (!type || !participants || !createdBy) {
        return res.status(400).json({ error: "Required fields are missing" });
      }
  
      // Create new chat instance
      const chat = new Chat({
        type,
        participants,
        name,
        description,
        groupPicture,
        createdBy,
        createdAt: new Date(),
        settings,
      });
  
      // Save the chat to the database
      await chat.save();
  
      // Send response
      res.status(201).json({
        message: "Chat created successfully",
        chat: chat,
      });
    } catch (error) {
      console.error("Error creating chat:", error);
      res.status(500).json({ error: "An error occurred while creating chat" });
    }
  });
  

  chatRouter.post("/api/createGetChats", auth, createOrGetChat);
  chatRouter.post('/api/registered-users', auth, getUsersByPhoneNumbers);  
// chatRrouter.get("/api/chats", auth, getUserChats);
chatRouter.get("/api/chats/:chatId/messages", auth, getChatMessages);
chatRouter.post('/sendMessage', auth,sendMessage);
chatRouter.post("/api/sendMessages", auth, sendMessage);
chatRouter.put("/api/chat/:chatId/read", auth, markMessagesAsRead);
chatRouter.delete("/api/message/:messageId", auth, deleteMessage);
chatRouter.get("/api/debug/messages/:chatId", auth, async (req, res) => {
  try {
    const messages = await Message.find({ chatId: req.params.chatId })
      .sort("-createdAt")
      .limit(10);

    const stats = {
      totalMessages: await Message.countDocuments({
        chatId: req.params.chatId,
      }),
      messagesByType: await Message.aggregate([
        { $match: { chatId: mongoose.Types.ObjectId(req.params.chatId) } },
        { $group: { _id: "$messageType", count: { $sum: 1 } } },
      ]),
    };

    res.json({ messages, stats });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = chatRouter;
