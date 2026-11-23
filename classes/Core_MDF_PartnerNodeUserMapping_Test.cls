/****************************************************************************************************************************************
* Class Name  : Core_MDF_PartnerNodeUserMapping_Test
* Version     : 1.0 
* Created Date: 07-31-2018
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV                    07/31/2018                    Created to test Partner User Mapping functionality.
* Accenture - KK					12/12/2019					  Refactored as per new changes in PNUM Batch.
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_PartnerNodeUserMapping_Test {
    //Test method for data setup
    @TestSetup static void setUpData(){
        
        Test.startTest();
        //Create Exchange rates records
        List<Core_MDF_Currency_Exchange_Rates__c> exchangeRecList = new List<Core_MDF_Currency_Exchange_Rates__c>();
        Core_MDF_Currency_Exchange_Rates__c exchangeRec1 = new Core_MDF_Currency_Exchange_Rates__c();
        exchangeRec1.Name= 'INR';
        exchangeRec1.Core_MDF_Exchange_Rate__c = 1;
        exchangeRec1.Core_MDF_Market_Date__c =System.today();
        exchangeRec1.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        exchangeRec1.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        exchangeRecList.add(exchangeRec1); 
        
        Core_MDF_Currency_Exchange_Rates__c exchangeRec2 = new Core_MDF_Currency_Exchange_Rates__c();
        exchangeRec2.Name= 'USD';
        exchangeRec2.Core_MDF_Exchange_Rate__c = 1;
        exchangeRec2.Core_MDF_Market_Date__c =System.today();
        exchangeRec2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        exchangeRec2.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        exchangeRecList.add(exchangeRec2);
        database.insert(exchangeRecList);
        
        //Creating Program with utility class        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        List<Account> accList = new List<Account>();
        List<Account> updateAccList = new List<Account>();
        
        //Creating Intel Account with utility class
        Account accountRecord1 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account ', cp.Id,Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);   
        accountRecord1.BillingCity = 'Test City';         
        accountRecord1.BillingCountry= 'AUS';
        accountRecord1.BillingStreet= 'Test Street';
        Database.insert(accountRecord1); 
        
        //Creating Co-marketing Account with utility class
        Account accountRecord = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 1', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        accountRecord.Core_MDF_Parent_Fund_Account__c = accountRecord1.Id;
        accountRecord.Core_MDF_CoMarketingActive__c = true;
        accList.add(accountRecord);
        
        Account accountRecord2 = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        accountRecord2.Core_MDF_Parent_Fund_Account__c = accountRecord1.Id;
        accountRecord2.Core_MDF_CoMarketingActive__c = true;
        accList.add(accountRecord2);
        
        Database.insert(accList);
        
        //Marking it as Partner User, because field is not writable while creating.
        accountRecord1.IsPartner = true;
        updateAccList.add(accountRecord1);
        accountRecord.IsPartner = true;
        updateAccList.add(accountRecord);
        accountRecord2.IsPartner = true;
        updateAccList.add(accountRecord2);
        
        Database.update(updateAccList);
        
        //Creating Contact for Partner User
        List<Contact> contactList = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(accountRecord1.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(accountRecord1.Id,false);
        contactList.add(conRecord1);
        contactList.add(conRecord2);
        Database.insert(contactList);
        
        //Creating Case on the Account
        Case case1 = new Case(AccountId=accountRecord.Id);
        Database.insert(case1);
        
        //This user is created with system admin permission in Utility Class 
        List<User> userList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        userList.add(usr1);
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test2@example.com';
        usr2.ContactId = conRecord2.Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        userList.add(usr2);
        
        Database.insert(userList);
        
        Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        
        //Create PMB for the above Account 
        PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,accountRecord.Id,cp.Id,123456,System.today(),Date.newInstance(System.today().year(),12,31),false);
        pmbRecord.IsIgnoreValidation = true;
        insert pmbRecord;
        
        //Create PFA records for the above accounts :
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, accountRecord, 1234,true);
        
        //Creating Account User Record by System Admin
        System.runAs(usr){
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accountRecord.Id,usr1.Id,true);
        }
        
        //Creating Campaign Record 
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), Date.newInstance(System.today().year(),12,31), 10000, 'Consumer Chromebook', accountRecord.Id, '2-in-1', true); 
        
        //Creating Activity Record
        PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                        Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                        String.valueof(accountRecord.id),pfaRecord,pmbRecord,'INDIA',
                                                                                        'Consumer',
                                                                                        'Desktop',
                                                                                        'Intel® Core™ i7+ Processor',
                                                                                        'Broadcast',
                                                                                        'Podcast',
                                                                                        'Draft',
                                                                                        false);
        pfr1.Title = 'Test Activity1';
        pfr1.Core_MDF_Activity_Description__c = 'Test Activity1';
        pfr1.Core_MDF_Start_Date__c = System.today();
        pfr1.Core_MDF_End_Date__c = System.today();
        pfr1.RequestedAmount = 2000;
        pfr1.Core_MDF_pagespayingfor__c = 15;
        Database.insert(pfr1);
        Test.stopTest();
        
        //Creating Bank Record
        Core_MDF_Bank__c testBank1 = Core_MDF_CCP_TestDataUtility.createBank(accountRecord1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1234567891');
        testBank1.Core_MDF_Bank_Status__c = 'Active';
        Database.update(testBank1);
        
        //Creating Payment Record
        Core_MDF_Payment__c dummyPaymentRecord = new Core_MDF_Payment__c();
        Database.insert(dummyPaymentRecord);
        
        //Creating Claim Record
        PartnerFundClaim pfc1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr1.Id, System.today(), System.today(), 50.00, System.today(),testbank1.Id, false);
        Database.insert(pfc1);
        
        //Creating Adjustment Request Record
        Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
        PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim where Title ='Test Claim'];
        claim.Core_MDF_Type_Txt__c ='Negative Claim';
        adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id;
        adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
        adjReq.Core_MDF_Amount_Amt__c = 10; 
        adjReq.Core_MDF_Comments_Txt__c = 'Test';
        Database.insert(adjReq); 
        
        pfc1.Core_MDF_Payment_Id__c = dummyPaymentRecord.Id;
        Database.update(pfc1);
        
        //Creating Account Bank Mapping Record
        List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        abmList.add(new Core_MDF_Account_Bank_Mapping__c(Core_MDF_Bank__c = testBank1.Id, Core_MDF_Account__c = accountRecord.Id));
        insert abmList;
        
        //Creating Payment Run Record
        Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
        payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
        payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
        payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
        Database.insert(payRunRecord);  
    }
    
    //Test method to test Create, Update & Delete PNUM Records
    @isTest static void createanddeletePNUMRecords(){
        
        User systemAdminRecord = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User partnerUserRec1 = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        User partnerUserRec2 = [SELECT Id,Email from User where Email='test2@example.com' limit 1];
        Account accRec1 = [SELECT Id from Account where Name='Test Account 1' limit 1];
        Account accRec2 = [SELECT Id from Account where Name='Test Account 2' limit 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter'];
        PermissionSetAssignment psaRecord = new PermissionSetAssignment();
        psaRecord.AssigneeId = partnerUserRec2.Id;
        psaRecord.PermissionSetId = ps.Id;
        insert psaRecord;
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_Account__r.name,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c LIMIT 1];
        System.runAs(systemAdminRecord){
            Test.startTest();
            //Create a Partner Node User Mapping with the above created Account
            try{
                AccountShare accshare = [Select UserOrGroupId From AccountShare WHERE AccountId =:accRec1.Id AND UserOrGroupId =:partnerUserRec1.Id  limit 1];
                System.assertNotEquals(accshare.Id,NUll);
                
                pnumRecord.Core_MDF_Account__c = accRec2.Id;
                Database.update(pnumRecord);
                
                pnumRecord.Core_MDF_Account__c = accRec1.Id;
                Database.update(pnumRecord);
                
                List<Core_MDF_Partner_Node_User_Mapping__c> pnumRecList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
                Core_MDF_Partner_Node_User_Mapping__c pnumRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRec2.Id,partnerUserRec1.Id,false);
                Core_MDF_Partner_Node_User_Mapping__c pnumRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRec1.Id,partnerUserRec2.Id,false);
                pnumRecList.add(pnumRecord2);
                pnumRecList.add(pnumRecord1);
                Database.insert(pnumRecList);
                
                System.assertNotEquals(pnumRecord1,null);
                Core_MDF_Partner_Node_User_Mapping__c pnumDuplicateRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRec2.Id,partnerUserRec1.Id,false);
                Database.SaveResult sr = Database.insert(pnumDuplicateRecord,false);
                Database.delete(pnumRecord);
            }catch(Exception e){
                System.debug(''+e.getMessage());
            }
            Test.stopTest();
        }
    }
    
    //Test method for Delete Account User scenario
    @isTest static void testDeleteShareRecords(){
        
        User partnerUserRecord = [SELECT Id,Email from User where Email='test2@example.com' limit 1];
        Account accountRecord1 = [SELECT Id from Account where Name='Test Account 1' limit 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter'];
        PermissionSetAssignment psaRecord = new PermissionSetAssignment();
        psaRecord.AssigneeId = partnerUserRecord.Id;
        psaRecord.PermissionSetId = ps.Id;
        insert psaRecord;
        
        User systemAdminRecord = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c limit 1];                                             
        List<Core_MDF_Partner_Node_User_Mapping__c> deleteRecordList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        
        //Test method to fetch and delete the created PNUM Records
        Set<Id> accIdset = new Set<Id>();
        for (Account accRecord : [SELECT Id from Account limit 1000]){
            accIdset.add(accRecord.Id); 
        }
        Test.startTest();
        List<Id> accIdList = new List<Id>(accIdset);
        Core_MDF_PNUMappingServiceHandler.mfetchPartnerNodeUserMapping(accIdList);
        
        System.runAs(systemAdminRecord){
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accountRecord1.Id,partnerUserRecord.Id,true);
            deleteRecordList.add(pnumRecord);
            deleteRecordList.add(pnumRecord1);
            System.assertNotEquals(pnumRecord1,null);
        }
        
        try{
            Database.delete(deleteRecordList);
            AccountShare accshare = [Select UserOrGroupId From AccountShare WHERE AccountId =:pnumRecord.Core_MDF_Account__c AND UserOrGroupId =:pnumRecord.Core_MDF_User__c  limit 1];
            System.assertEquals(accshare.Id,NUll);
        }catch(Exception e){
            System.debug('' + e.getMessage());
        }    
        Test.stopTest();
    }
    
    //Test method for exception scenario where user is empty
    @isTest static void createException(){
        User systemAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        Test.startTest();
        System.runAs(systemAdminUser){
            //Create a Partner Node User Mapping with the above created Account
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c LIMIT 1];
            pnumRecord.Core_MDF_User__c = NULL;
            
            try{
                Database.update(pnumRecord, false);
                System.assertEquals(pnumRecord.Core_MDF_User__c,NULL);
            }catch(Exception e){
                System.debug('' + e.getMessage());
            }
        }
        Test.stopTest();
    }
}