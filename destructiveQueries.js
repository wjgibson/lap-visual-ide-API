const Pool = require("pg").Pool;
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "postgres",
  password: "password",
  port: 5432,
});

const insertNewConfiguration = (request, response) => {
  let query = `INSERT INTO configjson (json, name) VALUES ('${request.body.jsonData}', '${request.body.name}')`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send("error connecting to database");
      throw error;
    }
    response.status(200).json(results.rows);
  });
};
const updateConfigurationData = (request, response) => {
  let query = `UPDATE configjson SET json = '${request.body.jsonData}' WHERE name = '${request.body.name})'`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send("error connecting to database");
      throw error;
    }
    response.status(200).json(results.rows);
  });
};

module.exports = {
  updateConfigurationData,
  insertNewConfiguration,
};
