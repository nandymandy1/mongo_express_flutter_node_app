const cors = require("cors");
const path = require("path");
const express = require("express");
const { connect } = require("mongoose");
const bodyParser = require("body-parser");
const { port, db } = require("./config/appConstants");

const app = express();

// Implement Middlewares
app.use(cors());
app.use(bodyParser.json());
app.use("/api/posts", require("./routes/Posts"));
app.use(express.static(path.join(__dirname, "./public")));

const startApp = async () => {
  // Database Connection
  await connect(
    db,
    { useNewUrlParser: true, useUnifiedTopology: true }
  )
    .then(() => console.log(`Database connected successfully\n${db}`))
    .catch(err => console.log(`Error in connecting the database\n${err}`));

  app.listen(port, () => console.log(`Server started on PORT ${port}`));
};

startApp();
