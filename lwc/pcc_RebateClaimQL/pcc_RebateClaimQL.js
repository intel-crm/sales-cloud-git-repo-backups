import { LightningElement,track,wire } from 'lwc';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApprovedQLs from '@salesforce/apex/PCC_RebateClaimQLController.getQuoteLineItems';
import processData from '@salesforce/apex/PCC_RebateClaimQLController.processData';
import { NavigationMixin } from 'lightning/navigation'; 
import getFieldSetLabels from '@salesforce/apex/PCC_RebateClaimController.getFieldSetLabels';

export default class Pcc_RebateClaimQL extends NavigationMixin(LightningElement) {
    @track data;
    @track draftValues = [];
    @track columns=[
        { label: 'QL#', fieldName: 'fieldId', type: 'url', typeAttributes: { label: { fieldName: 'Pricing_Quote_Line_Number__c' } ,tooltip:{fieldName :'Name'} , target: '_blank' }},
        { label: 'Quote#', fieldName: 'Quote_Id', type: 'url', typeAttributes: { label: { fieldName: 'Quote_Name' } ,tooltip:{fieldName :'Quote_Name'} , target: '_blank'  } } ,
        { label: 'Product', fieldName: 'Product_Id', type: 'url', typeAttributes: { label: { fieldName: 'Product_Name' },tooltip:{fieldName :'Product_Name'} , target: '_blank'  } },
        { label: 'Approved Start Date', fieldName: 'Pricing_Approved_Start_Date_Dup_Dt__c', type: 'text' },
        { label: 'Approved End Date', fieldName: 'Pricing_Approved_End_Date_Dup_Dt__c', type: 'text' },
        { label: 'OEM', fieldName: 'Pricing_OEM_Name_FI__c', type: 'text' },
        { label: 'Approved Qty', fieldName: 'Pricing_Approved_Unit_Dup_Qty__c', type: 'number' },
        { label: 'Claimed Qty', fieldName: 'claimedQuantity', type: 'number' },
        { label: 'Claimable Qty', fieldName: 'remainingQuantity', type: 'number' },
   ];
    @track error;
    @track isLoading=false;
    isError=false;
    selectedRows = [];
    isProceed=false;
    isSave=false;
    draftValues=[];
    @track copyCols=[];
    @track copydata;
    @wire(getApprovedQLs)
    getApprovedQLs({ error, data }) {
        this.isLoading=true;
        new Promise(
            (resolve,reject) => {
              setTimeout(()=> {
                if (data) {
                    let remainingQuantityMap = data.remainingQuantity;
                    let claimedQuantityMap = data.claimedQuantity;
                    this.data = data.qlList.map(item => {
                        return {
                            ...item,
                            fieldId: '/'+item.Id,
                            Product_Name: item.Pricing_Product_Nm__r.Name,
                            Product_Id: '/'+item.Pricing_Product_Nm__r.Id,
                            Quote_Name: item.SBQQ__Quote__r.Name,
                            Quote_Id: '/'+item.SBQQ__Quote__r.Id,
                            remainingQuantity: remainingQuantityMap[item.Id],
                            claimedQuantity:claimedQuantityMap[item.Id]
                        };
                    });
                    this.copydata = [...this.data];
                    /*this.copydata = data.qlList.map(item => {
                        return {
                            ...item,
                            fieldId: '/'+item.Id,
                            Product_Name: item.Pricing_Product_Nm__r.Name,
                            Product_Id: '/'+item.Pricing_Product_Nm__r.Id,
                            Quote_Name: item.SBQQ__Quote__r.Name,
                            Quote_Id: '/'+item.SBQQ__Quote__r.Id,
                            remainingQuantity: remainingQuantityMap[item.Id]
                        };
                    });*/
                } else if (error) {
                    console.error(error);
                }
                  resolve();
              }, 0);
          }).then(
              () => this.isLoading=false
          );
        
        
    }


    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handleProceed() {
        this.isLoading=true;
        this.data = this.selectedRows;
        this.isProceed=true;
        this.copyCols = [...this.columns];
        this.columns = [...this.columns,{ label: 'Claim Quantity', fieldName: 'claimQuantity', type: 'number', editable : 'true', cellAttributes: {
            class: 'slds-has-focus',
        }},{ label: 'Invoice Number', fieldName: 'invoiceNumber', type: 'text', editable : 'true', cellAttributes: {
            class: 'slds-has-focus',
        }},{ label: 'Consumption Countries', fieldName: 'consumcountries', type: 'text', editable : 'true', cellAttributes: {
            class: 'slds-has-focus', }
        },
        { label: 'Invoice Date', fieldName: 'invoiceDate', type: 'text', editable : 'true', cellAttributes: {
            class: 'slds-has-focus', }
        }];
        this.isSave=true;
        this.isLoading=false;
    }
    handleBack(){
        this.isLoading=true;
        new Promise(
            (resolve,reject) => {
              setTimeout(()=> {
                this.isSave=false;
                this.isProceed=false;
                this.columns = this.copyCols;
                this.data = this.copydata;
                this.isError=false;
                this.error=[]
                resolve();
              }, 0);
          }).then(
              () =>  this.isLoading=false
          );   
    }    

    errorMessage =[];

