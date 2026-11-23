public without sharing class Sales_SearchLicenses_Rehosting_Bot {
    public class HostInput {
        @InvocableVariable
        public Sales_Host__c hostObject;
        @InvocableVariable
        public String sproductName;
    }
    @InvocableMethod(label='Search Licenses by Rehosting')
    public static List<List<Sales_License__c>> getLicenseDetails(List<HostInput> hostinput) {
        //Set<Id> hostids = new Set<Id>();-- Unused
        Map<Id, String> mapofInputs = new Map<Id, String>();
        List<List<Sales_License__c>> listofLicenses = new List<List<Sales_License__c>>();
        List<Sales_License__c> licList = new List<Sales_License__c>();
        for(HostInput input : hostinput){
            String searchName= '%'+input.sproductName+'%';
            mapofInputs.put(input.hostObject.id, searchName);
        }
        List<String> searchName= mapofInputs.values();
        for(Sales_License__c lc : [Select Id,name,Sales_License_Status__c,Sales_Tool_License_Type__c,Sales_License_Activation_Code__c,Sales_License_Product_Name_Txt__c From Sales_License__c WHERE Sales_License_Product_Name_Txt__c LIKE : searchName and Sales_License_Host_Node_Id__c IN :mapofInputs.keyset() and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional']){
            licList.add(lc);
        }
        listofLicenses.add(licList);
        return listofLicenses;
    }
}