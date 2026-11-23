public class Pricing_UCD_ResponseWrapper {

    public class ResponseData{
        public String AccountId {set;get;}
        public String AccountName {set;get;}
        public string SurvivorAccountId {set;get;}
        public String MasteredSimplifiedAccountName {set;get;}
        public String BusinessPartyIdentifier {set;get;} 
        public String RequestedAccountRejectionReason {set;get;}
        public string RequestedAccountRejectionNotes {get; set;}
        public String RecordType {set;get;}
        public AccountAddress PrimaryAddress {set;get;}
        public AccountAddress SecondaryAddress {set;get;}
        public MasteredBusinessPhysicalAddress MasteredBusinessPhysicalAddress {set;get;}
        public CustomerAggregationType CustomerAggregationType {set;get;}
        public List<CustomerProcessEngagement> CustomerProcessEngagement {set;get;}
        public Pricing_UCD_ResponseWrapper.ResponseData ParentAccount {set;get;}
        public List<ComplianceWatchList> ComplianceWatchList {set;get;} 
    }

    public class AccountAddress{
        public String TypeCode {set;get;}
        public String CountryCode {set;get;}
        public String CountryName {set;get;}
    }
    
    public class MasteredBusinessPhysicalAddress{
    	public string CountryCode{get;set;}
        public string CountryName{get;set;}
        public MasteredBusinessPhysicalAddress(String countryCode,String countryName){
            this.CountryCode = countryCode;
            this.CountryName = countryName;
        }
    }
    
    public class CustomerAggregationType{
        public string Code{get;set;}
        public string Name{get;set;}
        public CustomerAggregationType(String code,String name){
            this.Code = code;
            this.Name = name;
        }
    }
     
    public class CustomerProcessEngagement{
       public string Code{get;set;}
        public string Name{get;set;}
        public CustomerProcessEngagement(string code, string name){
            this.Code = code;
            this.Name=name;
        }       
    }
    
    public class ComplianceWatchList {
    	public string Code{get;set;}
        public string Name{get;set;}
        public ComplianceWatchList(String code,String name){
            this.Code = code;
            this.Name = name;
        }
    }
    
    public class Header {
        public String CustomerAggregationType {set;get;}
        public String CustomerProcessEngagement {set;get;}    
    }

}