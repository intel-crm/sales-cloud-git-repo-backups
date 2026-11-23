import { LightningElement } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { FlowAttributeChangeEvent,FlowNavigationFinishEvent} from 'lightning/flowSupport';

export default class Core_CustomCancelButton extends LightningElement {

handleCancelBtn(event){
        // navigate to the next screen
        var navigationEvent = new FlowNavigationFinishEvent();

        try{
             this.dispatchEvent(navigationEvent);
        }
        catch(ex){
            console.log('Exception: ' + ex);
        }
    }

}