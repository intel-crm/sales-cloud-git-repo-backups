import { LightningElement, track, api } from 'lwc';
import getLicenseRecords from '@salesforce/apex/sales_ContractMergeUtility.getLicenseRecords';
import getFilteredRecords from '@salesforce/apex/sales_ContractMergeUtility.getFilteredRecords';
import checkMerge from '@salesforce/apex/sales_ContractMergeUtility.checkMerge';

const licenseColumns = [
    { 
     label: 'License Name',
     fieldName :'Name',
     type: 'text' 
    },
    { 
        label: 'Contract Number',
        fieldName :'Sales_License_Contract_Txt__c',
        type: 'text' 
       },
       {
        label: 'Product Name',
        fieldName: 'Sales_License_Product_Name_Txt__c',
        type: 'text'

       },
       {
        label: 'Available Quantity',
        fieldName:'Sales_License_Avbl_Qty_Nbr__c'
       },
       {
        label: 'Tool License Type',
        fieldName:'Sales_Tool_License_Type__c'
       }
];

export default class Sales_ContractMergeComp extends LightningElement {
    @track sourceContract;
    @track targetContract; 
    @track licenseColumns=licenseColumns;
    @track showLicenses=false;
    @track licenseList=[];
    @track tempLicenseList=[];
    @track licensesToMerge=[];
    @track showMergeButton=false;
    @track disableMergeButton=false;

    connectedCallback(){
        console.log('Successfully executed');
    }

    selectRows(event){
      const selectedRows=event.detail.selectedRows;  
      for(let i=0;i<selectedRows.length;i++) {
        if(!this.licensesToMerge.includes(selectedRows[i].Name)){
          this.licensesToMerge.push(selectedRows[i].Name); 
          console.log('Added'+selectedRows[i].Name);
        }
        }

      }   

    searchLicenses(event) {
      let licenseName=event.target.value;
      if(licenseName.length!=0) {
        getFilteredRecords({licName:licenseName, contractId:this.sourceContract})
        .then((result) => {
          if(result.length!=0){
            this.licenseList=result;
          }
          else {
            this.licenseList=this.tempLicenseList;
            console.log('result is blank'+result);
          }     
         })  
      }
      else{
        this.licenseList=this.tempLicenseList;
      }
    }

    handleSource(event) {
      this.sourceContract=event.target.value;
      getLicenseRecords({contractName:this.sourceContract})
            .then((result) => {
              console.log('Data received'+result);
              this.licenseList=result;
              this.tempLicenseList=this.licenseList;     
             }) 
        
    }

    handleTarget(event) {
      this.targetContract=event.target.value;
             this.showLicenses=true;
             this.showMergeButton=true;

    }
    performMergeOper(){
      this.disableMergeButton=true;
      if(this.licensesToMerge.length!=0){
        for(let j=0;j<this.licensesToMerge.length;j++)
        {
          console.log('License '+j+' : '+this.licensesToMerge[j]);
        }
        
        console.log('Target Contract:'+this.targetContract);
        checkMerge({licIds:this.licensesToMerge,cId:this.targetContract})
        .then((result)=>{
          console.log(result);
        }  
        ).catch(e => {
            console.log(e);
        });

      }
    }
    
}