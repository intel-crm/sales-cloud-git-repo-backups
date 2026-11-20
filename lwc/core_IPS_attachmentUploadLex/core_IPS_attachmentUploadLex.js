import { LightningElement,api,track,wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getCurrentCase from '@salesforce/apex/Core_IPS_caseAttLinkFileCont_LEX.getCurrentCase';
import fileAttachMsg1 from '@salesforce/label/c.Core_IPS_File_CSAttachPtoCMsg';
import fileMailMsg1 from '@salesforce/label/c.Core_IPS_File_CSAttachPtoCMsg1';
import prepareUrl from '@salesforce/apex/Core_IPS_File_AttachToCase_Controller.prepareUrl'; // krishna
import Core_IPS_Upload_Attachment_LEX from '@salesforce/resourceUrl/Core_IPS_Upload_Attachment_LEX';
//Import loadStyle-Method
import {loadStyle} from "lightning/platformResourceLoader";
export default class Core_IPS_attachmentUploadLex extends NavigationMixin(LightningElement) {
    @api attachurl;
    @api recordId;
    @track caseDetails;    
    @track attachmentRecords;
    @track classification;
    @track status;    
    @track fileAttachMsg = fileAttachMsg1;
    @track fileMailMsg = fileMailMsg1;
    @track publicFile=false;
    @track privatePartner = false; 
    @track privateIntel = false;
    @track projName;
    curUrl;
    temprecid;
    cnt=0;
    arr=[];
    @track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.recordId = this.currentPageReference?.state?.c__recordId;
        if(this.cnt==1 && this.recordId != this.temprecid){
            window.location.reload();
        }
    }

    getrecordId() {
        if(this.currentPageReference != null && this.currentPageReference != undefined){
            return this.currentPageReference?.state?.c__recordId;
        }
    }
   
    connectedCallback(){
         this.curUrl = window.location.origin;
         console.log('herf=',this.curUrl);
        this.recordId = this.getrecordId();
        this.cnt = 1;
        this.temprecid = this.recordId;
       console.log('recordId',this.recordId);
        this.arr = this.recordId.split(" ");
        console.log('id=',this.arr[0]);
        console.log('type=',this.arr[1]);
        if(localStorage.getItem('resume')=='resume'){
            this.attachurl = localStorage.getItem('iframeurl'); 
            localStorage.setItem('resume',' ');  
            localStorage.setItem('iframeurl',' ');
        }
        else{
            this.getIframeurl(this.arr[0],this.arr[1]);
        }
       this.getCasedetails();
       
       loadStyle(this, Core_IPS_Upload_Attachment_LEX)
            .then(result => {});
    
       console.log('casedeatils',this.caseDetails);
       if(this.recordId.includes('Public_to_Customers') || this.recordId.includes('Public to Customers') ){
            this.publicFile = true;
       }
       if(this.recordId.includes('Private_to_Partner') || this.recordId.includes('Private to Partner') ){
            this.privatePartner = true;
       }
       if(this.recordId.includes('Private_to_Intel') || this.recordId.includes('Private to Intel') ){
            this.privateIntel = true;
       }
    }
    
    getIframeurl(Id,type){
        prepareUrl({ caseId: Id, typeoffile: type })
            .then((result) => {
                this.attachurl = result; 
                console.debug('To get iframe URL',result);
                console.log('recordId', Id);
            })
            .catch((error) => {
                this.error = error;
            }); 
        
    }
    
    getCasedetails(){ 
        getCurrentCase({ csId: this.arr[0] })
            .then(result => {
                    let cs = [];
                    console.log('result',result.CaseNumber);
                        this.classification = result.Core_IPS_Classification__c;
                        this.status = result.Status; 
                        let rowobj ={}
                        rowobj.CaseNumber = result.CaseNumber;
                        rowobj.Core_IPS_Classification__c = result.Core_IPS_Classification__c;
                        rowobj.Subject = result.Subject;
                        rowobj.core_Account_Name__c = result.core_Account_Name__c;
                        rowobj.Core_IPS_Product_name__c = result.Core_IPS_Product_name__c;
                        rowobj.Core_Sub_Status__c = result.Core_Sub_Status__c;
                        if(result.Core_IPS_Project_Case__r){
                            let ProjName = JSON.stringify(result.Core_IPS_Project_Case__r);
                            ProjName = JSON.parse(ProjName);                        
                            rowobj.Core_IPS_Project_Case__c = ProjName.Name;
                        }
                        else{
                            rowobj.Core_IPS_Project_Case__c = result.Core_IPS_Project_Case__c
                        }
                        cs.push(rowobj); 
                    this.caseDetails = cs;
                //console.log('');    
                console.log('data',this.caseDetails);
            }) 
            .catch((error) => {
                this.error = error;
                console.log('error=',this.error);
            });
    }
    
    handlenaviagateattachment(){

        console.log('hrefurl',this.curUrl);
        let str = '/lightning/r/Case/'+this.arr[0]+'/view';
        let url = this.curUrl+str;
        location.replace(url);    


          
    }
 
}