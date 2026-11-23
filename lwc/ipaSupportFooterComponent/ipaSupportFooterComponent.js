import { LightningElement, track, api, wire } from 'lwc';
//custom labels
import intelHeading from '@salesforce/label/c.PMP_contact_intel_Heading';
import intelEmail from '@salesforce/label/c.PMP_contact_intel_Email';
import intelChat from '@salesforce/label/c.PMP_contact_intel_Chat';
import intelPhone from '@salesforce/label/c.PMP_contact_intel_Phone';
import subHeading from '@salesforce/label/c.PMP_Request_Support_SubHeading';
import chatSubHeading from '@salesforce/label/c.PMP_contact_intel_Chat_Sub_Heading';
import phoneSubHeading from '@salesforce/label/c.PMP_contact_intel_Phone_subheading';
import supportUrl from '@salesforce/label/c.IPA_Request_Support_URL';
import chatUrl from '@salesforce/label/c.IPA_Chat_URL';
import phoneUrl from '@salesforce/label/c.PMP_Phone_URL';
import emailSubHeading from '@salesforce/label/c.PMP_contact_intel_CTA_Email_SubHeading';
import chatSubHeading2 from '@salesforce/label/c.PMP_contact_intel_CTA_Chat_SubHeading';
import callSubHeading3 from '@salesforce/label/c.PMP_contact_intel_CTA_Sub_Heading';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import OBJ_FIELD from '@salesforce/schema/Contact.Core_Preferred_Language__c';
import getContacts from '@salesforce/apex/PRM_UserDetail.contactPrefferedLanguage';
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import Id from '@salesforce/user/Id';

import PreferredLangauge from '@salesforce/schema/Contact.Name';

//resource

import resContact from '@salesforce/resourceUrl/PMP_Contact_us_Chat';

import resRequestSupport from '@salesforce/resourceUrl/PMP_Contact_us_RequestSupport';

import resPhone from '@salesforce/resourceUrl/PMP_Contact_us_Phone';

const FIELDS = [CONTACT_ID];
const preflang = [OBJ_FIELD];

export default class IpaSupportFooterComponent extends LightningElement {

    @track Ucontactsdata = [];
    @track callContact = true;
    @track footerHeading = intelHeading;
	@api recordId = Id;
    @track Contact;
    @track paramField1;
    _userLanguage;
    
    get contactsdata() {
        getContacts().then((result) => {
            this._userLanguage = result;
            console.log('Data from setter -->',this._userLanguage);
        })
        .catch((err) => {
            console.log('Error from getter ->',err);
        })

        let contacdata = [
            {
                copy: subHeading,
                imgUrl: resRequestSupport,//"/imp/resource/1575453332000/PMP_Contact_us_RequestSupport",
                label: intelEmail,
                linkUrl: supportUrl,//"https://www.intel.com",
                linkCopy: emailSubHeading,//"Submit Request"
            }//,
            /*{
				copy: chatSubHeading,//"Chat is available during normal business hours.",
                imgUrl: resContact,//"chat",
                label: intelChat,//"Chat",
                linkUrl: chatUrl,//"https://www.intel.com",
                linkCopy: chatSubHeading2,//"Chat Now",
                linkTarget: "_self"
			},
            {
                copy: phoneSubHeading,//"Call us during normal business hours.",
                imgUrl: resPhone,
                label: intelPhone,//"Phone",
                linkUrl: phoneUrl,//"https://www.intel.com",
                linkCopy: callSubHeading3//"View Phone Directory"
            }*/
        ];
		console.log('this._userLanguage ->',this._userLanguage);
		if(this._userLanguage != 'ENG'){
			contacdata.push({copy: chatSubHeading,//"Chat is available during normal business hours.",
							imgUrl: resContact,//"chat",
							label: intelChat,//"Chat",
							linkUrl: chatUrl,//"https://www.intel.com",
							linkCopy: chatSubHeading2,//"Chat Now",
							linkTarget: "_self"},
							{copy: phoneSubHeading,//"Call us during normal business hours.",
							imgUrl: resPhone,
							label: intelPhone,//"Phone",
							linkUrl: phoneUrl,//"https://www.intel.com",
							linkCopy: callSubHeading3}//"View Phone Directory");
							);
		}
		console.log('con>>>' + JSON.stringify(contacdata));
		

        // contactsdata = contacdata;
        if (contacdata.length > 0) {
            this.callContact = true;
            this.Ucontactsdata = contacdata;
        }


		return this.Ucontactsdata;
	}
}