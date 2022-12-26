const { getVariable } = require("../util/helper");
const axios = require("axios");

const config = {
  headers: {
    "Content-Type": "application/json",
  },
  params: { api_secret: getVariable("convertkit_secret_key") },
};

async function getConvertKit() {
  const {
    data: { total_subscribers: followers },
  } = await axios.get("https://api.convertkit.com/v3/subscribers", config);
  return { name: "convertkit", followers };
}

module.exports = { getConvertKit };
