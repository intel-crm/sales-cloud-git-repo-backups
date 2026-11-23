@isTest
public without sharing class Sales_CreateComputerDetails_Bot {
    /*public class ComputerInput {
        @InvocableVariable
        public String LicenseId;
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
        @InvocableVariable
        public String ContactId;
        @InvocableVariable
        public String LoggedUser;
    }
    public class ComputerOutput {
        @InvocableVariable
        public String isSuccess;
    }
    @InvocableMethod(label='Create Computer Details')
    public static List<ComputerOutput> createComputerDetails(List<ComputerInput> computerInputs) {
        Set<String> licenseActivationCodeSet = new Set<String>(); 
        boolean hostDuplicateCheck=false;
        Integer flag=0;
        String returnMsg='';
        String check='chatbot';
        Id loggedInuserContactId;
        Id licenseId;
        Sales_License_ContactUser__c contactUserJun = new Sales_License_ContactUser__c();
        List<User> loggedInUser =new List<User>();
        for (ComputerInput compInput : computerInputs) {
            licenseActivationCodeSet.add(compInput.LicenseId);
            loggedInuserContactId = Id.valueof(compInput.ContactId);
        }
        loggedInUser =[SELECT id from User where ContactId=:loggedInuserContactId];
        if(loggedInUser==null || loggedInUser.isEmpty()) {
            contactUserJun=[select Id,Sales_License_User__c, Sales_License_Contact__c  from Sales_License_ContactUser__c where Sales_License_Contact__c=:loggedInuserContactId];
        }
        List<Sales_License__c> licenseList = [SELECT Id,Name,Sales_License_Host_Node_Id__c,Sales_License_Activation_Code__c,Sales_Tool_License_Type__c
                                              FROM Sales_License__c where Id in :licenseActivationCodeSet and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional'];
        Map<String, Sales_License__c> licenseRecordMap = new Map<String, Sales_License__c>(); 
        if (licenseList.size() > 0) {
            for (Sales_License__c lc : licenseList) {
                licenseRecordMap.put(lc.Id, lc);
            }
        }
        Map<Id, Sales_Host__c> mapOfHostObj = new Map<Id, Sales_Host__c>();
        List<Sales_Host__c> hostObjList = new List<Sales_Host__c>();
        for (ComputerInput compInput : computerInputs) {
            Sales_Host__c hostObj = new Sales_Host__c();
            if(licenseRecordMap.containsKey(compInput.LicenseId)) {
                String toolLicenseType = licenseRecordMap.get(compInput.LicenseId).Sales_Tool_License_Type__c;
                hostObj.Sales_Computer_Name_Txt__c = compInput.Sales_ComputerName_for_New_Computer; 
                hostObj.Sales_Computer_Type__c = compInput.ComputerType_for_NewComputer; 
                hostObj.Sales_Contact__c = compInput.ContactId;
                if(loggedInUser != null && !loggedInUser.isEmpty() ){
                    hostObj.LastModifiedById = loggedInUser[0].Id;
                    hostObj.CreatedById = loggedInUser[0].Id;
                }
                else{
                    hostObj.LastModifiedById = contactUserJun.Sales_License_User__c;
                    hostObj.CreatedById = contactUserJun.Sales_License_User__c;
                }
                hostObj.Sales_Host_Is_Created_From_Custom_Page__c=true;
                hostObj.Sales_License_Type__c = compInput.Host_LicenseType;      
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
                licenseId = licenseRecordMap.get(compInput.LicenseId).Id;
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
    }
    public static String getHostLicenseType(String toolType){
        String returnType='';
        if(toolType == 'FIXED'){
            returnType = 'FIXED';
        }
        else if (toolType == 'N-A' || toolType == 'FLOAT'){
            returnType = 'FLOAT';
        }
        else if (toolType == 'NEUTRAL'){
            returnType = 'FIXED or FLOAT';
        }
        return returnType;
    }*/
}