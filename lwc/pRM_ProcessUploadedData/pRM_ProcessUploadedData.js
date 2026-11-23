import {LightningElement, track, api,wire} from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { createRecord } from 'lightning/uiRecordApi';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import loadingCss from '@salesforce/resourceUrl/loadingCss';
import BULK_DATA_UPLOAD_OBJECT from '@salesforce/schema/PRM_Bulk_Data_Upload__c';
import ACCOUNT_ID from '@salesforce/schema/PRM_Bulk_Data_Upload__c.PRM_AccountId__c';
import LAST_NAME from '@salesforce/schema/PRM_Bulk_Data_Upload__c.PRM_Last_Name__c';
import FIRST_NAME from '@salesforce/schema/PRM_Bulk_Data_Upload__c.PRM_First_Name__c';
import CONTACT_EMAIL from '@salesforce/schema/PRM_Bulk_Data_Upload__c.PRM_ContactEmail__c';
import getAccountId from '@salesforce/apex/PRM_BulkInviteApex.getAccounId';
import { exportAsCSV } from 'c/pRM_Utils';
import createBulkRecords from '@salesforce/apex/PRM_BulkInviteApex.createBulkRecords';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getstatus from '@salesforce/apex/PRM_BulkInviteApex.getstatus';
import getWaitStatus from '@salesforce/apex/PRM_BulkInviteApex.getUploadStatusInWaiting';
import retryStatusOver from '@salesforce/apex/PRM_BulkInviteApex.retryStatusOver';
import PRM_Upload_Message from '@salesforce/label/c.PRM_Upload_Message';
import PRM_Success_AlertMsgBulk from '@salesforce/label/c.PRM_Success_AlertMsgBulk';
import PRM_Discard_AlertMsgBulk from '@salesforce/label/c.PRM_Discard_AlertMsgBulk';
import PRM_Fail_AlertMsgBulk from '@salesforce/label/c.PRM_Fail_AlertMsgBulk';
import PRM_Wait_alermsgBulk from '@salesforce/label/c.PRM_Wait_alermsgBulk';
import PRM_PleaseWaitSpinnerBulk from '@salesforce/label/c.PRM_PleaseWaitSpinnerBulk';
import PMP_Okay from '@salesforce/label/c.PMP_Okay';
import PRM_ProcessingTimer from '@salesforce/label/c.PRM_ProcessingTimer';
import PRM_PleaseWaitTimer from '@salesforce/label/c.PRM_PleaseWaitTimer';

export default class PRM_ProcessUploadedData extends LightningElement {
    @track timeoutID;
    @track waitStatusTimeoutID;
    @track status;
    @track isShowModalSuccess= false; 
    @track isShowModalFail= false; 
    @api recId='6';
    @api recordId;  
    @track record;  
    initializeParser = false;
    loading = false;
    @track _results;
    @track _rows=[];
    @track newRows;
    toggleIconName = 'utility:hide';
    toggleButtonLabel = 'Show Data'; 
    @api isShowModal= false;   
    @track accId;
    @track returnresult;
    datainstring;
    rowsplit;
    @track isFailed;
    @track isSuccess;
    @track showData=false;
   // @wire (getAccountId) acctDetails;
   @track fileInput;
   @api mapOfValues1=[];
   event1;
   @track isLoading=false;
   @track disableButton=false;
   subscription = {};
   @api channelName = '/event/PRM_Bulk_Invite__e';
   @track resultEvent='';
   @track waitStatus='';
  @track isStopBar=false;
  @track isWaitStatus=false;
  @track retryStatus=false;
  @track count=0;
  @track retryString='';
  @track isWaitStatusOver=false;
    /*connectedCallback(){
     
        let ob=new Object();
        ob.accId=record.accountId;
        alert('sdsd'+ob.accId);
    }*/
    label = {
        PMP_Okay,
        PRM_PleaseWaitSpinnerBulk,
        PRM_Upload_Message,
        PRM_Success_AlertMsgBulk,
        PRM_Discard_AlertMsgBulk,
        PRM_Fail_AlertMsgBulk,
        PRM_Wait_alermsgBulk,
        PRM_ProcessingTimer,
        PRM_PleaseWaitTimer
        

    };
   
