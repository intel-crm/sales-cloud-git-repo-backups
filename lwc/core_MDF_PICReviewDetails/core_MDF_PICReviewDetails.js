/****************************************************************************************************************************************
 * Component Name  : Core_MDF_PICReviewDetails
 * Version     : 1.0
 * Created Date: 12-07-2022
 * Modification Log :
 * Developer                     Date                          Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture – Vinodhini B      24/07/2022                    Create to display PIC Review Issues on Detail Screen.
 *****************************************************************************************************************************************/

import { LightningElement, api } from "lwc";
import getUserAndPICReviewResultDetails from "@salesforce/apex/Core_MDF_PICReviewDetails_controller.getUserAndPICReviewResultDetails";
import getObjectAccess from "@salesforce/apex/Core_MDF_PICReviewDetails_controller.getObjectAccess";
import picReviewDetail from "@salesforce/label/c.Core_MDF_PICReviewDetail";
import loadingLabel from "@salesforce/label/c.Core_MDF_Loading";
import picIssues from "@salesforce/label/c.Core_MDF_PIC_Issues";
import picFilesAffected from "@salesforce/label/c.Core_MDF_PIC_Files_Affected";
import picChecks from "@salesforce/label/c.Core_MDF_PIC_Checks";
import reviewDate from "@salesforce/label/c.Core_MDF_PIC_Review_Date";
import picStatus from "@salesforce/label/c.Core_MDF_PIC_Status";
import picReviewedby from "@salesforce/label/c.Core_MDF_PIC_Reviewed_By";
import internalComments from "@salesforce/label/c.Core_MDF_PICDetails_Internal_Comments";
import picReviewLabel from "@salesforce/label/c.Core_MDF_PIC_Review";
import applicationError from "@salesforce/label/c.Core_MDF_ApplicationErrorMessage";
import completed from "@salesforce/label/c.Core_MDF_PICReview_Status_Completed";
import resubReq from "@salesforce/label/c.Core_MDF_PIC_Review_Resubmission_Required";
import pendingAccManagerClarification from "@salesforce/label/c.Core_MDF_PIC_Review_Pending_Account_Manager_Clarification";
import ipaProgramName from "@salesforce/label/c.Core_MDF_IPA_Program_Name";
import comments from "@salesforce/label/c.Core_MDF_IPA_Comments";
import tactics from "@salesforce/label/c.Core_MDF_Activity_Tactics";
import dash from "@salesforce/label/c.Core_MDF_Dash";

export default class Core_MDF_PICReviewDetails extends LightningElement {
  @api recordId; //Hold claim record Id
  picReviewLocalizedFieldAPIName; //To hold localized Field Name
  picReviewColumns; //To hold PIC Review Columns data
  label = {
    picReviewDetail,
    loadingLabel,
    reviewDate,
    picStatus,
    picReviewedby,
    internalComments,
    picIssues,
    picFilesAffected,
    picChecks,
    picReviewLabel,
    applicationError,
    completed,
    resubReq,
    dash,
    pendingAccManagerClarification,
    ipaProgramName,
    comments, 
    tactics
  };
  displayPICReviewAccordion = false; //Flag to display PIC Review Detail List
  displayError = false; //Flag to display Error
  displayPICReviewContainer = false; //Flag to display PIC screen
  displayPICInternalComments = false; //Flag to display PIC Internal Comments
  isInternalUser = false; //Flag for Internal Users
  showSpinner = false; //Flag for showing Spinner
  countOfPICReview = 0; //To display count on header
  isCCRMUserOrPICReviewer = false // is claim case reviewer/manager/PIC Reviewer
  picReviewResultDetailsData; //holds PIC Review and PIC Review Results data
  picReviewDetails; //holds PIC Review details
  picReviewResultDetails; //holds PIC Review Result details - Issues list
  hasClaimUndergonePICReview = false; //Indicates whether claim has undergone PIC Review or not
  ipaOutcomeBasedClaim = false;
  //Initial load
  connectedCallback() {
    this.checkObjectAccess();
  }

