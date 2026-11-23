/*********************************************************************************************************************
Apex Class Name  : PRM_CIMAccountSearchNew
Version       : 2.0
Created Date  : May 2021
Function      : Rest API class to get exisitng Accounts from both SFDC and CIM

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
URL: /services/apexrest/Account/SearchAccount
Sample request : {
    "AccountName": "Tst ACM ACC",
    "AccountAddress": {"CountryCode2":"US"},
    "AccountURL": "www.aac.com",
    "BizOrgType": "null",
    "EmailAddress": "asdsdasd@dispostable.com",
    "SearchLimit": "20",
    "MinimumSearchScore": "10"
    }
Sample Response: {"SearchResults":[{"partnerRolesInfo":[{"Tier":"Member","statusChangeDt":"2022-06-06T05:15:47.000Z","status":"Approved","PartnerRole":"FPGA Design Services"},{"Tier":"Gold","statusChangeDt":null,"status":"Pending","PartnerRole":"Original Equipment Manufacturer (OEM)"},{"Tier":"Member","statusChangeDt":"2022-06-06T10:52:58.000Z","status":"Approved","PartnerRole":"Cloud & Comms Service Provider"},{"Tier":"Member","statusChangeDt":null,"status":"Pending","PartnerRole":"Manufacturer"}],"IPABadge":"Gold","CimID":null,"AccountName":"Intel Test Dec SBC","AccountLegalAgreements":[],"AccountID":"0018A00000o0djKQAQ","AccountAddress":{"StateCode2":"CA","PostalCode":"768765","CountryCode2":"US","City":"hiu","AddressLine2":null,"AddressLine1":"gyyu"}}]}

*********************************************************************************************************************/
@RestResource(urlMapping='/Account/SearchAccount')
global without sharing class PRM_CIMAccountSearchNew {
    public static Map<string, List<PRM_SearchAccountsNew.AccountLegalAgreement>> AccLegalAgreeMap = new Map<string, List<PRM_SearchAccountsNew.AccountLegalAgreement>>();
    public static List<PRM_SearchAccountsNew> AllAccounts = new List<PRM_SearchAccountsNew>();
    public static String billingCountryForAPI, CountryCodeinUC;
    public static String results;

    //public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh); // IPA Switch Removal

    @HttpPost
    global static void doPost(
        String AccountName,
        Address AccountAddress,
        String AccountURL,
        String BizOrgType,
        String EmailAddress,
        String SearchLimit,
        String MinimumSearchScore
       // string Website
    ) {
        performsearch(
            AccountName,
            JSON.serialize(AccountAddress),
            AccountURL,
            BizOrgType,
            EmailAddress,
            SearchLimit,
            MinimumSearchScore
           // Website
        );
    }
    @AuraEnabled
    public static String performsearch(
        String accountName,
        String accountAddress1,
        String accountURL,
        String bizOrgType,
        String emailAddress,
        String searchLimit,
        String minimumSearchScore
       // String Website
    ) {
        DateTime reqTime = System.now();
        Address AccountAddress = (Address) JSON.deserialize(
            accountAddress1,
            Address.class
        );
        String requestPayload =
            'AccountName:' +
            AccountName +
            ', AccountAddress:' +
            AccountAddress +
            ', AccountURL:' +
            AccountURL +
            ', BizOrgType:' +
            BizOrgType +
            ', EmailAddress:' +
            EmailAddress +
            ', SearchLimit:' +
            SearchLimit +
            ',MinimumSearchScore :' +
            MinimumSearchScore /*+
            ',Website :' +
            Website*/;
        RestResponse res = RestContext.response;
        Map<string, string> countryMap = new Map<string, string>();
        PRM_SBCSearchResults FinalSearchResult;
        set<string> AccountNameset = new Set<string>();
      //  PRM_CIMCalloutNEW prmUICimCallout = new PRM_CIMCalloutNEW();
        PRM_CIM_Request__mdt cimMdt;
        //set<id> recordTypeIds = new Set<id>();

        try {
           performSearch1(AccountAddress);
            //check if email address is not blank and country code is not part of PROC Countries
            //Commented below as step 1 search in config will be performed from getProfile API
           /* if (String.isNotBlank(EmailAddress)) {
                FinalsearchResult = performStep1Search(EmailAddress, res);
            } else */ if (String.isNotBlank(AccountURL) && String.isNotBlank(AccountName) && String.isNotBlank(CountryCodeinUC)) {
                FinalsearchResult = performStep2Search(AccountURL,AccountName,CountryCodeinUC,res,AccountNameset);
            } else {
                throw new CustomException('INVALID_EMAIL');
            }
            //defaulting seachlimit and minimunScore
            SearchLimit = string.isNotBlank(SearchLimit)
                ? SearchLimit
                : string.valueof(cimMdt.PRM_Max_Records__c);
            /*integer MinimumSearchScoreInt = string.isNotBlank(
                    MinimumSearchScore
                )
                ? integer.valueof(MinimumSearchScore)
                : integer.valueof(cimMdt.PRM_Min_Score__c);
            integer SearchLimitIntger = string.isnotblank(SearchLimit)
                ? integer.valueof(SearchLimit)
                : 0;
				*/
            // Concatenate the Address lines
            AccountAddress.AddressLine1 = String.IsNotBlank(
                    AccountAddress.AddressLine2
                )
                ? AccountAddress.AddressLine1 +
                  ' ' +
                  AccountAddress.AddressLine2
                : AccountAddress.AddressLine1;
            AccountAddress.Countrycode2 = billingCountryForAPI;

            //serialize Response with final Account list and Send to AEM
            if (FinalsearchResult != null) {
                results = JSON.serialize(FinalsearchResult);
                if(res != null){
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf(results);
                }
            }
        } catch (CustomException ce) {
            customSearchErrors(ce,res);
           
        } catch (System.QueryException e) {
            SalesforceError[] errs = new List<SalesforceError>{
                new SalesforceError('Query Exception ', e.getMessage())
            };
            if (res != null) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(errs));
            }
            results = JSON.serialize(errs);
        } catch (Exception e) {
            string ErrorinSort;
            SalesforceError[] errs = new List<SalesforceError>{
                new SalesforceError(
                    'BAD_REQUEST',
                    e.getMessage() +
                    '--sortingError' +
                    ErrorinSort
                )
            };
            if (res != null) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(errs));
            }

            results = JSON.serialize(errs);
        } finally {
            //  Calling the utility method to create Integration log record
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility = new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength = Schema.SObjectType.PRM_Integration_Log__c.fields.PRM_Response_Payload__c.getLength();
            if (res != null) {
                logEntryUtility.addLogEntry(
                    res.responseBody.toString(),
                    fieldLength
                );
                for (Integer i = 0; i < logEntryUtility.logEntryList.size(); i++) {
                    PRM_IPA_Utility.createIntegrationLog(
                        EmailAddress,
                        PRM_IPA_Constants.CALLOUT_TYPE_INBOUND,
                        PRM_IPA_Constants.MODULE_SELF_REGISTRATION,
                        requestPayload,
                        logEntryUtility.logEntryList[i],
                        res.statusCode,
                        PRM_IPA_Constants.SYSTEM_NAME_AEM,
                        'PRM_CIMAccountSearch',
                        reqTime,
                        System.now()
                        
                    );
                }
            }
        }
        return results;
    }
