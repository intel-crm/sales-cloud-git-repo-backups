/****************************************************************************************************** 
Class Name:         Core_MDF_SendPFREmailNotification
@parameters:        N/A
Description:        
Added By:           Saikat      09-23-2022
Modified By:        Ayush       12-18-2024  -  Added changes for "Reclaiming SF Partner License"
                    Ramapriya   07-25-2025  -  Added changes for IPA In-Progress Activity Edit
*******************************************************************************************************/
public without sharing class Core_MDF_SendPFREmailNotification{
    public static Boolean isSendEmailOnce = true;
    public static Boolean isSendEmailOnceForOpalNotification = true;
    public static Set<String> emailTemplateNameSet; 
    static {  
        emailTemplateNameSet = new Set<String>{'Core_MDF_ExternalStatusChange', 'Core_MDF_StatusUpdate_Internal',
                                               'Core_MDF_RMF_StatusUpdate', 'Core_MDF_StatusUpdate_GeoApprovers'};
    }
    
    /****************************************************************************************************** 
    Method Name:        pfrStatusChangeEmail
    @return  :          void
    @parameters:        NewPFRList and OldPfrMap
    Description:        
    Added By:           Saikat   09-23-2022
    Modified By:        Ayush    12-18-2024  -  Added changes for "Reclaiming SF Partner License"
    *******************************************************************************************************/
    public static void pfrStatusChangeEmail(List<PartnerFundRequest> newPFRList, Map<Id, PartnerFundRequest> oldPfrMap){
        //Akash changes
        List<PartnerFundRequest> filteredPFRList = new List<PartnerFundRequest>();
        for(PartnerFundRequest pfr : newPFRList) {
            // Skip sub-activities (outcome-based sub-activities)
            if(pfr.Core_MDF_Activity_Level_nm__c != 'Sub Activity') {
                filteredPFRList.add(pfr);
            }
        }
        
        // If no activities to process after filtering, return early
        if(filteredPFRList.isEmpty()) {
            return;
        }
        Map<String, String> emailTemplateMap = new Map<String, String>();
        Map<String, User> userMap = new Map<String, User>();
        Set<String> userIds = new Set<String>();
        List<Messaging.SingleEmailMessage> emailToSendList = new List<Messaging.SingleEmailMessage>();
        for(EmailTemplate template : [SELECT Id, Name, DeveloperName FROM EmailTemplate 
                                      WHERE DeveloperName IN: emailTemplateNameSet]){
                emailTemplateMap.put(template.DeveloperName, template.Id);
        }
        if(oldPfrMap != null){
            for(PartnerFundRequest newPfr: filteredPFRList){
                userIds.add(newPfr.createdByID);
                if(newPfr.Core_MDF_Activity_First_Approver_txt__c != null && 
                   newPfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')){
                    userIds.add(newPfr.Core_MDF_Activity_First_Approver_txt__c);
                }
            }
        } 
        for(User createdByUser: [SELECT Id, IsActive, UserType, Partner_License_Reclaimed__c  FROM User WHERE Id IN: userIds]){
                userMap.put(createdByUser.Id, createdByUser);
        }
        if(oldPfrMap != null){
            for(PartnerFundRequest pfr: filteredPFRList){
                String userType = userMap.get(pfr.CreatedById).UserType;
                //Ayush - Created below boolean to check if activity's created by user is manually deactivated for "Reclaiming SF Partner License"
                Boolean isPartnerLiscenceReclaimed = userMap.get(pfr.CreatedById).Partner_License_Reclaimed__c; 
                //Ayush - Created below boolean to check if activity's created by user is active or is manually deactivated else set to false and passing as paramater to sendEmailToExtUser method for "Reclaiming SF Partner License"
                Boolean isUserActive = userMap.get(pfr.CreatedById).IsActive == true ? true : isPartnerLiscenceReclaimed == true ? true : false;
                
                /* Action: Send Email  
                   Program: CCF,DCF,CCFB,SPCF,IPA(AccountBased)  
                   RecipientUserType: External
                   EmailTemplate: Core_MDF_ExternalStatusChange */
                   // ATHR Avoid long parameter lists - US 14285 - Indira
                EmailDecisionContext ctx = new EmailDecisionContext(pfr, oldPfrMap, userType, isUserActive);
                if(sendEmailToExtUser(ctx)){
                    emailToSendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(pfr.Id, emailTemplateMap.get('Core_MDF_ExternalStatusChange'), pfr.createdByID));
                }
                /* Action: Send Email 
                   Program: CCF,DCF,CCFB,SPCF,IPA(AccountBased) 
                   UserType: Internal
                   EmailTemplate: Core_MDF_StatusUpdate_Internal */
                else if(sendEmailToIntUser(ctx)){
                    emailToSendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(pfr.Id, emailTemplateMap.get('Core_MDF_StatusUpdate_Internal'), pfr.createdByID));
                }
                else if(pfr.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')) {
                    /* Action: Send Email 
                       Program: RMF 
                       UserType: Internal
                       EmailTemplate: Core_MDF_RMF_StatusUpdate */
                    if(sendEmailToRMFIntUser(ctx)){
                        emailToSendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(pfr.Id, emailTemplateMap.get('Core_MDF_RMF_StatusUpdate'), pfr.createdByID));
                    }
                    //Ayush - added the below code to check if Activity First Approver is active or is Partner License Reclaimed
                    Boolean isActivityFirstApproverActive = false;
                    if(userMap.containsKey(pfr.Core_MDF_Activity_First_Approver_txt__c)) {
                        User approverUser = userMap.get(pfr.Core_MDF_Activity_First_Approver_txt__c);
                        isActivityFirstApproverActive = (approverUser.IsActive == true) || (approverUser.Partner_License_Reclaimed__c == true);
                    }
                    /* Action: Send Email
                       Program: RMF 
                       UserType: Internal(Geo Approvers)
                       EmailTemplate: Core_MDF_StatusUpdate_Cloned */
                    if(pfr.Core_MDF_Activity_First_Approver_txt__c != null && sendEmailToRMFGeoApproversUser(pfr, oldPfrMap, isActivityFirstApproverActive)){
                        emailToSendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(pfr.Id, emailTemplateMap.get('Core_MDF_StatusUpdate_GeoApprovers'), pfr.Core_MDF_Activity_First_Approver_txt__c));
                    }
                }
            }
        }
        try{
            if(!emailToSendList.isEmpty() && isSendEmailOnce){
                Core_MDF_GenericClassToSendMail.sendEmails(emailToSendList);
                isSendEmailOnce = false;
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    /****************************************************************************************************** 
    Wrapper:            EmailDecisionContext
    Purpose  :          Avoid long parameter lists for email decision helpers
    *******************************************************************************************************/
    // ATHR Avoid long parameters list US 14285 - Indira 
    public class EmailDecisionContext {
        public PartnerFundRequest pfr;
        public Map<Id, PartnerFundRequest> oldPfrMap;
        public String userType;
        public Boolean isUserActive;
        public EmailDecisionContext(PartnerFundRequest pfr,
                                    Map<Id, PartnerFundRequest> oldPfrMap,
                                    String userType,
                                    Boolean isUserActive) {
            this.pfr = pfr;
            this.oldPfrMap = oldPfrMap;
            this.userType = userType;
            this.isUserActive = isUserActive;
        }
    }

    /****************************************************************************************************** 
    Method Name:        sendEmailToExtUser
    @return  :          Boolean
    @parameters:        EmailDecisionContext ctx
    Description:        
    Added By:           Saikat      10-07-2022
    Modified By:        Ramapriya   07-25-2025  Added status check as part of In-progress Activity Edit 
                       
    *******************************************************************************************************/
    // ATHR Avoid long parameter lists - US 14285 - Indira
    public static Boolean sendEmailToExtUser(EmailDecisionContext ctx){
        PartnerFundRequest pfr = ctx.pfr;
        Map<Id, PartnerFundRequest> oldPfrMap = ctx.oldPfrMap;
        String userType = ctx.userType;
        Boolean isUserActive = ctx.isUserActive;

        Boolean isSendEmail = false;
        // EOL - Commented below Condition associated with channel MDF Program                                        
        if(pfr.Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')
           /*&& pfr.Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_MDF_Program')*/
           && (pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Revision_Required') && pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_InProgress_Revision_Required') )
           && (String.isNotBlank(pfr.Core_MDF_PriorValueStatusForExternalUser__c) && pfr.Core_MDF_PriorValueStatusForExternalUser__c != oldPfrMap.get(pfr.Id).Core_MDF_PriorValueStatusForExternalUser__c)
           && pfr.Core_MDF_Proposal_Based_Ind__c == false && isUserActive && userType == 'PowerPartner'){
            isSendEmail = true;
        }
        return isSendEmail;
    }
    /****************************************************************************************************** 
    Method Name:        sendEmailToIntUser
    @return  :          Boolean
    @parameters:        EmailDecisionContext ctx
    Description:        
    Added By:           Saikat      10-07-2022
    Modified By:        Ramapriya   07-25-2025  Added status check as part of In-progress Activity Edit  
                      
    *******************************************************************************************************/
    // ATHR Avoid long parameter lists - US 14285 - Indira
    public static Boolean sendEmailToIntUser(EmailDecisionContext ctx){
        PartnerFundRequest pfr = ctx.pfr;
        Map<Id, PartnerFundRequest> oldPfrMap = ctx.oldPfrMap;
        String userType = ctx.userType;
        Boolean isUserActive = ctx.isUserActive;

        Boolean isSendEmail = false;
        // EOL - Commented below Condition associated with channel MDF Program                                        
        if(pfr.Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Program_Name')
           /*&& pfr.Core_MDF_Program__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Channel_MDF_Program')*/
           && pfr.Core_MDF_Fund_Request_Status__c != oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c
           && (pfr.Core_MDF_Fund_Request_Status__c != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm') && pfr.Core_MDF_Fund_Request_Status__c!= Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_InProgress_Pending_Approval') )
           && pfr.Core_MDF_Proposal_Based_Ind__c == false && isUserActive && userType == 'Standard'){
            isSendEmail = true;
        }
        return isSendEmail;
    }
    /****************************************************************************************************** 
    Method Name:        sendEmailToRMFIntUser
    @return  :          Boolean
    @parameters:        EmailDecisionContext ctx
    Description:        
    Added By:           Saikat   10-07-2022
    
    *******************************************************************************************************/
    // ATHR Avoid long parameter lists - US 14285 - Indira
    public static Boolean sendEmailToRMFIntUser(EmailDecisionContext ctx){
        PartnerFundRequest pfr = ctx.pfr;
        Map<Id, PartnerFundRequest> oldPfrMap = ctx.oldPfrMap;
        String userType = ctx.userType;
        Boolean isUserActive = ctx.isUserActive;

        Boolean isSendEmail = false;
        if(pfr.Core_MDF_Fund_Request_Status__c != oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c && isUserActive
           && userType == 'Standard'){
            isSendEmail = true;
        }
        return isSendEmail;
    }
     /****************************************************************************************************** 
    Method Name:        sendEmailToRMFGeoApproversUser
    @return  :          Boolean
    @parameters:        PFR, OldPfrMap, CreatedByUserType, FirstApproverUserIsActive
    Description:        
    Added By:           Saikat   10-07-2022
    Modified By:         
    *******************************************************************************************************/
    public static Boolean sendEmailToRMFGeoApproversUser(PartnerFundRequest pfr, Map<Id, PartnerFundRequest> oldPfrMap,
                                                        Boolean isUserActive){
        Boolean isSendEmail = false;
        if(pfr.Core_MDF_Fund_Request_Status__c != oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c
           && oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm')
           && pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Revision_Required')
           && pfr.Core_MDF_Approval_Step_Completed__c == 0 && pfr.Core_MDF_Activity_First_Approver_txt__c != null
           && isUserActive){
            isSendEmail = true;
        }
        return isSendEmail;
    }
    /****************************************************************************************************** 
    Method Name:        sendNotificationEmailToIntelOwner
    @return  :          void
    @parameters:        NewPFRList, OldPfrMap, isInsert
    Description:        Send Email Notification to Intel Onwer 
    Added By:           Saikat   10-14-2022
    Modified By:        Saikat   03-25-2024 
    *******************************************************************************************************/
    public static void sendNotificationEmailToIntelOwner(List<PartnerFundRequest> newPFRList, Map<Id, PartnerFundRequest> oldPfrMap, 
                                                         Boolean isInsert){
        Map<String, String> emailTemplateMap = new Map<String, String>();
        Map<String, User> userMap = new Map<String, User>();
        Set<String> userIdSet = new Set<String>();
        List<PartnerFundRequest> pfrToSendEmailList = new List<PartnerFundRequest>();
        List<Messaging.SingleEmailMessage> emailToSendList = new List<Messaging.SingleEmailMessage>();
        
        for(PartnerFundRequest newPfr: newPFRList){
            if((isInsert == true || 
               (isInsert == false 
               && ((newPfr.Core_MDF_Fund_Request_Status__c != oldPfrMap.get(newPfr.Id).Core_MDF_Fund_Request_Status__c)
                 || (newPfr.Core_MDF_Approval_Stage__c != oldPfrMap.get(newPfr.Id).Core_MDF_Approval_Stage__c))))
               && sendEmailToIntelOwnerUser(newPfr)){
                //userIdSet.add(newPfr.Core_MDF_Intel_Activity_Owner_Id__c);
                if(newPfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM 
                    && newPfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER){
                        userIdSet.add(newPfr.Core_MDF_Primary_Intel_Owner_Id__c);
                } else {
                    userIdSet.add(newPfr.Core_MDF_Intel_Activity_Owner_Id__c);
                }
                pfrToSendEmailList.add(newPfr);
            }
        } 
        try{
            if(!pfrToSendEmailList.isEmpty() && !userIdSet.isEmpty()){
                for(User user: [SELECT Id, IsActive, UserType, Partner_License_Reclaimed__c FROM User WHERE Id IN: userIdSet]){
                    userMap.put(user.Id, user);
                }
                emailTemplateMap = getEmailTemplateDetails(new Set<String>{'Core_MDF_Internal_Owner_AppNotification'});

                for(PartnerFundRequest pfr: pfrToSendEmailList){
                    /* Action: Send Email 
                       Program: CCF, DCF 
                       Budget Type: MDF, MDF+, OEM CMP, SP CMP
                       Status: Pending Review
                       UserType: Internal
                       EmailTemplate: Core_MDF_Internal_Owner_AppNotification */
                    Boolean isIntelOwnerActive = false;
                    String intelOwnerUserType = '';
                    if(pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER){
                        //Ayush - added ternary operator to check if Core_MDF_Primary_Intel_Owner_Id__c is active or is Partner License Reclaimed
                        isIntelOwnerActive = userMap.get(pfr.Core_MDF_Primary_Intel_Owner_Id__c).IsActive ? userMap.get(pfr.Core_MDF_Primary_Intel_Owner_Id__c).IsActive : userMap.get(pfr.Core_MDF_Primary_Intel_Owner_Id__c).Partner_License_Reclaimed__c == true ? userMap.get(pfr.Core_MDF_Primary_Intel_Owner_Id__c).Partner_License_Reclaimed__c : false ;
                        intelOwnerUserType = userMap.get(pfr.Core_MDF_Primary_Intel_Owner_Id__c).UserType;
                    } else {
                        //Ayush - added the below code to check if Core_MDF_Intel_Activity_Owner_Id__c is active or is Partner License Reclaimed
                        isIntelOwnerActive = userMap.get(pfr.Core_MDF_Intel_Activity_Owner_Id__c).IsActive ? userMap.get(pfr.Core_MDF_Intel_Activity_Owner_Id__c).IsActive : userMap.get(pfr.Core_MDF_Intel_Activity_Owner_Id__c).Partner_License_Reclaimed__c == true ? userMap.get(pfr.Core_MDF_Intel_Activity_Owner_Id__c).Partner_License_Reclaimed__c : false ;
                        intelOwnerUserType = userMap.get(pfr.Core_MDF_Intel_Activity_Owner_Id__c).UserType;
                    }
                    //
                    // if(isIntelOwnerActive && intelOwnerUserType != 'PowerPartner'){
                    //     if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                    //         if(pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_ACTIVATING_PARTNER){
                    //             emailToSendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(pfr.Id, emailTemplateMap.get('Core_MDF_Internal_Owner_AppNotification'), pfr.Core_MDF_Intel_Activity_Owner_Id__c));
                    //         }
                    //         else if (pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER){
                    //             emailToSendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(pfr.Id, emailTemplateMap.get('Core_MDF_Internal_Owner_AppNotification'), pfr.Core_MDF_Primary_Intel_Owner_Id__c));
                    //         }
                    //     } else {
                    //         emailToSendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(pfr.Id, emailTemplateMap.get('Core_MDF_Internal_Owner_AppNotification'), pfr.Core_MDF_Intel_Activity_Owner_Id__c));
                    //     }
                    // }
                    if (isIntelOwnerActive && intelOwnerUserType != 'PowerPartner') {
                        if (pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_ACTIVATING_PARTNER) {
                            emailToSendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(pfr.Id, emailTemplateMap.get('Core_MDF_Internal_Owner_AppNotification'), pfr.Core_MDF_Intel_Activity_Owner_Id__c));
                        } else if (pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER) {
                            emailToSendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(pfr.Id, emailTemplateMap.get('Core_MDF_Internal_Owner_AppNotification'), pfr.Core_MDF_Primary_Intel_Owner_Id__c));
                        } else if (pfr.Core_MDF_Program__c != Core_MDF_CCP_ConstantClass.EEF_PROGRAM) {
                            emailToSendList.add(Core_MDF_GenericClassToSendMail.createEmailInstanceTarget(pfr.Id, emailTemplateMap.get('Core_MDF_Internal_Owner_AppNotification'), pfr.Core_MDF_Intel_Activity_Owner_Id__c));
                        }
                    }
                }
                if(!emailToSendList.isEmpty() && isSendEmailOnceForOpalNotification){
                    Core_MDF_GenericClassToSendMail.sendEmails(emailToSendList);
                    isSendEmailOnceForOpalNotification = false;
                }
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
    /****************************************************************************************************** 
    Method Name:        sendEmailToIntelOwnerUser
    @return  :          Boolean
    @parameters:        New_PFR
    Description:        
    Added By:           Saikat   10-18-2022
    Modified By:        Saikat   03-25-2024 
    *******************************************************************************************************/
    public static Boolean sendEmailToIntelOwnerUser(PartnerFundRequest pfr){
        List<String> opalBudgetTypeList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_OPAL_BudgetTypes').split(';');                                                
        Boolean isSendEmail = false;
        if(pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status_PendingReview')
           && ((opalBudgetTypeList.contains(Pfr.Core_MDF_Budget_Type_nm__c) && pfr.Core_MDF_Approval_Step_Completed__c == 0
           && pfr.Core_MDF_Intel_Activity_Owner_Id__c != null)
               || (pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM 
                    && ((pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_ACTIVATING_PARTNER
                    && pfr.Core_MDF_Intel_Activity_Owner_Id__c != null)
                    ||(pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER
                    && pfr.Core_MDF_Primary_Intel_Owner_Id__c != null))))){
                isSendEmail = true;
        }
        return isSendEmail;
    }
    /****************************************************************************************************** 
    Method Name:        getEmailTemplateDetails
    @return  :          Map<String, String>
    @parameters:        emailTemplateNameSet
    Description:        Get Email Template Details
    Added By:           Saikat   11-11-2022
    Modified By:         
    *******************************************************************************************************/
    public static Map<String, String> getEmailTemplateDetails(Set<String> emailTemplateNameSet){
        Map<String, String> emailTemplateMap = new Map<String, String>();
        for(EmailTemplate template : [SELECT Id, Name, DeveloperName 
                                      FROM EmailTemplate 
                                      WHERE DeveloperName IN: emailTemplateNameSet]){
            emailTemplateMap.put(template.DeveloperName, template.Id);
        }
        return emailTemplateMap;
    }
}