/*********************************************************************************************************************
Apex Class Name  : PRM_IPA_DocumentUploadEmailService
Version       : 1.0
Created Date  : Oct 2025
Function      : Class to handle inbound emails received by the Email Service and process it

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Saba                  23/10/2025               Class to handle inbound emails received by the Email Service and process it

*********************************************************************************************************************/

public with sharing class PRM_IPA_DocumentUploadEmailService implements Messaging.InboundEmailHandler{
    public static Final String ORIGIN  = 'PRM_IPA_DocumentUploadEmailService';
    public static Final String SEVERITY  = 'Error';
    public static Final String PROJECT  = 'IPA';
    public static final String SCOPE    = 'PRM_IPA_DocumentUploadEmailService';  
    
	public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        result.success = true;
        try {
             
            if(email != null && checkEmailSubject(email.Subject)){
                
                String emailId = email.fromAddress;
                List<PRM_Registration_Request__c> regRequestList;
                
                if(String.isNotBlank(emailId)){
                    regRequestList = [Select id, PRM_Email_Id__c, Name from PRM_Registration_Request__c where PRM_Email_Id__c = :emailId
                                      and PRM_Channel_Program_Level_txt__c = 'Intel Partner Alliance' and PRM_Status__c NOT IN ('Approved', 'Rejected') order by createddate desc limit 1];    
                    
                    if(!regRequestList.isEmpty()){                       
                       List<PRM_Registration_Request__c> requestsToUpdate = new List<PRM_Registration_Request__c>();
                       PRM_Registration_Request__c regRequest = regRequestList[0];
                       Boolean isFileTypeRestricted = false;
                       if(email.binaryAttachments != null && !email.binaryAttachments.isEmpty()){
                        
                           List<ContentVersion> contentVersions = new List<ContentVersion>();                           
                           for (Messaging.InboundEmail.BinaryAttachment attachment : email.binaryAttachments) {                                
                               System.debug('attachment.mimeTypeSubType:' + attachment.mimeTypeSubType);
                               if(String.isNotBlank(attachment.mimeTypeSubType) && LabelConfiguration__mdt.getInstance('PRM_IPA_Document_Upload_Email_File_Types').Value__c.containsIgnoreCase(attachment.mimeTypeSubType.substringAfterLast('/'))){
                                   ContentVersion cv = new ContentVersion();
                                   cv.Title = attachment.fileName;
                                   cv.PathOnClient = '/' + attachment.fileName;
                                   cv.VersionData = attachment.body;
                                   cv.Origin = 'H'; // For historical upload source
                                   contentVersions.add(cv);
                               } else if(!LabelConfiguration__mdt.getInstance('PRM_IPA_Document_Upload_Email_File_Types').Value__c.containsIgnoreCase(attachment.mimeTypeSubType.substringAfterLast('/'))){
                               	   isFileTypeRestricted = true;	    
                               }
                           }
                           
                           if (!contentVersions.isEmpty()) {
                               PRM_DMLUtility.doinsert(contentVersions,'ContentVersion', 'PRM_IPA_DocumentUploadEmailService.handleInboundEmail');                     	
                               
                               // Get mapping of inserted ContentVersions to their ContentDocuments
                               Map<Id, Id> versionToDocMap = new Map<Id, Id>();
                               for (ContentVersion cv : [ SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions]){
                                   versionToDocMap.put(cv.Id, cv.ContentDocumentId);
                               }
                               
                               // Create ContentDocumentLinks to associate with the Registration Request
                               List<ContentDocumentLink> links = new List<ContentDocumentLink>();
                               for (ContentVersion cv : contentVersions) {
                                   if (versionToDocMap.containsKey(cv.Id)) {
                                       ContentDocumentLink cdl = new ContentDocumentLink();
                                       cdl.ContentDocumentId = versionToDocMap.get(cv.Id);
                                       cdl.LinkedEntityId = regRequest.Id;
                                       cdl.ShareType = 'V';
                                       //cdl.Visibility = 'AllUsers';
                                       links.add(cdl);
                                   }
                               }
                               
                               if (!links.isEmpty()) {
                                   PRM_DMLUtility.doinsert(links,'ContentDocumentLink', 'PRM_IPA_DocumentUploadEmailService.handleInboundEmail'); 
                               }
                               
                               //Update the status on reg request to indicate email is received from Partner for file upload                                                                
                               PRM_Registration_Request__c regReq = new PRM_Registration_Request__c();
                               regReq.id = regRequest.Id;
                               regReq.PRM_Status__c = 'New';
                               regReq.Name = regRequest.Name; 
                               requestsToUpdate.add(regReq);                                                                                                                       
                           }
                       }
                        
                        //Create email log
                        PRM_EmailLog__c log = new PRM_EmailLog__c();
                        log.PRM_EmailDeliverabilityStatus__c = true ;            
                        log.PRM_Timestamp__c = DateTime.now();
                        log.PRM_ToEmailID__c = String.valueOf(email.toAddresses);                        
                        log.PRM_EmailContent__c =  email.htmlBody;
                        log.PRM_EmailHTMLContent__c = email.htmlBody;
                        log.PRM_Subject__c = email.subject;
                        log.PRM_Type__c = 'IPA';
                        log.PRM_IPA_Registration_Request__c = regRequest.Id;
                        log.PRM_Email_API_Response__c = 'Email received successfully.';
                        if(isFileTypeRestricted == true){
                        	log.PRM_Email_API_Response__c = LabelConfiguration__mdt.getInstance('PRM_IPA_File_Type_Not_Supported_Message').Value__c;    
                        }
                        log.PRM_EmailDeliverabilityStatus__c = true;
                        
                        PRM_DMLUtility.doinsert(new List<PRM_EmailLog__c>{log},'PRM_EmailLog__c', 'PRM_IPA_DocumentUploadEmailService.handleInboundEmail'); 
                        
                        if(!requestsToUpdate.isEmpty()){
                            PRM_DMLUtility.doupdate(requestsToUpdate,'PRM_Registration_Request__c','PRM_IPA_DocumentUploadEmailService.handleInboundEmail');                	  
                            sendNotificationToIPAdmins(requestsToUpdate);
                        }
                    }
                }
            }
        } catch (Exception e) {
            Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY,'', e.getMessage() ,'' ,'PRM_IPA_DocumentUploadEmailService' ,'' ,e);        
        }
                	
        return result;      
	}
    
    public static void sendNotificationToIPAdmins(List<PRM_Registration_Request__c> reqList){
        if(!reqList.isEmpty()){
            //create link to records
            String sfdcBaseURL = URL.getOrgDomainUrl().toExternalForm();
            String hyperlink;
            List<String> toAddresses = new List<String>();
            for(GroupMember gm: [Select UserOrGroup.email from GroupMember where Group.DeveloperName = :LabelConfiguration__mdt.getInstance('IPA_All_Admin_Group_Name').Value__c and UserOrGroup.isActive = true]){
            	if(String.IsNotBlank(gm.UserOrGroup.email) && toAddresses.size() < Integer.valueOf(LabelConfiguration__mdt.getInstance('PRM_IPA_Admin_Group_Users_Limit').Value__c))
	                toAddresses.add(gm.UserOrGroup.email);    
            }
            for(PRM_Registration_Request__c req: reqList){
            	hyperlink = '<a href="' + sfdcBaseURL + '/' + req.id + '" target="_self">' + req.Name + '</a>' + '<br>';    
            }
            
            EmailTemplate temp = [select id, developername, name,HtmlValue,Body,Subject from EmailTemplate where developername = :LabelConfiguration__mdt.getInstance('IPA_Doc_Upload_Complete_EmailTemp_Name').Value__c];
            Messaging.SingleEmailMessage mail = PRM_SendDocumentUploadEmail.createEmailRecord(temp,toAddresses,null ); 
            String htmlBody = mail.getHTMLBody();
            mail.setHTMLBody(htmlBody.replace('{hyperlinks}', hyperlink));
            List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address =: Label.PRM_wsm_postmaster_intel_com];
            if(owea.size() > 0){
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            } 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }	    
    }
    
    private boolean checkEmailSubject(String receivedEmailSubject){
        boolean isSubMatching = false;
        for(String uploadEmailSubject: System.label.PRM_IPA_File_Upload_Email_Subject.split(';')){
            if(receivedEmailSubject.contains(uploadEmailSubject)){
            	isSubMatching = true;    
            }    
        }
        
        return isSubMatching;
    }
}