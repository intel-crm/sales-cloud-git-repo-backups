@RestResource(urlMapping='/PSLdata')
global with sharing class AnalyticsDashboardStep {
    @HttpPost 
    global static String fetchPSL() { 
        List<PermissionSetLicenseAssign> dataDisplay = new List<PermissionSetLicenseAssign>();
        List<WrappedData> wrpData = new List<WrappedData>();
        dataDisplay = [SELECT AssigneeId, PermissionSetLicenseId,PermissionSetLicense.MasterLabel FROM PermissionSetLicenseAssign];
        for(PermissionSetLicenseAssign  acc : dataDisplay){
            wrpData.add(new WrappedData(acc));
        }  
        //Serialize the wrapper that you have created with account data
        return JSON.serialize(new ChartFormatJSON(wrpData));
    }
    
    
    public class WrappedData{
        public String PermissionSetLicenseId;
        public String AssigneeId;
        public String PermissionSetLicense_MasterLabel ;
        public WrappedData(){}
        public WrappedData(PermissionSetLicenseAssign  data){
            this.PermissionSetLicenseId = data.PermissionSetLicenseId;
            this.AssigneeId = data.AssigneeId;
            this.PermissionSetLicense_MasterLabel = data.PermissionSetLicense.MasterLabel;
        }
    }
    public class ReturnMetadata 
    {
        public List<String> strings; // columns that return as text
        public List<String> numbers; // columns that return as numeric
        public List<String> groups;  // columns that return as groups
        public ReturnMetadata(List<String> strings, List<String> numbers, List<String> groups) {
            this.strings = strings;
            this.numbers = numbers;
            this.groups = groups;
        }
    }
    public class ChartFormatJSON {
        public List<WrappedData> data;
        public ReturnMetadata metadata;
        public ChartFormatJSON(List<WrappedData> data) {
            this.data = data;
            this.metadata = new ReturnMetadata(new List<String>{'PermissionSetLicenseId','AssigneeId','PermissionSetLicense_MasterLabel'}, 
                                               new List<String>{'PermissionSetLicense_MasterLabel'}, new List<String>{'PermissionSetLicenseId'});
        }   
    }
}