import MockData from 'c/ipaMockData';
import getUserNotification from "@salesforce/apex/IPABenefitUtility.getNotificationList";
import updateReadNotification from "@salesforce/apex/IPABenefitUtility.setReadVisibility";
import updateDeleteNotification from "@salesforce/apex/IPABenefitUtility.setDeleteIndicator";
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
const getNotificationResult = (userId, notificationView) => {
    let resultdata;
    return getUserNotification({
        userId: userId,
        notificationView: notificationView
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


export const getPartnerMessages = () => {
    // console.log(`%cMock Data:  (getPartnerMessages)  `, 'color: #1798c1; font-weight: bold', MockData.PartnerMessages());
    // return Promise.resolve(MockData.PartnerMessages());
    console.log("ale");
    return getNotificationResult(userId, 'Home Notification');

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
        if (result != undefined && result != null) {
            console.log("PartnerMessageupdate>>>", JSON.parse(JSON.stringify(result)));
            resultdata = result;
            return Promise.resolve(resultdata);
            // return Promise.resolve({ success: true, messageId: messageId, type: type });
        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
        // return Promise.reject(error);
    });
}

const updateMessageEmail1 = (messageId, type) => {
    let resultdata;
    return updateDeleteNotification({
        recordId: messageId,
        type: type
    }).then(result => {
        if (result != undefined && result != null) {
            console.log("PartnerMessageupdate1>>>", JSON.parse(JSON.stringify(result)));
            resultdata = result;
            return Promise.resolve(resultdata);
            // return Promise.resolve({ success: true, messageId: messageId, type: type });
        }
    }).catch(error => {
        console.log("this.error" + JSON.stringify(error));
        // return Promise.reject(error);
    });
}

export const markMessageAsRead = (messageId, type) => {
    //console.log(`%cMock Data:  (markMessageAsRead)  `, 'color: #1798c1; font-weight: bold', messageId, type);
    // return Promise.resolve({ success: true, messageId: messageId, type: type });
    console.log("msg" + messageId);
    console.log("type" + type);
    return updateMessageEmail(messageId, type);}

export const markMessageAsDelete = (messageId,type) => {
    //console.log(`%cMock Data:  (markMessageAsRead)  `, 'color: #1798c1; font-weight: bold', messageId, type);
    // return Promise.resolve({ success: true, messageId: messageId, type: type });
    console.log("msg" + messageId);
    console.log("type" + type);
    return updateMessageEmail1(messageId, type);

}