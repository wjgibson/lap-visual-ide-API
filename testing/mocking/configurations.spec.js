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

describe("updateConfigurationData", () => {
  test("should call updateConfigurationData with the correct information", () => {
    const request = {
      body: {
        jsonData: { foo: "bar" },
        cid: "123",
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

    queries.updateConfigurationData(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      `UPDATE reactflow.reactflowdata SET json = '{"foo":"bar"}' WHERE cid = '123'`,
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      body: {
        jsonData: { foo: "bar" },
        cid: "123",
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

    queries.updateConfigurationData(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});

describe("getConfigurationData", () => {
  test("should call getConfigurationData with the correct information", () => {
    const request = {
      params: {
        cid: "123",
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

    queries.getConfigurationData(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      `SELECT * FROM reactflow.reactflowdata WHERE cid = '123'`,
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      params: {
        cid: "123",
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

    queries.getConfigurationData(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});

describe("createNewConfiguration", () => {
  test("should call createNewConfiguration with the correct information", () => {
    const request = {
      body: {
        name: "test config",
        jsonData: {
          foo: "bar",
        },
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

    queries.createNewConfiguration(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "select setup.add_config('14f38f2c-97c2-46af-b79a-07672eb2f94e','test config', '{\"foo\":\"bar\"}');",
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      body: {
        name: "test config",
        jsonData: {
          foo: "bar",
        },
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

    queries.createNewConfiguration(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});

describe("insertNewConfiguration", () => {
  test("should call insertNewConfiguration with the correct information", () => {
    const request = {
      body: {
        name: "test config",
        jsonData: {
          foo: "bar",
        },
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

    queries.insertNewConfiguration(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "INSERT INTO reactflow.reactflowdata (json, name) VALUES ('{\"foo\":\"bar\"}', 'test config')",
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      body: {
        name: "test config",
        jsonData: {
          foo: "bar",
        },
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

    queries.insertNewConfiguration(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});

describe("getAllConfigurations", () => {
  test("should call getAllConfigurations with the correct information", () => {
    const request = {};
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

    queries.getAllConfigurations(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "SELECT * FROM setup.configurations",
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {};
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

    queries.getAllConfigurations(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});

describe("deleteConfig", () => {
  test("should call deleteConfig with the correct information", () => {
    const request = {
      body: {
        cid: "12345",
      },
    };
    const response = {
      status: jest.fn().mockReturnThis(),
      send: jest.fn(),
    };
    const mockPool = new Pool();
    const mockQueryResult = {
      rows: ["some", "data"],
    };
    mockPool.query.mockImplementation((query, callback) => {
      callback(null, mockQueryResult);
    });

    queries.deleteConfig(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "select setup.delete_config('12345');",
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.send).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      body: {
        cid: "12345",
      },
    };
    const response = {
      status: jest.fn().mockReturnThis(),
      send: jest.fn(),
    };
    const mockPool = new Pool();
    const mockError = new Error("Something went wrong");
    mockPool.query.mockImplementation((query, callback) => {
      callback(mockError, null);
    });

    queries.deleteConfig(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});
