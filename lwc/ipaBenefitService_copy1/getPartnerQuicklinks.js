/**
 * Get Benefit Profile

 * @returns {ipaBenefitService.PartnerQuickLinks}
 * @function getPartnerQuickLinks
 * @memberof ipaBenefitService
 *
 * @example
 * ...
*/

import MockData from 'c/ipaMockData';

import getQuickLinks from '@salesforce/apex/IPABenefitUtility.getPartnerQuickLinks';
import userId from '@salesforce/user/Id';

const getQuickLinkResult = (userId) => {
    let resultdata;
    return getQuickLinks({
        userId: userId
    }).then(result => {
        if (result != undefined && result != null) {
            console.log("Quicklinks>> ", JSON.parse(JSON.stringify(result)));
            resultdata = result;
            return Promise.resolve(resultdata);
        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
        //  return Promise.reject(error);
    });
}
export default () => {
    //console.log(`%cMock Data:  (getPartnerQuickLinks)  `, 'color: #1798c1; font-weight: bold',
    //    MockData.PartnerQuickLinks());
    //return Promise.resolve(MockData.PartnerQuickLinks());
    return getQuickLinkResult(userId);
}