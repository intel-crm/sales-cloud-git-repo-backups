public without sharing class UCD_ACM_AICleansedAddressDataModel {
    public class RequestBody{
        public RequestData data{set;get;}
    }

    public class RequestData{
        public String organization{get;set;}
        public String address{get;set;}
        public String country{get;set;}
        public String stateProvince{get;set;}
        public String city{get;set;}
        public String postalCode{get;set;}
    }

    public class ResponseBody {
        public ResponseData data {get;set;}
        public CleansedData cleansed {get;set;}
        public Integer requestTimeMs {get;set;}
        public Decimal confidence {get;set;}
    }

    public class ResponseData {
        public String organization {get;set;}
        public String address {get;set;}
        public String country {get;set;}
    }
    
    public class CleansedData {
        public String organization {get;set;}
        public String address {get;set;}
        public String country {get;set;}
        public String countryAlpha2 {get;set;}
        public String stateProvince {get;set;}
        public String city {get;set;}
        public String postalCode {get;set;}
        public String explanation {get;set;}
        public String language {get;set;}
        public String addrVerificationStatus {get;set;}
    }
}