public without sharing class Core_IPS_File_Assignment_Handler{
/***************************************************************************************************
* Version     : 1.0 
* Created Date: 30 Oct 2015
* Function    :  
* Input Parameters: Trigger Context
* Output Parameters: None
* Transactions: After Insert, After Update, Before Insert, Before Update
* Description: 
* Used in    : Core_IPS_File_Assignment_Dispatcher
* Number of Queries Within this Method: 
* Number of Queries in Loop: 0
* Number of Queries from Called methods:0
* Number of times called: Once for trigger execution
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Nischal                  10/30/2015              Created
* Malhotra, Abhimanyu S    11/20/2015              Re-write
****************************************************************************************************/  
    private static Id OWEmailId;
    private static EmailTemplate EmailTemplateObj;
    private static Set<ID> FileAssignIDSet = new Set<ID>();
/**************************************************************************************************
* Method name  : sendEmailNotification
* Description  : Send email for external file download
* Return Type  : n/a
* Parameters   : Trigger Context
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     11/21/2015              Created
****************************************************************************************************/    
    public static void sendEmailNotification(List<Core_IPS_File_Assignment__c> oldList, List<Core_IPS_File_Assignment__c> newList, 
                            Map<Id,Core_IPS_File_Assignment__c> oldMap,Map<Id,Core_IPS_File_Assignment__c> newMap){   
                                
        Set<ID> SupportedProdIDSet = new Set<ID>();
        Set<ID> AccountIDSet = new Set<ID>();
        Set<ID> AccountSPIDSet = new Set<ID>();
        Set<ID> AccountContactIDSet = new Set<ID>(); 
        Set<ID> SPContactIDSet = new Set<ID>(); 
        Set<ID> ContactIDSet = new Set<ID>();    
        Boolean ErrorFlag = false;
        Id FileUploadMasterId; 
        
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('sendIPSExtDownlEmailNotification')){           
            //Add Supported Products and Account to respective sets
            for(Core_IPS_File_Assignment__c CoreIPSFileAssign : newList){
                //SP Only scenario
                if(CoreIPSFileAssign.Core_Supported_Product__c != null && CoreIPSFileAssign.Core_Account__c == null){
                  if( trigger.isUpdate && oldMap != null && !oldMap.isEmpty()){
                Core_IPS_File_Assignment__c CoreIPSFileAssignOld = new Core_IPS_File_Assignment__c();    
                CoreIPSFileAssignOld = oldMap.get(CoreIPSFileAssign.Id);   
                      if(CoreIPSFileAssign.Core_Supported_Product__c != CoreIPSFileAssignOld.Core_Supported_Product__c || 
                         CoreIPSFileAssign.Core_Account__c != CoreIPSFileAssignOld.Core_Account__c){
                      SupportedProdIDSet.add(CoreIPSFileAssign.Core_Supported_Product__c);                                                  
                      }                 
                } else {
                SupportedProdIDSet.add(CoreIPSFileAssign.Core_Supported_Product__c);
                }   
                }
                //SP and Account scenario
                if(CoreIPSFileAssign.Core_Account__c != null && CoreIPSFileAssign.Core_Supported_Product__c != null){
                                  if( trigger.isUpdate && oldMap != null && !oldMap.isEmpty()){
                Core_IPS_File_Assignment__c CoreIPSFileAssignOld = new Core_IPS_File_Assignment__c();    
                CoreIPSFileAssignOld = oldMap.get(CoreIPSFileAssign.Id);   
                      if(CoreIPSFileAssign.Core_Supported_Product__c != CoreIPSFileAssignOld.Core_Supported_Product__c || 
                         CoreIPSFileAssign.Core_Account__c != CoreIPSFileAssignOld.Core_Account__c){
                    AccountIDSet.add(CoreIPSFileAssign.Core_Account__c);
                    AccountSPIDSet.add(CoreIPSFileAssign.Core_Supported_Product__c);                                                 
                      }                 
                                  } else {
                    AccountIDSet.add(CoreIPSFileAssign.Core_Account__c);
                    AccountSPIDSet.add(CoreIPSFileAssign.Core_Supported_Product__c);                                      
                                  }     
                }
                if (FileUploadMasterId == null){
                    FileUploadMasterId = CoreIPSFileAssign.Core_IPS_File_Upload_Master__c;  
                } else {
                    if (FileUploadMasterId != CoreIPSFileAssign.Core_IPS_File_Upload_Master__c ) {
                        ErrorFlag = true;
                        break;
                    }
                }
                //Build the File Assignment ID set
                FileAssignIDSet.add(CoreIPSFileAssign.Id);
            }  
            if (ErrorFlag == false) {
                //SP Only Scenario
                if(SupportedProdIDSet != null && SupportedProdIDSet.Size() > 0 ) {    
                    SPContactIDSet = getSPContactIds(SupportedProdIDSet);
                }           
                //SP and Account scenario
                if(AccountIDSet != null && AccountIDSet.Size() > 0 ) { 
                    AccountContactIDSet = getAccountContactIds(AccountIDSet,AccountSPIDSet);
                }
                //Get set
                ContactIDSet.addAll(SPContactIDSet);
                ContactIDSet.addAll(AccountContactIDSet);
                //Send Email
                if (ContactIDSet != null && ContactIDSet.size() > 0) {
                    sendEmail(ContactIDSet,FileUploadMasterId, FileAssignIDSet);
                }
            }
        }
    }    
