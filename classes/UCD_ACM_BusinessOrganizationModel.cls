global without sharing class UCD_ACM_BusinessOrganizationModel {


/*********************** Request **************************/

    public String TransactionId{get;set;}
    public BusinessOrganizationData BusinessOrganization{get;set;}
    public List<AttributesData> Attributes {set;get;}


    public class BusinessOrganizationData{
        public List<String> AccountId {set;get;}
        public List<String> BusinessPartyId {set;get;}
    }

    public class AttributesData{
        public String AttributeName {set;get;}
    }

/*********************** Parsing Request **************************/

    public static UCD_ACM_BusinessOrganizationModel parseRequestBody(String json){
            UCD_ACM_BusinessOrganizationModel requestBody ;
            try{
                     requestBody = (UCD_ACM_BusinessOrganizationModel) System.JSON.deserialize(json, UCD_ACM_BusinessOrganizationModel.class);
                     return requestBody ;
            }
            catch(Exception ex){
                return null;
            }
            
    }
    
/*********************** Response **************************/

    global class BusinessOrganizationResponse{
        public String Status {set;get;}
        public Decimal ExecutionTime {set;get;}
        public String InternalTxnID {set;get;}
        public List<ResponseData> Data {set;get;}
    } 
    
/*********************** ResponseData **************************/

    public class ResponseData{
        public String Id {set;get;}
        public AccountInformationData AccountInformation {set;get;}
        public List<AccountAddressInformation> AccountAddressInformation{set;get;}
        public ParentAccountInfomation ParentAccountInfomation{set;get;}
        public AccountMasteredDetails AccountMasteredDetails{set;get;}
        public List<AccountComplianceDetails> AccountComplianceDetails{set;get;}
    }
    
/*********************** Attributes **************************/

    public class AccountInformationData{
        public String AccountName {set;get;}
        public String AccountId {set;get;}
        public String BusinessPartyIdentifier {set;get;}
        public CustAggType CustomerAggregationType {set;get;}
        public List<cusProcEng> CustomerProcessEngagement {set;get;}
        public String AccountOwner{set;get;}
    }
    
    public class AccountAddressInformation{
        public String AddressType {set;get;}
        public String Street {set;get;}
        public String City {set;get;}
        public String StateCode {set;get;}
        public String StateName {set;get;}
        public String CountryName {set;get;}
        public String Countrycode {set;get;}
        public String ZipCode {set;get;}

    }
    
    public class ParentAccountInfomation{
        public String AccountName {set;get;}
        public Id AccountId {set;get;}
        public Id AcocuntId {set;get;}
        public String BusinessPartyIdentifier {set;get;}
        public String SimplifiedAccountName {set;get;} 

    }
    
    public class AccountMasteredDetails{
        public String SimplifiedAccountName {set;get;}
        public String BusinessPartyIdentifier {set;get;}
        public Address Address {set;get;}
        public String SimplifiedLocalLanguageName {set;get;}
        public String UnifiedHierarchy {set;get;}
 
    }
    
    public class AccountComplianceDetails{
        public String Code {set;get;}
        public String Name {set;get;}
        //public Date EffectiveStartDtm {set;get;}
        //public Date EffectiveEndDtm {set;get;}

    }

/*********************** List Inside Attributes **************************/ 
    
    public class Address{
        //public String AddressType {set;get;}
        public String CountryCode {set;get;}
        public String CountryName {set;get;}
    }
    
    public class CustAggType{
        public String Code {set;get;}
        public String Name {set;get;}

    }

    public class cusProcEng{
        public String Code {set;get;}
        public String Name {set;get;}

    }

   
}