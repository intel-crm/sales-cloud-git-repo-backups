import { LightningElement } from 'lwc';

export default class HandlePaginator extends LightningElement {
  

    handleNext(_event) {
        this.dispatchEvent(new CustomEvent('next'));
    }
}