const { Schema, model } = require("mongoose");

const PostSchema = new Schema(
  {
    title: {
      type: String,
      required: true
    },
    body: {
      type: String,
      required: true
    },
    imageUrl: {
      type: String,
      required: false
    }
  },
  { timestamps: true }
);

module.exports = model("posts", PostSchema);
