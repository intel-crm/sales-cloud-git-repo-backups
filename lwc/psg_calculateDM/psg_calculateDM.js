import { LightningElement,api,track} from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import calculateDM from '@salesforce/apex/PSG_DPA_ALNLinesBusinessLogic.calculateDM';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Psg_calculateDM extends LightningElement {

    @api recordId;
    isLoaded = false;
    title='Confirmation';
    message='Refreshed DM% will be populated in "Auto Calculated Disty Margin%" Field. ';
    
    handleClick(event){
        if(event.target.name =='Yes'){
            this.CalculateDM();
        }else{
            this.closeQuickAction();
        }

    }

    CalculateDM() {
        console.log('Line ID'+this.recordId);
       this.isLoaded=true;
       calculateDM({LineID :this.recordId})
       .then(result=>{ 
           this.isLoaded = false; 
           console.log(result);
           this.closeQuickAction();
           this.fireToastEvent('Success!','Auto Calculated Disty Margin% is Calculated & Updated','success','dismissable');
           eval("$A.get('e.force:refreshView').fire();");
           
           }) 
           .catch(error=>{  
           this.isLoaded=false;
           this.closeQuickAction();
           this.fireToastEvent('Failure!','Error while calculating Disty Margin% '+JSON.stringify(error),'error','dismissable');
           console.log('Error while calculation'+ JSON.stringify(error));
           }) 


    }

    fireToastEvent(title, message, variant, mode) {
        console.log('inside toast');
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
    }));
    }
    
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}