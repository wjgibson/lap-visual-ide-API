const reactflowQueries = require("./reactflowQueries");

// Actual queries
const insertNewConfiguration = (request, response) => {
  reactflowQueries.insertNewConfiguration(request, response);
};
const updateConfigurationData = (request, response) => {
  reactflowQueries.updateConfigurationData(request, response);
};

const createNewConfiguration = (request, response) => {
  reactflowQueries.createNewConfiguration(request, response);
};

const insertSequence = (request, response) => {
  reactflowQueries.insertSequence(request, response);
};

const insertSubSequence = (request, response) => {
  reactflowQueries.insertSubSequence(request, response);
};

const prepareSubSeqTable = (request, response) => {
  reactflowQueries.prepareSubSeqTable(request, response);
};

const prepareSequenceTable = (request, response) => {
  reactflowQueries.prepareSequenceTable(request, response);
};

const prepareControlModuleTable = (request, response) => {
  reactflowQueries.prepareControlModuleTable(request, response);
};

const insertControlModule = (request, response) => {
  reactflowQueries.insertControlModule(request, response);
};

const deleteConfig = (request, response) => {
  reactflowQueries.deleteConfig(request, response);
};

// Test queries
const insertNewConfigurationTest = (request, response) => {
  reactflowQueries.insertNewConfigurationTest(request, response);
};
const updateConfigurationDataTest = (request, response) => {
  reactflowQueries.updateConfigurationDataTest(request, response);
};
const deleteConfigTest = (request, response) => {
  reactflowQueries.deleteConfigTest(request, response);
};

module.exports = {
  updateConfigurationData,
  insertNewConfiguration,
  updateConfigurationDataTest,
  insertNewConfigurationTest,
  createNewConfiguration,
  insertSequence,
  deleteConfig,
  deleteConfigTest,
  insertControlModule,
  insertSubSequence,
  prepareSubSeqTable,
  prepareSequenceTable,
  prepareControlModuleTable,
};
