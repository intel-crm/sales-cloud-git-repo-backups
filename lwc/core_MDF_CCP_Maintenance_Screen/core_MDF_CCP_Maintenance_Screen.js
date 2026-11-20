import { LightningElement,wire,track,api } from 'lwc';
import fetchSampleRecs from '@salesforce/apex/Core_MDF_CCP_MultiLookup.fetchSampleRecs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getResults from '@salesforce/apex/Core_MDF_CCP_MultiLookup.getResults';
import getResult from '@salesforce/apex/Core_MDF_CCP_MultiLookup.getResult';
import Core_MDF_CCP_Maintenance_Max_Record_Count from '@salesforce/label/c.Core_MDF_CCP_Maintenance_Max_Record_Count';
export default class Core_MDF_CCP_Maintenance_Screen extends LightningElement {
     
    error;
    optionList;
    optionList1;
    options2;
    result;
    result1;
    displayFields =false;
    objectDropdownvalues;

    @track noRecord=false;
    @track errorRecord='';
    @track errorNoRecord='';
    @track filterResult;
    @track final;
    @track showTable=false;
    _selected = [];
    completeDropdownFieldvalues;
    maintenanceMaxRecordCount = Core_MDF_CCP_Maintenance_Max_Record_Count;

    @wire( fetchSampleRecs )  
    wiredRecs( value ) {
        const { data, error } = value;
        let records = [];
        this.objectDropdownvalues = [];
        if (data && data.length >0 ) {
            console.log('Full data',data); 
            let fullData = data;
            this.completeDropdownFieldvalues = data;
            fullData.map(data => {
                   let index = this.objectDropdownvalues.findIndex(element => element.label === data.Core_MDF_Object_Label__c )
                   console.log('Index',index);
                    if(index == -1)
                     {
                                console.log('Index1');
                                let dropdwonObj = {};
                                dropdwonObj.label = data.Core_MDF_Object_Label__c;
                                dropdwonObj.value = data.Core_MDF_Object_API_Name__c;
                                this.objectDropdownvalues.push(dropdwonObj);
                     }
                    // this.completeDropdownFieldvalues.push({})
                
            })       
            console.log('FirstPic1',this.objectDropdownvalues);

        } else if ( error ) {

            this.error = error;
            this.records = undefined;

        }
        
    }
    showTableEvent(event){
      this.showTable=event.detail;
      console.log('parent flag'+this.showTable);
    }

