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
  let query = `INSERT INTO reactflow.reactflowdata (json, name) VALUES ('${JSON.stringify(
    request.body.jsonData
  )}', '${request.body.name}')`;
  pool.query(query, (error, results) => {
    if (error) {
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
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const insertSequences = (request, response) => {
  let query = `select setup.add_seq('${request.body.configId}','${request.body.name}','${request.body.description}','${request.body.typeuuid}')`;
  console.log(query);
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
  let query = `INSERT INTO reactflow.testing (json, name) VALUES ('${JSON.stringify(
    request.body.jsonData
  )}', '${request.body.name}')`;
  pool.query(query, (error, results) => {
    if (error) {
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

const deleteConfig = (request, response) => {
  const { cid } = request.body
  let query = `DELETE FROM configjson WHERE cid = '${cid}'`;
  console.log(query)
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).send("Deletion Successful");
    }
  });
}

const deleteConfigTest = (request, response) => {
  let query = `DELETE FROM testing WHERE cid = '${request.body.cid}'`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
}
module.exports = {
  getConfigurationData,
  getAllConfigurations,
  getAllSeqTypes,
  insertSequences,
  getConfigurationDataTest,
  getAllConfigurationsTest,
  updateConfigurationData,
  insertNewConfiguration,
  updateConfigurationDataTest,
  insertNewConfigurationTest,
  deleteConfig,
  deleteConfigTest
};
