@RestResource(urlMapping='/Account/V2/SearchAccount')
global without sharing class ER_ENT_PRG_AccountSearch {   

    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_INFO     = 'info';
    public static final String LOG_ENTRY_SCOPE    = 'ER_ENT_PRG_AccountSearch';
   // public static final String FPGA_Account_Type  = 'PSG';
    //public static Set<Id> sbrAccountIds = new Set<Id>();
    
    
    global without sharing class SearchResults{
        List<ER_ENT_PRG_CIMAccountSearchInfo> SearchResults = new List<ER_ENT_PRG_CIMAccountSearchInfo>();
        SearchResults(List<ER_ENT_PRG_CIMAccountSearchInfo> listOfAccountSearch){
            if(listOfAccountSearch != null){
                SearchResults = listOfAccountSearch;
                
            }
        }
    }
    
    @HttpPost
    global static void doPost(ER_ENT_PRG_AccountSearch.CIMSearchBeforeCreate SearchAccount) {       
        RestResponse res = RestContext.response;
        //Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        try{
         /* List<PRM_SearchAccounts> lst_PrgSearchAccount = new List<PRM_SearchAccounts>();
            List<ER_SearchAccounts> lst_EntSearchAccount = new List<ER_SearchAccounts>();
            List<ER_ENT_PRG_CIMAccountSearchInfo> cimAccountsList = new List<ER_ENT_PRG_CIMAccountSearchInfo>();
            List<PRM_CIMSearchResults__c> listOfCimResult = null;
            List<String> PROCCountries = Label.PRM_PROC_Countries.toUpperCase().split(',');
            Set<Id> setOfAccountId = new Set<Id>();
            String AccountType = '';
            Boolean isProgramBased ;
            Map<string,string> countryMap = new map<string,string>();
            for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                //countryMap.put(allCountries.Country_Code__c, allCountries.ISO_Code__c);
                countryMap.put(allCountries.ISO_Code__c,allCountries.Country_Code__c);
            }
            string billingCountryForAPI;
            if(SearchAccount.AccountAddress.CountryCode2!=null && SearchAccount.AccountAddress.CountryCode2.toUpperCase().length() == 3 && countryMap!=null && countryMap.containsKey(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){
                billingCountryForAPI = countryMap.get(SearchAccount.AccountAddress.CountryCode2);
            }else{
                if(String.isNotBlank(SearchAccount.AccountAddress.CountryCode2) && SearchAccount.AccountAddress.CountryCode2.toUpperCase().length() == 2 && countryMap!=null && countryMap.values().contains(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){
                    billingCountryForAPI= SearchAccount.AccountAddress.CountryCode2;
                }
            }
            
            if(SearchAccount.AccountAddress != null){
                //if(String.isNotBlank(SearchAccount.SearchAccount.AccountAddress.CountryCode2) && !countryMap.containskey(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){ 
                if(String.isNotBlank(SearchAccount.AccountAddress.CountryCode2) && billingCountryForAPI==null){ 
                    throw new CustomException('INVALID_COUNTRYCODE');
                }
            }
            
            isProgramBased = String.isNotBlank(SearchAccount.EntitlementName) ? false : true;
            //Check only for entitlement also
            
            
            String partnerRole;
            if(isProgramBased){
                if(String.isNotBlank(SearchAccount.BizOrgType)){
                    String escapeSearchAccountBizOrgType =  String.escapeSingleQuotes(SearchAccount.BizOrgType);
                    PRM_PartnerRoleTypeMappings__mdt[] partnerRoleMapobj = [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c,PRM_Partner_Role_Label__c from PRM_PartnerRoleTypeMappings__mdt where PRM_Biz_Org_Type__c  =:escapeSearchAccountBizOrgType];
                    if(partnerRoleMapobj.size() > 0){
                        partnerRole = partnerRoleMapobj[0].PRM_Partner_Role_Label__c;
                    }else{
                        throw new CustomException('INVALID_BIZORGTYPE');  
                    }
                    
                
                  
                }
                if(String.isNotBlank(SearchAccount.EmailAddress) && !PROCCountries.contains(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){                
                    //if(String.isNotBlank(EmailAddress)){
                    if(PRM_searchSfdcAccounts.emailValidationCheck(SearchAccount.EmailAddress)){
                        if(PRM_searchSfdcAccounts.isBlacklistedEmailDomian(SearchAccount.EmailAddress)){
                            String emailDomain = SearchAccount.EmailAddress.substringAfter('@');
                            for(Contact con : (List<Contact>)[FIND :emailDomain IN EMAIL FIELDS RETURNING Contact(id,name,Accountid WHERE account.recordtype.id=:intelaccountRT)][0]){                                
                                setOfAccountId.add(con.accountId);
                            }
                        }else{
                        }
                    }else{
                        throw new CustomException('INVALID_EMAIL');  
                                 }                     
                }
                   
            }
            
            // Sorting the Accounts based on Priority Logic
          
            if(!isProgramBased)
            {
                ////////EntitleMent logic Buisness Type With E.Matrix Object/////
                if(String.isNotBlank(SearchAccount.EntitlementName))
                {
                    //List<string> ceAccountType=Label.CEAccountTypeMap.split(';');
                    Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
                    List<PRM_VXEnttlmntMatrix__c> ceAccountType = [SELECT PRM_Entitlement_Id__r.Name, Business_Types__r.Name FROM PRM_VXEnttlmntMatrix__c Where PRM_Entitlement_Id__r.Name =: SearchAccount.EntitlementName and RecordTypeId=: eBREnttRecTypeId];
                    
                    //Map<string,string> ceAccountTypeMap= new  Map<string,string>();
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
                listOfCimResult = new ER_ENT_PRG_SearchCIMAccount().getCimResults(SearchAccount.AccountName, SearchAccount.AccountAddress.AddressLine1, SearchAccount.AccountAddress.PostalCode,SearchAccount.AccountAddress.City,billingCountryForAPI,SearchAccount.AccountAddress.StateCode2,SearchAccount.SearchLimit,SearchAccount.MinimumSearchScore,SearchAccount.AccountURL,SearchAccount.EmailAddress,AccountType, true,setOfAccountId,partnerRole,isProgramBased);
               
            }
            
            if(String.isNotBlank(SearchAccount.EntitlementName)){
                
                lst_EntSearchAccount = ER_SearchSalesCloudAccounts.getSortedAccountsCim(listOfCimResult,setOfAccountId,AccountType,SearchAccount.SearchLimit);
                
                if(lst_EntSearchAccount != null)  // 
                {
                    //Formatting the Response from CIM 
                    cimAccountsList.addAll(getResponseJSON(lst_EntSearchAccount,countryMap));                    
                }
                
            }else{
                  lst_PrgSearchAccount = PRM_searchSfdcAccounts.getSortedAccountsCim(listOfCimResult,setOfAccountId,partnerRole); 
                 
                if(lst_PrgSearchAccount != null)
                {
                    cimAccountsList.addAll(getResponseJSON(lst_PrgSearchAccount,SearchAccount.SearchLimit,countryMap));
                    
                }
            }*/
      
            Map<string,string> countryMap = new map<string,string>();
            String billingCountryForAPI;
            for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                countryMap.put(allCountries.ISO_Code__c,allCountries.Country_Code__c);
            }
            if(SearchAccount.AccountAddress.CountryCode2!=null && SearchAccount.AccountAddress.CountryCode2.toUpperCase().length() == 3 && countryMap!=null && countryMap.containsKey(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){
                billingCountryForAPI = countryMap.get(SearchAccount.AccountAddress.CountryCode2);
            }else{
                if(String.isNotBlank(SearchAccount.AccountAddress.CountryCode2) && SearchAccount.AccountAddress.CountryCode2.toUpperCase().length() == 2 && countryMap!=null && countryMap.values().contains(SearchAccount.AccountAddress.CountryCode2.toUpperCase())){
                    billingCountryForAPI= SearchAccount.AccountAddress.CountryCode2;
                }
            }
            if(SearchAccount.AccountAddress != null){
                if(String.isNotBlank(SearchAccount.AccountAddress.CountryCode2) && billingCountryForAPI==null){ 
                    throw new CustomException('INVALID_COUNTRYCODE');
                }
            }
            
           
            String AccountType = '';
           
           ////////EntitleMent logic Buisness Type With E.Matrix Object/////
           if(String.isNotBlank(SearchAccount.EntitlementName))
           {
               //Id eBREnttRecTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get(System.Label.EBREntitlementRecordTypeName).getRecordTypeId();
               List<PRM_VXEnttlmntMatrix__c> ceAccountType = [SELECT PRM_Entitlement_Id__r.Name, Business_Types__r.Name FROM PRM_VXEnttlmntMatrix__c Where PRM_Entitlement_Id__r.Name =: SearchAccount.EntitlementName];
               if(ceAccountType.size()>0){
                AccountType = ceAccountType[0].Business_Types__r.Name;
               }                  
               else
               {
                throw new CustomException('INVALID_BUSINESSTYPE');
               }
           }
            List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fDetailsList  = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();
            PRM_AdminRegistrationDuplicateDetails.CountryStateWrapperForSBR csWrp = new PRM_AdminRegistrationDuplicateDetails.CountryStateWrapperForSBR();
            csWrp = PRM_AdminRegistrationDuplicateDetails.getCountryOrStateForSBR (SearchAccount.AccountAddress.CountryCode2, SearchAccount.AccountAddress.StateCode2);
            //create wrapper to search matching account results
            fDetailsList = PRM_AdminRegistrationDuplicateDetails.createFDetailsList (SearchAccount.AccountName, csWrp.country, csWrp.state, SearchAccount.AccountURL);
            //call reltio API to get matching accounts
             UCD_GenericAcctSearch_SBR.AccountSearchDataModelWithError accFinalDetails = new  UCD_GenericAcctSearch_SBR.AccountSearchDataModelWithError();
             List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel> accDetails = new  List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel>();
            if(!fDetailsList.isEmpty() && fDetailsList !=null){
              accFinalDetails = UCD_GenericAcctSearch_SBR.getAcctResults (fDetailsList, '');
              accDetails = accFinalDetails.accountSearchModel;//get only account details
            }
                
            Set<Id> sbrAccountIds = new Set<Id>();
            if (accDetails != null && !accDetails.isEmpty()) {
                sbrAccountIds.addAll(getUcdAccDetailsMap(accDetails));
            }
            List<Account> accList = new List<Account>();
            if(sbrAccountIds != null && !sbrAccountIds.isEmpty()){
                 accList = [SELECT Id, Name,Core_CIM_ID__c, Unified_Hierarchy_View__c,Core_Customer_Aggregation_Type__c,Core_Business_Party_Id__c, Core_Address_Details__c, 
                                Core_Intel_Partner_Alliance_PartnerGroup__c,/* Core_Account_Type__c, // BizOrgType code removal*/ toLabel(Core_IPA_Partner_Role__c), Core_Export_Compliance_Block__c, 
                                RecordType.name, Owner.name, BillingCity, BillingStateCode, BillingCountryCode, BillingStreet,BillingPostalCode,
                                 Core_Unified_Global_Customer_Name__c,Core_CNDA_Number__c,Core_Covered_Account__c,Core_B2B_Entitlement__c
                                FROM Account WHERE Id IN: sbrAccountIds];
            }
            Set<Id> setOfAccId = new Set<Id>();
            List<ER_SearchAccounts> lstSearchAccountObj = new List<ER_SearchAccounts>();
            for(Account acc :accList){  
                if(acc.Name.toUpperCase().contains(Label.ER_FPGA_Account_Name.toUpperCase())){
                       /* if(AccountType != null && AccountType == FPGA_Account_Type){
                    		setOfAccId.add(acc.Id);
                            lstSearchAccountObj.add(new ER_SearchAccounts(acc.id,acc.Core_Business_Party_Id__c, acc, 0));
                        }*/
                    }
                	else{
                    setOfAccId.add(acc.Id);
                    lstSearchAccountObj.add(new ER_SearchAccounts(acc.id,acc.Core_Business_Party_Id__c, acc, 0));
                    }
            } 
              
            
            List<ER_SearchAccounts> accoutSortedList =new List<ER_SearchAccounts>();
            List<ER_ENT_PRG_CIMAccountSearchInfo> cimAccountsList = new  List<ER_ENT_PRG_CIMAccountSearchInfo>();
            if(lstSearchAccountObj != null && !lstSearchAccountObj.isEmpty()){
                List<ER_SBC_PriorityMatrix__mdt> priorityMatrix = [SELECT AccountType__c,PriorityField__c,PriorityNumber__c,isObjectField__c,PriorityValue__c,isSearchScore__c
                                                               FROM ER_SBC_PriorityMatrix__mdt WHERE AccountType__c = :AccountType ORDER by PriorityNumber__c];
                accoutSortedList = ER_SearchSalesCloudAccounts.sortIdBasedOnSortingCriteria(lstSearchAccountObj,setOfAccId,priorityMatrix,SearchAccount.SearchLimit);
                cimAccountsList.addAll(getResponseJSON(accoutSortedList,countryMap));
            }
            res.statusCode = 200;
            if(cimAccountsList != null && !cimAccountsList.isEmpty()){
               res.responseBody = Blob.valueOf(JSON.serialize(new SearchResults(cimAccountsList)));
            }
            
           
        }catch(CustomException ce){
            res.statusCode = 400;
            SalesforceError[] errs = null;
            //Start Add Log exception in 'Log Entry' Object
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = ce.getMessage();
            custEx.Cause = ce.getCause();
            custEx.StackTraceString = ce.getStackTraceString();
            custEx.LineNumber = ce.getLineNumber();                
            custEx.TypeName = ce.getTypeName();            
            ER_ErrorUtility.createLogEntry('Custom Exception', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, 'SearchBeforeCreate API');
            //End Add Log exception in 'Log Entry'Object
            
            if(ce.getMessage()=='INVALID_COUNTRYCODE'){
                errs = new SalesforceError[]{new SalesforceError('0001', 'Invalid Country Code')};
                    res.responseBody = Blob.valueOf(JSON.serialize(errs));
            }            
            
            /*if(ce.getMessage()=='INVALID_BIZORGTYPE'){
                errs = new SalesforceError[]{new SalesforceError('0003', 'Invalid BizOrgType')};
                    res.responseBody = Blob.valueOf(JSON.serialize(errs));
            }            
            
            if(ce.getMessage()=='INVALID_EMAIL'){
                errs = new SalesforceError[]{new SalesforceError('0004', 'Invalid EmailAddress')};
                    res.responseBody = Blob.valueOf(JSON.serialize(errs));
            }*/
            
        }catch(System.QueryException e){           
            res.statusCode = 400;
            SalesforceError[] errs = new SalesforceError[]{ 
            new SalesforceError('Query Exception ', e.getMessage())
            };
            
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = e.getMessage();
            custEx.Cause = e.getCause();
            custEx.StackTraceString = e.getStackTraceString();
            custEx.LineNumber = e.getLineNumber();                
            custEx.TypeName = e.getTypeName();            
            ER_ErrorUtility.createLogEntry('General Exception', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, 'SearchBeforeCreate API');
            //End Add Log exception in 'Log Entry' Object
            
            res.responseBody = Blob.valueOf(JSON.serialize(errs));  
        
        }catch(Exception e){             
            res.statusCode = 400;
            SalesforceError[] errs = new SalesforceError[]{ 
            new SalesforceError('BAD_REQUEST', e.getMessage())
            };
            //Start Add Log exception in 'Log Entry' Object
            ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
            custEx.Message = e.getMessage();
            custEx.Cause = e.getCause();
            custEx.StackTraceString = e.getStackTraceString();
            custEx.LineNumber = e.getLineNumber();                
            custEx.TypeName = e.getTypeName();            
            ER_ErrorUtility.createLogEntry('General Exception', custEx, LOG_ENTRY_ERROR, LOG_ENTRY_SCOPE, 'SearchBeforeCreate API');
            //End Add Log exception in 'Log Entry' Object
            
            res.responseBody = Blob.valueOf(JSON.serialize(errs));        
        }
    }
     private static Set<Id> getUcdAccDetailsMap(List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel> accDetails) {
        List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel> sbrChildAcc = new List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel>();
        Set<id> sbrAccountIds=new Set<id>();
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
         
         return sbrAccountIds;
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
   @TestVisible private static List<ER_ENT_PRG_CIMAccountSearchInfo> getResponseJSON(List<ER_SearchAccounts> lstSrcAccount, Map<String,String> countryMap){
        
        List<ER_ENT_PRG_CIMAccountSearchInfo> cimAccountsList = new List<ER_ENT_PRG_CIMAccountSearchInfo>();
        for(ER_SearchAccounts prmSrcAcc : lstSrcAccount){
            Account account = prmSrcAcc.acc;
            Address addObj = new Address(account.BillingStreet, null, account.BillingCity, countryMap.get(account.BillingCountryCode),
                                         account.BillingStateCode, account.BillingPostalCode);
            ER_ENT_PRG_CIMAccountSearchInfo cimAccount = new ER_ENT_PRG_CIMAccountSearchInfo(account.Name,addObj,account.Id, prmSrcAcc.accCIMId);
            cimAccountsList.add(cimAccount);
        }  
        return cimAccountsList;
    }
    ///End ER/////////////////////
    //Response Formatting
   @TestVisible
    private static List<ER_ENT_PRG_CIMAccountSearchInfo> getResponseJSON(List<PRM_SearchAccounts> lstSrcAccount, String searchLimit,Map<String,String> countryMap){
        
        PRM_searchSfdcAccounts.getIPABadgeMap();
        List<ER_ENT_PRG_CIMAccountSearchInfo> cimAccountsList = new List<ER_ENT_PRG_CIMAccountSearchInfo>();
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
                ER_ENT_PRG_CIMAccountSearchInfo cimAccount = new ER_ENT_PRG_CIMAccountSearchInfo(account.Name,addObj,legalAgreements,mapToPartnerRoleInfo(relatedACMObj != null? relatedACMObj.listOfAcm:null), account.Id, prmSrcAcc.accCIMId,(relatedACMObj != null ? relatedACMObj.ipaBadge:null));
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
            if(agreement.PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name=='Intel Partner Alliance' && agreement.PRM_InActive_Ind__c==false){
                AccountLegalAgreement legalAgreement = new AccountLegalAgreement(agreement.PRM_Agreement_Sign_Dt__c);             
                legalAgreements.add(legalAgreement);  
            }
        }
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
    
    public class CustomException extends Exception
    {}
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