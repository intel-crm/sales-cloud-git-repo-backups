import { LightningElement, track, wire } from 'lwc';
import fetchAccounts from '@salesforce/apex/Core_MDF_TargetSettingController.getLineItemRecords';
import ACCOUNT_OBJECT from '@salesforce/schema/Core_MDF_Target_Setting_Line_Item__c';
import TYPE_FIELD from '@salesforce/schema/Core_MDF_Target_Setting_Line_Item__c.Core_MDF_Priority_nm__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
 
const columns = [
    { label: 'Spending Target Line Item Name', fieldName: 'Name', type: 'text'},
    { label: 'Account', fieldName: 'Core_MDF_Account__c', type: 'lookup'},
    { label: 'Priority', fieldName: 'Core_MDF_Priority_nm__c', type: 'picklistColumn', editable: true,
        typeAttributes: {
            options: { fieldName : 'pickListOptions' },
            value: { fieldName : 'Core_MDF_Priority_nm__c'},
            context: { fieldName: 'Id' },
            placeholder: "Choose Priority"
        }    
    },
    { label: 'Bucket', fieldName: 'Core_MDF_Bucket_nm__c', type: 'picklist', editable: true },
    { label: 'Country', fieldName: 'Core_MDF_Country_nm__c', type: 'picklist', editable: true },
    { label: 'Region', fieldName: 'Core_MDF_Region_nm__c', type: 'picklist'},
    { label: 'Amount', fieldName: 'Core_MDF_Amount__c', type: 'currency', editable: true },
    { label: 'Campaign Name', fieldName: 'Core_MDF_Campaign_Name__c', type: 'text', editable: true },
];
 
export default class CustomDatatableDemo extends LightningElement {
    columns = columns;
    showSpinner = false;
    @track data = [];
    @track accountData;
    @track draftValues = [];
    lastSavedData = [];
    @track pickListOptions;
 
    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;
 
    //fetch picklist options
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: TYPE_FIELD
    })
 
    wirePickList({ error, data }) {
        if (data) {
            this.pickListOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }
 
    //here I pass picklist option so that this wire method call after above method
    @wire(fetchAccounts, { pickList: '$pickListOptions' })
    accountData(result) {
        this.accountData = result;
        if (result.data) {
            this.data = JSON.parse(JSON.stringify(result.data));
 
            this.data.forEach(ele => {
                ele.pickListOptions = this.pickListOptions;
            })
 
            this.lastSavedData = JSON.parse(JSON.stringify(this.data));
 
        } else if (result.error) {
            this.data = undefined;
        }
    };
 
    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
 
        //write changes back to original data
        this.data = [...copyData];
    }
 
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
 
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }
 
    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        //this.updateDraftValues(event.detail.draftValues[0]);
        let draftValues = event.detail.draftValues;
        draftValues.forEach(ele=>{
            this.updateDraftValues(ele);
        })
    }
 
    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;
 
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
 
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.draftValues = [];
            return this.refresh();
        }).catch(error => {
            console.log(error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.draftValues = [];
            this.showSpinner = false;
        });
    }
 
    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }
 
    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
 
    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.accountData);
    }
}