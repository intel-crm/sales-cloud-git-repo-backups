/*************************************************************************************************************************************************************************
* Class Name  : PSS_PartnerResponsePageCtrl 
* Version     : 1.0 
* Created Date: 08/03/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Apoorva              M-01    : Original version       08/03/2021                         Controller class for pssSolutionDetail and PSS_CreateEditSolution_Cmp
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest 
public without sharing class  PSS_PartnerResponsePageCtrl {
    
    
    /**
* @description Method to get solution result data based on solution Id
* @param Id recordId
* @return partnerResponseWrapper
**/
//     @AuraEnabled
//     Public Static partnerResponseWrapper getPartnerResponses(Id recordId){
//         partnerResponseWrapper response= new partnerResponseWrapper();
//         Map<id,String> ids=new Map<id,String>();
//         List<questionAnswerWrapper> questionAnswerWrapperList=new List<questionAnswerWrapper>();
//         Map<id,PSS_PartnerResponsePageCtrl.questionAnswerWrapper> AnswerWrapperList=new Map<id,PSS_PartnerResponsePageCtrl.questionAnswerWrapper>();
//         String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
//         //Hidden Question Unique text
//         String hiddenQuestion =  PMP_Utility.getValue('PSS_Hidden_Question_Key');
//         String hiddenScoringQuestion = PMP_Utility.getValue('PSS_Hidden_Category_Scoring_Question');
//         Map<string,intelProductQuesAndAnsWrapper> wrapperMap = new Map<string,intelProductQuesAndAnsWrapper>();
        