/**************************************************************************************************
* Method name  : getSPContactIds
* Description  : Contact id processing for external file download
* Return Type  : Set<ID>
* Parameters   : Set<Id> SupportedProdIDSet Set<Id> AccountIDSet
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     11/21/2015              Created
****************************************************************************************************/    
    public static Set<Id> getSPContactIds(Set<Id> SupportedProdIDSet){
        Set<ID> ContactIDSet = new Set<ID>();
        Set<ID> AssetIDSet = new Set<ID>();
        Set<ID> SupportedProdUserIDSet = new Set<ID>();
        Set<ID> SupportedProdGroupIDSet = new Set<ID>();  
        Set<Id> UserRoleIdSet = new Set<Id>();
        Set<Id> UserIdSet = new Set<id>();
        List<Asset> AssetLst = new List<Asset>();
        List<AssetShare> AssetShareLst = new List<AssetShare>();
        List<groupmember> GroupmemberLst = new List<groupmember>();
        List<User> SupportedProdUserLst = new List<User>();
        List<Group> RoleGroupLst = new List<Group>();
        List<User> UserRoleLst = new List<User>();
        
        //Get Assets associated to the Supported Products
        if(SupportedProdIDSet != null && SupportedProdIDSet.size()> 0 ){
            //FLS check added-Venugopal
            if(Asset.SObjectType.getDescribe().isAccessible()){
            AssetLst = [Select ID from Asset where Core_Supported_Product__c in : SupportedProdIDSet and
                        RecordtypeId =:System.label.Core_IPS_Asset_Recordtype_Id];
            }
        }
        //Move Assets to a Set
        for(Asset Assetobj : AssetLst){
            AssetIDSet.add(AssetObj.id);
        }
        //Get User Id's from Asset Share
        if(AssetIDSet != null && AssetIDSet.size() > 0 ){
            //FLS check added_Venugopal
            if(AssetShare.SObjectType.getDescribe().isAccessible()){
            AssetShareLst = [SELECT Id, AssetId, UserOrGroupId FROM AssetShare where AssetId in :AssetIDSet];
            }
        }
        //Move to User Id set for Direct User         
        for(AssetShare AssetShr : AssetShareLst){
            String UserORGroupCheck = AssetShr.UserOrGroupId;
            if(string.valueof(UserORGroupCheck).startsWith('005')){
                SupportedProdUserIDSet.add(AssetShr.UserOrGroupId);
            }
            //Move to Group set for an Indirect User     
            if(string.valueof(UserORGroupCheck).startsWith('00G')){
                SupportedProdGroupIDSet.add(AssetShr.UserOrGroupId);
            }
        }
        //Fill up GroupMember List     
        if(SupportedProdGroupIDSet != null && SupportedProdGroupIdSet.size() > 0){
            GroupmemberLst = [select userorgroupid from groupmember where groupid in :SupportedProdGroupIDSet];
        }
        //Get Users from the Group Member List
        for(GroupMember GroupMemberObj : GroupmemberLst){
            if(string.valueof((GroupMemberObj.userorgroupid)).startswith('005')){
                SupportedProdUserIDSet.add(GroupMemberObj.userorgroupid);
            }
        }
        //Check whether Group is of type Role or Role Subordinate
        //Get Related Role Id's and then Related Users
        if(SupportedProdGroupIDSet != null && SupportedProdGroupIdSet.size() > 0){
            RoleGroupLst = [select id, RelatedId, Type from Group where  type in ('Role','RoleAndSubordinates','roleAndSubordinatesInternal') 
                            and Id in :SupportedProdGroupIDSet]; //RoleAndSubordinates to roleAndSubordinatesInternal change US-0049835
            for(Group RLGrpObj : RoleGroupLst ){
                UserRoleIdSet.add(RLGrpObj.RelatedId);
            }    
            if(UserRoleIdSet != null && UserRoleIdSet.size() > 0){
                //Get All Users for the Role Id's   
                UserRoleLst = [select id from User where UserRoleid in :UserRoleIdSet];
                for (User UsrObj : UserRoleLst)  {
                    SupportedProdUserIDSet.add(UsrObj.Id);
                }  
            }
        }
        //Get Contact details for the identified Users
        //Filter by IPS Flags, No filter for Bounced back emails   
        if(SupportedProdUserIDSet != null && SupportedProdUserIDSet.size() > 0){             
            SupportedProdUserLst = [Select u.Id, u.ContactId From User u where Id in :SupportedProdUserIDSet and 
                                    u.Contact.Core_IPS_Email_Opt_Out__c = false and 
                                    u.Contact.Core_IPS_Active__c = true and u.Contact.Email != null and u.ContactId != null and isactive =true];
        }
        //Build ContactId set
        if(SupportedProdUserLst != null && SupportedProdUserLst.size() > 0 ){
            for(User UserObj : SupportedProdUserLst){
                ContactIDSet.add(UserObj.ContactId);   
            }
        }
        return ContactIDSet;
    }
