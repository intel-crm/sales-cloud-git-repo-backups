/****************
 * Author: Harshal Gosavi
 * Date: 20/09/2021 
 * UCD_IQROrgRequestModel
 * This is a model class for UCD_IQROrgRequestController 
 * UseCase: return the response.  
******************/
global without sharing class UCD_BizOrgRequestModel { 

	global List<AccountDetail> AccountRequests{set;get;}

	global class AccountDetail{
		public String Name {set;get;}
		public String CustomerAggregationTypeCode {get;set;}
		public String CustomerProcessEngagmentCode {get;set;}
		public String RequesterName {get;set;}
		public String RequesterWWID {get;set;}
		public String RequesterEmail {get;set;}
		public List<AccountAddresses> Addresses {set;get;} 
		public Boolean IsDuplicate{get;set;}
		public List<AccountRequestReference> AccountRequestReferences {get;set;}
		public String ParentBusinessPartyIdentifierReference {get;set;}
		public String CustomerURL {get;set;}
	}
    
    
	Public class AccountAddresses{
		public String TypeCode { get{TypeCode = (TypeCode == null || TypeCode!= 'Shipping') ? 'Billing' : TypeCode; return TypeCode; } set;}
		public String CountryCode {get;set;}
		public String CountryName {get;set;}
	}
	
	public class AccountRequestReference{
		public string Name {get;set;}
		public string Value {get;set;}
	}
    	
	global Class BusinessOrganizationResponse{
		public String Code {set;get;}
		public String Status {set;get;}
		public String Errormessage {set;get;}
		public Data Data {set;get;}
	} 
    
    public class Data{
        public String AccountId{set;get;}
        public String Name{set;get;}
        public String CountryName{set;get;}
		public String AccountStatus{set;get;}
		public String DuplicateAccountId{set;get;}
		public String DuplicateAccountRecordType {set;get;}
		public UCD_ACM_Models.AccountResponseModel DuplicateAccountInfo{set;get;}
    }
     
}