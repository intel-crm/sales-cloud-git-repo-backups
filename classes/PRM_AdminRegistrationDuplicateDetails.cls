/*Function      : Displaying duplicate account and contact details in the Admin Registration UI 

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nishant      11 November,2019            Displaying duplicate account and contact details in the Admin Registration UI
* Shraddha     Dec 2023 - feb 2024         Added SBR Search logic for IPA Registrations

*********************************************************************************************************************/
public without sharing class PRM_AdminRegistrationDuplicateDetails {

    public static string LOG_ENTRY_ORIGIN ='PRM_AdminRegistrationDuplicateDetails';
    public static string LOG_ENTRY_PROJECT = 'IPA';
    public static string LOG_ENTRY_SCOPE = 'Medium';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static Set<Id> sbrAccountIds = new Set<Id>();
    
    /*showAccountsContacts on admin registration page*/
    @AuraEnabled
    public static accountContactList showAccountsContacts (map<string,string> requestDetails) {
        list<Contact> contactDetails = new list<Contact>();
        accountContactList accCntList = new accountContactList();
        Account accountAssociatedToExistingContact = new Account() ;
        Boolean associatedAccountIsIPA = false;
        ucdErrorhandlingWrapper ucdErrWrp = new ucdErrorhandlingWrapper();

        try {
            List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fDetails  = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();
            String accountName = requestDetails.get('AccountName').trim();
            String contactEmail = requestDetails.get('ContactEmail').trim();
            String country = requestDetails.get('Country').trim();
            String state = requestDetails.get('State').trim();
            String website = requestDetails.get('Website').trim();

            //SBR
            CountryStateWrapperForSBR csWrp = new CountryStateWrapperForSBR();
            csWrp = getCountryOrStateForSBR (country, state);
            fDetails = createFDetailsList (accountName, csWrp.country, csWrp.state, website);

            //call UCD SBR
            ucdErrWrp = searchAccountFromUCDSBR(fDetails);
            
            if(!ucdErrWrp.isError) {
                accCntList.accountList = ucdErrWrp.accList;
            } else {
                //throw new Exception to catch it on admin Reg UI
                throw new AuraHandledException(ucdErrWrp.errorMessage);
            }
            
            // Search the existing Contact in SFDC org
            if (contactEmail != null) {
                for (Contact cntc : [select id,name,email,accountId from contact where email=:contactEmail]) {
                    contactDetails.add(cntc); 
                    // accCntList.accountDupStatus= 'NoDup';
                    accCntList.displayRequestedAccount = False;
                    accCntList.accountList = null;
                }
            }
      accCntList.contactList=contactDetails;
            
            if (contactDetails != null && contactDetails.size()>0) {
                accCntList.contactDupStatus = 'Duplicate' ;
                accountAssociatedToExistingContact = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c from Account where id = : contactDetails[0].Accountid ];
                Id ipaChannelPgmId = [select id from ChannelProgram where prm_programCode__c=: System.Label.PRM_IPAEngagement limit 1].Id;
                List<PRM_AccountChannelMembership__c> associatedACMList = new List<PRM_AccountChannelMembership__c>();
                associatedACMList = [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: accountAssociatedToExistingContact.id and PRM_Channel_Program_Id__c =: ipaChannelPgmId and PRM_Partner_Role__c =:requestDetails.get('PartnerRole') and PRM_Status_Nm__c != 'Inactive' and PRM_Status_Nm__c !='' ];
                accCntList.accountAssociatedToExistingContact = accountAssociatedToExistingContact;
                accCntList.duplicateContactRecord = contactDetails[0];
                if (associatedACMList != null && associatedACMList.size()>0)
                 {
                    associatedAccountIsIPA = true;
                }
            }
            else{
                accCntList.contactDupStatus = 'NoDuplicate' ;
                accCntList.accountAssociatedToExistingContact = null;
                accCntList.duplicateContactRecord = null ;
            }
            accCntList.associatedAccountIsIPA = associatedAccountIsIPA;
        } 
        catch (Exception e) { PRM_ErrorUtilityClass.logError (e);
            throw new AuraHandledException(e.getMessage());
        }
        
        return accCntList;
    }

    /* Wrapper class for the account and contact details*/
    public class accountContactList  {
        
        @AuraEnabled
        public list<matchingAccWrapper> accountList = new list<matchingAccWrapper>();
        @AuraEnabled
        public list<Contact> contactList = new list<Contact>();
        // @AuraEnabled
        // public String accountDupStatus ;
        @AuraEnabled
        public String contactDupStatus ;
        @AuraEnabled
        public Account accountAssociatedToExistingContact ;
        @AuraEnabled
        public Contact duplicateContactRecord ;
        @AuraEnabled
        public Boolean associatedAccountIsIPA ;
        @AuraEnabled
        public Boolean displayRequestedAccount ;
        
    }

    /*****************************************************************************************************************
* Method Name: searchAccountFromUCDSBR
* Date: Nov 2023   
* Owner: Shraddha
* Description: to get list of matching accounts from sbr search
* Return: List<matchingAccWrapper>
******************************************************************************************************************/
    Public Static ucdErrorhandlingWrapper searchAccountFromUCDSBR (List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fDetails) {

        ucdErrorhandlingWrapper ucdErrWrp = new ucdErrorhandlingWrapper();
        //Map<Id, UCD_GenericAcctSearch_SBR.AccountSearchDataModelWithError> ucdAccDetailsMap = new Map<Id, UCD_GenericAcctSearch_SBR.AccountSearchDataModelWithError>();
        List<matchingAccWrapper> accWrpList = new List<matchingAccWrapper>();
        List<matchingAccWrapper> sortedAdminAccs = new List<matchingAccWrapper>();
        map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>(); 
        list<string> accidList=new list<string>();
        try {
            UCD_GenericAcctSearch_SBR.AccountSearchDataModelWithError accFinalDetails = UCD_GenericAcctSearch_SBR.getAcctResults (fDetails, 'Partner');
            //get only account details
            List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel> accDetails = accFinalDetails.accountSearchModel;       

            if (accDetails != null && !accDetails.isEmpty()) {
                getUcdAccDetailsMap(accDetails);
            }

            if (!sbrAccountIds.isEmpty() && sbrAccountIds!= null) {
        //TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
        List<Account> accList = [SELECT Id, Name, Unified_Hierarchy_View__c,Core_Customer_Aggregation_Type__c,Core_Unified_Intermediate_Customer_BP_Id__c,Core_Business_Party_Id__c, Core_Address_Details__c, 
                                Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Account_Type__c, toLabel(Core_IPA_Partner_Role__c), Core_Export_Compliance_Block__c, 
                                RecordType.name, Owner.name, BillingCity, toLabel(BillingStateCode), toLabel(BillingCountryCode), BillingStreet, BillingPostalCode,
                                Core_Unified_Global_Customer_BP_Id__c, Core_Unified_Global_Customer_Name__c
                                FROM Account WHERE Id IN: sbrAccountIds];
        Map<String,String> parentAccMap = new Map<String,String>();
        List<String> parentUnifiedId = new List<String>();
                for (Account acc : accList) {
          if(acc.Core_Unified_Global_Customer_BP_Id__c!=null){
            parentUnifiedId.add(acc.Core_Unified_Global_Customer_BP_Id__c);
          }
                    accidList.add(acc.id);
                }
        for(Account acc : [Select id,Core_Business_Party_Id__c from Account where Core_Business_Party_Id__c in: parentUnifiedId]){
            parentAccMap.put(acc.Core_Business_Party_Id__c,acc.id);
        }
                mapOfAccWithBlokedStatus= PRM_MatchingAccounts.getBlockedAccount(accidList);
                //TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
                for (Account acc : accList) {
                    matchingAccWrapper acWrp = setMatchingAccWrapper (acc,parentAccMap,mapOfAccWithBlokedStatus);
                    accWrpList.add(acWrp);
                }
                sortedAdminAccs = matchingAccountSort (accWrpList);
            }
            ucdErrWrp.accList = sortedAdminAccs;
            ucdErrWrp.isError = accFinalDetails.isError;
            ucdErrWrp.errorMessage = accFinalDetails.errorMessage;
        }
        catch(exception ex) { Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'searchAccountFromUCDSBR' ,'' ,ex); 
        }
        return ucdErrWrp;

    }

    /* @dev - Shraddha M
    @desciption - wrapper*/
    public class ucdErrorhandlingWrapper{
        public List<matchingAccWrapper> accList {get;set;}
        public Boolean isError {get;set;}
        public String errorMessage {get;set;}
    }

    /* @dev - Shraddha M
    @desciption - to get the getUcdAccDetailsMap*/
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

   /*
   @dev - Shraddha M
   @desciption - to set the SBR Search Wrapper
   */
    public static UCD_GenericAcctSearch_SBR.Fieldsetwrapper setfieldsetwrapper (String fieldLabel, String fieldAPIName, String fieldValue) {
        UCD_GenericAcctSearch_SBR.Fieldsetwrapper fdWrp = new UCD_GenericAcctSearch_SBR.Fieldsetwrapper();
        fdWrp.fieldLabel = fieldLabel;
        fdWrp.fieldAPIName = fieldAPIName;
        fdWrp.fieldValue = fieldValue;

        return fdWrp;
    }

    /*CountryStateWrapperForSBR*/
    public class CountryStateWrapperForSBR {
        @AuraEnabled
        public String country {get;set;}
        @AuraEnabled
        public String state {get;set;}
    }

     /*
    @dev - Shraddha M
    @desciption - to get country and state full name to show it on UI
    */
    @AuraEnabled
    public static CountryStateWrapperForSBR fetchCountryStateForAddress(String country, String state) {
        CountryStateWrapperForSBR csWrp = new CountryStateWrapperForSBR();
        try {
            csWrp = getCountryOrStateForSBR(country, state);
        } catch (Exception e) { throw new AuraHandledException(e.getMessage());
        }
        Return csWrp;
    }

    /*
    @dev - Shraddha M
    @desciption - to get country and state full name from code to pass it to the SBR search method
    */
    public Static CountryStateWrapperForSBR getCountryOrStateForSBR (String countryTemp, String state) {
        CountryStateWrapperForSBR csWrp = new CountryStateWrapperForSBR();
        String country;
        if(countryTemp.length() == 2 ) {
            country = PRM_Registration_Req_Approve_Reject.getCountryCode(countryTemp);
        }else {
            country = countryTemp;
        }
        List<PRM_AdminRegistration.stateCountryInfo> stateCountryInfoList= PRM_AdminRegistration.fetchStateCountryValues();
        for (PRM_AdminRegistration.stateCountryInfo cs : stateCountryInfoList) { //create list and store split results, add size check
            List<String> countryCdValues = new List<String>(cs.country.split(';'));
            if (countryCdValues.size() > 1 && countryCdValues[1] == country) {
                csWrp.country = countryCdValues[0];
                for (String st : cs.stateList) {
                    List<String> stateCdValues = new List<String>(st.split(';'));
                    if (stateCdValues.size() > 1 && stateCdValues[1] == state) {
                        csWrp.state = stateCdValues[0];
                        break;
                    }
                }
            }
        }
        Return csWrp;
    }

    /*
    @dev - Shraddha M
    @desciption - to create wrapper instance
    */
    Public static List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> createFDetailsList (String accountName, String country, String state, String website) {
        List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fDetails  = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();

        fDetails.add(setfieldsetwrapper ('Name', 'Name', accountName));
        fDetails.add(setfieldsetwrapper ('Core_Requested_Name__c', 'Core_Requested_Name__c', accountName));
        fDetails.add(setfieldsetwrapper ('BillingCountry', 'BillingCountry', country));
        fDetails.add(setfieldsetwrapper ('BillingState', 'BillingState', state));
        fDetails.add(setfieldsetwrapper ('Website', 'Website', website));
        fDetails.add(setfieldsetwrapper ('Core_MDM_Website__c', 'Core_MDM_Website__c', website));
        fDetails.add(setfieldsetwrapper ('Core_User_Defined_Website__c', 'Core_User_Defined_Website__c', website));
        return fDetails;
    }

    /*
    @dev - Shraddha M
    @desciption - to getAccountsFromSBRResults and show it on reg request page - (matching accounts)
    */
    @AuraEnabled
    public static duplicateAccWrapper getAccountsFromSBRResults (Id regRecId) {
        duplicateAccWrapper dupAccWrp = new duplicateAccWrapper();
        List<matchingAccWrapper> matchingAccList = new List<matchingAccWrapper>();
        List<matchingAccWrapper> sortedMatchingAccs = new List<matchingAccWrapper>();
        PRM_Registration_Request__c regRcd = new PRM_Registration_Request__c();
        String regRequestContactEmail;
        extAccWrapper extAccWrp = new extAccWrapper();
        regReqInfoWrapper regReqInfoWrp = new regReqInfoWrapper();
        Boolean blockedAccount=false;
        list<string> accidList=new list<string>();
        map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>(); 
        String sanitizedSearchKey = String.escapeSingleQuotes(UserInfo.getUserId());
        User user = [select Id,IsPortalEnabled,profile.name, username,Core_IPA_One_Partner_Id__c,Core_IPS_AccountId__c,Email from User where Id = :sanitizedSearchKey];//where Id =: currentUserId  
        string profileName=user.profile.name;
        list<PermissionSetAssignment> permissionsAssignedToUser=[ SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name 
        FROM PermissionSetAssignment WHERE Assignee.Id =: user.Id];
        list<string> permissionsAssignedToUsers=new list<string>();
        for(PermissionSetAssignment permissions:permissionsAssignedToUser){
            permissionsAssignedToUsers.add(permissions.PermissionSet.Name);
        }
        system.debug('permissionsAssignedToUsers'+permissionsAssignedToUsers);
        matchingAccWrapper accWrp =new  matchingAccWrapper();
        try {
            if (regRecId != null) {
                PRM_Registration_Request__c regReq = [SELECT id,PRM_Salesforce_ID__c,PRM_Email_ID__c,PRM_Enterprise_ID__c,PRM_Matching_Contact__c,PRM_Status__c,
                                                    PRM_Matching_Contact__r.Email,PRM_Matching_Contact__r.Account.Name,PRM_Dup_Status__c,
                                                    PRM_Matching_Contact__r.Account.Id,toLabel(PRM_Partner_Role__c),PRM_Partner_Type__c,PRM_Channel_Program__c,PRM_Auto_Approve__c,
                                                    PRM_Matching_Contact__r.Core_IPA_PartnerRole__c,toLabel(PRM_Matching_Contact__r.Account.Core_IPA_Partner_Role__c),
                                                    PRM_Matching_Contact__r.Account.Core_Deactivated__c 
                                                    FROM PRM_Registration_Request__c
                                                    WHERE id =:regRecId];
                regRcd = regReq;
                //TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
                List<PRM_CIMSearchResults__c> sbrList =[SELECT Id, PRM_Account_Id__c, PRM_Account_Id__r.Unified_Hierarchy_View__c, PRM_Account_Id__r.Core_Customer_Aggregation_Type__c,PRM_Account_Id__r.Core_Business_Party_Id__c, PRM_AddressLine1_Txt__c, PRM_RegReq_Id__c, PRM_Account_Id__r.Core_Address_Details__c, 
                                                PRM_Account_Id__r.Id, PRM_Account_Id__r.Name, PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c, PRM_Account_Id__r.Core_Export_Compliance_Block__c, 
                                                PRM_Account_Id__r.Owner.name, PRM_Account_Id__r.RecordType.name, toLabel(PRM_Account_Id__r.Core_IPA_Partner_Role__c), PRM_Account_Id__r.Core_Account_Type__c,
                                                PRM_Account_Id__r.Core_Unified_Global_Customer_BP_Id__c,PRM_Account_Id__r.Core_Unified_Intermediate_Customer_BP_Id__c, PRM_Account_Id__r.Core_Unified_Global_Customer_Name__c
                                                FROM PRM_CIMSearchResults__c 
                                                WHERE PRM_RegReq_Id__c  =: regRecId];
        List<String> parentUnifiedId = new List<String>();
        Map<String,String> parentAccMap = new Map<String,String>();
                for (PRM_CIMSearchResults__c sbr : sbrList) {
          if(sbr.PRM_Account_Id__r.Core_Unified_Global_Customer_BP_Id__c!=null){
            parentUnifiedId.add(sbr.PRM_Account_Id__r.Core_Unified_Global_Customer_BP_Id__c);
          }
                    accidList.add(sbr.PRM_Account_Id__r.Id);
                }
        for(Account acc : [Select id,Core_Business_Party_Id__c from Account where Core_Business_Party_Id__c in: parentUnifiedId]){
            parentAccMap.put(acc.Core_Business_Party_Id__c,acc.id);
        }
                mapOfAccWithBlokedStatus= PRM_MatchingAccounts.getBlockedAccount(accidList);
        for (PRM_CIMSearchResults__c sbr : sbrList) {
                        accWrp = setMatchingAccWrapper (sbr,parentAccMap,mapOfAccWithBlokedStatus);
                        matchingAccList.add(accWrp);
                        
                    }
                   
            if(regReq.PRM_Matching_Contact__r.Email!=null && PRM_AdminRegistration.getBlockedAccountContact(regReq.PRM_Matching_Contact__r.Email,null) && permissionsAssignedToUsers.contains('PRM_Internal_Intel_Admin') && regReq.PRM_Status__c=='New'){
                dupAccWrp.isAdminUserCont=true;
            }else{
                dupAccWrp.isAdminUserCont=false;
            }
            if(regReq.PRM_Salesforce_ID__c!=null && PRM_AdminRegistration.getBlockedAccountContact(null ,regReq.PRM_Salesforce_ID__c) && permissionsAssignedToUsers.contains('PRM_Internal_Intel_Admin') && regReq.PRM_Status__c=='New'){
                dupAccWrp.isAdminUserAcc=true;
            }else{
                dupAccWrp.isAdminUserAcc=false;
            }
        //TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
                sortedMatchingAccs = matchingAccountSort (matchingAccList);  

                dupAccWrp.matchingAccList = sortedMatchingAccs;

                regRequestContactEmail = regReq.PRM_Email_ID__c;
                Map<String,Boolean> resultmp = isRequestDuplicate(regRequestContactEmail, regRecId);

                if(resultmp.get('isDuplicateRequest')) {
                    dupAccWrp.isRegRequestDuplicate = true;
                }
                dupAccWrp.accList = regRcd;

                extAccWrp = getExistingAccDetails(regReq); 
                dupAccWrp.salesforceAccountId = extAccWrp.salesforceAccountId;
                dupAccWrp.existingAccInfo = extAccWrp.existingAccInfo;
                dupAccWrp.existingAccountContactEmail  = extAccWrp.existingAccountContactEmail;

                regReqInfoWrp = getRegistrationReqInfo(regReq);
                dupAccWrp.accountContactEmail = regReqInfoWrp.accountContactEmail;
                dupAccWrp.isSystemAcc = regReqInfoWrp.isSystemAcc;
                dupAccWrp.isAccountInactive  = regReqInfoWrp.isAccountInactive;
                dupAccWrp.existingContactPartnerRole = regReqInfoWrp.existingContactPartnerRole;
                dupAccWrp.accountExistingPartnerRoleACMCheck = regReqInfoWrp.accountExistingPartnerRoleACMCheck;
                dupAccWrp.isMatchingContact = regReqInfoWrp.isMatchingContact;
              //  dupAccWrp.blockedAccount= PRM_MatchingAccounts.getBlockedAccount(PRM_Account_Id__c);

            }  
        } 
        catch (Exception e) { throw new AuraHandledException (e.getMessage());
        }
        return dupAccWrp;
    } 

    /*isRequestDuplicate*/
    public static Map<String,Boolean> isRequestDuplicate(String conEmail,String currentRequestId) {
        
        Map<String,Boolean> resultmp = new Map<String, Boolean>();
        //Boolean isDuplicateRequest = False;
        List<PRM_Registration_Request__c> regReqList=[Select id, PRM_Email_ID__c, PRM_Status__c from PRM_Registration_Request__c where PRM_Email_ID__c=:conEmail 
                                                      AND id!=:currentRequestId];
        //String isDuplicateRequest;
        //String isRegRequestDuplicateApproved;
        if(regReqList.size()>0 && regReqList[0].PRM_Status__c=='New') {
            resultmp.put('isDuplicateRequest',True);
        }
        else {
            resultmp.put('isDuplicateRequest',False); 
        }        
        return resultmp;
    }

    /*duplicateAccWrapper*/
    public class duplicateAccWrapper {
        @AuraEnabled
        public Boolean isSystemAcc {get;set;}
        @AuraEnabled
        public List<matchingAccWrapper> matchingAccList {get;set;} 
        @AuraEnabled
        public Boolean isAccountInactive{get;set;}//Added by Vijay Agate as a part of TWC729-1727
        @AuraEnabled
        public Boolean isRegRequestDuplicate{get;set;} 
        @AuraEnabled
        public PRM_Registration_Request__c accList{get;set;} 
        @AuraEnabled
        public String accountContactEmail{get;set;}
        @AuraEnabled
        public Boolean isMatchingContact{get;set;} 
        @AuraEnabled
        public String existingAccountContactEmail{get;set;}
        @AuraEnabled
        public String salesforceAccountId{get;set;}
        @AuraEnabled
        public Account existingAccInfo{get;set;}
        @AuraEnabled
        public String existingContactPartnerRole{get;set;}
        @AuraEnabled
        public Boolean accountExistingPartnerRoleACMCheck{get;set;}
        @AuraEnabled
        public Boolean isAdminUserCont{get;set;}
        @AuraEnabled
        public Boolean isAdminUserAcc{get;set;}
       
    }

    /*
    @dev - Shraddha M
    @desciption - System Account Check
    */
    public Static boolean CheckSystemAccount(String regEmailId) {
        Boolean isSysAccount = false;
        List<String> regReqEmailsList  =new List<String>();
        Map<String,Boolean> isSysAccMap = new Map<String,Boolean>();

        regReqEmailsList.add(regEmailId);
        //System Account Check
        if(regReqEmailsList.size()>0) {
            isSysAccMap= PRM_IPA_Utility.systemAccountDetails(regReqEmailsList);
            if(isSysAccMap.containsKey(regEmailId)) {
                isSysAccount = true;
            }       
        }
        return isSysAccount;
    }

    /*matchingAccWrapper*/
    public class matchingAccWrapper {
        @AuraEnabled
        public String accUrl {get;set;}
        @AuraEnabled
        public Id accId {get;set;}
        @AuraEnabled
        public String accName {get;set;}
        @AuraEnabled
        public String unifiedHierarchy {get;set;}
        @AuraEnabled
        public String aggrCode {get;set;}
        @AuraEnabled
        public String intrmdtCust {get;set;}
        @AuraEnabled
        public String unifiedId {get;set;}
        @AuraEnabled
        public String address {get;set;}
        @AuraEnabled
        public String bizOrgType {get;set;}
        @AuraEnabled
        public Boolean ipaAccount {get;set;}
        @AuraEnabled
        public String partnerRole {get;set;}
        @AuraEnabled
        public Boolean gecBlock {get;set;}
        @AuraEnabled
        public String recordType {get;set;}
        @AuraEnabled
        public String accountOwner {get;set;}
        @AuraEnabled
        public String parentAccUrl {get;set;}
        @AuraEnabled
        public String parentAccName {get;set;}
        @AuraEnabled
        public Boolean blockedAccount{get;set;}
    }

     /*
    @dev - Shraddha M
    @desciption - to set the Wrapper
    */
    public static matchingAccWrapper setMatchingAccWrapper (PRM_CIMSearchResults__c sbr,Map<String,String> parentAccMap, map<string,boolean> mapOfAccWithBlokedStatus) {
        matchingAccWrapper matchingAcc = new matchingAccWrapper();
     //   map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>();
      //  mapOfAccWithBlokedStatus=PRM_MatchingAccounts.getBlockedAccount(sbr.PRM_Account_Id__r.Id);
        matchingAcc.accUrl = '/'+ sbr.PRM_Account_Id__c;
        matchingAcc.accId = sbr.PRM_Account_Id__r.Id;
        matchingAcc.accName = sbr.PRM_Account_Id__r.Name;
        matchingAcc.unifiedHierarchy = sbr.PRM_Account_Id__r.Unified_Hierarchy_View__c; 
        matchingAcc.aggrCode = sbr.PRM_Account_Id__r.Core_Customer_Aggregation_Type__c;
        matchingAcc.intrmdtCust = sbr.PRM_Account_Id__r.Core_Unified_Intermediate_Customer_BP_Id__c;//TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Intermediate_Customer_BP_Id__c
        matchingAcc.unifiedId = sbr.PRM_Account_Id__r.Core_Business_Party_Id__c;
        matchingAcc.address = sbr.PRM_AddressLine1_Txt__c;
        matchingAcc.bizOrgType = sbr.PRM_Account_Id__r.Core_Account_Type__c;
        matchingAcc.ipaAccount = sbr.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c;
        matchingAcc.partnerRole = sbr.PRM_Account_Id__r.Core_IPA_Partner_Role__c;
        matchingAcc.gecBlock = sbr.PRM_Account_Id__r.Core_Export_Compliance_Block__c;
        matchingAcc.recordType = sbr.PRM_Account_Id__r.RecordType.name;
        matchingAcc.accountOwner = sbr.PRM_Account_Id__r.Owner.name;
    matchingAcc.parentAccUrl = parentAccMap.containsKey(sbr.PRM_Account_Id__r.Core_Unified_Global_Customer_BP_Id__c) ? '/' + parentAccMap.get(sbr.PRM_Account_Id__r.Core_Unified_Global_Customer_BP_Id__c) : '';//TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
        matchingAcc.parentAccName = sbr.PRM_Account_Id__r.Core_Unified_Global_Customer_Name__c != null ? sbr.PRM_Account_Id__r.Core_Unified_Global_Customer_Name__c : '';
        matchingAcc.blockedAccount= mapOfAccWithBlokedStatus.containsKey(sbr.PRM_Account_Id__r.Id)?mapOfAccWithBlokedStatus.get(sbr.PRM_Account_Id__r.Id):false;
        return matchingAcc;
    } 

    /*
    @dev - Shraddha M
    @desciption - to set the Wrapper
    */
    public static matchingAccWrapper setMatchingAccWrapper (Account acc,Map<String,String> parentAccMap,map<string,boolean> mapOfAccWithBlokedStatus) {
        matchingAccWrapper matchingAcc = new matchingAccWrapper();
       // map<string,boolean> mapOfAccWithBlokedStatus=new Map<String,Boolean>();
      //  mapOfAccWithBlokedStatus=PRM_MatchingAccounts.getBlockedAccount(acc.Id);
        matchingAcc.accUrl = '/'+ acc.Id;
        matchingAcc.accId = acc.Id;
        matchingAcc.accName = acc.Name;
        matchingAcc.unifiedHierarchy = acc.Unified_Hierarchy_View__c; 
        matchingAcc.aggrCode = acc.Core_Customer_Aggregation_Type__c;
        matchingAcc.intrmdtCust = acc.Core_Unified_Intermediate_Customer_BP_Id__c;//TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Intermediate_Customer_BP_Id__c
        matchingAcc.unifiedId = acc.Core_Business_Party_Id__c;
        matchingAcc.bizOrgType = acc.Core_Account_Type__c;
        matchingAcc.ipaAccount = acc.Core_Intel_Partner_Alliance_PartnerGroup__c;
        matchingAcc.partnerRole = acc.Core_IPA_Partner_Role__c;
        matchingAcc.gecBlock = acc.Core_Export_Compliance_Block__c;
        matchingAcc.recordType = acc.RecordType.name;
        matchingAcc.accountOwner = acc.Owner.name;
        matchingAcc.address = '';
        matchingAcc.blockedAccount= mapOfAccWithBlokedStatus.containsKey(acc.id)?mapOfAccWithBlokedStatus.get(acc.id):false;
        //to set full address
        if (acc.BillingStreet != null) {
            matchingAcc.address += acc.BillingStreet;
        }
        if (acc.BillingCity != null) {
            matchingAcc.address += ', ' + acc.BillingCity;
        }
        if (acc.BillingStateCode != null) {
            matchingAcc.address += ', ' + acc.BillingStateCode;
        }
        if (acc.BillingCountryCode != null) {
            matchingAcc.address += ', ' + acc.BillingCountryCode;
        }
        if (acc.BillingPostalCode != null) {
            matchingAcc.address += ', ' + acc.BillingPostalCode;
        }
        matchingAcc.parentAccUrl = parentAccMap.containsKey(acc.Core_Unified_Global_Customer_BP_Id__c)? ('/' + parentAccMap.get(acc.Core_Unified_Global_Customer_BP_Id__c) ): null;//TWC729-7054 - Nandana - new logic as part of removal of Core_Unified_Global_Customer__c
        matchingAcc.parentAccName = acc.Core_Unified_Global_Customer_Name__c;
        matchingAcc.blockedAccount= mapOfAccWithBlokedStatus.containsKey(acc.Id)?mapOfAccWithBlokedStatus.get(acc.Id):false;
        return matchingAcc;
    }


  
