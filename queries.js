const Pool = require("pg").Pool;
const settings = require("./settings.json");
const fs = require("fs");
const pool = new Pool({
  user: settings.user,
  host: settings.host,
  port: settings.port,
  database: settings.database,
  password: settings.password,
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

const createNewConfiguration = (request, response) => {
  console.log(request.body);
  let query = `select setup.add_config('14f38f2c-97c2-46af-b79a-07672eb2f94e','${
    request.body.name
  }', '${JSON.stringify(request.body.jsonData)}');`;
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
const getAllControlModuleTypes = (request, response) => {
  let query = `SELECT * FROM types.controlmoduletypes WHERE configuuid = '${request.params.cid}'`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const insertSequence = (request, response) => {
  let query = `select setup.add_seq('${request.body.Id}','${request.body.configId}','${request.body.name}','${request.body.description}','${request.body.typeuuid}');`;
  console.log(query);
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const insertSubSequence = (request, response) => {
  let query = `select setup.add_sub_seq('${request.body.parentNodeId}','${request.body.childNodeId}','${request.body.configuuid}');`;
  pool.query(query, (error, results) => {
    if (error) {
      console.log(error);
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const prepareSubSeqTable = (request, response) => {
  let query = `delete from sequenceconfig.subsequences where configuuid='${request.body.configuuid}';`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const prepareSequenceTable = (request, response) => {
  let query = `delete from setup.sequences where configuuid='${request.body.configuuid}';`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const prepareControlModuleTable = (request, response) => {
  let query = `delete from setup.controlmodules where configuuid='${request.body.configuuid}';`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const insertControlModule = (request, response) => {
  let query = `select setup.add_cm('${request.body.Id}','${request.body.configId}','${request.body.name}','${request.body.description}','${request.body.typeuuid}');`;
  console.log(query);
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const deleteConfig = (request, response) => {
  const { cid } = request.body;
  let query = `select setup.delete_config('${cid}');`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).send(results.rows);
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

const deleteConfigTest = (request, response) => {
  let query = `DELETE FROM testing WHERE cid = '${request.body.cid}'`;
  pool.query(query, (error, results) => {
    if (error) {
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

const getDatabaseSettings = (request, response) => {
  let settings = require("./settings.json");
  response.send(settings);
};

const updateDatabaseSettings = (request, response) => {
  let newSettings = request.body;
  fs.writeFileSync("./settings.json", JSON.stringify(newSettings));
};

module.exports = {
  getConfigurationData,
  getAllConfigurations,
  getAllSeqTypes,
  insertSequence,
  prepareSubSeqTable,
  prepareSequenceTable,
  prepareControlModuleTable,
  insertSubSequence,
  insertControlModule,
  getAllControlModuleTypes,
  getConfigurationDataTest,
  getAllConfigurationsTest,
  updateConfigurationData,
  insertNewConfiguration,
  createNewConfiguration,
  updateConfigurationDataTest,
  insertNewConfigurationTest,
  deleteConfig,
  deleteConfigTest,
  getDatabaseSettings,
  updateDatabaseSettings,
};
