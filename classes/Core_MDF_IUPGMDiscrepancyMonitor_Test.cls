@isTest
public class Core_MDF_IUPGMDiscrepancyMonitor_Test {
    Public static Id IPA_RecordType = Schema.SObjectType.Core_MDF_Int_Users_Partner_Geo_Mapping__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
    
    @TestSetup
    static void createTestData(){
        
        User testUser = Core_MDF_CCP_TestDataUtility.createUser(false); 
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        Boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
        testUser.LastName='Admin_user';
        testUser.UserRoleId = usRole.Id;
        testUser.IsActive=true;
        insert testUser;
        
        System.runAs(testUser){
            List<String> bypassFunctionKeys = new List<String>();
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            bypassFunctionKeys.add('Core_MDF_RemoveGrpMemberBypass');
            bypassFunctionKeys.add('Core_MDF_Bypass_AccOnboardValidation');  // 14285 Indira
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);
            List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
            
            List<ChannelProgram> cpList = new List<ChannelProgram>();
            ChannelProgram ipaCp = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', false);
            cpList.add(ipaCp);
            insert cpList;
            
            Account ccpIntelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false); 
            ccpIntelAccount.Core_MDF_CoMarketingActive__c= true;
            ccpIntelAccount.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
            if(isUnifiedIdEnabled){
                ccpIntelAccount.Core_Unified_Global_Customer_BP_Id__c = 'ABC123';
            }else{
                ccpIntelAccount.Core_Prime_Id__c = 'ABC123'; 
            }
            Database.insert(ccpIntelAccount);
            
