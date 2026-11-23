/**
 * Get Benefits

 * @returns {ipaBenefitService.Benefit[]}
 * @function getBenefits
 * @memberof ipaBenefitService
 *
 * @example
 * ...
*/
import MockData from 'c/ipaMockData';

import getBenefits from '@salesforce/apex/IPABenefitUtility.getBenefitsInfo';
import UserId from '@salesforce/user/Id';

const getBenefitResult = (userId) => {
    let resultdata;
    return getBenefits({
        userId: userId
    }).then(result => {
        if (result != undefined && result != null) {
            console.log("Benefits are->>>>",JSON.stringify(result));
            console.log("Benefits>> ", JSON.parse(JSON.stringify(result)));
            resultdata = result;
            return Promise.resolve(resultdata);
        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
        //return Promise.reject(error);
    });
}

export default () => {
    //console.log(`%cMock Data:  (getBenefitService)  `, 'color: #1798c1; font-weight: bold', MockData.Benefits());
    //return Promise.resolve(MockData.Benefits());
    return getBenefitResult(UserId);
}