//         List<ArdiraSurvey__Survey_Result__c> surveyResultList= new List<ArdiraSurvey__Survey_Result__c>();
//         if(recordId != NULL){
//             // query to check the partner solution record.
//            for ( ArdiraSurvey__Survey_Result__c rec: [SELECT Id, ArdiraSurvey__Assigned_To__c,PSS_Partner_Name_From_IOTG_txt__c,PSS_Partner_Name_FR__c,Owner.Name,Owner.Email,PSS_Solution_Submitter_UserId_Id__r.Name,PSS_Solution_Submitter_UserId_Id__r.Email,PSS_Partner_Solution_Lifecycle_Status_Nm__c,ArdiraSurvey__Progress__c,
//                                 ArdiraSurvey__Score_Raw__c,PSS_AIIP_Score__c,PSS_View_Offering_Txt__c,PSS_Proposal_Name_Txt__c,toLabel(PSS_Partner_Account_Id__r.Core_IPA_Partner_Role__c),
//                                 toLabel(PSS_Partner_Account_Id__r.BillingCountryCode),PSS_Partner_Account_Id__r.Core_Geo__c,
//                                 PSS_Approval_Date_dt__c,PSS_Partner_Name_English_Only__c,ArdiraSurvey__Logical_Id__c,
//                                 PSS_Solution_Status_Nm__c,PSS_Solution_Activation_Call_Date_dt__c,PSS_SolutionStatusActivationComments_Txt__c,
//                                 PSS_MRS_Score__c,PSS_RRK_Score__c,PSS_Programs_Applicable_Nm__c, PSS_Solution_Revenue_Projection__c,                              
//                                 PSS_Review_Scheduled_Date_dt__c,PSS_Partner_Account_Id__c,PSS_Partner_Account_Id__r.Name,
//                                 PSS_Partner_Account_Id__r.Core_English_Only_Name__c,
//                                 PSS_Follow_up_Date_Dt__c,PSS_View_Program_Applicable_Txt__c,PSS_Company_Id__c,PSS_Company_Id__r.Name,                               
//                                 PSS_System_Suggested_Benefit_Level__r.Name,PSS_Submitted_On_Dt__c,PSS_Company_Id__r.PMP_Partner_Benefit_Type__c,
//                                 PSS_Admin_Suggested_Benefit_Level__r.Name,PSS_Impact_Path_Score__c,PSS_Conversion_Admin_Log_Details_Txt__c,
//                                 PSS_Elapsed_Time_For_On_Hold_Nm__c,PSS_Elapsed_Time_For_Update_Required_Nm__c,PSS_Total_Minutes_On_Hold__c,PSS_Total_Minutes_Update_Required__c,PSS_Cancel_Reason_Txt__c,
//                                 ArdiraSurvey__Assigned_To_User__r.Name,ArdiraSurvey__Assigned_To_User__r.Email,                  
// 				(SELECT Id,ArdiraSurvey__Answer_Rich_Text__c, ArdiraSurvey__Question__r.ArdiraSurvey__Question_Plain_Text__c, ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c, ArdiraSurvey__Answer_Text__c,ArdiraSurvey__Comment__c,
//                                  ArdiraSurvey__Score_Raw__c,ArdiraSurvey__Score_Percentage__c,ArdiraSurvey__Score_Level__c,ArdiraSurvey__Question__r.ArdiraSurvey__Type__c,
//                                  ArdiraSurvey__Question__r.ArdiraSurvey__Section__r.ArdiraSurvey__Display_Order__c,ArdiraSurvey__Repeat_Position__c,ArdiraSurvey__Question__r.ArdiraSurvey__Display_Order__c
//                                  FROM ArdiraSurvey__Question_Results__r where ArdiraSurvey__Answered__c = true AND ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c != :hiddenQuestion AND ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c != :hiddenScoringQuestion AND 
//                                  ArdiraSurvey__Question__r.ArdiraSurvey__Type__c !=: PSS_StaticConstants.SURVEY_QUESTION_THANKS_TYPE ORDER BY ArdiraSurvey__Question__r.ArdiraSurvey__Section__r.ArdiraSurvey__Display_Order__c,
//                                  ArdiraSurvey__Question__r.ArdiraSurvey__Display_Order__c,ArdiraSurvey__Repeat_Position__c/*Sorted the questions by section order and question order*/ )
//                                 FROM ArdiraSurvey__Survey_Result__c
//                                 WHERE id =: recordId limit 1]){
//                                                            surveyResultList.add(rec);  
//                                     					   response.resultRecordName = rec.PSS_Proposal_Name_Txt__c;
//                                     					   response.submitterName = rec.PSS_Solution_Submitter_UserId_Id__r.Name!=NULL ?rec.PSS_Solution_Submitter_UserId_Id__r.Name:rec.ArdiraSurvey__Assigned_To_User__r.Name;
//                                    					   response.submitterEmail = rec.PSS_Solution_Submitter_UserId_Id__r.Email!=NULL ?rec.PSS_Solution_Submitter_UserId_Id__r.Email:rec.ArdiraSurvey__Assigned_To_User__r.Email;
//                                     					   response.partnerName = rec.PSS_Partner_Name_English_Only__c;
//                                                        }
//         }
//         if(!surveyResultList.isEmpty()){
//             response.partnerRole = PSS_PartnerResponsePageCtrl.getPartnerRole(recordId);
//             System.debug('PartnerRole from apex :'+response.partnerRole);
//             System.debug('Partner Name : '+surveyResultList.get(0).PSS_Partner_Account_Id__r.Core_English_Only_Name__c);
//             response.resultRecord= surveyResultList.get(0);
//             //Added as part of TWC729-5748 - Ardira Package Update Issue Fix
//             response.logicalId = surveyResultList.get(0).ArdiraSurvey__Logical_Id__c;
//             response.showAddContact = surveyResultList.get(0).PSS_Partner_Solution_Lifecycle_Status_Nm__c == 'Draft' || surveyResultList.get(0).PSS_Partner_Solution_Lifecycle_Status_Nm__c == 'Update Required';
//             //condition to get the question result record
//             if(!surveyResultList.get(0).ArdiraSurvey__Question_Results__r.isEmpty()){
//                 for(ArdiraSurvey__Question_Result__c quesResult: surveyResultList.get(0).ArdiraSurvey__Question_Results__r){
//                     questionAnswerWrapper queResWrapper= new questionAnswerWrapper();
//                     intelProductQuesAndAnsWrapper intelProducts;
                    
