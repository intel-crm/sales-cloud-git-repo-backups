/****************************************************************************************************************************************
* Component Name  : core_MDF_PICReviewDetailsScreen
* Version     : 1.0 
* Created Date: 12-07-2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Sandesh H        12/07/2022                    Create to display PIC Review Issues on Detail Screen.
*****************************************************************************************************************************************/

import { LightningElement, wire, api } from 'lwc';
import getPICResults from '@salesforce/apex/Core_MDF_PICReviewDetails_controller.getPICResults';
import getFieldname from '@salesforce/apex/Core_MDF_PICReviewDetails_controller.getFieldname';
import picReviewDetail from '@salesforce/label/c.Core_MDF_PICReviewDetail';
import loadingLabel from '@salesforce/label/c.Core_MDF_Loading';
import picIssues from '@salesforce/label/c.Core_MDF_PIC_Issues';
import picFilesAffected from '@salesforce/label/c.Core_MDF_PIC_Files_Affected';
import picChecks from '@salesforce/label/c.Core_MDF_PIC_Checks';
import reviewDate from '@salesforce/label/c.Core_MDF_PIC_Review_Date';
import picStatus from '@salesforce/label/c.Core_MDF_PIC_Status';
import picReviewedby from '@salesforce/label/c.Core_MDF_PIC_Reviewed_By';
import picReviewLabel from '@salesforce/label/c.Core_MDF_PIC_Review';
import applicationError from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import { getRecord } from 'lightning/uiRecordApi';

import userLanguage from '@salesforce/schema/User.LanguageLocaleKey';
import USER_ID from '@salesforce/user/Id';
import user_Type from '@salesforce/schema/User.UserType';


export default class Core_MDF_PICReviewDetailsScreen extends LightningElement {

    localizedFieldName ; //To hold localized Field Name
    picReviewColumns; //To hold PIC Review Columns data
    label = { picReviewDetail, loadingLabel, reviewDate, picStatus, picReviewedby, picIssues, picFilesAffected, picChecks, picReviewLabel, applicationError };
    @api recordId; //Hold claim record Id
    hasPICReview; //Flag to display PIC Review Detail List
    hasPICReviewError = false; //Flag to display Error
    hasErrorOrData = false; //Flag to display PIC screen
    isInternalUser = true; //Flag for Internal Users
    showSpinner = false; //Flag for showing Spinner
    countOfPICReview = 0; //To display count on header
    userLanguageLocaleKey; //To hold user local language key
    loggedInUserType; //To hold logged in User Type

    //Method to get User Id,User Type and User Language Key
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [userLanguage, user_Type]
    }) wireUserDetails({ error, data }) {
        if (error) {
            //Display error Message
            this.displayServerExceptionMessage();
            console.log("Error in wireUserDetails : core_MDF_PICReviewDetailsScreen", error);
        }
        else if (data) {
            this.userLanguageLocaleKey = data.fields.LanguageLocaleKey.value;
            this.loggedInUserType = data.fields.UserType.value;
            //check if if user is Internal or  External
            if(this.loggedInUserType == 'PowerPartner'){
                this.isInternalUser = false;
            }else{
                this.isInternalUser = true;
            }
        }
    }


    //Method to check Interal and External Users
    @wire(getFieldname, { userLangKey: '$userLanguageLocaleKey' })
    wireMetadata(response) {
        const data = response.data; //store Language Field
        const error = response.error; //store error
        if (data && data != {}) {
            //check if user is Internal
            if(this.isInternalUser){

                this.localizedFieldName = 'Core_MDF_Issue_English_txt__c';
                //Display column to internal user
                this.picReviewColumns = [
                    {
                        label: this.label.picChecks,
                        fieldName: 'Core_MDF_QuestionEnglish_txt__c',
                        type: 'text',
                    },
                    {
                        label: this.label.picIssues,
                        fieldName: this.localizedFieldName,
                        type: 'text',
                    },

                    {
                        label: this.label.picFilesAffected,
                        fieldName: 'Core_MDF_FilesAffected_txt__c',
                        type: 'text'
                    },
                ];
            }
            else{
                this.localizedFieldName = data;
                //Display column to external user
                this.picReviewColumns = [
                    {
                        label: this.label.picIssues,
                        fieldName: this.localizedFieldName,
                        type: 'text',
                    },
                    {
                        label: this.label.picFilesAffected,
                        fieldName: 'Core_MDF_FilesAffected_txt__c',
                        type: 'text'
                    },
                ];
                
            } 
            this.fetchAllPICReviewDetails();
        }
        else if (error) {
            //Display Error Message
            console.log("Error in wireMetadata : core_MDF_PICReviewDetailsScreen", error);
            this.displayServerExceptionMessage();
        }
    }

    //Method to Display PIC Review Cycles on claim screen
    fetchAllPICReviewDetails() {
        let picReviewDetailsData = []; //To hold PIC Review Details to display
        getPICResults({ claimId: this.recordId, localizedFld: this.localizedFieldName })
            .then(picDetails => {
                console.log('picdetails', picDetails, typeof(Object));
                if(Object.keys(picDetails).length > 0) {
                    this.showSpinner = true;
                    this.hasPICReview = true;
                    this.hasErrorOrData = true;
                    this.countOfPICReview = Object.keys(picDetails).length;
                    for(const [reviewId, reviewResults] of Object.entries(picDetails)) {
                        let picReviewResultDetails = reviewResults[0];
                        let picStatus = picReviewResultDetails.Core_MDF_PIC_Review_id__r.Core_MDF_Review_Status_nm__c;
                        let picCycleNumber = picReviewResultDetails.Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c;
                        let picReviewedBy = picReviewResultDetails.Core_MDF_PIC_Review_id__r.Core_MDF_ReviewedBy_id__r.Name;
                        let picReviewedDate = picReviewResultDetails.Core_MDF_PIC_Review_id__r.formattedDate;
                        picReviewDetailsData.push({
                            picReviewDetail:  picStatus == 'Completed' ? null : reviewResults,
                            isPICCompleted: picStatus == 'Completed' ? true : false,
                            picCycleNumber: picCycleNumber,
                            picStatus: picStatus,
                            picReviewedBy: picReviewedBy,
                            picReviewedDate: picReviewedDate,
                            picReviewLabel: this.label.picReviewLabel + ' - ' + picCycleNumber,
                            picCSS: picStatus == 'Completed' ? 'picreview-completed' : 'picreview-failed',
                            picReviewId: reviewId,
                        });
                    }
                } else {
                    this.hasPICReview = false;
                    this.hasErrorOrData = false;
                }
                console.log('picReviewDetailsData', picReviewDetailsData);
                this.data = picReviewDetailsData;
                this.showSpinner = false;
            })
            .catch(error => {
                //Display Error Message
                console.log("Error in fetchAllPICReviewDetails : core_MDF_PICReviewDetailsScreen", error);
                this.displayServerExceptionMessage();
            });
    }

    // Method to Display error Message 
    displayServerExceptionMessage() {
        this.hasPICReviewError = true;
        this.hasErrorOrData = true;
        this.showSpinner = false;
    }
}