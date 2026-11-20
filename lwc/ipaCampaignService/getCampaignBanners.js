/**
 * Get Campaign Banners
 * @param {Object} params @AuraEnabled Method Parameters
 * @param {string} params.campaignId campaign Id
 * @returns {Campaign[]} Campaign Response for L3 Banner Carousel
 * @function getCampaignBanners
 * @memberof ipaCampaignService
 *s
 * @example
 * ...
*/

// mock data
// import MockData from "c/ipaMockData";
import langLocale from '@salesforce/i18n/lang'
import getBanners from '@salesforce/apex/PMP_SearchEventDetailController.getCampaignBannerDetails';

export default async () => {

    let url = window.location.href;
    let langCode = langLocale;
    if(langLocale.includes('-')){
        langCode = langLocale.replaceAll('-','_');
    }
    let isPartner = url.includes('/partner/') ? true: false;
    let  splits = url.indexOf("/partner/") != -1 ? url.split("/partner/") : [];
    let  splits2 = url.indexOf("/offering/") != -1 ? url.split("/offering/") : [];
    let partnerId = splits.length > 0 ? splits[1].split("/")[0] : splits2[1].split("/")[0];
    let response = {};            
        await getBanners({partnerId : partnerId,isPartner :isPartner, userLanguage : langCode})
            .then(result => {             
                response = result;            
            })
            .catch(error => {           
                console.log('Error in campaignBanner Service');
            });
    let banners = [];
    for(var i in response){
        banners.push({
            title: response[i].title,
            linkLabel: response[i].linkLabel,
            linkUrl: response[i].linkUrl,
            image : response[i].image,
            imageAlt : response[i].imageAlt
            });
        }
    return banners;
}