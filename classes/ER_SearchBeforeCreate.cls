/*********************************************************************************************************************
Modification Log : 
* Developer                 		Date                    Description
* ----------------------------------------------------------------------------------------------
*Harshitha/Manjunatha(Quest)       25/06/2021               Apex Class for Search Before Create functionality for B2B Programs
*********************************************************************************************************************/
@RestResource(urlMapping='/Account/V2/SearchAccount-old')

global without sharing class ER_SearchBeforeCreate {
     public static Set<Id> sbrAccountIds = new Set<Id>();
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
            Set<Id> setOfAccId = new Set<Id>();
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
                //listOfCimResult = new ER_SearchCIMAccounts().getCimResults(SearchAccount.AccountName, SearchAccount.AccountAddress.AddressLine1, SearchAccount.AccountAddress.PostalCode,SearchAccount.AccountAddress.City,billingCountryForAPI,SearchAccount.AccountAddress.StateCode2,SearchAccount.SearchLimit,SearchAccount.MinimumSearchScore,SearchAccount.AccountURL,SearchAccount.EmailAddress,AccountType, true);
				//System.debug('listOfCimResult size : '+listOfCimResult.size());
				 
            
            List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fDetailsList  = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();
        	PRM_AdminRegistrationDuplicateDetails.ucdErrorhandlingWrapper ucdErrWrp = new PRM_AdminRegistrationDuplicateDetails.ucdErrorhandlingWrapper();  
            PRM_AdminRegistrationDuplicateDetails.CountryStateWrapperForSBR csWrp = new PRM_AdminRegistrationDuplicateDetails.CountryStateWrapperForSBR();
            csWrp = PRM_AdminRegistrationDuplicateDetails.getCountryOrStateForSBR (SearchAccount.AccountAddress.CountryCode2, SearchAccount.AccountAddress.StateCode2);
            //create wrapper to search matching account results
            fDetailsList = PRM_AdminRegistrationDuplicateDetails.createFDetailsList (SearchAccount.AccountName, csWrp.country, csWrp.state, SearchAccount.AccountURL);
			 //List<ER_SearchAccounts> lstSearchAccountObj = new List<ER_SearchAccounts>();
            //call reltio API to get matching accounts
             UCD_GenericAcctSearch_SBR.AccountSearchDataModelWithError accFinalDetails = UCD_GenericAcctSearch_SBR.getAcctResults (fDetailsList, 'Partner');
            //get only account details
            List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel> accDetails = accFinalDetails.accountSearchModel;
            if (accDetails != null && !accDetails.isEmpty()) {
                getUcdAccDetailsMap(accDetails);
            }
            List<Account> accList = [SELECT Id, Name,Core_CIM_ID__c, Unified_Hierarchy_View__c,Core_Customer_Aggregation_Type__c,Core_Business_Party_Id__c, Core_Address_Details__c, 
                                Core_Intel_Partner_Alliance_PartnerGroup__c, /*Core_Account_Type__c, // BizOrgType code removal*/ toLabel(Core_IPA_Partner_Role__c), Core_Export_Compliance_Block__c, 
                                RecordType.name, Owner.name, BillingCity, BillingStateCode, BillingCountryCode, BillingStreet,BillingPostalCode,
                                Core_Unified_Global_Customer_Name__c,Core_CNDA_Number__c,Core_Covered_Account__c
                                FROM Account WHERE Id IN: sbrAccountIds];
            for(Account acc :accList)
                {	
                    setOfAccId.add(acc.Id);
                    ER_SearchAccounts accSearchObj = new ER_SearchAccounts(acc.id,acc.Core_CIM_ID__c, acc, 0); 
                    lstSearchAccountObj.add(accSearchObj);
                } 
				
                
            }
            List<ER_SBC_PriorityMatrix__mdt> priorityMatrix = [SELECT AccountType__c,PriorityField__c,PriorityNumber__c,isObjectField__c,PriorityValue__c,isSearchScore__c
                                                               FROM ER_SBC_PriorityMatrix__mdt WHERE AccountType__c ='RDC' ORDER by PriorityNumber__c]; 
            // Sorting the Accounts based on Priority Logic
           // lstSearchAccountObj = ER_SearchSalesCloudAccounts.getSortedAccountsCim(listOfCimResult,setOfAccountId,AccountType,SearchAccount.SearchLimit);
            //System.debug('lstSearchAccountObj size : '+lstSearchAccountObj.size());
            List<ER_SearchAccounts> accoutSortedList = ER_SearchSalesCloudAccounts.sortIdBasedOnSortingCriteria(lstSearchAccountObj,setOfAccId,priorityMatrix,SearchAccount.SearchLimit);
            
            List<ER_SBCAccountSearchResponse> cimAccountsList = new List<ER_SBCAccountSearchResponse>();
            if(lstSearchAccountObj != null){
                //Formatting the Response from CIM
                cimAccountsList.addAll(getResponseJSON(accoutSortedList,countryMap));
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
        public String BizOrgType{ get; set;}
        public String SearchLimit { get; set; }
        public String MinimumSearchScore { get; set; }
        public String EntitlementName { get; set; }
   
    }
 

    @Testvisible     
    private static void getUcdAccDetailsMap(List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel> accDetails) {
        List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel> sbrChildAcc = new List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel>();

        //store parent account ids in set
        for (UCD_GenericAcctSearch_SBR.AccountSearchDataModel adm : accDetails) {
            sbrAccountIds.add(adm.accId);
            if(adm.childAccounts != null && !adm.childAccounts.isEmpty()) {
                sbrChildAcc.addAll(adm.childAccounts); 
            }
        }

        //if any child account present call that same method again to store the accIds and to get child accounts if present
        if(!sbrChildAcc.isEmpty() && sbrChildAcc != null) {
            getUcdAccDetailsMap(sbrChildAcc);
        }
    }
    
    
}