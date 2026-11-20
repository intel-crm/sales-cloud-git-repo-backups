import { LightningElement,track,wire, api } from 'lwc';
/*import checkCapability from '@salesforce/apex/Sales_FeedbackController.checkCapability_NonEvent'; 
import givefeedback from '@salesforce/label/c.Sales_GiveFeedback_Html';
import give_nonfeedback from '@salesforce/label/c.Sales_Nonevent_GiveFeedback';
*/
export default class Sales_NonEventFeedback extends LightningElement {
/*@api isButtonClicked=false;
@track capabilityvalue;
@track windowURL;
@track iscapability=false;

label = {givefeedback,give_nonfeedback};

@wire(checkCapability, {capability : '$capabilityvalue'})//added for feedback
checkCapability({error,data}){
    if(data){
       console.log('capability available in parent>'+data);
        this.iscapability=data;
     }
    if(error){
      console.log('capability not available in parent>'+data);
    }
}

connectedCallback(){
  this.windowURL = String(window.location);
  console.log('Split value' + this.windowURL.split('/s/'));
  this.capabilityvalue=this.windowURL.split('/s/')[1];//to query the  capability from community
  this.capabilityvalue=this.capabilityvalue.split('/')[0];
  this.capabilityvalue=this.capabilityvalue.replace(/-/g, ' ');
  console.log(this.capabilityvalue+'connected callback');
      
}


 extendFeedback() {
  
    this.isButtonClicked=true;
    
}
 closeFeedback() {
	 console.log('cancel feedback');
	this.isButtonClicked=false;
}*/
}