const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: 'password',
  port: 5432,
});

const insertNewConfiguration = (request, response) => {
  console.log(request.body);
  const query = `INSERT INTO configjson (json, name) VALUES ('${JSON.stringify(
    request.body.jsonData,
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
  const query = `UPDATE configjson SET json = '${JSON.stringify(
    request.body.jsonData,
  )}' WHERE cid = '${request.body.cid}'`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const insertNewConfigurationTest = (request, response) => {
  console.log(request.body);
  const query = `INSERT INTO testing (json, name) VALUES ('${JSON.stringify(
    request.body.jsonData,
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
  const query = `UPDATE testing SET json = '${JSON.stringify(
    request.body.jsonData,
  )}' WHERE cid = '${request.body.cid}'`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const getAllConfigurations = (request, response) => {
  const query = 'SELECT * FROM configjson';
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const getAllConfigurationsTest = (request, response) => {
  const query = 'SELECT * FROM testing';
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const getConfigurationData = (request, response) => {
  const query = `SELECT * FROM configjson WHERE cid = '${request.params.cid}'`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const getConfigurationDataTest = (request, response) => {
  const query = `SELECT * FROM testing WHERE cid = '${request.params.cid}'`;
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
  getConfigurationDataTest,
  getAllConfigurationsTest,
  updateConfigurationData,
  insertNewConfiguration,
  updateConfigurationDataTest,
  insertNewConfigurationTest,
};
