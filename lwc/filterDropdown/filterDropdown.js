import { LightningElement, api, track } from 'lwc';
//Core_MDF_OutcomeBasedCmpgn_ParentComp
import getRecordTypeDetailsByValue from "@salesforce/apex/Core_MDF_OutcomeBasedCmpgn_ParentComp.getRecordTypeDetailsByValue";
export default class filterDropdown extends LightningElement {
    
    @track selectedValue = '';
    @track selectedLabel = '';
    
    // ──────────────────────────────────────
    // Dropdown Options
    // ──────────────────────────────────────
    get options() {
        return [
            { 
                label : '--None--',    
                value : ''           
            },
            { 
                label : 'Client',      
                value : 'Client'     
            },
            { 
                label : 'Data Center', 
                value : 'DataCenter' 
            },
            { 
                label : 'IPA',         
                value : 'IPA'        
            }
        ];
    }
    
    // ──────────────────────────────────────
    // Handle Selection Change
    // ──────────────────────────────────────
    handleSelectionChange(event) {
        try {
            this.selectedValue = event.detail.value;
            this.selectedLabel = this.getOptionLabel(
                this.selectedValue
            );
            
            console.log('[filterDropdown] Selected:', {
                value : this.selectedValue,
                label : this.selectedLabel
            });
            
        } catch(error) {
            console.error(
                '[filterDropdown] Error:', 
                error
            );
        }
    }
    
    // ──────────────────────────────────────
    // Handle Next Button
    // ──────────────────────────────────────
    handleNext() {
        // Fire Event to Aura Parent
        this.dispatchEvent(
            new CustomEvent('recordtypeselect', {
                detail: {
                    selectedValue : this.selectedValue,
                    selectedLabel : this.selectedLabel
                },
                bubbles  : true,
                composed : true
            })
        );
        console.log('[filterDropdown] Next Clicked:', {
            value : this.selectedValue,
            label : this.selectedLabel
        });
        var self = this;
        
        // Call Apex controller to fetch record type details
        getRecordTypeDetailsByValue({
              recordTypeValue: this.selectedValue
            })
              .then(result => {
                this.searchRecords = result;
              })
        console.log('[Recordtypedetails] Record Type Details Fetched:', this.searchRecords);
        
    }
    
    // ──────────────────────────────────────
    // Handle Cancel Button
    // ──────────────────────────────────────
    handleCancel() {
        // Fire Cancel Event to Aura
        this.dispatchEvent(
            new CustomEvent('cancelselect', {
                bubbles  : true,
                composed : true
            })
        );
    }
    
    // ──────────────────────────────────────
    // Get Option Label
    // ──────────────────────────────────────
    getOptionLabel(value) {
        const option = this.options.find(
            opt => opt.value === value
        );
        return option ? option.label : '';
    }
    
    // ──────────────────────────────────────
    // Getters
    // ──────────────────────────────────────
    get hasSelectedValue() {
        return this.selectedValue !== '';
    }
    
    get isNextDisabled() {
        return this.selectedValue === '';
    }
}