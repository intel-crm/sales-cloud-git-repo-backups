@isTest
public  with sharing class Sales_ShowComputers_Bot {
/*
    public class ComputerInput {
        @InvocableVariable
        public String sContactId;
        @InvocableVariable
        public String licenseType;
    }
    @InvocableMethod(label='Show Computers')
    public static List<List<Sales_Host__c>> getComputerDetailsonSearch(List<ComputerInput> compInput){
        Set<String> contactIdSet = new Set<String>();
        Set<String> primaryAdminIdSet = new Set<String>();
        List<List<Sales_Host__c>> hostListofLists= new List<List<Sales_Host__c>>();
        String licensetoolType='';
        String hostlicenseType='';     
        for(ComputerInput input : compInput){
            contactIdSet.add(input.sContactId);
            licensetoolType = input.licenseType;
        }
        if(licensetoolType == 'FIXED'){
            hostlicenseType = 'FIXED';
        }else if(licensetoolType == 'FLOAT' || licensetoolType == 'N-A'){
            hostlicenseType = 'FLOAT';
        }else if(licensetoolType == 'NEUTRAL'){
            hostlicenseType = 'FIXED or FLOAT';
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }
        List<Sales_Host__c> hostList;
        if(hostlicenseType == 'FIXED or FLOAT'){
            hostList = [SELECT Id, Name, Sales_Computer_Name_Txt__c,Sales_License_Type__c FROM Sales_Host__c WHERE Sales_isActiveHost__c=true and (Sales_Contact__c IN:primaryAdminIdSet OR Sales_Contact__c IN:contactIdSet)];
        }else{
            hostList = [SELECT Id, Name, Sales_Computer_Name_Txt__c,Sales_License_Type__c FROM Sales_Host__c WHERE Sales_License_Type__c=:hostlicenseType and Sales_isActiveHost__c=true and (Sales_Contact__c IN:primaryAdminIdSet OR Sales_Contact__c IN:contactIdSet)];
        }
        hostListofLists.add(hostList);
        return hostListofLists; 
    }
*/
}