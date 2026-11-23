import { LightningElement, track, api } from 'lwc';
import labelCompleteThisFieldError from '@salesforce/label/c.Core_MDF_CompleteThisField_ErrorMessage';
import actySubtypeLabel from '@salesforce/label/c.Core_MDF_ActivitySubType'; 
export default class core_MDF_ActySubtype extends LightningElement {
    @api
    values = [];
    @track
    selectedvalues = [];
    @track budgetValues = [];
    @track selectionFlagFromPicklistComponent;
    @api required;
    @track disablePickilst = false;    
    @api
    picklistlabel;
    showdropdown;    
    @api noOfValuesGotSelectedLable;
    @api selectedValueCount;
    @track enableDefaultSelection = false; // By defualt user need to do selectManualValues
    @api defaultSelectionReq; // this will get value from Aura
    label = {
        labelCompleteThisFieldError
    };  
   
    handleleave() {
        let sddcheck = this.showdropdown;

        if (sddcheck) {
            this.showdropdown = false;
            this.fetchSelectedValues();
        }
    }

    connectedCallback() {
        console.log(' connected callback called for Core_MDF_Claim_ActySubType called'); 
        this.showdropdown = false;
        console.log('showDropDown in connectedcall' + JSON.stringify(this.showdropdown));      
        this.enableDefaultSelection = this.defaultSelectionReq;
        console.log('enableDefaultSelection::'+ this.enableDefaultSelection);
        if(this.enableDefaultSelection){ 
            console.log('inside if 1');
            this.selectAllDefaultValues();
            console.log('inside if 2');
         }else{
            this.selectManualValues();   
        }             
    }
   

    @api selectAllDefaultValues(){
            console.log('inside selectAllDefaultValues called');
            this.values.forEach(element => this.selectedvalues.push(element.value)); //Added 1st line
             const value = this.selectedvalues;
            console.log('default selected values' +value); 
            this.refreshOrginalList();
            const valueEvent = new CustomEvent('DefualtSelection', {
                detail: { value }
            });
            console.log('Event values' +valueEvent);
            this.dispatchEvent(valueEvent);

    }
    @api selectManualValues(){
        this.values.forEach(element => element.selected ? this.selectedvalues.push(element.value) : '');
    }

    @api fetchSelectedValues() {
        console.log('fetchSelectedValues called');
        this.selectedvalues = [];
        this.budgetValues = [];

        //get all the selected values
        this.template.querySelectorAll('c-core_-m-d-f_-campaign_-picklist_-selection').forEach(
            element => {
                if (element.selected) {
                    console.log('inside if Areefa' + element.label);
                    let obj = { label: element.label, value: element.value };
                    this.budgetValues = [... this.budgetValues, obj];
                    this.selectedvalues.push(element.value);
                }
            }
        );
        console.log('this.selectedvalues' + this.selectedvalues);
        //refresh original list
        this.refreshOrginalList();
    }

    @api refreshOrginalList() {
        console.log('inside refreshOrginalList');
        const picklistvalues = this.values.map(eachvalue => ({ ...eachvalue }));

        picklistvalues.forEach((element, index) => {
            if (this.selectedvalues.includes(element.value)) {
                picklistvalues[index].selected = true;
            } else {
                picklistvalues[index].selected = false;
            }
        });
        this.values = picklistvalues;

    }

    @api clear() {
        console.log('inside clear');
        const picklistvalues = this.values.map(eachvalue => ({ ...eachvalue }));

        picklistvalues.forEach((element, index) => {
            picklistvalues[index].selected = false;
        });
        this.values = picklistvalues;
        this.selectedvalues = [];

    }

    handleShowdropdown() {
        console.log('inside handleShowdropdown');
        let sdd = this.showdropdown;
        console.log('this.showdropdown' + this.showdropdown);
        if (sdd) {
            this.showdropdown = false;
            this.fetchSelectedValues();
        } else {
            this.showdropdown = true;
        }
    }

    get selectedmessage() {
        return this.selectedvalues.length + ' ' + this.noOfValuesGotSelectedLable;
    }
     @api populateSelectedMessage(value){
         this.selectedvalues.length = value;
     }
    @api disablePickilstMethod() {
        this.disablePickilst = true;
    }
    @api enablePickilstMethod() {
        this.disablePickilst = false;
    }
    onPicklistSelection(event) {
        console.log('inside onPicklistSelection'); 
        this.fetchSelectedValues();
        const value = this.selectedvalues;
        console.log('lwc event value', value)
        const valueChangeEvent = new CustomEvent('ValueSelection', {
            detail: { value }
        });
        const valueChangeLWCEvent = new CustomEvent('select', {
            detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        this.dispatchEvent(valueChangeLWCEvent);
    }

    @api isValid() {
        const availableBudgetsCmp = this.template.querySelector(".availableBudgetsCmp");
        if (this.selectedvalues.length > 0) {
            availableBudgetsCmp.setCustomValidity("");
            availableBudgetsCmp.reportValidity();
            return true;
        }
        else {  
            //var errorMess = this.label.labelCompleteThisFieldError; //'Complete this field';  //availableBudgetsCmp.setCustomValidity("Complete this field.");
            availableBudgetsCmp.setCustomValidity(errorMess);
            availableBudgetsCmp.reportValidity();
            return false;
        }
    }
}