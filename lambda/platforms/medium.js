const { getVariable } = require("../util/helper");
const axios = require("axios");

async function getMedium() {
  const result = await axios.get(`https://medium.com/@${getVariable("crawler_medium_handle")}?format=json`);
  if (!result) return;
  const data = JSON.parse(result.data.replace("])}while(1);</x>", ""));
  const socialStats = data.payload.references.SocialStats;
  const userId = Object.keys(socialStats)[0];
  return {
    name: "medium",
    followers: socialStats[userId].usersFollowedByCount,
  };
}

module.exports = { getMedium };
