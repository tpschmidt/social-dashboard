const {getVariable} = require("../util/helper");
const axios = require("axios");

const regex = /.*karma.*?:<\/td>.*?.*<td>[^0-9]*([0-9]*)/gm;

async function getHackerNews() {
    let response = await axios.get(`https://news.ycombinator.com/user?id=${getVariable('hackernews_handle')}`);
    const karma = Number(regex.exec(response.data.trim())[1]);
    return {name: 'hackernews', karma};
}

module.exports = {getHackerNews};