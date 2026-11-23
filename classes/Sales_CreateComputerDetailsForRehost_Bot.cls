@isTest
public without sharing class Sales_CreateComputerDetailsForRehost_Bot {
    /*public class ComputerInput {
        @InvocableVariable
        public String Primary_Admin_Contact;
        @InvocableVariable(required=true)
        public String Sales_Activation_Code;
        @InvocableVariable(required=true)
        public String Sales_ComputerName_for_New_Computer;
        @InvocableVariable(required=true)
        public String ComputerType_for_NewComputer;
        @InvocableVariable(required=true)
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
        @InvocableVariable
        public String licenseId;
    }
    public class ComputerOutput {
        @InvocableVariable
        public String isSuccess;
    }
    @InvocableMethod(label='Create Computer Details For Rehost')
    public static List<ComputerOutput> createComputerDetails(List<ComputerInput> computerInputs) {
        Boolean hostDuplicateCheck=false;
        Set<String> licenseActivationCodeSet = new Set<String>(); 
        Set<String> licIdSet=new Set<String>(); 
        Id licenseId;
        Integer flag=0;
        String check='chatbot';
        String returnMsg='';
        for (ComputerInput compInput : computerInputs) {
            licenseActivationCodeSet.add(compInput.Sales_Activation_Code);
            licIdSet.add(compInput.licenseId);
        }
        List<Sales_License__c> licenseList = [SELECT Id,Name,Sales_License_Host_Node_Id__c,Sales_License_Activation_Code__c,Sales_Tool_License_Type__c
                                              FROM Sales_License__c where Sales_License_Activation_Code__c in :licenseActivationCodeSet and Id in:licIdSet ];
        Map<String, Sales_License__c> licenseRecordMap = new Map<String, Sales_License__c>(); 
        if (licenseList.size() > 0) {
            for (Sales_License__c lc : licenseList) {
                licenseRecordMap.put(lc.Sales_License_Activation_Code__c, lc);
            }
        }
        Id primaryAdminContact;
        Map<Id, Sales_Host__c> mapOfHostObj = new Map<Id, Sales_Host__c>();
        List<Sales_Host__c> hostObjList = new List<Sales_Host__c>();
        for (ComputerInput compInput : computerInputs) {
            Sales_Host__c hostObj = new Sales_Host__c();
            if(licenseRecordMap.containsKey(compInput.Sales_Activation_Code)) {
                //String toolLicenseType = licenseRecordMap.get(compInput.Sales_Activation_Code).Sales_Tool_License_Type__c;--Unused
                hostObj.Sales_Host_Is_Created_From_Custom_Page__c=true;
                hostObj.Sales_Computer_Name_Txt__c = compInput.Sales_ComputerName_for_New_Computer; 
                hostObj.Sales_Computer_Type__c = compInput.ComputerType_for_NewComputer; 
                hostObj.Sales_License_Type__c = compInput.Host_LicenseType;                                           
                hostObj.Sales_Contact__c = compInput.Primary_Admin_Contact;
                primaryAdminContact = compInput.Primary_Admin_Contact;
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
                licenseId = licenseRecordMap.get(compInput.Sales_Activation_Code).Id;
                mapOfHostObj.put(licenseId, hostObj);
            }
            hostObjList.add(hostObj);
        }
        if(hostObjList.size() > 0){
            insert hostObjList;
        }
        List<ComputerOutput> computeroutput = new List<ComputerOutput>();        
        ComputerOutput output = new ComputerOutput();
        returnMsg = Sales_LicenseRecordPageComponentsUtility.createHostonLicenseRecord(hostObjList[0].Id, licenseId);
        output.isSuccess = returnMsg;
        computeroutput.add(output);
        return computeroutput;
    }*/
}