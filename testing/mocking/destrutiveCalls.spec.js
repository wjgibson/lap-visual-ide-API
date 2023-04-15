const queries = require("../../queries");
const {
  insertNewConfiguration,
  updateConfigurationData,
  createNewConfiguration,
  insertSequence,
  insertSubSequence,
  prepareSubSeqTable,
  prepareSequenceTable,
  prepareControlModuleTable,
  insertControlModule,
  deleteConfig,
  updateDatabaseSettings,
} = require("../../destructiveCalls");

describe("destructiveCalls", () => {
  describe("insertNewConfiguration", () => {
    it("should call queries.insertNewConfiguration", () => {
      const request = {};
      const response = {};
      queries.insertNewConfiguration = jest.fn();
      insertNewConfiguration(request, response);
      expect(queries.insertNewConfiguration).toHaveBeenCalled();
    });
  });

  describe("updateConfigurationData", () => {
    it("should call queries.updateConfigurationData", () => {
      const request = {};
      const response = {};
      queries.updateConfigurationData = jest.fn();
      updateConfigurationData(request, response);
      expect(queries.updateConfigurationData).toHaveBeenCalled();
    });
  });

  describe("createNewConfiguration", () => {
    it("should call queries.createNewConfiguration", () => {
      const request = {};
      const response = {};
      queries.createNewConfiguration = jest.fn();
      createNewConfiguration(request, response);
      expect(queries.createNewConfiguration).toHaveBeenCalled();
    });
  });

  describe("insertSequence", () => {
    it("should call queries.insertSequence", () => {
      const request = {};
      const response = {};
      queries.insertSequence = jest.fn();
      insertSequence(request, response);
      expect(queries.insertSequence).toHaveBeenCalled();
    });
  });

  describe("insertSubSequence", () => {
    it("should call queries.insertSubSequence", () => {
      const request = {};
      const response = {};
      queries.insertSubSequence = jest.fn();
      insertSubSequence(request, response);
      expect(queries.insertSubSequence).toHaveBeenCalled();
    });
  });

  describe("prepareSubSeqTable", () => {
    it("should call queries.prepareSubSeqTable", () => {
      const request = {};
      const response = {};
      queries.prepareSubSeqTable = jest.fn();
      prepareSubSeqTable(request, response);
      expect(queries.prepareSubSeqTable).toHaveBeenCalled();
    });
  });

  describe("prepareSequenceTable", () => {
    it("should call queries.prepareSequenceTable", () => {
      const request = {};
      const response = {};
      queries.prepareSequenceTable = jest.fn();
      prepareSequenceTable(request, response);
      expect(queries.prepareSequenceTable).toHaveBeenCalled();
    });
  });

  describe("prepareControlModuleTable", () => {
    it("should call queries.prepareControlModuleTable", () => {
      const request = {};
      const response = {};
      queries.prepareControlModuleTable = jest.fn();
      prepareControlModuleTable(request, response);
      expect(queries.prepareControlModuleTable).toHaveBeenCalled();
    });
  });

  describe("insertControlModule", () => {
    it("should call queries.insertControlModule", () => {
      const request = {};
      const response = {};
      queries.insertControlModule = jest.fn();
      insertControlModule(request, response);
      expect(queries.insertControlModule).toHaveBeenCalled();
    });
  });

  describe("deleteConfig", () => {
    it("should call queries.deleteConfig", () => {
      const request = {};
      const response = {};
      queries.deleteConfig = jest.fn();
      deleteConfig(request, response);
      expect(queries.deleteConfig).toHaveBeenCalled();
    });
  });

  describe("updateDatabaseSettings", () => {
    it("should call queries.updateDatabaseSettings", () => {
      const request = {};
      const response = {};
      queries.updateDatabaseSettings = jest.fn();
      updateDatabaseSettings(request, response);
      expect(queries.updateDatabaseSettings).toHaveBeenCalled();
    });
  });
});
