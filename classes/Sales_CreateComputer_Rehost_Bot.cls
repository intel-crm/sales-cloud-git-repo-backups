@isTest
public without sharing class Sales_CreateComputer_Rehost_Bot {
    /*public class ComputerInput {
        @InvocableVariable
        public Sales_Host__c hostObject;
        @InvocableVariable
        public String Sales_ComputerName_for_New_Computer;
        @InvocableVariable
        public String ComputerType_for_NewComputer;
        @InvocableVariable
        public String Host_LicenseType;
        @InvocableVariable
        public String NIC_ID_or_Guard_ID;
        @InvocableVariable
        public String Host_ID_or_Guard_ID;
        @InvocableVariable
        public String Guard_ID;
        @InvocableVariable
        public String Companion_Server1_ID;
        @InvocableVariable
        public String Companion_Server2_ID;
        @InvocableVariable
        public String Redundant_Server1_ID;
        @InvocableVariable
        public String Redundant_Server2_ID;
    }
    @InvocableMethod(label='Create Computer rehosting')
    public static void createComputerDetails(List<ComputerInput> computerInputs) {
        //Set<Id> hostIdsInput = new Set<Id>(); --unused variable
        Map<Id, ComputerInput> mapOfHostIdComputerInpts = new Map<Id, ComputerInput>();
        Set<Sales_Host__c> hostObjSet = new Set<Sales_Host__c>();
        Map<Id, String> mapOfHostObj = new Map<Id, String>();
        Map<String, Sales_Host__c> mapOfHostNameHostObject = new Map<String, Sales_Host__c>();
        List<Sales_Host__c> hostObjList = new List<Sales_Host__c>();
        for (ComputerInput compInput : computerInputs) {
            mapOfHostIdComputerInpts.put(compInput.hostObject.id, compInput);
        }
        List<Sales_License__c> licenseList = [SELECT Id,Name,Sales_License_Host_Node_Id__c,Sales_License_Activation_Code__c,Sales_Tool_License_Type__c
                                              FROM Sales_License__c where Sales_License_Host_Node_Id__c in :mapOfHostIdComputerInpts.keySet() and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional'];
        if (licenseList.size() > 0) {
            for (Sales_License__c lc : licenseList) {
                Sales_Host__c hostObj = new Sales_Host__c();
                ComputerInput compInput = mapOfHostIdComputerInpts.get(lc.Sales_License_Host_Node_Id__c);
                //String toolLicenseType = lc.Sales_Tool_License_Type__c;--unsed variable
                hostObj.Sales_Computer_Name_Txt__c = compInput.Sales_ComputerName_for_New_Computer; 
                hostObj.Sales_Computer_Type__c = compInput.ComputerType_for_NewComputer; 
                hostObj.Sales_License_Type__c = 'FIXED';
                if(compInput.NIC_ID_or_Guard_ID!=null){
                    hostObj.Name = compInput.NIC_ID_or_Guard_ID;      
                }else if(compInput.Host_ID_or_Guard_ID!=null){
                    hostObj.Name = compInput.Host_ID_or_Guard_ID;        
                }else if(compInput.Guard_ID!=null){
                    hostObj.Name = compInput.Guard_ID;              
                }
                if(compInput.Host_LicenseType == 'FIXED'){
                    if(compInput.Companion_Server1_ID!=null)
                        hostObj.Sales_Companion_Server1_Txt__c = compInput.Companion_Server1_ID;
                    if(compInput.Companion_Server2_ID!=null)
                        hostObj.Sales_Companion_Server2_Txt__c = compInput.Companion_Server2_ID;
                }
                else if(compInput.Host_LicenseType == 'FLOAT'){
                    if(compInput.Redundant_Server1_ID!=null)
                        hostObj.Sales_Redundant_Server1_Txt__c = compInput.Redundant_Server1_ID;
                    if(compInput.Redundant_Server2_ID!=null)
                        hostObj.Sales_Redundant_Server2_Txt__c = compInput.Redundant_Server2_ID;
                }
                hostObjSet.add(hostObj);
                if(!mapOfHostNameHostObject.containskey(hostObj.Name)){
                    mapOfHostNameHostObject.put(hostObj.Name, hostObj);
                }
                mapOfHostObj.put(lc.id, hostObj.Name);
            }
        }
        hostObjList.addAll(hostObjSet);
        if(hostObjList.size() > 0){
            insert hostObjList;
        }
        List<Sales_License__c> licenseToBeUpdatedList = new List<Sales_License__c>();
        for (Sales_License__c licenseItem : licenseList) {
            licenseItem.Sales_License_Host_Node_Id__c = mapOfHostNameHostObject.get(mapOfHostObj.get(licenseItem.Id)).id;
            licenseItem.Sales_License_Status__c  = 'Licensed';
            licenseToBeUpdatedList.add(licenseItem);
        }
        update licenseToBeUpdatedList;
    }*/
}