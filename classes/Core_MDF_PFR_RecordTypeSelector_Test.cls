/***************************************************************************************************** 
Class Name :    Core_MDF_PFR_RecordTypeSelector_Test
Description:    This is the test class for Core_MDF_PFR_RecordTypeSelector class
Added By   :    Accenture - SKS 
Modified By:                      Date:07/31/2018                     Changes:None  
******************************************************************************************************/
@isTest
private class Core_MDF_PFR_RecordTypeSelector_Test
{
    @TestSetup 
    static void createTestData(){
     
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        Database.insert(usr);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
        
        System.runAs(usr){
            
            List<String> bypassFunctionKeys = new List<String>();
            Set<String> myset1 = new Set<String>();
            List<String> result1 = new List<String>();
            bypassFunctionKeys.add('byPassCampaignAndRelatedRecords');
            bypassFunctionKeys.add('byPassShareUnshareCampaignRecord');
            bypassFunctionKeys.add('Core_MDF_Bypass_Campaign_Trigger');
            myset1.addAll(bypassFunctionKeys);
            result1.addAll(myset1);

            
            
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            Set<String> psNameSet = new Set<String> ();
            Map<string,String>  psNameVsIdMap = new Map<string,String>();
            psNameSet.add('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
            psNameSet.add('Core_MDF_CCP_Internal_Generic_Access');
            psNameVsIdMap = getPermissionSetIdbyName(psNameSet);
            String ccfAcctMgrPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_CCF_Acct_Mgr');
            String genricAccessPsId =  psNameVsIdMap.get('Core_MDF_CCP_Internal_Generic_Access');
            User ccfaccntmngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            Database.insert(ccfaccntmngr);
            
            List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
            psAssignList.add(new PermissionSetAssignment(AssigneeId = ccfaccntmngr.id, PermissionSetId =ccfAcctMgrPsId));   
            psAssignList.add(new PermissionSetAssignment(AssigneeId = ccfaccntmngr.id, PermissionSetId =genricAccessPsId));   
            insert psAssignList;
            
            ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
            //Creating Test Acc New 1-  Intel Account using Data Utility
            Account accIntel = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
            // Creating Co-marketing Account with utility class
            Account accCoMarketing = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account 2', cp.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type,  false);
            accCoMarketing.Core_MDF_Parent_Fund_Account__c = accIntel.Id;
            accCoMarketing.Core_MDF_CoMarketing_Ultimate_Account__c = accIntel.Id;
            Database.insert(accCoMarketing);
            accCoMarketing.IsPartner = true;
            Database.update(accCoMarketing); 
            Campaign camp= Core_MDF_CCP_TestDataUtility.createCampaign('TestCamp','Consumer','Intel® Corporate Logo','Yes', 
                                                                       Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund',System.today() , 
                                                                       System.today().addYears(1), 2000, 'Unite', accCoMarketing.Id,'2-in-1', false);
            camp.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
            insert camp;    
            
        }
        
    }
    
    static Map<string,String> getPermissionSetIdbyName(Set<String> psNameSet){
        Map<string,String>  resultMap = new Map<string,String>();
        for(permissionSet ps: [SELECT Id , Name
                               FROM PermissionSet
                               WHERE Name IN:psNameSet]){
             resultMap.put(ps.Name, ps.Id);
            
        }
        return resultMap;
    }
    
    @isTest
    static void fetchRecordTypeValuesTest()
    {
        Test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        Map<String, String> newrecordtypemap = new map<String,string>();
        System.runAs(user1){  
            string objectName = 'Campaign';
            newrecordtypemap= Core_MDF_PFR_RecordTypeSelector.fetchRecordTypeValues(objectName);   
        }
        Test.stopTest();
        Assert.isTrue(newrecordtypemap.values().contains(Core_MDF_CCP_ConstantClass.CCF_PROGRAM));
    }
    
    @isTest
    static void fetchRecordTypeTest()
    {
        Test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];

        string objectName = 'Campaign';
        Core_MDF_PFR_RecordTypeSelector.recordTypeWrapper result=new Core_MDF_PFR_RecordTypeSelector.recordTypeWrapper();
        System.runAs(user1){ 
           result= Core_MDF_PFR_RecordTypeSelector.fetchRecordType(objectName);
        }
        Test.stopTest();
        Map<String, String> recordTypeDevNameAndLabelName=result.recordTypeDevNameAndLabelName;
        Assert.isTrue(recordTypeDevNameAndLabelName.values().contains(Core_MDF_CCP_ConstantClass.CCF_PROGRAM));
    }
    
    
    @isTest
    static void fetchRecordTypeValues_string_id_Test()
    {
        Test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        string objectName = 'Campaign';

        Map<String,id>  testMap=new Map<String,id>();
        System.runAs(user1){
           testMap= Core_MDF_PFR_RecordTypeSelector.fetchRecordTypeValues_string_id(objectName);
        }
        Test.stopTest();
        Assert.isTrue(testMap.containsKey('Core_MDF_Client_CoMarketing_Fund'));
    }
    
