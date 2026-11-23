/**
 * Get getSupportFooter

 * @returns {BenefitSupportFooter}
 * @function getSupportFooter
 * @memberof ipaBenefitService
 *
 * @example
 * ...
*/

import MockData from 'c/ipaMockData';
export default () => {
    console.log('getSupportFooterlwc');
    console.log('getSupportFooterlwc', MockData.BenfitSupportFooter());

    return Promise.resolve(MockData.BenfitSupportFooter());
}