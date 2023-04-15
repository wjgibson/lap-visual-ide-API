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

describe("insertSubSequence", () => {
  test("should call insertSubSequence with the correct information", () => {
    const request = {
      body: {
        parentNodeId: "1",
        childNodeId: "2",
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

    queries.insertSubSequence(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "select setup.add_sub_seq('1','2','12345');",
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      body: {
        parentNodeId: "1",
        childNodeId: "2",
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

    queries.insertSubSequence(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});

describe("prepareSubSeqTable", () => {
  test("should call prepareSubSeqTable with the correct information", () => {
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

    queries.prepareSubSeqTable(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "delete from sequenceconfig.subsequences where configuuid='12345';",
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

    queries.prepareSubSeqTable(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});
