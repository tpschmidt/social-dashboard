const {getVariable} = require("../helper");
const axios = require("axios");
const qs = require('qs');

const data = qs.stringify({
    'grant_type': 'password',
    'username': getVariable('crawler_reddit_handle'),
    'password': getVariable('crawler_reddit_password')
});
const config = {
    method: 'post',
    url: 'https://www.reddit.com/api/v1/access_token',
    headers: { ContentType: 'application/x-www-form-urlencoded'},
    auth: {
        username: getVariable('crawler_reddit_client_id'),
        password: getVariable('crawler_reddit_client_secret')
    },
    data
};

async function getReddit() {
    const {data: {access_token}} = await axios(config).catch(function (error) {
        console.log(error)
    });
    const karmaList = await axios.get('https://oauth.reddit.com/api/v1/me/karma', {
        headers: {Authorization: 'Bearer ' + access_token}
    });
    const karma = karmaList.data.data.reduce((acc, cur) => acc + cur.link_karma, 0);
    return {name: "reddit", karma};
}

module.exports = {getReddit: getReddit};