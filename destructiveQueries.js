const Pool = require("pg").Pool;
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "postgres",
  password: "password",
  port: 5432,
});

const insertNewConfiguration = (request, response) => {
  console.log(request.body);
  let query = `INSERT INTO configjson (json, name) VALUES ('${JSON.stringify(
    request.body.jsonData
  )}', '${request.body.name}')`;
  console.log(query);
  pool.query(query, (error, results) => {
    if (error) {
      console.log(error);
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};
const updateConfigurationData = (request, response) => {
  let query = `UPDATE configjson SET json = '${JSON.stringify(
    request.body.jsonData
  )}' WHERE cid = '${request.body.cid}'`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

module.exports = {
  updateConfigurationData,
  insertNewConfiguration,
};
