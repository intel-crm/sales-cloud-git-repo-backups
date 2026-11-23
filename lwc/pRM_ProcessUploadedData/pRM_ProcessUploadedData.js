import {LightningElement, track, api,wire} from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { createRecord } from 'lightning/uiRecordApi';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import BULK_DATA_UPLOAD_OBJECT from '@salesforce/schema/PRM_Bulk_Data_Upload__c';
import ACCOUNT_ID from '@salesforce/schema/PRM_Bulk_Data_Upload__c.PRM_AccountId__c';
import LAST_NAME from '@salesforce/schema/PRM_Bulk_Data_Upload__c.PRM_Last_Name__c';
import FIRST_NAME from '@salesforce/schema/PRM_Bulk_Data_Upload__c.PRM_First_Name__c';
import CONTACT_EMAIL from '@salesforce/schema/PRM_Bulk_Data_Upload__c.PRM_Contact_Email__c';
import getAccountId from '@salesforce/apex/PRM_BulkInviteApex.getAccounId';

export default class PRM_ProcessUploadedData extends LightningElement {
    @api recId='6';
    @api recordId;  
    @track record;  
    initializeParser = false;
    loading = false;
    @track _results;
    @track _rows;
    @track newRows;
    toggleIconName = 'utility:preview';
    toggleButtonLabel = 'Hide Data'; 
    @api isShowModal= false;   
    @track accId;
    @track showData=false;
   // @wire (getAccountId) acctDetails;
    
    /*connectedCallback(){
       
        
        let ob=new Object();
        ob.accId=record.accountId;
        alert('sdsd'+ob.accId);
    }*/
    
    get columns(){
        const columns = [
            //{ label: 'Account Id', fieldName: 'AccountId' },
            { label: 'Contact Email', fieldName: 'ContactEmail',type:'email' },
            { label: 'Last Name', fieldName: 'LastName',type:'text' },
            { label: 'First Name', fieldName: 'FirstName',type:'text' }
        ];

        if(this.results.length){
            columns.push({ label: 'Status',fieldName: 'result' });                            
        }
        return columns;
    }    

    get rows(){
        
        if(this._rows){
            return this._rows.map((row, index) => {                  
                row.key = index;                
                if(this.results[index]){
                    //change it to status based on id value
                    row.result = this.results[index].id || this.results[index].error;
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
    }

    handleTemplate(event){
        if(event.target.files.length > 0){
            const file = event.target.files[0];
            this.loading = true;
            Papa.parse(file, {
                quoteChar: '"',
                header: 'true',
                complete: (results) => {
                    this._rows = results.data;
                    this.loading = false;                    
                },
                error: (error) => {
                    console.error(error);
                    this.loading = false;
                }
            })
        }
    }
    
    uploadBulkDataUploadRecords(){
        getAccountId()
        .then(result=>{
            this.record = result;
        })
        const RecordsToCreate = this.rows.map(row => {
            const fields = {};
           // fields[ACCOUNT_ID.fieldApiName] = '0018A00000UEkI0QAL';
            /*getAccounId().then(response => {
            console.log('response--->'+ JSON.stringify(response));
            if(response.length>0){             
                this.accId=response;
                alert('id '+this.accId);
            }})
            .catch(error =>{
                console.log('Error',error);
            });*/            

            fields[ACCOUNT_ID.fieldApiName] =  '0018A00000bPWcLQAW';
            fields[CONTACT_EMAIL.fieldApiName] = row.ContactEmail;  
            fields[LAST_NAME.fieldApiName] = row.LastName;
            fields[FIRST_NAME.fieldApiName] = row.FirstName;
            const recordInput = { apiName: BULK_DATA_UPLOAD_OBJECT.objectApiName, fields };            
            //alert('#####'+this.recordInput);
            return createRecord(recordInput);
        });

        if(RecordsToCreate.length){
            this.loading = true;
            Promise.allSettled(RecordsToCreate)
                .then(results => this._results = results)
                .catch(error => console.error(error))
                .finally(() => this.loading = false, this.isShowModal=true);                
        }
    }

    cancel(){
        this._rows = undefined;
        this._results = undefined;
    }

    showModal() {  
        this.isShowModal = true;
    }

    closeModal(){          
        this.isShowModal = false;
    }
           
    handleToggleClick() {        
        const contentBlockClasslist = this.template.querySelector(
            '.lgc-id_content-toggle'
        ).classList;        
        contentBlockClasslist.toggle('slds-hidden');
        
        if (this.toggleIconName === 'utility:preview') {
            this.toggleIconName = 'utility:hide';
            this.toggleButtonLabel = 'Show Data';
        } else {
            this.toggleIconName = 'utility:preview';
            this.toggleButtonLabel = 'Hide Data';
        }
    }
    handleBtn(){
        //this.showData = true;
        if(this.showData===false){
            this.showData=true;            
        }else if(this.showData===true){
            this.showData=false;
        }
    }
}