  /*To Check the user with PIC Review and PIC Review Results Object access
  * If User has access, get the additional PIC review and pic review result details
  */
  async checkObjectAccess() {
    this.showSpinner = true;
    await getObjectAccess()
      .then(response => {
        if (response) {
          this.getUserAndPICReviewResultDetails();
        } else {
          this.showSpinner = false;
          this.displayPICReviewContainer = false;
        }
      }).catch(error => {
        this.showSpinner = false;
        this.displayError = true;
        this.displayPICReviewContainer = true;
        console.log('Error in checkObjectAccess : Core_MDF_PICReviewDetails', error);
      })
  }

  //To fetch the logged in user /PIC review /PIC Review Results details for a claim
  getUserAndPICReviewResultDetails() {
    getUserAndPICReviewResultDetails({ claimId: this.recordId })
      .then(response => {
        //wrapper object will be returned as response
        let userAndPICReviewDetails = response;
        if (Object.keys(userAndPICReviewDetails).length > 0) {
          this.picReviewLocalizedFieldAPIName = userAndPICReviewDetails.picReviewLocalizedFieldAPIName;
          let userDetails = userAndPICReviewDetails.userDetails;
          this.isInternalUser = userDetails.isInternalUser;
          this.picReviewDetails = userAndPICReviewDetails.picReviewDetails;
          this.picReviewResultdetails = userAndPICReviewDetails.picReviewResultDetails;
          this.isCCRMUserOrPICReviewer = userAndPICReviewDetails.isCCRMUserOrPICReviewer;
          this.hasClaimUndergonePICReview = userAndPICReviewDetails.hasClaimUndergonePICReview;
          this.ipaOutcomeBasedClaim = userAndPICReviewDetails.ipaOutcomeBasedClaim;
          //If - If the claim has undergone PIC Review, then display the PIC Review Section under claim's related list
          //else - hide the PIC Review Section from claim's related list
          if (this.hasClaimUndergonePICReview) {
            this.countOfPICReview = this.picReviewDetails.length;
            this.displayPICReviewContainer = true;
            this.displayPICReviewAccordion = true;
            this.preparePICReviewResultData(this.picReviewDetails, this.picReviewResultdetails);
          } else {
            this.showSpinner = false;
            this.displayPICReviewContainer = false;
          }
        }
      }).catch(error => {
        this.showSpinner = false;
        this.displayError = true;
        this.displayPICReviewContainer = true;
        console.log('Error in getUserAndPICReviewResultDetails : Core_MDF_PICReviewDetails', error);
      })
  }
  decodeHTMLEntities(text){
    const parser = new DOMParser();
    const decodedString = parser.parseFromString(text, 'text/html').documentElement.textContent;
    return decodedString;
  }
  // Utility function to replace <br> with \n in a given string
  replaceBrWithNewline(queIssueTxt){
    return typeof queIssueTxt === 'string' ? queIssueTxt.replaceAll('<br>', '\n').trim() : queIssueTxt;
  };

// Function to process each object in the array
  processPicRRDataArray(picRRDataArray){
    return picRRDataArray.map(picRR => {
      // Iterate over all properties of picRR
      if (picRR !== {} && Object.keys(picRR).length > 0) {
        Object.keys(picRR).forEach(key => {
          if(key.includes('Issue') || key.includes('QuestionEnglish')){
            picRR[key] = this.replaceBrWithNewline(picRR[key]);
            picRR[key] = this.decodeHTMLEntities(picRR[key]);
          }
        });
        return picRR;
      }
    });
  };
  //To Create an array of object with both PIC Review and PIC Review details to render the same in UI
  preparePICReviewResultData(picReviewDetails, picReviewResultdetails) {
    let picReviewResultdetailsArray = []
    let picReviewResultDetailsLocalData = [];
    //picReviewResultdetails - Child Object(returned as object from apex)
    if (picReviewResultdetails !== {} && Object.keys(picReviewResultdetails).length > 0) {
      //convert object to array of objects
      Object.keys(picReviewResultdetails).forEach(key => {
        let picRRDataArray = picReviewResultdetails[key];
        if(picRRDataArray.length > 0) {
          picRRDataArray = this.processPicRRDataArray(picRRDataArray);
        }
        picReviewResultdetailsArray.push({ id: key, picRRDetails: picRRDataArray })
      });
      //column Assignment
      this.assignColumns(this.isInternalUser, this.picReviewLocalizedFieldAPIName);
    } else {
      this.picReviewColumns = [];
    }
    //Pepare PIC Review and PIC review result details by iterating PIC Review(Parent Object) - picReviewResultDetailsLocalData(Array of Objects)
    picReviewDetails.forEach(picReview => {
      console.log('picReview', picReview);
      let picReviewStatus = picReview.Core_MDF_Review_Status_nm__c;
      let picReviewResultObject = {};
      this.displayPICInternalComments = picReview.Core_MDF_InternalComments_txt__c ? true : false;
      console.log("displayPICInternalComments-> "+this.displayPICInternalComments);
      //If - PIC Review status is failed, Else - PIC review status is completed(for completed pic review, disable the click of accordion)
      if (picReviewStatus !== this.label.completed) {
        let picReviewResult;
        /**If - PIC Review Results(child Object) is available for the PIC review(Parent Object), then match the child and parent
         * from picReviewResultdetailsArray and assign picReviewResultObject.picReviewResults with picRRDetails 
         * from picReviewResultdetailsArray(this is to render the datatable for the failed ones with PIC review results).
         * Else - PIC Review Results(child object) is not available for the PIC Review(Parent Object).In this Scenario, disable the
         * click of PIC Review accordion as datatable will not be displayed for such PIC Review records.
         * Example for Else - claims created before PIC review process will have only PIC review(Parent Object).
         */
        if (picReviewResultdetailsArray.length > 0) {
          picReviewResult = picReviewResultdetailsArray.find(picRR => picRR.id === picReview.Id);
          picReviewResultObject.picReviewResults = this.sortAndFilterQuestions(picReviewResult.picRRDetails);
          picReviewResultObject.isPICCompleted = false;
        } else {
          if(!this.displayPICInternalComments){
            picReviewResultObject.disableClickOfAccordionCSS = 'picreview-disableclick';
            picReviewResultObject.isPICCompleted = true;
          }else{
            picReviewResultObject.isPICCompleted = true;
          }
        }
      } else {
        if(!this.displayPICInternalComments){
          picReviewResultObject.isPICCompleted = true;
          picReviewResultObject.disableClickOfAccordionCSS = 'picreview-disableclick';
        }else{
          picReviewResultObject.isPICCompleted = true;
        }
      }
      
      picReviewResultObject.picReviewStatus =  picReview.Core_MDF_Review_Status_nm__c == this.label.completed ? this.isInternalUser ? picReviewStatus : picReview.LocalizedPICReviewStatus : (this.ipaOutcomeBasedClaim ? this.label.pendingAccManagerClarification : resubReq);
      picReviewResultObject.picReviewedBy = this.isCCRMUserOrPICReviewer ? picReview.Core_MDF_ReviewedBy_id__r.Name : null;
      picReviewResultObject.internalComments = this.isCCRMUserOrPICReviewer ? picReview.Core_MDF_InternalComments_txt__c : null;
      picReviewResultObject.picReviewedDate = picReview.formattedDate;
      picReviewResultObject.picReviewId = picReview.Id;
      picReviewResultObject.hasInternalComments = this.displayPICInternalComments;
      picReviewResultObject.picCSS = picReviewStatus === this.label.completed ? 'picreview-completed' : 'picreview-failed';
      picReviewResultObject.picReviewCycleNumber = picReview.Core_MDF_CycleNumber_nbr__c;
      picReviewResultObject.picReviewLabel = this.label.picReviewLabel + ' - ' + picReview.Core_MDF_CycleNumber_nbr__c;
      picReviewResultDetailsLocalData.push(picReviewResultObject);
    });
    this.picReviewResultDetailsData = picReviewResultDetailsLocalData;
    this.showSpinner = false;
  }

