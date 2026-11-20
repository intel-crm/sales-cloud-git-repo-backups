/*************************************************************************************************************************************************************************
* Class Name  : PSS_PartnersOnSolution 
* Version     : 1.0 
* Created Date: 4/06/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Hanuma              M-01    : Original version       4/06/2021                         Class to display partner data whiel creating offering
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest 
public without sharing class PSS_PartnersOnSolution {
    
    /**
* @description Method to get assigned permission set for the current user
* @param void 
* @return List<PermissionSetAssignment>
**/
//     @AuraEnabled(cacheable=true)
//     public static List<PermissionSetAssignment> getPermissionset(){
//         List<PermissionSetAssignment> result = [SELECT Id, 
//                                                 PermissionSetId, 
//                                                 PermissionSet.Name, 
//                                                 PermissionSet.ProfileId, 
//                                                 PermissionSet.Profile.Name, 
//                                                 AssigneeId, 
//                                                 Assignee.Name 
//                                                 FROM 
//                                                 PermissionSetAssignment 
//                                                 where
//                                                 assigneeId =: UserInfo.getUserId() AND 
//                                                 (PermissionSet.Name = 'PMP_Internal_Intel_Admin' OR PermissionSet.Name = 'PMP_External_Employee' 
//                                                  OR PermissionSet.Name = 'PMP_External_Lead_Development_Representative' 
//                                                  OR PermissionSet.Name = 'PMP_External_Offering_Editor' 
//                                                  OR PermissionSet.Name = 'PMP_External_Partner_Admin' 
//                                                  OR PermissionSet.Name = 'PMP_External_Marketing_Specialist')];
        
//         //System.debug('User Info:'+result);
//         return result;
//     }
    
//     @AuraEnabled
//     public static List<PMP_Company__c> partnersOnSolutionSearch(string partnerName){
//         List<PMP_OPID_MPI_Rel__c> companyData = new List<PMP_OPID_MPI_Rel__c>();
//         List<PMP_Company__c> companyDataFinal = new List<PMP_Company__c>();
//         string searchKeyword = '%' + partnerName + '%';
//         Set<string> companyIds = new Set<String>();

//         //if(Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible()){

//             companyData = [select id,Name,Is_Active__c,PMP_Marketing_Profile_Id__c,
// 							PMP_Marketing_Profile_Id__r.PMP_Partner_Program_nm__c, PMP_Marketing_Profile_Id__r.Name,
// 							PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,
// 							PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c,PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
// 							PMP_One_Partner_ID__c,PMP_One_Partner_ID__r.RecordType.Name
// 							FROM PMP_OPID_MPI_Rel__c
// 							WHERE Is_Active__c = true
// 							AND PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c = false
// 							AND PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c ='Published'
// 							AND PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c = true
// 							AND PMP_Marketing_Profile_Id__r.name like : searchKeyword];
        
//         for(PMP_OPID_MPI_Rel__c opidMPI : companyData){
//             companyIds.add(opidMPI.PMP_Marketing_Profile_Id__c);
//         }
        
//         if(!companyIds.isempty()){
            
//             companyDataFinal = [select Id,Name,PMP_Partner_Program_nm__c,PMP_Is_Published_Ind__c,PMP_Benefit_Update_Ind__c,PMP_Company_Lifecycle_Status_Nm__c 
//                        From PMP_Company__c 
//                        WHERE PMP_Benefit_Update_Ind__c = false 
//                        AND PMP_Company_Lifecycle_Status_Nm__c ='Published' 
//                        AND PMP_Is_Published_Ind__c = true
//                        AND Id =:companyIds ORDER BY Name ASC];
//         }
//         //}
//         return companyDataFinal;
//     }
    
  
//     @AuraEnabled
//     public static List<Contact> getPartnerContacts(string companyId) {
//         Set<Id> opIds = new Set<Id>();
//         Set<Id> locationIds = new Set<Id>();
//         Set<Id> contactIds = new Set<Id>();
//         Set<Id> userContactIds = new Set<Id>();
//         List<Contact> contactList = new List<Contact>();
//         List<PMP_OPID_MPI_Rel__c> opidMPIRel = new List<PMP_OPID_MPI_Rel__c>();
    
//         // Fetch PMP_OPID_MPI_Rel__c records
//         fetchOpidMPIRel(companyId, opidMPIRel);
    
