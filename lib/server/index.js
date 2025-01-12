const express = require("express");
const mongoose = require("mongoose");
const http = require("http");
const socketIO = require("socket.io");
const authRouter = require("./routes/auth.js");
const routes = require("./routes");
const User = require("./models/user");
const chatRoutes = require("./routes/chat");
const userRoutes = require("./routes/user");

const app = express();
const port = process.env.PORT || 5000;

// Use environment variables for sensitive data
const DB = "mongodb+srv://shivprasadrahulwad:npoAXmguuIxD1TeP@cluster.wxdju.mongodb.net/?retryWrites=true&w=majority&appName=Cluster";

// Create server and integrate Socket.IO
const server = http.createServer(app);
const io = socketIO(server);

// Middleware
app.use(express.json());
app.use(chatRoutes);
app.use(authRouter);
app.use(userRoutes);
app.use("/routes", routes);
app.use("/uploads", express.static("uploads"));

app.use("/api", chatRoutes);

let clients = {};

// Socket.IO handlers
io.on("connection", (socket) => {
  console.log("New socket connection established");

  // Handle user signin/initialization
  socket.on("signin", async (userId) => {
    try {
      console.log("User connected:", userId);
      clients[userId] = socket;

      // Skip database updates if needed
      if (!mongoose.Types.ObjectId.isValid(userId)) {
        console.log("Invalid ObjectId, skipping database operations");
        return;
      }

      try {
        // Update user online status
        await User.findByIdAndUpdate(
          mongoose.Types.ObjectId(userId),
          {
            isOnline: true,
            lastSeen: new Date(),
          },
          { runValidators: false }
        );

        // Notify user's contacts
        const userChats = await Chat.find({ 
          participants: mongoose.Types.ObjectId(userId) 
        });
        
        userChats.forEach((chat) => {
          const otherParticipant = chat.participants.find(
            (p) => p.toString() !== userId.toString()
          );
          if (clients[otherParticipant]) {
            clients[otherParticipant].emit("user_online", userId);
          }
        });
      } catch (dbError) {
        console.log("Database operation failed, but connection maintained:", dbError.message);
      }
    } catch (error) {
      console.error("Error in signin event:", error);
    }
  });

  // Handle messages
  socket.on("message", (data) => {
    console.log("Message received:", data);
    const targetSocket = clients[data.targetId];
    
    if (targetSocket) {
      targetSocket.emit("message", {
        message: data.message,
        sourceId: data.sourceId,
        targetId: data.targetId,
        path: data.path,
        messageId: data.messageId
      });
    }
  });

  // Handle read receipts
  socket.on("message_read", (data) => {
    console.log("Message read:", data);
    const targetSocket = clients[data.sourceId];
    
    if (targetSocket) {
      targetSocket.emit("message_read_receipt", {
        messageId: data.messageId,
        readAt: new Date().toISOString()
      });
    }
  });

  // Handle disconnection
  socket.on("disconnect", async () => {
    try {
      const userId = Object.keys(clients).find((key) => clients[key] === socket);
      if (userId) {
        delete clients[userId];

        if (!mongoose.Types.ObjectId.isValid(userId)) {
          console.log("Invalid ObjectId, skipping database operations");
          return;
        }

        try {
          // Update user status
          await User.findByIdAndUpdate(
            mongoose.Types.ObjectId(userId),
            {
              isOnline: false,
              lastSeen: new Date(),
            },
            { runValidators: false }
          );

          // Notify user's contacts
          const userChats = await Chat.find({ 
            participants: mongoose.Types.ObjectId(userId) 
          });
          
          userChats.forEach((chat) => {
            const otherParticipant = chat.participants.find(
              (p) => p.toString() !== userId.toString()
            );
            if (clients[otherParticipant]) {
              clients[otherParticipant].emit("user_offline", {
                userId,
                lastSeen: new Date(),
              });
            }
          });
        } catch (dbError) {
          console.log("Database operation failed during disconnect:", dbError.message);
        }
      }
    } catch (error) {
      console.error("Error in disconnect event:", error);
    }
  });
});