  //To show/hide the columns based on Internal/external user
  assignColumns(isInternalUser, localizedFieldName) {
    console.log('localizedFileName', localizedFieldName);
    //check if user is Internal
    if (isInternalUser) {
      let localizedFieldNameInternal = "Core_MDF_Issue_English_txt__c";
      //Display column to internal user
      this.picReviewColumns = [
        {
          label: this.label.picChecks,
          fieldName: "Core_MDF_QuestionEnglish_txt__c",
          type: "text"
        },
        {
          label: this.label.picIssues,
          fieldName: localizedFieldNameInternal,
          type: "text"
        }
        // commenting as tactics needs to be added before filesAttached columns
        /*{
          label: this.label.picFilesAffected,
          fieldName: "Core_MDF_FilesAffected_txt__c",
          type: "text"
        }*/
      ];
    } else {
      let localizedFieldNameExternal = localizedFieldName;
      //Display column to external user
      this.picReviewColumns = [
        {
          label: this.label.picIssues,
          fieldName: localizedFieldNameExternal,
          type: "text"
        }
        // commenting as tactics needs to be added before filesAttached columns
        /*{
          label: this.label.picFilesAffected,
          fieldName: "Core_MDF_FilesAffected_txt__c",
          type: "text"
        }*/
      ];
    }
    if (this.ipaOutcomeBasedClaim) {
      this.picReviewColumns.push(
        {
          label: this.label.tactics,
          fieldName: "Core_MDF_Tactic_txt__c",
          type: "text"
        }
      );
    }

    // moved after tactics column
    this.picReviewColumns.push(
      {
        label: this.label.picFilesAffected,
        fieldName: "Core_MDF_FilesAffected_txt__c",
        type: "text"
      }
    );

    if(this.ipaOutcomeBasedClaim){
      this.picReviewColumns.push(
        {
          label: this.label.comments,
          fieldName: "Core_MDF_Comment_txt__c",
          type: "text"
        });
    }
  }

