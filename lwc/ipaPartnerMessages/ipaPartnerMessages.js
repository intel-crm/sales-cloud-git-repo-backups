/* eslint-disable @lwc/lwc/no-api-reassignments */
/** Documentation for IPA Partner Messages
 * <br>
 * <p>Ipa Partner Message Component gets the  {@link ipaBenefitService.PartnerMessages } object from the {@link ipaBenefitService.getPartnerMessages} and creates multiple IpaPartnerMessage lwc items to render the messages
 * @namespace ipaPartnerMessages
 * @author Joshua Gonzalez
*/
const USE_MOCK = window.location.href.match('mockdata') ? true : false;

import { LightningElement, track } from 'lwc';

import partnerMessagesTemplate from './ipaPartnerMessages.html';
import loadingTemplate from './loading.html';
import { getPartnerMessages } from 'c/ipaBenefitService';
import { MockBenefitService } from 'c/ipaMockData';

import subject from '@salesforce/label/c.IPA_PartnerMessage_Subject';
import type from '@salesforce/label/c.IPA_PartnerMessage_Type';
import date from '@salesforce/label/c.IPA_PartnerMessage_Date';


export default class IpaPartnerMessages extends LightningElement {
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
        const date1 = new Date();
        const starttime = date1.getTime();
        console.error('PartnerMessageStarttime', +starttime);
        let result;
        try {
            if (USE_MOCK) {
                result = await MockBenefitService.getPartnerMessages();
            } else {
                result = await getPartnerMessages();
            }
        } catch (e) {
            console.error('getPartnerMessages error', `${e}`);
        }

        if (result) {
            this.title = result.title;
            this.viewAllLink = result.viewAllLink;
            this.messages = result && result.messages ? result.messages.map((message, index) => ({
                ...message,
                fields: this.addIds(message.fields, 'message-fields-' + index)
            })).slice(0, 5) : []; // limit to only 5 entries
            // console.log('getPartnerMessages', JSON.parse(JSON.stringify(this.messages)));
        }
        this.isLoading = false;
        const date2 = new Date();
        const endtime = date2.getTime();
        console.error('PartnerMessageEndtime', +endtime);
        const calTimeBenefits = starttime - endtime;
        console.error('PartnerMessageDIFF', +calTimeBenefits);
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
        return linkData && linkData.label && (linkData.communityPage || linkData.externalUrl)
    }
    get ifs() {
        return {
            isViewAllLinkValid: this.isLinkDataComplete(this.viewAllLink),
            hasMessages: this.messages && this.messages.length
        }
    }

}