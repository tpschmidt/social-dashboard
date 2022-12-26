const { getVariable } = require("../util/helper");
const axios = require("axios");

const config = {
  headers: {
    "Content-Type": "application/json",
    Authorization: `Bearer ${getVariable("revue_api_key")}`,
  },
};

async function getRevue() {
  const response = await axios.get(
    "https://www.getrevue.co/api/v2/subscribers",
    config
  );
  const followers = response.data?.length ?? 0;
  return { name: "revue", followers };
}

module.exports = { getRevue };
