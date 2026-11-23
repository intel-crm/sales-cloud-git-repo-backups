/*********************************************************************************************************************
Apex Class Name  : PRM_CIMAccountSearch
Version       : 2.0
Created Date  : May 2021
Function      : Rest API class to get exisitng Accounts from both SFDC and CIM

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Ruby                  Jan 2022             Rest API class to get exisitng Accounts from both SFDC and CIM

*********************************************************************************************************************/
@RestResource(urlMapping='/Account/SearchAccountOld')
    
global without sharing class PRM_CIMAccountSearch {

    @HttpPost
    global static void doPost(String AccountName,Address AccountAddress, String AccountURL, String BizOrgType, String EmailAddress, String SearchLimit, String MinimumSearchScore) {         
        DateTime reqTime = System.now();
        String requestPayload = 'AccountName:'+AccountName+', AccountAddress:'+AccountAddress+', AccountURL:'+AccountURL+', BizOrgType:'+BizOrgType+', EmailAddress:'+EmailAddress+', SearchLimit:'+SearchLimit+',MinimumSearchScore :'+MinimumSearchScore;
        system.debug('---requestPayloadAEM '+requestPayload);
        RestResponse res = RestContext.response;        
        Set<Id> setOfAccountId = new Set<Id>(); 
        Map<string,string> countryMap = new map<string,string>();
        string billingCountryForAPI,CountryCodeinUC;
        PRM_SBCSearchResults FinalSearchResult ;
        set<string> AccountNameset=new set<string>();
        PRM_CIMCalloutNEW prmUICimCallout = new PRM_CIMCalloutNEW();
        PRM_CIM_Request__mdt cimMdt; 
        //set<id> recordTypeIds=new set<id>();                  
    
        
        try{
            //get Intel Acount Record Type Id
            Id INTEL_ACCOUNT_RT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();        
            
            //collect System Account Name from metadata
            for(Core_Intel_System_Accounts__mdt mdt :Core_Intel_System_Accounts__mdt.getall().values()){
                AccountNameset.add(mdt.Account_Name__c);
            }
            
            //Collect PROC Countries from Label
            List<String> PROCCountries = Label.PRM_PROC_Countries.toUpperCase().split(',');
            
            //Fetch custom metadata which stores the  Cim score / SearchLimit and CIM Request info
            cimMdt = PRM_CIM_Request__mdt.getinstance('PRM_Dupe_Scores');  
              
            //Collect 3 & 2 digit countrycode in the map from Custom Setting
            for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                countryMap.put(allCountries.ISO_Code__c,allCountries.Country_Code__c);
            }          
            
            //Check if country code is 3 digit then get 2 digit code from map to send it to CIM
            if(string.isNotBlank(AccountAddress.CountryCode2) ) {
                CountryCodeinUC=AccountAddress.CountryCode2.toUpperCase();
                billingCountryForAPI=(CountryCodeinUC.length() == 3 && countryMap.containsKey(CountryCodeinUC))?countryMap.get(CountryCodeinUC):(CountryCodeinUC.length() == 2 && countryMap.values().contains(CountryCodeinUC))?AccountAddress.CountryCode2:null;
                if(String.isBlank(billingCountryForAPI))
                throw new CustomException('INVALID_COUNTRYCODE');
            } 
            
            //check BIZORGType
             if(String.isNotBlank(BizOrgType)){
                PRM_PartnerRoleTypeMappings__mdt[] partnerRoleMapobj = [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c,PRM_Partner_Role_Label__c from PRM_PartnerRoleTypeMappings__mdt where PRM_Biz_Org_Type__c  =:BizOrgType];
                if(partnerRoleMapobj.IsEmpty())
                throw new CustomException('INVALID_BIZORGTYPE');           
            }      
            
            //check if email address is not blank and country code is not part of PROC Countries
            if(String.isNotBlank(EmailAddress) && !PROCCountries.contains(CountryCodeinUC)){
                 if( PRM_searchSfdcAccounts.emailValidationCheck(EmailAddress)){
                    //check if emaildomain is Not in Black list & then fetch existing accounts based on email domain
                    if(PRM_searchSfdcAccounts.isBlacklistedEmailDomian(EmailAddress) ){                
                        String emailDomain ='%@'+ EmailAddress.substringAfter('@');
                        //Query to get Accounts from SFDC based on email domain
                        for(Contact con : [select id,AccountId,Account.BillingCountryCode from Contact WHERE account.recordtype.id =:INTEL_ACCOUNT_RT and  Account.name NOT in :AccountNameset and Email like:emailDomain]){  
                        setOfAccountId.add(con.accountId);
                        }
                    }
                }
                else{
                    throw new CustomException('INVALID_EMAIL');  
                } 
            }
            //system.debug('---setOfAccountIdsize '+setOfAccountId.size());
            
            //defaulting seachlimit and minimunScore
            SearchLimit=string.isNotBlank(SearchLimit)?SearchLimit:string.valueof(cimMdt.PRM_Max_Records__c);
            integer MinimumSearchScoreInt=string.isNotBlank(MinimumSearchScore)?integer.valueof(MinimumSearchScore):integer.valueof(cimMdt.PRM_Min_Score__c);        
            //integer SearchLimitIntger=string.isnotblank(SearchLimit)?integer.valueof(SearchLimit):0;
            
            // Concatenate the Address lines                
            AccountAddress.AddressLine1 = String.IsNotBlank(AccountAddress.AddressLine2)?AccountAddress.AddressLine1 +' '+ AccountAddress.AddressLine2:AccountAddress.AddressLine1 ;
            AccountAddress.Countrycode2=billingCountryForAPI;
            
            // Initate CIM Callout
           // FinalsearchResult=prmUICimCallout.getCimResults(AccountName, AccountAddress,SearchLimit,MinimumSearchScoreInt,AccountURL,setOfAccountId,EmailAddress,cimMdt);                               
            
            //serialize Response with final Account list and Send to AEM             
                if(FinalsearchResult!=null)
                {
                    res.statusCode = 200;
                    string finalresult=JSON.serialize(FinalsearchResult);
                    res.responseBody = Blob.valueOf(finalresult);
                    //system.debug('---FinalResponsefromSFDCtoAEMInSBCCallout==> '+finalresult);
                }       
        }        
        Catch(CustomException ce){
            res.statusCode = 400;
            SalesforceError[] errs = null;
            
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
            string ErrorinSort;
            //if Something went wrong in the CIM API/Process, then proceed with whatever records got from SFDC
            if(FinalsearchResult==null){
                try{
                    //FinalsearchResult=prmUICimCallout.getRecordsforSorting(setOfAccountId,cimMdt);
                }
                Catch(Exception eex){ErrorinSort=eex.getmessage();}
            }
                //serialize Response with final Account list and Send to AEM             
                if(FinalsearchResult!=null)
                {
                    res.statusCode = 200;
                    string finalresult=JSON.serialize(FinalsearchResult);
                    res.responseBody = Blob.valueOf(finalresult);
                    //system.debug('---FinalResponsefromSFDCtoAEMInSBCCallout==> '+finalresult);
                }
                else {      
                    res.statusCode = 400;
                    SalesforceError[] errs = new SalesforceError[]{ 
                    new SalesforceError('BAD_REQUEST', e.getMessage()+'--sortingError'+ErrorinSort)
                    };
                    res.responseBody = Blob.valueOf(JSON.serialize(errs));
               }
        }
        finally{
           //  Calling the utility method to create Integration log record
          PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
           Integer fieldLength=Schema.SObjectType.PRM_Integration_Log__c.fields.PRM_Response_Payload__c.getLength();
           if(res != null && res.responseBody != null){
               logEntryUtility.addLogEntry(res.responseBody.toString(),fieldLength);
           }
           for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
           PRM_IPA_Utility.createIntegrationLog(EmailAddress,PRM_IPA_Constants.CALLOUT_TYPE_INBOUND,PRM_IPA_Constants.MODULE_SELF_REGISTRATION,requestPayload,logEntryUtility.logEntryList[i],res.statusCode,PRM_IPA_Constants.SYSTEM_NAME_AEM,'PRM_CIMAccountSearchOld',reqTime,System.now());
          }          
       
        }
    
    }  
    
    //Wrapper for standard salesforce error response structure
    public class SalesforceError {
        public String errorCode;
        public String message;
        public SalesforceError(String errorCode, string message){
            this.errorCode = errorCode;
            this.message = message;
        }
    } 
        
    public class CustomException extends Exception{}
   
    }