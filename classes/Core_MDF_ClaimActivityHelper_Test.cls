/****************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimActivityHelper_Test
* Version     : 1.0 
* Created Date: 22-Jan-2019
* Modification Log :
* Developer                        Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------

*****************************************************************************************************************************************/

@isTest
//This is a test class for Core_MDF_ClaimActivityHelper 
private class Core_MDF_ClaimActivityHelper_Test {
    
    @TestSetup 
    static void setUpData(){
        List<PartnerFundRequest> testPartnerFundRequestRecordList = new List<PartnerFundRequest>();
        List<Account> accountList = new List<Account>();
        List<Campaign> campaignList = new List<Campaign>();
        List<ChannelProgram> channelProgramList = new List<ChannelProgram>();
        List<PartnerMarketingBudget> budgetList= new List<PartnerMarketingBudget>();
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        // Creating User with utility class
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.profileId = adminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            // Creating channel program with utility class
            ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', false);
            channelProgramList.add(cpCCF);
            //Creating DCF channel program 
            ChannelProgram cpDCF = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', false);
            channelProgramList.add(cpDCF);
            
            database.insert(channelProgramList);

            // Creating Intel Account with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'US Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cpCCF.Id;
            acc1.Core_MDF_CoMarketingActive__c = true;
            insert acc1; 
            
            // Creating Co-marketing Account with utility class
            Account accCCF = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account CCF', cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accCCF.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accCCF.Core_MDF_CoMarketingActive__c = true;
            //insert accCCF;
            accountList.add(accCCF);
            
            //Creating DCF CO-marketing Account
            Account accDCF = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account DCF', cpDCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accDCF.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            accDCF.Core_MDF_CoMarketingActive__c = true;
            //insert accDCF;
            accountList.add(accDCF);
            
            database.insert(accountList);            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund',System.today(), 
                                                                        System.today().addYears(1), 2000, 'Unite', accCCF.Id,'2-in-1', 
                                                                        false);
            campaignList.add(camp);
            
