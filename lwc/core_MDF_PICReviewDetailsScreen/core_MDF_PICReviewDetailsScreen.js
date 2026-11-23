/****************************************************************************************************************************************
 * Component Name  : core_MDF_PICReviewDetailsScreen
 * Version     : 1.0
 * Created Date: 12-07-2022
 * Modification Log :
 * Developer                     Date                          Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture – Sandesh H        18/07/2022                    Create to display PIC Review Issues on Detail Screen.
 *****************************************************************************************************************************************/

import { LightningElement, wire, api } from "lwc";
import getPICResults from "@salesforce/apex/Core_MDF_PICReviewDetails_controller.getPICResults";
import getPICReviewLocalizedFieldAPIName from "@salesforce/apex/Core_MDF_PICReviewDetails_controller.getPICReviewLocalizedFieldAPIName";
import picReviewDetail from "@salesforce/label/c.Core_MDF_PICReviewDetail";
import loadingLabel from "@salesforce/label/c.Core_MDF_Loading";
import picIssues from "@salesforce/label/c.Core_MDF_PIC_Issues";
import picFilesAffected from "@salesforce/label/c.Core_MDF_PIC_Files_Affected";
import picChecks from "@salesforce/label/c.Core_MDF_PIC_Checks";
import reviewDate from "@salesforce/label/c.Core_MDF_PIC_Review_Date";
import picStatus from "@salesforce/label/c.Core_MDF_PIC_Status";
import picReviewedby from "@salesforce/label/c.Core_MDF_PIC_Reviewed_By";
import picReviewLabel from "@salesforce/label/c.Core_MDF_PIC_Review";
import applicationError from "@salesforce/label/c.Core_MDF_ApplicationErrorMessage";
import { getRecord } from "lightning/uiRecordApi";
import hasCCRMOrPICReviewerAccess from "@salesforce/apex/Core_MDF_PICReviewDetails_controller.hasCCRMOrPICReviewerAccess";
import userLanguage from "@salesforce/schema/User.LanguageLocaleKey";
import user_ID from "@salesforce/user/Id";
import user_Type from "@salesforce/schema/User.UserType";

export default class Core_MDF_PICReviewDetailsScreen extends LightningElement {
  @api recordId; //Hold claim record Id
  localizedFieldName; //To hold localized Field Name
  picReviewColumns; //To hold PIC Review Columns data
  label = {
    picReviewDetail,
    loadingLabel,
    reviewDate,
    picStatus,
    picReviewedby,
    picIssues,
    picFilesAffected,
    picChecks,
    picReviewLabel,
    applicationError
  };
  displayPICReviewAccordion; //Flag to display PIC Review Detail List
  displayError = false; //Flag to display Error
  displayPICReview = false; //Flag to display PIC screen
  isInternalUser = false; //Flag for Internal Users
  showSpinner = false; //Flag for showing Spinner
  countOfPICReview = 0; //To display count on header
  userLanguageLocaleKey; //To hold user local language key
  loggedInUserType; //To hold logged in User Type
  isPICReviewerCCRM = false;

  //Method to get User Id,User Type and User Language Key
  @wire(getRecord, {
    recordId: user_ID, //small
    fields: [userLanguage, user_Type]
  })
  wireUserDetails({ error, data }) {
    if (data) {
      this.userLanguageLocaleKey = data.fields.LanguageLocaleKey.value;
      this.loggedInUserType = data.fields.UserType.value;
      //Check if user is Internal or External
      //this.isInternalUser =
        //this.loggedInUserType == "PowerPartner" ? false : true;
        if(this.loggedInUserType=="Standard"){
          this.isInternalUser = true;
          this.getUserAccess();
        }else{
          this.isInternalUser = false;
          this.isPICReviewerCCRM = false;
        }
    } else if (error) {
      //Display error Message
      this.displayServerExceptionMessage();
      console.log(
        "Error in wireUserDetails : core_MDF_PICReviewDetailsScreen",
        error
      );
    }
  }

  async getUserAccess(){
   await hasCCRMOrPICReviewerAccess()
    .then(response => {
      this.isPICReviewerCCRM = response;
    }).catch((error) => {
      //Display Error Message
      console.log(
        "Error in fetchAllPICReviewDetails : core_MDF_PICReviewDetailsScreen",
        error
      );
      this.displayServerExceptionMessage();
    });
  }
  