    get columns(){
        const columns = [
            //{ label: 'Account Id', fieldName: 'AccountId' },
            { label: 'Contact Email', fieldName: 'ContactEmail',type:'text' },
            { label: 'Last Name', fieldName: 'LastName',type:'text' },
            { label: 'First Name', fieldName: 'FirstName',type:'text' },
            { Label : 'Contact Country', fieldName: 'ContactCountry',type: 'text'}
        ];

        if(this.returnresult!=null){
            columns.push({ label: 'Status',fieldName: 'status',type: 'text' });                            
        }
        return columns;
    }    

    get rows(){
        
        if(this._rows){
            return this._rows.map((row, index) => {                  
                //row.key = index;                
                if(this.results[index]){
                    //change it to status based on id value
                    row.result = this.results[index].id ;
                }
                
                return row;                
            })
        }

        return [];
    }
    
    get results(){
        if(this._results){
            return this._results.map(r => {
                const result = {};
                result.success = r.status === 'fulfilled';
                result.id = result.success ? r.value.id : undefined;
                result.error = !result.success ? r.reason.body.message : undefined;                
                return result;                
            });
            
        }        
        return [];
    }

    renderedCallback() {
        if(!this.initializeParser){
            loadScript(this, PARSER)
                .then(() => {
                    this.initializeParser = true;
                })
                .catch(error => console.error(error));
        }      
        this.fileInput=this.template.querySelector(('input[type="file"]'));
    }

    // handleTemplate(event){
    //     if(event.target.files.length > 0){
    //         const file = event.target.files[0];
    //         this.loading = true;
    //         Papa.parse(file, {
    //             quoteChar: '"',
    //             header: 'true',
    //             complete: (results) => {
    //                 this._rows = results.data.slice(0, -1);
    //                 this.loading = false;                    
    //             },
    //             error: (error) => {
    //                 console.error(error);
    //                 this.loading = false;
    //             }
    //         })
    //     }
    //   //  uploadBulkDataUploadRecords();
    //     console.log('result-->'+result);
    //     //this.showModal();
    // }
   
     @api async uploadBulkDataUploadRecords(event){
       console.log('file length-->'+event.target.files.length);
              if(event.target.files.length > 0){
            const file = event.target.files[0];
            this.loading = true;
            Papa.parse(file, {
                quoteChar: '"',
                header: 'true',
                complete: (results) => {
                    this._rows = results.data.slice(0, -1);
                    this.loading = false;                    
                },
                error: (error) => {
                    console.error(error);
                    this.loading = false;
                }
            })
        }
        this.record =await getAccountId();
        this.datainstring=JSON.stringify(this.rows); 
     //   this.showModal();
       this.returnresult=await createBulkRecords({accId:this.record,rowData:this.datainstring});
       
       // this.showModal();
       this.resetFileInput();
        console.log('this.rows-->'+JSON.stringify(this.rows));
        console.log('this.record-->'+this.record);
        console.log('this.datainstring-->'+this.datainstring);
       
      
       console.log('rows after bulk op-->'+this._rows);
       this.disableButton=true;
       this.isShowModal=true;
    //    setTimeout(() => {
    //     this.isShowModal=false;
    //     this.getstatus();
    // }, 120000);
     
       }
       
       handleRefreshPage() {
        setTimeout(() => {
            //  this.isShowModal=false;
            location.reload();
          }, 20000);
          }
        
    
    @api async getstatus(){
        
        this.resultEvent=await getstatus();
       
        console.log('isShowModalSuccess:1',this.isShowModalSuccess);
        console.log('resultEvent:1',this.resultEvent);
        if(this.resultEvent=='Success'){    
            this.isShowModalSuccess=true;
            console.log('isShowModalSuccess:2',this.isShowModalSuccess);
            this.disableButton=false;
            this.isShowModal=false;
            this.handleRefreshPage();
        }else if(this.resultEvent=='Failed'){
            
            this.isShowModalFail=true;
          //  this.isShowModal=true;
            console.log('isShowModalFail:3',this.isShowModalFail);
            this.disableButton=false;
            this.isShowModal=false;
            this.handleRefreshPage();
        }else if(this.resultEvent=='Wait'){
            this.isShowModalFail=false;
            this.isShowModalSuccess=false;
            this.getWaitStatus(0);
        }
        if(this.resultEvent!=null || this.resultEvent!=undefined){
            console.log('isLoad');
            console.log('isShowModalSuccess:4',this.isShowModalSuccess);
            console.log('isShowModalFail:4',this.isShowModalFail);
           // this.disableButton=false;
           
        }
        
        clearTimeout(this.timeoutID);
    }
    
