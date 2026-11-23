import { LightningElement,api, wire, track } from 'lwc';
import getHost  from '@salesforce/apex/Sales_UpdateHostDetailsOnLicense.getHost';
import getRecords  from '@salesforce/apex/Sales_UpdateHostDetailsOnLicense.getRecords';
import updateRecords  from '@salesforce/apex/Sales_UpdateHostDetailsOnLicense.updateRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const columnnames = [
    { label: "License Name", fieldName :"licenseaname",type: "text" },
    { label: "Primary Computer ID",fieldName:"hostId", type: "text" },
];
const columnnames1 = [
    { label: "License Name", fieldName :"licenseaname",type: "text" },
    { label: "Error Reason",fieldName:"errmsg", type: "text" },
];
export default class Sales_UpdateHostOnLicenses extends LightningElement {
    @track dynamiClassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track dynamiClassnamenew= 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track hostName='';
    @track newHostList=[];
    @track hostList=[];
    @track licenseList=[];
    @track updatedlicenseList=[];
    @track recId;
    @track recIdNew;
    @track data=[];
    @track data1=[];
    @track dataTable1=[];
    @track selectedIds = [];
    @track selectedIdsNew = [];
    @track valueselected;
    @track valueselectedNew;
    @track dataTable=[];
    @track licenseNameSelected='';
    @track columnnames=columnnames;
    @track columnnames1=columnnames1;
    @track LoadingText = false;
    @track LoadingTextNew=false;
    @track messageFlag = false;
    @track messageFlagNew = false;
    @track hostSelected= [];
    @track hostSelectedNew= [];
    @track showtable=false;
    @track showModel=false;
    searchHost(event) {
        this.hostName=event.target.value;
        this.LoadingText = true;
         getHost({hostName:this.hostName})
        .then(result => {
          this.hostList=result;
          console.log(this.hostName);
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
    setSelectedRecord(event) {
        this.recId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        console.log(this.recId);
        console.log(selectName);
        this.valueselected=selectName;
        let newsObject = { 'recId' : this.recId ,'recName' : selectName };
        this.selectedIds.push(this.recId);
        this.hostSelected.push(newsObject);
        this.dynamiClassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        
    }
    searchHostNew(event) {
        this.hostName=event.target.value;
        this.LoadingTextNew = true;
        getHost({hostName:this.hostName})
        .then(result => {
          this.newHostList=result;
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
setSelectedRecordNew(event) {
    this.recIdNew = event.currentTarget.dataset.id;
    var selectNameNew = event.currentTarget.dataset.name;
    console.log(this.recId);
    console.log(selectNameNew);
    this.valueselectedNew=selectNameNew;
    let newsObjectNew = { 'recId' : this.recIdNew ,'recName' : selectNameNew};
    this.selectedIdsNew.push(this.recIdNew);
    this.hostSelectedNew.push(newsObjectNew);
    this.dynamiClassnamenew =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    
}
    rowSelection(evt){
    }
    getRecords(){
        this.showtable=true;
    getRecords({hostId:this.recId})  .then(result => {

        this.licenseList=result;
        let dataRec=[];
        this.dataTable=[];
        let tempRecords = JSON.parse(JSON.stringify(this.licenseList));
                        console.log("Temp Records" + JSON.stringify(tempRecords));

        if (this.licenseList != undefined){
            for(let i = 0; i < this.licenseList.length; i++){
                 dataRec = {
                   
                    licenseaname: this.licenseList[i].Name,
                    hostId : this.licenseList[i].Sales_License_Host_Node_Txt__c                  
                }
                this.dataTable.push(dataRec);
            }
            this.data=JSON.parse(JSON.stringify(this.dataTable));

            console.log("dataTable" + JSON.stringify(this.dataTable));
        }

      });
    }
    getUpdateRecords(){
        
        console.log('update ownership');
        if(this.showTable!=false){

        let tableSelectedData = [];
        this.dataTable1=[];
        tableSelectedData = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('tableSelecteddata'+JSON.stringify(tableSelectedData));

        if(tableSelectedData.length==0){
            const evt = new ShowToastEvent({
                variant:'error',
                title:'',
                message: 'Please select atleast one Object to Update'
            });
            this.dispatchEvent(evt);
            this.error=true;
        }
         if(tableSelectedData.length!=0){
             this.error=false;
             //filter based on selection
             this.licenseNameSelected='';
             tableSelectedData.forEach((item) => {
                 console.log(item.objectName+'object');
               this.licenseNameSelected=this.licenseNameSelected+item.licenseaname+',';
                });
               console.log('selected data'+this.licenseNameSelected);
                }
               console.log('old owner '+this.recId+'new owner'+this.recIdNew);

               this.licenseNameSelected=this.licenseNameSelected.slice(0,-1);
               console.log('sliced data'+this.licenseNameSelected);
               
                  updateRecords({oldHost:this.recId,newHost:this.recIdNew,licenseSelected:this.licenseNameSelected})
                   .then(result => {
                    //this.check=true;
                    this.updatedlicenseList=result;
                    console.log('updatedlicenseList data'+this.updatedlicenseList);
                    if (this.updatedlicenseList != undefined && this.updatedlicenseList !=null && this.updatedlicenseList !=''){
                    this.showModel=true;

                        for(let i = 0; i < this.updatedlicenseList.length; i++){
                            let dataRec = {
                               
                                licenseaname: this.updatedlicenseList[i].lname,
                                errmsg : this.updatedlicenseList[i].errmsg                  
                            }
                            this.dataTable1.push(dataRec);
                        }
                        this.data1=JSON.parse(JSON.stringify(this.dataTable1));
                        console.log("dataTable" + JSON.stringify(this.dataTable1));
                    }
                    else {
                        const evt = new ShowToastEvent({
                            variant:'success',
                            title:'',
                            message: 'License Updation  is Succesful.'
                        });
                        this.dispatchEvent(evt);
                    }

               });
              
              
            }
              else{ 
                const evt = new ShowToastEvent({
                variant:'error',
                title:'',
                message: 'Please select license to update Host information'
            });
            this.dispatchEvent(evt);
            }
            }
}