/**
 * Get Featured Tabs for L0 Home Featured section.
 * @param {Object} params @AuraEnabled Method Parameters
 * @returns {FeaturedOfferingsResponse} Featured Offerings Response
 * @function getFeaturedOfferings
 * @memberof ipaOfferingService
 *
 * @example
 * ...
*/

//import MockData from 'c/ipaMockData';
//import getFeaturedTabs from '@salesforce/apex/PMP_SearchFeaturedCarouselController.getFeaturedTabs';


const getTabs = () => {
    // return new Promise(resolve => {
    //     getFeaturedTabs()
    //     .then(result => {
    //         window.console.log('getFeaturedTabs result : ', result);
    //         resolve(result);
    //     })
    //     .catch(error => {
    //         resolve(error);
    //     });
    // });
}



// eslint-disable-next-line @lwc/lwc/no-async-operation
//export default () => new Promise(resolve => setTimeout(() => { resolve(response); }, 2000));
// export default () => Promise.resolve(response);

export default {getTabs};