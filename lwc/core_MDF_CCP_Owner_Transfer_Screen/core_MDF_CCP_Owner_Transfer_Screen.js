import { track,wire,LightningElement } from 'lwc';
import getUser  from '@salesforce/apex/Core_MDF_CCP_OwnerTransfer.getUser';
import getRecords from '@salesforce/apex/Core_MDF_CCP_OwnerTransfer.getRecords';
import fetchObjectData from '@salesforce/apex/Core_MDF_CCP_OwnerTransfer.fetchObjectData';
import fetchObjectDataMeta from '@salesforce/apex/Core_MDF_CCP_OwnerTransfer.fetchObjectDataMeta';
import updateRecords from '@salesforce/apex/Core_MDF_CCP_OwnerTransfer.updateRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

const columnnames = [
    { label: "Object Name", fieldName :"objectaname",type: "text" },
    { label: "No of Records",fieldName:"countrec", type: "text" },
];

export default class Core_MDF_CCP_Owner_Transfer_Screen extends LightningElement {
    @track userName='';
    @track ownerName=[];
    @track ownerNewUser=[];
    @track selectedIds = [];
    @track selectedIdsNew=[];
    @track dynamiClassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track dynamiClassnamenew = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track ownerSelected= [];
    @track ownerSelectedNew=[];
    @track valueselected;
    @track valueselectedNew;
    @track LoadingText = false;
    @track messageFlag = false;
    @track LoadingTextNew = false;
    @track messageFlagNew = false;
    @track datavalue =[];
    @track apiName=[];
    @track SobjectName=[];
    @track recordsvalue={};
    @track recId;
    @track recIdNew;
    @track columnname=columnnames;
    @track dataTable;
    @track objectNameSelected='';
    @track valueObject='';
    @track showTable=false;
    @track check=false;
    @track error=false;
 
   
    @wire( fetchObjectData )  
    sobjectvalue( value ) {
        const { data, error } = value;
        if (data) {
            console.log(data+'data');
            this.datavalue = data;
            this.error = undefined;
            this.datavalue.forEach(element => {
                this.apiName.push(element.value);
                this.SobjectName.push(element.label);
            })
        } else if ( error ) {
            console.log('inside error');
            this.error = error;
            this.datavalue = undefined;
        }
        console.log('object name'+JSON.stringify(this.datavalue));
       
        console.log('api'+this.apiName);
        console.log('api string'+this.apiName.toString()) ;
        console.log('sobject'+this.SobjectName);   
    }  
  

    searchUser(event) {
        this.userName=event.target.value;
        this.LoadingText = true;
        getUser({userName:this.userName})
        .then(result => {
          this.ownerName=result;
          console.log(this.userName);
          this.LoadingText = false;
          this.dynamiClassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
          console.log('length'+result.length);
          if( result.length == 0) 
          {
            this.messageFlag = true;
            console.log('no record');
           }
           else 
           {
            this.messageFlag = false;
            console.log('record present');
           }
    })
    .catch(error => {
        console.log('-------error-------------'+error);
        console.log(error);
    });
        
    }
    searchNewUser(event) {
        this.userName=event.target.value;
        this.LoadingTextNew = true;
        getUser({userName:this.userName})
        .then(result => {
          this.ownerNewUser=result;
          this.LoadingTextNew = false;
          this.dynamiClassnamenew=  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
          console.log('length'+result.length);
          if( result.length == 0) 
          {
            this.messageFlagNew = true;
            console.log('no record');
           }
           else 
           {
            this.messageFlagNew = false;
            console.log('record present');
           }
    })
    .catch(error => {
        console.log('-------error-------------'+error);
        console.log(error);
    });
        
    }

    setSelectedRecord(event) {
        this.recId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        console.log(this.recId);
        console.log(selectName);
        this.valueselected=selectName;
        let newsObject = { 'recId' : this.recId ,'recName' : selectName };
        this.selectedIds.push(this.recId);
        this.ownerSelected.push(newsObject);
        this.dynamiClassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        
    }
    setSelectedRecordNew(event) {
        
        this.recIdNew = event.currentTarget.dataset.id;
        var selectNameNew = event.currentTarget.dataset.name;
        console.log(this.recIdNew+'new recid');
        console.log(selectNameNew);
        this.valueselectedNew=selectNameNew;
        let newsObjectNew = { 'recId' : this.recIdNew ,'recName' : selectNameNew};
        this.selectedIdsNew.push(this.recIdNew);
        this.ownerSelectedNew.push(newsObjectNew);
        this.dynamiClassnamenew =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        
    }

