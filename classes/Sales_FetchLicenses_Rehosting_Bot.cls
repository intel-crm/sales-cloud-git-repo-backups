public without sharing class Sales_FetchLicenses_Rehosting_Bot {
    public class HostInput {
        @InvocableVariable
        public Sales_Host__c hostObject;
    }
    @InvocableMethod(label='Fetch Licenses by Rehosting')
    public static List<List<Sales_License__c>> fetchLicesesbyRehost(List<HostInput> inputs){
        Set<Id> hostIds = new Set<Id>();
        List<List<Sales_License__c>> listofLicenses = new List<List<Sales_License__c>>();
        List<Sales_License__c> licList = new List<Sales_License__c>();
        for(HostInput hostinput : inputs){
            hostIds.add(hostinput.hostObject.id);
        }
        for(Sales_License__c lc : [Select Id,name,Sales_License_Status__c,Sales_Tool_License_Type__c,Sales_License_Activation_Code__c,Sales_License_Product_Name_Txt__c,Sales_License_Web_Display_Flag__c  From Sales_License__c WHERE Sales_License_Host_Node_Id__c IN : hostIds and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional']){
            licList.add(lc);
        }
        listofLicenses.add(licList);
        return listofLicenses;
    }
}