//                     if(!wrapperMap.containsKey(quesResult.ArdiraSurvey__Repeat_Position__c)){
//                     	intelProducts=new intelProductQuesAndAnsWrapper();
//                     }else{
//                         intelProducts=  wrapperMap.get(quesResult.ArdiraSurvey__Repeat_Position__c);
//                     }    
//                     // question result object contains either intel product,projected quanitity,comments question
//                     if(quesResult.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c=='IOTG_IntelProduct' || quesResult.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c=='IOTG_ProjectedQuantity' || quesResult.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c=='IOTG_Comments'){
//                         if(quesResult.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c=='IOTG_IntelProduct'){
//                         	intelProducts.ques=quesResult.ArdiraSurvey__Answer_Text__c;
//                             wrapperMap.put(quesResult.ArdiraSurvey__Repeat_Position__c,intelProducts);
//                         }else if(quesResult.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c=='IOTG_ProjectedQuantity'){
//                             intelProducts.ans=quesResult.ArdiraSurvey__Answer_Text__c;
//                             wrapperMap.put(quesResult.ArdiraSurvey__Repeat_Position__c,intelProducts);
//                         }else if(quesResult.ArdiraSurvey__Question__r.PSS_Question_Unique_Key_Txt__c=='IOTG_Comments'){
//                         	intelProducts.comm=quesResult.ArdiraSurvey__Answer_Text__c;
//                             wrapperMap.put(quesResult.ArdiraSurvey__Repeat_Position__c,intelProducts);
//                         } 
//                     }
//                     //to add other question into the wrapper list.
//                     else{
                        
//                         if(quesResult.ArdiraSurvey__Answer_Rich_Text__c!=null){
//                             queResWrapper.ques = quesResult.ArdiraSurvey__Question__r.ArdiraSurvey__Question_Plain_Text__c;
//                             queResWrapper.ans = quesResult.ArdiraSurvey__Answer_Rich_Text__c;
//                         }
//                         else if(quesResult.ArdiraSurvey__Answer_Text__c!=null){
//                             queResWrapper.ques = quesResult.ArdiraSurvey__Question__r.ArdiraSurvey__Question_Plain_Text__c;
//                             queResWrapper.ans = quesResult.ArdiraSurvey__Answer_Text__c;
//                         }
//                         else{
//                             ids.put(quesResult.id,quesResult.ArdiraSurvey__Question__r.ArdiraSurvey__Question_Plain_Text__c);
//                         }
//                         questionAnswerWrapperList.add(queResWrapper);
//                     }
//                 }
                
//                 if(!wrapperMap.isEmpty()){
//                     for(string str:wrapperMap.keyset()){
//                         response.intelProductQuesAndAnsList.add(wrapperMap.get(str));
//                     } 
//                 }
//                 if(!ids.isEmpty()){
//                     Map<String,String> mpqueMap=new Map<String,String>();
//                     String stringURL;
//                    // List<String> strAns =new List<String>();
//                     List<id> idlist=new List<id>(); 
//                     Map<Id,Id> listOFContentDocs=new Map<Id,Id>();
//                     List<Id> conId=new List<Id>();
//                     List<ContentDocumentLink> conDoc=[Select LinkedEntityId,ContentDocumentId,ContentDocument.Title from ContentDocumentLink where LinkedEntityId IN :Ids.keySet() Order by LinkedEntityId];
//                     for(ContentDocumentLink link:conDoc){
//                         conId.add(link.ContentDocumentId);
//                     } 
//                     List<ContentVersion> conVersion=[Select id,contentDocumentId from ContentVersion where contentDocumentId IN :conId];
//                     for(ContentVersion conver:conVersion){
//                         listOFContentDocs.put(conver.ContentDocumentId,conver.id);
//                     }
//                     Map<Id,List<String>> QSList=new Map<Id,List<String>>();
//                     for(ContentDocumentLink c:conDoc){ 
//                         idlist.add(c.LinkedEntityId);
//                         /*
//                         if(idlist[0]!=c.LinkedEntityId){
//                             strAns.clear();
//                         }*/
//                         String fileURL=Label.PSS_DownloadFileURLforSolutionPage;
//                         String fullFileURL = baseUrl + System.Label.PMP_CommunityURLSuffix + 'sfc/servlet.shepherd/version/download/' + listOFContentDocs.get(c.ContentDocumentId);
//                         stringURL  = '<a href='+fullFileURL+'>'+c.contentDocument.title+'</a>';
//                         if(QSList.containsKey(c.LinkedEntityId)){
//                             List<String> str= QSList.get(c.LinkedEntityId);
//                             str.add(stringURL);
//                             QSList.put(c.LinkedEntityId,str);
//                         }
//                         else{
//                             QSList.put(c.LinkedEntityId, new List<String>{stringURL});  
//                         }
//                        // strAns.add(stringURL);
//                         //stringURL=string.join(strAns,',\n');  
//                         stringURL=string.join(QSList.get(c.LinkedEntityId),',\n'); 
//                         mpqueMap.put(ids.get(c.LinkedEntityId),stringURL);
                        
