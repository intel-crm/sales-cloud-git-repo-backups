import { LightningElement,wire,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Type_FIELD from "@salesforce/schema/PCC_Rebate_Claim_Stage__c.RecordType.Name";
import Status_FIELD from "@salesforce/schema/PCC_Rebate_Claim_Stage__c.PCC_Status__c";
import Rebate_Claim_FIELD from "@salesforce/schema/PCC_Rebate_Claim_Stage__c.PCC_Rebate_Claim__c";
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import PROFILE_ID from '@salesforce/schema/User.Profile.Name';
import ACCOUNT_ID from '@salesforce/schema/User.Contact.AccountId';
import rebateClaimReUpload from './pcc_RebateClaimReUpload.html';
import rebateClaimBulkUpload from './pcc_RebateClaimBulkUpload.html';
import getRecordsAgain from '@salesforce/apex/PCC_RebateClaimController.getProcessedRCRecords'; 

export default class Pcc_RebateClaimBulkUpload extends NavigationMixin(LightningElement)  {
   @api recordId;
    
   @track oldStatus='';
   @track rebateClaimData;

    isUpload=false;
    downloaded=false;
    loading=false;

    @wire(getRecord, { recordId: "$recordId", fields: [Type_FIELD,Status_FIELD,Rebate_Claim_FIELD]})
    rebateClaimData;

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_ID,ACCOUNT_ID] })
    userProfile;

    render(){
        return this.recordId?rebateClaimReUpload:rebateClaimBulkUpload;
    }
    get profileId() {
        return getFieldValue(this.userProfile.data, PROFILE_ID);
    }

    get accountId(){
        return getFieldValue(this.userProfile.data, ACCOUNT_ID);
    }

    get userProfileData() {
        if(this.userProfile && this.userProfile.data){
            return true;
        }
        return false;
    }  
    get isPartner() {
        if(this.userProfile.data){
            return getFieldValue(this.userProfile.data, PROFILE_ID)==='Partner';
        }    
        return true;
    }
 
    get Type(){
        return getFieldValue(this.rebateClaimData.data, Type_FIELD)==='Header';
    }
  
    createRebateClaim(){
        this.isUpload=true;
    }
    refresh(){
        this.downloaded =  !this.downloaded;
    }

    downloadBulkuploadTemplateFile() {
        this.loading=true;
            getRecordsAgain({ recordId : this.recordId})
                .then(result => {
                    this.columns = result['fieldMap']['labels'];
                    this.columnsAPI = result['fieldMap']['apinames'];
                    this.claimData = result['rebateClaimList'];
                    this.fileName= result['fileName'];
                    this.generateCSV();
                    this.downloaded=true;
                    this.loading=false;
                })
                .catch(error => {
                    console.error(error);
                });
    }

    generateCSV() {
        try {
            let csvContent =  '\uFEFF';
            csvContent += this.columns.join(",")+ "\r\n";
            if(this.claimData.length>0){
                this.claimData.forEach(record => {
                    const row = this.columnsAPI.map(field =>{
                        let value = record[field];
                        if (value && value.includes(',')) {
                            value = `"${value}"`;
                        }
                        if (value && value.includes('\n')) {
                            value = `"${value}"`;
                        }
                        return value;
                    });
                    csvContent += row.join(",") + "\r\n";
                });
            }
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const reader = new FileReader();
            const fileName = this.fileName;
            reader.readAsDataURL(blob);
            reader.onload = function(event) {
                const dataUrl = event.target.result;
                const link = document.createElement("a");
                link.setAttribute("href", dataUrl);
                link.setAttribute("download",fileName);
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            };
            this.showToast('success', 'CSV Downloaded', 'The CSV file has been downloaded successfully.');
        }
        catch(error){
            this.showToast('error', 'Error', 'An error occurred while downloading the CSV file.');
        }
    }
    showToast(variant, title, message) {
        const event = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message
        });
        this.dispatchEvent(event);
    }


    handleStagingRecords() {
        if(this.profileId==='Partner'){
              // Open the page in a new tab
        const pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: '/partneradmin/s/rebate-claim-stage-list-view'
            }
        };
            
        this[NavigationMixin.Navigate](pageReference, true);
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'PCC_Rebate_Claim_Stage__c',
                    actionName: 'list'
                },
                state: {
                    filterName: 'All' 
                }
            });
        }   
    }
    deleteFile(){
        this.fileName = '';
        this.filesUploaded = [];
    }
    handleClose() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'PCC_Rebate_Claim__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All' 
            }
        });
    }  
    handleCloseModal() {
        this.isUpload=false;
    }
}