            // Creating campaigns using utility class
            Campaign campDcf = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampdcf','Reseller','Intel® Xeon® Platinum Processor', 
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 
                                                                           'Data Center CoMarketing Fund',System.today() , 
                                                                           System.today().addYears(1), 2000, 'Advanced Analytics', 
                                                                           accDCF.Id,'Server', false);
            
            campaignList.add(campDcf);            
            database.insert(campaignList);
            
            //Creating Budget using utility class
            PartnerMarketingBudget testBudgetCCF = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataCCF',Core_MDF_CCP_TestDataUtility.budget_Record_Type, 
                                                                                             string.valueof(accCCF.id), cpCCF.Id , 10000 , System.today() - 25 , 
                                                                                             System.today() + 45 , false);
            budgetList.add(testBudgetCCF);
            
            //Creating Budget using utility class
            PartnerMarketingBudget testBudgetDCF = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataDCF',Core_MDF_CCP_TestDataUtility.budget_Record_Type, 
                                                                                             string.valueof(accDCF.id), cpDCF.Id , 10000 , System.today() - 25 , 
                                                                                             System.today() + 45 , false);
            budgetList.add(testBudgetDCF);
            database.insert(budgetList);
            
            
            // Creating Activity with budget using utility class
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),
                                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                          string.valueof(accCCF.id),
                                                                                                                          NULL,NULL,'ALBANIA','Consumer',
                                                                                                                          'Desktop','Intel® Corporate Logo',
                                                                                                                          'Event','Channel Partner Owned Event',
                                                                                                                          'Draft',false,true,
                                                                                                                          'Others','Test Other cpCCF');
            
            testPartnerFundRequestRecord.RequestedAmount=10;
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today();
            testPartnerFundRequestRecordList.add(testPartnerFundRequestRecord);
            
            Test.startTest();
            //DCF pfr with Budget
            PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(campDcf.Id),
                                                                                                                           Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                                                           string.valueof(accDCF.id),
                                                                                                                           NULL,NULL,'ALBANIA','Reseller',
                                                                                                                           'Server','Intel® Xeon® Platinum Processor',
                                                                                                                           'Event','Channel Partner Owned Event',
                                                                                                                           'Draft',false,true,
                                                                                                                           'Others','Test Other cpCCF');
            testPartnerFundRequestRecord1.RequestedAmount=10000;
            testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord1.Core_MDF_End_Date__c = system.today();
            testPartnerFundRequestRecordList.add(testPartnerFundRequestRecord1);
            
            database.insert(testPartnerFundRequestRecordList);
            
            testBudgetCCF.Core_MDF_Budget_Status__c = 'Released';
            update testBudgetCCF;
            
            testBudgetDCF.Core_MDF_Budget_Status__c = 'Released';
            update testBudgetDCF;
            Test.stopTest();
        }
    }
    
    /*This Method Inserts the Claim and Processes the CCF Activities  */
    @isTest
    static void testProcessCCFActivities() 
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Campaign camp = [SELECT ID FROM CAMPAIGN WHERE Name='TestCamp' LIMIT 1];
            //Creating PFA using testData Utility
            PartnerMarketingBudget pmb = [SELECT Id
                                          FROM PartnerMarketingBudget
                                          WHERE Title = 'TestBudgetDataCCF'
                                          LIMIT 1];
            Account acc1 = [SELECT Id,Name FROM Account WHERE Name='Test Account 1' LIMIT 1];
            Account accCCF = [SELECT Id, Name
                              FROM Account
                              WHERE Name = 'Co-marketing Test Account CCF'];
            PartnerFundAllocation testPartnerFundAllocation = new PartnerFundAllocation(Title = 'CCF Allocation',
                                                                                        BudgetId = pmb.Id, 
                                                                                        ChannelPartnerId = accCCF.Id, 
                                                                                        Amount = 10);
            insert testPartnerFundAllocation;
            
            String ccfPfrID = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF;  
            PartnerFundRequest indiaActivity = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE RecordTypeId=:ccfPfrID  LIMIT 1];
            Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', true,'1231231230');
            
            
            //creating ABM for bank1
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accCCF.Id,indiaBank.Id,true);
            
            Test.startTest();
            PartnerFundClaim indiaClaim = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   indiaActivity.Id, 
                                                                                   indiaActivity.Core_MDF_Start_Date__c, indiaActivity.Core_MDF_Start_Date__c, 
                                                                                   100, 
                                                                                   System.today(), indiaBank.ID, false);
            indiaClaim.Core_MDF_Currency__c = 'USD';
            insert indiaClaim;
            PartnerFundRequest uptdAct = [SELECT Id,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,RecordTypeId,BudgetId,Status,Core_MDF_Fund_Request_Status__c FROM PartnerFundRequest WHERE Id=:indiaClaim.RequestId Limit 1];
            System.assertEquals(uptdAct.Status,'Approved');
            delete indiaClaim;
            delete indiaActivity;
            PartnerFundRequest indiaActivity2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),
                                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                            string.valueof(accCCF.id),
                                                                                                            NULL,NULL,'ALBANIA','Consumer',
                                                                                                            'Desktop','Intel® Corporate Logo',
                                                                                                            'Event','Channel Partner Owned Event',
                                                                                                            'Draft',false,true,
                                                                                                            'Others','Test Other cpCCF');
            indiaActivity2.RequestedAmount=10;
            indiaActivity2.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            indiaActivity2.Core_MDF_Start_Date__c = system.today();
            indiaActivity2.Core_MDF_End_Date__c = system.today();
            insert indiaActivity2; 
            
            
            PartnerFundAllocation pfa = [Select id,budgetId from PartnerFundAllocation where budgetId =:pmb.Id];
            System.assertNotEquals(pfa.Id,NULL);
            delete indiaActivity2;
            delete pfa;
            delete pmb;
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),
                                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                          string.valueof(accCCF.id),
                                                                                                                          NULL,NULL,'ALBANIA','Consumer',
                                                                                                                          'Desktop','Intel® Corporate Logo',
                                                                                                                          'Event','Channel Partner Owned Event',
                                                                                                                          'Draft',false,true,
                                                                                                                          'Others','Test Other cpCCF');
            testPartnerFundRequestRecord.RequestedAmount=10000;
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today();
            insert testPartnerFundRequestRecord; 
            
            PartnerFundClaim indiaClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    testPartnerFundRequestRecord.Id, 
                                                                                    testPartnerFundRequestRecord.Core_MDF_Start_Date__c, testPartnerFundRequestRecord.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim1.Core_MDF_Currency__c = 'USD';
            Test.stopTest();
            
            try{
                insert indiaClaim1;    
            }catch(Exception e){
                String emsg = e.getMessage();
                System.assert(emsg.contains(System.Label.Core_MDF_No_Budget_Exist));
            } 
            
        }
    }
    
    /* This Method Inserts the Claim and Processes the DCF Activities */
    @isTest
    static void testProcessDCFActivities() 
    {
        System.debug('Number of Queries used in this apex code so far1:: ' + Limits.getQueries());
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            Campaign campDcf = [SELECT ID FROM CAMPAIGN WHERE Name='TestCampdcf' LIMIT 1];
            //Creating PFA using testData Utility
            
            PartnerMarketingBudget pmb = [SELECT Id
                                          FROM PartnerMarketingBudget
                                          WHERE Title = 'TestBudgetDataDCF'
                                          LIMIT 1];
            Account acc1 = [SELECT Id,Name FROM Account WHERE Name='Test Account 1' LIMIT 1];
            Account accDCF = [SELECT Id, Name
                              FROM Account
                              WHERE Name = 'Co-marketing Test Account DCF'];
            
            String dcfPfrID = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF;
            
            Core_MDF_Bank__c indiaBank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Data_Center_CoMarketing_Fund', true,'1231231230');
            indiaBank.Core_MDF_Program__c = 'Core_MDF_Data_Center_CoMarketing_Fund';
			update indiaBank;
            
            //creating ABM for bank1
            Core_MDF_Account_Bank_Mapping__c abm1 = Core_MDF_CCP_TestDataUtility.createAccountBankMap(accDCF.Id,indiaBank.Id,true);
            
            Test.startTest();
            
            List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
            
            PartnerFundRequest indiaActivity2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(campDcf.Id),
                                                                                                            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                                            string.valueof(accDCF.id),
                                                                                                            NULL,NULL,'ALBANIA','Reseller',
                                                                                                            'Server','Intel® Xeon® Platinum Processor',
                                                                                                            'Event','Channel Partner Owned Event',
                                                                                                            'Draft',false,true,
                                                                                                            'Others','Test Other cpCCF');
            indiaActivity2.RequestedAmount=10000;
            indiaActivity2.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            indiaActivity2.Core_MDF_Start_Date__c = system.today();
            indiaActivity2.Core_MDF_End_Date__c = system.today();
            insert indiaActivity2; 
            
            PartnerFundClaim indiaClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                    indiaActivity2.Id, 
                                                                                    indiaActivity2.Core_MDF_Start_Date__c, indiaActivity2.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim2.Core_MDF_Currency__c = 'USD';
                        
            claimList.add(indiaClaim2);
            database.insert(claimList);
            delete indiaClaim2;
            
            PartnerFundAllocation pfa = [Select id,budgetId from PartnerFundAllocation where budgetId =:pmb.Id];
            System.assertNotEquals(pfa.Id,NULL);
            delete indiaActivity2;
            delete pfa;
            delete pmb;
            
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(campDcf.Id),
                                                                                                                          Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                                                          string.valueof(accDCF.id),
                                                                                                                          NULL,NULL,'ALBANIA','Reseller',
                                                                                                                          'Server','Intel® Xeon® Platinum Processor',
                                                                                                                          'Event','Channel Partner Owned Event',
                                                                                                                          'Draft',false,true,
                                                                                                                          'Others','Test Other cpCCF');
            testPartnerFundRequestRecord.RequestedAmount=10000;
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today();
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today();
            
            insert testPartnerFundRequestRecord;   
            
            PartnerFundClaim indiaClaim1 = Core_MDF_CCP_TestDataUtility.createClaim('India Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_DCF, 
                                                                                    testPartnerFundRequestRecord.Id, 
                                                                                    testPartnerFundRequestRecord.Core_MDF_Start_Date__c, testPartnerFundRequestRecord.Core_MDF_Start_Date__c, 
                                                                                    100, 
                                                                                    System.today(), indiaBank.ID, false);
            indiaClaim1.Core_MDF_Currency__c = 'USD';
            try{
                insert indiaClaim1;    
            }catch(Exception e){
                String emsg = e.getMessage();
                System.assert(emsg.contains(System.Label.Core_MDF_No_Budget_Exist));
            } 
            Test.stopTest();
        }
    }
}