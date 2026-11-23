import {LightningElement, api, wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation'
import uploadFiles from '@salesforce/apex/PCC_DealRegFileUploadCtrl.uploadFiles'
import getRelatedFilesByRecordId from '@salesforce/apex/PCC_DealRegFileUploadCtrl.getRelatedFilesByRecordId'
import deleteSelectedfile from "@salesforce/apex/PCC_DealRegFileUploadCtrl.deleteSelectedfile";
import { refreshApex } from '@salesforce/apex';

const MAX_FILE_SIZE = 11534336;

export default class PCC_DealRegFileUpload extends NavigationMixin(LightningElement) {

    @api recordId;
    @track filesData = [];
    showSpinner = false;
    filesList =[];
    dataFromApex;
    btnDisable = true;

    get acceptedFormats() {
        return ['.pdf', '.xlsx','.jpg', '.jpeg', '.png', '.doc', '.docx','.xls' , '.xlsx'];
    }

    @wire(getRelatedFilesByRecordId, {recordId: '$recordId'})
    //wiredResult({data, error}){ 
        wiredResult(result){ 
            const { data, error } = result;
            this.dataFromApex = result;
        if(data){ 
            /*this.filesList = Object.keys(data).map(item=>({"label":data[item],
             "value": item,
             "url":`/sfc/servlet.shepherd/document/download/${item}`*/
             this.filesList = Object.keys(data).map(item=>({"label":data[item].Title,
             "value": data[item].ContentDocumentId,
             "url":`/sfc/servlet.shepherd/document/download/${data[item].ContentDocumentId}`,
             "contentVersionId" : data[item].Id
            }))
          console.log('@@Wire=='+JSON.stringify(this.filesList));
        }
        if(location.host.includes('site')){
            this.btnDisable = false;
        }

        if(error){ 
            console.log(error)
        }
    }

    handleFileUploaded(event) {
        if (event.target.files.length > 0) {
            for(var i=0; i< event.target.files.length; i++){
                /***********File Format Check ******************/
                let fileExt = event.target.files[i].name.split('.');
                let extension = '.' + fileExt[fileExt.length-1].toLowerCase();
                if (!this.acceptedFormats.includes(extension)) {
                    this.showToast('Error!', 'error', 'File format not supported.');
                    return;
                }
                /***********File Size Check ********************/
                if (event.target.files[i].size > MAX_FILE_SIZE) {
                    this.showToast('Error!', 'error', 'File size exceeded the upload size limit.');
                    return;
                }
                let file = event.target.files[i];
                let reader = new FileReader();
                reader.onload = e => {
                    var fileContents = reader.result.split(',')[1]
                    this.filesData.push({'fileName':file.name, 'fileContent':fileContents});
                };
                reader.readAsDataURL(file);
            }
        }
        
    }

    uploadFiles() {
        if(this.filesData == [] || this.filesData.length == 0) {
            this.showToast('Error', 'error', 'Please select files first'); return;
        }
        this.showSpinner = true;
        console.log('@@Record=='+this.recordId);
        uploadFiles({
            recordId : this.recordId,
            filedata : JSON.stringify(this.filesData)
        })
        .then(result => {
            console.log(result);
            if(result && result == 'success') {
                this.filesData = [];
                this.showToast('Success', 'success', 'Files Uploaded successfully.');
                refreshApex(this.dataFromApex);
            } else {
                this.showToast('Error', 'error', result);
            }
        }).catch(error => {
            if(error && error.body && error.body.message) {
                this.showToast('Error', 'error', error.body.message);
            }
        }).finally(() => this.showSpinner = false );
        
    }

    removeReceiptImage(event) {
        var index = event.currentTarget.dataset.id;
        this.filesData.splice(index, 1);
    }

    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }

    previewHandler(event){
        console.log(event.target.dataset.id);
        console.log('@Preview=='+event.target.dataset.contentVersionId);
        if(location.host.includes('site')){
            var baseURL = 'https://'+location.host+'/';
            var previewURL = baseURL + 'sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+event.target.dataset.msg;
            console.log('@@PreviewURL=='+JSON.stringify(previewURL));
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: previewURL
            }
            }, false );
        } else {
            this[NavigationMixin.Navigate]({ 
                type:'standard__namedPage',
                attributes:{ 
                    pageName:'filePreview'
                },
                state:{ 
                    selectedRecordId: event.target.dataset.id
                }
            })
        }
       /* 
        */
        
    }

    deleteSelectedRecords(event)
    {
      console.log('id of button==:' , event.currentTarget.dataset.id)
      //let recordIds = event.currentTarget.dataset.id;
      let recordIds = event.target.value;
      console.log('recordId set: ',recordIds);
      deleteSelectedfile({docIds : recordIds})
      .then(result => {
        console.log('Result Dleete=='+JSON.stringify(result));
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'File is deleted!',
            variant: 'success',
          }),
        );
        return refreshApex(this.dataFromApex);
      })
      .catch(error => {
        /*this.message = undefined;
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error creating records',
            message: error,
            variant: 'error',
          
          }),
        );*/
       console.log('Delete Error=='+JSON.stringify(error));
      });

    }
    
}