const express = require("express");
const bodyParser = require("body-parser");
const app = express();
const port = 3001;
const queries = require("./queries");

app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

app.get("/initTest", (request, response) => {
  response.statusCode = 200;
  response.json({ info: "Request Received" });
});
//get queries
app.get("/getConfigJSON/:name", queries.getConfigurationData());

//

app.listen(port, () => {
  console.log(`App running on port ${port}.`);
});
