public with sharing class Core_IPS_CaseDetailView_Controller {
    @AuraEnabled
    public static Map<String,List<String>> getFieldName(Id recordId){
        Map<String,List<String>> fieldSectionNames = new Map<string,List<String>>();
        Map<String,List<String>> fieldSectionMap = new Map<String,List<String>>();
        Core_IPS_InlineEditFields__mdt inlineEditFields;
        Case exCase;
        Case caseRecord;
        List<Core_IPS_Inline_SectionName__mdt> inlineSections;
		if(Case.SObjectType.getDescribe().isAccessible()){
        	exCase = [Select Id,RecordType.Name From Case Where Id = :recordId];
        }

        String profileName = [Select Id,Profile.Name From User Where Id = :UserInfo.getUserId()].Profile.Name;
        
        inlineEditFields = [Select Id,Field_Name__c,Profile_Name__c,Record_Type__c From Core_IPS_InlineEditFields__mdt Where Record_Type__c = :exCase.RecordType.Name And Profile_Name__c = :profileName];
        //if(Core_IPS_Inline_SectionName__mdt.SObjectType.getDescribe().isAccessible()){
        	inlineSections = [Select Id,Label,Fields_Name__c From Core_IPS_Inline_SectionName__mdt Limit 49999]; //Limit Added by Tushar
        //}
        
        List<String> fieldList = inlineEditFields.Field_Name__c.split(',');
       
        for(Core_IPS_Inline_SectionName__mdt inlineSection : inlineSections){
            fieldSectionMap.put(inlineSection.Label,inlineSection.Fields_Name__c.split(','));
        }
        
        for(String label : fieldSectionMap.keySet()){
            List<string> tempField = new List<String>();
           for(String fields : fieldSectionMap.get(label)){
               if(fieldList.contains(fields)){
                tempField.add(fields);
               }
           }
           fieldSectionNames.put(label,tempField);
        }
        return fieldSectionNames;
    }
 
    @AuraEnabled(cacheable=true)
    public static list<CustomSection> getStatus(String caseId){
        Case caseRecord;
        if(Case.SObjectType.getDescribe().isAccessible()){
        	caseRecord = [SELECT Id,Status,RecordType.Name,Core_Sub_Status__c,Core_IPS_GEC_Case__c FROM Case Where Id =:caseId];
        }
        Schema.DescribeFieldResult objFieldDescribe = Case.Status.getDescribe();
        List<Schema.PicklistEntry> lstStatusValues = objFieldDescribe.getPickListValues();
        List<CustomSection> selection = new List<CustomSection>();
        Core_IPS_InlineStatusField__c statusField = Core_IPS_InlineStatusField__c.getValues(caseRecord.RecordType.Name);
        List<String> statusValue = statusField.StatusValue__c.split(',');
        for(Schema.PicklistEntry statusPickList : lstStatusValues) {
                if(statusValue.contains(statusPickList.getValue())){
                    selection.add(new CustomSection(statusPickList.getLabel(),statusPickList.getValue()));
                } else {
                      if(caseRecord.Status == statusPickList.getValue()){
                        selection.add(new CustomSection(statusPickList.getLabel(),statusPickList.getValue()));
                      }
                }
        }
        return selection;
    }

    @AuraEnabled(cacheable=true)
    public static list<CustomSection> getSubStatus(String caseId, String currentStatus, String currentSubStatus){
        Case caseRecord;
        List<CustomSection> selection = new List<CustomSection>();
        if(Case.SObjectType.getDescribe().isAccessible()){
        	caseRecord = [SELECT Id,Status,RecordType.Name,Core_Sub_Status__c,Core_IPS_GEC_Case__c FROM Case Where Id =:caseId];
        }
        Schema.DescribeFieldResult objFieldDescribe = Case.Core_Sub_Status__c.getDescribe();
        List<Schema.PicklistEntry> lstSubStatusValues = objFieldDescribe.getPickListValues();
        Core_IPS_InlineStatusField__c statusField = Core_IPS_InlineStatusField__c.getValues(caseRecord.RecordType.Name);
        List<String> subStatusValue = statusField.SubStatusValue__c.split(',');
        if(currentStatus == 'Open'){
         for(Schema.PicklistEntry subStatusPickList : lstSubStatusValues) {
             if(subStatusPickList.getValue() != 'Closed'){
                if(subStatusValue.contains(subStatusPickList.getValue())){
                    selection.add(new CustomSection(subStatusPickList.getLabel(),subStatusPickList.getValue()));
                } else {
                      if((caseRecord.Core_Sub_Status__c == subStatusPickList.getValue()) && (currentSubStatus != '')){
                        selection.add(new CustomSection(subStatusPickList.getLabel(),subStatusPickList.getValue()));
                      }
                }
              }
            }
        } else if(currentStatus == 'Closed'){
            for(Schema.PicklistEntry subStatusPickList : lstSubStatusValues) {
                if(subStatusPickList.getValue() == 'Closed' || subStatusPickList.getValue() == 'Invalid' || subStatusPickList.getValue() == 'GEC Hold'){
                    if(subStatusValue.contains(subStatusPickList.getValue())){
                        selection.add(new CustomSection(subStatusPickList.getLabel(),subStatusPickList.getValue()));
                    } else {
                        if((caseRecord.Core_Sub_Status__c == subStatusPickList.getValue()) && (currentSubStatus != '')){
                            selection.add(new CustomSection(subStatusPickList.getLabel(),subStatusPickList.getValue()));
                          }
                    }
                }
            } 
                 
        } else if(currentStatus == 'On Hold'){
            for(Schema.PicklistEntry subStatusPickList : lstSubStatusValues) {
                if(subStatusPickList.getValue() == 'GEC Hold' && currentSubStatus != ''){
                    selection.add(new CustomSection(subStatusPickList.getLabel(),subStatusPickList.getValue()));
                }
            }   
        } else {
            if(caseRecord.Core_Sub_Status__c != null && currentSubStatus != ''){
                for(Schema.PicklistEntry subStatusPickList : lstSubStatusValues) {
                    if(subStatusPickList.getValue() == caseRecord.Core_Sub_Status__c){
                        selection.add(new CustomSection(subStatusPickList.getLabel(),subStatusPickList.getValue()));
                    }
                } 
            } 
        }
           return selection;
    }
   
    public class CustomSection{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public customSection(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

}