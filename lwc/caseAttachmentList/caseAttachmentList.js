/* eslint-disable no-alert */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import getattachments from '@salesforce/apex/Core_IPS_caseAttLinkFileCont_LEX.getattachments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import {refreshApex} from '@salesforce/apex';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import prepareUrl from '@salesforce/apex/Core_IPS_File_AttachToCase_Controller.prepareUrl'; // krishna
import showButtons from '@salesforce/apex/Core_IPS_caseAttLinkFileCont_LEX.showButtons';
import getCurrentCase from '@salesforce/apex/Core_IPS_caseAttLinkFileCont_LEX.getCurrentCase';
import CASEPRODUCT_ORG from '@salesforce/schema/Case.Core_IPS_Product_Org_Number__c';



const actions = [
    { label: 'Edit', name: 'Edit'}, 
    { label: 'Delete', name: 'Delete'}
];
let attachmentcolumns = [
    
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: ' bottom-left,'
        } },
    
    { label: 'Attachment Number', fieldName: 'Id', type: 'url', typeAttributes: {
        label: { fieldName: 'attachmentName' },
        target: '_blank',
    },},
    { label: 'Attachment Visibility', fieldName: 'Core_IPS_Attachment_Visibility__c', type: 'text'},
    { label: 'File Name', fieldName: 'Core_File_Name__c', type: 'text' },
    { label: 'File Description', fieldName: 'Core_File_Description__c', type: 'text' },
    { label: 'File Size', fieldName: 'Core_File_Size__c', type: 'text' },
    { label: 'File Download Link', type: 'button', fieldName: 'Core_File_URL__c',typeAttributes:  {label: {fieldName: 'Fieldlabelname'}, variant: 'brand' }
    },
    { label: 'Upload Status', fieldName: 'Core_Upload_Status__c', type: 'text' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'text' },
    
    { label: 'File Uploaded By', fieldName: 'Core_FileUploadedBy__c', type: 'text'},
    
];


const FIELDS = [CASEPRODUCT_ORG];
export default class caseAttachmentList extends NavigationMixin(LightningElement) {
     
    @track isDataAvailable = false;
    @track isLinkDataAvailable = false;
    switchView;
    searchResult;
    searchText
    wiredrecords = [];
    wiredLinkRecords =[];
    @track coreFileUploadedBy;
    
    @api recordId;
    @track isShowModal = false;
    @track attachmentURL;
    @track caseContactName;
    @track showbtnprfle = false;
    @track showdata;
    @track caseid;
    @track caseclosed;
    @track statusType;
    @track url;
    @track type = 'All data';
    @track isloading = true;

    attachmentRecords;
    columns = attachmentcolumns;
    rowLimit =10;
    rowOffSet=0;
    dataToShow=[];
    alldataToShow=[];
    linkRecords=[];
    addMoreDataCounter = true;
    @track caseStatus;
    @track addParamSymbole = '?';
    
    connectedCallback() {
        this.getUploadAttachmentUrl();
        this.checkUrlParams();
        this.RefreshValues();
        this.checkCaseStatus();
        this.getButtonsPermsission();
        
    }
    async RefreshValues() {
        await new Promise(resolve => setTimeout(resolve, 500));
        this.getRecords('Load Data');
        this.getRecords('All Data');
    }
    //Mohan
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        fetchCase(response) {
            this.record = response;
            console.log('test ck >> ',response);
        }

    //@wire(getAttachmentsRefresh,{ caseID: '$recordId'})
      @wire(getattachments,{caseID: '$recordId', limitSize : '$rowLimit',
        offset : '$rowOffSet',
        fetchType : 'All Data'})
       
