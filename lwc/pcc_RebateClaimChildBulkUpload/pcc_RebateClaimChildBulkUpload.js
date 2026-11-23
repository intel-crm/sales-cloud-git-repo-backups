import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getFieldSetLabels from '@salesforce/apex/PCC_RebateClaimController.getFieldSetLabels';
import saveFile from '@salesforce/apex/PCC_RebateClaimController.createStageRecordsfromCSV';
import getPartnerAccounts from '@salesforce/apex/PCC_RebateClaimController.getPartnerAccounts';
import getQuoteQuantity from '@salesforce/apex/PCC_RebateClaimController.getQuoteQuantity';
import getQLshow from '@salesforce/apex/PCC_RebateClaimController.isQLonRCVisible';

import rcTempGuidance from '@salesforce/label/c.RC_Template_Guidance_Link';

export default class Pcc_RebateClaimChildBulkUpload extends NavigationMixin(LightningElement) {

    @api recordId;
    @api partnerAcc;
    @api isPartner;
    @api partnerOptions;

    @track columns=[];
    @track columnsAPI = [];
    @track fileName;
    @track claimData=[];
    @track missingQuoteLines="";
    @track parentReference=[];
    @track quoteLineNumbers = "";
    @track quantityResults = [];

    isProcessing=false;
    filesUploaded = [];
    
    MAX_FILE_SIZE = 1500000;
    fileReader;
    fileContents;
    fileReader;
    partnerValue='';
    label={
        rcTempGuidance
    };
    
    isCreated=false;
    isClaimScreen=false;
    isDownloadScreen=false;
    showSpinner=true;
    showModal2 = false;
    isCreate=true;
    showQLSection=false;

    columns = [
        { label: 'Quote Line', fieldName: 'QuoteLine',
            cellAttributes: { alignment: 'left' }, },
        { label: 'Approved QL Quantity', fieldName: 'ApprovedQuantity', type: 'number' ,
            cellAttributes: { alignment: 'center' },},
        { label: 'Claimable Quantity', fieldName: 'RemainingQuantity', type: 'number' ,
            cellAttributes: { alignment: 'center' },},
        { label: 'Claimed Quantity', fieldName: 'ClaimedQuantity', type: 'number',
            cellAttributes: { alignment: 'center' }, }
    ];

    @wire(getPartnerAccounts) partnerOptions;

    connectedCallback(){
        this.getQLSection();
    }
    getQLSection(){
        this.isProcessing = true;
        getQLshow()
        .then(result => {
           if(result){
            this.showQLSection = result; 
           } 
           this.isProcessing = false;
        })
        .catch(error => {
            this.isProcessing = false;
        });
    }
    get isEmptymissingQuoteLines(){
        if(this.missingQuoteLines===""){
            return false;
        }
        return true;
    }

    get parentReferenceName() {
        return this.parentReference[0];
    }

    handleInputChange(event) {
        this.quoteLineNumbers = event.target.value;
    }

    handleSearch() {
        const quoteLineNumbers = this.quoteLineNumbers.split(',').map(quoteLine => quoteLine.trim());
        getQuoteQuantity({ qlNum: quoteLineNumbers })
            .then(result => {
                if (result.length !== 0) {
                    this.quantityResults = result;
                }
                else{
                    this.quantityResults=[];
                }
                const missingQuoteLines = quoteLineNumbers.filter(quoteLine => !result.some(item => item.QuoteLine === quoteLine.trim()));
               this.missingQuoteLines = missingQuoteLines.join(',');
            })
            .catch(error => {
                this.error = error;
                this.quantityResults = [];
            });
    }
    
    closeSpinner(){
        this.showSpinner=false;
    }
    handleClick(){
        this.showModal2=true;
    }
    handleModal2Close(){
        this.showModal2=false;
    }
    downloadBulkuploadTemplateFile() {
            getFieldSetLabels()
                .then(result => {
                    this.columns = result['labels'];
                    this.generateCSV();
                })
                .catch(error => {
                    console.error(error);
            });
    }

