/****************************************************************************************************************************************
* Class Name  : Core_MDF_PartnerFundClaim_Test
* Version     : 1.0 
* Created Date: 4-May-2019
* Modification Log :
* Developer    Intel :Areefa      Date:4-May-2019       Description:Claim Manual Hold Functionalty 
Vaishali - Accn					 Date:30-Dec-2019		Description : Refactor
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
Private class Core_MDF_PFC_ManualHold_Claim_Test {    
    
    /* Method to Setup Test Data */
    @TestSetup static void setUpData(){        
        
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 3', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc2.Id, true);
        
        // Updating Accounts 
        acc1.isPartner = true;
        acc2.isPartner = true;
        acc3.isPartner = true;
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc3);
        Database.update(toBeUpdated);
        
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSet clmSubmitter = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_External_Claim_Submitter' LIMIT 1];
        
        // Creating User with utility class 
        List<User> usrList = new List<User>();
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usrList.add(usr);
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        usrList.add(usr1);
        
        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.Email = 'clmcase@example.com';
        claimCase.Profile = ccpCoreProfile;
        usrList.add(claimCase);
        
        Database.insert(usrList);        
        
        List<PermissionSetAssignment> lstPSAssignment = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(usr1.Id,clmSubmitter.Id,false);
        lstPSAssignment.add(assignPermissionSetObj);
        PermissionSetAssignment assignPermissionSetObj1 = Core_MDF_CCP_TestDataUtility.createPermissionSetAssignment(claimCase.Id,clmCaseRevPS.Id,false);
        lstPSAssignment.add(assignPermissionSetObj1);
        
        system.runAs(usr){
            Database.insert(lstPSAssignment);
        }
        
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates();
        //adding bypass feature to bypass access validation
			List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 30000, 
                                                                               System.today(), System.today().addDays(364), false);
        pbm.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        
        database.insert(pbm);
        
        PartnerFundAllocation pfa = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 30000, true);
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(300), 10000, 'Always Connected PC', acc2.Id,'Desktop', false);
        
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        Database.insert(camp);
         
        Test.startTest();
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft', false);
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c = 'OEM CMP';
        testPartnerFundRequestRecord.Title = 'Test Activity For Manual Hold';
        testPartnerFundRequestRecord.Status = 'Approved';
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_pct__c = '50%';
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        Database.insert(testPartnerFundRequestRecord);
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
       
        Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
        
        Test.stopTest();
        Core_MDF_Configuration__c execution1 = new Core_MDF_Configuration__c();
        execution1.Name = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        execution1.Core_MDF_Category__c = 'Bank Document Hold Logic';
        execution1.Core_MDF_Value__c = 'Retail Marketing Funds,Intel Partner Alliance';
        insert execution1;
        /*
        //Core_MDF_CCP_TestDataUtility.createTriggerExecutionRecords();
        
        List<PartnerFundClaim> listPfc = new List<PartnerFundClaim>();
        
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim For Manual Hold', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, true);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund; //'Pending Available Fund';
        listPfc.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test isMemEligibleForEdit', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, true);
        claim2.Status = Label.Core_MDF_Status_Approved;
        claim2.Core_MDF_Status__c = 'Pending Available Fund';
        claim2.Core_MDF_Intel_Manual_Hold_Ind__c = true;
        listPfc.add(claim2);
        
        Database.update(listPfc);
        
        PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim3', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), -5000.00, System.today(), bank.Id, false);
        claim3.Status = Label.Core_MDF_Status_Submitted;
        claim3.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        claim3.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
        Database.insert(claim3);
       */
        
    }  
    
    /*check user has access to Manual Hold Claim or not*/
    @isTest static void checkingUserPermission(){
        //checking if user doesn't have permission
        User usr = [Select Email from User where email='sysadmin@example.com' LIMIT 1];
        test.startTest();
        System.runAs(usr){
            Boolean resultUserhasPerm = Core_MDF_PFC_ManualHold_Claim.hasAccess();
            System.assertEquals(false, resultUserhasPerm);
        }
        test.stopTest();
    }
    
    /*isPartner*/
    @isTest static void checkisPartner(){
        User usr1 = [SELECT Id,Email from User where Email='test1@example.com' limit 1];        
        test.startTest();
        System.runAs(usr1){
            Boolean isPartner = Core_MDF_PFC_ManualHold_Claim.isPartner();
            System.assertEquals(true, isPartner);
        }
        test.stopTest();
    }
    
    /* Method to test Manual Hold details details */
    @isTest
    static void testcheckClaimForHold()
    {
        User usr1 = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        test.startTest();
        system.runas(usr1){
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'Test Activity For Manual Hold']; 
            Core_MDF_Bank__c bank = [Select ID from Core_MDF_Bank__c limit 1];
            //PartnerFundClaim pfc = [SELECT Id, Title FROM PartnerFundClaim where Title='Test Claim For Manual Hold'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim For Manual Hold', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, 
                                                                               pfr.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, false);
        	claim1.Status = Label.Core_MDF_Status_Approved;
        	claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund; //'Pending Available Fund';
        	Database.insert(claim1);
            Core_MDF_PFC_ManualHold_Claim.HoldClaimDetails claimWrapper = Core_MDF_PFC_ManualHold_Claim.getClaimAndHoldDeatils(claim1.Id);
            system.assertNotEquals(claimWrapper.claimObj , NULL);
        }
        test.stopTest();
    }
    
    /*Get Hold details*/
    @isTest
    static void testgetHoldDetails()
    {
        User usr1 = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];
        test.startTest();
        system.runas(usr1){
            //PartnerFundClaim pfr = [SELECT Id, Core_MDF_Status__c,Core_MDF_Intel_Manual_Hold_Ind__c, Core_MDF_Member_Manual_Hold_Ind__c FROM PartnerFundClaim where Title = 'test'];
            //PartnerFundClaim pfr = [SELECT Id, Title FROM PartnerFundClaim where Title='Test Claim For Manual Hold'];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'Test Activity For Manual Hold']; 
            Core_MDF_Bank__c bank = [Select ID from Core_MDF_Bank__c limit 1];
            //PartnerFundClaim pfc = [SELECT Id, Title FROM PartnerFundClaim where Title='Test Claim For Manual Hold'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim For Manual Hold', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, 
                                                                               pfr.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, false);
        	claim1.Status = Label.Core_MDF_Status_Approved;
        	claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund; //'Pending Available Fund';
        	Database.insert(claim1);
            PartnerFundClaim pfcObj = Core_MDF_PFC_ManualHold_Claim.getClaimHoldStatus(claim1.Id);
            System.assertNotEquals(pfcObj , NULL);
        }
        test.stopTest();
    }
    /*manual hold update*/
    @isTest
    public static void testUpdateClaimOnManualHoldById(){
        User usr1 = [SELECT Id,Email from User where Email='test1@example.com' limit 1]; 
        User usr = [SELECT Id,Email from User where Email='clmcase@example.com' limit 1];  
        test.startTest();
        System.runAs(usr)
        {   PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'Test Activity For Manual Hold']; 
            Core_MDF_Bank__c bank = [Select ID from Core_MDF_Bank__c limit 1];
            PartnerFundClaim pfc1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim For Manual Hold', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, 
                                                                               pfr.Id, System.today(), System.today(), 5000.00, System.today(), bank.Id, false);
        	pfc1.Status = Label.Core_MDF_Status_Approved;
        	pfc1.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund; //'Pending Available Fund';
        	Database.insert(pfc1);
         
            //PartnerFundClaim pfc1 = [SELECT Id, Title FROM PartnerFundClaim where Title='Test Claim For Manual Hold']; 
            PartnerFundClaimShare sharewithExt = new PartnerFundClaimShare(ParentId = pfc1.Id, UserOrGroupId = usr1.Id, AccessLevel = 'Edit');
            try{
                Database.insert(sharewithExt);            
                boolean claimRec = Core_MDF_PFC_ManualHold_Claim.updateClaimOnManualHold(pfc1.Id, ' Test Claim For Manual Hold put on Manual Hold');
                PartnerFundClaim claimAfterUpdate = [Select Id,Core_MDF_Intel_Manual_Hold_Ind__c  ,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim For Manual Hold']; //Id =: claim1.Id];
                System.assertEquals('Submitted', claimAfterUpdate.Core_MDF_Status__c);
                System.assertEquals(true, claimAfterUpdate.Core_MDF_Intel_Manual_Hold_Ind__c);
                System.assertEquals(true, claimRec);
            }catch(Exception e){System.debug('EXCEPTION::::'+e.getMessage());}
        }
        System.runAs(usr1)
        {		
            PartnerFundClaim pfc2 = [SELECT Id, Title FROM PartnerFundClaim where Title='Test Claim For Manual Hold'];
            try{
                boolean claimRec = Core_MDF_PFC_ManualHold_Claim.updateClaimOnManualHold(pfc2.Id, ' Test Claim For Manual Hold put on Manual Hold');
                PartnerFundClaim claimAfterUpdate = [Select Id,Core_MDF_Member_Manual_Hold_Ind__c,Core_MDF_Status__c from PartnerFundClaim where Title = 'Test Claim For Manual Hold']; //Id =: claim1.Id];
                System.assertEquals('Submitted', claimAfterUpdate.Core_MDF_Status__c);
                System.assertEquals(true, claimAfterUpdate.Core_MDF_Member_Manual_Hold_Ind__c);
                System.assertEquals(true, claimRec);
            }catch(Exception e){System.debug('EXCEPTION::::'+e.getMessage());}
        }
        test.stopTest();
    }
}