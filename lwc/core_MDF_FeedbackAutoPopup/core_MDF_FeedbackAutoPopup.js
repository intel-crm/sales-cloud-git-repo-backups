// feedback.js
import { LightningElement, api, track, wire } from 'lwc';

import communityUI from './core_MDF_External_FeedbackAutoPopup.html';
import internalUI from './core_MDF_FeedbackAutoPopup.html';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';

import submitScoreAction from '@salesforce/apex/Core_MDF_FeedbackController.submitScoreAction';
import getQuestions from '@salesforce/apex/Core_MDF_FeedbackController.fetchRecords';
import isExternalPortal from '@salesforce/apex/Core_MDF_FeedbackController.isCommunity';
import getFirstLoginHistory from '@salesforce/apex/Core_MDF_FeedbackController.getFirstLoginHistory';

import Core_MDF_Submit_Feedback from '@salesforce/label/c.Core_MDF_Submit_Feedback';
import Core_MDF_Submit_Button_Label from '@salesforce/label/c.Core_MDF_Submit_Button_Label';
import Core_MDF_Cancel from '@salesforce/label/c.Core_MDF_Cancel';
import Core_MDF_Close from '@salesforce/label/c.Core_MDF_Close';
import Core_MDF_Additional_Comments from '@salesforce/label/c.Core_MDF_Additional_Comments';
import Core_MDF_Optional_Feedback from '@salesforce/label/c.Core_MDF_Optional_Feedback';
import Core_MDF_SuccessToastTitle from '@salesforce/label/c.Core_MDF_SuccessToastTitle';
import Core_MDF_Feedback_Success_Msg from '@salesforce/label/c.Core_MDF_Feedback_Success_Msg';
import APPLICATION_ERROR from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import Core_MDF_Strongly_Agree from '@salesforce/label/c.Core_MDF_Strongly_Agree';
import Core_MDF_Strongly_Disagree from '@salesforce/label/c.Core_MDF_Strongly_Disagree';




export default class Core_MDF_FeedbackAutoPopup extends LightningElement {
  @api userId;
  @api contactId;
  @track isModalOpen = false;
  @track optionalFeedback;
  @track surveyLog;
  @track questionList = [];
  @track questionSets = [];
  @track ratingMap = new Map();
  @track isCommunity = false;
  @track isQuestionAvailable = false;
  @track isSubmitDisabled = true;
  @track data = [];

  currentPageReference = null;
  closeButton = Core_MDF_Close;
  submitFeedback = Core_MDF_Submit_Feedback;
  submitButton = Core_MDF_Submit_Button_Label;
  cancelButton = Core_MDF_Cancel;
  additionalComments = Core_MDF_Additional_Comments;
  optionalFeedback = Core_MDF_Optional_Feedback;
  stronglyAgree = Core_MDF_Strongly_Agree;
  stronglyDisagree = Core_MDF_Strongly_Disagree;


  render() {
    return this.isCommunity == true ? communityUI : internalUI;
  }

  getSurveyQuestions() {
    getQuestions().then(result => {
      console.log('Result->', result);
      this.questionList = result;
      if (this.questionList != undefined && this.questionList != null && this.questionList.length > 0) {
        this.isQuestionAvailable = true;
        this.generateQuestionSets();

      }
    })
      .catch(error => {
        this.showToastMessage('Error', APPLICATION_ERROR, 'error', 'sticky');
      });
  }

  getIsCommunity() {
    isExternalPortal().then(result => {
      this.isCommunity = result;
      console.log('@@isCommunity -> ', this.isCommunity);
    })
      .catch(error => {
        this.showToastMessage('Error', APPLICATION_ERROR, 'error', 'sticky');
      });
  }

  connectedCallback() {
    this.getSurveyQuestions();
    this.getIsCommunity();
    this.getloginHistory();
  }

