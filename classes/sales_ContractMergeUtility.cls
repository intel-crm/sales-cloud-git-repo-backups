/*********************************************************************************************************************
Class Name    : sales_ContractMergeUtility
Version       : 1.0
Created Date  : June 2022
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Sahil Bahadure        28-June-2022           
* *********************************************************************************************************************/
public with sharing class sales_ContractMergeUtility {
    @AuraEnabled
    public static List<Sales_License__c> getLicenseRecords(Id contractName){
        Id contName=contractName;
        try {
           List<Sales_License__c> lstOfLicenses= [select Id,Name, Sales_License_Contract_Txt__c,Sales_License_Product_Name_Txt__c,Sales_License_Avbl_Qty_Nbr__c,Sales_Tool_License_Type__c from Sales_License__c where Sales_License_Contract__c=:contName];
           return lstOfLicenses;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Sales_License__c> getFilteredRecords(String licName,Id contractId){
     System.debug('Source Contract Id:'+contractId);
     String licFilter='%'+licName+'%';
        try {
           List<Sales_License__c> lstOfLicenses= [select Id,Name, Sales_License_Contract_Txt__c,Sales_License_Product_Name_Txt__c,Sales_License_Avbl_Qty_Nbr__c from Sales_License__c where Name LIKE :licFilter AND Sales_License_Contract__c=:contractId LIMIT 20];
           return lstOfLicenses;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string checkMerge(List<String> licIds,Id cId){
        Set<String> removeDuplicates=new Set<String>(licIds);
        List<String> noDuplicatesInList=new List<String>(removeDuplicates);
            for(String s:noDuplicatesInList)
            {
                System.debug('License Name: '+s);
            }
            System.debug('Contract Id:'+cId);
            //calling sales_ContractMerge class
            try {              
                //Sales_ContractMerge.updateContractOnLicenses(noDuplicatesInList,cId);
                ID jobID = System.enqueueJob(new Sales_ContractMergeDemo(noDuplicatesInList,cId));
                String stat='Merge successfull with Job Id:'+jobID;
                return stat;
            } catch (Exception e) {
                String errmsg=e.getMessage();
                return errmsg;
            }
          
            
        } 
}