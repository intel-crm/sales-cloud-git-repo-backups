public without sharing class Sales_OrderController {
    private static final String ACCOUNT_FPGA_ROLE='FPGA Designer';
    private static final String RECORD_TYPE_INTEL_ACCOUNT='Intel Account';
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey) {  
        string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
        string role = ACCOUNT_FPGA_ROLE; 
        string recordType = RECORD_TYPE_INTEL_ACCOUNT;  
        string query = 'SELECT Id, Name FROM Account WHERE Core_IPA_Partner_Role__c = :role and Core_Intel_Partner_Alliance_PartnerGroup__c = true and Core_Account_Record_Type__c = :recordType and Name LIKE '+searchText+' LIMIT 6';
        return Database.query(query);  
    }  
    @AuraEnabled(cacheable=true)  
    public static List<sobject> fetchSoldToDetails(Id acct,String selectedField) { 
        string query;
        query = 'SELECT Id, Name,Core_Direct_Account_Id__c,ParentId,BillingStreet,BillingState, BillingCountry, BillingCity, BillingPostalCode,ToLabel(BillingCountryCode), Tolabel(BillingStateCode),'+String.escapeSingleQuotes(selectedField)+' FROM Account WHERE Id =:acct Limit 1';
        return Database.query(query);         
    }
    @AuraEnabled(cacheable=true)  
    public static List<sobject> fetchEndCustDetails(Id endCst) { 
        string query = 'SELECT Id, Name,Core_Direct_Account_Id__c,ParentId,BillingStreet,BillingState, BillingCountry, BillingCity, BillingPostalCode,ToLabel(BillingCountryCode), Tolabel(BillingStateCode) FROM Account WHERE Id =:endCst Limit 1';
        return Database.query(query);    
    }    
    @AuraEnabled
    public static List < Map < String, String >> getPickListValues(String objApiName, String fieldName) {
        List < Map < String, String >> options = new List < Map < String, String >> ();
        Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: pickListValues) {
            Map < String, String > values = new Map < String, String > {
                'label' => f.getLabel(),
                    'value' => f.getValue()
                    };
                        options.add(values);
        }
        return options;
    }
    @AuraEnabled
    public static String getFieldLabel(String objName, String fieldName) {
        try{
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
            return objType.getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
        }catch (Exception ex){
            return '';
        }
    }
}