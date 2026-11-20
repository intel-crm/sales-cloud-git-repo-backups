import { LightningElement,api,track,wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getCurrentCase from '@salesforce/apex/Core_IPS_TestAllRecords.getCurrentCase';
import getcurrentuserprofile from '@salesforce/apex/Core_IPS_TestAllRecords.getcurrentuserprofile';
import prepareUrl from '@salesforce/apex/Core_IPS_File_AttachToCase_Controller.prepareUrl'; // krishna
import getattachments from '@salesforce/apex/Core_IPS_TestAllRecords.getattachments';
import fileAttachMsg1 from '@salesforce/label/c.Core_IPS_File_CSAttachPtoCMsg';
import fileMailMsg1 from '@salesforce/label/c.Core_IPS_File_CSAttachPtoCMsg1';


/*let columns = [
    { label: 'File Name', fieldName: 'Core_File_Name__c', type: 'text' },
    { label: 'Description', fieldName: 'Core_File_Description__c', type: 'text' },
    { label: 'File Download Link', type: 'button', fieldName: 'Core_File_URL__c', typeAttributes:  {label: {fieldName: 'Fieldlabelname'}, variant: 'brand'}
        
    },
    
];*/



export default class Core_IPS_caseAttachments extends NavigationMixin(LightningElement) {
    @api attachurl;
    @api recordId;
    @track caseDetails;    
    //@track attachmentRecords;
    //attachmentcolumns = columns;
    @track publicFile=false;
    @track privatePartner = false; 
    @track privateIntel = false;
    @track fileAttachMsg = fileAttachMsg1;
    @track fileMailMsg = fileMailMsg1;
    @track showMsg = false;

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
        let uri = localStorage.getItem('iframeurl');
        this.attachurl = encodeURI(uri);
        this.recordId = this.getrecordId();
        this.arr = this.recordId.split(" ");
        console.log('id',this.arr[0]);
        console.log('type',this.arr[1]);
        console.log('record-ID from currentpageref',this.getrecordId());
        //getCurrentCase({ csId: this.attachurl})
      //this.attachurl= localStorage.getItem('iframeurl');
       if(localStorage.getItem('resume')=='resume'){
           this.attachurl = localStorage.getItem('iframeurl');
           localStorage.setItem('iframeurl',' ');
           localStorage.setItem('resume',' ');
       }
       else{
           this.getIframeurl(this.arr[0],this.arr[1]);
       }
       localStorage.setItem('selected','attachments');
       
       this.getCasedetails();
      
      
       if(this.arr[1] == 'Public_to_Customers'){
        this.publicFile = true;
        }
        if(this.arr[1]== 'Private_to_Partner'){
            this.privatePartner = true;
        }
        if(this.arr[1]=='Private_to_Intel'){
            this.privateIntel = true;
        }
        this.getcurrentuserprofile();
    }

    getIframeurl(Id,type){
        prepareUrl({ caseId: Id, typeoffile: type })
            .then((result) => {
                this.attachurl = result; 
                console.debug('To get iframe URL',result);
                //localStorage.setItem('iframeurl', this.attachurl);
                console.log('recordId', Id);
               // console.log('Iframe-URL',localStorage.getItem('iframeurl'));
               // console.log('record-ID',localStorage.getItem('recordId'));
            })
            .catch((error) => {
                this.error = error;
            }); 
        
    }

    handlenaviagateattachment(){
       
        window.open("case-detail?recordId=" + this.arr[0], "_self");
        
    }
    
    @track classification;
    @track status;
    getCasedetails(){ 
        let uri = localStorage.getItem('recordId');
        let encoded = encodeURI(uri);
        getCurrentCase({ csId: this.arr[0]})
        //getCurrentCase({ csId: localStorage.getItem('recordId') })
            .then(result => {
                    let cs = [];
                   
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
                        }cs.push(rowobj); 
                    
                    
                    this.caseDetails = cs;
                  
               
            }) 
            .catch((error) => {
                this.error = error;
               
            });
    }
    /*@track attachmentData;
    @track click;
    getAttach() {
     
        getattachments({caseID: this.recordid})
            .then(result => {
                this.attachmentRecords = result;
              
                this.attachmentInitialRecords = result;
                
                
                let attach = [];
                result.forEach(element => {
                    let rowobj ={}
                    rowobj.Id =  element.Id;
                    rowobj.Core_File_Name__c = element.Core_File_Name__c;
                    rowobj.Core_File_Description__c  = element.Core_File_Description__c ;
                    rowobj.Core_File_URL__c  = element.Core_File_URL__c ;
                    rowobj.Core_Upload_Status__c  = element.Core_Upload_Status__c ;
                    if(element.Core_Upload_Status__c=='Complete'){
                        rowobj.Fieldlabelname  = 'Download' ;
                        
                        
                    }
                    else{
                        rowobj.Fieldlabelname  = 'Resume' ;
                         }
                    attach.push(rowobj);
                    
                    
                });
                this.attachmentData = attach;
                this.attachmentInitialRecords = attach;
               
                this.showTable = true;
            })
            .catch(error => {
                this.error = error;
               
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Cases',
                        message: error.message,
                        variant: 'error'
                    }),
                );
                this.attachmentRecords = undefined;
                this.attachmentInitialRecords = undefined;
            });           
            
    }
    attRowAction(event){
        const recId =  event.detail.row;  
        const actionName = event.detail.action;
        const record = JSON.stringify(recId);
        const recs = JSON.parse(record);
        let action = recs.Fieldlabelname;
        
        if(action == 'Resume'){
           window.open('attachment-upload','_blank');
           localStorage.setItem('iframeurl','recs.Core_File_URL__c');
        }
        if(action == 'Download'){
           window.open(recs.Core_File_URL__c); 
        }
        
  
    }*/
    getcurrentuserprofile(){
        getcurrentuserprofile({})
        .then(result => {
            if(result=='PartnerFAE')
            this.showMsg = true;
        })  
        .catch(error => { 
           
        })    

    }
}