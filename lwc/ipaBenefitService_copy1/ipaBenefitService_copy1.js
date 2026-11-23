//import { LightningElement } from 'lwc';
import getBenefits from './getBenefits';
// import messages from './getMessages';
// import quickLinks from './getQuickLinks';
import getBenefitProfile from './getBenefitProfile';
import getSupportFooter from './getSupportFooter';
//import getProfileBenefit from "@salesforce/apex/IPABenefitUtility.getProfileInfo";
import getPartnerQuickLinks from './getPartnerQuicklinks';
import { getPartnerMessages, markMessageAsRead } from './partnerMessage';
import { getPartnerMessagesViewAll, markMessageAsReadViewAll } from './partnerMessageViewAll';



export default {
    getBenefits,
    getBenefitProfile,
    getPartnerMessages,
    markMessageAsRead,
    getPartnerMessagesViewAll,
    getPartnerQuickLinks,
    getSupportFooter
}


/*const getBenefitProfile = (userId) => {

    //return Promise.resolve(MockData.BenefitProfile());
    console.log('getBenefitProfile2');
    var resultdata;
    getProfileBenefit({
        userID: userId
    })
        .then(result => {
            console.log("this.records1 " + JSON.stringify(result[0]));
            resultdata = result[0];

            //return Promise.resolve(resultdata);
        })
        .catch(error => {
            console.log("this.error" + JSON.stringify(error));
        });

    ///return resultdata;
}*/
//console.log("this.getBenefitProfile" + JSON.stringify(getBenefitProfile));
/*export default () => {
    console.log('getBenefitProfilejs1');
    // console.log('getBenefitProfile', MockData.BenefitProfile());
    return Promise.resolve(getBenefitProfile);
}
export default { getBenefitProfile, getBenefits, getSupportFooter }*/