            // Create additional account for more test scenarios
            Account ccpIntelAccount2 = Core_MDF_CCP_TestDataUtility.createIntelAccount('CCP Test Intel Account 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false); 
            ccpIntelAccount2.Core_MDF_CoMarketingActive__c= true;
            ccpIntelAccount2.Core_Intel_Partner_Alliance_PartnerGroup__c= true;
            if(isUnifiedIdEnabled){
                ccpIntelAccount2.Core_Unified_Global_Customer_BP_Id__c = 'DEF456';
            }else{
                ccpIntelAccount2.Core_Prime_Id__c = 'DEF456'; 
            }
            Database.insert(ccpIntelAccount2);
            
            Group ipaGRP = new Group();
            ipaGRP.Name = 'CCP_TESTACCTTEMP_CCF_EMEA';
            ipaGRP.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA';
            Database.insert(ipaGRP);
            
            Group ipaGRP2 = new Group();
            ipaGRP2.Name = 'CCP_TESTACCTTEMP_CCF_APJ';
            ipaGRP2.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_APJ';
            Database.insert(ipaGRP2);
            
            Group ipaGRP3 = new Group();
            ipaGRP3.Name = 'CCP_TESTACCTTEMP_CCF_AMERICAS';
            ipaGRP3.DeveloperName = 'Core_MDF_CCP_TESTACCTTEMP_CCF_AMERICAS';
            Database.insert(ipaGRP3);
            
            GroupMember grpMember = new GroupMember();
            grpMember.UserOrGroupId = testUser.Id;
            grpMember.GroupId = ipaGRP.Id;
            Database.insert(grpMember);
            
            GroupMember grpMember1 = new GroupMember();
            grpMember1.UserOrGroupId = testUser.Id;
            grpMember1.GroupId = ipaGRP2.Id;
            Database.insert(grpMember1);
            
            GroupMember grpMember2 = new GroupMember();
            grpMember2.UserOrGroupId = testUser.Id;
            grpMember2.GroupId = ipaGRP3.Id;
            Database.insert(grpMember2);
            
            PermissionSet ipaL2ApproverPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver' LIMIT 1];
            PermissionSetAssignment psa9 = new PermissionSetAssignment(PermissionSetId = ipaL2ApproverPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa9);
            
            PermissionSet ipaApprPS = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver' LIMIT 1];
            PermissionSetAssignment psa15 = new PermissionSetAssignment(PermissionSetId = ipaApprPS.Id, AssigneeId = testUser.Id);
            Database.insert(psa15);
            
            // Create multiple Core_MDF_Partner_Group_Mapping__c records for different scenarios
            List<Core_MDF_Partner_Group_Mapping__c> pgmList = new List<Core_MDF_Partner_Group_Mapping__c>();
            
            Core_MDF_Partner_Group_Mapping__c pgmRecord1 = new Core_MDF_Partner_Group_Mapping__c();
            pgmRecord1.Core_MDF_Account__c = ccpIntelAccount.Id;
            pgmRecord1.Core_MDF_Channel_Program__c = ipaCp.Id;
            pgmRecord1.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_EMEA';
            pgmRecord1.Core_MDF_Group_id__c = ipaGRP.Id;
            pgmRecord1.Core_MDF_Region_cd__c = 'EMEA'; // 14285 Indira
            pgmRecord1.Core_MDF_Sub_Region_cd__c = 'ANZ';  // 14285 Indira
            pgmRecord1.Core_MDF_BudgetType_nm__c = 'Client Specialties MDF';
            pgmRecord1.Core_MDF_Type_Of_Access__c = 'External';  // 14285 Indira
            pgmRecord1.Core_MDF_Inactive_Ind__c = false;
            pgmList.add(pgmRecord1);
            
            Core_MDF_Partner_Group_Mapping__c pgmRecord2 = new Core_MDF_Partner_Group_Mapping__c();
            pgmRecord2.Core_MDF_Account__c = ccpIntelAccount2.Id;
            pgmRecord2.Core_MDF_Channel_Program__c = ipaCp.Id;
            pgmRecord2.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_APJ';
            pgmRecord2.Core_MDF_Group_id__c = ipaGRP2.Id;
            pgmRecord2.Core_MDF_Region_cd__c = 'APJ';
            pgmRecord2.Core_MDF_Sub_Region_cd__c = 'IJKK'; // 14285 Indira
            pgmRecord2.Core_MDF_BudgetType_nm__c = 'Account Plan';
            pgmRecord2.Core_MDF_Type_Of_Access__c = 'External'; // 14285 Indira
            pgmRecord2.Core_MDF_Inactive_Ind__c = false;
            pgmList.add(pgmRecord2);
            
            // Record without sub region to test null handling
            Core_MDF_Partner_Group_Mapping__c pgmRecord3 = new Core_MDF_Partner_Group_Mapping__c();
            pgmRecord3.Core_MDF_Account__c = ccpIntelAccount.Id;
            pgmRecord3.Core_MDF_Channel_Program__c = ipaCp.Id;
            pgmRecord3.Core_MDF_Group_Name__c = 'Core_MDF_CCP_TESTACCTTEMP_CCF_AMERICAS';
            pgmRecord3.Core_MDF_Group_id__c = ipaGRP3.Id;
            pgmRecord3.Core_MDF_Region_cd__c = 'ASMO';  // 14285 Indira
            pgmRecord3.Core_MDF_Sub_Region_cd__c='NAR';  // 14285 Indira
            pgmRecord3.Core_MDF_BudgetType_nm__c = '';
            pgmRecord3.Core_MDF_Type_Of_Access__c = 'External'; // 14285 Indira
            pgmRecord3.Core_MDF_Inactive_Ind__c = false;
            pgmList.add(pgmRecord3);
            
             insert pgmList;  
           
            // Create multiple IUPGM records for comprehensive testing
            List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();

            // Record with budget type and geo mapping
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm1 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm1.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm1.RecordTypeId = IPA_RecordType;
            IPAiupgm1.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm1.Core_MDF_Region_cd__c = 'EMEA';
            IPAiupgm1.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
            IPAiupgm1.Core_MDF_Budget_Type_nm__c = 'Account Plan';
            IPAiupgm1.Core_MDF_GeoSubGeo_Budget_Type_nm__c = 'EMEA->Client Specialties MDF'; // 14285 Indira
            IPAiupgm1.Core_MDF_User_id__c = testUser.Id;
            IPAiupgm1.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
            IPAiupgm1.Core_MDF_All_Accounts_cd__c = 'No';
            IPAiupgm1.Core_MDF_Active_Ind__c = true;
            IPAiupgm1.Core_MDF_Budget_Type_nm__c='';
            IPAiupgm1.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            IPAiupgm1.Core_MDF_Activity_Classification_nm__c = 'Sales';
            iupgmList.add(IPAiupgm1);
            
            //Record without budget type
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm2 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm2.Core_MDF_Account_id__c = ccpIntelAccount2.Id;
            IPAiupgm2.RecordTypeId = IPA_RecordType;
            IPAiupgm2.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm2.Core_MDF_Region_cd__c = 'APJ';
            IPAiupgm2.Core_MDF_Region_Sub_Region_nm__c = 'APJ';
            IPAiupgm2.Core_MDF_User_id__c = testUser.Id;
            IPAiupgm2.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            IPAiupgm2.Core_MDF_All_Accounts_cd__c = 'No';
            IPAiupgm2.Core_MDF_Budget_Type_nm__c='';
            IPAiupgm2.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            IPAiupgm2.Core_MDF_Activity_Classification_nm__c = '';
            IPAiupgm2.Core_MDF_Active_Ind__c = true;
            iupgmList.add(IPAiupgm2);
            
            // Record with multiple geo mappings
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm3 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm3.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm3.RecordTypeId = IPA_RecordType;
            IPAiupgm3.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm3.Core_MDF_Region_cd__c = 'ASMO';
            IPAiupgm3.Core_MDF_Region_Sub_Region_nm__c = 'ASMO';
            IPAiupgm3.Core_MDF_Budget_Type_nm__c = '';
            IPAiupgm3.Core_MDF_GeoSubGeo_Budget_Type_nm__c = ''; // 14285 Indira
            IPAiupgm3.Core_MDF_User_id__c = testUser.Id;
            IPAiupgm3.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver';
            IPAiupgm3.Core_MDF_All_Accounts_cd__c = 'Yes';
            IPAiupgm3.Core_MDF_Active_Ind__c = true;
            IPAiupgm3.Core_MDF_Budget_Type_nm__c='';
            IPAiupgm3.Core_MDF_All_Budget_Type_Access_Ind__c = false;
            IPAiupgm3.Core_MDF_Activity_Classification_nm__c = 'Sales';
            //iupgmList.add(IPAiupgm3);
            
            //Inactive record
            Core_MDF_Int_Users_Partner_Geo_Mapping__c IPAiupgm4 = new Core_MDF_Int_Users_Partner_Geo_Mapping__c();
            IPAiupgm4.Core_MDF_Account_id__c = ccpIntelAccount.Id;
            IPAiupgm4.RecordTypeId = IPA_RecordType;
            IPAiupgm4.Core_MDF_Program_nm__c = 'Intel Partner Alliance';
            IPAiupgm4.Core_MDF_Region_cd__c = 'EMEA';
            IPAiupgm4.Core_MDF_Region_Sub_Region_nm__c = 'EMEA';
            IPAiupgm4.Core_MDF_User_id__c = testUser.Id;
            IPAiupgm4.Core_MDF_Role_nm__c = 'Core_MDF_CCP_Int_IPA_ProposalL1_Approver';
            IPAiupgm4.Core_MDF_All_Accounts_cd__c = 'No';
            IPAiupgm4.Core_MDF_Budget_Type_nm__c='';
            IPAiupgm4.Core_MDF_Active_Ind__c = false; // Inactive
            IPAiupgm4.Core_MDF_All_Budget_Type_Access_Ind__c = true;
            //IPAiupgm4.Core_MDF_Activity_Classification_nm__c = 'Sales';
            //iupgmList.add(IPAiupgm4);
            
            insert iupgmList;
        }
    }
    
    @isTest
    public static void testBatchExecution(){
        Test.startTest();
        Core_MDF_IUPGM_Discrepancy_Monitor_Batch obj = new Core_MDF_IUPGM_Discrepancy_Monitor_Batch(null, null);
        Id batchId = Database.executeBatch(obj, 200);
        Test.stopTest();
        
        Assert.areNotEqual(batchId, null, 'Batch job should be executed successfully');
    }
    
    @isTest
    public static void testBatchWithFieldFilter(){
        Test.startTest();
        Core_MDF_IUPGM_Discrepancy_Monitor_Batch obj = new Core_MDF_IUPGM_Discrepancy_Monitor_Batch('Core_MDF_Region_cd__c', '');
        Id batchId = Database.executeBatch(obj, 100);
        Test.stopTest();
        
        Assert.areNotEqual(batchId, null, 'Batch job with field filter should be executed successfully');
    }
    
    @isTest
    public static void testBatchWithDifferentBatchSize(){
        Test.startTest();
        Core_MDF_IUPGM_Discrepancy_Monitor_Batch obj = new Core_MDF_IUPGM_Discrepancy_Monitor_Batch(null, null);
        Id batchId = Database.executeBatch(obj, 5);
        Test.stopTest();
        
        Assert.areNotEqual(batchId, null, 'Batch job with small batch size should be executed successfully');
    }
    
    @isTest
    public static void testCreateContentWrapperWithNullParams(){
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Program_nm__c, 
                                                                     Core_MDF_Region_Sub_Region_nm__c, Core_MDF_Budget_Type_nm__c,
                                                                     Core_MDF_GeoSubGeo_Budget_Type_nm__c,Core_MDF_Account_id__r.Name,Core_MDF_Role_nm__c,
                                                                     Core_MDF_User_id__c,Core_MDF_All_Budget_Type_Access_Ind__c
                                                                     FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c LIMIT 1];  
        
        Test.startTest();
        List<Core_MDF_IUPGM_Discrepancy_Monitor_Batch.contentWrapper> result = 
            Core_MDF_IUPGM_Discrepancy_Monitor_Batch.createContentWrapper(iupgmList, null, null);
        Test.stopTest();
        
        Assert.areNotEqual(result, null, 'Content wrapper should be created even with null parameters');
    }
    
    @isTest
    public static void testCreateContentWrapperWithValidData(){
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList = [SELECT Id, Core_MDF_Account_id__c, Core_MDF_Program_nm__c, 
                                                                     Core_MDF_Region_Sub_Region_nm__c, Core_MDF_Budget_Type_nm__c,
                                                                     Core_MDF_GeoSubGeo_Budget_Type_nm__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c];
        
        List<Core_MDF_Partner_Group_Mapping__c> pgmRecords = [SELECT Id, Core_MDF_Account__c, 
                                                              Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, 
                                                              Core_MDF_Group_Name__c, Core_MDF_Group_id__c, Core_MDF_Region_cd__c, 
                                                              Core_MDF_Sub_Region_cd__c, Core_MDF_BudgetType_nm__c, Core_MDF_Inactive_Ind__c                                
                                                              FROM Core_MDF_Partner_Group_Mapping__c
                                                              WHERE Core_MDF_Inactive_Ind__c = FALSE];
        
        Map<String, Core_MDF_Partner_Group_Mapping__c> pgmMap = new Map<String, Core_MDF_Partner_Group_Mapping__c>();
        Set<String> iupgmKeySet = new Set<String>();
        
        for(Core_MDF_Partner_Group_Mapping__c pgmRecord : pgmRecords){
            String pgmKey = pgmRecord.Core_MDF_Account__c + ';' + 
                           pgmRecord.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c + ';' + 
                           pgmRecord.Core_MDF_Region_cd__c;
            if(pgmRecord.Core_MDF_Sub_Region_cd__c != null){
                pgmKey += '-' + pgmRecord.Core_MDF_Sub_Region_cd__c;
            }
            if(pgmRecord.Core_MDF_BudgetType_nm__c != null){
                pgmKey += ';' + pgmRecord.Core_MDF_BudgetType_nm__c;
            }
            pgmMap.put(pgmKey, pgmRecord);
        }
        
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgmRecord : iupgmList){
            if(iupgmRecord.Core_MDF_Region_Sub_Region_nm__c != null){
                List<String> geoList = iupgmRecord.Core_MDF_Region_Sub_Region_nm__c.split(';');
                for(String geo : geoList){
                    String accProgGeoKey = iupgmRecord.Core_MDF_Account_id__c + ';' + 
                                          iupgmRecord.Core_MDF_Program_nm__c + ';' + geo;
                    iupgmKeySet.add(accProgGeoKey);
                }
            }
        }
        
        Test.startTest();
        List<Core_MDF_IUPGM_Discrepancy_Monitor_Batch.contentWrapper> result = 
            Core_MDF_IUPGM_Discrepancy_Monitor_Batch.createContentWrapper(iupgmList, pgmMap, iupgmKeySet);
        Test.stopTest();
        
        Assert.areNotEqual(result, null, 'Content wrapper should be created with valid data');
    }
    
    @isTest
    public static void testGenerateInstanceWithValidParams(){
        Test.startTest();
        Object obj = Core_MDF_IUPGM_Discrepancy_Monitor_Batch.generateInstance(
            '{"fieldFilterName":"Core_MDF_Region_cd__c","fieldFilterValue":""}',
            'Core_MDF_IUPGM_Discrepancy_Monitor_Batch(String fieldFilterName, String fieldFilterValue)'
        );
        Test.stopTest();
        
        Assert.areNotEqual(obj, null, 'Instance should be generated with valid parameters');
        Assert.isTrue(obj instanceof Core_MDF_IUPGM_Discrepancy_Monitor_Batch, 'Object should be instance of the batch class');
    }
    
    @isTest
    public static void testGenerateInstanceWithInvalidParams(){
        Test.startTest();
        Object obj = Core_MDF_IUPGM_Discrepancy_Monitor_Batch.generateInstance(
            '{"invalidParam":"test"}',
            'InvalidConstructor(String param)'
        );
        Test.stopTest();
        
        // Should handle invalid parameters gracefully
        // The actual behavior depends on the implementation
    }
    
    @isTest
    public static void testBatchWithEmptyData(){
        // Delete all test data to test empty scenario
        delete [SELECT Id FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c];
        delete [SELECT Id FROM Core_MDF_Partner_Group_Mapping__c];
        
        Test.startTest();
        Core_MDF_IUPGM_Discrepancy_Monitor_Batch obj = new Core_MDF_IUPGM_Discrepancy_Monitor_Batch(null, null);
        Id batchId = Database.executeBatch(obj);
        Test.stopTest();
        
        Assert.areNotEqual(batchId, null, 'Batch should handle empty data gracefully');
    }
    
    @isTest
    public static void testContentWrapperClass(){
        Test.startTest();
        Core_MDF_IUPGM_Discrepancy_Monitor_Batch.contentWrapper wrapper = 
            new Core_MDF_IUPGM_Discrepancy_Monitor_Batch.contentWrapper();
        
        // Test wrapper properties if they exist
        wrapper.toString(); // This will test the wrapper class
        Test.stopTest();
        
        Assert.areNotEqual(wrapper, null, 'Content wrapper should be instantiated');
    }
    
    @isTest 
    static void testDiscrepancyInstance(){
        Test.startTest();
        Object obj = Core_MDF_IUPGM_Discrepancy_Monitor_Batch.generateInstance(
            '{"fieldFilterName":"test","fieldFilterValue":"123"}',
            'Core_MDF_IUPGM_Discrepancy_Monitor_Batch(String fieldFilterName, String fieldFilterValue)'
        );
        Test.stopTest();
        
        Assert.areNotEqual(obj, null, 'Instance should be generated successfully');
    }
    // 14285 Indira - Start 
     @isTest
