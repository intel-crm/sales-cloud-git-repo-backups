import { track,wire,LightningElement,api } from 'lwc';
import getProgPicklistValues from '@salesforce/apex/Core_MDF_CCP_Mass_Owner_Update.getProgramList';
import getAccountPicklistValues from '@salesforce/apex/Core_MDF_CCP_Mass_Owner_Update.getAccountList';
import getNodeAccountPicklistValues from '@salesforce/apex/Core_MDF_CCP_Mass_Owner_Update.getNodeAccountList';
import getObjectPicklistValues from '@salesforce/apex/Core_MDF_CCP_Mass_Owner_Update.getObjectList';
//import getObjectTransactions from '@salesforce/apex/Core_MDF_CCP_Mass_Owner_Update.getobjectTransactions';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent'

//custom labels
import programLabel from '@salesforce/label/c.Core_MDF_Program';
import accountLabel from '@salesforce/label/c.Core_MDF_Channel_Partner';
import nodeaccountLabel from '@salesforce/label/c.Core_MDF_Account_Node';
import selectProgram from '@salesforce/label/c.Core_MDF_LWC_SelectProgram_Label';
import selectAccount from '@salesforce/label/c.Core_MDF_LWC_SelectAccount_Label';
import getDataLabel from '@salesforce/label/c.Core_MDF_GetData';
const objectColumns=[{ label: 'ObjectId', fieldName: 'objectId' },
                       { label: 'Name', fieldName: 'name' },
                       { label: 'Program', fieldName: 'program' },
                       { label: 'AccountName', fieldName: 'accName' }];

export default class Core_MDF_Mass_Owner_Update extends LightningElement {
    accountNotLoaded=true;
    objectNotLoaded=true;
    nodeAccountNotLoaded=true;
    @track filterValChanged = false;
    @track accountValueSelected='';
    @track nodeAccountValueSelected='';
    @track programValueSelected='';
    @track objectValueSelected='';
    @track allOptionsNotSelected = true;
    @track showUserInput=false;
    isDisableButton  = true;
    isRecoveryDisabled = true;
    getDataLabel = getDataLabel;
    programOptions=[];
    accountOptions=[];
    nodeAccountOptions=[];
    objectOptions=[];
    programOpt = [];
    //objectTransactions=[];
    programLabel = programLabel;
    accountLabel = accountLabel;
    selectProgram = selectProgram;
    selectAccount = selectAccount;
    nodeaccountLabel=nodeaccountLabel;
    programSelected='';
    accountSelected='';
    objectSelected='';
    nodeAccountSelected='';
    @track accountName='';
    @track  objectData=[
            {
                Id:'1',
                objectId:'1xxxxxxxxx',
                name:'Campaign 1',
                program:'Intel Partner Alliance',
                accName:this.nodeAccountValueSelected
            }
        ];
    @track nodeAccountName='';
    @track LoadingText = false;
    @track messageFlag = false;
    @track LoadingTextNew = false;
    @track messageFlagNew = false;
   @api item={data:null,errors:null};
    connectedCallback() { 
        this.getPrograms();
    }
    objectColumns=objectColumns;
    getData(program,account,nodeaccount,object){
    //getObjectTransactions({program:this.programValueSelected,account:this.accountValueSelected,nodeaccount:this.nodeAccountValueSelected,object:this.objectValueSelected})
     //{
    //.then((data)=>{
        /*for(let i=0;i<data.length;i++)
        {
            this.objectTransactions=[...this.objectTransactions ,{value:data[i].objectId,label:data[i].name}];
        }*/
        this.showUserInput=true;

    //}
        
    }
   
