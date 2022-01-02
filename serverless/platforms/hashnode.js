const {getVariable} = require("../helper");
const axios = require("axios");

const config = {
    headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + getVariable('crawler_hashnode_token')
    },
    timeout: 5000
};
const query = `{
    user(username: "${getVariable("crawler_hashnode_handle")}") {
        numFollowers, numReactions, numPosts
    }
}`;

async function getHashNode() {
    const result = await axios.post('https://api.hashnode.com/', {query}, config)
    const followers = result.data.data.user.numFollowers;
    const reactions = result.data.data.user.numReactions;
    const posts = result.data.data.user.numPosts;
    return {name: "hashnode", followers, reactions, posts};
}

module.exports = {getHashNode};