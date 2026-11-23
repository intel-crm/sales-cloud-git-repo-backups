public with sharing class PRM_OPID_Util 
{
    @AuraEnabled(cacheable=true)
	//public static List<Core_Account_Group_Member__c> getOPIDAccounts(ID accountID) 
	public static string getOPIDAccounts(ID accountID) 
	{    
         System.Debug('Linenumber 6 : ' + accountID);
         list< map<string,object>> markerList = new list< map<string,object>>();
         for(Core_Account_Group_Member__c acc1 : [SELECT Id, Core_Partner_Account_Id__r.Name,Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.BillingStreet,
                                                  Core_Intel_Account_Id__r.BillingStateCode,Core_Intel_Account_Id__r.BillingCity,
                                                  Core_Intel_Account_Id__r.BillingPostalCode,
                                                  Core_Intel_Account_Id__r.BillingCountry 
                                                  FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c =: accountID AND Core_Inactive_Ind__c=false])
         {
              map<string,object> markerMap = new map<string,object>();
               markerMap.put('title', acc1.Core_Intel_Account_Id__r.Name);
               markerMap.put('description',acc1.Core_Partner_Account_Id__r.Name);
               map<string,object> addressMap = new map<string,object>();
               addressMap.put('Street',acc1.Core_Partner_Account_Id__r.BillingStreet);
               addressMap.put('City',acc1.Core_Partner_Account_Id__r.BillingCity);
             addressMap.put('PostalCode',acc1.Core_Partner_Account_Id__r.BillingPostalCode);
             addressMap.put('State',acc1.Core_Partner_Account_Id__r.BillingStateCode);
             addressMap.put('Country',acc1.Core_Partner_Account_Id__r.BillingCountry);
               //markerMap.put('location',addressMap);
               markerList.add(markerMap);  
         }
         System.Debug('Map JSON : ' + JSON.serialize(markerList));
         return JSON.serialize(markerList);       
	}
}