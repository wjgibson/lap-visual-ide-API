const queries = require("./reactflowQueries");

//Actual queries
const getAllConfigurations = (request, response) => {
  queries.getAllConfigurations(request, response);
};

const getConfigurationData = (request, response) => {
  queries.getConfigurationData(request, response);
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
  getConfigurationDataTest,
  getAllConfigurationsTest,
};