/**************************************************************************************************
* Method name  : getAccountContactIds
* Description  : Contact id processing for external file download
* Return Type  : Set<ID>
* Parameters   : Set<Id> AccountIDSet, Set<Id> AccountSPIDSet
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     02/02/2016              Created
****************************************************************************************************/     
    public static Set<Id> getAccountContactIds(Set<Id> AccountIDSet, Set<Id> AccountSPIDSet){
        List<Contact> AccountContactLst = new List<Contact>();
        List<Contact> UserContactLst = new List<Contact>();
        Set<ID> AccountContactIDSet = new Set<ID>(); 
        Set<ID> AccountContactSPIDSet = new Set<ID>();
        Set<ID> ContactIDSet = new Set<ID>(); 
        //Build AccountId set
        if(AccountIDSet != null && AccountIDSet.size() > 0){
            //FLS check added-Venugopal
            if(Contact.SObjectType.getDescribe().isAccessible()){
            AccountContactLst = [Select c.Id from Contact c where Accountid in : AccountIDSet and c.Email != null and
                                 c.Core_IPS_Email_Opt_Out__c = false and 
                                 c.Core_IPS_Active__c = true];
            }
        }
        if(AccountContactLst != null && AccountContactLst.size() > 0 ){
            for(Contact ContactObj : AccountContactLst){
                AccountContactIDSet.add(ContactObj.Id);   
            }
        }
        if(AccountContactIDSet != null && AccountContactIDSet.size() > 0 && 
           AccountSPIDSet != null && AccountSPIDSet.size() > 0){
               AccountContactSPIDSet =  getSPContactIds(AccountSPIDSet); 
           }
        //Check whether Direct Account Contacts have SP Access
        for (Id ContactId :  AccountContactIDSet ) {
            if (AccountContactSPIDSet.contains(ContactId)){
                ContactIDSet.add(ContactId);  
            }
        }
        return ContactIDSet;
    }
    
