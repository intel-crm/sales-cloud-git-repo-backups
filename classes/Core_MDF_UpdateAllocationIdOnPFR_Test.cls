@isTest
//This is a test class for Batch job Core_MDF_UpdateAllocationIdOnPFR
private class Core_MDF_UpdateAllocationIdOnPFR_Test {
    static List<PartnerFundRequest> testPartnerFundRequestRecordList = new List<PartnerFundRequest>();

    @TestSetup static void setUpData(){
        Profile itAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        // Creating User with utility class
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        usr.profileId = itAdminProfile.Id;
        Database.insert(usr);

        System.runAs(usr){
            //adding bypass feature to bypass access validation
			List<String> bypassFunctionKeys = new List<String>();
            bypassFunctionKeys.add('Bypass_MDF_Budget_Access_Validation');
            bypassFunctionKeys.add('Bypass_MDF_Budget_Status_Validation');
            
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            // Creating channel program with utility class
            ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
            //Creating DCF channel program 
            ChannelProgram cpDCF = Core_MDF_CCP_TestDataUtility.createProgram ('Data Center Co-Marketing Fund','Data Center CoMarketing Fund', true);
            Test.startTest();
            // Creating Intel Account with utility class
            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            acc1.Core_Account_Type__c = 'Reseller';
            acc1.Core_Sales_Groups__c = 'CCG Sales Group';
            acc1.Industry = 'Food & Beverage';
            acc1.Core_MDF_Channel_Program__c = cpCCF.Id;
            insert acc1; 
            
            // Creating Co-marketing Account with utility class
            Account accCCF = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account CCF', cpCCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accCCF.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            insert accCCF;
            
            //Creating DCF CO-marketing Account
            Account accDCF = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing DCF Test Account DCF', cpDCF.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            accDCF.Core_MDF_Parent_Fund_Account__c = acc1.Id;
            insert accDCF;
            
            // Creating campaigns using utility class
            Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes', 
                                                                        Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                        'Client CoMarketing Fund',System.today().addDays(5) , 
                                                                        System.today().addYears(1), 2000, 'Always Connected PC', accCCF.Id,'2-in-1', 
                                                                        true);
            
            // Creating campaigns using utility class
            Campaign campDcf = Core_MDF_CCP_TestDataUtility.createCampaign('TestCampdcf','Reseller','Intel® Xeon® Platinum Processor','Yes', 
                                                                           Core_MDF_CCP_TestDataUtility.Campaign_RecordType_DCF, 
                                                                           'Data Center CoMarketing Fund',System.today().addDays(5) , 
                                                                           System.today().addYears(1), 2000, 'Advanced Analytics', 
                                                                           accDCF.Id,'Server', true);
            
            
            
            // Creating activity without budget
            PartnerFundRequest testPartnerFundRequestObj = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),
                                                                                                                       Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                       string.valueof(accCCF.id),
                                                                                                                       NULL,NULL,'ALBANIA','Consumer',
                                                                                                                       'Desktop','Intel® Corporate Logo',
                                                                                                                       'Event','Promotion',
                                                                                                                       'Draft',false,true,
                                                                                                                       'Others','Test Other cpCCF');
            testPartnerFundRequestObj.RequestedAmount=100000000;
            testPartnerFundRequestObj.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestObj.Core_MDF_Start_Date__c = System.today() + 50;
            testPartnerFundRequestObj.Core_MDF_End_Date__c = System.today() + 50;
            insert testPartnerFundRequestObj;
            test.stopTest();
            
            //Creating Budget using utility class
            PartnerMarketingBudget testBudgetCCF = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataCCF',Core_MDF_CCP_TestDataUtility.budget_Record_Type, 
                                                                                          string.valueof(accCCF.id), cpCCF.Id , 10 , System.today() - 25 , 
                                                                                          System.today() + 45 , false);
            testBudgetCCF.Core_MDF_Budget_Type_Txt__c='CCF 1.0';
            insert testBudgetCCF;

            //Creating Budget using utility class
            PartnerMarketingBudget testBudgetDCF = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataDCF',Core_MDF_CCP_TestDataUtility.budget_Record_Type, 
                                                                                          string.valueof(accDCF.id), cpDCF.Id , 10 , System.today() - 25 , 
                                                                                          System.today() + 45 , false);
            testBudgetDCF.Core_MDF_Budget_Type_Txt__c='DCF 1.0';
            insert testBudgetDCF;
            
            
            // Creating Activity with budget using utility class
            
            for(Integer i = 0;i<5;i++){
                PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),
                                                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                                                              string.valueof(accCCF.id),
                                                                                                                              NULL,NULL,'ALBANIA','Consumer',
                                                                                                                              'Desktop','Intel® Corporate Logo',
                                                                                                                              'Event','Channel Partner Owned Event',
                                                                                                                              'Draft',false,true,
                                                                                                                              'Others'+i,'Test Other cpCCF');
                testPartnerFundRequestRecord.RequestedAmount=100000000 + i;
                testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Revision Required';
                testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today() + 30;
                testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today() + 30;
                testPartnerFundRequestRecordList.add(testPartnerFundRequestRecord);
            }
            
            //DCF pfrs
            for(Integer i = 0;i<5;i++){
                PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(campDcf.Id),
                                                                                                                              Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_DCF,
                                                                                                                              string.valueof(accDCF.id),
                                                                                                                              NULL,NULL,'ALBANIA','Reseller',
                                                                                                                              'Server','Intel® Xeon® Platinum Processor',
                                                                                                                              'Event','Channel Partner Owned Event',
                                                                                                                              'Draft',false,true,
                                                                                                                              'Others'+i,'Test Other cpCCF');
                testPartnerFundRequestRecord1.RequestedAmount=100000000 + i;
                testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Revision Required';
                testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = system.today() + 30;
                testPartnerFundRequestRecord1.Core_MDF_End_Date__c = system.today() + 30;
                testPartnerFundRequestRecordList.add(testPartnerFundRequestRecord1);
            }
            
            insert testPartnerFundRequestRecordList;
            
            testBudgetCCF.Core_MDF_Budget_Status__c = 'Released';
            update testBudgetCCF;

            testBudgetDCF.Core_MDF_Budget_Status__c = 'Released';
            update testBudgetDCF;
        }
    }
    
    /*This method generates Co-Marketing Activity records without allocationId and checks 
      whether these records are associated with AllocationId after running batch job */
    static testMethod void batchJobTestMethod() 
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            //Creating PFA using testData Utility
            //Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('CCF Allocation',testBudgetCCF,accCCF,10,true);
            PartnerMarketingBudget pmb = [SELECT Id
                                          FROM PartnerMarketingBudget
                                          WHERE Title = 'TestBudgetDataCCF'
                                          LIMIT 1];
            Account accCCF = [SELECT Id, Name
                              FROM Account
                              WHERE Name = 'Co-marketing Test Account CCF'];
            PartnerFundAllocation testPartnerFundAllocation = new PartnerFundAllocation(Title = 'CCF Allocation',
                                                                                        BudgetId = pmb.Id, 
                                                                                        ChannelPartnerId = accCCF.Id, 
                                                                                        Amount = 10);
            insert testPartnerFundAllocation;
            
            Test.startTest();
            
            /*Core_MDF_UpdateAllocationIdOnPFR batchClass = new Core_MDF_UpdateAllocationIdOnPFR();
            batchClass.fundAllocationCreation(new List<PartnerFundRequest> {testPartnerFundRequestRecordList[0]});*/
            Core_MDF_UpdateAllocationIdOnPFR obj = new Core_MDF_UpdateAllocationIdOnPFR();
            DataBase.executeBatch(obj); 
            
            Test.stopTest();
            
            //Checking if pfr records are associated with allocation Id
            List<Id> allocIdList = new List<Id>();
            for(PartnerFundRequest pfr : testPartnerFundRequestRecordList){
                if(pfr.AllocationId != NULL)
                    allocIdList.add(pfr.AllocationId);
            }
            
            System.assertNotEquals(allocIdList, NULL);
        }
    }

    static testMethod void batchJobTestMethod1() 
    {
        User sysAdminUser = [SELECT Id,Email from User where Email='sysadmin@example.com' limit 1];
        System.runAs(sysAdminUser){
            //Creating PFA using testData Utility
            
            Test.startTest();
            
            /*Core_MDF_UpdateAllocationIdOnPFR batchClass = new Core_MDF_UpdateAllocationIdOnPFR();
            batchClass.fundAllocationCreation(new List<PartnerFundRequest> {testPartnerFundRequestRecordList[0]});*/
            Core_MDF_UpdateAllocationIdOnPFR obj = new Core_MDF_UpdateAllocationIdOnPFR();
            DataBase.executeBatch(obj); 
            
            Test.stopTest();
            
            //Checking if pfr records are associated with allocation Id
            List<Id> allocIdList = new List<Id>();
            for(PartnerFundRequest pfr : testPartnerFundRequestRecordList){
                if(pfr.AllocationId != NULL)
                    allocIdList.add(pfr.AllocationId);
            }
            
            System.assertNotEquals(allocIdList, NULL);
        } 
    }
}