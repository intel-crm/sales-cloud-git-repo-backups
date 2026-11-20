@istest
public class Core_AAQC_Case_Ask_Commissions_Hndr_Test {

    /*@isTest
    public static void TestInsertTrue(){
        Case c = CreateTestCase(UserInfo.getUserId(), true, true);
    }
    
    @isTest
    public static void TestInsertFalse(){
        Case c = CreateTestCase(UserInfo.getUserId(), false, true);
    }

    /*@isTest 
    public static void TestShareCase(){
        System.debug('Core_AAQC_Case_Ask_Commissions_Hndr_Test TestShareCase');
        User manager = CreateManager();
        User salesUser = CreateUser(manager.Id);
        Case c = CreateTestCase(salesUser.Id, false, true);        
        
        Test.startTest();
        boolean result = Core_AAQC_Case_Ask_Commissions_Handler.ShareCase(c.Id, manager.Id);
        Test.stopTest();
        
        System.assertEquals(result, true);
    }

        @isTest 
    public static void TestShareCaseNegative(){
        System.debug('Core_AAQC_Case_Ask_Commissions_Hndr_Test TestShareCaseNegative');
        User manager = CreateManager();
        User salesUser = CreateUser(manager.Id);
        Case c = CreateTestCase(salesUser.Id, false, true);        
        
        boolean result = Core_AAQC_Case_Ask_Commissions_Handler.ShareCase(null, null);
        System.assertEquals(result, false);
        result = Core_AAQC_Case_Ask_Commissions_Handler.ShareCase(c.Id, null);
        System.assertEquals(result, false);
    }

    @isTest 
    public static void TestShareCaseWithManager(){
        System.debug('Core_AAQC_Case_Ask_Commissions_Hndr_Test TestShareCaseWithManager');
        User manager = CreateManager();
        User salesUser = CreateUser(manager.Id);
        Case c = CreateTestCase(salesUser.Id, false, true);        
        List<case> abc= new List<case>{c};
        Test.startTest();
        boolean result = Core_AAQC_Case_Ask_Commissions_Handler.ShareCaseWithManager(c);
         Core_AAQC_Case_Ask_Commissions_Handler.UpdateCreatedByManagerEmail(abc,null);
        Test.stopTest();
        
        
    }*/