//congnitive complexity:

public static void performSearch1(Address AccountAddress){
    Map<string, string> countryMap = new Map<string, string>();
  //  Address AccountAddress = (Address) JSON.deserialize( accountAddress1, Address.class);
    set<string> AccountNameset = new Set<string>();
    //get Intel Acount Record Type Id
    Id INTEL_ACCOUNT_RT = Schema.getGlobalDescribe()
    .get('Account')
    .getDescribe()
    .getRecordTypeInfosByDeveloperName()
    .get(System.Label.PRM_Intel_Account)
    .getRecordTypeId();

//collect System Account Name from metadata
for (Core_Intel_System_Accounts__mdt mdt : Core_Intel_System_Accounts__mdt.getall().values()) {
    AccountNameset.add(mdt.Account_Name__c);
}
//Fetch custom metadata which stores the  Cim score / SearchLimit and CIM Request info
//cimMdt = PRM_CIM_Request__mdt.getinstance('PRM_Dupe_Scores');

//Collect 3 & 2 digit countrycode in the map from Custom Setting
for (Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
   // countryMap.put(allCountries.ISO_Code__c, allCountries.Name);
   // countryMap.put(allCountries.Country_Code__c, allCountries.Name);
    countryMap.put(allCountries.Country_Code__c, allCountries.ISO_Code__c);
}
//Check if country code is 3 digit then get 2 digit code from map to send it to CIM
if (string.isNotBlank(AccountAddress.CountryCode2)) {
    CountryCodeinUC = AccountAddress.CountryCode2.toUpperCase();
    billingCountryForAPI = countryMap.containskey(CountryCodeinUC)
        ? countryMap.get(CountryCodeinUC)
        : null;
    if (String.isBlank(billingCountryForAPI))
        throw new CustomException('INVALID_COUNTRYCODE');
}
}

