/******************************************************************************************************************************************
Class Name  : Core_IntegrationInboundMsgERPM_Account
Version     : 1.0
Created Date: 31 May 2017
Function    : Business logic for processing inbound ERPM messages

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------
* Dave Hood                 11/03/2016              Original version
* Team: popcorn Apps        31/05/2017              New class created from Core_IntegrationInboundMsgERPM with a single method processAccountMessages
Changes: Code clean up and reorganize

*****************************************************************************************************************************************/
public class Core_IntInboundMsgERPM_Account{
    
    //public static final String B2B_DEDUP_GROUP_CODE = 'DEDUPB2B';Moved to Custom Label
    //public static final String RDC_ACCOUNT_INDUSTRY = 'Others';Moved to Custom Label            // TO DO: finalize this with Jordan
    //public static final String RDC_ACCOUNT_TYPE = 'Other';Moved to Custom Label                 // TO DO: finalize this with Jordan
    // public static final String RDC_ACCOUNT_SALES_GROUP = 'Regional Sales';Moved to Custom Label // TO DO: finalize this with Jordan
    //public static final String RDC_ENGAGEMENT_CODE = 'IRDC_Priv';Moved to Custom Label
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_SCOPE = 'IntegrationInboundMessageERPM';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Inbound_Message__c';
    
    // Custom exception we can throw ourselves. Needed to get certain code paths to execute in test classes.
    public class CustomException extends Exception {}
    
    // Main method for processing ERPM Account messages
    public static void processAccountMessages(List<Core_Integration_Inbound_Message__c> newList) {
        
        // Note: currently we have a single status for the whole batch, which all records will be set to. This is fine
        // for now, since iPaaS won't be sending batches. But goal state should be to have separate status per message.
        String processingStatus = 'Successful';
        String processingMessage = 'Timestamp: ' + Datetime.now() + ' GMT';
        Id logEntryId = null;
        
        
        
        Set<Id> msgIds = new Set<Id>();
        
        List<Core_IntegrationUtility.ERPM_Account> erpmAccounts = new List<Core_IntegrationUtility.ERPM_Account>();
        
        Set<Id> SFAccountIds  = new Set<Id>();
        Set<String> erpmCIMIDs = new Set<String>();
        //Added New set variable for ERPMAccountnumbers as part of ERPM-SF Optimization
        Set<String> erpmAccountNumbers = new Set<String>();
        List<Account> matchSFaccounts =new List<Account>();
        List<Core_IntegrationUtility.ERPM_Engagement> erpmEnggs = new List<Core_IntegrationUtility.ERPM_Engagement>();
        Set<String> erpmEnggCodes = new Set<String>();
        Map<Id,String> matchingSfIdCimIdMap = new Map<Id,String>();
        List<ERPM_AccountWrapper> accountWrappers = new List<ERPM_AccountWrapper>();
        
        // Build up "tags" for log entry/inbound message below
        String tags = '';
        List<String> PRMEngagements = string.isNotBlank(Label.PRM_IPA_Engagements) ? Label.PRM_IPA_Engagements.split(',') : null;
        Set<String>erpmAcctEnggCodes = new Set<String>();
        //--------------------------------------------------------------------------------------------------
        // PARSE MESSAGES & GET RELEVANT ID VALUES
        
        for (Core_Integration_Inbound_Message__c msg : newList) {
            
            // Only process messages inserted as "Pending"
            if ((msg.Core_Processing_Status__c == 'Pending') && (Core_IntegrationUtility.getFullPayload(msg)!= null)) {
                try {
                    System.debug('##### Processing message: ' + msg);
                    msgIds.add(msg.Id);
                    
                    // Parse the payload into an object, then add it to our collection of erpmPersons
                    Core_IntegrationUtility.ERPM_Account acct =
                        Core_IntegrationInboundMessageParsing.parseAccount(Core_IntegrationUtility.getFullPayload(msg));
                    System.debug('##### ERPM Account message parsed into an object: ' + acct);
                    System.debug('##### ERPM Account message parsed into an object: ' + acct.eRPM_Benefits);
                    
                    erpmAccounts.add(acct);
                    
                    
                    // Save the necessary ID values into collections that we'll need in upcoming SELECT statements
                    
                    //Optimization both sfid and cimid combination - This's Good to have condition
                    if(!String.isBlank(acct.sfdcId) && !String.isBlank(acct.cimId)) {
                        System.debug('acct.sfdcId'+ acct.sfdcId +' CIM'+ acct.cimId);
                        SFAccountIds.add(acct.sfdcId);
                        erpmCIMIds.add(acct.cimId);
                        tags += Core_IntegrationUtility.addTag(acct.sfdcId);
                        tags += Core_IntegrationUtility.addTag(acct.cimId);
                    }
                    else if (!String.isBlank(acct.sfdcId)) {
                        SFAccountIds.add(acct.sfdcId);
                        tags += Core_IntegrationUtility.addTag(acct.sfdcId);
                    }
                    //consider cimId and erpm acct number combination ERPM-SF Optimization
                    else if (!String.isBlank(acct.cimId)) {
                        erpmCIMIds.add(acct.cimId);
                        if(!String.isBlank(acct.erpmAccountNumber))
                            erpmAccountNumbers.add(acct.erpmAccountNumber);
                        string sfID=Core_IntegrationOptimization.GetMatchingAccountSFIDfromCIMID(erpmCIMIds,erpmAccountNumbers);
                        System.debug('testAcct'+sfID);
                        if(sfID!=null && sfID !=''){
                            SFAccountIds.Add(sfID);
                        }
                    }
                    
                    tags += Core_IntegrationUtility.addTag(acct.cimId);
                    /* else if (!String.isBlank(acct.cimId)) {
                    System.debug('CIMId only'+acct.cimId);
                    erpmCIMIds.add(acct.cimId);
                    tags += Core_IntegrationUtility.addTag(acct.cimId);
                    }*/
                    if (!String.isBlank(acct.erpmAccountNumber)) {
                        System.debug('Account No. only'+acct.erpmAccountNumber);
                        tags += Core_IntegrationUtility.addTag(acct.erpmAccountNumber);
                    }
                    
                    for (Core_IntegrationUtility.ERPM_Engagement engg : acct.accountEngagements) {
                        erpmEnggs.add(engg);
                        erpmEnggCodes.add(engg.engagementCode);
                        if(PRMEngagements.Contains(engg.engagementCode))
                            erpmAcctEnggCodes.add(engg.engagementCode);
                        
                    }
                }
                catch(Exception ex) {
                    
                    processingStatus = 'Failed';
                    processingMessage += ', Message 3: ' + Core_IntegrationUtility.exceptionMessageGenerator(ex);
                    
                    logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                      'Error reading ERPM Account message', '', msg.Id, LOG_ENTRY_OBJECT, '', ex);
                }
            }
        }
        
        //--------------------------------------------------------------------------------------------------
        // PULL ALL RECORDS WE'LL NEED FOR FURTHER PROCESSING
        
