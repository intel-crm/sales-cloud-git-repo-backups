import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class Zabcd extends LightningElement {
    @wire(CurrentPageReference)
    currentPageReference; 

    get recordIdFromState(){
        return this.currentPageReference &&
            this.currentPageReference.state.c__recordId; // Once you have recordId you can call apex
    }
}