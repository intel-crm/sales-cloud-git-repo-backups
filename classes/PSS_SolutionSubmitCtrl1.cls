/*************************************************************************************************************************************************************************
* Class Name  : PSS_SolutionSubmitCtrl
* Version     : 1.0 
* Created Date: 6/16/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Swathi              M-01    : Original version       4/06/2021                         Utility class for commonly used methods
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
global with sharing class PSS_SolutionSubmitCtrl1 {

    // public String recordId{get;set;}
    // public static String createRecordId{get;set;}
    // public static String logicalId{get;set;}
    // public static String companyId{get;set;}
    // public static Boolean showAddConFlag { get; set; }
    // public static string surveyResultId{get;set;}
    // public static string programName{get;set;}
    
    // private ApexPages.StandardController sc;
    
    // //Constructor to get record id from the url
    // public PSS_SolutionSubmitCtrl1(ApexPages.StandardController sc){
    //     this.sc = sc;
    //     DateTime start = System.Now();
    //     recordId=ApexPages.CurrentPage().getParameters().get('PSS_company_Id__c');
    //     programName = ApexPages.CurrentPage().getParameters().get('PSS_Solution_Category_Nm__c');
        
    //    // System.debug('Current Page URL ::: '+ApexPages.currentPage());
    //    // System.debug('Current Page URL Parameters ::: '+ApexPages.currentPage().getParameters());

    //     System.debug('recordId ::: '+recordId);
    //     System.debug('programName ::: '+programName);
    //     string str1;
    //     string str2;
    //     if(programName == 'IOTG'){
    //         str1 = 'PSS_Survey_RecordId';
    //         str2 = 'PSS_Survey_LogicalId';
    //         System.debug(' IOTG Record Id ::: '+str1);
    //         System.debug(' IOTG Logical Id ::: '+str2);
    //     }
    //     else if(programName == 'DCG'){
    //         str1 = 'PSS_DCG_Survey_RecordId';
    //         str2 = 'PSS_DCG_Survey_LogicalId';
    //         System.debug(' DCG Record Id ::: '+str1);
    //         System.debug(' DCG Logical Id ::: '+str2);
    //     }
	// 	// Partner Solution redirection
    //     else{
    //         str1 = 'PSS_Partner_Solution_Survey_RecordId';
    //         str2 = 'PSS_Partner_Solution_Survey_LogicalId';
    //         System.debug(' PS Record Id ::: '+str1);
    //         System.debug(' PS Logical Id ::: '+str2);
    //     }
        
    //     /**** To get the record id from static metadata PSS_Static_Data ****/
    //     // createRecordId=PMP_Utility.getValue('PSS_Survey_RecordId');
    //     createRecordId=PMP_Utility.getValue(str1);
    //     /**** To Get the logical Id from Static Metadata PSS_Static_Data ****/
    //     // logicalId=PMP_Utility.getValue('PSS_Survey_LogicalId');
    //     logicalId=PMP_Utility.getValue(str2);
    //     /**** To Get the Company Information field from Static Metadata PSS_Static_Data ****/
    //     System.debug('createRecordId ::: '+createRecordId);
    //     System.debug('logicalId ::: '+logicalId);
    //     companyId =companyId;
    //     showAddConFlag = false;
    //     surveyResultId='';
        
    // }
    
    // public static void addContactBtnVisibility() {
    //     String recordId = Apexpages.currentPage().getParameters().get('recordId');
    //     showAddConFlag = false;
    //     system.debug('recordId'+recordId);
    //     if(String.isBlank(recordId)) {
    //         showAddConFlag = true;
    //     } else {
    //         List<ArdiraSurvey__Survey_Result__c> surveyResult = [SELECT Id, PSS_Partner_Solution_Lifecycle_Status_Nm__c FROM ArdiraSurvey__Survey_Result__c WHERE Id = :recordId];
    //         if(surveyResult.size() > 0 && (surveyResult[0].PSS_Partner_Solution_Lifecycle_Status_Nm__c == 'Draft' || surveyResult[0].PSS_Partner_Solution_Lifecycle_Status_Nm__c == 'Update Required')) {
    //             showAddConFlag = true;
    //         }
    //     }

    // }
    
    // @RemoteAction
    // global static void statusChangeOnSubmit(String recordId,String buttonLabel){

    //     ArdiraSurvey__Survey_Result__c surveyResult=[select id,PSS_Partner_Solution_Lifecycle_Status_Nm__c,
    //                                                  PSS_Solution_Terminated_Status_Nm__c
    //                                                  from ArdiraSurvey__Survey_Result__c where Id = :recordId];
        
    //     system.debug('surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c :: '+surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
    //     system.debug('1 > 98 > PPPPPPPP'+ surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
    //     // as per life cycle status we can't change review scheduled to admin review
    //     if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c != PSS_StaticConstants.REVIEW_SCHEDULED) {
    //         surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.ADMIN_REVIEW;
    //     }
    //     surveyResult.PSS_Solution_Terminated_Status_Nm__c = '';
    //     surveyResult.ArdiraSurvey__Status__c = PSS_StaticConstants.IN_PROGRESS;
        
    //     //If Next button is selected
    //     if(buttonLabel == PSS_StaticConstants.NEXT){    
    //         surveyResult.PSS_Solution_Terminated_Status_Nm__c = PSS_StaticConstants.TCS;
    //     }
    //     //If Quit button is selected
    //     else if(buttonLabel == PSS_StaticConstants.QUIT){
    //         surveyResult.PSS_Solution_Terminated_Status_Nm__c = PSS_StaticConstants.QUIT;
    //         //Draft to Rejected status -this will happen only through quit button
    //         surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = PSS_StaticConstants.SOLUTION_REJECTED_STATUS;  
    //     }
    //     system.debug('##surveyResult:->'+surveyResult);
    //     update surveyResult;
        
    // }
}