// Database connection
mongoose.connect(DB)
  .then(() => {
    console.log("Connection successful");
  })
  .catch((e) => {
    console.log(e);
  });

server.listen(port, "0.0.0.0", () => {
  console.log("Connected to port", port);
});







































































// // const express = require("express");
// // const mongoose = require("mongoose");
// // const authRouter = require("./routes/auth.js");
// // var http = require("http");
// // const app = express();
// // const port = process.env.PORT || 5000;


// // const DB = "mongodb+srv://shivprasadrahulwad:npoAXmguuIxD1TeP@cluster.wxdju.mongodb.net/?retryWrites=true&w=majority&appName=Cluster"


// // var server = http.createServer(app);
// // var io = require("socket.io")(server);

// // //middlewre
// // app.use(express.json());
// // app.use(authRouter);
// // var clients = {};
// // const routes = require("./routes");
// // app.use("/routes",routes)
// // app.use("/uploads", express.static("uploads"));


// // io.on("connection", (socket) => {
// //   console.log("connetetd");
// //   console.log(socket.id, "has joined");

  
// //   socket.on("signin", (id) => {
// //     console.log(id);
// //     clients[id] = socket;
// //     console.log(clients);
// //   });


// //   socket.on("message", (msg) => {
// //     console.log(msg);
// //     let targetId = msg.targetId;
// //     if (clients[targetId]) clients[targetId].emit("message", msg);
// //   });

// //   socket.on("message_read", (data) => {
// //     console.log("Message read:", data);
// //     let sourceId = data.sourceId;
// //     if (clients[sourceId]) {
// //       clients[sourceId].emit("message_read_receipt", {
// //         messageId: data.messageId,
// //         readAt: new Date(),
// //         readBy: data.targetId
// //       });
// //     }
// //   });
// // });

// // mongoose.connect(DB).then(() => {
// //   console.log("Connection successful");
// // }).catch((e) => {
// //   console.log(e);
// // });

// // server.listen(port, "0.0.0.0", () => {
// //   console.log("Connected to port", port);
// // });




// // const express = require("express");
// // const {createServer} = require("http");
// // const { type } = require("os");
// // const {Server} = require("socket.io");

// //  const app = express();
// //  const httpServer = createServer(app);
// //  const io = new Server(httpServer);


// // app.route("/").get((req, res) => {
// //   res.json("Server is running 🫡🫡🫡");
// // });

// // io.on("connection", (socket) => {
// //   socket.join("group1");
// //   console.log("backend connetetd");
// //   socket.on("sendMsg", (msg) => {
// //     console.log("msg",msg);
// //     // socket.emit("sendMsgServer",{...msg,type:"otherMsg"});
// //     io.to("group1").emit("sendMsgServer",{...msg,type:"otherMsg"});

// //   });
// // });


// // httpServer.listen(3000);



// const express = require("express");
// const { createServer } = require("http");
// const { Server } = require("socket.io");

// const app = express();
// const httpServer = createServer(app);
// const io = new Server(httpServer, {
//   cors: {
//     origin: "*", // Allow all origins temporarily for debugging
//     methods: ["GET", "POST"]
//   }
// });

// app.route("/").get((req, res) => {
//   res.json("Server is running 🫡🫡🫡");
// });

// io.on("connection", (socket) => {
//   console.log("✅ Client connected:", socket.id);
//   socket.join("group1");
//   socket.on("sendMsg", (msg) => {
//     console.log("📩 Message received:", msg);
//     io.to("group1").emit("sendMsgServer", { ...msg, type: "otherMsg" });
//   });

//   socket.on("disconnect", () => {
//     console.log("❌ Client disconnected:", socket.id);
//   });
// });

// httpServer.listen(3000, () => {
//   console.log("🚀 Server listening on http://localhost:3000");
// });



















