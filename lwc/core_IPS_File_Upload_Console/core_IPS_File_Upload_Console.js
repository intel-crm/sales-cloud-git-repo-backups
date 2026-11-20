import { LightningElement,track,api } from 'lwc';
import Core_IPS_File_Upload_Console_LEX_Header from '@salesforce/resourceUrl/Core_IPS_File_Upload_Console_LEX_Header';
import getFileUploadConsoleUrl from '@salesforce/apex/Core_IPS_File_Upload_Console_Cont_LEX.getFileUploadConsoleUrl';
import getUploadedFiles from '@salesforce/apex/Core_IPS_File_Upload_Console_Cont_LEX.getUploadedFiles';
import getCurrentLoggedinUserName from '@salesforce/apex/Core_IPS_File_Upload_Console_Cont_LEX.getCurrentLoggedinUserName';
import {loadStyle} from "lightning/platformResourceLoader";

const fileColumns = [
    {
    label: 'File Upload Number',
    fieldName: 'Id',
    type: 'url',
    typeAttributes: {
        label: { fieldName: 'Name' },
        target: '_blank',
        },
    },
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
        
    },
    {
        label: 'File Size',
        fieldName: 'fileSize',
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
        label: 'File Uploaded By',
        fieldName: 'uploadedBy',
        type: 'text',
    }   
]   



export default class Core_IPS_File_Upload_Console extends LightningElement {
           
    @track upldUrl;
    @track taburl;
    @track fileAssignmentUrl;
    @track LoggedUserName;
    @track showData = false;
    @track FileRecordUrl;

    dataToShow =[];
    columns = fileColumns;

    connectedCallback(){
        loadStyle(this, Core_IPS_File_Upload_Console_LEX_Header)
            .then(result => {});
        this.taburl = window.location.href;
        this.fileAssignmentUrl = this.taburl;
        this.FileRecordUrl = this.taburl;

        this.getUsrName();
        this.getFiles();
    }

    getUsrName(){
        getCurrentLoggedinUserName({}).then(result=>{
            this.LoggedUserName = result;
        })
        .catch(error=>{
            console.log('Error in getting Name=>',error);
        })
    }
    getFiles(){
        getUploadedFiles({}).then(result=>{
            console.log('FilesList=>',result);
            if(result.length>0){
                let filesList =[];
                let files =[];
                this.showData = true;
                result.forEach(element => {
                    let rowobj ={}
                    this.FileRecordUrl =  this.FileRecordUrl.replace('n/IPS_File_Upload_Console_LEX','r/');
                    this.FileRecordUrl =  this.FileRecordUrl  + element.Id + '/' +'view';
                    rowobj.Id = this.FileRecordUrl;
                    rowobj.Name = element.Name;
                    rowobj.fileName = element.Core_File_Name__c;
                    if(element.Core_Upload_Status__c=='Complete'){
                        rowobj.Download = 'Download';
                    }
                    else{
                        rowobj.Download = 'Resume';
                    }
                    rowobj.fileDescription = element.Core_File_Description__c;
                    rowobj.fileSize = element.Core_File_Size__c;
                    rowobj.fileDownload = element.Core_File_URL__c;
                    rowobj.uploadStatus = element.Core_Upload_Status__c;
                    rowobj.uploadedBy = this.LoggedUserName;
                    files.push(rowobj);
                    this.FileRecordUrl = window.location.href;
                });
                this.dataToShow = [...this.dataToShow,...files];
                console.log('Files=>',this.dataToShow);
            }
        })
        .catch(error=>{
            console.log('Error in getting Files=>',error);
        })
    }
    refreshPage(){
        window.location.reload();
    }
    getUploadUrl(){
        getFileUploadConsoleUrl({}).then(result=>{
            this.upldUrl = result;
            console.log('File Upload Url=',this.upldUrl);
            window.open(this.upldUrl,'_blank');
        })
        .catch(error=>{
            console.log('Error=>',error);
        })
    }
    navigateToFileUploadMasterList(){
        let str = 'o/Core_IPS_File_Upload_Master__c/list?filterName=Recent'
        this.taburl = this.taburl.replace('n/IPS_File_Upload_Console_LEX',str);
        window.open(this.taburl,'_blank');     
    }
    navigateToFileAssignmentList(){
        let str = 'o/Core_IPS_File_Assignment__c/list?filterName=Recent'
        this.fileAssignmentUrl = this.fileAssignmentUrl.replace('n/IPS_File_Upload_Console_LEX',str);
        window.open(this.fileAssignmentUrl,'_blank');
    }   
}