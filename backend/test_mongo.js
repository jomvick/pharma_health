const mongoose = require('mongoose');
const uri = "mongodb+srv://pharmadb:n5w3Lq31YU9uRB42@cluster0.rtjvnyo.mongodb.net/pharmacy_db?retryWrites=true&w=majority";

async function testConnection() {
  try {
    console.log("Attempting to connect to MongoDB Atlas...");
    await mongoose.connect(uri);
    console.log("SUCCESS: Connected to MongoDB Atlas successfully!");
    process.exit(0);
  } catch (error) {
    console.error("FAILED: Could not connect to MongoDB Atlas:", error.message);
    process.exit(1);
  }
}

testConnection();