    filterEvent(event){
        this.errorRecord='';
        this.noRecord=true;
        console.log('line53');
        this.filterResult=event.detail;
        console.log('line 54'+this.filterResult);
         //added new
       getResult({ ObjectName: this.objectName,filterCondition:this.filterResult})
       .then(result => {
         this.searchRecords= result;
         console.log('result 88 '+JSON.stringify(this.searchRecords));
         if(result.length==0)
         {
             this.noRecord=true;
            this.errorRecord='No records found for the filter applied';
                
         }
         if(result.length > this.maintenanceMaxRecordCount){
            this.noRecord=true;
            this.selectedIds.length=0;
            this.errorRecord='Large number of records found. Please provide more specific filter.';
            this.showTable = false;
         }
         else{
         this.LoadingText = false;
         this.selectedIds.length=0;
         this.searchRecords.forEach(element => {
            this.selectedIds.push(element.recId);
            console.log('recId'+element.recId);
            console.log('after push'+this.selectedIds);
               
           }) 
        
         //
         this.dynamiClassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        }
     })
     .catch(error => {
         console.log('-------error-------------'+error);
         console.log(error);
         this.noRecord=true;
         this.errorRecord='Please check the filter conditions Please use appropriate brackets example:1 AND (2 OR 3)'
         console.log('this.errorRecord'+this.errorRecord);
     });
    
    console.log('selectedIds** 77'+this.selectedIds);
    }
    handleChange(event)
    {   
        this.final =[];
        this._selected.length=0;
        console.log('Finalvalue',this.final);
        this.result = event.target.value;
        console.log('First',this.result);
        this.objectName=this.result;
        this.showFilter = this.count % 2 == 0 ? false : true;
        this.count = this.count+1;
        this.getFieldvaluebasedonObject(this.result);
        console.log('objectname-',this.objectName);
        this.selectedRecords.length=0;
        this.selectedIds.length=0;
        this.showTable=false;
        // console.log('Inserted ids are line 93');
        // console.log(this.selectedIds);
       // alert(this.selectedIds + ' are the  selected ids');
        const selectedEvent = new CustomEvent('userselected', { 
            detail: this.selectedRecords
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

 }
 getRecords(event){
     
     if(this.setFlag!=true || this.valueIncident==undefined || this.valueIncident==''){
        const evt = new ShowToastEvent({
            variant:'error',
            title: '',
            message:'Incident Number should be atleast 11 digits or more'
            });
             this.dispatchEvent(evt)
    
     }
     else if(this.objectName==''|| this.objectName==undefined){
        const evt = new ShowToastEvent({
            variant:'error',
            title: '',
            message:'Please select the object '
            });
             this.dispatchEvent(evt)
     
     }
     else if(this.selectedFields==''|| this.selectedFields==undefined){
        const evt = new ShowToastEvent({
            variant:'error',
            title: '',
            message:'Please select atleast one field'
            });
             this.dispatchEvent(evt)
     }
     else{
         
          this.showTable = true;
     }
    
 }

 getFieldvaluebasedonObject(objName){
    let options = [];
    this.completeDropdownFieldvalues.map(val => {
    if(val.Core_MDF_Object_API_Name__c  == objName) {
    options.push({label: val.Core_MDF_Field_Label__c, value: val.Core_MDF_Field_API_Name__c});
    }
    })
    

    options.sort(function(a, b) {
        var labelA = a.label; 
        console.log('labelA',labelA);
        var labelB = b.label;
        console.log('labelB',labelB);
        if (labelA < labelB) {
          return -1;
        }
        if (labelA > labelB) {
          return 1;
        }
        return 0;
      });

      console.log('final1',options);
    this.final =options;

  }
  handleChange1(event)
    {
        console.log('Selected value',event.target.value);
    }
    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    handleChange2(e) {
        this._selected =e.target.value;
        this.selectedFields =this._selected;
        this.showTable=false;

    }

    @track showFilter=false;
    @track count = 1;
    @api objectName='';
    @track selectedFields = [];
    @track fieldName = '';
    @api filterField = ''; //used to provide filter field in where clause
    @api filterFieldValue= '';//used to provide filter field value in where clause
    @api useFilterCriteria = false; // used to toggle the where clause in soql query
    @api singleSelection = false; // used to toggle between single select and multi select
    @track disableInputField = false;
    @track setFlag=false;
    @api Label;
    @track incident;
    @track searchRecords = [];
    @track selectedIds = [];
    @track selectedRecords=[];
    @api selectedFromParent = [];
    @api required = false;
    @api iconName = 'standard:checkout'
    @api LoadingText = false;
    @track dynamiClassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;
    @track value;

    connectedCallback() {
        console.log('LookupComponentinserted')
        console.log(this.selectedFromParent);
        if(this.selectedFromParent != undefined){
            this.selectedRecords = [...this.selectedFromParent];
            if(this.singleSelection){
                this.disableInputField = true;
            }
        }
    }
    
    /*searchField(event) {
        this.showTable=false;
        var currentText = event.target.value;
        var selectRecId = [];
        for(let i = 0; i < this.selectedRecords.length; i++){
            selectRecId.push(this.selectedRecords[i].recId);
        }
        this.LoadingText = true;
        getResults({ ObjectName: this.objectName, fieldName: this.fieldName, value: currentText, selectedRecId : selectRecId, useFilterCriteria: this.useFilterCriteria, filterField: this.filterField, filterFieldValue:this.filterFieldValue,filterCondition:this.filterResult})
        .then(result => {
            this.searchRecords= result;
            this.LoadingText = false;

            //
            this.dynamiClassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            if(currentText.length > 0 && result.length == 0) {
                this.messageFlag = true;
            }
            else {
                this.messageFlag = false;
            }

            if(this.selectRecordId != null && this.selectRecordId.length > 0) {
                this.iconFlag = false;
                this.clearIconFlag = true;
            }
            else {
                this.iconFlag = true;
                this.clearIconFlag = false;
            }
        })
        .catch(error => {
            console.log('-------error-------------'+error);
            console.log(error);
        });

    }*/

 /*  setSelectedRecord(event) {

        var recId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        console.log(recId);
        //console.log(selectName);
        let newsObject = { 'recId' : recId ,'recName' : selectName };
        this.selectedIds.push(recId);
        this.selectedRecords.push(newsObject);
        console.log(this.selectedIds);
        console.log(this.selectedRecords);
        this.dynamiClassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        //let selRecords = this.selectedRecords
        this.template.querySelectorAll('lightning-input[data-id="userinput"]').forEach(element => {
            element.value = '';
            });
        console.log('event dispatch');
        //console.log(this.selectedIds);
        let ids = this.selectedIds.toString();
        let records1 = this.selectedRecords.toString();
     //   alert(this.selectedIds + ' are the  selected ids');
        const selectedEvent = new CustomEvent("userselected", { 
            detail: this.selectedRecords
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        if(this.singleSelection){
            this.disableInputField = true;
        }
    }*/

  /*  removeRecord (event){
        let selectRecId = [];
        let selectedIds1 = [];
        for(let i = 0; i < this.selectedRecords.length; i++){
            if(event.detail.name !== this.selectedRecords[i].recId){
                console.log('event'+event.detail.name);
                selectRecId.push(this.selectedRecords[i]);
                selectedIds1.push(this.selectedRecords[i].recId)
            }
        }
        this.selectedRecords = [...selectRecId];
        this.selectedIds = [...selectedIds1];
        let selRecords = this.selectedRecords;

        let ids = this.selectedIds.toString();
        if(this.singleSelection && selectRecId.length <=0){
            this.disableInputField = false;
        }
     //   alert(this.selectedIds + ' are the  selected ids');
        const selectedEvent = new CustomEvent('userselected', { 
            detail: this.selectedRecords
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.showTable=false;
    }*/

    storefield(event){
        console.log("incident is line 232");
        this.showTable=false;
        this.incident=event.target.value;
        this.valueIncident='';
        if(this.incident.length>=11)
        {
            
            this.valueIncident=this.incident;
            this.setFlag=true;
            console.log("value is "+this.valueIncident);
            console.log("incident is "+this.incident);
        }
    
        console.log("incident is line 238");
    }
}