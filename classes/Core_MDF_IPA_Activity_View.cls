public without sharing class Core_MDF_IPA_Activity_View {
   @AuraEnabled
   public static List<Core_MDF_ActivityFields_OnCampaign__mdt> getActivityFields(String programName ){ 
    
     List<Core_MDF_ActivityFields_OnCampaign__mdt> activityFieldList = [SELECT Field_API_Name__c, Field_Label__c,Program_Name__c FROM Core_MDF_ActivityFields_OnCampaign__mdt  WHERE Program_Name__c =:programName];
      system.debug('activityFieldList:'+activityFieldList);
       return activityFieldList;
}
}