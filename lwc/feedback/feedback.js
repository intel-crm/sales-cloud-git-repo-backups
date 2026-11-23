// feedbackBar.js
import { LightningElement,api,track,wire } from 'lwc';
import submitScoreAction from '@salesforce/apex/Core_MDF_FeedbackController.submitScoreAction';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import {NavigationMixin} from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getQuestions from '@salesforce/apex/Core_MDF_FeedbackController.fetchRecords';
import isExternalPortal from '@salesforce/apex/Core_MDF_FeedbackController.isCommunity';
import externalUI from './core_MDF_External_Feedback.html';
import internalUI from './feedback.html';
import Core_MDF_Submit_Feedback from '@salesforce/label/c.Core_MDF_Submit_Feedback';
import Core_MDF_Submit_Button_Label from '@salesforce/label/c.Core_MDF_Submit_Button_Label';
import Core_MDF_Cancel from '@salesforce/label/c.Core_MDF_Cancel';
import Core_MDF_Close from '@salesforce/label/c.Core_MDF_Close';
import Core_MDF_Additional_Comments from '@salesforce/label/c.Core_MDF_Additional_Comments';
import Core_MDF_Optional_Feedback from '@salesforce/label/c.Core_MDF_Optional_Feedback';



export default class FeedbackBar extends LightningElement {

  @track isModalOpen = false;
  @track easyToUse;
  @track hasFeaturesWant;
  @track fastAndResponsive;
  @track isSecured;
  @track optionalFeedback;
  @track surveyLog;
  data;
  error;
  @api recordId;
  currentPageReference = null; 
  urlStateParameters = null;
  @api picklistValues=[];
  @api activeColor = '#ffd055'
  @api inactiveColor = '#d8d8d8'
  @api stars=[];

  @track questionList=[];
  @track questionSets=[];
  @track ratingMap=new Map();
  @track question;
  @track response;
  @track res=[];
  @track isCommunity = false;

  closeButton = Core_MDF_Close;
  submitFeedback = Core_MDF_Submit_Feedback;
  submitButton = Core_MDF_Submit_Button_Label;
  cancelButton = Core_MDF_Cancel;
  additionalComments = Core_MDF_Additional_Comments;
  optionalFeedback = Core_MDF_Optional_Feedback;


  render() {
		return this.isCommunity == true ? externalUI : internalUI;
	}

    getSurveyQuestions(){
        getQuestions().then(result=>{
          console.log('Result->',result);
           this.questionList=result;
            if(this.questionList.length>0){
              this.generateQuestionSets();
            }
        })
        .catch(error => {
          this.error = error;//toast
        });
      }

      getIsCommunity(){
        isExternalPortal().then(result=>{
          this.isCommunity = result;
          console.log('@@isCommunity -> ',this.isCommunity);
        })
        .catch(error => {
          this.error = error;//toast
        });
      }  
    
      connectedCallback() {
        this.getSurveyQuestions();
        this.getIsCommunity();
      }

      @wire(CurrentPageReference)
  getPageReferenceParameters(currentPageReference) {
     if (currentPageReference) {
        console.log('Hi there'+JSON.stringify(currentPageReference));
        this.recordId = currentPageReference.attributes.recordId || null;
        this.surveyLog = currentPageReference.attributes;
        console.log('Logsss',this.surveyLog);
        console.log('attributes',JSON.stringify(currentPageReference.attributes));
     }
  }

  generateQuestionSets(){
    //this.stars=[];
    console.log('QuestionListLength',this.questionList.length);
    for(let index = 0; index < this.questionList.length; index++){
        console.log('Line 103');
        let ratingStars=[];
        ratingStars=this.generateStars(index+1);
        console.log('Line 105->',this.questionList[index]);
        this.questionSets.push({label:this.questionList[index].question,
                              quesOrder:this.questionList[index].order,
                              quesId:this.questionList[index].questionId,
                              star:ratingStars});
        console.log('Line 109');
    }
    console.log('questionSets',this.questionSets);
    

  }

  generateStars(index) {
    console.log('Inside generateStars2');
    var ratingStarsArr = [];
    console.log('Inside generateStars2  22');
    for (let counter = 1; counter <= 7; counter++) {
      
      var star = {
        id: 'ques'+index+'-star'+counter,
        name:'ques'+index,
        value:counter,
        //displayLabel:'Rating'+counter
      }
      ratingStarsArr.push(star)
    }
    console.log('starArray',ratingStarsArr);
    return ratingStarsArr;
  }

  rating(event){
    var question=event.target.name;
    var response=event.target.value;
    var data = event.target.getAttribute("data-id");
    var questionDetails;
    if(question !="OptionalFeedback"){
       questionDetails = data ;
    }
    else{
      questionDetails= question;
    }

    this.ratingMap.set(questionDetails,response);
    
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

    openFeedbackPopup() {
       // const feedbackPopup = this.template.querySelector('.feedback-popup');
        //feedbackPopup.style.display = 'block';
        this.isModalOpen = true;
    }

    closeFeedbackPopup() {
       // const feedbackPopup = this.template.querySelector('.feedback-popup');
        //feedbackPopup.style.display = 'none';
        this.isModalOpen = false;
    }

    submitFeedback() {
        const feedbackText = this.template.querySelector('#feedbackText').value;
        // Handle the feedback submission, e.g., send it to your server
        console.log('Feedback:', feedbackText);
       // const feedbackPopup = this.template.querySelector('.feedback-popup');
       // feedbackPopup.style.display = 'none';
    }

/*******************************************************************************************************************************************************************/


  submitAction(){
    console.log('quesRating->',this.ratingMap);
    var quesRating = [];
    var recordDetails ;        
    var surveyMapDetails = {};
    for (const [key, value] of this.ratingMap.entries()) {
      recordDetails = key != 'OptionalFeedback' ? key : '' ;
      quesRating.push({
        //'question': recordDetails.length ? recordDetails[0] : key,
        'questionId' : recordDetails ,
        'rating': value
      });
      surveyMapDetails.pageRef = JSON.stringify(this.surveyLog);
      surveyMapDetails.SurveyDetailsWrapperList = quesRating;
      console.log('questionRating->',quesRating);
    }
    console.log('surveyMapDetails',surveyMapDetails);
    submitScoreAction({surveyMap:surveyMapDetails})
    .then(result=>{
      //this.scoreRecoreId = result.Id;

       // window.console.log('scoreRecoreId##Vijay2 ' + this.scoreRecoreId);

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

        actionName: 'view'

    },

    });

    })
  }




/*******************************************************************************************************************************************************************/


}