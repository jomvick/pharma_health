const { MongoClient } = require('mongodb');

async function checkDb() {
  const uri = "mongodb+srv://pharmadb:n5w3Lq31YU9uRB42@cluster0.rtjvnyo.mongodb.net/pharmacy_db?retryWrites=true&w=majority";
  const client = new MongoClient(uri);

  try {
    await client.connect();
    console.log("Connected successfully to MongoDB Atlas");
    const db = client.db("pharmacy_db");
    const medicines = await db.collection("medicines").find({}).toArray();
    console.log(`Found ${medicines.length} medicines:`);
    medicines.forEach(m => {
      console.log(`- ${m.nom || m.name} (ID: ${m._id})`);
    });
    
    const lots = await db.collection("lots").find({}).toArray();
    console.log(`\nFound ${lots.length} lots.`);
  } catch (e) {
    console.error("Connection error:", e);
  } finally {
    await client.close();
  }
}

checkDb();