  @wire(CurrentPageReference)
  getPageReferenceParameters(currentPageReference) {
    if (currentPageReference) {
      this.surveyLog = currentPageReference.attributes;
      console.log('@@this.surveyLog',this.surveyLog);
    }
  }

    getloginHistory() {
      console.log('UserId', this.userId);
      getFirstLoginHistory().then(result => {
        console.log('Result->', result);
        if(result){
         // let popupValue = sessionStorage.getItem('Feedback');
         // console.log('popupValue->', popupValue);
         // if(popupValue != null && popupValue != 'PoppedUp'){
            this.isModalOpen = true;
         // }
        }
        
      })
        .catch(error => {
          this.showToastMessage('Error', APPLICATION_ERROR, 'error', 'sticky');
        });
    }

  generateQuestionSets() {
    console.log('QuestionListLength', this.questionList.length);
    for (let index = 0; index < this.questionList.length; index++) {
      let ratingNumbers = [];
      ratingNumbers = this.generateRadioButtons(index + 1);
      console.log('Line 105->', this.questionList[index]);
      this.questionSets.push({
        label: this.questionList[index].question,
        quesOrder: this.questionList[index].order,
        quesId: this.questionList[index].questionId,
        radioBtn: ratingNumbers
      });
      console.log('Line 109');
    }
    console.log('questionSets', this.questionSets);


  }

  generateRadioButtons(index) {
    var ratingArray = [];
    for (let counter = 1; counter <= 5; counter++) {

      var radioBtn = {
        id: 'ques' + index + '-radio' + counter,
        name: 'ques' + index,
        value: counter,
        //displayLabel:'Rating'+counter
      }
      ratingArray.push(radioBtn)
    }
    console.log('ratingArray', ratingArray);
    return ratingArray;
  }

  rating(event) {
    var question = event.target.name;  //question
    var response = event.target.value; //response 
    var data = event.target.getAttribute("data-id");  //questionId
    var questionDetails;
    if (question != "OptionalFeedback") {
      questionDetails = data;
    }
    else {
      questionDetails = question;
    }

    this.ratingMap.set(questionDetails, response);  // questionId / optionalFeedback to response map
    if (this.ratingMap !== undefined && this.ratingMap !== null && this.ratingMap !== '' && this.ratingMap.size > 0) {
      if(this.ratingMap.has(data)){
        this.isSubmitDisabled = false;
      }
    }

  }

  openFeedbackPopup() {
    this.isModalOpen = true;
  }

  closeFeedbackPopup() {
    this.isModalOpen = false;
    this.ratingMap.clear();
    this.isSubmitDisabled = true;
    //sessionStorage.setItem('Feedback', 'PoppedUp');
  }


  submitAction() {
    var questionRating = [];
    var recordDetails;
    var surveyMapDetails = {};
    if (this.ratingMap !== undefined && this.ratingMap !== null && this.ratingMap !== '' && this.ratingMap.size > 0) {
      for (const [key, value] of this.ratingMap.entries()) {
        recordDetails = key != 'OptionalFeedback' ? key : '';
        questionRating.push({
          'questionId': recordDetails,
          'rating': value
        });
        surveyMapDetails.pageRef = JSON.stringify(this.surveyLog);
        surveyMapDetails.SurveyDetailsWrapperList = questionRating;
        console.log('questionRating->', questionRating);
        //sessionStorage.setItem('Feedback', 'PoppedUp');
      }
      submitScoreAction({ surveyMap: surveyMapDetails })
        .then(result => {

          if (result != null && result != undefined) {
            this.showToastMessage(Core_MDF_SuccessToastTitle, Core_MDF_Feedback_Success_Msg, 'success', 'sticky');
            this.closeFeedbackPopup();
          }
        })
        .catch(error => {
          this.showToastMessage('Error', APPLICATION_ERROR, 'error', 'sticky');
        });
    }
  }

  showToastMessage(title, message, variant, mode) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
      })
    );
  }


}