@isTest
private class Core_AAQC_Case_Ask_Comm_Hndr_Test1 {
    
    @testSetup static void setup() {
        id RecordTypeId1 = Core_AAQC_Case_Ask_Commissions_Handler.GetAskCommissionsRecordTypeId();
        // Create common test cases
        Case c= new Case();
        c.Origin = 'My Origin';
        c.status ='Draft';
        c.Subject= 'Ask commision case subject';
        c.Core_AAQC_Commissions_Severity__c='test';
        c.Core_AAQC_Resolution_Type__c ='Training';
        insert c; 
        System.assert(c.Id != null, 'Case Record not created');
        
        // Create common Commission case
        Core_AAQC_Commissions_Case__c com =new Core_AAQC_Commissions_Case__c ();
        com.Core_AAQC_Case__c=c.id;
        insert com;
        System.assert(com.Id != null, 'Case Inquiry Record not created');
    }
    
    public static testMethod void ShareWithOBOField_Test(){
            setup();
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
                            UserName='SalesUserTest@intel123.com'
                           );
            insert u;
            id RecordTypeId1 = Core_AAQC_Case_Ask_Commissions_Handler.GetAskCommissionsRecordTypeId();
            case c =[SELECT Id,Core_AAQC_On_Behalf_Of__c,Core_AAQC_Owner_Updated__c,RecordTypeId FROM case LIMIT 1];
            c.Core_AAQC_On_Behalf_Of__c = u.Id;
            c.Core_AAQC_Owner_Updated__c = true;
            c.RecordTypeId = RecordTypeId1;
            update c;
            List<case> lstnewcase = new List<case>{c};
            Test.StartTest();
                Core_AAQC_Case_Ask_Commissions_Handler.ShareWithOBOField(lstnewcase);
            Test.StopTest();
    }
    
    public static testMethod void UpdateCreatedByManagerEmail_Positive_Test(){
            setup();
            id RecordTypeId1 = Core_AAQC_Case_Ask_Commissions_Handler.GetAskCommissionsRecordTypeId();
            case c =[SELECT Id,Core_AAQC_On_Behalf_Of__c,Core_AAQC_Owner_Updated__c,RecordTypeId,Core_AAQC_Allow_My_Manager_to_See__c,CreatedById FROM case LIMIT 1];
            c.Core_AAQC_Allow_My_Manager_to_See__c = true;
            c.Core_AAQC_Owner_Updated__c = true;
            c.RecordTypeId = RecordTypeId1;
            update c;
            List<case> lstnewcase = new List<case>{c};
            Test.StartTest();
                Core_AAQC_Case_Ask_Commissions_Handler.UpdateCreatedByManagerEmail(lstnewcase,null);
                Core_AAQC_Case_Ask_Commissions_Handler.ShareWithMyManager(lstnewcase,null);
            Test.StopTest();
    }
    public static testMethod void UpdateCreatedByManagerEmail_Negative_Test(){
            setup();
            id RecordTypeId1 = Core_AAQC_Case_Ask_Commissions_Handler.GetAskCommissionsRecordTypeId();
            case c =[SELECT Id,Core_AAQC_On_Behalf_Of__c,Core_AAQC_Owner_Updated__c,RecordTypeId,Core_AAQC_Allow_My_Manager_to_See__c,CreatedById FROM case LIMIT 1];
            c.Core_AAQC_Allow_My_Manager_to_See__c = false;
            c.Core_AAQC_Owner_Updated__c = true;
            c.RecordTypeId = RecordTypeId1;
            update c;
            List<case> lstnewcase = new List<case>{c};
            Test.StartTest();
                Core_AAQC_Case_Ask_Commissions_Handler.UpdateCreatedByManagerEmail(lstnewcase,null);
                Core_AAQC_Case_Ask_Commissions_Handler.ShareWithMyManager(lstnewcase,null);
            Test.StopTest();
    }
    
}