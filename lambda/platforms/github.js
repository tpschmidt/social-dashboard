const { getVariable } = require("../util/helper");
const axios = require("axios");

const config = {
  headers: { "Content-Type": "application/json" },
  timeout: 5000,
};

async function getGithub() {
  const result = await axios.get(
    `https://api.github.com/users/${getVariable(
      "crawler_github_handle"
    )}/followers`,
    config
  );
  const followers = result.data.length;
  return { name: "github", followers };
}

module.exports = { getGithub };
