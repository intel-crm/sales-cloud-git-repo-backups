@isTest
private class Core_MDF_PartnerFundReq_Controller_Test
{
    @testSetup
    static void setup()
    {
        Test.startTest();
        List<Account> accList = new List<Account>();
        //Setting up profile and permission set for User
        Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet aacntMngrPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
        //Creating Client Co-Marketing Fund program using Data Utility
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        //Creating Test Acc New 1-  Intel Account using Data Utility
        Account accIntel = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        // Creating Co-marketing Account with utility class
        Account accCoMarketing = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
        accCoMarketing.Core_MDF_Parent_Fund_Account__c = accIntel.Id;
        accCoMarketing.Core_MDF_CoMarketing_Ultimate_Account__c = accIntel.Id;
        Database.insert(accCoMarketing);
        accCoMarketing.IsPartner = true;
        accList.add(accCoMarketing);
        Database.update(accList);
        List<User> lstUser = new List<user>();

        //System Admin
        User systemAdm = Core_MDF_CCP_TestDataUtility.createUser(false);
        systemadm.Email = 'systemadm@example.com';
        lstUser.add(systemAdm);
        //CCF Account Manager
        User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
        ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
        ccfaccntmngr.Profile = ccpCoreAccessProfile;
        lstUser.add(ccfaccntmngr);
        Database.insert(lstUser);
        //Assign permission Sets
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = ccfaccntmngr.Id;
        assignPermissionSetObj.PermissionSetId = aacntMngrPS.Id;
        System.runAs(systemAdm){
            Database.insert(assignPermissionSetObj);
        }
        Test.stopTest();
        // Create IUPGM Data
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
        iupgm.Core_MDF_Account_id__c = accIntel.Id;
        iupgm.Core_MDF_All_Accounts_cd__c ='No';
        iupgm.Core_MDF_Program_nm__c = 'Client CoMarketing Fund';
        iupgm.Core_MDF_Region_cd__c = 'EMEA;APJ;PRC;ASMO';
        iupgm.Core_MDF_User_id__c = ccfaccntmngr.Id;
        iupgm.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_CCF_Acct_Mgr';
        iupgmList.add(iupgm);
        insert iupgmList;
        system.assert(iupgmList[0].Core_MDF_Account_id__c == accIntel.Id);
        //Create Campaign
        List<Campaign> campList = new List<Campaign>();
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7+ Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-15, System.today()+15, 10000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', false);
        Campaign campOld = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13','Gaming','Intel® Core™ i7+ Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today()-250, System.today()+100, 10000, 'Consumer Chromebook', accCoMarketing.Id, '2-in-1', false);
        campList.add(camp);
        campList.add(campOld);
        insert campList;

