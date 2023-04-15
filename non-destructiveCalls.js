const queries = require("./queries");

// Actual queries
const getAllConfigurations = (request, response) => {
  queries.getAllConfigurations(request, response);
};

const getLoginData = (request, response) => {
  queries.getLoginData(request, response);
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

const getDatabaseSettings = (request, response) => {
  queries.getDatabaseSettings(request, response);
};

module.exports = {
  getConfigurationData,
  getAllConfigurations,
  getSeqTypes,
  getAllSeqTypes,
  getAllControlModuleTypes,
  getDatabaseSettings,
  getLoginData,
};
