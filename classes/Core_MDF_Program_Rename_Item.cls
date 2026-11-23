/**
 * @description Flow row describing one in-scope metadata component and its rename preview.
 */
public with sharing class Core_MDF_Program_Rename_Item {
    @AuraEnabled
    public String metadataType;
    @AuraEnabled
    public String recordId;
    @AuraEnabled
    public String fullName;
    @AuraEnabled
    public String objectName;
    @AuraEnabled
    public String currentValue;
    @AuraEnabled
    public String proposedValue;
    @AuraEnabled
    public Integer replacementCount;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String message;
}