    resetFileInput() { 
        if (this.fileInput) { 
        this.fileInput.value = ''; // Reset the value of the file input field 
        this.file = undefined; // Reset the selected file 
        } 
        this.timeoutID= setTimeout(() => {
          //  this.isShowModal=false;
            this.getstatus();
        }, this.label.PRM_ProcessingTimer);
        }
   
    cancel(){
        this._rows = undefined;
        this._results = undefined;
    }

    // showModal() {  
    //     this.isShowModal = true;
        
    // }

    closeModal(){          
        this.isWaitStatus=false;
        this.isWaitStatusOver=false;
        this.isShowModalSuccess=false;
        this.isShowModalFail=false;
    }
    //platform event start:
    connectedCallback() {
      //this.getWaitStatus();
        this.handleSubscribe();
        // this.waitStatusTimeoutID= setTimeout(() => {
        //     this.getWaitStatus();
        // }, 30000);
       
    }
   //progress bar
   //progress bar:
   progress = 0;
   isProgressing = false;

  
  //show progress bar:
  get computedLabel() {
      return this.isProgressing ? 'Stop' : 'Start';
  }

  actionToggleBar() {
      if (this.isProgressing) {
          // progress bar stop
          this.isProgressing = false;
          clearInterval(this._interval);
      } else {
          // progress bar start
          this.isProgressing = true;            
          this._interval = setInterval(() => {
              this.progress = this.progress === 100 ? 0 : this.progress + 1;
          }, 100);
      }
  }

  disconnectedCallback() {
      // the component gets disconnected       
      clearInterval(this._interval);
     
  }
 
  handleSubscribe(){
      this.actionToggleBar();
  }
    
 @api async getWaitStatus(count){
    this.count=  count;
    console.log(' this.count-->', this.count);
this.waitStatus=await getWaitStatus();
console.log('this.waitStatus1-->',this.waitStatus);
if(this.waitStatus=='Wait'){
   
   if(this.count<=4){
        
        this.waitStatusTimeoutID= setTimeout(() => {
            this.count=this.count+1;
         console.log(' this.count1-->', this.count);
            this.getWaitStatus(this.count);
        }, this.label.PRM_PleaseWaitTimer);
        
       // this.count=this.count+1;
        console.log(' this.count2-->', this.count);
        if(this.count==3){
            this.isWaitStatus=true;
        }
        if(this.count==4){
            this.retryStatus=true;
            console.log(' this.retryStatus-->', this.retryStatus);
           // this.retryString= await retryStatusOver({retrycount:this.retryStatus});
           this.retryString= await retryStatusOver();
            console.log('this.retryString-->',this.retryString);
            if(this.retryString=='Discarded'){
                this.isWaitStatusOver=true;
                this.disableButton=false;
                this.isShowModal=false;
            }
            clearTimeout(this.waitStatusTimeoutID);
            
    }
    
   }
    console.log('this.waitStatus2-->',this.waitStatus);
}
if(this.waitStatus=='Success'){    
    this.isShowModalSuccess=true;
    console.log('isShowModalSuccess:2',this.isShowModalSuccess);
    this.disableButton=false;
    this.isShowModal=false;
    //this.handleRefreshPage();
}else if(this.waitStatus=='Failed'){
    
    this.isShowModalFail=true;
  //  this.isShowModal=true;
    console.log('isShowModalFail:3',this.isShowModalFail);
    this.disableButton=false;
    this.isShowModal=false;
    //this.handleRefreshPage();
}
// else if(this.waitStatus=='Processed'){
//     console.log('this.waitStatu3s-->',this.waitStatus);
//     this.isWaitStatus=false;
   
// }

 }   

}