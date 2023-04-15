const queries = require("./queries");

// Actual queries
const insertNewConfiguration = (request, response) => {
  queries.insertNewConfiguration(request, response);
};
const updateConfigurationData = (request, response) => {
  queries.updateConfigurationData(request, response);
};

const createNewConfiguration = (request, response) => {
  queries.createNewConfiguration(request, response);
};

const insertSequence = (request, response) => {
  queries.insertSequence(request, response);
};

const insertSubSequence = (request, response) => {
  queries.insertSubSequence(request, response);
};

const prepareSubSeqTable = (request, response) => {
  queries.prepareSubSeqTable(request, response);
};

const prepareSequenceTable = (request, response) => {
  queries.prepareSequenceTable(request, response);
};

const prepareControlModuleTable = (request, response) => {
  queries.prepareControlModuleTable(request, response);
};

const insertControlModule = (request, response) => {
  queries.insertControlModule(request, response);
};

const deleteConfig = (request, response) => {
  queries.deleteConfig(request, response);
};

const updateDatabaseSettings = (request, response) => {
  queries.updateDatabaseSettings(request, response);
};

module.exports = {
  updateConfigurationData,
  insertNewConfiguration,
  createNewConfiguration,
  insertSequence,
  deleteConfig,
  insertControlModule,
  insertSubSequence,
  prepareSubSeqTable,
  prepareSequenceTable,
  prepareControlModuleTable,
  updateDatabaseSettings,
};
