/*********************************************************************************************************************
Modification Log : 
* Developer                 		Date                    Description
* ----------------------------------------------------------------------------------------------
*Harshitha/Manjunatha(Quest)       25/06/2021               Apex Class for Search Before Create functionality for B2B Programs
*********************************************************************************************************************/
@RestResource(urlMapping='/Account/V2/SearchAccount-old')
global without sharing class ER_SearchBeforeCreate {
    global class SearchResults{
        List<ER_SBCAccountSearchResponse> SearchResults = new List<ER_SBCAccountSearchResponse>();
        SearchResults(List<ER_SBCAccountSearchResponse> listOfAccountSearch){
            if(listOfAccountSearch != null){
                SearchResults = listOfAccountSearch;
            }
        }
    }
    
    
    /* API End Point : /services/apexrest/Account/EnterpriseRegistrationSBC
* Sample Request : { "AccountName": "Apple UK", "AccountAddress": { "CountryCode2": "GBR" }, "EmailAddress": "alleniheavshadvbha@mailinator.com", "SearchLimit": "10", "MinimumSearchScore": "55", "AccountType" : "RDC" }
* HTTP Post Method for capturing input Request for SBC logic
* AccountType is the Program code from which the request is sent
*/
    //Post method Make entitlement name as input parameter.
    //Add default logic to return accounts if entitlement arguement is not passed.
    //Minimum search score changed to searchscore
    ////
    
    @HttpPost
    //global static void doPost(String AccountName,Address AccountAddress, String AccountURL, String EmailAddress, String SearchLimit, String MinimumSearchScore,String AccountType) {		
    global static void doPost(ER_SearchBeforeCreate.CIMSearchBeforeCreate SearchAccount){
        RestResponse res = RestContext.response;
      //  Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        try{
            List<ER_SearchAccounts> lstSearchAccountObj = new List<ER_SearchAccounts>();
            List<PRM_CIMSearchResults__c> listOfCimResult = null;
            Set<Id> setOfAccountId = new Set<Id>();
            String AccountType = '';
            
            //Getting all Country codes from Country Mapping
            Map<string,string> countryMap = new map<string,string>();
            for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {                    
                countryMap.put(allCountries.ISO_Code__c,allCountries.Country_Code__c);
            }
           
            //Getting all the Billing Countries from teh country code map
            string billingCountryForAPI;
            if(SearchAccount.AccountAddress.CountryCode2!=null && SearchAccount.AccountAddress.CountryCode2.toUpperCase().length() == 3 && countryMap!=null && countryMap.containsKey(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){
                billingCountryForAPI = countryMap.get(SearchAccount.AccountAddress.CountryCode2);
            }else{
                if(String.isNotBlank(SearchAccount.AccountAddress.CountryCode2) && SearchAccount.AccountAddress.CountryCode2.toUpperCase().length() == 2 && countryMap!=null && countryMap.values().contains(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){
                    billingCountryForAPI= SearchAccount.AccountAddress.CountryCode2;
                }
            }
            //Checking for invalid Country code
            if(SearchAccount.AccountAddress != null){
                if(String.isBlank(SearchAccount.AccountAddress.CountryCode2) && String.isBlank(billingCountryForAPI)){ 
                    throw new CustomException('INVALID_COUNTRYCODE');
                }
            }
            
            if(String.isNotBlank(SearchAccount.EntitlementName))
            {
                List<string> ceAccountType=Label.CEAccountTypeMap.split(';');
                Map<string,string> ceAccountTypeMap= new  Map<string,string>();
                for(string ceAType : ceAccountType){
                    List<string> ceAccsplit=ceAType.split('-');
                    ceAccountTypeMap.put(ceAccsplit[0],(ceAccsplit[1]));
                }
                
                if(ceAccountTypeMap.containsKey(SearchAccount.EntitlementName))
                {
                    AccountType = ceAccountTypeMap.get(SearchAccount.EntitlementName);
                }
                else
                {
                    throw new CustomException('INVALID_BUSINESSTYPE');
                }                
            }
            
            //CIM Callout Logic : ER_SearchCIMAccounts
            if(String.isNotBlank(SearchAccount.SearchLimit))
            {
                
                //ER_SearchCIMAccounts erCIMCallout = new ER_SearchCIMAccounts();
                if(String.IsNotBlank(SearchAccount.AccountAddress.AddressLine2)){
                    SearchAccount.AccountAddress.AddressLine1 = SearchAccount.AccountAddress.AddressLine1 +' '+ SearchAccount.AccountAddress.AddressLine2;
                }
                
                //Calling CIM API to get Matching Account Score Results                
                listOfCimResult = new ER_SearchCIMAccounts().getCimResults(SearchAccount.AccountName, SearchAccount.AccountAddress.AddressLine1, SearchAccount.AccountAddress.PostalCode,SearchAccount.AccountAddress.City,billingCountryForAPI,SearchAccount.AccountAddress.StateCode2,SearchAccount.SearchLimit,SearchAccount.MinimumSearchScore,SearchAccount.AccountURL,SearchAccount.EmailAddress,AccountType, true);
               
            }
            
            // Sorting the Accounts based on Priority Logic
            lstSearchAccountObj = ER_SearchSalesCloudAccounts.getSortedAccountsCim(listOfCimResult,setOfAccountId,AccountType,SearchAccount.SearchLimit);
            
            List<ER_SBCAccountSearchResponse> cimAccountsList = new List<ER_SBCAccountSearchResponse>();
            if(lstSearchAccountObj != null){
                //Formatting the Response from CIM
                cimAccountsList.addAll(getResponseJSON(lstSearchAccountObj,countryMap));
            }
            
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(new SearchResults(cimAccountsList)));
        }catch(CustomException ce){
            res.statusCode = 400;
            SalesforceError[] errs = null;
            
            if(ce.getMessage()=='INVALID_COUNTRYCODE'){
                errs = new SalesforceError[]{new SalesforceError('0001', 'Invalid Country Code')};
                    res.responseBody = Blob.valueOf(JSON.serialize(errs));
            }  
             if(ce.getMessage()=='INVALID_BUSINESSTYPE'){
                errs = new SalesforceError[]{new SalesforceError('0002', 'Invalid Entitlement Name or Entitlement has no BusinessType association.')};
                    res.responseBody = Blob.valueOf(JSON.serialize(errs));
            }   
            
            
        }catch(System.QueryException e){           
            res.statusCode = 400;
            SalesforceError[] errs = new SalesforceError[]{ 
                new SalesforceError('Query Exception ', e.getMessage())
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(errs));                  
        }catch(Exception e){             
            res.statusCode = 400;
            SalesforceError[] errs = new SalesforceError[]{ 
                new SalesforceError('BAD_REQUEST', e.getMessage())
                    };
                        res.responseBody = Blob.valueOf(JSON.serialize(errs));        
        }
    }
    
    //Response Formatting
    private static List<ER_SBCAccountSearchResponse> getResponseJSON(List<ER_SearchAccounts> lstSrcAccount, Map<String,String> countryMap){
        List<ER_SBCAccountSearchResponse> cimAccountsList = new List<ER_SBCAccountSearchResponse>();
        for(ER_SearchAccounts prmSrcAcc : lstSrcAccount){
            
            Account account = prmSrcAcc.acc;
            Address addObj = new Address(account.BillingStreet, null, account.BillingCity, countryMap.get(account.BillingCountryCode),
                                         account.BillingStateCode, account.BillingPostalCode);
            ER_SBCAccountSearchResponse cimAccount = new ER_SBCAccountSearchResponse(account.Name,addObj,account.Id, prmSrcAcc.accCIMId);
            cimAccountsList.add(cimAccount);
            
        }  
        return cimAccountsList;
    }
    
    //standard salesforce error response structure
    public class SalesforceError {
        public String errorCode;
        public String message;
        public SalesforceError(String errorCode, string message){
            this.errorCode = errorCode;
            this.message = message;
        }
    } 
    public class CustomException extends Exception{}
    
    global class CIMSearchBeforeCreate
    {
        public String AccountName { get; set; }
        public Address AccountAddress { get; set; }
        public String AccountURL { get; set; }
        public String EmailAddress { get; set; }
        public String SearchLimit { get; set; }
        public String MinimumSearchScore { get; set; }
        public String EntitlementName { get; set; }
    }
    
}