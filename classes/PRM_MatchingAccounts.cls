/*********************************************************************************************************************
Class Name    : PRM_MatchingAccounts
Version       : 1.0
Created Date  : June 2019
Function      : Displaying CIM results and matching account results 

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Rahul Kainth/Nishant      13 June,2019            Displaying CIM results and matching account results
* Nishant Dhar              13 Feb,2020             Modified to display sorted results for Matched Accounts
*********************************************************************************************************************/
public without sharing class PRM_MatchingAccounts {
    
    /*
* @description      : Returns CIM Results and matching account results by comparing with CIM Search Results table
* @name             : showAccounts
* @param            : Id recordId - Getting processInstanceWorkItem Id from approval request page
* @throws exception : NONE
*/
    @AuraEnabled
    public static MatchingAccountList showAccounts(String recordId){
        MatchingAccountList accountList = new MatchingAccountList();
        Map<String,string> accountIdResult = new Map<String,string>();
        Map<string,Account> accountCimMap = new Map<string,Account>();
        Map<string,integer> accSrchScore = new Map<string,integer>();
        list<integer> searchScore = new list<integer>();
        Map<string,Account> accountMap = new Map<string,Account>();
        List<PRM_CIMSearchResults__c> cimResults = new list<PRM_CIMSearchResults__c>();
        PRM_Registration_Request__c regRcd = new PRM_Registration_Request__c();
        String accNameConEmail = '';
        String dupStatus;
        // For the sorting logic
        map<string,string> searchScoreAccountsMap = new map<string,string>();
        map<id,account> ipaPartnerRoleAccs = new map<id,account>();
        map<id,account> ipaAccounts = new map<id,account>();
        map<id,account> nonIpaAccounts = new map<id,account>();
        map<id,list<PRM_AccountChannelMembership__c>> accountAcmMap = new map<id,list<PRM_AccountChannelMembership__c>>();
        map<id,string> cimAccountIdsMap = new map<id,string>();
        map<id,account> ipaPartnerRoleAccsWithCovered = new map<id,account>();
        map<id,account> ipaPartnerRoleAccsWithoutCovered = new map<id,account>();
        String accountIds;
        String partnerRole;
        Boolean isDuplicateContact = false;
        String requestedAccId;
        
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        System.debug(' Input RecordId '+recordId);
        
        String instanceId = [Select ProcessInstanceId from ProcessInstanceWorkitem where Id =: recordId].ProcessInstanceId;
        System.debug('INSTANCE ID'+instanceId);
        String targetObjectId = [Select TargetObjectId from ProcessInstance where Id =: instanceId].TargetObjectId;
        System.debug(' reg req Id '+targetObjectId);
        
        //get CIM Search Results matching with registration request Id
        cimResults = [Select Id,Name,PRM_RegReq_Id__c,PRM_RegReq_Id__r.PRM_Salesforce_ID__c,PRM_RegReq_Id__r.PRM_Email_ID__c,PRM_RegReq_Id__r.PRM_Enterprise_ID__c,PRM_RegReq_Id__r.PRM_Matching_Contact__c,PRM_RegReq_Id__r.PRM_Matching_Contact__r.Email,PRM_RegReq_Id__r.PRM_Matching_Contact__r.Account.Name,PRM_RegReq_Id__r.PRM_Dup_Status__c,PRM_Account_Id__c,PRM_SearchScore_Nbr__c,PRM_Gold_Record_Status_Nm__c,PRM_Gold_Trusted_Source_Nm__c,PRM_DUNS_Nbr__c,PRM_RegReq_Id__r.PRM_Address_Line_1__c,PRM_RegReq_Id__r.PRM_Phy_Address_Line_2__c,PRM_RegReq_Id__r.PRM_State_Province__c,PRM_RegReq_Id__r.PRM_Zip_Postal_Code__c,PRM_RegReq_Id__r.PRM_Country__c,PRM_RegReq_Id__r.PRM_Partner_Type__c,PRM_RegReq_Id__r.PRM_Account_Name__c,PRM_RegReq_Id__r.PRM_City__c,PRM_RegReq_Id__r.PRM_Partner_Role__c,PRM_CIM_ID__c from PRM_CIMSearchResults__c where PRM_RegReq_Id__c =:targetObjectId order by PRM_SearchScore_Nbr__c desc];
        // Code for the first row in CIM(only account details)
        Account acc = new Account();
        
        
        System.debug('cimResults.size()>> '+cimResults.size());
        
        if(cimResults!=null && cimResults.size() >0 ){
            if(cimResults[0].PRM_RegReq_Id__r.PRM_Matching_Contact__c != null) {
                if(cimResults[0].PRM_RegReq_Id__r.PRM_Matching_Contact__r.Email != null &&
                   cimResults[0].PRM_RegReq_Id__r.PRM_Matching_Contact__r.Email != '' && 
                   cimResults[0].PRM_RegReq_Id__r.PRM_Matching_Contact__r.Account.Name != null &&
                   cimResults[0].PRM_RegReq_Id__r.PRM_Matching_Contact__r.Account.Name != ''){
                       isDuplicateContact = true;
                       accNameConEmail = cimResults[0].PRM_RegReq_Id__r.PRM_Matching_Contact__r.Email+';'+cimResults[0].PRM_RegReq_Id__r.PRM_Matching_Contact__r.Account.Name;
                   }
            }
            System.debug('cimResults'+cimResults);
            System.debug('isDuplicateContact'+isDuplicateContact);
            
            //Keerthan added it as part of US570062
            if(cimResults[0].PRM_RegReq_Id__r.PRM_Salesforce_ID__c != null){
                Account existingAccount = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Core_CIM_ID__c,Industry,Owner.Name From Account Where id =: cimResults[0].PRM_RegReq_Id__r.PRM_Salesforce_ID__c];
                accountList.salesforceAccountId = cimResults[0].PRM_RegReq_Id__r.PRM_Salesforce_ID__c;
                accountList.existingAccInfo = existingAccount;
                System.debug('---->accountList.existingAccInfo'+accountList.existingAccInfo);
                if(cimResults[0].PRM_RegReq_Id__r.PRM_Email_ID__c != null){
                    List<Contact> con = [Select Id,Name from contact where Email =: cimResults[0].PRM_RegReq_Id__r.PRM_Email_ID__c];
                    if(con.size() == 0){
                        String existingAccountName = existingAccount.Name;
                        accountList.existingAccountContactEmail  = existingAccountName+';'+cimResults[0].PRM_RegReq_Id__r.PRM_Email_ID__c;
                        
                    }
                }
            }
            
            if(isDuplicateContact == false){ // Do further processing if there is no duplicate in matching contact field
                accountCimMap.put(null, acc);
                regRcd= cimResults[0].PRM_RegReq_Id__r;
                partnerRole = cimResults[0].PRM_RegReq_Id__r.PRM_Partner_Role__c;
                if(partnerRole!=null){
                    partnerRole=partnerRole.trim();  
                }
                system.debug('ONLY ACCOUNT --> '+accountCimMap);
                system.debug('Partner ROLE -->'+partnerRole);
                set<id> accids = new set<id>();
                for(PRM_CIMSearchResults__c result : cimResults){
                    //populate account ID and CIM Search Result Name
                    if (result.PRM_Account_Id__c!=null){
                        if(result.PRM_CIM_ID__c!=null && result.PRM_CIM_ID__c!=''){
                            accountIdResult.put(result.PRM_Account_Id__c,json.serialize(result));
                            accSrchScore.put(result.PRM_Account_Id__c,Integer.valueOf(result.PRM_SearchScore_Nbr__c));
                            accids.add(result.PRM_Account_Id__c);}
                        else{
                            cimAccountIdsMap.put(result.PRM_Account_Id__c,json.serialize(result));
                            accids.add(result.PRM_Account_Id__c);
                        }
                        //System.debug('@@ Map CIM Result '+accountIdResult);
                    }
                }
                system.debug('cimAccountIdsMap --> '+cimAccountIdsMap);
                System.debug('@@ Map CIM Result '+accids);
                for (string ids : accountIdResult.keyset()){
                    system.debug('accountIdResult -->'+ids);
                }
                //Iterate over accounts present in the map getting populated from CIM Search Results
                //Added Industry field in query for US452620
                //for(Account a : [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Industry from Account where Id IN: accountIdResult.keySet()]){
                for(Account a : [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Industry,Owner.Name,(select id,PRM_Partner_Role__c,PRM_Channel_Program_Level_Id__r.name,PRM_Channel_Program_Id__r.name,PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,PRM_Account_Id__r.Core_Covered_Account__c from Channel_Memberships1__r) from Account where Id IN: accids]){    
                    
                    if(accountIdResult.containsKey(a.Id)||cimAccountIdsMap.containsKey(a.Id)){
                        //acmList.add(a.Channel_Memberships1__r);
                        System.debug(' Account Record '+a);
                        // Logic for the sorting
                        accountMap.put(a.Id,a);
                        //accountAcmMap.put(a.Channel_Memberships1__r,a);
                        accountAcmMap.put(a.id,a.Channel_Memberships1__r);
                        if(a.Channel_Memberships1__r.size()==0){
                            nonIpaAccounts.put(a.id,null); 
                        }
                        if (accSrchScore.containskey(a.Id)){
                            searchScore.add(accSrchScore.get(a.Id));  
                        }
                    }
                }
                system.debug('accountAcmMap -->' +accountAcmMap);
                for(list<PRM_AccountChannelMembership__c> acmList : accountAcmMap.values()){
                    if(acmList!=null && acmList.size()>0){
                        for(PRM_AccountChannelMembership__c acm : acmList){
                            if(acm.PRM_Partner_Role__c == partnerRole && acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true && acm.PRM_Account_Id__r.Core_Covered_Account__c == true){
                                
                                ipaPartnerRoleAccsWithCovered.put(acm.PRM_Account_Id__c,null);
                                system.debug('Covered --> '+acm.PRM_Account_Id__c);
                                if(ipaAccounts.containsKey(acm.PRM_Account_Id__c)){
                                    ipaAccounts.remove(acm.PRM_Account_Id__c);
                                }    
                            }
                            else if(!ipaPartnerRoleAccsWithCovered.containskey(acm.PRM_Account_Id__c) && acm.PRM_Partner_Role__c == partnerRole && acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true && acm.PRM_Account_Id__r.Core_Covered_Account__c == false){
                                
                                ipaPartnerRoleAccsWithoutCovered.put(acm.PRM_Account_Id__c,null);
                                system.debug('Uncovered acc --> '+acm.PRM_Account_Id__c);
                                if(ipaAccounts.containsKey(acm.PRM_Account_Id__c)){
                                    ipaAccounts.remove(acm.PRM_Account_Id__c);
                                }    
                            }
                            else if (!ipaAccounts.containsKey(acm.PRM_Account_Id__c) && acm.PRM_Partner_Role__c == partnerRole && acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true){
                                //ipaPartnerRoleAccs.put(acm.PRM_Account_Id__c,null);
                                system.debug('ipaPR --> '+ipaPartnerRoleAccs);
                            }
                            else if(acm.PRM_Channel_Program_Id__r.name==System.Label.PRM_Intel_Partner_Alliance && acm.PRM_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c==true){
                                if(!ipaPartnerRoleAccs.containsKey(acm.PRM_Account_Id__c) && !ipaPartnerRoleAccsWithCovered.containskey(acm.PRM_Account_Id__c) && !ipaPartnerRoleAccsWithoutCovered.containskey(acm.PRM_Account_Id__c)){
                                    ipaAccounts.put(acm.PRM_Account_Id__c,null);
                                    system.debug('ipa --> '+ipaAccounts);
                                }
                            }else{
                                if(!ipaPartnerRoleAccs.containsKey(acm.PRM_Account_Id__c) && !ipaAccounts.containsKey(acm.PRM_Account_Id__c)){
                                    nonIpaAccounts.put(acm.PRM_Account_Id__c,null);
                                    system.debug('nonIpaAccounts --> '+nonIpaAccounts);
                                }
                            }
                        }
                    }else{
                        //nonIpaAccounts.put(accId,null);
                    }
                }
                
                //For Empty ACMrecord scenario to put as nonIPA record
                for(id accId : accids){
                    if(!accountAcmMap.containsKey(accId)){
                        System.debug('Issue Acct : '+accId);
                        nonIpaAccounts.put(accId,null);
                        
                    }
                }
                
                
                //Logic for sorting based on the search score and partner role
                map<string,list<string>> sortedAccounts = new map<string,list<string>>();
                
                map<string,integer> sortIpaPartnerRoleMap = new map<string,integer>();
                map<string,integer> sortIpaMap = new map<string,integer>();
                map<string,integer> sortNonIpaMap = new map<string,integer>();
                map<string,integer> sortedCoveredAccountsMap = new map<string,integer>();
                map<string,integer> sortedUnCoveredAccountsMap = new map<string,integer>();
                list<string> sortIpaList = new list<string>();
                list<string> sortNonIpaList = new list<string>();
                list<string> sortedCoveredAccountsList = new list<string>();
                list<string> sortedUnCoveredAccountsList = new list<string>();
                
                list<string> sortedAccountsList = new list<string>();
                
                for (String accIdVal : cimAccountIdsMap.keyset()){
                    
                    
                    if (ipaPartnerRoleAccsWithCovered.containskey(accIdVal)){
                        
                        
                        sortedCoveredAccountsList.add(accIdVal);                         
                        system.debug('sortedCoveredAccountsdom  -->' +accIdVal);}
                    
                    if (ipaPartnerRoleAccsWithoutCovered.containskey(accIdVal)){
                        
                        sortedUnCoveredAccountsMap.put(accIdVal,accSrchScore.get(accIdVal));
                        sortedUnCoveredAccountsList.add(accIdVal);}
                    system.debug('sortedUnCoveredAccountsdom  -->' +accIdVal);
                    
                    if (ipaAccounts.containskey(accIdVal)){
                        
                        sortIpaMap.put(accIdVal,accSrchScore.get(accIdVal));
                        sortIpaList.add(accIdVal);
                        system.debug('sortIpaMapdom  -->' +accIdVal);
                    }
                    if (nonIpaAccounts.containskey(accIdVal)){
                        
                        sortNonIpaMap.put(accIdVal,accSrchScore.get(accIdVal));
                        sortNonIpaList.add(accIdVal);
                        system.debug('sortNonIpaMapdom  -->' +accIdVal);
                    }
                    
                    
                }
                
                sortedAccountsList.addall(sortedCoveredAccountsList);
                sortedAccountsList.addall(sortedUnCoveredAccountsList);
                sortedAccountsList.addall(sortIpaList);
                sortedAccountsList.addall(sortNonIpaList);
                sortedCoveredAccountsList.clear();
                sortedUnCoveredAccountsList.clear();
                sortIpaList.clear();
                sortNonIpaList.clear();
                sortedAccounts.put('accIdVal',sortedAccountsList);
                for (String sortedaccountId : sortedAccounts.get('accIdVal')){
                    system.debug('sortedAccountsdomain --> '+sortedaccountId);
                    if(cimResults[0].PRM_RegReq_Id__r.PRM_Salesforce_ID__c!=null && accountMap.containskey(cimResults[0].PRM_RegReq_Id__r.PRM_Salesforce_ID__c)){
                        requestedAccId=cimResults[0].PRM_RegReq_Id__r.PRM_Salesforce_ID__c;
                    }
                    if(sortedaccountId!=requestedAccId){
                        accountCimMap.put(cimAccountIdsMap.get(sortedaccountId),accountMap.get(sortedaccountId));
                    }
                }
                for (String accIdVal : accountIdResult.keyset()){
                    
                    
                    if (ipaPartnerRoleAccsWithCovered.containskey(accIdVal)){
                        
                        
                        sortedCoveredAccountsList.add(accIdVal);                         
                        system.debug('sortedCoveredAccounts  -->' +accIdVal);}
                    
                    if (ipaPartnerRoleAccsWithoutCovered.containskey(accIdVal)){
                        
                        sortedUnCoveredAccountsMap.put(accIdVal,accSrchScore.get(accIdVal));
                        sortedUnCoveredAccountsList.add(accIdVal); 
                    }
                    system.debug('sortedUnCoveredAccounts  -->' +accIdVal);
                    
                    if (ipaAccounts.containskey(accIdVal)){
                        
                        sortIpaMap.put(accIdVal,accSrchScore.get(accIdVal));
                        sortIpaList.add(accIdVal);
                        system.debug('sortIpaMap  -->' +accIdVal);
                    }
                    if (nonIpaAccounts.containskey(accIdVal)){
                        
                        sortNonIpaMap.put(accIdVal,accSrchScore.get(accIdVal));
                        system.debug('sortNonIpaMap  -->' +accIdVal);
                        sortNonIpaList.add(accIdVal);
                    }
                    
                    
                }
                sortedAccountsList.addall(sortedCoveredAccountsList);
                sortedAccountsList.addall(sortedUnCoveredAccountsList);
                sortedAccountsList.addall(sortIpaList);
                sortedAccountsList.addall(sortNonIpaList);
                sortedAccounts.put('accIdVal',sortedAccountsList);
                
                
                // Sorted accounts
                //for(String score : sortedAccounts.keyset()){
                for (String sortedaccountId : sortedAccounts.get('accIdVal')){
                    system.debug('sortedAccounts --> '+sortedaccountId);
                    if(cimResults[0].PRM_RegReq_Id__r.PRM_Salesforce_ID__c!=null && accountMap.containskey(cimResults[0].PRM_RegReq_Id__r.PRM_Salesforce_ID__c)){
                        requestedAccId=cimResults[0].PRM_RegReq_Id__r.PRM_Salesforce_ID__c;
                    }
                    
                    if(!accountCimMap.values().contains(accountMap.get(sortedaccountId)) && requestedAccId!=sortedaccountId){
                        accountCimMap.put(accountIdResult.get(sortedaccountId),accountMap.get(sortedaccountId));
                    }
                }
                //}
                
            } //isDuplicateContact Ends  
        }
        else {
            PRM_Registration_Request__c regReq = [Select id,PRM_Salesforce_ID__c,PRM_Email_ID__c,PRM_Enterprise_ID__c,PRM_Matching_Contact__c,PRM_Matching_Contact__r.Email,PRM_Matching_Contact__r.Account.Name,PRM_Dup_Status__c,PRM_Partner_Role__c,PRM_Partner_Type__c from PRM_Registration_Request__c where id =:targetObjectId];
            regRcd=regReq;
            if (regReq.PRM_Matching_Contact__c != null){
                if(regReq.PRM_Matching_Contact__r.Email != null && regReq.PRM_Matching_Contact__r.Email != '' && regReq.PRM_Matching_Contact__r.Account.Name != null && regReq.PRM_Matching_Contact__r.Account.Name != ''){
                    accNameConEmail = regReq.PRM_Matching_Contact__r.Email+';'+regReq.PRM_Matching_Contact__r.Account.Name;
                }
            }
            
            //Keerthan added it as part of US570062
            if(regReq.PRM_Salesforce_ID__c != null){
                Account existingAccount = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Core_CIM_ID__c,Industry,Owner.Name From Account Where id =: regReq.PRM_Salesforce_ID__c];
                accountList.salesforceAccountId = regReq.PRM_Salesforce_ID__c;
                accountList.existingAccInfo = existingAccount;
                System.debug('---->accountList.existingAccInfo'+accountList.existingAccInfo);
                if(regReq.PRM_Email_ID__c != null){
                    List<Contact> con = [Select Id,Name from contact where Email =: regReq.PRM_Email_ID__c];
                    if(con.size() == 0){
                        String existingAccountName = existingAccount.Name;
                        accountList.existingAccountContactEmail  = existingAccountName+';'+regReq.PRM_Email_ID__c;
                        
                    }
                }
            }
        }
        
        System.debug(' accNameConEmail '+accNameConEmail);  
        System.debug('@@ Final Map '+accountCimMap);
        accountList.accountMap = accountCimMap;
        accountList.accountContactEmail = accNameConEmail;
        accountList.accList=regRcd;
        //System.debug(' WRAPPER '+accountList);
        return accountList;
    }
    
    /*
* @description      : Inserts contact, account contact relationship,contact subscription association,account channel membership,
legal agreement association,profile responses and updating account and assigning benefits/entitlements.
Also, approving approval request and returning processInstanceStep Id for redirecting page
* @name             : insertRecords
* @param            : String regRequestId - Getting registration request Id from lightning component
* @param            : Account accountResult - Getting account result  from lightning component table
* @param            : Id recordId - Getting processInstanceWorkItem Id from lightning component
* @throws exception : NONE
*/
    
    @AuraEnabled
    public static String insertRecords(String regRequestId,Account accountResult,String recordId) {
        
        Boolean isIPA ;
        String cimMatchStatus;
        Account accountToProcess;
        Contact contactToProcess;
        String bizOrgType;
        String accountBizOrgType;
        Set<String> setBizOrgType = new Set<String>();
        System.debug(' Reg Req ID '+regRequestId);
        System.debug(' ACCOUNT RESULT '+accountResult);
        System.debug(' RECORD ID '+recordId);
        String stepId;
        Savepoint sp = Database.setSavepoint();
        try{
            if(regRequestId != null && accountResult != null && recordId != null)
            {
                PRM_Registration_Request__c regReq = [Select Id,PRM_First_Name__c,PRM_Partner_Type__c,PRM_Account_Partner_Type__c,PRM_Partner_Role__c,PRM_Last_Name__c,PRM_Channel_Program__c,PRM_Channel_Program_Level__c,PRM_Dup_Status__c,PRM_Email_ID__c,PRM_Account_Phone__c,PRM_Person_Phone_Number__c,PRM_Job_Function__c,PRM_Preferred_Language__c,PRM_Contact_Login_ID__c,PRM_Enterprise_ID__c,PRM_Legal_Agreements__c,PRM_Partner_Relationship__c,PRM_Profile_Response__c,PRM_Subscriptions__c,PRM_Contact_Country__c from PRM_Registration_Request__c where Id=:regRequestId];
                
                cimMatchStatus = regReq.PRM_Dup_Status__c;
                bizOrgType = regReq.PRM_Partner_Type__c;
                accountBizOrgType= regReq.PRM_Account_Partner_Type__c;
                
                System.debug('@@ bizOrgType'+bizOrgType);
                System.debug('@@ accountBizOrgType'+accountBizOrgType);
                
                if(bizOrgType != null && String.isNotBlank(String.valueOf(bizOrgType))){
                    setBizOrgType.addAll(bizOrgType.split(';'));
                }
                if(accountBizOrgType != null && String.isNotBlank(String.valueOf(accountBizOrgType))){
                    setBizOrgType.addAll(accountBizOrgType.split(';'));
                }
                System.debug('setBizOrgType'+setBizOrgType);
                
                accountToProcess= accountResult;
                
                //Added by Rahul for US596330
                //starts
                if(regReq.PRM_Partner_Role__c != null && String.isNotBlank(String.valueOf(regReq.PRM_Partner_Role__c))){
                    if(regReq.PRM_Partner_Role__c.contains(Label.PRM_FPGA_Desginer)){
                        System.debug('update FPGA flag');
                        accountToProcess.Core_PSG_Account__c = true;
                    }
                }
                //ends
                
                //Added by Rahul for US596149
                //starts
                String existingAccountType = accountToProcess.Core_Account_Type__c;
                Set<String> existingAccTypeSet = new Set<String>();
                if(existingAccountType != null && String.isNotBlank(String.valueOf(existingAccountType))){
                    System.debug('@@ Existing biz org');
                    existingAccTypeSet.addAll(existingAccountType.split(';'));
                    System.debug('existingAccTypeSet'+existingAccTypeSet);
                    if(setBizOrgType.size()>0){
                        existingAccTypeSet.addAll(setBizOrgType);
                    }
                }
                else{
                    System.debug('@@ Empty biz org');
                    if(setBizOrgType.size()>0){
                        existingAccTypeSet.addAll(setBizOrgType);
                    }
                }
                System.debug('Final existingAccTypeSet'+existingAccTypeSet);

                String accountType;
                if(existingAccTypeSet.size()>0){
                    System.debug('if there are existing values in biz org type of account object');
                    for(String s : existingAccTypeSet){
                        if(accountType != null){
                            accountType = accountType+';'+s;
                        }
                        else {
                            accountType = s;
                        }
                    }
                    System.debug('accountType'+accountType);
                    accountToProcess.Core_Account_Type__c = accountType;
                }
                //ends 
                System.debug('accountToProcess.Core_Account_Type__c'+accountToProcess.Core_Account_Type__c);
                
                List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
                acmList= [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: accountToProcess.id and PRM_Channel_Program_Id__c =: regReq.PRM_Channel_Program__c and PRM_Partner_Role__c =: regReq.PRM_Partner_Role__c];
                PRM_CreateAccountAndRelatedRecords.approveACM(acmList);
                //changes in logic to identify, account is IPA or not
                //isIPA= accountToProcess.Core_Intel_Partner_Alliance_PartnerGroup__c ;    
                isIPA = accountToProcess.Core_Intel_Partner_Alliance_PartnerGroup__c && (accountToProcess.Core_Account_Type__c != null && String.isNotBlank(String.valueOf(accountToProcess.Core_Account_Type__c)) &&  accountToProcess.Core_Account_Type__c.split(';').contains(regReq.PRM_Partner_Type__c)) && (acmList != null && acmList.size() >0 );
                system.debug('isIPA Flag for reUse---->'+isIPA);
                if(!isIPA)
                {
                    accountToProcess.Core_Intel_Partner_Alliance_PartnerGroup__c = true ;
                    String existingRole = accountToProcess.Core_IPA_Partner_Role__c;
                    if(accountToProcess.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(accountToProcess.Core_IPA_Partner_Role__c)))
                    {   Set<String> existingAccRoleSet = new Set<String>();
                     existingAccRoleSet.addAll(existingRole.split(';'));
                     if(! existingAccRoleSet.contains(regReq.PRM_Partner_Role__c)) {accountToProcess.Core_IPA_Partner_Role__c = existingRole+';'+regReq.PRM_Partner_Role__c ; }
                    }else {
                        accountToProcess.Core_IPA_Partner_Role__c = regReq.PRM_Partner_Role__c ;
                    }
                    
                    /*if(accountToProcess.Core_Account_Type__c != null && String.isNotBlank(String.valueOf(accountToProcess.Core_Account_Type__c)))
{    Set<String> existingAccTypeSet = new Set<String>();
existingAccTypeSet.addAll(existingAccountType.split(';'));
if(! existingAccTypeSet.contains(regReq.PRM_Partner_Type__c)) {accountToProcess.Core_Account_Type__c = existingAccountType+';'+regReq.PRM_Partner_Type__c ;}
}else {
accountToProcess.Core_Account_Type__c = regReq.PRM_Partner_Type__c ;
}*/
                    
                    //Added for US452620                  
                    if(accountToProcess.Industry == null || String.isBlank(String.valueOf(accountToProcess.Industry))){
                        accountToProcess.Industry = System.Label.PRM_Needs_Defined;
                    }
                    system.debug('Existing values from ReUse '+existingRole+'@@'+existingAccountType);
                    system.debug('Updated values from reUse'+accountToProcess);
                }
                update accountToProcess;
                //PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(Account acc, Contact cont,Boolean isIPA ,PRM_Registration_Request__c regReq)    
                PRM_CreateAccountAndRelatedRecords.businessEvent = System.label.PRM_Welcome_Email_Existing_Event;
                PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(accountToProcess, contactToProcess,isIPA,regReq);
                //to stop invoking process builder in case of reUse reg req.
                regReq.PRM_TriggerProcess__c = true;
                update regReq;
                if(recordId != null &&  recordId != ''){
                    String instanceId = [Select ProcessInstanceId from ProcessInstanceWorkitem where Id =: recordId].ProcessInstanceId;
                    System.debug(' INSTANCE ID---->'+instanceId);
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments('Approving request.');
                    req2.setAction('Approve');
                    req2.setWorkitemId(recordId);
                    Approval.ProcessResult result2 =  Approval.process(req2);
                    ProcessInstanceStep instanceStep = [Select Id,ProcessInstanceId,StepNodeId,StepStatus from ProcessInstanceStep where ProcessInstanceId=:instanceId AND StepStatus =: System.Label.PRM_Engagement_Status_Approved];
                    System.debug(' instanceStep.ID'+instanceStep.Id);
                    stepId=instanceStep.Id;
                }
                return stepId;
            }
        }catch(Exception e)
        {
            PRM_ErrorUtilityClass.logError(e);
            Database.rollback( sp );  
        }
        return stepId;
    }  
    
    //Rahul added it as part of US584803
    /** @description      : Returning account result on the basis of account Id and Intel account Record Type
*   @name             : searchAccount
*   @param            : String accntId - Getting account Id from lightning component
*/
    @AuraEnabled
    public static MatchingAccountList searchAccount(String accntId){
        System.debug('accntId'+accntId);
        MatchingAccountList wrapperList = new MatchingAccountList();
        
        String errorMsg = 'Please provide a valid Account Id with record type as Intel Account';
        Account a;
        Id intelaccountRT = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        try{
            a = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_CIM_ID__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Industry,Owner.Name from Account where Id =:accntId AND RecordTypeId = :intelaccountRT];
            if(a != null) {
                System.debug('a'+a);
                wrapperList.accountList = a;
            }
        }catch(Exception e){
            PRM_ErrorUtilityClass.logError(e);
            // Database.rollback( sp ); 
            if(a == null){
                System.debug('Catch wrapperList.accountList'+a);
                wrapperList.errorMsg = errorMsg;
            }
        }
        System.debug('wrapperList'+wrapperList);
        return wrapperList;
    }
    
    
    public class MatchingAccountList {
        
        @AuraEnabled
        public Map<string,Account> accountMap = new Map<string,Account>();
        @AuraEnabled
        public String accountContactEmail = '';
        @AuraEnabled
        public PRM_Registration_Request__c accList = new PRM_Registration_Request__c();
        @AuraEnabled
        public String errorMsg = '';
        @AuraEnabled
        public Account accountList;
        @AuraEnabled
        public String existingAccountContactEmail='';
        @AuraEnabled
        public String salesforceAccountId;
        @AuraEnabled
        public Account existingAccInfo;
    }
}