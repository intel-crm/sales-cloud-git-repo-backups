import { LightningElement, track, api } from 'lwc';

export default class App extends LightningElement { 
    @api
    selected = false;
    
    @api
    label;
    
    @api
    value;

    @api
    id;

    @api
    objectname;

    heading='';

    connectedCallback() {
        this.heading ="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small slds-is-selected";
    }

    handleSelect(event) {
        if(this.selected){
            this.selected = false;
        }else{
            this.selected = true;
        } 
    }

    handlecolorchange(event) {
       this.heading = "slds-media slds-listbox__option slds-listbox__option_plain slds-media_small slds-is-selected bluecoloradded"
    }
}