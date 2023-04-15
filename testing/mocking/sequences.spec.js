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

describe("getAllSeqTypes", () => {
  test("should call getAllSeqTypes with the correct information", () => {
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

    queries.getAllSeqTypes(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "SELECT * FROM types.sequenceTypes WHERE configuuid = '12345'",
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

    queries.getAllSeqTypes(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});

describe("insertSequence", () => {
  test("should call insertSequence with the correct information", () => {
    const request = {
      body: {
        Id: "123",
        configId: "456",
        name: "sequence1",
        description: "a test sequence",
        typeuuid: "789",
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

    queries.insertSequence(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "select setup.add_seq('123','456','sequence1','a test sequence','789');",
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      body: {
        Id: "123",
        configId: "456",
        name: "sequence1",
        description: "a test sequence",
        typeuuid: "789",
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

    queries.insertSequence(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});

describe("prepareSequenceTable", () => {
  test("should call prepareSequenceTable with the correct information", () => {
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

    queries.prepareSequenceTable(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "delete from setup.sequences where configuuid='12345';",
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

    queries.prepareSequenceTable(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});
