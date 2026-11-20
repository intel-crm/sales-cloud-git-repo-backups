import { LightningElement, track, api } from 'lwc';

export default class Core_MDF_Campaign_Available_Budgets_Picklist extends LightningElement {

    @api
    values = [];

    @track
    selectedvalues = [];
    @track budgetValues = [];
    @track selectionFlagFromPicklistComponent;
    @api required;

    @api
    picklistlabel = 'Budget Type';

    showdropdown;

    handleleave() {
        
        let sddcheck= this.showdropdown;

        if(sddcheck){
            this.showdropdown = false;
            this.fetchSelectedValues();
        }
    }

    connectedCallback(){
        console.log('Core_MDF_Campaign_Available_Budgets_Picklist called');
        this.values.forEach(element => element.selected 
                            ? this.selectedvalues.push(element.value) : '');
    }

    fetchSelectedValues() {
        
        this.selectedvalues = [];
        this.budgetValues = [];

        //get all the selected values
        this.template.querySelectorAll('c-core_-m-d-f_-campaign_-picklist_-selection').forEach(
            element => {
                if(element.selected){
                    //console.log('Awesome' + element.label);
                    let obj = {label : element.label, value: element.value };
                    this.budgetValues = [... this.budgetValues, obj];
                    this.selectedvalues.push(element.value);
                }
            }
        );
        //refresh original list
        this.refreshOrginalList();
    }

    refreshOrginalList() {
        const picklistvalues = this.values.map(eachvalue => ({...eachvalue}));

        picklistvalues.forEach((element, index) => {
            if(this.selectedvalues.includes(element.value)){
                picklistvalues[index].selected = true;
            }else{
                picklistvalues[index].selected = false;
            }
        });
        this.values = picklistvalues;

    }

    handleShowdropdown(){
        let sdd = this.showdropdown;
        console.log('this.showdropdown' + this.showdropdown);
        if(sdd){
            this.showdropdown = false;
            this.fetchSelectedValues();
        }else{
            this.showdropdown = true;
        }
    }

    get selectedmessage() {
        return this.selectedvalues.length + ' budget(s) are selected';
    }

    onPicklistSelection(event){
        this.fetchSelectedValues();
        const passEvent = new CustomEvent('budgetselection', {
            detail:{recordId:this.budgetValues} 
        });
       this.dispatchEvent(passEvent);
    }

    @api isValid() {
        let availableBudgetsCmp = this.template.querySelector(".availableBudgetsCmp");
        if(this.selectedvalues.length > 0){
            console.log('Thisn12');
            availableBudgetsCmp.setCustomValidity("");
            availableBudgetsCmp.reportValidity();
            return true;
        }
        else{
            availableBudgetsCmp.setCustomValidity("Complete this field.");
            availableBudgetsCmp.reportValidity();
            return false;
        }
    }
}