public static void customSearchErrors(CustomException ce,RestResponse res){
    SalesforceError[] errs = null;
    if (ce.getMessage() == 'INVALID_COUNTRYCODE') {
        errs = new List<SalesforceError>{
            new SalesforceError('0001', 'Invalid Country Code')
        };
    }

    if (ce.getMessage() == 'INVALID_BIZORGTYPE') {
        errs = new List<SalesforceError>{
            new SalesforceError('0003', 'Invalid BizOrgType')
        };
    }

    if (ce.getMessage() == 'INVALID_EMAIL') {
        errs = new List<SalesforceError>{
            new SalesforceError('0004', 'Invalid EmailAddress')
        };
    }
    if (!errs.isEmpty() && res != null) {
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(errs));
    }
}

    //ATHR Fix - TWC729-9556
/*public static void createLogEntries(RestResponse res){
   
}*/
    public static PRM_SBCSearchResults performStep1Search(String EmailAddress/*,RestResponse res*/) {
       // Set<Id> setOfAccountId = new Set<Id>();
       list<Id> listOfAccountId=new list<Id>();
        PRM_SBCSearchResults FinalSearchResult;
        if (PRM_searchSfdcAccounts.emailValidationCheck(EmailAddress)) {
            //check if emaildomain is Not in Black list & then fetch existing accounts based on email domain
            if (PRM_searchSfdcAccounts.isBlacklistedEmailDomian(EmailAddress)) {
                String emailDomain = EmailAddress.substringAfter('@');
                //Query to get Accounts from SFDC based on email domain
                for (PRM_SBC_Account_Search_Configuration__c config : [
                    SELECT ID, Account__c/*, Account__r.BillingCountryCode*/ //ATHR Fix - TWC729-9556
                    FROM PRM_SBC_Account_Search_Configuration__c
                    WHERE
                        Email_Domain__c = :emailDomain
                        AND Country__c = :billingCountryForAPI LIMIT 10 
                ]) {
                    if(!listOfAccountId.contains(config.Account__c))
                        listOfAccountId.add(config.Account__c);
                   // setOfAccountId.add(config.Account__c);
                }
            }

            if (!listOfAccountId.isEmpty()) {
                FinalsearchResult = getRecordsforSorting(listOfAccountId, null);
              /*  if (FinalsearchResult != null) {
                    String finalresult = JSON.serialize(FinalsearchResult);
                    if(res != null){
                        res.statusCode = 200;
                        res.responseBody = Blob.valueOf(finalresult);
                    }
                    results = finalresult;
                } else {
                    SalesforceError[] errs = new List<SalesforceError>{
                        new SalesforceError(
                            'BAD_REQUEST',
                            'No Matching Records Found.'
                        )
                    };
                    if(res != null){
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf(JSON.serialize(errs));
                    }
                    
                    results = JSON.serialize(errs);
                }
            }else {
                SalesforceError[] errs = new List<SalesforceError>{
                    new SalesforceError(
                        'BAD_REQUEST',
                        'No Matching Records Found.'
                    )
                };
                if(res != null){
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.serialize(errs));
                }
                
                results = JSON.serialize(errs); */
            }
        } 
            
        return FinalsearchResult;
    }

    public static PRM_SBCSearchResults performStep2Search(String AccountURL, String AccountName, String CountryCodeinUC, RestResponse res,set<string> AccountNameset) {
        Set<Id> setOfAccountId = new Set<Id>();
        list<PRM_AccountChannelMembership__c> listOfACM = new list<PRM_AccountChannelMembership__c>();
        list<PRM_AccountChannelMembership__c> listOfACMDiffCountry = new list<PRM_AccountChannelMembership__c>();
        PRM_SBCSearchResults FinalSearchResult;
        List<String> strList = new List<String>(label.PRM_List_SBC_Domains.split(';'));
       AccountName=AccountName.trim();
       AccountURL=AccountURL.trim();
       
        for (String str : strList) {
            AccountURL = AccountURL.remove(str);
        }
        String searchString = '%' + AccountURL + '%';
        //added by LATA
        for (PRM_AccountChannelMembership__c acm : [
            SELECT
                PRM_Account_Id__c,
                PRM_Account_Id__r.BillingAddress,
                PRM_Account_Id__r.BillingStreet,
                PRM_Account_Id__r.BillingCountryCode,
                PRM_Account_Id__r.BillingCity,
                PRM_Account_Id__r.BillingState,
                PRM_Account_Id__r.BillingCountry,
                PRM_Account_Id__r.BillingPostalCode,
                Name,
                PRM_Account_Id__r.Name,
                PRM_Account_Id__r.ShippingAddress,
                /*PRM_Account_Id__r.Core_Account_Legal_Name__c,//TWC729-7726 : Cim Prime EOL*/
                PRM_Account_Id__r.Core_CIM_ID__c,
                PRM_Account_Id__r.Core_Business_Party_Id__c,//TWC729-7726 : Cim Prime EOL
                PRM_Channel_Program_Id__r.name,
                toLabel(PRM_Partner_Role__c),
                PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,
                PRM_Account_Id__r.Core_Covered_Account__c,
                PRM_Channel_Program_Level_Id__r.name,
                PRM_Status_Nm__c,
                PRM_Status_Change_Dt__c,
                PRM_Account_Id__r.Core_User_Defined_Website__c
            FROM PRM_AccountChannelMembership__c
            WHERE
                PRM_Status_Nm__c='Approved'
                AND PRM_Account_Id__r.Core_deactivated__c = FALSE 
                AND PRM_Account_Id__r.Core_Export_Compliance_Block__c = FALSE
            	AND PRM_Account_Id__r.Name not in: AccountNameset
                AND (PRM_Account_Id__r.Core_User_Defined_Website__c LIKE :searchString
                OR PRM_Account_Id__r.website LIKE :searchString)
                AND PRM_Account_Id__r.Name LIKE :AccountName + '%'
            ORDER BY PRM_Account_Id__r.Name asc, PRM_Channel_Program_Level_Id__r.Rank desc,PRM_Account_Id__r.Core_Covered_Account__c desc LIMIT 50
                
        ]) {
            if(setOfAccountId.size() < 10){
                if(acm.PRM_Account_Id__r.BillingCountry == billingCountryForAPI){
                listofACM.add(acm);	 
			    setOfAccountId.add(acm.PRM_Account_Id__c);
                }
               else{
			listOfACMDiffCountry.add(acm);	
			}
            }else{
                break;
            }
        }
        if(setOfAccountId.size() < 10){
            for(PRM_AccountChannelMembership__c acmRec :listOfACMDiffCountry)
            {
               listofACM.add(acmRec);
               setOfAccountId.add(acmRec.PRM_Account_Id__c);
            }
        }
        if (!listOfACM.isEmpty()) {
            FinalsearchResult = getRecordsforSorting(null, listOfACM);
            if (FinalsearchResult != null) {
                String finalresult = JSON.serialize(FinalsearchResult);
                if(res != null){
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf(finalresult);
                }
                results = finalresult;
            }else {
                salesforceErrors(res);
            }
        } else {
            salesforceErrors(res);
        }
        return FinalsearchResult;

    }

 //cognitive complexity:
 public static void salesforceErrors(RestResponse res){
    SalesforceError[] errs = new List<SalesforceError>{
        new SalesforceError(
            'BAD_REQUEST',
            'No Matching Records Found.'
        )
    };
    if(res != null){
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(errs));
    }
    
    results = JSON.serialize(errs);
}

    public static PRM_SBCSearchResults getRecordsforSorting(
        list<id> sfdcAccountId,
        list<PRM_AccountChannelMembership__c> listOfACM
    ) {
        //get the Badge and its Rank from Metadata
       // Map<String, Integer> ipaBadgeMap = getIPABadgeMap();
        //list<id> AccountId = sfdcAccountId;
        PRM_SBCSearchResults seachresult;
        //list<PRM_SearchAccountsNew> searcAcc = new List<PRM_SearchAccountsNew>();
       // map<string, PRM_SearchAccountsNew> AllAccountsMAP = new Map<string, PRM_SearchAccountsNew>();
    
        //Fetch ACMs associated to the Accounts
        if (sfdcAccountId != null) {
        listOfACM = fetchACMAssociatedToAccs(sfdcAccountId );}
        if(!listOfACM.isEmpty()){
        AllAccounts =  getRecordsForSortingMethod1(listOfACM,sfdcAccountId);}
               //Create final wrapper list
        if (AllAccounts.size() > 0)
            seachresult = prepareFinalList(AllAccounts);
        return seachresult;
    }

    public static map<string, List<PRM_SearchAccountsNew.AccountLegalAgreement>> getAccountLegalAgreements(
        list<id> acctid
    ) {
        map<string, List<PRM_SearchAccountsNew.AccountLegalAgreement>> Legalagreementmap = new Map<string, List<PRM_SearchAccountsNew.AccountLegalAgreement>>();
        List<PRM_AccountLegalAgreemntAssociation__c> AccLegalAgrmt = new List<PRM_AccountLegalAgreemntAssociation__c>(); 
    // IPA Refresh 2.0 - TWC729-7874-start
        AccLegalAgrmt = [
            SELECT
                Name,
                PRM_Account_Id__c,
                PRM_Agreement_Sign_Dt__c,
                PRM_InActive_Ind__c,
                PRM_Signed_By_Email__c,
                PRM_Signed_By_Name__c,
                PRM_Partner_Agreement_Id__r.Name,
                PRM_Partner_Agreement_Id__r.PRM_InActive_Ind__c,
                PRM_Partner_Agreement_Id__r.PRM_Agreement_Category_Nm__c,
                PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c,
                PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name
            FROM PRM_AccountLegalAgreemntAssociation__c
            WHERE PRM_Account_Id__c IN :acctid];
        // IPA Refresh 2.0 - TWC729-7874-end
        for (PRM_AccountLegalAgreemntAssociation__c agreement : AccLegalAgrmt) {
            if (
                agreement.PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name ==
                'Intel Partner Alliance' &&
                agreement.PRM_InActive_Ind__c == false
            ) {
                if (
                    Legalagreementmap.containskey(agreement.PRM_Account_Id__c)
                ) {
                    list<PRM_SearchAccountsNew.AccountLegalAgreement> legalAgreelist = Legalagreementmap.get(
                        agreement.PRM_Account_Id__c
                    );
                    PRM_SearchAccountsNew.AccountLegalAgreement legalAgreement = new PRM_SearchAccountsNew.AccountLegalAgreement(
                        agreement.PRM_Agreement_Sign_Dt__c
                    );
                    legalAgreelist.add(legalAgreement);
                } else {
                    list<PRM_SearchAccountsNew.AccountLegalAgreement> legalAgreelist = new List<PRM_SearchAccountsNew.AccountLegalAgreement>();
                    PRM_SearchAccountsNew.AccountLegalAgreement legalAgreement = new PRM_SearchAccountsNew.AccountLegalAgreement(
                        agreement.PRM_Agreement_Sign_Dt__c
                    );
                    legalAgreelist.add(legalAgreement);
                    Legalagreementmap.put(
                        agreement.PRM_Account_Id__c,
                        legalAgreelist
                    );
                }
            }
        }
        return Legalagreementmap;
    }

    public static PRM_SBCSearchResults prepareFinalList(
        list<PRM_SearchAccountsNew> sortedaccounts
    ) {
        list<PRM_SBCSearchResults.SearchResults> searchresList = new List<PRM_SBCSearchResults.SearchResults>();
        integer count = 0;
        //get 2 digit country code
        Map<string, string> countryMap = new Map<string, string>();
        for (
            Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll()
                .values()
        ) {
            countryMap.put(
                allCountries.ISO_Code__c,
                allCountries.Country_Code__c
            );
        }
        for (PRM_SearchAccountsNew sa : sortedaccounts) {
            string country2code;
            country2code = countryMap.containskey(sa.acc.BillingCountryCode)
                ? countryMap.get(sa.acc.BillingCountryCode)
                : sa.acc.BillingCountryCode;
            Address adobj = new Address(
                sa.acc.Billingstreet,
                null,
                sa.acc.BillingCity,
                country2code,
                sa.acc.BillingState,
                sa.acc.BillingPostalCode
            );
            List<PRM_SearchAccountsNew.AccountLegalAgreement> legalList = new List<PRM_SearchAccountsNew.AccountLegalAgreement>();
            if (AccLegalAgreeMap.containskey(sa.acc.id)) {
                legalList = AccLegalAgreeMap.get(sa.acc.id);
            }
            PRM_SBCSearchResults.SearchResults searchaccres = new PRM_SBCSearchResults.SearchResults(
                sa.acc.Name,
                adobj,
                legalList,
                sa.partnerrolesinfo,
                string.valueof(sa.AccountId),
                sa.acc.Core_CIM_ID__c,
                sa.acc.Core_Business_Party_Id__c,//TWC729-7726 : Cim Prime EOL
                sa.ipabadge,
                sa.acc.Core_User_Defined_Website__c
            );
            searchresList.add(searchaccres);
            count++;
            //get out of loop Once reached max records
            if (count == 10)
                break;
        }
        PRM_SBCSearchResults sbcsearchresult = new PRM_SBCSearchResults();
        sbcsearchresult.SearchResults = searchresList;
        return sbcsearchresult;
    }

   //cognitive
