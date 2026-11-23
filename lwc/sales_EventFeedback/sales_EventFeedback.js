import { LightningElement, track,api } from 'lwc';
import createFeedBack from '@salesforce/apex/Sales_FeedbackController.createFeedBack'; 
import ALN_OBJECT from '@salesforce/schema/Sales_License__c';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import feedbackicon from '@salesforce/resourceUrl/Feedbackicon';
import successmessage from '@salesforce/label/c.Sales_successfornonevent';
import charactermessage from '@salesforce/label/c.sales_feedback_char_message';
import optional from '@salesforce/label/c.sales_feedback_optional_message';
import rating_one from '@salesforce/label/c.sales_feedback_rate_message';
//import rating_one from '@salesforce/label/c.sales_event_feedback_rate_message';
//import rating_two from '@salesforce/label/c.sales_event_feedback_rate_end_message';
import rating_label from '@salesforce/label/c.sales_feedback_rate_message';
import service from '@salesforce/label/c.sales_feedback_service_message';
import givefeedback from '@salesforce/label/c.Sales_GiveFeedback_Html';
import submitfeedback from '@salesforce/label/c.Sales_SubmitFeedback_Html';
import Sales_GiveFeedback_1star  from '@salesforce/label/c.Sales_GiveFeedback_1star';
import Sales_GiveFeedback_2star  from '@salesforce/label/c.Sales_GiveFeedback_2star';
import Sales_GiveFeedback_3star  from '@salesforce/label/c.Sales_GiveFeedback_3star';
import Sales_GiveFeedback_4star  from '@salesforce/label/c.Sales_GiveFeedback_4star';
import Sales_GiveFeedback_5star  from '@salesforce/label/c.Sales_GiveFeedback_5star';
import getPickListValues from '@salesforce/apex/Sales_FeedbackController.getPickListValues';
import Sales_capability  from '@salesforce/label/c.Sales_capability';


/******************************************************
    Component Name    : Sales_FeedbackController
    Created Date  : Jul 2021
    Function      : US1051027,US1051031
    
    Modification Log :
    Developer                       Date                    Description
    mohanx.ananga@intel.com         19/07/2021               US1051027
    chaithanyax.lakshman@intel.com  08/10/2021               US1051031
    *****************************************************/
export default class sales_EventFeedback extends  NavigationMixin(LightningElement) {
    feedbackiconnew = feedbackicon ;
    @track labelvalue='';
    @track labelvaluechatbot='';
    @track  feedText='';
    @track remaining=500;
    @track output=500;
    @track eventrating;
    @track rating1;
    @track textIP;
    @api recId;
    @api capablity='';
    @track isRatingProvided=false;
    @track isCapabilityProvided = false;
    @api chatbot;//added for chatbot feedback
    @track ischatbotvalue=false;//added for chatbot feedback
    @api fieldapiName='Capability__c';
    @api objectApiName = 'Sales_Feedback__c';
    @track options;
    @track value;
    @track capabilitydropdown;
    @api fromchatbotvariable=false;
    @track disablevalue=false;
    
    label = {
        successmessage,charactermessage,optional,rating_one,service,givefeedback,submitfeedback,Sales_GiveFeedback_1star,Sales_GiveFeedback_2star,Sales_GiveFeedback_3star,Sales_GiveFeedback_4star,Sales_GiveFeedback_5star,rating_label,Sales_capability}; 
        
    inputOnChange(event){
     
       this.feedText= event.target.value;
       this.output =(this.remaining)-(this.feedText.length);
       
    }
    rating(event) {
          this.eventrating = event.target.value;
          console.log('this.eventrating>>>>'+this.eventrating);
      }

    handlecapability(event) {
        this.capabilitydropdown = event.target.value;
        console.log('capability dropdown value ' + this.capabilitydropdown);
    }

    connectedCallback(){
        this.labelvalue=this.label.rating_one;
       let url=  window.location;
       //added for chatbot

     if(this.chatbot=='chatbot'){
	    this.ischatbotvalue=true;	
        console.log('ischatbotvalue value'+this.ischatbotvalue);
       }
      if(this.capablity=='Generate License')
      {
       // this.labelvalue=this.label.rating_two;
        this.capabilitydropdown='Generate License';
        this.value=this.capabilitydropdown;
        this.disablevalue=true;
      }
      else if(this.capablity=='Split Seats')
      { this.capabilitydropdown='Split Seats';
        this.value=this.capabilitydropdown;
       // this.labelvalue=this.label.rating_one; 
       this.disablevalue=true;
      }
      else if(this.capablity=='License Chatbot'){
        this.capabilitydropdown='';
      }

      //  alert('connected callback>>>>');
      getPickListValues({
        objApiName: this.objectApiName,
        fieldName: this.fieldapiName
    })
        .then(data => {
           
            this.options = data;
            console.log(data);
            console.log('data line 93'+JSON.stringify(this.options)); 
            
        })
        .catch(error => {
            this.displayError(error);
        });
        console.log('values'+JSON.stringify(this.options)); 
    }
    
