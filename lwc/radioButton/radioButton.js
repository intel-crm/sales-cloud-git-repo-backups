/*import { LightningElement, track, api } from 'lwc';

export default class App extends LightningElement {
    @track optionSelected;

getSelection(event) {
    this.optionSelected = event.detail.value;
}

get isOption1(){return this.optionSelected == 'Opt1'}
get isOption2(){return this.optionSelected == 'Opt2'}

get myoptions() {
    return [
        { label: 'Option 1', value: 'Opt1' },
        { label: 'Option 2', value: 'Opt2' },
    ];
}

}*/
import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class radioButton extends LightningElement {
    showToast() {
        const event = new ShowToastEvent({
            title: 'Get Help',
            message: 'Salesforce {0} documentation is available in the app. Click {1} in the upper-right corner.',
            "messageData": [
                'Salesforce',
                {
                    url: 'http://www.salesforce.com/',
                    label: 'here'
                }
            ]
        });
        this.dispatchEvent(event);
    }
    handleButtonClick() {
        const event = new ShowToastEvent({
            "title": "Success!",
            "message": "Record {0} created! See it {1}!",
            "messageData": [
                'Salesforce',
                {
                    url: 'http://www.salesforce.com/',
                    label: 'here'
                }
            ]
        });
        this.dispatchEvent(event);
    }
}