// controllers/chatController.js
const Chat = require('../models/chat');
const Message = require('../models/message');
const Media = require('../models/media');
const User = require('../models/user');
const mongoose = require('mongoose');
const { ObjectId } = mongoose.Types;

const createOrGetChat = async (req, res) => {
    try {
      const { participantId, hide } = req.body;
      const userId = req.user; // Set by auth middleware
  
      console.log('Creating chat - userId:', userId);
      console.log('Creating chat - participantId:', participantId);
      console.log('Creating chat - hide:', hide);
  
      if (!mongoose.Types.ObjectId.isValid(participantId)) {
        return res.status(400).json({ error: 'Invalid participant ID format' });
      }
  
      // Find if chat exists
      const existingChat = await Chat.findOne({
        type: 'individual',
        hide: hide,
        'participants.userId': {
          $all: [userId, participantId],
        },
      }).populate('participants.userId', 'name avatar isOnline lastSeen');
  
      if (existingChat) {
        return res.status(200).json(existingChat);
      }
  
      // Create new chat
      const newChat = new Chat({
        participants: [
          {
            userId: userId,
            role: 'admin',
            password: '###**###',
            joinedAt: new Date(),
          },
          {
            userId: participantId,
            role: 'member',
            password: '###**###',
            joinedAt: new Date(),
          },
        ],
        type: 'individual',
        hide:hide,
        createdAt: new Date(),
        settings: {
          onlyAdminsCanMessage: false,
          onlyAdminsCanEditInfo: true,
          blockedUsers: []
        },
      });
  
      await newChat.save();
      await newChat.populate('participants.userId', 'name avatar isOnline lastSeen');
  
      res.status(201).json(newChat);
    } catch (error) {
      console.error('Chat creation error:', error);
      res.status(500).json({ error: error.message });
    }
  };

  
