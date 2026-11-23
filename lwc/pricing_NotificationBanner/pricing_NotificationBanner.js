import { LightningElement, track } from 'lwc';
import NotificationBannerText from '@salesforce/label/c.Pricing_Tender_NotificationBannerText';

export default class Pricing_NotificationBanner extends LightningElement {

    label = {
        NotificationBannerText,
    };

    // @track hasRendered = true;
    // get isNotificationDismissed() {
    //     return this.getCookie('IQR_Notification_Dismissed');
    // }

    // renderedCallback() {
    //     if (this.hasRendered) {
    //         this.showHideNotification();
    //         this.hasRendered = false;
    //     }
    // }

    // showHideNotification() {
    //     let isDismissed = this.getCookie('IQR_Notification_Dismissed');  // NOSONAR
    //     let divNotification = this.template.querySelector('[data-id="divNotification"]');  // NOSONAR
    //     if (divNotification) {
    //         this.template.querySelector('[data-id="divNotification"]').classList.add(isDismissed ? 'hideNotification' : 'showNotification');
    //     }
    // }

    // dismissNotofication() {
    //     this.createCookie('IQR_Notification_Dismissed', true, 365);
    //     this.showHideNotification();
    // }

    // createCookie(name, value, days) {
    //     var expires;
    //     if (days) {
    //         const date = new Date();
    //         date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    //         expires = "; expires=" + date.toGMTString();
    //     } else {
    //         expires = "";
    //     }

    //     document.cookie = name + "=" + value + expires + "; path=/";
    // }

    // getCookie(key) {
    //     var cookieVal = this.retriveCookie();
    //     var value;
    //     if (cookieVal != '') {
    //         for (let i = 0; i < cookieVal.length; i++) {
                
    //             if (cookieVal[i].includes(key)) {
    //                 value = cookieVal[i].split('=')[1];
    //             }
    //         }
    //     } else {
    //         value = '';
    //     }
    //     return value;
    // }

    // retriveCookie() {

    //     var cookieString = decodeURIComponent(document.cookie);
    //     var cookieStrArray = cookieString.split("; ");
    //     return cookieStrArray;
    // }
}