/****************************************************************************************************************************************
* Class Name  : Core_MDF_PIC_SendEmailToClaimOwner 
* Version     : 1.0 
* Created Date: 12/22/2021
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – JB              12/22/2021                    Send email notification to the Claim owner when the Claim status is 'Resubmission required'
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PIC_SendEmailToClaimOwner {
    //to store node account ids referred on claims
    public static Set<Id> nodeAccountIds = new Set<Id>();

    //to store node account group ids referred on claims
    public static Set<Id> nodeAccountGroupIds = new Set<Id>();

    //to store claim id and it's node account id
    public static Map<Id,Id> claimIdtoNodeAccGrpIdMap = new Map<Id,Id>();

    //to store node acc group id and List of user ids 
    public static Map<Id,List<String>> nodeAccGrpIdUserIdMap = new Map<Id,List<String>>();

   //to store claim id and List of user ids
    public static Map<Id,List<String>> claimIdtoUserIdMap = new Map<Id,List<String>>();

    //to store Group id and Claim Id (node acc)
    public static Map<Id,List<Id>> accGroupIdtoClaimIdsMap = new Map<Id,List<Id>>();

    //to indicate if email is for claim owner or account manager
    public static boolean isEmailforInternalAccMng = false;
    public static string stdUsrType = Core_MDF_CCP_ConstantClass.Std_UserType;

    //added for IPA OutcomeBased claims
    public static String ipaProram = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
    // added for adding adding reminder in subject
    public static boolean addReminderInSubject = false;
   
   /****************************************************************************************************************************************
   Method Name:                                             sendEmailtoClaimOwnerOnResubReqd
   @return  :                                               --
   @parameters:                                             List of Ids                                 
   Description:                                             Send email notification to the Claim owner when the Claim Status is 'Resubmission Required'
   Added By:                                                Accenture – JB  -  12/22/2021
   Modified By:                  Date:                      Changes: 
   Accenture – Jahnavi K             2/26/2024              Pic Main Question-Sub Question Changes
   *****************************************************************************************************************************************/ 
   @InvocableMethod
   public static void sendEmailtoClaimOwnerOnResubReqd(List<NotificationWrapper> inputList) {

       //To By-pass the method execution
       if(Core_MDF_Utility.byPassFeature('Core_MDF_PIC_SendEmailToClaimOwner')){
           return;
       }

      //Notification wrapper
       List<Id> claimId = new List<Id>();
       Boolean notifyPartnerUser = false;

        for (NotificationWrapper input : inputList) {
            if (input.claimIds != null) {
                claimId.add(input.claimIds);
            }
            notifyPartnerUser = (input.notifyPartnerUser == true) ? input.notifyPartnerUser : notifyPartnerUser;
            addReminderInSubject = (input.addReminderInSubject == true) ? input.addReminderInSubject : addReminderInSubject;          

            //break;//need first record
        }

       //Creating List of Email Instance
       List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
       List<Messaging.SingleEmailMessage> emailListforClmOwner = new List<Messaging.SingleEmailMessage>();
       List<Messaging.SingleEmailMessage> emailListforAM = new List<Messaging.SingleEmailMessage>();
       
       //Map to srore Claim Id with Claim Owner Id(key:Claim Id value: Claim Owner Id)
       Map<Id,Id> claimIdToOwnerIdMap = new Map<Id,Id>();
       
       //Map to store User Id and LanguageLocaleKey, UserType
       Map<Id,User> claimOwnerToUserMap = new Map<Id,User>();
       
       
       //Map to store Claim Id with Claim Reference Number(key:Claim Id Value: Claim Reference Number)
       Map<Id,String> claimIdtoClaimRefNumberMap = new Map<Id,String>();

       //Map to store Claim Id with Claim Name(key:Claim Id Value: Claim Name)
       Map<Id,String> claimIdtoClaimName = new Map<Id,String>();

       //Map to store Claim Id with Legacy Detail(key:Claim Id Value: isLegacy)
       Map<Id,Boolean> claimIdtoLegacyDetailsMap = new Map<Id,Boolean>();
       
       //Map to store Claim Id with highest Cycle number(key:Claim Id Value: Maximum Cycle Number)
       Map<Id,Integer> claimWithCycleNumberMap = new Map<Id,Integer>();

       //To store metadata records
       Map<String,Core_MDF_Email_Translation_Resub_Reqd__mdt> languageAndTranslationMap = new Map<String,Core_MDF_Email_Translation_Resub_Reqd__mdt>();
       
       //Map to store the Claim Id with respective core_MDF_PICReviewResult__c
       Map<Id,List<core_MDF_PICReviewResult__c>> claimIdToPicReviewResultMap = new Map<Id,List<core_MDF_PICReviewResult__c>>();
       
       //to store node acc id and user id (acc manager)
       Map<Id,List<Id>> nodeAccIdUserMap = new Map<Id,List<Id>>();
       
       //to store main question and sub question 
        Map<id,List<core_MDF_PICReviewResult__c>> mainQuestionIdtoSubQuestionMap = new Map<id,List<core_MDF_PICReviewResult__c>>();
       
       //to store excluded user id list
       List<Id> excludedUserIdList = new List<Id>();
       List<Core_MDF_FlowMapClass> excludedUserIdWrapperList = new List<Core_MDF_FlowMapClass>();            
       List<Core_MDF_SubUnsub_Notifications_Utility.MailParams> mailParamsWrapperList = new List<Core_MDF_SubUnsub_Notifications_Utility.MailParams>();
       Set<String> responeString = Core_MDF_CCP_ConstantClass.picQuestionResponses;

        //Roshan - added for IPA OutcomeBased claims
        Boolean isOutcomeBasedClaim = false;
        Map<Id, String> claimIdToRegion = new Map<Id, String>();
        Map<Id, Id> claimIdToUltimateAcc = new Map<Id, Id>();
        Set<Id> claimIds = new Set<Id>();
        Map<Id, List<String>> claimIdToOutcomeBasedManagers = new Map<Id, List<String>>();
        boolean notifyPartnerCheck = false;//Swati - added notifyPartnerCheck             

       try{
             //To get the PIC Review Result based on Claim Id
            List<Core_MDF_PICReviewResult__c> picReviewResultsList = new List<Core_MDF_PICReviewResult__c>();
            picReviewResultsList = [SELECT Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Claim_Ref_Number__c,Core_MDF_Question_id__c, Core_MDF_Question_id__r.Core_MDF_Parent_Question__c,Core_MDF_Question_id__r.Core_MDF_Sub_Question_Ind__c,
                                    Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.OwnerId, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Request.Title,Core_MDF_FilesAffected_txt__c, 
                                                   Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_Start_Date__c,
                                                   Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_End_Date__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_Types__c,
                                                   Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Country_Location_nm__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Status__c,
                                                   Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_SubType_nm__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Program__c,
                                                   Core_MDF_Response_txt__c, Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c,Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_AccountCompany__c,
                                                   Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Legacy_Reminder_txt__c,Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Document_Submission_DueDate_dtm__c,
                                                   Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Legacy_Claim_Ind__c, Core_MDF_Question_id__r.Core_MDF_Sort_Order__c, Core_MDF_Issue_English_txt__c,
                                                   Core_MDF_Issue_German_txt__c, Core_MDF_Issue_Italian_txt__c, Core_MDF_Issue_Japanese_txt__c,
                                                   Core_MDF_Issue_Korean_txt__c, Core_MDF_Issue_Spanish_txt__c, Core_MDF_Issue_French_txt__c,
                                                   Core_MDF_Issue_MexicanSpanish_txt__c, Core_MDF_IssuePortuguese_txt__c, Core_MDF_IssueRussian_txt__c,
                                                   Core_MDF_Issue_SimplifiedChinese_txt__c, Core_MDF_Issue_TraditionalChinese_txt__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.ChannelPartnerId, 
                                                   Core_MDF_Comment_txt__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Ultimate_Account_Id__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Region_Cd__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Ad_Run_Start_Date__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Ad_Run_End_Date__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Amount, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Activity_Number__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Campaign_Id__r.Core_MDF_Host_Region_cd__c,
                                                   Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.ChannelPartner.Core_MDF_Group_Id__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Title, Core_MDF_Tactic_txt__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_OutcomeBased_Ind__c, Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Host_Region_txt__c
                                                   FROM core_MDF_PICReviewResult__c   //Roshan
                                                   WHERE Core_MDF_Response_txt__c  IN: responeString  AND Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c IN: claimId AND Core_MDF_PIC_Review_id__r.Core_MDF_AI_PIC_Review_Ind__c = false
                                    ORDER BY Core_MDF_Question_id__r.Core_MDF_Sort_Order__c];
                //To get the PIC Review Result based on Claim Id
                if(picReviewResultsList != null && picReviewResultsList.size() > 0) {
                    for(core_MDF_PICReviewResult__c result : picReviewResultsList){  
                                                       //To add the Claim Id with respective PIC Review Result records
                                                       if(claimIdToPicReviewResultMap.containskey(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c)){
                                                           claimIdToPicReviewResultMap.get(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c).add(result);
                                                       }else{
                                                           claimIdToPicReviewResultMap.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c,new List<core_MDF_PICReviewResult__c>{result});
                                                       }
                                                       //To add the Claim Id with owner Id
                                                       if(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r != null)
                                                           claimIdToOwnerIdMap.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c, result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.OwnerId);
                                                       //To add Claim Id with Claim Reference Number
                                                       if(String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c)){
                                                           claimIdtoClaimRefNumberMap.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c, result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Claim_Ref_Number__c);
                                                           claimIdtoClaimName.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c,result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Title);
                                                           //To add claim id with respective node acc id : claimIdtoNodeAccIdMap
                                                           if(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Program__c == Label.Core_MDF_Retail_Program_Name)
                                                               claimIdtoNodeAccGrpIdMap.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c,result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.ChannelPartner.Core_MDF_Group_Id__c);
                                                               if(accGroupIdtoClaimIdsMap.containsKey(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.ChannelPartner.Core_MDF_Group_Id__c)){
                                                                   accGroupIdtoClaimIdsMap.get(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.ChannelPartner.Core_MDF_Group_Id__c).add(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c);
                                                               }else {
                                                                   accGroupIdtoClaimIdsMap.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.ChannelPartner.Core_MDF_Group_Id__c,new List<Id>{result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c});
                                                               }
                                                       }
                                                       //To add Claim Id with Legacy Details
                                                       claimIdtoLegacyDetailsMap.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c, result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Legacy_Claim_Ind__c);

                                                       //To add Claim Id with highest Cycle Number
                                                       if(claimWithCycleNumberMap.containskey(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c)){
                                                           if(claimWithCycleNumberMap.get(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c) < result.Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c){
                                                               claimWithCycleNumberMap.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c, Integer.valueOf(result.Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c));
                                                           }
                                                       }else{
                                                           claimWithCycleNumberMap.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c, Integer.valueOf(result.Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c));
                                                       }

                                                        //added for IPA OutcomeBased claims
                                                        isOutcomeBasedClaim = result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_OutcomeBased_Ind__c && result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Program__c == ipaProram;  //Roshan
                                                        if (isOutcomeBasedClaim) {
                                                            if (!claimIdToUltimateAcc.containsKey(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c)) {
                                                                claimIdToUltimateAcc.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c, result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Ultimate_Account_Id__c);
                                                            }
                                                            if (!claimIdToRegion.containsKey(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c)) {
                                                                claimIdToRegion.put(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c, result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Host_Region_txt__c);  //Roshan
                                                            }
                                                            claimIds.add(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c); 
                                                        }

                                                    }
                    
                }
            
            //construct Main Subquestion Id to Sub question Map for the Latest PIC cycle
            for(core_MDF_PICReviewResult__c picReview : picReviewResultsList) {
                if(String.isNotBlank(String.valueOf(picReview.Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c)) 
                    && picReview.Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c == claimWithCycleNumberMap.get(picReview.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__c)
                   && picReview.Core_MDF_Question_id__r.Core_MDF_Sub_Question_Ind__c == true)
                {
                    if(mainQuestionIdtoSubQuestionMap.containsKey(picReview.Core_MDF_Question_id__r.Core_MDF_Parent_Question__c)){
                        mainQuestionIdtoSubQuestionMap.get(picReview.Core_MDF_Question_id__r.Core_MDF_Parent_Question__c).add(picReview);
                    }else if(!mainQuestionIdtoSubQuestionMap.containsKey(picReview.Core_MDF_Question_id__r.Core_MDF_Parent_Question__c)){
                        mainQuestionIdtoSubQuestionMap.put(picReview.Core_MDF_Question_id__r.Core_MDF_Parent_Question__c,new List<core_MDF_PICReviewResult__c>{picReview});
                    }
                }
            }
	    
            //Roshan - added for IPA OutcomeBased claims
            //Swati - added notifyPartnerCheck
            if (isOutcomeBasedClaim && !notifyPartnerUser) {
                claimIdToOutcomeBasedManagers = getOutcomeBasedAccountManagers(claimIds, claimIdToRegion, claimIdToUltimateAcc);
            }

           //set of node account ids reffered on claim
           if(!accGroupIdtoClaimIdsMap.isEmpty()){
               nodeAccountGroupIds.addAll(accGroupIdtoClaimIdsMap.keySet());
               //getRMFAccManagers:  get Map of Node Account Ids to List of User Emails
               if(!nodeAccountGroupIds.isEmpty())
                   getRMFAccManagers(nodeAccountGroupIds); 
               //Prepare a map of claim id to list of user email ids based on node acc id
               if(!claimIdtoNodeAccGrpIdMap.isEmpty() && !nodeAccGrpIdUserIdMap.isEmpty()){
                   for(Id clm: claimIdtoNodeAccGrpIdMap.keySet()){
                       List<String> userIds = nodeAccGrpIdUserIdMap.get(claimIdtoNodeAccGrpIdMap.get(clm));
                       claimIdtoUserIdMap.put(clm, userIds);
                   }
               }
           }
           //To get the user LanguageLocaleKey
           for(User claimOwner : [SELECT Id, UserType, LanguageLocaleKey FROM User WHERE Id IN: claimIdToOwnerIdMap.values()]){
               claimOwnerToUserMap.put(claimOwner.Id, claimOwner);
           }
           
           String issue = '';
           String filesAttached = '';          

           //To get the fields based on Language Local Key from Custom metadata.
           for(Core_MDF_Email_Translation_Resub_Reqd__mdt record : Core_MDF_Email_Translation_Resub_Reqd__mdt.getAll().values()){
               if(String.isNotBlank(record.Core_MDF_LanguageLocalKey__c)){
                   languageAndTranslationMap.put(record.Core_MDF_LanguageLocalKey__c, record);
               }
           }
           //Create object and notification type list
           String claimObjForEmailPreferences = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailPreferenceObjectClaim');
           String notificationType =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_NotificationType_PIC_FAIL');    
           
           List<String> notificationTypeList = new List<String>{notificationType};
           
           List<String> objectTypeList = new List<String>{claimObjForEmailPreferences};
           
           //Create Subscription mailparams wrapper
           Core_MDF_SubUnsub_Notifications_Utility.MailParams paramsWrapper= new  Core_MDF_SubUnsub_Notifications_Utility.MailParams();
           paramsWrapper.notificationName = notificationTypeList ;
           paramsWrapper.objectName = objectTypeList;

           mailParamsWrapperList.add(paramsWrapper);
           
           //Call Subscription utility class to get excluded users Id list. //change below var name like excluded user list
           List<List<Core_MDF_FlowMapClass>> excludedUserWrapperResult = Core_MDF_SubUnsub_Notifications_Utility.getExcludedUserList(mailParamsWrapperList);
           
           if(excludedUserWrapperResult != null && excludedUserWrapperResult.size() > 0) {
                excludedUserIdWrapperList = excludedUserWrapperResult[0]; 
               if(excludedUserIdWrapperList != null && excludedUserIdWrapperList.size() > 0) {
                    excludedUserIdList = excludedUserIdWrapperList[0].userIdList;
               }
               
           }
          
            //added for IPA OutcomeBased claims - block method call for outcome claims
            //added notifyPartnerUser
            if (!isOutcomeBasedClaim||(isOutcomeBasedClaim && notifyPartnerUser == true)) {
                emailListforClmOwner = getEmailContent(claimIdToPicReviewResultMap,languageAndTranslationMap, claimOwnerToUserMap, claimWithCycleNumberMap, 
                            claimIdtoClaimRefNumberMap,claimIdtoClaimName,claimIdtoLegacyDetailsMap,claimIdToOwnerIdMap,isEmailforInternalAccMng,excludedUserIdList,mainQuestionIdtoSubQuestionMap,isOutcomeBasedClaim,null,notifyPartnerUser);
                if(!emailListforClmOwner.isEmpty()){
                    emailList.addAll(emailListforClmOwner);
                }
            }

          if(!claimIdToOutcomeBasedManagers.isEmpty() || !claimIdtoUserIdMap.isEmpty()){//Swati
           isEmailforInternalAccMng = true;
           }
           //added for IPA OutcomeBased claims
           //added notifyPartnerUser
           if(isEmailforInternalAccMng && !notifyPartnerUser){
           emailListforAM = getEmailContent(claimIdToPicReviewResultMap,languageAndTranslationMap, claimOwnerToUserMap, claimWithCycleNumberMap, 
                                                claimIdtoClaimRefNumberMap,claimIdtoClaimName,claimIdtoLegacyDetailsMap,claimIdToOwnerIdMap,isEmailforInternalAccMng,excludedUserIdList,mainQuestionIdtoSubQuestionMap,isOutcomeBasedClaim,claimIdToOutcomeBasedManagers,notifyPartnerUser);
           if(!emailListforAM.isEmpty()){
               emailList.addAll(emailListforAM);
               }
           }
           
           //Send Emails only if emailList has values
           if(!emailList.isEmpty()){
               Messaging.sendEmail(emailList);
           }
       }catch(Exception e){
           Core_MDF_CCP_UtilityClass.logErrorinLogObject(Core_MDF_CCP_UtilityClass.getErrorDetails(e),'Exception occured in sendEmailtoClaimSubmitter method');
       }
   }

   /****************************************************************************************************************************************
   Method Name:                                             getEmailContent
   @return  :                                               --
   @parameters:                                             List of Ids                                 
   Description:                                             Prepare Email Content to be sent based on userType, language
   Added By:                                                Accenture – NB  -  05/14/2024
   Modified By:                  Date:                      Changes: 
   Accenture – Jahnavi K              02/26/2025            Pic Main and Sub Question Changes
   *****************************************************************************************************************************************/ 
   public static List<Messaging.SingleEmailMessage> getEmailContent(Map<Id,List<core_MDF_PICReviewResult__c>> claimIdToPicReviewResultMap, Map<String,Core_MDF_Email_Translation_Resub_Reqd__mdt> languageAndTranslationMap,
                                      Map<Id,User> claimOwnerToUserMap, Map<Id,Integer> claimWithCycleNumberMap, Map<Id,String> claimIdtoClaimRefNumberMap,Map<Id,String> claimIdtoClaimName,
                                      Map<Id,Boolean> claimIdtoLegacyDetailsMap, Map<Id,Id> claimIdToOwnerIdMap, Boolean isEmailforInternalAccMng, List<Id> excludedUserIdList,Map<Id,List<core_MDF_PICReviewResult__c>> mainQuestionIdtoSubQuestionMap,Boolean isOutcomeBasedClaim,Map<Id, List<String>> claimIdToOutcomeBasedManagers, Boolean notifyPartnerUser){  //added notifyPartnerUser
       List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        //Iterate over list of claims
        for(Id claimId : claimIdToPicReviewResultMap.keySet()){
           Set<String> langSet = new Set<String>{'en_US'};
           String languageKey = '';
           String usertype = '';
           String programName = '';
           String budgetType = '';
           String activityName = '';
           String activityStartDate = '';
           String activityEndDate = '';
           String activityType = '';
           String activitySubtype = '';
           String accountName = '';
           String country = '';
           Datetime closureDate;
           String legacyReminder = '';
           String claimStatus = '';
           Boolean isFirstResultRecord = true;
           String tableContent = '';
           String issue = '';
           String parentIssue = '';
           String childIssue = '';
           String parentfilesAttached = '';
           String childfilesAttached = '';
	   
           String executionStartDate = '';
           String executionEndDate = '';
           String reimbursementAmt = '';
           String activityNumber = '';
           String requestId = '';

           //Iterate over list of PIC Review Result
           for(core_MDF_PICReviewResult__c result : claimIdToPicReviewResultMap.get(claimId)){

               //Allow only the highest cycle number PIC Review Result records for a Claim
               if(String.isNotBlank(String.valueOf(result.Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c)) && result.Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c == claimWithCycleNumberMap.get(claimId)){
                   
                   //To get the LanguageLocaleKey
                   if(isFirstResultRecord){
                       //If the user Language not available in the metadata assign default as English
                       languageKey = claimOwnerToUserMap.get(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.OwnerId).LanguageLocaleKey;
                       languageKey = languageAndTranslationMap.containsKey(languageKey) ? languageKey :'en_US';
                       userType = claimOwnerToUserMap.get(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.OwnerId).UserType;
                       if(isEmailforInternalAccMng){
                           languageKey = 'en_US';
                           userType = stdUsrType;
                       }

                       programName = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Program__c) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Program__c : '';
                       budgetType = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Budget_Type_Options_Nm__c) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Budget_Type_Options_Nm__c : '';
                       activityName = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Request?.Title) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Request?.Title : '';
                       activityStartDate = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_Start_Date__c.format()) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_Start_Date__c.format() : '';
                       activityEndDate = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_End_Date__c.format()) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_End_Date__c.format() : '';
                       activityType = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_Types__c) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_Types__c : '';
                       activitySubtype = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_SubType_nm__c) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Activity_SubType_nm__c.replace(';',', ') : '';
                       accountName = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_AccountCompany__c) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_AccountCompany__c : '';
                       country = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Country_Location_nm__c) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Country_Location_nm__c : '';
                       closureDate = result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Document_Submission_DueDate_dtm__c != null ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Document_Submission_DueDate_dtm__c: null;
                       legacyReminder = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Legacy_Reminder_txt__c) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Legacy_Reminder_txt__c : '';
                       claimStatus = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Status__c) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Status__c : '';

                       //added for IPA OutcomeBased claims
                       executionStartDate = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Ad_Run_Start_Date__c.format()) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Ad_Run_Start_Date__c.format() : '';
                       executionEndDate = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Ad_Run_End_Date__c.format()) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Core_MDF_Ad_Run_End_Date__c.format() : '';
                       reimbursementAmt = (result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Amount != null) ? String.valueOf(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Amount) : '';
                       activityNumber = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Activity_Number__c) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.Request.Core_MDF_Activity_Number__c : '';
                       requestId = String.isNotBlank(result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.RequestId) ? result.Core_MDF_PIC_Review_id__r.Core_MDF_Claim_ID_id__r.RequestId : '';

 
                       tableContent = '<tr style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;"><th style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;width:500px">'
                       + languageAndTranslationMap.get(languageKey).Core_MDF_Issue__c + (isOutcomeBasedClaim ? ('<th style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + System.Label.get('', 'Core_MDF_Activity_Tactics', languageKey) + '</th>') : '') +  //Roshan - Tactics notification
                        '</th><th style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + languageAndTranslationMap.get(languageKey).Core_MDF_Files_Affected__c + 
                       '</th>' + (isOutcomeBasedClaim ? ('<th style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + System.Label.get('', 'Core_MDF_IPA_Comments', languageKey) + '</th>') : '') + '</tr>';

                       isFirstResultRecord = false;

                   }

                   String emailLanguage = languageAndTranslationMap.containsKey(languageKey) && String.isNotBlank(String.valueOf(result.get(languageAndTranslationMap.get(languageKey).Core_MDF_PIC_Review_Result_Field_Name__c))) ? languageAndTranslationMap.get(languageKey).Core_MDF_PIC_Review_Result_Field_Name__c :'Core_MDF_Issue_English_txt__c'; 
                   //Add the issue based on Claim owner LanguageLocaleKey
                    if(result.Core_MDF_Question_id__r.Core_MDF_Parent_Question__c == null && result.Core_MDF_Question_id__r.Core_MDF_Sub_Question_Ind__c == false){
                        if(mainQuestionIdtoSubQuestionMap.containsKey(result.Core_MDF_Question_id__c) 
                        && !mainQuestionIdtoSubQuestionMap.get(result.Core_MDF_Question_id__c).isEmpty()){
                            //iterate over the subquestions and add the issue based on claim owner language key
                            for(core_MDF_PICReviewResult__c subResult :mainQuestionIdtoSubQuestionMap.get(result.Core_MDF_Question_id__c)){
                                if(String.isNotBlank(String.valueOf(subResult.Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c)) && subResult.Core_MDF_PIC_Review_id__r.Core_MDF_CycleNumber_nbr__c == claimWithCycleNumberMap.get(claimId)){

                                    //Roshan - Tactics notification
                                    String childCommentsProvided = '';
                                    String childTacticsProvided = '';  

                                    childIssue =  String.valueOf(subResult.get(emailLanguage));
                                    if(childIssue.contains('\n')){ 
                                        childIssue = childIssue.replace('\n','<br/>');
                   }
                                    if(String.isNotBlank(subResult.Core_MDF_FilesAffected_txt__c)){
                                        childfilesAttached = subResult.Core_MDF_FilesAffected_txt__c.replace(';',', ');
                   }else{
                                        childfilesAttached = languageAndTranslationMap.get(languageKey).Core_MDF_Not_Applicable__c;
                   }
                                    if (isOutcomeBasedClaim) {
                                        childTacticsProvided = subResult.Core_MDF_Tactic_txt__c;
                                        childCommentsProvided = subResult.Core_MDF_Comment_txt__c;
                                    }
                                    
                                    tableContent += '<tr style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;"><td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + childIssue + '</td>';

                                    //Roshan - Tactics notification
                                    if (isOutcomeBasedClaim) {
                                        tableContent += '<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + childTacticsProvided + '</td>';
                                    }

                                    tableContent += '<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + childfilesAttached + '</td>';  

                                    //Roshan - Tactics notification
                                    if (isOutcomeBasedClaim) {
                                        tableContent += '<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + childCommentsProvided + '</td>';
                                    }

                                    tableContent += '</tr>';
                                }
                                
                                childIssue = '';
                                childfilesAttached = ''; 
                            }
                        }else{
                            parentIssue =  String.valueOf(result.get(emailLanguage));
			    
                            String parentTacticsProvided = ''; 
                            String commentsProvided = ''; 
			    
                            if(parentIssue.contains('\n')){ 
                                parentIssue = parentIssue.replace('\n','<br/>');
                            }
                            tableContent += '<tr style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;"><td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">'
                            + parentIssue + '</td>';
                            if (isOutcomeBasedClaim) {
                                parentTacticsProvided = result.Core_MDF_Tactic_txt__c;
                                tableContent += '<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + parentTacticsProvided + '</td>';
                            }
                            if(String.isNotBlank(result.Core_MDF_FilesAffected_txt__c)){
                                parentfilesAttached = result.Core_MDF_FilesAffected_txt__c.replace(';',', ');
                            }else{
                                parentfilesAttached = languageAndTranslationMap.get(languageKey).Core_MDF_Not_Applicable__c;
                                }
                                tableContent += '<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + parentfilesAttached + '</td>';

                                if (isOutcomeBasedClaim) {
                                    commentsProvided = result.Core_MDF_Comment_txt__c;
                                    tableContent += '<td style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + commentsProvided + '</td>';
                                }
                                tableContent += '</tr>';
                        }
                    }
               }
               parentIssue = '';
               parentfilesAttached = '';
            }
   
           //Claim Details

            String claimDetails = '<ul>' + 
            (String.isNotBlank(accountName) ? (isOutcomeBasedClaim ? ('<li>' + System.Label.get('', 'Core_MDF_IPA_EmailTemp_Field1', languageKey) + ' ' + accountName + '</li>') : ((userType != Label.Core_MDF_Partner_User_Type) ? ('<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_Account__c + ' ' + accountName + '</li>') : '')) : '') +
            '<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_MailSubject1__c + ': ' + claimIdtoClaimRefNumberMap.get(claimId) + '</li>' +
            '<li>' + System.Label.get('', 'Core_MDF_EmailTemp_AdjReq_Create_Body3', languageKey) + (isOutcomeBasedClaim ? ' <a href="' + ((userType == Label.Core_MDF_Partner_User_Type) ? Label.Core_MDF_PFRCommunityLink : (URL.getOrgDomainUrl().toExternalForm() + '/'))  + claimId + '">' + claimIdtoClaimName.get(claimId) + '</a>' : ' ' + claimIdtoClaimName.get(claimId)) + '</li>' +
            (isOutcomeBasedClaim ? ((String.isNotBlank(executionStartDate) ? '<li>' + System.Label.get('', 'Core_MDF_Ad_Run_Start_Date_Help', languageKey) + ': ' + executionStartDate + '</li>' : '') + 
            (String.isNotBlank(executionEndDate) ? '<li>' + System.Label.get('', 'Core_MDF_Ad_Run_End_Date_Help', languageKey)+ ': ' + executionEndDate + '</li>' : '') + 
            (String.isNotBlank(reimbursementAmt) ? '<li>' + System.Label.get('', 'Core_MDF_Reimbursement_Amount_email', languageKey) + ': $' + reimbursementAmt + '</li>' : '') +
            (String.isNotBlank(activityNumber) ? '<li>' + System.Label.get('', 'Core_MDF_ActivityNumber', languageKey)+ ': '  + activityNumber + '</li>' : '')) : '') +
            (String.isNotBlank(activityName) ? ('<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_Activity_Name__c + (isOutcomeBasedClaim ? ' <a href="'+ ((userType == Label.Core_MDF_Partner_User_Type) ? Label.Core_MDF_PFRCommunityLink : (URL.getOrgDomainUrl().toExternalForm() + '/')) + requestId + '">' + activityName + '</a>' : ' ' + activityName) + '</li>') : '') +
            (!isOutcomeBasedClaim ? ((String.isNotBlank(activityType) ? '<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_Activity_Type__c + ' ' + activityType + '</li>' : '') +
            (String.isNotBlank(activitySubtype) ? '<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_Activity_Subtype__c + ' ' + activitySubtype + '</li>' : '') +
            (String.isNotBlank(activityStartDate) ? '<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_Activity_Start_Date__c + ' ' + activityStartDate + '</li>' : '') +
            (String.isNotBlank(activityEndDate) ? '<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_Activity_End_Date__c + ' ' + activityEndDate + '</li>' : '') +
            (String.isNotBlank(country) ? '<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_Country_Region__c + ' ' + country + '</li>' : '') +
            (String.isNotBlank(programName) ? '<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_Program__c + ' ' + programName + '</li>' : '')) : '') +
            (String.isNotBlank(budgetType) ? ('<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_Budget_Type__c + ' ' + budgetType  + '</li>') : '') +
            (!isOutcomeBasedClaim ? ((String.isNotBlank(String.valueOf(closureDate)) ? '<li><span style="color: red;"><medium>' + (claimIdtoLegacyDetailsMap.get(claimId) ? languageAndTranslationMap.get(languageKey).Core_MDF_Due_Date__c : languageAndTranslationMap.get(languageKey).Core_MDF_Claimin_Window_Closure_Date__c) + ' ' + String.valueOf(closureDate.formatGMT('EEE MMM dd HH:mm:ss z yyyy')) + '</medium></span></li>' : '') +
            ('<li>' + languageAndTranslationMap.get(languageKey).Core_MDF_Document_Submission_Link__c + ' <a href="' + ((userType == Label.Core_MDF_Partner_User_Type) ? Label.Core_MDF_PFRCommunityLink : (URL.getOrgDomainUrl().toExternalForm() + '/')) + claimId + '">' + claimIdtoClaimRefNumberMap.get(claimId) + '</a></li>')) : '') +
            '</ul>';


       
       //Partner User Footer Contents
       String partnerUserFooter = '<div style="font-size:11px;font-family:Calibri"><p><i>' +  languageAndTranslationMap.get(languageKey).Core_MDF_MailFooter1__c +
           '<a href = "' + Label.Core_MDF_EmailTemp_Claim_HyperLink_Customer_Support + '"> ' + languageAndTranslationMap.get(languageKey).Core_MDF_MailFooter2__c + ' </a>' +
           languageAndTranslationMap.get(languageKey).Core_MDF_MailFooter3__c + '<br/><br/></i>' + languageAndTranslationMap.get(languageKey).Core_MDF_MailFooter4__c + 
           '<a href = "' + Label.Core_MDF_EmailTemp_Claim_HyperLink_Customer_Support + '"> ' + languageAndTranslationMap.get(languageKey).Core_MDF_MailFooter2__c +  ' </a>' +
           languageAndTranslationMap.get(languageKey).Core_MDF_MailFooter5__c + '<br/><br/>' + 
           '<a href = "' + Label.Core_MDF_EmailTemp_Claim_HyperLink_Home + '">' + languageAndTranslationMap.get(languageKey).Core_MDF_MailFooter6__c + '</a> | ' + 
           '<a href = "' + Label.Core_MDF_EmailTemp_Claim_HyperLink_Trademarks + '">' + languageAndTranslationMap.get(languageKey).Core_MDF_MailFooter7__c + '</a> | ' + 
           '<a href = "' + Label.Core_MDF_EmailTemp_Claim_HyperLink_Privacy + '">' + languageAndTranslationMap.get(languageKey).Core_MDF_MailFooter8__c + '</a> | ' +
           '<a href = "' + Label.Core_MDF_EmailTemp_Claim_HyperLink_Cookies + '">' + languageAndTranslationMap.get(languageKey).Core_MDF_MailFooter9__c + '</a></i></p></div>';

      
       //Email body Content
        String emailBody = '<html><head><style>table,td,th{border: 1px solid black;border-collapse: collapse;padding: 3px 15px;}</style></head><body><div style="font-size:14px;font-family:Calibri"><div style="color:red;">' + 
        languageAndTranslationMap.get(languageKey).Core_MDF_Action_Required__c + '</div><br/>' + ((userType == Label.Core_MDF_Partner_User_Type) ? languageAndTranslationMap.get(languageKey).Core_MDF_Greetings_External__c : languageAndTranslationMap.get(languageKey).Core_MDF_Greetings_Internal__c) + 
        '<br/><br/>' + (claimStatus == Label.Core_MDF_Claim_Status_Paid_and_Resubmission_Required ? languageAndTranslationMap.get(languageKey).Core_MDF_Post_Payment_Body_Content1__c : (isOutcomeBasedClaim ? System.Label.get('', 'Core_MDF_Claim_EmailTemp_Body5', languageKey) : languageAndTranslationMap.get(languageKey).Core_MDF_MailBody4__c)) + (isOutcomeBasedClaim ? '' : (' ' + (closureDate != null ? closureDate.formatGMT('EEE MMM dd HH:mm:ss z yyyy') : '') + languageAndTranslationMap.get(languageKey).Core_MDF_MailBody5__c)) + '<br/>' + claimDetails + (claimStatus == Label.Core_MDF_Claim_Status_Paid_and_Resubmission_Required ? languageAndTranslationMap.get(languageKey).Core_MDF_Post_Payment_Body_Content2__c : (isOutcomeBasedClaim ? '' : languageAndTranslationMap.get(languageKey).Core_MDF_MailBody15__c)) + '<br/><br/>' + '<table style="border: 1px solid black;border-collapse: collapse;padding: 3px 15px;">' + tableContent + '</table>' +
        (isOutcomeBasedClaim ? ('<br/><br/><a href="'+ ((userType == Label.Core_MDF_Partner_User_Type) ? Label.Core_MDF_PFRCommunityLink : (URL.getOrgDomainUrl().toExternalForm() + '/')) + claimId  + '">' + System.Label.get('', 'Core_MDF_Click_here', languageKey) + '</a> ' + (!notifyPartnerUser ? System.Label.Core_MDF_Claim_EmailTemp_Body6 : System.Label.get('', 'Core_MDF_Claim_EmailTemp_Body2', languageKey))) : '')+ '<br/>' + (isOutcomeBasedClaim ? '<br/>' + System.Label.get('', 'Core_MDF_PleaseContact', languageKey) + ' <a href="mailto:payment.clearance.team@intel.com">' + System.Label.get('', 'Core_MDF_ContactPaymentTeam', languageKey) + '</a>' : '')+ '<br/><br/>' + languageAndTranslationMap.get(languageKey).Core_MDF_Thank_You__c + '<br/><br/>' + Label.Core_MDF_Email_Signature 
        + '<br/><img src="' + Label.Core_MDF_Intel_Logo_URL + '" alt="Intel Logo" width="120" height="48" />'
        + partnerUserFooter + '</div></body></html>';//added notifyPartnerUser

       //SubjectLine1 based on notification type(Immediate, 1st Reminder, 2nd Reminder)
       String subjectLine1 = String.isNotBlank(legacyReminder) ? (legacyReminder == Label.Core_MDF_Legacy_Reminder_2 ? languageAndTranslationMap.get(languageKey).Core_MDF_Reminder1_Subject__c : 
           (legacyReminder == Label.Core_MDF_Legacy_Reminder_3 ? languageAndTranslationMap.get(languageKey).Core_MDF_Reminder2_Subject__c : languageAndTranslationMap.get(languageKey).Core_MDF_MailSubject1__c )) : languageAndTranslationMap.get(languageKey).Core_MDF_MailSubject1__c;
           
           //Single Email
           Core_MDF_GenericClassToSendMail.HtmlEmailParams htmlEmailWrapper = new Core_MDF_GenericClassToSendMail.HtmlEmailParams();
           List<String> userIdsforWrapper = new List<String>();
           List<List<String>> usersList = new List<List<String>>();
           List<String> finalUserIdList = new List<String>();
           String targetObjectId;
           if(isEmailforInternalAccMng && !notifyPartnerUser){
                //added for IPA OutcomeBased claims
                if (!claimIdToOutcomeBasedManagers.isEmpty() && claimIdToOutcomeBasedManagers.keySet().contains(claimId)) {
                    userIdsforWrapper = claimIdToOutcomeBasedManagers.get(claimId);
                } else if(!claimIdtoUserIdMap.isEmpty() && claimIdtoUserIdMap.keySet().contains(claimId)){
                    userIdsforWrapper = claimIdtoUserIdMap.get(claimId);
                    //targetObjectId = userIdsforWrapper[0];
                }

            }else{
                if(!isOutcomeBasedClaim || (notifyPartnerUser && isOutcomeBasedClaim)) { //added notifyPartnerUser
                 userIdsforWrapper = new List<String>{claimIdToOwnerIdMap.get(claimId)};
                    //targetObjectId = claimIdToOwnerIdMap.get(claimId);
                }

                   
            }

            //Check whether user has unsubscribed for a notification or not. If not then add to the final UserId list.
           for(String userId : userIdsforWrapper) {
                if(excludedUserIdList != null && !excludedUserIdList.contains(userId)) {
                    finalUserIdList.add(userId);
                }
                
            }
       
         if(!finalUserIdList.isEmpty()) {
           targetObjectId =  finalUserIdList[0];    
           htmlEmailWrapper.userIds = finalUserIdList;
           htmlEmailWrapper.saveAsActivity = false;
           htmlEmailWrapper.targetObjectId = targetObjectId;
           htmlEmailWrapper.orgWideEmailAddressId = Label.Core_MDF_OrgWideId;

           //Roshan - added for IPA OutcomeBased claims
           htmlEmailWrapper.subject =(isOutcomeBasedClaim && addReminderInSubject) ? 
    (System.Label.get('', 'Core_MDF_VAT_EmailSubject_Reminder', languageKey) + ' ' + accountName + ' ' + System.Label.get('', 'Core_MDF_RecoveryClaimStatus', languageKey) + ': ' + System.Label.get('', 'Core_MDF_PIC_Review_Pending_Account_Manager_Clarification', languageKey)) : isOutcomeBasedClaim ? (accountName + ' ' + System.Label.get('', 'Core_MDF_RecoveryClaimStatus', languageKey) + ': ' + System.Label.get('', 'Core_MDF_PIC_Review_Pending_Account_Manager_Clarification', languageKey)) : (subjectLine1 + claimIdtoClaimRefNumberMap.get(claimId) + ': ' + claimIdtoClaimName.get(claimId) + ' - ' + ((claimStatus == Label.Core_MDF_Claim_Status_Paid_and_Resubmission_Required) ? (languageAndTranslationMap.get(languageKey).Core_MDF_Post_Payment_MailSubject2__c) : (languageAndTranslationMap.get(languageKey).Core_MDF_MailSubject2__c)));
           htmlEmailWrapper.emailBody = emailBody;
           if(String.isNotBlank(String.valueOf(closureDate)) && closureDate.getTime() > System.now().getTime())
               emailList.addAll(Core_MDF_GenericClassToSendMail.createEmailInstaceforHtmlBody(htmlEmailWrapper));
            } 
            
           
       }
       return emailList;
   }
/****************************************************************************************************************************************
   Method Name:                                             getRMFAccManagers
   @return  :                                               --
   @parameters:                                             List of Ids                                 
   Description:                                             Prepare Map of Node Account Ids to List of UserIds
   Added By:                                                Accenture – NB  -  05/14/2024
   Modified By:                  Date:                      Changes: 
   Accenture – NB              05/14/2024                   Created.
   Roshan                      06/02/2025                   Partner License Reclaim
   *****************************************************************************************************************************************/ 
   public static void getRMFAccManagers(Set<Id> accGroupIdSet){
       //to store users who belong to the group 
       List<GroupMember> userGroups = new List<GroupMember>();
       try{
       
       userGroups = [select id, UserOrGroupId, UserOrGroup.IsActive,  GroupId from GroupMember where GroupId in :accGroupIdSet and (UserOrGroup.IsActive=true or UserOrGroup.Partner_License_Reclaimed__c = true)];              
       
       if((!userGroups.isEmpty() && userGroups != NULL && userGroups.Size() > 0)){
           for(GroupMember gMemb: userGroups){
               if((nodeAccGrpIdUserIdMap != null && nodeAccGrpIdUserIdMap.containsKey(gMemb.GroupId))){
                   nodeAccGrpIdUserIdMap.get(gMemb.GroupId).add(gMemb.UserOrGroupId);
               }else{
                   nodeAccGrpIdUserIdMap.put(gMemb.GroupId,new List<String>{gMemb.UserOrGroupId});
               }
           }
       }
   }
       catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}                                                    
   }

    /****************************************************************************************************************************************
     Method Name:                                           getOutcomeBasedAccountManagers
    @return  :                                              List of IPA Account Managers
    @parameters:                                            claimId, set of claimIds to region, set of claimIds to ultimateAccId                
    Added By:                                               Accenture – RP - 16/08/2025
    Modified By:                  Date:                     Changes:
    *****************************************************************************************************************************************/ 
    public static Map<Id, List<String>> getOutcomeBasedAccountManagers(Set<Id> claimIds, Map<Id, String> claimIdToRegion, Map<Id, Id> claimIdToUltimateAcc) {

        Map<Id, List<String>> claimIdToManagers = new Map<Id, List<String>>();
        String programName = ipaProram;
        String role = System.Label.Core_MDF_CCP_Internal_IPA_Acct_Mgr_PS;
        String category = Core_MDF_CCP_ConstantClass.CLAIM_APPROVAL_MAPPING;
        List<String> permissionSetNameList = new List<String>{'Core_MDF_CCP_Internal_IPA_Acct_Mgr'};

        try {
            List<String> programList = new List<String>{programName};
            List<String> regionList = new List<String>();
            List<String> ultimateAccList = new List<String>();

            for (Id claimId : claimIds) {
                regionList.add(claimIdToRegion.get(claimId));
                ultimateAccList.add(String.valueOf(claimIdToUltimateAcc.get(claimId)));
            }

            Map<String, Map<String, List<Id>>> resultMap = Core_MDF_GeneralPurpose_UI_Utility.getIupgmRecordsForApprovers(ultimateAccList, programList, regionList, permissionSetNameList, category);

            if (resultMap != null && resultMap.containsKey(role)) {

                for (Id claimId : claimIds) {
                    String region = claimIdToRegion.get(claimId);
                    Id ultimateAcc = claimIdToUltimateAcc.get(claimId);

                    String allAccountNOKey = programName + region + role + String.valueOf(ultimateAcc);
                    String allAccountNOKeyWW  = programName + 'WW' + role + String.valueOf(ultimateAcc);
                    String allAccountYesKey = programName + region + role + 'null';
                    String allAccountYesKeyWW = programName + 'WW' + role + 'null';

                    Set<String> uniqueUsers = new Set<String>();

                    for (String key : resultMap.get(role).keySet()) {
                        if (key == allAccountNOKey || key == allAccountNOKeyWW || key == allAccountYesKey || key == allAccountYesKeyWW) {
                            for (Id uId : resultMap.get(role).get(key)) {
                                uniqueUsers.add(String.valueOf(uId));
                            }
                        }
                    }

                    if (!uniqueUsers.isEmpty()) {
                        claimIdToManagers.put(claimId, new List<String>(uniqueUsers));
                    }
                }
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }

        return claimIdToManagers;
    }

    //Added wrapper class to utilize in Core_MDF_PIC_SendEmailToClaimOwner
     public class NotificationWrapper {
        @InvocableVariable(required=true)
        public Id claimIds;

        @InvocableVariable(required=false)
        public Boolean notifyPartnerUser = false;
     
        @InvocableVariable(required=false)
        public Boolean addReminderInSubject = false;

    }



}