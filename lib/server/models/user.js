// const mongoose = require("mongoose");

// const userSchema = mongoose.Schema({
//   name: {
//     type: String,
//   },
//   username: {
//     type: String,
//     required: true,
//     unique: true,
//     trim: true,
//   },
//   avatar: {
//     type: String,
//     default: "", 
//   },
//   isOnline: {
//     type: Boolean,
//     default: false,
//   },
//   lastSeen: {
//     type: Date,
//     default: Date.now,
//   },
//   createdAt: {
//     type: Date,
//     default: Date.now,
//   },
//   email: {
//     required: true,
//     type: String,
//     trim: true,
//     validate: {
//       validator: (value) => {
//         const re =
//           /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
//         return value.match(re);
//       },
//       message: "Please enter a valid email address",
//     },
//   },
//   password: {
//     required: true,
//     type: String,
//     trim: true,
//   },

//   type: {
//     type: String,
//     default: "user",
//   },
//   number: {
//     type: String,
//     required: true,
//     trim: true,
//   },

//   groups: {
//     type: [String], 
//     default: [],
//   },
// });

// const User = mongoose.model("User", userSchema);
// module.exports = User;



const mongoose = require("mongoose");
const { ObjectId } = mongoose.Schema.Types;

const userSchema = mongoose.Schema({
  name: {
    type: String,
  },
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  avatar: {
    type: String,
    default: "", 
  },
  isOnline: {
    type: Boolean,
    default: false,
  },
  lastSeen: {
    type: Date,
    default: Date.now,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  email: {
    required: true,
    type: String,
    trim: true,
    validate: {
      validator: (value) => {
        const re =
          /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
        return value.match(re);
      },
      message: "Please enter a valid email address",
    },
  },
  password: {
    required: true,
    type: String,
    trim: true,
  },

  type: {
    type: String,
    default: "user",
  },
  number: {
    type: String,
    required: true,
    trim: true,
  },
});

const User = mongoose.model("User", userSchema);
module.exports = User;
