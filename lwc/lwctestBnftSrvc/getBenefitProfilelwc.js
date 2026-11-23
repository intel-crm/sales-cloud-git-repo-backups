/**
 * Get Benefit Profile

 * @returns {BenefitProfile}
 * @function getBenefitProfile
 * @memberof ipaBenefitService
 *
 * @example
 * ...
*/
import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc';
//import MockData from 'c/ipaMockData';
//import getProfileBenefit from "@salesforce/apex/IPABenefitUtility.getProfileInfo";
//Option 1: Default - Call the MockData method
/*export default () =>
{
    console.log('getBenefitProfilelwc');
    console.log('getBenefitProfilelwc', MockData.BenefitProfile());
    return Promise.resolve(MockData.BenefitProfile());
}*/

//Option 2: Not an option
/*export default class getBenefitProfile extends LightningElement {
    connectedCallback() {
        console.log('getBenefitProfilelwc-conn');
       console.log('getBenefitProfilelwc-conn', MockData.BenefitProfile());
       return Promise.resolve(MockData.BenefitProfile());
    }
}*/

//Option 3: Calling the Apex method imperatively through ConnectedCallback
/*export default class getBenefitProfilelwc extends LightningElement {
    connectedCallback() {
        console.log('getBenefitProfile999');
        //imperative method
        getProfileBenefit({
            userID: '0058A000004C0JPQA0'
        })
            .then(result => {
                console.log("this.records " + JSON.stringify(result));
            })
            .catch(error => {
                console.log("this.error" + JSON.stringify(error));
            });
    }
}*/

//Option 4: Apex Wire services
/*export default class getBenefitProfilelwc extends LightningElement {
    @wire(getProfileBenefit, { UserID: '0058A000004C0JPQA0' }) //$recordId
    getProfileData(result) {
        // this.wiredContactResults = result;
        if (result.data) 
        {
            console.log("data>>" + JSON.stringify(result.data));
            const da = result.data;
            return Promise.resolve(da);
        }
        else if (result.error) 
        {
            console.log('error>>' + JSON.stringify(result.error));
        }
    }
} */

/**
 * Get Benefit Profile

 * @returns {BenefitProfile}
 * @function getBenefitProfile
 * @memberof ipaBenefitService
 *
 * @example
 * ...
*/

import MockData from 'c/ipaMockData';
import getProfileBenefit from "@salesforce/apex/IPABenefitUtility.getProfileInfo";

const getBenefitProfilelwc = (userId) => {
    let resultdata;
    return getProfileBenefit({
        userID: userId
    }).then(result => {
            console.log("this.records1 ", JSON.parse(JSON.stringify(result[0])));
            resultdata = result[0];
            return Promise.resolve(resultdata);
    }).catch(error => {
            console.log("this.error" + JSON.stringify(error));
            return Promise.reject(error);
    });
}

export default () => {
    // console.log(`%cMock Data:  (getBenefitProfile)  `, 'color: #1798c1; font-weight: bold',
    // MockData.BenefitProfile());
    // return Promise.resolve(MockData.BenefitProfile());
    // Do we need a user id from the front end? or can this be taken from the server
    return getBenefitProfilelwc('0058A000004C0JPQA0');
   
}