    handleSave(){
        let errorMessage=[];
        this.errorMessage=[];
        this.isError=false;
            const draftValues = this.template.querySelector('lightning-datatable').draftValues;
            console.log(draftValues);
            const updatedData = this.data.map(item => {
                const draftValue = draftValues.find(draft => draft.Id === item.Id);
                return draftValue ? { ...item, ...draftValue } : item;
            });
            let errorList1=[];
            let errorList2=[]
            updatedData.forEach(item => {
                const claimQuantity = item.claimQuantity;
                const remainingQuantity = item.remainingQuantity;
                if(claimQuantity==0 || claimQuantity==null){
                    this.isError = true;
                    errorList1.push(item.Name);
                    errorMessage.push({label:item.Id, value:item.Name,message:'Claim Quantity cannot be zero or null'});
                }
                if (claimQuantity > remainingQuantity) {
                    this.isError = true;
                    errorList2.push(item.Name);
                    errorMessage.push({label:item.Id, value:item.Name,message:'Claim Quantity cannot be greater than Remaining Quantity'});
                }
            });
           
            if(errorList1.length>0){
                this.errorMessage.push({'key':'Claim Quantity cannot be zero or null','value':errorList1});
            }
            if(errorList2.length>0){
                this.errorMessage.push({'key':'Claim Quantity cannot be greater than Remaining Quantity','value':errorList2})
            }
    
            
            let errors = {};
            errors.rows = {};
            errorMessage.forEach(id => {
                errors.rows[id.label] = { title: 'Error', messages: [id.message], fieldNames: ['claimQuantity'] };
            });
            this.error = errors;
            if (!this.isError) {
                let tempMap = {};
                let inputMap={}
                updatedData.forEach(item => {
                    tempMap={};
                    tempMap['quantity']=item.claimQuantity;
                    tempMap['consumcountries']=item.invoiceDate;
                    tempMap['invoiceNumber']=item.invoiceNumber;
                    inputMap[item.Id]=tempMap;
                });
               /* console.log('myMap before conversion:',draftValues );

                 const array = Object.entries(draftValues);
                 const mapObj=Object.fromEntries(array);
                  
                    console.log('Sending mapObj:', mapObj);*/
                processData({ inputMap: JSON.stringify(inputMap) })
                    .then(result => {
                        this.data = result;
                        this.filteredData = [...this.data];
                        this.draftValues = [];
                        this.showToast('Success', 'Claims Created successfully', 'success','sticky');
                        this[NavigationMixin.Navigate]({
                            type: 'standard__objectPage',
                            attributes: {
                                objectApiName: 'PCC_Rebate_Claim__c',
                                actionName: 'list'
                            },
                            state: {
                                // 'filterName' is a property on 'state'
                                // and identifies the target list view.
                                // It may also be an 18 character list view id.
                                // or by 18 char '00BT0000002TONQMA4'
                                filterName: 'All' 
                            }
                        });
                        
                    })
                    .catch(error => {
                        console.error(error);
                        this.showToast('Error', 'An error occurred while processing data', 'error','dismissible');
                    });
            }
            
            /*
            this.data = updatedData;
            this.filteredData = [...this.data];
            this.draftValues = [];
            this.showToast('Success', 'Records updated successfully', 'success');*/
        
    }

    showToast(variant, title, message,mode) {
        const event = new ShowToastEvent({
            mode:mode,
            variant: variant,
            title: title,
            message: message
        });
        this.dispatchEvent(event);
    }



    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
            this.data = this.copydata.filter(row => {
                return Object.values(row).some(value =>
                    String(value).toLowerCase().includes(searchKey)
                );
            });
        } else {
            this.data = [...this.copydata];
        }
    }

    @track updatedData=[];
    @track columnsLabel=[];
    @track columnsAPI=[];

    handleCSV() {
        getFieldSetLabels()
            .then(result => {
                this.columnsLabel = result['labels'];
                this.columnsAPI = ['Pricing_Quote_Line_Number__c','Product_Name','claimQuantity','Pricing_OEM_Name_FI__c','consumcountries','invoiceNumber','invoiceDate'];
                const draftValues = this.template.querySelector('lightning-datatable').draftValues;
            this.updatedData = this.data.map(item => {
                const draftValue = draftValues.find(draft => draft.Id === item.Id);
                return draftValue ? { ...item, ...draftValue } : item;
            });
            this.generateCSV();
            })
            .catch(error => {
                console.error(error);
        });
    }
    generateCSV(){
        try {
            let csvContent =  '\uFEFF';
            csvContent += this.columnsLabel.join(",")+ "\r\n";
            if(this.updatedData.length>0){
                this.updatedData.forEach(record => {
                    const row = this.columnsAPI.map(field =>{
                        let value = record[field];
                        if (value && value.includes(',')) {
                            value = `"${value}"`;
                        }
                        return value;
                    });
                    csvContent += row.join(",") + "\r\n";
                });
            }
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const reader = new FileReader();
            reader.readAsDataURL(blob);
             reader.onload = function(event) {
             const dataUrl = event.target.result;

            const link = document.createElement("a");
           link.setAttribute("href", dataUrl);
            link.setAttribute("download", "RebateClaimTemplate.csv");
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            
        };
        
        this.showToast('success', 'Template Downloaded', 'The Template file has been downloaded successfully.');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'PCC_Rebate_Claim__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All' 
            }
        });
        }
        catch(error){
            this.showToast('error', 'Error', 'An error occurred while downloading the CSV file.');
        } 
    }
}