// Get user's chats
const getUserChats = async (req, res) => {
    try {
        const userId = req.user.id;

        const chats = await Chat.find({
            participants: userId
        })
        .populate('participants', 'name avatar isOnline lastSeen')
        .populate({
            path: 'lastMessage',
            populate: {
                path: 'sender',
                select: 'name'
            }
        })
        .sort({ updatedAt: -1 });

        res.status(200).json(chats);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


const sendMessage = async (req, res) => {
    try {
        const {
            messageId,
            chatId,
            content,
            messageType = 'text',
            replyTo,
            senderId
        } = req.body;

        console.log('first message id- message --id:',content.text );

        // Create message content properly
        let messageContent = {
            text: messageType === 'text' ? content.text || content : null,
            mediaUrl: ['image', 'video', 'audio', 'document'].includes(messageType) ? content.mediaUrl : null,
            thumbnail: content.thumbnail || null,
            fileName: content.fileName || null,
            fileSize: content.fileSize || null,
            duration: content.duration || null,
            contactInfo: content.contactInfo || null
        };

        const messageData = {
            messageId,
            chatId,
            senderId,
            type: messageType,
            content: messageContent,
            replyTo: replyTo || null,
            readBy: [],
            deliveredTo: [],
            status: 'sent',
            reactions: [],
            isDeleted: false,
            deletedFor: []
        };

        const newMessage = await Message.create(messageData);

        if (!newMessage) {
            throw new Error('Failed to save message');
        }

        // Update chat's last message
        await Chat.findByIdAndUpdate(chatId, {
            lastMessage: messageId
        });

        res.status(201).json(newMessage);

    } catch (error) {
        console.error('Error in sendMessage:', error);
        res.status(500).json({ error: error.message });
    }
};

/// reply messages
const replyMessage = async (req, res) => {
    try {
        const {
            messageId,
            chatId,
            content,
            messageType = 'text',
            quotedMessageId,
            senderId,
            forwardedFrom
        } = req.body;

        // Create message content based on the MessageContent model
        let messageContent = {
            text: messageType === 'text' ? content.text || content : null,
            mediaUrl: ['image', 'video', 'audio', 'document'].includes(messageType) ? content.mediaUrl : null,
            thumbnail: content.thumbnail || null,
            fileName: content.fileName || null,
            fileSize: content.fileSize || null,
            duration: content.duration || null,
            contactInfo: content.contactInfo || null
        };

        // Create message data following the Message model structure
        const messageData = {
            messageId,
            chatId,
            senderId,
            type: messageType,
            content: messageContent,
            replyTo: quotedMessageId || null,
            forwardedFrom: forwardedFrom || null,
            readBy: [],
            deliveredTo: [],
            status: 'sending',
            createdAt: new Date(),
            reactions: [],
            isDeleted: false,
            deletedFor: []
        };

        const newMessage = await Message.create(messageData);

        if (!newMessage) {
            throw new Error('Failed to save message');
        }

        // Update chat's last message
        await Chat.findByIdAndUpdate(chatId, {
            lastMessage: messageId,
            updatedAt: new Date()
        });

        res.status(201).json(newMessage);
    } catch (error) {
        console.error('Error in sendMessage:', error);
        res.status(500).json({ error: error.message });
    }
};


/// update or reset chat password
const updateChatPassword = async (req, res) => {
    try {
      const { chatId, password } = req.body;
      const userId = req.user; // Set by auth middleware
      console.log('password consol',password);
      console.log('password consol',chatId);
  
      if (!mongoose.Types.ObjectId.isValid(chatId)) {
        return res.status(400).json({ error: 'Invalid chat ID format' });
      }
  
      if (!password || typeof password !== 'string') {
        return res.status(400).json({ error: 'Valid password is required' });
      }
  
      const result = await Chat.updateOne(
        { 
          _id: chatId,
          'participants.userId': userId
        },
        {
          $set: {
            'participants.$.password': password
          }
        }
      );
  
      if (result.matchedCount === 0) {
        return res.status(404).json({ error: 'Chat not found or user not a participant' });
      }
  
      res.status(200).json({ message: 'Password updated successfully' });
  
    } catch (error) {
      console.error('Password update error:', error);
      res.status(500).json({ error: error.message });
    }
  };


//send message in group
// const sendGroupMessage = async (req, res) => {
//     try {
//         const {
//             messageId,
//             chatId,
//             content,
//             type = 'text',
//             replyTo,
//             senderId,
//             fileName,
//             fileSize,
//             duration,
//             thumbnail,
//             contactInfo
//         } = req.body;

//         if (!senderId || !chatId) {
//             return res.status(400).json({ error: 'Sender ID and Chat ID are required' });
//         }

//         // Validate chat exists and is a group chat
//         const chat = await Chat.findById(chatId);
//         console.log('chatId is :', chatId);
//         if (!chat) {
//             return res.status(404).json({ error: 'Chat not found' });
//         }
        
//         if (chat.type !== "group") {
//             return res.status(400).json({ error: 'This endpoint is for group messages only' });
//         }
        
//         // Validate sender is a member of the group
//         if (!chat.participants.includes(senderId)) {
//             return res.status(403).json({ error: 'Sender is not a member of this group' });
//         }

//         // Create message content based on type
//         const messageContent = {
//             text: type === 'text' ? content : null,
//             mediaUrl: ['image', 'video', 'audio', 'document'].includes(type) ? content : null,
//             thumbnail,
//             fileName,
//             fileSize,
//             duration,
//             contactInfo
//         };

//         // Base message data matching schema
//         const messageData = {
//             messageId: messageId || new Date().getTime().toString(),
//             chatId,
//             senderId,
//             type,
//             content: messageContent,
//             replyTo,
//             readBy: [],
//             deliveredTo: [],
//             status: 'sent',
//             createdAt: new Date(),
//             reactions: [],
//             isDeleted: false,
//             deletedFor: []
//         };

//         // Validate reply-to message if provided
//         if (replyTo) {
//             const replyMessage = await Message.findOne({ messageId: replyTo });
//             if (!replyMessage) {
//                 return res.status(404).json({ error: 'Reply message not found' });
//             }
//             if (replyMessage.chatId.toString() !== chatId) {
//                 return res.status(400).json({ error: 'Reply message must be from the same chat' });
//             }
//         }

//         // Create and save the message
//         const newMessage = await Message.create(messageData);

//         if (!newMessage) {
//             throw new Error('Failed to save message');
//         }

//         // Update chat's last message
//         await Chat.findByIdAndUpdate(chatId, {
//             lastMessage: newMessage.messageId,
//             lastMessageAt: newMessage.createdAt
//         });

//         // Emit socket event for real-time updates
//         const io = req.app.get('io'); // Assuming you've set io instance in your app
//         if (io) {
//             io.to(chatId).emit('groupMessage', {
//                 messageId: newMessage.messageId,
//                 message: type === 'text' ? content : null,
//                 sourceId: senderId,
//                 groupId: chatId,
//                 path: type !== 'text' ? content : null,
//                 type: 'group',
//                 createdAt: newMessage.createdAt,
//                 messageType: type,
//                 fileName,
//                 fileSize,
//                 duration,
//                 thumbnail
//             });
//         }

//         res.status(201).json(newMessage);
//     } catch (error) {
//         console.error('Error in sendGroupMessage:', error);
//         res.status(500).json({ error: error.message });
//     }
// };

const sendGroupMessage = async (req, res) => {
    try {
        const {
            messageId,
            chatId,
            content,
            type = 'text',
            replyTo,
            senderId,
            fileName,
            fileSize,
            duration,
            thumbnail,
            contactInfo
        } = req.body;

        // Input validation
        if (!senderId || !chatId) {
            return res.status(400).json({ error: 'Sender ID and Chat ID are required' });
        }

        // Validate chat exists and is a group chat
        const chat = await Chat.findById(chatId);
        console.log('chatId is:', chatId);
        
        if (!chat) {
            return res.status(404).json({ error: 'Chat not found' });
        }

        if (chat.type !== "group") {
            return res.status(400).json({ error: 'This endpoint is for group messages only' });
        }

        // Validate sender is a member of the group
        const participant = chat.participants.find(p => p.userId == senderId);
        console.log("Sender Id :", senderId);
        if (!participant) {
            return res.status(403).json({ error: 'Sender is not a member of this group' });
        }

        // Optional: Check if user is allowed to send messages based on role
        if (participant.role !== 'admin' && participant.role !== 'member') {
            return res.status(403).json({ error: 'User does not have permission to send messages' });
        }

        // Create message content based on type
        const messageContent = {
            text: type === 'text' ? content : null,
            mediaUrl: ['image', 'video', 'audio', 'document'].includes(type) ? content : null,
            thumbnail,
            fileName,
            fileSize,
            duration,
            contactInfo
        };

        // Base message data matching schema
        const messageData = {
            messageId: messageId || new Date().getTime().toString(),
            chatId,
            senderId,
            senderRole: participant.role, // Adding sender's role to message
            type,
            content: messageContent,
            replyTo,
            readBy: [],
            deliveredTo: [],
            status: 'sent',
            createdAt: new Date(),
            reactions: [],
            isDeleted: false,
            deletedFor: []
        };

        // Validate reply-to message if provided
        if (replyTo) {
            const replyMessage = await Message.findOne({ messageId: replyTo });
            if (!replyMessage) {
                return res.status(404).json({ error: 'Reply message not found' });
            }
            if (replyMessage.chatId.toString() !== chatId) {
                return res.status(400).json({ error: 'Reply message must be from the same chat' });
            }
        }

        // Create message and update chat in a transaction
        const session = await mongoose.startSession();
        session.startTransaction();

        try {
            // Create and save the message
            const newMessage = await Message.create([messageData], { session });

            if (!newMessage || newMessage.length === 0) {
                throw new Error('Failed to save message');
            }

            // Update chat's last message and update time
            await Chat.findByIdAndUpdate(
                chatId,
                {
                    lastMessage: newMessage[0].messageId,
                    lastMessageAt: newMessage[0].createdAt,
                    $inc: { messageCount: 1 }
                },
                { session }
            );

            // Commit the transaction
            await session.commitTransaction();

            // Emit socket event for real-time updates
            const io = req.app.get('io');
            if (io) {
                io.to(chatId).emit('groupMessage', {
                    messageId: newMessage[0].messageId,
                    message: type === 'text' ? content : null,
                    sourceId: senderId,
                    senderRole: participant.role,
                    groupId: chatId,
                    path: type !== 'text' ? content : null,
                    type: 'group',
                    createdAt: newMessage[0].createdAt,
                    messageType: type,
                    fileName,
                    fileSize,
                    duration,
                    thumbnail
                });
            }

            res.status(201).json(newMessage[0]);
        } catch (error) {
            // If anything fails, abort transaction
            await session.abortTransaction();
            throw error;
        } finally {
            session.endSession();
        }
    } catch (error) {
        console.error('Error in sendGroupMessage:', error);
        res.status(500).json({ error: error.message });
    }
};

// get the users info by number
// Node.js/Express server code
const getUsersByPhoneNumbers = async (req, res) => {
    try {
        console.log('📩 Received request body:', req.body);
        const { phoneNumbers } = req.body;
        
        // Validate input
        if (!Array.isArray(phoneNumbers) || phoneNumbers.length === 0) {
            console.log('❌ Invalid input: phoneNumbers is not an array or is empty');
            return res.status(400).json({ error: "Please provide an array of phone numbers" });
        }
        
        console.log('🔍 Searching for phone numbers:', phoneNumbers);
        
        // Normalize phone numbers for comparison
        const normalizedPhoneNumbers = phoneNumbers.map(number => 
            number.replace(/[\s\(\)-]/g, '')
        );
        
        console.log('📱 Normalized phone numbers:', normalizedPhoneNumbers);
        
        // Find users with matching phone numbers
        const users = await User.find({
            number: { $in: normalizedPhoneNumbers }
        })
        .select('name username avatar isOnline lastSeen createdAt number')
        .sort({ name: 1 });
        
        console.log(`✅ Found ${users.length} users`);
        console.log('👥 Users:', users.map(u => ({ 
            name: u.name, 
            number: u.number 
        })));
        
        // Return found users
        res.status(200).json(users);
    } catch (error) {
        console.error('❌ Error in getUsersByPhoneNumbers:', error);
        res.status(500).json({ error: error.message });
    }
};


const getChatMessages = async (req, res) => {
    try {
        const { chatId } = req.params;
        const { page = 1, limit = 50 } = req.query;
        const userId = req.user;

        // Fetch messages that are NOT deleted for the user
        const messages = await Message.find({
            chatId,
            $or: [
                { isDeleted: false }, // Message is not deleted at all
                { isDeleted: true, deletedFor: { $not: { $elemMatch: { userId: userId } } } } // Message is deleted but NOT for this user
            ]
        })
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(parseInt(limit))
        .lean();

        // Log for debugging
        console.log("Filtered Messages: ", messages);

        res.status(200).json({
            messages,
            hasMore: messages.length === parseInt(limit)
        });
    } catch (error) {
        console.error('Error fetching messages:', error);
        res.status(500).json({ error: error.message });
    }
};


// Mark messages as read
const markMessagesAsRead = async (req, res) => {
    try {
        const { chatId } = req.params;
        const userId = req.user.id;

        await Message.updateMany(
            { chatId, sender: { $ne: userId } },
            { $addToSet: { readBy: userId } }
        );

        await Chat.findByIdAndUpdate(chatId, {
            $set: { [`unreadCounts.${userId}`]: 0 }
        });

        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const deleteMessage = async (req, res) => {
    try {
        console.log("Request User Object:", req.user);

        const { messageId } = req.params;
        if (!req.user) {
            return res.status(400).json({ error: "User ID not found in request" });
        }

        const userId = req.user;
        
        // Change from findById to findOne with messageId
        const message = await Message.findOne({ messageId: messageId });

        if (!message) {
            return res.status(404).json({ error: 'Message not found' });
        }

        // Check if already deleted for this user
        const isAlreadyDeleted = message.deletedFor.some(entry => 
            entry.userId.toString() === userId.toString()
        );

        if (isAlreadyDeleted) {
            return res.status(400).json({ error: 'Message already deleted' });
        }

        const deleteEntry = {
            userId: userId,
            deletedAt: new Date()
        };

        console.log('Deleting message for user:', deleteEntry);

        // Update using messageId instead of _id
        if (message.senderId.toString() === userId.toString()) {
            // For message sender - mark as deleted and add to deletedFor array
            await Message.findOneAndUpdate(
                { messageId: messageId },
                {
                    $set: { isDeleted: true },
                    $push: { deletedFor: deleteEntry }
                },
                { new: true } // Return updated document
            );
        } else {
            // For message receiver - only add to deletedFor array
            await Message.findOneAndUpdate(
                { messageId: messageId },
                {
                    $push: { deletedFor: deleteEntry }
                },
                { new: true } // Return updated document
            );
        }

        // Emit socket event to notify other users
        if (req.io) {
            req.io.emit('messageDeleted', {
                messageId: messageId,
                deletedBy: userId,
                isDeleted: message.senderId.toString() === userId.toString()
            });
        }

        res.status(200).json({ 
            message: 'Message deleted successfully',
            messageId: messageId
        });

    } catch (error) {
        console.error('Error deleting message:', error);
        res.status(500).json({ error: error.message });
    }
};


const deleteAllMessages = async (req, res) => {
    try {
        const { chatId } = req.params;
        console.log("Request User Object:", req.user);
        if (!req.user) {
            return res.status(400).json({ error: "User ID not found in request" });
        }
        const userId = req.user;

        // if (!userId) {
        //     return res.status(400).json({ error: "User ID not found in request" });
        // }

        // Find all messages in the chat that haven't been deleted for this user
        const messages = await Message.find({
            chatId: chatId,
            'deletedFor.userId': { $ne: userId }
        });

        if (!messages || messages.length === 0) {
            return res.status(200).json({ 
                message: 'No messages to delete',
                deletedMessages: []
            });
        }

        const updatedMessages = [];

        // Process each message
        for (const message of messages) {
            const deleteEntry = {
                userId: userId,
                deletedAt: new Date()
            };

            let updatedMessage;
            if (message.senderId.toString() === userId.toString()) {
                // Sender deleting the message
                updatedMessage = await Message.findOneAndUpdate(
                    { messageId: message.messageId },
                    {
                        $set: { isDeleted: true },
                        $push: { deletedFor: deleteEntry }
                    },
                    { new: true }
                );
            } else {
                // Receiver deleting the message
                updatedMessage = await Message.findOneAndUpdate(
                    { messageId: message.messageId },
                    {
                        $push: { deletedFor: deleteEntry }
                    },
                    { new: true }
                );
            }

            if (updatedMessage) {
                updatedMessages.push(updatedMessage.messageId);
                
                // Emit socket event
                if (req.io) {
                    req.io.emit('messageDeleted', {
                        messageId: message.messageId,
                        deletedBy: userId,
                        isDeleted: message.senderId.toString() === userId.toString()
                    });
                }
            }
        }

        res.status(200).json({
            message: 'Messages deleted successfully',
            deletedMessages: updatedMessages
        });
        
    } catch (error) {
        console.error('Error deleting messages:', error);
        res.status(500).json({ error: error.message });
    }
};

const blockUser = async (req, res) => {
    try {
      const { chatId, userIdToBlock } = req.body;
      const userId = req.user;
  
      const chat = await Chat.findById(chatId);
      if (!chat) {
        return res.status(404).json({ error: 'Chat not found' });
      }
      chat.blockUser(userIdToBlock);
      await chat.save();
      await chat.populate('settings.blockedUsers.userId', 'name avatar');
  
      res.json(chat);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };
  
  const unblockUser = async (req, res) => {
    try {
      const { chatId, userIdToUnblock } = req.body;
      const userId = req.user;
  
      const chat = await Chat.findById(chatId);
      if (!chat) {
        return res.status(404).json({ error: 'Chat not found' });
      }
  
      chat.unblockUser(userIdToUnblock);
      await chat.save();
      
      res.json(chat);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };
  

// module.exports = { deleteMessage };


module.exports = {
    deleteMessage,
    createOrGetChat,
    getUserChats,
    updateChatPassword,
    deleteMessage,
    getChatMessages,
    sendGroupMessage,
    sendMessage,
    getUsersByPhoneNumbers,
    markMessagesAsRead,
    deleteMessage,
    replyMessage,
    deleteAllMessages,
    blockUser,
    unblockUser
};