        getData(result){
            this.wiredrecords = result;
            
            if(result.data){
               // console.log('refrreshdata',result.data.length);
                let attach = [];
                for(let i=0;i<result.data.length;i++){
                    let rowobj ={}
                    rowobj.Core_File_Name__c = result.data[i].Core_File_Name__c;
                    rowobj.Core_File_Description__c  = result.data[i].Core_File_Description__c ;
                    rowobj.Core_File_URL__c  = result.data[i].Core_File_URL__c ;
                    rowobj.Core_File_Size__c  = result.data[i].Core_File_Size__c ;
                    rowobj.Core_Upload_Status__c  = result.data[i].Core_Upload_Status__c ;
                    rowobj.Core_IPS_Attachment_Visibility__c = result.data[i].Core_IPS_Attachment_Visibility__c;
                    rowobj.Core_Upload_idsid__c = result.data[i].Core_Upload_idsid__c;
                    //rowobj.Name = element.Name;
                    rowobj.attachmentName =  result.data[i].Name;
                    rowobj.Id1 =  result.data[i].Id;
                    rowobj.Id = '/' + result.data[i].Id;
                    rowobj.Core_FileUploadedBy__c = result.data[i].Core_FileUploadedBy__r.Name;
                    var utcTime = new Date(result.data[i].CreatedDate);
                    var usaTime = utcTime.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                    rowobj.CreatedDate    = usaTime   ;
                    if(result.data[i].Core_Upload_Status__c=='Complete'){
                        rowobj.Fieldlabelname  = 'Download' ;
                    }
                    else{
                        rowobj.Fieldlabelname  = 'Resume' ;
                    }
                    if(rowobj.Core_FileUploadedBy__c.includes('Backend Integration User IPS') && result.data[i].Core_Upload_idsid__c != null){
                        console.log('idsid=',result.data[i].Core_Upload_idsid__c);

                        rowobj.Core_FileUploadedBy__c  = rowobj.Core_FileUploadedBy__c.concat("(",result.data[i].Core_Upload_idsid__c);
                        rowobj.Core_FileUploadedBy__c  = rowobj.Core_FileUploadedBy__c.concat("",")");
                    }
                    else{
                        let upldBy = JSON.stringify(result.data[i].Core_FileUploadedBy__r);
                        let  FileUploadByName = JSON.parse(upldBy);
                        rowobj.Core_FileUploadedBy__c = FileUploadByName.Name;
                    }
                    attach.push(rowobj);
                    if(result.data.length>0){
                        this.isDataAvailable = true;
                        this.switchView = true;
                    }
                    else{
                        this.isDataAvailable = false;
                    }
                    
                }
               // console.log('datarefresh-',this.wiredrecords);
                if(this.type=='Load Data'){
                    this.dataToShow = attach;
                }
                else if(this.type=='All Data'){
                    this.alldataToShow = attach;
                }
                this.attachmentRecords = attach;
               //  console.log('datarefresh-',this.dataToShow);                                    
            }
            else if (result.error) {
                console.log('error--' + result.error);
            }
        }

    getRecords(msg) {
        let type = msg;
         return getattachments({ caseID: this.recordId, limitSize : this.rowLimit,
            offset : this.rowOffSet,
            fetchType : type })
            .then(result => {
                const attach = [];
                let unique =[];
                console.log('queryresult=',result);
                result.forEach(element => {
                    let rowobj ={}
                    rowobj.Core_File_Name__c = element.Core_File_Name__c;
                    rowobj.Core_File_Description__c  = element.Core_File_Description__c ;
                    rowobj.Core_File_URL__c  = element.Core_File_URL__c ;
                    rowobj.Core_File_Size__c  = element.Core_File_Size__c ;
                    rowobj.Core_Upload_Status__c  = element.Core_Upload_Status__c ;
                    rowobj.Core_IPS_Attachment_Visibility__c = element.Core_IPS_Attachment_Visibility__c;
                    //rowobj.Name = element.Name;
                    rowobj.attachmentName =  element.Name;
                    rowobj.Id1 =  element.Id;
                    rowobj.Id = '/' + element.Id;
                    rowobj.Core_FileUploadedBy__c = element.Core_FileUploadedBy__r.Name;
                    var utcTime = new Date(element.CreatedDate);
                    var usaTime = utcTime.toLocaleString("en-US", {timeZone: "America/Los_Angeles"});
                    rowobj.CreatedDate    = usaTime   ;
                    if(element.Core_Upload_Status__c=='Complete'){
                        rowobj.Fieldlabelname  = 'Download' ;
                    }
                    else{
                        rowobj.Fieldlabelname  = 'Resume' ;
                    }
                    if(rowobj.Core_FileUploadedBy__c.includes('Backend Integration User IPS') && element.Core_Upload_idsid__c != null){
                        rowobj.Core_FileUploadedBy__c  = rowobj.Core_FileUploadedBy__c.concat("(",element.Core_Upload_idsid__c);
                        rowobj.Core_FileUploadedBy__c  = rowobj.Core_FileUploadedBy__c.concat("",")");
                    }
                    else{
                        rowobj.Core_FileUploadedBy__c = element.Core_FileUploadedBy__r.Name;
                    }
                    attach.push(rowobj);
                    //this.alldataToShow = attach;
                    console.log('attach=',attach);
                    if(attach.length>0){
                        this.isDataAvailable = true;
                        this.switchView = true;
                    }
                    else{
                        this.isDataAvailable = false;
                    }
                    
                });
                if(type =='Load Data'){
                    console.log('inside-if-type=',type);
                    //this.dataToShow = [];
                    this.dataToShow = [...this.dataToShow,...attach];
                }
                if(type ==='All Data'){
                   // console.log('inside-if-type=',type);
                    this.alldataToShow = [...this.alldataToShow,...attach];
                }
                
                //console.log('Attach===>',attach);
                
               // console.log('type=',type);
                //this.dataToShow = attach;
               // console.log('attachlength=',attach);
               // console.log('Datatoshow',this.dataToShow);
               // console.log('datalength',this.dataToShow);
                
               // console.log('AttintialData',this.attachmentRecords);
                
            })
            .catch(error => {
                console.error('caseAttachmentList ::: Error in loading records. Error : ', JSON.stringify(error));
                //this.showToast('ERROR', error.body.message, 'error');
                console.log('error=',error.body.message);
                this.isDataAvailable = true;
            })
            
    }
    
