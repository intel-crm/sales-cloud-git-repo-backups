/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-15-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class PRM_SalesCloudAccountIntStatus_Handler {
    public static List<String> configPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
   //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);  //IPA2.0-TWC727-2861
  /*List<SObject> newRecords {set; get;}
    Map<Id,SObject> oldRecords {set; get;}
    set<Id> accountIds {set; get;}
    String sObjectName {set; get;}
    List<String> configPartnerRoles {set; get;}
        public PRM_SalesCloudAccountIntStatus_Handler(List<SObject> newRecords,  Map<Id,SObject> oldRecords, set<Id> accountIds){
            this.newRecords = newRecords;
            this.oldRecords = oldRecords;
            this.accountIds = accountIds;
            this.sObjectName = sObjectName;
            configPartnerRoles = Label.PRM_AGSIdentityCreation_PartnerRoles.split(',');
        }
    public void execute(QueueableContext qc){
        if(newRecords instanceof List<PRM_AccountChannelMembership__c>) {
            setAccountIPAIntegrationStatusToPending( (List<PRM_AccountChannelMembership__c>) newRecords);
        }else if(newRecords instanceof List<PRM_Account_Specialty_Association__c>) {
            setAccountIPAIntegrationStatusToPending( (List<PRM_Account_Specialty_Association__c>) newRecords);
        }else if(newRecords instanceof List<PRM_AccountBenefitAssociation__c>) {
            setAccountIPAIntegrationStatusToPending( (List<PRM_AccountBenefitAssociation__c>) newRecords);
        }else if(newRecords instanceof List<Account>) {
            setAccountIPAIntegrationStatusToPendingOnUpdate( (List<Account>)newRecords, (Map<Id,Account>)oldRecords, accountIds);
        }else if(newRecords instanceof List<Core_Account_Group_Member__c>) {
            setAccountIPAIntegrationStatusToPending( (List<Core_Account_Group_Member__c>) newRecords);
        }
    }*/
    public static void setAccountIPAIntegrationStatusToPending(List<PRM_AccountChannelMembership__c> newAcms){
        //system.debug('setAccountIPAIntegrationStatusToPending  ACM');
        set<Id> acctIds = new set<Id>();
        for(PRM_AccountChannelMembership__c newAcm : newAcms) {
            acctIds.add(newAcm.PRM_Account_Id__c);
        }
        //system.debug('AcctIds ==>'+acctIds);
        if(acctIds.size() > 0) {
            updateAccountStatus(acctIds);
        }
    }
    
    //Added by Anand TB as part of US847809
    public static void setAccountIPAIntegrationStatusToPending(List<PRM_AccountLegalAgreemntAssociation__c> newAlas){
        //system.debug('setAccountIPAIntegrationStatusToPending  ALA');
        set<Id> acctIds = new set<Id>();
        for(PRM_AccountLegalAgreemntAssociation__c newAla : newAlas) {
            //UTKARSH - Put inactive indicator check
            if(newAla.PRM_InActive_Ind__c == false){
                acctIds.add(newAla.PRM_Account_Id__c);
            }
        }
       // system.debug('AcctIds ==>'+acctIds);
        if(acctIds.size() > 0) {
            updateAccountStatus(acctIds);
        }
    }
    
    public static void setAccountIPAIntegrationStatusToPending(List<PRM_Account_Specialty_Association__c> newAsas){
        //system.debug('setAccountIPAIntegrationStatusToPending  ASA');
        set<Id> acctIds = new set<Id>();
        /*if(!ipaRefresh  || test.isrunningtest()){ //IPA2.0-TWC727-2861
        for(PRM_Account_Specialty_Association__c newAsa : newAsas) {
            acctIds.add(newAsa.PRM_Account_Id__c);
        }
        if(acctIds.size() > 0) {
            updateAccountStatus(acctIds);
        }
    }*/ //IPA Refresh - switch removal
    }
    public static void setAccountIPAIntegrationStatusToPending(List<PRM_AccountBenefitAssociation__c> newAbas){
        //system.debug('setAccountIPAIntegrationStatusToPending  ABA');
        set<Id> acctIds = new set<Id>();
        for(PRM_AccountBenefitAssociation__c newAba : newAbas){
            acctIds.add(newAba.PRM_Account_Id__c);
        }
        for(Core_Account_Group_Member__c cag : [SELECT Core_Intel_Account_Id__c FROM Core_Account_Group_Member__c WHERE Core_Partner_Account_Id__c  IN:acctIds AND Core_Inactive_Ind__c = false ]){//TWC729-9275-To Create OBM on Intel account
            acctIds.add(cag.Core_Intel_Account_Id__c);
        }
        if(acctIds.size() > 0) {
            updateAccountStatus(acctIds);
        }
    }
    public static void setAccountIPAIntegrationStatusToPending(List<Core_Account_Whitelisted_Domains__c> newAWDs){
        //system.debug('setAccountIPAIntegrationStatusToPending  AWD');
        set<Id> acctIds = new set<Id>();
        for(Core_Account_Whitelisted_Domains__c newAWD : newAWDs) {
            acctIds.add(newAWD.Account__c);
        }
        if(acctIds.size() > 0) {
            updateAccountStatus(acctIds);
        }
    }
    
    public static void setAccountIPAIntegrationStatusToPending(List<PRM_Partner_Assist_Consent__c> newPAConsents){
        //system.debug('setAccountIPAIntegrationStatusToPending  PAConsents');
        set<Id> acctIds = new set<Id>();
        for(PRM_Partner_Assist_Consent__c newPAConsent : newPAConsents) {
            //UTKARSH - put inactive indicator check
            if(newPAConsent.PRM_InActive_Ind__c == false){
                acctIds.add(newPAConsent.PRM_Account_Id__c);
            }
        }
        if(acctIds.size() > 0) {
            updateAccountStatus(acctIds);
        }
    }
    public static void setAccountIPAIntegrationStatusToPending(List<PRM_Profile_Responses__c> newProfResps){
       // system.debug('setAccountIPAIntegrationStatusToPending  ProfResps');
        set<Id> acctIds = new set<Id>();
        for(PRM_Profile_Responses__c newProfResp : newProfResps) {
            acctIds.add(newProfResp.PRM_Account_Id__c);
        }
        if(acctIds.size() > 0) {
            updateAccountStatus(acctIds);
        }
    }
    
    public static void setAccountIPAIntegrationStatusToPendingOpId(List<Core_Account_Group_Member__c> newAgms, Set<Id> oldAcctIds){
        //system.debug('setAccountIPAIntegrationStatusToPending  AGM');
        set<Id> acctIds = new set<Id>();
       // set<Id> oPAcctIds = new set<Id>();
        for(Core_Account_Group_Member__c newAgm : newAgms) {
            acctIds.add(newAgm.Core_Partner_Account_Id__c);
            acctIds.add(newAgm.Core_Intel_Account_Id__c);
        }
        /*for(Core_Account_Group_Member__c agm : [SELECT Id, Core_Partner_Account_Id__c, Core_Intel_Account_Id__c
                                                FROM Core_Account_Group_Member__c
                                                WHERE Core_Partner_Account_Id__c IN: oPAcctIds]) {
                                                    acctIds.add(agm.Core_Intel_Account_Id__c);
                                                }*/
        //acctIds.addAll(oldAcctIds);
        if(acctIds.size() > 0) {
            updateAccountStatus(acctIds);
        }
    }
    
    public static void updateAccountStatus(Set<Id> acctIds){
        //system.debug('inside updateAccountStatus');
        List<Account> accountsToBeUpdated = new List<Account>();
        Map<id,Account> accountsMap = getAccountsMap(acctIds);
        if(accountsMap.size() > 0) {
            for(Account acct : accountsMap.values()) {
                if(acct.Channel_Memberships1__r.size() > 0 && acct.PRM_IPA_Integration_Status__c != 'Pending') {
                    acct.PRM_IPA_Integration_Status__c = 'Pending';
                    accountsToBeUpdated.add(acct);
                }
            }
           // system.debug('accountsToBeUpdated ==>'+accountsToBeUpdated);
            if(accountsToBeUpdated.size() > 0) {
                update accountsToBeUpdated;
            }
        }
    }
   















   public static void setAccountIPAIntegrationStatusToPendingOnUpdate(List<Account> newAccounts, Map<Id,Account> oldAccountsMap, Set<Id> accountIds){
        Set<Id> accountsToBeUpdated = new Set<Id>();
        //Map<id,Account> accountsMap = getAccountsMap(accountIds);
        //system.debug('accountsMap- '+accountsMap);
        //system.debug('newAccounts- '+newAccounts);
        //Set<Id> CIMUpdatedAcctIds = new Set<Id>();
        
        if(!FeatureManagement.checkPermission('PCC_Bypass_Automation')){
            for(Account newAccount : newAccounts) {
                Account oldAccount = oldAccountsMap.get(newAccount.Id);
                //TWC729-7726 : Cim Prime EOL - logic added for checking unified id change instead of cim id change when cimprime switch is true
                if((newAccount.RecordTypeId != oldAccount.RecordTypeId ||
                                                                    newAccount.Name != oldAccount.Name ||
                                                                    newAccount.Core_Business_Party_Id__c!= oldAccount.Core_Business_Party_Id__c||
                                                                    newAccount.BillingStreet != oldAccount.BillingStreet ||
                                                                    newAccount.BillingCity != oldAccount.BillingCity ||
                                                                    newAccount.BillingState != oldAccount.BillingState ||
                                                                    newAccount.BillingCountry != oldAccount.BillingCountry ||
                                                                    newAccount.BillingPostalCode != oldAccount.BillingPostalCode ||
                    												//TWC729-9386-Need to send service cloud account payload even when secondary address is changed- START
                    												newAccount.ShippingStreet != oldAccount.ShippingStreet ||
                    												newAccount.ShippingCity != oldAccount.ShippingCity ||
                    												newAccount.ShippingState != oldAccount.ShippingState ||
                        											newAccount.ShippingCountry != oldAccount.ShippingCountry ||
                    												newAccount.ShippingPostalCode != oldAccount.ShippingPostalCode ||
                    												//TWC729-9386-Need to send service cloud account payload even when secondary address is changed- END
                                                                    newAccount.Core_Account_Type__c != oldAccount.Core_Account_Type__c ||
                                                                    newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c != oldAccount.Core_Intel_Partner_Alliance_PartnerGroup__c ||
                                                                    /*(newAccount.Core_IPA_Partner_Segment__c != oldAccount.Core_IPA_Partner_Segment__c && !boolean.valueOf(label.PRM_IPARefresh)) ||*/
                                                                    newAccount.Core_IPA_Partner_Role__c != oldAccount.Core_IPA_Partner_Role__c ||
                                                                    newAccount.Core_IPA_Badge_Tier__c != oldAccount.Core_IPA_Badge_Tier__c )) {
                                                                    if(newAccount.PRM_IPA_Integration_Status__c != 'Pending') {
                                                                            //Account acct = new Account(Id=newAccount.Id, PRM_IPA_Integration_Status__c = 'Pending');
                                                                        accountsToBeUpdated.add(newAccount.Id); 
                                                                        //newAccount.PRM_IPA_Integration_Status__c = 'Pending';
                                                                            /*
                                                                            if(String.isEmpty(oldAccount.Core_CIM_ID__c) && newAccount.Core_CIM_ID__c != oldAccount.Core_CIM_ID__c){
                                                                                CIMUpdatedAcctIds.add(newAccount.Id);
                                                                            }*/
                                                                            //accountsToBeUpdated.add(acct);
                                                                        }
                                                                    }
            }
            if(!accountsToBeUpdated.isEmpty()){
                Map<id,Account> accountsMap = getAccountsMap(accountsToBeUpdated);
                for(Account newAccount : newAccounts){
                    if(accountsMap.containsKey(newAccount.id) && accountsMap.get(newAccount.Id).Channel_Memberships1__r.size() > 0){
                            newAccount.PRM_IPA_Integration_Status__c = 'Pending';    
                    }
                }  
            }
            /*if(accountsToBeUpdated.size() > 0) {
                system.debug('actual update');
                update accountsToBeUpdated;
            }*/
            /*
            if(CIMUpdatedAcctIds.size() > 0){
                List<Contact> contactsTobeUpdated = [SELECT Id,PRM_IPA_Integration_Status__c FROM Contact WHERE AccountId IN :CIMUpdatedAcctIds AND PRM_IPA_Integration_Status__c!=null AND PRM_IPA_Integration_Status__c!='Pending'];
                if(contactsTobeUpdated.size() > 0){
                    for(Contact cont:contactsTobeUpdated){
                    cont.PRM_IPA_Integration_Status__c = 'Pending';
                    }
                    update contactsTobeUpdated;
                }
            }*/
        }
    }      
    public static Map<Id,Account> getAccountsMap(Set<Id> accountIds) {
        //system.debug('configPartnerRoles ==>'+configPartnerRoles);
        //Id PAGRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        /*return new Map<Id,Account>([ SELECT id,PRM_IPA_Integration_Status__c,
                                    (SELECT PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c
                                     FROM Channel_Memberships1__r WHERE PRM_Partner_Role__c NOT IN: configPartnerRoles AND PRM_Status_Nm__c != 'Pending' LIMIT 1)
                                    FROM Account WHERE Id IN: accountIds]);*/
        //TWC729-7584 - ApexGuru
        return new Map<Id,Account>([ SELECT id,PRM_IPA_Integration_Status__c,
                                    (SELECT PRM_Channel_Program_Id__r.Name,PRM_Channel_Program_Id__r.PRM_programCode__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Partner_Role__c,PRM_Status_Nm__c
                                     FROM Channel_Memberships1__r WHERE PRM_Partner_Role__c NOT IN: configPartnerRoles AND PRM_Status_Nm__c IN ('Approved','Inactive') LIMIT 1)
                                    FROM Account WHERE Id IN: accountIds]);
        
    }
}