  // This method is filtering question to display in POP Screening on claim details page UI,
  // it will filter parent question if no child questions exist else exclude parent question and add all the respective child questions
  sortAndFilterQuestions(allQuestions) {
    let parentQuesIdToParentQuesMap = new Map();
    let parentToChildQuesMap = new Map();
    let sortedQuestions = [];

    // Separate parent and child records and add custom CSS
    allQuestions.forEach(record => {
      if (record["Core_MDF_Question_id__r"] != null && record["Core_MDF_Question_id__r"]["Core_MDF_Sub_Question_Ind__c"] != null && record["Core_MDF_Question_id__r"]["Core_MDF_Sub_Question_Ind__c"] == false) {
        parentQuesIdToParentQuesMap.set(record.Core_MDF_Question_id__r.Id, record);
      } else if (record["Core_MDF_Question_id__r"] != null && record["Core_MDF_Question_id__r"]["Core_MDF_Sub_Question_Ind__c"] != null && record["Core_MDF_Question_id__r"]["Core_MDF_Sub_Question_Ind__c"] == true) {
        if (!parentToChildQuesMap.has(record.Core_MDF_Question_id__r.Core_MDF_Parent_Question__c)) {
          parentToChildQuesMap.set(record.Core_MDF_Question_id__r.Core_MDF_Parent_Question__c, []);
        }
        parentToChildQuesMap.get(record.Core_MDF_Question_id__r.Core_MDF_Parent_Question__c).push(record);
      }
    });

    // Add parent question if no child question exist else exclude parent question and add all child questions
    parentQuesIdToParentQuesMap.forEach((parent, parentId) => {
      const children = parentToChildQuesMap.get(parentId);

      if (children && children.length > 0) {
        // If there are child questions, add them only
        sortedQuestions = [...sortedQuestions, ...children];
      } else {
        // If no child questions, add the parent question
        sortedQuestions.push(parent);
      }
    });
    return sortedQuestions;
  }
  
}