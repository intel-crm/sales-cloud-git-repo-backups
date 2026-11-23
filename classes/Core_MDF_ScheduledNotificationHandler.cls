/****************************************************************************************************************************************
* Class Name        : Core_MDF_ScheduledNotificationHandler
* Test Class Name   : Core_MDF_SchNotificationHandler_Test
* Created Date      : 10/11/2020
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - AM       10/11/2020         Class to send emails to specific users based on permission set
* Ayush                12/18/2024         Added changes for "Reclaiming SF Partner License"
*****************************************************************************************************************************************/
public Without Sharing class Core_MDF_ScheduledNotificationHandler {
    public static Set<String> emailTemplateNameSet; 
     
    public static List<string> Intel_Owner_Based_Notification_Prog = Core_MDF_CCP_ConstantClass.Intel_Owner_Based_Notification_Prog; 
    public static List<string> IUPGM_Based_Notification_Prog = Core_MDF_CCP_ConstantClass.IUPGM_Based_Notification_Prog ;
    static {  
        emailTemplateNameSet = new Set<String>{'Core_MDF_Notify_RMF_Ext_User','Core_MDF_Notify_RMF_Int_User','Core_MDF_Notify_Int_Japan_Retailer','Core_MDF_Notify_Ext_Japan_Retailer'};
            }
    /*public static void notifyRMFUsers(Map<String,Id> pfrMap, Set<Id> japanRetailerAcctIds ,Set<Id> nonJapanRetailerAcctIds){
        
            Set<Id> accIdSet = new Set<Id>();
            Map<String,String> emailTemplateMap = new Map<String,String>();
            Map<Id,Boolean> acctCountryJPMap = new Map<Id,Boolean>();
            if(japanRetailerAcctIds != null && !japanRetailerAcctIds.isEmpty()){
                accIdSet.addAll(japanRetailerAcctIds);
            }
            if(nonJapanRetailerAcctIds != null && !nonJapanRetailerAcctIds.isEmpty()){
                accIdSet.addAll(nonJapanRetaileracctIds);
            }
        if(emailTemplateNameSet != null && !emailTemplateNameSet.isEmpty()){
              for(EmailTemplate template : [SELECT Id, Name, DeveloperName 
                                              FROM EmailTemplate 
                                              WHERE DeveloperName IN: emailTemplateNameSet]){
                                                  emailTemplateMap.put(template.DeveloperName, template.Id);
             }
            
        }
        Set<Id> userIdSet = new Set<Id>();
        if(accIdSet != NULL && accIdSet.Size() > 0){
                //Ayush - Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
            for(Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Id,Core_MDF_Account__c, Core_MDF_User__c 
                                                              FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                              WHERE Core_MDF_Account__c IN : accIdSet AND
                                                                  (Core_MDF_User__r.IsActive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE)]){                
                                                                  userIdSet.add(pnum.Core_MDF_User__c);
                                                                  if(japanRetailerAcctIds.contains(pnum.Core_MDF_Account__c)){
                                                                      acctCountryJPMap.put(pnum.Core_MDF_User__c,true);
                                                                  }
                                                                  if(nonJapanRetailerAcctIds.contains(pnum.Core_MDF_Account__c)){
                                                                      acctCountryJPMap.put(pnum.Core_MDF_User__c,false);
                                                                  }
                                                              }
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id,Core_MDF_Account_id__c,Core_MDF_User_id__c,Core_MDF_Active_Ind__c,Core_MDF_Account_id__r.Name
                                                                   FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                   WHERE Core_MDF_Account_id__c  IN: accIdSet AND 
                                                                   Core_MDF_is_User_Active_ind__c = TRUE AND
                                                                   Core_MDF_Active_Ind__c = TRUE AND
                                                                   (Core_MDF_Role_nm__c =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Custom_Permission_IAM_Retail')
                                                                    OR Core_MDF_Role_nm__c =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RMF_PRC_Claim_Operations'))]){ 
                                                                        userIdSet.add(iupgm.Core_MDF_User_id__c);
                                                                        if(japanRetailerAcctIds.contains(iupgm.Core_MDF_Account_id__c)){
                                                                            acctCountryJPMap.put(iupgm.Core_MDF_User_id__c,true);
                                                                        }
                                                                        if(nonJapanRetailerAcctIds.contains(iupgm.Core_MDF_Account_id__c)){
                                                                            acctCountryJPMap.put(iupgm.Core_MDF_User_id__c,false);
                                                                        }
                                                                    }   
            
        }
        
        Set<Id> userWithExternalPermissionSet = new Set<Id>();
        Set<Id> userWithInternalPermissionSet = new Set<Id>();
        Set<Id> internalUsersForJapanRetailer = new Set<Id>();
        Set<Id> externalUsersForJapanRetailer = new Set<Id>();
                             List<Messaging.SingleEmailMessage> emailTosendList= new List<Messaging.SingleEmailMessage>();
       Id recordIdJP ;
         Id recordIdNJP;
            if(pfrMap != null && pfrMap.containsKey('closeDateJP')){
                               recordIdJP = pfrMap.get('closeDateJP');
            }
           if(pfrMap != null && pfrMap.containsKey('closeDateNonJP')){
                               recordIdNJP = pfrMap.get('closeDateNonJP');
            }
                                     
        if(acctCountryJPMap != NULL  && acctCountryJPMap.size() > 0){
            for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, PermissionSet.Name 
                                                  FROM PermissionSetAssignment WHERE AssigneeId IN :acctCountryJPMap.keySet() 
                                                  AND (PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Approver') 
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Ext_RMF_Claim_Submitter')  
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Custom_Permission_IAM_Retail')
                                                       OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RMF_PRC_Claim_Operations')) ]){
                                                           
                                                           if(usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Ext_RMF_Claim_Submitter')|| 
                                                              usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Approver')){
                                                                  if(acctCountryJPMap.containsKey(usrPer.AssigneeId) && acctCountryJPMap.get(usrPer.AssigneeId) && !externalUsersForJapanRetailer.contains(usrPer.AssigneeId)){
                                                                      externalUsersForJapanRetailer.add(usrPer.AssigneeId);
                                                                                                                                                                                                                                                       emailTosendList.add(createEmailInstanceTarget(recordIdJP,emailTemplateMap.get('Core_MDF_Notify_Ext_Japan_Retailer'),usrPer.AssigneeId));
                                                                  }
                                                                  if(acctCountryJPMap.containsKey(usrPer.AssigneeId) && acctCountryJPMap.get(usrPer.AssigneeId) == false && !userWithExternalPermissionSet.contains(usrPer.AssigneeId)){
                                                                      userWithExternalPermissionSet.add(usrPer.AssigneeId);
                                                                                                                                                                                                                                                        emailTosendList.add(createEmailInstanceTarget(recordIdNJP,emailTemplateMap.get('Core_MDF_Notify_RMF_Ext_User'),usrPer.AssigneeId));
                                                                  }
                                                              }
                                                           if(usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Custom_Permission_IAM_Retail')||
                                                              usrPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_RMF_PRC_Claim_Operations')){
                                                                  if(acctCountryJPMap.containsKey(usrPer.AssigneeId) && acctCountryJPMap.get(usrPer.AssigneeId) && !internalUsersForJapanRetailer.contains(usrPer.AssigneeId)){
                                                                      internalUsersForJapanRetailer.add(usrPer.AssigneeId);
                                                                                                                                                                                                                                                        emailTosendList.add(createEmailInstanceTarget(recordIdJP,emailTemplateMap.get('Core_MDF_Notify_Int_Japan_Retailer'),usrPer.AssigneeId));
                                                                  }
                                                                  if(acctCountryJPMap.containsKey(usrPer.AssigneeId) && acctCountryJPMap.get(usrPer.AssigneeId) == false && !userWithInternalPermissionSet.contains(usrPer.AssigneeId)){
                                                                      userWithInternalPermissionSet.add(usrPer.AssigneeId);
                                                                                                                                                                                                                                                          emailTosendList.add(createEmailInstanceTarget(recordIdNJP,emailTemplateMap.get('Core_MDF_Notify_RMF_Int_User'),usrPer.AssigneeId));
                                                                  }
                                                              }
                                                           
                                                       }

        }
   
                             
        
        
        if(emailTosendList != NULL && emailTosendList.size() >0){
            Core_MDF_GenericClassToSendMail.sendEmails(emailTosendList);
        }
    }*/
    public static void notifyIPAUsers (Set<Id> pfraccIdSet , Set<Id> pfrultimateAccIds,List<Partnerfundrequest> pfrs, String notificationType){
        
        Set<Id> intExtUserIdSet = new Set<Id>();
        Set<String> remainderNotifyTemplateSet = Core_MDF_CCP_ConstantClass.ipaReminderEmailTemplates;
        String allAccountYes = Core_MDF_CCP_ConstantClass.allAccountYes;
         String ipaClaimSubmitterPS = Core_MDF_CCP_ConstantClass.ipaClaimSubmitterPS;
        List<Messaging.SingleEmailMessage> emailTosendList= new List<Messaging.SingleEmailMessage>();
        id pfrid =pfrs[0].id;
        Map<String,String> emailTemplateMap = new Map<String,String>();   
        Set<Id> iupgmUserIdSet = new Set<Id>();
        String pfrObjectNameForEmailPreferences = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailPreferenceObject_PFR');
        if(remainderNotifyTemplateSet != null && !remainderNotifyTemplateSet.isEmpty()){
            for(EmailTemplate template : [SELECT Id, Name, DeveloperName 
                                          FROM EmailTemplate 
                                          WHERE DeveloperName IN: remainderNotifyTemplateSet]){                                                
                                              emailTemplateMap.put(template.DeveloperName, template.Id);
                                          }
        }
        
        
        
        if(pfraccIdSet != NULL && !pfraccIdSet.isEmpty()){           
            //Ayush - Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
            for(Core_MDF_Partner_Node_User_Mapping__c pnum :[SELECT Id,Core_MDF_Account__c, Core_MDF_User__c,Core_MDF_User__r.Id 
                                                             FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                             WHERE Core_MDF_Account__c IN : pfraccIdSet AND
                                                              Core_MDF_Active_Ind__c = TRUE AND
                                                             (Core_MDF_User__r.IsActive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE)]){
                                                                 
                                                                     intExtUserIdSet.add(pnum.Core_MDF_User__c);
                                                                
                                                             }
        }
        if(pfrultimateAccIds != NULL && !pfrultimateAccIds.isEmpty()){
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id,Core_MDF_Account_id__c,Core_MDF_User_id__c,Core_MDF_Active_Ind__c,Core_MDF_Account_id__r.Name
                                                                       FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                       WHERE (Core_MDF_Account_id__c  IN: pfrultimateAccIds OR 
                                                                       Core_MDF_All_Accounts_cd__c =:allAccountYes) AND 
                                                                       Core_MDF_Role_nm__c =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Account_Manager_PS') AND
                                                                       Core_MDF_is_User_Active_ind__c = TRUE AND
                                                                       Core_MDF_Active_Ind__c = TRUE
                                                                      ]){
                                                                          //intExtUserIdSet.add(iupgm.Core_MDF_User_id__c);
                                                                          iupgmUserIdSet.add(iupgm.Core_MDF_User_id__c);
            }
            if(iupgmUserIdSet!=null && iupgmUserIdSet.size()>0 && notificationType != Null && pfrObjectNameForEmailPreferences != Null){
                List<Id> fiteredIupgmUserIdLst = Core_MDF_SubUnsub_Notifications_Utility.filterUserBasedOnSubscription(notificationType,pfrObjectNameForEmailPreferences,iupgmUserIdSet);
                if(fiteredIupgmUserIdLst != null && fiteredIupgmUserIdLst.size() > 0){
                    for(Id userId : fiteredIupgmUserIdLst){
                        intExtUserIdSet.add(userId);
                    }
                } 
            }
            else{
                intExtUserIdSet.addAll(iupgmUserIdSet);
            }

        }
        Set<id> userIdSet = new Set<Id>();

        if(intExtUserIdSet!= Null && !intExtUserIdSet.isEmpty()) {
            for(PermissionSetAssignment userPer : [SELECT Id, AssigneeId, Assignee.AccountId, Assignee.IsActive, PermissionSet.Name 
                                                   FROM PermissionSetAssignment WHERE AssigneeId IN :intExtUserIdSet 
                                                   AND (PermissionSet.Name =:ipaClaimSubmitterPS 
                                                        OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_IPA_Proposal_Manager')  
                                                        OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_IPA_Activity_Manager')
                                                        OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Account_Manager_PS')
                                                       )]) {
                                                           if(!userIdSet.contains(userper.AssigneeId)) {
                                                                 if(userPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Account_Manager_PS')) {
                                                               
                                                               emailTosendList.add(createEmailInstanceTarget(pfrid,emailTemplateMap.get('Core_MDF_IPA_ReminderNotification'),userper.AssigneeId));
                                                           }
                                                           if(userPer.PermissionSet.Name == 'Core_MDF_CCP_External_IPA_Claim_Submitter' || 
                                                              userPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_IPA_Proposal_Manager') ||
                                                              userPer.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_IPA_Activity_Manager')) {
                                                                  emailTosendList.add(createEmailInstanceTarget(pfrid,emailTemplateMap.get('Core_MDF_IPA_ReminderNotification_Ext'),userPer.AssigneeId));
                                                              }
                                                              userIdSet.add(userper.AssigneeId);
                                                           }


                                                       }
            
        }
       
        if(emailTosendList != NULL && !emailTosendList.isEmpty()) {
            List<Messaging.SendEmailResult> res= Core_MDF_GenericClassToSendMail.sendEmails(emailTosendList);
             
        }             
    } 
    public static Messaging.SingleEmailMessage createEmailInstanceTarget(Id recordId, Id templateId,String setTargetObjectId){
                             return Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(recordId,templateId,setTargetObjectId);   
    }
    /*Method to get receipents to get notified on PIC Completion , Claim Score and on Paid Claims */
    Public static ResultWrapper getUsersToSendMail(InputWrapper inputWrap) {
        Set<Id> internalUserIds = new Set<Id>();
        Set<Id> externalUserIds = new Set<Id>();
        ResultWrapper resultWrap = new ResultWrapper();
            
        Set<Id> userIdSet = inputWrap.userId;
        Set<Id> accIdSet = inputWrap.accountIdSet;
        Set<string> progBudgetTypeKeySet = inputWrap.progBTSet;
        Set<string> progSetInt = inputWrap.programSetInt;
        Set<string> progSetExt = inputWrap.programSetExt;
        Boolean isNotifyInternalUsers = inputWrap.isNotifyInternalUsers;
        Boolean isNotifyExternalUsers = inputWrap.isNotifyExternalUsers;
        List<String> externalRoleToCheck = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Program_To_ClaimSubmitterRole').split(',');
        //To get Internal Role name to query on IUPGM based Incoming Program and Budget type for CCF/DCF and based on Incoming Program for IPA/RMF
        Set<String> eligibleRoles = getInternalRoleName(progSetInt , progBudgetTypeKeySet);
        
        if(isNotifyInternalUsers){
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm: [SELECT Id,Core_MDF_User_id__c
                                                                  FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c
                                                                  WHERE (Core_MDF_Account_id__c  IN: accIdSet OR Core_MDF_All_Accounts_cd__c = 'Yes')  
                                                                  AND Core_MDF_Role_nm__c =: eligibleRoles
                                                                  AND (Core_MDF_Channel_Program_id__r.Name IN: progSetInt 
                                                                  AND ((Core_MDF_Channel_Program_id__r.Name IN:Intel_Owner_Based_Notification_Prog AND Core_MDF_User_id__c IN :userIdSet) 
                                                                       OR Core_MDF_Channel_Program_id__r.Name IN:IUPGM_Based_Notification_Prog))
                                                                  AND Core_MDF_is_User_Active_ind__c = TRUE
                                                                  AND Core_MDF_Active_Ind__c = TRUE]){
                                                                     internalUserIds.add(iupgm.Core_MDF_User_id__c); 
                                                                  }
        }
        
        if(isNotifyExternalUsers){
            Set<Id> channelPartnerIdSet = inputWrap.channelPartnerIdSet;
            //To get External Claim submitter Role to query on Permission set Assignment for user based on Incoming program
           
            //Ayush - Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
            for(Core_MDF_Partner_Node_User_Mapping__c pnum :[SELECT Id,Core_MDF_Account__c, Core_MDF_User__c
                                                             FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                             WHERE Core_MDF_Account__c IN : channelPartnerIdSet
                                                             AND Core_MDF_Active_Ind__c = TRUE 
                                                             AND (Core_MDF_User__r.IsActive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE)
                                                             AND Core_MDF_User__c IN (SELECT AssigneeId 
                                                                                       FROM PermissionSetAssignment 
                                                                                       WHERE PermissionSet.Name IN:externalRoleToCheck)]) {
                                                                 externalUserIds.add(pnum.Core_MDF_User__c);
                                                             }
         
        }
        
        resultWrap.internalUsers = internalUserIds;
        resultWrap.externalUsers = externalUserIds;
        
        return resultWrap;
    }
    /*Method to get Internal user permission set based on Incoming Program and Budget Type */
    Public static set<String> getInternalRoleName(set<String> progSetInt , set<String> progBudgetTypeKeySet) {
        Map<string,string> progTechNameToLabelMap = new Map<string,string>();
        String RMF_PROGRAM = Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
        set<String> roles = new set<String>();
        for(Core_MDF_ChannelProgram__mdt cpm : [SELECT Core_MDF_Abbreviated_ProgramName_txt__c, MasterLabel,Core_MDF_Technical_Program_Name__c
                                                 FROM Core_MDF_ChannelProgram__mdt
                                                 WHERE Core_MDF_Abbreviated_ProgramName_txt__c != null]) { 
                                                     progTechNameToLabelMap.put(cpm.Core_MDF_Technical_Program_Name__c, cpm.MasterLabel);
                                                 } 
        if(!progTechNameToLabelMap.isEmpty()){
        for(Core_MDF_Program_Budget_RecordType__mdt mdtConfiq: [SELECT Id,Core_MDF_Program__c, Core_MDF_Account_Manager_PS_API_Name__c, Core_MDF_BudgetType__c 
                                                                FROM Core_MDF_Program_Budget_RecordType__mdt 
                                                                WHERE Core_MDF_Account_Manager_PS_API_Name__c != NULL ]){
                                                                    string ProgName = progTechNameToLabelMap.get(mdtConfiq.Core_MDF_Program__c);
                                                                    
                                                                    if(progSetInt.contains(ProgName)) {
                                                                        string progBTKey = ProgName + mdtConfiq.Core_MDF_BudgetType__c;
                                                                        if(Intel_Owner_Based_Notification_Prog.contains(ProgName) && progBudgetTypeKeySet.contains(progBTKey)) {
                                                                            roles.add(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c);
                                                                        }else if(IUPGM_Based_Notification_Prog.contains(ProgName) && progBudgetTypeKeySet.contains(ProgName) ) {
                                                                            roles.add(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c);
                                                                            if(ProgName == RMF_PROGRAM){
                                                                                roles.add(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_PRC_ClaimSubmitter'));
                                                                            }
                                                                           
                                                                        }
                                                                    } 
                                                                }
        }
        return roles;

    }
   Public class InputWrapper {
        Public Set<Id> userId = new Set<Id>() ;
        Public Set<Id> accountIdSet =  new Set<Id>();
        Public Map<string,string> progTechNameToLabelMap = new Map<String,String>();
        Public Set<string> progBTSet =  new Set<String>();
        Public Set<string> programSetInt =  new Set<String>();
        Public Set<String> programSetExt = new set<String> ();
        Public Set<Id> channelPartnerIdSet =  new Set<Id>();
        Public boolean isNotifyInternalUsers = false;
        Public boolean isNotifyExternalUsers = false;
    }
    
    
    
    Public class ResultWrapper {
        Public Set<Id> internalUsers = new Set<Id>();
        Public Set<Id> externalUsers = new Set<Id>();
    }

}