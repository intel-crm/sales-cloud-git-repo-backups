/**
 * Get Benefits

 * @returns {Benefit[]}
 * @function getBenefits
 * @memberof ipaBenefitService
 *
 * @example
 * ...
*/

import MockData from 'c/ipaMockData';
export default () => {
    console.log('getBenefitServicelwc');
    console.log('getBenefitServicelwc', MockData.Benefits());
    return Promise.resolve(MockData.Benefits());
}