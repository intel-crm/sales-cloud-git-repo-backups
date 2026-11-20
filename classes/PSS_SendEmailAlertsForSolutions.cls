/*******************************************************************************************************************************************************************************************************
* Class Name  : PSS_SendEmailAlertsForSolutions
* Description : Stores the logic for sending the email for all solution email scenarios.
* Version     : 1.0 
* Created Date: 10-Feb-2021
* Modification Log :
* Created By  : Priyanka (Infosys)
********************************************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest 
public without sharing class PSS_SendEmailAlertsForSolutions {
//     public static Map<Id,ArdiraSurvey__Survey_Result__c> solListForMRS_RRK= new Map<Id,ArdiraSurvey__Survey_Result__c>();
    
//     //wrapper which holds the solution  and template details
//     public class EmailWrapperForSolutions {
//         @InvocableVariable(label='Solution Id' description='Solution Id Captured here' required=true)
//         public Id solutionId;
//         @InvocableVariable(label='Template Name' description='Template Name is Captured here' required=true)
//         Public String templateName;
//     }
    
//     /*******************************************************************************************************************************************************************************************************
// * Method Name : sendSolutionsEmailNotifications
// * Description : This method will send the email to all solutions email scenarios and it is invoked by a process builder -
// * Params      : EmailWrapperForSolutions[] , which contains template name and solution id.
// * Version     : 1.0 
// * Created Date: 09-Feb-2020
// * Modification Log :
// * Created By  : Priyanka (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     @InvocableMethod(label='Send Emails for Solutions' description='Sends the email to submitter of solution')
//     public static void sendSolutionsEmailNotifications(List<EmailWrapperForSolutions> solutionAndTemplateDetails) {
//         String templateName = solutionAndTemplateDetails[0].templateName;
    
//         // Fetch solution details
//         List<ArdiraSurvey__Survey_Result__c> solutions = fetchSolutionDetails(solutionAndTemplateDetails);
    
//         // Initialize maps and lists
//         Map<Id, Id> submitterSolutionIdMap = new Map<Id, Id>();
//         List<Id> iotMarketReadySolList = new List<Id>();
//         Set<String> MRSAndRRK = new Set<String>(PSS_StaticConstants.MRSAndRRK);
//         List<PSS_Solution_Contact_Association__c> solutionContactsToEmail = new List<PSS_Solution_Contact_Association__c>();
    
//         // Populate maps and lists based on solution details
//         populateMapsAndLists(solutions, submitterSolutionIdMap, iotMarketReadySolList, MRSAndRRK, solutionContactsToEmail);
    
//         // Send emails based on populated data
//         sendEmails(templateName, submitterSolutionIdMap, iotMarketReadySolList, solutionContactsToEmail);
//     }
    
//     // Helper method to fetch solution details
//     private static List<ArdiraSurvey__Survey_Result__c> fetchSolutionDetails(List<EmailWrapperForSolutions> solutionAndTemplateDetails) {
//         List<Id> solutionIds = new List<Id>();
//         for (EmailWrapperForSolutions req : solutionAndTemplateDetails) {
//             solutionIds.add(req.solutionId);
//         }
    
//         List<ArdiraSurvey__Survey_Result__c> solutions = new List<ArdiraSurvey__Survey_Result__c>();
//         if (Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()) {
//             solutions = [
//                 SELECT Id, Name, CreatedById, OwnerId, ArdiraSurvey__Assigned_To_Contact__c, PSS_Submitted_by_Txt__c,
//                        ArdiraSurvey__Assigned_To_User__c, ArdiraSurvey__Assigned_To_User__r.IsActive,
//                        PSS_Solution_Submitter_UserId_Id__c, PSS_Solution_Submitter_UserId_Id__r.ContactId,
//                        PSS_Solution_Submitter_UserId_Id__r.FirstName, PSS_Solution_Submitter_UserId_Id__r.IsActive,
//                        PSS_Company_Id__c, PSS_Programs_Applicable_Nm__c, PSS_Partner_Solution_Lifecycle_Status_Nm__c,
//                        PSS_Solution_Submitter_UserId_Id__r.Contact.Core_Do_Not_Contact__c
//                 FROM ArdiraSurvey__Survey_Result__c
//                 WHERE Id IN :solutionIds
//             ];
//         }
//         return solutions;
//     }
    
//     // Helper method to populate maps and lists based on solution details
//     private static void populateMapsAndLists(List<ArdiraSurvey__Survey_Result__c> solutions, Map<Id, Id> submitterSolutionIdMap,
//                                           List<Id> iotMarketReadySolList, Set<String> MRSAndRRK,
//                                           List<PSS_Solution_Contact_Association__c> solutionContactsToEmail) {
//         for (ArdiraSurvey__Survey_Result__c solution : solutions) {
//             processProgramApplicable(solution, submitterSolutionIdMap, iotMarketReadySolList, MRSAndRRK);
//             processAssignedToUser(solution, submitterSolutionIdMap);
//         }

//         fetchSolutionContacts(solutionContactsToEmail, submitterSolutionIdMap);
//     }

//     // Helper method to process program applicability and update maps and lists
//     private static void processProgramApplicable(ArdiraSurvey__Survey_Result__c solution, Map<Id, Id> submitterSolutionIdMap,
//                                                 List<Id> iotMarketReadySolList, Set<String> MRSAndRRK) {
//         Set<String> programApplicable = new Set<String>();
//         if (solution.PSS_Programs_Applicable_Nm__c != null) {
//             programApplicable.addAll(solution.PSS_Programs_Applicable_Nm__c.split(';'));
//             programApplicable.retainAll(MRSAndRRK);
//             if (programApplicable.size() > 0 && solution.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_APPROVED_STATUS) {
//                 submitterSolutionIdMap.put(solution.PSS_Solution_Submitter_UserId_Id__c, solution.Id);
//             }
//         }

//         if (solution.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_APPROVED_STATUS && programApplicable.size() > 0 &&
//             (solution.PSS_Solution_Submitter_UserId_Id__c == null ||
//             solution.PSS_Solution_Submitter_UserId_Id__r.Contact.Core_Do_Not_Contact__c)) {
//             iotMarketReadySolList.add(solution.Id);
//         } else if (solution.PSS_Solution_Submitter_UserId_Id__c != null && (solution.PSS_Solution_Submitter_UserId_Id__r.IsActive == true ||(solution.PSS_Solution_Submitter_UserId_Id__r.IsActive==false))) {
//             submitterSolutionIdMap.put(solution.PSS_Solution_Submitter_UserId_Id__c, solution.Id);
//         }
//     }

//     // Helper method to process assigned user and update maps
//     private static void processAssignedToUser(ArdiraSurvey__Survey_Result__c solution, Map<Id, Id> submitterSolutionIdMap) {
//         if (solution.ArdiraSurvey__Assigned_To_User__c != null && (solution.ArdiraSurvey__Assigned_To_User__r.IsActive == true||(solution.ArdiraSurvey__Assigned_To_User__r.IsActive == false))) {
//             submitterSolutionIdMap.put(solution.ArdiraSurvey__Assigned_To_User__c, solution.Id);
//         }
//     }

//     // Helper method to fetch solution contacts
//     private static void fetchSolutionContacts(List<PSS_Solution_Contact_Association__c> solutionContactsToEmail, Map<Id, Id> submitterSolutionIdMap) {
//         if (Schema.sObjectType.PSS_Solution_Contact_Association__c.isAccessible()) {
//             solutionContactsToEmail = [
//                 SELECT Id, PSS_Solution_Name__c, PSS_Assigned_User__c, PSS_Assigned_Contact__c
//                 FROM PSS_Solution_Contact_Association__c
//                 WHERE PSS_Solution_Name__c IN :submitterSolutionIdMap.values() AND PSS_Active__c = true AND
//                     PSS_Assigned_User__r.IsPortalEnabled = true AND (PSS_Assigned_User__r.IsActive = true OR (PSS_Assigned_User__r.IsActive =false))
//             ];
//         }

//         for (PSS_Solution_Contact_Association__c solutionContact : solutionContactsToEmail) {
//             submitterSolutionIdMap.put(solutionContact.PSS_Assigned_User__c, solutionContact.PSS_Solution_Name__c);
//         }
//     }

    
//     // Helper method to send emails based on populated data
//     private static void sendEmails(String templateName, Map<Id, Id> submitterSolutionIdMap, List<Id> iotMarketReadySolList,
//                                    List<PSS_Solution_Contact_Association__c> solutionContactsToEmail) {
//         if (!submitterSolutionIdMap.keySet().isEmpty()) {
//             PMP_Utility.sendEmailAndLogData(templateName, submitterSolutionIdMap);
//         }
    
//         if (iotMarketReadySolList.size() > 0) {
//             PMP_Utility.sendEmailToIOTReady(templateName, iotMarketReadySolList);
//         }
//     }
    
    
    
}