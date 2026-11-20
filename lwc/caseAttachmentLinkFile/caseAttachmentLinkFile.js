import { LightningElement, track, api, wire } from 'lwc';
import getFileList from '@salesforce/apex/Core_IPS_caseAttLinkFileCont_LEX.getFiles';
import saveRecords from '@salesforce/apex/Core_IPS_caseAttLinkFileCont_LEX.saveFile';
import {refreshApex} from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columns = [
    {
    label: 'File Name',
    fieldName: 'fileName',
    type: 'text',
    sortable: true
},
{
    label: 'File Descrption',
    fieldName: 'fileDescription',
    type: 'text',
    sortable: true
},
{
    label: 'Category',
    fieldName: 'fileCategory',
    type: 'text',
    sortable: true
},
{
    label: 'File Size',
    fieldName: 'fileSize',
    type: 'text',
    sortable: true
},
{
    label: 'Effective Date',
    fieldName: 'fileEffectiveDate',
    type: 'text',
    sortable: true
},
{
    label: 'Expiration Date',
    fieldName: 'fileExpirarionDate',
    type: 'text',
    sortable: true
},
{
    label: 'File Download Link',
    fieldName: 'fileDownload',
    type: 'url',
    typeAttributes: {
        label: { fieldName: 'Download' },
        target: '_blank',
    },
    sortable: true
},
{
    label: 'Upload Status ',
    fieldName: 'uploadStatus',
},

{
    label: 'Upload Status Updated At',
    fieldName: 'uploadStatusLatUpdated',
},
{
    label: 'File Uploaded By',
    fieldName: 'uploadedBy',
    type: 'url',
    typeAttributes: {
        label: { fieldName: 'uploadedByUrl' },
        target: '_blank',
    },
    sortable: true
},
{
    label: 'File GUID',
    fieldName: 'fileGUID',
},
];

export default class CaseAttachmentLinkFile extends NavigationMixin(LightningElement) {
    @track dataToShow;
    @track columns = columns;
    @track isDataAvailable = false;
    @track response;
    @track errors;
    @track spinner = false;
    @track recordsCount = 0;
    
    fileRecords=[];
    wiredRecords =[];
    @api recordId;
    @api refreshData;



    @wire(getFileList, { caseId: '$recordId' })
    wiredFiles({ data, error }) {
            this.wiredRecords = data;
            if (data) {
                let dataWrapper = [];
                let FileUploadByName;
                let FileUploadedById;
                for (let i = 0; i < data.length; i++) {
                    this.row = data[i];
                    console.log('FileUploadedbyId',data[i].Core_FileUploadedBy__c);
                    if (this.row.Core_FileUploadedBy__r) {
                         
                        let upldBy = JSON.stringify(this.row.Core_FileUploadedBy__r);
                         FileUploadByName = JSON.parse(upldBy);
                         FileUploadedById = FileUploadByName.Id;
                        this.coreFileUploadedBy = FileUploadByName.Name;
                    }
                    console.log('FilesName',FileUploadByName);
                    var effdate = new Date(data[i].Core_Effective_Date__c);
                    var effectivedate = effdate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                    var expdate = new Date(data[i].Core_Expiration_Date__c);
                    var expirationdate = expdate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                    var uploaddate = new Date(data[i].Core_Last_Status_Updated_At__c);
                    var uploaddateStatus = uploaddate.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                    //let uploadedbyName = data[i].Core_FileUploadedBy__c != undefined ? data[i].Core_FileUploadedBy__r.Name : '';
                    let obj = {
                        'Id' : data[i].Id,
                        'fileName': data[i].Core_File_Name__c,
                        'fileNumber': data[i].Name,
                        'fileDescription': data[i].Core_File_Description__c,
                        'fileCategory' : data[i].Core_Category__c,
                        'fileSize': data[i].Core_File_Size__c,
                        'fileEffectiveDate' : effectivedate,
                        'fileExpirarionDate' : expirationdate,
                        'fileDownload': data[i].Core_File_URL__c,
                        'uploadStatus': data[i].Core_Upload_Status__c,
                        'createdDate': data[i].CreatedDate,
                        'uploadStatusLatUpdated' : uploaddateStatus,
                        'uploadedByUrl': this.coreFileUploadedBy,
                        'uploadedBy': FileUploadedById,
                        'fileGUID' : data[i].Core_File_GUID__c,
                        'Download' : 'Download'
                    };
                    dataWrapper = [...dataWrapper, obj]
                }
                this.dataToShow = dataWrapper;
                console.log('Data=>',JSON.stringify(data));
                console.log('Data wrapper==>',data.Core_File_Description__c);
                console.log('in child component',JSON.stringify(this.dataToShow));
                if(this.dataToShow.length>0){
                    this.isDataAvailable = true;
                }
                else{
                    this.isDataAvailable = false;
                }
            }
            if (error) {
                this.response = undefined;
                this.errors = error;
                this.showToast('ERROR', 'No Relevant Files found with Case related Supported Product', 'error');
    
            }
            this.refreshList();
            console.log('After refresh==',this.wiredRecords);
    }
    refreshList(){
        if(this.refreshData === 'Load Data'){
            console.log('load data in link file');
            return refreshApex(this.wiredRecords);
        }
        
    }
    getSelectedRecords(event){
        let selectedRecords = [];
        const selectedRows = event.detail.selectedRows;
        console.log('selectedrows==',selectedRows);
        this.recordsCount = event.detail.selectedRows.length;
        let fileIds = new Set();
        for (let i = 0; i < selectedRows.length; i++) {
            console.log('Id=',selectedRows[i].Id);
            fileIds.add(selectedRows[i].Id);
            selectedRecords = [...selectedRecords,selectedRows[i].Id]
        }
        //this.selectedRecords = Array.from(fileIds);

        window.console.log('selectedRecords ====> '+ selectedRecords);
        this.fileRecords = selectedRecords;
        console.log('Filerecords=',this.fileRecords);
    }
    onSaveHandler(){
        this.spinner = true;
        saveRecords({selectedRecordIds: this.fileRecords, caseId: this.recordId})
        .then(result => {
            
            if(this.fileRecords.length>0){
                window.console.log('result ====> ' + result);
                this.showToast('SUCCESS!!', 'Files has been Attached successfully', 'success');
                this.template.querySelector('lightning-datatable').selectedRows = [];
                this.spinner = false;
                this.recordsCount = 0;
                window.location.reload();
            }
            else{
                alert('Please Select Atleast one File ');
                this.spinner = false;
            }
        })
        .catch(error => {
            window.console.log(error);
            this.showToast('ERROR', error.body.message, 'error');
            this.navigateToList();

        });
        
    }

    onCancelHandler(){
        if(this.recordId !== null){
            this.navigateCaseView();
        }else{
            this.navigateToList();
        }
        
    }
    navigateCaseView(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Case',
                actionName: 'view'
            },
        });
    }
    navigateToList(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}