/**
 * @description Flow row describing changes at one workbook-scoped metadata path.
 */
public with sharing class Core_MDF_Program_Rename_Occurrence {
  @AuraEnabled
  public String occurrenceId;
  @AuraEnabled
  public String metadataType;
  @AuraEnabled
  public String recordId;
  @AuraEnabled
  public String fullName;
  @AuraEnabled
  public String objectName;
  @AuraEnabled
  public String metadataPath;
  @AuraEnabled
  public Integer matchCount;
  @AuraEnabled
  public String oldProgramName;
  @AuraEnabled
  public String newProgramName;
  @AuraEnabled
  public String currentValue;
  @AuraEnabled
  public String proposedValue;
}