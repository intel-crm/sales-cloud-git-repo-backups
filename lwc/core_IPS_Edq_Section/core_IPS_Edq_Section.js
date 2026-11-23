import { LightningElement } from 'lwc';

export default class Core_IPS_caseCreation_EDQ_Section extends LightningElement {
    value = 'inProgress';
    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }
}