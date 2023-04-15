const queries = require("../../queries");
const { Pool } = require("pg");

jest.mock("pg", () => {
  const mockPool = {
    query: jest.fn(),
  };
  return {
    Pool: jest.fn(() => mockPool),
  };
});

describe("getAllControlModuleTypes", () => {
  test("should call getAllControlModuleTypes with the correct information", () => {
    const request = {
      params: {
        cid: "12345",
      },
    };
    const response = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      send: jest.fn(),
    };
    const mockPool = new Pool();
    const mockQueryResult = {
      rows: ["some", "data"],
    };
    mockPool.query.mockImplementation((query, callback) => {
      callback(null, mockQueryResult);
    });

    queries.getAllControlModuleTypes(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "SELECT * FROM types.controlmoduletypes WHERE configuuid = '12345'",
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      params: {
        cid: "12345",
      },
    };
    const response = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      send: jest.fn(),
    };
    const mockPool = new Pool();
    const mockError = new Error("Something went wrong");
    mockPool.query.mockImplementation((query, callback) => {
      callback(mockError, null);
    });

    queries.getAllControlModuleTypes(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});

describe("prepareControlModuleTable", () => {
  test("should call prepareControlModuleTable with the correct information", () => {
    const request = {
      body: {
        configuuid: "12345",
      },
    };
    const response = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      send: jest.fn(),
    };
    const mockPool = new Pool();
    const mockQueryResult = {
      rows: ["some", "data"],
    };
    mockPool.query.mockImplementation((query, callback) => {
      callback(null, mockQueryResult);
    });

    queries.prepareControlModuleTable(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "delete from setup.controlmodules where configuuid='12345';",
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      body: {
        configuuid: "12345",
      },
    };
    const response = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      send: jest.fn(),
    };
    const mockPool = new Pool();
    const mockError = new Error("Something went wrong");
    mockPool.query.mockImplementation((query, callback) => {
      callback(mockError, null);
    });

    queries.prepareControlModuleTable(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});

describe("insertControlModule", () => {
  test("should call insertControlModule with the correct information", () => {
    const request = {
      body: {
        Id: "12345",
        configId: "67890",
        name: "test name",
        description: "test description",
        typeuuid: "abcd-1234",
      },
    };
    const response = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      send: jest.fn(),
    };
    const mockPool = new Pool();
    const mockQueryResult = {
      rows: ["some", "data"],
    };
    mockPool.query.mockImplementation((query, callback) => {
      callback(null, mockQueryResult);
    });

    queries.insertControlModule(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      `select setup.add_cm('12345','67890','test name','test description','abcd-1234');`,
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      body: {
        Id: "12345",
        configId: "67890",
        name: "test name",
        description: "test description",
        typeuuid: "abcd-1234",
      },
    };
    const response = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      send: jest.fn(),
    };
    const mockPool = new Pool();
    const mockError = new Error("Something went wrong");
    mockPool.query.mockImplementation((query, callback) => {
      callback(mockError, null);
    });

    queries.insertControlModule(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});