    /*    @isTest 
    public static void TestUnShareCaseWithManager(){
        System.debug('Core_AAQC_Case_Ask_Commissions_Hndr_Test TestUnShareCaseWithManager');
        User manager = CreateManager();
        User salesUser = CreateUser(manager.Id);
        Case c = CreateTestCase(salesUser.Id, false, true);  
        List<case> abc= new List<case>{c};
        boolean result = Core_AAQC_Case_Ask_Commissions_Handler.ShareCaseWithManager(c);
        
        
        Test.startTest();
        result = Core_AAQC_Case_Ask_Commissions_Handler.UnShareCaseWithManager(c);
        Core_AAQC_Case_Ask_Commissions_Handler.UpdateCreatedByManagerEmail(abc,null);
        Core_AAQC_Case_Ask_Commissions_Handler.ShareWithOBOField(abc);
        Test.stopTest();
        
       
    }
    
    @isTest 
    public static void TestShareCaseWithManagerNegative(){
        System.debug('Core_AAQC_Case_Ask_Commissions_Hndr_Test TestShareCaseWithManagerNegative');
        User manager = CreateManager();
        User salesUser = CreateUser(null);
        Case c = CreateTestCase(salesUser.Id, false, true);        
        List<case> abc= new List<case>{c};
        boolean result = Core_AAQC_Case_Ask_Commissions_Handler.ShareCaseWithManager(c);
        System.assertEquals(result, false);
        result = Core_AAQC_Case_Ask_Commissions_Handler.ShareCaseWithManager(null);
        Core_AAQC_Case_Ask_Commissions_Handler.UpdateCreatedByManagerEmail(abc,null);
        System.assertEquals(result, false);
    }

    @isTest 
    public static void TestManagerUnShareCase(){
        System.debug('Core_AAQC_Case_Ask_Commissions_Handler_Test TestManagerUnShareCase BeginTest');
        User manager = CreateManager();
        User salesUser = CreateUser(manager.Id);
        
        Case c = CreateTestCase(salesUser.Id, false, true);        
        
        List<CaseShare> caseShares2 = [SELECT Id, UserOrGroupId, 
            RowCause, CaseId FROM CaseShare WHERE CaseId = :c.Id AND UserOrGroupId= :manager.Id];

        system.debug('Core_AAQC_Case_Ask_Commissions_Handler_Test TestManagerUnShareCase caseShares2 ' + caseShares2);

        List<CaseShare> caseShares3 = [SELECT Id, UserOrGroupId, 
            RowCause, CaseId FROM CaseShare WHERE CaseId = :c.Id];

        system.debug('Core_AAQC_Case_Ask_Commissions_Handler_Test TestManagerUnShareCase caseShares3 ' + caseShares3);
        
        List<CaseShare> caseShares = [SELECT Id, UserOrGroupId, 
            RowCause, CaseId FROM CaseShare WHERE CaseId = :c.Id AND UserOrGroupId= :manager.Id];

        system.debug('Core_AAQC_Case_Ask_Commissions_Handler_Test TestManagerUnShareCase caseShares ' + caseShares);

        c.Core_AAQC_Allow_My_Manager_to_See__c = true;
        update c;

        List<CaseShare> caseShares4 = [SELECT Id, UserOrGroupId, 
            RowCause, CaseId FROM CaseShare WHERE CaseId = :c.Id];

        system.debug('Core_AAQC_Case_Ask_Commissions_Handler_Test TestManagerUnShareCase caseShares4 ' + caseShares4);
        
        Test.startTest();
        c.Core_AAQC_Allow_My_Manager_to_See__c = false;
        update c;
        Test.stopTest();
        
         List<CaseShare> caseSharesNew = [SELECT Id, UserOrGroupId, 
            RowCause FROM CaseShare WHERE CaseId = :c.Id];

	    system.debug('Core_AAQC_Case_Ask_Commissions_Handler_Test TestManagerUnShareCase caseSharesNew ' + caseSharesNew);
    }

    @isTest 
    public static void TestCaseRecordType(){
        System.debug('Core_AAQC_Case_Ask_Commissions_Hndr_Test TestCaseRecordType');
        User manager = CreateManager();
        User salesUser = CreateUser(manager.Id);
        Case c = CreateTestCase(salesUser.Id, true, false);        
        System.debug('Core_AAQC_Case_Ask_Commissions_Hndr_Test TestCaseRecordType Case ' + c);
    }
    
    @isTest 
    public static void TestUnShareCase(){
        System.debug('Core_AAQC_Case_Ask_Commissions_Hndr_Test TestUnShareCase');
        User manager = CreateManager();
        User salesUser = CreateUser(manager.Id);
        Case c = CreateTestCase(salesUser.Id, false, true);        
        Core_AAQC_Case_Ask_Commissions_Handler.ShareCase(c.Id, manager.Id);
        
        Test.startTest();
        boolean result = Core_AAQC_Case_Ask_Commissions_Handler.UnShareCase(c.Id, manager.Id);
        Test.stopTest();
        
        System.assertEquals(result, true);
    }

    
    @isTest static void NegativeTest(){
        User manager = CreateManager();
        User salesUser = CreateUser(manager.Id);
        Case c = CreateTestCase(salesUser.Id, false, true);        
		boolean result = false;
        
        result = Core_AAQC_Case_Ask_Commissions_Handler.ShareCase(null, null);
        System.assertEquals(result, false);

        result = Core_AAQC_Case_Ask_Commissions_Handler.ShareCase(c.Id, null);
        System.assertEquals(result, false);
        
        result = Core_AAQC_Case_Ask_Commissions_Handler.UnShareCase(null, null);
        System.assertEquals(result, false);

        result = Core_AAQC_Case_Ask_Commissions_Handler.UnShareCase(c.Id, null);
        System.assertEquals(result, false);
    }

    */
    @isTest
     static void CreateTestCase(){
        
        test.startTest();
        id RecordTypeId = Core_AAQC_Case_Ask_Commissions_Handler.GetAskCommissionsRecordTypeId();
        Test.stopTest();
    }

    /*private static User CreateManager(){
          Profile p = [SELECT Id FROM Profile WHERE Name='Sales Manager'];
          User u = new User(Alias = 'salman',
                            Email='SalesManagerBB@example.com',
                            EmailEncodingKey='UTF-8',
                            FirstName='FirstManager',
                            LastName='LastManager',
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US',
                            ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName='SalesManagerTest@intel123.com');
        insert u;
        return u;
    }
    
    private static User CreateUser(Id managerId){
          Profile p = [SELECT Id FROM Profile WHERE Name='Sales Rep-BB'];
          User u = new User(Alias = 'salrep',
                            Email='SalesRepBB123@example.com',
                            EmailEncodingKey='UTF-8',
                            FirstName='SalesFirst',
                            LastName='SalesLast',
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US',
                            ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName='SalesUserTest@intel123.com',
                            ManagerId = managerId
                           );
        insert u;
        return u;
    }*/
        
}