    handleOnSubmit(){
        console.log('this.eventrating>>>>'+this.eventrating+'<<<this.capablity>>>'+this.capabilitydropdown+'<<this.feedText>>'+this.feedText);
        if(this.eventrating !=undefined ){
            this.isRatingProvided = false;
        }
        else{
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
       
       if(this.eventrating !=undefined && (this.capabilitydropdown!=undefined && this.capabilitydropdown!='')){
            console.log('inside if>>>');
           
            this.createRecord(this.eventrating,this.feedText,this.capabilitydropdown,this.recId,this.fromchatbotvariable);
            console.log('feedback Record>>>>>'+this.recId)
            const evt = new ShowToastEvent({
                variant:'success',
                title: '',
                message:  this.label.successmessage
            });
            this.dispatchEvent(evt);
            this.navigatetorecord(this.recId);
        }else{
            console.log('inside error else');
            
        }
   
    }
    handleOnCancel(){
        console.log('Incancel')
        this.eventrating=0;
        console.log('this.eventrating>>>>'+this.eventrating+'<<<this.capablity>>>'+this.capabilitydropdown+'<<this.feedText>>'+this.feedText);
        this.createRecord(this.eventrating,this.feedText,this.capabilitydropdown,this.recId,this.fromchatbotvariable);
        this.navigatetorecord(this.recId);
    }
    createRecord(rating1,textIP,capabilitydropdown,recID,fromchatbotvariable){
        console.log('Apex call for create feedback>>'+rating1+' <<<textIP>>> '+textIP+'fromchatbot'+fromchatbotvariable);
        createFeedBack({rating: rating1,textinput: textIP,capablity:capabilitydropdown,recID:recID,feedbackchatbot:fromchatbotvariable})
        .then(data => {
            console.log('Success'+data);
        })
        .catch(error => {
           console.log('Failure');
        }); 
    }
    navigatetorecord(rec){
        console.log('Navigate recId>>>'+this.recId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: rec,
                objectApiName: 'Sales_License__c', // objectApiName is optional
                actionName: 'view'
            }
        });
        //alert('before reload evt');
        this.reloadPage();

    }
    
    reloadPage(){

        setTimeout(function() {
        location.reload(true);
        }, 2000);    
    }
    @api handleOnCancelchatbot(){
        	console.log('Incancel')
        	this.eventrating=0;
            console.log('this.eventrating>>>>'+this.eventrating+'<<<this.capablity>>>'+this.capabilitydropdown+'<<this.feedText>>'+this.feedText);
        	this.createRecord(this.eventrating,this.feedText,this.capabilitydropdown,this.recId,this.fromchatbotvariable);
        	//added for chatbotfeedback
            console.log('Incancel');
        	const close = new CustomEvent("close");
            this.dispatchEvent(close);
       	 }
        
        
    handleOnSubmitchatbot(){
                console.log('this.eventrating>>>>'+this.eventrating+'<<<this.capablity>>>'+this.capabilitydropdown+'<<this.feedText>>'+this.feedText);
                if(this.eventrating !=undefined ){
                    this.isRatingProvided = false;
                }
                else{
                    this.isRatingProvided = true;
                   }
                if((this.capabilitydropdown==undefined ||this.capabilitydropdown=='')){
                    this.isCapabilityProvided = true;
                    console.log('value of flag'+this.isCapabilityProvided);
                }
                else{
                    this.isCapabilityProvided = false;
                }
                
                if(this.eventrating>0 && this.eventrating !=undefined && (this.capabilitydropdown!=undefined && this.capabilitydropdown!='')){
                    console.log('inside if>>>');
                   // this.isRatingProvided = false;
                  
                    this.createRecord(this.eventrating,this.feedText,this.capabilitydropdown,this.recId,this.fromchatbotvariable);
                    console.log('feedback Record>>>>>'+this.recId)
                    const evt = new ShowToastEvent({
                        variant:'success',
                        title: '',
                        message:  this.label.successmessage
                    });
                    this.dispatchEvent(evt);
                     const close = new CustomEvent("close");
                     this.dispatchEvent(close);
                     }
                else
                   {
                    console.log('inside error else');
                   // this.isRatingProvided = true;
                    }
     }
    }