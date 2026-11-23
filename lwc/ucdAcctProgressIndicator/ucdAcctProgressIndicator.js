import { LightningElement, api } from 'lwc';

export default class UcdAcctProgressIndicator extends LightningElement {
    steps = [
        { label: 'Account Request', value: 'step-1' },
        { label: 'Duplicate Information', value: 'step-2' },     
        { label: 'Final Submission', value: 'step-3' }
    ];
    @api stepnum;
}