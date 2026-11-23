/****************************************************************************************************************************************
* Class Name  : Core_MDF_PartnerNodeUserMapping_Test
* Version     : 1.0 
* Created Date: 07-31-2018
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - JV                    07/31/2018                    Created to test Partner User Mapping functionality.
* Accenture - KK                    12/12/2019                    Refactored as per new changes in PNUM Batch.
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_PartnerNodeUserMapping_Test {
    //Test method for data setup
    @TestSetup static void setUpData(){
        
        //Test.startTest();
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
        List<ChannelProgram> cpList = new List<ChannelProgram>();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
        cpList.add(cp);
        ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', false);
        cpList.add(retailCp);
        Database.insert(cpList);
        List<Account> accList = new List<Account>();
        List<Account> updateAccList = new List<Account>();
        
        //Creating Intel Account with utility class
        Account accountRecord1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        accountRecord1.Core_Geo__c = 'APJ';
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
        
        Account intelRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Test Account', retailCp.Id,
                                                                          Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        intelRetail.Core_MDF_Parent_Fund_Account__c = accountRecord1.Id;
        intelRetail.Core_MDF_CoMarketing_Ultimate_Account__c = accountRecord1.Id;
        intelRetail.Core_Geo__c = 'APJ';
        accList.add(intelRetail);
        
        Database.insert(accList);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        PermissionSet retailClaimSubmitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Retail_Claim_Submitter' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter'];
        
        //Creating Contact for Partner User
        List<Contact> contactList = new List<Contact>();
        List<Contact> contactUpdateList = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(accountRecord1.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(accountRecord1.Id,false);
        contactList.add(conRecord1);
        contactList.add(conRecord2);
        
        Contact externalUser = Core_MDF_CCP_TestDataUtility.createContact(accountRecord1.Id,false);
        externalUser.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
        contactList.add(externalUser);
        
        Contact externalUser1 = Core_MDF_CCP_TestDataUtility.createContact(accountRecord1.Id,false);
        externalUser1.RecordTypeId = Core_MDF_CCP_TestDataUtility.Intel_Contact_Record_Type;
        contactList.add(externalUser1);
        
        Database.insert(contactList);
        
        externalUser.Core_Audience_List__c = 'RMF User;RMF External Claim Submitter';
        externalUser1.Core_Audience_List__c = 'RMF User;RMF External Claim Submitter';
        contactUpdateList.add(externalUser);
        contactUpdateList.add(externalUser1);
        database.update(contactUpdateList); 
        
        //Creating Case on the Account
        Case case1 = new Case(AccountId=accountRecord.Id);
        Database.insert(case1);
        
        //This user is created with system admin permission in Utility Class 
        List<User> userList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        database.insert(usr);
        
        System.runAs(usr){
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
            
            User extUser = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUser.LastName = 'Claim Submitter';
            extUser.ProfileId = profileId;
            extUser.email = 'xyz@mail.com';
            extUser.ContactId = externalUser.Id;
            extUser.isActive = true;
            userList.add(extUser);
            
            User extUser1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUser1.LastName = 'Test Claim Submitter 1';
            extUser1.ProfileId = profileId;
            extUser1.email = 'xyzabc@mail.com';
            extUser1.ContactId = externalUser1.Id;
            extUser1.isActive = true;
            userList.add(extUser1);
            
            Database.insert(userList);
            
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        
            //Create PMB for the above Account 
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,accountRecord.Id,cp.Id,123456,System.today(),Date.newInstance(System.today().year(),12,31),true);
            
            //Create PFA records for the above accounts :
            PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('TestPFA',pmbRecord, accountRecord, 1234,true);
        
            //Creating Account User Record by System Admin
            
            List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
            PermissionSetAssignment psa1 = new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = usr2.Id);
            PermissionSetAssignment psa2 = new PermissionSetAssignment(PermissionSetId = retailClaimSubmitterPS.Id, AssigneeId = extUser.Id);
            PermissionSetAssignment psa3 = new PermissionSetAssignment(PermissionSetId = retailClaimSubmitterPS.Id, AssigneeId = extUser1.Id);
            permissionSetAssignmentList.add(psa1);
            permissionSetAssignmentList.add(psa2);
            permissionSetAssignmentList.add(psa3);
            insert permissionSetAssignmentList;    
            
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accountRecord.Id,usr1.Id,true);
        
            //Creating Campaign Record 
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), Date.newInstance(System.today().year(),12,31), 10000, 'Consumer Chromebook', accountRecord.Id, '2-in-1', true); 
            
            //Creating Bank Record
            Core_MDF_Bank__c testBank1 = Core_MDF_CCP_TestDataUtility.createBank(accountRecord1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1234567891');
            //testBank1.Core_MDF_Bank_Status__c = 'Active';
            //Database.update(testBank1);
            
            Test.startTest();
            
            //Creating Activity Record
            PartnerFundRequest pfr1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                            String.valueof(accountRecord.id),pfaRecord,pmbRecord,'INDIA',
                                                                                            'Consumer',
                                                                                            'Desktop',
                                                                                            'Intel® Core™ i7 Processor',
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
            pfr1.Amount = 0;
            Database.insert(pfr1);
            
            //Creating Account Bank Mapping Record
            //List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
            //abmList.add(new Core_MDF_Account_Bank_Mapping__c(Core_MDF_Bank__c = testBank1.Id, Core_MDF_Account__c = accountRecord.Id));
            //abmList.add(new Core_MDF_Account_Bank_Mapping__c(Core_MDF_Bank__c = testBank1.Id, Core_MDF_Account__c = intelRetail.Id));
            //insert abmList;
            
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accountRecord.Id,testBank1.Id,true);
            
            //Creating Claim Record
            PartnerFundClaim pfc1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr1.Id, System.today(), System.today(), 50.00, System.today(),testbank1.Id, true);
            //Database.insert(pfc1);
             Test.stopTest();
            //Creating Adjustment Request Record

            
            //Creating Payment Record
            Core_MDF_Payment__c dummyPaymentRecord = new Core_MDF_Payment__c();
            Database.insert(dummyPaymentRecord);
            
            pfc1.Core_MDF_Payment_Id__c = dummyPaymentRecord.Id;
            Database.update(pfc1);
        
            //Creating Payment Run Record
            Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
            payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(1);
            payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
            payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
            Database.insert(payRunRecord); 
           
        }
    }
    
    //Test method to test Create, Update & Delete PNUM Records
    @isTest static void createanddeletePNUMRecords(){
        
        User systemAdminRecord = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User partnerUserRec1 = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        Test.startTest();
        User partnerUserRec2 = [SELECT Id,Email from User where Email='test2@example.com' limit 1];
        Account accRec1 = [SELECT Id from Account where Name='Test Account 1' limit 1];
        Account accRec2 = [SELECT Id from Account where Name='Test Account 2' limit 1];
        /*PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter'];
        PermissionSetAssignment psaRecord = new PermissionSetAssignment();
        psaRecord.AssigneeId = partnerUserRec2.Id;
        psaRecord.PermissionSetId = ps.Id;
        insert psaRecord;*/
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_Account__r.name,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c LIMIT 1];
        System.runAs(systemAdminRecord){
            //Test.startTest();
            
            //Creating Adjustment Request Record
            Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
            PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim where Title ='Test Claim'];
            //adjReq.Core_MDF_Type_Txt__c ='Negative Claim';
            adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id;
            adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            adjReq.Core_MDF_Amount_Amt__c = 10; 
            adjReq.Core_MDF_Comments_Txt__c = 'Test';
            Database.insert(adjReq);
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
        /*PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter'];
        PermissionSetAssignment psaRecord = new PermissionSetAssignment();
        psaRecord.AssigneeId = partnerUserRecord.Id;
        psaRecord.PermissionSetId = ps.Id;
        insert psaRecord;*/
        Test.startTest();
        User systemAdminRecord = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c limit 1];                                             
        List<Core_MDF_Partner_Node_User_Mapping__c> deleteRecordList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        
        //Test method to fetch and delete the created PNUM Records
        Set<Id> accIdset = new Set<Id>();
        for (Account accRecord : [SELECT Id from Account limit 1000]){
            accIdset.add(accRecord.Id); 
        }
        //Test.startTest();
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
    
    @isTest
    static void testRetailSharing(){
        
        User systemAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        ChannelProgram retailCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds' limit 1];
        
        test.startTest();
        Account accountRecord1 = [SELECT Id from Account where Name='Test Account' limit 1];
        
        Account retailAccount = [SELECT Id, Name FROM Account WHERE Name = 'Retail Test Account' limit 1];
        
        User claimSubmitter = [SELECT Id,Email from User where Email='xyz@mail.com' limit 1];
        
        Core_MDF_Bank__c retailBank = Core_MDF_CCP_TestDataUtility.createBank(accountRecord1.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1234567892');
        retailBank.Core_MDF_Intel_Company_Code__c = '150';
        retailBank.Core_MDF_Currency_cd__c = 'USD';
        retailBank.Core_MDF_Tax_codes_cd__c = 'I0';
        retailBank.Core_MDF_Bank_Status__c = 'Active';
        database.insert(retailBank);
        
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(retailAccount.Id,retailBank.Id,false);
        abm.Core_MDF_Active_ind__c = true;
        insert abm;
        
        system.runAs(systemAdminUser){
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                        'Retail Marketing Funds',
                                                                        System.today() - 45, System.today().addYears(1), 2000, 
                                                                        'Instore innovation', retailAccount.Id,'2-in-1', false);
            camp.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            database.insert(camp);
            
            PartnerFundRequest retailPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                                               Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                               string.valueof(retailAccount.id),NULL,NULL,
                                                                                                               'AFGHANISTAN','All','Workstation',
                                                                                                               'EVO','Broadcast',
                                                                                                               'Podcast','Draft',false);
            
            retailPfr.Title ='Retail MDF Activity';
            retailPfr.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            retailPfr.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            retailPfr.Core_MDF_Start_Date__c = System.today() - 40;
            retailPfr.Core_MDF_End_Date__c  = System.today() - 40;
            retailPfr.RequestedAmount =1000;
            retailPfr.Amount=1000;
            retailPfr.Core_MDF_Country__c ='AFGHANISTAN';
            retailPfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            retailPfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            retailPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            retailPfr.Core_MDF_Reimbursement_Rate_pct__c='100%';
            database.insert(retailPfr);
            
            Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            
            Core_MDF_Escalation__c esc = new Core_MDF_Escalation__c();
            esc.Core_MDF_Escalation_Status_nm__c='Pending Review';
            esc.Core_MDF_Escalation_Name_txt__c='Test1';
            esc.Core_MDF_Total_Dollar_Impact_amt__c= 56;
            esc.Core_MDF_Root_Cause_nm__c = 'Tools and Systems';
            esc.Core_MDF_Co_Marketing_Activity_id__c = retailPfr.Id;
            esc.Core_MDF_Channel_Program_id__c = retailCp.Id;
            esc.recordtypeid= claimRecType;
            Database.insert(esc);
            
            
            
            Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(retailAccount.Id,claimSubmitter.Id,true);

            List<Core_MDF_Escalation__Share> escShareList = [SELECT Id,ParentId, UserOrGroupId 
                                                             FROM Core_MDF_Escalation__Share 
                                                             WHERE ParentId =: esc.Id AND
                                                             UserOrGroupId =: claimSubmitter.Id];
            
            System.assert(escShareList != NULL);
            
            database.delete(pnum);
            test.stopTest();
        }
    }
    
    @isTest
    static void testRetailCampaignSharing(){
        
        User systemAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        ChannelProgram retailCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds' limit 1];
        
        test.startTest();
        Account accountRecord1 = [SELECT Id from Account where Name='Test Account' limit 1];
        
        Account retailVirtualAccount = [SELECT Id, Name FROM Account WHERE Name = 'Retail Test Account' limit 1];
               
        Account retailAPJAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Test Account1', retailCp.Id,
                                                                          Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        retailAPJAccount.Core_MDF_Parent_Fund_Account__c = retailVirtualAccount.Id;
        retailAPJAccount.Core_MDF_CoMarketing_Ultimate_Account__c = accountRecord1.Id;
        retailAPJAccount.Core_MDF_Active_Ind__c = true;
        retailAPJAccount.Core_Geo__c = 'APJ';
        Database.insert(retailAPJAccount);
        
        Account retailINDAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Test Account2', retailCp.Id,
                                                                          Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        retailINDAccount.Core_MDF_Parent_Fund_Account__c = retailAPJAccount.Id;
        retailINDAccount.Core_MDF_CoMarketing_Ultimate_Account__c = accountRecord1.Id;
        retailINDAccount.Core_MDF_Active_Ind__c = true;
        retailINDAccount.Core_Geo__c = 'APJ';
        Database.insert(retailINDAccount);

        
        Account retailAccount1 = [SELECT Id, Name, Core_MDF_Parent_Fund_Account__c FROM Account WHERE Name = 'Retail Test Account1' limit 1];
        Account retailAccount2 = [SELECT Id, Name, Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c FROM Account WHERE Name = 'Retail Test Account2' limit 1];
        System.debug('retailAccount:' + retailVirtualAccount.Id);
        System.debug('retailAccount1.Id:' + retailAccount1.Id);
        System.debug('retailAccount1:' + retailAccount1.Core_MDF_Parent_Fund_Account__c);
        System.debug('retailAccount2:' + retailAccount2.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c);
        
        User claimSubmitter = [SELECT Id,Email from User where Email='xyz@mail.com' limit 1];
        User claimSubmitter1 = [SELECT Id,Email from User where Email='xyzabc@mail.com' limit 1];
        
        
        system.runAs(systemAdminUser){
            List<Campaign> cmpList = new List<Campaign>();
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                        'Retail Marketing Funds',
                                                                        System.today() - 45, System.today().addYears(1), 2000, 
                                                                        'Instore innovation', retailVirtualAccount.Id,'2-in-1', false);
            camp.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            cmpList.add(camp);
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp1','Gaming','Athena', 
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                        'Retail Marketing Funds',
                                                                        System.today() - 45, System.today().addYears(1), 2000, 
                                                                        'Instore innovation', retailAccount1.Id,'2-in-1', false);
            camp1.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            cmpList.add(camp1);
            
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp2','Gaming','Athena', 
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                        'Retail Marketing Funds',
                                                                        System.today() - 45, System.today().addYears(1), 2000, 
                                                                        'Instore innovation', retailAccount2.Id,'2-in-1', false);
            camp2.Core_MDF_Budget_Type_txt__c ='Retail MDF';
            cmpList.add(camp2);
            
            database.insert(cmpList);
            
            Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(retailVirtualAccount.Id,claimSubmitter.Id,true);
            Core_MDF_Partner_Node_User_Mapping__c pnum1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(retailVirtualAccount.Id,claimSubmitter1.Id,true);          
            
            List<CampaignShare> cmpShareList = [SELECT Id, CampaignId, UserOrGroupId
                                                             FROM CampaignShare 
                                                             WHERE CampaignId =: camp.Id AND
                                                             UserOrGroupId =: claimSubmitter.Id];

            
            
            System.assert(cmpShareList != NULL);
            
            database.delete(pnum);
            test.stopTest();
        }
    }
    
    //Test method for Delete Account User scenario
    @isTest static void testmfetchPartnerNodeUserMappingException(){
        
        User partnerUserRecord = [SELECT Id,Email from User where Email='test2@example.com' limit 1];
        Account accountRecord1 = [SELECT Id from Account where Name='Test Account 1' limit 1];        
        Test.startTest();
        User systemAdminRecord = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c limit 1];                                             
        List<Core_MDF_Partner_Node_User_Mapping__c> deleteRecordList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        
        //Test method to fetch and delete the created PNUM Records
        Set<Id> accIdset = new Set<Id>();
        for (Account accRecord : [SELECT Id from Account limit 2]){
            //accRecord.Id = '001g0000025ts1CXXX'; 
            accIdset.add(accRecord.Id); 
        }
        try{        
        List<Id> accIdList = new List<Id>();        
        Core_MDF_PNUMappingServiceHandler.mfetchPartnerNodeUserMapping(accIdList);
        }catch(Exception e){
            System.debug('' + e.getMessage());
            System.assertNotEquals(NULL,e);
        }    
        Test.stopTest();       
        
        
    }
    
    
}