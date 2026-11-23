public without sharing class Sales_GetHostRecordDetails_Bot {
    public class HostOutput {
        @InvocableVariable
        public String outputString;
    }
    public class HostInput {
        @InvocableVariable
        public Sales_Host__c hostObject;
        @InvocableVariable 
        public String Host_LicenseType_New;
    }
    @InvocableMethod(label='Get host record details')
    public static List<HostOutput> getHostRecordDetails(List<HostInput> hostInputData) {
        List<HostOutput> hostOutputList = new List<HostOutput>(); 
        HostOutput hostOutput = new HostOutput();
        Set<String> hostIds = new Set<String>(); 
        List<String> licenseList = new List<String>();
        List<String> LicenseListFixed = new List<String>();
        List<String> LicenseListFloat = new List<String>();
        List<String> LicenseListNeutral = new List<String>();
        String message ;
        String hostLicenseTypeNew ;
        for(HostInput input : hostInputData) {
            hostIds.add(input.hostObject.Id);
            hostLicenseTypeNew = input.Host_LicenseType_New;
        }
        for(Sales_License__c license : [SELECT Id,Name,Sales_License_Host_Node_Id__c,Sales_License_Host_Node_Id__r.Sales_License_Type__c,Sales_License_Activation_Code__c,Sales_Tool_License_Type__c
                                        FROM Sales_License__c where Sales_License_Host_Node_Id__c IN: hostIds and Sales_License_Web_Display_Flag__c=true and Sales_License_Type__c!='Optional']){
                                            licenseList.add(license.Id);
                                            if(license.Sales_Tool_License_Type__c=='NEUTRAL' && (license.Sales_License_Host_Node_Id__r.Sales_License_Type__c=='FLOAT' || license.Sales_License_Host_Node_Id__r.Sales_License_Type__c=='FIXED')){
                                                LicenseListNeutral.add(license.Id);
                                            }
                                            if((license.Sales_Tool_License_Type__c=='FIXED' || license.Sales_Tool_License_Type__c=='NEUTRAL') && license.Sales_License_Host_Node_Id__r.Sales_License_Type__c=='FIXED'){
                                                LicenseListFixed.add(license.Id);
                                            }
                                            else if((license.Sales_Tool_License_Type__c=='FLOAT' || (license.Sales_Tool_License_Type__c=='NEUTRAL') || (license.Sales_Tool_License_Type__c=='N-A')) && license.Sales_License_Host_Node_Id__r.Sales_License_Type__c=='FLOAT'){
                                                LicenseListFloat.add(license.Id);
                                            }
                                        }
        if(licenseList.size()>0 && (LicenseListNeutral.size()>0) && (licenseList.size()==LicenseListNeutral.size()) && (hostLicenseTypeNew=='FIXED' || hostLicenseTypeNew=='FLOAT')){
            message = hostLicenseTypeNew;          
        }
        else if(licenseList.size()>0 && (LicenseListFixed.size()>0) && (licenseList.size()==LicenseListFixed.size()) && (hostLicenseTypeNew=='FIXED')){
            message = hostLicenseTypeNew;           
        }
        else if(licenseList.size()>0 && (LicenseListFloat.size()>0) && (licenseList.size()==LicenseListFloat.size()) && (hostLicenseTypeNew=='FLOAT')){
            message = hostLicenseTypeNew;          
        }
        else {
            message = 'MISMATCH';
        }
        HostOutput output = new HostOutput();
        output.outputString = message;
        hostOutputList.add(output);
        return hostOutputList;
    }
}