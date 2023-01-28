const Pool = require("pg").Pool;
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "LAP_PG",
  password: "password",
  port: 5432,
});

const createNewConfiguration = (request, response) => {
  console.log(request.body);
  let query = `select setup.add_config('14f38f2c-97c2-46af-b79a-07672eb2f94e','${
    request.body.name
  }', '${JSON.stringify(request.body.jsonData)}');`;
  console.log(query);
  pool.query(query, (error, results) => {
    if (error) {
      console.log(error);
      response.status(400).send(error);
    } else {
      response.status(200).json(results.rows);
    }
  });
};

module.exports = {
  createNewConfiguration,
};