//                     }
//                     QSList.clear();
                    
//                     if(mpqueMap!=null){
//                         for(String str:mpqueMap.keySet()){
//                             questionAnswerWrapper queAnsWrapper= new questionAnswerWrapper();
//                             queAnsWrapper.ques=str;
//                             queAnsWrapper.ans=mpqueMap.get(str);
//                             questionAnswerWrapperList.add(queAnsWrapper);
//                         }
//                     }
//                 }  
//                 response.questionAnsList.addAll(questionAnswerWrapperList);
                
//             }
//         }
//         response.surveyLogicalId = PMP_Utility.getValue('PSS_Survey_LogicalId');
//         response.surveyRecordId = PMP_Utility.getValue('PSS_Survey_RecordId');
        
//         if(PMP_Utility.isLoggedInUserAdmin()){
//             response.isAdmin=true;
//         }
//         else if(PSS_Utility.isLoggedInUserIsIntelEmployee()){
//             response.isEmployee=true;
//         }
//         else{ //OPEN:Need to check how to identify the partner user
//             response.isPartner=true;
//         }
//         if((response.isAdmin || response.isPartner|| response.isEmployee) && !surveyResultList.isEmpty()){
//             response.showEditable=editSolutionButtonCheck(response.isAdmin,response.resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
//             System.debug('Edit Button : '+response.showEditable);
//             response.showAddContact=addContactBtnVisibility(response.resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c);

//         }
//       /*  else if((response.isAdmin || response.isPartner) && !surveyResultList.isEmpty()){
            
//             response.showEditable=editSolutionButtonCheck(response.isAdmin,response.resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
//             response.showAddContact=addContactBtnVisibility(response.resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
//         }*/
//         return response;
//     }
    
//     public class partnerResponseWrapper{
//         @AuraEnabled
//         Public List<questionAnswerWrapper> questionAnsList= new List<questionAnswerWrapper>();
//         @AuraEnabled
//         Public List<intelProductQuesAndAnsWrapper> intelProductQuesAndAnsList=new List<intelProductQuesAndAnsWrapper>();
//         @AuraEnabled
//         Public ArdiraSurvey__Survey_Result__c resultRecord=new ArdiraSurvey__Survey_Result__c();
//         @AuraEnabled
//         Public String resultRecordName;
//         @AuraEnabled
//         Public Boolean isAdmin=false;
//         @AuraEnabled
//         Public Boolean isEmployee=false;
//         @AuraEnabled
//         Public Boolean isPartner=false;
//         @AuraEnabled
//         Public Boolean showEditable =false;
//         @AuraEnabled
//         Public List<String> statusValues =new List<String>();
//         @AuraEnabled
//         Public String surveyLogicalId;
//         @AuraEnabled
//         Public String surveyRecordId;
//         @AuraEnabled
//         Public Boolean showAddContact = false;
//         @AuraEnabled
//         Public String partnerRole;
//         @AuraEnabled
//         Public String submitterName;
//         @AuraEnabled
//         Public String submitterEmail;
//         @AuraEnabled
//         Public String partnerName;
//         //Added as part of TWC729-5748 - Ardira Package Update Issue Fix
//         @AuraEnabled
//         Public String logicalId;
//     }
    
