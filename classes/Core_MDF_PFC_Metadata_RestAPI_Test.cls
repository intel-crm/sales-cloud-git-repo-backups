@isTest(SeeAllData=false)
private class Core_MDF_PFC_Metadata_RestAPI_Test {

    private static final String ENDPOINT = '/services/apexrest/v1.0/partnercenter/claimmetadata';
    private static final String ACTION_CREATE = 'create';
	
    @TestSetup
    static void setupData() {
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.Email = 'sysadmin@example.com';
        Database.insert(usr);
        
        //Profile ccpCoreProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
        PermissionSet clmCaseRevPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_Claim_Case_Reviewer' LIMIT 1];
        PermissionSet ccfPayAdmin = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Payment_Adm' LIMIT 1];
        User claimCase = Core_MDF_CCP_TestDataUtility.createUser(false);
        claimCase.Email = 'clmcase@example.com';
        insert claimCase;
        List<PermissionSetAssignment> permSetAssignment = new List<PermissionSetAssignment>();
        PermissionSetAssignment assignPermissionSetObj = new PermissionSetAssignment();
        assignPermissionSetObj.AssigneeId = claimCase.Id;
        assignPermissionSetObj.PermissionSetId = clmCaseRevPS.Id;
        permSetAssignment.add(assignPermissionSetObj);
        
        PermissionSetAssignment assignPermissionSetObj1 = new PermissionSetAssignment();
        assignPermissionSetObj1.AssigneeId = usr.Id;
        assignPermissionSetObj1.PermissionSetId = ccfPayAdmin.Id;
        permSetAssignment.add(assignPermissionSetObj1);
        system.runas(usr){
            Database.insert(permSetAssignment);
        }
        
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
        
        //Creating Contact for Partner User
        Contact conRecord1 = Core_MDF_CCP_TestDataUtility.createContact(acc1.Id,true);
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='Partner' limit 1].Id;
        User usr1 = Core_MDF_CCP_TestDataUtility.createUser(false);        
        usr1.Email='test1@example.com';
        usr1.ContactId = conRecord1.Id;
        usr1.ProfileId = profileId;
        usr1.isActive = true;
        Database.insert(usr1);
        
        Profile ccpProfile1 = [SELECT Id FROM Profile WHERE Name='CCP - Core Access'];
        //UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User usr2 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr2.ProfileId = ccpProfile1.Id;
        usr2.Email='test2@intel.com';
        usr2.isActive = true;
        usr2.UserPermissionsMarketingUser=true;
        Database.insert(usr2);
        
