@isTest
public class PFR_Test1 {
	@isTest
    static void toTestSetupMethod(){
        /*List<String> bypassFunctionKeys = new List<String>();
        bypassFunctionKeys.add('Bypass_ValidateActivityWithCampaign');
        bypassFunctionKeys.add('Bypass_MDF_Budget_Access');
        Set<String> myset1 = new Set<String>();
        List<String> result1 = new List<String>();
        myset1.addAll(bypassFunctionKeys);
        result1.addAll(myset1);*/
        
       // List<Core_Trigger_Executions__c> bypassfunctinalitylist1 = Core_MDF_CCP_TestDataUtility.byPassFeature(result1,true,true);
        profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'MDF Budget Loader';
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', True);
        //insert cp;
         Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account', cp.Id,
                                                                              Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
        insert acc;
        channelProgram cpRetail = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', True);
 		Account acc1Retail = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account Retail', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, 
                                                                                  false);
      acc1Retail.Core_Account_Type__c = 'Reseller';
      acc1Retail.Industry = 'Food & Beverage';
      acc1Retail.Core_MDF_Channel_Program__c = cpRetail.Id;
      acc1Retail.Core_Geo__c = 'APJ';            
      acc1Retail.Core_Sub_Geo__c = 'IJKK';
	  Account accRetail = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing Test Account Retail', cpRetail.Id,
                                                                            Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
      accRetail.Core_MDF_Parent_Fund_Account__c = acc1Retail.Id;
      //accRetail.Core_Geo__c = 'APJ';
      //accRetail.Core_Sub_Geo__c = 'IJKK';
       /*User usertest = Core_MDF_CCP_TestDataUtility.createUser(false);
       usertest.LastName = 'testUser';
       usertest.IsActive = true;*/
        test.startTest();
        
        insert acc1Retail;
        insert accRetail;
        //insert usertest;
        test.stopTest();
        String retailBudgetRT = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Retail_Marketing_Funds').getRecordTypeId();
         Id recordTypeIdPMB = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByName().get('CoMarketing').getRecordTypeId();
        
        system.runAs(usr)
        {
        PermissionSet psFinance = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Finance_Usr' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance.Id);
            PermissionSet psFinance1 = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_User' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psFinance1.Id);
             permissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_Retail_Finance_Usr' LIMIT 1];
           insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = ps.Id);
            PermissionSet psbudLoader = [SELECT Id FROM PermissionSet WHERE Name = 'Core_MDF_CCP_Internal_CCF_MDF_Budget_Loader' LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = usr.id, PermissionSetId = psbudLoader.Id);
           // insert budgetList;
            
        }
       	 PartnerMarketingBudget  pmbRecord = Core_MDF_CCP_TestDataUtility.createBudget('TestPMB',RecordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
         PartnerMarketingBudget opalbudgetMDF = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB',recordTypeIdPMB,acc.Id,cp.Id,12345678,System.today().addDays(1),System.today().addDays(15),false);
         PartnerMarketingBudget opalbudgetMDF1 = Core_MDF_CCP_TestDataUtility.createBudget('TestOpalPMB1',recordTypeIdPMB,acc.Id,cp.Id,100000,System.today().addDays(16),System.today().addDays(30),false);
         PartnerMarketingBudget OEMPMB = Core_MDF_CCP_TestDataUtility.createBudget('TestoemcmpPMB',recordTypeIdPMB,acc.Id,cp.Id,100000,System.today().addDays(16),System.today().addDays(30),false);
        PartnerMarketingBudget retailbudget = Core_MDF_CCP_TestDataUtility.createBudget('Retail TestBudget',retailBudgetRT,accRetail.Id,cpRetail.Id,200000,System.today(),System.today(), false);
            PartnerMarketingBudget retailbudgetMD = Core_MDF_CCP_TestDataUtility.createBudget('Retail TestBudget MD',retailBudgetRT,accRetail.Id,cpRetail.Id,200000,System.today(),System.today(), false);
            retailBudget.Core_MDF_Budget_Type__c = 'Retail MDF';
            retailbudgetMD.Core_MDF_Budget_Type__c = 'RSA MD';
             retailBudget.Core_MDF_Budget_Type_Txt__c = 'Retail MDF';
           retailbudgetMD.Core_MDF_Budget_Type_Txt__c = 'RSA MD';
         
         pmbRecord.Core_MDF_Budget_Type__c='MDF';
         
         pmbRecord.Core_MDF_Budget_Type_Txt__c='MDF';
        OEMPMB.Core_MDF_Budget_Type__c='OEM CMP';
        OEMPMB.Core_MDF_Budget_Type_Txt__c='OEM CMP';
        opalbudgetMDF.Core_MDF_Budget_Type_Txt__c='MDF';
        opalbudgetMDF.Core_MDF_Budget_Type__c='MDF';
        opalbudgetMDF1.Core_MDF_Budget_Type__c='MDF';
        opalbudgetMDF1.Core_MDF_Budget_Type_Txt__c='MDF';
        List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
        budgetList.add(pmbRecord);
        budgetList.add(OEMPMB);
        budgetList.add(opalbudgetMDF);
        budgetList.add(retailbudget);
        budgetList.add(retailbudgetMD);
        
        system.runAs(usr){
            insert budgetList;
        }
        
		
        }
}