public class Core_MDF_AuditDoc_POC_Controller {
	@AuraEnabled(cacheable=true)
    public static List<Core_MDF_Audit_Document__c> fetchAuditDocuments(Id claimId) {
        List<Core_MDF_Audit_Document__c> AuditDocumentList = new List<Core_MDF_Audit_Document__c>();
        AuditDocumentList = [select Id, Core_MDF_Document_Types__c, Core_MDF_Selected_Document_Types_txt__c, Core_MDF_Document_Title__c, Core_MDF_Int_Document_Name__c, Core_MDF_Claim__c, createdDate, createdById, CreatedBy.Name from Core_MDF_Audit_Document__c where Core_MDF_Claim__c =: claimId ];
        return AuditDocumentList;
    }

    @AuraEnabled
    public static string dummyMethod(){
        String message;
        try {
            message = 'Successfully rendered';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return message;
    }
}