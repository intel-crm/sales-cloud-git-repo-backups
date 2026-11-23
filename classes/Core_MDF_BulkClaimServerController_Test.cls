/*
* Class Name  : Core_MDF_BulkClaimServerController_Test 
* Version     : 1.0 
* Created Date: 11-04-2019
* Developer                             Date                          Description 
* -----------------------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Krishna Kulkarni         11/04/2019      Created Core_MDF_BulkClaimServerController_Test for testing every action from Core_MDF_BulkClaimServerController
* Accenture – JV                       15/04/2019      Modified entire class based on the changes made in functioanality   
-------------------------------------------------------------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData = false)
private class Core_MDF_BulkClaimServerController_Test {

    //Set Up All Data
    @TestSetup static void setUpData() {
        
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram('Client Co-Marketing Fund', 'Client CoMarketing Fund', true);
        
        Account intelAccount = Core_MDF_CCP_TestDataUtility.createAccount('Test Acc New 1', cp.id, Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
        intelAccount.BillingCity = 'Test City';
        intelAccount.BillingCountry = 'AUS';
        intelAccount.BillingStreet = 'Test Street';
        intelAccount.Core_MDF_Active_Ind__c = true;
        intelAccount.Core_MDF_CoMarketingActive__c = true;
        Database.insert(intelAccount);

        Contact ccfUserContact = Core_MDF_CCP_TestDataUtility.createContact(intelAccount.Id, true);
        ccfUserContact.Core_Audience_List__c = 'CCF User';
        Database.update(ccfUserContact);
                
        Id partnerProfileId = [SELECT Id FROM Profile WHERE Name = 'Partner' limit 1].Id;
        User japaneseUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        japaneseUser.Email = 'testClaimSubmitter@example.com';
        japaneseUser.ContactId = ccfUserContact.Id;
        japaneseUser.ProfileId = partnerProfileId;
        japaneseUser.LanguageLocaleKey = 'ja';
        japaneseUser.isActive = true;
        Database.insert(japaneseUser); 

        User sysAdminUser = Core_MDF_CCP_TestDataUtility.createUser(false);
        sysAdminUser.LanguageLocaleKey = 'en_US';
        database.insert(sysAdminUser);
      
        Account virtualCorpAccount = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 2', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id, false);
        virtualCorpAccount.Core_MDF_Active_Ind__c = true;
        virtualCorpAccount.Core_MDF_CoMarketingActive__c = true;
        virtualCorpAccount.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
        Account virtualCorpAccount2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc New 3', cp.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id, false);
        virtualCorpAccount2.Core_MDF_Active_Ind__c = true;
        virtualCorpAccount2.Core_MDF_CoMarketingActive__c = true;
        virtualCorpAccount2.Core_MDF_CoMarketing_Ultimate_Account__c = intelAccount.Id;
        List<Account> accounts = new List<Account>();
        accounts.add(virtualCorpAccount);
        accounts.add(virtualCorpAccount2);
        DataBase.insert(accounts);
        
        Core_MDF_Currency_Exchange_Rates__c usdExchangeRate = new Core_MDF_Currency_Exchange_Rates__c();
        usdExchangeRate.Name= 'USD';
        usdExchangeRate.Core_MDF_Exchange_Rate__c = 1;
        usdExchangeRate.Core_MDF_Market_Date__c =System.today();
        usdExchangeRate.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        usdExchangeRate.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        database.insert(usdExchangeRate);
       
        Test.startTest();

        PartnerMarketingBudget budget = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget New', Core_MDF_CCP_TestDataUtility.budget_Record_Type, virtualCorpAccount.Id, cp.Id, 200000, System.today() - 20, System.today().addDays(40), true);
        budget.IsIgnoreValidation = true;
        database.update(budget);

        PartnerFundAllocation allocation = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New', budget, virtualCorpAccount, 200.0, true);
        PartnerFundAllocation allocation2 = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test Allocation New2', budget, virtualCorpAccount2, 200.0, true);

        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 13', 'Gaming', 'Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(15), 10000, 'Always Connected PC', virtualCorpAccount.Id, 'Desktop', true);

        PartnerFundRequest testPartnerFundRequest = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
            String.valueof(virtualCorpAccount.id), allocation, null, 'INDIA',
            'Consumer',
            'Desktop',
            'Intel® Core™ i7 Processor',
            'Broadcast',
            'Podcast',
            'Draft',
            false);

        testPartnerFundRequest.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest.Core_MDF_End_Date__c = system.today();
        testPartnerFundRequest.Amount=0;
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'INDIA';
        PartnerFundRequest testPartnerFundRequest2 = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(camp.Id),
            Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
            String.valueof(virtualCorpAccount2.id), allocation2, null, 'BRAZIL',
            'Consumer',
            'Desktop',
            'Intel® Core™ i7 Processor',
            'Broadcast',
            'Podcast',
            'Draft',
            false);

        testPartnerFundRequest2.Core_MDF_Start_Date__c = system.today();
        testPartnerFundRequest2.Core_MDF_End_Date__c = system.today();
        testPartnerFundRequest2.Amount=0;
        testPartnerFundRequest.Core_MDF_Country_nm__c = 'BRAZIL';
        List<PartnerFundRequest> pfrs = new List<PartnerFundRequest>();
        pfrs.add(testPartnerFundRequest);
        pfrs.add(testPartnerFundRequest2);
        database.insert(pfrs);

        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(intelAccount.Id, 'Core_MDF_Client_CoMarketing_Fund', true, '1231231230');
        
        Core_MDF_CCP_TestDataUtility.createAccountBankMap(virtualCorpAccount.Id, bank.id, true);
        Core_MDF_CCP_TestDataUtility.createAccountBankMap(virtualCorpAccount2.Id, bank.id, true);
        
        Test.stopTest();

        PartnerFundClaim testClaim = Core_MDF_CCP_TestDataUtility.createClaim('Dell DCF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   testPartnerFundRequest.Id, 
                                                                                   testPartnerFundRequest.Core_MDF_Start_Date__c, testPartnerFundRequest.Core_MDF_Start_Date__c, 
                                                                                   1234, 
                                                                                   System.today(), bank.ID, false);
        testClaim.Core_MDF_Media_Vehicle__c = 'Krishna1011';
        testClaim.Core_MDF_Currency__c = 'USD';
        testClaim.Core_MDF_Invoice_Number__c = '1234';
        testClaim.Core_MDF_Total_Invoice_Amount_Local__c = 10;
        testClaim.Core_MDF_Taxes_Local__c = 0;
        PartnerFundClaim testClaim2 = Core_MDF_CCP_TestDataUtility.createClaim('Dell DCF Claim', Core_MDF_CCP_TestDataUtility.claim_RecordType_CCF, 
                                                                                   testPartnerFundRequest2.Id, 
                                                                                   testPartnerFundRequest2.Core_MDF_Start_Date__c, testPartnerFundRequest2.Core_MDF_Start_Date__c, 
                                                                                   1234, 
                                                                                   System.today(), bank.ID, false);
        testClaim2.Core_MDF_Media_Vehicle__c = 'Krishna1011';
        testClaim2.Core_MDF_Currency__c = 'USD';
        testClaim2.Core_MDF_Invoice_Number__c = '1234';
        testClaim2.Core_MDF_Total_Invoice_Amount_Local__c = 10;
        testClaim2.Core_MDF_Taxes_Local__c = 0;
        List<PartnerFundClaim> claims = new List<PartnerFundClaim>();
        claims.add(testClaim);
        claims.add(testClaim2);
        database.insert(claims);
        
        
        
        List < Document > docList = new List < Document > ();
        Document document = new Document();
        document.ContentType = 'application/vnd.ms-excel';
        document.DeveloperName = 'Core_MDF1_Request_Template_CCF_DCF_en_US';
        document.IsPublic = true;
        document.Name = 'Request_Template_CCF_DCF_en_US';
        document.FolderId = [select id from folder where name = 'Bulk Claim Templates'].id;
        docList.add(document);
        
        Document document1 = new Document();
        document1.ContentType = 'application/vnd.ms-excel';
        document1.DeveloperName = 'Core_MDF1_Request_Template_CCF_DCF_ja';
        document1.IsPublic = true;
        document1.Name = 'Request_Template_CCF_DCF_ja';
        document1.FolderId = [select id from folder where name = 'Bulk Claim Templates'].id;
        docList.add(document1);
        database.insert(docList);
        
        Core_MDF_Claim_Batch__c claimbatchinstance = new Core_MDF_Claim_Batch__c();
        claimbatchinstance.Core_MDF_Program_Id__c =  cp.Id;
        claimbatchinstance.Core_MDF_Account__c = [SELECT ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c FROM 
                                                    PartnerFundRequest WHERE ID=:testPartnerFundRequest.Id].ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
        Database.SaveResult sr = Database.insert(claimbatchinstance);
    }

    //Test Method to fetchUserAndTemplateDetails 
    @isTest static void testFetchUserAndTemplateDetails() {

        Test.startTest();
        User japaneseUser = [Select Id from User WHERE LanguageLocaleKey = 'ja' LIMIT 1];
        //System.runAs(japaneseUser){
            List <String> fetchUserList = new List <String>();
            fetchUserList = Core_MDF_BulkClaimServerController.fetchUserAndTemplateDetails('CCF');
            System.debug('fetchUserList:'+fetchUserList);
            System.assertEquals(FALSE,fetchUserList.contains('PowerPartner'));
        //}
        Test.stopTest();
    }
    
    //Test Method to test Successful Insertion and Duplicate Record Insertion of Claim Stage Records
    @isTest static void testParseFileAndDuplicateRecordInsertion() {
        
        Test.startTest();
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            List<Account> accounts = [Select Id, Name from Account where Name in ('Test Acc New 2','Test Acc New 3')];
            PartnerFundRequest activityRecord = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where ChannelPartnerId = :accounts[0].Id limit 1];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            PartnerFundRequest activityRecord2 = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where ChannelPartnerId = :accounts[1].Id limit 1];

            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);

            String csvString = 'Claim Name,Activity #,"Ad Run Start Date  (YYYY-MM-DD)","Ad Run End Date (YYYY-MM-DD)",Media Vehicle,Bank,"Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',Krishna1011,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 3,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1';
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + activityRecord2.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',Krishna1014,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            Blob myBlob = Blob.valueof(csvString);
            String base64Data = EncodingUtil.base64Encode(myBlob);
            String fileName = 'fileName.csv';

            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client Co-Marketing Fund'];
                
            Core_MDF_BulkClaimServerController.fetchRecordTypeMetaData();
            
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            System.debug('abc'+claimbatchinstance);
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgram.Id LIMIT 1].Core_MDF_Technical_Program_Name__c;
            Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                        Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c
                                                                                                                        FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                        WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                        AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);
            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                      FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                      WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];


            Core_MDF_BulkClaimServerController.createClaimBatchStageRecords(claimbatchinstance,metadataIdToRecordMap,recordType,myBlob);
            Core_MDF_Claim_Batch_Stage__c batchStage = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_Claim_Batch_Successful limit 1];
            system.debug('xyz'+claimbatchinstance.Id);

            try{
                Database.delete(batchStage);
            }catch(Exception e)
            {System.assertEquals(e.getMessage().contains(Label.Core_MDF_Claim_Cannot_BeDeleted),True);}
             
            Core_MDF_Claim_Batch_Stage__c duplicatebatchStage = [select id,Core_MDF_Is_Duplicate_ind__c,Core_MDF_Claim_Reference_Nbr__c,Core_MDF_Create_Duplicate_ind__c, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Is_Duplicate_ind__c =TRUE AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_Claim_Batch_Failed limit 1];
            duplicatebatchStage.Core_MDF_Create_Duplicate_ind__c = true;
            Database.update(duplicatebatchStage);
            duplicatebatchStage = [SELECT Core_MDF_Processing_Status_Nm__c,Core_MDF_Claim_Reference_Nbr__c,Core_MDF_Message_txt__c FROM Core_MDF_Claim_Batch_Stage__c WHERE ID =: duplicatebatchStage.Id LIMIT 1];
            System.assertEquals(Label.Core_MDF_Claim_Batch_Failed,duplicatebatchStage.Core_MDF_Processing_Status_Nm__c);
           Core_MDF_BulkClaimServerController.parseFile(base64Data, fileName, channelProgram.Id);
            try{Core_MDF_BulkClaimServerController.parseFile(base64Data, fileName, channelProgram.Id);}catch(Exception e){System.debug('Exception'+e);}
        }
        Test.stopTest();
    }

    //Test Method to test the Update scenarios on Claim Batch Stage Records
    @isTest static void testUpdateScenariosOnClaimBatchStageRecords() {

        Test.startTest();
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM User WHERE LanguageLocaleKey='en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram  LIMIT 1].Core_MDF_Technical_Program_Name__c;
            Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                        Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c
                                                                                                                        FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                        WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                        AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);
            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                      FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                      WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];
            
            PartnerFundRequest activityRecord = [Select id, Title, Core_MDF_Activity_Number__c,Core_MDF_Start_Date__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Title = 'test' Limit 1];
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c, Core_MDF_Bank_Status__c, Core_MDF_Program__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            String fileName = 'file1.csv';
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client Co-Marketing Fund'];
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            String csvStringForFailedRecord = 'Claim Name,Activity #,"Ad Run Start Date  (YYYY-MM-DD)","Ad Run End Date (YYYY-MM-DD)",Media Vehicle,Bank,"Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',7011,' + null+ ',' + dateString + ',1234,USD,10,0,0,Claim1';
            Blob myBlob = Blob.valueof(csvStringForFailedRecord);
            Core_MDF_BulkClaimServerController.createClaimBatchStageRecords(claimbatchinstance,metadataIdToRecordMap,recordType,myBlob);
            Core_MDF_Claim_Batch_Stage__c failedStageRecord = [SELECT id,Core_MDF_Claim_Reference_Nbr__c,Core_MDF_Is_Duplicate_ind__c,Core_MDF_Create_Duplicate_ind__c,Core_MDF_Ad_Run_End_Dt__c, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c FROM Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Is_Duplicate_ind__c =FALSE AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_Claim_Batch_Failed  AND  Core_MDF_Media_Vehicle_txt__c='7011' limit 1];
            failedStageRecord.Core_MDF_Ad_Run_End_Dt__c = System.today();
            failedStageRecord.Core_MDF_Media_Vehicle_txt__c = '239sdk834';
            failedStageRecord.Core_MDF_Bank_Nbr__c = bankRecord.Core_MDF_Supplier_Number__c;
            database.update(failedStageRecord);
            failedStageRecord = [SELECT Core_MDF_Processing_Status_Nm__c,Core_MDF_Claim_Reference_Nbr__c FROM Core_MDF_Claim_Batch_Stage__c WHERE ID =: failedStageRecord.Id LIMIT 1];
            System.assertNotEquals(Label.Core_MDF_Claim_Batch_Failed,failedStageRecord.Core_MDF_Processing_Status_Nm__c);
        }
        Test.stopTest();
    }
    
    //Test Method to test the UI Validations on Uploading the CSV File AND Insert/Update failing Stage Records
    @isTest static void testUIValidationsAndFailedStageScenarios() {

        Test.startTest();
        User sysAdminUser = [SELECT ID FROM User WHERE LanguageLocaleKey='en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram  LIMIT 1].Core_MDF_Technical_Program_Name__c;
            Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                        Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c
                                                                                                                        FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                        WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                        AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);
            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                      FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                      WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];

            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            PartnerFundRequest activityRecord = [Select id, Title, Core_MDF_Activity_Number__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where Title = 'test' Limit 1];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c, Core_MDF_Bank_Status__c, Core_MDF_Program__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client Co-Marketing Fund'];
            
            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);
            
            String csvStringForFailedRecord2 = 'Claim Name,Activity #,"Ad Run Start Date (YYYY-MM-DD)","Ad Run End Date (YYYY-MM-DD)",Media Vehicle,Bank,"Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',701189,' + null+ ',' + dateString + ',1234,USD,10,0,0,Claim1';
            Blob myBlob2 = Blob.valueof(csvStringForFailedRecord2);
            Core_MDF_BulkClaimServerController.createClaimBatchStageRecords(claimbatchinstance,metadataIdToRecordMap,recordType,myBlob2);
            Core_MDF_Claim_Batch_Stage__c failedStageRecord2 = [SELECT id,Core_MDF_Claim_Reference_Nbr__c,Core_MDF_Is_Duplicate_ind__c,Core_MDF_Create_Duplicate_ind__c,Core_MDF_Ad_Run_End_Dt__c, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Is_Duplicate_ind__c =FALSE AND  Core_MDF_Media_Vehicle_txt__c='701189' limit 1];
            failedStageRecord2.Core_MDF_Media_Vehicle_txt__c = null;
            database.update(failedStageRecord2);
            failedStageRecord2 = [SELECT Core_MDF_Claim_Reference_Nbr__c FROM Core_MDF_Claim_Batch_Stage__c WHERE ID =: failedStageRecord2.Id LIMIT 1];
            System.assertEquals(null,failedStageRecord2.Core_MDF_Claim_Reference_Nbr__c);
          
            String csvString3 = 'Claim Name,Activity #,"Ad Run Start Date (YYYY-MM-DD)","Ad Run End Date (YYYY-MM-DD)",Media Vehicle,Bank,"Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + '18/02/2019' + ',' + dateString + ',701189,' + null+ ',' + dateString + ',1234,USD,10,0,0,Claim1';
            Blob myBlob3 = Blob.valueof(csvString3);
            String base64Data = EncodingUtil.base64Encode(myBlob3);
            String fileName = 'MyName';
            String uiExceptionError = Core_MDF_BulkClaimServerController.parseFile(base64Data,fileName,channelProgram.Id);
            System.assertEquals(TRUE,uiExceptionError.contains('UIExceptionError'));
        }
        Test.stopTest();
    }
    // To Create Claim from batch stage
    @isTest static void testFetchClaimRecType() {
        
        Test.startTest();
        User sysAdminUser = [SELECT Id,LanguageLocaleKey FROM USER WHERE LanguageLocaleKey = 'en_US' LIMIT 1];
        System.runAs(sysAdminUser){
            
            List<Account> accounts = [Select Id, Name from Account where Name in ('Test Acc New 2','Test Acc New 3')];
            PartnerFundRequest activityRecord = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where ChannelPartnerId = :accounts[0].Id limit 1];
            Core_MDF_Bank__c bankRecord = [Select id, Name, Core_MDF_Supplier_Number__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c = '1231231230'];
            PartnerFundRequest activityRecord2 = [Select id, Title, Core_MDF_Activity_Number__c,ChannelPartner.Core_MDF_Active_Ind__c,ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Fund_Request_Status__c from PartnerFundRequest where ChannelPartnerId = :accounts[1].Id limit 1];

            String dateFormatString = 'dd-MMM-yy';
            Date d = Date.today();
            Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
            String dateString = dt.format(dateFormatString);

            String csvString = 'Claim Name,Activity #,"Ad Run Start Date  (YYYY-MM-DD)","Ad Run End Date (YYYY-MM-DD)",Media Vehicle,Bank,"Invoice/Receipt Date (YYYY-MM-DD)",Invoice/Receipt Number,Invoice/Receipt Currency,Total Amount (Local),Costs not Reimbursable (Local),Taxes (Local),Claim Comments \n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',Krishna1011,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 1,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1 \n Dell DCF Claim from Bulk 3,' + activityRecord.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',99999997644,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',1234,USD,10,0,0,Claim1';
            csvString = csvString + '\n Dell DCF Claim from Bulk 4,' + activityRecord2.Core_MDF_Activity_Number__c + ',' + dateString + ',' + dateString + ',Krishna1014,' + bankRecord.Core_MDF_Supplier_Number__c + ',' + dateString + ',12345,USD,50,0,0,Claim1' ;
            Blob myBlob = Blob.valueof(csvString);
            String base64Data = EncodingUtil.base64Encode(myBlob);
            String fileName = 'fileName.csv';

            ChannelProgram channelProgram = [Select id from ChannelProgram where Name = 'Client Co-Marketing Fund'];
                
            Core_MDF_BulkClaimServerController.fetchRecordTypeMetaData();
            
            Core_MDF_Claim_Batch__c claimbatchinstance = [SELECT Id,Core_MDF_Program_Id__c,Core_MDF_Account__c FROM Core_MDF_Claim_Batch__c LIMIT 1];
            System.debug('abc'+claimbatchinstance);
            String channelProgramName = [Select Core_MDF_Technical_Program_Name__c From ChannelProgram WHERE Id =:channelProgram.Id LIMIT 1].Core_MDF_Technical_Program_Name__c;
            Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt> metadataIdToRecordMap = new Map<Id,Core_MDF_BulkClaimTemplateParticulars__mdt>([SELECT Id,Core_MDF_Stage_Field_API_Name__c,Core_MDF_Field_DataType_Txt__c,Core_MDF_Column_Index__c,
                                                                                                                        Core_MDF_Target_Field_API_Name__c, Core_MDF_Stage_Required_Ind__c
                                                                                                                        FROM Core_MDF_BulkClaimTemplateParticulars__mdt
                                                                                                                        WHERE Core_MDF_Channel_program__c = :channelProgramName
                                                                                                                        AND Core_MDF_Upload_Record_Type__c =:Label.Core_MDF_PFCText]);
            Core_MDF_ClaimActAllocRecTypeMapping__mdt  recordType = [SELECT Id, Core_MDF_ClaimStage_RecordType_txt__c
                                                                      FROM Core_MDF_ClaimActAllocRecTypeMapping__mdt
                                                                      WHERE Core_MDF_Channel_Program_Name_txt__c = :channelProgramName LIMIT 1];


            Core_MDF_BulkClaimServerController.createClaimBatchStageRecords(claimbatchinstance,metadataIdToRecordMap,recordType,myBlob);
            system.debug('claimbatchinstance::'+claimbatchinstance);
            system.debug('metadataIdToRecordMap::'+metadataIdToRecordMap);
            system.debug('recordType::'+recordType);
            system.debug('myBlob::'+myBlob);
            Core_MDF_Claim_Batch_Stage__c batchStage = [select id, Core_MDF_Media_Vehicle_txt__c, Core_MDF_Processing_Status_Nm__c, Core_MDF_Message_txt__c, Core_MDF_Bank_Nbr__c from Core_MDF_Claim_Batch_Stage__c WHERE Core_MDF_Batch_ID__c =: claimbatchinstance.Id AND Core_MDF_Processing_Status_Nm__c =: Label.Core_MDF_Claim_Batch_Successful limit 1];
            String returnString = Core_MDF_BatchStageClaimController.fetchClaimRecordType(batchStage.Id);
			system.assertNotEquals(returnString,null);	
            }
        Test.stopTest();
    }
   }