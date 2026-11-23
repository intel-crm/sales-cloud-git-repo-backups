public without sharing class PRM_CreateAccountAndRelatedRecordsAdmin {
    
    /**
*  @description      : Create New Account, Contact and their related Records.
*  @name             : createAccountAndRelatedRecords
*  @param            : map<String,String> 
*  @throws exception : NONE
**/
    @AuraEnabled
    public static Map<String,String> createAccountAndRelatedRecordsAdmin(Map<String,String> registrationDetailsMap)
    {
        Map<String,String> recordIdsMap = new Map<String, String>();
        system.debug('input Param Map'+registrationDetailsMap);
        /*Sample input Map passed from client side...  for Reference 
         {"AccountName":"s","BizOrgType":"EBM- Embedded Board Manufacturer","PartnerRole":"Not Applicable","AddressLine1":"Flat No 403, Pritam woods , Green Glen Layout","Country":"ALA","CountryLabel":"Aland Islands","State":"","StateLabel":"","City":"Be","PostalCode":"560103","ContactFirstName":"s","ContactLastName":"s","ContactEmail":"s","PreferredLanguage":"THA",
          "DuplicateInfo":"[{\"Id\":\"0016C00000BIhWeQAL\",\"Name\":\"BIG Networks\",\"BillingStreet\":\"2178  Roosevelt Street\",\"BillingCity\":\"San Francisco\",\"BillingState\":\"CA\",\"BillingPostalCode\":\"94105\",\"BillingCountry\":\"USA\",\"Core_Intel_Partner_Alliance_PartnerGroup__c\":false,\"Core_Account_Type__c\":\"EMS- Electronic Manufacturing Services;End user: Education\",\"Core_IPA_Partner_Role__c\":\"Distributor;FPGA Designer\",\"Industry\":\"Needs Defined\",\"AccountName\":\"/lightning/r/Account/0016C00000BIhWeQAL/view\",\"BillingAddress\":\"2178  Roosevelt Street,San Francisco,CA,94105,USA\",\"DuplicateStatus\":\"PartDup\"},{\"Id\":\"0016C00000CldIiQAJ\",\"Name\":\"Sapient\",\"BillingStreet\":\"4492  Golden Ridge Road Church City\",\"BillingCity\":\"Las Vegas\",\"BillingState\":\"NY\",\"BillingPostalCode\":\"07292\",\"BillingCountry\":\"USA\",\"Core_Intel_Partner_Alliance_PartnerGroup__c\":true,\"Core_Account_Type__c\":\"Cloud Service Provider (CSP)\",\"Core_IPA_Partner_Role__c\":\"Service Provider\",\"Industry\":\"Chemicals\",\"AccountName\":\"/lightning/r/Account/0016C00000CldIiQAJ/view\",\"BillingAddress\":\"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA\",\"DuplicateStatus\":\"PartDup\"}]",
          "SelectedRow":[{"Id":"0016C00000CldIiQAJ","Name":"Sapient","BillingStreet":"4492  Golden Ridge Road Church City","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"07292","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Cloud Service Provider (CSP)","Core_IPA_Partner_Role__c":"Service Provider","Industry":"Chemicals","AccountName":"/lightning/r/Account/0016C00000CldIiQAJ/view","BillingAddress":"4492  Golden Ridge Road Church City,Las Vegas,NY,07292,USA","DuplicateStatus":"PartDup"}],
          "AccountDuplicateStatus":"PartDup",
          "ContactDuplicateStatus":"NoDuplicate",
          "accountAssociatedToExistingContact":{"Id":"0016C00000EPSf5QAH","Name":"Roy Enterprises","BillingStreet":"US Church Street 927181/127 Near Trinity University","BillingCity":"Las Vegas","BillingState":"NY","BillingPostalCode":"0721","BillingCountry":"USA","Core_Intel_Partner_Alliance_PartnerGroup__c":true,"Core_Account_Type__c":"Distributor;Cloud Service Provider (CSP)","Core_IPA_Partner_Role__c":"Distributor;Independent Software Vendor;Service Provider","Industry":"Banking"}}
          null in case no existingAccountFound duplicateContactRecord
        */
        system.debug('accountAssociatedToExistingContact'+registrationDetailsMap.get('accountAssociatedToExistingContact'));
        system.debug('duplicateContactRecord'+registrationDetailsMap.get('duplicateContactRecord'));
        //Rollback everything, in case of any exception
        Savepoint sp = Database.setSavepoint();
        try{
            //Get values from input Map passed
            String accountDupStatus = registrationDetailsMap.get('AccountDuplicateStatus');
            String contactDupStatus = registrationDetailsMap.get('ContactDuplicateStatus');
            String duplicateRecordsFromCim = String.valueOf(registrationDetailsMap.get('DuplicateInfo'));
            Account accountAssociatedToExistingContact ;
            Contact duplicateContactRecord ;
            Account accToProcess ;
            Contact contToProcess ;
            Boolean rowSelected = false; 
            Boolean isDuplicateContact = false;
            system.debug('inside class'+registrationDetailsMap.get('AccountName'));
            //Parse values to get selected row details
            List<Object> selectedRowJSONList = new List<Object>();
            Map<String, Object> selectedRowMap = new Map<String,Object>();
            system.debug('Selected Row-->'+registrationDetailsMap.get('SelectedRow'));
            if(registrationDetailsMap.keySet().contains('SelectedRow') &&  registrationDetailsMap.get('SelectedRow') != null && registrationDetailsMap.get('SelectedRow') != '')
            {   rowSelected = true;
                selectedRowJSONList = (List<Object>) JSON.deserializeUntyped(registrationDetailsMap.get('SelectedRow'));
                system.debug(selectedRowJSONList);
                system.debug(selectedRowJSONList[0]);
                selectedRowMap = (Map<String,Object>) selectedRowJSONList[0];
                system.debug(selectedRowMap.get('Name'));
                //String Name = String.valueOf(selectedRowMap.get('Name'));
                //system.debug(name);
            }
            
            //Check scenario
            if(contactDupStatus == 'Duplicate')
            {   system.debug('<----Existing Contact Found--->');
                isDuplicateContact = true;
                duplicateContactRecord = [select id,name,email,accountId,Core_IPA_Partner_Role__c,Core_Preferred_Language__c,Core_Do_Not_Contact__c from contact where email=:registrationDetailsMap.get('ContactEmail')];
                accountAssociatedToExistingContact = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Industry from Account where id = : duplicateContactRecord.Accountid ];
                accToProcess =accountAssociatedToExistingContact ;
                contToProcess = duplicateContactRecord ;
                system.debug('Duplicate Contact'+contToProcess);
                system.debug('Account associated with Existing Contact'+accToProcess);
            }
            
            //Create Account ********************************   
            boolean newAccountCreated = false;
            if((isDuplicateContact == false) && (accountDupStatus == 'NoDup' || (!rowSelected)))
            {
            system.debug('<----New Account Creation--->');
            Account newAccount = new Account();
            Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
            newAccount.Name = registrationDetailsMap.get('AccountName') ;
            newAccount.RecordTypeId = accountRecordType;
            newAccount.BillingCountryCode = registrationDetailsMap.get('Country');
            newAccount.ShippingCountryCode = registrationDetailsMap.get('Country');
            newAccount.BillingStateCode = registrationDetailsMap.get('State');
            newAccount.ShippingStateCode = registrationDetailsMap.get('State');
            newAccount.BillingStreet = registrationDetailsMap.get('AddressLine1');
            newAccount.ShippingStreet = registrationDetailsMap.get('AddressLine1');
            if(String.isNotBlank(registrationDetailsMap.get('AddressLine2'))){
                newAccount.BillingStreet += ' ' + registrationDetailsMap.get('AddressLine2');
            }
            if(String.isNotBlank(registrationDetailsMap.get('AddressLine2'))){
                newAccount.ShippingStreet += ' ' + registrationDetailsMap.get('AddressLine2');
            }
            newAccount.BillingCity = registrationDetailsMap.get('City');
            newAccount.ShippingCity = registrationDetailsMap.get('City');
            newAccount.BillingPostalCode = registrationDetailsMap.get('PostalCode');
            newAccount.ShippingPostalCode = registrationDetailsMap.get('PostalCode');
            newAccount.Core_Account_Type__c = registrationDetailsMap.get('BizOrgType');
            newAccount.Core_IPA_Partner_Role__c = registrationDetailsMap.get('PartnerRole');
            //newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true ; 
            newAccount.Core_Sales_Groups__c = System.Label.PRM_Undefined;
            newAccount.Industry = System.Label.PRM_Needs_Defined;
            User u = [Select id from User where alias =: System.Label.PRM_UncoveredAccount] ;
            if(u != null) {newAccount.OwnerId  = u.id ; }
            System.debug('AccountToCreate--->'+newAccount);
            if(newAccount != null) {
                insert newAccount;
                accToProcess = newAccount;
                newAccountCreated = true; 
            }     
            }
            else if(rowSelected){
             system.debug('<----Existing Account Found--->'); 
             List<Account> selectedAccountList  = new List<Account>();
             Id accountId = String.valueOf(selectedRowMap.get('Id'));   
             selectedAccountList = [Select id,Name,Core_Account_Type__c,Core_IPA_Partner_Role__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Sales_Groups__c,Industry from Account where id =: accountId ];
             if(selectedAccountList != null && selectedAccountList.size()>0) { accToProcess =  selectedAccountList[0]; }
             } 
            
            //Create Contact **************************
            boolean newContactCreated = false;
            Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
            if(contactDupStatus == 'NoDuplicate')
            {
            system.debug('<----New Contact Creation--->');
            Contact cont = new Contact();
            cont.FirstName = registrationDetailsMap.get('ContactFirstName');
            cont.LastName = registrationDetailsMap.get('ContactLastName');
            cont.Email = registrationDetailsMap.get('ContactEmail');
            //Keerthan added as part of US609304
            /*******************/
            System.debug('ContactCountry : '+registrationDetailsMap.get('ContactCountry'));
            cont.MailingCountry = registrationDetailsMap.get('ContactCountry');
            cont.MailingCountryCode = registrationDetailsMap.get('ContactCountry');
            /*******************/
            List<String> prefLanguageList= new List<String>();
            Schema.DescribeFieldResult fieldResult = Contact.Core_Preferred_Language__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                prefLanguageList.add(pickListVal.getValue());
            }    
            if(registrationDetailsMap.get('PreferredLanguage') != null && registrationDetailsMap.get('PreferredLanguage') != '' &&
               prefLanguageList != null && prefLanguageList.contains(registrationDetailsMap.get('PreferredLanguage'))){
                   cont.Core_Preferred_Language__c =registrationDetailsMap.get('PreferredLanguage');
                   cont.Core_eRPM_Language_Code__c=registrationDetailsMap.get('PreferredLanguage');
               }
            else{
                cont.Core_Preferred_Language__c =System.Label.PRM_ENG;
                cont.Core_eRPM_Language_Code__c=System.Label.PRM_ENG;
            }
            system.debug(cont.Core_Preferred_Language__c);
            cont.RecordTypeId = contactRecordType;
            cont.Core_IPA_Partner_Role__c = registrationDetailsMap.get('PartnerRole') ;
            cont.AccountId = accToProcess.id;             
            insert cont;
            newContactCreated = true;
            contToProcess = cont;
            //PRM_AGS_IdentityCreation.createIdentityInAGS(cont.Id);
            System.debug('!!!Contact Id:'+cont.Id);
            system.debug('Contact inserted-->'+cont);
            system.debug('Total queries executed after Contact creation--->'+Limits.getQueries());
            } 
            
            //Create ACM************************
            String ipaChannelPgmId ;
            String channelProgramLevelId ;
            Boolean newACMCreated = false;
            List<ChannelProgram> chProgramList = [select id from ChannelProgram where prm_programCode__c=: System.Label.PRM_IPAEngagement];
            Map<String,PRM_AccountChannelMembership__c> existingACMMap = new Map<String,PRM_AccountChannelMembership__c>();
            List<PRM_AccountChannelMembership__c> accChannelMembershipListToUpsert = new List<PRM_AccountChannelMembership__c>();
            if(ChProgramList != null && ChProgramList.size()>0)
            {
                ipaChannelPgmId = ChProgramList[0].id;
            }
            List<ChannelProgramLevel> chProgramLevelList = [select id from ChannelProgramLevel where prm_programlevelcode__c='MEMBER' and ProgramId =:ipaChannelPgmId];
            if(chProgramLevelList != null && chProgramLevelList.size()>0){
                channelProgramLevelId = chProgramLevelList[0].id;
            }
            //check for existing ACM records :
            boolean isIPAaccount = false;
            for(PRM_AccountChannelMembership__c acm : [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: accToProcess.id and PRM_Channel_Program_Id__c =: ipaChannelPgmId and PRM_Partner_Role__c =: registrationDetailsMap.get('PartnerRole')])
            {
                existingACMMap.put(String.valueOf(acm.PRM_Account_Id__c)+String.valueOf(acm.PRM_Channel_Program_Id__c)+String.valueOf(acm.PRM_Partner_Role__c),acm);
                //if ACM record found for the same account with patrtner role provided in input, Account will be considered as IPA
                if(acm.PRM_Status_Nm__c != null && acm.PRM_Status_Nm__c != 'Inactive')
                {
                 isIPAaccount = true;  
                }
            }
            system.debug('<----IPA Account--->'+isIPAaccount);  
            PRM_AccountChannelMembership__c accChannelMembership ;
            
            if((!isIPAaccount) || (rowSelected == false && isDuplicateContact == false))
            {
            //Create new ACM when New Account created or existing Account is NonIPA 
            newACMCreated = true;
            accChannelMembership = new PRM_AccountChannelMembership__c();
            accChannelMembership.PRM_Partner_Role__c = registrationDetailsMap.get('PartnerRole');
            accChannelMembership.PRM_Account_Id__c = accToProcess.id ;
            accChannelMembership.PRM_Status_Nm__c = System.Label.PRM_Status_Pending ;//System.Label.PRM_Status;
            if(ipaChannelPgmId != null && ipaChannelPgmId != '') {accChannelMembership.PRM_Channel_Program_Id__c = ipaChannelPgmId;}
            if(channelProgramLevelId != null && channelProgramLevelId != '') {accChannelMembership.PRM_Channel_Program_Level_Id__c = channelProgramLevelId ;}
            //update Account(Biz Org Type, PR, IPA) and Contact(PR) when ACM record created, but when records are not newly created already
             if(!newAccountCreated)
             {
                if(accToProcess.Core_Account_Type__c != null && String.isNotBlank(String.valueOf(accToProcess.Core_Account_Type__c)))
                {   Set<String> existingAccTypeSet = new Set<String>();
                existingAccTypeSet.addAll(accToProcess.Core_Account_Type__c.split(';'));
                if(! existingAccTypeSet.contains(registrationDetailsMap.get('BizOrgType'))) { accToProcess.Core_Account_Type__c = accToProcess.Core_Account_Type__c+';'+registrationDetailsMap.get('BizOrgType') ;  }
                }else {
                accToProcess.Core_Account_Type__c = registrationDetailsMap.get('BizOrgType') ;
                }
               //accToProcess.Core_Account_Type__c = registrationDetailsMap.get('BizOrgType');
               if(accToProcess.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(accToProcess.Core_IPA_Partner_Role__c)))
                {   Set<String> existingPartnerRoleSet = new Set<String>();
                existingPartnerRoleSet.addAll(accToProcess.Core_IPA_Partner_Role__c.split(';'));
                if(! existingPartnerRoleSet.contains(registrationDetailsMap.get('PartnerRole'))) { accToProcess.Core_IPA_Partner_Role__c = accToProcess.Core_IPA_Partner_Role__c+';'+registrationDetailsMap.get('PartnerRole') ;  }
                }else {
                accToProcess.Core_IPA_Partner_Role__c = registrationDetailsMap.get('PartnerRole') ;
                }
              //accToProcess.Core_IPA_Partner_Role__c = registrationDetailsMap.get('PartnerRole');
              //accToProcess.Core_Intel_Partner_Alliance_PartnerGroup__c = true ;
             // update accToProcess ;
              system.debug('<----Account Updated--->');
             }
             /*if(!newContactCreated)
             {
              if(contToProcess.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(contToProcess.Core_IPA_Partner_Role__c)))
                {Set<String> existingPartnerRoleSet = new Set<String>();
                existingPartnerRoleSet.addAll(contToProcess.Core_IPA_Partner_Role__c.split(';'));
                if(! existingPartnerRoleSet.contains(registrationDetailsMap.get('PartnerRole'))) { contToProcess.Core_IPA_Partner_Role__c = contToProcess.Core_IPA_Partner_Role__c+';'+registrationDetailsMap.get('PartnerRole') ;  }
                }else {
                contToProcess.Core_IPA_Partner_Role__c = registrationDetailsMap.get('PartnerRole') ;
                }   
              //contToProcess.Core_IPA_Partner_Role__c = registrationDetailsMap.get('PartnerRole') ;
              update contToProcess ;
              system.debug('<----Contact Updated--->');
             }*/
            }
            /*else {
                //update Account field IPA flag to true , even if it is a IPA Account 
                if(!newAccountCreated && accToProcess.Core_Intel_Partner_Alliance_PartnerGroup__c == false)
                {
                    accToProcess.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
                    //update accToProcess;
                    system.debug('<-----IPA Flag for IPA Account updated---->');
                }
            }*/
            
            //update contact's partner role if it is an existing contact
            if(!newContactCreated)
             {
              if(contToProcess.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(contToProcess.Core_IPA_Partner_Role__c)))
                {Set<String> existingPartnerRoleSet = new Set<String>();
                existingPartnerRoleSet.addAll(contToProcess.Core_IPA_Partner_Role__c.split(';'));
                if(! existingPartnerRoleSet.contains(registrationDetailsMap.get('PartnerRole'))) { contToProcess.Core_IPA_Partner_Role__c = contToProcess.Core_IPA_Partner_Role__c+';'+registrationDetailsMap.get('PartnerRole') ;  }
                }else {
                contToProcess.Core_IPA_Partner_Role__c = registrationDetailsMap.get('PartnerRole') ;
                }   
              //contToProcess.Core_IPA_Partner_Role__c = registrationDetailsMap.get('PartnerRole') ;
              update contToProcess ;
              system.debug('<----Contact Updated--->');
             }
            
            update accToProcess;
            
            system.debug(existingACMMap);
            //system.debug(String.valueOf(accToProcess.id)+String.valueOf(ipaChannelPgmId)+String.valueOf(registrationDetailsMap.get('PartnerRole')));
            if(existingACMMap != null && existingACMMap.get(String.valueOf(accToProcess.id)+String.valueOf(ipaChannelPgmId)+String.valueOf(registrationDetailsMap.get('PartnerRole'))) != null)
            {   //update existing ACM only if status is inActive
                //system.debug(existingACMMap.get(String.valueOf(accToProcess.id)+String.valueOf(ipaChannelPgmId)+String.valueOf(registrationDetailsMap.get('PartnerRole'))));
                if(existingACMMap.get(String.valueOf(accToProcess.id)+String.valueOf(ipaChannelPgmId)+String.valueOf(registrationDetailsMap.get('PartnerRole'))).PRM_Status_Nm__c == 'Inactive' ) {
                    accChannelMembership = existingACMMap.get(String.valueOf(accToProcess.id)+String.valueOf(ipaChannelPgmId)+String.valueOf(registrationDetailsMap.get('PartnerRole')));
                    accChannelMembership.PRM_Status_Nm__c = System.Label.PRM_Status_Pending ;
                    system.debug('ACM to update-->'+accChannelMembership);
                    accChannelMembershipListToUpsert.add(accChannelMembership) ;
                }
            }
            else{
                 //If no duplicate ACM found..
                 system.debug('<----New ACM Creation--->');
                 if(accChannelMembership != null) {accChannelMembershipListToUpsert.add(accChannelMembership) ; }
            }
            if(accChannelMembershipListToUpsert != null && accChannelMembershipListToUpsert.size()>0) {upsert accChannelMembershipListToUpsert;}
            
            system.debug('Total queries executed after ACM creation--->'+Limits.getQueries());
            

            //Create ACR***********************
            Map<String, PRM_ContactRelationships__c> contactRelationshipsById = New Map<String,PRM_ContactRelationships__c>();
            Map<String,PRM_Account_Contact_Relationship__c> existingACRMap = new Map<String,PRM_Account_Contact_Relationship__c>();
            List<PRM_Account_Contact_Relationship__c> accConRelationshipsToUpsert = new List<PRM_Account_Contact_Relationship__c>();
            //check for duplicates
            for(PRM_Account_Contact_Relationship__c acr : [Select id,PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_InActive_Ind__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c =: accToProcess.id and PRM_Contact_Id__c =: contToProcess.id])
            {
                existingACRMap.put(String.valueOf(acr.PRM_Account_Id__c)+String.valueOf(acr.PRM_Contact_Id__c)+String.valueOf(acr.PRM_Relationship_Id__c),acr) ;
            }
            system.debug('Existing ACRs-- '+existingACRMap.size());
            if(ipaChannelPgmId != null  && ipaChannelPgmId != '' ){
                for(PRM_ContactRelationships__c crel : [Select Id, Name, PRM_Channel_Program_Id__c From PRM_ContactRelationships__c Where PRM_Channel_Program_Id__c =: ipaChannelPgmId]){
                    contactRelationshipsById.put(crel.Name, crel);
                }
                system.debug('@@@contactRelationshipsById'+contactRelationshipsById); 
            }
            Set<String> relationshipToAssign = new Set<String>();
            system.debug('coming here to create Account Contact relationship for member');
            if(contactRelationshipsById != null && (!contactRelationshipsById.isEmpty())){
                //PC and WF both are assigned when new ACM is created, otherwise only WF  
                if(newACMCreated && contactRelationshipsById.containsKey(System.Label.PRM_Primary_Contact)){ relationshipToAssign.add(contactRelationshipsById.get(System.Label.PRM_Primary_Contact).id);}
                if(contactRelationshipsById.containsKey(System.Label.PRM_WorksFor)) {relationshipToAssign.add(contactRelationshipsById.get(System.Label.PRM_WorksFor).id);}
            }
            
            system.debug('Relationship to assign-->'+relationshipToAssign);
            for(String crelID : relationshipToAssign)
            {   
                PRM_Account_Contact_Relationship__c accConRel = New PRM_Account_Contact_Relationship__c();  
                accConRel.PRM_Relationship_Id__c = crelID ;
                accConRel.PRM_Account_Id__c= accToProcess.id;
                accConRel.PRM_Contact_Id__c = contToProcess.id ;
                // for setting email flag to false
                accConRel.PRM_No_Email__c = false;
                //set below flag to false : for stoping trigger executioon
                accConRel.PRM_execute_trigger__c = false;   
                accConRel.PRM_InActive_Ind__c= false;
                accConRel.PRM_Status_Nm__c = 'Pending Action';
                system.debug('existingACRMap-->'+existingACRMap);
                if(existingACRMap != null && existingACRMap.get(String.valueOf(accConRel.PRM_Account_Id__c)+String.valueOf(accConRel.PRM_Contact_Id__c)+String.valueOf(accConRel.PRM_Relationship_Id__c)) != null )
                {   //update ACR only if inActive indicator is false
                    if(existingACRMap.get(String.valueOf(accConRel.PRM_Account_Id__c)+String.valueOf(accConRel.PRM_Contact_Id__c)+String.valueOf(accConRel.PRM_Relationship_Id__c)).PRM_InActive_Ind__c == true){
                    accConRel = existingACRMap.get(String.valueOf(accConRel.PRM_Account_Id__c)+String.valueOf(accConRel.PRM_Contact_Id__c)+String.valueOf(accConRel.PRM_Relationship_Id__c));
                    accConRel.PRM_InActive_Ind__c= false;    
                    system.debug('ACR to update-->'+accConRel);
                    accConRelationshipsToUpsert.add(accConRel) ;    
                    }    
                }
                else{
                  //if no duplicate ACR record found..  
                  accConRelationshipsToUpsert.add(accConRel) ;
                }
                system.debug('ACR List to upsert'+accConRelationshipsToUpsert);
            }    
            if(accConRelationshipsToUpsert!= null && accConRelationshipsToUpsert.size()>0) { upsert accConRelationshipsToUpsert ; }
            system.debug('Total queries executed after ACR creation--->'+Limits.getQueries());
            
            system.debug(accToProcess.id+''+contToProcess.id);
            // Get values to return**********************
            recordIdsMap.put('AccountId',accToProcess.id);
            recordIdsMap.put('ContactId',contToProcess.id);
            List<Contact> contactsTosendEmail = new List<Contact>();
            contactsTosendEmail.add(contToProcess);
            //sendWelcomeEmailNotification(contactsTosendEmail); 
            return recordIdsMap;  
        }
        catch(Exception e){
            PRM_ErrorUtilityClass.logError(e);
            Database.rollback( sp );
        }
        
        return null;  
    }
    
    //Harshit added on 26/11/2019: to invoke EmailFramework for sending welcome email to newly added contacts
    public static void sendWelcomeEmailNotification(List<Contact> contactListToInsert)
    {
        system.debug('Total queries executed before Email Class--->'+Limits.getQueries());  
        for(Contact c : contactListToInsert) 
        {
            PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
            map<String, String> inputParameters = new map<String, String>();
            inputParameters.put('Account_ID',c.AccountId);
            objEmailNotif.InputParameters=inputParameters;
            objEmailNotif.BusinessEvent='Welcome_email_on_admin_request_approval';
            objEmailNotif.Language = c.Core_Preferred_Language__c;
            objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
            objEmailNotif.PartnerType=System.Label.PRM_CsP;
            objEmailNotif.EmailID= c.Email;
            if(c != null && c.Core_Do_Not_Contact__c  == false)
            {
                PRM_EmailUtility.sendEmail(objEmailNotif);    
                PRM_createAccountandRelatedRecords.linkEmailLogToContact(c.Email);
            }
        }
        system.debug('Total queries executed after sending Emails and updating logs--->'+Limits.getQueries());  
    }
    
    //Keerthan added on 01/09/2020 : To process and create related records for Admin registration
    public static void processRelatedRecordsAdmin(List<Id> accountIds, Map<Id,PRM_Registration_Request__c> accRegMap,List<String> contactEmailList){
        //Rollback everything, in case of any exception
        Savepoint sp = Database.setSavepoint();
        try{
            //********************************************
            //********************************************
            //##create Legal Agreement Association
            String accId;
            String conId;
            PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
            List<Contact> contactList = new List<Contact>();
            Set<String> legalAgrmntValues =new Set<String>();
            Map<String, String> legalAgrmntMap = new Map<String, String>();
            List<PRM_AccountLegalAgreemntAssociation__c> accLegalAgreementUpsertList = new List<PRM_AccountLegalAgreemntAssociation__c>();
            Map<String,PRM_AccountLegalAgreemntAssociation__c> existingALAMap = new Map<String,PRM_AccountLegalAgreemntAssociation__c>();
            for(Id id : accountIds){
                accId = id;
            }
            System.debug('@@ accId'+accId);
            if(String.isNotBlank(accId)){
                regRequest = accRegMap.get(accId);
            }
            System.debug('@@ regRequest'+regRequest);
            System.debug('@@ regRequest.PRM_Legal_Agreements__c'+regRequest.PRM_Legal_Agreements__c);
            if(String.isNotBlank(regRequest.PRM_Legal_Agreements__c)){
                legalAgrmntValues.addall(regRequest.PRM_Legal_Agreements__c.split(';'));
            }
            if(!legalAgrmntValues.isEmpty() && legalAgrmntValues != null){
                for(PRM_PartnerAgreement__c pa : [Select Id,Name from PRM_PartnerAgreement__c where Name IN : legalAgrmntValues]){
                    legalAgrmntMap.put(pa.Name,pa.id);
                }
            }
            //check for duplicates:
            for(PRM_AccountLegalAgreemntAssociation__c ala : [Select id,PRM_Account_Id__c,PRM_Partner_Agreement_Id__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c =: accId and PRM_Partner_Agreement_Id__c in : legalAgrmntMap.values()])
            {
                existingALAMap.put(String.valueOf(ala.PRM_Account_Id__c)+String.valueOf(ala.PRM_Partner_Agreement_Id__c),ala);
            }
                
            for(Contact c : [Select Id,AccountId,Email,Core_eRPM_Language_Code__c,Core_IPA_Partner_Role__c,Core_Do_Not_Contact__c,Core_Preferred_Language__c,Firstname,Lastname From Contact Where Email In : contactEmailList]){
                conId = c.Id;
                contactList.add(c);
            }
            System.debug('@@ conId'+conId);
            System.debug('@@ contactList'+contactList);
            
            if(String.isNotBlank(regRequest.PRM_Legal_Agreements__c)){
                for(String value : regRequest.PRM_Legal_Agreements__c.split(';')){
                    system.debug('@@Map=='+legalAgrmntMap+'@@Value=='+value);
                    if(legalAgrmntMap.containsKey(value)){
                        PRM_AccountLegalAgreemntAssociation__c acntLegalAgrAssoc = new PRM_AccountLegalAgreemntAssociation__c();
                        acntLegalAgrAssoc.PRM_Partner_Agreement_Id__c = legalAgrmntMap.get(value);
                        acntLegalAgrAssoc.PRM_Account_Id__c = accId;
                        acntLegalAgrAssoc.PRM_Contact__c = conId ;
                        if(existingALAMap != null && existingALAMap.get(String.valueOf(accId)+String.valueOf(legalAgrmntMap.get(value))) != null) {
                            acntLegalAgrAssoc = existingALAMap.get(String.valueOf(accId)+String.valueOf(legalAgrmntMap.get(value))); 
                        }
                        acntLegalAgrAssoc.PRM_Agreement_Sign_Dt__c = System.Now();
                        accLegalAgreementUpsertList.add(acntLegalAgrAssoc); 
                        system.debug('Record ==>'+acntLegalAgrAssoc);     
                    }
                }
            }    
            if(accLegalAgreementUpsertList!= null && accLegalAgreementUpsertList.size()>0) { upsert accLegalAgreementUpsertList ; }
    //***********************************************************
    //***********************************************************
    //Update ACM to Approved Status
            Boolean isAdminProcess = True;
            List<PRM_AccountChannelMembership__c> acmList =  [Select Id,PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Channel_Program_Id__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Account_Id__c In : accountIds];
            System.debug('acmList queried'+acmList);
            List<PRM_AccountChannelMembership__c> acmListtoUpdate = new List<PRm_AccountChannelMembership__c>();
            Boolean acmApproved = False;
            if(acmList.size() > 0){
                for(PRM_AccountChannelMembership__c acm : acmList){
                    if((acm.PRM_Channel_Program_Id__c == accRegMap.get(acm.PRM_Account_Id__c).PRM_Channel_Program__c)&&(acm.PRM_Partner_Role__c==accRegMap.get(acm.PRM_Account_Id__c).PRM_Partner_Role__c)){
                        if(acm.PRM_Status_Nm__c == 'Approved')
                        {
                            acmApproved = true;
                            system.debug('<---ACM Status already approved--->');
                        }
                        else{
                            acm.PRM_Status_Nm__c = 'Approved';
                            acmListtoUpdate.add(acm);
                        }
                    }
                }
            }
            if(acmListtoUpdate.size() > 0){
                update acmListtoUpdate;
                acmApproved = True;
                system.debug('<---ACM updated--->');
            }
            if(acmApproved){
            List<Account> accountList = [Select Id,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPA_Partner_Role__c,Industry,Core_IPA_Partner_Speciality__c From Account Where Id In : accountIds];
            //List<Contact> contactList = [Select Id,AccountId,Email,Core_eRPM_Language_Code__c,Core_IPA_Partner_Role__c,Core_Do_Not_Contact__c,Core_Preferred_Language__c,Firstname,Lastname From Contact Where Email In : contactEmailList];
            Map<Id,Contact> accContactMap = new Map<Id,Contact>();
            for(Contact con : contactList){
                accContactMap.put(con.AccountId,con);
            }
            for(Account acc : accountList){
                createRelatedRecords(accRegMap.get(acc.id),acc,accContactMap.get(acc.Id));
            }
            System.enqueueJob( new PRM_RegReqProcessingQueueable(accountList,contactList,acmApproved,isAdminProcess,'',null));
            system.debug('Total queries after queueable class--->'+Limits.getQueries());
           }
        }
        catch(exception e){
            PRM_ErrorUtilityClass.logError(e);
            Database.rollback( sp );
        }
    } 
    
    public static void createRelatedRecords(PRM_Registration_Request__c regRequest, Account acc, Contact cont){
        try{
System.debug('----regRequest----'+regRequest);
            
            // Country Mapping for contact
            Map<string,string> countryMapContact = new map<string,string>();
            for(Core_Country_Code_Mapping__c allCountry : Core_Country_Code_Mapping__c.getAll().values()) {
                countryMapContact.put(allCountry.Country_Code__c, allCountry.ISO_Code__c);
            }
            //********************************************
            //##Populate Account and Contact Fields
            acc.Phone = regRequest.PRM_Account_Phone__c;
            if(acc.Core_Intel_Partner_Alliance_PartnerGroup__c == false){
                acc.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            }
            //Added by Rahul for US596330
            //starts
            if(regRequest.PRM_Partner_Role__c != null && String.isNotBlank(String.valueOf(regRequest.PRM_Partner_Role__c))){
                if(regRequest.PRM_Partner_Role__c.contains(Label.PRM_FPGA_Desginer)){
                    System.debug('@@ Update PSG flag');
                    acc.Core_PSG_Account__c = true;
                }
            }
            //ends

      cont.FirstName = regRequest.PRM_First_Name__c;
      cont.LastName = regRequest.PRM_Last_Name__c;
            if(regRequest.PRM_Contact_Country__c != null && regRequest.PRM_Contact_Country__c != '')
            {
                if (regRequest.PRM_Contact_Country__c.length() == 2){
                    cont.MailingCountry = countryMapContact.get(regRequest.PRM_Contact_Country__c);
                    cont.MailingCountryCode = countryMapContact.get(regRequest.PRM_Contact_Country__c);   
                }else{
                    cont.MailingCountry = regRequest.PRM_Contact_Country__c;
                    cont.MailingCountryCode = regRequest.PRM_Contact_Country__c;   
                }
            }
      cont.Core_Preferred_Language__c = regRequest.PRM_Preferred_Language__c; 
            cont.Phone = regRequest.PRM_Person_Phone_Number__c;
            //cont.Core_Job_Function__c = regRequest.PRM_Job_Function__c;
            cont.Core_Job_Function_Code__c = regRequest.PRM_Job_Function__c;
            
            //**********Team QUEST*********************
            //cont.PRM_Wechat_Open_Id__c=regRequest.PRM_Wechat_Open_Id__c;
            //cont.PRM_Wechat_Union_Id__c=regRequest.PRM_Wechat_Union_Id__c;
            //cont.PRM_Registration_Source_txt__c=regRequest.PRM_Registration_Source_txt__c;
          //*********END******************************
            update acc;
            update cont;
            //***********************************************************
            //***********************************************************
            //##create Contact Subscription Association   
            
            Set<String> subscriptionValues =new Set<String>();
            Map<String, PRM_Partner_Subscription__c> subscriptionMap = new Map<String, PRM_Partner_Subscription__c>();
            Map<String,PRM_ContactSubscriptionAssociation__c> existingCSAMap = new Map<String,PRM_ContactSubscriptionAssociation__c>();
            List<PRM_ContactSubscriptionAssociation__c> contactSubscriptionUpsertList = new List<PRM_ContactSubscriptionAssociation__c>();
            Set<String> subscriptionIds = new Set<String>();
            if(String.isNotBlank(regRequest.PRM_Subscriptions__c)){
                subscriptionValues.addall(regRequest.PRM_Subscriptions__c.split(';'));
                system.debug('Subscription values from RR'+subscriptionValues);
            }       
            if(!subscriptionValues.isEmpty() && subscriptionValues != null){
                for(PRM_Partner_Subscription__c sub : [Select Id,PRM_Subscription_Cd__c,Name from PRM_Partner_Subscription__c where PRM_Subscription_Cd__c IN : subscriptionValues]){
                    subscriptionMap.put(sub.PRM_Subscription_Cd__c,sub);
                    subscriptionIds.add(sub.id);
                    System.debug('@@@ SubscriptionMap'+subscriptionMap);
                }
            }
            //check for duplicate records:
            for(PRM_ContactSubscriptionAssociation__c csa : [Select id,PRM_Partner_Subscription_Id__c,PRM_Status_Nm__c,PRM_Contact_Id__c from PRM_ContactSubscriptionAssociation__c where PRM_Partner_Subscription_Id__c in : subscriptionIds and PRM_Contact_Id__c =: cont.id])
            {
                existingCSAMap.put(String.valueOf(csa.PRM_Partner_Subscription_Id__c)+String.valueOf(csa.PRM_Contact_Id__c),csa);
            }
            if(String.isNotBlank(regRequest.PRM_Subscriptions__c)){
                for(String value : regRequest.PRM_Subscriptions__c.split(';')){
                    PRM_ContactSubscriptionAssociation__c cntSubscrAssoc = new PRM_ContactSubscriptionAssociation__c();
                    if(subscriptionMap.containsKey(value)){
                        System.debug('@@@ SubscriptionMap'+subscriptionMap);
                        cntSubscrAssoc.PRM_Partner_Subscription_Id__c = subscriptionMap.get(value).Id;
                        cntSubscrAssoc.PRM_Contact_Id__c = cont.Id;
                        system.debug('@@@'+cntSubscrAssoc); 
                        if(existingCSAMap != null && existingCSAMap.get(String.valueOf(subscriptionMap.get(value).Id)+String.valueOf(cont.Id)) != null) { cntSubscrAssoc = existingCSAMap.get(String.valueOf(subscriptionMap.get(value).Id)+String.valueOf(cont.Id)) ; }
                        cntSubscrAssoc.PRM_Status_Nm__c = 'Active';
                        contactSubscriptionUpsertList.add(cntSubscrAssoc);
                    } 
                }
            }
            if(contactSubscriptionUpsertList!= null && contactSubscriptionUpsertList.size()>0) { upsert contactSubscriptionUpsertList ; }
            system.debug('Total queries executed after CS creation--->'+Limits.getQueries());
            
            //***********************************************************
            //##create Profile Response  
            List<Account> accountsToCreate = new List<Account>();
            accountsToCreate.add(acc);
            List<Contact> contactToInsert = new List<Contact>();
            contactToInsert.add(cont);  
            List<PRM_Registration_Request__c> regReqList = new List<PRM_Registration_Request__c>();
            regReqList.add(regRequest);
            system.debug('Total queries executed before ProfileResponse creation-->'+Limits.getQueries());
            //PRM_ProfileResponse.createResponse(regReqList,accountsToCreate,contactToInsert,false);
            system.debug('Total queries executed before ProfileResponse creation--->'+Limits.getQueries());
            
            
            //***********************************************************
        }
        catch(Exception e){     
            System.debug('Exception : '+e);
        }
    }
    
    public static void sendAdminRegApprovalEmail(List<Contact> contactList){
        for(Contact con : contactList){
            PRM_EmailUtility.EmailNotification objEmailNotify = new PRM_EmailUtility.EmailNotification();
            System.debug('PartnerRole'+con.Core_IPA_Partner_Role__c);
           PRM_Email_Content_DataSetup__c emailSetup = PRM_Email_Content_DataSetup__c.getValues(con.Core_IPA_Partner_Role__c);
            map<String, String> inputParameters = new map<String, String>();
            inputParameters.put('Account_ID',con.AccountId);
           if(emailSetup != null){
                inputParameters.put('EmailContent_Setup',emailSetup.Id);    
            }
            objEmailNotify.InputParameters=inputParameters;
            objEmailNotify.BusinessEvent='Email_Admin_Request_Got_Approved';
            objEmailNotify.Language = con.Core_Preferred_Language__c;
            objEmailNotify.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
            objEmailNotify.PartnerType=System.Label.PRM_CsP;
            objEmailNotify.EmailID= con.Email ;
            
            if(con != null && con.Core_Do_Not_Contact__c  == false)
            {                
                PRM_EmailUtility.sendEmail(objEmailNotify);
                PRM_createAccountandRelatedRecords.linkEmailLogToContact(con.Email);                
            }
        }        
   }
}