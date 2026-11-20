import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import {CurrentPageReference} from 'lightning/navigation';


export default class UCDFinalPopUp extends LightningElement {
    @api showModal = false;

    closeModal() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}