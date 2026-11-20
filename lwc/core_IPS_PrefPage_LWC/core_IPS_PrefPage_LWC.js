import { LightningElement, api, wire, track } from 'lwc';
import Core_Country_Region__c from '@salesforce/schema/Contact.Core_Country_Region__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Contact from '@salesforce/schema/Contact';
import SubmitChoice from '@salesforce/apex/Core_IPS_PrefPage_CTRL.SubmitChoice';
import Core_IPS_CommEmailOptController from '@salesforce/apex/Core_IPS_PrefPage_CTRL.Core_IPS_CommEmailOptController';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import gettimezone from '@salesforce/apex/Core_IPS_PrefPage_CTRL.gettimezone';
import { NavigationMixin } from 'lightning/navigation';
import Prefpagecombo from '@salesforce/resourceUrl/core_ips_combobox_pagepreference';
import { loadStyle } from 'lightning/platformResourceLoader';
export default class Core_IPS_PrefPage_LWC extends NavigationMixin(LightningElement) {
    @track isChecked;
    checkboolean3;
    checkedno2;
    options = [];
    picklistOptions = [];
    selectedValue;
    dataFromemail;
    checkedyes1;
    timevalue;
    @track isSpinner;
    @wire(getObjectInfo, { objectApiName: Contact })
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Core_Country_Region__c })
    wiredData({ error, data }) {
        if (data) {
            let dataOjb = data.values;
            let finalData = [{ label: "--None--", value: "None" }, ...dataOjb];
            this.options = finalData.map(objPL => {
                return {
                    label: `${objPL.label}`,
                    value: `${objPL.value}`
                };
            });
        } else if (error) {
        }
    }
    selectedCountryValue = this.selectedValue;
    handlePicklistChange(event) {
        let strCheck = JSON.stringify(event.detail.value);
        this.selectedCountryValue = strCheck.replace(/['"]+/g, '');
    }
    value = ['true'];
    handleChangeYEs(e) {
        this.value = e.detail.value;
        this.radioValue = this.value.replace(/['"]+/g, '');
    }
    contactid;
    datafromcoo;
    idvalue;
    emailout = false;
    connectedCallback() {
               loadStyle(this, Prefpagecombo); 
        Core_IPS_CommEmailOptController()
            .then(result => {
                this.selectedValue = result[0].Core_Country_Region__c;
                this.selectedCountryValue = this.selectedValue;
                this.yesValue = result[0].Core_MINDS__c;
                this.checkboolean3 = result[0].Core_IPS_Email_Opt_Out__c;
                this.idvalue = result[0].Id;
                if (this.yesValue == true) {
                    this.noValue = false;
                }
                this.error = undefined;
                if (result[0].Core_IPS_Email_Opt_Out__c == true) {
                    this.emailin = true;
                }
                else {
                    this.emailout = true;
                }
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
            })
        gettimezone()
            .then(result => {
                this.timevalue = result.TimeZoneSidKey;
                this.selectedTimeZone = result.TimeZoneSidKey;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.accounts = undefined;
            })
    }
    @track noValue = true;
    yesValue;
    emailin = false;
    handleChangecheck(event) {
        if (event.target.name == "yeschecked") {
            this.yesValue = event.target.checked;
            if (this.yesValue == false) {
                this.noValue = true;
                if (this.noValue == true) {
                    this.yesValue = false;
                }
            }
            else {
                this.noValue = false;
                this.yesvalue = true;
            }
        }
    }
    handleChangecheckNo(event) {
        this.noValue = event.target.checked;
        if (this.noValue == false) {
            this.yesValue = true;
            if (this.yesValue == true) {
                this.noValue = false;
            }
        }
        else {
            this.yesValue = false;
            this.novalue = true;
        }
    }
    checkboolean3;
    handleChangecheckoptin(event) {
        if (event.target.name == "yescheckedopt") {
            if (event.detail.checked == true) {
                this.checkboolean3 = false;
            }
        }
    }
    handleChangecheckoptout(event) {
        if (event.target.name == "yescheckedopt") {
            if (event.detail.checked == true) {
                this.checkboolean3 = true;
            }
        }
    }
    submitHandleClick() {
        this.isSpinner = true;
        if (this.selectedCountryValue == null || this.selectedCountryValue == 'None' || this.selectedCountryValue == undefined || this.selectedCountryValue == '') {
            this.isSpinner = false;
            this.showToast('ERROR!!', 'Please select a Country/Region value before submitting your changes', 'error');
            return;
        }
        SubmitChoice({ countryValue: this.selectedCountryValue, radioCheckbox: this.yesValue, EmailOpt: this.checkboolean3, timeZoneValue: this.selectedTimeZone })
            .then((result) => {
                if (result.legth > 0) {
                    this.isSpinner = false;
                    this.contacts = result;
                    this.error = undefined;
                }
            })
            .catch((error) => {
                this.isSpinner = false;
                this.error = error;
                this.contacts = undefined;
            });
        this.showToast('SUCCESS!!', 'Updated Sucessfully', 'success');
        setTimeout(() => window.location.reload(), 3000);
    }
    @track timeZoneName;
    @api objectApiName = 'User';
    @api recordId;
    @wire(getRecord, { recordId: USER_ID, })
    userData({ error, data }) {
        if (data) {
            let objCurrentData = data.TimeZoneSidKey;
            this.timevalue = data.TimeZoneSidKey;
        } else if (error) {
        }
    }
    @track contctcname;
    @api contaid = this.idvalue;
    @api conobjectApiName = 'Contact';
    @wire(getRecord, { contaid: CONTACT_ID, fields: ['Contact.Name', 'Contact.Core_Country_Region__c', 'Contact.Core_MINDS__c', 'Contact.Core_IPS_Email_Opt_Out__c'] })
    userData({ error, data }) {
        if (data) {
            let objCurrentData = data.fields;
            this.contctcname = objCurrentData.Core_Country_Region__c.value;
            this.contaid = objCurrentData.Id.value;
        } else if (error) {
        }
    }
    selectedTimeZone;
    handlePicklistChangetimezone(event) {
        let strtimezone = JSON.stringify(event.detail.value);
        this.selectedTimeZone = strtimezone.replace(/['"]+/g, '');
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    handleNavigateBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }
    cancelHandleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }
}