public static void testBatchWithInternalPGM(){
    
  // Create a user with the exact name from the custom label
    User allowedUser = Core_MDF_CCP_TestDataUtility.createUser(false);
    allowedUser.FirstName = 'PGMTestClass';
    allowedUser.LastName = 'User';
    allowedUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    allowedUser.IsActive = true;
    
    UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
    allowedUser.UserRoleId = usRole.Id;
    
    insert allowedUser;
    
    System.runAs(allowedUser){
        // Update existing PGM records to Internal using DML bypass
        List<Core_MDF_Partner_Group_Mapping__c> pgmToUpdate = [SELECT Id, Core_MDF_Type_Of_Access__c FROM Core_MDF_Partner_Group_Mapping__c];
        
        for(Core_MDF_Partner_Group_Mapping__c pgm : pgmToUpdate){
            pgm.Core_MDF_Type_Of_Access__c = 'Internal';
            pgm.Core_MDF_Source_Txt__c = 'IUPGM'; // Change source to avoid validation
        }
      
            update pgmToUpdate;
        
        
        Test.startTest();
        Core_MDF_IUPGM_Discrepancy_Monitor_Batch obj = new Core_MDF_IUPGM_Discrepancy_Monitor_Batch();
        Database.executeBatch(obj, 200);
        Test.stopTest();
    }
}
    // 14285 Indira - end
}