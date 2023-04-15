const queries = require("../../queries");
const fs = require("fs");

// Mock the 'fs' module using Jest
jest.mock("fs", () => ({
  readFileSync: jest.fn(),
  writeFileSync: jest.fn(),
}));

describe("getDatabaseSettings", () => {
  test("should return database settings", () => {
    const mockSettings = {
      host: "localhost",
      port: 5432,
      username: "testuser",
      password: "testpassword",
      database: "testdatabase",
    };

    // Mock the 'readFileSync' method to return the mock settings object
    fs.readFileSync.mockReturnValue(mockSettings);

    // Create mock request and response objects
    const req = {};
    const res = {
      send: jest.fn(),
    };

    // Call the function with the mock request and response objects
    queries.getDatabaseSettings(req, res);

    // Check that the response status is not an error
    expect(res.send).toHaveBeenCalledWith(mockSettings);
  });
});

describe("updateDatabaseSettings", () => {
  test("should write new database settings", () => {
    const req = {
      body: {
        host: "localhost",
        port: 5432,
        username: "testuser",
        password: "testpassword",
        database: "testdatabase",
      },
    };

    // Create mock response object
    const res = {};

    // Call the function with the mock request and response objects
    queries.updateDatabaseSettings(req, res);

    // Check that the 'writeFileSync' method was called with the correct arguments
    expect(fs.writeFileSync).toHaveBeenCalledWith(
      "./settings.json",
      JSON.stringify(req.body)
    );
  });
});
