const queries = require("../../queries");
const {
  getAllConfigurations,
  getAllSeqTypes,
  getAllControlModuleTypes,
  getConfigurationData,
  getSeqTypes,
  getDatabaseSettings,
  getLoginData,
} = require("../../non-destructiveCalls");

describe("non-destructiveCalls", () => {
  describe("getAllConfigurations", () => {
    it("should call queries.getAllConfigurations", () => {
      const request = {};
      const response = {};
      queries.getAllConfigurations = jest.fn();
      getAllConfigurations(request, response);
      expect(queries.getAllConfigurations).toHaveBeenCalled();
    });
  });

  describe("getAllSeqTypes", () => {
    it("should call queries.getAllSeqTypes", () => {
      const request = {};
      const response = {};
      queries.getAllSeqTypes = jest.fn();
      getAllSeqTypes(request, response);
      expect(queries.getAllSeqTypes).toHaveBeenCalled();
    });
  });

  describe("getAllControlModuleTypes", () => {
    it("should call queries.getAllControlModuleTypes", () => {
      const request = {};
      const response = {};
      queries.getAllControlModuleTypes = jest.fn();
      getAllControlModuleTypes(request, response);
      expect(queries.getAllControlModuleTypes).toHaveBeenCalled();
    });
  });

  describe("getConfigurationData", () => {
    it("should call queries.getConfigurationData", () => {
      const request = {};
      const response = {};
      queries.getConfigurationData = jest.fn();
      getConfigurationData(request, response);
      expect(queries.getConfigurationData).toHaveBeenCalled();
    });
  });

  describe("getSeqTypes", () => {
    it("should call queries.getSeqTypes", () => {
      const request = {};
      const response = {};
      queries.getSeqTypes = jest.fn();
      getSeqTypes(request, response);
      expect(queries.getSeqTypes).toHaveBeenCalled();
    });
  });

  describe("getDatabaseSettings", () => {
    it("should call queries.getDatabaseSettings", () => {
      const request = {};
      const response = {};
      queries.getDatabaseSettings = jest.fn();
      getDatabaseSettings(request, response);
      expect(queries.getDatabaseSettings).toHaveBeenCalled();
    });
  });

  describe("getLoginData", () => {
    it("should call queries.getLoginData", () => {
      const request = {};
      const response = {};
      queries.getLoginData = jest.fn();
      getLoginData(request, response);
      expect(queries.getLoginData).toHaveBeenCalled();
    });
  });
});
