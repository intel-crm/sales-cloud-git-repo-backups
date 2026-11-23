/**
 * Get Campaign Cards ( Partner / Product )
 * @param {Object} params @AuraEnabled Method Parameters
 * @param {string} params.campaignId campaign Id
 * @param {string} params.cardType required - can be 'partner' or 'product'
 * @param {number} [params.page] page number for results (only used if lazy loading data)
 * @param {number} [params.perPage] per page count for results (only used if lazy loading data)
 * @returns {object} response format: <code>{ heading: '', cards: Product|Partner[], total: number }</code><br><b>heading</b> - example: 'Covid-19 Offerings' / 'Covid-19 Partners'<br><i>(NOTE: Total is only needed for lazy loading)</i>
 * @function getCampaignCards
 * @memberof ipaCampaignService
 *
 * @example
 * ...
*/

// mock data
// import MockData from "c/ipaMockData";
import partners from '@salesforce/label/c.PMP_L2_Tab_Partners';
//import offerings from '@salesforce/label/c.PMP_Marketplace_Offerings';//IPA2.0:US-4497-1631_OfferingEOL
import getCampaignDetails from '@salesforce/apex/PMP_SearchEventDetailController.getCampaignCardDetails';
import USERLANG from '@salesforce/i18n/lang';

// page and perPage are only needed if lazy loading... NOTE: MIGHT NOT NEED TO IMPLEMENT LAZY LOADING AT ALL
export default async ({ campaignId, cardType, page, perPage }) => {
    let log = false;
    if (log) console.log('getCampaignCards params: ', campaignId, cardType, page, perPage);
    let response = {};            
        await getCampaignDetails({campaignId : campaignId ,cardType : cardType,langCode : USERLANG, currentPage :page, pageSize :perPage })
            .then(result => {             
                response = result;            
            })
            .catch(error => {           
                console.log('Error in campaign Service');
            });
              

    let cards = [];
    let total = 0;
    let campaignName='';
    campaignName = response.name; 
    if (cardType === 'partner') { 
       cards = response.partnerCards;
       total = response.partnerTotal;
        
    }

    if (cardType === 'product') {
        cards = response.productCards;
        total = response.productTotal;
    }
    return {
        //IPA2.0:US-4497-1631_OfferingEOL
        //heading: campaignName + ' '+(cardType === 'partner' ? partners : offerings),
        heading: campaignName + ' '+ partner,
        cards,
        total,
    };
}