/*****************************************************************************************************************
* Method Name: matchingAccountSort
* Date: 04/12/2023    
* Owner: Sushmita
* Description: Sorts the list of accounts based on UnifiedHierarchy and IpaAccount 
******************************************************************************************************************/ 
    public static List<matchingAccWrapper> matchingAccountSort (List<matchingAccWrapper> acctList) {
        List<matchingAccWrapper> sortedAccs = new List<matchingAccWrapper>();
        Map<unifiedHierarchyType, List<matchingAccWrapper>> hierarchyToAccMap = new Map<unifiedHierarchyType, List<matchingAccWrapper>>();
    
        for  (matchingAccWrapper accsWrp : acctList) {
            unifiedHierarchyType unifiedHierarchyType = getunifiedHierarchyType (accsWrp.aggrCode, accsWrp.intrmdtCust, accsWrp.unifiedHierarchy, accsWrp.ipaAccount);
            
            if  (!hierarchyToAccMap.containsKey(unifiedHierarchyType)) {
                hierarchyToAccMap.put(unifiedHierarchyType, new List<matchingAccWrapper>());
            }
            hierarchyToAccMap.get(unifiedHierarchyType).add(accsWrp);
        }
    
        for  (unifiedHierarchyType type : unifiedHierarchyType.values()) {
            if  (hierarchyToAccMap.containsKey(type)) {
                sortedAccs.addAll (hierarchyToAccMap.get(type));
            }
        }
        return sortedAccs;
    }
    
    /*unifiedHierarchyType*/
    public enum unifiedHierarchyType {
        GlobalIpa,
        GlobalNonIpa,
        Intermediate1Ipa,
        Intermediate1NonIpa,
        Intermediate2Ipa,
        Intermediate2NonIpa,
        CountryIpa,
        CountryNonIpa,
        LocationIpa,
        LocationNonIpa,
        NotUnifiedIpa,
        NotUnifiedNonIpa,
        Ipa,
        NonIpa
    }

    /*getUnifiedHierarchyType*/
    private static unifiedHierarchyType getUnifiedHierarchyType (String aggrCode, String intermediateCust, String unifiedHierarchy, Boolean ipaAccount) {
        unifiedHierarchyType result = null;
        if (aggrCode != null) {
            result = handleAggrCode(aggrCode,intermediateCust,ipaAccount);
        }else {
            if (unifiedHierarchy == 'Not Unified') {
                result = ipaAccount ? unifiedHierarchyType.NotUnifiedIpa : unifiedHierarchyType.NotUnifiedNonIpa;
            }else if  (unifiedHierarchy == null) {
                result = ipaAccount ? unifiedHierarchyType.Ipa : unifiedHierarchyType.NonIpa;
            }
        }
        return result;
    } 

    /*handleAggrCode*/
    private static unifiedHierarchyType handleAggrCode(String aggrCode, String intermediateCust, Boolean ipaAccount) {
        unifiedHierarchyType unfdHierarchy = null;
        switch on aggrCode {
            when 'UNFD_GLBL_CUST' {
                unfdHierarchy = ipaAccount ? unifiedHierarchyType.GlobalIpa : unifiedHierarchyType.GlobalNonIpa;
            }
            when 'UNFD_INTRMD_CUST' {
                if (intermediateCust == null) {
                     unfdHierarchy = ipaAccount ? unifiedHierarchyType.Intermediate1Ipa : unifiedHierarchyType.Intermediate1NonIpa;
                 } else {
                     unfdHierarchy = ipaAccount ? unifiedHierarchyType.Intermediate2Ipa : unifiedHierarchyType.Intermediate2NonIpa;
                 }
            }
            when 'UNFD_CTRY_CUST' {
                unfdHierarchy = ipaAccount ? unifiedHierarchyType.CountryIpa : unifiedHierarchyType.CountryNonIpa;
            }
            when 'UNFD_LOC_CUST' {
                unfdHierarchy = ipaAccount ? unifiedHierarchyType.LocationIpa : unifiedHierarchyType.LocationNonIpa;
            }
        }
        return unfdHierarchy;
    }
    

    //getDeatils
    private static extAccWrapper getExistingAccDetails(PRM_Registration_Request__c regReq) {
        extAccWrapper extAccWrp = new extAccWrapper();
         //Keerthan added it as part of US570062
        if(regReq.PRM_Salesforce_ID__c != null) {
            Account existingAccount = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,
                                    Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_Export_Compliance_Block__c,
                                    Core_Account_Record_Type__c,toLabel(Core_IPA_Partner_Role__c),Owner.Name 
                                    From Account Where id =: regReq.PRM_Salesforce_ID__c];

            extAccWrp.salesforceAccountId = regReq.PRM_Salesforce_ID__c;
            extAccWrp.existingAccInfo = existingAccount;
            String partnerRoleExist = 'false';

            if(regReq.PRM_Partner_Role__c != null && String.isNotBlank(String.valueOf(regReq.PRM_Partner_Role__c))
                && existingAccount.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(existingAccount.Core_IPA_Partner_Role__c))
            ) {
                    String[] partnerRoleList = ((String)existingAccount.Core_IPA_Partner_Role__c).split(';');
                    if(partnerRoleList.contains(regReq.PRM_Partner_Role__c)) {
                        partnerRoleExist = 'true';
                    }
            }

            if(regReq.PRM_Email_ID__c != null) {
                List<Contact> con = [Select Id,Name from contact where Email =: regReq.PRM_Email_ID__c];
                if(con.size() == 0) {
                    String existingAccountName = existingAccount.Name;
                    extAccWrp.existingAccountContactEmail  = existingAccountName+';'+regReq.PRM_Email_ID__c+';'+partnerRoleExist;
                }
            }
        }      
        return extAccWrp;
    }

    /*ExistingAccDetailsWrapper*/
    public class extAccWrapper {
        @AuraEnabled
        public String existingAccountContactEmail{get;set;}
        @AuraEnabled
        public String salesforceAccountId{get;set;}
        @AuraEnabled
        public Account existingAccInfo{get;set;}
    }

    /*getRegistrationReqInfo*/
    private static regReqInfoWrapper getRegistrationReqInfo(PRM_Registration_Request__c regReq) {       
        regReqInfoWrapper regReqInfoWrp = new regReqInfoWrapper();
        Boolean isMatchingConPresent = false;
        String duplicateContactPartnerRole = '';
        Boolean accountExistingPartnerRoleACM;

        if(regReq.PRM_Email_ID__c !=null) {
            regReqInfoWrp.isSystemAcc = CheckSystemAccount(regReq.PRM_Email_ID__c);
        }
        if (regReq.PRM_Matching_Contact__c != null) {
            isMatchingConPresent = true;
            regReqInfoWrp.isAccountInactive = regReq.PRM_Matching_Contact__r.Account.Core_Deactivated__c; //Added by Vijay Agate as a part of TWC729-1727
            regReqInfoWrp.accountContactEmail = getAccountContactEmail(regReq);

            //Rahul added for US704683
            if(regReq.PRM_Matching_Contact__r.Core_IPA_PartnerRole__c != null 
                && String.isNotBlank(regReq.PRM_Matching_Contact__r.Core_IPA_PartnerRole__c)
            ) {
                
                Map<String,String> partnerLabelValueMap= new Map<String,String>();      
                Schema.DescribeFieldResult fieldResult1 = Contact.Core_IPA_PartnerRole__c.getDescribe();
                List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
                for(Schema.PicklistEntry pickListVal : ple1) {
                    partnerLabelValueMap.put(pickListVal.getValue(),pickListVal.getLabel());
                }                       
                duplicateContactPartnerRole = partnerLabelValueMap.get(regReq.PRM_Matching_Contact__r.Core_IPA_PartnerRole__c);
            } 
            else {
                accountExistingPartnerRoleACM = getAccountExistingPartnerRoleACM(regReq);
            }
        }
        regReqInfoWrp.isMatchingContact = isMatchingConPresent;
        regReqInfoWrp.existingContactPartnerRole = duplicateContactPartnerRole;
        regReqInfoWrp.accountExistingPartnerRoleACMCheck = accountExistingPartnerRoleACM;
        return regReqInfoWrp;
    }

    /*getAccountExistingPartnerRoleACM*/
    public static Boolean getAccountExistingPartnerRoleACM(PRM_Registration_Request__c regReq) {
        Boolean accExistingPartnerRoleACM;
         //No Partner Role at Contact
        //Associated Account has a partner role matching with New Registration Partner Role
        //Disable Approve/Reject - DE87425
        Set<String> setOfPartnerRole = new Set<String>();
        List<PRM_AccountChannelMembership__c> ACMStatusListRegReq = new List<PRM_AccountChannelMembership__c>();
        
        if(regReq.PRM_Matching_Contact__r.Account.Core_IPA_Partner_Role__c != null && String.isNotBlank(regReq.PRM_Matching_Contact__r.Account.Core_IPA_Partner_Role__c)
        ) {
            for(String s : regReq.PRM_Matching_Contact__r.Account.Core_IPA_Partner_Role__c.split(';')) {
                setOfPartnerRole.add(s);
            }
            
            if(regReq.PRM_Salesforce_ID__c != null) {
                ACMStatusListRegReq = [select id ,PRM_Status_Nm__c from  PRM_AccountChannelMembership__c where PRM_Account_Id__c =: regReq.PRM_Salesforce_ID__c and PRM_Status_Nm__c = 'Approved'];
                
                if(setOfPartnerRole.size() > 0 && String.isNotBlank(regReq.PRM_Partner_Role__c) && setOfPartnerRole.contains(regReq.PRM_Partner_Role__c) && !ACMStatusListRegReq.IsEmpty()) {
                    accExistingPartnerRoleACM = true;
                }
            } else {
                accExistingPartnerRoleACM = false;
            }
        }
        return accExistingPartnerRoleACM;
    }

    /*getAccountContactEmail*/
    private static String getAccountContactEmail(PRM_Registration_Request__c regReq) {
        String accountContactEmail;
        if(regReq.PRM_Matching_Contact__r.Email != null 
            && regReq.PRM_Matching_Contact__r.Email != '' 
            && regReq.PRM_Matching_Contact__r.Account.Name != null 
            && regReq.PRM_Matching_Contact__r.Account.Name != ''
        ) {
            accountContactEmail = regReq.PRM_Matching_Contact__r.Email+';'+regReq.PRM_Matching_Contact__r.Account.Name;
        }
        return accountContactEmail;
    }

    /*ExistingAccDetailsWrapper*/
    public class regReqInfoWrapper {
        @AuraEnabled
        public Boolean isSystemAcc{get;set;}
        @AuraEnabled
        public Boolean isAccountInactive{get;set;}
        @AuraEnabled
        public String accountContactEmail{get;set;}
        @AuraEnabled
        public String existingContactPartnerRole{get;set;}
        @AuraEnabled
        public Boolean accountExistingPartnerRoleACMCheck{get;set;}
        @AuraEnabled
        public Boolean isMatchingContact{get;set;} 
    }
}