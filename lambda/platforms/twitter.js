const {TwitterClient} = require("twitter-api-client");
const {getVariable} = require("../util/helper");

const apiKey = getVariable('crawler_twitter_api_key');
const apiSecret = getVariable('crawler_twitter_api_secret_key');
const accessToken = getVariable('crawler_twitter_api_access_token');
const accessTokenSecret = getVariable('crawler_twitter_api_access_secret');
const screen_name = getVariable('crawler_twitter_handle');

const twitterClient = new TwitterClient({apiKey, apiSecret, accessToken, accessTokenSecret});

async function getTwitter() {
    const status = await twitterClient
        .accountsAndUsers
        .usersShow({
            screen_name,
            include_entities: false,
    }).catch(err => console.error(err))
    return {
        name: 'twitter',
        followers: status.followers_count
    };
}

module.exports = {getTwitter};