//     public class questionAnswerWrapper{
//         @AuraEnabled
//         Public String ques;
//         @AuraEnabled
//         Public String ans;
        
        
//     }
//     public class intelProductQuesAndAnsWrapper{
//         @AuraEnabled
//         Public String ques;
//         @AuraEnabled
//         Public String ans;
//         @AuraEnabled
//         Public String comm;
//     }
//     @AuraEnabled
//     Public Static void submitAdminReview(ArdiraSurvey__Survey_Result__c resultRecord){
        
//         update resultRecord;
        
//     }
//     /**
// * @description Method to get visibility of edit button in solution detail page.
// * @param Boolean isAdmin, String Status
// * @returns Boolean
// **/
//     @AuraEnabled
//     Public Static Boolean editSolutionButtonCheck(Boolean isAdmin,String status){
//         //Boolean for edit solution button
//         Boolean isEditSolution=false;
//         Set<Id> idSet=new Set<Id>();
//         idSet.add(UserInfo.getUserId());// setting the current logged in user.
//         List<String> permissionSetList=new List<String>();
//         String permissionSet=PMP_Utility.getValue('PSS_PermissionSetAssignment');
//         permissionSetList=permissionSet.split(':');
//         // adding the permission set to the list
//         // passing the id,list<permissionset> to pssUtility.getUsersWithAssignedPermissionSet(id,list);
//         //to get the  assigned permission set to the logged in user.
//         List<PermissionSetAssignment> assignedList=PSS_Utility.getUsersWithAssignedPermissionSet(idSet,permissionSetList);
//         List<String> namesOfAssignedPermissionList= new  List<String>();
//         for(PermissionSetAssignment assignedPermission:assignedList){
//             namesOfAssignedPermissionList.add(assignedPermission.PermissionSet.name);
//         }
//         //To get the value from the custom metadata PMP_StaticData
//         String value=PMP_Utility.getValue('PSS_StatusOfSolution');   //Cancelled,Rejected,converted to MP Offering,Approved.
//         String valueForAdmin=PMP_Utility.getValue('PSS_StatusOfAdmin'); //Admin Review,on-hold,review scheduled
//         List<String> adminStatusList=new List<String>();
//         adminStatusList=valueForAdmin.split(':');
//         List<String> statusList=new List<String>();
//         statusList=value.split(':');// list to split the value which we get in custom metadata.
//         // Checks whether status is admin review
//         // checks whether logged in user in admin
//         if(adminStatusList.contains(status)){
//             if(isAdmin){
//                 isEditSolution=true;
//             }
//         }
//         //status not equal Apporoved,cancelled,converted to mp offerings,Rejected.
//         //checks for the assigned permission set of the current logged in user.
        
//         else if(!statusList.contains(status)){
//             if(namesOfAssignedPermissionList.size()>1 && status!=PSS_StaticConstants.RETIRED){
//                 isEditSolution=true;
//             }
//             else if(namesOfAssignedPermissionList.size()==1 && !namesOfAssignedPermissionList.contains('PMP_Internal_Intel_Read_Only') 
//                     && status!=PSS_StaticConstants.RETIRED){
//                 isEditSolution=true;
//             }
//         }
//         return isEditSolution;
//     }
//     /**
// * @description Method to get visibility of Add Contact button in solution detail page.
// * @param String Status
// * @returns Boolean
// **/
//     public static Boolean addContactBtnVisibility(String status) {
//         Boolean showAddContact = false;
//         if(status=='Draft' || status=='Update Required'){
//         Set<Id> idSet=new Set<Id>();
//         idSet.add(UserInfo.getUserId());// setting the current logged in user.
//         List<String> permissionSetList=new List<String>();
//         String permissionSet=PMP_Utility.getValue('PSS_PermissionSetAssignment');
//         permissionSetList=permissionSet.split(':');
//         // adding the permission set to the list
//         // passing the id,list<permissionset> to pssUtility.getUsersWithAssignedPermissionSet(id,list);
//         //to get the  assigned permission set to the logged in user.
//         List<PermissionSetAssignment> assignedList=PSS_Utility.getUsersWithAssignedPermissionSet(idSet,permissionSetList);
//         List<String> namesOfAssignedPermissionList= new  List<String>();
//         for(PermissionSetAssignment assignedPermission:assignedList){
//             namesOfAssignedPermissionList.add(assignedPermission.PermissionSet.name);
//         }
//         //To check the size of the list and if the logged user is only intel employee then add contact 
//         //button will not be visible.
//         if(namesOfAssignedPermissionList.size()==1 && !namesOfAssignedPermissionList.contains('PMP_Internal_Intel_Read_Only')){
//             showAddContact=true;
//         }
//         else if(namesOfAssignedPermissionList.size()>1){
//             showAddContact=true;
//         }         
//         }
//         return showAddContact;
//     }
    
