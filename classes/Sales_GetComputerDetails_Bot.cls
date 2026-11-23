public with sharing class Sales_GetComputerDetails_Bot {
    public class ComputerInput {
        @InvocableVariable
        public String scomputerName;
        @InvocableVariable
        public String sActivationCode;		
        @InvocableVariable
        public String sContactId;
    }
    @InvocableMethod(label='Get Computer Details on Search')
    public static List<List<Sales_Host__c>> getComputerDetailsonSearch(List<ComputerInput> compInput){
        Set<String> contactIdSet = new Set<String>();
        Set<String> primaryAdminIdSet = new Set<String>();
        List<List<Sales_Host__c>> hostListofLists= new List<List<Sales_Host__c>>();
        Map<String, String> mapOfInputs = new Map<String,String>();
        for(ComputerInput input : compInput){
            String searchName= '%'+input.scomputerName+'%';
            mapOfInputs.put(searchName, input.sActivationCode);
            contactIdSet.add(input.sContactId);
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }
        if(mapOfInputs.size() > 0){
            Set<String> searchName= mapOfInputs.KeySet();
            String licenseType = [SELECT Id, Sales_Tool_License_Type__c from Sales_License__c WHERE Id IN :mapOfInputs.values()]?.Sales_Tool_License_Type__c;
            String hostlicenseType='';       
            if(licenseType == 'FIXED'){
                hostlicenseType = 'FIXED';
            }else if(licenseType == 'FLOAT' || licenseType == 'N-A'){
                hostlicenseType = 'FLOAT';
            }else if(licenseType == 'NEUTRAL'){
                hostlicenseType = 'FIXED or FLOAT';
            }
            List<Sales_Host__c> hostList;
            if(hostlicenseType == 'FIXED or FLOAT'){
                hostList = [SELECT Id, Name, Sales_Computer_Name_Txt__c,Sales_License_Type__c FROM Sales_Host__c WHERE Sales_isActiveHost__c=true and (Sales_Contact__c IN:primaryAdminIdSet OR Sales_Contact__c IN:contactIdSet) and(Sales_Computer_Name_Txt__c LIKE :searchName or Name LIKE  :searchName)];
            }else{
                hostList = [SELECT Id, Name, Sales_Computer_Name_Txt__c,Sales_License_Type__c FROM Sales_Host__c WHERE Sales_License_Type__c=:hostlicenseType and Sales_isActiveHost__c=true and (Sales_Contact__c IN:primaryAdminIdSet OR Sales_Contact__c IN:contactIdSet) and(Sales_Computer_Name_Txt__c LIKE :searchName or Name LIKE  :searchName)];
            }hostListofLists.add(hostList);
        }
        return hostListofLists; 
    }
    @AuraEnabled (cacheable=true)
    public static List<Sales_Host__c> retriveComputerDetails(String hostName) {
        List<Sales_Host__c> lstProd = [SELECT Id, Name, Sales_Computer_Name_Txt__c,Sales_License_Type__c FROM Sales_Host__c WHERE Sales_Computer_Name_Txt__c =:hostName or Name=:hostName];
        return lstProd; 
    }
}