        try {
            // Accounts
            List<Account> matchingAccounts = new List<Account>();
            Set<Id> matchingAccountIds = new Set<Id>();
            Map<Id,Account> matchingAccountIdMap = new Map<Id,Account>();
            Map<String,Account> matchingAccountCIMIdMap = new Map<String,Account>();
            //ERPM-SF Optimization
            
            
            System.debug('erpmCIMIds'+erpmCIMIds);
            System.debug('SFAccountIds'+SFAccountIds);
            // Pull by SFDC IDs if we have them. Pull by CIM IDs if we don't. (Ideally this should handle a mix,
            // but I'm keeping the code simple at this point, since we won't get a mix.)            
            //ERPM-SF Optimization
            if (SFAccountIds.size() > 0) {                                                      
                
                for (Account a : [select Id, Core_CIM_ID__c, CreatedDate, Core_B2B_Entitlement__c, 
                                  Core_IPA_Partner_Role__c, Core_Account_Type__c, Core_IPA_Partner_Speciality__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Sales_Groups__c,Industry
                                  from Account where Id in :SFAccountIds]) {
                                      matchingAccountIds.add(a.Id);
                                      matchingAccountIdMap.put(a.Id, a);
                                      if (!matchingAccountCIMIdMap.containsKey(a.Core_CIM_ID__c)) {
                                          matchingAccountCIMIdMap.put(a.Core_CIM_ID__c, a);
                                          //ERPM-SF Optimization
                                          matchingSfIdCimIdMap.put(a.Id,a.Core_CIM_ID__c);
                                      }
                                  }
            }
            // Account ERPM Engagements
            List<Core_Account_ERPM_Engagement__c> matchingAccountERPMEngagements = new List<Core_Account_ERPM_Engagement__c>();
            Map<Id,List<Core_Account_ERPM_Engagement__c>> matchingAccountERPMEngagementMap =
                new Map<Id,List<Core_Account_ERPM_Engagement__c>>();                   
            
            if (matchingAccountIds.size() > 0) {
                //Added Core_ERPM_Account_Number__c field in select- ERPM-SF Optimization               
                for (Core_Account_ERPM_Engagement__c aee :  [select Id, Core_Account_Id__c, Core_ERPM_Engagement_Id__c, Core_ERPM_Business_Attributes__c,
                                                             Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c,Core_ERPM_Account_Number__c
                                                             from Core_Account_ERPM_Engagement__c
                                                             where Core_Account_Id__c in :matchingAccountIds]) {                                                                                                                                  
                                                                 if (!matchingAccountERPMEngagementMap.containsKey(aee.Core_Account_Id__c))                                                                    
                                                                     matchingAccountERPMEngagementMap.put(aee.Core_Account_Id__c, new List<Core_Account_ERPM_Engagement__c>{aee});                                                                 
                                                                 else
                                                                     matchingAccountERPMEngagementMap.get(aee.Core_Account_Id__c).add(aee);                                                                 
                                                             }
            }
            system.debug('matchingAccountERPMEngagementMap'+matchingAccountERPMEngagementMap);
            // ----------- #REGION :: eRPM Code Changes :: START ------------- //
            //eRPM-SF integration get existing Account Channel Memberships
            Map<Id,List<PRM_AccountChannelMembership__c>> matchingAccountChnlMembMap = 
                new Map<Id,List<PRM_AccountChannelMembership__c>>();
            if (matchingAccountIds.size() > 0) {
                for(PRM_AccountChannelMembership__c acm : [SELECT Id, PRM_Account_Id__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,
                                                           PRM_Channel_Program_Id__r.PRM_programCode__c, PRM_Status_Nm__c, PRM_Status_Reason_Txt__c,
                                                           PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c, PRM_Partner_Role__c
                                                           FROM PRM_AccountChannelMembership__c 
                                                           WHERE PRM_Account_Id__c in :matchingAccountIds AND PRM_Channel_Program_Id__r.PRM_programCode__c =: Label.PRM_IPAEngagement]){                                                               
                                                               if (!matchingAccountChnlMembMap.containsKey(acm.PRM_Account_Id__c))                                                                    
                                                                   matchingAccountChnlMembMap.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});                                                                 
                                                               else
                                                                   matchingAccountChnlMembMap.get(acm.PRM_Account_Id__c).add(acm);   
                                                           }
                system.debug('matchingAccountChnlMembMap :'+matchingAccountChnlMembMap);
            }
            // ----------- #REGION :: eRPM Code Changes :: END ------------- //
            
            // ERPM Engagements
            List<Core_ERPM_Engagement__c> matchingERPMEngagements = new List<Core_ERPM_Engagement__c>();
            Set<Id> matchingERPMEngagementIds = new Set<Id>();
            
            if (matchingAccountERPMEngagements.size() > 0) {                        
                for (Core_ERPM_Engagement__c engg : [select Id, Name, Core_Technical_Name__c, Core_Description__c, Core_Technical_Engagement_Code__c
                                                     from Core_ERPM_Engagement__c
                                                     where Core_Technical_Engagement_Code__c in :erpmEnggCodes])
                    matchingERPMEngagementIds.add(engg.Id);
            }
            
            // Entitlements
            List<Core_Entitlement__c> matchingEntitlements = new List<Core_Entitlement__c>();
            
            if (matchingERPMEngagements.size() > 0) {
                
                matchingEntitlements = [
                    select Id, Name, Core_ERPM_Engagement_Id__c, Core_Display_Name__c, Core_Description__c
                    from Core_Entitlement__c
                    where Core_ERPM_Engagement_Id__c in :matchingERPMEngagementIds and Core_AGS_Role_Id__c = ''];
            }
            
            // Collections for Account INSERTs and UPDATEs
            List<Account> accountsToInsert = new List<Account>();
            List<Account> accountsToUpsert = new List<Account>();
            
            // ----------- #REGION :: eRPM Code Changes :: START ------------- //
            List<Core_IntegrationUtility.eRPM_Profile_Response> eRPM_ProfileResponses = new List<Core_IntegrationUtility.eRPM_Profile_Response>();
            //Get the list of PRM engagements from Label
            
            system.debug('PRMEngagements:'+PRMEngagements);
            boolean IsPRMEngagement = false;
            string eRPM_engagementcode = '';
            if(PRMEngagements !=null && PRMEngagements.size() > 0) {
                for(string enggCode : erpmEnggCodes){
                    if(PRMEngagements.contains(enggCode))
                    {
                        IsPRMEngagement = true;
                        eRPM_engagementcode = enggCode;
                        break;
                    }
                }                
            }
            
            // ----------- #REGION :: eRPM Code Changes :: END   ------------- //
            
            //--------------------------------------------------------------------------------------------------
            //PMD Issue Fix
            //String ACCOUNT_KEY = 'ACCOUNTKEY';
            //Integer keyNum = 0;            
            List<ERPM_SF_MAPPING_SETTING__mdt> eRPMSFMappingSettingMdt = [SELECT SF_KeyValue__c, eRPM_KeyValue__c, eRPM_EngagementCodes__c, Mappting_Type__c
                                                                                    FROM ERPM_SF_MAPPING_SETTING__mdt
                                                                                    WHERE (Mappting_Type__c =: Label.PRM_Partner_Role
                                                                                           OR Mappting_Type__c =: Label.PRM_Biz_Org_Type 
                                                                                           OR Mappting_Type__c = : Label.PRM_IPA_Partner_Specialty)
                                                                                    AND eRPM_EngagementCodes__c IN: erpmEnggCodes];
            Set<Id> accountIdsTobeUpdated = new Set<Id>();
            List<Account> allAccountsToBeUpserted = new List<Account>();
            List<Account> allAccountsToBeUpdated = new List<Account>();
            
            // ACCOUNT RECORD INSERTS & UPDATES            
            // Loop through collection of erpmAccounts...
            for (Core_IntegrationUtility.ERPM_Account acct : erpmAccounts) 
            {
                System.debug('##### Operating on this account message to check for account inserts & updates: ' + acct);
                System.debug('acct.primary'+acct.primaryStreet1);
                
                if (acct.sfdcId == '')
                    acct.sfdcId = null;
                
                System.debug('erpmAcctEnggCodes' +erpmAcctEnggCodes);
                System.debug('erpmEnggCodes'+erpmEnggCodes);
                //Check for ITP benefit.
                if(!acct.eRPM_isITPBenefitCheck  && erpmAcctEnggCodes.Size()==1 && erpmAcctEnggCodes.Contains(Label.AllowedPRMEngagenents))
                {
                    System.debug('##Only ITP account');
                    acct.ignoreMessage = true;  
                    acct.ignoreReason='Account Message Ignored because ITP account doesnt have allowed benefits.';
                    
                }                
                
                System.debug('acct.ignoreMessage' +acct.ignoreMessage);
                // For each, check to see if an Account needs to be INSERTed
                if(!acct.ignoreMessage){
                    Account accountToUpsert= new Account();
                    
                    if (!matchingAccountIds.contains(acct.sfdcId) && !matchingAccountCIMIdMap.containsKey(acct.cimId)) 
                    {
                        System.debug('##### SFDC ID and CIM ID do not exist, may need to create account');
                        
                        // If this was RDC self-registration, create an account
                        if (isRDCSelfRegistration(acct)) 
                        {
                            System.debug('This is an RDC account');
                            if(Label.IsIPAAccountInsertAllowed == 'Y')
                            {
                                if(String.isNotBlank(acct.cimId))
                                {
                                    accountsToInsert.addAll(CreateRDCAccount(acct));
                                }
                                else 
                                {
                                    acct.ignoreMessage = true;
                                    acct.ignoreReason='Account Message ignored because account message doesnt have CIM Id.';
                                    System.debug('##### Account Message ignored because account message doesnt have CIM Id.');   
                                }
                            }
                            else
                            {
                                accountsToInsert.addAll(CreateRDCAccount(acct));
                            }
                            
                        }
                        else if(Label.IsIPAAccountInsertAllowed == 'N')
                        {
                            acct.ignoreMessage = true;
                            acct.ignoreReason='Account Message ignored because account not found in SF.';
                            System.debug('##### This account message does NOT look like RDC self-reg, dropping it');
                        }
                        
                    }
                    //For IPA
                    System.debug('erpmEnggCodes'+erpmEnggCodes);
                    if(Label.IsIPAAccountInsertAllowed == 'Y')
                    {
                        
                        if(String.isNotBlank(acct.cimId) && (acct.enggDedupGroupCode == Label.Core_B2B_DEDUP_GROUP_CODE || IsPRMEngagement) && accountsToInsert.size()==0)//insert and update for b2b & ipa
                        {
                            //Added sfid Check - atb
                            if(!matchingAccountCIMIdMap.containsKey(acct.cimId) && !matchingSfIdCimIdMap.containsKey(acct.sfdcId))
                            {
                                if(acct.enggDedupGroupCode == Label.Core_B2B_DEDUP_GROUP_CODE && !isRDCSelfRegistration(acct))
                                {
                                    acct.ignoreMessage = true;
                                    acct.ignoreReason='Account Message ignored : ERPM-SF Integration does not allow B2B account creation except for RDC engg';
                                    System.debug('##### Account Message ignored : ERPM-SF Integration does not allow B2B account creation except for RDC engg');
                                }
                                else if(erpmEnggCodes.Contains(Label.PRM_CSPx2EngagementCode))
                                {
                                    acct.ignoreMessage = true;
                                    acct.ignoreReason='Account Message ignored : ERPM-SF Integration does not allow CSPx2 account creation';
                                    System.debug('##### Account Message ignored : ERPM-SF Integration does not allow CSPx2 account creation');
                                }
                                else if(!erpmEnggCodes.Contains(Label.PRM_CSPx2EngagementCode))
                                {
                                    accountToUpsert = getAccountFromERPMAccount(acct,true);  //insert
                                }
                            }
                        }
                        //Ignore if no CIM Id in account message for IPA Engagmeents only
                        else
                        {
                            //Make sure you are not ignoring RDC insert.
                            if(accountsToInsert.size()==0 && (acct.sfdcId == null  && !matchingAccountIds.contains(acct.sfdcId)))
                            {
                                acct.ignoreMessage = true;
                                acct.ignoreReason='Account Message ignored because account message doesnt have CIM Id or SF Id.';
                                System.debug('##### This account message does NOT have CIM Id or SF Id hence ignoring the message');
                            }
                        }
                    }
                    
                    //common update logic for B2B & IPA enggs
                    if (!acct.ignoreMessage && (acct.enggDedupGroupCode == Label.Core_B2B_DEDUP_GROUP_CODE || IsPRMEngagement) && accountsToInsert.size()==0) 
                    {    
                        if (String.isBlank(accountToUpsert.Name)) 
                            accountToUpsert = matchingAccountIdMap.containsKey(acct.sfdcId) ? matchingAccountIdMap.get(acct.sfdcId) : matchingAccountCIMIdMap.get(acct.cimId);
                        
                        if(eRPM_engagementcode == Label.PRM_CSPx2EngagementCode)
                            accountToUpsert.AccountNumber=acct.erpmAccountNumber;
                        
                        if(acct.enggDedupGroupCode == Label.Core_B2B_DEDUP_GROUP_CODE && !isRDCSelfRegistration(acct)){
                            System.debug('acct.erpmAccountNumber'+acct.erpmAccountNumber);
                            accountToUpsert.Core_B2B_ERPM_Account_Number__c = acct.erpmAccountNumber;
                        }
                        
                        
                        
                        if(IsPRMEngagement){
                            //eRPM - Update NumberOfEmployees and URL from eRPM
                            System.debug('acct.phone : '+acct.phone);
                            accountToUpsert.Core_User_Defined_Website__c = String.isNotBlank(acct.website) ? acct.website : null;                         
                            accountToUpsert.Core_User_Defined_Number_of_Employees__c = String.isNotBlank(acct.employeeGrp) ? acct.employeeGrp : null;
                            accountToUpsert.Core_User_Defined_Phone_Number__c = String.isNotBlank(acct.phone) ? acct.phone : null;
                            if(!accountToUpsert.Core_Intel_Partner_Alliance_PartnerGroup__c && eRPM_engagementcode != Label.PRM_CSPx2EngagementCode)
                                accountToUpsert.Core_Intel_Partner_Alliance_PartnerGroup__c =true;  
                            
                            if(String.isEmpty(accountToUpsert.Core_Sales_Groups__c))
                                accountToUpsert.Core_Sales_Groups__c = Label.PRM_Core_Sales_Group;
                            
                            if(String.isEmpty(accountToUpsert.Industry))
                                accountToUpsert.Industry = Label.PRM_Industry;
                            
                            system.debug('website -'+accountToUpsert.Core_User_Defined_Website__c);
                            
                            //Add shipping address
                            //accountToUpdate.ShippingCity=acct.secondaryCity;
                            if(acct.secondaryAddress!=null){
                                System.debug('acct.secondaryCity'+ acct.secondaryAddress.secondaryCity);
                                accountToUpsert.ShippingCity=acct.secondaryAddress.secondaryCity;
                                accountToUpsert.ShippingCountry=acct.secondaryAddress.secondaryCountry;
                                accountToUpsert.ShippingState=acct.secondaryAddress.secondaryState;
                                accountToUpsert.ShippingPostalCode=acct.secondaryAddress.secondaryPostalCode;
                                accountToUpsert.ShippingStreet =acct.secondaryAddress.secondaryStreet1;
                                accountToUpsert.ShippingStreet = accountToUpsert.ShippingStreet  + (acct.secondaryAddress.secondaryStreet2.trim() != '' ? (' ' + acct.secondaryAddress.secondaryStreet2) : '');
                                accountToUpsert.ShippingStreet= accountToUpsert.ShippingStreet + (acct.secondaryAddress.secondaryStreet3.trim() != '' ? (' ' + acct.secondaryAddress.secondaryStreet3) : '');
                                accountToUpsert.ShippingStreet= accountToUpsert.ShippingStreet + (acct.secondaryAddress.secondaryStreet4.trim() != '' ? (' ' + acct.secondaryAddress.secondaryStreet4) : '');
                            }
                            //Get partner roles/ biz org type/partner speciality based on account benefits
                            //update only for ITP and ISA not for CIP
                            if(!erpmEnggCodes.Contains(Label.PRM_CSPx2EngagementCode)){
                                List<String> erpmBenefitCodes = new List<String>();
                                for(Core_IntegrationUtility.eRPM_Benefit benefit : acct.eRPM_Benefits)
                                {
                                    erpmBenefitCodes.add(benefit.eRPM_BenefitCode);
                                }
                                system.debug('erpmBenefitCodes - '+ erpmBenefitCodes);
                                system.debug('erpmEnggCodes - '+ erpmEnggCodes);
                                map<string, List<string>> customSettingmap = new map<string, List<string>>();
                                map<string, List<string>> customSettingBzOrgMap = new map<string, List<string>>();
                                map<string, List<string>> customSettingPrtrSpclmap = new map<string, List<string>>();
                                Integer i=0;
                                
                                //PMD Issue Fix
                                for( ERPM_SF_MAPPING_SETTING__mdt customSettings : eRPMSFMappingSettingMdt){   
                                                                                        system.debug('customSettings.SF_KeyValue__c'+ customSettings.SF_KeyValue__c);
                                                                                        if(customSettings.Mappting_Type__c == Label.PRM_Partner_Role){ 
                                                                                            system.debug('customSettings_PartnerRole');
                                                                                            if ((!customSettingmap.containsKey(customSettings.eRPM_EngagementCodes__c)) ){
                                                                                                system.debug('customSettings_PartnerRole_Key_NotExits - '+customSettings.eRPM_EngagementCodes__c+': '+customSettings.SF_KeyValue__c);
                                                                                                if(erpmBenefitCodes.Contains(customSettings.SF_KeyValue__c)) {
                                                                                                    system.debug('customSettings_PartnerRole_Benefit_Exits - '+customSettings.SF_KeyValue__c);
                                                                                                    customSettingmap.put(customSettings.eRPM_EngagementCodes__c, new List<String>{customSettings.eRPM_KeyValue__c});
                                                                                                }
                                                                                                else if(customSettings.eRPM_EngagementCodes__c == Label.PRM_ISA_Engagement_Code
                                                                                                        || customSettings.eRPM_EngagementCodes__c == Label.PRM_CSPx2EngagementCode){
                                                                                                            system.debug('customSettings_PartnerRole_NoBenefit - '+customSettings.eRPM_EngagementCodes__c+' :'+customSettings.eRPM_KeyValue__c);
                                                                                                            customSettingmap.put(customSettings.eRPM_EngagementCodes__c, new List<String>{customSettings.eRPM_KeyValue__c});
                                                                                                        }
                                                                                                
                                                                                            }
                                                                                            else {
                                                                                                system.debug('customSettings_PartnerRole_Key_Exits - '+customSettings.eRPM_EngagementCodes__c+': '+customSettings.eRPM_KeyValue__c);
                                                                                                if(!customSettingmap.get(customSettings.eRPM_EngagementCodes__c).Contains(customSettings.eRPM_KeyValue__c)) {
                                                                                                    if(erpmBenefitCodes.Contains(customSettings.SF_KeyValue__c)) {
                                                                                                        system.debug('customSettings_PartnerRole_Key_Exits_Add - '+customSettings.eRPM_KeyValue__c);
                                                                                                        customSettingmap.get(customSettings.eRPM_EngagementCodes__c).add(customSettings.eRPM_KeyValue__c);
                                                                                                    }
                                                                                                }
                                                                                            } 
                                                                                        }
                                                                                        else if (customSettings.Mappting_Type__c == Label.PRM_Biz_Org_Type){
                                                                                            if ((!customSettingBzOrgMap.containsKey(customSettings.eRPM_EngagementCodes__c)) ){
                                                                                                if(erpmBenefitCodes.Contains(customSettings.SF_KeyValue__c)) 
                                                                                                {
                                                                                                    
                                                                                                    customSettingBzOrgMap.put(customSettings.eRPM_EngagementCodes__c, new List<String>{customSettings.eRPM_KeyValue__c});
                                                                                                }
                                                                                                else if(customSettings.eRPM_EngagementCodes__c == Label.PRM_ISA_Engagement_Code
                                                                                                        || customSettings.eRPM_EngagementCodes__c == Label.PRM_CSPx2EngagementCode){
                                                                                                            customSettingBzOrgMap.put(customSettings.eRPM_EngagementCodes__c, new List<String>{customSettings.eRPM_KeyValue__c});
                                                                                                        }
                                                                                                
                                                                                            }
                                                                                            else {
                                                                                                if(!customSettingBzOrgMap.get(customSettings.eRPM_EngagementCodes__c).Contains(customSettings.eRPM_KeyValue__c)) {
                                                                                                    if(erpmBenefitCodes.Contains(customSettings.SF_KeyValue__c)) {
                                                                                                        customSettingBzOrgMap.get(customSettings.eRPM_EngagementCodes__c).add(customSettings.eRPM_KeyValue__c);
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                        else if(customSettings.Mappting_Type__c == Label.PRM_IPA_Partner_Specialty)
                                                                                        {
                                                                                            System.debug('Count hsk' + i);
                                                                                            i=i+1;
                                                                                            if ((!customSettingPrtrSpclmap.containsKey(customSettings.eRPM_EngagementCodes__c)))
                                                                                            {
                                                                                                System.debug('customSettings.eRPM_EngagementCodes__c if IPA : ' + customSettings.eRPM_EngagementCodes__c);
                                                                                                if(erpmBenefitCodes.Contains(customSettings.eRPM_KeyValue__c)) 
                                                                                                {
                                                                                                    System.debug('');
                                                                                                    customSettingPrtrSpclmap.put(customSettings.eRPM_EngagementCodes__c, new List<String>{customSettings.SF_KeyValue__c});
                                                                                                }
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                System.debug('customSettings.eRPM_EngagementCodes__c else IPA : ' + customSettings.eRPM_EngagementCodes__c);
                                                                                                if(!customSettingPrtrSpclmap.get(customSettings.eRPM_EngagementCodes__c).Contains(customSettings.eRPM_KeyValue__c)) 
                                                                                                {
                                                                                                    if(erpmBenefitCodes.Contains(customSettings.eRPM_KeyValue__c))
                                                                                                    {
                                                                                                        customSettingPrtrSpclmap.get(customSettings.eRPM_EngagementCodes__c).add(customSettings.SF_KeyValue__c);
                                                                                                    }                                                                                                
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                
                                system.debug('customSettingmap - '+ customSettingmap);  
                                System.debug('customSettingPrtrSpclmap : ' + customSettingPrtrSpclmap);
                                List<String> partnerRoles = new List<String>();
                                List<String> bizOrgTypes = new List<String>();
                                List<String> prtrSpeciality = new List<String>();
                                if(customSettingmap.values().size() > 0) {
                                    for(List<String> roles : customSettingmap.values()) {
                                        partnerRoles.addAll(roles);
                                    }
                                    //Set<String> nonDupPartnerRoles = new Set<String>(partnerRoles);
                                    if(String.isNotBlank(accountToUpsert.Core_IPA_Partner_Role__c))
                                        partnerRoles.addAll(accountToUpsert.Core_IPA_Partner_Role__c.split(';'));
                                    accountToUpsert.Core_IPA_Partner_Role__c =  Core_IntegrationUtility.formatMultiSelectPicklist(new List<String>(new Set<String>(partnerRoles)));
                                }
                                if(customSettingBzOrgMap.values().size() > 0) {
                                    for(List<String> bizOrgs : customSettingBzOrgMap.values()) {
                                        bizOrgTypes.addAll(bizOrgs);
                                    }
                                    system.debug('bizOrgTypes'+bizOrgTypes);
                                    if(String.isNotBlank(accountToUpsert.Core_Account_Type__c))
                                        bizOrgTypes.addAll(accountToUpsert.Core_Account_Type__c.split(';'));
                                    accountToUpsert.Core_Account_Type__c =  Core_IntegrationUtility.formatMultiSelectPicklist(new List<String>(new Set<String>(bizOrgTypes)));
                                }
                                
                                if(customSettingPrtrSpclmap != null && customSettingPrtrSpclmap.values().size() > 0) 
                                {
                                    for(List<String> prtr : customSettingPrtrSpclmap.values()) 
                                    {
                                        prtrSpeciality.addAll(prtr);
                                    }
                                    
                                    system.debug('prtrSpeciality : '+ prtrSpeciality);
                                    if(String.isNotBlank(accountToUpsert.Core_IPA_Partner_Speciality__c))
                                        prtrSpeciality.addAll(accountToUpsert.Core_IPA_Partner_Speciality__c.split(';'));
                                    accountToUpsert.Core_IPA_Partner_Speciality__c =  Core_IntegrationUtility.formatMultiSelectPicklist(new List<String>(new Set<String>(prtrSpeciality)));
                                }
                            }
                            
                            accountsToUpsert.add(accountToUpsert);
                            System.debug('##### Attempting to update this account: ' + accountToUpsert);
                            
                            
                            // ----------- #REGION :: eRPM Code Changes :: START ------------- //
                            system.debug('****** acct.eRPM_Profile_Responses ******* '+ acct.eRPM_Profile_Responses);
                            if(acct.eRPM_Profile_Responses !=null && acct.eRPM_Profile_Responses.size() >0)
                                eRPM_ProfileResponses.addall(acct.eRPM_Profile_Responses);
                            // ----------- #REGION :: eRPM Code Changes :: END   ------------- //
                            
                        }

                    }
                }
                //system.debug('eRPM_ProfileResponses ==>'+eRPM_ProfileResponses);
                //system.debug('eRPM_ProfileResponses IsPRMEngagement ==>'+IsPRMEngagement);
                //system.debug('eRPM_ProfileResponses accountsToUpsert ==>'+accountsToUpsert);
                //PMD Issue Fix
                ERPM_AccountWrapper acctWrapper = new ERPM_AccountWrapper();               
                //keyNum+=1;
                //acctWrapper.key = ACCOUNT_KEY+keyNum;
                acctWrapper.accountsToUpsert = accountsToUpsert;
                acctWrapper.IsPRMEngagement = IsPRMEngagement;
                acctWrapper.eRPM_ProfileResponses = eRPM_ProfileResponses;
                //system.debug('eRPM_ProfileResponses NEW Wrapper==>'+acctWrapper);
                accountWrappers.add(acctWrapper);

                for (Account a : accountsToUpsert) {
                    if(Label.IsIPAAccountInsertAllowed == 'Y') {
                        if(!String.isEmpty(a.Id)){
                            if(!accountIdsTobeUpdated.contains(a.Id)) {
                                accountIdsTobeUpdated.add(a.Id);
                                allAccountsToBeUpserted.add(a);
                                System.debug('a : '+a);
                            }                        
                        }else{
                            allAccountsToBeUpserted.add(a); 
                            System.debug('a : '+a);
                        }   
                    }else{
                        if(!String.isEmpty(a.Id)){
                            if(!accountIdsTobeUpdated.contains(a.Id)) {
                                accountIdsTobeUpdated.add(a.Id);
                                allAccountsToBeUpdated.add(a);
                                System.debug('a : '+a);
                            }                        
                        } 
                    } 
                }
                /*PMD Issue fix - Commented to AVOID DML Statements inside FOR loop
                // Perform DML INSERTs and UPDATEs for Accounts
                System.debug('##### accountsToUpdate: ' + accountsToUpsert);
                if (accountsToUpsert.size() > 0){
                    if(Label.IsIPAAccountInsertAllowed == 'Y')
                        upsert accountsToUpsert;
                    else
                        update accountsToUpsert;
                    
                    
                    for (Account a : accountsToUpsert) {
                        matchingAccountIdMap.put(a.Id, a);
                        matchingAccountCIMIdMap.put(a.Core_CIM_ID__c, a);
                    }
                }
                
                // ----------- #REGION :: eRPM Code Changes :: START ------------- //
                try{                                       
                    if((eRPM_ProfileResponses.size()>0) && IsPRMEngagement){
                        System.debug('##### eRPM_ProfileResponses Before Insert/Update ###### : ' + eRPM_ProfileResponses);
                        //new Core_Integration_Additional_Attributes(accountsToUpdate[0].Id, null, Label.PRM_IPAEngagement).SetProfileResponses(eRPM_ProfileResponses);
                        System.enqueueJob(new Core_Integration_Additional_Attributes(accountsToUpsert[0].Id, null, Label.PRM_IPAEngagement,eRPM_ProfileResponses, null,null,null,null,null));
                    }
                }
                catch(Exception ex) {
                    processingStatus = 'Failed';
                    processingMessage += ', Message 4: ' + Core_IntegrationUtility.exceptionMessageGenerator(ex);
                    // Create a log entry
                    logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                      'Error processing ERPM Account message - SetProfileResponses', '', newList[0].Id,
                                                                      LOG_ENTRY_OBJECT, tags, ex);
                }
                // ----------- #REGION :: eRPM Code Changes :: END   ------------- //
                */
            }
            //system.debug('eRPM_ProfileResponses allAccountsToBeUpserted size===>'+allAccountsToBeUpserted.size());
            //system.debug('eRPM_ProfileResponses allAccountsToBeUpserted ===>'+allAccountsToBeUpserted);
            set<Account> allAccounts = new Set<Account>();
            if(allAccountsToBeUpserted.size() > 0){               
               upsert allAccountsToBeUpserted;
               allAccounts.addAll(allAccountsToBeUpserted);
            }else if(allAccountsToBeUpdated.size() > 0){
                update allAccountsToBeUpdated;
                allAccounts.addAll(allAccountsToBeUpdated);
            }    
            for(Account a : allAccounts) {
                matchingAccountIdMap.put(a.Id, a);
                matchingAccountCIMIdMap.put(a.Core_CIM_ID__c, a);
            } 
            //system.debug('eRPM_ProfileResponses accountWrappers ==>'+accountWrappers);
            for(ERPM_AccountWrapper acctWrapper : accountWrappers) {
                //system.debug('eRPM_ProfileResponses acctWrapper In FOR Loop==>'+acctWrapper.eRPM_ProfileResponses);
                //system.debug('eRPM_ProfileResponses acctWrapper IsPRMEngagement In FOR Loop ==>'+acctWrapper.IsPRMEngagement);
                
                // ----------- #REGION :: eRPM Code Changes :: START ------------- //
                try{                                       
                    if((acctWrapper.eRPM_ProfileResponses.size()>0) && acctWrapper.IsPRMEngagement){
                        System.debug('##### eRPM_ProfileResponses Before Insert/Update ###### : ' + acctWrapper.eRPM_ProfileResponses);
                        //new Core_Integration_Additional_Attributes(accountsToUpdate[0].Id, null, Label.PRM_IPAEngagement).SetProfileResponses(eRPM_ProfileResponses);
                        System.enqueueJob(new Core_Integration_Additional_Attributes(acctWrapper.accountsToUpsert[0].Id, null, Label.PRM_IPAEngagement,acctWrapper.eRPM_ProfileResponses, null,null,null,null,null));
                    }
                }
                catch(Exception ex) {
                    processingStatus = 'Failed';
                    processingMessage += ', Message 4: ' + Core_IntegrationUtility.exceptionMessageGenerator(ex);
                    // Create a log entry
                    logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                                    'Error processing ERPM Account message - SetProfileResponses', '', newList[0].Id,
                                                                    LOG_ENTRY_OBJECT, tags, ex);
                }
                // ----------- #REGION :: eRPM Code Changes :: END   ------------- //
            }

            System.debug('##### accountsToInsert: ' + accountsToInsert);
            if (accountsToInsert.size() > 0)
                insert accountsToInsert;
            
            for (Account a : accountsToInsert) {
                matchingAccountIdMap.put(a.Id, a);
                matchingAccountCIMIdMap.put(a.Core_CIM_ID__c, a);
            }
            
            //--------------------------------------------------------------------------------------------------
            // ENTITLEMENT & ERPM ENGAGEMENT RECORD POTENTIAL INSERTS
            
            Core_IntegrationUtility.insertMissingEngagementsEntitlements(erpmEnggs, erpmEnggCodes);
            
            // Create a new map of all ERPM Engagement Codes to Engagement IDs in the system
            List<Core_ERPM_Engagement__c> fullSetEngagements = [
                select Id, Core_Technical_Engagement_Code__c from Core_ERPM_Engagement__c];
            Map<String,Id> engagementCodeEngagementIdMap = new Map<String,Id>();
            
            for (Core_ERPM_Engagement__c ee : fullSetEngagements)
                engagementCodeEngagementIdMap.put(ee.Core_Technical_Engagement_Code__c, ee.Id);
            
            //--------------------------------------------------------------------------------------------------
            // ACCOUNT ERPM ENGAGEMENT RECORD INSERTS & UPDATES
            
            // For upcoming inserts & updates
            List<Core_Account_ERPM_Engagement__c> accountERPMEngagementsToInsert = new List<Core_Account_ERPM_Engagement__c>();
            List<Core_Account_ERPM_Engagement__c> accountERPMEngagementsToUpdate = new List<Core_Account_ERPM_Engagement__c>();
            List<Core_Account_ERPM_Engagement__c> accountERPMEngagementsToDelete = new List<Core_Account_ERPM_Engagement__c>();
            List<PRM_AccountChannelMembership__c> accountChannelMemberships = new List<PRM_AccountChannelMembership__c>();
            //PMD Issue Fix
            Set<Id> acctIds = new Set<Id>();
            Set<String> accountPartnerRoles = new Set<String>();
            Map<Id,Account> accountsPartnerRoleMap = new Map<Id,Account>();              
            Map<String,List<ERPM_SF_MAPPING_SETTING__mdt>> acctPartnerRoleERPMSFMappingMap = new Map<String,List<ERPM_SF_MAPPING_SETTING__mdt>>();  
            //PMD Issue Fix
            for (Core_IntegrationUtility.ERPM_Account erpmAcct : erpmAccounts) {
                if (!erpmAcct.ignoreMessage) {                  
                    Account acct = matchingAccountIdMap.containsKey(erpmAcct.sfdcId) ? matchingAccountIdMap.get(erpmAcct.sfdcId) : (matchingAccountCIMIdMap.containsKey(erpmAcct.cimId) ? matchingAccountCIMIdMap.get(erpmAcct.cimId) : null);
                    if(acct!=null)
                        acctIds.add(acct.Id); 
                }
            }
            //system.debug('acctIds ==>'+acctIds.size());
            //system.debug('acctIds ==>'+acctIds);
            if(acctIds.size() > 0){
                for(Account acct : [SELECT Core_IPA_Partner_Role__c FROM Account WHERE Id IN : acctIds]){
                    accountsPartnerRoleMap.put(acct.Id, acct);
                    if(!String.isEmpty(acct.Core_IPA_Partner_Role__c)){
                        accountPartnerRoles.addAll(acct.Core_IPA_Partner_Role__c.split(';'));
                    }
                }
                system.debug('accountPartnerRoles: '+accountPartnerRoles);
                if(accountPartnerRoles.size() > 0) {
                    for(ERPM_SF_MAPPING_SETTING__mdt eRPMSFMappingMdt : [SELECT SF_KeyValue__c, eRPM_KeyValue__c, eRPM_EngagementCodes__c 
                                                                            FROM ERPM_SF_MAPPING_SETTING__mdt
                                                                            WHERE Mappting_Type__c =: Label.PRM_Partner_Role
                                                                            AND eRPM_EngagementCodes__c IN :erpmEnggCodes
                                                                            AND  eRPM_KeyValue__c IN :accountPartnerRoles]){
                         if(acctPartnerRoleERPMSFMappingMap.containsKey((eRPMSFMappingMdt.eRPM_KeyValue__c+'~~'+eRPMSFMappingMdt.eRPM_EngagementCodes__c).toUpperCase())){
                             acctPartnerRoleERPMSFMappingMap.get((eRPMSFMappingMdt.eRPM_KeyValue__c+'~~'+eRPMSFMappingMdt.eRPM_EngagementCodes__c).toUpperCase()).add(eRPMSFMappingMdt);                                                     
                         }else{
                             acctPartnerRoleERPMSFMappingMap.put((eRPMSFMappingMdt.eRPM_KeyValue__c+'~~'+eRPMSFMappingMdt.eRPM_EngagementCodes__c).toUpperCase(), new List<ERPM_SF_MAPPING_SETTING__mdt>{eRPMSFMappingMdt});
                         }
                        
                    }
                }
            }
            //system.debug('accountsPartnerRoleMap ==>'+accountsPartnerRoleMap);
            system.debug('acctPartnerRoleERPMSFMappingMap ==>'+acctPartnerRoleERPMSFMappingMap);
            // Loop through collection of erpmAccounts...
            for (Core_IntegrationUtility.ERPM_Account erpmAcct : erpmAccounts) {
                if (!erpmAcct.ignoreMessage) {
                    
                    System.debug('##### Operating on this account message to check for account ERPM engagement inserts & updates: ' + erpmAcct);
                    
                    Account acct;
                    
                    // Use Account IDs from previous steps to look up Account ERPM Engagements, if any
                    // Check here for optimization
                    if (matchingAccountIdMap.containsKey(erpmAcct.sfdcId))
                        acct = matchingAccountIdMap.get(erpmAcct.sfdcId);
                    else if (matchingAccountCIMIdMap.containsKey(erpmAcct.cimId))
                        acct = matchingAccountCIMIdMap.get(erpmAcct.cimId);
                    
                    System.debug('acct'+acct);
                    List<Core_Account_ERPM_Engagement__c> existingAEEs = matchingAccountERPMEngagementMap.get(acct.Id);
                    //get account channel memberships
                    List<PRM_AccountChannelMembership__c> existingACMs = matchingAccountChnlMembMap.get(acct.Id);
                    system.debug('existingACM '+existingACMs);
                    system.debug('existingAEEs '+existingAEEs);
                    
                    
                    List<String> acmPartnerRoles = new List<String>();
                    if(existingACMs!= null) {                       
                        for(PRM_AccountChannelMembership__c acmMtd : existingACMs){
                            acmPartnerRoles.add(acmMtd.PRM_Partner_Role__c);
                        }
                    }
                    
                    //Map<String,String> partnerRoleMtd = new Map<String,String>();
                    List<String> erpmBenefitCodes = new List<String>();
                    for(Core_IntegrationUtility.eRPM_Benefit benefit : erpmAcct.eRPM_Benefits){
                        erpmBenefitCodes.add(benefit.eRPM_BenefitCode);
                    }
                    //system.debug('erpmBenefitCodes ==>'+erpmBenefitCodes);
                    //PMD Issue Fix
                    //String acctPartnerRole = [SELECT Core_IPA_Partner_Role__c
                                              //FROM Account WHERE Id =: acct.Id ].Core_IPA_Partner_Role__c;
                    //system.debug('Account Id ==>'+acct.Id);
                    String acctPartnerRole = accountsPartnerRoleMap.containsKey(acct.Id) ? accountsPartnerRoleMap.get(acct.Id).Core_IPA_Partner_Role__c : null;
                    List<String> acctPartnerRoles = new List<String>();
                    List<ERPM_SF_MAPPING_SETTING__mdt> customSettingsMdt = new List<ERPM_SF_MAPPING_SETTING__mdt>();
                    system.debug('acctPartnerRoles '+acctPartnerRoles);
                    if(acctPartnerRole != null){
                        acctPartnerRoles = acctPartnerRole.split(';');
                        system.debug('erpmEnggCodes ==>'+erpmEnggCodes);
                        for(String acctPartnrRole : acctPartnerRoles){
                            for(String erpmEnggCode : erpmEnggCodes){
                                system.debug('acctPartnerRoleERPMSFMappingMap Key==>'+acctPartnrRole+'~~'+erpmEnggCode);                               
                                if(acctPartnerRoleERPMSFMappingMap.containsKey((acctPartnrRole+'~~'+erpmEnggCode).toUpperCase())){
                                     system.debug('acctPartnerRoleERPMSFMappingMap Value==>'+acctPartnerRoleERPMSFMappingMap.get((acctPartnrRole+'~~'+erpmEnggCode).toUpperCase()));
                                    customSettingsMdt.addAll(acctPartnerRoleERPMSFMappingMap.get((acctPartnrRole+'~~'+erpmEnggCode).toUpperCase()));
                                }
                            }
                        } 
                    }   
                    //system.debug('customSettingsMdt size ===>'+customSettingsMdt.size());
                    //[SELECT SF_KeyValue__c, eRPM_KeyValue__c, eRPM_EngagementCodes__c 
                    //FROM ERPM_SF_MAPPING_SETTING__mdt
                    //WHERE Mappting_Type__c =: Label.PRM_Partner_Role
                    //AND eRPM_EngagementCodes__c IN: erpmEnggCodes
                    //AND  eRPM_KeyValue__c IN: acctPartnerRoles
                    //AND  eRPM_KeyValue__c IN: acctPartnerRoles]                 
                    map<string, List<string>> customSettingMdtMap = new map<string, List<string>>();
                    for( ERPM_SF_MAPPING_SETTING__mdt customSettings : customSettingsMdt){ 
                        //system.debug('customSettings.SF_KeyValue__c'+ customSettings.SF_KeyValue__c);
                        if ((!customSettingMdtMap.containsKey(customSettings.eRPM_EngagementCodes__c)) ){
                            if(erpmBenefitCodes.Contains(customSettings.SF_KeyValue__c)) {
                                customSettingMdtMap.put(customSettings.eRPM_EngagementCodes__c, new List<String>{customSettings.eRPM_KeyValue__c});
                            }
                            else if(customSettings.eRPM_EngagementCodes__c == Label.PRM_ISA_Engagement_Code
                                    || customSettings.eRPM_EngagementCodes__c == Label.PRM_CSPx2EngagementCode){
                                customSettingMdtMap.put(customSettings.eRPM_EngagementCodes__c, new List<String>{customSettings.eRPM_KeyValue__c});
                            }              
                        }
                        else {
                            if(!customSettingMdtMap.get(customSettings.eRPM_EngagementCodes__c).Contains(customSettings.eRPM_KeyValue__c)) {
                                if(erpmBenefitCodes.Contains(customSettings.SF_KeyValue__c)) {
                                     customSettingMdtMap.get(customSettings.eRPM_EngagementCodes__c).add(customSettings.eRPM_KeyValue__c);
                                }
                            }
                        } 
                    } 
                    system.debug('customSettingMdtMap - '+ customSettingMdtMap);
                    //system.debug('partnerRoleMtd2 ' + partnerRoleMtd);
                    
                    Set<String> existingAccountEngagementCodes = new Set<String>();
                    Map<String,Core_Account_ERPM_Engagement__c> matchingEngagementCodeAEEMap = new Map<String,Core_Account_ERPM_Engagement__c>();
                    
                    if (existingAEEs != null) {
                        for (Core_Account_ERPM_Engagement__c aee : existingAEEs) {
                            existingAccountEngagementCodes.add(aee.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c);
                            matchingEngagementCodeAEEMap.put(aee.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c, aee);
                        }
                    }
                    
                    System.debug('existingAccountEngagementCodes : '+ existingAccountEngagementCodes);
                    System.debug('matchingEngagementCodeAEEMap : '+ matchingEngagementCodeAEEMap);
                    
                    Set<String> erpmEngagements = new Set<String>();
                    //PMD Issue Fix
                    Set<String> engagementCodes = new Set<String>();
                    Set<String> engagementTiers = new Set<String>();  
                    Set<String> engagementTiersAfterSFMapping = new Set<String>();
                    Map<String,String> engCodeTierERPMSFMap = new Map<String,String>(); 
                    Map<String,ChannelProgramLevel> ChannelProgramLevelsMap = new Map<String,ChannelProgramLevel>();              
                    for (Core_IntegrationUtility.ERPM_Engagement engg : erpmAcct.accountEngagements) {
                        engagementCodes.add(engg.engagementCode); 
                        engagementTiers.add(engg.tierCode); 
                    }      
                    system.debug('engagementTiers ==>'+engagementTiers);
                    if(engagementCodes.size()>0){
                        for(ERPM_SF_MAPPING_SETTING__mdt eRPMSFMappingMdt : [SELECT SF_KeyValue__c,Mappting_Type__c,eRPM_EngagementCodes__c,eRPM_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt 
                                                                        WHERE Mappting_Type__c =: Label.PRM_ProgramLevel AND eRPM_EngagementCodes__c IN :engagementCodes
                                                                        AND eRPM_KeyValue__c IN :engagementTiers]){
                            engCodeTierERPMSFMap.put(eRPMSFMappingMdt.eRPM_EngagementCodes__c+'~~'+eRPMSFMappingMdt.eRPM_KeyValue__c, eRPMSFMappingMdt.SF_KeyValue__c);  
                            engagementTiersAfterSFMapping.add(eRPMSFMappingMdt.SF_KeyValue__c);

                        }
                    }
                    system.debug('engagementTiers After Mapping ==>'+engagementTiersAfterSFMapping);
                    if(engagementTiers.size() > 0) {
                        for(ChannelProgramLevel cpl : [SELECT Id, ProgramId,PRM_programlevelcode__c FROM ChannelProgramLevel WHERE PRM_programlevelcode__c IN :engagementTiersAfterSFMapping 
                            AND Program.PRM_programCode__c =: Label.PRM_IPAEngagement]) {
                                ChannelProgramLevelsMap.put(cpl.PRM_programlevelcode__c.toUpperCase(), cpl);    
                        }
                    }
                    system.debug('ChannelProgramLevelsMap ==>'+ChannelProgramLevelsMap.keySet());
                    for (Core_IntegrationUtility.ERPM_Engagement engg : erpmAcct.accountEngagements) {
                        System.debug('##### Checking this ERPM account engagement code to see if insert/update is needed: ' + engg.engagementCode);
                        
                        erpmEngagements.add(engg.engagementCode);
                        system.debug('IsPRMEngagement: '+IsPRMEngagement);
                        //eRPM-SF integration Account channel memberships
                        if(PRMEngagements !=null && PRMEngagements.size() > 0 && PRMEngagements.Contains(engg.engagementCode)
                           && engg.engagementCode != Label.PRM_CSPx2EngagementCode) {                                            
                               String enggStausCode = engg.engagementStatusCode == 'ENGSTSAPRD'? Label.PRM_Engagement_Status_Approved : 'Inactive';
                               system.debug('engg.engagementCode' + engg.engagementCode +'engg.engagementStatusCode'+engg.engagementStatusCode);
                               system.debug('engg.tierCode'+engg.tierCode);
                               //String tierCode = [SELECT SF_KeyValue__c FROM ERPM_SF_MAPPING_SETTING__mdt 
                                //                  WHERE Mappting_Type__c =: Label.PRM_ProgramLevel AND eRPM_EngagementCodes__c =:  engg.engagementCode
                                //                  AND eRPM_KeyValue__c =: engg.tierCode LIMIT 1].SF_KeyValue__c;
                               String tierCode = engCodeTierERPMSFMap.containsKey(engg.engagementCode+'~~'+engg.tierCode) ? engCodeTierERPMSFMap.get(engg.engagementCode+'~~'+engg.tierCode) : null ;
                               system.debug('tierCode'+ tierCode);                       
                               //List<ChannelProgramLevel> channelPrgLevel = [SELECT Id, ProgramId FROM ChannelProgramLevel WHERE PRM_programlevelcode__c =: tierCode 
                               //                                            AND Program.PRM_programCode__c =: Label.PRM_IPAEngagement LIMIT 1];
                               ChannelProgramLevel channelPrgLevel = new ChannelProgramLevel();
                               if(!String.isEmpty(tierCode)){
                                  channelPrgLevel =  ChannelProgramLevelsMap.get(tierCode.toUpperCase()); 
                               }
                                
                               system.debug('channelPrgLevel-'+channelPrgLevel);
                               if(existingACMs != null){
                                   if(customSettingMdtMap.get(engg.engagementCode) != null) {
                                       for(String mpr : customSettingMdtMap.get(engg.engagementCode)){
                                           for(PRM_AccountChannelMembership__c acm : existingACMs){
                                               if(mpr == acm.PRM_Partner_Role__c) { //&& engg.engagementCode == partnerRoleMtd.get(mpr)) {
                                                   //update acm
                                                   system.debug('update');
                                                   if(acm.PRM_Status_Nm__c != enggStausCode || 
                                                      acm.PRM_Channel_Program_Level_Id__r.PRM_programlevelcode__c != tierCode){
                                                          
                                                          system.debug('Existing ACM');                                                                                                                
                                                          acm.PRM_Status_Nm__c= enggStausCode;
                                                          //acm.PRM_Channel_Program_Level_Id__c = channelPrgLevel[0].Id;
                                                          acm.PRM_Channel_Program_Level_Id__c = channelPrgLevel.Id;
                                                          acm.PRM_Status_Reason_Txt__c = engg.engagementStatusReasonCode;
                                                          accountChannelMemberships.add(acm);
                                                          system.debug('accountChannelMemberships update :' +accountChannelMemberships);
                                                      }
                                               }
                                               else if (!acmPartnerRoles.contains(mpr)) { //&& engg.engagementCode == partnerRoleMtd.get(mpr)) {
                                                   //insert new amc
                                                   system.debug('insert - some exists');
                                                   accountChannelMemberships.add(new PRM_AccountChannelMembership__c(PRM_Account_Id__c = acct.Id, 
                                                                                                                     //PRM_Channel_Program_Id__c = channelPrgLevel[0].ProgramId,
                                                                                                                     //PRM_Channel_Program_Level_Id__c = channelPrgLevel[0].Id, 
                                                                                                                     PRM_Channel_Program_Id__c = channelPrgLevel.ProgramId,
                                                                                                                     PRM_Channel_Program_Level_Id__c = channelPrgLevel.Id,
                                                                                                                     PRM_Status_Nm__c = Label.PRM_Engagement_Status_Approved, 
                                                                                                                     PRM_Partner_Role__c = mpr));
                                               }
                                           }
                                       }    
                                   }
                               }
                               else {
                                   system.debug('New ACM');                               
                                   //No acm to at all ad new
                                   system.debug('customSettingmap.get(engg.engagementCode)'+customSettingMdtMap.get(engg.engagementCode));
                                   system.debug('customSettingmap.get( channelPrgLevel ==>'+channelPrgLevel);
                                   if(customSettingMdtMap.get(engg.engagementCode) != null) {                                     
                                       for(String mPr : customSettingMdtMap.get(engg.engagementCode)) {
                                           //if(engg.engagementCode == partnerRoleMtd.get(mPr)) {
                                           //if(channelPrgLevel != null && channelPrgLevel.size()>0) {
                                            if(channelPrgLevel != null) {
                                               accountChannelMemberships.add(new PRM_AccountChannelMembership__c(PRM_Account_Id__c = acct.Id, 
                                                                                                                 //PRM_Channel_Program_Id__c = channelPrgLevel[0].ProgramId, 
                                                                                                                 //PRM_Channel_Program_Level_Id__c = channelPrgLevel[0].Id,
                                                                                                                 PRM_Channel_Program_Id__c = channelPrgLevel.ProgramId, 
                                                                                                                 PRM_Channel_Program_Level_Id__c = channelPrgLevel.Id,  
                                                                                                                 PRM_Status_Nm__c = Label.PRM_Engagement_Status_Approved, 
                                                                                                                 PRM_Partner_Role__c = mPr));
                                           }
                                           //}
                                       }
                                   }                                
                               }
                           }
                        System.debug('engg.effectiveTierCode'+ engg.effectiveTierCode);
                        System.debug('engg.engagementCode'+ engg.engagementCode);
                        System.debug(matchingEngagementCodeAEEMap.get(engg.engagementCode));
                        if (!existingAccountEngagementCodes.contains(engg.engagementCode)) {
                           
                            Core_Account_ERPM_Engagement__c aee =
                                new Core_Account_ERPM_Engagement__c(Core_Account_Id__c=acct.Id, Core_ERPM_Account_Number__c = erpmAcct.erpmAccountNumber,
                                                                    Core_ERPM_Engagement_Id__c=engagementCodeEngagementIdMap.get(engg.engagementCode),
                                                                    Core_ERPM_Business_Attributes__c=engg.effectiveTierCode
                                                                   );
                            accountERPMEngagementsToInsert.add(aee);
                            existingAccountEngagementCodes.add(engg.engagementCode);
                            System.debug('##### Attempting to add account ERPM engagement code: ' + aee);
                        }
                        // Check to see if "selected" needs to be updated, or the Tier has changed & needs updating
                        // Check for CSP engagement and account no value only exists
                        // Added condition for CSPx2 account no update bug.
                        else if (matchingEngagementCodeAEEMap.get(engg.engagementCode)!=null&&((matchingEngagementCodeAEEMap.get(engg.engagementCode).Core_ERPM_Business_Attributes__c.toUpperCase() != engg.effectiveTierCode.toUpperCase())|| 
                                                                                               (engg.engagementCode==Label.PRM_CSPx2EngagementCode && string.IsBlank(matchingEngagementCodeAEEMap.get(engg.engagementCode).Core_ERPM_Account_Number__c))))
                        {
                            System.debug(matchingEngagementCodeAEEMap.get(engg.engagementCode).Core_ERPM_Business_Attributes__c);
                            System.debug('engg.effectiveTierCode'+engg.effectiveTierCode);
                            Core_Account_ERPM_Engagement__c aee = matchingEngagementCodeAEEMap.get(engg.engagementCode);
                            aee.Core_ERPM_Business_Attributes__c = engg.effectiveTierCode;
                            aee.Core_ERPM_Account_Number__c = erpmAcct.erpmAccountNumber;
                            accountERPMEngagementsToUpdate.add(aee);
                            System.debug('##### Attempting to update account ERPM engagement code: ' + aee);
                        }
                    }
                    
                    // Check to see if any engagements were removed and need to be deleted
                    for (String existingAccountEngagementCode : existingAccountEngagementCodes) {
                        if (!erpmEngagements.contains(existingAccountEngagementCode)) {
                            Core_Account_ERPM_Engagement__c aee = matchingEngagementCodeAEEMap.get(existingAccountEngagementCode);
                            accountERPMEngagementsToDelete.add(aee);
                            System.debug('##### Attempting to delete account ERPM engagement code: ' + aee);
                        }
                    }
                }
            }
            
            // Perform DML INSERTs, UPDATEs, DELETEs for Account ERPM Engagements
            System.debug('##### accountERPMEngagementsToInsert: ' + accountERPMEngagementsToInsert);
            if (accountERPMEngagementsToInsert.size() > 0)
                insert accountERPMEngagementsToInsert;
            
            System.debug('##### accountERPMEngagementsToUpdate: ' + accountERPMEngagementsToUpdate);
            if (accountERPMEngagementsToUpdate.size() > 0)
                update accountERPMEngagementsToUpdate;
            
            System.debug('##### accountChannelMemberships: ' + accountChannelMemberships);
            if(accountChannelMemberships.size() > 0)
                upsert accountChannelMemberships;
            
            // TO DO: resolve this open. For now, we won't be deleting or inactivating Account Engagements.
            //System.debug('##### accountERPMEngagementsToDelete: ' + accountERPMEngagementsToDelete);
            //if (accountERPMEngagementsToDelete.size() > 0) 
            //    delete accountERPMEngagementsToDelete;
            
            // Create a log entry
            // 
            
            String successMessage = '';
            String successDetails = '';
            for (Core_IntegrationUtility.ERPM_Account erpmAcct : erpmAccounts) {
                // If we ignored any messages, that's what we put in the log entry
                if ((successMessage == '') && (erpmAcct.ignoreMessage)) {
                    successMessage = 'Ignored ERPM Account message';
                    successDetails = 'Ignored message based on business rules.';
                    if (erpmAcct.ignoreReason != '') {
                        successDetails += ' ' + erpmAcct.ignoreReason + '.';
                    }
                }
            }
            if (successMessage == '') {
                successMessage = 'Successfully processed ERPM Account message';
                successDetails = 'Success!';
            }
            
            logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_INFO,
                                                            successMessage, successDetails, newList[0].Id, LOG_ENTRY_OBJECT, tags);
            
            /* logEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_INFO,
'Successfully processed ERPM Account message',
'Success!', newList[0].Id, LOG_ENTRY_OBJECT, tags);*/
        }
        catch(Exception ex) {
            processingStatus = 'Failed';
            processingMessage += ', Message 4: ' + Core_IntegrationUtility.exceptionMessageGenerator(ex);
            // Create a log entry
            logEntryId = Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_ERROR,
                                                              'Error processing ERPM Account message', '', newList[0].Id,
                                                              LOG_ENTRY_OBJECT, tags, ex);
        }
        //--------------------------------------------------------------------------------------------------
        // FINAL SUCCESS/FAILURE LOGIC
        
        // Update Processing Status to "Successful" or "Failed" depending on above
        List<Core_Integration_Inbound_Message__c> messagesToUpdate = new List<Core_Integration_Inbound_Message__c>();
        
        for (Core_Integration_Inbound_Message__c msg : [select Id, Core_Processing_Status__c, Core_Exception_Message__c, Core_Log_Entry__c, Core_Tags__c
                                                        from Core_Integration_Inbound_Message__c where Id in :msgIds]) {
                                                            msg.Core_Processing_Status__c = processingStatus;
                                                            msg.Core_Exception_Message__c = processingMessage;
                                                            msg.Core_Log_Entry__c = logEntryId;
                                                            msg.Core_Tags__c = tags;
                                                            messagesToUpdate.add(msg);
                                                        }
        
        System.debug('##### Updating this message record with final successful/failed status: ' + messagesToUpdate);
        if(messagesToUpdate.size()>0){
            update messagesToUpdate;
        }
    }    
    // Copy info from an ERPM Account record into an Account (for RDC self-registration)
    public static Account getAccountFromERPMAccount(Core_IntegrationUtility.ERPM_Account acct ,boolean IsIPARegistration) {
        system.debug('BillingAddress 1==>'+ acct.primaryStreet1);
        system.debug('BillingAddress 2==>'+ acct.primaryStreet2);
        system.debug('BillingAddress 3==>'+ acct.primaryStreet3);
        system.debug('BillingAddress 4==>'+ acct.primaryStreet4);       
        system.debug('BillingAddress primaryCity==>'+ acct.primaryCity);
        system.debug('BillingAddress primaryState==>'+ acct.primaryState);
        system.debug('BillingAddress primaryCountry==>'+ acct.primaryCountry);
        
        Account a              = new Account();
        a.Name                 = acct.name;
        a.Core_CIM_ID__c       = acct.cimId;
        a.BillingStreet        = acct.primaryStreet1;
        a.BillingStreet        = a.BillingStreet + (acct.primaryStreet2.trim() != '' ? (' ' + acct.primaryStreet2) : '');
        a.BillingStreet        = a.BillingStreet + (acct.primaryStreet3.trim() != '' ? (' ' + acct.primaryStreet3) : '');
        a.BillingStreet        = a.BillingStreet + (acct.primaryStreet4.trim() != '' ? (' ' + acct.primaryStreet4) : '');
        a.BillingCity          = acct.primaryCity;
        a.BillingState         = acct.primaryState;
        a.BillingPostalCode    = acct.primaryPostalCode;
        a.BillingCountry       = acct.primaryCountry;
        
        if(!IsIPARegistration){
            a.Phone				   = acct.phone;
            a.Fax				   = acct.fax;        
            a.NumberOfEmployees	   = String.isNotBlank(acct.employees) ? Integer.ValueOf(acct.employees) : null;
            a.Website			   = acct.website;
            a.Industry             = Label.Core_RDC_ACCOUNT_INDUSTRY;
            a.Core_Account_Type__c = Label.Core_RDC_ACCOUNT_TYPE;
            a.Core_Sales_Group__c  = Label.Core_RDC_ACCOUNT_SALES_GROUP;
        }
        else //IPA attributes only
        {
            a.OwnerId 			   = [Select id from User where alias =: System.Label.PRM_UncoveredAccount].Id;
            a.RecordTypeId 		   = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            a.Industry			   = Label.PRM_Industry;
            a.Core_Sales_Groups__c = Label.PRM_Core_Sales_Group;
            a.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        }
        system.debug('a Ref========>'+a);
        return a;
    }
    // Helper method to determine, based on an ERPM Account record, whether or not it's RDC self-registration
    private static Boolean isRDCSelfRegistration(Core_IntegrationUtility.ERPM_Account acct) {
        
        for (Core_IntegrationUtility.ERPM_Engagement engg : acct.accountEngagements) {
            system.debug('####engg.engagementCode:'+engg.engagementCode);
            
            if (engg.engagementCode == Label.Core_RDC_Engagement_Code)//if (engg.engagementCode == RDC_ENGAGEMENT_CODE)
                return true;
        }
        return false;
    }
    
    private static List<Account> CreateRDCAccount(Core_IntegrationUtility.ERPM_Account acct)
    {
        List<Account> InsertAccts = new List<Account>();
        Account a = getAccountFromERPMAccount(acct,false);                       
        
        if (acct.enggDedupGroupCode == Label.Core_B2B_DEDUP_GROUP_CODE)
            a.Core_B2B_ERPM_Account_Number__c = acct.erpmAccountNumber;
        InsertAccts.add(a);
        System.debug('##### This account message looks like RDC self-reg, attempting to add account: ' + a);
        return InsertAccts;
        
    }
    public class ERPM_AccountWrapper {
        //String key {set;get;}
        List<Account> accountsToUpsert {set;get;}
        boolean IsPRMEngagement {set;get;}
        List<Core_IntegrationUtility.eRPM_Profile_Response> eRPM_ProfileResponses {set;get;}
    }
    
}