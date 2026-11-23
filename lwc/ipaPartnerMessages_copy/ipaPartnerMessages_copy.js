import { LightningElement, track } from 'lwc';

import partnerMessagesTemplate from './ipaPartnerMessages_copy.html';
import loadingTemplate from './loading.html';
import { getPartnerMessages, markMessageAsRead } from 'c/ipaBenefitService_copy1';

import subject from '@salesforce/label/c.PMP_PartnerMessage_Subject';
import type from '@salesforce/label/c.PMP_PartnerMessage_Type';
import date from '@salesforce/label/c.PMP_PartnerMessage_Date';


export default class IpaPartnerMessages_copy extends LightningElement {
    @track isLoading = true;
    @track title = '';
    @track messages = [];
    @track viewAllLink = {};

    label = {
        subject,
        type,
        date
    };

    connectedCallback() {
        this.fetchPartnerMessages();
    }
    render() {
        return this.isLoading ? loadingTemplate : partnerMessagesTemplate;
    }

    async fetchPartnerMessages() {
        const result = await new Promise(resolve => {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                getPartnerMessages().then((value) => {
                    resolve(value);
                });
            }, 2000);
        });
        console.log('resultpartnermsg', JSON.parse(JSON.stringify(result)));

        this.title = result.title;
        this.viewAllLink = result.viewAllLink;
        this.messages = result.messages.map((message, index) => ({
            ...message,
            fields: this.addIds(message.fields, 'message-fields-' + index)
        }));
        console.log('getPartnerMessages', JSON.parse(JSON.stringify(this.messages)));
        this.isLoading = false;
    }


    markAsRead() {

        markMessageAsRead().then((value) => {
            console.log(value);
        }).catch((error) => {
            console.log('mark message as read errir', error)
        })


    }

    addIds(arr, prefix) {
        if (arr && arr.length > 0) {
            return arr.map((item, index) => ({
                ...item,
                id: prefix + '-' + index
            }));
        }
        return arr;
    }

    get classes() {
        return {
            containerClass: "container",
            alignment: this.ifs.hasRightPanel ? "Left" : this.alignment
        };
    }

    isLinkDataComplete(linkData) {
        return linkData.label && (linkData.communityPage || linkData.externalUrl)
    }
    get ifs() {
        return {
            isViewAllLinkValid: this.isLinkDataComplete(this.viewAllLink)
        }
    }

}