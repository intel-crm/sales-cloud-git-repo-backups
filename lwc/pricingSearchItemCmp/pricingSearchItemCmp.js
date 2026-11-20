import { LightningElement, api } from 'lwc';

export default class PricingSearchItemCmp extends LightningElement {
    @api record;
    @api iconname;

    handleSelect(event){
        event.preventDefault();
        const selectedRecord = new CustomEvent(
            "select", { detail : {recordId: this.record.recordId, fldValue: this.record.fldValue }}
        );
        /* eslint-disable no-console */
        //console.log( this.record.Id);
        /* fire the event to be handled on the Parent Component */
        this.dispatchEvent(selectedRecord);
    }
}