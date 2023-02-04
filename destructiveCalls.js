const queries = require("./queryFile");

//Actual queries
const insertNewConfiguration = (request, response) => {
  queries.insertNewConfiguration(request, response);
};
const updateConfigurationData = (request, response) => {
  queries.updateConfigurationData(request, response);
};
const deleteConfig = (request, response) => {
  queries.deleteConfig(request, response);
}

//Test queries
const insertNewConfigurationTest = (request, response) => {
  queries.insertNewConfigurationTest(request, response);
};
const updateConfigurationDataTest = (request, response) => {
  queries.updateConfigurationDataTest(request, response);
};
const deleteConfigTest = (request, response) => {
  queries.deleteConfigTest(request, response);
}


module.exports = {
  updateConfigurationData,
  insertNewConfiguration,
  updateConfigurationDataTest,
  insertNewConfigurationTest,
  deleteConfig,
  deleteConfigTest
};
