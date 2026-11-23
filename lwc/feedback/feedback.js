import { LightningElement, api,track,wire} from "lwc";
import submitScoreAction from '@salesforce/apex/Feedbackhelper.submitScoreAction';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import {NavigationMixin} from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';


export default class ChildRating extends LightningElement {
  @track easyToUse;
  @track hasFeaturesWant;
  @track fastAndResponsive;
  @track isSecured;
  @track optionalFeedback;
  @track logs;
  data;
  error;
  @api recordId;
  currentPageReference = null; 
  urlStateParameters = null;

  @wire(CurrentPageReference)
  getPageReferenceParameters(currentPageReference) {
     if (currentPageReference) {
        console.log('Hi there'+JSON.stringify(currentPageReference));
        this.recordId = currentPageReference.attributes.recordId || null;
        let attributes = currentPageReference.attributes;
        let states = currentPageReference.state;
        let type = currentPageReference.type;
        this.logs = JSON.stringify(currentPageReference);
     }
  }
  

  rating(event) {
    if (event.target.name === "etu") {
      this.easyToUse = event.target.value;
    }
    if (event.target.name === "hfw") {
      this.hasFeaturesWant = event.target.value;
    }
    if (event.target.name === "ifr") {
      this.fastAndResponsive = event.target.value;
    }
    if (event.target.name === "isec") {
      this.isSecured = event.target.value;
    }
    if (event.target.name === "w3review") {
        this.optionalFeedback = event.target.value;
      }

  }

  getvalues() {
    
    alert(
      "Is Easy To Use:" +
        this.easyToUse +
        ", Has Features I Want:" +
        this.hasFeaturesWant +
        ", Fast And Responsive:" +
        this.fastAndResponsive +
        ", Is Secured:" +
        this.isSecured +
         ", Optional Feedback :" +
        this.optionalFeedback
    );
    
  }
  submitAction(){

    submitScoreAction({EasytoUse:this.easyToUse,hasFeatures:this.hasFeaturesWant,fastandResponsive:this.fastAndResponsive,isSecured:this.isSecured,additionalQuestions:this.optionalFeedback,logs:this.logs})
    
    .then(result=>{
    
    this.scoreRecoreId = result.Id;
    
    window.console.log('scoreRecoreId##Vijay2 ' + this.scoreRecoreId);
    
    const toastEvent = new ShowToastEvent({
    
    title:'Success!',
    
    message:'Record created successfully',
    
    variant:'success'
    
    });
    
    this.dispatchEvent(toastEvent);
    window.location.reload();
    
    
    /*Start Navigation*/
    
    this[NavigationMixin.Navigate]({
    
    type: 'standard__recordPage',
    
    attributes: {
    
    recordId: this.Id,
    
    objectApiName: 'In_App_Feedback__c',
    
    actionName: 'view'
    
    },
    
    });
    
    /*End Navigation*/
    
    
    
    })
    
    .catch(error =>{
    
    this.errorMsg=error.message;
    
    window.console.log(this.error);
    
    });
   
    
    
    
    }
    

    }