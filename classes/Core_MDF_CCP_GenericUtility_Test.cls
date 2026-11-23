/****************************************************************************************************************************************
* Class Name  : Core_MDF_CCP_GenericUtility_Test
* Version     : 1.0 
* Created Date: 20-Nov-2019
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture - Vaishali                  20-Nov-2019               Created to cover Generic Utility class
NP(11630236)					   28-Feb-2020					Added source for PGM insert
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public without sharing class Core_MDF_CCP_GenericUtility_Test {
    
    @TestSetup static void setUpData(){
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc1.Core_MDF_CoMarketingActive__c = true;
        insert acc1;
        
        List<Contact> listContact = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        
        listContact.add(conRecord1);
        listContact.add(conRecord2);
        
        Database.insert(listContact);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        
        List<User> listUser = new List<User>();
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = listContact[0].Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        listUser.add(usr1);
        //Database.insert(usr1);
        
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test123@example.com';
        usr2.ContactId = listContact[1].Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        listUser.add(usr2);
        //Database.insert(usr2);
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email = 'sysadmin@example.com';
        listUser.add(usr3);
        //Database.insert(listUser);
        Database.insert(listUser);        
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 3', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        List<Account> accList = new List<Account>();
        accList.add(acc2);
        accList.add(acc3);
        insert accList;

        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today() -20,System.today().addDays(40), false);
        budget.IsIgnoreValidation = true;
        //update budget;
        PartnerMarketingBudget budget2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New 2',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc3.Id,cp.Id,200000,System.today() -20,System.today().addDays(40), false);
        budget2.IsIgnoreValidation = true;
        List<PartnerMarketingBudget> pmbList = new List<PartnerMarketingBudget>();
        pmbList.add(budget);
        pmbList.add(budget2);

        insert pmbList;
        
        //List<Group> groupList = new List<Group>();
        //Create CCF APJ Group
        Group ccfgrp = new Group();
        ccfgrp.Name = 'Core CCP CCF APJ Internal';
        ccfgrp.DeveloperName = 'Core_CCP_CCF_APJ_Internal';
        insert ccfgrp;

        //Create CCF WW Group
        Group ccfgrp2 = new Group();
        ccfgrp2.Name = 'Core CCP CCF Internal WW';
        ccfgrp2.DeveloperName = 'Core_CCP_CCF_Internal_WW';
        insert ccfgrp2;

        //Create CCF APJ SA Group
        Group ccfgrp3 = new Group();
        ccfgrp3.Name = 'Core CCP CCF APJ SA Internal';
        ccfgrp3.DeveloperName = 'Core_CCP_CCF_APJ_SA_Internal';
        insert ccfgrp3;

        Test.startTest();
        List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
        //Create PGM
        Core_MDF_Partner_Group_Mapping__c ccfPgm = new Core_MDF_Partner_Group_Mapping__c();
        ccfPgm.Core_MDF_Account__c = acc1.Id;
        ccfPgm.Core_MDF_Group_Name__c = 'Core_CCP_CCF_APJ_Internal';
        ccfPgm.Core_MDF_Type_of_Access__c = 'Internal';
        ccfPgm.Core_MDF_Group_Id__c = ccfgrp.Id;
        ccfPgm.Core_MDF_Channel_Program__c = cp.Id;
        ccfPgm.Core_MDF_Region_cd__c = 'APJ';
        ccfPgm.Core_MDF_AccountIdGroupName__c = acc1.Id + '_Core_CCP_CCF_APJ_Internal';
        ccfPgm.Core_MDF_Source_Txt__c = 'Test';
        pgmList.add(ccfPgm);

        Core_MDF_Partner_Group_Mapping__c ccfPgm2 = new Core_MDF_Partner_Group_Mapping__c();
        ccfPgm2.Core_MDF_Account__c = acc1.Id;
        ccfPgm2.Core_MDF_Group_Name__c = 'Core_CCP_CCF_Internal_WW';
        ccfPgm2.Core_MDF_Type_of_Access__c = 'Internal';
        ccfPgm2.Core_MDF_Group_Id__c = ccfgrp2.Id;
        ccfPgm2.Core_MDF_Channel_Program__c = cp.Id;
        ccfPgm2.Core_MDF_Region_cd__c = 'WW';
        ccfPgm2.Core_MDF_AccountIdGroupName__c = acc1.Id + '_Core_CCP_CCF_Internal_WW';
        ccfPgm2.Core_MDF_Source_Txt__c = 'Test';
        pgmList.add(ccfPgm2);

        Core_MDF_Partner_Group_Mapping__c ccfPgm3 = new Core_MDF_Partner_Group_Mapping__c();
        ccfPgm3.Core_MDF_Account__c = acc1.Id;
        ccfPgm3.Core_MDF_Group_Name__c = 'Core_CCP_CCF_APJ_SA_Internal';
        ccfPgm3.Core_MDF_Type_of_Access__c = 'Internal';
        ccfPgm3.Core_MDF_Group_Id__c = ccfgrp3.Id;
        ccfPgm3.Core_MDF_Channel_Program__c = cp.Id;
        ccfPgm3.Core_MDF_Region_cd__c = 'APJ';
        ccfPgm3.Core_MDF_Sub_Region_cd__c = 'SA';
        ccfPgm3.Core_MDF_AccountIdGroupName__c = acc1.Id + '_Core_CCP_CCF_APJ_SA_Internal';
        ccfPgm3.Core_MDF_Source_Txt__c = 'Test';
        pgmList.add(ccfPgm3);

        insert pgmList;
        

        List<PartnerFundAllocation> pfaList = new List<PartnerFundAllocation>();
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,false);
        PartnerFundAllocation allocation2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget2,acc3,200.0,false);
        pfaList.add(allocation);
        pfaList.add(allocation2);

        insert pfaList;
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', true); 
        
        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Broadcast',
                                                                                                          'Podcast',
                                                                                                          'Draft',
                                                                                                          false);
        testPartnerFundRequest.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest.Core_MDF_End_Date__c  = system.today();
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        insert testPartnerFundRequest;
		Test.stopTest();
        /* testPartnerFundRequest.ChannelPartnerId = acc3.Id;
        update testPartnerFundRequest; */
        //inserting currency data
        
        
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        listBank.add(bank);
        Database.insert(listBank);
        
        Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
    }
    @isTest static void createPFR(){
        Test.startTest();
        Account accRecord = [SELECT Id, Name
                             FROM Account
                             WHERE Name = 'Test Acc New 3'];
        PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
        pfr.ChannelPartnerId = accRecord.Id;
        update pfr;
        Map<String,Core_MDF_CCP_GenericUtility.countryGeoSubGeoWrapper> wrapperMapOfCountryRegion = Core_MDF_CCP_GenericUtility.getCountryGeoMap();
        System.assert(wrapperMapOfCountryRegion.size() > 0);
        Test.stopTest();
    }
    
    
}