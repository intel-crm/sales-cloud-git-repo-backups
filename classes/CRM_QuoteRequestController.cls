public with sharing class CRM_QuoteRequestController {

    public static final String LOG_ENTRY_ORIGIN   = 'CRM_QuoteRequestController';
    public static final String LOG_ENTRY_PROJECT  = 'Deal Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Related list  on Opportunity Line Items';
    public static final String LOG_ENTRY_ERROR    = 'Error';
    public static final String LOG_ENTRY_SEVERITY = 'Error';
    public static final String LOG_ENTRY_INFO     = 'Info';

    public class DataFieldsWrapper{
        @AuraEnabled public List<SBQQ__QuoteLine__c> QuoteLineItems	{get;set;}
        @AuraEnabled public List<FieldSetWrapper> FieldSetWrapList{get;set;}
        @AuraEnabled public String ProfileName {get;set;}
    }
    public class FieldSetWrapper{
        @AuraEnabled public String Label {get;set;}
        @AuraEnabled public String ApiName {get;set;}
        @AuraEnabled public String Type {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static DataFieldsWrapper getQLIWithFieldSet(String recId) {
        DataFieldsWrapper dw = new DataFieldsWrapper();
        try {
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            dw.ProfileName=profileName;
            List<Schema.FieldSetMember> fields;
            if(profileName=='Partner'){
                fields = Schema.SObjectType.SBQQ__QuoteLine__c.fieldSets.getMap().get('Related_List_on_Opportunity_Partners').getFields();
            }
            else{
                fields = Schema.SObjectType.SBQQ__QuoteLine__c.fieldSets.getMap().get('RelatedListonOpportunity').getFields();
            }
            String selectFields = 'Name,Pricing_Quote_Line_Number__c'; // Add standard fields
            List<FieldSetWrapper> listColumns = new List<FieldSetWrapper>();
            FieldSetWrapper fieldSetMap = new FieldSetWrapper();
            for(Schema.FieldSetMember field : fields) {
                selectFields += ', ' + field.getFieldPath();
                fieldSetMap=new FieldSetWrapper();
                fieldSetMap.Label = field.getLabel();
                fieldSetMap.ApiName = field.getFieldPath();
                Schema.DisplayType type = field.getType();
                fieldSetMap.Type = getTypeforDataTable(type);                
                listColumns.add(fieldSetMap);
            }

            
            List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();
            Id recordId = Id.valueOf(recId);
            String objectType = recordId.getsobjecttype().getDescribe().getName();
            if(objectType == 'OpportunityLineItem'){
                OpportunityLineItem oli = new  OpportunityLineItem();
              //  if( OpportunityLineItem.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.OpportunityLineItem.fields.SBQQ__QuoteLine__c.isAccessible()){
                    oli = [SELECT SBQQ__QuoteLine__c FROM OpportunityLineItem WHERE Id = :recId];
              //  } 
                if(oli!=null && oli.SBQQ__QuoteLine__c!=null){
                    String qid = oli.SBQQ__QuoteLine__c;
                    quoteLineItems = Database.query('SELECT '+ String.escapeSingleQuotes(selectFields)+' FROM SBQQ__QuoteLine__c WHERE Id = :qid and Pricing_Status_Nm__c!=\'Revised\'');
                }
            }
            else{
                List<SBQQ__Quote__c> quotesList = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :recId];
                Set<String> qidset = new Set<String>();
                for(SBQQ__Quote__c q : quotesList){
                    qidset.add(q.Id);
                }
                quoteLineItems = Database.query('SELECT '+ String.escapeSingleQuotes(selectFields)+' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN :qidset and Pricing_Status_Nm__c!=\'Revised\'');
            }
           
            dw.QuoteLineItems=quoteLineItems;
            dw.FieldSetWrapList=listColumns;
            return dw;
        } 
        catch (DMLException dmlEx) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'CRM_QuoteRequestController.getQLIWithFieldSet' ,'' ,dmlEx);
            throw new AuraHandledException('An error occurred while processing the request.'+dmlEx.getMessage());
        }                  
    }
    
    public static String getTypeforDataTable(Schema.DisplayType type) {
        String modType;
        if(type == Schema.DisplayType.Reference){
            modType = 'url';
        }
        else if(type == Schema.DisplayType.ID){
            modType = 'Id';
        }
        else if(type == Schema.DisplayType.Date){
            modType = 'date';
        }
        else if(type == Schema.DisplayType.DateTIME){
            modType = 'date';
        }
        else if(type == Schema.DisplayType.BOOLEAN){
            modType = 'boolean';
        }
        else if(type == Schema.DisplayType.CURRENCY){
             modType = 'currency';
        }
        else{
            modType = 'text';
        }
        return modType;
    }
}