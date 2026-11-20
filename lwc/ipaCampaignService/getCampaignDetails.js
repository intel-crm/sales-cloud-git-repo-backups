/**
 * Get Campaign Details (for Marquee)
 * @param {Object} params @AuraEnabled Method Parameters
 * @param {string} params.campaignId campaign Id
 * @returns {Campaign} Campaign Response, includes details for Marquee
 * @function getCampaignDetails
 * @memberof ipaCampaignService
 *
 * @example
 * ...
*/

import getCampaignMarquee from '@salesforce/apex/PMP_SearchEventDetailController.getCampaignMarqueeDetails';
import errorPageURL from '@salesforce/label/c.PMP_Error_Page_URL';

export default async () => {

    let url = window.location.href;
    let splits = url.indexOf("pmp-marketplace-event/") != -1 ? url.split("pmp-marketplace-event/") : [];
    let campaignId = splits.length > 0 ? splits[1].split("/")[0] : '';
    let response = {};            
        await getCampaignMarquee({campaignId : campaignId})
            .then(result => {             
                response = result; 
                if(response.isInvalidEvent === true) {
                    window.location.href = errorPageURL;
                }           
            })
            .catch(error => {           
                console.log('Error in campaignmarquee Service');
            });
    return Promise.resolve(response);


}
// mock data
/*export default () => Promise.resolve({
    name: 'COVID-19',
    description: 'Voluptatem dignissimos nam nulla velit.',
    linkData: {
        label: 'Learn More', // is this dynamic?
        externalUrl: 'https://www.intel.com'
    }
})*/

// TODO - replace with real data
// export default ({ campaignId }) => ... aura method call