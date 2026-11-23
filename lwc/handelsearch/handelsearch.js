import { LightningElement,track,wire,api} from 'lwc';
import getSearchResult from '@salesforce/apex/handleSearchcontroller.getSearchResult';



import {ShowToastEvent} from 'lightning/platformShowToastEvent'
const casecolumns = [
       {  
            label: 'Action',
            type:  'button',
            typeAttributes: 
            {
              label: 'Comment', 
              name: 'Comment', 
              title: 'Comment', 
              disabled: false, 
              value: 'test'
            }
        },
    {  
        label: "CaseNumber",  
        fieldName: "CaseNumber",  
        type: "url",  
        typeAttributes: { label: { fieldName: "CaseNumber" }, tooltip:"Name", target: "_self" }  
    },
    { label: 'Status', fieldName: 'Status', type: 'text', },
    { label: 'Core Sub Status', fieldName: 'Core_Sub_Status__c', type: 'text', },
    { label:  'Severity',fieldName: 'Core_Severity__c',type:'text',},
    { label: 'Subject', fieldName: 'Subject', type: 'text', },
    { label: 'Product Name',fieldName: 'Core_IPS_Product_name__c',type:'url',},
    {label: 'Project',fieldName:'Core_IPS_Project_Case__c',type:'text'},
    {label:'Contact Name',fieldName:'Core_Contact_Name__c',type:'text'},
    { label: 'Open Date', fieldName: 'OpenDate', type: 'date', typeAttributes:{timeZone:'UTC', year:'numeric', month:'numeric', day:'numeric'}},
    {label:'Lastmodified',fieldname:'LastModifiedDate',type:'Date'},
    {label:'Legacy ID',fieldname:'Core_IPS_Legacy_IPS_ID__c',type:'Id'},
    {label:'Category',fieldname:'Core_External_Issue_Category__c',type:'text'},
    {label:'Sub Category',fieldName:'Core_External_Issue_Subcategory__c',type:'text'},
    { label: 'Close Date', fieldName: 'CloseDate', type: 'date', typeAttributes:{timeZone:'UTC', year:'numeric', month:'numeric', day:'numeric'}},
    {label:'Customer Reference',fieldName:'Core_Customer_Reference_ID__c',type:'Id'}
];
const projectcolumns = [

    {  
        label: 'Action',
        type:  'button',
        typeAttributes: 
        {
          label: 'Edit', 
          name: 'Edit', 
          title: 'Edit', 
          disabled: false, 
          value: 'test'
        }
    },
    { label: 'Project Name', fieldName: 'Name', type: 'text', },
    { label: 'Date Created', fieldName: 'CreatedDate', type: 'text', },
    { label: 'Description', fieldName: 'Core_Project_Description__c', type: 'text', },
    { label: 'Status', fieldName: 'Core_Status__c', type: 'text', }
];
const productColumns = [
    {  
        label: 'Action',
        type:  'button',
        typeAttributes: 
        {
          label: 'New Case', 
          name: 'New Case', 
          title: 'New Case', 
          disabled: false, 
          value: 'test'
        }
    },
    { label: 'Intel Product Name', fieldName: 'Name', type: 'text', },
    { label: 'Product Focus Area', fieldName: 'core_Product_Application__c', type: 'text', },
    { label: 'Support License', fieldName: 'Core_IPS_Support_License__c', type: 'text', },
    { label: 'Project Id', fieldName: 'Core_IPS_Project_Id__c', type: 'text', },
    { label: 'Premier Support Project', fieldName: 'ProjectName', type: 'text', },
    { label: 'Account Name', fieldName: 'AccountName', type: 'text', },
];
export default class Handelsearch extends LightningElement {
    @track projectcolumns=projectcolumns;
    @track productColumns=productColumns;
    @track casecolumns=casecolumns;
    @track caserecordsToDisplay;
    @track pdtRecToDisplay;
    @track prjRecToDisplay; 
  
    searchValue = '';
   @track searchdata=false;
        isLoading=false;
        @track tableLoadingState = false;
        @track err;
        @track offset=0;
        @track Prevoffset=0;

         //rowlimit = 20;

 
    searchKeyword(event) {
        this.searchValue = event.target.value;
        console.log(this.searchValue);
    
 
    // call apex method on button click 
    if(this.searchValue!=''){
        getSearchResult({
            //searchKey: this.searchValue
        searchKey: this.searchValue,
       
            })
            .then(result => {
                // set @track contacts variable with return contact list from server  
                console.log('only result',result);
               console.log('only result'+result);
               this.pdtRecToDisplay = result[1];
                this.prjRecToDisplay = result[2];
                 this.caserecordsToDisplay = result[0];

                 this.searchdata=true;
                
                    
            })
            .catch(error => {
               
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message,
                });
                this.dispatchEvent(event);
                // reset contacts var with null   
                this.pdtRecToDisplay = null;
                this.prjRecToDisplay = null;
                 this.caserecordsToDisplay = null;
            });
    }else{
       this.searchdata=false;
    }
    
  }
  
  
  

  
        }