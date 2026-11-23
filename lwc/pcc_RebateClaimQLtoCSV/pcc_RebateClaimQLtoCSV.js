import { LightningElement,track } from 'lwc';
import getWonQLs from '@salesforce/apex/PCC_RebateClaimController.getQuoteLineItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation'; 
import getFieldSetLabels from '@salesforce/apex/PCC_RebateClaimController.getFieldSetLabels';

export default class Pcc_RebateClaimQLtoCSV extends NavigationMixin(LightningElement) {
    @track data;
    @track copydata;
    @track copyCols;
    isLoading = false;
    isLevel1=true;
    isLevel2=false;
    checkboxhidden=false;
    selectedRows=[];
    @track columns=[
        { label: 'QL#', fieldName: 'Pricing_Quote_Line_Number__c', type: 'text'},
        { label: 'Product', fieldName: 'Product_Name', type: 'url', typeAttributes: { label: { fieldName: 'Product_Name' },tooltip:{fieldName :'Product_Name'} , target: '_blank'  } },
        { label: 'Approved Qty', fieldName: 'Pricing_Approved_Unit_Dup_Qty__c', type: 'number',cellAttributes: { alignment: 'center' } },
        { label: 'Claimed Qty', fieldName: 'claimedQuantity', type: 'number',cellAttributes: { alignment: 'center' } },
        { label: 'Remaining Qty', fieldName: 'remainingQuantity', type: 'number',cellAttributes: { alignment: 'center' } },
   ];

   connectedCallback(){
        this.getQLData();
   }


   getQLData(){
        this.isLoading = true;
        getWonQLs()
        .then(result => {
           if(result){
                const remainingQuantityMap = result.remainingQuantity;
                const claimedQuantityMap = result.claimedQuantity;
                this.data = result.qlList.map(item => {
                     return {
                          ...item,
                          Product_Name: item.Pricing_Product_Nm__r.Name,
                          Product_Id: '/'+item.Pricing_Product_Nm__r.Id,
                          Quote_Name: item.SBQQ__Quote__r.Name,
                          remainingQuantity: remainingQuantityMap[item.Id],
                          claimedQuantity:claimedQuantityMap[item.Id]
                     };
                });
                this.copydata = [...this.data];
           } 
           this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
        });
    }


    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

   handleProceed() {
        this.isLoading=true;
        if(this.selectedRows.length>0){
            this.checkboxhidden=true;
            this.data = this.selectedRows;
            this.isLevel1=false;
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
            this.isLevel2=true;
        } 
        else{
            this.showToast('error', 'Error', 'Please select atleast one record to proceed.');
        }
        this.isLoading=false;
    }

    handleBack(){
        this.isLoading=true;
        this.columns = this.copyCols;
        this.data = this.copydata;
        this.isLoading=false;
        this.isLevel1=true;
        this.isLevel2=false;  
        this.checkboxhidden=false;
    }   

    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
        const searchKeys = searchKey.split(',').map(key => key.trim());
        const columnToSearch = 'Pricing_Quote_Line_Number__c'; // specify the column to search

        this.data = this.copydata.filter(row => {
            return searchKeys.some(key => row[columnToSearch].toLowerCase().includes(key));
        });
    }
    
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
        this.dispatchEvent(new CustomEvent('backtocreate'));

        }
        catch(error){
            this.showToast('error', 'Error', 'An error occurred while downloading the CSV file.');
        } 
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
   
}