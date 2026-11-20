/**
 * Get getSupportFooter

 * @returns {ipaBenefitService.PartnerSupportFooter}
 * @function getSupportFooter
 * @memberof ipaBenefitService
 *
 * @example
 * ...
*/

import MockData from 'c/ipaMockData';
export default () => {

    console.log(`%cMock Data:  (getSupportFooter)  `, 'color: #1798c1; font-weight: bold',
     MockData.PartnerSupportFooter());
    return Promise.resolve(MockData.PartnerSupportFooter());
}