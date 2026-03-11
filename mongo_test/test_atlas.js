const { MongoClient } = require('mongodb');

const uri = "mongodb+srv://pharmadb:n5w3Lq31YU9uRB42@cluster0.rtjvnyo.mongodb.net/pharmacy_db?retryWrites=true&w=majority";

const client = new MongoClient(uri);

async function run() {
  try {
    console.log("Connecting to MongoDB Atlas...");
    await client.connect();
    
    // Check connection by pinging the database
    const db = client.db("pharmacy_db");
    const result = await db.command({ ping: 1 });
    console.log("SUCCESS: Connected correctly to server. Ping result:", result);
    
    // Check collections
    const collections = await db.listCollections().toArray();
    console.log("Collections in DB:", collections.map(c => c.name));
    
  } catch (err) {
    console.error("FAILED to connect or execute:", err.message);
  } finally {
    await client.close();
  }
}

run().catch(console.dir);