  getPrograms() {
        getProgPicklistValues() 
        .then((data) => {
            for(let i=0; i<data.length; i++)  {
                this.programOptions = [...this.programOptions ,{value: data[i].progApiName , label: data[i].progname} ];                              
            } 
            if(data[0].isExternal && data.length == 1){
                let programOpt = this.programOptions.find((sam,index) => index==0);
                if(programOpt != undefined ){
                    this.isExternalUser = true;
                    this.programSelected = programOpt.value;  
                    this.programValueSelected = programOpt.label;  
                    this.getObjects(this.programValueSelected);
                }
                console.log('Print-> ',programOpt);
            }
         })
            .catch(error => {
                this.error = error; 
            }); 
    }
    getAccounts(){
        getAccountPicklistValues() 
        .then((data) => {
            this.accountNotLoaded=false;
            for(let i=0; i<data.length; i++)  {
                if(!this.accountOptions.find(opt=> opt.value==data[i].accountId)){
                    this.accountOptions = [...this.accountOptions ,{value: data[i].accountId , label: data[i].accountName} ];                                   
            
                }  
            }
            if(data[0].isExternal && data.length == 1){
                let accountOpt = this.accountOptions.find((sam,index) => index==0);
                if(accountOpt != undefined ){
                    this.isExternalUser = true;
                    this.accountSelected = accountOpt.value;  
                    this.accountValueSelected = accountOpt.label;
                    this.getNodeAccounts(this.programValueSelected,this.accountValueSelected);
                }

            }  
          
         })
            .catch(error => {
                this.error = error;
            }); 
    }
    getNodeAccounts(program,account){
        getNodeAccountPicklistValues({program:this.programValueSelected,account:this.accountValueSelected}) 
        .then((data) => {
             this.nodeAccountNotLoaded=false;
             for(let i=0; i<data.length; i++)  {
                if(!this.nodeAccountOptions.find(opt=> opt.value==data[i].nodeAccountId)){
                    this.nodeAccountOptions = [...this.nodeAccountOptions ,{value: data[i].nodeAccountId , label: data[i].nodeAccountName} ];                                   
            
                }
                
            }
            if(data != undefined && data[0].isExternal && data.length == 1){
                let nodeaccountOpt = this.nodeAccountOptions.find((sam,index) => index==0);
                if(nodeaccountOpt != undefined ){
                    this.isExternalUser = true;
                    this.nodeAccountSelected = nodeaccountOpt.value;  
                    this.nodeAccountValueSelected = nodeaccountOpt.label;  
                }
                }  
          
         })
            .catch(error => {
                this.error = error;
            }); 
    }
    getObjects(prog){
        getObjectPicklistValues({program:prog}) 
        .then((data) => {
            this.objectNotLoaded=false;
            let objectOpt=[];
            console.log('object data',data);
            for (const [key, value] of Object.entries(data)) {
                        objectOpt.push({ label: value, value: key });
                    }
                this.objectOptions=objectOpt;
                this.getAccounts();
         })
            .catch(error => {
                this.error = error;
            }); 
    }

    handleProgramFilterChange(event){
        this.filterValChanged = true;
        this.programValueSelected = this.programOptions.find(opt=> opt.value==event.detail.value).label;
        this.getObjects(this.programValueSelected);
    }
    handleAccountFilterChange(event){
        let accValueSelected = this.accountOptions.find(opt=> opt.value==event.detail.value).value;
        if(accValueSelected != undefined && accValueSelected != null){
            this.accountValueSelected = accValueSelected;
        }
        this.getNodeAccounts(this.programValueSelected,this.accountValueSelected);
    }
    handleNodeAccountFilterChange(event){
        this.allOptionsNotSelected =false;
        let nodeAccValueSelected = this.nodeAccountOptions.find(opt=> opt.value==event.detail.value).value;
        if(nodeAccValueSelected != undefined && nodeAccValueSelected != null){
            this.nodeAccountValueSelected = nodeAccValueSelected;
        }

    }
    handleobjectFilterChange(event){
        let objectValueSelected = this.objectOptions.find(opt=> opt.value==event.detail.value).value;
        if(objectValueSelected != undefined && objectValueSelected != null){
            this.objectValueSelected = objectValueSelected;
        }

    }
}