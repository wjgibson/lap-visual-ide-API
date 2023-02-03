const Pool = require("pg").Pool;
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "LAP_PG",
  password: "password",
  port: 5432,
});

//Queries for reactflow specific data
const insertNewConfiguration = (request, response) => {
  console.log(request.body);
  let query = `INSERT INTO reactflow.reactflowdata (json, name) VALUES ('${JSON.stringify(
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
  let query = `UPDATE reactflow.reactflowdata SET json = '${JSON.stringify(
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

const getConfigurationData = (request, response) => {
  let query = `SELECT * FROM reactflow.reactflowdata WHERE cid = '${request.params.cid}'`;
  console.log(query);
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

//Queries for lap specific data
const getAllConfigurations = (request, response) => {
  let query = `SELECT * FROM setup.configurations`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const getAllSeqTypes = (request, response) => {
  let query = `SELECT * FROM types.sequenceTypes WHERE configuuid = '${request.params.cid}'`;
  console.log(query);
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const saveConfigurationForLAP = (request, response) => {
  let query = `SELECT * FROM setup.configurations`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

//Queries for testing
const insertNewConfigurationTest = (request, response) => {
  console.log(request.body);
  let query = `INSERT INTO reactflow.testing (json, name) VALUES ('${JSON.stringify(
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

const updateConfigurationDataTest = (request, response) => {
  let query = `UPDATE reactflow.testing SET json = '${JSON.stringify(
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

const getAllConfigurationsTest = (request, response) => {
  let query = `SELECT * FROM reactflow.testing`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};
const getConfigurationDataTest = (request, response) => {
  let query = `SELECT * FROM reactflow.testing WHERE cid = '${request.params.cid}'`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

module.exports = {
  getConfigurationData,
  getAllConfigurations,
  getAllSeqTypes,
  getConfigurationDataTest,
  getAllConfigurationsTest,
  updateConfigurationData,
  insertNewConfiguration,
  updateConfigurationDataTest,
  insertNewConfigurationTest,
};
