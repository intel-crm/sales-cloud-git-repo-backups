/*************************************************************************************************************************************
Apex Class Name     : PRM_UCD_ResponseWrapper 
Created Date        : Oct 2023

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Shraddha                Oct- 2023           Wrapper class for PRM_AccountChangeEventSubscriber
***************************************************************************************************************************************/
public class PRM_UCD_ResponseWrapper  {

    /*AccountAddress*/
    public class AccountAddress {
        public String TypeCode  {set;get;}
        public String CountryCode  {set;get;}
        public String CountryName  {set;get;}
    }
    
    /*MasteredBusinessPhysicalAddress*/
    public class MasteredBusinessPhysicalAddress {
    	public string CountryCode {get;set;}
        public string CountryName {get;set;}
        public MasteredBusinessPhysicalAddress(String countryCode,String countryName) {
            this.CountryCode = countryCode;
            this.CountryName = countryName;
        }
    }
    
    /*CustomerAggregationType*/
    public class CustomerAggregationType {
        public string Code {get;set;}
        public string Name {get;set;}
        public CustomerAggregationType(String code,String name) {
            this.Code = code;
            this.Name = name;
        }
    }
     
    /*CustomerProcessEngagement*/
    public class CustomerProcessEngagement {
       public string Code {get;set;}
        public string Name {get;set;}
        public CustomerProcessEngagement(string code, string name) {
            this.Code = code;
            this.Name=name;
        }       
    }
    
    /*ComplianceWatchList*/
    public class ComplianceWatchList  {
    	public string Code {get;set;}
        public string Name {get;set;}
        public ComplianceWatchList(String code,String name) {
            this.Code = code;
            this.Name = name;
        }
    }
    
    /*Header*/
    /*public class Header  {
        public String CustomerAggregationType  {set;get;}
        public String CustomerProcessEngagement  {set;get;}    
    }*/

    /*arqResponseData*/
    public class arqResponseData {
        public AccountResponseModel Account  {set;get;}
        public String RequestId  {set;get;}
        public String Status  {set;get;}
        public String AccountId  {set;get;} 
        public string RejectionReason  {set;get;}
        public String AccountReferenceSourceName  {set;get;}
    }

    /*AccountResponseModel*/
    public class AccountResponseModel  { 
        public string AccountId  { get; set; } 
        public string AccountName  { get; set; } 
        public string SurvivorAccountId  { get; set; } 
        public string BusinessPartyIdentifier  { get; set; } 
        public string MasteredSimplifiedAccountName  { get; set; } 
        public String RecordType  { get; set; } 
        public string RequestedAccountRejectionReason  { get; set; } 
        public string RequestedAccountRejectionNotes  { get; set; } 
        public AccountAddress PrimaryAddress  { get; set; } 
        public AccountAddress SecondaryAddress  { get; set; } 
        public MasteredBusinessPhysicalAddress MasteredBusinessPhysicalAddress  { get; set; } 
        public CustomerAggregationType CustomerAggregationType  { get; set; } 
        public List<CustomerProcessEngagement> CustomerProcessEngagement  { get; set; } 
        public AccountResponseModel ParentAccount  { get; set; } 
        public List<ComplianceWatchList> ComplianceWatchList  { get; set; } 
    }
}