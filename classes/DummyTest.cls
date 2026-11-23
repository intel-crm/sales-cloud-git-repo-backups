@isTest public class DummyTest {
    @TestSetUp
    static void createTestData(){
        
        //Test.startTest();
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        //List<Account> accList = new List<Account>();
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        //accList.add(acc1);
      insert acc1;
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
        //accList.add(acc2);
      insert acc2;
        
       PartnerMarketingBudget testBudget = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      acc2.id, cp.Id , 10000 ,  Date.newInstance(2021, 01, 01), Date.newInstance(2021, 06, 29) , 
                                                                                     true);
       // testBudget.IsIgnoreValidation = true;
        testBudget.Core_MDF_Budget_Type_Txt__c = 'CCF 1.0';
        insert testBudget;
        testBudget.Core_MDF_Budget_Status__c = 'Released';
        update testBudget;  
        PartnerMarketingBudget testBudgetOem = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetDataOEMCMP',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                      acc2.id, cp.Id , 10000 ,  Date.newInstance(2021, 01, 01), Date.newInstance(2021, 06, 29) , 
                                                                                      false);
        testBudgetOem.IsIgnoreValidation = true;
        testBudgetOem.Core_MDF_Budget_Type_Txt__c = 'OEM CMP';
        insert testBudgetOem;
        testBudgetOem.Core_MDF_Budget_Status__c = 'Released';
        update testBudgetOem;
        PartnerMarketingBudget testBudgetOemId = [select id from PartnerMarketingBudget where Title ='TestBudgetDataOEMCMP'];
        Core_MDF_Campaign_Budgets__c CampOEMBudget = new Core_MDF_Campaign_Budgets__c(Core_MDF_Reimbursement_Amt__c=500,Core_MDF_Budget_Name_Id__c=testBudgetOem.Id, Core_MDF_Reimbursement_Rate_Pct__c='50%');
        insert CampOEMBudget; 

        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', 'Yes',
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                    'Client CoMarketing Fund', Date.newInstance(2021, 01, 01), //System.today().addDays(-300), 
                                                                    Date.newInstance(2021, 12, 29), 10000, 'Always Connected PC', //date.valueOf('2020-12-30')
                                                                    acc2.Id,'Desktop', true);
        
        Campaign ccfCamp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp CCF','Gaming','Intel® Core™ i7 Processor', 'Yes',
                                                                    Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                    'Client CoMarketing Fund', Date.newInstance(2021, 01, 01), //System.today().addDays(-300), 
                                                                    Date.newInstance(2021, 12, 29), 10000, 'Always Connected PC', //date.valueOf('2020-12-30')
                                                                    acc2.Id,'Desktop', false);
        ccfCamp.Core_MDF_Opal_Budget_Type_Txt__c= 'CCF 1.0';
        Database.insert(ccfCamp);
        
        //Code for Retail begins
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        
        Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        acc3.Core_Geo__c = 'APJ';
        acc3.Core_Sub_Geo__c = 'IJKK';
        acc3.Core_Account_Country__c = 'JAPAN';
        insert acc3;
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
        acc4.Core_Geo__c = 'APJ';
        acc4.Core_Sub_Geo__c = 'IJKK';
        insert acc4;
  
        
        System.debug('SOQL used: ' + Limits.getQueries());
        PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Retail_Record_Type,
                                                                                       acc4.id, cp1.Id , 10000 , System.today()-60 , System.today() + 60 , 
                                                                                       false);
        
        testBudget1.IsIgnoreValidation = true;
        testBudget1.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
        // testBudget1.RecordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        insert testBudget1;
        testBudget1.Core_MDF_Budget_Status__c = 'Released';
         Test.startTest();
        update testBudget1;
        List<Campaign> cmplst = new List<Campaign>();
        Campaign camp1 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 24','Gaming','Athena', 'Yes',
                                                                     Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                     'Client CoMarketing Fund', System.today()-100, //System.today().addDays(-300), 
                                                                     System.today()+100, 10000, 'Instore innovation', 
                                                                     acc4.Id,'Desktop', false);
        
        camp1.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        camp1.Core_MDF_Activity_Category_Type__c =null;
        camp1.Core_MDF_Program__c = 'Retail Marketing Funds';
        camp1.Core_MDF_Reimbursement_Rate__c='100%';
        camp1.Core_MDF_Technology__c = 'ACPC';
        //Test.startTest();
        //insert camp1;
    cmplst.add(camp1);

        //Campaign for Japan cycle
        Campaign camp6 = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 45','Gaming','Athena', 'Yes',
                                                                     Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                     'Client CoMarketing Fund', system.today()+ 2, //System.today().addDays(-300), 
                                                                     System.today()+230, 10000, 'Instore innovation', 
                                                                     acc4.Id,'Desktop', false);
        
        camp6.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
        camp6.Core_MDF_Activity_Category_Type__c =null;
        camp6.Core_MDF_Program__c = 'Retail Marketing Funds';
        camp6.Core_MDF_Reimbursement_Rate__c='100%';
        camp6.Core_MDF_Technology__c = 'ACPC';

        //insert camp6;
    cmplst.add(camp6);
   
    insert cmplst;
        //Code for IPA starts
        ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
        Account ipaUltimateAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        System.debug('SOQL used: ' + Limits.getQueries());    
        Account ipaCoMarketingAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('IPA Co-Marketing Account', ipaCP.id, Core_MDF_CCP_TestDataUtility.Account_Record_Type,ipaUltimateAccount.id, true);           
        System.debug('SOQL used: ' + Limits.getQueries());
        String budgetType = Core_MDF_CCP_IPA_TestDataUtility.createBenefit(ipaCoMarketingAccount);
        System.debug('SOQL used: ' + Limits.getQueries());
        Campaign ipaCampaignForAP = Core_MDF_CCP_IPA_TestDataUtility.createIPACampaign('Test Campaign - AP',ipaCoMarketingAccount.id, System.today(), System.today().adddays(30),budgetType, 110000,'INDIA', 'Channel Partner', 'Apollo Lake', 'Planned', true);
        System.debug('SOQL used: ' + Limits.getQueries());
        Test.stopTest();   
    }
    
    @isTest 
    static void runRegionTest(){
        Integer pfrCount = 0;
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail LIMIT 1];
       
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
       
        try
        {
           
            
            System.runAs(usr1){
                Test.startTest();
                date sdate = date.today();        
                
                Account acc4 = [select id from account where name = 'Test Account 4']; 
                Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
                
                PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData1'];
                
                List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
                
                 Date strDate = system.today() + 20;
                Date edDate = strDate + 1; 
               /* PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(),acc4.Id,null,
                                                                                                                        testBudget,'ALBANIA','Gaming','Desktop','Athena','Online',
                                                                                                                        'Customer.com','Draft',false);*/
                PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),strDate,edDate,false); 
            
              
                
                testPartnerFundRequestRecord1.Core_MDF_Start_Date__c = strdate;
                testPartnerFundRequestRecord1.Core_MDF_End_Date__c = edDate;
                testPartnerFundRequestRecord1.RequestedAmount = 100;
                testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = '';
                testPartnerFundRequestRecord1.Core_MDF_Country_nm__c = 'AFGHANISTAN'+';BANGLADESH';
               //testPartnerFundRequestRecord1.Core_MDF_Region_cd__c = 'APJ';
                pfrtoinsert = new List<PartnerFundRequest>();
                pfrtoinsert.add(testPartnerFundRequestRecord1);
                //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
                
               /* PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(),acc4.Id,null,
                                                                                                                        testBudget,'ALBANIA','Gaming','Desktop','Athena','Online',
                                                                                                                        'Customer.com','Draft',false);
              */
                 PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),strDate,edDate,false); 
            
              
                strDate = system.today() + 20;
                edDate = strDate + 1;
                testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = strdate;
                testPartnerFundRequestRecord2.Core_MDF_End_Date__c = edDate;
                testPartnerFundRequestRecord2.RequestedAmount = 100;
                testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = '';
                testPartnerFundRequestRecord2.Core_MDF_Country_nm__c = 'ALBANIA'+';BANGLADESH';
                pfrtoinsert = new List<PartnerFundRequest>();
                pfrtoinsert.add(testPartnerFundRequestRecord2);
                
               // Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
                
                testPartnerFundRequestRecord2.Core_MDF_Country_nm__c = 'ARGENTINA';
                pfrtoinsert = new List<PartnerFundRequest>();
                pfrtoinsert.add(testPartnerFundRequestRecord2);
                //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
                
                Test.stopTest();
            } 
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Geo') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
               
    }
    
    //Code for Retail begins
    @isTest 
    static void runRetailActivityTest(){
        
        Integer pfrCount = 0;
        Test.startTest();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
        PermissionSet psGeoApprvr = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver' LIMIT 1];
       
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = psGeoApprvr.Id);
       
         try
        {
           
            
            System.runAs(usr1){
                
                date sdate = date.today();        
                
                Account acc4 = [select id from account where name = 'Test Account 4']; 
                Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
                
                PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData1'];
                
                List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
                
                /*PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(),acc4.Id,null,
                                                                                                                        testBudget,'ALBANIA','Gaming','Chromebook','10ᵗʰ Gen','Event',
                                                                                                                        'Joint Event','Draft',false);
                */
                 PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),system.today() - 2, system.today(),false); 
            
                testPartnerFundRequestRecord.RequestedAmount = 250;
                pfrtoinsert.add(testPartnerFundRequestRecord);
                //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
                insert testPartnerFundRequestRecord;
                pfrCount += 1;
                //testPartnerFundRequestRecord.Core_MDF_Program__c = 'Retail Marketing Funds';
                testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Pending Review';
                testPartnerFundRequestRecord.RequestedAmount = 2500;
                testPartnerFundRequestRecord.Core_MDF_Approval_Step_Completed__c = 1;
                testPartnerFundRequestRecord.Core_MDF_Price_reviewer_check_ind__c = False;
                update testPartnerFundRequestRecord;
                //Core_MDF_UpdateActivityFields.setStatusRetailExternal(testPartnerFundRequestRecord);
                Test.stopTest();
            } 
         }
        catch(Exception ex){
            
            Boolean expectedExceptionThrown =  ex.getMessage().contains('The start date of an activity cannot be prior to') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    //Code for Retail ends 
    
    @isTest 
    static void runCloseActivityTest(){
        //     boolean hasAccess = false;
        Integer pfrCount = 0;
        List<PartnerFundRequest> vpfrList = new List<PartnerFundRequest>();
        
        //   PermissionSet accountManager = [SELECT Id FROM permissionset where name = 'Core_MDF_CCP_Internal_CCF_Account_Manager' limit 1];
        
        // Creating User with utility class 
        //    User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        //    Database.insert(usr1);
        
        //        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = accountManager.Id, AssigneeId = usr1.Id);
        //        Database.upsert(psa);
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        System.runAs(usr1){
            
            date sdate = date.today();
            
            Test.startTest();
            Account acc2 = [select id from account where name = 'Test Account 2']; 
            Campaign camp = [select id from Campaign where name = 'Test Camp 12' limit 1];
            
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
            
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            
            // Create a pfr for the dates the way which is not crossed the 180 days
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                    testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                    'Member Participation in Third-Party Event','Draft',false);
            testPartnerFundRequestRecord.RequestedAmount = 250;
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Planned';
            sdate = system.today() + 1;
            //sdate = sdate.addDays(-170);
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today() + 1;
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today() + 1;
            //system.debug('###s date' + testPartnerFundRequestRecord.Core_MDF_Start_Date__c);
            //system.debug('###e date' + testPartnerFundRequestRecord.Core_MDF_End_Date__c
            pfrtoinsert.add(testPartnerFundRequestRecord);
            //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
            insert testPartnerFundRequestRecord;
            pfrCount += 1;
            
            PartnerFundRequest pfr21 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                    testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                    'Member Participation in Third-Party Event','Draft',false);
            List<PartnerFundRequest> pfrtoinsert1 = new List<PartnerFundRequest>();
            pfr21.RequestedAmount = 250;
            pfr21.Core_MDF_Fund_Request_Status__c = 'Planned';
            sdate = system.today() + 1;
            pfr21.Core_MDF_Start_Date__c = sdate;
            pfr21.Core_MDF_End_Date__c = sdate;
            pfr21.Core_MDF_Country_nm__c = 'ALBANIA';
            pfrtoinsert1.add(pfr21);
            //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert1);
            insert pfr21;
            
            // Update the end date
            Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfr1 = [select id,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF LIMIT 1];
            pfr1.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            pfrMap.put(pfr1.Id,pfr1);
            //Core_MDF_UpdateActivityFields.populateBackEndFieldsUpdate(pfrMap,null);
             
            
            pfrCount += 1;
            
            pfrMap = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfr2 = [select id,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF  LIMIT 1];
            pfr2.Core_MDF_Fund_Request_Status__c = 'Cancelled';
            pfrMap.put(pfr2.Id,pfr2);
            //Core_MDF_UpdateActivityFields.populateBackEndFieldsUpdate(pfrMap,null);
            pfrCount += 1;
            
            Map<Id,PartnerFundRequest> pfrMap1 = new Map<Id,PartnerFundRequest>();
            Map<Id,PartnerFundRequest> pfrMap2 = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfr3 = [select id,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF  LIMIT 1];
            
            PartnerFundRequest pfr4 = [select id,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF  LIMIT 1];
            pfr3.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr3.Core_MDF_Budget_Amount_Local_amt__c = 100000;
            pfr4.Core_MDF_Fund_Request_Status__c = 'Cancelled';
            pfrMap1.put(pfr3.Id,pfr3);
            pfrMap2.put(pfr4.Id,pfr4);
            //Core_MDF_UpdateActivityFields.populateBackEndFieldsUpdate(pfrMap1,pfrMap2);
            
            pfrCount += 1;
            
            //system.debug('Methodcall reached##');
            pfrMap = new Map<Id,PartnerFundRequest>();
            pfrMap1 = new Map<Id,PartnerFundRequest>();
            PartnerFundRequest pfrcancel = [select id,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c from PartnerFundRequest where title =: 'test' and recordtypeid =: Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF  LIMIT 1];
            PartnerFundRequest pfrclose = pfrcancel;
            pfrcancel.Core_MDF_Fund_Request_Status__c = 'Cancelled';
            pfrclose.Core_MDF_Fund_Request_Status__c = 'Closed';
            pfrMap.put(pfrclose.Id,pfrclose);
            pfrMap1.put(pfrcancel.Id,pfrcancel);
           // Core_MDF_UpdateActivityFields.populateBackEndFieldsUpdate(pfrMap,pfrMap1);
            
            Test.stopTest();
        }
        System.assert(pfrCount >= 2);
    }
    
    @isTest 
    static void activityEventTest(){
        
        //       boolean hasAccess = false;
        Integer pfrCount = 0;
        //      Profile itAdminProfile = [SELECT Id FROM Profile WHERE Name='IT Admin'];
        // Creating User with utility class 
        //     User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        //     usr2.profileId = itAdminProfile.Id;
        //    insert usr2;
        UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        Database.insert(usr2);
        try{
            System.runAs(usr2){
                
                Test.startTest();
                
                Account acc2 = [select id from account where name = 'Test Account 2']; 
                Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', 
                                                                            Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                            'Client CoMarketing Fund', system.today(), //System.today().addDays(-300), 
                                                                            date.valueOf('2020-12-30'), 10000, 'Always Connected PC', 
                                                                            acc2.Id,'Desktop', true); 
                
                Campaign camp1 = [select id from Campaign where name = 'Test Camp 13' limit 1];
                
                PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
                
                List<PartnerFundRequest> pfrtoinsert1 = new List<PartnerFundRequest>();
                /*List<Core_MDF_PFR_Event_Rule__mdt> metadataList = [SELECT Id, Core_MDF_PFR_RecordType__c,Core_MDF_Country_Picklist_Value__c, Core_MDF_Activity_Category__c, Core_MDF_Requested_Amount__c, Core_MDF_Activity_Types__c, 
                                                                   Core_MDF_Day_Difference__c, Core_MDF_PFR_RecordType_Id__c, Core_MDF_PFR_StartDate__c, Core_MDF_Amount_Operator__c, Core_MDF_Days_Difference_Operator__c, Core_MDF_Error_Message__c FROM Core_MDF_PFR_Event_Rule__mdt];*/
                List<Core_MDF_CCP_Country_Geo_Mapping__mdt> countryGeoMetaData = [SELECT Id, MasterLabel, Core_MDF_Geo__c FROM Core_MDF_CCP_Country_Geo_Mapping__mdt];
                
                //Test.startTest();
                
                PartnerFundRequest testPartnerFundRequestRecord2 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp1.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                         testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                         'Member Participation in Third-Party Event','Draft',false);
                
                Date stDate = date.valueOf('2019-10-25');
                Date endDate = date.valueOf('2019-11-02');
                Date nstDate = date.valueOf('2019-11-29');
                //testPartnerFundRequestRecord2.RecordType.DeveloperName = 'Core_MDF_Client_CoMarketing_Fund';
                testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = stdate;
                testPartnerFundRequestRecord2.Core_MDF_End_Date__c = endDate;
                testPartnerFundRequestRecord2.RequestedAmount = 16250;
                testPartnerFundRequestRecord2.Core_MDF_Fund_Request_Status__c = 'Planned';
                testPartnerFundRequestRecord2.Core_MDF_Country_nm__c = 'United Kingdom';
              // testPartnerFundRequestRecord2.Core_MDF_Region_cd__c = 'APJ';
                Date todaysDate = System.today();
                Integer daysDifference = 8;
                Id recordTypeId = Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Client_CoMarketing_Fund_Boost').getRecordTypeId();
                PartnerFundRequest testPartnerFundRequestRecord3 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp1.id,recordTypeId,acc2.Id,null,
                                                                                                                         testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                         'Promotion','Draft',false);
                
                Date strDate = date.valueOf('2020-01-25');
                Date edDate = date.valueOf('2020-02-02');
                Date newstDate = date.valueOf('2020-01-29');
                // testPartnerFundRequestRecord3.RecordType.DeveloperName = 'Core_MDF_Client_CoMarketing_Fund';
                testPartnerFundRequestRecord3.Core_MDF_Start_Date__c = strdate;
                testPartnerFundRequestRecord3.Core_MDF_End_Date__c = edDate;
                testPartnerFundRequestRecord3.RequestedAmount = 66250;
                testPartnerFundRequestRecord3.Core_MDF_Fund_Request_Status__c = 'Planned';
                testPartnerFundRequestRecord3.Core_MDF_Country_nm__c = 'United Kingdom'+';China';
                //testPartnerFundRequestRecord3.Core_MDF_Region_cd__c = 'APJ';
                Date todaysDt = System.today();
                pfrtoinsert1.add(testPartnerFundRequestRecord2);
                pfrtoinsert1.add(testPartnerFundRequestRecord3);
                //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert1);  
                //insert testPartnerFundRequestRecord2;
                //insert testPartnerFundRequestRecord3;
                testPartnerFundRequestRecord2.Core_MDF_Start_Date__c = nstDate;
                //update testPartnerFundRequestRecord2;                
                   
                Test.stopTest();
            }
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Countries selected') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        
        
    }
    
    static void retailApprovalTest(){
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        try{
        Database.insert(usr1);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: Label.Core_MDF_Custom_Permission_IAM_Retail];
        
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id); 
        System.runAs(usr1){
            date sdate = date.today();        
            
            Account acc4 = [select id from account where name = 'Test Account 4']; 
            Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
            
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData1'];
            
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            Test.startTest();
            
            /*PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Schema.SObjectType.PartnerFundRequest.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId(),acc4.Id,null,
                                                                                                                    testBudget,'ALBANIA','Gaming','Desktop','Athena','Event',
                                                                                                                    'General (Customer-owned)','Draft',false);
            */
            sdate = system.today()-1;
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),sdate,sdate.addDays(15),false); 
      
            testPartnerFundRequestRecord.RequestedAmount = 250;
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            testPartnerFundRequestRecord.Core_MDF_Approval_Step_Completed__c = 0;
            pfrtoinsert.add(testPartnerFundRequestRecord);
           // Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
            insert testPartnerFundRequestRecord;
            ProcessInstance pi = [SELECT TargetObjectId
                                       FROM ProcessInstance
                                       WHERE TargetObjectId =: testPartnerFundRequestRecord.Id
                                       AND Status = 'Pending'];
            insert pi;
        }
     }
            catch(Exception ex)
            {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            
        
    }
    
   @isTest 
    static void runRetailAutoClosureTest(){
        
        Integer pfrCount = 0;
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
       
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
       
         System.runAs(usr1)
        {
            Test.startTest();
            date sdate = date.today();        
            Account acc4 = [select id from account where name = 'Test Account 4']; 
            Campaign camp = [select id from Campaign where name = 'Test Camp 24' limit 1];
            
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),sdate, sdate.addDays(1),false); 
            
            testPartnerFundRequestRecord.RequestedAmount = 250;
            pfrtoinsert.add(testPartnerFundRequestRecord);
            //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
            insert testPartnerFundRequestRecord;
            
            Map<Id,PartnerFundRequest> oldPfrMap = new Map<Id,PartnerFundRequest>();
            Map<Id,PartnerFundRequest> newMap = new Map<Id,PartnerFundRequest>();
            
            oldPfrMap.put(testPartnerFundRequestRecord.Id,testPartnerFundRequestRecord);
            
            PartnerFundRequest updatepfr = [select id,Core_MDF_Budget_Type_nm__c,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c,Core_MDF_Activity_First_Approver_txt__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Country_nm__c from PartnerFundRequest where title =: 'Test Retail' and recordtypeid =: Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail  LIMIT 1];
            
            updatepfr.Core_MDF_End_Date__c =  sdate.addDays(1);
            updatepfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            updatepfr.Core_MDF_Budget_Type_nm__c = 'Retail MDF';
            newMap.put(updatepfr.Id,updatepfr);
           // Core_MDF_UpdateActivityFields.populateBackEndFieldsUpdate(newMap,oldPfrMap);
            update updatepfr;
            oldPfrMap = new Map<Id,PartnerFundRequest>();
            oldPfrMap.put(updatepfr.Id,updatepfr);
            
            PartnerFundRequest updatepfr1 = [select id,Core_MDF_Budget_Type_nm__c,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c,Core_MDF_Activity_First_Approver_txt__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Country_nm__c from PartnerFundRequest where title =: 'Test Retail' and recordtypeid =: Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail  LIMIT 1];
            updatepfr1.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            newMap = new Map<Id,PartnerFundRequest>();
            newMap.put(updatepfr1.Id,updatepfr1);
            //Core_MDF_UpdateActivityFields.populateBackEndFieldsUpdate(newMap,oldPfrMap);            
            
            pfrCount += 1;
            
            // Japan country creation
            PartnerFundRequest JapanPFR = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),sdate, sdate.addDays(1),false); 
            
            JapanPFR.Core_MDF_Budget_Type_nm__c = 'RSA MD';
            pfrtoinsert = new List<PartnerFundRequest>();
            pfrtoinsert.add(JapanPFR);
            //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
            //insert JapanPFR;
            
            System.assertEquals(pfrCount > 0, true);
            
            Test.stopTest();
        } 
    }

    //Japan cycle test
    @isTest 
    static void runRetailJapanCycleTest(){
        Integer pfrCount = 0;
        
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Account_Manager' LIMIT 1];
       
        insert new PermissionSetAssignment(AssigneeId = usr1.id, PermissionSetId = ps.Id);
       
        try{
            System.runAs(usr1)
            {
                Test.startTest();
                date sdate = date.today();        
                Account acc4 = [select id from account where name = 'Test Account 4']; 
                Campaign camp = [select id from Campaign where name = 'Test Camp 45' limit 1];
                
                List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();                                                
                            
                // Japan country validation
                PartnerFundRequest JapanPFR = Core_MDF_CCP_TestDataUtility.createRetailActivity(string.valueof(camp.Id),string.valueof(acc4.id),sdate, sdate.addDays(15),false); 
                
                JapanPFR.Core_MDF_Budget_Type_nm__c = 'RSA MD';
                pfrtoinsert = new List<PartnerFundRequest>();
                JapanPFR.Core_MDF_Country_nm__c = 'JAPAN';
                JapanPFR.Core_MDF_Start_Date__c = system.today()+4 ;//212
                JapanPFR.Core_MDF_End_Date__c = system.today()+50;//230//5
                pfrtoinsert.add(JapanPFR);
                //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
                insert JapanPFR;

                //System.assertEquals(pfrCount < 1, true);
                
                Test.stopTest();
            }
        }
        
        catch(Exception ex){   
            System.debug('Japan error->'+ex.getMessage());         
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Activity dates cannot overlap cycles') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    
  @isTest 
    static void validateIPAActivityClosure(){
        
  Integer pfrCount = 0;
        Account ipaCoMarketingAccount = [select id,Core_MDF_Parent_Fund_Account__c,Core_MDF_Channel_Program__c from Account where Name= 'IPA Co-Marketing Account'];
        
        Campaign ipaCampaignForAP = [SELECT Id, Core_MDF_Activity_Sub_Type_nm__c, Status, Core_MDF_Approval_Step_Counter_nbr__c, 
                                     Core_MDF_Reimbursement_Rate__c, Core_MDF_Region_cd__c, Description,
                                     StartDate, EndDate, Core_MDF_Total_Campaign_Cost_Amt__c, Core_MDF_Market__c  
                                     FROM Campaign WHERE Name = 'Test Campaign - AP' LIMIT 1];
        
        //ipaCampaignForAP.Core_MDF_Activity_Sub_Type_nm__c = 'Other (NonPartner.com)';
        //Database.update(ipaCampaignForAP);
        Test.startTest();
        List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();

        PartnerFundRequest ipaPFR5 = Core_MDF_CCP_IPA_TestDataUtility.createIPAPartnerFundRequest(ipaCampaignForAP.id,ipaCoMarketingAccount.id,System.today(),System.today(),false);
        pfrtoinsert.add(ipaPFR5);
        //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);
        insert ipaPFR5;
        
        Map<Id,PartnerFundRequest> oldPfrMap = new Map<Id,PartnerFundRequest>();
        Map<Id,PartnerFundRequest> newMap = new Map<Id,PartnerFundRequest>();

        oldPfrMap.put(ipaPFR5.Id,ipaPFR5);
        
        PartnerFundRequest updatepfr = [select id,Core_MDF_Budget_Type_nm__c,RequestedAmount,Core_MDF_Approval_Step_Completed__c,Core_MDF_Start_Date__c,Core_MDF_Fund_Request_Status__c,recordTypeId,Core_MDF_End_Date__c,Core_MDF_Activity_First_Approver_txt__c,Core_MDF_ToBeClosedDate__c,Core_MDF_Country_nm__c from PartnerFundRequest where title =: 'Test IPA' and recordtypeid =: Core_MDF_CCP_IPA_TestDataUtility.partnerFund_RecordType_IPA  LIMIT 1];
            
        updatepfr.Core_MDF_End_Date__c =  System.today().addDays(1);
        newMap.put(updatepfr.Id,updatepfr);
        //Core_MDF_UpdateActivityFields.populateBackEndFieldsUpdate(newMap,oldPfrMap);
        update updatepfr;
        
      pfrCount += 1;
            
        System.assertEquals(pfrCount > 0, true);
        Test.stopTest();
    }
         
    @isTest 
    static void countryCannotRemove(){
        List<User> ulist = new List<User>();
         UserRole usrRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.LastName = 'User Test';
        usr2.UserRoleId = usrRole.Id;
        ulist.add(usr2);
        
        User ccrm = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccrm.LastName = 'User Test';
        ccrm.UserRoleId = usrRole.Id;
        ulist.add(ccrm);
        
        Database.insert(ulist);
        PermissionSet pset = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager' LIMIT 1];
        
        insert new PermissionSetAssignment(AssigneeId = ccrm.id, PermissionSetId = pset.Id);
        
        System.runAs(usr2){
                
                Test.startTest();
                
                Account acc2 = [select id from account where name = 'Test Account 2']; 
            
            
                Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7 Processor','Yes', 
                                                                            Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 
                                                                            'Client CoMarketing Fund', system.today(), //System.today().addDays(-300), 
                                                                            System.today().addDays(30), 10000, 'Always Connected PC', 
                                                                            acc2.Id,'Desktop', true); 
                
                Campaign camp1 = [select id from Campaign where name = 'Test Camp 13' limit 1];
                
                PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
                PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp1.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                         testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                         'Member Participation in Third-Party Event','Draft',false);
                
                pfr.Core_MDF_Start_Date__c = System.today().addDays(1);
                pfr.Core_MDF_End_Date__c = System.today().addDays(20);
                pfr.RequestedAmount = 16250;
                pfr.Core_MDF_Fund_Request_Status__c = 'In-Progress';
                pfr.Core_MDF_Country_nm__c = 'CHINA';
                //pfr.Core_MDF_Region_cd__c = 'APJ';
                insert pfr;                
                try{
                    System.runAs(ccrm){
                        pfr.Core_MDF_Country_nm__c = 'INDIA';
                        update pfr; 
                    }
                }catch(exception e){
                    String msg = e.getMessage();
                    System.assert(msg.contains(Label.Core_MDF_Cannot_Remove_Country));
                } 
                Test.stopTest();
         }
    }

    @isTest
    static void populateRRTest(){
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        //Creating User with utility class 
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr1.LastName = 'User Test';
        usr1.UserRoleId = usRole.Id;
        Database.insert(usr1);
        System.runAs(usr1){
            Test.startTest();
            Account acc2 = [select id from account where name = 'Test Account 2'];
            Campaign camp = [select id from Campaign where name = 'Test Camp CCF' limit 1];
            
            PartnerMarketingBudget testBudget = [select id from PartnerMarketingBudget where Title ='TestBudgetData'];
            //PartnerMarketingBudget testBudgetOem = [select id from PartnerMarketingBudget where Title ='TestBudgetDataOEMCMP']          
            
           
            List<PartnerFundRequest> pfrtoinsert = new List<PartnerFundRequest>();
            
            // Create a pfr for the dates the way which is not crossed the 180 days
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                    testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                    'Member Participation in Third-Party Event','Draft',false);            
            testPartnerFundRequestRecord.RequestedAmount = 250;
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecord.Core_MDF_Start_Date__c = system.today() + 1;
            testPartnerFundRequestRecord.Core_MDF_End_Date__c = system.today() + 1;
            //system.debug('###s date' + testPartnerFundRequestRecord.Core_MDF_Start_Date__c);
            //system.debug('###e date' + testPartnerFundRequestRecord.Core_MDF_End_Date__c
            insert testPartnerFundRequestRecord;
            PartnerFundRequest testPartnerFundRequestRecordCmp = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,null,
                                                                                                                    testBudget,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event',
                                                                                                                    'Third Party Event','Draft',false);
            /*PartnerFundRequest testPartnerFundRequestRecordCmp = new PartnerFundRequest();
            testPartnerFundRequestRecordCmp.CampaignId = camp.id;
            testPartnerFundRequestRecordCmp.RecordTypeId = Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF;
            testPartnerFundRequestRecordCmp.*/
            testPartnerFundRequestRecordCmp.Core_MDF_Budget_Type_nm__c='OEM CMP';
            testPartnerFundRequestRecordCmp.RequestedAmount = 250;
            testPartnerFundRequestRecordCmp.Core_MDF_Fund_Request_Status__c = 'Planned';
            testPartnerFundRequestRecordCmp.Core_MDF_Start_Date__c = system.today() + 1;
            testPartnerFundRequestRecordCmp.Core_MDF_End_Date__c = system.today() + 1;            
            testPartnerFundRequestRecordCmp.Core_MDF_Competitive_Elements__c='Yes';
            testPartnerFundRequestRecordCmp.Core_MDF_Government_Nexus__c='No';
            insert testPartnerFundRequestRecordCmp;
            pfrtoinsert.add(testPartnerFundRequestRecord);
            //pfrtoinsert.add(testPartnerFundRequestRecordCmp);
            //Core_MDF_UpdateActivityFields.populateBackEndFieldsInsert(pfrtoinsert);            
            Test.stopTest();
        }
    }

}