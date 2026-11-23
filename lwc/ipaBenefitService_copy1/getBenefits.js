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
import getBenefits from '@salesforce/apex/IPABenefitUtility.getBenefitsInfo';
import UserId from '@salesforce/user/Id';

const getBenefitResult = (userId) => {
    let resultdata;
    return getBenefits({
        userId: userId
    }).then(result => {
        if (result != undefined && result != null) {
            console.log("this.records1 ", JSON.parse(JSON.stringify(result[0])));
            resultdata = result;
            return Promise.resolve(resultdata);
        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
        //return Promise.reject(error);
    });
}

export default () => {
    // console.log('getBenefitService');
    // console.log('getBenefitService', MockData.Benefits());
    // return Promise.resolve(MockData.Benefits());
    return getBenefitResult(UserId);
}

/*export default class GetBenefits extends LightningElement {

   // console.log('getBenefitService');
   // console.log('getBenefitService', MockData.Benefits());
   // return Promise.resolve(MockData.Benefits());

    Benefits(){

    Promise.resolve(getBenefits({
        UserId: '0058A000004C0JPQA0',

    })
        .then((result) => {
            console.log('res' + JSON.stringify(result));

        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        }); )

   }
  //return Promise.resolve(Benefits());
}*/
/*
export default class GetBenefits extends LightningElement
{

   @wire(getBenefits,{UserId:'0058A000004C0JPQA0'})
   benefits(result){
    if (result.data) {
      console.log('Userbenefit--->'+JSON.stringify(result.data));

    } else if (result.error) {
        console.log('error'+JSON.stringify(result.error));
    }
   }
}*/