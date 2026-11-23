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

    @InvocableMethod
    public static void createAccountAndRelatedRecords(List<PRM_Registration_Request__c> regReqList)
    {
        Boolean isContactExisting ;
        Boolean isIPA ;
        Boolean duplicateAccount = false;
        String  cimMatchStatus ;
        String  existingContactId ;
        String duplicateAccountId;
        Account existingAccount ;
        PRM_Registration_Request__c regReqRecord;
        String bizOrgType;
        String accountBizOrgType;
        Set<String> setBizOrgType = new Set<String>();
        
        //assuming only 1 regReq record will be processed at at time
        if(regReqList!= null && regReqList.size()>0){ regReqRecord = regReqList[0]; }
        Id accountRecordType = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        
        //Code for approval of records  
        if(regReqRecord != null){   
            System.debug('@@ regReqRecord'+regReqRecord);
            System.debug('@@ regReqRecord'+regReqRecord.PRM_Partner_Role__c);
            //Check for Existing Contact
            if(regReqRecord.PRM_Matching_Contact__c != null)
            {
                isContactExisting = true;
                existingContactId= regReqRecord.PRM_Matching_Contact__c ;
            }
            //Check for Duplicate Account(New User/Existing Account)
            if(regReqRecord.PRM_Salesforce_ID__c != null){
                duplicateAccount = true;
                duplicateAccountId = regReqRecord.PRM_Salesforce_ID__c;                 
            }
            //Check for Dup status
            cimMatchStatus = regReqRecord.PRM_Dup_Status__c ;
            
            bizOrgType = regReqRecord.PRM_Partner_Type__c;
            accountBizOrgType= regReqRecord.PRM_Account_Partner_Type__c;
            
            System.debug('@@ bizOrgType'+bizOrgType);
            System.debug('@@ accountBizOrgType'+accountBizOrgType);
            
            if(bizOrgType != null && String.isNotBlank(String.valueOf(bizOrgType))){
                setBizOrgType.addAll(bizOrgType.split(';'));
            }
            System.debug('setBizOrgType'+setBizOrgType);
            if(accountBizOrgType != null && String.isNotBlank(String.valueOf(accountBizOrgType))){
                setBizOrgType.addAll(accountBizOrgType.split(';'));
            }
            System.debug('setBizOrgType'+setBizOrgType);

        }
        System.debug('duplicateAccount'+duplicateAccount);
        System.debug('duplicateAccountId'+duplicateAccountId);
        //Rollback everything, in case of any exception
        Savepoint sp = Database.setSavepoint();
        try{
            
            //#################################
            //##Scenario : Existing Contact and Existing Account
            if(isContactExisting != null && isContactExisting == true)
            {
                // Get Existing Contact and Account record
                Contact existingContact = [Select Id,AccountId,Email,Core_eRPM_Language_Code__c,Core_IPA_Partner_Role__c,Core_Do_Not_Contact__c,Core_Preferred_Language__c from Contact where Id=: existingContactId] ;
                existingAccount = [Select Id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPS_Active__c,Core_IPA_Partner_Role__c from Account where Id =: existingContact.accountId];
                system.debug('Scenario : Existing Contact and Existing Account');
                system.debug('ExistingContact-->'+existingContact);
                system.debug('ExistingAccount-->'+existingAccount);
                if(existingAccount != null) {
                    //change in logic to identify an Account as IPA
                    List<PRM_AccountChannelMembership__c> acmListToCheckIPA = new List<PRM_AccountChannelMembership__c>();
                    acmListToCheckIPA= [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: existingAccount.id and PRM_Channel_Program_Id__c =: regReqRecord.PRM_Channel_Program__c and PRM_Partner_Role__c =: regReqRecord.PRM_Partner_Role__c];
                    isIPA = existingAccount.Core_Intel_Partner_Alliance_PartnerGroup__c && (existingAccount.Core_Account_Type__c != null && String.isNotBlank(String.valueOf(existingAccount.Core_Account_Type__c)) &&  existingAccount.Core_Account_Type__c.split(';').contains(regReqRecord.PRM_Partner_Type__c)) && (acmListToCheckIPA != null && acmListToCheckIPA.size() >0 );
                    system.debug('isIPA Flag for Approve scenario---->'+isIPA);
                    // isIPA = existingAccount.Core_Intel_Partner_Alliance_PartnerGroup__c ; 
                    
                }
                
                //Added by Rahul for US596330
                //starts
                if(regReqRecord.PRM_Partner_Role__c != null && String.isNotBlank(String.valueOf(regReqRecord.PRM_Partner_Role__c))){
                if(regReqRecord.PRM_Partner_Role__c.contains(Label.PRM_FPGA_Desginer)){
                    System.debug('update FPGA flag');
                    existingAccount.Core_PSG_Account__c = true;
                }
                }
                //ends

                //Added by Rahul for US596149
                //starts
                //Update Biz Org Type in every scenario
                String existingAccountType = existingAccount.Core_Account_Type__c;
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
                    existingAccount.Core_Account_Type__c = accountType;
                }
                //ends
                system.debug('existingAccount.Core_Account_Type__c'+existingAccount.Core_Account_Type__c);
                
                if(isIPA)
                {
                    //Existing Account and Existing Contact with IPA true   
                    businessEvent = System.label.PRM_Welcome_Email_New_Event;  
                    update existingAccount;
                    PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(existingAccount, existingContact,isIPA,regReqRecord) ;
                }
                else{
                    //Existing Account and Existing Contact with IPA false
                    existingAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true ;
                    String existingRole = existingAccount.Core_IPA_Partner_Role__c;
                    if(existingAccount.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(existingAccount.Core_IPA_Partner_Role__c)))
                    {   Set<String> existingAccRoleSet = new Set<String>();
                     existingAccRoleSet.addAll(existingRole.split(';'));
                     if(! existingAccRoleSet.contains(regReqRecord.PRM_Partner_Role__c)) {existingAccount.Core_IPA_Partner_Role__c = existingRole+';'+regReqRecord.PRM_Partner_Role__c ;} 
                    }else {
                        existingAccount.Core_IPA_Partner_Role__c = regReqRecord.PRM_Partner_Role__c ;
                    }
                    
                    /*if(existingAccount.Core_Account_Type__c != null && String.isNotBlank(String.valueOf(existingAccount.Core_Account_Type__c)))
                    {   Set<String> existingAccTypeSet = new Set<String>();
                     existingAccTypeSet.addAll(existingAccountType.split(';'));
                     if(! existingAccTypeSet.contains(regReqRecord.PRM_Partner_Type__c)) { existingAccount.Core_Account_Type__c = existingAccountType+';'+regReqRecord.PRM_Partner_Type__c ;  }
                    }else {
                        existingAccount.Core_Account_Type__c = regReqRecord.PRM_Partner_Type__c ;
                    }*/
                    system.debug('Existing values '+existingRole+'@@'+existingAccountType);
                    system.debug('Updated values '+existingAccount);
                    businessEvent = System.label.PRM_Welcome_Email_New_Event;   
                    update existingAccount;         
                    PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(existingAccount, existingContact,isIPA,regReqRecord) ;
                }
                    

            }
            
            //PRM_Salesforce_ID__c
            //##Scenario : New User and Existing Account - on the basis of PRM_Salesforce_ID__c
            else if(duplicateAccount){
                List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
                acmList= [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c,PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: duplicateAccountId and PRM_Channel_Program_Id__c =: regReqRecord.PRM_Channel_Program__c and PRM_Partner_Role__c =: regReqRecord.PRM_Partner_Role__c];        
                approveACM(acmList);
                
                Account duplicateAccountRecord;
                Contact newCont;
                //Boolean IPAWithSamePartnerRole;
                duplicateAccountRecord = [Select Id,Name,Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Account_Type__c,Core_IPS_Active__c,Core_IPA_Partner_Role__c,
                                          (Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c from Channel_Memberships1__r
                                           where PRM_Channel_Program_Id__c =: regReqRecord.PRM_Channel_Program__c)
                                          from Account where Id =: duplicateAccountId];
                System.debug('duplicateAccountRecord'+duplicateAccountRecord);
                
                if(duplicateAccountRecord != null){
                    if(duplicateAccountRecord.Core_Intel_Partner_Alliance_PartnerGroup__c &&
                       (duplicateAccountRecord.Core_Account_Type__c != null && 
                        String.isNotBlank(String.valueOf(duplicateAccountRecord.Core_Account_Type__c)) &&  
                        duplicateAccountRecord.Core_Account_Type__c.split(';').contains(regReqRecord.PRM_Partner_Type__c))){
                            isIPA = false;
                            if(duplicateAccountRecord.Channel_Memberships1__r != null){
                                for(PRM_AccountChannelMembership__c acm : duplicateAccountRecord.Channel_Memberships1__r){
                                    if(acm.PRM_Partner_Role__c != null && String.isNotBlank(String.valueOf(acm.PRM_Partner_Role__c))
                                       && acm.PRM_Partner_Role__c == regReqRecord.PRM_Partner_Role__c){
                                           isIPA = true;
                                       }
                                }
                                } 
                        }
                }
                
                //Added by Rahul for US596330
                //starts
                if(regReqRecord.PRM_Partner_Role__c != null && String.isNotBlank(String.valueOf(regReqRecord.PRM_Partner_Role__c))){
                if(regReqRecord.PRM_Partner_Role__c.contains(Label.PRM_FPGA_Desginer)){
                    System.debug('update FPGA flag');
                    duplicateAccountRecord.Core_PSG_Account__c = true;
                }
            }
                //ends

                System.debug('isIPA'+isIPA);
                
                //Added by Rahul for US596149
                //starts
                //Update Biz org type in every scenario
                String existingAccountType = duplicateAccountRecord.Core_Account_Type__c;
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
                    duplicateAccountRecord.Core_Account_Type__c = accountType;
                }
                //ends 
                System.debug('duplicateAccountRecord.Core_Account_Type__c'+duplicateAccountRecord.Core_Account_Type__c);
                
                // Sub-scenarios
                
                // 1) Non-IPA Account(isIPA = null)
               // 2) IPA with different partner role(isIPA = false)
                //3) IPA with same partner role(isIPA = true)
                if(isIPA == null || isIPA == false){
                    if(isIPA == null && (duplicateAccountRecord.Core_Intel_Partner_Alliance_PartnerGroup__c == false)){
                        system.debug('non-ipa account');
                    duplicateAccountRecord.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
                    }
                    String existingRole = duplicateAccountRecord.Core_IPA_Partner_Role__c;
                    if(duplicateAccountRecord.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(duplicateAccountRecord.Core_IPA_Partner_Role__c)))
                    {   Set<String> existingAccRoleSet = new Set<String>();
                     existingAccRoleSet.addAll(existingRole.split(';'));
                     if(! existingAccRoleSet.contains(regReqRecord.PRM_Partner_Role__c)) {duplicateAccountRecord.Core_IPA_Partner_Role__c = existingRole+';'+regReqRecord.PRM_Partner_Role__c ;} 
                    }else {
                        duplicateAccountRecord.Core_IPA_Partner_Role__c = regReqRecord.PRM_Partner_Role__c ;
                    }
                                        
                    //if there are no values in biz org type of account object
                    /*else {
                        system.debug('if there are no values in biz org type of account object');
                        for(String s : setBizOrgType){
                            if(duplicateAccountRecord.Core_Account_Type__c != null && String.isNotBlank(String.valueOf(duplicateAccountRecord.Core_Account_Type__c))){
                                duplicateAccountRecord.Core_Account_Type__c =duplicateAccountRecord.Core_Account_Type__c+';'+s;
                            }
                            else {
                                duplicateAccountRecord.Core_Account_Type__c = s;
                            }
                        }                        
                    }
                        
                   
                    if(duplicateAccountRecord.Core_Account_Type__c != null && String.isNotBlank(String.valueOf(duplicateAccountRecord.Core_Account_Type__c)))
                    {   Set<String> existingAccTypeSet = new Set<String>();
                     existingAccTypeSet.addAll(existingAccountType.split(';'));
                     if(! existingAccTypeSet.contains(regReqRecord.PRM_Partner_Type__c)) { duplicateAccountRecord.Core_Account_Type__c = existingAccountType+';'+regReqRecord.PRM_Partner_Type__c ;  }
                    }else {
                        duplicateAccountRecord.Core_Account_Type__c = regReqRecord.PRM_Partner_Type__c ;
                    }*/

                }
                update duplicateAccountRecord;
                System.debug('updated duplicateAccountRecord'+duplicateAccountRecord);

                if(duplicateAccountRecord != null){    
                businessEvent = System.label.PRM_Welcome_Email_New_Event;          
                PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(duplicateAccountRecord,newCont,isIPA,regReqRecord) ;
            }            
            } 
            
            else //New Contact 
            {
                //##########################################
                //##Scenario : New Contact and Existing Account
                if(cimMatchStatus == Label.PRM_Fulldup ||  cimMatchStatus == Label.PRM_Partdup)
                {
                    //existingAccount = 
                    system.debug('Scenario : New Contact and Existing Account');
                }
                //Below code will execute in both scenarios : New Contact-New Account && New Contact-Existing Account when called from approve button
                //#############################################
                //##Scenario : New Contact and New Account
                system.debug('Scenario :  New Contact and New Account');
                // Country Mapping
                Map<string,string> countryMap = new map<string,string>();
                for(Core_Country_Code_Mapping__c allCountries : Core_Country_Code_Mapping__c.getAll().values()) {
                    countryMap.put(allCountries.Country_Code__c, allCountries.ISO_Code__c);
                }
                
                Account newAccount ;
                Contact newContact ;
                
                newAccount = new Account();
                System.debug('regReqRecord'+regReqRecord);
                //##create Account:
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
                System.debug('regReqRecord.PRM_Address_Line_2__c'+regReqRecord.PRM_Address_Line_2__c);
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
                System.debug('newAccount.Core_Account_Type__c'+newAccount.Core_Account_Type__c);
                
                newAccount.Core_IPA_Partner_Role__c = regReqRecord.PRM_Partner_Role__c;
                System.debug('@@ regReqRecord.PRM_Partner_Role__c'+regReqRecord.PRM_Partner_Type__c);
                System.debug('@@ regReqRecord.PRM_Partner_Role__c'+regReqRecord.PRM_Partner_Role__c);
                //Added by Rahul for US596330
                //starts
                if(regReqRecord.PRM_Partner_Role__c != null && String.isNotBlank(String.valueOf(regReqRecord.PRM_Partner_Role__c))){
                if(regReqRecord.PRM_Partner_Role__c.contains(Label.PRM_FPGA_Desginer)){
                        System.debug('update FPGA flag');
                        newAccount.Core_PSG_Account__c = true;
                }
                }
                //ends
                
                newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true ; 
                //added new attributed below : US431759
                newAccount.Core_User_Defined_Website__c  = regReqRecord.PRM_Account_URL__c ;
                newAccount.Core_User_Defined_Phone_Number__c = regReqRecord.PRM_Account_Phone__c ;
                newAccount.Core_User_Defined_Number_of_Employees__c = regReqRecord.PRM_Company_Size__c ;
                //Added for US452620
                newAccount.Core_Sales_Groups__c = System.Label.PRM_Undefined;
                newAccount.Industry = System.Label.PRM_Needs_Defined;
                User u = [Select id from User where alias =: System.Label.PRM_UncoveredAccount] ;
                if(u != null) {newAccount.OwnerId  = u.id ; }
                System.debug('eachSetOfRecordsToCreate--->'+newAccount);
               
                if(newAccount != null) {
                    insert newAccount;
                }                     
                //PRM_CreateAccountAndRelatedRecords.processRecords(Account acc, Contact cont,Boolean isIPA,PRM_Registration_Request__c regReq)
                businessEvent = System.label.PRM_Welcome_Email_New_Event;
                PRM_CreateAccountAndRelatedRecords.processRegistrationRecords(newAccount, newContact,null,regReqRecord) ;
            }
        }
        catch(Exception e){
            PRM_ErrorUtilityClass.logError(e);
            Database.rollback( sp );
        }    
    }
    
    
    public static void processRegistrationRecords(Account acc, Contact cont, Boolean isIPA ,PRM_Registration_Request__c regRequest)
    {
        //System.debug('@@@Request '+regRequest);
        //System.debug('@@@Agreements '+regRequest.PRM_Legal_Agreements__c);
        system.debug('Total queries executed after Account creation--->'+Limits.getQueries());
                    System.debug('## acc'+acc);
            System.debug('## con'+cont);
        System.debug('isIPA'+isIPA);

        if(acc != null && regRequest != null)
        {
             // Country Mapping for contact
                Map<string,string> countryMapContact = new map<string,string>();
                for(Core_Country_Code_Mapping__c allCountry : Core_Country_Code_Mapping__c.getAll().values()) {
                    countryMapContact.put(allCountry.Country_Code__c, allCountry.ISO_Code__c);
                }
            if(cont == null)
            {
                //##create Contact :
                Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
                cont = new Contact();
                system.debug('Total queries executed before language query--->'+Limits.getQueries());
                List<String> prefLanguageList= new List<String>();
                Schema.DescribeFieldResult fieldResult = Contact.Core_Preferred_Language__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : ple){
                    prefLanguageList.add(pickListVal.getValue());
                }     
                system.debug('Total queries executed after language query--->'+Limits.getQueries());
                cont.FirstName = regRequest.PRM_First_Name__c;
                cont.LastName = regRequest.PRM_Last_Name__c;
                cont.Email = regRequest.PRM_Email_ID__c;
                cont.Phone = regRequest.PRM_Person_Phone_Number__c;
                cont.Core_Job_Function_Code__c=regRequest.PRM_Job_Function__c;
                //to convert 2 digits of country into 3 digits
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
                if(regRequest.PRM_Preferred_Language__c != null && regRequest.PRM_Preferred_Language__c != '' &&
                   prefLanguageList != null && prefLanguageList.contains(regRequest.PRM_Preferred_Language__c)){
                       cont.Core_Preferred_Language__c =regRequest.PRM_Preferred_Language__c;
                       cont.Core_eRPM_Language_Code__c=regRequest.PRM_Preferred_Language__c;
                   }
                else{
                    cont.Core_Preferred_Language__c =System.Label.PRM_ENG;
                    cont.Core_eRPM_Language_Code__c=System.Label.PRM_ENG;
                }
                cont.Core_Login_Id__c= regRequest.PRM_Contact_Login_ID__c ; 
                cont.RecordTypeId = contactRecordType;
                cont.Core_Enterprise_Id__c=regRequest.PRM_Enterprise_ID__c;
                cont.Core_IPA_Partner_Role__c = regRequest.PRM_Partner_Role__c ; 
                cont.AccountId = acc.id; 
                insert cont;
                system.debug('Contact inserted-->'+cont);
                system.debug('Total queries executed after Contact creation--->'+Limits.getQueries());
            }
            else if(cont != null){
                String existingRole = Cont.Core_IPA_Partner_Role__c;
                if(Cont.Core_IPA_Partner_Role__c != null && String.isNotBlank(String.valueOf(Cont.Core_IPA_Partner_Role__c)))
                {
                    System.debug('test5555');
                    Set<String> existingROleSet = new Set<String>();
                    existingROleSet.addAll(existingRole.split(';'));
                    if(! existingROleSet.contains(regRequest.PRM_Partner_Role__c)) {Cont.Core_IPA_Partner_Role__c = existingRole+';'+regRequest.PRM_Partner_Role__c ; }
                }
                else {
                     System.debug('test6666');
                    cont.Core_IPA_Partner_Role__c = regRequest.PRM_Partner_Role__c ;
                   
                }
                System.debug('test777');
                cont.FirstName = regRequest.PRM_First_Name__c;
                cont.LastName = regRequest.PRM_Last_Name__c;
                cont.Core_Preferred_Language__c = regRequest.PRM_Preferred_Language__c; 
                cont.Phone = regRequest.PRM_Person_Phone_Number__c;
                cont.Core_Job_Function_Code__c = regRequest.PRM_Job_Function__c;
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
                update cont;
                system.debug('Contact updated-->'+cont);
                system.debug('Total queries executed after updating Contact--->'+Limits.getQueries());
            }
            
            //variable decleration : 
            Set<id> channelProgramIds = New Set<Id>();
            Set<String> legalAgrmntValues =new Set<String>();
            Set<String> subscriptionValues =new Set<String>();
            Map<String, String> legalAgrmntMap = new Map<String, String>();
            Map<String, PRM_Partner_Subscription__c> subscriptionMap = new Map<String, PRM_Partner_Subscription__c>();
            Map<String, PRM_ContactRelationships__c> contactRelationshipsById = New Map<String,PRM_ContactRelationships__c>();
            Boolean assignBenefit = false;
            
            //*************************************************************
            //##create Legal Agreement Association  
            if(isIPA == null || isIPA == false)
            {
                List<PRM_AccountLegalAgreemntAssociation__c> accLegalAgreementUpsertList = new List<PRM_AccountLegalAgreemntAssociation__c>();
                Map<String,PRM_AccountLegalAgreemntAssociation__c> existingALAMap = new Map<String,PRM_AccountLegalAgreemntAssociation__c>();
                if(String.isNotBlank(regRequest.PRM_Legal_Agreements__c)){
                    System.debug('@@ Legal Agreement '+regRequest.PRM_Legal_Agreements__c);
                    legalAgrmntValues.addall(regRequest.PRM_Legal_Agreements__c.split(';'));
                }
                
                if(!legalAgrmntValues.isEmpty() && legalAgrmntValues != null){
                    for(PRM_PartnerAgreement__c pa : [Select Id,Name from PRM_PartnerAgreement__c where Name IN : legalAgrmntValues]){
                        legalAgrmntMap.put(pa.Name,pa.id);
                    }
                }
                
                //check for duplicates:
                for(PRM_AccountLegalAgreemntAssociation__c ala : [Select id,PRM_Account_Id__c,PRM_Partner_Agreement_Id__c from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c =: acc.id and PRM_Partner_Agreement_Id__c in : legalAgrmntMap.values()])
                {
                    existingALAMap.put(String.valueOf(ala.PRM_Account_Id__c)+String.valueOf(ala.PRM_Partner_Agreement_Id__c),ala);
                }
                
                if(String.isNotBlank(regRequest.PRM_Legal_Agreements__c)){
                    for(String value : regRequest.PRM_Legal_Agreements__c.split(';')){
                        system.debug('@@Map=='+legalAgrmntMap+'@@Value=='+value);
                        if(legalAgrmntMap.containsKey(value)){
                            PRM_AccountLegalAgreemntAssociation__c acntLegalAgrAssoc = new PRM_AccountLegalAgreemntAssociation__c();
                            acntLegalAgrAssoc.PRM_Partner_Agreement_Id__c = legalAgrmntMap.get(value);
                            acntLegalAgrAssoc.PRM_Account_Id__c = acc.Id ;
                            acntLegalAgrAssoc.PRM_Contact__c = cont.id ;
                            if(existingALAMap != null && existingALAMap.get(String.valueOf(acc.id)+String.valueOf(legalAgrmntMap.get(value))) != null) {
                                acntLegalAgrAssoc = existingALAMap.get(String.valueOf(acc.id)+String.valueOf(legalAgrmntMap.get(value))); 
                            }
                            acntLegalAgrAssoc.PRM_Agreement_Sign_Dt__c = System.Now();
                            accLegalAgreementUpsertList.add(acntLegalAgrAssoc); 
                            system.debug('Record ==>'+acntLegalAgrAssoc);     
                        }
                    }
                }    
                if(accLegalAgreementUpsertList!= null && accLegalAgreementUpsertList.size()>0) { upsert accLegalAgreementUpsertList ; }
            }
            system.debug('Total queries executed after LA creation--->'+Limits.getQueries());
         
            //******************************************
            //##create Account Channel Membership
            if(String.isNotBlank(regRequest.PRM_Channel_Program__c)){
                channelProgramIds.add(regRequest.PRM_Channel_Program__c);
            }
            if(isIPA == null || isIPA == false)
            {
                //for new Account -- Approve scenario
                
                Map<String,PRM_AccountChannelMembership__c> existingACMMap = new Map<String,PRM_AccountChannelMembership__c>();
                List<PRM_AccountChannelMembership__c> accChannelMembershipListToUpsert = new List<PRM_AccountChannelMembership__c>();
                //check for duplicates :
                for(PRM_AccountChannelMembership__c acm : [Select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c =: acc.id and PRM_Channel_Program_Id__c =: regRequest.PRM_Channel_Program__c and PRM_Partner_Role__c =: regRequest.PRM_Partner_Role__c])
                {
                    existingACMMap.put(String.valueOf(acm.PRM_Account_Id__c)+String.valueOf(acm.PRM_Channel_Program_Id__c)+String.valueOf(acm.PRM_Partner_Role__c),acm);
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
                accChannelMembershipListToUpsert.add(accChannelMembership) ;
                system.debug('Not Inside'+accChannelMembershipListToUpsert);
                system.debug('Not Inside'+accChannelMembershipListToUpsert[0].PRM_Partner_Role__c);
                system.debug('Not Inside'+system.label.PRM_Service_Provider);
                if(accChannelMembershipListToUpsert != null && accChannelMembershipListToUpsert.size()>0 ){
                Database.UpsertResult[] results = Database.upsert(accChannelMembershipListToUpsert, PRM_AccountChannelMembership__c.Id);
                if(accChannelMembershipListToUpsert[0].PRM_Partner_Role__c == system.label.PRM_Service_Provider)
                {//upsert accChannelMembershipListToUpsert ; 
                    // US506328: Changes to insert into Core_Account_ERPM_Engagement__c -- Nishant Dhar
                    system.debug('Inside If Partner role for erpm engagement');
                    
                    List<Core_Account_ERPM_Engagement__c> coreAccErpmEng = new List<Core_Account_ERPM_Engagement__c>();
                    list<Core_ERPM_Engagement__c> coreErpmEng = [SELECT Id FROM Core_ERPM_Engagement__c WHERE Core_Technical_Name__c= :System.Label.PRM_CSPx2EngagementCode limit 1];
                    for(Integer index = 0, size = results.size(); index < size; index++) {
                        if(results[index].isSuccess()) {
                            if(results[index].isCreated()) {
                                Core_Account_ERPM_Engagement__c accEngs = new Core_Account_ERPM_Engagement__c();
                                accEngs.Core_Account_Id__c = (id)accChannelMembershipListToUpsert[index].PRM_Account_Id__c;
                                accEngs.Core_ERPM_Business_Attributes__c=System.Label.PRM_ERPM_Business_Attribute;
                                if (coreErpmEng!=null && coreErpmEng.size()>0){
                                accEngs.Core_ERPM_Engagement_Id__c = coreErpmEng[0].id;
                                    }
                                coreAccErpmEng.add(accEngs);
                                system.debug('Account Engagement to add list--> '+coreAccErpmEng);
                                System.debug(accChannelMembershipListToUpsert[index].id +' is been created');
                                System.debug('Account is --> '+accChannelMembershipListToUpsert[index].PRM_Account_Id__c);
                            } else {
                                System.debug(accChannelMembershipListToUpsert[index].id +' is been updated');
                            }
                        }
                    }
                    if(coreAccErpmEng!=null && coreAccErpmEng.size()>0){
                        system.debug('Total queries executed before COREACCENG creation--->'+Limits.getQueries());
                        insert coreAccErpmEng;
                        system.debug('Total queries after COREACCENG creation--->'+Limits.getQueries());
                        for ( Core_Account_ERPM_Engagement__c accErpmEng: coreAccErpmEng){
                            system.debug('Account Engagement inserted is --> '+accErpmEng.Id);
                        }
                    }
                }
            }
            }
            system.debug('Total queries executed after ACM creation--->'+Limits.getQueries());
            
            //***********************************************
            //##create Account Contact Relationship  
            Map<String,PRM_Account_Contact_Relationship__c> existingACRMap = new Map<String,PRM_Account_Contact_Relationship__c>();
            List<PRM_Account_Contact_Relationship__c> accConRelationshipsToUpsert = new List<PRM_Account_Contact_Relationship__c>();
            //check for duplicates
            for(PRM_Account_Contact_Relationship__c acr : [Select id,PRM_Account_Id__c,PRM_Contact_Id__c,PRM_Relationship_Id__c,PRM_Partner_Role__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c =: acc.id and PRM_Contact_Id__c =: cont.id])
            {
                existingACRMap.put(String.valueOf(acr.PRM_Account_Id__c)+String.valueOf(acr.PRM_Contact_Id__c)+String.valueOf(acr.PRM_Relationship_Id__c),acr) ;
            }
            system.debug(existingACRMap.size());
            if(!channelProgramIds.isEmpty() && channelProgramIds != null){
                for(PRM_ContactRelationships__c crel : [Select Id, Name, PRM_Channel_Program_Id__c From PRM_ContactRelationships__c Where PRM_Channel_Program_Id__c IN: channelProgramIds]){
                    contactRelationshipsById.put(crel.Name, crel);
                }
                system.debug('@@@contactRelationshipsById'+contactRelationshipsById); 
            }
            Set<String>relationshipToAssign = new Set<String>();
            if(isIPA != null && isIPA == true)
            {
                if(contactRelationshipsById.get(System.Label.PRM_WorksFor) != null) { relationshipToAssign.add(contactRelationshipsById.get(System.Label.PRM_WorksFor).Id); }
                // accConRel.PRM_Relationship_Id__c = contactRelationshipsById.get(System.Label.PRM_WorksFor).Id;
            }
            else{
                System.debug('@ regRequest.PRM_Partner_Relationship__c '+regRequest.PRM_Partner_Relationship__c);
                system.debug('coming here to create Account Contact relationship for member');
                if(String.isNotBlank(regRequest.PRM_Partner_Relationship__c)){
                    for(String value : regRequest.PRM_Partner_Relationship__c.split(';')){
                        if(!contactRelationshipsById.isEmpty() && contactRelationshipsById != null && contactRelationshipsById.containsKey(value) && contactRelationshipsById.get(value).Name.equalsIgnoreCase(value)){
                            relationshipToAssign.add(contactRelationshipsById.get(value).Id);
                            //accConRel.PRM_Relationship_Id__c = contactRelationshipsById.get(value).Id;
                        }
                    }
                } 
            }    
            system.debug('Relationship to assign-->'+relationshipToAssign);
            for(String crelID : relationshipToAssign)
            {
                PRM_Account_Contact_Relationship__c accConRel = New PRM_Account_Contact_Relationship__c();  
                accConRel.PRM_Relationship_Id__c = crelID ;
                accConRel.PRM_Account_Id__c= acc.id;
                accConRel.PRM_Contact_Id__c = cont.id ;
                // for setting email flag to true and status to complete
                accConRel.PRM_No_Email__c = true;
                accConRel.PRM_Status_Nm__c = 'Complete';
                //set below flag to false : for stoping trigger executioon
                accConRel.PRM_execute_trigger__c = false;    
                system.debug('existingACRMap-->'+existingACRMap);
                if(existingACRMap != null && existingACRMap.get(String.valueOf(accConRel.PRM_Account_Id__c)+String.valueOf(accConRel.PRM_Contact_Id__c)+String.valueOf(accConRel.PRM_Relationship_Id__c)) != null )
                {
                    accConRel = existingACRMap.get(String.valueOf(accConRel.PRM_Account_Id__c)+String.valueOf(accConRel.PRM_Contact_Id__c)+String.valueOf(accConRel.PRM_Relationship_Id__c));
                    system.debug('Existing record found'+accConRel);
                }
                accConRel.PRM_InActive_Ind__c= false;
                accConRelationshipsToUpsert.add(accConRel) ;
                system.debug('ACR List to upsert'+accConRelationshipsToUpsert);
            }    
            if(accConRelationshipsToUpsert!= null && accConRelationshipsToUpsert.size()>0) { upsert accConRelationshipsToUpsert ; }
            system.debug('Total queries executed after ACR creation--->'+Limits.getQueries());
            
            //Send email to primarycontact call
            system.debug('SendEmail To EndUser PrimaryContact Start Query count--->'+Limits.getQueries());
            if(accConRelationshipsToUpsert != null && accConRelationshipsToUpsert.size()>0){
                Map<id,PRM_Account_Contact_Relationship__c> mapOfACR = new Map<id,PRM_Account_Contact_Relationship__c>();
                for(PRM_Account_Contact_Relationship__c acr : accConRelationshipsToUpsert){
                    mapOfACR.put(acr.id,acr);               
                }
                List<String> partnerRoles = new List<String>();
                partnerRoles.add(regRequest.PRM_Partner_Role__c);
                System.debug('>>>>>> partnerRoles '+partnerRoles);
                System.debug('>>>>>> sendEmailToAllPrimaryContact started');
                PRM_EmailToPrimaryContact.sendEmailToAllPrimaryContact(null,mapOfACR,partnerRoles,true,false);
            }
            system.debug('SendEmail To EndUser PrimaryContact End Query count--->'+Limits.getQueries());            
            //***********************************************************
            //##create Contact Subscription Association   
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
            if(isIPA == null|| isIPA == false)
            {
                PRM_ProfileResponse.createResponse(regReqList,accountsToCreate,contactToInsert,false);
            }
            system.debug('Total queries executed before ProfileResponse creation--->'+Limits.getQueries());
            
            
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
            system.debug('Total queries before queueable class--->'+Limits.getQueries());
            System.enqueueJob( new PRM_RegReqProcessingQueueable(accountsToCreate,contactToInsert,assignBenefit,isAdminProcess,businessEvent,regRequest));
            system.debug('Total queries after queueable class--->'+Limits.getQueries());
        }  
    }   
    
    
    //Harshit added on 11/4/2019: to invoke EmailFramework for sending welcome email to newly added contacts
    public static void sendWelcomeEmailNotification(List<Contact> contactListToInsert, String businessEvent, PRM_Registration_Request__c regRequest)
    {
        system.debug('Total queries executed before Email Class--->'+Limits.getQueries());  
        for(Contact c : contactListToInsert) 
        {
            PRM_EmailUtility.EmailNotification objEmailNotif = new PRM_EmailUtility.EmailNotification();
            PRM_Email_Content_DataSetup__c emailSetup = PRM_Email_Content_DataSetup__c.getValues(regRequest.PRM_Partner_Role__c);            
            map<String, String> inputParameters = new map<String, String>();
            inputParameters.put('Account_ID',c.AccountId);            
            inputParameters.put('Registration_Request_ID',regRequest.Id);
            if(emailSetup != null){
                inputParameters.put('EmailContent_Setup',emailSetup.Id);    
            }
            objEmailNotif.InputParameters=inputParameters;
            objEmailNotif.BusinessEvent=businessEvent;
            objEmailNotif.Language = c.Core_Preferred_Language__c;
            objEmailNotif.ChannelProgram=System.Label.PRM_Intel_Partner_Alliance;
            //objEmailNotif.PartnerType=System.Label.PRM_CsP;
            objEmailNotif.EmailID= c.Email ;
            if(c != null && c.Core_Do_Not_Contact__c  == false)
            {
                PRM_EmailUtility.sendEmail(objEmailNotif);    
                linkEmailLogToContact(c.Email);
            }
        }
        system.debug('Total queries executed after sending Emails and updating logs--->'+Limits.getQueries());  
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
                userList = [Select id,Email,contactId from User where contactId=:conList[0].id];  
                for(PRM_EmailLog__c log : emailLogList)
                {
                    log.PRM_Contact__c = conList[0].id; 
                    if(userList!= null && userList.size()>0) { log.PRM_User__c = userList[0].id ; }  
                }
                try{Database.update(emailLogList);
                   }
                catch(Exception e){PRM_ErrorUtilityClass.logError(e);}    
            }
        }
    }
    
    public static void approveACM(List<PRM_AccountChannelMembership__c> acmList){
        if(acmList.size() > 0){
            List<PRM_AccountChannelMembership__c> acmListUpdate = new List<PRM_AccountChannelMembership__c>();
            for(PRM_AccountChannelMembership__c acm : acmList){
                    if(acm.PRM_Status_Nm__c != 'Approved'){
                        acm.PRM_Status_Nm__c = 'Approved';
                        acmListUpdate.add(acm);
                    } 
                 }
                 if(acmListUpdate.size() > 0){
                    update acmListUpdate;
                 }
         }
    }
    
}