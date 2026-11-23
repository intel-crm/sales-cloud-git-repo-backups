@isTest(SeeAllData=false)
private class Core_MDF_IPA_BudgetCap_Test {
	
    static Id ipaBudTypeCapRecordtype = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_IPA_Budget_Type_Cap').getRecordTypeId();
    @TestSetup static void setUpData(){ 
    	Test.startTest();
        List<User> userList = new List<User>();
        Map<String,Id> profileToId = new Map<String,Id>();

        for(Profile prfl:[SELECT Id,Name FROM Profile WHERE Name IN ('System Administrator')]) {
            profileToId.put(prfl.Name,prfl.Id);
        }
        User usr = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='test1@example.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = profileToId.get('System Administrator'),
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);
        usr.Email = 'sysadmin@example.com';
        userList.add(usr);
        database.insert(userList);
        List<Core_MDF_Budget_Cap__c> ipaBudgetCaps = new List<Core_MDF_Budget_Cap__c>();
        Core_MDF_Budget_Cap__c budgetCapJan = new Core_MDF_Budget_Cap__c();
        budgetCapJan.RecordtypeId = ipaBudTypeCapRecordtype;
        budgetCapJan.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
        budgetCapJan.Core_MDF_Requested_Cap_amt__c = 31;
        budgetCapJan.Core_MDF_Effective_Start_Date_Dt__c = Date.newInstance(2021, 01, 05);
        budgetCapJan.Core_MDF_Effective_End_Date_Dt__c = Date.newInstance(2021, 01, 06);
        ipaBudgetCaps.add(budgetCapJan);
        Core_MDF_Budget_Cap__c budgetCapFeb = new Core_MDF_Budget_Cap__c();
        budgetCapFeb.RecordtypeId = ipaBudTypeCapRecordtype;
        budgetCapFeb.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
        budgetCapFeb.Core_MDF_Requested_Cap_amt__c = 31;
        budgetCapFeb.Core_MDF_Effective_Start_Date_Dt__c = Date.newInstance(2021, 02, 05);
        budgetCapFeb.Core_MDF_Effective_End_Date_Dt__c = Date.newInstance(2021, 02, 06);
        ipaBudgetCaps.add(budgetCapFeb);
        System.runAs(usr){
            database.insert(ipaBudgetCaps);
        }
        Test.stopTest(); 
    }
    
    @isTest static void testDuplicateOverlappingCaps(){
        Test.startTest();
        User sysAdm = [SELECT Id,Email from User WHERE Email =: 'sysadmin@example.com' LIMIT 1];
        List<Core_MDF_Budget_Cap__c> ipaBudgetCaps = new List<Core_MDF_Budget_Cap__c>();
        Core_MDF_Budget_Cap__c budgetCapJan = new Core_MDF_Budget_Cap__c();
        budgetCapJan.RecordtypeId = ipaBudTypeCapRecordtype;
        budgetCapJan.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
        budgetCapJan.Core_MDF_Requested_Cap_amt__c = 31;
        budgetCapJan.Core_MDF_Effective_Start_Date_Dt__c = Date.newInstance(2021, 01, 05);
        budgetCapJan.Core_MDF_Effective_End_Date_Dt__c = Date.newInstance(2021, 01, 06);
        ipaBudgetCaps.add(budgetCapJan);
        Core_MDF_Budget_Cap__c budgetCapJan1 = new Core_MDF_Budget_Cap__c();
        budgetCapJan1.RecordtypeId = ipaBudTypeCapRecordtype;
        budgetCapJan1.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
        budgetCapJan1.Core_MDF_Requested_Cap_amt__c = 32;
        budgetCapJan1.Core_MDF_Effective_Start_Date_Dt__c = Date.newInstance(2021, 01, 04);
        budgetCapJan1.Core_MDF_Effective_End_Date_Dt__c = Date.newInstance(2021, 01, 07);
        ipaBudgetCaps.add(budgetCapJan1);
        Core_MDF_Budget_Cap__c budgetCapJan2 = new Core_MDF_Budget_Cap__c();
        budgetCapJan2.RecordtypeId = ipaBudTypeCapRecordtype;
        budgetCapJan2.Core_MDF_Budget_Type_nm__c = 'Client Specialties MDF';
        budgetCapJan2.Core_MDF_Requested_Cap_amt__c = 32;
        budgetCapJan2.Core_MDF_Effective_Start_Date_Dt__c = Date.newInstance(2021, 01, 04);
        budgetCapJan2.Core_MDF_Effective_End_Date_Dt__c = Date.newInstance(2021, 01, 07);
        ipaBudgetCaps.add(budgetCapJan2);
        try{
        	database.insert(ipaBudgetCaps);
        }
        catch(Exception e){
            System.debug('Exception Caught'+e);
        }
        Test.stopTest();
    }
}