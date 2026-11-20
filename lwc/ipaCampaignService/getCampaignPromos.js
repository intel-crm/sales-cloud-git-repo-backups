/**
 * Get Campaign Promos
 * @param {Object} params @AuraEnabled Method Parameters
 * @param {string} params.campaignId campaign Id
 * @returns {Campaign[]} Campaign Response for Promos Carousel
 * @function getCampaignPromos
 * @memberof ipaCampaignService
*/

// mock data
// import MockData from "c/ipaMockData";

export default async ({ campaignId }) => {
    let promos = [];
    while (promos.length < (Math.floor(Math.random() * 10) + 1)) {
        promos.push({
            image: 'https://www.intel.com/content/dam/www/public/us/en/images/corporate/rwd/csr-2019-header-graphic-rwd.jpg.rendition.intel.web.576.324.jpg',
            title: 'Promo-' + promos.length,
            description: 'Eligendi itaque consequatur esse magni labore alias rerum rerum sapiente Amet proident incididunt ut cillum nulla sit duis. Non amet mollit sit aute voluptate proident excepteur fugiat laborum ad consequat adipisicing officia. Occaecat culpa minim culpa pariatur ut nostrud. Officia reprehenderit dolor magna minim nostrud pariatur officia velit pariatur. Cupidatat laborum cupidatat officia ullamco velit reprehenderit consequat.'.slice(0, Math.floor(Math.random() * 500)),
            linkLabel: 'Lorem ipsum delor',
            linkExternalUrl: 'www.intel.com' //TODO: Navigate to event detail page
        });
    }
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    await new Promise(r => setTimeout(r, 1000)) // REMOVE! mock server delay
    return promos;
}