public with sharing class Sales_GetComputerDetailsForCompanion_bot {
	public class ComputerInputFixed {
        @InvocableVariable
        public String scomputerNameFixed;
        @InvocableVariable
        public String scontactIdFixed;
    }
    @InvocableMethod(label='Get Companion Computer Details for Search')
    public static List<List<Sales_Host__c>> getDetailsonSearchforCompanion(List<ComputerInputFixed>compInput){
		Set<String> setofComputerName = new Set<String>();
        Set<String> contactIdSet = new Set<String>();
        Map<String,String> licenseToHostMap = new Map<String,String>();
        List<List<Sales_Host__c>> hostListofLists= new List<List<Sales_Host__c>>();
        Set<String> primaryAdminContactIdSet = new Set<String>();
        for(ComputerInputFixed input : compInput){
            String searchName= '%'+input.scomputerNameFixed+'%';
           	setofComputerName.add(searchName);
       		contactIdSet.add(input.scontactIdFixed);
        }
        for(Sales_License_Admin_Delegate__c licAdmin : [Select Id,Sales_License_PrimaryAdmin_Contact__c,Sales_License_DlgAdmin_Contact__c from Sales_License_Admin_Delegate__c where Sales_License_DlgAdmin_Contact__c IN:contactIdSet AND Sales_License_isActive__c=true]){
        	primaryAdminContactIdSet.add(licAdmin.Sales_License_PrimaryAdmin_Contact__c); 
       	}
        if(contactIdSet.size() > 0){
            for(Sales_License__c lic : [Select id ,Sales_License_Primary_Admin_Contact__c,Sales_License_Host_Node_Id__c,Sales_Tool_License_Type__c from Sales_License__c where (Sales_License_Primary_Admin_Contact__c IN:contactIdSet OR Sales_License_Primary_Admin_Contact__c IN:primaryAdminContactIdSet) AND  (Sales_License_Host_Node_Id__r.Sales_Contact__c IN:contactIdSet OR Sales_License_Host_Node_Id__r.Sales_Contact__c IN:primaryAdminContactIdSet) AND (Sales_Tool_License_Type__c='FIXED' OR Sales_Tool_License_Type__c='NEUTRAL')and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional']){
                licenseToHostMap.put(lic.Sales_License_Host_Node_Id__c,lic.id);
            }
        } 
        if(setofComputerName.size() > 0 && licenseToHostMap.size()>0){
            Set<String> searchName= setofComputerName;
            List<Sales_Host__c> hostList = [SELECT Id, Name, Sales_Computer_Name_Txt__c,Sales_License_Type__c,Sales_Companion_Server1_Txt__c,Sales_Companion_Server2_Txt__c,Sales_Computer_Type__c FROM Sales_Host__c WHERE  Sales_License_Type__c='FIXED' AND Sales_isActiveHost__c=true and (Sales_Computer_Name_Txt__c LIKE :searchName or Name LIKE  :searchName) AND (ID IN:licenseToHostMap.keySet()) order by CreatedDate  desc Limit 10];
            hostListofLists.add(hostList);
        }
        return hostListofLists; 
    }
    @auraEnabled
    public static String getLicenseHostId(Id recId){
        String hostId='';
        if(recId!=null){
            hostId=[Select Id,Sales_License_Host_Node_Id__c from Sales_License__c where id=:recId].Sales_License_Host_Node_Id__c;
        }
        return hostId;
    }
}