const { getTwitter } = require("./platforms/twitter");
const { getHashNode } = require("./platforms/hashnode");
const { getDev } = require("./platforms/dev");
const { getMedium } = require("./platforms/medium");
const { getReddit } = require("./platforms/reddit");
const { DynamoDB } = require("aws-sdk");
const { DateTime } = require("luxon");
const { getStackOverflow } = require("./platforms/stackoverflow");
const { getGithub } = require("./platforms/github");
const { getHackerNews } = require("./platforms/hackernews");
const { getRevue } = require("./platforms/revue");
const { getConvertKit } = require("./platforms/convertkit");

const TableName = process.env.TABLE_NAME
  ? process.env.TABLE_NAME
  : "social-platform-data";
const client = new DynamoDB({ region: "eu-central-1" });

module.exports.handler = async () => {
  const data = await Promise.allSettled([
    getTwitter(),
    getMedium(),
    getReddit(),
    getHashNode(),
    getDev(),
    getStackOverflow(),
    getGithub(),
    getHackerNews(),
    getRevue(),
    getConvertKit(),
  ]);
  const fulfilled = data
    .filter((d) => d.status === "fulfilled")
    .map((v) => v.value);
  const rejected = data
    .filter((d) => d.status === "rejected")
    .map((v) => v.reason);
  if (rejected.length) {
    console.log(`Rejected: ${JSON.stringify(rejected)}`);
  }
  await saveToDynamoDb(fulfilled);
};

async function saveToDynamoDb(data) {
  return Promise.all(
    data
      .filter((d) => d && d.name)
      .map((d) => {
        const Item = {
          platform: { S: d.name },
          timestamp: { S: DateTime.utc().toFormat("yyyyLLdd-HHmmss") },
        };
        if (d.followers) Item.followers = { N: String(d.followers) };
        if (d.posts) Item.posts = { N: String(d.posts) };
        if (d.karma) Item.karma = { N: String(d.karma) };
        if (d.reactions) Item.reactions = { N: String(d.reactions) };
        if (d.reputation) Item.reputation = { N: String(d.reputation) };
        console.log(`Submitting Data to DynamoDB`);
        console.log(JSON.stringify(Item));
        return client.putItem({ TableName, Item }).promise();
      })
  );
}

if (!process.env.AWS_LAMBDA_FUNCTION_NAME) {
  this.handler();
}
