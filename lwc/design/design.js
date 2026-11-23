import { LightningElement } from 'lwc';

export default class Design extends LightningElement {
    value = 'Entire Site';

    get options() {
        return [
            { label: 'Entire Site', value: 'Entire Site' },
            { label: 'Support & Technical Documentation', value: 'Support & Technical Documentation' },
            { label: 'Knowledge Base', value: 'Knowledge Base' },
            { label: 'Forums & Wiki', value: 'Forums & Wiki' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }
}