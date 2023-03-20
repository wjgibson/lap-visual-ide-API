const queries = require("./queries");

// Actual queries
const getAllConfigurations = (request, response) => {
  queries.getAllConfigurations(request, response);
};

const getAllSeqTypes = (request, response) => {
  queries.getAllSeqTypes(request, response);
};

const getAllControlModuleTypes = (request, response) => {
  queries.getAllControlModuleTypes(request, response);
};

const getConfigurationData = (request, response) => {
  queries.getConfigurationData(request, response);
};

const getSeqTypes = (request, response) => {
  queries.getSeqTypes(request, response);
};
//Test queries
const getAllConfigurationsTest = (request, response) => {
  queries.getAllConfigurationsTest(request, response);
};

const getConfigurationDataTest = (request, response) => {
  queries.getConfigurationDataTest(request, response);
};

module.exports = {
  getConfigurationData,
  getAllConfigurations,
  getSeqTypes,
  getConfigurationDataTest,
  getAllConfigurationsTest,
  getAllSeqTypes,
  getAllControlModuleTypes,
};