public static List<PRM_SearchAccountsNew> getRecordsForSortingMethod1(list<PRM_AccountChannelMembership__c> listOfACM,list<id> sfdcAccountId){
    map<string, PRM_SearchAccountsNew> AllAccountsMAP = new Map<string, PRM_SearchAccountsNew>();
    Map<String, Integer> ipaBadgeMap = getIPABadgeMap();
    if(!listOfACM.isEmpty()){
        for(PRM_AccountChannelMembership__c acm : listOfACM){
            if(sfdcAccountId == null){
                sfdcAccountId = new List<Id>{acm.PRM_Account_Id__c};
            }else if (sfdcAccountId != null && !sfdcAccountId.contains(acm.PRM_Account_Id__c)){
                sfdcAccountId.add(acm.PRM_Account_Id__c);
            }

            if (
                acm.PRM_Channel_Program_Id__r.name ==
                System.Label.PRM_Intel_Partner_Alliance
            ) {
                if (AllAccountsMAP.containskey(acm.PRM_Account_Id__c)) {
                    PRM_SearchAccountsNew accWrap = AllAccountsMAP.get(
                        string.valueof(acm.PRM_Account_Id__c)
                    );
                    accWrap.partnerrolesinfo.add(createPartnerRolInfo(acm));
                    if (
                        string.IsNotBlank(
                            acm.PRM_Channel_Program_Level_Id__r.name
                        ) &&
                        ipaBadgeMap.get(
                            acm.PRM_Channel_Program_Level_Id__r.name
                        ) < ipaBadgeMap.get(accWrap.ipabadge)
                    )
                        accWrap.ipabadge = acm.PRM_Channel_Program_Level_Id__r.name;
                } else {
                   

                    createWrapperInstance(acm,AllAccountsMAP);
                }
            }
        }
    }

    AccLegalAgreeMap = getAccountLegalAgreements(sfdcAccountId);
    //Create instance of PRM_SearchAccountsNew  for the Accounts without ACM
  //  AllAccountsMAP.putall(AddAccountsWOACM(AccountId));
    if (AllAccountsMAP.size() > 0) {
        AllAccounts = AllAccountsMAP.values();
    }
    return AllAccounts;
}