    handleRowActions(event) {
        const handleRowActionsEvent = new CustomEvent("rowActions", {
            detail: {
                actionName: event.detail.action.name,
                row: event.detail.row
            }
        
        });
        let rec = JSON.stringify(handleRowActionsEvent);
        let record = JSON.parse(rec);
        console.log('nameaction',record);
        let action = record.detail.row.Fieldlabelname;
        let actionName = record.detail.actionName;
            switch (actionName) {
                case 'Edit': this.editCurrentRecord(record.detail.row);
                            break;
                case 'Delete': let res = confirm('Are you sure you want to delete this IPS Case Attachment');
                               if(res == true){
                                this.deleteCurrentRecord(record.detail.row);
                               }
                               else{
                                   event.preventDefault();
                               }    
                        break;                 
            }
            //console.log('actionName=',actionName);
        if(actionName != 'Edit'){

           // console.log('inside-if-actionName=',actionName);
         if(actionName != 'Delete'){
            if(action == 'Resume'){
                localStorage.setItem('iframeurl',record.detail.row.Core_File_URL__c);
                localStorage.setItem('resume','resume');

                window.open(this.url+this.addParamSymbole+'c__recordId='+this.recordId+'+'+record.detail.row.Core_IPS_Attachment_Visibility__c,'_blank'); 
                
             }
            if(action == 'Download'){
                window.open(record.detail.row.Core_File_URL__c); 
            }
         }   
            
        }    
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    hanldeRefreshButtonClick() {
        //this.getRecords();
       // console.log('before-getrecords');
       // console.log('after-getrecords');
        this.type='Load Data';
        refreshApex(this.wiredrecords);
        return refreshApex(this.wiredLinkRecords);
        //console.log('Linkecords==',this.wiredLinkRecords);
    }
    editCurrentRecord(row) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id1,
                actionName: 'edit',
            },
        });
    }
    deleteCurrentRecord(row) {
        deleteRecord(row.Id1)
            .then(() => {
                this.showToast('SUCCESS', 'Records is Deleted', 'success');
                window.location.reload();
                //refreshApex(this.wiredrecords);
            })
            
            .catch(error => {
                this.showToast('ERROR', 'caseAttachment -- Error in deleting record. Error : '+JSON.stringify(error), 'error');
                console.error('caseAttachment -- Error in deleting record. Error : ', JSON.stringify(error));
            });
            
    }
    hanldeLinkFileButtonClick(){
        this.caseid = this.recordId;
        this.loadData ='Load Data';
        this.isShowModal = true;
        return refreshApex(this.wiredLinkRecords);
    }
    closeModal(){
        this.isShowModal = false;
    }
    showattach = false;
    getAttachmentUrl(){
        this.showattach = true;
              
            console.log('url=',this.url);
            const newWindow = window.open(this.url+this.addParamSymbole+'c__recordId='+this.recordId+'+'+'Public_to_Customers');
            console.log('newWindow', newWindow);
            newWindow.opener = null;//window.open(this.url,'_blank');
    }
    getAttachmentUrlPartners(){
        this.showattach = true;
        
            const newWindow = window.open(this.url+this.addParamSymbole+'c__recordId='+this.recordId+'+'+'Private_to_Partner');
            console.log('newWindow', newWindow);
            newWindow.opener = null;
        //    window.open(this.url,'_blank');
    }
    getAttachmentUrlIntel(){
         
        this.showattach = true;
        
            const newWindow = window.open(this.url+this.addParamSymbole+'c__recordId='+this.recordId+'+'+'Private_to_Intel');
            newWindow.opener = null;
            //window.open(this.url,'_blank');
    }

    
    getButtonsPermsission(){
        showButtons({ CaseID: this.recordId })
        .then((result) => {
            console.log('recordtype=',result);
            if( (result ==='IPS Case Create' || result=='IPS No Assigned Contact Case') && (this.caseStatus !='Closed') ){
                this.showbtnprfle = true;
            }
            //Mohan
            if(getFieldValue(this.record.data, CASEPRODUCT_ORG) == '025'){
                this.showbtnprfle = false;
            }
        })
        .catch((error) => {
            this.error = error;
            console.log('error=>',this.error);
        });
    }
    checkCaseStatus(){
        getCurrentCase({csId: this.recordId})
        .then((result) => {
            this.caseStatus = result.Status; 
        })
        .catch((error) => {
            this.error = error;
            console.log('error=>',this.error);
        });
    }
    getUploadAttachmentUrl(){
        let testURL1 = window.location.href;
        this.url  = encodeURI(testURL1);
        console.log('Url=',testURL1);
       // this.url = window.location.href;
        if(this.url.includes('lightning/r/Case')){
            console.log('url1==',this.url);
            let cururl = '/r/Case/'+this.recordId+'/view';
            let gourl = '/n/Core_IPS_Case_Attachments_LEX';
            this.url = this.url.replace(cururl,gourl);
            this.url = this.url.replace();
            console.log('url==',this.url);
        }
        else if(this.url.includes('crmdevcase--c.sandbox.vf.force.com/apex')){
            this.url =  'https://intel--crmdevcase.sandbox.lightning.force.com/lightning/n/Core_IPS_Case_Attachments_LEX';
        }
        else if(this.url.includes('crmqa3--c.sandbox.vf.force.com/apex')){
            this.url =  'https://intel--crmqa3.sandbox.lightning.force.com/lightning/n/Core_IPS_Case_Attachments_LEX';
        }
        else if(this.url.includes('crmdevint3--c.sandbox.vf.force.com/apex')){
            this.url =  'https://intel--crmdevint3.sandbox.lightning.force.com/lightning/n/Core_IPS_Case_Attachments_LEX';
        }
        else if(this.url.includes('c.visualforce.com/apex') || this.url.includes('c.vf.force.com/apex')){
            this.url ='https://intel.lightning.force.com/lightning/n/Core_IPS_Case_Attachments_LEX';
        }
    }
    attachmentsearchbox(event) {
        try{
            let tempattach = [];
            this.searchText = event.target.value;
            console.log('search-text',this.searchText);
            if(this.searchText) {
                this.attachmentRecords.forEach(attach =>{
                    if(attach.Core_File_Name__c != undefined && attach.Core_File_Name__c.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    } else if(attach.Core_File_Description__c != undefined && attach.Core_File_Description__c.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    } else if(attach.Core_Upload_Status__c != undefined && attach.Core_Upload_Status__c.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    } else if(attach.Core_IPS_Attachment_Visibility__c != undefined && attach.Core_IPS_Attachment_Visibility__c.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    }
                    else if(attach.attachmentName != undefined && attach.attachmentName.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    }
                    else if(attach.Core_FileUploadedBy__c != undefined && attach.Core_FileUploadedBy__c.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    }
                    else if(attach.Fieldlabelname != undefined && attach.Fieldlabelname.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    }
                    else if(attach.CreatedDate != undefined && attach.CreatedDate.toLowerCase().indexOf(this.searchText.toString().toLowerCase()) !== -1){
                        tempattach.push(attach);
                    }
                });
                console.log('tempvar',tempattach);
                this.searchResult = tempattach;
                console.log('searchresult=',this.searchResult);
                this.switchView =false;
            } else {
                this.switchView = true;
            }
        }catch(error){
            console.log('error in search handler '+error.message());
        }    
    }
    handleLoadMore(event) {
        const currentRecord = this.dataToShow;
        console.log('data-loading');
        const { target } = event;
        target.isLoading = true;
        if(this.rowOffSet <= 200){
            this.rowOffSet = this.rowOffSet + this.rowLimit;
            console.log('inside-if-rowoffset',this.rowOffSet);
            this.getRecords('Load Data')
                .then(()=> {
                    target.isLoading = false;
                });
        }
        else{
            this.isloading = false;
            target.isLoading = false;
        } 
        
    }

    //Method to check weather there are paramters alreadyc available or not in URL based upon decide the symoble;
    checkUrlParams(){
        if(this.url){
            this.addParamSymbole = this.url.includes('?') ? '&' : '?';
            console.log('addparasymbole', this.addParamSymbole);
        }
    }
    
}