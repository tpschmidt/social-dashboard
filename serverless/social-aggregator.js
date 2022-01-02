const {DynamoDB} = require("aws-sdk");
const {DateTime} = require("luxon");
const {PLATFORMS, timestampToString} = require("./helper");

const TableName = process.env.TABLE_NAME ? process.env.TABLE_NAME : 'social-dashboard-platform-data';
const client = new DynamoDB({region: 'eu-central-1'});

module.exports.handler = async () => {
    const dayBeforeYesterday = DateTime.utc().minus({days: 2});
    const before = DateTime.fromObject({
        year: dayBeforeYesterday.year,
        month: dayBeforeYesterday.month,
        day: dayBeforeYesterday.day,
        hour: 23,
        minute: 59,
        second: 59,
        millisecond: 999
    }, {zone: 'utc'});
    const after = DateTime.utc().minus({days: 7});
    const data = await Promise.all(PLATFORMS.map(p => getData(p.name, before, after)));
    const toDelete = data.map(filterEverythingExceptLastOfADay);
    await Promise.all(toDelete.map(d => deleteData(d)));
}

async function deleteData(data) {
    console.log(`Deleting ${data.length} items from ${TableName}`);
    const size = 25;
    const chunks = [];
    while (data.length) {
        chunks.push(data.splice(0, size));
    }
    await Promise.all(chunks.map(chunk => {
        const params = {
            RequestItems: {[TableName]: chunk.map(toDeleteRequest)}
        };
        return client.batchWriteItem(params).promise();
    }))
}

function filterEverythingExceptLastOfADay(data) {
    const dataPerDay = {};
    data.forEach(d => dataPerDay[d.timestamp.substring(0, 8)] = d);
    const toKeep = Object.values(dataPerDay);
    return data.filter(d => !toKeep.includes(d));
}

function toDeleteRequest(d) {
    return {
        DeleteRequest: {
            Key: {
                platform: {S: d.platform},
                timestamp: {S: d.timestamp}
            }
        }
    }
}

async function getData(platform, before, after) {
    const data = await client.query({
            TableName,
            KeyConditionExpression: '#platform = :platform and #timestamp BETWEEN :after and :before',
            ExpressionAttributeNames: {
                '#timestamp': 'timestamp',
                '#platform': 'platform',
            },
            ExpressionAttributeValues: {
                ':platform': {S: platform},
                ':after': {S: timestampToString(after)},
                ':before': {S: timestampToString(before)},
            }
        }
    ).promise()
    return data.Items.map(DynamoDB.Converter.unmarshall)
        .sort((a, b) => a.timestamp > b.timestamp ? -1 : 1)
}

if (!process.env.AWS_LAMBDA_FUNCTION_NAME) {
    this.handler()
}

