import { LightningElement,track,api } from 'lwc';
export default class TestFunctionality extends LightningElement {
  @track options = [
    { label: 'English', value: 'en' },
    { label: 'German', value: 'de' },
    { label: 'Spanish', value: 'es' },
    { label: 'French', value: 'fr' },
    { label: 'Italian', value: 'it' },
    { label: 'Japanese', value: 'ja' },
];
@track selected = [];

handleSelection() {
this.options.forEach(ele => {
    if(ele.value == event.currentTarget.dataset.value) {
        this.selected.push(ele);
    }
});

this.options = this.options.filter(ele => ele.value != event.currentTarget.dataset.value);
}

}