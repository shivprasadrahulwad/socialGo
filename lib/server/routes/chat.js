const express = require("express");
const mongoose = require("mongoose");
const Chat = require("../models/chat");
const ObjectId = mongoose.Types.ObjectId;
const auth = require("../middleware/auth");
const chatRouter = express.Router();

const {
  createOrGetChat,
  unblockUser,
  replyMessage,
  getChatMessages,
  sendMessage,
  deleteAllMessages,
  updateChatPassword,
  sendGroupMessage,
  getUsersByPhoneNumbers,
  markMessagesAsRead,
  deleteMessage,
  blockUser,
} = require("../controllers/chatController");

chatRouter.get("/api/chats", async (req, res) => {
  try {
    const { userId } = req.query;


    if (!userId) {
      console.log("No userId provided in request");
      return res.status(400).json({ error: "userId is required" });
    }

    // Convert string userId to ObjectId
    const objectIdUserId = new mongoose.Types.ObjectId(userId);

    // First find all chats to inspect their structure
    const allChats = await Chat.find({}).populate(
      "participants.userId",
      "name email avatar isOnline lastSeen"
    );

    console.log("\n=== Examining All Chats Structure ===");
    let matchingChatIds = new Set(); // To keep track of matching chats

    allChats.forEach((chat, chatIndex) => {
      let hasMatch = false;
      chat.participants.forEach((participant, partIndex) => {

        if (participant.userId && typeof participant.userId === "object") {
          const participantId = participant.userId._id?.toString();
          const requestedId = objectIdUserId.toString();
          const matches = participantId === requestedId;

          if (matches) {
            hasMatch = true;
            matchingChatIds.add(chat._id.toString());
          }
        }
      });

      console.log(`Chat ${chat._id} has match:`, hasMatch);
    });

    // Updated query to use $in with the collected matching chat IDs
    const query = {
      _id: {
        $in: Array.from(matchingChatIds).map(
          (id) => new mongoose.Types.ObjectId(id)
        ),
      },
    };

    const matchingChats = await Chat.find(query)
      .populate("participants.userId", "name email avatar isOnline lastSeen")
      .exec();
    matchingChats.forEach((chat, index) => {
    });

    if (!matchingChats || matchingChats.length === 0) {
      console.log("No matching chats found");
      return res.status(404).json({ error: "No chats found for this user" });
    }

    console.log("\n=== Sending Response ===");
    res.status(200).json(matchingChats);
  } catch (e) {

    if (e.name === "CastError") {
      return res.status(400).json({ error: "Invalid user ID format" });
    }

    res.status(500).json({ error: e.message });
  }
});

chatRouter.post("/api/cchats", async (req, res) => {
  try {
    const {
      type,
      participants,
      name,
      description,
      groupPicture,
      createdBy,
      settings,
    } = req.body;

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
chatRouter.patch("/api/updateChatPassword", auth, updateChatPassword);
chatRouter.post("/api/registered-users", auth, getUsersByPhoneNumbers);
chatRouter.delete('/api/messages/:messageId', auth, deleteMessage);
chatRouter.delete('/api/messages/chat/:chatId',auth, deleteAllMessages);
chatRouter.post('/api/chat/block', auth, blockUser);
chatRouter.post('/api/chat/unblock', auth, unblockUser);
// chatRrouter.get("/api/chats", auth, getUserChats);
chatRouter.get("/api/chats/:chatId/messages", auth, getChatMessages);
chatRouter.post("/api/replyMessages", auth, replyMessage);
chatRouter.post('/api/messages/group/send', sendGroupMessage);
chatRouter.post("/api/sendMessages", auth, sendMessage);
chatRouter.put("/api/chat/:chatId/read", auth, markMessagesAsRead);
// chatRouter.delete("/api/message/:messageId", auth, deleteMessage);
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
