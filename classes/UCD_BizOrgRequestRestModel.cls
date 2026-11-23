/**************** 
 * Author: Harshal Gosavi
 * Date: 20/09/2021
 * UCD_BizOrgRequestRestModel
 * This is a model class for UCD_BizOrgRequestRestController 
 * UseCase: deserialize and return the response.  
******************/
global without sharing class UCD_BizOrgRequestRestModel {
   
	global List<AccountRestDetail> AccountRequests{set;get;}

	global class AccountRestDetail{
		public String Name {set;get;}
		public String CustomerAggregationTypeCode {get;set;}
		public String CustomerProcessEngagmentCode {get;set;}
		public String RequesterName {get;set;}
		public String RequesterWWID {get;set;}
		public String RequesterEmail {get;set;}
        public String CustomerURL {get;set;}
		public List<AccountRestAddresses> Addresses {set;get;}
		public Boolean IsDuplicate{get;set;}
		public List<AccountRestRequestReference> AccountRequestReferences {get;set;}
		public String ParentBusinessPartyIdentifierReference {get;set;}
	}
    
    
	public class AccountRestAddresses{
		public String TypeCode { get{TypeCode = 'Billing'; return TypeCode; } set;}
		public String CountryCode {get;set;}
		public String CountryName {get;set;}
	}

	public class AccountRestRequestReference{
		public string Name {get;set;}
		public string Value {get;set;}
	}
    	
	global class BusinessOrganizationResponse{
		public String Code {set;get;}
		public String Status {set;get;}
		public String ErrorMessage {set;get;}
		public Data Data {set;get;}
	} 
    
    public class Data{
        public String AccountId{set;get;}
        public String Name{set;get;}
        public String CountryName{set;get;}
		public String AccountStatus{set;get;}
		public String DuplicateAccountId{set;get;}
		public String DuplicateAccountRecordType{set;get;}
		public UCD_ACM_Models.AccountResponseModel DuplicateAccountInfo{set;get;}

    }
    
	/**
     * description:-  Deserialize the JSON
     * params:- String
     * return:- UCD_BizOrgRequestRestModel
     * author and date:- ankit1x.sharma@intel.com 04/10/2021
     */

    public static UCD_BizOrgRequestRestModel parseRequestBody(String json){
		UCD_BizOrgRequestRestModel requestModel ;
		try{
			requestModel = (UCD_BizOrgRequestRestModel) System.JSON.deserialize(json, UCD_BizOrgRequestRestModel.class);
			return requestModel ;
		}
		catch(Exception ex){
            return null;
		}
    }
}