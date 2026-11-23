@isTest(SeeAllData=false)
public class Core_MDF_KPIDetailPage_test {
    
@TestSetUp
    static void createTestData(){
        
        
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc3.Core_Geo__c = 'APJ';
        acc3.Core_Sub_Geo__c = 'IJKK';
        insert acc3;
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
        acc4.Core_Geo__c = 'APJ';
        acc4.Core_Sub_Geo__c = 'IJKK';
        insert acc4;
        
        
        PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                       acc4.id, cp1.Id , 10000 , System.today()-60 , System.today() + 60 , 
                                                                                       false);
        
        testBudget1.IsIgnoreValidation = true;
        // testBudget1.RecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        insert testBudget1;
        testBudget1.Core_MDF_Budget_Status__c = 'Released';
        update testBudget1; 
        
        
        /*Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 24','Gaming','10ᵗʰ Gen', 
                                                                     Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                     'Client CoMarketing Fund', System.today()+1, //System.today().addDays(-300), 
                                                                     System.today()+300, 10000, 'Instore innovation', 
                                                                     acc4.Id,'Desktop', false);
        
        camp1.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        camp1.Core_MDF_Activity_Category_Type__c =null;
        camp1.Core_MDF_Program__c = 'Retail Marketing Funds';
        camp1.Core_MDF_Reimbursement_Rate__c='100%';
        camp1.Core_MDF_Technology__c = 'ACPC';*/
		Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 24','Gaming','Athena', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today(), 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', acc4.Id,'2-in-1', false);
        
        insert camp1;
        
        
    }
    
    
@isTest 
    static void runKPIDetailPagetest(){
        
        Integer pfrCount = 0;
        //Map<string,string> kPIRes = new Map<String,String>();
        Core_MDF_KPIDetailPage.KPIWrapper kPIRes= new Core_MDF_KPIDetailPage.KPIWrapper();
               
      
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
       
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
       
     //   try
       // {
           
            Test.startTest();
            System.runAs(usr1){
                
                date sdate = date.today();        
                
                Account acc4 = [select id from account where name = 'Test Account 4']; 
                Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
                
                PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData1'];
                
                List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
                //Test.startTest();
                
                /*PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(),acc4.Id,null,
                                                                                                                        testBudget,'ALBANIA','Gaming','Desktop','EVO','Broadcast',
                                                                                                                        'Podcast','Draft',false);*/
				PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),System.today(),System.today(),false);
				
                
                /* testPartnerFundRequestRecord.RecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(); */
                /*testPartnerFundRequestRecord.RequestedAmount = 250;
                testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Planned';
                sdate = system.today() + 12;
                //sdate = sdate.addDays(-170);
                testPartnerFundRequestRecord.Core_MDF_Start_Date__c = sdate;
                testPartnerFundRequestRecord.Core_MDF_End_Date__c = sdate.addDays(15);
                // testPartnerFundRequestRecord.Core_MDF_Magazine_Newspaper_txt__c = '100';
                // testPartnerFundRequestRecord.Core_MDF_Estimated_Ad_Size_nbr__c = 20;*/
                testPartnerFundRequestRecord.Core_MDF_Metrics_txt__c = '123';
                
                pfrtoinsert.add(testPartnerFundRequestRecord);
                Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
                insert testPartnerFundRequestRecord;
				System.debug(testPartnerFundRequestRecord.Id);
                kPIRes = Core_MDF_KPIDetailPage.getKPIvalues(testPartnerFundRequestRecord.Id,'PartnerFundRequest','Actual_Metrics');
                pfrCount += 1;
                
                Test.stopTest();
            } 
        //}
       // catch(Exception ex){
      //      System.debug(ex.getMessage());
      //  }
               
        
        System.assert(kPIRes.datamap.size()>0,'KPI values fetched');
    }

        
    @isTest 
    static void runKPIDetailPagetestforCase(){
        
        Integer pfrCount = 0;
        //Map<string,string> kPIRes = new Map<String,String>();
        Core_MDF_KPIDetailPage.KPIWrapper kPIRes= new Core_MDF_KPIDetailPage.KPIWrapper();

        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        PermissionSet ps1 = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
       
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps1.Id);
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps2.Id);
       
       // try
        //{
           
            Test.startTest();
            System.runAs(usr1){
                
                date sdate = date.today();  
                
			Account acc4 = [select id from account where name = 'Test Account 4']; 
                Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
                
                PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData1'];
                
                List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
                //Test.startTest();
                
                PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),System.today(),System.today(),false);
                
            /*    PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(),acc4.Id,null,
                                                                                                                        testBudget,'ALBANIA','Gaming','Desktop','10ᵗʰ Gen','Broadcast',
                                                                                                                        'Podcast','Draft',false); */
                
                /* testPartnerFundRequestRecord.RecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(); */
            /*    testPartnerFundRequestRecord.RequestedAmount = 250;
                testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Planned';
                sdate = system.today() + 12;
                //sdate = sdate.addDays(-170);
                testPartnerFundRequestRecord.Core_MDF_Start_Date__c = sdate;
                testPartnerFundRequestRecord.Core_MDF_End_Date__c = sdate.addDays(15);
                // testPartnerFundRequestRecord.Core_MDF_Magazine_Newspaper_txt__c = '100';
                // testPartnerFundRequestRecord.Core_MDF_Estimated_Ad_Size_nbr__c = 20; */
                testPartnerFundRequestRecord.Core_MDF_Metrics_txt__c = '123';

                pfrtoinsert.add(testPartnerFundRequestRecord);
                Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
                insert testPartnerFundRequestRecord;                
                
                            
			Id caseAuditRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Core_MDF_Audit').getRecordTypeId();
            Case cs = new Case();
            List<Case> caseList = new List<Case>();    
            cs.recordTypeId = caseAuditRecType;
            cs.AccountId = acc4.Id;
            cs.OwnerId = usr1.Id;
            cs.Core_MDF_Activity_ID__c = testPartnerFundRequestRecord.Id;                
            caseList.add(cs);
            Database.insert(caseList);
            System.debug('cs' + cs);
                                 
            kPIRes = Core_MDF_KPIDetailPage.getKPIvalues(cs.Id,'PartnerFundRequest','Planned_Metrics');     
            Test.stopTest();
            } 
      //  }
       // catch(Exception ex){
      //      System.debug(ex.getMessage());
     //   }
               
        
        System.assert(kPIRes.datamap.size()>0,'KPI for activity fetched');
    }
    
     @isTest 
    static void runKPIDetailPagetestforNull(){
        Test.startTest();
     	 //Map<string,string> kPIRes = new Map<String,String>();
          Core_MDF_KPIDetailPage.KPIWrapper kPIRes= new Core_MDF_KPIDetailPage.KPIWrapper();
         kPIRes = Core_MDF_KPIDetailPage.getKPIvalues(null,null,null);
        Test.stopTest();   
        System.assert(kPIRes.datamap.size()==0,'No KPI value fetched'); 
    }
    
}