/*********************************************************************************************************************
Class Name    : Sales_GetComputerList_Rehosting_Bot
Version       : 1.0
Created Date  : June 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Jasmine Narula           June-2021				 CHATBOT By Rehosting - Also used in By Computer Group
* ************************************************************************************************************************************************/
public without sharing class Sales_GetComputerList_Rehosting_Bot {
    public class ContactInput {
        @InvocableVariable
        public String scontactId;
    }
    @InvocableMethod(label='Get list of computer Rehosting')
    public static List<List<Sales_Host__c>> getHostDetails(List<ContactInput> contactId){
        List<List<Sales_Host__c>> hostObjList = new List<List<Sales_Host__c>>();
        Set<String> primaryAdminIdSet = new Set<String>();
        Set<String> contactIdSet = new Set<String>();
        for(ContactInput c : contactId ){
            contactIdSet.add(c.scontactId);
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet  and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }
        List<Sales_Host__c> hostlst = new List<Sales_Host__c>();
        List<Id> HostId =new list<Id>();
        if(contactIdSet.size() > 0){
            for(Sales_License__c lc : [Select Id,Sales_License_Status__c,Sales_Tool_License_Type__c,Sales_License_Host_Node_Id__r.Sales_Contact__c,Sales_License_Activation_Code__c,Sales_License_Product_Name_Txt__c,Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__c From Sales_License__c WHERE Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional' and(Sales_License_Host_Node_Id__r.Sales_Contact__c IN:primaryAdminIdSet OR Sales_License_Host_Node_Id__r.Sales_Contact__c IN:contactIdSet)]){
                HostId.add(lc.Sales_License_Host_Node_Id__c);
            }
            for(Sales_Host__c hostObj : [Select Id,Sales_Contact__c,Sales_isActiveHost__c,(Select Id From Licenses__r  LIMIT 1),Sales_License_Type__c,Sales_Computer_Type__c,Sales_Computer_Name_Txt__c,Name from Sales_Host__c WHERE id in:HostId and Sales_isActiveHost__c = true AND (Sales_Contact__c IN:primaryAdminIdSet OR Sales_Contact__c IN:contactIdSet) order by CreatedDate desc]){
                if(hostObj.Licenses__r != null && hostObj.Licenses__r.size() > 0 ) {
                    hostlst.add(hostObj);
                }    
            }
        }
        hostObjList.add(hostlst);     
        return hostObjList;
    }
}