public static void createWrapperInstance(PRM_AccountChannelMembership__c acm,map<string, PRM_SearchAccountsNew> AllAccountsMAP){
     //get score value of each Account
     integer scoreval = 1; //getScore (acm.PRM_Account_Id__c,acm.PRM_Account_Id__r.Core_CIM_ID__c);
     //get IPAcheck Rank
     integer ipacheckrank = ipaCheck(
         acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,
         acm.PRM_Account_Id__r.Core_Covered_Account__c
     );
     //Remove ACoount Ids with ACM to get hold of Account Ids without ACM
     //  AccountId.remove(acm.PRM_Account_Id__c);
          //create wrapper instance
          list<PRM_SearchAccountsNew.PartnerRoleInfo> roleInfo = new List<PRM_SearchAccountsNew.PartnerRoleInfo>();
          roleInfo.add(
              new PRM_SearchAccountsNew.PartnerRoleInfo(
                  acm.PRM_Partner_Role__c,
                  acm.PRM_Channel_Program_Level_Id__r.name,
                  acm.PRM_Status_Nm__c,
                  acm.PRM_Status_Change_Dt__c
              )
          );
          PRM_SearchAccountsNew AccountWACM = new PRM_SearchAccountsNew(
              acm.PRM_Account_Id__c,
              acm.PRM_Account_Id__r.Core_CIM_ID__c,
              acm.PRM_Account_Id__r.Core_Business_Party_Id__c,//TWC729-7726 : Cim Prime EOL
              acm.PRM_Account_Id__r,
              scoreval,
              acm.PRM_Channel_Program_Level_Id__r.name,
              0,
              ipacheckrank,
              roleInfo
          );
          AllAccountsMAP.put(
              string.valueof(acm.PRM_Account_Id__c),
              AccountWACM
          );
}
//cognitive complexity:
public static list<PRM_AccountChannelMembership__c> fetchACMAssociatedToAccs( list<id> sfdcAccountId ){
    list<PRM_AccountChannelMembership__c> listOfACM =new list<PRM_AccountChannelMembership__c> (); 
    if (sfdcAccountId != null) {
       listOfACM = [
            SELECT
                PRM_Account_Id__c,
                PRM_Account_Id__r.BillingAddress,
                PRM_Account_Id__r.BillingStreet,
                PRM_Account_Id__r.BillingCountryCode,
                PRM_Account_Id__r.BillingCity,
                PRM_Account_Id__r.BillingState,
                PRM_Account_Id__r.BillingCountry,
                PRM_Account_Id__r.BillingPostalCode,
                Name,
                PRM_Account_Id__r.Name,
                PRM_Account_Id__r.ShippingAddress,
                /*PRM_Account_Id__r.Core_Account_Legal_Name__c,//TWC729-7726 : Cim Prime EOL*/
                PRM_Account_Id__r.Core_CIM_ID__c,
                PRM_Account_Id__r.Core_Business_Party_Id__c,//TWC729-7726 : Cim Prime EOL
                PRM_Channel_Program_Id__r.name,
                toLabel(PRM_Partner_Role__c),
                PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,
                PRM_Account_Id__r.Core_Covered_Account__c,
                PRM_Channel_Program_Level_Id__r.name,
                PRM_Status_Nm__c,
                PRM_Status_Change_Dt__c,
                PRM_Account_Id__r.Core_User_Defined_Website__c
            FROM PRM_AccountChannelMembership__c
            WHERE
                PRM_Account_Id__c IN :sfdcAccountId
                AND PRM_Status_Nm__c != 'Inactive' order by PRM_Account_Id__r.Name asc , PRM_Account_Id__r.Core_Covered_Account__c desc
        ];
    }
    return listOfACM;
}

 /* public static Map<String, PRM_SearchAccountsNew> AddAccountsWOACM(
        set<id> sfdcId
    ) {
        Map<String, PRM_SearchAccountsNew> accmap = new Map<String, PRM_SearchAccountsNew>();

        for (Account acc : [
            SELECT
                id,
                Name,
                Core_Intel_Partner_Alliance_PartnerGroup__c,
                Core_CIM_ID__c,
                BillingAddress,
                BillingStreet,
                BillingCity,
                BillingState,
                BillingCountry,
                BillingPostalcode,
                Core_Covered_Account__c,
                BillingCountryCode,
                Core_User_Defined_Website__c
            FROM Account
            WHERE id IN :sfdcId 
        ]) {
            //get the score
            integer scoreval = 1; //getScore (acc.Id,acc.Core_CIM_ID__c);
            //get IPAcheck Rank
            integer ipacheckrank = ipaCheck(
                acc.Core_Intel_Partner_Alliance_PartnerGroup__c,
                acc.Core_Covered_Account__c
            );

            PRM_SearchAccountsNew accWrap = new PRM_SearchAccountsNew(
                acc.Id,
                acc.Core_CIM_ID__c,
                acc,
                scoreval,
                null,
                0,
                ipacheckrank,
                null,
                 acc.Core_User_Defined_Website__c
            );
            accmap.put(string.valueof(acc.Id), accWrap);
        }
        return accmap;
    }*/
    
    public static Map<String, Integer> getIPABadgeMap() {
        Map<String, Integer> mapOfIPABadge = new Map<String, Integer>();
        for(String bageMapping :LabelConfiguration__mdt.getInstance('ChannelProgramLevelRanking').Value__c.split(';')){ 
            List<String> progTier = bageMapping.split(':');
            mapOfIPABadge.put(progTier[0],Integer.valueOf(progTier[1]));        
        }
        return mapOfIPABadge;
    }

    public static PRM_SearchAccountsNew.PartnerRoleInfo createPartnerRolInfo(
        PRM_AccountChannelMembership__c acm
    ) {
        PRM_SearchAccountsNew.PartnerRoleInfo roleInfo;
        if (acm != null)
            roleInfo = new PRM_SearchAccountsNew.PartnerRoleInfo(
                acm.PRM_Partner_Role__c,
                acm.PRM_Channel_Program_Level_Id__r.name,
                acm.PRM_Status_Nm__c,
                acm.PRM_Status_Change_Dt__c
            );
        return roleInfo;
    }
    public static integer ipaCheck(boolean ipa, boolean coverflag) {
        integer retval;
        if (ipa) {
            if (coverflag) {
                retval = 1;
            } else {
                retval = 2;
            }
        } else {
            if (coverflag) {
                retval = 3;
            } else {
                retval = 4;
            }
        }
        return retval;
    }
    //Wrapper for standard salesforce error response structure
    public class SalesforceError {
        public String errorCode;
        public String message;
        public SalesforceError(String errorCode, string message) {
            this.errorCode = errorCode;
            this.message = message;
        }
    }

    public class CustomException extends Exception {
    }
}