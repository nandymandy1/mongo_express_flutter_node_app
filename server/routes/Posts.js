const fs = require("fs");
const multer = require("multer");
const Post = require("../models/Post");
const router = require("express").Router();

const storage = multer.diskStorage({
  destination: (req, file, next) => {
    next(null, "./public/images/");
  },
  filename: (req, file, next) => {
    var date = new Date();
    var timestamp = date.getTime();
    let lastIndex = file.originalname.lastIndexOf(".");
    let extension = file.originalname.substring(lastIndex);
    let fileName = `${timestamp}-${file.fieldname}${extension}`;
    next(null, fileName);
  }
});

const upload = multer({
  storage: storage
});

router.post("/", upload.single("postImage"), async (req, res) => {
  try {
    let newPost = new Post({
      ...req.body
    });
    req.file ? (newPost.imageUrl = req.file.path.split("public").pop()) : null;
    let post = await newPost.save();
    return res.json(post);
  } catch (err) {
    return res.json(err);
  }
});

router.get("/", async (req, res) => {
  try {
    let posts = await Post.find().sort({ updatedAt: -1 });
    return res.json(posts);
  } catch (err) {
    return res.json(err);
  }
});

router.get("/:_id", async (req, res) => {
  try {
    let { _id } = req.params;
    let post = await Post.findById(_id);
    return res.json(post);
  } catch (err) {
    return res.json(err);
  }
});

router.put("/:_id", upload.single("postImage"), async (req, res) => {
  try {
    let { _id } = req.params;
    let post = await Post.findById(_id);
    if (!post) {
      return res.status(404).json({
        message: "Post not found"
      });
    }
    let { title, body } = req.body;
    post.title = title;
    post.body = body;

    // Delete the old image if the file is present in the request
    // And update it with new Image
    if (req.file) {
      await fs.unlinkSync(`./public/${post.imageUrl}`);
      post.imageUrl = req.file.path.split("public").pop();
    }

    let updatedPost = await post.save();
    return res.json(updatedPost);
  } catch (err) {
    return res.json(err);
  }
});

router.delete("/:_id", async (req, res) => {
  try {
    let { _id } = req.params;
    let post = await Post.findById(_id);
    if (!post) {
      return res.status(404).json({
        message: "Post not found"
      });
    }
    if (post.imageUrl) {
      await fs.unlinkSync(`./public/${post.imageUrl}`);
    }
    let deletedPost = await post.delete();
    return res.json(deletedPost);
  } catch (err) {
    return res.json(err);
  }
});

module.exports = router;
