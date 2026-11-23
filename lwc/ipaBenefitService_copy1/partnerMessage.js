import MockData from 'c/ipaMockData';
import getUserNotification from "@salesforce/apex/IPABenefitUtility.getNotificationList";
import updateReadNotification from "@salesforce/apex/IPABenefitUtility.setReadVisibility";
import userId from '@salesforce/user/Id';
/**
 * Get Partner Messages
 * @returns {PartnerMessages}
 * @function getPartnerMessages
 * @memberof ipaBenefitService
 *
 * @example
 * ...
*/
const getNotificationResult = (userId) => {
    let resultdata;
    return getUserNotification({
        userId: userId
    }).then(result => {
        console.log("Notification>>>", JSON.parse(JSON.stringify(result)));

        if (result != undefined && result != null) {
            resultdata = result;
            return Promise.resolve(resultdata);
        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
        // return Promise.reject(error);
    });
}


export const getPartnerMessages = () => {
    //export default () => {
    //console.log(`%cMock Data:  (getPartnerMessages)  `, 'color: #1798c1; font-weight: bold',
    //    MockData.PartnerMessages());
    //return Promise.resolve(MockData.PartnerMessages());
    // console.log("ale");
    return getNotificationResult('0058A000004C0JPQA0');

}

/**
 * Mark message as read
 * @function markMessageAsRead
 * @param  {messageid} messageId the message id to be post back
 * @param  {messageType} type the type of message
 * @returns {Object} success or failure of the promise
 * @memberof ipaBenefitService  setReadVisibility

 */

const updateMessageEmail = (messageId, type) => {
    let resultdata;
    return updateReadNotification({
        recordId: messageId,
        type: type
    }).then(result => {
        console.log("updateNoti>>>", JSON.parse(JSON.stringify(result)));

        if (result != undefined && result != null) {
            resultdata = result;
            return Promise.resolve(resultdata);
            // return Promise.resolve({ success: true, messageId: messageId, type: type });

        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
        //return Promise.reject(error);
    });
}



export const markMessageAsRead = (messageId, type) => {
    //console.log(`%cMock Data:  (markMessageAsRead)  `, 'color: #1798c1; font-weight: bold',
    //    messageId, type);
    // return Promise.resolve({ success: true, messageId: messageId, type: type });
    return updateMessageEmail(messageId, type);
}