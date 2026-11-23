global with sharing class CaseAttachmentListController {
   /* @AuraEnabled(cacheable = true)
    public static List<Core_IPS_Case_Attachments__c> getCaseAttachment(String caseId){
        
        return  [SELECT Id,Name,CreatedByID,Createdby.name,CreatedDate,Core_File_Hyperlink__c,Core_Upload_Status__c,core_case__c,Core_File_Size__c,Core_Category__c,Core_File_Description__c,Core_File_Name__c,Core_FileUploadedBy__c,Core_FileUploadedBy__r.name,Core_Upload_UserId__c,Core_IPS_Attachment_Visibility__c FROM Core_IPS_Case_Attachments__c WHERE core_case__c =: caseId];
        
    }*/
    /* Start------ Tushar ---- Vanuability Changes added filter*/
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Case_Attachments__c> getCaseAttachment(String caseId) {
        // Determine allowed visibility tiers based on running user's profile
        List<String> allowedTiers = getVisibilityTiersForCurrentUser();
        return [SELECT Id, Name, CreatedByID, Createdby.name, CreatedDate,
                Core_File_Hyperlink__c, Core_Upload_Status__c, core_case__c,
                Core_File_Size__c, Core_Category__c, Core_File_Description__c,
                Core_File_Name__c, Core_IPS_Attachment_Visibility__c
                FROM Core_IPS_Case_Attachments__c
                WHERE Core_Case__c = :caseId
                AND Core_IPS_Attachment_Visibility__c IN :allowedTiers
                WITH USER_MODE];
    }
    
    private static List<String> getVisibilityTiersForCurrentUser() {
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        if (profileName.contains('Customer Community')) {
            return new List<String>{'Public to Customers'};
                } else if (profileName.contains('Partner-DFAE')) {
                    return new List<String>{'Public to Customers', 'Private to Partner'};
                        } else if (profileName.contains('Partner')) {
                            return new List<String>{'Public to Customers'};
                                }
        return new List<String>{'Public to Customers', 'Private to Partner', 'Private to Intel'};
            }
    /* End------ Tushar ---- Vanuability Changes added filter*/
}