    getUpdateRecords(){
        this.error=false;
        console.log('update ownership');
        console.log('new recordid'+this.recIdNew);
        if(this.recIdNew==null || this.recIdNew==undefined){
            const evt = new ShowToastEvent({
                variant:'error',
                title:'',
                message: 'Please select new user'
            });
            this.dispatchEvent(evt);
            this.error=true;
            }

     if(this.recId==this.recIdNew){
            const evt = new ShowToastEvent({
                variant:'error',
                title:'',
                message: 'Existing user and New user cannot be same'
            });
            this.dispatchEvent(evt);
            this.error=true;
        }
        console.log(this.showTable+'this.showTable**');

        if(this.showTable!=false){

        let tableSelectedData = [];
        tableSelectedData = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('tableSelecteddata'+JSON.stringify(tableSelectedData));
        console.log('table length'+tableSelectedData.length);

        if(tableSelectedData.length==0){
            const evt = new ShowToastEvent({
                variant:'error',
                title:'',
                message: 'Please select atleast one Object to Update'
            });
            this.dispatchEvent(evt);
            this.error=true;
        }

        if(tableSelectedData.length>0 && this.error!=true){
             //filter based on selection
             this.objectNameSelected='';
             tableSelectedData.forEach((item) => {
                 console.log(item.objectName+'object');
                 if(item.countrec!=0){
                  this.objectNameSelected=this.objectNameSelected+item.objectaname+',';
                 }
                 else{
                    const evt = new ShowToastEvent({
                    variant:'error',
                    title:'',
                    message: 'You cannot update object ownership with no record'
                });
                this.dispatchEvent(evt);
                this.error=true;

                 }
                });
               console.log('selected data'+this.objectNameSelected);
                
               console.log('old owner '+this.recId+'new owner'+this.recIdNew);

               this.objectNameSelected=this.objectNameSelected.slice(0,-1);
               console.log('sliced data'+this.objectNameSelected);
              
               fetchObjectDataMeta({objectName:this.objectNameSelected})
               .then(result =>{
                let selectedobject = []; 
                selectedobject=result;
              
                 console.log('selected obj**'+JSON.stringify(selectedobject));
                 this.valueObject='';
                 selectedobject.forEach((item) => {
                    this.valueObject=this.valueObject+item.value+',';
                  });
                  this.valueObject=this.valueObject.slice(0,-1);
                  console.log('valueObject'+this.valueObject);

                  if(this.error!=true){
                  updateRecords({oldOwner:this.recId,newOwner:this.recIdNew,objectSelected:this.valueObject})
                   .then(result => {
                    this.check=true;
                     console.log(result+'result');
                    
                     const evt = new ShowToastEvent({
                        variant:'success',
                        title:'',
                        message: 'Ownership Update is initiated.'
                    });
                    this.dispatchEvent(evt);
                    
                   })
                }
               });
               
              
            }
        
        }
    
   }



    rowSelection(evt){
        console.log('row selection'+evt);
    }

    getRecords(){
        console.log('recid'+this.recId);
        if(this.recId==null || this.recId==undefined){
            const evt = new ShowToastEvent({
                variant:'error',
                title:'',
                message: 'Please select existing user'
            });
            this.dispatchEvent(evt);
            this.error=true;
            
        }
        this.showTable=true;
        console.log('getrecords');

       getRecords({ownerId:this.recId,objectName:(this.apiName.toString()),objectLabel:(this.SobjectName.toString())})
        .then(result => {
       
            let dataRecord =[]; 
            this.recordsvalue = new Map(Object.entries(result));
            let it = this.recordsvalue.keys(); 
            
            let rowIndexes = it.next();
            console.log('rowIndexes',rowIndexes);
            
            while (!rowIndexes.done) {
                let newLst = {};
            
                if(this.recordsvalue.has(rowIndexes.value)){
                    newLst.objectaname = rowIndexes.value;
                    newLst.countrec = this.recordsvalue.get(rowIndexes.value);
                    dataRecord.push(newLst);
                }
                rowIndexes = it.next();
            }
            this.dataTable = JSON.parse(JSON.stringify(dataRecord));
        });
    }
   
}