/**************************************************************************************************
* Method name  : sendEmail
* Description  : Send external email
* Return Type  : n/a
* Parameters   : Set<Id> ContactIds Id FileUploadMasterId
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     11/21/2015              Created
****************************************************************************************************/        
    @future
    public static void sendEmail(Set<Id> ContactIds, Id FileUploadMasterId, Set<Id> FileAssignIds){ 
        OWEmailId = null; 
        Boolean SaveAsActivityFlag = false;
        Boolean AllOrNoneFlag = false;
        
        try {           
            Core_IPS_ExtDownNotif_Email_Settings__c ExtSettingSaveAsActivity  = Core_IPS_ExtDownNotif_Email_Settings__c.getValues('SaveAsActivity');
            Core_IPS_ExtDownNotif_Email_Settings__c ExtSettingAllOrNone  = Core_IPS_ExtDownNotif_Email_Settings__c.getValues('AllOrNone');
            if(ExtSettingSaveAsActivity != null){
                SaveAsActivityFlag = boolean.valueof(ExtSettingSaveAsActivity.Core_Value__c);
            }          
            if(ExtSettingAllOrNone != null){
                AllOrNoneFlag = boolean.valueof(ExtSettingAllOrNone.Core_Value__c);
            }
            //Email Template ID
            EmailTemplateObj = [select id, name from EmailTemplate where DeveloperName = :system.label.Core_IPS_File_ExtDownlNotif_Email_Templ];
            //FLS check added -Venugopal
            if(OrgWideEmailAddress.SObjectType.getDescribe().isAccessible()){
            for(OrgWideEmailAddress OrgWideEmailObj : [select id, Address, DisplayName from OrgWideEmailAddress]) {
                if(OrgWideEmailObj.DisplayName == system.label.Core_IPS_Org_Wide_Email_Display_Name) {
                    OWEmailId = OrgWideEmailObj.Id;
                    break;
                }
            }
        }
            //Further processing only if Email template and IPS Org Wide EMail Id found
            if(EmailTemplateObj.Id != null && OWEmailId != null ){
                //Stash for Bulk processing
                for(Id ContactId : ContactIds) {
                    Core_EmailUtil.to(ContactId)
                        .templateId(EmailTemplateObj.Id)
                        .whatId(FileUploadMasterId)
                        .orgWideEmailAddressId(OWEmailId)
                        .saveAsActivity(SaveAsActivityFlag)
                        .stashForBulk();
                }
                //Send Email
                Core_EmailUtil.sendBulkEmail(AllOrNoneFlag);
                
                               
                //Send Report to Internal user and/or Log any errors
                //Check Flags for each activity
                if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('sendIPSExtDownlNotifIntEmailReport') == true || 
                   Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('IPSExtDownlNotifLogErrors')){
                       sendReport(ContactIds,FileUploadMasterId,FileAssignIds); 
                   }
            }
        } catch (System.EmailException ex) {

            sendExceptionEmail(ex, FileUploadMasterId,FileAssignIds);   
        }
    }
