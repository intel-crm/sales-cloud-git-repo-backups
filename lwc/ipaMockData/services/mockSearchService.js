import { mockPartner } from '../objects/partner';
import { mockProduct } from '../objects/product';

let resultCounts = {};
resultCounts.TESTINGQUICKSEARCH = 8;
for (let i = 0; i < (Math.floor(Math.random() * 200) + 800); i++) {
    resultCounts['filterid' + i] = Math.floor(Math.random()*20);
}

for (let i = 0; i < 2000; i++) {
    resultCounts['processor' + i] = Math.floor(Math.random()*20) + 1;
}

for (let i = 0; i < 20; i++) {
    resultCounts['PartnerID00' + i] = Math.floor(Math.random()*20) + 1;
}

resultCounts.country_AL = Math.floor(Math.random()*20) + 1;
resultCounts.country_ALG = 0;
resultCounts.country_AUS = Math.floor(Math.random()*20) + 1;
resultCounts.country_US = Math.floor(Math.random()*20) + 1;
resultCounts.country_ZN = Math.floor(Math.random()*20) + 1;

export default { search: async (params = {}) => {
    if (window.MOCKDATA_SEARCH) {
        resultCounts = JSON.parse(window.MOCKDATA_SEARCH);
    }
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    await new Promise(r => setTimeout(r, 500)); // mock server request delay

    let results = [];

    if (params.category === 'a6y8A000000L8T3QAK') {
        while (results.length < 12) results.push(mockPartner({ member: Math.floor(Math.random()*2) === 1 }));
    } else if (params.category === 'a5N8A000000Co3gUAC') {
        while (results.length < 30) results.push(mockPartner({
            searchGrouping: 'dist' + (Math.floor(Math.random()*3) + 1)
        }));
        return {
            results,
            resultCounts,
            resultsPerPage: 0,
            totalResults: 30,
            totalPages: 1,
        }
    } else  {
        let count = params.page === 26 ? 5 : 12
        while (results.length < count) results.push(mockProduct());
    }

    // MOCK ERROR RESPONSE FOR ERROR HANDLING
    if (params.keyword === 'err') {
        throw new TypeError('Mock Error from Server');
    }

    // MOCK NO RESULTS RESPONSE
    if (params.keyword === 'noresults') {
        return {
            results: [],
            resultCounts: {},
            resultsPerPage: 12,
            totalResults: 0,
            totalPages: 0
        };
    }

    // MOCK NORMAL RESPONSE WITH RESULTS
    return {
        results,
        resultCounts,
        resultsPerPage: 12,
        totalResults: 305,
        totalPages: 26,
    };
}}