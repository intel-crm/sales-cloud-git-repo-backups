/*Function      : Displaying duplicate account and contact details in the Admin Registration UI 

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nishant      11 November,2019            Displaying duplicate account and contact details in the Admin Registration UI

*********************************************************************************************************************/
public without sharing class PRM_AdminRegistrationDuplicateDetails {
    @AuraEnabled
    public static accountContactList showAccountsContacts(map<string,string> requestDetails){
        list<Account> accountDetails = new list<Account>();
        list<Contact> contactDetails = new list<Contact>();
        map<string,account> addrAccountMap = new map<string,account>();
        accountContactList accCntList = new accountContactList();
        Account accountAssociatedToExistingContact = new Account() ;
        Contact duplicateContactRecord = new Contact();
        Boolean associatedAccountIsIPA = false;
        Boolean accountMatchSfdc = false;
        String regAccountCimId;
        List<Contact> existingContact = new List<Contact>();


        List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fDetails  = new List<UCD_GenericAcctSearch_SBR.fieldsetwrapper>();
        List<Account> accList = new List<Account>();
        List<AccountDetailsWrp> accWrpList = new List<AccountDetailsWrp>();


        try{
            system.debug(requestDetails);
            String billingStreet;
            set<id> reqAccId = new set<id>();
            String duplicateInfo = requestDetails.get('DuplicateInfo');
            String accountName = requestDetails.get('AccountName').trim();
            String contactEmail = requestDetails.get('ContactEmail').trim();
            String addressLineOne = requestDetails.get('AddressLine1').trim();
            String emailAddr = requestDetails.get('ContactEmail').trim();
            String bizOrgtype = requestDetails.get('BizOrgType').trim();

            
            String country = requestDetails.get('Country').trim();
            String state = requestDetails.get('State').trim();
            String website = requestDetails.get('Website').trim();

            fDetails.add(setfieldsetwrapper('Name', 'Name', accountName));
            fDetails.add(setfieldsetwrapper('Core_Requested_Name__c', 'Core_Requested_Name__c', accountName));
            fDetails.add(setfieldsetwrapper('BillingCountry', 'BillingCountry', country));
            fDetails.add(setfieldsetwrapper('BillingState', 'BillingState', state));
            fDetails.add(setfieldsetwrapper('Website', 'Website', website));
            fDetails.add(setfieldsetwrapper('Core_MDM_Website__c', 'Core_MDM_Website__c', website));
            
            //Rahul added
            //Querying metatdata for getting 2 digit country code for calling cim
            Map<String,String> countryMap = new map<String,String>();
            for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                countryMap.put(allCountries.ISO_Code__c, allCountries.Country_Code__c);
            }
            System.debug('countryMap'+countryMap);
            
            Map<String,String> roleTypeMap = new Map<String,String>();
            for(PRM_PartnerRoleTypeMappings__mdt roleTypeReq : [Select Id,PRM_Biz_Org_Type__c,PRM_Partner_Role__c	
                                                                from PRM_PartnerRoleTypeMappings__mdt]){
                                                                    roleTypeMap.put(roleTypeReq.PRM_Biz_Org_Type__c, roleTypeReq.PRM_Partner_Role__c);
                                                                }
            
            String partnerRole = roleTypeMap.get(bizOrgtype).trim();
            system.debug('partnerROLE >>>>'+partnerRole);
            if (requestDetails.get('AddressLine2')!=null && requestDetails.get('AddressLine2')!=' ' && requestDetails.get('AddressLine2')!=''){
                billingStreet = addressLineOne+' '+requestDetails.get('AddressLine2').trim();   
            }else{
                billingStreet = addressLineOne; 
            }        
            String billingCity , billingState , billingPostalCode ,billingCountry,billingCountryForCallout ;
            if( requestDetails.get('City')!= null &&  requestDetails.get('City')!= '')  billingCity = requestDetails.get('City').trim();
            if( requestDetails.get('State')!= null &&  requestDetails.get('State')!= '') billingState = requestDetails.get('State').trim();
            if( requestDetails.get('PostalCode')!= null &&  requestDetails.get('PostalCode')!= '') billingPostalCode = requestDetails.get('PostalCode').trim();
            if( requestDetails.get('Country')!= null &&  requestDetails.get('Country')!= '') billingCountry = requestDetails.get('Country').trim();
            system.debug('accountName -->'+accountName);
            
            // Search the Account first in SFDC org
            for(Account acc : [select Id,Name,Unified_Hierarchy_View__c,Core_Business_Party_Id__c,Core_Address_Details__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Industry from Account where name=:accountName and BillingState=: billingState and BillingPostalCode=:billingPostalCode and BillingCountry=:billingCountry ]){
                if(billingStreet.trim().replaceAll('(\\s+)', '') == acc.BillingStreet.trim().replaceAll('(\\s+)', '') && billingCity.trim().replaceAll('(\\s+)', '') == acc.BillingCity.trim().replaceAll('(\\s+)', '')){
                    reqAccId.add(acc.id);
                    accCntList.displayRequestedAccount = True;
                    accountMatchSfdc = true;
                    AccountDetailsWrp acWrp = setaccWrp(acc.Id , acc.Name, acc.Unified_Hierarchy_View__c, acc.Core_Business_Party_Id__c, acc.Core_Address_Details__c, 
                                                    acc.Core_Account_Type__c, acc.Core_Intel_Partner_Alliance_PartnerGroup__c, acc.Core_IPA_Partner_Role__c);
                    accWrpList.add(acWrp);
                    //accCntList.accountDupStatus= 'NoDup';
                }
            }


            //call UCD SBR
            accWrpList.addAll(searchAccountFromUCDSBR(fDetails));
            accCntList.accountList = accWrpList;

            //Rahul added
            //replacing 3 digit country code to 2 digit country code for calling PRM_UICIMCallout
            if(billingCountry.length() == 3 && countryMap != null){
                billingCountryForCallout = countryMap.get(billingCountry);
            }
            System.debug('billingCountryForCallout'+billingCountryForCallout);
            
            existingContact = [select id,name,email,accountId from contact where email=:contactEmail];
            
            // Search the existing Contact in SFDC org
            if(existingContact.size() > 0){
                for(Contact cntc : existingContact){
                    contactDetails.add(cntc); 
                    // accCntList.accountDupStatus= 'NoDup';
                    accCntList.displayRequestedAccount = False;
                    accCntList.accountList = null;
                }
            }
			accCntList.contactList=contactDetails;
            
            if(contactDetails != null && contactDetails.size()>0)
            {
                accCntList.contactDupStatus = 'Duplicate' ;
                accountAssociatedToExistingContact = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Industry from Account where id = : contactDetails[0].Accountid ];
                List<ChannelProgram> chProgramList = [select id from ChannelProgram where prm_programCode__c=: System.Label.PRM_IPAEngagement];
                String ipaChannelPgmId ;
                if(ChProgramList != null && ChProgramList.size()>0)
                {
                    ipaChannelPgmId = ChProgramList[0].id;
                }
                List<PRM_AccountChannelMembership__c> associatedACMList = new List<PRM_AccountChannelMembership__c>();
                associatedACMList = [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: accountAssociatedToExistingContact.id and PRM_Channel_Program_Id__c =: ipaChannelPgmId and PRM_Partner_Role__c =:requestDetails.get('PartnerRole') and PRM_Status_Nm__c != 'Inactive' and PRM_Status_Nm__c !='' ];
                accCntList.accountAssociatedToExistingContact = accountAssociatedToExistingContact;
                accCntList.duplicateContactRecord = contactDetails[0];
                if(associatedACMList != null && associatedACMList.size()>0)
                {
                    associatedAccountIsIPA = true;
                }
            }
            else
            {
                accCntList.contactDupStatus = 'NoDuplicate' ;
                accCntList.accountAssociatedToExistingContact = null;
                duplicateContactRecord = null ;
            }
            accCntList.associatedAccountIsIPA = associatedAccountIsIPA;
            system.debug('accountAssociatedToExistingContact found -->'+accCntList.accountAssociatedToExistingContact);
            system.debug('accountContactList -->'+accCntList);
        } 
        catch(Exception e){
            
            PRM_ErrorUtilityClass.logError(e);
            system.debug('exc::'+e.getMessage());
            
        }
        return accCntList;
    }
    // Wrapper class for the account and contact details
    public class accountContactList {
        
        @AuraEnabled
        public list<AccountDetailsWrp> accountList = new list<AccountDetailsWrp>();
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


    Public Static List<AccountDetailsWrp> searchAccountFromUCDSBR(List<UCD_GenericAcctSearch_SBR.fieldsetwrapper> fDetails){

        Map<Id, Account> sfdcAccMap = new Map<Id, Account>();
        Map<Id, UCD_GenericAcctSearch_SBR.AccountSearchDataModel> ucdAccDetailsMap = new Map<Id, UCD_GenericAcctSearch_SBR.AccountSearchDataModel>();
        List<AccountDetailsWrp> accWrpList = new List<AccountDetailsWrp>();

        // String accountName = requestDetails.get('AccountName').trim();
        // String country = requestDetails.get('Country').trim();
        // String state = requestDetails.get('State').trim();
        // String website = requestDetails.get('Website').trim();

        List<UCD_GenericAcctSearch_SBR.AccountSearchDataModel> accDetails= UCD_GenericAcctSearch_SBR.getAcctResults(fDetails, 'Partner');

        System.debug('accDetails--->'+accDetails);

        for(UCD_GenericAcctSearch_SBR.AccountSearchDataModel adm : accDetails){
            ucdAccDetailsMap.put(adm.accId, adm);
        }

        if(ucdAccDetailsMap!= null){
            for(Account acc : [SELECT Id, Name, Unified_Hierarchy_View__c,Core_Business_Party_Id__c,  Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Account_Type__c, Core_IPA_Partner_Role__c 
                              FROM Account WHERE Id IN: ucdAccDetailsMap.keyset()]
            ){
                AccountDetailsWrp acWrp = setaccWrp(acc.Id , acc.Name, acc.Unified_Hierarchy_View__c, acc.Core_Business_Party_Id__c, acc.Core_Address_Details__c, 
                                                    acc.Core_Account_Type__c, acc.Core_Intel_Partner_Alliance_PartnerGroup__c, acc.Core_IPA_Partner_Role__c);
                accWrpList.add(acWrp);
            }
        }

        return accWrpList;

    }

    public static UCD_GenericAcctSearch_SBR.Fieldsetwrapper setfieldsetwrapper(String fieldLabel, String fieldAPIName, String fieldValue){
        UCD_GenericAcctSearch_SBR.Fieldsetwrapper fdWrp = new UCD_GenericAcctSearch_SBR.Fieldsetwrapper();
        fdWrp.fieldLabel = fieldLabel;
        fdWrp.fieldAPIName = fieldAPIName;
        fdWrp.fieldValue = fieldValue;

        return fdWrp;
    }

    public class AccountDetailsWrp{
        @AuraEnabled
        public Id accId{get;set;}
        @AuraEnabled
        public String accName{get;set;}
        @AuraEnabled
        public String unifiedHierarchy{get;set;}
        @AuraEnabled
        public String unifiedId{get;set;}
        @AuraEnabled
        public String address{get;set;}
        @AuraEnabled
        public String bizOrgType{get;set;}
        @AuraEnabled
        public Boolean ipaAccount{get;set;}
        @AuraEnabled
        public String partnerRole{get;set;}
        // @AuraEnabled
        // public String unifiedGlobalCustomer{get;set;}
        // @AuraEnabled
        // public String recordUrl{get;set;}
        // @AuraEnabled
        // public String requestedName{get;set;}
    }


    public static AccountDetailsWrp setaccWrp(Id accId, String accName, String unifiedHierarchy,  String unifiedId, String address, String bizOrgType, Boolean ipaAccount, String partnerRole){
        AccountDetailsWrp accWrp = new AccountDetailsWrp();
        accWrp.accId = accId;
        accWrp.accName = accName;
        accWrp.unifiedHierarchy = unifiedHierarchy;
        accWrp.unifiedId = unifiedId;
        accWrp.address = address;
        accWrp.bizOrgType = bizOrgType;
        accWrp.ipaAccount = ipaAccount;
        accWrp.partnerRole = partnerRole;

        return accWrp;
    }

}