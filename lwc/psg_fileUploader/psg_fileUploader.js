import {LightningElement, track,wire, api} from 'lwc';
//import getFiles from '@salesforce/apex/PSG_QuoteRequestController.fetchFiles';
import { deleteRecord } from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
//import downloadFiles from '@salesforce/apex/PSG_QuoteRequestController.fetchDocumentDownloadUrl';

const columns = [
    { label: 'File Name',fieldName: 'FileName',type: 'text' },
    { label: 'File Size',fieldName: 'size',type: 'text' },
    { label: 'File Type',fieldName: 'type',type: 'text' },
    { label: 'Created Date',fieldName: 'CreatedDate',type: 'date',typeAttributes: {  
        day: 'numeric',  
        month: 'short',  
        year: 'numeric',  
        hour: '2-digit',  
        minute: '2-digit',  
        hour24: true}},
    { label: 'Delete',type:'button-icon',
        typeAttributes: {
            iconName: 'utility:delete',
            name: 'delete',
            fixedWidth:2
        }
    }
    /*{label: 'Download', fieldName: 'DownloadFile', type:'button-icon', 
        typeAttributes: {
            iconName: 'utility:download',
            name: 'download',
            fixedWidth:2
        }
    }*/
];

const columnsLocked = [
    { label: 'Title',fieldName: 'FileName',type: 'text' },
    { label: 'File Size',fieldName: 'size',type: 'text' },
    { label: 'File Type',fieldName: 'type',type: 'text' },
    { label: 'Created Date',fieldName: 'CreatedDate',type: 'date', typeAttributes: {  
        day: 'numeric',  
        month: 'short',  
        year: 'numeric',  
        hour: '2-digit',  
        minute: '2-digit', 
        hour24: true}}
];

export default class psg_fileUploader extends NavigationMixin (LightningElement) {
    showLoadingSpinner = false;
	@api recordId;
	keyRecordId;
    @track fileNames = '';
    @track filesUploaded = [];
    @track data;
    @track columns = columns;
    @track columnsLocked=columnsLocked;
    @track error;
    @track attachmentList = [];
    @track showList=false;
    @api lockRecord;
    @track isEdit=false;
    //@api downloadUrl;
    attCounter=0;
    attUploadCounter=0;

    MAX_FILE_SIZE = 2000000; //6MB
    tempDataList1 = [];
    uploadedFileSize = 0;
    totalFiles = 0;

    connectedCallback(){
        if(this.recordId){
            //this.getFilesData(this.recordId);
            this.isEdit=true;
        }
    }

	handleFileChanges(event){
		let files = event.target.files;
        let tempDataList = [];
        let fileSize = 0;

        if (files.length > 0 /*&& files.length <6*/) {
            this.totalFiles = this.totalFiles + files.length;
           /* if(this.totalFiles > 5 ){
                this.error = 'Exceeded maximum files to be uploaded.';
                this.totalFiles = this.totalFiles - files.length;
            }else{*/
                this.showLoadingSpinner = true;
                for (let i = 0; i < files.length; i++) {
                    let file = files[i];
                    fileSize = fileSize + file.size;
                }
                console.log('Total file size of uploaded files '+ fileSize);
                this.uploadedFileSize = this.uploadedFileSize + fileSize;
                console.log('Total file size of uploaded and existing files '+ this.uploadedFileSize);

                if(this.uploadedFileSize > this.MAX_FILE_SIZE){
                    this.error = 'File size exceeded 2MB';
                    this.uploadedFileSize = this.uploadedFileSize - fileSize;
                    this.totalFiles = this.totalFiles - files.length;
                }else{
                    console.log('Uploaded file size'+this.uploadedFileSize);
                    this.error = undefined;
                    for (let i = 0; i < files.length; i++) {
                        let file = files[i];
                        this.tempDataList1.push({
                            FileName : file.name,
                            size : this.getReadableFileSizeString(file.size),
                            type : file.type,
                            id : ++this.attCounter,
                            fsize:file.size
                        });   
                        let freader = new FileReader();
                        freader.onload = f => {
                            let base64 = 'base64,';
                            let content = freader.result.indexOf(base64) + base64.length;
                            let fileContents = freader.result.substring(content);
                            this.attachmentList.push({
                                strFileName: file.name,
                                base64Data: encodeURIComponent(fileContents),
                                id: ++this.attUploadCounter
                            });
                        };
                        freader.readAsDataURL(file);
                    } 
                    tempDataList = [...this.tempDataList1];
                    this.data = tempDataList;
                    if(this.data.length>0){
                        this.showList=true;
                    }
                    else{
                        this.showList=false;
                    }
                }          
           // }
        }/*else{
            this.error = 'Exceeded maximum files to be uploaded.';
        }*/
	}

    

    /*getFilesData(recId) {
        getFiles({quoteId : recId})
        .then(data => {
            let totalFileSizeInServer = 0;
            data.forEach((record) => {
                this.tempDataList1.push({
                    FileName : record.Title,
                    size : this.getReadableFileSizeString(record.ContentSize),
                    type : record.FileType,
                    recordId : record.Id,
                    cdId : record.ContentDocumentId,
                    id: ++this.attCounter,
                    CreatedDate : record.CreatedDate,
                    fsize:record.ContentSize
                });
                totalFileSizeInServer = totalFileSizeInServer + record.ContentSize; 
            });
            let tempRetrievedData = [...this.tempDataList1];
            this.data = tempRetrievedData; 
            this.uploadedFileSize = totalFileSizeInServer;
            this.totalFiles = this.tempDataList1.length;
            if(this.data.length>0){
                this.showList=true;
            }
            else{
                this.showList=false;
            }
        })
        .catch(error => {
            window.console.log('error ====> ' + error);
        })
    }*/

