const { DateTime } = require("luxon");

function getVariable(name) {
    const path = `${__dirname}/../${process.env.AWS_LAMBDA_FUNCTION_NAME ? '' : '../'}configuration.json`;
    return require(path)[name]
}

const PLATFORMS = [
    { name: 'twitter', url: `https://twitter.com/@${getVariable('crawler_twitter_handle')}`},
    { name: 'medium', url: `https://medium.com/@${getVariable('crawler_medium_handle')}`},
    { name: 'dev', url: `https://dev.to/${getVariable('crawler_dev_handle')}`},
    { name: 'hashnode', url: `https://hashnode.com/@${getVariable('crawler_hashnode_handle')}`},
    { name: 'reddit', url: `https://www.reddit.com/user/${getVariable('crawler_reddit_handle')}`},
    { name: 'stackoverflow', url: `https://stackoverflow.com/users/${getVariable('crawler_stackoverflow_user_id')}`},
    { name: 'github', url: `https://github.com/${getVariable('crawler_github_handle')}`},
    { name: 'hackernews', url: `https://news.ycombinator.com/user?id=${getVariable('hackernews_handle')}`},
    { name: 'revue', url: `https://www.getrevue.co/app/lists`},web
    { name: 'convertkit', url: `https://app.convertkit.com/subscribers`}
];

function timestampToString(ts) {
    return ts.toFormat('yyyyLLdd-HHmmss')
}

function stringToTimestamp(ts) {
    return DateTime.fromFormat(ts, 'yyyyLLdd-HHmmss')
}

module.exports = { getVariable, PLATFORMS, timestampToString };