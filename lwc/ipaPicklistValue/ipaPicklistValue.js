import { LightningElement, api } from 'lwc';

/** Documentation for ipaPicklistValue Component
 *
 * @property {boolean} selected determines if a option is selected or not
 * @property {String} label the label of the option
 * @property {String} value the value of the option
 * @property {String} id the id of the option
 * @property {String} objectname gives if category, specification or specification value
 */
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

    /**
     * Keeps track of the heading classes for the option
     *
     * @private
     */
    heading='';

    /**
     * ConnectedCallback - updates the class values for the heading to be used for options
     * 
     * @private
     */
    connectedCallback() {
        this.heading ='slds-media slds-listbox__option slds-listbox__option_plain slds-media_small slds-is-selected';
    }

    /**
     * Fires when an option is selected
     *
     * @private
     * @param {*} event
     */
    handleSelect(event) {
        if(this.selected) {
            this.selected = false;
        } else {
            this.selected = true;
        }
    }

    /**
     * Handles the option color change when being hovered
     *
     * @private
     * @param {*} event
     */
    handlecolorchange(event) {
       this.heading = 'slds-media slds-listbox__option slds-listbox__option_plain slds-media_small slds-is-selected bluecoloradded';
    }
}