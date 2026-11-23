@isTest
public class PMP_SearchCompanyLeadGenAction_Test {
    
     @testSetup
    static void setupTestData() {
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Company_Info_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update and create Partners');
        insert cs;
    }
	
    @isTest
    static void updatePublishedCopyTest(){
        
       
        Account acc = PMP_SearchTestDataFactory.createIntelAccount('TestAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        
        PMP_Company__c partner = new PMP_Company__c(Name='workingPartner', PMP_Is_Working_Copy_Ind__c = true);
        insert partner;
        
        PMP_Company__c pubPartner = new PMP_Company__c(Name='pubPartner', PMP_Is_Published_Ind__c=true, PMP_Working_Copy_Id__c=partner.Id);
      	insert pubPartner;
        Test.startTest();
        partner.PMP_Published_Copy_Id__c = pubPartner.Id;
        partner.PMP_Is_Working_Copy_Ind__c = true;
        partner.PMP_Is_Enabled_Lead_Gen_Nm__c = 'True';
        partner.PMP_Is_Lead_Gen_Limited_Nm__c = 'True';
        partner.PMP_Company_Lead_Gen_Language_Nm__c = 'English';
        update partner;
        
        Test.stopTest();
        
    }
    
}