        List<Core_MDF_Currency_Exchange_Rates__c> exchangeRateList = new List<Core_MDF_Currency_Exchange_Rates__c>();
        Core_MDF_Currency_Exchange_Rates__c usdExchangeRate = new Core_MDF_Currency_Exchange_Rates__c();
        usdExchangeRate.Name= 'USD';
        usdExchangeRate.Core_MDF_Exchange_Rate__c = 1;
        usdExchangeRate.Core_MDF_Market_Date__c = System.today().addDays(-30);
        usdExchangeRate.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today().addDays(-30));
        usdExchangeRate.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today().addDays(-30));
        exchangeRateList.add(usdExchangeRate);

        Core_MDF_Currency_Exchange_Rates__c audExchangeRate = new Core_MDF_Currency_Exchange_Rates__c();
        audExchangeRate.Name= 'AUD';
        audExchangeRate.Core_MDF_Exchange_Rate__c = 0.67;
        audExchangeRate.Core_MDF_Market_Date__c = System.today().addDays(-30);
        audExchangeRate.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today().addDays(-30));
        audExchangeRate.Core_MDF_Unique_Key__c = 'AUD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today().addDays(-30));
        exchangeRateList.add(audExchangeRate);
        
        Core_MDF_Currency_Exchange_Rates__c aedExchangeRate = new Core_MDF_Currency_Exchange_Rates__c();
        aedExchangeRate.Name= 'AED';
        aedExchangeRate.Core_MDF_Exchange_Rate__c = 0.27;
        aedExchangeRate.Core_MDF_Market_Date__c = System.today();
        aedExchangeRate.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        aedExchangeRate.Core_MDF_Unique_Key__c = 'AED'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        exchangeRateList.add(aedExchangeRate);
        database.insert(exchangeRateList);
    }

    @isTest static void testloadPFRRecord(){

        Test.startTest();
            User usr = [select id,email from User where email='ccfaccntmngr@example.com'];
            System.runAs(usr){
            Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Camp 12' LIMIT 1];
            Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2'];
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Channel_Partner_Led__c = True;
            pfr.Core_MDF_Budget_Amount_Local_amt__c=100000000;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            insert pfr;

            PartnerFundRequest  result = new PartnerFundRequest();
            result = Core_MDF_PartnerFundRequestCreatePage.loadPFRRecord(pfr.Id);
            System.assert(result  != null);
            }
        Test.stopTest();
    }
    @isTest static void testPFRAmountandExchangeRate(){

        Test.startTest();
            User usr = [select id,email from User where email='ccfaccntmngr@example.com'];
            System.runAs(usr){
                Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Camp 12' LIMIT 1];
                Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2'];
                PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',false);
                pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
                pfr.Title = 'Test Activity';
                pfr.Core_MDF_Activity_Description__c = 'Test Activity';
                pfr.Core_MDF_Channel_Partner_Led__c = True;
                pfr.Core_MDF_Budget_Amount_Local_amt__c=100000000;
                pfr.Core_MDF_Budget_Currency_cd__c='AED';
                insert pfr;

                Decimal exchangeRate = pfr.Core_MDF_Exchange_Rate_ptc__c;
                pfr.Core_MDF_Budget_Amount_Local_amt__c=200000000;
                update pfr;
                System.assert(exchangeRate == pfr.Core_MDF_Exchange_Rate_ptc__c);
                Core_MDF_PartnerFundRequestCreatePage.ExchangeRateConvertedAmountWrapper exchRateWrapInst = new Core_MDF_PartnerFundRequestCreatePage.ExchangeRateConvertedAmountWrapper();
                pfr.Core_MDF_Budget_Amount_Local_amt__c=200000000;

                pfr.Core_MDF_Exchange_Rate_ptc__c = 1.58;
                exchRateWrapInst = Core_MDF_PartnerFundRequestCreatePage.budgetAmountCalculatePFR(pfr, false);

                //System.assert(exchRateWrapInst.usdBudgetAmount != 200000000);
                pfr.Core_MDF_Budget_Currency_cd__c = 'AED';
                pfr.Core_MDF_Budget_Amount_Local_amt__c = 657890;
                exchRateWrapInst = Core_MDF_PartnerFundRequestCreatePage.budgetAmountCalculatePFR(pfr,false);
                //System.assert(exchRateWrapInst.usdBudgetAmount != 200000000);

                List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
                pfrList.add(pfr);
                Core_MDF_PartnerFundRequestCreatePage.getExchangeRateConvertedAmountWrapperList(pfrList,false,true);
            }
        Test.stopTest();
    }
    @isTest static void testloadsavenSendRecordId(){

        Test.startTest();
        User usr = [SELECT Id,email FROM User WHERE email='ccfaccntmngr@example.com' LIMIT 1];
        Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm = [SELECT Id, Core_MDF_Account_id__c,Core_MDF_User_id__c, Core_MDF_Region_cd__c, Core_MDF_Channel_Program_id__c
                                                           FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_User_id__c =: usr.Id LIMIT 1];
        Campaign camp = [SELECT Id,Name, Core_MDF_Account__r.Core_MDF_Channel_Program__c,Core_MDF_Account__r.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c FROM Campaign WHERE Name = 'Test Camp 12' LIMIT 1];
        Account accCoMarketing = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        system.assert(iupgm.Core_MDF_Account_id__c == camp.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c);
        system.assert(iupgm.Core_MDF_User_id__c == usr.Id);
        system.assert(iupgm.Core_MDF_Channel_Program_id__c  == camp.Core_MDF_Account__r.Core_MDF_Channel_Program__c);
        List<ContentDocument> doc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
        List<String>contIds= new list<String>();
        for(ContentDocument content : doc){
            contIds.add(content.id);
        }
        System.runAs(usr){
            PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,accCoMarketing.Id,null,null,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            testPartnerFundRequestRecord.RequestedAmount = 250;
            testPartnerFundRequestRecord.Core_MDF_Priorities__c = 'Always Connected PC';
            testPartnerFundRequestRecord.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord.Core_MDF_Budget_Amount_Local_amt__c = 250;
            testPartnerFundRequestRecord.Core_MDF_Budget_Currency_cd__c = 'USD';
            testPartnerFundRequestRecord.Core_MDF_Channel_Partner_Led__c = false;
            testPartnerFundRequestRecord.Core_MDF_Channel_Partner__c = '';
            testPartnerFundRequestRecord.Core_MDF_Channel_Partner__c = '';
            //testPartnerFundRequestRecord.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c = camp.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c;
            //testPartnerFundRequestRecord.Campaign.Core_MDF_Account__r.Core_MDF_Channel_Program__c = camp.Core_MDF_Account__r.Core_MDF_Channel_Program__c ;

            //insert testPartnerFundRequestRecord;
            PartnerFundRequest testPartnerFundRequestRecord1 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,accCoMarketing.Id,null,null,'INDIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            testPartnerFundRequestRecord1.RequestedAmount = 250;
            testPartnerFundRequestRecord1.Core_MDF_Priorities__c = 'Always Connected PC';
            testPartnerFundRequestRecord1.Core_MDF_Fund_Request_Status__c = 'Revision Required';
            testPartnerFundRequestRecord1.Core_MDF_Budget_Amount_Local_amt__c = 250;
            testPartnerFundRequestRecord1.Core_MDF_Budget_Currency_cd__c = 'USD';
            testPartnerFundRequestRecord1.Core_MDF_Channel_Partner_Led__c = false;
            testPartnerFundRequestRecord1.Core_MDF_Channel_Partner__c = '';

            insert testPartnerFundRequestRecord1;
            //system.assert(iupgm.Core_MDF_Account_id__c == testPartnerFundRequestRecord1.Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c);
            //system.assert(iupgm.Core_MDF_User_id__c == usr.Id);
            //system.assert(iupgm.Core_MDF_Channel_Program_id__c  == testPartnerFundRequestRecord1.Campaign.Core_MDF_Account__r.Core_MDF_Channel_Program__c);
            //testPartnerFundRequestRecord1.RequestedAmount = 2500;

            PartnerFundRequest pfrRecord = Core_MDF_PartnerFundRequestCreatePage.loadPFRRecord(testPartnerFundRequestRecord1.Id);
            /* [SELECT Id, Campaign.Core_MDF_Account__r.Core_MDF_Channel_Program__c, ChannelPartnerId,
                                                   Campaign.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, RequestedAmount
                                            FROM PartnerFundRequest
                                            WHERE Id = :testPartnerFundRequestRecord1.Id]; */
            pfrRecord.RequestedAmount = 2500;
            Id result = null;
            Id result1;
            result = Core_MDF_PartnerFundRequestCreatePage.savenSendRecordId(testPartnerFundRequestRecord,contIds,FALSE);
            result1 = Core_MDF_PartnerFundRequestCreatePage.savenSendRecordId(pfrRecord,contIds,FALSE);
            System.assert(result  != null);
            System.assert(result1  == pfrRecord.Id);
        }
        Test.stopTest();
    }

     @isTest static void testloadsavenSendRecordIdError(){

        Test.startTest();
                User usr = [select id,email from User where email='ccfaccntmngr@example.com'];
                List<ContentDocument> doc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
                List<String>contIds= new list<String>();
                Map<Decimal,Decimal> resultBudget = null;
                for(ContentDocument content : doc){
                    contIds.add(content.id);
                }
                System.runAs(usr){
                    Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Camp 12' LIMIT 1];
                    Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2'];
                    PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(null,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,null,null,null,'','','','','','','Draft',false);

                    try{
                        Core_MDF_PartnerFundRequestCreatePage.savenSendRecordId(testPartnerFundRequestRecord,contIds,true);
                    }catch(Exception e){
                        System.assert(e != null );
                    }
                    //testPartnerFundRequestRecord.Id = null;
                     try{
                        testPartnerFundRequestRecord.RequestedAmount = null;
                        Core_MDF_PartnerFundRequestCreatePage.calculateExchangeRateAndAmount(testPartnerFundRequestRecord);
                    }catch(Exception e){
                        System.assert(e != null );
                    }

        Test.stopTest();
        }
    }
    @isTest
    static void testIsChannelPartnerMethod1()
    {
        User usr = [select id,email from User where email='ccfaccntmngr@example.com'];
        List<ContentDocument> doc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
        List<String>contIds= new list<String>();
        for(ContentDocument content : doc){
            contIds.add(content.id);
        }
        System.runAs(usr){

            Test.startTest();
                    Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Camp 12' LIMIT 1];
                    Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2'  LIMIT 1];
                    //CPLed Scenario 1
                    boolean isCP =  Core_MDF_PartnerFundRequestCreatePage.ischannelpartner('Event','Channel Partner Owned Event','Core_MDF_Client_CoMarketing_Fund');
                    PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',true,true,'Others','Test Other CP');

                    PartnerFundRequest result = new PartnerFundRequest();
                    //CPLed Scenario 2
                    testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',true,true,'Others','');
                    result = new PartnerFundRequest();
                    result = Core_MDF_PartnerFundRequestCreatePage.loadPFRRecord(testPartnerFundRequestRecord.Id);
                    try{
                        Core_MDF_PartnerFundRequestCreatePage.savenSendRecordId(testPartnerFundRequestRecord,contIds,false);
                    }Catch(Exception e){
                        System.assert(e != null );
                    }
                    //CPLed Scenario 3
                    testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',true,false,'','');
                    result = new PartnerFundRequest();
                    result = Core_MDF_PartnerFundRequestCreatePage.loadPFRRecord(testPartnerFundRequestRecord.Id);
                    try{
                       Core_MDF_PartnerFundRequestCreatePage.savenSendRecordId(testPartnerFundRequestRecord,contIds,false);
                    }Catch(Exception e){
                       System.assert(e != null );
                   }
            Test.stopTest();
    }
    }
    @isTest
    static void testIsChannelPartnerMethod2()
    {
        User usr = [select id,email from User where email='ccfaccntmngr@example.com'];
        List<ContentDocument> doc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
        List<String>contIds= new list<String>();
        for(ContentDocument content : doc){
            contIds.add(content.id);
        }
        System.runAs(usr){
            Test.startTest();
                Campaign camp = [select id,Name from Campaign WHERE Name = 'Test Camp 12' LIMIT 1];
                Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2'  LIMIT 1];
                //CPLed Scenario 1
                boolean isCP =  Core_MDF_PartnerFundRequestCreatePage.ischannelpartner('Event','Channel Partner Owned Event','Core_MDF_Client_CoMarketing_Fund');
                PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',true,true,'Others','Test Other CP');
                PartnerFundRequest result = new PartnerFundRequest();
                //CPLed Scenario 4
                testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Event','Channel Partner Owned Event','Draft',true,true,'','');
                result = new PartnerFundRequest();
                result = Core_MDF_PartnerFundRequestCreatePage.loadPFRRecord(testPartnerFundRequestRecord.Id);
                try{
                    Core_MDF_PartnerFundRequestCreatePage.savenSendRecordId(testPartnerFundRequestRecord,contIds,false);
                }Catch(Exception e){
                    System.assert(e != null );
                }
                //CPLed Scenario 5
                isCP = Core_MDF_PartnerFundRequestCreatePage.ischannelpartner('Broadcast','Radio','Core_MDF_Client_CoMarketing_Fund');
                testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',true,true,'Others','');
                result = new PartnerFundRequest();
                result = Core_MDF_PartnerFundRequestCreatePage.loadPFRRecord(testPartnerFundRequestRecord.Id);

                try{
                    Core_MDF_PartnerFundRequestCreatePage.savenSendRecordId(testPartnerFundRequestRecord,contIds,false);
                }Catch(Exception e){
                    System.assert(e != null );
                }
                //CPLed Scenario 6
                testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequestwithCP(string.valueof(camp.Id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',true,true,'','');
                result = new PartnerFundRequest();
                result = Core_MDF_PartnerFundRequestCreatePage.loadPFRRecord(testPartnerFundRequestRecord.Id);

                try{
                    Core_MDF_PartnerFundRequestCreatePage.savenSendRecordId(testPartnerFundRequestRecord,contIds,false);
                }Catch(Exception e){
                    System.assert(e != null );
                }
            Test.stopTest();
        }
    }
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{"example":"test"}');
                    res.setStatusCode(200);
                    system.assert(res != null );
                    return res;
        }
    }
    @isTest
    static void testMainPicklistFetcher()
    {
        Map<string,Object> testMap = new Map<string,Object>();
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
                testMap = Core_MDF_PartnerFundRequestCreatePage.mainPicklistFetcher('Core_MDF_Service_Provider_CoMarketing_Fund');
                Test.stopTest();
                system.assert(testMap != null );
    }
    @isTest
    static void testUserHasPermissionSet()
    {
        Map<string,List<string>> perset = new Map<string,List<string>>();
        list<string> persets = new list<string>();
        persets.add('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
        persets.add('Core_MDF_CCP_Internal_DCF_Acct_Mgr');
        perset.put('accmgrper',persets);
        persets = new list<string>();
        persets.add('Core_MDF_CCP_External_Activity_Submitter');
        perset.put('externalper',persets);
        persets = new list<string>();
        persets.add('Core_MDF_CCP_Internal_Claim_Case_Reviewer');
        persets.add('Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager');
        perset.put('auditorper',persets);

        persets = new list<string>();
        persets.add('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
        persets.add('Core_MDF_CCP_Internal_DCF_Acct_Mgr');
        persets.add('Core_MDF_CCP_Internal_SPCF_Acct_Mgr');
        perset.put('fileexceptionper',persets);
        System.assert(Core_MDF_PartnerFundRequestCreatePage.userHasPermissionSet(perset)  != null);
    }
    @isTest
    static void testApitoLabelReference(){
        String obj = 'PartnerFundRequest';
        List<String> field = new List<String>();
        field.add('Core_MDF_Brand__c');
        Map<String,String> result = Core_MDF_PartnerFundRequestCreatePage.getLabelApiMapforPicklistfields (obj,field);
        System.assert(result  != null);
    }

    //test method for Variable Reimbursement
    @isTest static void testVariableReimbursement(){

        Test.startTest();
        Campaign camp = [select id,Name, Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c from Campaign WHERE Name = 'Test Camp 12' LIMIT 1];
        Core_MDF_CoMarketing_Activity_Inc_Rule__c ruleobj = new Core_MDF_CoMarketing_Activity_Inc_Rule__c(Core_MDF_Channel_Program_Id__c = camp.Core_MDF_Channel_Program__c,
        Core_MDF_Effective_Dt__c = System.today(),Core_MDF_Incentive_Pct__c = 10,Core_MDF_Activity_Category_Nm__c = 'Broadcast',Core_MDF_Activity_Type_Nm__c='Radio',Core_MDF_Active_Ind__c=true);

        insert ruleobj;


            User usr = [select id,email from User where email='ccfaccntmngr@example.com'];
            System.runAs(usr){

            Account accCoMarketing = [select id from Account WHERE Name = 'Test Account 2'];
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(camp.id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Budget_Amount_Local_amt__c=1000;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today();
            insert pfr;

            List<PartnerFundRequest> output = Core_MDF_PartnerFundRequestCreatePage.calculateIncentiveForActivity(pfr,camp.Core_MDF_Channel_Program__c);
            System.assert(output  != null);

            string techchannelprogram = camp.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
            Core_MDF_ChannelProgram__mdt mdt = Core_MDF_PartnerFundRequestCreatePage.fetchVRMetadataMapping(techchannelprogram);
            System.assert(mdt!=null);

            }


        Test.stopTest();
    }

    @isTest static void activityBudgetCurrencyTest(){
        List<Campaign> campList = [SELECT Id,Name FROM Campaign WHERE Name = 'Test Camp 12' OR Name = 'Test Camp 13' LIMIT 2];
        User usr = [SELECT Id,email FROM User WHERE email='ccfaccntmngr@example.com' LIMIT 1];
        Account accCoMarketing = [SELECT Id FROM Account WHERE Name = 'Test Account 2' LIMIT 1];
        System.runAs(usr){
            PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(campList[0].id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr.Title = 'Test Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr.Core_MDF_Budget_Amount_Local_amt__c=1000;
            pfr.Core_MDF_Budget_Currency_cd__c='AED';
            pfr.Core_MDF_Start_Date__c = System.today();
            pfr.Core_MDF_End_Date__c = System.today();
            insert pfr;
            PartnerFundRequest pfrNew = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(campList[0].id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            pfrNew.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfrNew.Title = 'Test Activity';
            pfrNew.Core_MDF_Activity_Description__c = 'Test Activity';
            pfrNew.Core_MDF_Budget_Amount_Local_amt__c=10000;
            pfrNew.Core_MDF_Budget_Currency_cd__c='AED';
            pfrNew.Core_MDF_Start_Date__c = System.today();
            pfrNew.Core_MDF_End_Date__c = System.today();
            insert pfrNew;
            PartnerFundRequest newPFRCreatedDate = [SELECT Id, CreatedDate, Core_MDF_Budget_Currency_cd__c, Core_MDF_Budget_Amount_Local_amt__c, Core_MDF_Exchange_Rate_ptc__c
                                         FROM PartnerFundRequest
                                         WHERE Id = :pfrNew.Id];
            PartnerFundRequest updatedPFRchange = Core_MDF_PartnerFundRequestCreatePage.recalculatebudgetAmountOnPFR(newPFRCreatedDate,pfr);
            system.assert(updatedPFRchange.Core_MDF_Budget_Currency_cd__c == 'AED');
            Datetime createdate = Datetime.now().addDays(-200);
            Test.setCreatedDate(pfr.Id, createdate);
            PartnerFundRequest oldPFR = pfr;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            update pfr;
            Test.startTest();
            PartnerFundRequest newPFR = [SELECT Id, CreatedDate, Core_MDF_Budget_Currency_cd__c, Core_MDF_Budget_Amount_Local_amt__c, Core_MDF_Exchange_Rate_ptc__c
                                         FROM PartnerFundRequest
                                         WHERE Id = :pfr.Id];
            PartnerFundRequest updatedPFR = Core_MDF_PartnerFundRequestCreatePage.recalculatebudgetAmountOnPFR(newPFR,oldPFR);
            system.assert(updatedPFR.Core_MDF_Budget_Currency_cd__c == 'USD');

            oldPFR = newPFR;
            pfr.Core_MDF_Budget_Currency_cd__c='USD';
            update pfr;
            newPFR = [SELECT Id, CreatedDate, Core_MDF_Budget_Currency_cd__c, Core_MDF_Budget_Amount_Local_amt__c, Core_MDF_Exchange_Rate_ptc__c
                                         FROM PartnerFundRequest
                                         WHERE Id = :pfr.Id];
            updatedPFR = Core_MDF_PartnerFundRequestCreatePage.recalculatebudgetAmountOnPFR(newPFR,oldPFR);
            system.assert(updatedPFR.Core_MDF_Budget_Currency_cd__c == 'USD');
            oldPFR = newPFR;
            newPFR.Core_MDF_Budget_Currency_cd__c = 'AUD';
            newPFR.Core_MDF_Exchange_Rate_ptc__c = 0.67;
            updatedPFR = Core_MDF_PartnerFundRequestCreatePage.recalculatebudgetAmountOnPFR(newPFR,oldPFR);
            PartnerFundRequest pfr2019 = Core_MDF_CCP_TestDataUtility.insertPartnerFundRequest(string.valueof(campList[1].id),Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,string.valueof(accCoMarketing.id),null,null,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast','Radio','Draft',false);
            pfr2019.Core_MDF_Fund_Request_Status__c = 'Planned';
            pfr2019.Title = 'Test Activity';
            pfr2019.Core_MDF_Activity_Description__c = 'Test Activity';
            pfr2019.Core_MDF_Budget_Amount_Local_amt__c=1000;
            pfr2019.Core_MDF_Budget_Currency_cd__c='USD';
            pfr2019.Core_MDF_Start_Date__c = System.today()-22;
            pfr2019.Core_MDF_End_Date__c = System.today()-22;
            insert pfr2019;
            Datetime pastdate = Datetime.now().addDays(-6);
            Test.stopTest();
            Test.setCreatedDate(pfr2019.Id, pastdate);
            
            PartnerFundRequest oldPFR2019 = pfr2019;
            pfr2019.Title = 'Test Activity1' ;
            update pfr2019;
            PartnerFundRequest newPFR2019 = [SELECT Id, CreatedDate, Core_MDF_Budget_Currency_cd__c, Core_MDF_Budget_Amount_Local_amt__c, Core_MDF_Exchange_Rate_ptc__c
                                         FROM PartnerFundRequest
                                         WHERE Id = :pfr2019.Id];
            PartnerFundRequest updatedPFR2019 = Core_MDF_PartnerFundRequestCreatePage.recalculatebudgetAmountOnPFR(newPFR2019,oldPFR2019);
            system.assert(updatedPFR2019.Core_MDF_Budget_Currency_cd__c == 'USD');
            pfr2019.Core_MDF_Budget_Amount_Local_amt__c = 2000 ;
            update pfr2019;
            newPFR2019 = [SELECT Id, CreatedDate, Core_MDF_Budget_Currency_cd__c, Core_MDF_Budget_Amount_Local_amt__c, Core_MDF_Exchange_Rate_ptc__c
                                         FROM PartnerFundRequest
                                         WHERE Id = :pfr2019.Id];
            updatedPFR2019 = Core_MDF_PartnerFundRequestCreatePage.recalculatebudgetAmountOnPFR(newPFR2019,oldPFR2019);
            system.assert(updatedPFR2019.RequestedAmount == 2000 );
        }
        //Test.stopTest();
    }
    @isTest static void checkIFActivityInApprovalQue(){
         //Create CCF Channel Program
         ChannelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
            
         // Creating Intel Account for retail program
         Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                               false);
         Database.insert(acc1Retail);
         
         // Creating Retail Account with utility class
         Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                         Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
         accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
         accRetail.Core_Geo__c = 'EMEA';
         Database.insert(accRetail);
         PermissionSet accountManager = [select id from PermissionSet where name='Core_MDF_CCP_Internal_Retail_Account_Manager'];
         PartnerMarketingBudget testBudget1 = Core_MDF_CCP_TestDataUtility.createBudget('TestBudgetData1',Core_MDF_CCP_TestDataUtility.budget_Record_Type,
                                                                                           accRetail.id, cpRetail.Id , 10000 , System.today()-60 , System.today() + 30 , 
                                                                                           false);
            
            testBudget1.IsIgnoreValidation = true;
            insert testBudget1;
            testBudget1.Core_MDF_Budget_Status__c = 'Released';
            update testBudget1;
            test.startTest();
            Campaign camp2 = Core_MDF_CCP_TestDataUtility.createCampaign('TestRetailCamp','Gaming','Athena', 
                                                                         Core_MDF_CCP_TestDataUtility.campaign_RecordType_Retail, 'Retail Marketing Funds',System.today().addDays(16) , 
                                                                         System.today().addYears(1), 2000, 'Instore innovation', accRetail.Id,'2-in-1', true);
            /*PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
            Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'UNITED KINGDOM','Gaming','2-in-1',
            '9ᵗʰ Gen','Broadcast','Podcast','Draft',false);*/
			PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(string.valueof(camp2.Id),
                                                                                                              Core_MDF_CCP_TestDataUtility.partnerFund_RecordType_Retail,string.valueof(accRetail.id),NULL,NULL,'AFGHANISTAN','Enthusiast Gaming','Traditional Notebook',
                                                                                                              'Intel® 11ᵗʰ Gen','Sales Readiness','In-Store Promotion','Draft',false); 
            pfr.Title = 'Test Retail Activity';
            pfr.Core_MDF_Activity_Description__c = 'Test Retail Activity';
            pfr.Core_MDF_Start_Date__c = System.today().addDays(17);
            pfr.Core_MDF_End_Date__c = System.today().addDays(18);
            pfr.RequestedAmount = 1000;
            pfr.Core_MDF_Country_nm__c = 'INDIA';
            pfr.Core_MDF_Fund_Request_Status__c = 'Pending Review';
			
            Database.insert(pfr);
            System.assert(pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review');
        
            test.stopTest();
            Core_MDF_PartnerFundRequestCreatePage.validateIfInApprvlQue(pfr.id);
        }
    
}