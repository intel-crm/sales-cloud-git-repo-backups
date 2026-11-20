import { LightningElement,api, track } from 'lwc';
 
export default class Core_MDF_Campaign_Picklist_Selection extends LightningElement {
    @api
    selected = false;
    
    @api
    label;
    
    @api
    value;

    @api
    originalFileName;

    @api
    questionCode;

    @api disabled= false;

    @track listItemCssClass;
    @api parentQuestionCode;


    connectedCallback() {
        if(this.disabled) {
            this.listItemCssClass = 'slds-listbox__item disablelistitem';
        } else {
            this.listItemCssClass = 'slds-listbox__item';
        }
    }

    handleSelect(event) {
        console.log("event from campaign", event.target);
        if(this.selected){
            this.selected = false;
        }else{
            this.selected = true;
        }     
        const passEvent = new CustomEvent('picklistselection', {
            detail:{selectionFlag:this.selected} 
        });
       this.dispatchEvent(passEvent);
    }
}