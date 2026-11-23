import { LightningElement, track } from 'lwc';

export default class Domain extends LightningElement {
    @track programValue = 'Select' ;
    get ShowOptions(){
        window.console.log('Inside get Options::');
        return [
            { label: 'Client Co-Marketing Fund', value: 'Client Co-Marketing Fund' },
            { label: 'Data Center Co-Marketing Fund', value: 'Data Center Co-Marketing Fund' },
            { label: 'Service Provider Co-Marketing Fund', value: 'Service Provider Co-Marketing Fund' },
            { label: 'Client Co-Marketing Fund Boost', value: 'Client Co-Marketing Fund Boost' },
            { label: 'Retail Marketing Funds', value: 'Retail Marketing Funds' },
        ]
    }
    handleChange(event) {
        window.console.log('inside handle change event.detail.value::'+event.detail.value);
        this.programValue = event.detail.value;
    }
}