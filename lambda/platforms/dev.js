const { getVariable } = require("../util/helper");
const axios = require("axios");

const config = {
  headers: {
    "Content-Type": "application/json",
    "api-key": getVariable("crawler_dev_api_key"),
  },
  params: { per_page: "1000" },
};

async function getDev() {
  let followersQuery = axios.get("https://dev.to/api/followers/users", config);
  let articlesQuery = axios.get("https://dev.to/api/articles/me/all", config);
  const [f, a] = await Promise.all([followersQuery, articlesQuery]);
  const followers = f.data.length;
  const posts = a.data.length;
  return { name: "dev", followers, posts };
}

module.exports = { getDev };