    getReadableFileSizeString(size){
        if (size < 1024) {
            return size + ' B'
        }
        let i = Math.floor(Math.log(size) / Math.log(1024))
        let num = (size / Math.pow(1024, i))
        let round = Math.round(num)
        num = round < 10 ? num.toFixed(2) : round < 100 ? num.toFixed(1) : round
        return `${num} ${'KMGTPEZY'[i-1]}B`
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            case 'delete':
                this.deleteRow(row);                
                break;
                
            /*case 'download':
                this.downloadRow(row);
                break;*/
            }

    }


    //https://intel--crmdevsls3-intelcloudcrm.cs69.force.com/sfc/servlet.shepherd/document/download/0692D000000j9TEQAY - redirect 
    //https://intel--crmdevsls3.lightning.force.com/sfc/servlet.shepherd/document/download/0692D000000j9SpQAI?operationContext=S1 - internal
    
    //https://crmdevsls3-intelcloudcrm.cs69.force.com/sfc/servlet.shepherd/document/download/0692D000000j9TEQAY?operationContext=S1


    

    // getBaseUrl(){
    //     let baseUrl = 'https://intel--' + location.host + '/';
    //     //let newUrl = baseUrl.replace("-intelcloudcrm.cs69",".lightning")
    //     return baseUrl;
    // }

    downloadRow(file) {

        let stringifiedData = JSON.stringify(file);
        let finalData = JSON.parse(stringifiedData);
        console.log('getBase URL'+ finalData);
        console.log('getBase URL Stringified' + stringifiedData)
        //let downloadUrl = this.downloadUrlLink(file.cdId);
        // console.log('BaseUrl>>>' + baseUrl)
        // console.log('New Url>>>' + newUrl)
        // let newBaseUrlArr = baseUrl.split("//");
        // let newBaseUrl = newBaseUrlArr[0] + '//intel--' + newBaseurl[1]
        console.log('DownloadURL>>>' + downloadUrl)
                                    
        //let downloadUrl = newUrl + 'sfc/servlet.shepherd/document/download/' + file.ContentDocumentId + '?operationContext=S1';
        console.log('Insdide Download')

    }

    deleteRow(row) {
        const index = this.findRowIndexById(row.id);
        const index2= this.findRowIndexById2(row.id);
        let tempDataList = [];
        let tempAttList=this.attachmentList;
        if (index !== -1) {
            this.tempDataList1 = this.tempDataList1
                .slice(0, index)
                .concat(this.data.slice(index + 1));
            this.attachmentList = this.attachmentList
                .slice(0, index2)
                .concat(tempAttList.slice(index2 + 1));
            if(row.cdId){
                this.deleteFromDB(row.cdId);
            }
            this.uploadedFileSize=this.uploadedFileSize-row.fsize;
        }
        this.error = '';
        this.totalFiles = this.tempDataList1.length;
        tempDataList = [...this.tempDataList1];
        this.data = tempDataList;
        if(this.data.length>0){
            this.showList=true;
        }
        else{
            this.showList=false;
        }
    }

    deleteFromDB(recId){
        deleteRecord(recId)
        .then(() => {
            this.showToast('Success','Attachment was deleted','success');
        })
        .catch(error => {
            this.showToast('Error deleting record',error.body.message,'error');
        });
    }
    //*********DownloadUrlFun */
    /*downloadUrlLink(cdId) {
        let downloadUrlLink;
        downloadFiles({ContentDocumentId : cdId})
        .then(data => {
			downloadUrlLink = data; 
			console.log('DownloadURLInsideFun>>>' + downloadUrlLink)
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: downloadUrlLink
                    //url: 'https://intel--crmdevsls3.lightning.force.com/sfc/servlet.shepherd/document/download/0692D000000j9SpQAI?operationContext=S1'
                }
            }, false);

        })
        .catch(error => {
            window.console.log('error ====> ' + error);
            console.log('errorConsoleLog ====> ' + error);
        })
        return downloadUrlLink;
    }*/
//*********** */
    findRowIndexById(id) {
        let ret = -1;
        this.tempDataList1.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    findRowIndexById2(id) {
        let ret = -1;
        this.attachmentList.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    showToast(msgTitle,msg,type){
        this.dispatchEvent(
            new ShowToastEvent({
                title: msgTitle,
                message: msg,
                variant: type,
                mode: 'dismissable'
            }),
        );
    }

    @api fetchattachmentdata() {
        var attList=[];
        console.log('length?',this.attachmentList.length);
        for(var i=0;i<this.attachmentList.length;i++){
            console.log(this.attachmentList[i].strFileName);
            attList.push({
                strFileName: this.attachmentList[i].strFileName,
                base64Data: this.attachmentList[i].base64Data
            });
        }
        return attList;
    }
}