/**************************************************************************************************
* Method name  : sendReport
* Description  : Send email report to internal user and log any errors
* Return Type  : n/a
* Parameters   : Set<Id> ContactIds Id FileUploadMasterId
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     11/21/2015              Created
****************************************************************************************************/            
    public static void sendReport(Set<Id> ContactIds, Id FileUploadMasterId, Set<Id> FileAssignIds) {
        String htmlBody = '';
        String subject = '';
        String htmlBodyFileAssignInfo = '';
        String htmlBodyFileAssignTriggerInfo = '';
        String recordLink = '';       
        Core_IPS_File_Upload_Master__c FileUpldMasterObj;
        Map<Id,String> FailedContactIdErrMsgMap = new Map<Id,String>();
        Map<Id,Contact> ContactIdObjMap;
  List<Core_IPS_File_Assignment__c> FileAssignmentsLst = new List<Core_IPS_File_Assignment__c>();
        //Contact details
        //FLS check added-Venugopal
        if(contact.SObjectType.getDescribe().isAccessible()){
        ContactIdObjMap = new Map<Id,Contact>([select Id, Name, Account.Name, Email from contact where id in :ContactIds]);
        }
        //Get Errors
        for (Messaging.SendEmailResult sendEmailResult : Core_EmailUtil.last_sendEmail_result) {
            if(!sendEmailResult.isSuccess()){
                for (Messaging.Sendemailerror sendEmailError : sendEmailResult.getErrors()){
                    FailedContactIdErrMsgMap.put(sendEmailError.TargetObjectId,sendEmailError.Message);                    
                }
            }               
        }

        //File Master details
        //FLS check added-Venugopal
        if(Core_IPS_File_Upload_Master__c.SObjectType.getDescribe().isAccessible()){
                                        FileUpldMasterObj = [select Id, Name, Core_File_Name__c, Core_File_Description__c, Core_Category__c,  
                                                            Core_Effective_Date__c, Core_Expiration_Date__c, Core_File_Size__c from Core_IPS_File_Upload_Master__c 
                                                            where id =:FileUploadMasterId ];
             }
        //Internal Email Flag check
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('sendIPSExtDownlNotifIntEmailReport') == true){
            try {
                //File Assignment Information
                htmlBodyFileAssignInfo =  'File Name: ' + FileUpldMasterObj.Core_File_Name__c;
                htmlBodyFileAssignInfo +=  '<p>File#: ' + FileUpldMasterObj.Name + '</p>';
                htmlBodyFileAssignInfo +=  '<p>File Category: ' + FileUpldMasterObj.Core_Category__c + '</p>';
                htmlBodyFileAssignInfo +=  '<p>File Size: ' + FileUpldMasterObj.Core_File_Size__c + '</p>';
                htmlBodyFileAssignInfo +=  '<p>File Effective Date: ' + FileUpldMasterObj.Core_Effective_Date__c.format() + '</p>';
                htmlBodyFileAssignInfo +=  '<p>File Expiration Date: ' + FileUpldMasterObj.Core_Expiration_Date__c.format() + '</p>';
                htmlBody += htmlBodyFileAssignInfo;
                htmlBodyFileAssignTriggerInfo += '</br>' + '<table><tr><th>' + 'Following File Assignment Updates Initiated these Email Notifications:' + '</th></tr></table>' + 
                    '</br><table border="1"<tr><th>' + 'FileAssignment#' + '</th><th>' + 'Supported Product' + 
                    '</th><th>' + 'Account' + '</th><th>' + 'Support-Org' + '</th></tr>';
                if(Core_IPS_File_Assignment__c.SObjectType.getDescribe().isAccessible()){
                FileAssignmentsLst = [select Name, Core_Supported_Product_Name__c, Core_Account__r.Name, Core_Support_Org_ID__c 
                                                                        from Core_IPS_File_Assignment__c where id in :FileAssignIds]; 
                                 }
                for(Core_IPS_File_Assignment__c FileAssignObj : FileAssignmentsLst){
                    String FileAssNum = FileAssignObj.Name;
                    String SuppProdName = FileAssignObj.Core_Supported_Product_Name__c ;
                    String AccName = FileAssignObj.Core_Account__r.Name;
                    String SuppOrgName = FileAssignObj.Core_Support_Org_ID__c;  
                    if(AccName == null){AccName = '';}
                    if(SuppProdName == null){SuppProdName = '';}   
                    if(SuppOrgName == null){SuppOrgName = '';}   
                    htmlBodyFileAssignTriggerInfo += '<tr><td>' + FileAssNum + '</td><td>' + SuppProdName + '</td><td>' + AccName 
                        + '</td><td>' + SuppOrgName + '</td></tr>';
                }
                htmlBodyFileAssignTriggerInfo += '</table>';
                htmlBody += htmlBodyFileAssignTriggerInfo;                
                //Open Table
                subject = 'Ext.File Download Notification Report for File: ' + FileUpldMasterObj.Core_File_Name__c;
                //Body 
                htmlBody += '<table><tr><th>' + 'Summary Notification Report: ' + '</th></tr></table>';      
                htmlBody += '<table border="1"><tr><th>' + 'Contact' + '</th><th>' + 'Contact Email' + '</th><th>' + 'Account' + '</th><th>Status</th></tr>';
                //Build Table Rows
                for(Id ContactId : ContactIds ){  
                    //Build Success
                    if(FailedContactIdErrMsgMap.get(ContactId) == null){
                        //Move to object as referening with '.' may throw exception with null values    
                        Contact ContactObj = ContactIdObjMap.get(ContactId);     
                        String Contact = ContactObj.Name;
                        String ContactEmail = ContactObj.Email;
                        String Account = ContactObj.Account.Name;
                        String SuccessMessage = 'Success';
                        htmlBody += '<tr><td>' + Contact + '</td><td>' + ContactEmail + '</td><td>' 
                            + Account + '</td><td>' + SuccessMessage + '</td></tr>';
                    }
                    else {
                        //Move to object as referening with '.' may throw exception with null values    
                        Contact ContactObj = ContactIdObjMap.get(ContactId);     
                        String Contact = ContactObj.Name;
                        String ContactEmail = ContactObj.Email;
                        String Account = ContactObj.Account.Name;
                        String ErrorMessage = 'Error: ' + FailedContactIdErrMsgMap.get(ContactId); 
                        if(ContactEmail == null){ContactEmail = '';}
                        htmlBody += '<tr><td>' + Contact + '</td><td>' + ContactEmail + '</td><td>' + Account 
                            + '</td><td>' + ErrorMessage + '</td></tr>';
                    }   
                }
                //Close table
                htmlBody += '</table>';
                //Convert to Attach
                Messaging.EmailFileAttachment Attachment = new Messaging.EmailFileAttachment();
                List<Messaging.Emailfileattachment> AttachmentLst = new List<Messaging.Emailfileattachment>();
                Attachment.setContentType('application/pdf');
                Attachment.setFileName('Report.pdf');
                Attachment.body = Blob.toPdf(htmlBody);
                AttachmentLst.add(Attachment);
                //Email to User intiating the File Assignment
                    Core_EmailUtil.to(UserInfo.getUserId())
                    .htmlBody(htmlBodyFileAssignInfo)
                    .subject(subject)
                    .saveAsActivity(false)
                    .fileAttachments(AttachmentLst)
                    .orgWideEmailAddressId(OWEmailId)
                    .sendEmail(true);
            } catch (System.EmailException ex){
            }
        }
        //Log Errors
        if(FailedContactIdErrMsgMap != null && FailedContactIdErrMsgMap.size() > 0 && 
           Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('IPSExtDownlNotifLogErrors')) {
               logEmailSendErrors(FailedContactIdErrMsgMap, FileUploadMasterId, ContactIdObjMap);
           }
    }
