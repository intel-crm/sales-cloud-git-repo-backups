@RestResource(urlMapping='/Account/merge/SearchAccount')
global without sharing class PRM_ER_AccountSearch {  
    global class SearchResults{
        List<PRM_ER_CIMAccountSearchInfo> SearchResults = new List<PRM_ER_CIMAccountSearchInfo>();
        SearchResults(List<PRM_ER_CIMAccountSearchInfo> listOfAccountSearch){
            if(listOfAccountSearch != null){
                SearchResults = listOfAccountSearch;
                System.debug('PRM_ER_SearchResults : '+SearchResults);
                System.debug('PRM_ER_SearchResults : '+SearchResults.size());
                
            }
        }
    }
    
    @HttpPost
    global static void doPost(PRM_ER_AccountSearch.CIMSearchBeforeCreate SearchAccount) {		
        RestResponse res = RestContext.response;
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        try{
            List<PRM_SearchAccounts> lst_PrgSearchAccount = new List<PRM_SearchAccounts>();
            List<ER_SearchAccounts> lst_EntSearchAccount = new List<ER_SearchAccounts>();
            List<PRM_ER_CIMAccountSearchInfo> cimAccountsList = new List<PRM_ER_CIMAccountSearchInfo>();
            List<PRM_CIMSearchResults__c> listOfCimResult = null;
            List<String> PROCCountries = Label.PRM_PROC_Countries.toUpperCase().split(',');
            Set<Id> setOfAccountId = new Set<Id>();
            system.debug('Country Code PROCCountries ==>'+PROCCountries);
            String AccountType = '';
            Boolean isProgramBased ;
            Map<string,string> countryMap = new map<string,string>();
            for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                //countryMap.put(allCountries.Country_Code__c, allCountries.ISO_Code__c);
                countryMap.put(allCountries.ISO_Code__c,allCountries.Country_Code__c);
                //system.debug('allCountries.ISO_Code__c --> '+allCountries.ISO_Code__c);
            }
            System.debug('Country Map : '+countryMap);
            string billingCountryForAPI;
            if(SearchAccount.AccountAddress.CountryCode2!=null && SearchAccount.AccountAddress.CountryCode2.toUpperCase().length() == 3 && countryMap!=null && countryMap.containsKey(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){
                billingCountryForAPI = countryMap.get(SearchAccount.AccountAddress.CountryCode2);
            }else{
                if(String.isNotBlank(SearchAccount.AccountAddress.CountryCode2) && SearchAccount.AccountAddress.CountryCode2.toUpperCase().length() == 2 && countryMap!=null && countryMap.values().contains(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){
                    billingCountryForAPI= SearchAccount.AccountAddress.CountryCode2;
                }
            }
            System.debug('billingCountryForAPI --> '+billingCountryForAPI);
            
            if(SearchAccount.AccountAddress != null){
                //if(String.isNotBlank(SearchAccount.SearchAccount.AccountAddress.CountryCode2) && !countryMap.containskey(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){ 
                if(String.isNotBlank(SearchAccount.AccountAddress.CountryCode2) && billingCountryForAPI==null){ 
                    throw new CustomException('INVALID_COUNTRYCODE');
                }
            }
            
            isProgramBased = String.isNotBlank(SearchAccount.BizOrgType) ? true : false;
            //Check only for entitlement also
            System.debug('isProgramBased-->'+isProgramBased);
            
            
            String partnerRole;
            if(isProgramBased){
                if(String.isNotBlank(SearchAccount.BizOrgType)){
                    PRM_PartnerRoleTypeMappings__mdt[] partnerRoleMapobj = [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c,PRM_Partner_Role_Label__c from PRM_PartnerRoleTypeMappings__mdt where PRM_Biz_Org_Type__c  =:SearchAccount.BizOrgType];
                    if(partnerRoleMapobj.size() > 0){
                        partnerRole = partnerRoleMapobj[0].PRM_Partner_Role_Label__c;
                    }else{
                        throw new CustomException('INVALID_BIZORGTYPE');  
                    }
                }
                system.debug('Country Code ==>'+SearchAccount.AccountAddress.CountryCode2);
                if(String.isNotBlank(SearchAccount.EmailAddress) && !PROCCountries.contains(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){                
                    //if(String.isNotBlank(EmailAddress)){
                    system.debug('Country Code inside if ==>'+SearchAccount.AccountAddress.CountryCode2);
                    if(PRM_searchSfdcAccounts.emailValidationCheck(SearchAccount.EmailAddress)){
                        if(PRM_searchSfdcAccounts.isBlacklistedEmailDomian(SearchAccount.EmailAddress)){
                            system.debug('isBlacklistedEmailDomian ==>false');
                            String emailDomain = SearchAccount.EmailAddress.substringAfter('@');
                            system.debug('emailDomain ==>'+emailDomain);
                            for(Contact con : (List<Contact>)[FIND :emailDomain IN EMAIL FIELDS RETURNING Contact(id,name,Accountid WHERE account.recordtype.id=:intelaccountRT)][0]){                                
                                setOfAccountId.add(con.accountId);
                            }
                        }else{
                            System.debug('Email domain is blacklisted : '+SearchAccount.EmailAddress);
                        }
                    }else{
                        throw new CustomException('INVALID_EMAIL');  
                    }                     
                }
                system.debug('Account Ids ==>'+setOfAccountId+' ;; SearchLimit ==>'+SearchAccount.SearchLimit);
                system.debug('partner role'+partnerRole);
            }

                        
            // Sorting the Accounts based on Priority Logic
          
            System.debug('isProgramBased-->'+isProgramBased);
            if(!isProgramBased)
            {
                ////////EntitleMent logic Buisness Type With E.Matrix Object/////
                if(String.isNotBlank(SearchAccount.EntitlementName))
                {
                    //List<string> ceAccountType=Label.CEAccountTypeMap.split(';');
                    List<PRM_VXEnttlmntMatrix__c> ceAccountType = [SELECT PRM_Entitlement_Id__r.Name, Business_Types__r.Name FROM PRM_VXEnttlmntMatrix__c Where PRM_Entitlement_Id__r.Name =: SearchAccount.EntitlementName];
                    System.debug('EntitlementName'+SearchAccount.EntitlementName);
                    System.debug('SOQL ceAccountType'+ceAccountType);
                    System.debug('SOQL ceAccountType'+ceAccountType[0].Business_Types__r.Name);
                    Map<string,string> ceAccountTypeMap= new  Map<string,string>();
                    if(ceAccountType.size()>0){
                        AccountType = ceAccountType[0].Business_Types__r.Name;
                    }
                    else
                    {
                        throw new CustomException('INVALID_BUSINESSTYPE');
                    }         
                    
                }
                
                 ////////end/////////
            }

            //UICIMCallout logic  
            if(String.isNotBlank(SearchAccount.SearchLimit))
            {
                
                if(String.IsNotBlank(SearchAccount.AccountAddress.AddressLine2))
                {
                    SearchAccount.AccountAddress.AddressLine1 = SearchAccount.AccountAddress.AddressLine1 +' '+ SearchAccount.AccountAddress.AddressLine2;
                }
                //listOfCimResult = prmUICimCallout.getCimResults(AccountName, SearchAccount.AccountAddress.AddressLine1, SearchAccount.AccountAddress.PostalCode,SearchAccount.AccountAddress.City,SearchAccount.AccountAddress.CountryCode2,SearchAccount.AccountAddress.StateCode2,SearchLimit,MinimumSearchScore,AccountURL,setOfAccountId,EmailAddress,partnerRole);                       
                //listOfCimResult = prmUICimCallout.getCimResults(SearchAccount.AccountName, SearchAccount.AccountAddress.AddressLine1, SearchAccount.AccountAddress.PostalCode,SearchAccount.AccountAddress.City,billingCountryForAPI,SearchAccount.AccountAddress.StateCode2,SearchAccount.SearchLimit,SearchAccount.MinimumSearchScore,SearchAccount.AccountURL,setOfAccountId,SearchAccount.EmailAddress,partnerRole);
                listOfCimResult = new PMR_ER_SearchCIMAccounts().getCimResults(SearchAccount.AccountName, SearchAccount.AccountAddress.AddressLine1, SearchAccount.AccountAddress.PostalCode,SearchAccount.AccountAddress.City,billingCountryForAPI,SearchAccount.AccountAddress.StateCode2,SearchAccount.SearchLimit,SearchAccount.MinimumSearchScore,SearchAccount.AccountURL,SearchAccount.EmailAddress,AccountType, true,setOfAccountId,partnerRole,isProgramBased);
                System.debug('listOfCimResult size : '+listOfCimResult.size());
            }
                if(String.isNotBlank(SearchAccount.EntitlementName))
                {
                    lst_EntSearchAccount = ER_SearchSalesCloudAccounts.getSortedAccountsCim(listOfCimResult,setOfAccountId,AccountType,SearchAccount.SearchLimit);
                    System.debug('If lst_PrgSearchAccount size : '+lst_EntSearchAccount.size());
                    System.debug('if lst_PrgSearchAccount if Entitilement is not Blank : '+lst_EntSearchAccount);
                    if(lst_EntSearchAccount != null)  // 
                    {
                    
                    //Formatting the Response from CIM 
                    cimAccountsList.addAll(getResponseJSON(lst_EntSearchAccount,countryMap));
                    System.debug('lst_EntSearchAccount if Entitilement is not Blank CIMList : '+cimAccountsList);
                    
                    }
                }
                else
                {
                    lst_PrgSearchAccount = PRM_searchSfdcAccounts.getSortedAccountsCim(listOfCimResult,setOfAccountId,partnerRole); 
                    System.debug('else lst_PrgSearchAccount size : '+lst_PrgSearchAccount.size());
                    System.debug('else lst_PrgSearchAccount if Entitilement Blank : '+lst_PrgSearchAccount); 
                    if(lst_PrgSearchAccount != null)
                    {
                        
                        cimAccountsList.addAll(getResponseJSON(lst_PrgSearchAccount,SearchAccount.SearchLimit,countryMap));
                        System.debug('lst_EntSearchAccount if BiZOrg is not Blank : '+cimAccountsList);
                        
                    }
                }
            res.statusCode = 200;
                    
            
            res.responseBody = Blob.valueOf(JSON.serialize(new SearchResults(cimAccountsList)));
            System.debug('CimList in if'+cimAccountsList);
             
           
        }catch(CustomException ce){
            res.statusCode = 400;
            SalesforceError[] errs = null;
            System.debug('error '+ce.getMessage());
            
            if(ce.getMessage()=='INVALID_COUNTRYCODE'){
                errs = new SalesforceError[]{new SalesforceError('0001', 'Invalid Country Code')};
                    res.responseBody = Blob.valueOf(JSON.serialize(errs));
            }            
            
            if(ce.getMessage()=='INVALID_BIZORGTYPE'){
                errs = new SalesforceError[]{new SalesforceError('0003', 'Invalid BizOrgType')};
                    res.responseBody = Blob.valueOf(JSON.serialize(errs));
            }            
            
            if(ce.getMessage()=='INVALID_EMAIL'){
                errs = new SalesforceError[]{new SalesforceError('0004', 'Invalid EmailAddress')};
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
    
    
    
    
    @TestVisible private static List<PartnerRoleInfo> mapToPartnerRoleInfo(List<PRM_AccountChannelMembership__c> ptnrRoleInfo){       
        List<PartnerRoleInfo> listOfPartnerRole = null; 
        if(ptnrRoleInfo != null){
            listOfPartnerRole = new List<PartnerRoleInfo>();
            for(PRM_AccountChannelMembership__c obj : ptnrRoleInfo){                
                PartnerRoleInfo roleInfo = new PartnerRoleInfo(obj.PRM_Partner_Role__c, obj.PRM_Channel_Program_Level_Id__r.name, obj.PRM_Status_Nm__c,obj.PRM_Status_Change_Dt__c);
                listOfPartnerRole.add(roleInfo);
            }
        }
        return listOfPartnerRole;
    }
    
    
    //FOR ER Response Formatting
   @TestVisible private static List<PRM_ER_CIMAccountSearchInfo> getResponseJSON(List<ER_SearchAccounts> lstSrcAccount, Map<String,String> countryMap){
        System.debug('getResponseJSON call for ER...');
       System.debug('er Search Acc...'+lstSrcAccount);
        List<PRM_ER_CIMAccountSearchInfo> cimAccountsList = new List<PRM_ER_CIMAccountSearchInfo>();
        for(ER_SearchAccounts prmSrcAcc : lstSrcAccount){
            System.debug('Inside ER Search...');
            Account account = prmSrcAcc.acc;
            Address addObj = new Address(account.BillingStreet, null, account.BillingCity, countryMap.get(account.BillingCountryCode),
                                         account.BillingStateCode, account.BillingPostalCode);
            PRM_ER_CIMAccountSearchInfo cimAccount = new PRM_ER_CIMAccountSearchInfo(account.Name,addObj,account.Id, prmSrcAcc.accCIMId);
            cimAccountsList.add(cimAccount);
            System.debug('Inside ER Search CIM AAccount:'+cimAccountsList);
        }  
        return cimAccountsList;
    }
    ///End ER/////////////////////
    //Response Formatting
   @TestVisible
    private static List<PRM_ER_CIMAccountSearchInfo> getResponseJSON(List<PRM_SearchAccounts> lstSrcAccount, String searchLimit,Map<String,String> countryMap){
        System.debug('getResponseJSON call PRM...');
        System.debug('PRM Search Acc...'+lstSrcAccount);
        PRM_searchSfdcAccounts.getIPABadgeMap();
        List<PRM_ER_CIMAccountSearchInfo> cimAccountsList = new List<PRM_ER_CIMAccountSearchInfo>();
        List<AccountLegalAgreement> legalAgreements = new List<AccountLegalAgreement>();
        Integer srchLmt = 0;
        Integer lmt = (String.isNotBlank(searchLimit) ? Integer.valueOf(searchLimit) : lstSrcAccount.size());
        for(PRM_SearchAccounts prmSrcAcc : lstSrcAccount){
            System.debug('Inside PRM SEARCH:');
            if(srchLmt < lmt){
                Account account = prmSrcAcc.acc;
                Address addObj = new Address(account.BillingStreet, null, account.BillingCity, countryMap.get(account.BillingCountryCode),
                                             account.BillingStateCode, account.BillingPostalCode);
                legalAgreements =getAccountLegalAgreements(account);
                RelatedACMRecords relatedACMObj = prmSrcAcc.relatedACM;
                PRM_ER_CIMAccountSearchInfo cimAccount = new PRM_ER_CIMAccountSearchInfo(account.Name,addObj,legalAgreements,mapToPartnerRoleInfo(relatedACMObj != null? relatedACMObj.listOfAcm:null), account.Id, prmSrcAcc.accCIMId,(relatedACMObj != null ? relatedACMObj.ipaBadge:null));
                cimAccountsList.add(cimAccount);
                System.debug('Inside PRM Search CIM AAccount:'+cimAccountsList);
                srchLmt++ ;        
            }
        }  
        return cimAccountsList;
    }
    
    //Method to return IPA Legal Agreement details 
    public static List<AccountLegalAgreement> getAccountLegalAgreements(Account acct){        
        List<AccountLegalAgreement> legalAgreements = new List<AccountLegalAgreement>();
        for(PRM_AccountLegalAgreemntAssociation__c agreement : acct.AccountLegalAgreementAssociations__r){
            System.debug('agreementInd'+agreement.PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c);
            if(agreement.PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name=='Intel Partner Alliance' && agreement.PRM_InActive_Ind__c==false){
                AccountLegalAgreement legalAgreement = new AccountLegalAgreement(agreement.PRM_Agreement_Sign_Dt__c);             
                legalAgreements.add(legalAgreement);  
            }
        }
        System.debug('Legal Agreements'+legalAgreements);
        return legalAgreements;
    }
    
    //Wrapper Class to Construct Legal Agreements Details 
    public class AccountLegalAgreement{   
        public DateTime AgreementSignedDate;
        public AccountLegalAgreement(DateTime inputAgreementSignedDate){
            AgreementSignedDate = inputAgreementSignedDate;           
        }
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
}