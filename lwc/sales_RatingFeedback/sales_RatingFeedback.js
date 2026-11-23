import { LightningElement,wire, track,api } from 'lwc';
import createFeedBack from '@salesforce/apex/Sales_FeedbackController.createFeedBack_NonEvent';
import getPickListValues from '@salesforce/apex/Sales_FeedbackController.getPickListValues';
import checkCapability from '@salesforce/apex/Sales_FeedbackController.checkCapability_NonEvent'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import successmessage from '@salesforce/label/c.Sales_successfornonevent';
import charactermessage from '@salesforce/label/c.sales_feedback_char_message';
import optional from '@salesforce/label/c.sales_feedback_optional_message';
import rating_one from '@salesforce/label/c.sales_feedback_rate_message';
//import rating_two from '@salesforce/label/c.sales_feedback_rate_end_message';
import feedbackicon from '@salesforce/resourceUrl/Feedbackicon';
import service from '@salesforce/label/c.sales_feedback_service_message';
import SalesGiveFeedbackHtml from '@salesforce/label/c.Sales_GiveFeedback_Html';
import Sales_SubmitFeedback_Html from '@salesforce/label/c.Sales_SubmitFeedback_Html';
import Sales_GiveFeedback_1star  from '@salesforce/label/c.Sales_GiveFeedback_1star';
import Sales_GiveFeedback_2star  from '@salesforce/label/c.Sales_GiveFeedback_2star';
import Sales_GiveFeedback_3star  from '@salesforce/label/c.Sales_GiveFeedback_3star';
import Sales_GiveFeedback_4star  from '@salesforce/label/c.Sales_GiveFeedback_4star';
import Sales_GiveFeedback_5star  from '@salesforce/label/c.Sales_GiveFeedback_5star';
import Sales_capability  from '@salesforce/label/c.Sales_capability';
import Sales_SelectCapability  from '@salesforce/label/c.Sales_SelectCapability';


export default class Sales_RatingFeedback extends LightningElement {
    feedbackiconnew = feedbackicon ;
    @track  textfeed='';
    @track remaining = 500;
    @track output=500;
    @track isRatingProvided=false;
    @track name;
    @track eventrating;
    @track capabilitydropdown;
    @track ratinginput;
    @track textinput;
    @track capabilityinput;
    @api capability;
  // @track capabilityhtml;
   @track windowURL;
   @track iscapability=false;
   @track capabilityvalue ;
   @api fieldapiName='Capability__c';
   @api objectApiName = 'Sales_Feedback__c';
   @track options;
   @track isCapabilityProvided=false;
   
   connectedCallback(){
    this.windowURL = String(window.location);
    console.log('Split value' + this.windowURL.split('/s/'));
    this.capabilityvalue=this.windowURL.split('/s/')[1];//to query the  capability from community
    //this.capabilityvalue=this.capabilityvalue.split('/')[0];
    console.log(this.capabilityvalue+'connected callback of rating component');

    if(this.capabilityvalue=='feedback'){
    this.capabilityvalue=this.capabilityvalue.replace(/-/g, ' ');
    this.capability=this.capabilityvalue;
    }
   getPickListValues({
            objApiName: this.objectApiName,
            fieldName: this.fieldapiName
        })
            .then(data => {
               
                this.options = data;
                console.log(data);
                console.log('data'+JSON.stringify(this.options)); 
                
            })
            .catch(error => {
                this.displayError(error);
            });
            console.log('values'+JSON.stringify(this.options)); 

  }
  
   @wire(checkCapability, {capability : '$capability'})//added for feedback
   checkCapability({error,data}){
       if(data){
          console.log('capability available>'+data);
           this.iscapability=data;
         //  this.capabilityhtml=this.capability.replace(/-/g, ' ');
         // console.log(capabilityhtml);
          
        }
       if(error){
       }
   }
   

   label = {
    successmessage,charactermessage,optional,rating_one,SalesGiveFeedbackHtml,service,Sales_SubmitFeedback_Html,Sales_GiveFeedback_1star,Sales_GiveFeedback_2star,Sales_GiveFeedback_3star,Sales_GiveFeedback_4star,Sales_GiveFeedback_5star,Sales_capability,Sales_SelectCapability}; 

    input1OnChange(event){
        this.textfeed= event.target.value;
        //console.log(this.textfeed);
        //console.log(this.textfeed.length);

        this.output =(this.remaining)-(this.textfeed.length);
       // console.log(this.output);
    }
    rating(event) {
        this.eventrating=null;
        this.eventrating = event.target.value;
        console.log('this.eventrating>>>>'+this.eventrating);
      
    }
    handlecapability(event) {
        this.capabilitydropdown = event.target.value;
        console.log('capability dropdown value ' + this.capabilitydropdown);
    }
    
    @api handleOnSubmit(){
        if(this.eventrating>0 && this.eventrating !=undefined){
            this.isRatingProvided = false;
        }else{
            this.isRatingProvided = true;
        }
        if((this.capabilitydropdown==undefined ||this.capabilitydropdown=='')){
            this.isCapabilityProvided = true;
            console.log('capability not entered');

        }
        else{
            this.isCapabilityProvided = false;
            console.log('capability entered');

        }
     console.log('this.eventrating>>>>'+this.eventrating+'<<<this.capability>>>'+this.capabilitydropdown+'<<this.feedText>>'+this.textfeed);
    if(this.iscapability==true && this.eventrating>0 && this.eventrating !=undefined &&(this.capabilitydropdown !=undefined && this.capabilitydropdown!='')){
      //  this.createRecord(this.eventrating,this.textfeed,this.capability);
      this.createRecord(this.eventrating,this.textfeed,this.capabilitydropdown);

      }  
    }
     @api handleOnCancel(){
      console.log('Incancel');
      const close = new CustomEvent("close");
      this.dispatchEvent(close);
    }

    createRecord(ratinginput,textinput,capabilityinput){
        console.log('Apex call for create feedback>>'+ratinginput+' <<<textinput>>> '+textinput+' <<<capability>>> '+capabilityinput);
        console.log(this.capability+'capability');
        createFeedBack({rating: ratinginput,textinput: textinput,capability:capabilityinput})
        .then(data => {
            console.log('Success data created'+data);
            const evt = new ShowToastEvent({
                variant:'success',
                title:'',
                message: this.label.successmessage
            });
            this.dispatchEvent(evt);
        const close = new CustomEvent("close");
        this.dispatchEvent(close);
        })
        .catch(error => {
           console.log('Failure'+JSON.stringify(error));
        }); 
}

  
}