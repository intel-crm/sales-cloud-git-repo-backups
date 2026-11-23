import { LightningElement } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class DummyComp extends LightningElement {
    connectedCallback(){
        console.log('Started');
        this.closeAction();
    }
    closeAction(){ 
        
        this.dispatchEvent(new CloseActionScreenEvent()); 
        console.log('Closing Console');
    }
}