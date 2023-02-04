const reactflowQueries = require("./reactflowQueries");
const lapQueries = require("./lapQueries");

// Actual queries
const insertNewConfiguration = (request, response) => {
  reactflowQueries.insertNewConfiguration(request, response);
};
const updateConfigurationData = (request, response) => {
  reactflowQueries.updateConfigurationData(request, response);
};

const createNewConfiguration = (request, response) => {
  lapQueries.createNewConfiguration(request, response);
};

const insertSequence = (request, response) => {
  reactflowQueries.insertSequence(request, response);
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
};
