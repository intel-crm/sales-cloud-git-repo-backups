public with sharing class Core_IPS_MindSectionController {
    @AuraEnabled public static List<CustomSelectOptions> countryOptions{get;set;}
    
    public Core_IPS_MindSectionController() {}
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> getDefaultCountry(String contactdata) {
        List<String> returnDefault = new List<String>();
        if(contactdata!=null){
        // SOQL Injection Fix  - Start -  Shipra
        String abc =  String.escapeSingleQuotes(contactdata);
        String temp = abc.replace('"', '');
        Map<String, Object> bindMap = new Map<String, Object>{'tempVal' => temp};
        String query = 'Select Core_MINDS__c, Core_Country_Region__c, Core_IPS_Embargoed_State__c from contact  where Id = :tempVal'; 
        contact cont = (contact) Database.queryWithBinds(query,bindMap,AccessLevel.USER_MODE);
        // SOQL Injection Fix  -  Shipra
        returnDefault.add(cont.Core_Country_Region__c);
        returnDefault.add(cont.Core_IPS_Embargoed_State__c);
        if(cont.Core_MINDS__c){
            returnDefault.add('Yes');
        }
        else {
            returnDefault.add('No');
        }
        }
        return returnDefault;
        
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<CustomSelectOptions> getCountriesOptions() {
        
        countryOptions = new List<CustomSelectOptions>();
        //countryOptions.add(new SelectOption('','-None-'));        
        Schema.Describefieldresult result = Schema.sObjectType.Contact.fields.Core_Country_Region__c;
        Schema.DescribeFieldResult fieldResult = result.getSObjectField().getDescribe();//Contact.BillingCountry.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
        for( Schema.PicklistEntry f : ple)
        {
            countryOptions.add(new CustomSelectOptions(f.getLabel(), f.getValue()));
        }       
        // Core_Utility.doSort(countryOptions, Core_Utility.FieldToSort.Label,'-None-');
        return countryOptions;
    }
}