/**************************************************************************************************
* Method name  : logEmailSendErrors
* Description  : Log any errors while sending emails
* Return Type  : N/A
* Parameters   : Map<Id,String> FailedContactIdErrMsgMap, Id FileUploadMasterId, Map<Id,Contact> ContactIdObjMap
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     11/21/2015              Created
****************************************************************************************************/                
    public static void logEmailSendErrors(Map<Id,String> FailedContactIdErrMsgMap, Id FileUploadMasterId, Map<Id,Contact> ContactIdObjMap){
        Map<Id,Id> EmailLoggedContactIdLogIdMap = new Map<Id,Id>(); 
        List<Core_IPS_Email_Log__c> EmailLogInsertLst = new List<Core_IPS_Email_Log__c>();
       List<Core_IPS_Email_Log__c> EmailLogLst = new List<Core_IPS_Email_Log__c>();
        //Get any existing Errors for the current object 
        //FLS check added-Venugopal 
        if(Core_IPS_Email_Log__c.SObjectType.getDescribe().isAccessible()){
        EmailLogLst = [select Id, Core_TargetObjectId__c, Core_WhatId__c from Core_IPS_Email_Log__c 
                                                   where Core_WhatId__c =:FileUploadMasterId and Core_TargetObjectId__c in :FailedContactIdErrMsgMap.keySet() 
                                                   and Core_Project__c = 'IPS' and Core_ApplicationArea__c = 'IPS External Download Notification'];
        }
        
                                                   //Map of already logged Contacts
        for (Core_IPS_Email_Log__c EmailLogObject : EmailLogLst ){
            EmailLoggedContactIdLogIdMap.put(EmailLogObject.Core_TargetObjectId__c, EmailLogObject.Id);
        }  

        //Now log for the ones that were not already logged
        for( Id FailedContactId : FailedContactIdErrMsgMap.keySet() ){
            if(EmailLoggedContactIdLogIdMap.get(FailedContactId)== null){
                Core_IPS_Email_Log__c EmailLog = new Core_IPS_Email_Log__c();
                String ErrorMsg;
                if (FailedContactIdErrMsgMap.get(FailedContactId) != null && FailedContactIdErrMsgMap.get(FailedContactId) != ''){
                ErrorMsg = FailedContactIdErrMsgMap.get(FailedContactId);
                    If (ErrorMsg.length() > 255){
                    ErrorMsg = ErrorMsg.substring(0,255);    
                    } 
                }
                /*US1021249 - 05/27/2021 - yamini - FLS Check for security vulnerability --*/
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_TargetObjectId__c.isCreateable()) {
                EmailLog.Core_TargetObjectId__c = FailedContactId; 
               // }
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_WhatId__c.isCreateable()) {
                EmailLog.Core_WhatId__c = FileUploadMasterId;
               // }
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_Project__c.isCreateable()) {
                EmailLog.Core_Project__c = 'IPS';
               // }
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_ApplicationArea__c.isCreateable()) {
                EmailLog.Core_ApplicationArea__c = 'IPS External Download Notification';
               // }
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_Message__c.isCreateable()) {
                EmailLog.Core_Message__c = ErrorMsg;
               // }
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_Status__c.isCreateable()) {
                EmailLog.Core_Status__c = 'Error';
               // }
                //if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_OrgWideEmailAddressId__c.isCreateable()) {
                EmailLog.Core_OrgWideEmailAddressId__c = OWEmailId;
                //}
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_TemplateID__c.isCreateable()) {
                EmailLog.Core_TemplateID__c = EmailTemplateObj.Id;
                //}
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_TargetObjectName__c.isCreateable()) {
                EmailLog.Core_TargetObjectName__c = ContactIdObjMap.get(FailedContactId).Name;
               // }
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_TargetObjectEmail__c.isCreateable()) {
                EmailLog.Core_TargetObjectEmail__c = ContactIdObjMap.get(FailedContactId).Email;
               // }
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_TargetObjectRelatedObjName__c.isCreateable()) {
                EmailLog.Core_TargetObjectRelatedObjName__c = ContactIdObjMap.get(FailedContactId).Account.Name;
               // }
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_TargetObjectType__c.isCreateable()) {
                EmailLog.Core_TargetObjectType__c = 'Contact';
              //  }
               // if (Schema.sObjectType.Core_IPS_Email_Log__c.fields.Core_TargetObjectRelatedObjType__c.isCreateable()) {
                EmailLog.Core_TargetObjectRelatedObjType__c = 'Account';
               // }
                EmailLogInsertLst.add(EmailLog);
            }
        }
        //Insert
        if (EmailLogInsertLst != null && EmailLogInsertLst.size() > 0){
            insert EmailLogInsertLst;
        }
    }
