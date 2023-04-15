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

describe("getLoginData", () => {
  test("should call pool.query with the correct SQL query", () => {
    const request = {
      params: {
        username: "testuser",
      },
    };
    const response = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
      send: jest.fn(),
    };
    const mockPool = new Pool();
    const mockQueryResult = {
      rows: [{ password: "testpassword" }],
    };
    mockPool.query.mockImplementation((query, callback) => {
      callback(null, mockQueryResult);
    });

    queries.getLoginData(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      "SELECT password from login.users where username='testuser'",
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(200);
    expect(response.json).toHaveBeenCalledWith(mockQueryResult.rows);
  });

  test("should handle errors", () => {
    const request = {
      params: {
        username: "testuser",
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

    queries.getLoginData(request, response);

    expect(mockPool.query).toHaveBeenCalledWith(
      expect.any(String),
      expect.any(Function)
    );
    expect(response.status).toHaveBeenCalledWith(400);
    expect(response.send).toHaveBeenCalledWith(mockError);
  });
});
