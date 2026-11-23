public class Core_IPS_chdController {
    public void export(){
        List<Core_IPS_Product_Organization__c> supportOrg = [SELECT Core_IPS_Support_Org_Name__c,Core_Organization_Description__c,CreatedById,CreatedDate,Id,
                             IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,
                             OwnerId,RecordTypeId,SystemModstamp FROM Core_IPS_Product_Organization__c where Core_IPS_Support_Org_Name__c ='Connected Home Division'];
        List<Core_IPS_Supported_Product__c> supportProduct = [SELECT Code_Name_Hidden_Evaluate_NA__c,Code_Name_Hidden_Evaluate_NOCONA__c,Core_Code_Name_Hidden_Insert_Spaces__c,Core_Code_Name__c,
            Core_EOIS__c,Core_Flag_Status__c,Core_IPS_Code_Name__c,Core_IPS_Is_Show_Variant__c,Core_IPS_Public_Product__c,Core_Platform_Name__c,Core_Product_Application__c,
            Core_Product_EPM_ID__c,Core_Product_Launch_Date__c,Core_Product_Organization__c,Core_Product__c,Core_Prod_EPM_Id__c,Core_Supported_Product_Alias__c,
            Core_Supported_Product_Name__c,Core_Supported_Product_Tag__c,Core_Supported_Prod_Name__c,Core_Support_Launch_Date__c,Core_Support_Org_Name__c,Core_Unique_Supported_Product__c,CreatedById,CreatedDate,Id,IsDeleted,LastModifiedById,
            LastModifiedDate,LastReferencedDate,LastViewedDate,Name FROM Core_IPS_Supported_Product__c where Core_Support_Org_Name__c = 'Connected Home Division'];
        
    }
}