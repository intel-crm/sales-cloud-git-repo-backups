@isTest
public class PMP_Acc_ERPM_Eng_TriggerActions_Test {
    @testSetup
    static void setupTestData() {
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'erpm_acc_handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'Core_Acct_erpm_eng_TriggerHandler',
                                                                        Core_Object__c = 'Core_Account_ERPM_Engagement__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update, After Delete',
                                                                        Core_Description__c = 'this updates the comp info Partner Program and Program Membership fields when ERPM accounts created/updated.');
        insert cs;
        
        Account partner_acc = PMP_SearchTestDataFactory.createIntelAccount('Test PAG Account', PMP_SearchTestDataFactory.Partner_Account_Record_Type, true);
        Account intel_acc = PMP_SearchTestDataFactory.createIntelAccount('Test Intel Account', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
		PMP_SearchTestDataFactory.createCompanyInformation(intel_acc.Name, intel_acc.Id, true);
        Core_Account_Group_Member__c group_mem = PMP_SearchTestDataFactory.createPAGMember(partner_acc.Id, intel_acc.Id, true, false, true);        
    }
    
    static testMethod void AccountERPMTest() {
        List<Account> acc_lst = [Select Id from Account where RecordTypeId =: PMP_SearchTestDataFactory.intel_Account_Record_Type];
        test.startTest();
        Core_ERPM_Engagement__c engagement = PMP_SearchTestDataFactory.createERPMEngagement('ISA', true);
        Core_Account_ERPM_Engagement__c acc_erpm_valid = PMP_SearchTestDataFactory.createAccountERPMEngagement(acc_lst[0].Id, engagement.Id, '', true);
        Core_Account_ERPM_Engagement__c acc_erpm_invalid = PMP_SearchTestDataFactory.createAccountERPMEngagement(acc_lst[0].Id, engagement.Id, 'UNDETERMND', true); 
        
        acc_erpm_valid.Core_ERPM_Business_Attributes__c = 'Gold';
        update acc_erpm_valid;
        
        delete acc_erpm_valid;
        test.stopTest();
        system.assertEquals('Gold',acc_erpm_valid.Core_ERPM_Business_Attributes__c); 
    }   
}