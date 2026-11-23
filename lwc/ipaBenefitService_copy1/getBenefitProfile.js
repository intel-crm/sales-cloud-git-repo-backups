/**
 * Get Benefit Profile

* @returns {BenefitProfile}
* @function getBenefitProfile
* @memberof ipaBenefitService
*
* @example
* ...
*/


import getProfileBenefit from "@salesforce/apex/IPABenefitUtility.getProfileInfo";
import UserId from '@salesforce/user/Id';

import MockData from 'c/ipaMockData';

const getBenefitProfile = (userId) => {
    let resultdata;
    return getProfileBenefit({
        userID: userId
    }).then(result => {
        if (result != undefined && result != null) {
        console.log("this.records1 ", JSON.parse(JSON.stringify(result)));
        resultdata = result;
        return Promise.resolve(resultdata);
        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
       // return Promise.reject(error);
    });
}

export default () => {
    console.log('getBenefitprofile.js');
    // console.log('getBenefitService', MockData.Benefits());
    // return Promise.resolve(MockData.Benefits());
    return getBenefitProfile(UserId);
}


/*const getBenefitProfile = (cmp) => {
    console.log('getBenefitProfile3');


    getProfileBenefit({
        userID: cmp
    })
        .then(result => {
            console.log("this.records3 " + JSON.stringify(result));

        })
        .catch(error => {
            console.log("this.erro3" + JSON.stringify(error));
        });

}

//export default { getBenefitProfile }
export default () => {
    console.log('getBenefitProfilejs');
    console.log('getBenefitProfile', MockData.BenefitProfile());
    return Promise.resolve(MockData.BenefitProfile());
}*/

/*export default class getBenefitProfile extends LightningElement {



    connectedCallback() {
        console.log('getBenefitProfilejs');
        console.log('getBenefitProfile', MockData.BenefitProfile());
        return Promise.resolve(MockData.BenefitProfile());

        console.log('getBenefitProfile9');
        // show variant based on product id
        /*  getProfileBenefit({
              userID: '0058A000004C0JPQA0'
  
          })
              .then(result => {
                  console.log("this.records " + JSON.stringify(result));
  
              })
              .catch(error => {
                  console.log("this.error" + JSON.stringify(error));
  
              });

    }*/
    // wiredContactResults;


    /* @wire(getProfileBenefit, { UserID: '0058A000004C0JPQA0' }) //$recordId
     getProfileData(result) {
         // this.wiredContactResults = result;
         if (result.data) {
    
             console.log("data>>" + JSON.stringify(result.data));
             //  this.notificationDisplay = result.data;
             //console.log('datatrack>>' + JSON.stringify(this.notificationDisplay));
             // this.errors = undefined;
             const da = result.data;
             return Promise.resolve(da);
         }
         else if (result.error) {
             console.log('error>>' + JSON.stringify(result.error));
    
             //this.notificationDisplay = undefined;
             // this.errors = result.error;
         }
     }*/

//}