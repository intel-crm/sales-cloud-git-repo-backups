public with sharing class Sales_GetCompanionLicenseDetails_Bot {
    public class ContactInput {
        @InvocableVariable
        public String scontactId;
    }
    @InvocableMethod(label='Find active list of companion computer details')
    public static List<List<Sales_Host__c>> getHostDetails(List<ContactInput> contactId) {
        Map<Id,Id> licenseToHostMap = new Map<Id,Id>();
        List<List<Sales_Host__c>> hostObjList = new List<List<Sales_Host__c>>();
        Set<String> contactIdSet = new Set<String>();
        for(ContactInput c : contactId ){
            contactIdSet.add(c.scontactId);
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet AND  Sales_License_isActive__c=true]){
            contactIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }
        if(contactIdSet.size() > 0){
            for(Sales_License__c lic : [Select id ,Sales_License_Primary_Admin_Contact__c,Sales_License_Host_Node_Id__c from Sales_License__c where Sales_License_Primary_Admin_Contact__c IN:contactIdSet AND (Sales_License_Host_Node_Id__r.Sales_Contact__c IN:contactIdSet) AND (Sales_Tool_License_Type__c='FIXED' OR Sales_Tool_License_Type__c='NEUTRAL') and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional' order by CreatedDate desc]){
                licenseToHostMap.put(lic.Sales_License_Host_Node_Id__c,lic.id);
            }
        } 
        List<Sales_Host__c> hostRecords = [Select Id,Sales_Contact__c,Sales_isActiveHost__c,Sales_Companion_Server1_Txt__c,Sales_Companion_Server2_Txt__c,Sales_License_Type__c,Sales_Computer_Type__c,Sales_Computer_Name_Txt__c,Name from Sales_Host__c where Sales_License_Type__c='FIXED' AND Sales_isActiveHost__c = true AND (ID IN:licenseToHostMap.keySet()) order by CreatedDate desc];
        hostObjList.add(hostRecords);
        return hostObjList;
    }
}