/**************************************************************************************************
* Method name  : sendExceptionEmail
* Description  : Send email to user initiating file assignment - if any exceptions encountered
* Return Type  : n/a
* Parameters   : Set<Id> ContactIds Id FileUploadMasterId
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     11/21/2015              Created
****************************************************************************************************/              
    public static void sendExceptionEmail(System.EmailException Error, Id FileUploadMasterId, Set<Id> FileAssignIds ) {
        String htmlBodyFileAssignInfo = '';
        String htmlBody = '';
        String subject = '';
        Core_IPS_File_Upload_Master__c FileUpldMasterObj;
  List<Core_IPS_File_Assignment__c> FileAssignmentsLst = new List<Core_IPS_File_Assignment__c>();
        //File Master details
        //FLS check added-Venugopal
        if(Core_IPS_File_Upload_Master__c.SObjectType.getDescribe().isAccessible()){        
                                       FileUpldMasterObj = [select Id, Name, Core_File_Name__c, Core_File_Description__c, Core_Category__c, 
                                                            Core_Effective_Date__c, Core_Expiration_Date__c, Core_File_Size__c from Core_IPS_File_Upload_Master__c 
                                                            where id =:FileUploadMasterId ];  
        }
        //Subject
        subject = 'Ext.File Download Notification Report for File: ' + FileUpldMasterObj.Core_File_Name__c;
        //Error Message
        htmlBody = 'Following Exception While Sending Email: ' + Error;
        htmlBody += '</br>';
        //File Assignment Information
        htmlBodyFileAssignInfo =  '<p>File Name: ' + FileUpldMasterObj.Core_File_Name__c + '</p>';
        htmlBodyFileAssignInfo +=  '<p>File#: ' + FileUpldMasterObj.Name + '</p>';
        htmlBodyFileAssignInfo +=  '<p>File Category: ' + FileUpldMasterObj.Core_Category__c + '</p>';
        htmlBodyFileAssignInfo +=  '<p>File Size: ' + FileUpldMasterObj.Core_File_Size__c + '</p>';
        htmlBodyFileAssignInfo +=  '<p>File Effective Date: ' + FileUpldMasterObj.Core_Effective_Date__c + '</p>';
        htmlBodyFileAssignInfo +=  '<p>File Expiration Date: ' + FileUpldMasterObj.Core_Expiration_Date__c + '</p>';
        htmlBodyFileAssignInfo += '</br>' + '<table><tr><th>' + 'Following File Assignment Updates Initiated these Email Notifications:' + '</th></tr></table>' + 
            '</br><table border="1"<tr><th>' + 'FileAssignment#' + '</th><th>' + 'Supported Product' + 
            '</th><th>' + 'Account' + '</th><th>' + 'Support-Org' + '</th></tr>';
        if(Core_IPS_File_Assignment__c.SObjectType.getDescribe().isAccessible()){
        FileAssignmentsLst = [select Name, Core_Supported_Product_Name__c, Core_Account__r.Name, Core_Support_Org_ID__c 
                                                                        from Core_IPS_File_Assignment__c where id in :FileAssignIds]; 
        }
        for(Core_IPS_File_Assignment__c FileAssignObj : FileAssignmentsLst){
            String FileAssNum = FileAssignObj.Name;
            String SuppProdName = FileAssignObj.Core_Supported_Product_Name__c ;
            String AccName = FileAssignObj.Core_Account__r.Name;
            String SuppOrgName = FileAssignObj.Core_Support_Org_ID__c;  
            if(AccName == null){AccName = '';}
            if(SuppProdName == null){SuppProdName = '';}   
            if(SuppOrgName == null){SuppOrgName = '';}   
            htmlBodyFileAssignInfo += '<tr><td>' + FileAssNum + '</td><td>' + SuppProdName + '</td><td>' + AccName 
                + '</td><td>' + SuppOrgName + '</td></tr>';
        }
        htmlBodyFileAssignInfo += '</table>';
        htmlBody += htmlBodyFileAssignInfo;
        //Email to User intiating the File Assignment
            Core_EmailUtil.to(UserInfo.getUserId())
            .htmlBody(htmlBody)
            .subject(subject)
            .saveAsActivity(false)
            .orgWideEmailAddressId(OWEmailId)          
            .sendEmail(true);
    }
