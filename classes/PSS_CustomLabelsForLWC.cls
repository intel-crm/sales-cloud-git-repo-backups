/*******************************************************************************************************************************************************************************************************
* Class Name  : PSS_CustomLabelsForLWC
* Description : Stores methods to fetch the custom labels for GeTM
* Version     : 1.0 
* Created Date: 17-09-2020
* Modification Log :
* Created By  : Infosys Team (Infosys)
********************************************************************************************************************************************************************************************************/
//IPA2.0: US-TWC729-7976
@isTest 
public without sharing class PSS_CustomLabelsForLWC {
 
    /**
    * @description Method to fetch all the label values for solution detail page.
    * @param None
    * @param  None
    * @return cusLabels
    **/
    /*@AuraEnabled
    public static Map<String, String> customLabelsForSolDetailPage(){
        Map<String, String> cusLabels= new Map<String, String>();
        cusLabels.put('messageHeading',System.Label.PSS_MessageBox_Heading);
        cusLabels.put('messageHelpText',System.Label.PSS_MessageText);
        cusLabels.put('draftStatusLabel',System.Label.PSS_Draft_SolutionDetail_BannerMessage);
        cusLabels.put('updateLabel',System.Label.PSS_UpdateRequired_SolutionDetail_BannerMessage);
        cusLabels.put('rejectedLabel',System.Label.PSS_Rejected_SolutionDetail_BannerMessage);
        cusLabels.put('approvedLabel',System.Label.PSS_Approved_SolutionDetail_BannerMessage);
        cusLabels.put('adminLabel',System.Label.PSS_AdminReview_SolutionDetail_BannerMessage);
        cusLabels.put('cancelLabel',System.Label.PSS_Cancel_SolutionDetail_BannerMessage);
        cusLabels.put('onholdLabel',System.Label.PSS_OnHold_SolutionDetail_BannerMessage);
        cusLabels.put('reviewLabel',System.Label.PSS_ReviewScheduled_SolutionDetail_BannerMessage);
        cusLabels.put('submitterDetailsLabel',System.Label.PSS_Submitter_Details);
        cusLabels.put('solutionDetailsLabel',System.Label.PSS_Solution_Details);
        cusLabels.put('solutionUrlLabel',System.Label.PSS_Solution_URL);
        cusLabels.put('messageLabel',System.Label.PSS_Message_About_Your_Solution);
        cusLabels.put('editSolutionLabel',System.Label.PSS_Edit_Solution);
        cusLabels.put('addContactsLabel',System.Label.PSS_Add_Contacts);
        cusLabels.put('draftOffering',System.Label.PSS_Create_Draft_Offering);
        cusLabels.put('recreateButtonLabel',System.Label.PSS_ReCreate_Offering_Button);
        cusLabels.put('warningLabel',System.Label.PMP_Create_Offering_Form_Warning_Heading);
        cusLabels.put('partnerValidationLabel',System.Label.PSS_Conversion_MPI_Record_Validation_Error);
        cusLabels.put('successLabel',System.Label.PMP_Success);
        cusLabels.put('offeringCreationSuccessLabel',System.Label.PSS_Offering_Creation_Success);
        cusLabels.put('benefitValidationTitleLabel',System.Label.PSS_Select_Benefit_Validation_Toast_Title);
        cusLabels.put('benefitValidationMessageLabel',System.Label.PSS_Select_Benefit_Validation_Toast_Message);
        cusLabels.put('helpText',System.Label.PSS_AddContacts_HelpText);
        
        cusLabels.put('submittedByLabel',  System.Label.PSS_Submitted_By);
		cusLabels.put('submittedOnLabel',  System.Label.PSS_Submitted_On);
		cusLabels.put('statusLabel',  System.Label.PSS_Status);
		cusLabels.put('cancelLabel',  System.Label.PSS_Cancel_Reason);
		cusLabels.put('scoreLabel',  System.Label.PSS_Consolidated_Score);
		cusLabels.put('programsLabel',  System.Label.PSS_Programs_Applicable);
		cusLabels.put('systemBenefitLabel',  System.Label.PSS_System_Suggested_Benefit_Level);
		cusLabels.put('adminBenefitLabel',  System.Label.PSS_Admin_Suggested_Benefit_Level);
		cusLabels.put('followUpLabel',  System.Label.PSS_Follow_Up_Date);
		cusLabels.put('reviewLabel',  System.Label.PSS_Review_Scheduled_Date);
		cusLabels.put('onholdLabel',  System.Label.PSS_On_Hold_Time);
		cusLabels.put('updateTimeLabel',  System.Label.PSS_Update_Required_Time);
		cusLabels.put('daysLabel',  System.Label.PSS_Days);
		cusLabels.put('hoursLabel',  System.Label.PSS_Hours);
		cusLabels.put('minsLabel',  System.Label.PSS_Mins);
		cusLabels.put('viewOfferingLabel',  System.Label.PMP_View_Offering);
		cusLabels.put('conversionLogLabel',  System.Label.PSS_Conversion_Admin_Log_Details);
		cusLabels.put('solutionSharedWith',  System.Label.PSS_Solution_Shared_With);
		cusLabels.put('viewSharedContactsLabel',  System.Label.PSS_View_Shared_Contacts);
		cusLabels.put('submitterEmail',  System.Label.PSS_Solution_SubmitterEmail);
		cusLabels.put('partnerName',  System.Label.PSS_Solution_PartnerName);
		cusLabels.put('forecastRevenue',  System.Label.PSS_Forecast_Revenue);
		cusLabels.put('partnerRole',  System.Label.PSS_Partner_Role);
		cusLabels.put('accountName',  System.Label.PSS_Account_Name);
		cusLabels.put('country',  System.Label.PSS_Country);
		cusLabels.put('region',  System.Label.PSS_Region);
		cusLabels.put('approvedDate',  System.Label.PSS_Approved_Date);
		cusLabels.put('viewActivationCallDetails',  System.Label.PSS_View_Activation_Call_Details);
		cusLabels.put('activationDetails',  System.Label.PSS_Solution_Activation_Call);

        //Custom Labels for Activation Call
        cusLabels.put('activationCallStatusLabel',  System.Label.PSS_Activation_Status);
		cusLabels.put('activationCallDateLabel',  System.Label.PSS_Activation_Call_Date);
		cusLabels.put('activationCallDetails',  System.Label.PSS_Activation_Call_Details);
		//cusLabels.put('activationCallComments',  System.Label.PSS_Activation_Call_Comments);
		cusLabels.put('ActivationToastTitle',  System.Label.PSS_ActivationToastTitle);
		cusLabels.put('ActivationToastMessage',  System.Label.PSS_ActivationToastMessage);
        
        //log the custom label issue into custom object Core_Log_Entry__c
        logCustomLabelIssue('PSS_CustomLabelsForLWC-customLabelsForSolDetailPage');
        
        return cusLabels;
    }*/
    
        /**
    * @description Method to fetch all the label values for solution list view page
    * @param None
    * @return cusLabels
    **/
    /*@AuraEnabled
    public static Map<String, String> customLabelsForSolListViewPage(){
        Map<String, String> cusLabels= new Map<String, String>();
        cusLabels.put('submitButtonLabel',System.Label.PSS_Submit_Solution);
        
        //log the custom label issue into custom object Core_Log_Entry__c
        logCustomLabelIssue('PSS_CustomLabelsForLWC-customLabelsForSolListViewPage');
        return cusLabels;
    }*/
    
    
    
   /**
    * @description Method to fetch all the label values for partner selection model
    * @param None
    * @return cusLabels
    **/
    /*@AuraEnabled
    public static Map<String, String> customLabelsForParnerSelectionModel(){
        Map<String, String> cusLabels= new Map<String, String>();
        cusLabels.put('ipamURL',System.Label.PMP_LeadGen_Submit);
        cusLabels.put('submitLabel',System.Label.PSS_Solution_URL);
        cusLabels.put('cancelLabel',System.Label.PMP_Cancel);
        cusLabels.put('partnerName',System.Label.PMP_Partner_Name);
        cusLabels.put('partnerNameRequired',System.Label.PMP_Edit_Storefront_Partner_Name_Error);
        cusLabels.put('partnerDetails',System.Label.PSS_Partner_Details);
        cusLabels.put('chooseOneLabel',System.Label.PMP_LeadGen_ChooseOne);
        
        cusLabels.put('contactNameLabel',  System.Label.PSS_ContactName_PartnerModal);
		cusLabels.put('contactRequiredLabel',  System.Label.PSS_ContactRequiredLabel_PartnerModal);
        //log the custom label issue into custom object Core_Log_Entry__c
        logCustomLabelIssue('PSS_CustomLabelsForLWC-customLabelsForParnerSelectionModel');
        return cusLabels;
    }*/
    
    /**
    * @description Method to log the custom label issue
    * @param Origin
    * @return void
    **/
    /*public static void logCustomLabelIssue(String Origin){
        //creating  the log entry when custom labels failed in the client side
        Map<String, String> exceptionMap = new Map<String, String>();
        exceptionMap.put('Core_Details__c', 'Salesforce labels failed on the client side, so backend is sending the labels');
        exceptionMap.put('Core_Message__c', 'Custom Labels are not properly loading in client side');
        exceptionMap.put('Core_Origin__c', Origin);
        exceptionMap.put('Core_Project__c','PSS_CustomLabel_Issue');
        exceptionMap.put('Core_Scope__c','CustomLabelsFailed');
        exceptionMap.put('Core_Severity__c', 'Critical');
        PMP_UTility.createLogEntry(exceptionMap); // insert the log to check if the custom label issue occured.
    }*/
    
}