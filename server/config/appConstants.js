module.exports = {
  db:
    process.env.NODE_ENV === "production"
      ? "production_database_url"
      : "mongodb://localhost:27017/app_db",
  port: process.env.PORT || 5000
};
