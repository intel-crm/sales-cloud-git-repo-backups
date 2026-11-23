/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for IPA Partner Message
 * <br>
 * <p>Ipa Partner Message Component uses the  {@link ipaBenefitService.PartnerMessage } object, and renders each message with toggle detail display. It also calls the {@link ipaBenefitService.markMessageAsRead()} service to mark the message as read.

 * @namespace ipaPartnerMessage
 * @property {ipaBenefitService.PartnerMessage} message partner message data containing types and icons for the message
 * @author Joshua Gonzalez
*/

import { LightningElement, api, track } from 'lwc';
import { markMessageAsRead } from 'c/ipaBenefitService';
import { markMessageAsDelete} from 'c/ipaBenefitService';


import markAsRead from '@salesforce/label/c.IPA_PartnerMessage_MarkAsRead';
import markAsDelete from '@salesforce/label/c.IPA_PartnerMessage_MarkAsDelete';
import markAsReadServiceError from '@salesforce/label/c.IPA_PartnerMessage_MarkAsReadErrorMessage';
import markAsDeleteServiceError from '@salesforce/label/c.IPA_PartnerMessage_MarkAsDeleteErrorMessage';


export default class IpaPartnerMessage extends LightningElement {
    @track _message;
    @track subject;
    @track type;
    @track body;
    @track date;
    @track fields;
    @track iconType;
    @track messageId;
    @track replyLink;
    @track read;
    @track del;

    @track markAsReadServiceError = false;
    @track markAsDeleteServiceError = false;
    @track isOpen = false;

    

    label = {
        markAsRead,
        markAsDelete,
        markAsReadServiceError,
        markAsDeleteServiceError
    };

    @api set message(message) {
        this._message = message;
        // separate out the logic
        this.subject = message.subject;
        this.type = message.type;
        this.body = message.body;
        this.msgDate = message.msgDate;
        this.fields = message.fields;
        this.iconType = message.iconType;
        this.subject = message.subject;
        this.messageId = message.messageId;
        this.replyLink = message.replyLink;
        this.read = message.read;
        this.del = message.delete;
        console.log('Msg'+JSON.stringify(this._message));
        console.log('Sub'+JSON.stringify(this.subject));
       
    }
    get message() {
        return this._message;
    }

    toggleOpen(){
        this.isOpen = !this.isOpen;
    }

    get iconClass(){
        if (this.type === 'Direct Message') {
            return 'fa-mail';
        } else if (this.iconType === 'alert') {
            return 'fa-alert';
        }
        return 'none';
    }

    get formattedDate(){
        if(this.msgDate!= undefined && this.msgDate!= null && this.msgDate!=''){
        let date = new Date(this.msgDate);
        console.log('DATE123'+date);
        console.log('Date msg'+this.msgDate);
        console.log('Date'+date.toLocaleDateString("en-US",{ year: "numeric", month: "2-digit",day: "2-digit"}));
        return date.toLocaleDateString("en-US",{ year: "numeric", month: "2-digit",day: "2-digit"});}
    }
    get classes() {
        return {
            containerClass: "message-container " + (this.isOpen ? 'open ': 'close ') + (this.read ? ' message-read': 'message-unread')
        };
    }

    isLinkDataComplete(linkData) {
        return linkData.label && (linkData.communityPage || linkData.externalUrl)
    }
    get ifs() {
        return {
            isLinkValid: this.isLinkDataComplete(this.replyLink)
        }
    }

    markAsRead(evt){
        evt.preventDefault();
        this.markAsReadServiceError = false;

        // for QA testing only DELETE AFTER TESTING AND INTEGRATOIN WHEN GOING TO PROD START DELETE
        if (window.location.search.indexOf('simulatemarkasreaderror') > -1){
            console.log('Simluating Mark As Read service Error');
            this.markAsReadServiceError = true;
            return;
        }
        // for QA testing only DELETE AFTER TESTING AND INTEGRATOIN WHEN GOING TO PROD END DELETE

        markMessageAsRead(this.messageId, this.type).then(() => {
           this.read = true;
        }).catch((error) => {
            console.log('mark message as read error',error);
            this.markAsReadServiceError = true;
        })
    }

    markAsDelete(evt){
        evt.preventDefault();
        this.markAsDeleteServiceError = false;

        // for QA testing only DELETE AFTER TESTING AND INTEGRATOIN WHEN GOING TO PROD START DELETE
        if (window.location.search.indexOf('simulatemarkasdeleteerror') > -1){
            console.log('Simluating Mark As Delete service Error');
            this.markAsDeleteServiceError = true;
            return;
        }
        // for QA testing only DELETE AFTER TESTING AND INTEGRATOIN WHEN GOING TO PROD END DELETE

        markMessageAsDelete(this.messageId, this.type).then(() => {
           this.del = true;
        }).catch((error) => {
            console.log('mark message as delete error',error);
            this.markAsDeleteServiceError = true;
        })
    }

}