import { LightningElement, api, track } from 'lwc';
import Core_MDF_New_Contract_Section from "@salesforce/label/c.Core_MDF_New_Contract_Section";
import Core_MDF_Add_New_Contract_Section from "@salesforce/label/c.Core_MDF_Add_New_Contract_Section";

export default class Core_MDF_CampaignContractLineItems extends LightningElement {
    @api contractLineItemsList = [];
    @api disableContractLineItems = false;
    @api parentId = '';
    showAddContractButton = true;
    newContractSectionLabel = Core_MDF_New_Contract_Section;
    addNewContractSectionLabel = Core_MDF_Add_New_Contract_Section;

    connectedCallback() {
        if(this.disableContractLineItems) {
            this.showAddContractButton = false;
        }
    }
    handleContractLineItemChange(event) {
        const index = event.target.dataset.index;
        const value = event.target.value ? event.target.value.trim() : event.target.value;

        // Ensure we're updating a NEW array (not mutating the original)
        let updatedList = [...this.contractLineItemsList];

        // update record and mark the changed record as updated
        updatedList[index] = {
            ...updatedList[index],
            value: value,
            isUpdated: true
        };

        this.dispatchEvent(new CustomEvent('updatecontractlineitems', {
            detail: updatedList
        }));
    }

    handleAddContractLineItem() {
        // New records will have type = 'new' and for old records type = 'new' so we can handle them in Apex
        const newItem = {
            value: '',
            type: 'new',
            tempKey: 'temp-' + Date.now(), //key to render UI
            parentId: this.parentId
        }
        let updatedList = [...this.contractLineItemsList];
        updatedList.push(newItem);
        
        this.dispatchEvent(new CustomEvent('updatecontractlineitems', { detail: updatedList }));
    }
}