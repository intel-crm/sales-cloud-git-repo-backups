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

	/**
	 * Created by Deepaksai as part of BugAssist
	 * @params - recordId : bugAssist record id from core_IPS_caseCreation_form 
	 * @return - Bug Assist record
	 */
	@AuraEnabled
	public static Core_IPS_BugAssist_Attachment__c fetchBugAssistRecord(Id recordId){
		return [SELECT Id, Core_File_Name__c, Core_Upload_Status__c, Core_Last_Status_Updated_At__c, Core_File_Description__c, CreatedDate FROM Core_IPS_BugAssist_Attachment__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
	}

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
	private class BugAssistRecordHandler {
		String notApplicable = 'NA'; // global varible to validate value
        public void bugAssitRecordtoIPSAttachment(Id caseId, Id bugAssistrecordId) {
            Core_IPS_BugAssist_Attachment__c bugAssistRecord = [Select Id,CreatedById,  Name, Core_IPS_Attachment_Source__c, Core_IPS_Attachment_Visibility__c, Core_Last_Status_Updated_At__c, Core_Upload_Status__c, Core_Upload_idsid__c, Core_Type__c, Core_File_URL__c, Core_FileSizeInBytes__c, Core_File_Size__c, Core_File_Name__c, Core_File_GUID__c, Core_File_Description__c, Core_Category__c, Core_SFT_Recommendation__c, Core_SFT_Suggestion__c from Core_IPS_BugAssist_Attachment__c  WHERE Id =: bugAssistrecordId WITH SECURITY_ENFORCED];
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
			// Adding Case Id to the file URL For download Button URL.
			ipsAttachment.Core_File_URL__c = (bugAssistRecord.Core_File_URL__c.endsWith('null')) ? bugAssistRecord.Core_File_URL__c.substring(0, bugAssistRecord.Core_File_URL__c.length() - 4) + caseId : bugAssistRecord.Core_File_URL__c;

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
			List <Core_IPS_BugAssist_Attachment__c> bugAssistRecord = [Select Id from Core_IPS_BugAssist_Attachment__c  WHERE Id =: bugAssistrecordId WITH SECURITY_ENFORCED];
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