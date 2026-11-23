@isTest
private class Core_MDF_ProcessClaimPredictionTest {

        /* Method to Setup Test Data */
    @testSetup 
    static void setup() {  
        
            List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);
        
        List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        List<Contact> listContact = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        listContact.add(conRecord1);
        Database.insert(listContact);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        
        List<Core_AGS_Role__c> agsRoleList = new List<Core_AGS_Role__c>();
        
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
        agsRoleList.add(agsRoleCCF);
        
        Core_AGS_Role__c agsRoleCCFClaimSub = Core_MDF_CCP_TestDataUtility.createAgsRole('Co-Marketing(Salesforce)-External Claim Submitter-CCF', 'Co-Marketing(Salesforce)-External Claim Submitter-CCF', true, false);
        agsRoleList.add(agsRoleCCFClaimSub);
        
        Database.insert(agsRoleList);        
        
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        
        List<Core_Entitlement__c> entitlementList = new List<Core_Entitlement__c>();
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Consolidated Co-marketing Platform','CCF User',erpmEngagementCCF.Id , true,'Client',false);
        entitlementList.add(entitlementCCF);
        
        Core_Entitlement__c entitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createEntitlement('Client Claim Submitter',agsRoleCCFClaimSub.Id ,'Consolidated Co-marketing Platform','CCF Claim Submitter',erpmEngagementCCF.Id , true,'Client',false);
        entitlementList.add(entitlementCCFClaimSub);
        
        Database.insert(entitlementList); 
        
        List<Core_Contact_Entitlement__c> contEntList = new List<Core_Contact_Entitlement__c>();
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCF);
        
        Core_Contact_Entitlement__c contactEntitlementCCFClaimSub = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCFClaimSub.Id ,true,'Complete', false);
        contEntList.add(contactEntitlementCCFClaimSub);
        
        Database.insert(contEntList);       
        
         List<User> listUser = new List<User>();
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        //usr1.ContactId = listContact[0].Id;
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        listUser.add(usr1);        
        
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.Email = 'sysadmin@example.com';
        listUser.add(usr3);
        
        //Login as claim claim Case reviewer
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User ccrUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccrUser.Email='testCCR@example.com';
        ccrUser.ProfileId = p.id;
        listUser.add(ccrUser);
            
        //creating system admin user
        User sysAdmUsr = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdmUsr.LastName = 'System Adm';
        listUser.add(sysAdmUsr);
        
        //creating claim case user
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName='Claim Case User';
        usr.profile=ccpCoreProfile;
        listUser.add(usr);
        
        Database.insert(listUser);  

        Group grp = new Group();
        grp.name = 'PGM_TEST';
        insert grp;
        system.runAs(sysAdmUsr){
            
            GroupMember gm = new GroupMember();
            gm.GroupId = grp.Id;
            gm.UserOrGroupId = usr1.Id;
            insert gm;
            
            //asigning permission set to claim case user
            PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
            assignPermissionSetObj.AssigneeId = usr.Id;
            assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
            
            Database.insert(assignPermissionSetObj);
        //}

        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'Internal',acc1.Id,cp.Id,'PGM_TEST',true);
        
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        List<Core_MDF_Bank__c> listBank = new List<Core_MDF_Bank__c>();
        List<Core_MDF_Bank__c> bankList = new List<Core_MDF_Bank__c>();
        
 
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        bank.Core_MDF_Bank_Status__c='Active';
        listBank.add(bank);
        
        Core_MDF_Bank__c bank1 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1241241240');
        bank1.Core_MDF_Bank_Status__c='Active';
        listBank.add(bank1); 

        Core_MDF_Bank__c bank2 = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1249641240');
        bank2.Core_MDF_Bank_Status__c='Active';
        listBank.add(bank2);
        
        Database.insert(listBank);
            
        bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
        BankList.add(bank);
        
        bank1.Core_MDF_Bank_Alias_Name__c='TestActiveBank2';
        BankList.add(bank1);              
        
        bank2.Core_MDF_Bank_Alias_Name__c='TestActiveBank3';
        BankList.add(bank2); 
        
        //Database.update(BankList);
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-15), System.today().addDays(15), 10000, 'Always Connected PC', acc2.Id,'Desktop', true);             
        
        //Database.update(abm);
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates(); 
        //test.startTest();
        
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,System.today().addDays(-20),System.today(), false);
        budget.Core_MDF_Budget_Type__c='MDF';
        budget.Core_MDF_Budget_Type_Txt__c = 'MDF';
        Database.insert(budget);
        test.startTest(); 
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,200.0,true);
        
         
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
        List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        //creating ABM for bank1
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,false);
        abmList.add(abm1);
        Core_MDF_Account_Bank_Mapping__c abm2 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank1.Id,false);
        abmList.add(abm2);
        //creating ABM for bank2
        Core_MDF_Account_Bank_Mapping__c abm = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank2.Id,false);
        abmList.add(abm);
        Database.insert(abmList);
        abm.Core_MDF_Active_ind__c=false;
       
               
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
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
        
        
        testPartnerFundRequest.Core_MDF_Start_Date__c = system.today().addDays(-5);
        testPartnerFundRequest.Core_MDF_End_Date__c  = system.today();
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest.amount = 1000;
        testPartnerFundRequest.Core_MDF_Budget_Type_nm__c = 'CCF 1.0';
        //testPartnerFundRequest.CampaignId = camp.Id; // Added by Areefa
        insert testPartnerFundRequest;
        //inserting currency data        
       
        test.stopTest();
        }
        //Database.insert(pfcList);
        
        
        
        //Escalation
        //Core_MDF_CCP_TestDataUtility.createEscalation();
                Core_MDF_Configuration__c config8 = new Core_MDF_Configuration__c();
         config8.Core_MDF_Value__c = 'Core_MDF_CCP_RMF_Internal_Claim_Operations';
            config8.Name = 'PRC_CLAIM_OPERATION_CUSTOM_PERMISSION';
            insert config8;
        Core_MDF_Configuration__c config9 = new Core_MDF_Configuration__c();
         config9.Core_MDF_Value__c = 'MDF,MDF+';
            config9.Name = 'BUDGET_TYPE_CLAIM_BANK_HIDE';
            insert config9;        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
    }
    
    /* Method to test save claim */
    @isTest
    static void testCreateClaimPredictionMethod()
    {
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1241241240' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), bank1.Id, false);
            claim1.Core_MDF_Currency__c='USD';//INR
            list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
           // Highlight: Unused Local Variable - Indira
          /*  Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = */ Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null, false, null, false, null, false);            
            //System.assertEquals(claim1.ID,res);

            Core_MDF_Claim_Prediction__c t = new Core_MDF_Claim_Prediction__c();
            t.Core_MDF_Claim_id__c=    claim1.ID;
            insert t;
            Core_MDF_Claim_Prediction__c cpred = [Select Id,Core_MDF_Claim_id__c,Core_MDF_New_Prediction_Score_nbr__c from Core_MDF_Claim_Prediction__c where Core_MDF_Claim_id__c =: claim1.ID];
          
            System.assertEquals(cpred.Core_MDF_Claim_id__c,claim1.ID);
            //System.assertNotEquals(cpred.Core_MDF_Prediction_Score_Nbr__c,0);
            //System.assertNotEquals(cpred.Core_MDF_Prediction_Score_Nbr__c,null);
            test.stopTest();
        }
    }
}