/**
* @File Name : Core_IPS_BugAssistController.cls
* @Description : This Controller is use for BugAssist Feature related functionality
* @Author : Accellor Software Private Ltd.
* @Last Modified By : Hassan Khan
* @Last Modified On : October 9, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 9, 2024 |   | Initial Version
**/

public with sharing class Core_IPS_BugAssistController {
	/* Tushar -- 12/05/2026 --- CRUD Added as part of vulnerability fix. */    
    private static final String ALLOWED_HOST = 'https://eftlab.intel.com/';

    //Created by Deepaksai as part of BugAssist
    @AuraEnabled(cacheable=false)
    public static string createIPSBugAssistAttachmentRecord() {
        Core_IPS_BugAssist_Attachment__c bugAssistAttachment = new Core_IPS_BugAssist_Attachment__c();
        bugAssistAttachment.Core_File_Name__c = 'Bug Assist Attachment Record';
        if (Schema.sObjectType.Core_IPS_BugAssist_Attachment__c.isAccessible() && Schema.sObjectType.Core_IPS_BugAssist_Attachment__c.isCreateable()) {
            insert bugAssistAttachment;
        }
        return bugAssistAttachment.Id;
    }
    
    /** Wrapper to avoid exposing raw SObject to the LWC layer. */
/*Start -- Tushar -- 12/05/2026 --- CRUD Added as part of vulnerability fix. */
    public class BugAssistRecordWrapper {
        @AuraEnabled public String   recordId            { get; set; }
        @AuraEnabled public String   fileName            { get; set; }
        @AuraEnabled public String   uploadStatus        { get; set; }
        @AuraEnabled public String   fileDescription     { get; set; }
        @AuraEnabled public DateTime lastStatusUpdatedAt { get; set; }
        @AuraEnabled public DateTime createdDate         { get; set; }
        
        public BugAssistRecordWrapper(Core_IPS_BugAssist_Attachment__c rec) {
            this.recordId            = rec.Id;
            this.fileName            = rec.Core_File_Name__c;
            this.uploadStatus        = rec.Core_Upload_Status__c;
            this.fileDescription     = rec.Core_File_Description__c;
            this.lastStatusUpdatedAt = rec.Core_Last_Status_Updated_At__c;
            this.createdDate         = rec.CreatedDate;
        }
    }
    /*End -- Tushar -- 12/05/2026 --- added as part of vulnerability fix. */
    
    /**
* Created by Deepaksai as part of BugAssist
* @params - recordId : bugAssist record id from core_IPS_caseCreation_form 
* @return - BugAssistRecordWrapper (safe wrapper over Core_IPS_BugAssist_Attachment__c)
*/
    @AuraEnabled
    public static BugAssistRecordWrapper fetchBugAssistRecord(Id recordId){
        List<Core_IPS_BugAssist_Attachment__c> bugAssistList = new List<Core_IPS_BugAssist_Attachment__c>();
        bugAssistList = [SELECT Id, Core_File_Name__c, Core_Upload_Status__c, Core_Last_Status_Updated_At__c, Core_File_Description__c, CreatedDate FROM Core_IPS_BugAssist_Attachment__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        if (bugAssistList.size() > 0) {
            return new BugAssistRecordWrapper(bugAssistList[0]);
        }
        return null;
    }
   /*End -- Tushar -- 12/05/2026 --- added as part of vulnerability fix. */ 
    
    /*
* Created by Siddardha as part of BugAssist to get productorg
*/
    @AuraEnabled
    public static Boolean validateProductOrg(Id recordId){
        // Hassan Khan make a "List<Asset> productOrg" to fix (List has no rows for assignment to Sobject) Exception Handling issue.		
        List<Asset> productOrg =[ SELECT Id, Core_Supported_Product__c, Core_Product_Organization__r.Name FROM Asset WHERE Id =: recordId WITH SECURITY_ENFORCED];
        if (!productOrg.isEmpty() && productOrg[0].Core_Product_Organization__r.Name ==label.Core_IPS_Bug_Assist_Supported_Products){
            return validateBugAssistProd(productOrg[0].Core_Supported_Product__c);
        }else{
            return false;
        }
    }
    /**
* Created by Deepaksai
* @param : recordId - Core_Supported_Product__c 
*/
    @AuraEnabled
    public static Boolean validateBugAssistProd(Id recordId){
        List<Core_IPS_Backend_Routing__c> backendRoutingRec = new List<Core_IPS_Backend_Routing__c>();
        if (recordId !=null) {
            backendRoutingRec = [SELECT Id FROM Core_IPS_Backend_Routing__c WHERE Core_IPS_Supported_Product__c =: recordId WITH SECURITY_ENFORCED];
            if (!backendRoutingRec.isEmpty()) {
                return true;
            } else {
                return false;
            }
        } else{
            return false;
        }
    }
    @AuraEnabled
    public static String getProductOrgName(Id recordId) {
    List<Asset> productOrg = new List<Asset>();
    if (recordId == null) {
        return null;
    }
    //Moved the query to  without sharing class - vulnerability fixes - Nuthana
    String productOrgQuery = 'SELECT Id, Core_Product_Organization__r.Name FROM Asset WHERE Core_Product_Organization__r.Id = :recordId';
    productOrg = (List<Asset>) Core_IPS_QueryService.queryRecords(productOrgQuery, new Map<String, Object>{ 'recordId' => recordId });
        

    if (!productOrg.isEmpty() && productOrg[0].Core_Product_Organization__r != null) {
        return productOrg[0].Core_Product_Organization__r.Name;
    }
    return null;
    }
    
    /*
* Created by Hassan as part of BugAssist to Convert BUG Assist Attachment record to IPS Attachment
*/
    @AuraEnabled(cacheable=false)
    public static void bugAssistRecordConversion(Id caseId, Id bugAssistrecordId){
        BugAssistRecordHandler bugAssistcon = new BugAssistRecordHandler();
        bugAssistcon.bugAssitRecordtoIPSAttachment(caseId,bugAssistrecordId);
    }
    
    /*
* Created by Hassan as part of BugAssist to Delete Record On Bug Assist 'No' Flow.
*/
    @AuraEnabled(cacheable=false)
    public static void bugAssistRecordDeletion(Id bugAssistrecordId){
        BugAssistRecordHandler bugAssistcon = new BugAssistRecordHandler();
        bugAssistcon.deleteBugAssistRecord(bugAssistrecordId);
    }
    
    /*
* This Inner Class Created by Hassan to Avoid Sharing Settings at the time of BUG Assist Attachment record Conversion.
*/
    private without sharing class BugAssistRecordHandler { // 'without sharing' added by Tushar as part of ATHR critical
        String notApplicable = 'NA'; // global varible to validate value
        public void bugAssitRecordtoIPSAttachment(Id caseId, Id bugAssistrecordId) {
            Core_IPS_BugAssist_Attachment__c bugAssistRecord = [Select Id,CreatedById,  Name, Core_IPS_Attachment_Source__c, Core_IPS_Attachment_Visibility__c, Core_Last_Status_Updated_At__c, Core_Upload_Status__c, Core_Upload_idsid__c, Core_Type__c, Core_File_URL__c, Core_FileSizeInBytes__c, Core_File_Size__c, Core_File_Name__c, Core_File_GUID__c, Core_File_Description__c, Core_Category__c, Core_SFT_Recommendation__c, Core_SFT_Suggestion__c from Core_IPS_BugAssist_Attachment__c  WHERE Id =: bugAssistrecordId];
			/*Start -- Tushar -- 12/05/2026 --- CRUD Added as part of vulnerability fix. */
            if (bugAssistRecord.CreatedById != UserInfo.getUserId()) {
                throw new AuraHandledException('Access denied: record not owned by calling user.');
            }
            /*End -- Tushar -- 12/05/2026 --- added as part of vulnerability fix. */
            Core_IPS_Case_Attachments__c ipsAttachment = new Core_IPS_Case_Attachments__c();
            ipsAttachment.Core_Case__c = caseId;
            ipsAttachment.Core_IPS_Attachment_Source__c = bugAssistRecord.Core_IPS_Attachment_Source__c;
            ipsAttachment.Core_IPS_Attachment_Visibility__c = bugAssistRecord.Core_IPS_Attachment_Visibility__c;
            ipsAttachment.Core_Category__c = bugAssistRecord.Core_Category__c;
            ipsAttachment.Core_File_GUID__c = bugAssistRecord.Core_File_GUID__c;
            ipsAttachment.Core_File_Name__c = bugAssistRecord.Core_File_Name__c;
            ipsAttachment.Core_File_Size__c = bugAssistRecord.Core_File_Size__c;
            ipsAttachment.Core_FileSizeInBytes__c = bugAssistRecord.Core_FileSizeInBytes__c;
            ipsAttachment.Core_FileUploadedBy__c = bugAssistRecord.CreatedById;
            ipsAttachment.Core_Type__c = bugAssistRecord.Core_Type__c;
            ipsAttachment.Core_Upload_idsid__c = bugAssistRecord.Core_Upload_idsid__c;
            ipsAttachment.Core_Last_Status_Updated_At__c = bugAssistRecord.Core_Last_Status_Updated_At__c;
            ipsAttachment.Core_Upload_Status__c = bugAssistRecord.Core_Upload_Status__c;
            // Adding Default Value if Description is Blank.
            ipsAttachment.Core_File_Description__c = (bugAssistRecord.Core_File_Description__c == null || bugAssistRecord.Core_File_Description__c =='' || bugAssistRecord.Core_File_Description__c == notApplicable) ? System.Label.Core_IPS_Bug_Assist_Attachment_Description : bugAssistRecord.Core_File_Description__c;
			/*Start -- Tushar -- 12/05/2026 --- CRUD Added as part of vulnerability fix. */
            if (bugAssistRecord.Core_File_URL__c != null
                    && bugAssistRecord.Core_File_URL__c.startsWith(ALLOWED_HOST)
                    && bugAssistRecord.Core_File_URL__c.endsWith('null')) {
                ipsAttachment.Core_File_URL__c = bugAssistRecord.Core_File_URL__c
                    .substring(0, bugAssistRecord.Core_File_URL__c.length() - 4) + caseId;
            } else {
                ipsAttachment.Core_File_URL__c = bugAssistRecord.Core_File_URL__c;
            }
            /*End -- Tushar -- 12/05/2026 --- added as part of vulnerability fix. */
            try{
                if (bugAssistRecord.Core_Upload_Status__c == 'Complete' && Schema.sObjectType.Core_IPS_Case_Attachments__c.isAccessible() && Schema.sObjectType.Core_IPS_Case_Attachments__c.isCreateable()) {
                    insert ipsAttachment;
                }
            }catch(Exception ex){
                //create an error log
            }
            
            //To Create Comment of Suggestion and Recommendation;
            bugAssistRecommendationComment(caseId,ipsAttachment,bugAssistRecord);
            
            //To Deleted Bug Assist Record after Successful Conversion to IPS Case Attachment.
            if(ipsAttachment.id != null && Schema.sObjectType.Core_IPS_BugAssist_Attachment__c.isAccessible() && Schema.sObjectType.Core_IPS_BugAssist_Attachment__c.isDeletable()) {
                delete bugAssistRecord;
            } 
        }
        public void bugAssistRecommendationComment(Id caseId, Core_IPS_Case_Attachments__c attachmentRecord, Core_IPS_BugAssist_Attachment__c bugAssistRecord) {
            Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
            
            newComment.Core_IPS_Case__c = caseId;
            newComment.Core_IPS_Comment_Author_Type__c= System.label.Core_IPS_Partner_Profile_Name;	 
            newComment.Core_IPS_Case_Comment_Type__c = attachmentRecord.Core_IPS_Attachment_Visibility__c; 
            newComment.Core_IPS_Case_Comment_Source__c = attachmentRecord.Core_IPS_Attachment_Source__c;
            newComment.Core_IPS_Comment_Authored_By__c = attachmentRecord.Core_FileUploadedby__c;
            newComment.Core_IPS_Comment_Authored_By_Name__c = attachmentRecord.Core_IPS_Uploaded_By_Name__c;
            newComment.Core_IPS_Comment_Authored_By_FirstName__c = attachmentRecord.Core_IPS_Uploaded_By_FirstName__c;
            newComment.Core_IPS_Comment_Authored_By_Email__c = attachmentRecord.Core_IPS_Uploaded_By_Email__c;			
            
            if(bugAssistRecord.Core_SFT_Suggestion__c != null && bugAssistRecord.Core_SFT_Suggestion__c != notApplicable && bugAssistRecord.Core_SFT_Recommendation__c != null && bugAssistRecord.Core_SFT_Recommendation__c != notApplicable){
                newComment.Core_IPS_Rich_Comment__c =  bugAssistRecord.Core_SFT_Recommendation__c + bugAssistRecord.Core_SFT_Suggestion__c;
            }
            else if (bugAssistRecord.Core_SFT_Suggestion__c != notApplicable && bugAssistRecord.Core_SFT_Suggestion__c != null ){
                newComment.Core_IPS_Rich_Comment__c = bugAssistRecord.Core_SFT_Suggestion__c;
            }
            else if (bugAssistRecord.Core_SFT_Recommendation__c != notApplicable && bugAssistRecord.Core_SFT_Recommendation__c != null ){
                newComment.Core_IPS_Rich_Comment__c = bugAssistRecord.Core_SFT_Recommendation__c;
            }
            
            if(newComment.Core_IPS_Rich_Comment__c != null && Schema.sObjectType.Core_IPS_Case_Comments__c.isAccessible() && Schema.sObjectType.Core_IPS_Case_Comments__c.isCreateable()){
                insert newComment;
            }
        }
        public void deleteBugAssistRecord(Id bugAssistRecordId) {
            //List <Core_IPS_BugAssist_Attachment__c> bugAssistRecord = [Select Id from Core_IPS_BugAssist_Attachment__c  WHERE Id =: bugAssistrecordId WITH SECURITY_ENFORCED];
            /*Start -- Tushar -- 12/05/2026 --- CRUD Added as part of vulnerability fix. */
            List <Core_IPS_BugAssist_Attachment__c> bugAssistRecord = [Select Id, CreatedById from Core_IPS_BugAssist_Attachment__c  WHERE Id =: bugAssistrecordId WITH SECURITY_ENFORCED];
            if (!bugAssistRecord.isEmpty() && bugAssistRecord[0].CreatedById != UserInfo.getUserId()) {
                throw new AuraHandledException('Access denied: record not owned by calling user.');
            }
            /*End -- Tushar -- 12/05/2026 --- added as part of vulnerability fix. */
            try{		
                if (!bugAssistRecord.isEmpty() && Schema.sObjectType.Core_IPS_BugAssist_Attachment__c.isAccessible() && Schema.sObjectType.Core_IPS_BugAssist_Attachment__c.isDeletable()) {
                    delete bugAssistRecord;
                }
            }catch(Exception ex){
                //create an error log
            }
        }
    }
}