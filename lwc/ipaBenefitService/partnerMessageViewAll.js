import MockData from 'c/ipaMockData';
import getUserNotificationViewAll from "@salesforce/apex/IPABenefitUtility.getNotificationList";
import updateReadNotificationViewAll from "@salesforce/apex/IPABenefitUtility.setReadVisibility";
import userId from '@salesforce/user/Id';
/**
 * Get Partner Messages View all list
 * @returns {PartnerMessages}
 * @function getPartnerMessages
 * @memberof ipaBenefitService
 *
 * @example
 * ...
*/
const getNotificationResult = (userId, notificationView) => {
    let resultdata;
    return getUserNotificationViewAll({
        userId: userId,
        notificationView, notificationView
    }).then(result => {
        if (result != undefined && result != null) {
            console.log("Notification>>>", JSON.parse(JSON.stringify(result)));
            resultdata = result;
            return Promise.resolve(resultdata);
        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
        //return Promise.reject(error);
    });
}


export const getPartnerMessagesViewAll = () => {
    //console.log(`%cMock Data:  (getPartnerMessages)  `, 'color: #1798c1; font-weight: bold',    MockData.PartnerMessages());
    //return Promise.resolve(MockData.PartnerMessages());
    // console.log("ale");
    return getNotificationResult(userId, 'View All Notification');

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
    return updateReadNotificationViewAll({
        recordId: messageId,
        type: type
    }).then(result => {
        if (result != undefined && result != null) {
            console.log("PartnerMessageupdate>>>", JSON.parse(JSON.stringify(result)));
            resultdata = result;
            return Promise.resolve(resultdata);
            // return Promise.resolve({ success: true, messageId: messageId, type: type });
        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
        //return Promise.reject(error);
    });
}



export const markMessageAsReadViewAll = (messageId, type) => {
    //console.log(`%cMock Data:  (markMessageAsRead)  `, 'color: #1798c1; font-weight: bold',
    //    messageId, type);
    // return Promise.resolve({ success: true, messageId: messageId, type: type });
    return updateMessageEmail(messageId, type);
}