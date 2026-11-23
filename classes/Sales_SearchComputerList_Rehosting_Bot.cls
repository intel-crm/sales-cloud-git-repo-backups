/*********************************************************************************************************************
Class Name    : Sales_Primary_DelegateNames_Utility
Version       : 1.0
Created Date  : Jun 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula        23-Jun-2021                 Also used in By Computer Group
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_SearchComputerList_Rehosting_Bot {
/*
    public class ContactInput {
        @InvocableVariable
        public String scontactId;
        @InvocableVariable
        public String computername;
    }
    @InvocableMethod(label='Search computer Rehosting')
    public static List<List<Sales_Host__c>> getHostDetails(List<ContactInput> inputs) {
        List<List<Sales_Host__c>> hostObjList = new List<List<Sales_Host__c>>();
        Map<String, String> mapofInputs = new map<String, String>();
        Set<String> primaryAdminIdSet = new Set<String>();
        for(ContactInput c : inputs){
            String searchName= '%'+c.computername+'%';
            mapofInputs.put(c.scontactId, searchName);
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:mapofInputs.keySet() and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }
        List<Sales_Host__c> hostlst = new List<Sales_Host__c>();
        List<Id> HostId =new list<Id>();
        List<String> searchName= mapofInputs.values();
        for(Sales_License__c lc : [Select Id,Sales_License_Status__c,Sales_Tool_License_Type__c,Sales_License_Activation_Code__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Product_Name_Txt__c,Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__c,Sales_License_Primary_Admin_Contact__c From Sales_License__c WHERE Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional' AND Sales_License_Host_Node_Id__c !=NULL and (Sales_License_Primary_Admin_Contact__c IN:primaryAdminIdSet  OR Sales_License_Lic_User_Contact_ID__c IN:mapofInputs.keySet() OR Sales_License_Primary_Admin_Contact__c IN:mapofInputs.keySet())]){
            HostId.add(lc.Sales_License_Host_Node_Id__c);
            primaryAdminIdSet.add(lc.Sales_License_Lic_User_Contact_ID__c);
        }
        for(Sales_Host__c hostObj : [Select Id,Sales_Contact__c,Sales_isActiveHost__c,(Select Id From Licenses__r  LIMIT 1),Sales_License_Type__c,Sales_Computer_Type__c,Sales_Computer_Name_Txt__c,Name from Sales_Host__c where Sales_isActiveHost__c = true AND (Sales_Contact__c IN:primaryAdminIdSet OR Sales_Contact__c IN:mapofInputs.keySet()) AND  id in:HostId and (Sales_Computer_Name_Txt__c LIKE :searchName or Name LIKE  :searchName) order by CreatedDate desc]){
            if(hostObj.Licenses__r != null && hostObj.Licenses__r.size() > 0 ) {
                hostlst.add(hostObj);
            }    
        }
        hostObjList.add(hostlst);     
        return hostObjList;
    }
*/
}