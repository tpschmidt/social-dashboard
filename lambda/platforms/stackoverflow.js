const {getVariable} = require("../util/helper");
const axios = require("axios");

const userId = getVariable('crawler_stackoverflow_user_id');

async function getStackOverflow() {
    const result = await axios.get(`https://api.stackexchange.com/2.3/users/${userId}?&site=stackoverflow`)
    const reputation = result.data.items[0].reputation
    return {name: "stackoverflow", reputation};
}

module.exports = {getStackOverflow};