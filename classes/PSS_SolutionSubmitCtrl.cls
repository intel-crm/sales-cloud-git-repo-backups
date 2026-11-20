/*************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionSubmitCtrl
* Version     : 1.0 
* Created Date: 6/16/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Swathi              M-01    : Original version       4/06/2021                         Utility class for commonly used methods
* Ajay Gat            M-02    : Verison 2              4/05/2022                         Added getSolutionDataAura and statusChangeOnSubmitAura method
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
global with sharing class PSS_SolutionSubmitCtrl {
    
    // public String recordId{get;set;}
    // public static boolean isRejected{get;set;}
    // public static String createRecordId{get;set;}
    // public static String logicalId{get;set;}
    // public static String companyId{get;set;}
    // public static Boolean showAddConFlag { get; set; }
    // public static string surveyResultId{get;set;}
    
    // //Constructor to get record id from the url
    // public pSS_SolutionSubmitCtrl(){
    //     DateTime start = System.Now();
    //     recordId=ApexPages.CurrentPage().getParameters().get('PSS_company_Id__c');

    //     /**** To get the record id from static metadata PSS_Static_Data ****/
    //     // createRecordId=PMP_Utility.getValue('PSS_Survey_RecordId');
    //     // createRecordId=PMP_Utility.getValue(str1);
    //     /**** To Get the logical Id from Static Metadata PSS_Static_Data ****/
    //     // logicalId=PMP_Utility.getValue('PSS_Survey_LogicalId');
    //     // logicalId=PMP_Utility.getValue(str2);
    //     /**** To Get the Company Information field from Static Metadata PSS_Static_Data ****/
    //     companyId = companyId;
    //     showAddConFlag = false;
    //     surveyResultId='';
        
    // }
    
    // //This method is used for visualForce page PSS_SolutionSubmit.page
    // //After aura integration is live this can be removed.
    // public static void addContactBtnVisibility() {
    //     String recordId = Apexpages.currentPage().getParameters().get('recordId');
    //     showAddConFlag = false;
    //     if(String.isBlank(recordId)) {
    //         showAddConFlag = true;
    //     } else {
    //         List<ArdiraSurvey__Survey_Result__c> surveyResult = [SELECT Id, PSS_Partner_Solution_Lifecycle_Status_Nm__c FROM ArdiraSurvey__Survey_Result__c WHERE Id = :recordId];
    //         if(surveyResult.size() > 0 && (surveyResult[0].PSS_Partner_Solution_Lifecycle_Status_Nm__c == 'Draft' || surveyResult[0].PSS_Partner_Solution_Lifecycle_Status_Nm__c == 'Update Required')) {
    //             showAddConFlag = true;
    //         }
    //     }
        
    // }
    
    // /**
    // * @description Method to update solution data
    // * @param String recordId,String buttonLabel 
    // * @return void
    // **/
    // @AuraEnabled
    // global static void statusChangeOnSubmitAura(String recordId,String buttonLabel) {
    //     try {
    //         ArdiraSurvey__Survey_Result__c surveyResult = [select id,PSS_Partner_Solution_Lifecycle_Status_Nm__c,
    //                                                         PSS_Solution_Terminated_Status_Nm__c,PSS_Auto_Rejected_Ind__c,PSS_Rejection_Reason_Txt__c,ArdiraSurvey__End_State__c,
    //                                                         PSS_Programs_Applicable_Nm__c,PSS_Strategic_Attributes_Nm__c,PSS_Solution_Category_Nm__c,
    //                                                         PSS_Solution_Revenue_Projection__c
    //                                                         from ArdiraSurvey__Survey_Result__c where Id = :recordId];
                    
    //         // as per life cycle status we can't change review scheduled to admin review
    //         if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c != PSS_StaticConstants.REVIEW_SCHEDULED) {
    //             surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.ADMIN_REVIEW;
    //         }
            
    //         surveyResult.PSS_Solution_Terminated_Status_Nm__c = '';
    //         surveyResult.ArdiraSurvey__Status__c = PSS_StaticConstants.IN_PROGRESS;

    //         if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.REVIEW_SCHEDULED || 
    //             surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.ADMIN_REVIEW ||
    //             surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_ONHOLD_STATUS) {
    //                 surveyResult.ArdiraSurvey__End_State__c = false;
    //             }
            
    //         //If Next button is selected
    //         if(buttonLabel == PSS_StaticConstants.NEXT) {    
    //             surveyResult.PSS_Solution_Terminated_Status_Nm__c = PSS_StaticConstants.TCS;
    //         }
    //         //If Quit button is selected
    //         else if(buttonLabel == PSS_StaticConstants.QUIT) {
    //             surveyResult.PSS_Solution_Terminated_Status_Nm__c = PSS_StaticConstants.QUIT;
    //             //Draft to Rejected status -this will happen only through quit button
    //             surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.SOLUTION_REJECTED_STATUS; 
    //             //Auto reject solution since user chose to Quit
    //             surveyResult.PSS_Rejection_Reason_Txt__c = 'Auto Rejected';
    //             surveyResult.PSS_Auto_Rejected_Ind__c = true;
                
    //         }
            
    //         //bug fix for Vision and Workload Consolidation is auto selected in Strategic Attributes when Partner user resubmits the Solution 
    //         //By changing the path where Q no 51 and forecast question is not available
    //         Boolean isStrategicUpdated = false;
    //         if(String.isNotBlank(surveyResult.PSS_Programs_Applicable_Nm__c)&&
    //             !surveyResult.PSS_Programs_Applicable_Nm__c.contains(PSS_StaticConstants.MRS) &&
    //             !surveyResult.PSS_Programs_Applicable_Nm__c.contains(PSS_StaticConstants.RRK) &&
    //             String.isNotBlank(surveyResult.PSS_Strategic_Attributes_Nm__c) && surveyResult.PSS_Strategic_Attributes_Nm__c != Null) {
    //                 if(surveyResult.PSS_Strategic_Attributes_Nm__c.contains(PSS_StaticConstants.WORKLOAD_CONSOLIDATION)) {
    //                     surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove(PSS_StaticConstants.WORKLOAD_CONSOLIDATION+';');
    //                     surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove(PSS_StaticConstants.WORKLOAD_CONSOLIDATION);
    //                     isStrategicUpdated= true;
    //                 }
    //                 if(surveyResult.PSS_Strategic_Attributes_Nm__c.contains('Vision')) {
    //                     surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove('Vision;');
    //                     surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove('Vision');
    //                     isStrategicUpdated= true;
    //                 }
    //             } 
    //             else if(String.isBlank(surveyResult.PSS_Programs_Applicable_Nm__c) && surveyResult.PSS_Strategic_Attributes_Nm__c != Null) {
    //                 surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove(PSS_StaticConstants.WORKLOAD_CONSOLIDATION+';');
    //                 surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove(PSS_StaticConstants.WORKLOAD_CONSOLIDATION);
                    
    //                 surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove('Vision;');
    //                 surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove('Vision');
    //                 isStrategicUpdated= true;
    //             }
            
    //         update surveyResult;
            
    //         if(isStrategicUpdated) {
    //             map<id, ArdiraSurvey__Survey_Result__c> surveyResultMap= new map<id, ArdiraSurvey__Survey_Result__c>();
    //             List<ArdiraSurvey__Survey_Result__c> resultListToUpdate = new List<ArdiraSurvey__Survey_Result__c>();
    //             surveyResultMap.put(surveyResult.id, surveyResult);
    //             resultListToUpdate = PSS_ImpactPathScoring_Utility.calculateImpactPathScore(surveyResultMap);
    //             resultListToUpdate = PSS_BenefitAssignmentTriggerHelper.convertSolutionToOffering(resultListToUpdate);
    //             update resultListToUpdate;
    //         }
    //     }
    //     catch(Exception e) {
    //         PMP_Utility.logError(e,'statusChangeOnSubmitAura'); 
    //     }
    // }

    // //Unused code : This method is used for visualForce page PSS_SolutionSubmit.page
    // //After aura integration is live this can be removed.
    // @RemoteAction
    // global static void statusChangeOnSubmit(String recordId,String buttonLabel) {
        
    //     ArdiraSurvey__Survey_Result__c surveyResult=[select id,PSS_Partner_Solution_Lifecycle_Status_Nm__c,
    //                                                  PSS_Solution_Terminated_Status_Nm__c,PSS_Auto_Rejected_Ind__c,PSS_Rejection_Reason_Txt__c,ArdiraSurvey__End_State__c,
    //                                                  PSS_Programs_Applicable_Nm__c,PSS_Strategic_Attributes_Nm__c,PSS_Solution_Category_Nm__c,
    //                                                  PSS_Solution_Revenue_Projection__c
    //                                                  from ArdiraSurvey__Survey_Result__c where Id = :recordId];
        
        
    //     // as per life cycle status we can't change review scheduled to admin review
    //     if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c != PSS_StaticConstants.REVIEW_SCHEDULED) {
            
    //         surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.ADMIN_REVIEW;
    //     }
        
    //     surveyResult.PSS_Solution_Terminated_Status_Nm__c = '';
    //     surveyResult.ArdiraSurvey__Status__c = PSS_StaticConstants.IN_PROGRESS;
    //     if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.REVIEW_SCHEDULED || 
    //        surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.ADMIN_REVIEW ||
    //        surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_ONHOLD_STATUS){
    //            surveyResult.ArdiraSurvey__End_State__c = false;
    //        }
        
    //     //If Next button is selected
    //     if(buttonLabel == PSS_StaticConstants.NEXT){    
    //         surveyResult.PSS_Solution_Terminated_Status_Nm__c = PSS_StaticConstants.TCS;
    //     }
    //     //If Quit button is selected
    //     else if(buttonLabel == PSS_StaticConstants.QUIT){
    //         surveyResult.PSS_Solution_Terminated_Status_Nm__c = PSS_StaticConstants.QUIT;
    //         //Draft to Rejected status -this will happen only through quit button
    //         surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.SOLUTION_REJECTED_STATUS; 
    //         //Auto reject solution since user chose to Quit
    //         surveyResult.PSS_Rejection_Reason_Txt__c = 'Auto Rejected';
    //         surveyResult.PSS_Auto_Rejected_Ind__c = true;
            
    //     }
        
    //     //bug fix for Vision and Workload Consolidation is auto selected in Strategic Attributes when Partner user resubmits the Solution 
    //     //By changing the path where Q no 51 and forecast question is not available
    //     Boolean isStrategicUpdated= false;
    //     if(String.isNotBlank(surveyResult.PSS_Programs_Applicable_Nm__c)&&
    //        !surveyResult.PSS_Programs_Applicable_Nm__c.contains(PSS_StaticConstants.MRS) &&
    //        !surveyResult.PSS_Programs_Applicable_Nm__c.contains(PSS_StaticConstants.RRK) &&
    //        String.isNotBlank(surveyResult.PSS_Strategic_Attributes_Nm__c) && surveyResult.PSS_Strategic_Attributes_Nm__c != Null){
    //            if(surveyResult.PSS_Strategic_Attributes_Nm__c.contains(PSS_StaticConstants.WORKLOAD_CONSOLIDATION)){
    //                surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove(PSS_StaticConstants.WORKLOAD_CONSOLIDATION+';');
    //                surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove(PSS_StaticConstants.WORKLOAD_CONSOLIDATION);
    //                isStrategicUpdated= true;
    //            }
    //            if(surveyResult.PSS_Strategic_Attributes_Nm__c.contains('Vision')){
    //                surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove('Vision;');
    //                surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove('Vision');
    //                isStrategicUpdated= true;
    //            }
    //        }else if(String.isBlank(surveyResult.PSS_Programs_Applicable_Nm__c) && surveyResult.PSS_Strategic_Attributes_Nm__c != Null){
    //            surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove(PSS_StaticConstants.WORKLOAD_CONSOLIDATION+';');
    //            surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove(PSS_StaticConstants.WORKLOAD_CONSOLIDATION);
               
    //            surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove('Vision;');
    //            surveyResult.PSS_Strategic_Attributes_Nm__c=surveyResult.PSS_Strategic_Attributes_Nm__c.remove('Vision');
    //            isStrategicUpdated= true;
    //        }
        
    //     update surveyResult;
        
    //     if(isStrategicUpdated){
    //         map<id, ArdiraSurvey__Survey_Result__c> surveyResultMap= new map<id, ArdiraSurvey__Survey_Result__c>();
    //         List<ArdiraSurvey__Survey_Result__c> resultListToUpdate = new List<ArdiraSurvey__Survey_Result__c>();
    //         surveyResultMap.put(surveyResult.id, surveyResult);
    //         resultListToUpdate = PSS_ImpactPathScoring_Utility.calculateImpactPathScore(surveyResultMap);
    //         resultListToUpdate = PSS_BenefitAssignmentTriggerHelper.convertSolutionToOffering(resultListToUpdate);
    //         update resultListToUpdate;
    //     }
        
    // }
    
    // public String currentParams {get;set;}
    // //this method is called with apex:actionFunction in VF page
    // public void setAdditonalparamsInApex() {
    //     //the name of the parameter must be the same as it set in apex:param tag
    //     this.currentParams = Apexpages.currentPage().getParameters().get('userParam');        
    // }
    
    // /**
    // * @description Method to get solution data
    // * @param string solRecordId
    // * @return SolutionDataCheckWrapper
    // **/
    // @AuraEnabled
    // public Static SolutionDataCheckWrapper getSolutionDataAura(string solRecordId) {

    //     Boolean showAddConFlag = false;
    //     Boolean isRedirect = false;
    //     SolutionDataCheckWrapper solutionDataCheck = new SolutionDataCheckWrapper();
        
    //     ArdiraSurvey__Survey_Result__c surveyResult = new ArdiraSurvey__Survey_Result__c();
    //     try {
    //         if(solRecordId != Null && String.isNotBlank(solRecordId)) {
    //             List<ArdiraSurvey__Survey_Result__c> surveyResultRecord = [select id,PSS_Partner_Solution_Lifecycle_Status_Nm__c,
    //                                                                        PSS_Solution_Terminated_Status_Nm__c,PSS_Auto_Rejected_Ind__c,PSS_Rejection_Reason_Txt__c,ArdiraSurvey__End_State__c,
    //                                                                        PSS_Programs_Applicable_Nm__c,PSS_Strategic_Attributes_Nm__c,PSS_Solution_Category_Nm__c,
    //                                                                        PSS_Solution_Revenue_Projection__c,PSS_Company_Id__c
    //                                                                        from ArdiraSurvey__Survey_Result__c where Id = :solRecordId];
    //             if(surveyResultRecord.size()>0){
    //                 surveyResult=surveyResultRecord[0];
    //                 if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_REJECTED_STATUS || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_APPROVED_STATUS || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_CANCELLED_STATUS
    //                    || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_CONVERTED_STATUS || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.RETIRED) {
    //                        isRedirect = true;
    //                    }
    //                 else if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.ADMIN_REVIEW  || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.REVIEW_SCHEDULED || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_ONHOLD_STATUS ){
    //                     isRedirect= PMP_Utility.isLoggedInUserAdmin() == false? true:false;
    //                 }
                    
                    
    //                 if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.DRAFT || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_UPDATE_REQUIRED_STATUS) {
    //                     showAddConFlag = true;
    //                 }    
    //             }
    //             else {
    //                 isRedirect = true;
    //             }    
                
    //         }
    //         else {
    //             showAddConFlag = true;
    //         } 

    //         solutionDataCheck.isRedirect = isRedirect;
    //         solutionDataCheck.showAddConFlag = showAddConFlag;
            
    //     }
    //     catch(Exception e) {
    //         PMP_Utility.logError(e,'getSolutionDataAura'); 
    //     }
    //     return solutionDataCheck;
    // }

    // //Wrapper class with @AuraEnabled and {get;set;} properties for solution data
    // public class SolutionDataCheckWrapper{
    //     @AuraEnabled 
    //     public Boolean isRedirect {get;set;}
    //     @AuraEnabled 
    //     public Boolean showAddConFlag {get;set;}
    // }

    // //Unused code : This method is used for visualForce page PSS_SolutionSubmit.page
    // //After aura integration is live this can be removed.
    // @RemoteAction
    // public Static SolutionDataCheckWrapper getSolutionData(string SolRecordId){
    //     Boolean showAddConFlag = false;
    //     Boolean isRedirect = false;
    //     SolutionDataCheckWrapper solutionDataCheck = new SolutionDataCheckWrapper();
    //    ArdiraSurvey__Survey_Result__c surveyResult= new ArdiraSurvey__Survey_Result__c();
    //     try {
    //         if(solRecordId != Null && String.isNotBlank(solRecordId)) {
    //             List<ArdiraSurvey__Survey_Result__c> surveyResultRecord = [select id,PSS_Partner_Solution_Lifecycle_Status_Nm__c,
    //                                                             PSS_Solution_Terminated_Status_Nm__c,PSS_Auto_Rejected_Ind__c,PSS_Rejection_Reason_Txt__c,ArdiraSurvey__End_State__c,
    //                                                             PSS_Programs_Applicable_Nm__c,PSS_Strategic_Attributes_Nm__c,PSS_Solution_Category_Nm__c,
    //                                                             PSS_Solution_Revenue_Projection__c
    //                                                             from ArdiraSurvey__Survey_Result__c where Id = :solRecordId];
    //             if(surveyResultRecord.size()>0){
    //                 surveyResult=surveyResultRecord[0];
    //                 if( surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_REJECTED_STATUS || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_APPROVED_STATUS || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_CANCELLED_STATUS
    //                    || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_CONVERTED_STATUS || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.RETIRED) {
    //                        isRedirect = true;
    //                    }
    //                 else if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.ADMIN_REVIEW  || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.REVIEW_SCHEDULED || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_ONHOLD_STATUS ){
    //                     isRedirect= PMP_Utility.isLoggedInUserAdmin() == false? true:false;
    //                 }
                    
    //                 if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.DRAFT || surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_UPDATE_REQUIRED_STATUS) {
    //                     showAddConFlag = true;
    //                 }
    //             }
    //             else{
    //                 isRedirect=true;
    //             }
    //         } 
    //         else {
    //             showAddConFlag = true;
    //         } 

    //         solutionDataCheck.isRedirect = isRedirect;
    //         solutionDataCheck.showAddConFlag = showAddConFlag;
    //     }
    //     catch(Exception e) {
    //     }
    //     return solutionDataCheck;
    // }
}