//         // Process PMP_OPID_MPI_Rel__c records
//         processOpidMPIRel(opidMPIRel, opIds, locationIds);
    
//         // Fetch Core_Account_Group_Member__c records
//         List<Core_Account_Group_Member__c> cagms = fetchCoreAccountGroupMembers(opIds);
    
//         // Process Core_Account_Group_Member__c records
//         processCoreAccountGroupMembers(cagms, locationIds);
    
//         // Fetch PRM_Account_Contact_Relationship__c records
//         fetchPRMAccountContactRelationships(locationIds, contactIds);
    
//         // Fetch Users related to contacts
//         fetchUsers(contactIds, userContactIds);
    
//         // Fetch contacts related to users
//         fetchContacts(userContactIds, contactList);
    
//         return contactList;
//     }
    
//     private static void fetchOpidMPIRel(string companyId, List<PMP_OPID_MPI_Rel__c> opidMPIRel) {
//         if (Schema.sObjectType.PMP_OPID_MPI_Rel__c.isAccessible()) {
//             opidMPIRel.addAll([SELECT Id, Name, Is_Active__c, PMP_Marketing_Profile_Id__c,
//                           PMP_Marketing_Profile_Id__r.PMP_Partner_Program_nm__c, PMP_Marketing_Profile_Id__r.Name,
//                           PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,
//                           PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c, PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
//                           PMP_One_Partner_ID__c, PMP_One_Partner_ID__r.RecordType.developerName
//                           FROM PMP_OPID_MPI_Rel__c 
//                           WHERE Is_Active__c = true 
//                           AND PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c = false 
//                           AND PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c = 'Published' 
//                           AND PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c = true 
//                           AND PMP_Marketing_Profile_Id__c = :companyId]);
            
//         }
//     }
    
//     private static void processOpidMPIRel(List<PMP_OPID_MPI_Rel__c> opidMPIRel, Set<Id> opIds, Set<Id> locationIds) {
//         for (PMP_OPID_MPI_Rel__c opiDMPI : opidMPIRel) {
//             if (opiDMPI.PMP_One_Partner_ID__c != null && (opiDMPI.PMP_One_Partner_ID__r.RecordType.developerName == PSS_StaticConstants.PAG_ACCOUNT_DEVELOPERNAME ||
//                                                            opiDMPI.PMP_One_Partner_ID__r.RecordType.developerName == PSS_StaticConstants.INTEL_ACCOUNT_DEVELOPERNAME)) {
//                 opIds.add(opiDMPI.PMP_One_Partner_ID__c);
//             } else {
//                 locationIds.add(opiDMPI.PMP_One_Partner_ID__c);
//             }
//         }
//     }
    
//     private static List<Core_Account_Group_Member__c> fetchCoreAccountGroupMembers(Set<Id> opIds) {
//         return [SELECT Id, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c 
//                 FROM Core_Account_Group_Member__c 
//                 WHERE Core_Partner_Account_Id__c IN :opIds OR Core_Intel_Account_Id__c IN :opIds];
//     }
    
//     private static void processCoreAccountGroupMembers(List<Core_Account_Group_Member__c> cagms, Set<Id> locationIds) {
//         for (Core_Account_Group_Member__c cagm : cagms) {
//             if (cagm.Core_Intel_Account_Id__c != null) {
//                 locationIds.add(cagm.Core_Intel_Account_Id__c);
//             }
//         }
//     }
    
//     private static void fetchPRMAccountContactRelationships(Set<Id> locationIds, Set<Id> contactIds) {
//         List<PRM_Account_Contact_Relationship__c> pcrs = [SELECT Id, PRM_Contact_Id__c, PRM_Account_Id__c,
//                                                             PRM_InActive_Ind__c, PRM_Status_Nm__c 
//                                                             FROM PRM_Account_Contact_Relationship__c 
//                                                             WHERE PRM_Account_Id__c IN :locationIds AND PRM_InActive_Ind__c = false AND 
//                                                             PRM_Status_Nm__c = 'Complete'];
    
//         for (PRM_Account_Contact_Relationship__c pcr : pcrs) {
//             contactIds.add(pcr.PRM_Contact_Id__c);
//         }
//     }
    
