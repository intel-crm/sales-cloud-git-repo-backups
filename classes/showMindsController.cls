public with sharing class showMindsController {
    
        @AuraEnabled public static List<CustomSelectOptions> countryOptions{get;set;}
    
    public showMindsController() {

    }

     @AuraEnabled(cacheable=true)
    public static List<String> getDefaultCountry(String contactdata) {

    List<String> returnDefault = new List<String>();    
    String abc = contactdata;
    String temp = abc.replace('"', '');
    system.debug('====temp===='+temp);
     String query = 'Select Core_MINDS__c, Core_Country_Region__c from contact  where Id = \'' +temp+'\''; 
     System.debug('query'+query);
     contact cont = (contact) Database.query(query);
    
    returnDefault.add(cont.Core_Country_Region__c);
    if(cont.Core_MINDS__c){
        returnDefault.add('Yes');
    }
    else {
        returnDefault.add('No');
    }
    
    return returnDefault;
        
    }


    @AuraEnabled(cacheable=true)    
    public static map<String, list<String>> returnMapOfListValues() {
        map<String, list<String>> mapOfListValues = new map<String, list<String>>();
        
        mapOfListValues.put('India', new list<String>{'Hyderabad', 'Delhi', 'Mumbaie'});
        mapOfListValues.put('USA', new list<String>{'New York', 'Las Vegas', 'Miami'});
        mapOfListValues.put('China', new list<String>{'Shenzhen', 'Guangzhou', 'Shanghai'});
        return mapOfListValues;
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