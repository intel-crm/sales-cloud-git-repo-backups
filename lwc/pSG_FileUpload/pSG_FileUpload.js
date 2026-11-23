import {LightningElement, track,wire, api} from 'lwc';
import getFiles from '@salesforce/apex/PSG_FileUploadController.getFiles';
import removeAttachment from '@salesforce/apex/PSG_FileUploadController.removeAttachment';
import getAllObjects from '@salesforce/apex/PSG_UploadFile.getAllObjects';
import { deleteRecord } from 'lightning/uiRecordApi';


const columns = [{
    label: 'Title',
    fieldName: 'FileName',
    type: 'text',
    cellAttributes:{ name:"Id" , type:"string"},
    hideDefaultActions: true   
},
    {
        label: 'File Size',
        fieldName: 'size',
        type: 'text',
        hideDefaultActions: true            
    },
    {
        label: 'File Type',
        fieldName: 'type',
        type: 'text',
        hideDefaultActions: true              
    },
    {
        type: 'button-icon',
        typeAttributes:
        {
            iconName: 'utility:delete',
            name: 'delete',
            iconClass: 'slds-icon-text-error'
        }
    }
];


export default class pSG_FileUpload extends LightningElement {
    showLoadingSpinner = false;
    @api recordId;
    @api attachId;
	keyRecordId;
    @track fileNames = '';
    @track filesUploaded = [];
    @track data;
    @track columns = columns;
    @track error;
    @track attachmentList = [];
    @track selectedRows;

    @track selectObjectDevName = "";
    @track error = undefined;
    @track searchOptions;

    MAX_FILE_SIZE = 6000000 //6MB
    tempDataList1 = [];
    uploadedFileSize = 0;
    totalFiles = 0;

    connectedCallback(){
        let recordId = 'a9Y2D000000CkYjUAK';
        if(recordId){
            this.getFilesData(recordId);
        }
    }

    // wire method to get all object names
    @wire(getAllObjects)
    objectNames({ error, data }) {
        if (data) {
            trval = data.getReturnValue();
            console.log(JOSN.stringify(trval));
            // this.searchOptions = data.map((type) => {
            //     return {
            //         label: type.Name,
            //         value: type.Id
            //     };
            // });
            // this.searchOptions.unshift({ label: "All Types", value: "" });
        } else if (error) {
            this.searchOptions = undefined;
            this.error = error;
        }
    }
    handleSearchOptionChange(event) {
        event.preventDefault();
        this.selectedBoatTypeId = event.detail.value;
        const searchEvent = new CustomEvent("search", {
            detail: {
                boatTypeId: this.selectedBoatTypeId
            }
        });
        this.dispatchEvent(searchEvent);
    }

	handleFileChanges(event){
		let files = event.target.files;
        let tempDataList = [];
        let fileSize = 0;

        
        if (files.length > 0 && files.length <6) {
            this.totalFiles = this.totalFiles + files.length;
            if(this.totalFiles > 5 ){
                this.error = 'Exceeded maximum files to be uploaded.';
                this.totalFiles = this.totalFiles - files.length;
            }else{
                this.showLoadingSpinner = true;
                for (let i = 0; i < files.length; i++) {
                    let file = files[i];
                    fileSize = fileSize + file.size;
                }
                this.uploadedFileSize = this.uploadedFileSize + fileSize;
                if(this.uploadedFileSize > this.MAX_FILE_SIZE){
                    this.error = 'File size exceeded 6MB';
                    this.uploadedFileSize = this.uploadedFileSize - fileSize;
                    this.totalFiles = this.totalFiles - files.length;
                }else{
                    this.error = undefined;
                for (let i = 0; i < files.length; i++) {
                    let file = files[i];
                        this.tempDataList1.push({
                            FileName : file.name,
                            size : this.getReadableFileSizeString(file.size),
                            type : file.type
                        });                             
                    
                    let freader = new FileReader();
                    freader.onload = f => {
                        let base64 = 'base64,';
                        let content = freader.result.indexOf(base64) + base64.length;
                        let fileContents = freader.result.substring(content);
                        this.attachmentList.push({
                            strFileName: file.name,
                            base64Data: encodeURIComponent(fileContents)
                        });
                        
                    };
                    freader.readAsDataURL(file);
                } 
                    tempDataList = [...this.tempDataList1];
                    this.data = tempDataList;
                }          
            }
            
        }else{
            this.error = 'Exceeded maximum files to be uploaded.';
        }
		
	}

    getFilesData(fileId) {
        getFiles({recId : fileId})
        .then(data => {
            let totalFileSizeInServer = 0;
            data.forEach((record) => {
                this.tempDataList1.push({
                    FileName : record.Title,
                    size : this.getReadableFileSizeString(record.ContentSize),
                    type : record.FileType,
                    Id : record.ContentDocumentId
                });
             totalFileSizeInServer = totalFileSizeInServer + record.ContentSize; 
            });
            let tempRetrievedData = [...this.tempDataList1];
            this.data = tempRetrievedData; 
            this.uploadedFileSize = totalFileSizeInServer;
            this.totalFiles = this.tempDataList1.length;
        })
        .catch(error => {
            window.console.log('error ====> ' + error);
        })
    }

    getReadableFileSizeString(fileSize){
        console.log('file Size****'+fileSize);
        let convertedSize;
        if(fileSize < 1024){
            convertedSize = fileSize + ' B';
        }else if(fileSize <(1024*1024)){
            let fileSizeDec = fileSize/(1024);
            convertedSize = fileSizeDec.toFixed(2) + ' KB';
        }
        else if(fileSize <(1024*1024*1024)){
            let fileSizeDec = fileSize/(1024*1024);
            convertedSize = fileSizeDec.toFixed(2) + ' MB';
        }
        return convertedSize;
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('row::'+JSON.stringify(row));
        this.deleteRow(row);  
    }
    
    deleteDB(fileId){
        console.log('fileID::'+fileId);
        deleteRecord(fileId)
        .then()
        .catch(error => {
           this.error ="Error deleting attachment ::"+error.body.message;
        });
    }
    deleteRow(row) {
        const index = this.findRowIndexById(row.FileName);
        let tempDataList = [];
        if (index !== -1) {
            this.tempDataList1 = this.data
                .slice(0, index)
                .concat(this.data.slice(index + 1));
        }
        this.error = '';
        this.totalFiles = this.tempDataList1.length;
        tempDataList = [...this.tempDataList1];
        this.data = tempDataList;
        if(row.Id){
            this.deleteDB(row.Id);
        }
    }
    findRowIndexById(key) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.FileName === key) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }
    @api fetchattachmentdata() {
        return this.attachmentList;
    }
}