/********************************************************************************************************************************************** 
Class Name:         Core_MDF_IUPGM_InActive_Batch
@parameters:        N/A
Description:        Deactivate IUPGM record if the user is not having the specified Permission Set same as the role present on the IUPGM record 
Added By:           Shiva   09-14-2023
Modified By:        Date:           Changes:
Ayush               01-25-2024      Merged IUPGM deactivation logic if a user is inactive from Core_MDF_InactivateIUPGM batch in this batch.
Ayush               01-29-2025      Added changes for "Reclaiming SF Partner License"
**********************************************************************************************************************************************/

global with sharing class Core_MDF_IUPGM_InActive_Batch implements Database.Batchable<sObject>,Database.Stateful {
    Public List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmToInactivateList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
    Public String csvHeader = 'Id,Is Record Active,Role, Program Name, User Id, User Name, Is User Active';
    Public List<String> csvRecordList = new List<String>{csvHeader};
    Public List<ContentVersion> contentVersionInsertList = new List<ContentVersion>();
    Public Id recordTrackingId;
    Public List<string> rolesList = new List<string>();
    Public final Boolean notifyUsers = Boolean.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_AGS_IUPGM_Sync_Notify_User'));
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        rolesList = getEligibleRoles();
        String query = 'SELECT Id, Core_MDF_Program_nm__c, Core_MDF_Channel_Program_id__c,Core_MDF_Role_nm__c,Core_MDF_User_id__c,Core_MDF_User_id__r.Name,Core_MDF_Active_Ind__c,Core_MDF_is_User_Active_ind__c,Core_MDF_User_id__r.Partner_License_Reclaimed__c '+
            'FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c '+ 
            'WHERE Core_MDF_Active_Ind__c = TRUE ';
        
        return Database.getQueryLocator(query);
    }   
    
    global void execute(Database.BatchableContext bc, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList){
        Map<Id,set<string>> userIdToPSSetMap = new Map<Id,set<string>>();
        set<Id> activeUserIds = new set<Id>();
        set<Id> inactiveUserIds = new set<Id>();
        
        try{
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iugpm : iupgmList){
                //Ayush - Added partner licence reclaimed check as well in or condition to stop inactivation of IUPGMs if user is inactive but licence flag is TRUE
                if(iugpm.Core_MDF_is_User_Active_ind__c == true || iugpm.Core_MDF_User_id__r.Partner_License_Reclaimed__c == true){ 
                    activeUserIds.add(iugpm.Core_MDF_User_id__c);
                }
                else{
                    inactiveUserIds.add(iugpm.Core_MDF_User_id__c);
                }
            }
            
            for(PermissionSetAssignment ps : [SELECT Id,AssigneeId, PermissionSet.Name 
                                              FROM PermissionSetAssignment
                                              WHERE AssigneeId =: activeUserIds
                                              AND PermissionSet.Name IN: rolesList]){
                                                  
                                                  if(!userIdToPSSetMap.containsKey(ps.AssigneeId)){
                                                      userIdToPSSetMap.put(ps.AssigneeId, new set<string>());
                                                  }
                                                  userIdToPSSetMap.get(ps.AssigneeId).add(ps.PermissionSet.Name);
                                              } 
            
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iugpm : iupgmList){
                if(!userIdToPSSetMap.containsKey(iugpm.Core_MDF_User_id__c) || (userIdToPSSetMap.get(iugpm.Core_MDF_User_id__c) != null && !userIdToPSSetMap.get(iugpm.Core_MDF_User_id__c).contains(iugpm.Core_MDF_Role_nm__c))
                    || inactiveUserIds.contains(iugpm.Core_MDF_User_id__c)){
                    String csvRow = iugpm.Id + ',' + iugpm.Core_MDF_Active_Ind__c + ',' + iugpm.Core_MDF_Role_nm__c + ',' + iugpm.Core_MDF_Program_nm__c + ',' + iugpm.Core_MDF_User_id__c + ',' + iugpm.Core_MDF_User_id__r.Name + ',' + iugpm.Core_MDF_is_User_Active_ind__c; 
                    csvRecordList.add(csvRow);
                    Core_MDF_Int_Users_Partner_Geo_Mapping__c obj = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
                    obj.Id = iugpm.Id;
                    obj.Core_MDF_Active_Ind__c = false;
                    iupgmToInactivateList.add(obj);//Records to inactive
                }
            }  
            
        }catch(Exception ex){
	    //Avoid empty catch blocks
            Core_MDF_CCP_UtilityClass.logError(ex);
        }      
    }
    
    
    /*-----------------------------------------------------------------------------------
Method Name         : createContentVersion
@Input Parameters   : List of csv records.
Description         : This method creates file based on progam. 
------------------------------------------------------------------------------------*/
    public ContentVersion createContentVersion(List<String> csvRecordList){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'AGS_IUGPM_Sync.csv';
        String base64 = EncodingUtil.base64Encode(Blob.valueOf(String.join(csvRecordList,'\n')));
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.PathOnClient = 'AGS_IUGPM_Sync.csv';
        return cv;
    }
    
    public void saveAttachment(List<ContentVersion> contentVersionInsertList){
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
        if(recordTrackingId != null){
            for(ContentDocument contentDoc : [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId IN :contentVersionInsertList]){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDoc.Id; 
                cdl.LinkedEntityId = recordTrackingId;
                cdl.ShareType = 'V'; // V stands for "Viewer Access". You can also use E for "Edit Access"
                cdl.Visibility = 'InternalUsers';// set the visibility of the file. Other options are InternalUsers or SharedUsers
                contentDocLinkList.add(cdl);
            }
            insert contentDocLinkList;
        }
        
    }
    
    public List<string> getEligibleRoles(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Core_MDF_Int_Users_Partner_Geo_Mapping__c.Core_MDF_Role_nm__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry value : picklistEntry){
            pickListValuesList.add(value.getValue());
        }   
        return pickListValuesList;
    }
    
    global void finish(Database.BatchableContext bc) {
        if(!csvRecordList.isEmpty()){
            contentVersionInsertList.add(createContentVersion(csvRecordList));
        }
        
        if(recordTrackingId == null){
            Core_MDF_Record_Tracking__c rt = new Core_MDF_Record_Tracking__c();
            rt.Core_MDF_Scope_nm__c = 'AGS IUPGM Sync';
            Database.SaveResult insertedRecord = Database.insert(rt);
            
            if(insertedRecord != null && insertedRecord.isSuccess()){
                recordTrackingId = insertedRecord.getId();
            }  
        } 
        
        if(!contentVersionInsertList.isEmpty()){
            Database.insert(contentVersionInsertList);
            saveAttachment(contentVersionInsertList);
        }
        
        if(!iupgmToInactivateList.isEmpty()){
             Database.executeBatch(new Core_MDF_BulkUpdate_Batch(iupgmToInactivateList),1);
        }
       
        
        if(recordTrackingId != null && notifyUsers){
            List<String> userIdsList = new List<String>();
            List<Messaging.SingleEmailMessage> singleEmailList = new List<Messaging.SingleEmailMessage>();
            String templateName =  Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGMDiscrepancyEmailTemp');
            String iupgmGroupName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGMDiscrepancyRecipients');
            EmailTemplate template = [SELECT Id, HtmlValue, Subject 
                                      FROM EmailTemplate 
                                      WHERE DeveloperName = :templateName LIMIT 1];
            
            for(GroupMember grpMember : [SELECT Id, GroupId, UserOrGroupId, Group.DeveloperName 
                                         FROM GroupMember 
                                         WHERE Group.DeveloperName =:iupgmGroupName]){
                                             userIdsList.add(grpMember.UserOrGroupId);
                                         }
            
            for( User usr : [SELECT Id FROM user WHERE Id in: userIdsList]){
                Messaging.SingleEmailMessage sendEmail =new Messaging.SingleEmailMessage();
                sendEmail.setWhatId(recordTrackingId);
                sendEmail.setTemplateId(template.id);
                sendEmail.setTargetObjectId(usr.id);
                sendEmail.setSaveAsActivity(false);
                sendEmail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                singleEmailList.add(sendEmail);
            }
            
            if(singleEmailList != NULL && singleEmailList.size() > 0){
                Core_MDF_GenericClassToSendMail.sendEmails(singleEmailList);
            }            
        }
    }
}