//     private static void fetchUsers(Set<Id> contactIds, Set<Id> userContactIds) {
//         for (User usr : [SELECT Id, ContactId, Name FROM User WHERE ContactId IN :contactIds AND IsActive = true]) {
//             userContactIds.add(usr.ContactId);
//         }
//     }
    
//     private static void fetchContacts(Set<Id> userContactIds, List<Contact> contactList) {
//         if (!userContactIds.isEmpty()) {
//             contactList.addAll([SELECT Id, Name, FirstName, LastName, Email, AccountId 
//                             FROM Contact 
//                             WHERE Id IN :userContactIds]);
//         }
//     }
    
    
//     /**
// * @description Method to get identify the solution button visibility
// * @param void 
// * @return boolean
// **/
//     @AuraEnabled(cacheable=true)
//     public static Boolean getSoulutionButtonVisibility() {
//         Boolean isSubmitVisible=false;
//         Set<Id> idSet=new Set<Id>();
//         idSet.add(UserInfo.getUserId());// setting the current logged in user.
//         List<String> permissionSetList=new List<String>();
//         permissionSetList.add('PMP_Internal_Intel_Admin');
//         permissionSetList.add('PMP_External_Employee');
//         permissionSetList.add('PMP_External_Lead_Development_Representative');
//         permissionSetList.add('PMP_External_Offering_Editor');
//         permissionSetList.add('PMP_External_Partner_Admin');
//         permissionSetList.add('PMP_External_Marketing_Specialist');
//         permissionSetList.add('PMP_Internal_Intel_Read_Only');
//         List<PermissionSetAssignment> assignedList=PSS_Utility.getUsersWithAssignedPermissionSet(idSet,permissionSetList);
//         List<String> namesOfAssignedPermissionList= new  List<String>();
//         for(PermissionSetAssignment assignedPermission:assignedList){
//             namesOfAssignedPermissionList.add(assignedPermission.PermissionSet.name);
//         }
//         if(namesOfAssignedPermissionList.size()>1){
//             isSubmitVisible=true;
//         }
//         else if(namesOfAssignedPermissionList.size()==1 && !namesOfAssignedPermissionList.contains('PMP_Internal_Intel_Read_Only')){
//             isSubmitVisible=true;
//         }
//         //system.debug('dsjsjja'+isSubmitVisible);
//         return isSubmitVisible;
//     }
 

//     @AuraEnabled
//     public static List<String> getPickListValuesIntoList(){
//         try {
//             List<String> pickListValuesList= new List<String>();
// 		    Schema.DescribeFieldResult fieldResult = ArdiraSurvey__Survey_Result__c.PSS_Solution_Category_Nm__c.getDescribe();
// 		    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
// 		    for( Schema.PicklistEntry pickListVal : ple){
// 			    pickListValuesList.add(pickListVal.getLabel());
// 		    }     
// 		    return pickListValuesList;
//         } catch (Exception e) {
//             throw new AuraHandledException(e.getMessage());
//         }
//     }
    
//    /**
// * @description Method to get identify the export button visibility
// * @param void 
// * @return boolean
// **/
//     @AuraEnabled(cacheable=true)
//     public static Boolean getexportButtonVisibility() {
//         Boolean isExportVisible=false;
//         Set<Id> idSet=new Set<Id>();
//         idSet.add(UserInfo.getUserId());// setting the current logged in user
//         List<String> permissionSetList=new List<String>();
//         permissionSetList.add('PMP_Internal_Intel_Admin');
//         permissionSetList.add('PMP_External_Employee');
//         permissionSetList.add('PMP_External_Lead_Development_Representative');
//         permissionSetList.add('PMP_External_Offering_Editor');
//         permissionSetList.add('PMP_External_Partner_Admin');
//         permissionSetList.add('PMP_External_Marketing_Specialist');
        	
//         List<PermissionSetAssignment> assignedList=PSS_Utility.getUsersWithAssignedPermissionSet(idSet,permissionSetList);
        
//          List<String> namesOfAssignedPermissionList= new List<String>();
//         if(!assignedList.isEmpty()){
//         for(PermissionSetAssignment assignedPermission:assignedList){
//             namesOfAssignedPermissionList.add(assignedPermission.PermissionSet.name);
//         }
//         if(namesOfAssignedPermissionList.size()>0){
//             isExportVisible=true;
//         }
//         }
//         return isExportVisible;
//     }
   
   
}