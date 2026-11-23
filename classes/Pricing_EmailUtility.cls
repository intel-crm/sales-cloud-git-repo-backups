/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 07-30-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public without sharing class Pricing_EmailUtility extends TriggerHandler{
    
    Public static Map<Id,Id> QuoteIdToquotelineIdMap = new Map<Id,Id>();
    public static String psamRole = 'PSAM';
    public static String contactRole = 'Primary_Contact';
    public static String salesRepApproverRole = 'Sales_Rep_Approver';
        public static Boolean isNotQuoteLetterNotify = false;
    
    public static List<Pricing_EmailNotificationTemplate__mdt> templateConfig = new List<Pricing_EmailNotificationTemplate__mdt>();
    //public static boolean isNewFramework = false;
    public static boolean isAddSubmitter = false;
    public static void sendEmail(Set<Id> recIds, String emailTemplate){
        List<Pricing_IQR_Event__e> newsEventList = new List<Pricing_IQR_Event__e>();
        List<Id> qliRecIds = new List<Id>();
        if(recIds.size() > 0){
            qliRecIds.addAll(recIds);
            newsEventList.add(new Pricing_IQR_Event__e(
                Pricing_QuoteLineId_Txt__c = String.join(qliRecIds,','),
            Pricing_EmailTemplate_Nm__c=emailTemplate,
            Pricing_IQR_Action_Nm__c = Label.Pricing_Send_EmailNotification_Event));
        }
        if(newsEventList.size() > 0){
            // Call method to publish events.
            EventBus.publish(newsEventList);
        }
    }
    
    @Future
    public static void sendEmailToReciepents(Set<Id> recIds, String emailTemplate){
        try{
                templateConfig = [SELECT id,Permission_Set_Name__c FROM Pricing_EmailNotificationTemplate__mdt 
                              WHERE Template_API_Name__c =:emailTemplate];
            Map<Id, Map<Id,Set<Id>>> notificationMap = new Map<Id, Map<Id,Set<Id>>>();
            List<String> permissionSetList = new List<String>();
            if(templateConfig[0].Permission_Set_Name__c != null){
                permissionSetList = templateConfig[0].Permission_Set_Name__c.split(',');
            }
            if(templateConfig.size() > 0){
                switch on emailTemplate {
                    when 'Pricing_QuoteLineWonLossNotification' {
                        notificationMap = getAllEmailReceipents(recIds, permissionSetList, false);
                        sendEmailNotifications(notificationMap, emailTemplate);
                    }
                    when 'Pricing_QuoteLineApproveAENotification' {
                        notificationMap = getAllEmailReceipents(recIds, permissionSetList, false);
                        sendEmailNotifications(notificationMap, emailTemplate);
                    }
                    when 'Pricing_QLApprove_OppWonLost_Notify' {
                        notificationMap = getAllEmailReceipents(recIds, permissionSetList, false);
                        sendEmailNotifications(notificationMap, emailTemplate);
                    }
                    when 'Pricing_QuoteLineApproveRPMNotification' {
                        notificationMap = getAllEmailReceipents(recIds, permissionSetList,false);
                        sendEmailNotifications(notificationMap, emailTemplate);
                    }
                    when 'Pricing_QuoteLetterEmailNotification' ,'Pricing_FI_QuoteLetterEmailNotification' {
                        isAddSubmitter = True;
                        notificationMap = getAllEmailReceipents(recIds, permissionSetList,false);
                        sendEmailNotifications(notificationMap, emailTemplate, True, True);
                    }
                    when 'Pricing_QuoteLineRejectedNotification','Pricing_QuoteLineCancelEmailNotification', 'Pricing_FI_QL_Rejection_Notification','Pricing_FI_QL_Cancel_Notification' {
                        isAddSubmitter = True;
                        notificationMap = getAllEmailReceipents(recIds, permissionSetList,false);
                        sendEmailNotifications(notificationMap, emailTemplate, false, false);
                    }
                    when 'Pricing_AE_QuoteLineCRNotification' {
                        isAddSubmitter = True;
                        notificationMap = getAllEmailReceipents(recIds, permissionSetList,false);
                        sendEmailNotifications(notificationMap, emailTemplate);
                    }
                }
            }
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp);
        }
    }
    
    //This method is to send Email notifications to Quote Team members on addition
    @Future
    public static void sendEmail(Set<Id> recIds, String emailTemplate, Boolean isQuoteTeamEmail){
       sendEmailInAsyncContext(recIds, emailTemplate, isQuoteTeamEmail); 
    }
    
    /**
     * Executes the email logic directly when already running in
     * a Batch/Future context to avoid Future-to-Future exceptions. 
     */
    public static void sendEmailInAsyncContext(Set<Id> recIds, String emailTemplate, Boolean isQuoteTeamEmail){
        String sObjectId;
        try{
            templateConfig = [SELECT id,Permission_Set_Name__c FROM Pricing_EmailNotificationTemplate__mdt 
                              WHERE Template_API_Name__c=:emailTemplate];
            Map<Id, Map<Id,Set<Id>>> notificationMap = new Map<Id, Map<Id,Set<Id>>>();
            if(templateConfig.size() > 0){
                for(Pricing_Quote_Team__c qtm :[SELECT Id, Pricing_Role_Nm__c, Pricing_Quote_Team_Member_Id__c, Pricing_Quote_Id__c 
                                                FROM Pricing_Quote_Team__c where Id IN :recIds]){
                    if(qtm.Pricing_Role_Nm__c != Label.Pricing_Quote_Team_Role_FSE && qtm.Pricing_Quote_Team_Member_Id__c!=UserInfo.getUserId()){
                        if(notificationMap.containsKey(qtm.Pricing_Quote_Id__c)){
                            notificationMap.get(qtm.Pricing_Quote_Id__c).put(qtm.Id, new Set<Id>{qtm.Pricing_Quote_Team_Member_Id__c});
                        }else{
                            notificationMap.put(qtm.Pricing_Quote_Id__c, new Map<Id,Set<Id>>{qtm.Id => new Set<Id>{qtm.Pricing_Quote_Team_Member_Id__c}});
                            QuoteIdToquotelineIdMap.put(qtm.Pricing_Quote_Id__c,qtm.Id);
                        }
                        sObjectId = (qtm?.Pricing_Quote_Id__c != null) ? Id.valueOf(qtm.Pricing_Quote_Id__c) : null;
                    }
                }
                if(notificationMap.size()>0){
                    sendEmailNotifications(notificationMap, emailTemplate);
                }
            }
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp,sObjectId); // pass String SOBJect ID
        }
    }
    // add custom exception to test ID in E-Mail Notification to get SOBject-ID in
    
    public static Map<Id,Map<Id,Set<Id>>> getAllEmailReceipents(Set<Id> quoteLineIds, List<String> roleNames, boolean getSalesRepDelegates){
        Map<Id,Map<Id,Set<Id>>> notificationMap = new Map<Id,Map<Id,Set<Id>>>();
        Set<Id> quoteIds = new Set<Id>();
        Map<Id,Id> quiteLineQuoteIdMap = new Map<Id,Id>();
        for(SBQQ__QuoteLine__c quoteLine: [SELECT id,SBQQ__Quote__c FROM SBQQ__QuoteLine__c 
                                           WHERE Id IN :quoteLineIds]){
            quoteIds.add(quoteLine.SBQQ__Quote__c);
            quiteLineQuoteIdMap.put(quoteLine.Id, quoteLine.SBQQ__Quote__c);
            QuoteIdToquotelineIdMap.put(quoteLine.SBQQ__Quote__c,quoteLine.Id);
        }
        Map<Id,Set<Id>> quoteUsersMap = getAllUsersFromQuote(roleNames, quoteIds);
        Map<Id,Set<Id>> quoteLineUsersMap = getAllUsersFromQuoteLine(roleNames, quoteLineIds);
        mergeFinalMaps(notificationMap, quoteUsersMap, quoteLineUsersMap, quiteLineQuoteIdMap);
        return notificationMap;
    }
    
    public static void mergeFinalMaps(Map<Id,Map<Id,Set<Id>>> notificationMap, Map<Id,Set<Id>> quoteUsersMap, Map<Id,Set<Id>> quoteLineUsersMap, Map<Id,Id> quiteLineQuoteIdMap){
        
        if(quoteLineUsersMap.size() > 0){
            for(Id qliId : quoteLineUsersMap.keySet()){
                if(quiteLineQuoteIdMap.containsKey(qliId)){
                    Id quoteId = quiteLineQuoteIdMap.get(qliId);
                    if(quoteUsersMap.containsKey(quoteId)){
                        quoteLineUsersMap.get(qliId).addAll(quoteUsersMap.get(quoteId));
                    }
                    if(notificationMap.containsKey(quoteId)){
                        if(notificationMap.get(quoteId).containsKey(qliId)){
                            notificationMap.get(quoteId).get(qliId).addAll(quoteLineUsersMap.get(qliId));
                        }else{
                            notificationMap.get(quoteId).put(qliId, quoteLineUsersMap.get(qliId));
                        }
                    }else{
                        notificationMap.put(quoteId, new Map<Id,Set<Id>>{qliId => quoteLineUsersMap.get(qliId) });
                    }
                }
            }
        }else{
            for(Id qliId : quiteLineQuoteIdMap.keySet()){
                Id quoteId = quiteLineQuoteIdMap.get(qliId);
                if(quoteUsersMap.containsKey(quoteId)){
                    if(notificationMap.containsKey(quoteId)){
                        if(notificationMap.get(quoteId).containsKey(qliId)){
                            notificationMap.get(quoteId).get(qliId).addAll(quoteUsersMap.get(quoteId));
                        }else{
                            notificationMap.get(quoteId).put(qliId, quoteUsersMap.get(quoteId));
                        }
                    }else{
                        notificationMap.put(quoteId, new Map<Id,Set<Id>>{qliId => quoteUsersMap.get(quoteId)});
                    }
                    
                }
            }
        }
        
    }
    
    public static Map<Id,Set<Id>> getAllUsersFromQuote(List<String> roleNames, Set<id> objIds ){
        Map<Id,Set<Id>> quoteUsersMap = new  Map<Id,Set<Id>>();
        if(roleNames.size() > 0){
            for(String roleName : roleNames ){
                mergeMaps(quoteUsersMap, getUsers(roleName, objIds, false));
            }
        }
        return quoteUsersMap;
    }
    
    public static Map<Id,Set<Id>> getAllUsersFromQuoteLine(List<String> roleNames, Set<id> objIds ){
        Map<Id,Set<Id>> quoteLineUsersMap = new  Map<Id,Set<Id>>();
        if(roleNames.size() > 0){
            for(String roleName : roleNames ){
                mergeMaps(quoteLineUsersMap, getUsers(roleName, objIds, true));
            }
        }
        return quoteLineUsersMap;
    }
    
    public static void mergeMaps(Map<Id,Set<Id>> quoteUsersMap, Map<Id,Set<Id>> usersMap){
        for(Id objId : usersMap.keySet()){
            if(quoteUsersMap.containsKey(objId)){
                quoteUsersMap.get(objId).addAll(usersMap.get(objId));
            }else{
                quoteUsersMap.put(objId, usersMap.get(objId));
            }
        }
    }
    public static void mergeQLIMaps(Map<Id,Set<Id>> qliUsersMap, Map<Id,Set<Id>> usersMap){
        for(Id objId : usersMap.keySet()){
            if(qliUsersMap.containsKey(objId)){
                qliUsersMap.get(objId).addAll(usersMap.get(objId));
            }else{
                qliUsersMap.put(objId, usersMap.get(objId));
            }
        }
    }
    public static Map<Id,Set<Id>> getUsers(String roleName, Set<id> objIds, boolean getFromQLI){
        switch on roleName {
            when 'Tender_User' {
                return getFSEs(objIds, getFromQLI);
            }
            when 'Tender_Account_Executive' {
                return getAEs(objIds, getFromQLI);
            }
            when 'Pricing_Tender_IT_Specialist' {
                return getITSs(objIds, getFromQLI);
            }
            when 'Pricing_Tender_Regional_Pricing_Manager','Pricing_Financial_Incentive_Regional_Pricing_Manager' {
                return getPricingManagers(objIds, getFromQLI);
            }
            when 'Tender_Partner','Tender_Partner_Drafter_Access','Pricing_Tender_Partner_Administrator','Tender_Partner_Drafter_Limited_Access' {
                return getPrimaryContacts(objIds, getFromQLI);
            }
            when 'PSAM' {  //PSAM refers to Intel Sales Rep for FI Quotes which have Financial Incentive Read-Only All Permission Set
                return getRoleBasedUsers(objIds, getFromQLI, roleName);
            }
            when 'Primary_Contact' { // Primary_Contact refers to Primary Contact on FI Quotes which have Financial Incentive Partner Read Only Permission Set
                return getRoleBasedUsers(objIds, getFromQLI, roleName);
            }
            when 'Sales_Rep_Approver' {
                return getRoleBasedUsers(objIds, getFromQLI, roleName);
            }
            when else {
                return new Map<Id,Set<Id>>();
            }
        }
    }
    
    public static void addToMap(Map<Id,Set<Id>> userMap, Id objId, Id userId ){
        if(userMap.containsKey(objId)){
            userMap.get(objId).add(userId);
        }else{
            userMap.put(objId, new Set<Id>{userId});
        }
    }
    
    public static Map<Id,Set<Id>> getPrimaryContacts(Set<Id> quoteLineIds, boolean getFromQLI){
        Map<Id,Set<Id>> primaryContactsMap = new Map<Id,Set<Id>>();
        if(quoteLineIds.size() > 0 && getFromQLI){
            Set<Id> allContactIds = new Set<Id>();
            Map<Id,Id> contUserIdMap = new Map<Id,Id>();
            Map<Id,Set<Id>> qliContactIdMap = new Map<Id,Set<Id>>();
            Map<Id,Id> qliIntSubmitterMap = new Map<Id,Id>();
            for(SBQQ__QuoteLine__c quoteLine : [SELECT id,Pricing_Primary_Contact_Nm__c,Pricing_Last_Submitted_By_Id__c,
                                                Pricing_Last_Submitted_By_Id__r.contactId  FROM SBQQ__QuoteLine__c
                                                WHERE Id IN :quoteLineIds]){
                Set<Id> contactIds = new Set<Id>();
                contactIds.add(quoteLine.Pricing_Primary_Contact_Nm__c);
                if(quoteLine.Pricing_Last_Submitted_By_Id__r.contactId != null) {
                    contactIds.add(quoteLine.Pricing_Last_Submitted_By_Id__r.contactId);
                }else if(isAddSubmitter){
                    qliIntSubmitterMap.put(quoteLine.Id, quoteLine.Pricing_Last_Submitted_By_Id__c);
                }
                qliContactIdMap.put(quoteLine.Id, contactIds);
                allContactIds.addAll(contactIds);
            }
            
            List<String> partnerPermissionsets = Label.Pricing_PartnerPermissionsets_For_Notifications.split(',');
            for(User usr : [SELECT id,ContactId,(SELECT id FROM PermissionSetAssignments WHERE PermissionSet.Name IN :partnerPermissionsets) FROM User WHERE ContactId IN :allContactIds ]){
                if(usr.PermissionSetAssignments.size() > 0){
                    contUserIdMap.put(usr.ContactId, usr.Id);
                }
            }
            if(contUserIdMap.size() > 0) {
                for(Id qliId : qliContactIdMap.keySet()){
                    for(Id conId:qliContactIdMap.get(qliId)){
                        addToMap(primaryContactsMap, qliId, contUserIdMap.get(conId));
                    }
                }
            }
            for(Id qliId : qliIntSubmitterMap.keySet()){
                addToMap(primaryContactsMap, qliId, qliIntSubmitterMap.get(qliId));
            }
        }
        return primaryContactsMap;
    }
    
    public static Map<Id,Set<Id>> getPricingManagers(Set<Id> quoteLineIds, boolean getFromQLI){
        Map<Id, Set<Id>> quotelineIdToUserIdMap = new Map<Id, Set<Id>>();
        Map<Id,String> addRpmEmailsToQliMap = new Map<Id,String>();
        Map<Id,String> rpmEmailsToQliMap = new Map<Id,String>();
        List<SBQQ__QuoteLine__c> qlList = [SELECT id, Pricing_Manager__r.Email,Pricing_Additional_RPM_Notify_Recipients__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds];
        List<String> RPM_Emails = new List<String>();
        Set<String> permissionSets = new Set<String>();
        permissionSets.add(Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager);
        permissionSets.add(Label.Pricing_Tender_PermissionSets_FinancialIncentivePricingManager);
        
        if(quoteLineIds.size() > 0 && getFromQLI){
            for(SBQQ__QuoteLine__c quoteLine : qlList){
                RPM_Emails.add(quoteLine.Pricing_Manager__r.Email);
                rpmEmailsToQliMap.put(quoteLine.Id,quoteLine.Pricing_Manager__r.Email);
                if(quoteLine.Pricing_Additional_RPM_Notify_Recipients__c!=null){
                    RPM_Emails.addAll(((quoteLine.Pricing_Additional_RPM_Notify_Recipients__c).deleteWhitespace()).split(';'));
                    addRpmEmailsToQliMap.put(quoteLine.Id,quoteLine.Pricing_Additional_RPM_Notify_Recipients__c);
                }
            }
            for(PermissionSetAssignment userEmails : [SELECT Id, AssigneeId,Assignee.Email FROM PermissionSetAssignment WHERE Assignee.Email in: RPM_Emails AND Assignee.IsActive = true 
                                                      AND PermissionSet.Name IN: permissionSets]){
                for(Id key:rpmEmailsToQliMap.keySet()){
                    if((addRpmEmailsToQliMap.get(key) != null && addRpmEmailsToQliMap.get(key).contains(userEmails.Assignee.Email)) || (rpmEmailsToQliMap.get(key) != null && rpmEmailsToQliMap.get(key)==userEmails.Assignee.Email)){
                        addToMap(quotelineIdToUserIdMap, key, userEmails.AssigneeId);
                    }
                }
            }
        }
        return quotelineIdToUserIdMap;
    }
    
    public static Map<Id,Set<Id>> getFSEs(Set<Id> quoteIds, boolean getFromQLI){
        Map<Id,Set<Id>> quoteFseMap = new Map<Id,Set<Id>>();
        quoteFseMap = Pricing_Publish_Quote.validateQtmFse(quoteIds);
        quoteFseMap = getSalesRepApprover(quoteFseMap);
        return quoteFseMap;
    }
    
    /**
     * @description Method written to get the Sales Rep Approver for a Quote Line
     * @author Bharath Chandrashekar | 11-09-2022
     * @param quoteFseMap
     * @return Map<Id, Set<Id>>
     **/
    public static Map<Id,Set<Id>> getSalesRepApprover(Map<Id,Set<Id>> quoteFseMap){
        Set<Id> salesRepApproverIds = new Set<Id>();
        Set<Id> userIdsWithValidFSEPS = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, SBQQ__Quote__c, Pricing_Sales_Rep_Approver__c 
                                                  FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: quoteFseMap.keySet()];
        for(SBQQ__QuoteLine__c qli: quoteLineList){
            salesRepApproverIds.add(qli.Pricing_Sales_Rep_Approver__c);
        }
        for(PermissionSetAssignment psa: [SELECT Id, AssigneeId FROM PermissionSetAssignment 
                                          WHERE AssigneeId IN: salesRepApproverIds AND PermissionSet.Name =: Label.Pricing_Tender_PermissionSets_TenderUser 
                                          AND Assignee.IsActive = true]){
            userIdsWithValidFSEPS.add(psa.AssigneeId);
        }
        for(SBQQ__QuoteLine__c ql: quoteLineList){
            if(userIdsWithValidFSEPS.contains(ql.Pricing_Sales_Rep_Approver__c)){
                quoteFseMap.get(ql.SBQQ__Quote__c).add(ql.Pricing_Sales_Rep_Approver__c);
            }
        }
        return quoteFseMap;
    }
    
    public static Map<Id,Set<Id>> getAEs(Set<Id> quoteIds, boolean getFromQLI){
        Map<Id,Set<Id>> quoteAEMap = new Map<Id,Set<Id>>();
        Set<Id> qtmIds = new Set<Id>();
        Set<Id> validAEUsers = new Set<Id>();
        Map<Id, Set<Id>> quoteIdToQTMIdMap = new Map<Id, Set<Id>>();
        List<Pricing_Quote_Team__c> qtmList = [SELECT id,Pricing_Quote_Id__c,Pricing_Quote_Team_Member_Id__c 
                                               FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c IN :quoteIds 
                                               AND Pricing_Role_Nm__c=:Label.Pricing_Quote_Team_Role_Account_Executive 
                                               AND Pricing_Grant_Access_Ind__c=True];
        if(quoteIds.size() > 0){
            for(Pricing_Quote_Team__c qtm: qtmList){
                qtmIds.add(qtm.Pricing_Quote_Team_Member_Id__c);
                if(quoteIdToQTMIdMap.containsKey(qtm.Pricing_Quote_Id__c)){
                    quoteIdToQTMIdMap.get(qtm.Pricing_Quote_Id__c).add(qtm.Pricing_Quote_Team_Member_Id__c);
                }
                else{
                    quoteIdToQTMIdMap.put(qtm.Pricing_Quote_Id__c, new Set<Id>{qtm.Pricing_Quote_Team_Member_Id__c});
                }
            }
            validAEUsers = checkUserHasValidPermission(qtmIds, Label.Pricing_Tender_PermissionSets_TenderAccountExecutive);
            for(Id key: quoteIdToQTMIdMap.keyset()){
                for(Id userId: quoteIdToQTMIdMap.get(key)){
                    if(validAEUsers.contains(userId)){
                        addToMap(quoteAEMap, key, userId);
                    }
                }
            }
        }
        return quoteAEMap;
    }
    
    public static Map<Id,Set<Id>> getITSs(Set<Id> quoteIds, boolean getFromQLI){
        Map<Id,Set<Id>> quoteITSMap = new Map<Id,Set<Id>>();
        Set<Id> qtmIds = new Set<Id>();
        Set<Id> validITSUsers = new Set<Id>();
        Map<Id, Set<Id>> quoteIdToQTMIdMap = new Map<Id, Set<Id>>();
        List<Pricing_Quote_Team__c> qtmList = [SELECT id,Pricing_Quote_Id__c,Pricing_Quote_Team_Member_Id__c 
                                               FROM Pricing_Quote_Team__c WHERE Pricing_Quote_Id__c IN :quoteIds 
                                               AND Pricing_Role_Nm__c=:Label.Pricing_Quote_Team_Role_ITS 
                                               AND Pricing_Grant_Access_Ind__c=True];
        if(quoteIds.size() > 0){
            for(Pricing_Quote_Team__c qtm: qtmList){
                qtmIds.add(qtm.Pricing_Quote_Team_Member_Id__c);
                if(quoteIdToQTMIdMap.containsKey(qtm.Pricing_Quote_Id__c)){
                    quoteIdToQTMIdMap.get(qtm.Pricing_Quote_Id__c).add(qtm.Pricing_Quote_Team_Member_Id__c);
                }
                else{
                    quoteIdToQTMIdMap.put(qtm.Pricing_Quote_Id__c, new Set<Id>{qtm.Pricing_Quote_Team_Member_Id__c});
                }
            }
            
            validITSUsers = checkUserHasValidPermission(qtmIds, Label.Pricing_Tender_Permission_Set_IT_Specialist);
            
            for(Id key: quoteIdToQTMIdMap.keyset()){
                for(Id userId: quoteIdToQTMIdMap.get(key)){
                    if(validITSUsers.contains(userId)){
                        addToMap(quoteITSMap, key, userId);
                    }
                }
            }
        }
        return quoteITSMap;
    }
    
    /**
     * @description Method to return Users Based on Role for FI Quotes
    PSAM will return Intel Sales Rep User from Quote
        Primary_Contact will return Primary Contact from Quote
        need to update this method if need to get Intel Account Executive or Sales Rep Approver fields as part of Recipients
         * @author Sandeep Chamate | 04-12-2024
     * @param quoteLineIds
     * @param getFromQLI
     * @return Map<Id, Set<Id>>
     **/
    public static Map<Id,Set<Id>> getRoleBasedUsers(Set<Id> quoteLineIds, Boolean getFromQLI, String roleName) {
        Map<Id, Set<Id>> quotelineIdToUserIdMap = new Map<Id, Set<Id>>();
        Map<Id,List<String>> emailsToQliMap = new Map<Id,List<String>>(); // List of Email
        List<SBQQ__QuoteLine__c> qlList = [SELECT Id, SBQQ__Quote__r.SBQQ__PrimaryContact__c, SBQQ__Quote__r.Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Sales_Rep_Approver__r.Email FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds];
        List<String> emailList = new List<String>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Id> qliContactIdMap = new Map<Id,Id>();
        Map<Id,Id> contUserIdMap = new Map<Id,Id>();
        
        if(quoteLineIds.size() > 0 && getFromQLI){
            for(SBQQ__QuoteLine__c quoteLine : qlList) {
                contactIds.add(quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__c);
                qliContactIdMap.put(quoteLine.Id, quoteLine.SBQQ__Quote__r.SBQQ__PrimaryContact__c);
                if(roleName == psamRole) {
                    emailList.add(quoteLine.SBQQ__Quote__r.Pricing_Intel_Sales_Rep_Email_Txt__c);
                    if(emailsToQliMap.containsKey(quoteLine.Id)){
                        emailsToQliMap.get(quoteLine.Id).add(quoteLine.SBQQ__Quote__r.Pricing_Intel_Sales_Rep_Email_Txt__c);
                    }else{
                        emailsToQliMap.put(quoteLine.Id, new List<String> { quoteLine.SBQQ__Quote__r.Pricing_Intel_Sales_Rep_Email_Txt__c});
                    }
                }else if(roleName == salesRepApproverRole) {
                    emailList.add(quoteLine.Pricing_Sales_Rep_Approver__r.Email); // sales-rep approver email
                    if(emailsToQliMap.containsKey(quoteLine.Id)){
                        emailsToQliMap.get(quoteLine.Id).add(quoteLine.Pricing_Sales_Rep_Approver__r.Email);
                    }else{
                        emailsToQliMap.put(quoteLine.Id, new List<String> { quoteLine.Pricing_Sales_Rep_Approver__r.Email});
                    }
                }
            }
            
            if(roleName == contactRole) {
                for(User usr : [SELECT id,ContactId FROM User WHERE ContactId IN :contactIds AND isActive = true]){
                    contUserIdMap.put(usr.ContactId, usr.Id);
                }
                if(contUserIdMap.size() > 0) {
                    for(Id qliId : qliContactIdMap.keySet()){
                        addToMap(quotelineIdToUserIdMap, qliId, contUserIdMap.get(qliContactIdMap.get(qliId)));
                    }
                }
            }
            else {
                for(User usr : [SELECT Id,Email FROM User WHERE Email IN: emailList AND isActive = true]){
                    for(Id key:emailsToQliMap.keySet()){
                        if(emailsToQliMap.get(key) != null && emailsToQliMap.get(key).contains(usr.Email)){
                            addToMap(quotelineIdToUserIdMap, key, usr.Id);
                        }
                    }
                }
            }
        }
        return quotelineIdToUserIdMap;
    }
    
    public static Set<Id> checkUserHasValidPermission(Set<Id> userIds, String permissionSet){
        Set<Id> userIdsWithValidPS = new Set<Id>();
        for(PermissionSetAssignment psa: [SELECT Id, AssigneeId FROM PermissionSetAssignment 
                                          WHERE AssigneeId IN: userIds AND PermissionSet.Name =: permissionSet 
                                          AND Assignee.IsActive = true]){
            userIdsWithValidPS.add(psa.AssigneeId);
        }
        return userIdsWithValidPS;
    }
    
    public static void corelogcreation(String templateName,Map<Id,String> recIdtoUserMap){
        List<core_log_entry__c> corelist = new List<core_log_entry__c>();
        for(String keys :recIdtoUserMap.keySet()){
            core_log_entry__c logEntry = new core_log_entry__c();
            logEntry.Core_sObjectId__c =  keys;
            logEntry.Core_Details__c = String.isBlank(recIdtoUserMap.get(keys))?'Users are inactive for whom the Quote is shared. Please check and try again.':recIdtoUserMap.get(keys);
            logEntry.Core_Origin__c =  'IQR notification';
            logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
            logEntry.Core_Severity__c = 'Low';
            logEntry.Core_Support_Email__c = Label.Pricing_IQR_Support_Email;
            logEntry.Core_Support_Link__c = Label.Pricing_IQR_Support_Link;
            logEntry.Core_Scope__c = templateName;
            logEntry.Core_When__c = system.now();
            corelist.add(logEntry);
        }
        insert corelist;
    }
    
    public static void sendEmailToApprover(Set<Id> qliIds, String emailTemplateName){
        String SObjectId;
        try{
            if(qliIds.size() > 0){
                SObjectId = Id.valueOf(qliIds?.iterator().next());
                List<OrgWideEmailAddress> orgWideEmailAdd = [SELECT Id from OrgWideEmailAddress where Address=:Label.Pricing_OrgWideEmailAddress];
                Id orgWideEmailAddId = orgWideEmailAdd[0].id;
                List<EmailTemplate> emailTemplate = [SELECT id FROM EMailTemplate WHERE DeveloperName=:emailTemplateName];
                if(emailTemplate.size() > 0){
                    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                    for(Id qliId:qliIds){
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setTargetObjectId(UserInfo.getUserId());
                        message.setsaveAsActivity(false);
                        message.setTreatTargetObjectAsRecipient(false);
                        message.toaddresses = new List<String>{Label.Pricing_QuoteLineApprovaliInitialNotif_Recepient};
                        message.setWhatId(qliId);
                        message.setOrgWideEmailAddressId(orgWideEmailAddId);
                        message.setUseSignature(false);
                        message.setBccSender(false);
                        message.setSaveAsActivity(false);
                        message.setTemplateID(emailTemplate[0].Id);
                        emails.add(message);
                    }
                    if(emails.size() > 0){
                        Messaging.sendEmail(emails);
                    }
                }
            }
        }
        catch(Exception exp){
            Pricing_Tender_Utility.logError(exp, SObjectId);
        }
    }
    
    public static void sendEmailNotifications(Map<Id,Map<Id,Set<Id>>> quoteUserIdMap, String emailTemplateName){
        String SObjectId;
        try{
            if(quoteUserIdMap.size() > 0){
                OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address='wsm-postmaster@intel.com'];
                List<EmailTemplate> emailTemplate = [SELECT id FROM EMailTemplate WHERE DeveloperName=:emailTemplateName];
                if(emailTemplate.size() > 0){
                    List<SBQQ__Quote__c> quotes = [SELECT id,SBQQ__Account__c,Pricing_Region_Nm__c FROM SBQQ__Quote__c WHERE id IN :quoteUserIdMap.keySet()];
                    Set<Id> accountIds = new Set<Id>();
                    Set<String> regions = new Set<String>();
                    Set<Id> allUserIds = new Set<Id>();
                    Map<id, User> allActiveUsersMap = new Map<id,User>();
                    Map<Id,boolean> userPrefMap = new Map<id,boolean>();
                    Map<String,boolean> accountOptinMap = new Map<String,boolean>();
                    Map<Id,String> objIdtoUserMap = new Map<Id,String>();
                    
                    for(SBQQ__Quote__c quote : quotes){
                        accountIds.add(quote.SBQQ__Account__c);
                        regions.add(quote.Pricing_Region_Nm__c);
                        for(Id objId : quoteUserIdMap.get(quote.Id).keySet()){
                            allUserIds.addAll(quoteUserIdMap.get(quote.Id).get(objId));
                        }
                        SObjectId = (quote?.Id != null) ? Id.valueOf(quote.Id) : null;
                        
                    }
                    //get only active users
                    allActiveUsersMap = new Map<id,User>([SELECT id,Name,Email,ContactId FROM User WHERE Id IN :allUserIds AND IsActive=True]);
                    //Get user preferences for active users
                    for(Pricing_IQR_Email_Preferences__c emailPref : [SELECT id,Pricing_User__c,Pricing_Opt_In_Ind__c FROM Pricing_IQR_Email_Preferences__c 
                                                                      WHERE Pricing_User__c IN :allActiveUsersMap.keySet() AND Pricing_Template_API_Name_Nm__c=:emailTemplateName]){
                        userPrefMap.put(emailPref.Pricing_User__c,emailPref.Pricing_Opt_In_Ind__c);
                    }
                    //fetch all the Account-Region based preferences
                    for(Pricing_EmailNotificationPreference__mdt acctPref : [SELECT Account_Id__c,Pricing_Optin_Ind__c,Pricing_Region__c FROM Pricing_EmailNotificationPreference__mdt
                                                                             WHERE Account_Id__c IN :accountIds AND Pricing_Template_API_Name_Nm__c=:emailTemplateName
                                                                             AND Pricing_Region__c IN :regions]){
                        accountOptinMap.put(acctPref.Account_Id__c+'~~'+acctPref.Pricing_Region__c, acctPref.Pricing_Optin_Ind__c);
                    }
                    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                    Set<String> toEmailsListForCoreLogCreation = new Set<String>();
                    
                    for(SBQQ__Quote__c quote : quotes){
                        String key = quote.SBQQ__Account__c+'~~'+quote.Pricing_Region_Nm__c;
                        
                        //If there is no Accout preference if configured Or If configured and Opted-in
                        
                        for(Id objId : quoteUserIdMap.get(quote.Id).keySet()){
                            Map<String, Id> toEmailToIds = new Map<String, Id>();
                            for(Id userId : quoteUserIdMap.get(quote.Id).get(objId)){
                                //Mark user preference for Active user as Opted-In if opted-in or if there is no preference record at all
                                if(allActiveUsersMap.containsKey(userId) && (!userPrefMap.containsKey(userId) || (userPrefMap.containsKey(userId) && userPrefMap.get(userId)))) {
                                    if(String.isEmpty(allActiveUsersMap.get(userId).ContactId) || (!String.isEmpty(allActiveUsersMap.get(userId).ContactId) && (!accountOptinMap.containsKey(key) || (accountOptinMap.containsKey(key) && accountOptinMap.get(key))))){
                                        toEmailToIds.put(allActiveUsersMap.get(userId).Email, userId);
                                    }
                                }
                            }
                            if(toEmailToIds.size() > 0){
                                //send Email notification to Active and Opted-in users
                                getEmailMessage(emails , objId, emailTemplate[0].Id, toEmailToIds, orgWideEmailAdd.Id);
                            }
                            toEmailsListForCoreLogCreation.addAll(toEmailToIds.keySet());
                            if(emailTemplateName != Label.Pricing_QuoteLetter_Template_Name && emailTemplateName != Label.Pricing_QuoteTeam_EmailNotification_Template){
                                String toEmail = String.join(new List<String>(toEmailToIds.keySet()), ',');
                                objIdtoUserMap.put(objId,toEmail);
                            }
                        }
                        if(emailTemplateName == Label.Pricing_QuoteLetter_Template_Name || emailTemplateName == Label.Pricing_QuoteTeam_EmailNotification_Template){
                            String toEmail = String.join(new List<String>(toEmailsListForCoreLogCreation), ',');
                            objIdtoUserMap.put(quote.Id, toEmail);
                        }
                    }
                    corelogcreation(emailTemplateName,objIdtoUserMap);
                    if(emails.size() > 0){
                        Messaging.sendEmail(emails);
                    }
                }
            }
            
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp,SObjectId);
        }
        
    }
    
    public static void sendEmailNotifications(Map<Id,Map<Id,Set<Id>>> quoteUserIdMap, String emailTemplateName, boolean attachFile, boolean sendSingleEmail){
        String SObjectId;
        try{
            if(quoteUserIdMap.size() > 0){
                
                OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address='wsm-postmaster@intel.com'];
                List<EmailTemplate> emailTemplate = [SELECT Id FROM EMailTemplate WHERE DeveloperName=:emailTemplateName];
                if(emailTemplate.size() > 0){
                    List<SBQQ__Quote__c> quotes = [SELECT id,SBQQ__Account__c,Pricing_Region_Nm__c,Pricing_AdditionalRecipients__c,Pricing_Quote_Program_Nm__c,
                                                   (SELECT id,SBQQ__DocumentId__c FROM R00N70000001lX7YEAU__r  ORDER By CreatedDate DESC LIMIT 1)
                                                   FROM SBQQ__Quote__c WHERE id IN :quoteUserIdMap.keySet()];
                    Set<Id> accountIds = new Set<Id>();
                    Set<String> regions = new Set<String>();
                    Set<Id> allUserIds = new Set<Id>();
                    Map<id, User> allActiveUsersMap = new Map<id,User>();
                    Map<Id,boolean> userPrefMap = new Map<id,boolean>();
                    Map<String,boolean> accountOptinMap = new Map<String,boolean>();
                    Map<Id,Id> quoteIdDocIdMap = new Map<Id,Id>();
                    Map<Id,Document> quoteIdDocMap = new Map<Id,Document>();
                    Map<Id,String> objIdtoUserMap = new Map<Id,String>();
                    Map<String,User> userIdMap = new Map<String,User>();
                    Map<String,String> idAddressMap = new Map<String,String>();
                    List<PRM_EmailLog__c> prmEmailLogList = new List<PRM_EmailLog__c>();
                    
                    Map<Id,ContentVersion> quoteDocVersionMap = new Map<Id,ContentVersion>();
                    
                    for(SBQQ__Quote__c quote : quotes){
                        accountIds.add(quote.SBQQ__Account__c);
                        regions.add(quote.Pricing_Region_Nm__c);
                        for(Id objId : quoteUserIdMap.get(quote.Id).keySet()){
                            allUserIds.addAll(quoteUserIdMap.get(quote.Id).get(objId));
                        }
                        if(attachFile){
                            quoteIdDocIdMap.put(quote.R00N70000001lX7YEAU__r[0].SBQQ__DocumentId__c, quote.Id);
                        }
                    }
                    if(quoteIdDocIdMap.size() > 0){
                        for(Document doc : [SELECT Id,Name,Body FROM Document WHERE Id IN :quoteIdDocIdMap.keySet()]){
                            quoteIdDocMap.put(quoteIdDocIdMap.get(doc.Id), doc);
                        }
                    }
                    //get only active users
                    allActiveUsersMap = new Map<id,User>([SELECT id,Name,Email,ContactId,Contact.Email,(SELECT id,PermissionSet.Name FROM PermissionSetAssignments)
                                                          FROM User WHERE Id IN :allUserIds AND IsActive=True]);
                    //Get user preferences for active users
                    for(Pricing_IQR_Email_Preferences__c emailPref : [SELECT id,Pricing_User__c,Pricing_Opt_In_Ind__c FROM Pricing_IQR_Email_Preferences__c 
                                                                      WHERE Pricing_User__c IN :allActiveUsersMap.keySet() AND Pricing_Template_API_Name_Nm__c=:emailTemplateName]){
                        
                        userPrefMap.put(emailPref.Pricing_User__c,emailPref.Pricing_Opt_In_Ind__c);
                    }
                    //fetch all the Account-Region based preferences
                    for(Pricing_EmailNotificationPreference__mdt acctPref : [SELECT Account_Id__c,Pricing_Optin_Ind__c,Pricing_Region__c FROM Pricing_EmailNotificationPreference__mdt
                                                                             WHERE Account_Id__c IN :accountIds AND Pricing_Template_API_Name_Nm__c=:emailTemplateName
                                                                             AND Pricing_Region__c IN :regions]){
                        accountOptinMap.put(acctPref.Account_Id__c+'~~'+acctPref.Pricing_Region__c, acctPref.Pricing_Optin_Ind__c);
                    }
                    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                    SObjectId = Id.valueOf(quotes[0].Id);
                    for(SBQQ__Quote__c quote : quotes){
                        String key = quote.SBQQ__Account__c+'~~'+quote.Pricing_Region_Nm__c;
                        Set<String> toEmails = new Set<String>();
                        Set<String> ccEmails = new Set<String>();
                        Set<String> bccEmails = new Set<String>();
                        List<String> additionalRecipients = new List<String>();// For Additional Recipients
                        if((emailTemplateName == label.Pricing_QuoteLetter_Template_Name || emailTemplateName == 'Pricing_QuoteLineCancelEmailNotification') && quote.Pricing_AdditionalRecipients__c != '' && quote.Pricing_AdditionalRecipients__c != null){
                            additionalRecipients = quote.Pricing_AdditionalRecipients__c.split(';');
                            for(String str : additionalRecipients ){
                                ccEmails.add(str);
                            }
                        }
                        //If there is no Accout preference if configured Or If configured and Opted-in
                        Set<Id> userIds = new Set<Id>();
                        for(Id objId : quoteUserIdMap.get(quote.Id).keySet()){
                            for(Id userId : quoteUserIdMap.get(quote.Id).get(objId)){
                                if(!userIds.contains(userId)){
                                    if(sendSingleEmail){
                                        userIds.add(userId);
                                    }
                                    //Mark user preference for Active user as Opted-In if opted-in or if there is no preference record at all
                                    if(allActiveUsersMap.containsKey(userId) && (!userPrefMap.containsKey(userId) || (userPrefMap.containsKey(userId) && userPrefMap.get(userId)))) {
                                        if(/*String.isEmpty(allActiveUsersMap.get(userId).ContactId) || */(!String.isEmpty(allActiveUsersMap.get(userId).ContactId) && (!accountOptinMap.containsKey(key) || (accountOptinMap.containsKey(key) && accountOptinMap.get(key))))){
                                            toEmails.add(allActiveUsersMap.get(userId).Email);
                                        }else {
                                            for(PermissionSetAssignment permAssignment : allActiveUsersMap.get(userId).PermissionSetAssignments){
                                                if((quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program && permAssignment.PermissionSet.Name  == Label.Pricing_Tender_PermissionSets_PricingTenderRegionalPricingManager) || (quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote && permAssignment.PermissionSet.Name  == Label.Pricing_Tender_PermissionSets_FinancialIncentivePricingManager)){
                                                    bccEmails.add(allActiveUsersMap.get(userId).Email);
                                                    break;
                                                }else if((quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program && permAssignment.PermissionSet.Name  == Label.Pricing_Tender_PermissionSets_TenderUser) || (quote.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_FinancialIncentive_Quote && permAssignment.PermissionSet.Name == 'Pricing_Financial_Incentive_ReadOnly')){
                                                    ccEmails.add(allActiveUsersMap.get(userId).Email);
                                                    break;
                                                }else if(permAssignment.PermissionSet.Name  == Label.Pricing_Tender_PermissionSets_TenderAccountExecutive){
                                                    if(emailTemplateName == label.Pricing_QuoteLetter_Template_Name){
                                                        bccEmails.add(allActiveUsersMap.get(userId).Email);
                                                    }else{
                                                        ccEmails.add(allActiveUsersMap.get(userId).Email);
                                                    }
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if(!sendSingleEmail && (toEmails.size() > 0 || ccEmails.size() > 0 || bccEmails.size() > 0) ){
                                //send Email notification to Active and Opted-in users
                                getEmailMessage(emails , objId, emailTemplate[0].Id, toEmails, ccEmails, bccEmails, quoteIdDocMap, orgWideEmailAdd.Id, attachFile);
                            }
                            if(emailTemplateName != Label.Pricing_QuoteLetter_Template_Name && emailTemplateName != Label.Pricing_QuoteTeam_EmailNotification_Template){
                                String TOEmail = String.join(new List<String>(toEmails), ',');
                                String CCEmail = String.join(new List<String>(ccEmails), ',');
                                String BCCEmail = String.join(new List<String>(bccEmails), ',');
                                String allEmails = 'To Emails - '+TOEmail +','+'CC Emails - '+CCEmail +','+'Bcc Emails - '+BCCEmail;
                                objIdtoUserMap.put(objId, allEmails);
                            }
                        }
                        if(sendSingleEmail && (toEmails.size() > 0 || ccEmails.size() > 0 || bccEmails.size() > 0) ){
                            //send Email notification to Active and Opted-in users
                            if(TriggerHandler.isActive('Pricing_RecallEmailSwitch') && emailTemplateName == Label.Pricing_QuoteLetter_Template_Name){
                                Pricing_QuoteEmailAlertController.isRecallMail = true;
                                isNotQuoteLetterNotify = true;
                                Pricing_QuoteEmailAlertController.toEmail.addAll(toEmails);
                                Pricing_QuoteEmailAlertController.ccEmail.addAll(ccEmails);
                                Pricing_QuoteEmailAlertController.bccEmail.addAll(bccEmails);
                            }
                            getEmailMessage(emails , quote.Id, emailTemplate[0].Id, toEmails, ccEmails, bccEmails, quoteIdDocMap, orgWideEmailAdd.Id, attachFile);
                        }
                        
                        if(emailTemplateName == Label.Pricing_QuoteLetter_Template_Name || emailTemplateName == Label.Pricing_QuoteTeam_EmailNotification_Template){
                            String TOEmail = String.join(new List<String>(toEmails), ',');
                            String CCEmail = String.join(new List<String>(ccEmails), ',');
                            String BCCEmail = String.join(new List<String>(bccEmails), ',');
                            String allEmails = 'To Emails - '+TOEmail +','+'CC Emails - '+CCEmail +','+'Bcc Emails - '+BCCEmail;
                            objIdtoUserMap.put(quote.Id, allEmails);
                        }
                    }
                    corelogcreation(emailTemplateName, objIdtoUserMap);
                    if(emails.size() > 0){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
                    }
                    if(quotes[0].Pricing_Quote_Program_Nm__c==Label.Pricing_Tender_FinancialIncentive_Quote){
                        Map<String,User> emailToUserMap = new Map<String,User>();
                        for(user usr:allActiveUsersMap.values()){
                            emailToUserMap.put(usr.Email,usr);
                        }
                        
                        for(Messaging.SingleEmailMessage mail  : emails ){
                            Map<String,User> prmContIDUserMap  = new Map<String,User>();

                           for(String toAddress : mail.getToAddresses()){
                                if(emailToUserMap.get(toAddress).ContactId != null){
                                    prmContIDUserMap.put(emailToUserMap.get(toAddress).ContactId,emailToUserMap.get(toAddress));
                                }
                            }
                            for(user usr:allActiveUsersMap.values()){
                                userIdMap.put(mail.getTargetObjectId(),usr);
                                idAddressMap.put(mail.getTargetObjectId(),usr.Contact.Email);
                            }
                            if(!mail.getToAddresses().isEmpty()){
                                if(prmContIDUserMap.size()>0){
                                    List<String> conList = new List<String>(prmContIDUserMap.keyset());
                                    if (!conList.isEmpty()) {
                                        String firstContact = conList[0];  
                                        mail.setTargetObjectId(firstContact);
                                    }
                                }
                                
                                prmEmailLogList.addAll(PRM_EmailUtility.createEmailLogsBasedOnType(mail,Label.Pricing_IQR_Program_Name,idAddressMap,prmContIDUserMap,userIdMap,'English',emailTemplateName));
                            }
                        }
                        if(prmEmailLogList.size() > 0){
                            insert prmEmailLogList;
                        }
                    }
                }
            }
            
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp,SObjectId);
        }
    }
    
    private static void getEmailMessage(List<Messaging.SingleEmailMessage> emails , Id recId, Id emailTemplateId, Map<String, Id> toAddresses, Id orgwideEmailId){
        try{
            if(toAddresses.size() > 0){
                List<String> finalEmailIdsList = new List<String>();
                Integer counter = 0;
                for(String emailId : toAddresses.keyset()){
                    if(counter <= 100){
                        finalEmailIdsList.add(emailId);
                    }
                }
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                if(finalEmailIdsList.size() == 1){
                    message.setTargetObjectId(toAddresses.get(finalEmailIdsList[0]));
                }else if(finalEmailIdsList.size() > 0){
                    message.setTargetObjectId(UserInfo.getUserId());
                }
                
                message.setsaveAsActivity(false);
                message.setTreatTargetObjectAsRecipient(false);
                message.toaddresses = finalEmailIdsList;
                message.setWhatId(recId);
                message.setOrgWideEmailAddressId(orgwideEmailId);
                message.setReplyTo('wsm-postmaster@intel.com');
                message.setUseSignature(false);
                message.setBccSender(false);
                message.setSaveAsActivity(false);
                message.setTemplateID(emailTemplateId);
                emails.add(message);
            }
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp,recId);
        }
    }
    
    private static void getEmailMessage(List<Messaging.SingleEmailMessage> emails , Id recId, Id emailTemplateId,
    Set<String> toAddresses, Set<String> ccAddresses, Set<String> bccAddresses,
                                        Map<Id,Document> quoteIdDocMap, Id orgwideEmailId, Boolean attachFile){
        try{
            if(toAddresses.size() > 0 || ccAddresses.size() > 0 || bccAddresses.size() > 0){
                List<String> finalToEmailIdsList = new List<String>();
                List<String> finalCCEmailIdsList = new List<String>();
                List<String> finalBCCEmailIdsList = new List<String>();
                if(!TriggerHandler.isActive('Pricing_RecallEmailSwitch') || !isNotQuoteLetterNotify) {
                    Integer counter = 0;
                    for(String emailId : toAddresses){
                        if(counter <= 100){
                            finalToEmailIdsList.add(emailId);
                        }
                    }
                    counter = 0;
                    for(String emailId : ccAddresses){
                        if(counter <= 100){
                            finalCCEmailIdsList.add(emailId);
                        }
                    }
                    counter = 0;
                    for(String emailId : bccAddresses){
                        if(counter <= 100){
                            finalBCCEmailIdsList.add(emailId);
                        }
                    }
                }
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(UserInfo.getUserId());
                message.setsaveAsActivity(false);
                message.setTreatTargetObjectAsRecipient(false);
                if(TriggerHandler.isActive('Pricing_RecallEmailSwitch') && isNotQuoteLetterNotify){
                    message.toaddresses = new List<string> {'anikx.chakraborty@intel.com'};
                }else{
                    message.toaddresses = finalToEmailIdsList;
                    message.ccaddresses = finalCCEmailIdsList;
                    message.bccaddresses = finalBCCEmailIdsList;
                }
                
                message.setWhatId(recId);
                message.setOrgWideEmailAddressId(orgwideEmailId);
                message.setReplyTo('wsm-postmaster@intel.com');
                message.setUseSignature(false);
                message.setSaveAsActivity(false);
                message.setTemplateID(emailTemplateId);
                
                if(attachFile && quoteIdDocMap.containsKey(recId)){
                    message.setFileAttachments(documentAsAttachement(quoteIdDocMap.get(recId)));
                }
                emails.add(message);
            }
        }catch(Exception exp){
            Pricing_Tender_Utility.logError(exp,(recId != null) ? Id.valueOf(recId) : null);
        }
    }
    
    public static List<Messaging.EmailFileAttachment> documentAsAttachement(Document doc) {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
        File myFile = File.make(doc);
        Blob body = myFile.getBody();
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setBody(body);
        attachment.setFileName(doc.Name);
        attachments.add(attachment);
        return attachments;
    }
    
    @InvocableMethod(label='Send Rejection Email for Quote Line' description='Sends rejection email to SalesRep and SalesRepApproved')
    public static void sendQLIRejectionEmail(List<Id> quoteLineIds){
        if(quoteLineIds.size() > 0){
            sendEmail(new Set<Id>(quoteLineIds), Label.Pricing_QuoteLineRejectedNotification_Template);
        }
    }
    /**
     * @description Sends Won notification email exclusively to Account Executives
     *              on the Quote Team. Builds the recipient map directly from
     *              Pricing_Quote_Team__c (role = Account Executive) so no other
     *              persona receives the email.
     * @param qliIds        Set of Quote Line Ids that have moved to Won status
     * @param emailTemplate DeveloperName of the email template to use
     */
    /*@Future
    public static void sendWonNotificationToAEOnly(Set<Id> qliIds, String emailTemplate) {
        try {
            Map<Id, Id> qliToQuoteIdMap = new Map<Id, Id>();
            for (SBQQ__QuoteLine__c qli : [SELECT Id, SBQQ__Quote__c
                                           FROM SBQQ__QuoteLine__c
                                           WHERE Id IN :qliIds]) {
                qliToQuoteIdMap.put(qli.Id, qli.SBQQ__Quote__c);
                QuoteIdToquotelineIdMap.put(qli.SBQQ__Quote__c, qli.Id);
            }
 
            Set<Id> quoteIds = new Set<Id>(qliToQuoteIdMap.values());
            // getAEs returns Map<quoteId, Set<userId>> filtered to AE permission-set holders
            Map<Id, Set<Id>> quoteAEMap = getAEs(quoteIds, false);
 
            // Build Map<quoteId, Map<qliId, Set<userId>>> expected by sendEmailNotifications
            Map<Id, Map<Id, Set<Id>>> notificationMap = new Map<Id, Map<Id, Set<Id>>>();
            for (Id qliId : qliToQuoteIdMap.keySet()) {
                Id quoteId = qliToQuoteIdMap.get(qliId);
                if (quoteAEMap.containsKey(quoteId)) {
                    if (notificationMap.containsKey(quoteId)) {
                        notificationMap.get(quoteId).put(qliId, quoteAEMap.get(quoteId));
                    } else {
                        notificationMap.put(quoteId, new Map<Id, Set<Id>>{ qliId => quoteAEMap.get(quoteId) });
                    }
                }
            }
            system.debug('Entering email utility quote ae map:'+quoteAEMap);
            if (!notificationMap.isEmpty()) {
                system.debug('Entering email utility class notification map: '+notificationMap);
                sendEmailNotifications(notificationMap, emailTemplate);
            }
        } catch (Exception exp) {
            Pricing_Tender_Utility.logError(exp);
        }
    }*/
    /*public static Boolean sendWonNotification(Set<Id> qliIds, String emailTemplate) {
        try {
            // Fetch the logged-in user's ID
            Id loggedInUserId = UserInfo.getUserId();
            Id quoteId;
    
            // 1. Gather Quote Line data
            Map<Id, Id> qliToQuoteIdMap = new Map<Id, Id>();
            Map<Id, Id> qliToRpmIdMap = new Map<Id, Id>();
    
            for (SBQQ__QuoteLine__c qli : [SELECT Id, SBQQ__Quote__c, Pricing_Manager__c
                                           FROM SBQQ__QuoteLine__c
                                           WHERE Id IN :qliIds]) {
                qliToQuoteIdMap.put(qli.Id, qli.SBQQ__Quote__c);
                
                // Safe extraction: Since there's only one record, this will assign the single Quote ID perfectly
                quoteId = qli.SBQQ__Quote__c;
    
                if (qli.Pricing_Manager__c != null) {
                    qliToRpmIdMap.put(qli.Id, qli.Pricing_Manager__c);
                }
            }
    
            // 2. Step-by-Step Authorization Check (Short-circuit optimization)
            Boolean isAuthorized = false;
    
            // Check if the user is already an RPM (Pricing Manager)
            if (qliToRpmIdMap.values().contains(loggedInUserId)) {
                isAuthorized = true;
            } 
            // If NOT an RPM, only then query the database and check the Quote Team
            else {
                // Check Quote Team using the single quoteId variable
                List<Pricing_Quote_Team__c> qtmList = [SELECT Pricing_Quote_Team_Member_Id__c 
                                                       FROM Pricing_Quote_Team__c 
                                                       WHERE Pricing_Quote_Id__c = :quoteId 
                                                       AND Pricing_Grant_Access_Ind__c = TRUE];
    
                for (Pricing_Quote_Team__c teamMember : qtmList) {
                    if (teamMember.Pricing_Quote_Team_Member_Id__c == loggedInUserId) {
                        isAuthorized = true;
                        break; // Authorized! Stop looking further
                    }
                }
            }
               
            // 3. Build the notificationMap and dispatch email if authorized
            if (isAuthorized) {
                Map<Id, Map<Id, Set<Id>>> notificationMap = new Map<Id, Map<Id, Set<Id>>>();
    
                for (Id qliId : qliIds) {
                    // Check if the map already contains the quoteId
                    if (notificationMap.containsKey(quoteId)) {
                        // Corrected: Wrap the userId in a Set to match the Map declaration type
                        notificationMap.get(quoteId).put(qliId, new Set<Id>{ loggedInUserId });
                    } else {
                        // Corrected: Initializing map key with QuoteLineId mapped to a Set of User IDs
                        notificationMap.put(quoteId, new Map<Id, Set<Id>>{ qliId => new Set<Id>{ loggedInUserId } });
                    }
                }
    
                System.debug('Dispatching notifications. Map: ' + notificationMap);
                if (!notificationMap.isEmpty()) {
                    System.debug('Entering email utility class notification map: ' + notificationMap);
                    sendEmailNotifications(notificationMap, emailTemplate);
                }
                
                return true; // Successfully sent
            } else {
                return false; // Not authorized (not an RPM or Team Member)
            }
    
        } catch (Exception exp) {
            Pricing_Tender_Utility.logError(exp);
            return false; 
        }
    }*/
    public static String validateAndProcessWonNotification(Set<Id> qliIds, String emailTemplate) {
    try {
        Id loggedInUserId = UserInfo.getUserId();
        Id quoteId;

        // 1. Gather Quote Line data
        Map<Id, Id> qliToQuoteIdMap = new Map<Id, Id>();
        Map<Id, Id> qliToRpmIdMap = new Map<Id, Id>();

        for (SBQQ__QuoteLine__c qli : [SELECT Id, SBQQ__Quote__c, Pricing_Manager__c
                                       FROM SBQQ__QuoteLine__c
                                       WHERE Id IN :qliIds]) {
            qliToQuoteIdMap.put(qli.Id, qli.SBQQ__Quote__c);
            quoteId = qli.SBQQ__Quote__c; // Assigning since we process single Quote in transaction

            if (qli.Pricing_Manager__c != null) {
                qliToRpmIdMap.put(qli.Id, qli.Pricing_Manager__c);
            }
        }

        // 2. Perform Authorization Checks Step-by-Step
        Boolean isAssignedRpm = qliToRpmIdMap.values().contains(loggedInUserId);
        Boolean isTeamMember = false;
        
        // If not the assigned RPM, check if they are on the Quote Team
        if (!isAssignedRpm) {
            List<Pricing_Quote_Team__c> qtmList = [SELECT Pricing_Quote_Team_Member_Id__c 
                                                   FROM Pricing_Quote_Team__c 
                                                   WHERE Pricing_Quote_Id__c = :quoteId 
                                                   AND Pricing_Grant_Access_Ind__c = TRUE
                                                   AND Pricing_Quote_Team_Member_Id__c = :loggedInUserId];
            if (!qtmList.isEmpty()) {
                isTeamMember = true;
            }
        }

        // 3. Consolidated Action Phase
        Boolean isAuthorized = isAssignedRpm || isTeamMember;

        if (isAuthorized) {
            // Build map ONCE
            Map<Id, Map<Id, Set<Id>>> notificationMap = new Map<Id, Map<Id, Set<Id>>>();
            
            for (Id qliId : qliIds) {
                if (!notificationMap.containsKey(quoteId)) {
                    notificationMap.put(quoteId, new Map<Id, Set<Id>>());
                }
                if (!notificationMap.get(quoteId).containsKey(qliId)) {
                    notificationMap.get(quoteId).put(qliId, new Set<Id>());
                }
                notificationMap.get(quoteId).get(qliId).add(loggedInUserId);
            }

            System.debug('Dispatching consolidated notifications: ' + notificationMap);
            sendEmailNotifications(notificationMap, emailTemplate);
            
            return 'SUCCESS';
        } else {
            // If completely unauthorized, check why to return the exact custom code
            if (Pricing_QuoteLineController.isRPMUser) {
                // User is a Pricing Manager by profile, but wasn't assigned to this Quote Line
                return 'NOT_ASSIGNED_RPM';
            } else {
                // User is a standard user who is not on the Quote Team
                return 'NOT_ON_TEAM';
            }
        }

    } catch (Exception exp) {
        Pricing_Tender_Utility.logError(exp);
        return 'ERROR'; 
    }
 }

    

}