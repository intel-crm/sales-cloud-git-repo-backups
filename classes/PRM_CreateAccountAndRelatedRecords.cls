/*********************************************************************************************************************
Apex Class Name  : PRM_CreateAccountAndRelatedRecords
Version       : 1.0
Created Date  : NOV 2018
Function      : Create New Account, Contact and their related Records using registration request object field values.

Modification Log 
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Eswara                    19/11/2018
* Harshit                   25/07/2019
* GopiKrishna           26/09/2021            Added Error Logging 
*********************************************************************************************************************/

public without sharing class PRM_CreateAccountAndRelatedRecords
{       
    /**
*  @description      : Create New Account, Contact and their related Records.
*  @name             : createAccountAndRelatedRecords
*  @param            : List<PRM_Registration_Request__c>
*  @throws exception : NONE
**/    
    public static String businessEvent = '';
    public static String logEntryMsgString='';
    public static String transactionEmail ='';
    
    public static final String LOG_ENTRY_ORIGIN   = 'CreateAccountAndRelatedRecords';
    public static final String LOG_ENTRY_PROJECT  = 'IPA Registrations';
    public static final String LOG_ENTRY_SCOPE    = 'CreateAccountAndRelatedRecords';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static string logEntries;    
    public static Boolean ipaAccount;
    public static Map<Id, String> mapToUpdateWebsite = new Map<Id, String>(); //Rohit-Adding as part of website Stapping on VXR on Account Resue Scenario

    // public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh); // IPA Switch Removal

    @InvocableMethod
    public static void createAccountAndRelatedRecords(List<PRM_Registration_Request__c> regReqList)
    {                               
        //Rollback everything, in case of any exception
        //Savepoint sp = Database.setSavepoint();
         set<String> reordIds=new set<string>();              
        try{
            Set<String> setPartnerRole = new Set<String>(); 
            Set<String> setBizOrgType = new Set<String>(); 
           
            List<processRegRecordWrapper> processRegRecordWrapperList = new List<processRegRecordWrapper>();
            
            logEntryMsgString+='\ncreateAccountAndRelatedRecords Method invoked at:'+System.Now().format('MM/dd/YYYY HH:MM:SS','PST')+' PST dt@@@';
            
            //Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            
            Boolean isACRActive = null;
            Boolean isACMActive = null;   
            Boolean isIPA ;
            String accNumber = '';
            String  cimMatchStatus;
            transactionEmail='';
            Map<Id, Id> regReqIdExistingContIdMap = new Map<Id, Id>();
            Set<Id> regReqDuplicateAccIdSet = new Set<Id>();
            Set<Id> accToBeQueried = new Set<Id>();
            Map<Id, PRM_Registration_Request__c> regReqMap = new Map<Id, PRM_Registration_Request__c>();
            Set<String> regRequestPartnerRoleSet = new Set<String>();
            Set<String> regRequestChannelProgramSet = new Set<String>();
            Map<Id, Contact> existingContactMap;
            Map<Id, Account> existingAccountMap = new Map<Id, Account>();
            //Set<id> accIdSet = new Set<Id>();
            Set<String> regReqEmails = new Set<String>();
            Set<id> accNumUpdateSet = new Set<id>();
            Map<String, Id> mapEmailToContacId = new Map<String, Id>(); 
            Map<Id, List<PRM_AccountChannelMembership__c>> accountIdACMListMap = new Map<Id, List<PRM_AccountChannelMembership__c>>();
            Map<Id, List<PRM_Account_Contact_Relationship__c>> accountIdACRListMap = new Map<Id, List<PRM_Account_Contact_Relationship__c>>();
            List<Account> allAccListForEnqueue = new List<Account>();
            Map<Id, List<ContentDocumentLink>> regRequestFilesMap = new Map<Id, List<ContentDocumentLink>>();
            //Processing all registration requests
            for(PRM_Registration_Request__c regReqRecord: regReqList){ 
                reordIds.add(regReqRecord.id);         
                regReqMap.put(regReqRecord.id, regReqRecord);
                regRequestPartnerRoleSet.add(regReqRecord.PRM_Partner_Role__c);
                regRequestChannelProgramSet.add(regReqRecord.PRM_Channel_Program__c);
                
                //Check for Existing Contact
                if(regReqRecord.PRM_Matching_Contact__c != null)
                {                
                    regReqIdExistingContIdMap.put(regReqRecord.id, regReqRecord.PRM_Matching_Contact__c);            
                    logEntryMsgString+='\n***Processing Existing Contact'+regReqRecord.PRM_Matching_Contact__c;
                }
                if(String.isNotBlank(regReqRecord.PRM_Email_ID__c)){
                    regReqEmails.add(regReqRecord.PRM_Email_ID__c);
                }
                //Check for Duplicate Account(New User/Existing Account)
                if(regReqRecord.PRM_Salesforce_ID__c != null){              
                    regReqDuplicateAccIdSet.add(regReqRecord.PRM_Salesforce_ID__c);
                    logEntryMsgString+='\n***Duplicate Account Found'+regReqRecord.PRM_Salesforce_ID__c;
                }                                   
            }            
            //Get existing contact details
            if(!regReqIdExistingContIdMap.isEmpty() || !regReqEmails.isEmpty() || !regReqDuplicateAccIdSet.isEmpty()){
                //Get any files attached to request record      
                system.debug('reordIdsssss'+reordIds);   
                if(reordIds!=null && !reordIds.isEmpty())  {
                    for(ContentDocumentLink contDocLinkRec: [Select id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: reordIds]){
                    if(regRequestFilesMap.containsKey(contDocLinkRec.LinkedEntityId)){
                        List<ContentDocumentLink> filesList = regRequestFilesMap.get(contDocLinkRec.LinkedEntityId);
                        filesList.add(contDocLinkRec);
                    	regRequestFilesMap.put(contDocLinkRec.LinkedEntityId, filesList);	    
                    }else{
                        regRequestFilesMap.put(contDocLinkRec.LinkedEntityId, new List<ContentDocumentLink>{contDocLinkRec});	        
                    }    
                }    
             }     
                         

                List<Contact> contList = new List <Contact>();
                
                contList = [
                    SELECT 
                    Id,
                    AccountId,
                    Email,
                    Core_IPA_Contact_Segment__c,
                    Core_eRPM_Language_Code__c,
                    Core_IPA_PartnerRole__c,
                    Core_Do_Not_Contact__c,
                    Core_Preferred_Language__c,
                    PRM_Wechat_Union_Id__c,
                    Core_Login_Status__c,
                    Core_Enterprise_Id__c,
                    Account.Core_IPA_Partner_Segment__c,
                    Account.Name,
                    Account.AccountNumber,
                    Account.Core_Intel_Partner_Alliance_PartnerGroup__c,
                    Account.Core_Account_Type__c,
                    Account.Core_IPS_Active__c,
                    Account.Core_IPA_Partner_Role__c,
                    Account.Core_User_Defined_Phone_Number__c,
                    Account.Core_User_Defined_Website__c,
                    Account.ShippingCountryCode,
                    Account.ShippingStateCode,
                    Account.ShippingStreet,
                    Account.ShippingCity,
                    Account.ShippingPostalCode,
                    Account.BillingCountryCode,
                    Account.BillingStateCode,
                    Account.BillingStreet,
                    Account.BillingCity,
                    Account.BillingPostalCode
                    FROM Contact 
                    WHERE Id IN : regReqIdExistingContIdMap.values() 
                    OR Email IN: regReqEmails
                    OR AccountId IN :regReqDuplicateAccIdSet];
                
                existingContactMap = new Map<Id, Contact>(contList);
                
                for(Contact con: existingContactMap.values()){ 
                    regReqDuplicateAccIdSet.add(con.AccountId);
                    if(regReqIdExistingContIdMap.containskey(con.id) || regReqEmails.contains(con.email)){
                        mapEmailToContacId.put(con.Email, con.id);
                    }     
                    if(!existingAccountMap.containsKey(con.AccountId)){
                        Account acc = new Account(
                        Id = con.AccountId,
                        //Core_IPA_Partner_Segment__c = !ipaRefresh?con.Account.Core_IPA_Partner_Segment__c:'', // IPA Switch Removal
                        Name = con.Account.Name,
                        AccountNumber = con.Account.AccountNumber,
                        Core_Intel_Partner_Alliance_PartnerGroup__c = con.Account.Core_Intel_Partner_Alliance_PartnerGroup__c,
                        Core_Account_Type__c = con.Account.Core_Account_Type__c,
                        Core_IPS_Active__c = con.Account.Core_IPS_Active__c,
                        Core_IPA_Partner_Role__c = con.Account.Core_IPA_Partner_Role__c,
                        Core_User_Defined_Phone_Number__c = con.Account.Core_User_Defined_Phone_Number__c,
                        ShippingCountryCode = con.Account.ShippingCountryCode,
                        ShippingStateCode = con.Account.ShippingStateCode,
                        ShippingStreet = con.Account.ShippingStreet,
                        ShippingCity = con.Account.ShippingCity,
                        ShippingPostalCode = con.Account.ShippingPostalCode,
                        BillingCountryCode = con.Account.BillingCountryCode,
                        BillingStateCode = con.Account.BillingStateCode,
                        BillingStreet = con.Account.BillingStreet,
                        BillingCity = con.Account.BillingCity,
                        BillingPostalCode = con.Account.BillingPostalCode,
                        Core_User_Defined_Website__c = con.Account.Core_User_Defined_Website__c
                    );
                        existingAccountMap.put(con.AccountId,acc);
                    }
                }   
            }
            //to handle account with no contact
            if(!regReqDuplicateAccIdSet.isEmpty()){
                for(Id accId : regReqDuplicateAccIdSet){
                    if(!existingAccountMap.containsKey(accId)){
                        accToBeQueried.add(accId);
                    }
                }
            }
            
            if(!accToBeQueried.isEmpty()){
                for(Account acc : [
                    SELECT 
                    Id,
                    Core_IPA_Partner_Segment__c,
                    Name,
                    AccountNumber,
                    Core_Intel_Partner_Alliance_PartnerGroup__c,
                    Core_Account_Type__c,
                    Core_IPS_Active__c,
                    Core_IPA_Partner_Role__c,
                    Core_User_Defined_Phone_Number__c,
                    ShippingCountryCode,
                    ShippingStateCode,
                    ShippingStreet,
                    ShippingCity,
                    ShippingPostalCode,
                    BillingCountryCode,
                    BillingStateCode,
                    BillingStreet,
                    BillingCity,
                    BillingPostalCode,
                    Core_User_Defined_Website__c,(Select id,PRM_Partner_Role__c,PRM_Status_Nm__c,PRM_InActive_Ind__c from Account_Contact_Relationships__r)
                    FROM Account
                    WHERE Id In :accToBeQueried
                ]){
                    existingAccountMap.put(acc.Id, acc);
                }
            }
            
            Map<Id, PRM_AccountChannelMembership__c> mapACM;
            if(!regReqDuplicateAccIdSet.isEmpty()){
                if(!regRequestChannelProgramSet.isEmpty()){
                    mapACM = new Map<Id, PRM_AccountChannelMembership__c>();
                    for (PRM_AccountChannelMembership__c acm : [
                        SELECT 
                            Id,
                            PRM_Account_Id__c,
                            PRM_Partner_Role__c,
                            PRM_Channel_Program_Id__c,
                            PRM_Status_Nm__c
                        FROM PRM_AccountChannelMembership__c
                        WHERE PRM_Channel_Program_Id__c IN :regRequestChannelProgramSet 
                            AND PRM_Account_Id__c IN :regReqDuplicateAccIdSet]
                    ) {
                        mapACM.put(acm.id, acm);
                        if(regRequestPartnerRoleSet.contains(acm.PRM_Partner_Role__c)){
                            if(accountIdACMListMap.containsKey(acm.PRM_Account_Id__c)){
                                accountIdACMListMap.get(acm.PRM_Account_Id__c).add(acm);    
                            }else{
                                accountIdACMListMap.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});
                            }
                        }
                    }
                }


                
            }
            
            
            if(!regReqDuplicateAccIdSet.isEmpty())
            {
              for(PRM_Account_Contact_Relationship__c acr :[
                    SELECT 
                        Id,
                        PRM_InActive_Ind__c, 
                        PRM_Partner_Role__c,
                        PRM_Status_Nm__c, PRM_relationship_id__c,PRM_Relationship_Id__r.Name,
                        PRM_AGS_Identity_Creation_Fail__c,PRM_Account_Id__c
                    FROM PRM_Account_Contact_Relationship__c
                    WHERE PRM_Account_Id__c IN:regReqDuplicateAccIdSet]){
                        if(accountIdACRListMap.containsKey(acr.PRM_Account_Id__c)){
                                accountIdACRListMap.get(acr.PRM_Account_Id__c).add(acr);    
                            }else{
                                accountIdACRListMap.put(acr.PRM_Account_Id__c, new List<PRM_Account_Contact_Relationship__c>{acr});
                            }    

                    }

            }

            List<Account> accountListToUpsert = new List<Account>();
            for(PRM_Registration_Request__c regReqRecord: regReqList){                            
                //resetting variables
                setBizOrgType.clear();
                isACRActive = null;
                isACMActive = null;
                isIPA = null;
                accNumber = null;
                cimMatchStatus = null;
                
                String bizOrgType = regReqRecord.PRM_Partner_Type__c;
                String partnerRole = regReqRecord.PRM_Partner_Role__c;
                String accountBizOrgType= regReqRecord.PRM_Account_Partner_Type__c;
                transactionEmail = transactionEmail + ';' + regReqRecord.PRM_Email_ID__c;
                if(String.isBlank(regReqRecord.PRM_Matching_Contact__c) && String.isNotBlank(regReqRecord.PRM_Email_ID__c)
                   && mapEmailToContacId.containsKey(regReqRecord.PRM_Email_ID__c)){
                    //regReqRecord.PRM_Matching_Contact__c = mapEmailToContacId.get(regReqRecord.PRM_Email_ID__c);
                }
                if(String.isNotBlank(String.valueOf(bizOrgType))){
                    setBizOrgType.addAll(bizOrgType.split(';'));
                }
                //System.debug('setBizOrgType'+setBizOrgType);
                if(String.isNotBlank(String.valueOf(accountBizOrgType))){
                    setBizOrgType.addAll(accountBizOrgType.split(';'));
                }
                
                if(String.isNotBlank(String.valueOf(partnerRole))){
                    setPartnerRole.addAll(partnerRole.split(';'));
                }
                //System.debug('setPartnerRole'+setPartnerRole);
               
                
                //#################################
                //##Scenario : Existing Contact and Existing Account
                if((regReqIdExistingContIdMap.containsKey(regReqRecord.id) || mapEmailToContacId.containsKey(regReqRecord.PRM_Email_ID__c)) && !existingContactMap.isEmpty() //TODO: can we check if && can be replace with || and use mapEmailToContacId.get(request.email)
                    && (existingContactMap.get(regReqIdExistingContIdMap.get(regReqRecord.id)) != null || existingContactMap.get(mapEmailToContacId.get(regReqRecord.PRM_Email_ID__c)) != null))
                 {
                    Contact existingContact = regReqIdExistingContIdMap.get(regReqRecord.id) != null ? existingContactMap.get(regReqIdExistingContIdMap.get(regReqRecord.id)) : existingContactMap.get(mapEmailToContacId.get(regReqRecord.PRM_Email_ID__c));
                    Account existingAccount = existingAccountMap.get(existingContact.AccountId);
                      if(existingAccount != null){
                          PRM_CreateAccountAndRelatedRecords.partnerSegOnExistingAcc(existingAccount,regReqRecord);
                    
                      }
                    List<PRM_AccountChannelMembership__c> acmListToCheckIPA = new List<PRM_AccountChannelMembership__c>();
                    if(existingAccount != null) {
                        //change in logic to identify an Account as IPA
                        
                         //acmListToCheckIPA= [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: existingAccount.id and PRM_Channel_Program_Id__c =: regReqRecord.PRM_Channel_Program__c and PRM_Partner_Role__c =: regReqRecord.PRM_Partner_Role__c];                      
                         acmListToCheckIPA = PRM_IPA_Utility.getACMList(accountIdACMListMap.get(existingAccount.id), regReqRecord);                                                
                    }
                    /*Utkarsh - PRB10047472 - Passing 'PRM_Partner_Type__c' while calling 'isAccountIPAForPartnerRole' instead of 'partner role' which we were passing earlier*/
                            /*   isIPA = PRM_IPA_Utility.isAccountIPAForPartnerRole(existingAccount, acmListToCheckIPA, regReqRecord.PRM_Partner_Type__c);
                    ipaAccount = isIPA; //TWC727-443 - Utkarsh - Storing 'isIPA' variable value to another class level variable 'ipaAccount' so that it can used into another method.
                                //system.debug('isIPA Flag for Approve scenario---->'+isIPA);
                    //system.debug('ipaAccount Flag for Approve scenario---->'+ipaAccount);*/
                    /*Utkarsh - PRB10047472 changes END*/
                    // Utkarsh - Changes done as part of nonmvp.  
                    
            
                      
                                 
                                                                                    
                    //Added by Rahul for US596149
                    //starts
                    //Update Biz Org Type in every scenario
                    String existingAccountType = existingAccount.Core_Account_Type__c;
                    string existingPartnerRole= existingAccount.Core_IPA_Partner_Role__c;
                    Set<String> existingAccTypeSet = new Set<String>();
                    Set<String> existingroleSet = new Set<String>();
                    if(setBizOrgType.size()>0){
                        existingAccTypeSet.addAll(setBizOrgType);
                    }
                    
                    if(String.isNotBlank(String.valueOf(existingAccountType))){
                        existingAccTypeSet.addAll(existingAccountType.split(';'));                           
                    }                                               
                        
                    String accountType;
                    if(existingAccTypeSet.size()>0){
                        //System.debug('if there are existing values in biz org type of account object');
                        for(String s : existingAccTypeSet){
                            if(accountType != null){
                                accountType = accountType+';'+s;
                            }
                            else {
                                accountType = s;
                            }
                        }
                        //System.debug('accountType'+accountType);
                        existingAccount.Core_Account_Type__c = accountType;
                    }
                    //ends                        
                    if(setPartnerRole.size()>0){
                        existingroleSet.addAll(setPartnerRole);
                    }
                  //setting up partnerrole  
                    if(String.isNotBlank(String.valueOf(existingPartnerRole))){
                        existingroleSet.addAll(existingPartnerRole.split(';'));                           
                    }                                               
                        
                    String partner_role;
                    if(existingroleSet.size()>0){
                        //System.debug('if there are existing values in partner role of account object');
                        for(String r : existingroleSet){
                            if(partner_role != null){
                                partner_role = partner_role+';'+r;
                            }
                            else {
                                partner_role = r;
                            }
                        }
                        //System.debug('partner_role'+partner_role);
                        existingAccount.Core_IPA_Partner_Role__c = partner_role;
                    }
                   // update existingAccount; 
                        
                    //isIPA = existingAccount.Core_Intel_Partner_Alliance_PartnerGroup__c && (existingAccount.Core_Account_Type__c != null && String.isNotBlank(String.valueOf(existingAccount.Core_Account_Type__c)) &&  existingAccount.Core_Account_Type__c.split(';').contains(regReqRecord.PRM_Partner_Type__c)) && (acmListToCheckIPA != null && acmListToCheckIPA.size() >0 );
                      /*Utkarsh - PRB10047472 - Passing 'PRM_Partner_Type__c' while calling 'isAccountIPAForPartnerRole' instead of 'partner role' which we were passing earlier*/
                      //if(IPARefresh){
                        isIPA = PRM_IPA_Utility.isAccountIPAForPartnerRole(existingAccount, acmListToCheckIPA, regReqRecord.PRM_Partner_Role__c); //ACM getting back to partner issue fix-- RRT
                      /*}
                      else{
                        isIPA = PRM_IPA_Utility.isAccountIPAForPartnerRole(existingAccount, acmListToCheckIPA, regReqRecord.PRM_Partner_Type__c);
                      }*/ // IPA Switch Removal
                      //system.debug('isIPA Flag for Approve scenario---->'+isIPA);
                      ipaAccount = isIPA; //TWC727-443 - Utkarsh - Storing 'isIPA' variable value to another class level variable 'ipaAccount' so that it can used into another method.
                      //system.debug('isIPA Flag for Approve scenario---->'+isIPA);
                      //system.debug('ipaAccount Flag for Approve scenario---->'+ipaAccount);
                          
                    //Added by Saba for DE100842: check if ACR of duplicate account is active for same partner role
                    isACRActive = PRM_IPA_Utility.acrActiveCheck(accountIdACRListMap.get(existingAccount.Id),regReqRecord);
                    
                    //Added by Saba for DE100842: check if ACM of account is approved for same partner role 
                    isACMActive = PRM_IPA_Utility.acmActiveCheck(acmListToCheckIPA,regReqRecord);      
                      if(existingAccount != null){
                          PRM_CreateAccountAndRelatedRecords.phoneAndWebsiteMapping(existingAccount, regReqRecord);
                      }
                      /*Utkarsh - PRB10047472 changes END*/
                    // isIPA = existingAccount.Core_Intel_Partner_Alliance_PartnerGroup__c ; 
                        
                    //Added by Rahul for US596330
                    //starts
                    if(String.isNotBlank(String.valueOf(regReqRecord.PRM_Partner_Role__c))){
                        if(regReqRecord.PRM_Partner_Role__c.contains(Label.PRM_FPGA_Desginer)){
                            existingAccount.Core_PSG_Account__c = true;
                        }
                    }
                    //ends                    
                    List<Account> duplicateAccountQueueable = new List<Account>{existingAccount};
                    if(isIPA)
                    {
                        // Schema.SObjectType acc = Schema.Account.getSObjectType();                    
                        // System.enqueueJob(new ContactERPMIntegrationStatusHandler(duplicateAccountQueueable,acc));
                        allAccListForEnqueue.addAll(duplicateAccountQueueable);
                        //System.debug('if IPA'+allAccListForEnqueue);
                        //Existing Account and Existing Contact with IPA true   
                        businessEvent = System.label.PRM_Welcome_Email_New_Event;  
                        //update existingAccount;
                        // PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(existingAccount, existingContact,isIPA,regReqRecord, isACRActive, isACMActive) ;

                        processRegRecordWrapper wrapperRec = new processRegRecordWrapper(existingAccount, existingContact,isIPA,regReqRecord, isACRActive, isACMActive, regRequestFilesMap.get(regReqRecord.id));
                        processRegRecordWrapperList.add(wrapperRec);
                    }
                    else{
                        //Existing Account and Existing Contact with IPA false
                        if(existingAccount.Core_Intel_Partner_Alliance_PartnerGroup__c == false){
                            //System.debug('@@ IPA CHECK');
                            existingAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true ;
                            //System.debug('@@ ACCOUNT NUM'+existingAccount.AccountNumber);
                            if(existingAccount.AccountNumber == null || String.isBlank(existingAccount.AccountNumber)){
                                //System.debug('@@ BLANK ACCOUNT NUMBER');
                                // accNumber = PRM_AccountNumberGenerator.getAccountNum();
                                // if(String.isNotBlank(accNumber)){
                                //     existingAccount.AccountNumber = accNumber;
                                // }
                                //System.debug('@@ accNumber'+accNumber);
                                accNumUpdateSet.add(existingAccount.Id);
                            }
                        }
                        String existingRole = existingAccount.Core_IPA_Partner_Role__c;
                        if(String.isNotBlank(String.valueOf(existingAccount.Core_IPA_Partner_Role__c))){   //TODO: why String.valueOf 
                            Set<String> existingAccRoleSet = new Set<String>();
                            existingAccRoleSet.addAll(existingRole.split(';'));
                            if(String.isNotBlank(regReqRecord.PRM_Partner_Role__c) && !existingAccRoleSet.contains(regReqRecord.PRM_Partner_Role__c)) {
                                existingAccount.Core_IPA_Partner_Role__c = existingRole+';'+regReqRecord.PRM_Partner_Role__c ;
                            } 
                        }else {
                            existingAccount.Core_IPA_Partner_Role__c = regReqRecord.PRM_Partner_Role__c ;
                        }                 
                        
                        //system.debug('Updated values '+existingAccount);
                        // Schema.SObjectType acc = Schema.Account.getSObjectType();
                        // System.enqueueJob(new ContactERPMIntegrationStatusHandler(duplicateAccountQueueable,acc));
                        allAccListForEnqueue.addAll(duplicateAccountQueueable);
                         //System.debug('if not IPA'+allAccListForEnqueue);
                        businessEvent = System.label.PRM_Welcome_Email_New_Event;   
                        //update existingAccount;         
                        // PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(existingAccount, existingContact,isIPA,regReqRecord, isACRActive, isACMActive) ;
                        processRegRecordWrapper wrapperRec = new processRegRecordWrapper(existingAccount, existingContact,isIPA,regReqRecord, isACRActive, isACMActive, regRequestFilesMap.get(regReqRecord.id));
                        processRegRecordWrapperList.add(wrapperRec);
                    }
                    // update duplicateAccountRecord;    
                }//PRM_Salesforce_ID__c
                    //##Scenario : New User and Existing Account - on the basis of PRM_Salesforce_ID__c
                else if(regReqRecord.PRM_Salesforce_ID__c != null) {
                    List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
                    /*  acmList= [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: duplicateAccountId and PRM_Channel_Program_Id__c =: regReqRecord.PRM_Channel_Program__c and PRM_Partner_Role__c =: regReqRecord.PRM_Partner_Role__c];     */
                    acmList = PRM_IPA_Utility.getACMList(accountIdACMListMap.get(regReqRecord.PRM_Salesforce_ID__c), regReqRecord);
                    
                    //approveACM(acmList);// commenting this line as we are already updating status of acm from 'createUpdateACM' method.
                    
                    Account  duplicateAccountRecord;
                    Contact newCont;                                       
                    duplicateAccountRecord  = existingAccountMap.get(regReqRecord.PRM_Salesforce_ID__c);
                    
                    //System.debug('duplicateAccountRecord'+duplicateAccountRecord);
                    //Partner Segment Mapping on Existing Inactive Account
                    if(duplicateAccountRecord != null){
                        PRM_CreateAccountAndRelatedRecords.partnerSegOnExistingAcc(duplicateAccountRecord,regReqRecord);
                    }
                    
                    //Added by Rahul for US596149
                    //starts
                    //Update Biz org type in every scenario
                    String existingAccountType = duplicateAccountRecord.Core_Account_Type__c;
                    Set<String> existingAccTypeSet = new Set<String>();
                    if(existingAccountType != null && String.isNotBlank(String.valueOf(existingAccountType))){
                        existingAccTypeSet.addAll(existingAccountType.split(';'));
                        //System.debug('existingAccTypeSet'+existingAccTypeSet);
                        if(setBizOrgType.size()>0){
                            existingAccTypeSet.addAll(setBizOrgType);
                        }
                    }
                    else{
                        //System.debug('@@ Empty biz org');
                        if(setBizOrgType.size()>0){
                            existingAccTypeSet.addAll(setBizOrgType);
                        }
                    }
                    //System.debug('Final existingAccTypeSet'+existingAccTypeSet);
                    String accountType;
                    if(existingAccTypeSet.size()>0){
                        //System.debug('if there are existing values in biz org type of account object');
                        for(String s : existingAccTypeSet){
                            if(accountType != null){
                                accountType = accountType+';'+s;
                            }
                            else {
                                accountType = s;
                            }
                        }
                        //System.debug('accountType'+accountType);
                        duplicateAccountRecord.Core_Account_Type__c = accountType;
                    }
                    //ends 
                    //System.debug('duplicateAccountRecord.Core_Account_Type__c'+duplicateAccountRecord.Core_Account_Type__c);
                    List<PRM_AccountChannelMembership__c> acmListForDuplicateAcc = new List<PRM_AccountChannelMembership__c>();
                    /*Utkarsh - PRB10047472 - Passing 'PRM_Partner_Type__c' while calling 'isAccountIPAForPartnerRole' instead of 'partner role' which we were passing earlier*/
                    //system.debug('accountIdACMListMap '+accountIdACMListMap); 
                    //system.debug('duplicateAccountRecord '+duplicateAccountRecord); 
                    if(duplicateAccountRecord != null) {
                                    //change in logic to identify an Account as IPA
                        acmListForDuplicateAcc = PRM_IPA_Utility.getACMList(accountIdACMListMap.get(duplicateAccountRecord.id), regReqRecord);
                        
                         //acmListForDuplicateAcc= [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: duplicateAccountRecord.id and PRM_Channel_Program_Id__c =: regReqRecord.PRM_Channel_Program__c and PRM_Partner_Role__c =: regReqRecord.PRM_Partner_Role__c];  
                        //System.debug('acmListForDuplicateAcc-->'+acmListForDuplicateAcc);
                                                                        
                    }
                    if(duplicateAccountRecord != null && duplicateAccountRecord.Core_Intel_Partner_Alliance_PartnerGroup__c == true){
                        //if(IPARefresh){
                            isIPA = PRM_IPA_Utility.isAccountIPAForPartnerRole(duplicateAccountRecord, acmListForDuplicateAcc, regReqRecord.PRM_Partner_Role__c); //ACM getting back to partner issue fix-- RRT
                        /*}
                        else{
                            isIPA = PRM_IPA_Utility.isAccountIPAForPartnerRole(duplicateAccountRecord, acmListForDuplicateAcc, regReqRecord.PRM_Partner_Type__c); 
                        }*/ // IPA Switch Removal
                        ipaAccount = isIPA; //TWC727-443 - Utkarsh - Storing 'isIPA' variable value to another class level variable 'ipaAccount' so that it can used into another method.                  
                    }
                    //System.debug('isIPA-->'+isIPA);
                    //System.debug('ipaAccount-->'+ipaAccount);
                    /*Utkarsh - PRB10047472 changes END*/
                    //Added by Saba for DE99904: check if ACR of duplicate account is active for same partner role
                    isACRActive = PRM_IPA_Utility.acrActiveCheck(accountIdACRListMap.get(duplicateAccountRecord.Id),regReqRecord);
                    isACMActive = PRM_IPA_Utility.acmActiveCheck(acmListForDuplicateAcc,regReqRecord); 
                    if(duplicateAccountRecord != null){
                        PRM_CreateAccountAndRelatedRecords.phoneAndWebsiteMapping(duplicateAccountRecord, regReqRecord);
                    }
                    
                    //Added by Rahul for US596330
                    //starts
                    if(regReqRecord.PRM_Partner_Role__c != null && String.isNotBlank(String.valueOf(regReqRecord.PRM_Partner_Role__c))){
                        if(regReqRecord.PRM_Partner_Role__c.contains(Label.PRM_FPGA_Desginer)){
                            //System.debug('update FPGA flag');
                            duplicateAccountRecord.Core_PSG_Account__c = true;
                        }
                    }
                    //ends
                    
                    //System.debug('isIPA'+isIPA);
                    
                    
                    // Sub-scenarios
                    
                    // 1) Non-IPA Account(isIPA = null)
                    // 2) IPA with different partner role(isIPA = false)
                    //3) IPA with same partner role(isIPA = true)
                    List<Account> duplicateAccountQueueable1 = new List<Account>{duplicateAccountRecord};
                    if(isIPA == null || isIPA == false){
                        
                        if(isIPA == null && (duplicateAccountRecord.Core_Intel_Partner_Alliance_PartnerGroup__c == false)){
                            duplicateAccountRecord.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
                            
                            if(duplicateAccountRecord.AccountNumber == null || String.isBlank(duplicateAccountRecord.AccountNumber)){                                
                                // accNumber = PRM_AccountNumberGenerator.getAccountNum();
                                // if(String.isNotBlank(accNumber)){ duplicateAccountRecord.AccountNumber = accNumber;
                                // }
                                accNumUpdateSet.add(duplicateAccountRecord.Id);   
                            }
                        
                        
                            String existingRole = duplicateAccountRecord.Core_IPA_Partner_Role__c;
                            if(duplicateAccountRecord.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(duplicateAccountRecord.Core_IPA_Partner_Role__c)))
                            {   Set<String> existingAccRoleSet = new Set<String>();
                                existingAccRoleSet.addAll(existingRole.split(';'));
                                if(! existingAccRoleSet.contains(regReqRecord.PRM_Partner_Role__c)) {duplicateAccountRecord.Core_IPA_Partner_Role__c = existingRole+';'+regReqRecord.PRM_Partner_Role__c ;} 
                            }else {
                                duplicateAccountRecord.Core_IPA_Partner_Role__c = regReqRecord.PRM_Partner_Role__c ;
                            }          
                        }                               
                    
                        // update duplicateAccountRecord;
                        // Schema.SObjectType acc = Schema.Account.getSObjectType();
                        // System.enqueueJob(new ContactERPMIntegrationStatusHandler(duplicateAccountQueueable1,acc));
                        allAccListForEnqueue.addAll(duplicateAccountQueueable1);
                        //System.debug('else if'+allAccListForEnqueue);
                        //System.debug('updated duplicateAccountRecord'+duplicateAccountRecord);
                        
                        if(duplicateAccountRecord != null){    
                            businessEvent = System.label.PRM_Welcome_Email_New_Event;          
                            //PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(duplicateAccountRecord,newCont,isIPA,regReqRecord, isACRActive, isACMActive) ;
                            processRegRecordWrapper wrapperRec = new processRegRecordWrapper(duplicateAccountRecord, newCont,isIPA,regReqRecord, isACRActive, isACMActive, regRequestFilesMap.get(regReqRecord.id));
                            processRegRecordWrapperList.add(wrapperRec);
                        }            
                    }
                    else{
                            String existingRole = duplicateAccountRecord.Core_IPA_Partner_Role__c;
                            if(duplicateAccountRecord.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(duplicateAccountRecord.Core_IPA_Partner_Role__c)))
                            {   Set<String> existingAccRoleSet = new Set<String>();
                            existingAccRoleSet.addAll(existingRole.split(';'));
                            if(! existingAccRoleSet.contains(regReqRecord.PRM_Partner_Role__c)) {duplicateAccountRecord.Core_IPA_Partner_Role__c = existingRole+';'+regReqRecord.PRM_Partner_Role__c ;} 
                            }else {
                                duplicateAccountRecord.Core_IPA_Partner_Role__c = regReqRecord.PRM_Partner_Role__c ;
                            }
                            // update duplicateAccountRecord;
                            // Schema.SObjectType acc = Schema.Account.getSObjectType();
                            // System.enqueueJob(new ContactERPMIntegrationStatusHandler(duplicateAccountQueueable1,acc));
                            allAccListForEnqueue.addAll(duplicateAccountQueueable1);
                            //System.debug('ELSE'+allAccListForEnqueue);
                            logEntryMsgString+= '\n'+'Duplicate Accounts Queueable'+duplicateAccountQueueable1;
                            //System.debug('updated duplicateAccountRecord'+duplicateAccountRecord);
                            if(duplicateAccountRecord != null){    
                            businessEvent = System.label.PRM_Welcome_Email_New_Event;          
                            processRegRecordWrapper wrapperRec = new processRegRecordWrapper(duplicateAccountRecord, newCont,isIPA,regReqRecord, isACRActive, isACMActive, regRequestFilesMap.get(regReqRecord.id));
                            processRegRecordWrapperList.add(wrapperRec);
                            } 
                        } 
                }
                    
                else //New Contact 
                {
                    //##########################################
                    //##Scenario : New Contact and Existing Account                  
                    //Below code will execute in both scenarios : New Contact-New Account && New Contact-Existing Account when called from approve button
                    //#############################################
                    //##Scenario : New Contact and New Account                    
                    // Country Mapping
                    Map<string,string> countryMap = new map<string,string>();
                    for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                        countryMap.put(allCountries.Country_Code__c, allCountries.ISO_Code__c);
                    }
                    
                    Contact newContact ;                    
                    
                    Account newAccount = createNewAccountFromRegistrationReq(regReqRecord, countryMap, setBizOrgType);
                    if(newAccount != null) {
                        //insert newAccount;
                        //upsertData(new List<Account> {newAccount});                   
                        accountListToUpsert.add(newAccount);
                    }    
                    //PRM_CreateAccountAndRelatedRecords.processRecords(Account acc, Contact cont,Boolean isIPA,PRM_Registration_Request__c regReq)
                    businessEvent = System.label.PRM_Welcome_Email_New_Event;
                    //PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(newAccount, newContact,null,regReqRecord, isACRActive, isACMActive) ;
                    processRegRecordWrapper wrapperRec = new processRegRecordWrapper(newAccount, newContact,null,regReqRecord, isACRActive, isACMActive, regRequestFilesMap.get(regReqRecord.id));
                    processRegRecordWrapperList.add(wrapperRec);
                }                    
            }
                if(allAccListForEnqueue.size() > 0 && !allAccListForEnqueue.isEmpty()){
                    Integer accListSize = 1;
                    long accNum = long.valueOf(Account__c.getValues('AccountNumber').PRM_Max_Account_Number__c);
                    logEntryMsgString+='\n account number from custom setting: '+accNum;
                    Integer accNumListSize = accNumUpdateSet.size();
                    if(accNumListSize != null){
                        Account__c acs = Account__c.getValues('AccountNumber');
                        acs.PRM_Max_Account_Number__c = String.valueOf(accNum + accNumListSize);
                        logEntryMsgString+='\n account number to be updated on custom setting: '+acs.PRM_Max_Account_Number__c;
                        Database.SaveResult result = Database.update(acs);
                        if(!result.isSuccess()){
                            logEntryMsgString+='\nError -->'+result.getErrors()+'Id -->'+result.getId();
                        }
                    }
                    List<Account> accForAcctNumUpdate = new List<Account>();
                    for(Account acc : allAccListForEnqueue){
                        if(accNumUpdateSet.contains(acc.id)){
                            Account accnt = new Account();
                            accnt.id=acc.id;
                            accnt.accountNumber = String.valueOf(accNum + accListSize);//1000 + 3
                            accnt.Core_User_Defined_Website__c = acc.Core_User_Defined_Website__c;
                            accnt.Core_Intel_Partner_Alliance_PartnerGroup__c = acc.Core_Intel_Partner_Alliance_PartnerGroup__c;
                            accnt.Core_Account_Type__c = acc.Core_Account_Type__c;
                            accnt.Core_IPA_Partner_Role__c = acc.Core_IPA_Partner_Role__c;
                            accListSize++;
                            accForAcctNumUpdate.add(accnt);
                        }
                    }
                    Schema.SObjectType acc = Schema.Account.getSObjectType();
                    logEntryMsgString+='\naccForAcctNumUpdate: '+accForAcctNumUpdate;
                    System.enqueueJob(new PRM_RegReqProcessingQueueable(accForAcctNumUpdate,null,false,'Update_Account',null,true));//TWC729-7729//NJ
                    }
                 //insert newAccount;
                if(!accountListToUpsert.IsEmpty()) { 
                    logEntryMsgString+='\n accounts to Upsert: '+accountListToUpsert;
                    upsertData(accountListToUpsert, 'Account');                    
                } 
                if(!processRegRecordWrapperList.IsEmpty()){
                    logEntryMsgString+='\n processRegRecordWrapperList: '+processRegRecordWrapperList;
                    PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(processRegRecordWrapperList);
                }       
            
        }catch(Exception e){
            //Database.rollback( sp );
            PRM_ErrorUtilityClass.logError(e);
            logEntryMsgString+=PRM_ProcessInboundOPIDLogEntriesUtility.processException(e);//Added error log statement
            //logEntryMsgString+='\n'+'Rolling Back Transaction because of Exception';
           string logentry=createLogEntry(logEntryMsgString);
           logEntries=logEntries!=null?logEntries+';'+logentry: logentry;
           /*if(e.getMessage().containsIgnoreCase('unable to obtain exclusive access to this record')){
                throw new CustomException('Unable to obtain exclusive access to this record. Please process later');
           }*/
            
        }
        finally{ // Added by Agate Team to insert a log entry for both DML and Exceptions
            //System.debug('Entered Finally Block');
            string logentryId=createLogEntry(logEntryMsgString);
            Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Id = LogEntryId, Core_Retry_Counter__c = 1);
            update logEntry;
            logEntries=logEntries!=null?logEntries+';'+logentryId: logentryId;
            if(System.Label.PRM_Tracker_Enabled=='true')
           PRM_RegistrationTrackerUtility.EnQueueTrackerUtility(reordIds,null,logEntries,'PRM_CreateAccountAndRelatedRecords','Self');
        }
    }
    
    //ATHR Fix - TWC729-9556
    /*public static String getPartnerSegment(String segType) {
        String partnerSegment = '';
        if(segType != '') {
            /* fetching role type from metadata */
            //Map<String,String> roleTypeMap = new Map<String,String>();
            
            /* fetch segment type from metadata 
            Map<String,String> segTypeMap = new Map<String,String>();
            for(PRM_PartnerRoleTypeMappings__mdt segTypeReq : [Select Id,PRM_Partner_Role__c,PRM_Partner_Segment__c from PRM_PartnerRoleTypeMappings__mdt where PRM_Partner_Segment__c != null]){
                segTypeMap.put(segTypeReq.PRM_Partner_Role__c,segTypeReq.PRM_Partner_Segment__c);
            }         
            // get account and contact partner segement
            for(String str : segTypeMap.keyset()){
                if(str.equals(segType)){  partnerSegment = segTypeMap.get(str); 
                }
            }
        }
        return partnerSegment;
    }*/
    
    private class processRegRecordWrapper{
        Account acc;
        Contact cont; 
        Boolean isIPA;
        PRM_Registration_Request__c regRequest;
        Boolean isACRActive; 
        Boolean isACMActive;    	
        List<ContentDocumentLink> regRequestFiles;	
        
        private processRegRecordWrapper(Account accRec, Contact contRec, Boolean isIPAFlag ,PRM_Registration_Request__c regRequestRec, Boolean isACRActiveFlag, Boolean isACMActiveFlag, List<ContentDocumentLink> filesAttachedToRequest){
            acc = accRec;
            cont = contRec; 
            isIPA = isIPAFlag;
            regRequest = regRequestRec;
            isACRActive = isACRActiveFlag; 
            isACMActive = isACMActiveFlag;  
            regRequestFiles = filesAttachedToRequest;
        }
    }
    
    //  public static void processRegistrationRecords(Account acc, Contact cont, Boolean isIPA ,PRM_Registration_Request__c regRequest, Boolean isACRActive, Boolean isACMActive)
    public static void processRegistrationRecords(List<processRegRecordWrapper> regRequestRecordWrapperList)
    {
        logEntryMsgString+='\n Entered processRegistrationRecords, regRequestRecordWrapperList: '+regRequestRecordWrapperList;
        //System.debug('List12 -'+regRequestRecordWrapperList);
        List<PRM_Registration_Request__c> regReqList = new List<PRM_Registration_Request__c>();
        try{    
            Set<String> legalAgrmntValues =new Set<String>();               
            Map<String, String> legalAgrmntMap = new Map<String, String>();
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> contIdSet = new Set<Id>();
            Set<String> regRequestPartnerRoleSet = new Set<String>();
            Set<String> regRequestChannelProgramSet = new Set<String>();
            Map<Id, id> regReqChannelPrgmIdMap = new Map<Id, Id>();
            Set<String> subscriptionValues = new Set<String>();
            Map<String, PRM_Partner_Subscription__c> subscriptionMap = new Map<String, PRM_Partner_Subscription__c>();
            //Map<String, PRM_ContactRelationships__c> contactRelationshipsById = New Map<String,PRM_ContactRelationships__c>();
            Set<String> subscriptionIds = new Set<String>();
            List<PRM_AccountLegalAgreemntAssociation__c> accLegalAgreementUpsertList = new List<PRM_AccountLegalAgreemntAssociation__c>();
            List<PRM_ContactSubscriptionAssociation__c> contactSubscriptionUpsertList = new List<PRM_ContactSubscriptionAssociation__c>();
            List<PRM_Account_Contact_Relationship__c> accConRelationshipsToUpsert = new List<PRM_Account_Contact_Relationship__c>();
            List<PRM_AccountChannelMembership__c> accChannelMembershipListToUpsert = new List<PRM_AccountChannelMembership__c>();
            List<Account> accountsToCreateForOptIn = new List<Account>();               
            List<Contact> contactToInsertForOptIn = new List<Contact>();
            List<Account> accountsToCreateForProfRes = new List<Account>();               
            List<Contact> contactToInsertForProfRes = new List<Contact>();
            List<PRM_Registration_Request__c> regReqListForProfRes = new List<PRM_Registration_Request__c>();
            
      for(processRegRecordWrapper wrapperRec: regRequestRecordWrapperList){
                PRM_Registration_Request__c regRequest = wrapperRec.regRequest; 
                regRequestPartnerRoleSet.add(wrapperRec.regRequest.PRM_Partner_Role__c);
                regRequestChannelProgramSet.add(wrapperRec.regRequest.PRM_Channel_Program__c);
                if(String.isNotBlank(regRequest.PRM_Legal_Agreements__c)){
                    //System.debug('@@ Legal Agreement '+regRequest.PRM_Legal_Agreements__c);
                    legalAgrmntValues.addall(regRequest.PRM_Legal_Agreements__c.split(';'));
                    
                }
                if(String.isNotBlank(regRequest.PRM_Channel_Program__c)){
                    regReqChannelPrgmIdMap.put(regRequest.id,regRequest.PRM_Channel_Program__c);
                }
                
                if(wrapperRec.acc.id != null){
                    accIdSet.add(wrapperRec.acc.id);    
                }
                
                if(wrapperRec.cont != null){
                    contIdSet.add(wrapperRec.cont.id);    
                }   
                
                if(String.isNotBlank(regRequest.PRM_Subscriptions__c)){
                    subscriptionValues.addall(regRequest.PRM_Subscriptions__c.split(';'));                   
                }       
                
            }
            
            if(!subscriptionValues.isEmpty() && subscriptionValues != null){
                for(PRM_Partner_Subscription__c sub : [Select Id,PRM_Subscription_Cd__c,Name from PRM_Partner_Subscription__c where PRM_Subscription_Cd__c IN : subscriptionValues and PRM_InActive_Ind__c = false]){
                    subscriptionMap.put(sub.PRM_Subscription_Cd__c,sub);
                    subscriptionIds.add(sub.id);                
                }
            }
            Map<String,PRM_ContactSubscriptionAssociation__c> existingCSAMap = new Map<String,PRM_ContactSubscriptionAssociation__c>();
            //check for duplicate records:
            if(contIdSet != null && !contIdSet.isEmpty()){
                for(PRM_ContactSubscriptionAssociation__c csa : [Select id,PRM_Partner_Subscription_Id__c,PRM_Status_Nm__c,PRM_Contact_Id__c from PRM_ContactSubscriptionAssociation__c where PRM_Partner_Subscription_Id__c in : subscriptionIds and PRM_Contact_Id__c IN :contIdSet])
                {
                    existingCSAMap.put(String.valueOf(csa.PRM_Partner_Subscription_Id__c)+String.valueOf(csa.PRM_Contact_Id__c),csa);
                }
            }
            
            if(!legalAgrmntValues.isEmpty() && legalAgrmntValues != null){
                //System.debug('@@ legalAgrmntValues'+legalAgrmntValues);
                for(PRM_PartnerAgreement__c pa : [Select Id,Name,PRM_Agreement_Cd__c from PRM_PartnerAgreement__c where PRM_Agreement_Cd__c IN : legalAgrmntValues]){
                    legalAgrmntMap.put(pa.PRM_Agreement_Cd__c,pa.id);
                }
            }
            Map<Id, List<PRM_AccountLegalAgreemntAssociation__c>>  alaMap = new Map<Id, List<PRM_AccountLegalAgreemntAssociation__c>>();     
            //check for duplicates:
               for(PRM_AccountLegalAgreemntAssociation__c ala : [Select id,PRM_Account_Id__c,PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c IN :accIdSet and PRM_Partner_Agreement_Id__c in : legalAgrmntMap.values() AND PRM_InActive_Ind__c = false])
                {
                    List<PRM_AccountLegalAgreemntAssociation__c> alaList;
                    if(alaMap.containsKey(ala.PRM_Account_Id__c)){   alaList = alaMap.get(ala.PRM_Account_Id__c);
                    }else{
                        alaList = new List<PRM_AccountLegalAgreemntAssociation__c>();    
                    }  
                    alaList.add(ala);
                    alaMap.put(ala.PRM_Account_Id__c, alaList);
                }
        	
            Map<Id, List<PRM_AccountChannelMembership__c>> accountIdACMListMap = new Map<Id, List<PRM_AccountChannelMembership__c>>();
            if(accIdSet!=null && !accIdSet.isEmpty() && regRequestChannelProgramSet!=null && !regRequestChannelProgramSet.isEmpty() && regRequestPartnerRoleSet!=null && !regRequestPartnerRoleSet.isEmpty()){//NJ SOQL fix
                for(PRM_AccountChannelMembership__c acm: [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN :accIdSet and PRM_Channel_Program_Id__c  IN :regRequestChannelProgramSet and PRM_Partner_Role__c IN :regRequestPartnerRoleSet]){
                    List<PRM_AccountChannelMembership__c> acmList;
                    if(accountIdACMListMap.containsKey(acm.PRM_Account_Id__c)){  acmList = accountIdACMListMap.get(acm.PRM_Account_Id__c);    
                                                                            }else{
                                                                                acmList = new List<PRM_AccountChannelMembership__c>();
                                                                            }  
                    acmList.add(acm);
                    accountIdACMListMap.put(acm.PRM_Account_Id__c, acmList);    
                }
            }
            
            
            Map<Id, List<PRM_Account_Contact_Relationship__c>> accountIdACRListMap = new Map<Id, List<PRM_Account_Contact_Relationship__c>>();
            if(contIdSet != null && !contIdSet.isEmpty()){
                for(PRM_Account_Contact_Relationship__c acr : [Select id,PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_Partner_Role__c,PRM_Start_Date_Dt__c,PRM_SkipValidation__c,PRM_AGS_Identity_Creation_Fail__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c IN: accIdSet and PRM_Contact_Id__c IN :contIdSet]){
                    List<PRM_Account_Contact_Relationship__c> acrList;
                    if(accountIdACRListMap.containsKey(acr.PRM_Account_Id__c)){  acrList = accountIdACRListMap.get(acr.PRM_Account_Id__c);    
                    }else{
                        acrList = new List<PRM_Account_Contact_Relationship__c>();
                    }  
                    acrList.add(acr);
                    accountIdACRListMap.put(acr.PRM_Account_Id__c, acrList);      
                }
            }
            Map<id, List<PRM_ContactRelationships__c>> channelPrgmIdCRMap = new Map<id, List<PRM_ContactRelationships__c>>();
            for(PRM_ContactRelationships__c crel : [Select Id, Name, PRM_Channel_Program_Id__c From PRM_ContactRelationships__c Where PRM_Channel_Program_Id__c IN: regReqChannelPrgmIdMap.values()]){          
                List<PRM_ContactRelationships__c> crelList;
                if(channelPrgmIdCRMap.containsKey(crel.PRM_Channel_Program_Id__c)){
                    crelList = channelPrgmIdCRMap.get(crel.PRM_Channel_Program_Id__c);    
                }else{
                    crelList = new List<PRM_ContactRelationships__c>();
                    
                }  
                crelList.add(crel);
                channelPrgmIdCRMap.put(crel.PRM_Channel_Program_Id__c, crelList); 
            }
            Map<id, Contact> regReqIdContactMap = new Map<id, Contact>();
            Map<PRM_AccountLegalAgreemntAssociation__c, id> accLegalAgreementAssRegReqMap = new Map<PRM_AccountLegalAgreemntAssociation__c, id>();    
            //Map<PRM_Account_Contact_Relationship__c, id> acrRegReqMap = new Map<PRM_Account_Contact_Relationship__c, id>();    
            Map<Id, List<PRM_Account_Contact_Relationship__c>> regReqACRListMap = new Map<Id, List<PRM_Account_Contact_Relationship__c>>();
            List<Contact> contactSet = new List<Contact>();
            List<String> contactIdToLinktoEmail = new List<String>();
            Map<Id,Id> mapRegReqToAccountId = new Map<Id,Id>();
            Map<String, PRM_ContactSubscriptionAssociation__c> contactSubsRegReqMap = new Map<String, PRM_ContactSubscriptionAssociation__c>();
            List<PRM_SendEmailsToPrimaryContacts.emailToContactWrapper> emailToContactWrapperList = new List<PRM_SendEmailsToPrimaryContacts.emailToContactWrapper>();
            List<PRM_RegReqProcessingQueueable> regRequestProcessQueueableList = new List<PRM_RegReqProcessingQueueable>();
            Set<Id> existingAccFromReqIds = new Set<Id>(); 
            List<PRM_AccountLegalAgreemntAssociation__c> eligibleLegalAgreementRollUpToOPID = new List<PRM_AccountLegalAgreemntAssociation__c>();
            List<PRM_ContactSubscriptionAssociation__c> existingContactSubAssocSetToUpdate = new List<PRM_ContactSubscriptionAssociation__c>();
            List<ContentDocumentLink> contentDocLinksToInsert = new List<ContentDocumentLink>();
            for(processRegRecordWrapper wrapperRec: regRequestRecordWrapperList){
                Account acc = wrapperRec.acc;
                Contact cont = wrapperRec.cont;
                Boolean isIPA = wrapperRec.isIPA;
                PRM_Registration_Request__c regRequest = wrapperRec.regRequest;
                Boolean isACRActive = wrapperRec.isACRActive;
                Boolean isACMActive = wrapperRec.isACMActive;            
                logEntryMsgString+='\n***Entered processRegistrationRecords Method***';
                //system.debug('Total queries executed after Account creation--->'+Limits.getQueries());
                //System.debug('## acc'+acc);
                //System.debug('## con'+cont);
                mapRegReqToAccountId.put(wrapperRec.regRequest.id, wrapperRec.acc.id);
                // String partnerSegment = (regRequest.PRM_Partner_Role__c != '' /*&& !ipaRefresh */) ? getPartnerSegment(regRequest.PRM_Partner_Role__c) : '';
                String contactSegment = '' ;
                try{
                    if(acc != null && regRequest != null)
                    {
                        
                        /** partner segment assigned to account */
                         /*if(String.isNotBlank(partnerSegment) && !ipaRefresh) {
                            if(acc.Core_IPA_Partner_Segment__c != null) {
                                List<String> partnersegList = (acc.Core_IPA_Partner_Segment__c).split(';');
                                if(partnersegList.contains(partnerSegment)){
                                    partnerSegment = acc.Core_IPA_Partner_Segment__c; 
                                }
                                else{
                                    partnerSegment = acc.Core_IPA_Partner_Segment__c+';'+ partnerSegment;
                                }
                            }
                            acc.Core_IPA_Partner_Segment__c = partnerSegment;
                        }*/  // IPA Switch Removal
                        // Country Mapping for contact
                        Map<string,string> countryMapContact = new map<string,string>();
                        for(Core_Country_Code_Mapping__c allCountry : Core_Country_Code_Mapping__c.getAll().values()) {
                            countryMapContact.put(allCountry.Country_Code__c, allCountry.ISO_Code__c);
                        }
                       if(cont == null)
                        {
                            cont =  new Contact();
                            cont = createUpdateContactFromRegRequest(cont, acc.id, regRequest, contactSegment);
                            // upsertData(new List<Contact> {cont});
                            contactSet.add(cont);
                            regReqIdContactMap.put(regRequest.id,cont);
                            //system.debug('Contact inserted-->'+cont);
                            //system.debug('Total queries executed after Contact creation--->'+Limits.getQueries());
                            //system.debug('Contact inserted Email>'+cont.Email);
                            //  linkEmailLogToContact(cont.Id); // Agate -Javid - TWC729-1966 -Modified the line. Earlier we were sending the parameter as cont.Email. Now we would be sending cont.Id.
                            contactIdToLinktoEmail.add(cont.Email);
                        }
                        else if(cont != null){
                        /** contact segment assigned to the existing contact */
                            cont = createUpdateContactFromRegRequest(cont, acc.id, regRequest, contactSegment);                                                
                            contactSet.add(cont);
                            regReqIdContactMap.put(regRequest.id,cont);
                            //system.debug('Contact updated-->'+cont);
                            //system.debug('Total queries executed after updating Contact--->'+Limits.getQueries());
                            
                        }
                        
                        //variable decleration : 
                        //Set<id> channelProgramIds = New Set<Id>();                    
                        Boolean assignBenefit = false;
                        
                        //*************************************************************
                        //##create Legal Agreement Association  
                        // if(isIPA == null || isIPA == false)
                        // {                
                        Map<String,PRM_AccountLegalAgreemntAssociation__c> existingALAMap = new Map<String,PRM_AccountLegalAgreemntAssociation__c>();
                        set<String> accLegalAggrementSet = new set<String>();                    
                        
                        //check for duplicates:
                        //for(PRM_AccountLegalAgreemntAssociation__c ala : [Select id,PRM_Account_Id__c,PRM_InActive_Ind__c,PRM_Partner_Agreement_Id__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c =: acc.id and PRM_Partner_Agreement_Id__c in : legalAgrmntMap.values() AND PRM_InActive_Ind__c = false])
                        if(alaMap.containsKey(acc.id)){
                            for(PRM_AccountLegalAgreemntAssociation__c ala : alaMap.get(acc.id))
                            {
                                existingALAMap.put(String.valueOf(ala.PRM_Account_Id__c)+String.valueOf(ala.PRM_Partner_Agreement_Id__c),ala);
                                accLegalAggrementSet.add(String.valueOf(ala.PRM_Account_Id__c)+String.valueOf(ala.PRM_Partner_Agreement_Id__c));
                            }
                        }
                       
                        if(String.isNotBlank(regRequest.PRM_Legal_Agreements__c)){
                            for(String value : regRequest.PRM_Legal_Agreements__c.split(';')){
                                //system.debug('@@Map=='+legalAgrmntMap+'@@Value=='+value);
                                if(legalAgrmntMap.containsKey(value)){
                                    PRM_AccountLegalAgreemntAssociation__c acntLegalAgrAssoc = new PRM_AccountLegalAgreemntAssociation__c();
                                    acntLegalAgrAssoc.PRM_Partner_Agreement_Id__c = legalAgrmntMap.get(value);
                                    acntLegalAgrAssoc.PRM_Account_Id__c = acc.Id ;
                                    // IPA 2.0 - TWC729-7874 -start
                                    acntLegalAgrAssoc.PRM_Signed_By_Email__c = cont.Email;
                                    acntLegalAgrAssoc.PRM_Signed_By_Name__c = cont.FirstName+' '+cont.LastName;
                                    //IPA 2.0 - TWC729-7874 - end
                                    acntLegalAgrAssoc.PRM_Agreement_Sign_Dt__c = System.Now();
                                    if(!accLegalAgreementAssRegReqMap.containsKey(acntLegalAgrAssoc)){
                                        accLegalAgreementAssRegReqMap.put(acntLegalAgrAssoc, regRequest.id);
                                    }
                                    if((!accLegalAggrementSet.contains(String.valueOf(acntLegalAgrAssoc.PRM_Account_Id__c)+String.valueOf(acntLegalAgrAssoc.PRM_Partner_Agreement_Id__c)))) {
                                        // acntLegalAgrAssoc = existingALAMap.get(String.valueOf(acc.id)+String.valueOf(legalAgrmntMap.get(value))); 
                                        accLegalAgreementUpsertList.add(acntLegalAgrAssoc); 
                                        //system.debug('Record ==>'+acntLegalAgrAssoc);
                                    }
                                    if(value == System.Label.PRM_IPATNCCode){
                                        if(!eligibleLegalAgreementRollUpToOPID.contains(acntLegalAgrAssoc)){
                                            eligibleLegalAgreementRollUpToOPID.add(acntLegalAgrAssoc);
                                        }
                                    }
                                    
                                }
                            }
                            if(eligibleLegalAgreementRollUpToOPID != null && eligibleLegalAgreementRollUpToOPID.size() > 0){
                                List<PRM_AccountLegalAgreemntAssociation__c> legalAgreementRollUpToOPID = PRM_ALA_Utility.PopulateLegalAgreeOnOPID(eligibleLegalAgreementRollUpToOPID);
                                accLegalAgreementUpsertList.addAll(legalAgreementRollUpToOPID);  
                                for(PRM_AccountLegalAgreemntAssociation__c LA : legalAgreementRollUpToOPID){
                                    accLegalAgreementAssRegReqMap.put(LA, regRequest.id);
                                }
                            } 
                        }    
                        /*if(accLegalAgreementUpsertList!= null && accLegalAgreementUpsertList.size()>0) { /*upsert accLegalAgreementUpsertList ;*/ // upsertData(accLegalAgreementUpsertList);
                                                                                                        
                                                                                                //    }
                        //}
                        //system.debug('Total queries executed after LA creation--->'+Limits.getQueries());
                        
                        //******************************************
                        //##create Account Channel Membership
                        
                        
                        
                        if(!existingAccFromReqIds.contains(regRequest.PRM_Salesforce_ID__c)){
                            existingAccFromReqIds.add(regRequest.PRM_Salesforce_ID__c);
                            accChannelMembershipListToUpsert.addAll(createUpdateACM(regRequest,accountIdACMListMap,isACMActive,isIPA,acc));
                        }
                        
                        
                        //***********************************************
                        //##create Account Contact Relationship                      
                        List<PRM_Account_Contact_Relationship__c> acrList = new List<PRM_Account_Contact_Relationship__c>();
                        acrList = createUpdateACR(regRequest,accountIdACRListMap.get(acc.id),acc,cont,isIPA,isACRActive,channelPrgmIdCRMap);
                       // accConRelationshipsToUpsert.addAll(acrList);                        
                        if(!regReqACRListMap.containsKey(regRequest.id)){
                            regReqACRListMap.put(regRequest.id, acrList);
                        }
                        
                        /*if(acrList!= null && acrList.size()>0) { 
                            
                                                                                                       }*/
                        //system.debug('Total queries executed after ACR creation--->'+Limits.getQueries());
                        
                        //Send email to primarycontact call
                        if(acrList != null && acrList.size()>0){
                            /*  Map<id,PRM_Account_Contact_Relationship__c> mapOfACR = new Map<id,PRM_Account_Contact_Relationship__c>();
                            for(PRM_Account_Contact_Relationship__c acr : accConRelationshipsToUpsert){
                                mapOfACR.put(acr.id,acr);               
} */                        
                            logEntryMsgString+='Creating ACR Record, accConRelationshipsToUpsert: '+accConRelationshipsToUpsert; 
                            upsertData(accConRelationshipsToUpsert,'Account Channel Relationship');
                            List<String> partnerRoles = new List<String>();
                            partnerRoles.add(regRequest.PRM_Partner_Role__c);
                            //System.debug('>>>>>> partnerRoles '+partnerRoles);
                            //System.debug('>>>>>> sendEmailToAllPrimaryContact started');
                            //  PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContact(null,mapOfACR,partnerRoles,true,false);
                            
                            PRM_SendEmailsToPrimaryContacts.emailToContactWrapper wrapperRecForEmail = new PRM_SendEmailsToPrimaryContacts.emailToContactWrapper(null,acrList,partnerRoles,true,false, null);
                            emailToContactWrapperList.add(wrapperRecForEmail); 
                            
                            
                        }
                        
                        //***********************************************************
                        //##create Contact Subscription Association   
                        
                        if(String.isNotBlank(regRequest.PRM_Subscriptions__c)){
                            for(String value : regRequest.PRM_Subscriptions__c.split(';')){
                                PRM_ContactSubscriptionAssociation__c cntSubscrAssoc = new PRM_ContactSubscriptionAssociation__c();
                                if(subscriptionMap.containsKey(value)){
                                    //System.debug('@@@ SubscriptionMap'+subscriptionMap);
                                    cntSubscrAssoc.PRM_Partner_Subscription_Id__c = subscriptionMap.get(value).Id;
                                    cntSubscrAssoc.PRM_Contact_Id__c = cont.Id;
                                    //system.debug('@@@'+cntSubscrAssoc); 
                                    if(existingCSAMap != null && existingCSAMap.get(String.valueOf(subscriptionMap.get(value).Id)+String.valueOf(cont.Id)) != null) { cntSubscrAssoc = existingCSAMap.get(String.valueOf(subscriptionMap.get(value).Id)+String.valueOf(cont.Id)) ; }
                                    cntSubscrAssoc.PRM_Status_Nm__c = 'Active';
                                    cntSubscrAssoc.PRM_Status_Reason_Txt__c = 'IPA Registration process';//TWC729-8089 : Adding reason text : NJ

                                    if(cntSubscrAssoc.PRM_Contact_Id__c != null){
                                        existingContactSubAssocSetToUpdate.add(cntSubscrAssoc);
                                    }else{                                
                                        String Key = cntSubscrAssoc.PRM_Partner_Subscription_Id__c + '-' + regRequest.id;
                                        if(!contactSubsRegReqMap.containsKey(Key)){
                                            contactSubsRegReqMap.put(Key, cntSubscrAssoc);
                                        }
                                    }
                                } 
                            }
                        }
                        /*if(contactSubsRegReqMap!= null && contactSubsRegReqMap.size()>0) { upsert contactSubscriptionUpsertList ;*/ //upsertData(contactSubscriptionUpsertList); 
                                                                                                       // }
                        //system.debug('Total queries executed after CS creation--->'+Limits.getQueries());
                        
                        //***********************************************************
                        //##create Profile Response  
                        List<Account> accountsToCreate = new List<Account>();
                        accountsToCreate.add(acc);
                        List<Contact> contactToInsert = new List<Contact>();
                        contactToInsert.add(cont);  
                        //system.debug('Total queries executed before ProfileResponse creation-->'+Limits.getQueries());
                        if(isIPA == null|| isIPA == false)
                        {
                            if(regRequest.PRM_Profile_Response__c != null){
                                regReqListForProfRes.add(regRequest);
                                accountsToCreateForProfRes.add(acc);
                                contactToInsertForProfRes.add(cont);
                                // PRM_ProfileResponse.createResponse(regReqList,accountsToCreate,contactToInsert,false);
                            }
                            accountsToCreateForOptIn.add(acc);
                            contactToInsertForOptIn.add(cont);
                            regReqList.add(regRequest);

                            //  PRM_ProfileResponseOptIn.createResponse(accountsToCreate,contactToInsert);
                        }
                        //system.debug('Total queries executed before ProfileResponse creation--->'+Limits.getQueries());
                        
                        //***********************************************************
                        //##Attach files from Registration Request to Account  
                        if(wrapperRec.regRequestFiles != null && !wrapperRec.regRequestFiles.isEmpty()){
							for(ContentDocumentLink contentDoclinkRec: wrapperRec.regRequestFiles){
								ContentDocumentLink cdl = new ContentDocumentLink();
								cdl.ContentDocumentId = contentDoclinkRec.ContentDocumentId;
								cdl.LinkedEntityId = acc.Id;
								cdl.ShareType = 'V';
								//cdl.Visibility = 'AllUsers';
								contentDocLinksToInsert.add(cdl);	
							}
						}
                        
                        //***********************************************************
                        //##create Benefit, Entitlement, Send Email  
                        //ToDo : need separate class for ENtitlement and benefit assignment --> Ruby team is working  
                        if(isIPA == null || isIPA == false)
                        {
                            //ToDO: invoke benefit assignment class   
                            assignBenefit = true; 
                        }
                        Boolean isAdminProcess = false;
                        //ToDo:  invoke entitlement assignment class for all scenarios
                        //system.debug('Total queries before queueable class--->'+Limits.getQueries());
                        //String isActiveEmailFramework = System.Label.PRM_Invoke_Email_Framework;
                        regRequestProcessQueueableList.add(new PRM_RegReqProcessingQueueable(accountsToCreate,contactToInsert,isAdminProcess,businessEvent,regRequest,true));                    
                    }
                }Catch(Exception e){
                    PRM_ErrorUtilityClass.logError(e);
                    logEntryMsgString+=PRM_ProcessInboundOPIDLogEntriesUtility.processException(e);//Added error log statement                       
                    createLogEntry(logEntryMsgString);
                }
            }
            if(!existingContactSubAssocSetToUpdate.isEmpty()){
                 logEntryMsgString+='Updating Subscriptions, existingContactSubAssocSetToUpdate:'+existingContactSubAssocSetToUpdate;
                upsertData(existingContactSubAssocSetToUpdate,'Subscriptions');
            }
            upsertData(contactSet, 'Contact');
            //SOQL Fix NJ
            //Boolean acmUpdated = false;
            //if(System.Limits.getQueries()<20){
             logEntryMsgString+='Creating ACMs, accChannelMembershipListToUpsert:'+accChannelMembershipListToUpsert;
                upsertData(accChannelMembershipListToUpsert, 'Account Channel Membership');
               // acmUpdated= true;
            //}
            if(!regReqACRListMap.isEmpty()){
                for(Id regReqId: regReqACRListMap.keyset()){
                    Id contId = regReqIdContactMap.get(regReqId).id;
                    for(PRM_Account_Contact_Relationship__c acr: regReqACRListMap.get(regReqId)){                        
                        if(String.isNotBlank(contId)){     
                            acr.PRM_Contact_Id__c = contId;
                            accConRelationshipsToUpsert.add(acr);
                         }                        
                    }       
                }
                 logEntryMsgString+='Creating ACRs, accConRelationshipsToUpsert: '+accConRelationshipsToUpsert;
                    upsertData(accConRelationshipsToUpsert,'Account Channel Relationship');
            }
                
            
                
            if(!accLegalAgreementUpsertList.isEmpty()){
                for(PRM_AccountLegalAgreemntAssociation__c acntLegalAgrAssoc: accLegalAgreementUpsertList){
                    if(accLegalAgreementAssRegReqMap.containsKey(acntLegalAgrAssoc)){
                        id regReqId = accLegalAgreementAssRegReqMap.get(acntLegalAgrAssoc);
                        if(regReqIdContactMap.containsKey(regReqId)){
                            // IPA 2.0 - TWC729-7874 - start
                            acntLegalAgrAssoc.PRM_Signed_By_Email__c = regReqIdContactMap.get(regReqId).Email;
                            acntLegalAgrAssoc.PRM_Signed_By_Name__c = regReqIdContactMap.get(regReqId).FirstName+' '+regReqIdContactMap.get(regReqId).LastName;
                            //IPA 2.0 - TWC729-7874 - end
                        }
                    }    
                }
                logEntryMsgString+='Creating Legal Agreements, accLegalAgreementUpsertList: '+accLegalAgreementUpsertList;
                upsertData(accLegalAgreementUpsertList,'Account Legal Agreements');  
            } 
        
            if(!contactSubsRegReqMap.isEmpty()){
            //  for(PRM_ContactSubscriptionAssociation__c cntSubscrAssoc: contactSubscriptionUpsertList){
                for(String key: contactSubsRegReqMap.keyset()){             
                    PRM_ContactSubscriptionAssociation__c cntSubscrAssoc = contactSubsRegReqMap.get(key);
                    String regReqId = key.split('-')[1];                                    
                    if(regReqId != null && regReqIdContactMap.containsKey(regReqId)){   
                        if(String.IsBlank(cntSubscrAssoc.PRM_Contact_Id__c)){
                            cntSubscrAssoc.PRM_Contact_Id__c =  regReqIdContactMap.get(regReqId).id;
                        }
                        contactSubscriptionUpsertList.add(cntSubscrAssoc);
                    }                                      
                }                
                //system.debug('--contactSubscriptionUpsertList '+ contactSubscriptionUpsertList);  
                 logEntryMsgString+='Creating Subscriptions, contactSubscriptionUpsertList: '+contactSubscriptionUpsertList;
                upsertData(contactSubscriptionUpsertList,'Subscriptions');
            }

            List<PRM_Registration_Request__c> listRegReq = new List<PRM_Registration_Request__c>();
            if(!regReqList.isEmpty()){
                for(PRM_Registration_Request__c regReq : regReqList){
                    listRegReq.add(new PRM_Registration_Request__c(Id = regReq.id,
                        Sync_Profile_Response__c = true, 
                        PRM_New_Account__c = regReq.PRM_Salesforce_ID__c == null && mapRegReqToAccountId.containsKey(regReq.id) ? mapRegReqToAccountId.get(regReq.id) : null)
                    );// this is to avoind any unintended update request
                }
            }
            if(!listRegReq.isEmpty() /*|| (acmUpdated=false && accChannelMembershipListToUpsert!=null)*/){
                logEntryMsgString+='\nUpdateSyncProfileResponse enqueued, listRegReq: '+listRegReq;
                System.enqueueJob(new UpdateSyncProfileResponse(listRegReq));
            }
            //enqueue job to assign entitlements and send welcome email    
              logEntryMsgString+='\n regRequestProcessQueueableList to be enqueued: '+regRequestProcessQueueableList;
            for(PRM_RegReqProcessingQueueable queueableJob: regRequestProcessQueueableList){
                System.enqueueJob(queueableJob);
            }
            /*IPA 2.0 - TWC729-8059 : for loop was unnecessary as it was re- assigning the map from wrapper instance back to the wrapper instance
            for(PRM_SendEmailsToPrimaryContacts.emailToContactWrapper wrapRec:emailToContactWrapperList){
                Map<Id,sObject> accConNewMap = wrapRec.accConNewMap;
                if(accConNewMap != null && !accConNewMap.isEmpty()){
                    List<PRM_Account_Contact_Relationship__c> acrList = accConNewMap.values();
                    if(acrList != null && !acrList.isEmpty()){
                        wrapRec.accConNewMap = new Map<Id,sObject>(acrList);
                        /*id regReqId = acrRegReqMap.get(acrList[0]);
if(regReqId != null && mapOfContactACRList.containsKey(regReqIdContactMap.get(regReqId).id)){
wrapRec.accConNewMap = new Map<Id,sObject>(mapOfContactACRList.get(regReqIdContactMap.get(regReqId).id));                    
} *//*
                    }
                }
            }
            */
            PRM_SendEmailsToPrimaryContacts.sendEmailToAllPrimaryContact(emailToContactWrapperList);
            linkBulkEmailLogToContact(contactIdToLinktoEmail); 
            if(!contentDocLinksToInsert.isEmpty()){
				upsertData(contentDocLinksToInsert,'ContentDocumentLink');
			}
        }catch(exception e){
           // Database.rollback( sp );
            PRM_ErrorUtilityClass.logError(e);
            logEntryMsgString+=PRM_ProcessInboundOPIDLogEntriesUtility.processException(e);//Added error log statement
            //logEntryMsgString+='\n'+'Rolling Back Transaction because of Exception';
        }finally{
            createLogEntry(logEntryMsgString);
        }
    }    
    
    public without sharing class UpdateSyncProfileResponse implements Queueable { 
        List<PRM_Registration_Request__c> listRegReq = new List<PRM_Registration_Request__c>();

        public UpdateSyncProfileResponse(List<PRM_Registration_Request__c> regReqListForProfRes) {        
            this.listRegReq = regReqListForProfRes;
        }
        
        public void execute(QueueableContext context) { 
           // upsertData(acmToUpdate,sObjectType);
            TriggerHandler.bypass('PRM_RegRequest_TriggerHandler');
            upsertData(listRegReq,'New Registration');
            TriggerHandler.clearbypass('PRM_RegRequest_TriggerHandler');
        }
            

    }

    //Harshit added on 11/4/2019: to invoke EmailFramework for sending welcome email to newly added contacts
    public static void sendWelcomeEmailNotification(List<Contact> contactListToInsert, String businessEvent, PRM_Registration_Request__c regRequest)
    {
        //system.debug('Total queries executed before Email Class--->'+Limits.getQueries());  
        List<PRM_Language_Culture_Mapping__mdt> lngmapping = [Select Id,MasterLabel,PRM_Culture__c,PRM_Country__c,PRM_Country_Cd__c From PRM_Language_Culture_Mapping__mdt];
        PRM_Language_Culture_Mapping__mdt langCulEmail;
        for(PRM_Language_Culture_Mapping__mdt mdtRec: lngmapping){
            if(langCulEmail == null && (mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase('us'))){
                langCulEmail = mdtRec;
            }
            if(mdtRec.PRM_Country_Cd__c != null && mdtRec.PRM_Country_Cd__c.equalsIgnoreCase(regRequest.PRM_Contact_Country__c) && mdtRec.MasterLabel == regRequest.PRM_Preferred_Language__c){
                langCulEmail = mdtRec;
            }
        }
        for(Contact c : contactListToInsert) 
        {
            PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
            // PRM_Email_Content_DataSetup__c emailSetup = PRM_Email_Content_DataSetup__c.getValues(regRequest.PRM_Partner_Role__c);            
            map<String, String> inputParameters = new map<String, String>();
            inputParameters.put('Account_ID',c.AccountId);            
            inputParameters.put('Registration_Request_ID',regRequest.Id);
            /* if(emailSetup != null){
inputParameters.put('EmailContent_Setup',emailSetup.Id);    
} */            
            
            if(langCulEmail != null){
                inputParameters.put('LanguageCulture_MDT',langCulEmail.Id);    
            }
            objEmailNotif.InputParameters=inputParameters;
            objEmailNotif.partnerRole = c.Core_IPA_PartnerRole__c; //Utkarsh - TWC727-864 - passing partner role for welcome email changes
            objEmailNotif.BusinessEvent=businessEvent;
            objEmailNotif.Language = c.Core_Preferred_Language__c;
            objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
            //objEmailNotif.PartnerType=System.Label.PRM_CsP;
            objEmailNotif.EmailID= c.Email ;
            if(c != null && c.Core_Do_Not_Contact__c  == false)
            {
                //PRM_EmailUtility.sendEmail(objEmailNotif);    
                ////added as part of governor limit story:4380
                PRM_EmailUtility.sendEmail(new List<PRM_EmailUtility.EmailNotification> {objEmailNotif});              
                
                linkEmailLogToContact(c.Email);
            }
        } 
        //system.debug('Total queries executed after sending Emails and updating logs--->'+Limits.getQueries());  
    }
    
    //Harshit added on 24/5/2019 to link Email Logs with contact
    public static void linkEmailLogToContact(String recipientEmailId){ 
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>(); 
        if(recipientEmailId != null){
            emailLogList = [select PRM_ToEmailID__c,PRM_User__c,PRM_Contact__c,ID from PRM_EmailLog__c where PRM_ToEmailID__c =:recipientEmailId];
        }
        if(emailLogList != null && emailLogList.size()>0)
        {            
            List<Contact> conList = [Select id,Email from contact where Email =: recipientEmailId];
            //List<User> uList = [Select id,email from User where Email =: recipientEmailId]; 
            if(conList != null && conList.size()>0)
            {
                List<User> userList = new List<User>();
                userList = [Select id/*,Email,contactId*/ from User where contactId=:conList[0].id];  //ATHR Fix - TWC729-9556
                for(PRM_EmailLog__c log : emailLogList)
                {
                    log.PRM_Contact__c = conList[0].id; 
                    if(userList!= null && userList.size()>0) { log.PRM_User__c = userList[0].id ; }  
                }
                try{
                    //Database.update(emailLogList);
                    upsertData(emailLogList,'Email Log');
                }
                catch(Exception e){
                    PRM_ErrorUtilityClass.logError(e);
                    logEntryMsgString+=PRM_ProcessInboundOPIDLogEntriesUtility.processException(e);//Added error log statement                       
                    createLogEntry(logEntryMsgString);
                }    
            }
        }
    }
    
    public static void linkBulkEmailLogToContact(List<String> recipientEmailIds){ 
        List<PRM_EmailLog__c> emailLogList = new List<PRM_EmailLog__c>(); 
        Map<String,Contact> contactMap = new Map<String,Contact>();
        Map<String,User> userMap = new Map<String,User>();
        Set<Id> conIdSet = new Set<Id>();
        if(!recipientEmailIds.isEmpty()){
            emailLogList = [select PRM_ToEmailID__c,PRM_User__c,PRM_Contact__c,ID from PRM_EmailLog__c where PRM_ToEmailID__c IN:recipientEmailIds];
        }
        if(emailLogList != null && emailLogList.size()>0)
        {            
            for(Contact con :[Select id,Email from contact where Email IN: recipientEmailIds]){
                contactMap.put(con.Email,con);
                conIdSet.add(con.Id);
            }
            for(User usr :[Select id,Email,contactId from User where contactId IN:conIdSet]){
                userMap.put(usr.Email,usr);
            }
            if(contactMap != null && !contactMap.isEmpty())
            {
                //List<User> userList = new List<User>();
                for(PRM_EmailLog__c log : emailLogList)
                {
                    log.PRM_Contact__c = contactMap.get(log.PRM_ToEmailID__c).Id;
                    if(userMap!= null && !userMap.isEmpty()) { 
                        log.PRM_User__c =userMap.get(log.PRM_ToEmailID__c).Id;
                    }  
                }
                try{                   
                    upsertData(emailLogList,'Email Log');
                }
                catch(Exception e){
                    Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);                                   
                }    
            }
        }
    }
    
    public static void approveACM(List<PRM_AccountChannelMembership__c> acmList){
        logEntryMsgString+='\n Entered approveACM, acmList: '+acmList;
        if(acmList.size() > 0){
            List<PRM_AccountChannelMembership__c> acmListUpdate = new List<PRM_AccountChannelMembership__c>();
            for(PRM_AccountChannelMembership__c acm : acmList){
                if(acm.PRM_Status_Nm__c != 'Approved'){
                    acm.PRM_Status_Nm__c = 'Approved';
                    acm.PRM_Status_Reason_Txt__c = System.Label.PRM_APPROVE_MSG;
                    acmListUpdate.add(acm);
                }
            }
            if(acmListUpdate.size() > 0){
                //update acmListUpdate;
                upsertData(acmListUpdate,'Account Channel Membership');
            }
        }
    }
    
    public static void upsertData(List<SObject> newLst, String sObjectType) { 
        //system.debug('---newLst '+newLst);          
        if(newLst!=null && !newLst.isEmpty()) {
           logEntryMsgString+= '\n*******Salesforce Governer Limits******** \n'+getSalesforceLimits();
            logEntryMsgString+= '\n*******Salesforce Governer Limits End******** \n';
            Database.UpsertResult[] urList = Database.upsert(newLst, false);            
            logEntryMsgString+= PRM_ProcessInboundOPIDLogEntriesUtility.processDatabaseUpsertResult(newLst,urList,sObjectType);
            logEntryMsgString+= '\n*******Salesforce Governer Limits******** \n'+getSalesforceLimits();
            logEntryMsgString+= '\n*******Salesforce Governer Limits End******** \n';
        }
    }
    
    public static string createLogEntry(String logEntryMsgString){
    string corelogId;
    string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
        if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
               //corelogId= Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,logEntryMsgString.split('@@@')[0] ,logEntryUtility.logEntryList[i] , '', '', transactionEmail);
               corelogId= Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', transactionEmail);
            }//loop ends here..
        }
        return corelogId;
    }
    //Method to get the Salesforce Governer Limits
    public static String getSalesforceLimits(){
        String totalSalesforceLimits;
        totalSalesforceLimits += 'CPU Time Consumed:'+' '+Limits.getCpuTime(); 
        totalSalesforceLimits += '\nNumber Of DML Rows Consumed:'+' '+Limits.getDMLRows();
        totalSalesforceLimits += '\nNumber Of SOQL Queries Consumed:'+' '+Limits.getQueries();
        totalSalesforceLimits += '\nHeap Size Consumed:'+' '+Limits.getHeapSize();
        totalSalesforceLimits += '\nNumber Of Future Calls:'+' '+Limits.getFutureCalls();
        totalSalesforceLimits += '\nNumber Of Callouts:'+' '+Limits.getCallouts();
        totalSalesforceLimits += '\nNumber Of Queueable Jobs Consumed:'+' '+Limits.getQueueableJobs();
        totalSalesforceLimits += '\nNumber Of SOSL Queries Consumed:'+' '+Limits.getSoslQueries();     
        return totalSalesforceLimits;
    } 
    
   public static void phoneAndWebsiteMapping(Account acc,PRM_Registration_Request__c regReq)
    {
        //for(PRM_Registration_Request__c reg : regReqlist){
        if(acc.Core_User_Defined_Phone_Number__c == null){
            if(regReq.PRM_Account_Phone__c != null){
                acc.Core_User_Defined_Phone_Number__c = regReq.PRM_Account_Phone__c ;
            }
            else if(regReq.PRM_Person_Phone_Number__c != null){  
                acc.Core_User_Defined_Phone_Number__c = regReq.PRM_Person_Phone_Number__c ;
            }
        }
        
        if(acc.Core_User_Defined_Website__c == null && regReq.PRM_Account_URL__c != null){   
            acc.Core_User_Defined_Website__c = regReq.PRM_Account_URL__c;
            //system.debug('acc.Core_User_Defined_Website__c--'+acc.Core_User_Defined_Website__c);
        }
        /*TWC727-443 - Utkarsh - Start - Need to populate secondary address if it is blank when non IPA account converted into IPA */
        //system.debug('ipaAccount--'+ipaAccount);
        if(ipaAccount != true){
            if(acc.ShippingCountryCode == null || acc.ShippingCountryCode == ''){   
                acc.ShippingCountryCode = acc.BillingCountryCode;
            }
            if(acc.ShippingStateCode == null || acc.ShippingStateCode == ''){   
                acc.ShippingStateCode = acc.BillingStateCode;
            }
            if(acc.ShippingStreet == null || acc.ShippingStreet == ''){   
                acc.ShippingStreet = acc.BillingStreet;
            }
            if(acc.ShippingCity == null || acc.ShippingCity == ''){   
                acc.ShippingCity = acc.BillingCity;
            }
            if(acc.ShippingPostalCode == null || acc.ShippingPostalCode == ''){   
                acc.ShippingPostalCode = acc.BillingPostalCode;
            }
        }
        //TWC729-4465 -  for Website Stamping on Payload
        //Rohit - Adding as part of website Stapping on VXR on Account Resue Scenario
        mapToUpdateWebsite.put(acc.Id, acc.Core_User_Defined_Website__c);
        /*TWC727-443 - Utkarsh - End */
    }
    @TestVisible
  private static Account createNewAccountFromRegistrationReq(PRM_Registration_Request__c regReqRecord, Map<string,string> countryMap, Set<String> setBizOrgType){
        logEntryMsgString+='\n Entered createNewAccountFromRegistrationReq method, regReqRecord: '+regReqRecord;
        Account newAccount;
        if(regReqRecord != null && countryMap != null && setBizOrgType != null){
            String accNumber = '';
            Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            newAccount = new Account();            
            newAccount.Name = regReqRecord.PRM_Account_Name__c;
            newAccount.RecordTypeId = accountRecordType;
            
            // Nishant Dhar - 21/06/2019 -Code added to extract the three letter country code for the two digit country code
            if (regReqRecord.PRM_Country__c.length() == 2){
                newAccount.BillingCountryCode = countryMap.get(regReqRecord.PRM_Country__c);
                newAccount.ShippingCountryCode = countryMap.get(regReqRecord.PRM_Phy_Country__c);   
            }else{newAccount.BillingCountryCode = regReqRecord.PRM_Country__c;
                  newAccount.ShippingCountryCode = regReqRecord.PRM_Phy_Country__c;
                 }
            //eachSetOfRecordsToCreate.newAccount.BillingCountryCode = regRequest.PRM_Country__c;
            newAccount.BillingStateCode = regReqRecord.PRM_State_Province__c;
            newAccount.ShippingStateCode = regReqRecord.PRM_Phy_State_Province__c;
            newAccount.BillingStreet = regReqRecord.PRM_Address_Line_1__c;
            newAccount.ShippingStreet = regReqRecord.PRM_Phy_Address_Line_1__c;
            //System.debug('regReqRecord.PRM_Address_Line_2__c'+regReqRecord.PRM_Address_Line_2__c);
            if(String.isNotBlank(regReqRecord.PRM_Address_Line_2__c)){
                newAccount.BillingStreet += ' ' + regReqRecord.PRM_Address_Line_2__c;
            }
            if(String.isNotBlank(regReqRecord.PRM_Phy_Address_Line_2__c)){
                newAccount.ShippingStreet += ' ' + regReqRecord.PRM_Phy_Address_Line_2__c;
            }
            //newAccount.BillingStreet=newAccount.BillingStreet.replaceAll('<[^>]+>',' ');
            //newAccount.ShippingStreet=newAccount.ShippingStreet.replaceAll('<[^>]+>',' ');
            newAccount.BillingCity = regReqRecord.PRM_City__c;
            newAccount.ShippingCity = regReqRecord.PRM_Phy_City__c;
            newAccount.BillingPostalCode = regReqRecord.PRM_Zip_Postal_Code__c;
            newAccount.ShippingPostalCode = regReqRecord.PRM_Phy_Zip_Postal_Code__c;
            //newAccount.Core_Account_Type__c = regReqRecord.PRM_Partner_Type__c;
            
            //Keerthan added as part of US673650
            if((String.isBlank(regReqRecord.PRM_Phy_Address_Line_1__c) || regReqRecord.PRM_Phy_Address_Line_1__c == null) && 
               (String.isBlank(regReqRecord.PRM_Phy_Address_Line_2__c) || regReqRecord.PRM_Phy_Address_Line_2__c == null) &&
               (String.isBlank(regReqRecord.PRM_Phy_City__c) || regReqRecord.PRM_Phy_City__c == null) && 
               (String.isBlank(regReqRecord.PRM_Phy_State_Province__c) || regReqRecord.PRM_Phy_State_Province__c == null) &&
               (String.isBlank(regReqRecord.PRM_Phy_Zip_Postal_Code__c) || regReqRecord.PRM_Phy_Zip_Postal_Code__c == null) &&
               (String.isBlank(regReqRecord.PRM_Phy_Country__c))){
                   newAccount.ShippingStateCode = regReqRecord.PRM_State_Province__c;
                   newAccount.ShippingStreet = regReqRecord.PRM_Address_Line_1__c;
                   newAccount.ShippingCity = regReqRecord.PRM_City__c;
                   newAccount.ShippingPostalCode = regReqRecord.PRM_Zip_Postal_Code__c;
                   if(String.isNotBlank(regReqRecord.PRM_Address_Line_2__c)){
                       newAccount.ShippingStreet += ' ' + regReqRecord.PRM_Address_Line_2__c;
                   }
                   if (regReqRecord.PRM_Country__c.length() == 2){
                       
                       newAccount.ShippingCountryCode = countryMap.get(regReqRecord.PRM_Country__c);   
                   }
                   else{
                       newAccount.ShippingCountryCode = regReqRecord.PRM_Country__c;
                   }
               }
            
            //Added by Rahul for US596149
            //starts
            if(setBizOrgType.size()>0){
                for(String s : setBizOrgType){
                    if(newAccount.Core_Account_Type__c != null && newAccount.Core_Account_Type__c != ''){
                        newAccount.Core_Account_Type__c =newAccount.Core_Account_Type__c+';'+s;
                    }
                    else {
                        newAccount.Core_Account_Type__c = s;
                    }
                }
            } 
            //ends
            //System.debug('newAccount.Core_Account_Type__c'+newAccount.Core_Account_Type__c);
            
            newAccount.Core_IPA_Partner_Role__c = regReqRecord.PRM_Partner_Role__c;
            //System.debug('@@ regReqRecord.PRM_Partner_Role__c'+regReqRecord.PRM_Partner_Role__c);
            //Added by Rahul for US596330
            //starts
           if(regReqRecord.PRM_Partner_Role__c != null && String.isNotBlank(String.valueOf(regReqRecord.PRM_Partner_Role__c))){
                if(regReqRecord.PRM_Partner_Role__c.contains(Label.PRM_FPGA_Desginer)){
                    //System.debug('update FPGA flag');
                    newAccount.Core_PSG_Account__c = true;
                }
            }
            //ends
            newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true ; 
            //added new attributed below : US431759
            newAccount.Core_User_Defined_Website__c  = regReqRecord.PRM_Account_URL__c ;
            //Utkarsh - Changes done as part of nonmvp.
            if(newAccount.Core_User_Defined_Phone_Number__c == null){
                if(regReqRecord.PRM_Account_Phone__c != null){
                    newAccount.Core_User_Defined_Phone_Number__c = regReqRecord.PRM_Account_Phone__c ;
                }
                else if(regReqRecord.PRM_Person_Phone_Number__c != null){
                    newAccount.Core_User_Defined_Phone_Number__c = regReqRecord.PRM_Person_Phone_Number__c ;
                }
            }
            newAccount.Core_User_Defined_Number_of_Employees__c = regReqRecord.PRM_Company_Size__c ;
            //Added for US452620
            newAccount.Core_Sales_Groups__c = System.Label.PRM_Undefined;
            newAccount.Industry = System.Label.PRM_Needs_Defined;
            
            //Rahul added for US647468
            //System.debug('@@ ACCOUNT NUM'+newAccount.AccountNumber);
            if(newAccount.AccountNumber == null || String.isBlank(newAccount.AccountNumber)){
                //System.debug('@@ BLANK ACCOUNT NUMBER');
                accNumber = PRM_AccountNumberGenerator.getAccountNum();
                if(String.isNotBlank(accNumber)){ newAccount.AccountNumber = accNumber;
                                                 
                                                }
                //System.debug('@@ accNumber'+accNumber);
            }
            
            User u = [Select id from User where alias =: System.Label.PRM_UncoveredAccount] ;
            if(u != null) {newAccount.OwnerId  = u.id ; }
            //System.debug('eachSetOfRecordsToCreate--->'+newAccount);
            
            /** partner segment assigned to account */
           /*String accountPartnerSegment = (regReqRecord.PRM_Partner_Role__c != '' && !ipaRefresh) ? getPartnerSegment(regReqRecord.PRM_Partner_Role__c) : '';
            if(String.isNotBlank(accountPartnerSegment) && !ipaRefresh) {                
                newAccount.Core_IPA_Partner_Segment__c = accountPartnerSegment;
            } */ // IPA Switch Removal
        }
        logEntryMsgString+='\n Value returned by createNewAccountFromRegistrationReq: '+newAccount; 
        return newAccount;
    } 
    
    //This method is used to create or update Contact record
    private static Contact createUpdateContactFromRegRequest(Contact newCont, id accId,PRM_Registration_Request__c regRequest, String partnerSegment){
        logEntryMsgString+='\n Entered createUpdateContactFromRegRequest method, regRequest: '+regRequest;
        Contact cont = newCont;
        if(cont != null && regRequest != null){
            if(String.isNotBlank(partnerSegment)) {
                /*if(cont.Core_IPA_Contact_Segment__c != null) {
                    List<String> partnersegList = (cont.Core_IPA_Contact_Segment__c).split(';');
                    if(partnersegList.contains(partnerSegment)) {
                        partnerSegment = cont.Core_IPA_Contact_Segment__c; 
                    }
                    else{
                        partnerSegment = cont.Core_IPA_Contact_Segment__c+';'+ partnerSegment;
                    }
                }*/
                //if(!boolean.valueOf(label.PRM_IPARefresh))cont.Core_IPA_Contact_Segment__c = partnerSegment;
            }               
                               
            cont.Core_IPA_PartnerRole__c = regRequest.PRM_Partner_Role__c;
            cont.FirstName = regRequest.PRM_First_Name__c;
            cont.LastName = regRequest.PRM_Last_Name__c;
            cont.Core_Preferred_Language__c = regRequest.PRM_Preferred_Language__c; 
            cont.Phone = regRequest.PRM_Person_Phone_Number__c;
            //cont.Core_Job_Function_Code__c = regRequest.PRM_Job_Function__c;
             cont.Core_Profession__c = regRequest.PRM_Profession__c;
            //Added by Manju
            cont.PRM_Wechat_Union_Id__c = regRequest.PRM_Wechat_Union_Id__c;
            
            //Added by Naresh as part of DE89965                
            if(cont.Core_Login_Status__c == 'Deleted' && String.isEmpty(cont.Core_Enterprise_Id__c) && !String.isEmpty(regRequest.PRM_Enterprise_ID__c)){
                //populate Enterprise id on Contact for the Existing contact - Use It or Lose It Scenario - Contact's return journey
                cont.Core_Login_Status__c = 'Active';          
                cont.Core_Enterprise_Id__c=regRequest.PRM_Enterprise_ID__c;                          
            }
            
            // Country Mapping for contact
            Map<string,string> countryMapContact = new map<string,string>();
            for(Core_Country_Code_Mapping__c allCountry : Core_Country_Code_Mapping__c.getAll().values()) {
                countryMapContact.put(allCountry.Country_Code__c, allCountry.ISO_Code__c);
            }  
            
            // to convert 2 digits of country into 3 digits
            if(regRequest.PRM_Contact_Country__c != null && regRequest.PRM_Contact_Country__c != '')
            {
                if (regRequest.PRM_Contact_Country__c.length() == 2){
                    cont.MailingCountry = countryMapContact.get(regRequest.PRM_Contact_Country__c);
                    cont.MailingCountryCode = countryMapContact.get(regRequest.PRM_Contact_Country__c);   
                }else{cont.MailingCountry = regRequest.PRM_Contact_Country__c;
                      cont.MailingCountryCode = regRequest.PRM_Contact_Country__c;   
                 }
            }
        
            //##create Contact :
            if(cont.id == null){                                                             
                List<String> prefLanguageList= new List<String>();
                Schema.DescribeFieldResult fieldResult = Contact.Core_Preferred_Language__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    prefLanguageList.add(pickListVal.getValue());
                }     
                                        
                cont.Email = regRequest.PRM_Email_ID__c;
                            
                            
                if(regRequest.PRM_Preferred_Language__c != null && regRequest.PRM_Preferred_Language__c != '' &&
                   prefLanguageList != null && prefLanguageList.contains(regRequest.PRM_Preferred_Language__c)){
                       cont.Core_Preferred_Language__c =regRequest.PRM_Preferred_Language__c;
                       cont.Core_eRPM_Language_Code__c=regRequest.PRM_Preferred_Language__c;
                   }
                else{
                    cont.Core_Preferred_Language__c =System.Label.PRM_ENG;
                    cont.Core_eRPM_Language_Code__c=System.Label.PRM_ENG;
                }            
                cont.RecordTypeId = PRM_IPA_Constants.CONTACT_RECORD_TYPE_ID;
                cont.Core_Enterprise_Id__c=regRequest.PRM_Enterprise_ID__c;            
                cont.AccountId = accId; 
                            
                
                if(UserInfo.getUserType()!='Standard') {                
                    cont.OwnerId = Id.valueOf(Label.PRM_IPARegistration_Integration_UserId);
                    cont.Core_IPS_Intel_Support_Owner__c = Id.valueOf(Label.PRM_IPARegistration_Integration_UserId);
                }       
                //insert cont;
            }
                                                
        }
        logEntryMsgString+='\n Value returned by createUpdateContactFromRegRequest: '+cont; 
        return cont;
    }
    
    //This method is used to create ACM object from Registration Request
    public static List<PRM_AccountChannelMembership__c> createUpdateACM(PRM_Registration_Request__c regRequest,Map<Id, List<PRM_AccountChannelMembership__c>> accountIdACMListMap,Boolean isACMActive,Boolean isIPA,Account acc)
    {  
        logEntryMsgString+='\n Entered createUpdateACM method, regRequest: '+regRequest; 
        List<PRM_AccountChannelMembership__c> accChannelMembershipListToUpsert = new List<PRM_AccountChannelMembership__c>();
        if(regRequest != null && accountIdACMListMap != null){            
            //System.debug('isIPA-->'+isIPA);
            //System.debug('isACMActive-->'+isACMActive);
            if(isIPA == null || isIPA == false || isACMActive == false)
            {
                //for new Account -- Approve scenario
                
                Map<String,PRM_AccountChannelMembership__c> existingACMMap = new Map<String,PRM_AccountChannelMembership__c>();                
                //check for duplicates :
                if(accountIdACMListMap.containsKey(acc.id)){
                    for(PRM_AccountChannelMembership__c acm: accountIdACMListMap.get(acc.id))
                    {
                        if(acm.PRM_Partner_Role__c == regRequest.PRM_Partner_Role__c && acm.PRM_Channel_Program_Id__c == regRequest.PRM_Channel_Program__c){
                            existingACMMap.put(String.valueOf(acm.PRM_Account_Id__c)+String.valueOf(acm.PRM_Channel_Program_Id__c)+String.valueOf(acm.PRM_Partner_Role__c),acm);
            }
                    }
                }
                PRM_AccountChannelMembership__c accChannelMembership = new PRM_AccountChannelMembership__c();
                accChannelMembership.PRM_Channel_Program_Id__c = regRequest.PRM_Channel_Program__c;
                accChannelMembership.PRM_Partner_Role__c = regRequest.PRM_Partner_Role__c;
                accChannelMembership.PRM_Account_Id__c = acc.id ;
                if(existingACMMap != null && existingACMMap.get(String.valueOf(acc.id)+String.valueOf(regRequest.PRM_Channel_Program__c)+String.valueOf(regRequest.PRM_Partner_Role__c)) != null)
                {
                    accChannelMembership = existingACMMap.get(String.valueOf(acc.id)+String.valueOf(regRequest.PRM_Channel_Program__c)+String.valueOf(regRequest.PRM_Partner_Role__c));
          
                }
        accChannelMembership.PRM_Channel_Program_Level_Id__c = regRequest.PRM_Channel_Program_Level__c;
                accChannelMembership.PRM_Status_Nm__c = System.Label.PRM_Status;
                //if(regRequest.PRM_Auto_Approve__c){
                    accChannelMembership.PRM_Status_Reason_Txt__c = System.Label.PRM_APPROVE_MSG;
                //}
        //system.debug('accChannelMembership-->'+accChannelMembership);
                accChannelMembershipListToUpsert.add(accChannelMembership) ;                                
            }            
        }
        logEntryMsgString+='\n Value returned by createUpdateACM method createUpdateACR: '+accChannelMembershipListToUpsert;
        return accChannelMembershipListToUpsert;
    }
    
    //This method is used to create ACR object from Registration Request
    public static List<PRM_Account_Contact_Relationship__c> createUpdateACR(PRM_Registration_Request__c regRequest, List<PRM_Account_Contact_Relationship__c> acrList,Account acc,Contact cont,Boolean isIPA,Boolean isACRActive,Map<id, List<PRM_ContactRelationships__c>> channelPrgmIdCRMap)
    {
        logEntryMsgString+='\n Entered createUpdateACR method regRequest: '+regRequest;
        List<PRM_Account_Contact_Relationship__c> accConRelationshipsToUpsert = new List<PRM_Account_Contact_Relationship__c>();
        if(regRequest != null){
            
            Map<String, PRM_ContactRelationships__c> contactRelationshipsById = New Map<String,PRM_ContactRelationships__c>();
            Map<String,PRM_Account_Contact_Relationship__c> existingACRMap = new Map<String,PRM_Account_Contact_Relationship__c>();
                        
            //check for duplicates
            if(acrList != null){
                for(PRM_Account_Contact_Relationship__c acr :acrList)
                {
                    if(acr.PRM_Contact_Id__c == cont.id){
                        acr.PRM_SkipValidation__c=true;
                        existingACRMap.put(String.valueOf(acr.PRM_Account_Id__c)+String.valueOf(acr.PRM_Contact_Id__c)+String.valueOf(acr.PRM_Relationship_Id__c),acr);
                    }
                }   
            }
            if(!String.IsBlank(regRequest.PRM_Channel_Program__c)){
                for(PRM_ContactRelationships__c crel : channelPrgmIdCRMap.get(regRequest.PRM_Channel_Program__c)){
                    contactRelationshipsById.put(crel.Name, crel);
                }                
            }
            Set<String>relationshipToAssign = new Set<String>();
            if(isIPA == true)
            {
                if(contactRelationshipsById.get(System.Label.PRM_WorksFor) != null) { 
                    relationshipToAssign.add(contactRelationshipsById.get(System.Label.PRM_WorksFor).Id); 
                    if((isACRActive == false && regRequest.PRM_Partner_Relationship__c.contains(System.Label.PRM_Primary_Contact))){
                        relationshipToAssign.add(contactRelationshipsById.get(System.Label.PRM_Primary_Contact).Id); 
                    }
                }                
            }
            else{                
                if(String.isNotBlank(regRequest.PRM_Partner_Relationship__c)){
                    for(String value : regRequest.PRM_Partner_Relationship__c.split(';')){
                        if(!contactRelationshipsById.isEmpty() && contactRelationshipsById.containsKey(value) && contactRelationshipsById.get(value).Name.equalsIgnoreCase(value)){
                            relationshipToAssign.add(contactRelationshipsById.get(value).Id);
                            //accConRel.PRM_Relationship_Id__c = contactRelationshipsById.get(value).Id;
                        }
                    }
                } 
            }    
            //system.debug('Relationship to assign-->'+relationshipToAssign);
            for(String crelID : relationshipToAssign)
            {
                PRM_Account_Contact_Relationship__c accConRel = New PRM_Account_Contact_Relationship__c();  
                accConRel.PRM_Relationship_Id__c = crelID ;
                accConRel.PRM_Account_Id__c= acc.id;
                accConRel.PRM_Contact_Id__c = cont.id ;
                // for setting email flag to true and status to complete
                accConRel.PRM_No_Email__c = true;
                accConRel.PRM_Status_Nm__c = 'Complete';
                accConRel.PRM_SkipValidation__c=true;
                //Added by Naresh
                accConRel.PRM_Start_Date_Dt__c = system.Today();
                accConRel.PRM_Status_Reason_Txt__c = 'Approved as part of Self Registration';
                if(regRequest.PRM_Auto_Approve__c){
                    accConRel.PRM_Status_Reason_Txt__c = System.Label.PRM_APPROVE_MSG;
                }
                
                //set below flag to false : for stoping trigger executioon
                accConRel.PRM_execute_trigger__c = false;    
               
                if(existingACRMap != null && existingACRMap.get(String.valueOf(accConRel.PRM_Account_Id__c)+String.valueOf(accConRel.PRM_Contact_Id__c)+String.valueOf(accConRel.PRM_Relationship_Id__c)) != null )
                {
                   
                    accConRel = existingACRMap.get(String.valueOf(accConRel.PRM_Account_Id__c)+String.valueOf(accConRel.PRM_Contact_Id__c)+String.valueOf(accConRel.PRM_Relationship_Id__c));
                    //accConRel.PRM_Status_Reason_Txt__c = 'Approved as part of Self Registration';
                    if(regRequest.PRM_Is_Returning_User__c &&
                       String.isNotBlank(regRequest.PRM_Review_Note_txt__c))//TWC729-9379  PCR status reason should be UIOLI Return Journey when the contact has come through Self Reg process of UIOLI
                    {
                        accConRel.PRM_Status_Reason_Txt__c = regRequest.PRM_Review_Note_txt__c;
                    }
                    else
                    {
                        accConRel.PRM_Status_Reason_Txt__c = 'Approved as part of Self Registration';
                    }
                    string conemail=String.ValueOf(cont.Email);
        Core_Entitlement_Outbound_Integrations.mapOfContactActivatingACR.put(conemail,true);
                    //system.debug('Existing record found'+accConRel);
                }
                if(accConRel.PRM_AGS_Identity_Creation_Fail__c && cont.Core_Enterprise_Id__c != null){
                    accConRel.PRM_AGS_Identity_Creation_Fail__c = false;
                    accConRel.PRM_AGS_Response_Status__c = 'Success';
                    accConRel.PRM_Error_Message__c = null;
                    accConRel.PRM_Retry_Count__c = null;
                }
                accConRel.PRM_Source_Agent__c = 'Self Registration';
                accConRel.PRM_CampaignId__c=null;
                accConRel.Bulk_Data_Upload__c=null;
                accConRel.PRM_InActive_Ind__c= false;
                accConRelationshipsToUpsert.add(accConRel) ;
            }
        }
        logEntryMsgString+='\n Value returned by createUpdateACR method createUpdateACR: '+accConRelationshipsToUpsert;
        return accConRelationshipsToUpsert;
    }
    //Partner Segment Mapping on Existing Inactive Account
    public static void partnerSegOnExistingAcc(Account acc,PRM_Registration_Request__c regReqRecord)
    {
        /*String partnerSegment = (regReqRecord.PRM_Partner_Role__c != '') ? getPartnerSegment(regReqRecord.PRM_Partner_Role__c) : '';
        //System.debug('partnerSegment -->' + partnerSegment);
        if(acc != null && regReqRecord != null){
             partner segment assigned to account 
            if(String.isNotBlank(partnerSegment)&& !ipaRefresh) {
                if(acc.Core_IPA_Partner_Segment__c != null ) {
                    List<String> partnersegList = (acc.Core_IPA_Partner_Segment__c).split(';');
                    if(partnersegList.contains(partnerSegment)){
                        partnerSegment = acc.Core_IPA_Partner_Segment__c; 
                    }
                    else{
                        partnerSegment = acc.Core_IPA_Partner_Segment__c+';'+ partnerSegment;
                    }
                }
                acc.Core_IPA_Partner_Segment__c = partnerSegment;
            } 
        }*/ // IPA Switch Removal
    }
}