/**************************************************************************************************
* Method name  : updateFileDescription
* Description  : Update File Description to help List view Reports. This is a log text field & cannot
*                be used in formula's
* Return Type  : n/a
* Parameters   : Trigger Context
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Malhotra, Abhimanyu S     02/07/2016              Created
****************************************************************************************************/                  
    public static void updateFileDescription(List<Core_IPS_File_Assignment__c> oldList, List<Core_IPS_File_Assignment__c> newList, Map<Id,Core_IPS_File_Assignment__c> oldMap,Map<Id,Core_IPS_File_Assignment__c> newMap){ 
        if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateIPSFileAssignment')){ 
            Set<Id> FileUploadIds = new Set<Id>();
            //Get File Upload Master ID's
            for(Core_IPS_File_Assignment__c CoreIPSFileAssign : newList){
                FileUploadIds.add(CoreIPSFileAssign.Core_IPS_File_Upload_Master__c);
            }  
            //Get File Description
            Map<Id,Core_IPS_File_Upload_Master__c> FileUploadMap = new Map<Id,Core_IPS_File_Upload_Master__c>([select id, Core_File_Description__c from Core_IPS_File_Upload_Master__c where id in :FileUploadIds]); 
            if(FileUploadMap != null && FileUploadMap.size()> 0){   
                //Update File Description
                for(Core_IPS_File_Assignment__c CoreIPSFileAssign : NewList){
                    if (FileUploadMap.get(CoreIPSFileAssign.Core_IPS_File_Upload_Master__c) != null){
                        Core_IPS_File_Upload_Master__c FileUploadObj = new Core_IPS_File_Upload_Master__c();
                        FileUploadObj = FileUploadMap.get(CoreIPSFileAssign.Core_IPS_File_Upload_Master__c);
                        CoreIPSFileAssign.Core_File_Description__c = FileUploadObj.Core_File_Description__c;           
                    }
                }
            } 
        }
    }
}