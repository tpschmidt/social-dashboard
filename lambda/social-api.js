const { DynamoDB } = require("aws-sdk");
const { DateTime, Interval } = require("luxon");
const { timestampToString, PLATFORMS } = require("./util/helper");

const client = new DynamoDB({ region: "eu-central-1" });
const TableName = process.env.TABLE_NAME
  ? process.env.TABLE_NAME
  : "social-platform-data";

module.exports.handler = async (event) => {
  const query = event ? event.queryStringParameters : undefined;
  let since = DateTime.utc().minus({ weeks: 1 });
  const now = DateTime.utc();
  if (query && query.since) {
    const sinceQuery = DateTime.fromFormat(query.since, "yyyyLLdd-HHmmss");
    since = sinceQuery.isValid ? sinceQuery : since;
  }
  const diff = Interval.fromDateTimes(since, now);
  console.log(
    `Getting data [since=${timestampToString(since)}, ` +
      `days=${diff.length("days").toFixed()}, hours=${diff
        .length("hours")
        .toFixed()}]`
  );
  const results = {};
  await Promise.all(
    PLATFORMS.map(async (p) => {
      let data = await getData(p.name, since);
      if (data.length > 0) {
        const platformName = data[0].platform;
        data.forEach((platformResult) => delete platformResult.platform);
        if (diff.length("days") > 2) {
          // if data is for more than 2 days, we cluster the last 24h also
          data = filterLastOfADay(data);
        }
        results[platformName] = {
          name: p.name,
          url: p.url,
          data,
        };
      }
    })
  );
  return {
    statusCode: 200,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(results),
  };
};

function filterLastOfADay(data) {
  const dataPerDay = {};
  data.forEach((d) => (dataPerDay[d.timestamp.substring(0, 8)] = d));
  const toKeep = Object.values(dataPerDay);
  return data.filter((d) => toKeep.includes(d));
}

async function getData(platform, since) {
  const data = await client
    .query({
      TableName,
      KeyConditionExpression:
        "#platform = :platform and #timestamp > :timestamp",
      ExpressionAttributeNames: {
        "#timestamp": "timestamp",
        "#platform": "platform",
      },
      ExpressionAttributeValues: {
        ":platform": { S: platform },
        ":timestamp": { S: timestampToString(since) },
      },
    })
    .promise();
  return data.Items.map(DynamoDB.Converter.unmarshall).sort((a, b) =>
    a.timestamp < b.timestamp ? -1 : 1
  );
}

if (!process.env.AWS_LAMBDA_FUNCTION_NAME) {
  this.handler().then((data) => console.log(data));
}
