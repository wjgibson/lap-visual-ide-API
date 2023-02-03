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

// Test queries
const insertNewConfigurationTest = (request, response) => {
  reactflowQueries.insertNewConfigurationTest(request, response);
};
const updateConfigurationDataTest = (request, response) => {
  reactflowQueries.updateConfigurationDataTest(request, response);
};

module.exports = {
  updateConfigurationData,
  insertNewConfiguration,
  updateConfigurationDataTest,
  insertNewConfigurationTest,
  createNewConfiguration,
};
