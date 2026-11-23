public with sharing class Core_IPS_CaseDetailsWrapper {
    public Core_IPS_CaseDetailsWrapper() {

    }
    public class BasicInfo {
        public string project;
        public string projectName;
        public string productvariant;
        public string productvariantName;
        public string Product;
        public string ProductName;
        public string Subject;
        public string CategoryId;
        public string CategoryName;
        public string SubCategoryName;
        public string SubCategoryId;
        public string Language;
        public string NickName;
        public string testQuestion;
        public string childQuestion1;
        public string childQuestion2;
        public string picklistQuestion;
        
    }
    public class finalPageDetails {
        public String subject;
        public String description;
        public String caseType;
        public String caseseverity;
        public String custmerreference;
        public String endcustomer;
    }
    public static Core_IPS_CaseDetailsWrapper.BasicInfo parseBasicInfo(String json) {
        return (Core_IPS_CaseDetailsWrapper.BasicInfo) System.JSON.deserialize(json, Core_IPS_CaseDetailsWrapper.BasicInfo.class);
    }
    public static Core_IPS_CaseDetailsWrapper.finalPageDetails parsefinalPageDetails(String json) {
        return (Core_IPS_CaseDetailsWrapper.finalPageDetails ) System.JSON.deserialize(json, Core_IPS_CaseDetailsWrapper.finalPageDetails.class);
    }
}