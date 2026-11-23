import { LightningElement, api, track } from 'lwc';

/** The delay used when debouncing event handdlers before invoking functions. */
export default class ReusableCustomDropdownWithSearchLwc extends LightningElement {

    @api fieldDisabled = false; //Flag for Disabled

    salutationsList = [
        { label: 'Mr.', value: 'Mr.' },
        { label: 'Ms.', value: 'Ms.' },
        { label: 'Mrs.', value: 'Mrs.' },
        { label: 'Dr.', value: 'Dr.' },
        { label: 'Prof.', value: 'Prof.' },
    ];

    get salutationOptions() {
        return this.salutationsList;
    }

    disableHandleClick(){
        if(this.fieldDisabled = true){
            this.fieldDisabled = false;
        }
        else{
            this.fieldDisabled = true;
        }
    }
}