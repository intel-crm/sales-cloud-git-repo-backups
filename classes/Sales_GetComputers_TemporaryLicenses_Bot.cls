@isTest
public without sharing class Sales_GetComputers_TemporaryLicenses_Bot {
    /*public class ContactInput {
        @InvocableVariable
        public String scontactId;
    }
    @InvocableMethod(label='Get list of computer Temporary(Active and Float type)')
    public static List<List<Sales_Host__c>> getActiveFloattypeHostDetails(List<ContactInput> contactId){
        List<List<Sales_Host__c>> hostObjList = new List<List<Sales_Host__c>>();
        Set<String> primaryAdminIdSet = new Set<String>();
        Set<String> contactIdSet = new Set<String>();
        for(ContactInput c : contactId ){
            contactIdSet.add(c.scontactId);
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet and Sales_License_isActive__c=true]){
            primaryAdminIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
        }
        List<Sales_Host__c> hostlst = new List<Sales_Host__c>();
        List<Id> HostId =new list<Id>();
        if((contactIdSet.size() > 0)){
            for(Sales_License__c lc : [Select Id,Sales_License_Status__c,Sales_Tool_License_Type__c,Sales_License_Activation_Code__c,Sales_License_Product_Name_Txt__c,Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__c,Sales_License_Available_Temp_Licenses__c From Sales_License__c WHERE Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional' AND Sales_License_Host_Node_Id__c !=NULL AND (Sales_License_Primary_Admin_Contact__c IN:primaryAdminIdSet  OR Sales_License_Primary_Admin_Contact__c IN:contactIdSet) and Sales_License_Available_Temp_Licenses__c>0 and Sales_License_Available_Temp_Licenses__c!=null]){
                HostId.add(lc.Sales_License_Host_Node_Id__c);
            }
            for(Sales_Host__c hostObj : [Select Id,Sales_Contact__c,Sales_isActiveHost__c,(Select Id From Licenses__r LIMIT 1),Sales_License_Type__c,Sales_Computer_Type__c,Sales_Computer_Name_Txt__c,Name from Sales_Host__c WHERE Sales_isActiveHost__c = true and id in:HostId AND Sales_License_Type__c='FLOAT' AND (Sales_Contact__c IN:primaryAdminIdSet OR Sales_Contact__c IN:contactIdSet) order by CreatedDate desc]){
                if(hostObj.Licenses__r != null && hostObj.Licenses__r.size() > 0 ) {
                    hostlst.add(hostObj);
                }    
            }
        }
        hostObjList.add(hostlst);     
        return hostObjList;
    }*/
}