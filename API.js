const express = require("express");
const bodyParser = require("body-parser");

const app = express();
const port = 3001;
const queries = require("./non-destructiveCalls");
const destructive = require("./destructiveCalls");

app.use(bodyParser.json());

app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
  next();
});

app.get("/initTest", (request, response) => {
  response.statusCode = 200;
  response.json({ info: "Request Received" });
});
//get queries
app.get("/getConfigJSON:cid", queries.getConfigurationData);
app.get("/getAllConfigs", queries.getAllConfigurations);
app.get("/getAllConfigsTest", queries.getAllConfigurationsTest);
app.get("/getConfigurationDataTest", queries.getConfigurationDataTest);
app.get("/getAllSequenceTypes:cid", queries.getAllSeqTypes);

//destructiveQueries
app.post("/updateConfig", destructive.updateConfigurationData);
app.post("/insertNewConfig", destructive.insertNewConfiguration);
app.post("/createNewConfig", destructive.createNewConfiguration);
app.post("/updateConfigTest", destructive.updateConfigurationDataTest);
app.post("/insertNewConfigTest", destructive.insertNewConfigurationTest);

app.listen(port, () => {
  console.log(`App running on port ${port}.`);
});
