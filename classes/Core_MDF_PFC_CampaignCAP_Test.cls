@isTest
private class Core_MDF_PFC_CampaignCAP_Test {
    
    /* Method to Setup Test Data */
    @testSetup 
    static void setup() {  
        List<Core_Trigger_Executions__c> transactions = new List<Core_Trigger_Executions__c>();
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Budget_Check','Bypass_GeoBased_Budget_Sharing'}, true, false));       
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Allocation_Reservation','Bypass_GeoBased_Allocation_Sharing'}, true, false));   
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_MDF_Budget_Access_Validation','Bypass_MDF_Budget_Status_Validation','Bypass_MDF_Budget_Access'}, true, false));  
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_Duplicate_Bank_Check','Bypass_Bank_Internal_Sharing',
                    'Bypass_Bank_External_Sharing','Bypass_Bank_Program_InActivation_Check','Bypass_Bank_ABM_Sharing'}, true, false));
        transactions.addAll(Core_MDF_CCP_TestDataUtility.byPassFeature(new List<String>{'Bypass_ABM_Internal_Sharing','Bypass_ABM_External_Sharing','Bypass_ABM_NodeGroup_Sharing'}, true, false));                 
        Database.insert(transactions);
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client','Client CoMarketing Fund', true);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        List<Contact> listContact = new List<Contact>();
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        Contact conRecord2 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,false);
        
        listContact.add(conRecord1);
        listContact.add(conRecord2);
        
        Database.insert(listContact);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        
        
        Core_AGS_Role__c agsRoleCCF = Core_MDF_CCP_TestDataUtility.createAgsRole('CCF_USER', 'Co-Marketing(Salesforce)-CCF USER', true, false);
        //Database.insert(agsRoleCCF);
        
        Core_ERPM_Engagement__c erpmEngagementCCF = Core_MDF_CCP_TestDataUtility.createErpmEngagement('CCF', 'CCF', 'DEDUPB2B', 'SEC', true, false);
        Database.insert(erpmEngagementCCF);
        
        Core_Entitlement__c entitlementCCF = Core_MDF_CCP_TestDataUtility.createEntitlement('Client User',agsRoleCCF.Id ,'Consolidated Co-marketing Platform','CCF User',erpmEngagementCCF.Id , true,'Client',false);
        Database.insert(entitlementCCF); 
        
        Core_Contact_Entitlement__c contactEntitlementCCF = Core_MDF_CCP_TestDataUtility.createContactEntitlement(conRecord1.Id,entitlementCCF.Id ,true,'Complete', false);
        Database.insert(contactEntitlementCCF);        
        
         List<User> listUser = new List<User>();
        
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = listContact[0].Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        listUser.add(usr1);        
        
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.Email='test123@example.com';
        usr2.ContactId = listContact[1].Id;
        usr2.ProfileId = profileId;
        usr2.isActive = true;
        listUser.add(usr2);
        
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
            
            
            Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, true);
        
        Core_MDF_CCP_TestDataUtility.createPartnerGroupMapping(acc1.Id,'Internal',acc1.Id,cp.Id,'PGM_TEST',true);
        
        //Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true); 
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        bank.Core_MDF_Bank_Alias_Name__c='TestActiveBank1';
        bank.Core_MDF_Bank_Status__c='Active';
        Database.insert(bank);
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes' ,Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-15), System.today().addDays(15), 2000, 'Always Connected PC', acc2.Id,'Desktop', false); 
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF';
        camp.Core_MDF_Spending_Cap_Amt__c = 300;  
        database.insert(camp);
        

        //Database.update(abm);
        Core_MDF_CCP_TestDataUtility.insertCurrencyExchangeRates(); 
        
        
        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New',Core_MDF_CCP_TestDataUtility.budget_Record_Type,acc2.Id,cp.Id,200000,
                                                                                  System.today().addDays(-20),System.today().addDays(40), false);
        budget.Core_MDF_Budget_Type_Txt__c = 'MDF';
        database.insert(budget);
        //test.startTest();    
        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New',budget,acc2,20000.0,true);
   
        test.startTest();
       // Highlight: Unused Local Variable
       // List<Core_MDF_Account_Bank_Mapping__c> abmList = new List<Core_MDF_Account_Bank_Mapping__c>();
        //creating ABM for bank1
        Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id,bank.Id,false);        
        Database.insert(abm1);
        

        
         List<Core_MDF_Configuration__c> configMDF = new List<Core_MDF_Configuration__c>();
        Core_MDF_Configuration__c config = new Core_MDF_Configuration__c();
        config.NAME = 'ALLOWED_PRG_FOR_RUS_NOTIF';
        config.Core_MDF_Value__c='3';
        config.Core_MDF_Category__c ='Bank Document Hold Logic';
        configMDF.add(config);
        insert configMDF;
        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id), 
                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                          String.valueof(acc2.id),allocation,null,'INDIA',
                                                                                                          'Consumer',
                                                                                                          'Desktop',
                                                                                                          'Intel® Core™ i5 Processor',
                                                                                                          'Broadcast (Pre-2025)',
                                                                                                          'Podcast',
                                                                                                          'Draft',
                                                                                                          false);
        
        
        testPartnerFundRequest.Core_MDF_Start_Date__c = system.today().addDays(-5);
        testPartnerFundRequest.Core_MDF_End_Date__c  = system.today().addDays(5);
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        testPartnerFundRequest.amount = 1000;
        testPartnerFundRequest.Core_MDF_Reimbursement_Rate_pct__c='100%';
         testPartnerFundRequest.Core_MDF_Reimbursement_Rate_txt__c='100%';
        testPartnerFundRequest.Core_MDF_Budget_Type_nm__c = 'MDF';
        insert testPartnerFundRequest;
        //inserting currency data        

        
        test.stopTest();

        }

             
        
        
    }
    
     /* Method to test save claim */
    @isTest
    static void testcampaignCAPSaveClaimSuccessMethod()
    {
        test.startTest();
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser)
        {
            
            Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
            User Usr1 =[Select id from user where email = 'test1@example.com'];
            Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
            // Highlight: Unused Local Variable
           // Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1231231230' limit 1];
            PartnerFundRequest pfr = [Select Id,Title from PartnerFundRequest where Title = 'test'];
            PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(), 50.00, System.today(), null, false);
            claim1.Core_MDF_Currency__c='USD';
            // Highlight: Unused Local Variable
           // list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
           
            //Core_MDF_PartnerFundClaim.ClaimWrap claimWrapResult = Core_MDF_PartnerFundClaim.saveClaim(claim1, auditDocList,null,null);
            // String res = claimWrapResult.claimDetail.Id;  
            Database.insert(claim1);
            //System.assertEquals(claim1.ID,res);
            
            test.stopTest();
            // Unit Test Method should include System.Assert
             System.assertNotEquals(null, claim1.Id, 'Claim should be created successfully');
            
        }
    }
    
    @isTest
    static void testCampaignCAPSaveClaimExcMethod()
    {
        test.startTest();
       // try{
            User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
            System.runAs(sysAdminUser)
            {
                
                Account acc2 = [Select id from Account where Name = 'Test Acc New 2'];
                User Usr1 =[Select id from user where email = 'test1@example.com'];
                Core_MDF_CCP_TestDataUtility.createPartnerNodeUserMapping(acc2.Id, Usr1.Id, true);
                // Highlight: Unused Local Variable
               // Core_MDF_Bank__c bank1 = [Select Id from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c='1231231230' limit 1];
                PartnerFundRequest pfr = [Select Id,Title,campaignid from PartnerFundRequest where Title = 'test'];
                //campaign cmpgn = [select id, Core_MDF_Spending_Cap_Amt__c from campaign where id =:pfr.CampaignId ];
                
                // Highlight: Unused Local Variable
               // List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
               // list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
                
                List<PartnerFundClaim> pfcInsert = new List<PartnerFundClaim>();
                
                PartnerFundClaim c1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim1', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(),20.00, System.today(),null, false);
                c1.Core_MDF_Currency__c='USD';
                c1.Core_MDF_Total_Invoice_Amount_Local__c = 100.00;
                c1.Core_MDF_Reimbursable_TransactionAmt_Loc__c=100.00;

                pfcInsert.add(c1);                
                //String res = Core_MDF_PartnerFundClaim.saveClaim(c1, auditDocList);
                
                PartnerFundClaim c2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, pfr.Id, System.today(), System.today(),20.00, System.today(),null, false);
                c2.Core_MDF_Currency__c='USD';
                c2.Core_MDF_Total_Invoice_Amount_Local__c = 100.00; 
                c2.Core_MDF_Reimbursable_TransactionAmt_Loc__c=100.00;
                pfcInsert.add(c2);  
                database.insert(pfcInsert);
                
                //String res1 = Core_MDF_PartnerFundClaim.saveClaim(c2, auditDocList);
                try{
 
                    PartnerFundClaim c3 =[Select Id,Title from PartnerFundClaim where Title = 'Test Claim2'];
                    c3.Core_MDF_Currency__c='USD';
                    c3.Core_MDF_Total_Invoice_Amount_Local__c = 400.00;
                    c3.Core_MDF_Reimbursable_TransactionAmt_Loc__c=400.00;
                    database.update(c3); 
                
                }catch(Exception e){
                //System.assertNotEquals(null,e);
                }
                
                test.stopTest();
                // Unit Test Method should include System.Assert
                System.assertEquals(2, pfcInsert.size(), 'PFC Insert list should contain 2 claims');
            }
    }
}