import { LightningElement, track, api } from 'lwc';

export default class Core_MDF_Campaign_Available_Budgets_Picklist extends LightningElement {

    @api
    values = [];

    @track
    selectedvalues = [];
    @track budgetValues = [];
    @track selectionFlagFromPicklistComponent;
    availableBudgetsError = false;
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
        
	this.values.forEach(element => element.selected?this.selectedvalues.push(element.value) : '');
    }

    @api fetchSelectedValues() {
        this.selectedvalues = [];
        this.budgetValues = [];

        //get all the selected values
        this.template.querySelectorAll('c-core_-m-d-f_-campaign_-picklist_-selection').forEach(
            element => {
                if(element.selected){
                    let obj = {label : element.label, value: element.value };
                    this.budgetValues = [... this.budgetValues, obj];
                    this.selectedvalues.push(element.value);
                }
            }
        );
        //refresh original list
        this.refreshOrginalList();
        return this.selectedvalues;
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
       this.availableBudgetsError = false;
    }

    @api isValid() {
    
        this.availableBudgetsError = this.selectedvalues.length > 0? false : true;
        return !this.availableBudgetsError ;
    }
}