/*************************************************************************************************
Class Name  : Core_MDF_ReportBatch
Function    : Batch class to deactivate user if role is CCP Internal Report Viewer
Modification Log :
* Developer              Date          Description
* ---------------------------------------------------------------------------- 
* Akash Bawankar         04/06/2025    Original version
**************************************************************************************************/
global class Core_MDF_ReportBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Set<String> csvDataList = new Set<String>{'UserId,Name,Email,WWID,IsActive,IsPartnerLicenseReclaimed,ProfileName'};
    public List<ContentVersion> contentVersionListToBeInserted = new List<ContentVersion>();
    public Id recordTrackingId;

    global static Database.QueryLocator start(Database.BatchableContext context) {
            String roleName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Report_Role_Label');
            String query;
            Integer daysAfterModified = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Days_After_Modified_Value_Label'));
            if(!String.isBlank(roleName) && daysAfterModified != null){
                query = 'Select Id, Core_MDF_Role_nm__c, Core_MDF_Active_Ind__c,Core_MDF_User_id__c,Core_MDF_User_id__r.Profile.Name '
                + 'from Core_MDF_Int_Users_Partner_Geo_Mapping__c '+'Where Core_MDF_Role_nm__c = \'' + roleName + '\' ' 
                + 'and Core_MDF_Active_Ind__c = true and Core_MDF_User_id__r.IsActive = true and Core_MDF_Days_After_Modified__c <= ' + daysAfterModified;
                return Database.getQueryLocator(query);
            }
            else{
                return null;
            }
    }

    global void execute(Database.BatchableContext bc, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList) {
        try {
            Set<Id> userIds = new Set<Id>();
            for (Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmList) {
                if(iupgm.Core_MDF_User_id__r.Profile.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_Core_Access_Label')){
                    userIds.add(iupgm.Core_MDF_User_id__c);
                }
                
            }
            if(userIds != null){
            Map<Id, List<String>> userRolesMap = new Map<Id, List<String>>();
            for (Core_MDF_Int_Users_Partner_Geo_Mapping__c role : [SELECT Core_MDF_User_id__c, Core_MDF_Role_nm__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__c IN :userIds AND Core_MDF_Active_Ind__c = true
            ]) {
                if (!userRolesMap.containsKey(role.Core_MDF_User_id__c)) {
                    userRolesMap.put(role.Core_MDF_User_id__c, new List<String>{role.Core_MDF_Role_nm__c});
                }
                else{
                    userRolesMap.get(role.Core_MDF_User_id__c).add(role.Core_MDF_Role_nm__c);
                }
            }
            Map<Id, Set<String>> userPermissionSetsMap = new Map<Id, Set<String>>();
            for (PermissionSetAssignment psa : [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :userIds AND PermissionSet.ProfileId = null
            ]) {
                if (!userPermissionSetsMap.containsKey(psa.AssigneeId)) {
                    userPermissionSetsMap.put(psa.AssigneeId, new Set<String>());
                }
                userPermissionSetsMap.get(psa.AssigneeId).add(psa.PermissionSet.Name);
            }

            Set<Id> usersToSkipBasedOnPS = new Set<Id>();
            for (Id userId : userIds) {
                if (userPermissionSetsMap.containsKey(userId)) {
                    Set<String> userPS = userPermissionSetsMap.get(userId);
                    String reportPSName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Report_Role_Label');
                    String reportGenericPSName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_PS_Internal_Generic_Label');
                    userPS.remove(reportPSName);
                    userPS.remove(reportGenericPSName);
                    if (userPS.isEmpty()) {
                        continue;
                    } else {
                        usersToSkipBasedOnPS.add(userId);
                    }
                } else {
                    usersToSkipBasedOnPS.add(userId);
                }
            }

            Set<Id> userIdsToBeSkipped = new Set<Id>();
            for (Id userId : userIds) {
                if(userRolesMap.containskey(userId)){
                    for(String role : userRolesMap.get(userid)){
                        if(role!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Report_Role_Label')){
                            //if the role for the user is other than CCP Internal Report Viewer then we are adding those user ids to the set userIdsToBeSkipped
                            userIdsToBeSkipped.add(userId);
                            break;
                        }
                    }
                }
            }

            Set<Id> finalUserToBeUpdated = new Set<Id>(userIds);
            if (userIdsToBeSkipped != null) {
                finalUserToBeUpdated.removeAll(userIdsToBeSkipped);
            }
            if (usersToSkipBasedOnPS != null) {
                finalUserToBeUpdated.removeAll(usersToSkipBasedOnPS);
            }

            List<User> usersToUpdate = new List<User>();
            List<Core_MDF_SFReportWrapper> reportWrapList = new List<Core_MDF_SFReportWrapper>();

            if (!finalUserToBeUpdated.isEmpty()) {
                for (User user : [SELECT Id, Name, Email, Core_WWID__c, IsActive, Partner_License_Reclaimed__c, Profile.Name FROM User WHERE Id IN :finalUserToBeUpdated]) {
                    user.IsActive = false;
                    user.Partner_License_Reclaimed__c = true;
                    usersToUpdate.add(user);
                    reportWrapList.add(new Core_MDF_SFReportWrapper(user));
                }
            }

            if (!usersToUpdate.isEmpty()) {
                Database.SaveResult[] updateResults = Database.update(usersToUpdate, false);
                for (Database.SaveResult result : updateResults) {
                    if(result.isSuccess()){
                        csvDataList.addAll(generateCSV(reportWrapList));
                    }
                }           
            }
        }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    global void finish(Database.BatchableContext context) {
        try {
            if (recordTrackingId == null && !csvDataList.isEmpty() && csvDataList.size()>1) {
                Core_MDF_Record_Tracking__c rt = new Core_MDF_Record_Tracking__c();
                rt.Core_MDF_Scope_nm__c = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SF_Power_BI_Report');
                Database.SaveResult insertedRecord = Database.insert(rt);
                if (insertedRecord.isSuccess()) {
                    recordTrackingId = insertedRecord.getId();
                }
            }
            if (!csvDataList.isEmpty() && csvDataList.size()>1) {
                contentVersionListToBeInserted.add(createContentVersion(csvDataList));
                Database.insert(contentVersionListToBeInserted);
                saveAttachment(contentVersionListToBeInserted);

                sendNotificationEmails();
            }
        } catch (Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    private void saveAttachment(List<ContentVersion> contentVersionList) {
        if (recordTrackingId != null) {
            List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
            for (ContentDocument contentDoc : [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVersionList]) {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDoc.Id;
                cdl.LinkedEntityId = recordTrackingId;
                cdl.ShareType = 'V';
                cdl.Visibility = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_InternalUsers_Label');
                contentDocLinkList.add(cdl);
            }
            insert contentDocLinkList;
        }
    }

    private List<String> generateCSV(List<Core_MDF_SFReportWrapper> reportWrapList) {
        List<String> csvList = new List<String>();
        for (Core_MDF_SFReportWrapper wrapper : reportWrapList) {
            csvList.add(wrapper.userId + ',' + wrapper.Name + ',' + wrapper.Email + ',' +
                        wrapper.WWID + ',' + wrapper.IsActive + ',' + wrapper.licenseReclaimed + ',' +
                        wrapper.profileName);
        }
        return csvList;
    }

    private ContentVersion createContentVersion(Set<String> csvDataList) {
        ContentVersion cv = new ContentVersion();
        cv.Title = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SFPowerBIAccess_CSV_Label');
        cv.VersionData = Blob.valueOf(String.join(csvDataList, '\n'));
        cv.PathOnClient = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SFPowerBIAccess_CSV_Label');
        return cv;
    }

    private void sendNotificationEmails() {
        List<String> userIdsList = new List<String>();
        String templateName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SF_PowerBIReport_Notify');
        String iupgmGroupName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SF_PowerBIReport_NotifyGroup');
        List<EmailTemplate> templateList = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
        if (!templateList.isEmpty() && recordTrackingId != null) {
            for (GroupMember grpMember : [SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :iupgmGroupName]) {
                userIdsList.add(grpMember.UserOrGroupId);
            }
            List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
            for (User usr : [SELECT Id FROM User WHERE Id IN :userIdsList]) {
                Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();
                sendEmail.setWhatId(recordTrackingId);
                sendEmail.setTemplateId(templateList[0].Id);
                sendEmail.setTargetObjectId(usr.Id);
                sendEmail.setSaveAsActivity(false);
                sendEmail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                emailsToBeSent.add(sendEmail);
            }
            if (!emailsToBeSent.isEmpty()) {
                Core_MDF_GenericClassToSendMail.sendEmails(emailsToBeSent);
            }
        }
    }

    public class Core_MDF_SFReportWrapper {
        public Id userId;
        public String Email;
        public String Name;
        public String WWID;
        public Boolean IsActive;
        public Boolean licenseReclaimed;
        public String profileName;

        public Core_MDF_SFReportWrapper(User user) {
            this.userId = user.Id;
            this.Email = user.Email;
            this.Name = user.Name;
            this.WWID = user.Core_WWID__c;
            this.IsActive = user.IsActive;
            this.licenseReclaimed = user.Partner_License_Reclaimed__c;
            this.profileName = user.Profile.Name;
        }
    }
}