    generateCSV() {
        try {
            console.info('profileId'+this.profileId);
            let csvContent =  '\uFEFF';
            csvContent += this.columns.join(",")+ "\r\n";
            if(this.claimData.length>0){
                this.claimData.forEach(record => {
                    const row = this.columnsAPI.map(field =>{
                        let value = record[field];
                        if (value && value.includes(',')) {
                            value = `"${value}"`;
                        }
                        return value;
                    });
                    csvContent += row.join(",") + "\r\n";
                });
            }
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const reader = new FileReader();
            reader.readAsDataURL(blob);
             reader.onload = function(event) {
             const dataUrl = event.target.result;

            const link = document.createElement("a");
           link.setAttribute("href", dataUrl);
            link.setAttribute("download", "RebateClaimTemplate.csv");
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            
        };
        
        this.showToast('success', 'Template Downloaded', 'The Template file has been downloaded successfully.');
        }
        catch(error){
            this.showToast('error', 'Error', 'An error occurred while downloading the CSV file.');
        }
    }

   
    handleFilesChange(event) {
        console.log(this.partnerAcc);
        if(event.target.files.length > 0) {
             this.filesUploaded = event.target.files;
             this.fileName = event.target.files[0].name;
           
         }
     }
     handleSave() {
         if(this.filesUploaded.length > 0) {
             this.isProcessing=true;
             this.uploadFile();
         }
         else {
             this.fileName = 'Upload a duly filled Rebate Claim Template to proceed further';
         }
     }

     showToast(variant, title, message,mode) {
        const event = new ShowToastEvent({
            mode:mode,
            variant: variant,
            title: title,
            message: message
        });
        this.dispatchEvent(event);
    }
    uploadFile() {
        if (this.filesUploaded[0].size > this.MAX_FILE_SIZE) {
            this.fileName = 'File Size is large';
            return;
        }
        const fileExtension = this.filesUploaded[0].name.split('.').pop();
        if (fileExtension !== 'csv') {
            this.isProcessing=false;
            this.showToast('error', 'Error', 'Invalid Rebate Claim Template. Carefully read through the Instructions for Partners');
        } 
        else {
            this.fileReader = new FileReader();
            this.fileReader.onloadend = () => {
                this.fileContents = this.fileReader.result;
                this.saveFile();
            };
            this.fileReader.readAsText(this.filesUploaded[0],'UTF-8');
        }
    }
    saveFile() {
        try { 
            if (this.isPartner || this.partnerValue.length > 0) {
                this.saveTheFile();
                
            } else {
                this.isProcessing=false;
                this.showToast('error', 'Error', 'Please Enter the Partner Email ID');
            }
        } catch (error) {
            console.error(error);
            this.isProcessing=false;
            this.showToast('error','Error while uploading File!!', error.message);
        }
    }
    
    saveTheFile() {
    
        const lstFiles = this.fileContents.split('\r\n').filter(part => part !== '');;
        
        // Remove the last element if it is an empty string
        if (lstFiles[lstFiles.length - 1] === '' || lstFiles[lstFiles.length - 1].trim().split(',').every(value => value.trim() === '')) {
            lstFiles.pop();
        }
        if(lstFiles.length===1 || lstFiles.length===0){
            this.isProcessing=false;
            this.showToast('error','Error', 'No data entered in the Rebate Claim Template. Carefully read through the Instructions for Partners');
        }
        else if(lstFiles.length>1){
            const allValuesEmpty = lstFiles.some(line => line.trim().split(',').every(value => value.trim() === ''));
            if(allValuesEmpty) {
                this.isProcessing = false;
                this.showToast('error', 'Error', 'One or more rows empty in Rebate Claim Template. Carefully read through the Instructions for Partners');
            } else {
            saveFile({
                base64Data: JSON.stringify(lstFiles.join('\r\n')),
                partnerInfo : this.partnerAcc,
                templateName : this.filesUploaded[0].name,
                isPartner:this.isPartner
            })
            .then(result => {
                if(result.status==='success'){
                    this.isProcessing=false;
                    this.parentReference= result.message.split('#');
                    this.isCreated=true;                    
                }
                else if(result.status==='failed'){
                    this.isProcessing=false;
                    this.showToast('error','Error', result.message);
                }
            })
            .catch(error => {
                this.isProcessing=false;
                console.error(error);
               this.showToast('error','Error while uploading File!!', error.message);     
            });
        }
    }
        
    }

    deleteFile(){
        this.fileName = '';
        this.filesUploaded = [];
    }
    handleChange(event) {
        this.partnerValue = event.detail.value;
        this.partnerAcc = this.partnerValue;
    }
    handleCalculate(){
        this.isCreate=false;
        this.isClaimScreen=true;
    }
    handleDownload(){
        this.isCreate=false;
        this.isDownloadScreen=true;
    }
    handleBack(){
        this.isCreate=true;
        this.isDownloadScreen=false;
        this.isClaimScreen=false;
    }
    
    navigatetoRecordPage(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.parentReference[1],
                objectApiName: 'PCC_Rebate_Claim_Stage__c',
                actionName: 'view'
            },
        });
    }
}