//       /**
// * @description Method to get visibility of the solution in solution detail page.
// * @param  String recordId
// * @returns Boolean
// **/

//     @AuraEnabled
//     public static boolean accessSolutionRecord(String recordId){
//         Boolean isAccessSolution=false;
//         Set<Id> userId=new Set<Id>();
//         userId.add(userInfo.getUserId());
//         List<String> permissionSetList=new List<String>();
//         String permissionSet=PMP_Utility.getValue('PSS_PermissionSetAssignment');
//         permissionSetList=permissionSet.split(':');
//         List<PermissionSetAssignment> assignedList=PSS_Utility.getUsersWithAssignedPermissionSet(userId,permissionSetList);
//         List<String> namesOfAssignedPermissionList= new  List<String>();
//         for(PermissionSetAssignment assignedPermission:assignedList){
//             namesOfAssignedPermissionList.add(assignedPermission.PermissionSet.name);
//         }
//         //Check whether the logged user as access to the solution.
//         List<ArdiraSurvey__Survey_Result__Share> partnerSol=[SELECT AccessLevel,Id,ParentId,UserOrGroupId FROM ArdiraSurvey__Survey_Result__Share where parentId=:recordId and UserOrGroupId=:userInfo.getUserId()];  
//         if(!partnerSol.isEmpty()){
//             isAccessSolution=true;
//         }
//         //intel admin/intel employee should see all the solution submitted either by partner.
//         else if(namesOfAssignedPermissionList.contains('PMP_Internal_Intel_Admin') || namesOfAssignedPermissionList.contains('PMP_Internal_Intel_Read_Only')){
//             isAccessSolution=true;
//         }
//         return isAccessSolution;
//     }
    
//     @AuraEnabled
//     public static String getPartnerRole(Id recordId){
//         //list<solutionListWrapper> solutionWrap = new list<solutionListWrapper>();
//         partnerResponseWrapper partnerWrapper = new partnerResponseWrapper();
//         String partnerRole='';
//         String accountId;
//         //String roleName='';
//         Map<Id, String> accountIdMap = new Map<Id, String>();
//         List<ArdiraSurvey__Survey_Result__c> asr=[select id,PSS_OPID_Account_Id__c,PSS_Partner_Account_Id__c 
//                                                   from ArdiraSurvey__Survey_Result__c where id=:recordId];
//         for(ArdiraSurvey__Survey_Result__c surveyResult:asr){
//             accountId=String.isBlank(surveyResult.PSS_OPID_Account_Id__c)?surveyResult.PSS_Partner_Account_Id__c:surveyResult.PSS_OPID_Account_Id__c;
//             accountIdMap.put(surveyResult.Id, accountId);
//         }
//             if(accountIdMap != null && !accountIdMap.isEmpty()){
//                 List<Account> partnerRoleAccount=[select id,(select id, PRM_Status_Nm__c, toLabel(PRM_Partner_Role__c) from Channel_Memberships1__r)
//                                                   from Account where id=:accountIdMap.values()];
//                 for(Account acc:partnerRoleAccount){
//                     for(PRM_AccountChannelMembership__c acm:acc.Channel_Memberships1__r){
//                         if(acm.PRM_Status_Nm__c=='Approved'){
//                             partnerRole += acm.PRM_Partner_Role__c + ';';
//                         }
//                     }
//                     //partnerRole = roleName.removeEnd(';');
//                 }
//             }
       
//         return partnerRole.removeEnd(';'); 
//     }

}