        List<Core_MDF_Currency_Exchange_Rates__c> newValues = new List<Core_MDF_Currency_Exchange_Rates__c>();
        Core_MDF_Currency_Exchange_Rates__c record1 = new Core_MDF_Currency_Exchange_Rates__c();
        record1.Name= 'ZMK';
        record1.Core_MDF_Exchange_Rate__c = 0.0000850159;
        record1.Core_MDF_Market_Date__c =System.today();
        record1.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record1.Core_MDF_Unique_Key__c = 'ZMK'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record1);
        
        Core_MDF_Currency_Exchange_Rates__c record2 = new Core_MDF_Currency_Exchange_Rates__c();
        record2.Name= 'INR';
        record2.Core_MDF_Exchange_Rate__c = 1;
        record2.Core_MDF_Market_Date__c =System.today();
        record2.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record2.Core_MDF_Unique_Key__c = 'INR'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record2); 
        
        Core_MDF_Currency_Exchange_Rates__c record3 = new Core_MDF_Currency_Exchange_Rates__c();
        record3.Name= 'USD';
        record3.Core_MDF_Exchange_Rate__c = 1;
        record3.Core_MDF_Market_Date__c =System.today();
        record3.Core_MDF_Intel_WW__c = Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        record3.Core_MDF_Unique_Key__c = 'USD'+Core_MDF_CCP_Multicurrency.calculateIntelWorkWeek(System.today());
        newValues.add(record3); 
        database.insert(newValues);
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        //Permissionset internalFinanceUser=[SELECT Id From PermissionSet WHERE Label='CCP Internal Finance User'];
        // Creating User with utility class 
        User usr3 = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr3.profileId = systemAdminProfile.Id;
        usr3.Email='test2@example.com';
        Database.insert(usr3);
        Map<String,PermissionSet> nameToPerSet = new Map<String,PermissionSet>();
        for(PermissionSet pSet:[SELECT Id,Name FROM PermissionSet WHERE Name IN (
                            'Core_MDF_CCP_Internal_Retail_Finance_Usr','Core_MDF_CCP_Internal_IPA_Finance_Usr',
            				'Core_MDF_CCP_Internal_Finance_Usr','Core_MDF_CCP_Internal_CCF_User',
            				'Core_MDF_CCP_Internal_DCF_User','Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader'
                            )]) {
            nameToPerSet.put(pSet.Name,pSet);
        }
        
         
		List<PermissionSetAssignment> permSetAssgnLst = new List<PermissionSetAssignment>();
        PermissionSet retailInternalFinanceUser = nameToPerSet.get('Core_MDF_CCP_Internal_Retail_Finance_Usr');
        PermissionSetAssignment assignMDFBudgetLoaderPermissionSet = new PermissionSetAssignment();
        assignMDFBudgetLoaderPermissionSet.AssigneeId = usr3.Id;
        assignMDFBudgetLoaderPermissionSet.PermissionSetId = retailInternalFinanceUser.Id; 
        permSetAssgnLst.add(assignMDFBudgetLoaderPermissionSet);
        PermissionSet ipaFinanceUser = nameToPerSet.get('Core_MDF_CCP_Internal_IPA_Finance_Usr');
        PermissionSetAssignment assignIPAPermissionSet = new PermissionSetAssignment();
        assignIPAPermissionSet.AssigneeId = usr3.Id;
        assignIPAPermissionSet.PermissionSetId = ipaFinanceUser.Id; 
        permSetAssgnLst.add(assignIPAPermissionSet);
        PermissionSet internalFinanceUser = nameToPerSet.get('Core_MDF_CCP_Internal_Finance_Usr');
        PermissionSetAssignment assignInternalFinanceUserPermissionSet = new PermissionSetAssignment();
        assignInternalFinanceUserPermissionSet.AssigneeId = usr3.Id;
        assignInternalFinanceUserPermissionSet.PermissionSetId = internalFinanceUser.Id; 
        permSetAssgnLst.add(assignInternalFinanceUserPermissionSet);
        PermissionSet internalCCFUser = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_User');
        PermissionSetAssignment assignInternalCCFUserPermissionSet = new PermissionSetAssignment();
        assignInternalCCFUserPermissionSet.AssigneeId = usr3.Id;
        assignInternalCCFUserPermissionSet.PermissionSetId = internalCCFUser.Id; 
        permSetAssgnLst.add(assignInternalCCFUserPermissionSet);
        PermissionSet internalDCFUser = nameToPerSet.get('Core_MDF_CCP_Internal_DCF_User');
        PermissionSetAssignment assigninternalDCFUserPermissionSet = new PermissionSetAssignment();
        assigninternalDCFUserPermissionSet.AssigneeId = usr3.Id;
        assigninternalDCFUserPermissionSet.PermissionSetId = internalDCFUser.Id; 
        permSetAssgnLst.add(assigninternalDCFUserPermissionSet);
        PermissionSetAssignment assigninternalCCFBudLoPermissionSet = new PermissionSetAssignment();
        assigninternalCCFBudLoPermissionSet.AssigneeId = usr3.Id;
        assigninternalCCFBudLoPermissionSet.PermissionSetId = nameToPerSet.get('Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader').id;
        permSetAssgnLst.add(assigninternalCCFBudLoPermissionSet);
        system.runAs(usr3){
            Database.insert(permSetAssgnLst);
        }
        
        System.runAs(usr3){
        PartnerMarketingBudget pbm = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000000, System.today().addDays(-4), System.today().addDays(364), false);
        pbm.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        insert pbm;
        PartnerFundAllocation pfaRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundAllocation('Test PFA', pbm, acc2, 3000000, true);
        
        pbm.IsIgnoreValidation = true;
        update pbm;
        
        PartnerFundAllocation pfa = [Select id, Amount from PartnerFundAllocation where BudgetId =: pbm.Id and Title='Test PFA' limit 1];
        
        Campaign camp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today().addDays(-2), System.today().addDays(300), 100000, 'Always Connected PC', acc2.Id,'Desktop', false);
        camp.Core_MDF_Opal_Budget_Type_Txt__c = 'OEM CMP';
        camp.Core_MDF_Budget_Amount_amt__c = 1000000;
        camp.Core_MDF_Total_Campaign_Cost_Amt__c = 1000000;
        insert(camp);    
            
        List<Core_Trigger_Executions__c> executionList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution.Core_Trigger_Events__c = 'after insert';
        claimFunctionalityNameTriggerExecution.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution.Name = 'fundReservation';
        claimFunctionalityNameTriggerExecution.Core_Description__c = 'description';
        executionList.add(claimFunctionalityNameTriggerExecution);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution2 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution2.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution2.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution2.Core_Trigger_Events__c = 'before insert';
        claimFunctionalityNameTriggerExecution2.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution2.Name = 'checkESDHoldAndUpdateClaimStatus';
        claimFunctionalityNameTriggerExecution2.Core_Description__c = 'check ESD hold for the bank selected on Claim and change Claim status to Hold if it is on ESD Hold';
        executionList.add(claimFunctionalityNameTriggerExecution2);
        Core_Trigger_Executions__c claimFunctionalityNameTriggerExecution1 = new Core_Trigger_Executions__c();
        claimFunctionalityNameTriggerExecution1.Core_Active__c = true;
        claimFunctionalityNameTriggerExecution1.Core_Class_Name__c = 'Core_MDF_ProcessCCP_Claim';
        claimFunctionalityNameTriggerExecution1.Core_Trigger_Events__c = 'before insert';
        claimFunctionalityNameTriggerExecution1.Core_Object__c = 'PartnerFundClaim';
        claimFunctionalityNameTriggerExecution1.Name = 'duplicateClaimCheck';
        claimFunctionalityNameTriggerExecution1.Core_Description__c = 'check ESD hold for the bank selected on Claim and change Claim status to Hold if it is on ESD Hold';
        executionList.add(claimFunctionalityNameTriggerExecution1);
        
        Database.insert(executionList); 
        
        Core_MDF_Bank__c bank = Core_MDF_CCP_TestDataUtility.createBank(acc1.Id, 'Core_MDF_Client_CoMarketing_Fund', false,'1231231230');
        bank.Core_MDF_Payment_Currency_Cd__c = 'USD';    
        bank.Core_MDF_Bank_Status__c='Active';
        //System.runAs(usr){
        insert bank;
        
        //}
        Core_MDF_Account_Bank_Mapping__c accountBankMap = Core_MDF_CCP_TestDataUtility.createAccountBankMap(acc2.Id, bank.Id, true);
        
        
        Test.startTest();
        
       
        PartnerFundRequest testPartnerFundRequestRecord = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(camp.id,Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,acc2.Id,pfa,pbm,'ALBANIA','Consumer','Desktop','Intel® Corporate Logo','Broadcast (Pre-2025)','Radio','Draft',false);
           
        testPartnerFundRequestRecord.Amount = testPartnerFundRequestRecord.RequestedAmount;
        testPartnerFundRequestRecord.Core_MDF_Budget_Type_nm__c ='OEM CMP';
        testPartnerFundRequestRecord.AllocationId = pfa.Id;
        testPartnerFundRequestRecord.Status = 'Approved';
        testPartnerFundRequestRecord.Title = 'indiaActivity';
		testPartnerFundRequestRecord.Amount = 200;
        testPartnerFundRequestRecord.Core_MDF_Reimbursement_Rate_txt__c = '50%';
        
       
        insert testPartnerFundRequestRecord;
           
        
        
        
        Core_MDF_CCP_TestDataUtility.createMDFConfigurationData();
        List<PartnerFundClaim> claimsToBeInserted = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimsToBeUpdated = new List<PartnerFundClaim>();
        PartnerFundClaim claim1 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 50.00, System.today(), bank.Id, false);
        //claimsToBeInserted.add(claim1);
        claim1.Status = Label.Core_MDF_Status_Approved;
        claim1.Core_MDF_Status__c = Label.Core_MDF_Status_Payment_Due;
        claimsToBeUpdated.add(claim1);
        
        PartnerFundClaim claim2 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim2', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), 50.00, System.today(), bank.Id, false);
        //claimsToBeInserted.add(claim2);
        claim2.Status = Label.Core_MDF_Status_Approved;
        claim2.Core_MDF_Criteria_Hold_Ind__c = true;
        claim2.Core_MDF_Intel_Manual_Hold_Ind__c =true;
        claim2.Core_MDF_Status__c = 'hold';        
        claimsToBeUpdated.add(claim2);  
        
        //Database.insert(claimsToBeInserted); 
       
        
        PartnerFundClaim claim3 = Core_MDF_CCP_TestDataUtility.createClaim('Test Claim3', Core_MDF_CCP_TestDataUtility.Claim_RecordType_CCF, testPartnerFundRequestRecord.Id, System.today(), System.today(), -50.00, System.today(), bank.Id, false);
        claim3.Status = Label.Core_MDF_Status_Submitted;
        claim3.Core_MDF_Status__c = Label.Core_MDF_Status_Pending_Available_Fund;
        claim3.Core_MDF_Type_Txt__c = Label.Core_MDF_Claim_Type_to_be_excluded;
        claimsToBeUpdated.add(claim3);
        Database.upsert(claimsToBeUpdated);
        
        Test.stopTest();
        
        Core_MDF_Configuration__c config8 = new Core_MDF_Configuration__c();
        config8.Core_MDF_Value__c = 'Core_MDF_CCP_RMF_Internal_Claim_Operations';
        config8.Name = 'PRC_CLAIM_OPERATION_CUSTOM_PERMISSION';
        insert config8;
        Core_MDF_Configuration__c config9 = new Core_MDF_Configuration__c();
        config9.Core_MDF_Value__c = 'Core_MDF_CCP_Internal_CSC_Claim_Submitter';
        config9.Name = 'CSC_CLAIM_SUBMITTER_CUSTOM_PERMISSION';
        insert config9;
        }
        
        Core_MDF_Custom_Layout_Section__c createSection = new Core_MDF_Custom_Layout_Section__c(
            Core_MDF_Section_Name_txt__c = 'PFC Metadata Create',
            Core_MDF_Object_Name_txt__c = 'PartnerFundClaim',
            Core_MDF_Record_Type_Name_txt__c = 'Client',
            Core_MDF_Field_View_nm__c = 'API Create',
            Core_MDF_No_Of_Columns_nm__c = '1',
            Core_MDF_Sequence_No_nbr__c = 1
        );
        insert new List<Core_MDF_Custom_Layout_Section__c>{ createSection };

        insert new List<Core_MDF_Custom_Layout_Configurations__c>{
            new Core_MDF_Custom_Layout_Configurations__c(
                Core_MDF_Object_API_Name_txt__c = 'PartnerFundClaim',
                Core_MDF_User_Type_nm__c = 'External User',
                Core_MDF_Record_Type_Name_txt__c = 'Client',
                Core_MDF_Section_id__c = createSection.Id,
                Core_MDF_Field_Label_txt__c = 'Claim Country',
                Core_MDF_Field_API_Name_txt__c = 'Core_MDF_Country_Location_nm__c',
                Core_MDF_Active_Ind__c = true,
                API_Visibility__c = true,
                Core_MDF_API_Required_Ind__c = true,
                Core_MDF_Sequence_No_nbr__c = 1
            )
        };
    }

    @isTest
    static void testGetFieldMetadata_ValidationAndErrorPaths() {
        RestResponse resNoParams = invokeApi(new Map<String, String>());
        assertResponseAvailable(resNoParams);
				
        RestResponse resInvalidParam = invokeApi(new Map<String, String>{
            'action' => ACTION_CREATE,
            'badParam' => 'x'
        });
        assertResponseAvailable(resInvalidParam);

        RestResponse resInvalidAction = invokeApi(new Map<String, String>{
            'claimType' => 'Normal'
        });
        assertResponseAvailable(resInvalidAction);

        RestResponse resInvalidClaimType = invokeApi(new Map<String, String>{
            'action' => ACTION_CREATE,
            'claimType' => 'Unknown'
        });
        assertResponseAvailable(resInvalidClaimType);

        RestResponse resNoActivityForNormal = invokeApi(new Map<String, String>{
            'action' => ACTION_CREATE,
            'claimType' => 'Normal'
        });
        assertResponseAvailable(resNoActivityForNormal);

        RestResponse resNoEscForLate = invokeApi(new Map<String, String>{
            'action' => ACTION_CREATE,
            'claimType' => 'Late Claim'
        });
        assertResponseAvailable(resNoEscForLate);
		
        PartnerFundRequest pfr = [Select Id from PartnerFundRequest limit 1];
        RestResponse resInvalidActivityId = invokeApi(new Map<String, String>{
            'action' => ACTION_CREATE,
            'claimType' => 'Normal',
            'activityIdOrNumber' => pfr.Id
        });
        assertResponseAvailable(resInvalidActivityId);

        RestResponse resInvalidEscId = invokeApi(new Map<String, String>{
            'action' => ACTION_CREATE,
            'claimType' => 'Late Claim',
            'escalationId' => 'a4S000000000001'
        });
        assertResponseAvailable(resInvalidEscId);
    }

    @isTest
    static void testGetFieldMetadata_SuccessPath_ActivityOrProgram() {
        RestResponse response = invokeApi(new Map<String, String>{
            'action' => ACTION_CREATE,
            'programName' => 'Client'
        });

        assertResponseAvailable(response);
        String body = response.responseBody == null ? '' : response.responseBody.toString();
        System.assert(body.contains('"isSuccess":'), 'Response should contain the success flag.');
        System.assert(body.contains('"fields":'), 'Response should contain field metadata.');
    }
    
    @isTest
    static void testUtility_PublicMethodsAndResolvePaths() {
        Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext nullCtx = Core_MDF_PFC_Metadata_RestAPIUtility.resolve(null);
        System.assertNotEquals(null, nullCtx, 'resolve(null) should return a context instance.');

        Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams normalBadId = new Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams();
        normalBadId.clmType = 'Normal';
        normalBadId.actId = 'INVALID';
        Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext normalBadCtx = Core_MDF_PFC_Metadata_RestAPIUtility.resolve(normalBadId);
        System.assertEquals(false, normalBadCtx.recFound, 'Invalid normal-claim activity id should not resolve.');

        Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams lateBadId = new Core_MDF_PFC_Metadata_RestAPIUtility.ResolveParams();
        lateBadId.clmType = 'Late Claim';
        lateBadId.escId = 'INVALID';
        Core_MDF_PFC_Metadata_RestAPIUtility.ActivityContext lateBadCtx = Core_MDF_PFC_Metadata_RestAPIUtility.resolve(lateBadId);
        System.assertEquals(false, lateBadCtx.recFound, 'Invalid escalation id should not resolve.');

        List<Core_MDF_PFC_Metadata_RestAPIUtility.LabelValue> countries = Core_MDF_PFC_Metadata_RestAPIUtility.buildActivityCountries('USA;usa; JPN ; ');
        System.assertNotEquals(null, countries, 'Country list should not be null.');

        List<Core_MDF_PFC_Metadata_RestAPIUtility.LabelValue> submitters = Core_MDF_PFC_Metadata_RestAPIUtility.buildClmSubmitterVal(null, null);
        System.assertEquals(0, submitters.size(), 'Null inputs should produce empty submitter list.');

        List<Core_MDF_PFC_Metadata_RestAPIUtility.LabelValue> banksNoAccount = Core_MDF_PFC_Metadata_RestAPIUtility.buildBankSupNum(null);
        System.assertEquals(0, banksNoAccount.size(), 'Null account should produce empty bank list.');

        List<Core_MDF_PFC_Metadata_RestAPIUtility.LabelValue> invalidFieldVals = Core_MDF_PFC_Metadata_RestAPIUtility.getStaticLabelValues('Invalid_Field__c');
        System.assertEquals(0, invalidFieldVals.size(), 'Unknown field should return empty values.');

        List<Core_MDF_PFC_Metadata_RestAPIUtility.LabelValue> cached1 = Core_MDF_PFC_Metadata_RestAPIUtility.getStaticLabelValues(Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_CLAIM_COUNTRY);
        List<Core_MDF_PFC_Metadata_RestAPIUtility.LabelValue> cached2 = Core_MDF_PFC_Metadata_RestAPIUtility.getStaticLabelValues(Core_MDF_PFC_Metadata_RestAPIUtility.FIELD_CLAIM_COUNTRY);
        System.assertNotEquals(null, cached1, 'First cache read should not return null.');
        System.assertNotEquals(null, cached2, 'Second cache read should not return null.');
    }

    private static RestResponse invokeApi(Map<String, String> params) {
        RestRequest req = new RestRequest();
        req.requestURI = ENDPOINT;
        req.httpMethod = 'GET';
        if (params != null) {
            for (String key : params.keySet()) {
                req.addParameter(key, params.get(key));
            }
        }

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Core_MDF_PFC_Metadata_RestAPI.getFieldMetadata();

        return RestContext.response;
    }

    private static void assertResponseAvailable(RestResponse response) {
        System.assertNotEquals(null, response, 'Response should be initialized.');
        System.assertNotEquals(null, response.responseBody, 'Response body should be present.');
    }

}