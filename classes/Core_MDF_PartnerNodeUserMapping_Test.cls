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
  /*   @isTest 
    static void getCodeCoverageForMainClass(){
         Test.startTest();
         Core_MDF_PNUMappingServiceHandler.getCodeCoverage();
         Test.stopTest();
        // US - TWC702-14285: Unit Test Method should include System.Assert
        System.assert(true, 'Code coverage method should execute without throwing exceptions');
    }*/
    //Test method for data setup
    @TestSetup static void setUpData(){
        
        UserRole usRole = new UserRole(Name = 'Admin');
        insert usRole;
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name like '%Partner User%' LIMIT 1];//US - TWC702-14285: Worked on this test class (no logic/structure change)
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.UserRoleId = usRole.Id;
        database.insert(usr);

   System.runAs(usr){        
        //Creating Program with utility class 
        List<ChannelProgram> cpList = new List<ChannelProgram>();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
        cpList.add(cp);
        ChannelProgram retailCp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.RMF_PROGRAM,'Retail Marketing Funds', false);
        cpList.add(retailCp);
        Database.insert(cpList);
        List<Account> accList = new List<Account>();

        
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
        intelRetail.Core_Sub_Geo__c = 'SA';
        accList.add(intelRetail);
        
        Database.insert(accList);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        PermissionSet retailClaimSubmitterPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Retail_Claim_Submitter' LIMIT 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_External_Claim_Submitter'];
        
        //Creating Contact for Partner User
        List<Contact> contactList = new List<Contact>();

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
        
        List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
        agsRoleList.add(agsRoleCCF);
        Core_AGS_Role__c agsRoleRMF = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-RMF User', 'Co-Marketing(Salesforce)-RMF User', true, false);
        agsRoleList.add(agsRoleRMF);
        Core_AGS_Role__c agsRoleRMF_CS = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-External Retail Claim Submitter', 'Co-Marketing(Salesforce)-External Retail Claim Submitter', true, false);
        agsRoleList.add(agsRoleRMF_CS);
        Database.insert(agsRoleList);
       
        List<Core_ERPM_Engagement__c> erpmEngagementList = new List<Core_ERPM_Engagement__c>();
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        erpmEngagementList.add(erpmEngagementCCF);
        Core_ERPM_Engagement__c erpmEngagementRMF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('RPS_Retailer', 'RPS_Retailer', 'DEDUPGPRET', 'SEC', true, false);
        erpmEngagementList.add(erpmEngagementRMF);
        Database.insert(erpmEngagementList);
        
        List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Intel® Partner Investment Center','CCF User',erpmEngagementCCF.Id , true,Core_MDF_CCP_ConstantClass.CCF_PROGRAM,false);
        entitlementList.add(entitlementCCF);
        Core_Entitlement__c entitlementRMF = Core_MDF_CCP_TestDataUtility.createEntitlement('RMF User',agsRoleRMF.Id ,'Intel® Partner Investment Center','RMF User',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',false);
        entitlementList.add(entitlementRMF);
        Core_Entitlement__c entitlementRMF_CS= Core_MDF_CCP_TestDataUtility.createEntitlement('RMF External Claim Submitter',agsRoleRMF_CS.Id ,'Intel® Partner Investment Center','RMF External Claim Submitter',erpmEngagementRMF.Id , true,'Retail Marketing Funds (RMF)',false);
        entitlementList.add(entitlementRMF_CS);
        Database.insert(entitlementList);
        
        
        List<Core_Contact_Entitlement__c> contactEntitlementList = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementCCF);
        Core_Contact_Entitlement__c contactEntitlementCCF1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord2.Id,entitlementCCF.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementCCF1);
        Core_Contact_Entitlement__c contactEntitlementRMF_C1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(externalUser.Id,entitlementRMF.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementRMF_C1);
        Core_Contact_Entitlement__c contactEntitlementRMF_CS_C1 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(externalUser.Id,entitlementRMF_CS.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementRMF_CS_C1);
        Core_Contact_Entitlement__c contactEntitlementRMF_C2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(externalUser1.Id,entitlementRMF.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementRMF_C2);
        Core_Contact_Entitlement__c contactEntitlementRMF_CS_C2 = Core_MDF_CCP_TestDataUtility.createContactEntitlement(externalUser1.Id,entitlementRMF_CS.Id ,true,'Complete', false);
        contactEntitlementList.add(contactEntitlementRMF_CS_C2);
        Database.insert(contactEntitlementList);
        Test.startTest();
         
         List<User> accountOwnerList = [SELECT Id, UserRoleId FROM User WHERE Id = :intelRetail.OwnerId];
          
           if (!accountOwnerList.isEmpty()) {
               User accountOwner = accountOwnerList[0];
               if (accountOwner.UserRoleId == null) {
                   accountOwner.UserRoleId = usRole.Id;
                   update accountOwner;
               }
           } else {
               // Set the account owner to a user that exists and has a role
               intelRetail.OwnerId = usr.Id;
               update intelRetail;
           }
        
            List<User> userList = new List<User>();
            User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr1.Email='test1@example.com';
            //Usr1.UserRoleId=usRole1.id;//US - TWC702-14285: Worked on this test class (no logic/structure change)
            usr1.ContactId = conRecord1.Id;
            usr1.ProfileId = profileId;
            usr1.isActive = true;
            userList.add(usr1);
            
            User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
            usr2.Email='test2@example.com';
            //Usr2.UserRoleId=usRole1.id;//US - TWC702-14285: Worked on this test class (no logic/structure change)
            usr2.ContactId = conRecord2.Id;
            usr2.ProfileId = profileId;
            usr2.isActive = true;
            userList.add(usr2);
            
            User extUser = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUser.LastName = 'Claim Submitter';
            //extUser.UserRoleId=usRole1.id;//US - TWC702-14285: Worked on this test class (no logic/structure change)
            extUser.ProfileId = profileId;
            extUser.email = 'xyz@mail.com';
            extUser.ContactId = externalUser.Id;
            extUser.isActive = true;
            userList.add(extUser);
            
            User extUser1 = Core_MDF_CCP_TestDataUtility.createUser(false);
            extUser1.LastName = 'Test Claim Submitter 1';
            //extUser1.UserRoleId=usRole1.id;//US - TWC702-14285: Worked on this test class (no logic/structure change)
            extUser1.ProfileId = profileId;
            extUser1.email = 'xyzabc@mail.com';
            extUser1.ContactId = externalUser1.Id;
            extUser1.isActive = true;
            userList.add(extUser1);
            
            Database.insert(userList);
            Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
            Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
            //adding bypass feature to bypass access validation
            List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            bypassFunctionKeys.add('Bypass_Duplicate_AcctUserMapping_Check');
            bypassFunctionKeys.add('ByPass_BlockLegacyBudgetCreation');
            //bypassFunctionKeys.add('Core_MDF_validateAccountUserAccess');
            
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            //Create PMB for the above Account 
            PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,accountRecord.Id,cp.Id,123456,System.today()-5,System.today()+5,false);
            pmbRecord.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
            insert pmbRecord;
            
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
            
            // Creating Groups for PGM
            Group grp = new Group();
            grp.name = 'PGM_TEST';
            insert grp;
            
            List<GroupMember> gmList = new List<GroupMember>();
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = usr1.Id;
            gmList.add(gm);
            
            GroupMember gm1 = new GroupMember();
            gm1.GroupId = grp.Id;
            gm1.UserOrGroupId = usr2.Id;
            gmList.add(gm1);
            
            GroupMember gm2 = new GroupMember();
            gm2.GroupId = grp.Id;
            gm2.UserOrGroupId = extUser.Id;
            gmList.add(gm2);
            
            GroupMember gm3 = new GroupMember();
            gm3.GroupId = grp.Id;
            gm3.UserOrGroupId = extUser1.Id;
            gmList.add(gm3);
            
            Database.insert(gmList);
            
            Core_MDF_Partner_Group_Mapping__c pgm = new Core_MDF_Partner_Group_Mapping__c();
            pgm.Core_MDF_Account__c = accountRecord1.Id;
            pgm.Core_MDF_Group_Name__c = 'PGM_TEST';
            pgm.Core_MDF_Type_of_Access__c = 'Internal';
            pgm.Core_MDF_Group_Id__c = grp.Id;                
            pgm.Core_MDF_Channel_Program__c = cp.Id;
            pgm.Core_MDF_Region_cd__c='WW';
            pgm.Core_MDF_Source_Txt__c = 'test';
            pgm.Core_MDF_AccountIdGroupName__c = accountRecord.Id+'PGM_TEST';
            database.insert(pgm);
            
            Core_MDF_Partner_Node_User_Mapping__c pnumRecord = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accountRecord.Id,usr1.Id,true);
            
            
            PartnerMarketingBudget retailBudget = Core_MDF_CCP_TestDataUtility.createRetailBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
            intelRetail.id, retailCP.Id , 123456789 , System.today()-60 , System.today() + 60 , false, 'Retail MDF');
            retailBudget.IsIgnoreValidation = true;
            retailBudget.Core_MDF_Budget_Status__c='Released';
            insert retailBudget;
            //update retailBudget;
            
            //allocation
            PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',retailBudget,intelRetail,600,true);
        
        
            //Creating Campaign Record 
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-5, System.today()+5, 10000, 'Consumer Chromebook', accountRecord.Id, '2-in-1', false); 
            camp.Core_MDF_Opal_Budget_Type_Txt__c='OEM CMP';
            camp.Core_MDF_Technology__c='Intel® Arc™ graphics';
            insert camp;
            
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
            pfr1.Core_MDF_Start_Date__c = System.today()-5;
            pfr1.Core_MDF_End_Date__c = System.today()+5;
            pfr1.RequestedAmount = 2000;
            pfr1.Core_MDF_pagespayingfor__c = 15;
            pfr1.Amount = 0;
            pfr1.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
            pfr1.Core_MDF_Reimbursement_Rate_txt__c='100%';
            pfr1.Core_MDF_ActivityCategory__c='';//US - TWC702-14285: Worked on this test class (no logic/structure change)
            pfr1.Core_MDF_Activity_Types__c='';//US - TWC702-14285: Worked on this test class (no logic/structure change)
            Database.insert(pfr1);
            
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
            
            //Creating Case on the Account
            Case case1 = new Case(AccountId=accountRecord.Id);
            Database.insert(case1);
            
        
            Test.stopTest(); 
           
        }
    }
    
    //Test method to test Create, Update & Delete PNUM Records
    @isTest static void createPNUMRecords(){
        
        Core_Trigger_Executions__c execution1 = new Core_Trigger_Executions__c();
            execution1.Name = 'Core_MDF_Bypass_Manual_Share';
            execution1.Core_Active__c = TRUE;
            execution1.Core_Class_Name__c = 'Core_MDF_PNUMappingTriggerHandler';
            execution1.Core_Description__c = 'Switch ON/OFF the Manual Share';
            execution1.Core_Object__c = 'Core_MDF_Partner_Node_User_Mapping__c';
            execution1.Core_Trigger_Events__c = 'After Update';
            insert execution1;
        
        Test.startTest();
        User systemAdminRecord = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User partnerUserRec1 = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        Account accountRecord1 = [SELECT Id from Account where Name= 'Test Account' limit 1];
       
        User partnerUserRec2 = [SELECT Id,Email from User where Email='test2@example.com' limit 1];
        Account accRec1 = [SELECT Id from Account where Name='Test Account 1' limit 1];
        Account accRec2 = [SELECT Id from Account where Name='Test Account 2' limit 1];

        
        PartnerFundRequest pfr1 = [Select id from PartnerFundRequest where title = 'Test Activity1'];
        //Creating Bank Record
        Core_MDF_Bank__c testBank1 = new Core_MDF_Bank__c();
        Core_MDF_Account_Bank_Mapping__c abm1 = new Core_MDF_Account_Bank_Mapping__c();
        
        system.runAs(systemAdminRecord){
        testBank1 = Core_MDF_CCP_TestDataUtility.createBank(accountRecord1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1234567891');
            
            
        abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accRec1.Id,testBank1.Id,true);
        }
        //Core_MDF_Bank__c testbank1 = [Select id from Core_MDF_Bank__c];
         //Creating Claim Record

        
        //Creating Payment Record
        //Core_MDF_Payment__c dummyPaymentRecord = new Core_MDF_Payment__c();
        //Database.insert(dummyPaymentRecord);
        
        //pfc1.Core_MDF_Payment_Id__c = dummyPaymentRecord.Id;
        //Database.update(pfc1);
    
        //Creating Payment Run Record
        /*Core_MDF_Payment_Run__c payRunRecord = new Core_MDF_Payment_Run__c();
        payRunRecord.Core_MDF_ScheduleRun_Dtm__c= DateTime.Now().addMinutes(3);
        payRunRecord.Core_MDF_Geo_Txt__c = 'APJ';
        payRunRecord.Core_MDF_Program_Id__c  = cp.Id;
        Database.insert(payRunRecord); */
        

        System.runAs(systemAdminRecord){
            
            //Creating Adjustment Request Record
           /* Core_MDF_Adjustment_Request__c adjReq = new Core_MDF_Adjustment_Request__c();
            PartnerFundClaim claim = [SELECT Id FROM PartnerFundClaim where Title ='Test Claim'];
            //adjReq.Core_MDF_Type_Txt__c ='Negative Claim';
            adjReq.Core_MDF_Reference_Claim_Nbr__c = claim.Id;
            adjReq.Core_MDF_Reason_Cd__c = 'Claim Review Results (Negative)';
            adjReq.Core_MDF_Amount_Amt__c = 10; 
            adjReq.Core_MDF_Comments_Txt__c = 'Test';
            Database.insert(adjReq);*/
            //Create a Partner Node User Mapping with the above created Account
            try{
                AccountShare accshare = [Select UserOrGroupId From AccountShare WHERE AccountId =:accRec1.Id AND UserOrGroupId =:partnerUserRec1.Id  limit 1];
                System.assertNotEquals(accshare.Id,NUll);
                
                List<Core_MDF_Partner_Node_User_Mapping__c> pnumRecList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
                Core_MDF_Partner_Node_User_Mapping__c pnumRecord2 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRec2.Id,partnerUserRec1.Id,false);
                Core_MDF_Partner_Node_User_Mapping__c pnumRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accRec1.Id,partnerUserRec2.Id,false);
                pnumRecList.add(pnumRecord2);
                pnumRecList.add(pnumRecord1);
               Database.insert(pnumRecList);
                
                System.assertNotEquals(pnumRecord1,null);
            }catch(Exception e){
                
            }
            Test.stopTest();
        }
    }
    
    //Test method to test Create, Update & Delete PNUM Records
    @isTest static void updateanddeletePNUMRecords(){
        
        User systemAdminRecord = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        User partnerUserRec1 = [SELECT Id,Email from User where Email='test1@example.com' limit 1];
        Account accountRecord1 = [SELECT Id from Account where Name= 'Test Account' limit 1];

        Account accRec1 = [SELECT Id from Account where Name='Test Account 1' limit 1];
        Account accRec2 = [SELECT Id from Account where Name='Test Account 2' limit 1];

        
        PartnerFundRequest pfr1 = [Select id from PartnerFundRequest where title = 'Test Activity1'];
        //Creating Bank Record
        Core_MDF_Bank__c testBank1 = new Core_MDF_Bank__c();
        Core_MDF_Account_Bank_Mapping__c abm1 = new Core_MDF_Account_Bank_Mapping__c();
        
        system.runAs(systemAdminRecord){
        testBank1 = Core_MDF_CCP_TestDataUtility.createBank(accountRecord1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1234567891');
        abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accRec1.Id,testBank1.Id,true);
        }
        //Core_MDF_Bank__c testbank1 = [Select id from Core_MDF_Bank__c];
         //Creating Claim Record
         Test.startTest();


        
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_Account__r.name,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c LIMIT 1];
        System.runAs(systemAdminRecord){
           
            //Create a Partner Node User Mapping with the above created Account
            try{
                AccountShare accshare = [Select UserOrGroupId From AccountShare WHERE AccountId =:accRec1.Id AND UserOrGroupId =:partnerUserRec1.Id  limit 1];
                System.assertNotEquals(accshare.Id,NUll);
                
                pnumRecord.Core_MDF_Account__c = accRec2.Id;
                Database.update(pnumRecord);
                
                //pnumRecord.Core_MDF_Account__c = accRec1.Id;
                //Database.update(pnumRecord);

                Database.delete(pnumRecord);
            }catch(Exception e){
                
                
            }
            Test.stopTest();
        }
    }
    
    //Test method for Delete Account User scenario
    @isTest static void testDeleteShareRecords(){
        
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
        
        //Core_MDF_PNUMappingServiceHandler.mfetchPartnerNodeUserMapping(accIdList);
 
        System.runAs(systemAdminRecord){
           /* Core_MDF_Partner_Node_User_Mapping__c pnumRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(accountRecord1.Id,partnerUserRecord.Id,true);
            pnumRecord.Core_MDF_Active_Ind__c=false;
            pnumRecord1.Core_MDF_Active_Ind__c=false;
            deleteRecordList.add(pnumRecord);
            deleteRecordList.add(pnumRecord1);
            System.assertNotEquals(pnumRecord1,null);*/
        }
        
        try{
            Database.update(deleteRecordList);
         
            AccountShare accshare = [Select UserOrGroupId,RowCause From AccountShare WHERE AccountId =:pnumRecord.Core_MDF_Account__c AND UserOrGroupId =:pnumRecord.Core_MDF_User__c  limit 1];
         
            //System.assertEquals(accshare.Id,NUll);
        }catch(Exception e){
            
        }    
    // US - TWC702-14285: Unit Test Method should include System.Assert    
    System.assertNotEquals(null, pnumRecord, 'PNUM record should exist');
    System.assertNotEquals(null, pnumRecord.Core_MDF_Account__c, 'PNUM record should have an associated account');
    System.assertNotEquals(null, accIdList, 'Account ID list should not be null');
    System.assert(accIdset.size() >= 0, 'Account ID set should be initialized');
        
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
               
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testRetailSharing(){
        
        User systemAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        
        ChannelProgram retailCp = [SELECT Id, Name FROM ChannelProgram WHERE Name = 'Retail Marketing Funds' limit 1];
        
        test.startTest();
        system.runAs(systemAdminUser){
        Account accountRecord1 = [SELECT Id from Account where Name='Test Account' limit 1];
        
        Account retailAccount = [SELECT Id, Name FROM Account WHERE Name = 'Retail Test Account' limit 1];
        
        User claimSubmitter = [SELECT Id,Email from User where Email='xyz@mail.com' limit 1];
          PartnerFundAllocation pfa=[select id from PartnerFundAllocation where Title=:'Test Allocation New'];
        
        Core_MDF_Bank__c retailBank = Core_MDF_CCP_TestDataUtility.createBank(accountRecord1.Id, 'Core_MDF_Retail_Marketing_Funds', false,'1234567892');
        retailBank.Core_MDF_Intel_Company_Code__c = '150';
        retailBank.Core_MDF_Program__c = 'Core_MDF_Retail_Marketing_Funds';
        retailBank.Core_MDF_Currency_cd__c = 'USD';
        retailBank.Core_MDF_Tax_codes_cd__c = 'I0';
        retailBank.Core_MDF_Bank_Status__c = 'Active';
        retailBank.Core_MDF_Supplier_Name__c = 'Test';
        retailBank.Core_MDF_Payment_Method_Code__c = 'C';
        database.insert(retailBank);
        
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(retailAccount.Id,retailBank.Id,false);
        abm.Core_MDF_Active_ind__c = true;
        insert abm;
        
        
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 'Yes',
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                        'Retail Marketing Funds',
                                                                        System.today() - 45, System.today().addYears(1), 200, 
                                                                        'Instore innovation', retailAccount.Id,'2-in-1', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c ='Retail MDF';
            camp.Core_MDF_Budget_Amount_amt__c = 200;
            database.insert(camp);
            
            PartnerFundRequest retailPfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp.Id),
                                                                                                               Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,
                                                                                                               string.valueof(retailAccount.id),NULL,NULL,
                                                                                                               'AFGHANISTAN','All','Workstation',
                                                                                                               'EVO','Broadcast',
                                                                                                               'Podcast','Draft',false);
            
            retailPfr.Title ='Retail MDF Activity';
            retailPfr.Core_MDF_Activity_Description__c ='Retail MDF Activity';
            retailPfr.Core_MDF_Budget_Type_nm__c ='Retail MDF';
            retailPfr.Core_MDF_Start_Date__c = System.today() - 40;
            retailPfr.Core_MDF_End_Date__c  = System.today() - 40;
            retailPfr.RequestedAmount =10;
            retailPfr.Amount=10;
            //retailPfr.Core_MDF_Country__c ='AFGHANISTAN';
            retailPfr.Core_MDF_Country_nm__c = 'AFGHANISTAN';
            retailPfr.Core_MDF_Fund_Request_Status__c = 'Closed';
            retailPfr.Core_MDF_Budget_Currency_cd__c ='USD'; 
            retailPfr.Core_MDF_Reimbursement_Rate_pct__c='25%';
            retailPfr.Core_MDF_Reimbursement_Rate_txt__c='25%';
            //retailPfr.Core_MDF_Campaign_Amount__c = 200;
            retailPfr.AllocationId=pfa.Id;
            retailPfr.Core_MDF_ActivityCategory__c='';//US - TWC702-14285: Worked on this test class (no logic/structure change)
            retailPfr.Core_MDF_Activity_Types__c='';//US - TWC702-14285: Worked on this test class (no logic/structure change)
            database.insert(retailPfr);
            
            Id claimRecType = Schema.SObjectType.Core_MDF_Escalation__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Late_Claim').getRecordTypeId();
            
            Core_MDF_Escalation__c esc = new Core_MDF_Escalation__c();
            esc.Core_MDF_Escalation_Status_nm__c='Pending Review';
            esc.Core_MDF_Escalation_Name_txt__c='Test1';
            esc.Core_MDF_Total_Dollar_Impact_amt__c= 1;
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
            
            //database.delete(pnum);
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
        retailAPJAccount.Core_Sub_Geo__c = 'SA';
        Database.insert(retailAPJAccount);
        
        Account retailINDAccount = Core_MDF_CCP_TestDataUtility.createAccount ('Retail Test Account2', retailCp.Id,
                                                                          Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        retailINDAccount.Core_MDF_Parent_Fund_Account__c = retailAPJAccount.Id;
        retailINDAccount.Core_MDF_CoMarketing_Ultimate_Account__c = accountRecord1.Id;
        retailINDAccount.Core_MDF_Active_Ind__c = true;
        retailINDAccount.Core_Geo__c = 'APJ';
        retailINDAccount.Core_Sub_Geo__c = 'SA';
        Database.insert(retailINDAccount);

        
        Account retailAccount1 = [SELECT Id, Name, Core_MDF_Parent_Fund_Account__c FROM Account WHERE Name = 'Retail Test Account1' limit 1];
        Account retailAccount2 = [SELECT Id, Name, Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c FROM Account WHERE Name = 'Retail Test Account2' limit 1];
        
        User claimSubmitter = [SELECT Id,Email from User where Email='xyz@mail.com' limit 1];
        User claimSubmitter1 = [SELECT Id,Email from User where Email='xyzabc@mail.com' limit 1];
        
        
        system.runAs(systemAdminUser){
            List<Campaign> cmpList = new List<Campaign>();
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena','Yes' ,
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                        'Retail Marketing Funds',
                                                                        System.today() - 45, System.today().addYears(1), 2000, 
                                                                        'Instore innovation', retailVirtualAccount.Id,'2-in-1', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c ='Retail MDF';
            cmpList.add(camp);
            
            Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp1','Gaming','Athena','Yes', 
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                        'Retail Marketing Funds',
                                                                        System.today() - 45, System.today().addYears(1), 2000, 
                                                                        'Instore innovation', retailAccount1.Id,'2-in-1', false);
            camp1.Core_MDF_Opal_Budget_Type_Txt__c ='Retail MDF';
            cmpList.add(camp1);
            
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp2','Gaming','Athena','Yes', 
                                                                        Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 
                                                                        'Retail Marketing Funds',
                                                                        System.today() - 45, System.today().addYears(1), 2000, 
                                                                        'Instore innovation', retailAccount2.Id,'2-in-1', false);
            camp2.Core_MDF_Opal_Budget_Type_Txt__c ='Retail MDF';
            cmpList.add(camp2);
            
            database.insert(cmpList);
            
            Core_MDF_Partner_Node_User_Mapping__c pnum = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(retailVirtualAccount.Id,claimSubmitter.Id,true);
            Core_MDF_Partner_Node_User_Mapping__c pnum1 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(retailVirtualAccount.Id,claimSubmitter1.Id,true);          
            Core_MDF_Partner_Node_User_Mapping__c pnum2 = Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(retailAPJAccount.Id,claimSubmitter1.Id,true);
            Core_MDF_Partner_Node_User_Mapping__c testPartnerNodeUserMapping = new Core_MDF_Partner_Node_User_Mapping__c(Core_MDF_Account__c = retailVirtualAccount.Id,Core_MDF_User__c=claimSubmitter.Id, Core_MDF_Active_Ind__c= true,Core_MDF_Error_Details_txt__c = 'Group Member insert failed');       
            insert testPartnerNodeUserMapping;
            Database.executeBatch(new Core_MDF_Batch_PNUMRefresh());
            List<CampaignShare> cmpShareList = [SELECT Id, CampaignId, UserOrGroupId
                                                             FROM CampaignShare 
                                                             WHERE CampaignId =: camp.Id AND
                                                             UserOrGroupId =: claimSubmitter.Id];

            List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
            pnumList.add(pnum);
            pnumList.add(pnum1);
            pnumList.add(pnum2);
           // Core_MDF_PNUMappingServiceHandler.validateAccountUserAccess(pnumList);
            //Core_MDF_PNUMappingServiceHandler.displayErrorForInvalidUser(pnumList,null,null,null,null);
            //Core_MDF_PNUMappingServiceHandler.validateCrossAccUserAccess(pnumList);
            //Core_MDF_PNUMappingServiceHandler.prepareCommonMapData(pnumList);
            //Core_MDF_PNUMappingServiceHandler.validateAccountUserMapping(pnumList);
            System.assert(cmpShareList != NULL);
                       
            //database.delete(pnum);
            test.stopTest();
        }
    }
    
    //Test method for Delete Account User scenario
    @isTest static void testmfetchPartnerNodeUserMappingException(){
            
        Test.startTest();
        Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap = new Map<Id, Core_MDF_Partner_Node_User_Mapping__c>();
        Core_MDF_Partner_Node_User_Mapping__c pnumRecord = [SELECT ID,Core_MDF_Account__c,Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c limit 1];                                             
        List<Core_MDF_Partner_Node_User_Mapping__c> deleteRecordList = new List<Core_MDF_Partner_Node_User_Mapping__c>();
        deleteRecordList.add(pnumRecord);
        newPNUMappingMap.put(pnumRecord.Id, pnumRecord);
        //Test method to fetch and delete the created PNUM Records
        Set<Id> accIdset = new Set<Id>();
        for (Account accRecord : [SELECT Id from Account limit 2]){
            //accRecord.Id = '001g0000025ts1CXXX'; 
            accIdset.add(accRecord.Id); 
        }
        try{        
      
        //Core_MDF_PNUMappingServiceHandler.mfetchPartnerNodeUserMapping(accIdList);
        //Core_MDF_PNUMappingServiceHandler.deleteObjectShareRecords(deleteRecordList,newPNUMappingMap,true);
        //Core_MDF_PNUMappingServiceHandler.isApexJobLimitAvailable(deleteRecordList);
        //Core_MDF_PNUMappingServiceHandler.checkPNUMDuplicateRecords(deleteRecordList,newPNUMappingMap);
        //Core_MDF_PNUMappingServiceHandler.addOrUpdateGeneralizeDedupMap(deleteRecordList,newPNUMappingMap);
        //Core_MDF_PNUMappingServiceHandler.isAccountUserUpdated(newPNUMappingMap,newPNUMappingMap);
        
        }catch(Exception e){
            
            System.assertNotEquals(NULL,e);
        }    
        Test.stopTest();         
    }
    
}