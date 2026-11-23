/**************************************************************************************************************
Apex Class Name:  PRM_CIMAccountSearch
Version     : 1.0 
Created Date: 28 Jan 2020
Function    : Custom REST service for Account Search from CIM based on details provided by Admin
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Prasant Sahu         01/28/2020        Initial version
* Prasant Sahu         03/04/2020        Updated with Exception handling    
***************************************************************************************************************/
@RestResource(urlMapping='/Account/OldSearchAccount')
global without sharing class POC_CIMAccountSearch { 
    
     /*global class SearchResults{
        List<CIMAccountSearchInfo> SearchResults = new List<CIMAccountSearchInfo>();
        SearchResults(List<CIMAccountSearchInfo> listOfAccountSearch){
            if(listOfAccountSearch != null){
                SearchResults = listOfAccountSearch;
            }
        }
    }
    
    @HttpPost
    global static void doPost(String AccountName,Address AccountAddress, String AccountURL, String BizOrgType, String EmailAddress, String SearchLimit, String MinimumSearchScore) {        
        DateTime reqTime = System.now();
        RestResponse res = RestContext.response; 

        String requestPayload = 'AccountName:'+AccountName+', AccountAddress:'+AccountAddress+', AccountURL:'+AccountURL+', BizOrgType:'+BizOrgType+', EmailAddress:'+EmailAddress+', SearchLimit:'+SearchLimit+',MinimumSearchScore :'+MinimumSearchScore;
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        try{
            List<PRM_SearchAccounts> lstSearchAccountObj = new List<PRM_SearchAccounts>();
            List<PRM_CIMSearchResults__c> listOfCimResult = null;
            List<String> PROCCountries = Label.PRM_PROC_Countries.toUpperCase().split(',');
            Set<Id> setOfAccountId = new Set<Id>();
            system.debug('Country Code PROCCountries ==>'+PROCCountries);
            
            Map<string,string> countryMap = new map<string,string>();
                for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                    //countryMap.put(allCountries.Country_Code__c, allCountries.ISO_Code__c);
                    countryMap.put(allCountries.ISO_Code__c,allCountries.Country_Code__c);
                    //system.debug('allCountries.ISO_Code__c --> '+allCountries.ISO_Code__c);
                }
            System.debug('Country Map : '+countryMap);
            string billingCountryForAPI;
            if(AccountAddress.CountryCode2!=null && AccountAddress.CountryCode2.toUpperCase().length() == 3 && countryMap!=null && countryMap.containsKey(AccountAddress.CountryCode2.toUpperCase())){
                billingCountryForAPI = countryMap.get(AccountAddress.CountryCode2);
            }else{
                if(String.isNotBlank(AccountAddress.CountryCode2) && AccountAddress.CountryCode2.toUpperCase().length() == 2 && countryMap!=null && countryMap.values().contains(AccountAddress.CountryCode2.toUpperCase())){
                  billingCountryForAPI= AccountAddress.CountryCode2;
                }
            }
            System.debug('billingCountryForAPI --> '+billingCountryForAPI);
            
            if(AccountAddress != null){
                //if(String.isNotBlank(AccountAddress.CountryCode2) && !countryMap.containskey(AccountAddress.CountryCode2.toUpperCase())){ 
                if(String.isNotBlank(AccountAddress.CountryCode2) && billingCountryForAPI==null){ 
                    throw new CustomException('INVALID_COUNTRYCODE');
                }
            }
            
            String partnerRole;
            if(String.isNotBlank(BizOrgType)){
                PRM_PartnerRoleTypeMappings__mdt[] partnerRoleMapobj = [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c,PRM_Partner_Role_Label__c from PRM_PartnerRoleTypeMappings__mdt where PRM_Biz_Org_Type__c  =:BizOrgType];
                if(partnerRoleMapobj.size() > 0){
                    partnerRole = partnerRoleMapobj[0].PRM_Partner_Role_Label__c;
                }else{
                    throw new CustomException('INVALID_BIZORGTYPE');  
                }
            }
            system.debug('Country Code ==>'+AccountAddress.CountryCode2);
            if(String.isNotBlank(EmailAddress) && !PROCCountries.contains(AccountAddress.CountryCode2.toUpperCase())){                
            //if(String.isNotBlank(EmailAddress)){
                    system.debug('Country Code inside if ==>'+AccountAddress.CountryCode2);
                    if(PRM_searchSfdcAccounts.emailValidationCheck(EmailAddress)){
                        if(PRM_searchSfdcAccounts.isBlacklistedEmailDomian(EmailAddress)){
                            system.debug('isBlacklistedEmailDomian ==>false');
                            String emailDomain = EmailAddress.substringAfter('@');
                            system.debug('emailDomain ==>'+emailDomain);
                            for(Contact con : (List<Contact>)[FIND :emailDomain IN EMAIL FIELDS RETURNING Contact(id,name,Accountid WHERE account.recordtype.id=:intelaccountRT)][0]){
                                setOfAccountId.add(con.accountId);
                            }
                        }else{
                            System.debug('Email domain is blacklisted : '+EmailAddress);
                        }
                    }else{
                        throw new CustomException('INVALID_EMAIL');  
                    }                     
                }
                system.debug('Account Ids ==>'+setOfAccountId+' ;; SearchLimit ==>'+SearchLimit);
                system.debug('partner role'+partnerRole);
                //UICIMCallout logic
                if(String.isNotBlank(SearchLimit)){
                    if(setOfAccountId.size() < Integer.valueOf(SearchLimit)){
                        PRM_UICIMCallout prmUICimCallout = new PRM_UICIMCallout();
                        if(String.IsNotBlank(AccountAddress.AddressLine2)){
                            AccountAddress.AddressLine1 = AccountAddress.AddressLine1 +' '+ AccountAddress.AddressLine2;
                        }
                        //listOfCimResult = prmUICimCallout.getCimResults(AccountName, AccountAddress.AddressLine1, AccountAddress.PostalCode,AccountAddress.City,AccountAddress.CountryCode2,AccountAddress.StateCode2,SearchLimit,MinimumSearchScore,AccountURL,setOfAccountId,EmailAddress,partnerRole);
                        PRM_UICIMCallout.getCimResultsWrapper obj_1=new PRM_UICIMCallout.getCimResultsWrapper();
                        obj_1.accName=AccountName;
                        obj_1.accAddr=AccountAddress.AddressLine1;
                        obj_1.accPostalCode= AccountAddress.PostalCode;
                        obj_1.accCity=AccountAddress.City;
                        obj_1.accCountry=billingCountryForAPI;
                        obj_1.accStateProvince=AccountAddress.StateCode2;
                        obj_1.rcdLimit=SearchLimit;
                        obj_1.searchScore=MinimumSearchScore;
                        obj_1.companyWebsite=AccountURL;
                        obj_1.accountsSfdc=setOfAccountId;
                        obj_1.regEmail=EmailAddress;
                        obj_1.partnerRole=partnerRole;
                        listOfCimResult = prmUICimCallout.getCimResults(obj_1);//Athr fixes
                        //listOfCimResult = prmUICimCallout.getCimResults(AccountName, AccountAddress.AddressLine1, AccountAddress.PostalCode,AccountAddress.City,billingCountryForAPI,AccountAddress.StateCode2,SearchLimit,MinimumSearchScore,AccountURL,setOfAccountId,EmailAddress,partnerRole);
                    }
                }
            
                lstSearchAccountObj = PRM_searchSfdcAccounts.getSortedAccountsCim(listOfCimResult,setOfAccountId,partnerRole);                
                List<CIMAccountSearchInfo> cimAccountsList = new List<CIMAccountSearchInfo>();
                if(lstSearchAccountObj != null){
                    cimAccountsList.addAll(getResponseJSON(lstSearchAccountObj,SearchLimit,countryMap));
                }
            
            
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(new SearchResults(cimAccountsList)));               

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
        finally{
           //  Calling the utility method to create Integration log record
            PRM_IPA_Utility.create8LogWrapper obj_1=new PRM_IPA_Utility.create8LogWrapper();
            obj_1.recordId=null;
            obj_1.callType=PRM_IPA_Constants.CALLOUT_TYPE_INBOUND;
            obj_1.module=PRM_IPA_Constants.MODULE_SELF_REGISTRATION;
            obj_1.reqPayload=requestPayload; 
            obj_1.respPayload=res.responseBody.toString();
            obj_1.respCode=res.statusCode;
            obj_1.systemName=PRM_IPA_Constants.SYSTEM_NAME_AEM;
            obj_1.className='PRM_CIMAccountSearch';
            obj_1.reqTime=reqTime;
            obj_1.resTime=System.now();
            PRM_IPA_Utility.createIntegrationLog(obj_1);//Athr fixes
            //PRM_IPA_Utility.createIntegrationLog(null,PRM_IPA_Constants.CALLOUT_TYPE_INBOUND,PRM_IPA_Constants.MODULE_SELF_REGISTRATION,requestPayload,res.responseBody.toString(),res.statusCode,PRM_IPA_Constants.SYSTEM_NAME_AEM,'PRM_CIMAccountSearch', reqTime,System.now(), true);             
                     

        }
    }
    
    
    
    
    private static List<PartnerRoleInfo> mapToPartnerRoleInfo(List<PRM_AccountChannelMembership__c> ptnrRoleInfo){       
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
    
     public static integer  ipaCheck(boolean ipa,boolean coverflag){
        integer retval;
        if(ipa ){
            if(coverflag){
            retval=1;
            }
            else{
            retval=2;
            }
        }
        else{
            if(coverflag){
            retval=3;
            }
            else{
            retval=4;
            }
        }
        return retval;
    }
    //Response Formatting
    private static List<CIMAccountSearchInfo> getResponseJSON(List<PRM_SearchAccounts> lstSrcAccount, String searchLimit,Map<String,String> countryMap){
        System.debug('getResponseJSON call...');
        PRM_searchSfdcAccounts.getIPABadgeMap();
        List<CIMAccountSearchInfo> cimAccountsList = new List<CIMAccountSearchInfo>();
        List<AccountLegalAgreement> legalAgreements = new List<AccountLegalAgreement>();
        Integer srchLmt = 0;
        Integer lmt = (String.isNotBlank(searchLimit) ? Integer.valueOf(searchLimit) : lstSrcAccount.size());
        for(PRM_SearchAccounts prmSrcAcc : lstSrcAccount){
            if(srchLmt < lmt){
                Account account = prmSrcAcc.acc;
                Address addObj = new Address(account.BillingStreet, null, account.BillingCity, countryMap.get(account.BillingCountryCode),
                                             account.BillingStateCode, account.BillingPostalCode);
                legalAgreements =getAccountLegalAgreements(account);
                RelatedACMRecords relatedACMObj = prmSrcAcc.relatedACM;
                integer IPARank=ipaCheck(account.Core_Intel_Partner_Alliance_PartnerGroup__c,account.Core_Covered_Account__c);
                account.Name+=IPARank==1 ?'<==> IPA Covered ':IPARank==2 ?     '<==> IPA uncovered ':IPARank==3?' <==> NON IPA Covered ':IPARank==4?' <==> NON IPA UnCovered ':null;
                account.Name+=prmSrcAcc.searchScore;
                CIMAccountSearchInfo cimAccount = new CIMAccountSearchInfo(account.Name,addObj,legalAgreements,mapToPartnerRoleInfo(relatedACMObj != null? relatedACMObj.listOfAcm:null), account.Id, prmSrcAcc.accCIMId,(relatedACMObj != null ? relatedACMObj.ipaBadge:null));
                cimAccountsList.add(cimAccount);
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
    }*/
    
    //Wrapper Class to Construct Legal Agreements Details 
    public class AccountLegalAgreement{   
        public DateTime AgreementSignedDate;
        public AccountLegalAgreement(DateTime inputAgreementSignedDate){
            AgreementSignedDate = inputAgreementSignedDate;           
        }
    }
    
    //standard salesforce error response structure
    /*public class SalesforceError {
        public String errorCode;
        public String message;
        public SalesforceError(String errorCode, string message){
            this.errorCode = errorCode;
            this.message = message;
        }
    } 
    
    public class CustomException extends Exception{}*/
}