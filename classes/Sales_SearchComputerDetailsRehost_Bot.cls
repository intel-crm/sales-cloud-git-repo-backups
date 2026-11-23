public without sharing class Sales_SearchComputerDetailsRehost_Bot {
    public class ComputerInput {
        @InvocableVariable
        public String scomputerName;
        @InvocableVariable
        public String sActivationCode;
        @InvocableVariable
        public String sContactId;
        @InvocableVariable
        public String licenseId;
    }
    @InvocableMethod(label='Search computer details for rehosting')
    public static List<List<Sales_Host__c>> getComputerDetailsonSearch(List<ComputerInput> compInput){
        Set<String> contactIdSet = new Set<String>();
        Set<String> primaryAdminIdSet = new Set<String>();
        List<List<Sales_Host__c>> hostListofLists= new List<List<Sales_Host__c>>();
        List<Sales_Host__c> hostList = new List<Sales_Host__c>();    
        Map<String, String> mapOfInputs = new Map<String,String>();
        String inputcomputerName='';
        String liceseType;
        Set<Id> licIds= new Set<Id>();
        for(ComputerInput input : compInput){
            if(!String.isBlank(input.scomputerName))
            {
                inputcomputerName=input.scomputerName;
                String searchName= '%'+input.scomputerName+'%';
                mapOfInputs.put(searchName, input.licenseId);
            }
            contactIdSet.add(input.sContactId);
            licIds.add(input.licenseId);
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c);
        }
        if(mapOfInputs.size() > 0){
            Set<String> searchName= mapOfInputs.KeySet();
            liceseType = [SELECT Id, Sales_Tool_License_Type__c from Sales_License__c WHERE Id IN :mapOfInputs.values()]?.Sales_Tool_License_Type__c;
        }
        else
        {liceseType = [SELECT Id, Sales_Tool_License_Type__c from Sales_License__c WHERE Id IN :licIds]?.Sales_Tool_License_Type__c;
        }
        String hostquery;
        if(!String.isBlank(inputcomputerName))
        {
            hostquery='SELECT Id,Name, Sales_Contact__c,Sales_Contact__r.Name,Sales_Computer_Name_Txt__c,Sales_License_Type__c FROM Sales_Host__c WHERE (Sales_Computer_Name_Txt__c LIKE :searchName or Name LIKE :searchName) and (Sales_Contact__c IN:primaryAdminIdSet OR Sales_Contact__c IN:contactIdSet) and Sales_isActiveHost__c=true and ';
        }
        else
        {
            hostquery='SELECT Id,Name, Sales_Contact__c,Sales_Contact__r.Name,Sales_Computer_Name_Txt__c,Sales_License_Type__c FROM Sales_Host__c WHERE (Sales_Contact__c IN:primaryAdminIdSet OR Sales_Contact__c IN:contactIdSet) and Sales_isActiveHost__c=true and ';
        }
        if(liceseType == 'FIXED'){
            liceseType = 'Sales_License_Type__c=\'FIXED\'';
        }
        else if (liceseType == 'N-A' || liceseType == 'FLOAT'){
            liceseType = 'Sales_License_Type__c=\'FLOAT\'';
        }
        else if (liceseType == 'NEUTRAL'){
            liceseType = '(Sales_License_Type__c=\'FIXED\' or  Sales_License_Type__c=\'FLOAT\')';
        }
        hostquery = hostquery + liceseType;
        if(String.isNotBlank(hostquery)){
            hostList = Database.query(hostquery);
        }
        hostListofLists.add(hostList);
        return hostListofLists; 
    }
}