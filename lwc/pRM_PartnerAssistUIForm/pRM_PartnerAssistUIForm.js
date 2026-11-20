import { LightningElement, track, wire } from 'lwc';
import getDistributorList from '@salesforce/apex/PRM_Partner_Assist_Utility.getDistributorList';
import fetchFormText from '@salesforce/apex/PRM_Partner_Assist_Utility.fetchFormText';
import insertPartnerConsentRecs from '@salesforce/apex/PRM_Partner_Assist_Utility.insertPartnerConsentRecs'
import ReleaseInfoTitle from '@salesforce/label/c.PRM_ReleaseInfoTitle';
import IntelDistributorTitle from '@salesforce/label/c.PRM_AuthDistTitle';
import OptInTitle from '@salesforce/label/c.PRM_OptIn_Title';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PRM_PA_Confirm_Message from '@salesforce/label/c.PRM_PA_Confirm_Message';
import PRM_PA_Submit_Message from '@salesforce/label/c.PRM_PA_Submit_Message';
import PRM_PA_NA_Message from '@salesforce/label/c.PRM_PA_NA_Message';
import PRM_Icon_Close from '@salesforce/label/c.PRM_Icon_Close';
import PRM_Icon_Approval from '@salesforce/label/c.PRM_Icon_Approval';
import PRM_Icon_Check from '@salesforce/label/c.PRM_Icon_Check';
import PRM_Submit from '@salesforce/label/c.PRM_Button_Submit';
import PRM_Select1 from '@salesforce/label/c.PRM_PA_Select1';
import PRM_Select2 from '@salesforce/label/c.PRM_PA_Select2';

export default class PRM_PartnerAssistUIForm extends LightningElement {
    @track firstPicklistValue;
    @track isDasabled = true;
    @track secondPicklistOptions;
    @track isChecked = false;
    @track secondPicklistValue;
    @track firstPicklistOptions = [];
    @track error;
    @track releaseInfoTitle = ReleaseInfoTitle;
    @track intelDistributorsTitle = IntelDistributorTitle;
    @track optInTitle = OptInTitle;
    @track releaseInfoTermsAndConditions;
    @track authorisedTermsAndConditions;
    @track isSubmissionPage = false;
    @track isConfirmPage = false;
    @track spinner = false;
    @track checkboxDisable = false;
    @track isNotAuthorised = false;
    @track isAlreadySubmitted = false;
    @track firstErrorValue;
    @track alreadySubmissionCompleted;
    @track confirmMessage = PRM_PA_Confirm_Message;
    @track alreadySubmittedMessage = PRM_PA_Submit_Message;
    @track notAuthorisedMessage = PRM_PA_NA_Message;
    @track submitButtonLabel = PRM_Submit;
    @track select1 = PRM_Select1;
    @track select2 = PRM_Select2;
    @track iconName;
    @track iconClose = PRM_Icon_Close;
    @track iconApproval = PRM_Icon_Approval;

    /*firstPicklistOptions = [
        { label: 'ASI Corporation', value: 'ASI Corporation' },
        { label: 'D&H Distributing', value: 'D&H Distributing' },
        { label: 'Ingram Micro Inc', value: 'Ingram Micro Inc' },
        { label: 'Synnex Corporation', value: 'Synnex Corporation' }
    ]; */    

    @wire(getDistributorList, {})
    fetchData({error,data}){
        if (data) {
            this.firstPicklistOptions = data;
            this.error = undefined;
            console.log('Apex Rerutned Data: '+JSON.stringify(this.firstPicklistOptions));
        } else if (error) {
            this.error = error;
            this.firstPicklistOptions = undefined;
            console.log('Error: '+JSON.stringify(this.error));
        }
    }

    @wire(fetchFormText, {})
    fetchTandCData({error,data}){
        if (data) {
            this.firstErrorValue = data.displayFirstErrorMssg;
            this.alreadySubmissionCompleted = data.displaySecondErrorMssg;
            console.log('Already Submitted: '+this.alreadySubmissionCompleted);
            console.log('Is Authorised or not :' +this.firstErrorValue);
            if(this.firstErrorValue === true){
                this.isNotAuthorised = true;
            }else if(this.alreadySubmissionCompleted === true){
                this.isAlreadySubmitted = true;
            }else if(this.firstErrorValue === false && this.alreadySubmissionCompleted === false){
                this.releaseInfoTermsAndConditions = data.upperText;
                this.authorisedTermsAndConditions = data.lowerText;
                this.isSubmissionPage = true;
            }
            this.error = undefined;
            //console.log(' T &C Apex Rerutned Data: '+JSON.stringify(this.releaseInfoTermsAndConditions));
        } else if (error) {
            this.error = error;
            this.releaseInfoTermsAndConditions = undefined;
            this.authorisedTermsAndConditions = undefined;
            //console.log('T & C Error: '+JSON.stringify(this.error));
        }
    }

    handleChange(event) {
        //console.log('Value for option value: '+this.value);
        this.firstPicklistValue = event.detail.value;
        console.log('First option value: '+this.firstPicklistValue);
        console.log('Checkbox value: '+this.isChecked);
        let temp=[];

        if (this.firstPicklistValue !== undefined && this.firstPicklistValue !== null) {
            for(let i = 0; i < this.firstPicklistOptions.length; i++){
                if (this.firstPicklistOptions[i].value !== this.firstPicklistValue) {
                    temp.push(this.firstPicklistOptions[i]);
                }
            }
            this.secondPicklistOptions = temp;
        }

        if (this.firstPicklistValue !== undefined && this.firstPicklistValue !== null && this.isChecked === true) {
            this.isDasabled = false;
        }else {
            this.isDasabled = true;   
        }
    }

    handleSecPicValChange(event){
        this.secondPicklistValue = event.detail.value;
        Console.log('Second option value: '+this.secondPicklistValue);
    }

    handleCheck() {
        this.isChecked = !this.isChecked;
        //console.log('Checkbox value: '+this.isChecked);
        if(this.isChecked === true){
            this.iconName = PRM_Icon_Check;
        }
        else if(this.isChecked === false){
            this.iconName = '';
        }

        if (this.firstPicklistValue !== undefined && this.firstPicklistValue !== null && this.isChecked === true) {
            this.isDasabled = false;
        } else if (this.firstPicklistValue !== undefined && this.firstPicklistValue !== null && this.isChecked === false) {
            this.isDasabled = true;
        }
    }

    handleClick(){

        //this.isChecked = !this.isChecked;
        //this.spinner = true;
        this.isDasabled = true;
        if(this.secondPicklistValue === undefined || this.secondPicklistValue === null || this.secondPicklistValue === this.firstPicklistValue){
            this.secondPicklistValue = null;
        }
        console.log('First Picklist value: '+this.firstPicklistValue);
        console.log('Second Picklist value: '+this.secondPicklistValue);
        console.log('Checkbox value: '+this.isChecked);

        insertPartnerConsentRecs({firstDistributorId:this.firstPicklistValue,secondDistributorId:this.secondPicklistValue,isChecked:this.isChecked})
            .then(result =>{
                if(result === true){
                    this.isSubmissionPage = false;
                    this.isConfirmPage = true;
                    window.scrollTo(0, 0);
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Failed',
                            message: 'Please try Again...!!',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error =>{
                this.error = error;
            });
    }
}