    @isTest
    static void getRtFieldSetMappingsTest()
    {
        Test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        
        string objectName = 'Campaign';
        List<Core_MDF_RecordType_FieldSet_Mapping__mdt>  testList=new List<Core_MDF_RecordType_FieldSet_Mapping__mdt>();
        System.runAs(user1){
          testList=Core_MDF_PFR_RecordTypeSelector.getRtFieldSetMappings(objectName,'Core_MDF_Custom_Picklist__c','create');
        }
        Test.stopTest();
        // US - TWC702-14285: Unit Test Method should include System.Assert
        System.assertNotEquals(null, testList, 'getRtFieldSetMappings should return a non-null list');
    }
   
    @isTest
    static void getCampaignFieldsTest()
    {
        Test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];

        Campaign camp = [SELECT id FROM Campaign WHERE Name = 'TestCamp' LIMIT 1];
        Campaign resultCamp;
        System.runAs(user1){
           Id myId = camp.id;
           resultCamp=Core_MDF_PFR_RecordTypeSelector.getCampaignFields(myId);
        }
        Test.stopTest();
        Assert.areEqual('Client CoMarketing Fund', resultCamp.Core_MDF_Program__c);
    }
   @isTest
    static void testCreatePermission(){
       
        Test.startTest();
        User user1 = [SELECT id,email FROM User WHERE email='ccfaccntmngr@example.com' LIMIT 1];
        Boolean result1;
        System.runAs(user1){
            String objectName = 'PartnerFundRequest';
            result1 = Core_MDF_PFR_RecordTypeSelector.checkSObjectCreatePermission(objectName);   
        }
        
        Test.stopTest();
        Assert.areEqual(true, result1);
    }
    @isTest
    static void getRtBudTypeFieldSetMappingsTest()
    {
        Test.startTest();
        User user1 = [select id,email from User where email='ccfaccntmngr@example.com' limit 1];
        

        List<Core_MDF_RecordType_FieldSet_Mapping__mdt>  testList=new List<Core_MDF_RecordType_FieldSet_Mapping__mdt>();
        System.runAs(user1){
          testList=Core_MDF_PFR_RecordTypeSelector.getRtBudTypeFieldSetMappings('Core_MDF_Custom_Picklist__c','Account Plan');
          
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
        
        Core_MDF_PFR_RecordTypeSelector.userHasPermissionSet(perset);
        }
        
        Test.stopTest();
        // US - TWC702-14285: Unit Test Method should include System.Assert
        System.assertNotEquals(null, testList, 'getRtBudTypeFieldSetMappings should return a non-null list');
    }
   /*  @isTest
    static void testgetRtBudTypeFieldSetMappings(){
        
        Test.startTest();
        User usr = [select id,LastName from User where LastName='User Test' ];
         String objectName;
        String budgetName;
        System.runAs(usr){
            objectName = 'PartnerFundRequest';
            budgetName = 'MDF';
        }
        Test.stopTest();
        System.assert(Core_MDF_PFR_RecordTypeSelector.getRtBudTypeFieldSetMappings(objectName,budgetName)  != null);
   
    }
      @isTest
    static void testUserHasPermissionSet()
    {
        Test.startTest();
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
        System.assert(Core_MDF_PFR_RecordTypeSelector.userHasPermissionSet(perset)  != null);
        Test.stopTest();
    }*/
}