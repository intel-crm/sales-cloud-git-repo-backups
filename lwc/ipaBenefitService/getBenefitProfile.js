/**
 * Get Benefit Profile

 * @returns {ipaBenefitService.BenefitProfile}
 * @function getBenefitProfile
 * @memberof ipaBenefitService
 *
 * @example
 * ...
*/

import getProfileBenefit from "@salesforce/apex/IPABenefitUtility.getProfileInfo";
import UserId from '@salesforce/user/Id';

import MockData from 'c/ipaMockData';

const getBenefitProfile = (userId , pageType) => {
    //console.log('U benefit==>'+userId);
    console.log('pageTypeIn getBenefitProfile==>'+pageType);
    let resultdata;
    return getProfileBenefit({
        userID: userId,
        page: pageType
    }).then(result => {
        if (result != undefined && result != null) {
            console.log("User Profile ", JSON.parse(JSON.stringify(result)));
            resultdata = result;
            return Promise.resolve(resultdata);
        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
        // return Promise.reject(error);
    });
}



export default (pageType) => {
    //console.log(`%cMock Data:  (getBenefitProfile)  `, 'color: #1798c1; font-weight: bold', MockData.BenefitProfile());
    //return Promise.resolve(MockData.BenefitProfile());
    console.log("getBenefitProfile pagetype-------->"+pageType);
    return getBenefitProfile(UserId , pageType);
}