  //Method to check Interal and External Users
  @wire(getPICReviewLocalizedFieldAPIName, {
    userLangKey: "$userLanguageLocaleKey"
  })
  wireMetadata(response) {
    const data = response.data; //store Language Field
    const error = response.error; //store error
    if (data && data != {}) {
      //check if user is Internal
      if (this.isInternalUser) {
        this.localizedFieldName = "Core_MDF_Issue_English_txt__c";
        //Display column to internal user
        this.picReviewColumns = [
          {
            label: this.label.picChecks,
            fieldName: "Core_MDF_QuestionEnglish_txt__c",
            type: "text"
          },
          {
            label: this.label.picIssues,
            fieldName: this.localizedFieldName,
            type: "text"
          },

          {
            label: this.label.picFilesAffected,
            fieldName: "Core_MDF_FilesAffected_txt__c",
            type: "text"
          }
        ];
      } else {
        this.localizedFieldName = data;
        //Display column to external user
        this.picReviewColumns = [
          {
            label: this.label.picIssues,
            fieldName: this.localizedFieldName,
            type: "text"
          },
          {
            label: this.label.picFilesAffected,
            fieldName: "Core_MDF_FilesAffected_txt__c",
            type: "text"
          }
        ];
      }
      this.fetchAllPICReviewDetails();
    } else if (error) {
      //Display Error Message
      console.log(
        "Error in wireMetadata : core_MDF_PICReviewDetailsScreen",
        error
      );
      this.displayServerExceptionMessage();
    }
  }

  //Method to Display PIC Review Cycles on claim screen
  fetchAllPICReviewDetails() {
    let picReviewDetailsData = []; //To hold PIC Review Details to display
    console.log("User Type-> " + this.isPICReviewerCCRM);
    let picReviewWrapper = {
      claimId: this.recordId,
      picReviewLocalizedFieldAPIName: this.localizedFieldName,
      isInternalUser: this.isInternalUser,
      isCCRMUserOrPICReviewer: this.isPICReviewerCCRM,
    }
    console.log('picReviewWrapper',picReviewWrapper);
    getPICResults({
      picReviewWrapper: picReviewWrapper
    })
      .then((picDetails) => {
        console.log("picdetails", picDetails, typeof Object);
        if (Object.keys(picDetails).length > 0) {
          this.showSpinner = true;
          this.displayPICReviewAccordion = true;
          this.displayPICReview = true;
          this.countOfPICReview = Object.keys(picDetails).length;
          for (const [reviewId, reviewResults] of Object.entries(picDetails)) {
            let picReviewResultDetails = reviewResults[0];
            let picStatus =
              picReviewResultDetails.Core_MDF_PIC_Review_id__r
                .Core_MDF_Review_Status_nm__c;
            let picCycleNumber =
              picReviewResultDetails.Core_MDF_PIC_Review_id__r
                .Core_MDF_CycleNumber_nbr__c;
            let picReviewedBy =
              this.isPICReviewerCCRM == true
                ? picReviewResultDetails.Core_MDF_PIC_Review_id__r
                    .Core_MDF_ReviewedBy_id__r.Name
                : null;
            console.log("picReviewedBy" + picReviewedBy);
            let picReviewedDate =
              picReviewResultDetails.Core_MDF_PIC_Review_id__r.formattedDate;
            picReviewDetailsData.push({
              picReviewDetail: picStatus == "Completed" ? null : reviewResults,
              isPICCompleted: picStatus == "Completed" ? true : false,
              picCycleNumber: picCycleNumber,
              picStatus: picStatus,
              picReviewedBy: picReviewedBy,
              picReviewedDate: picReviewedDate,
              picReviewLabel:
                this.label.picReviewLabel + " - " + picCycleNumber,
              picCSS:
                picStatus == "Completed"
                  ? "picreview-completed"
                  : "picreview-failed",
              picReviewId: reviewId
            });
          }
        } else {
          this.displayPICReviewAccordion = false; //displayPICReviewAccordion
          this.displayPICReview = false;
        }
        console.log("picReviewDetailsData", picReviewDetailsData);
        this.data = picReviewDetailsData;
        this.showSpinner = false;
      })
      .catch((error) => {
        //Display Error Message
        console.log(
          "Error in fetchAllPICReviewDetails : core_MDF_PICReviewDetailsScreen",
          error
        );
        this.displayServerExceptionMessage();
      });
  }

  // Method to Display error Message
  displayServerExceptionMessage() {
    this.displayError = true;
    this.displayPICReview = true;
    this.showSpinner = false;
    this.displayPICReviewAccordion = false;
  }
}