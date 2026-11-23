@isTest
public class PMP_PAG_mem_handler_Test {
    @testSetup
    static void setupTestData() {
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'PAG_mem_handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'Core_Acct_Grp_Mbr_TriggerHandler',
                                                                        Core_Object__c = 'Core_Account_Group_Member__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update, Before Delet',
                                                                        Core_Description__c = 'Update the related MDA Partner info when ever Account updated.');
        insert cs;
        List<Account> accList = new List<Account>();
        Account partner_acc = PMP_SearchTestDataFactory.createIntelAccount('Test PAG Account', PMP_SearchTestDataFactory.Partner_Account_Record_Type, false);
        Account intel_acc = PMP_SearchTestDataFactory.createIntelAccount('Test Intel Account', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        // Account partner_acc1 = PMP_SearchTestDataFactory.createIntelAccount('Test PAG Account1', PMP_SearchTestDataFactory.Partner_Account_Record_Type, false);
        // Account intel_acc1 = PMP_SearchTestDataFactory.createIntelAccount('Test Intel Account1', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        accList.add(partner_acc);
        accList.add(intel_acc);
        //  accList.add(partner_acc1);
        //  accList.add(intel_acc1);
        insert accList;
        Core_ERPM_Engagement__c engagement = PMP_SearchTestDataFactory.createERPMEngagement('ISA', true);
        
        List<Core_Account_ERPM_Engagement__c> accEngList = new List<Core_Account_ERPM_Engagement__c>();
        accEngList.add(PMP_SearchTestDataFactory.createAccountERPMEngagement(intel_acc.Id, engagement.Id, 'ISA', false));
        //   accEngList.add(PMP_SearchTestDataFactory.createAccountERPMEngagement(intel_acc1.Id, engagement.Id, 'UNDETERMND', false));
        insert accEngList;
        
        List<PMP_Company__c> compList = new List<PMP_Company__c>();
        PMP_Company__c comp = PMP_SearchTestDataFactory.createCompanyInformation(intel_acc.Name, intel_acc.Id, false);
        comp.PMP_Is_Published_Ind__c = true;
        comp.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Published;
        compList.add(comp); 
        //    compList.add(PMP_SearchTestDataFactory.createCompanyInformation(intel_acc1.Name, intel_acc1.Id, false)); 
        insert compList;
        
    }
    
    /*static testMethod void PAGInsertTest(){
List<Core_Account_Group_Member__c> insert_members = new List<Core_Account_Group_Member__c>();
List<Account> partner_acc_list= [Select Id, Name,RecordTypeId from Account where RecordTypeId =: PMP_SearchTestDataFactory.Partner_Account_Record_Type];
List<Account> intel_acc_list = [Select Id, Name,RecordTypeId from Account where RecordTypeId =: PMP_SearchTestDataFactory.intel_Account_Record_Type];        
List<PMP_Company__c> comp_lst = [Select Id, Name, PMP_Account_Id__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Published_Ind__c from PMP_Company__c Where PMP_Account_Id__c IN: intel_acc_list];

for(PMP_Company__c c: comp_lst){
c.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Published;
c.PMP_Is_Published_Ind__c = true;            
}
update comp_lst;
test.startTest();
Core_Account_Group_Member__c group_mem1 = PMP_SearchTestDataFactory.createPAGMember(partner_acc_list[0].Id, intel_acc_list[0].Id, true, false, true);
Core_Account_Group_Member__c group_mem2 = PMP_SearchTestDataFactory.createPAGMember(partner_acc_list[1].Id, intel_acc_list[1].Id, false, false, true);

group_mem2.Core_MDA_Ind__c = true;
update group_mem2;        
test.stopTest();
system.assertEquals(true, group_mem2.Core_MDA_Ind__c); 
}*/
    
    @isTest static void onGroupMemAfterInsert_Test(){
        List<Account> partner_acc_list= [Select Id, Name,RecordTypeId,Core_IPA_Partner_Role__c from Account where RecordTypeId =: PMP_SearchTestDataFactory.Partner_Account_Record_Type];
        List<Account> intel_acc_list = [Select Id, Name,RecordTypeId,Core_IPA_Partner_Role__c from Account where RecordTypeId =: PMP_SearchTestDataFactory.intel_Account_Record_Type];        
        Core_Account_Group_Member__c group_mem1 = PMP_SearchTestDataFactory.createPAGMember(partner_acc_list[0].Id, intel_acc_list[0].Id, true, false, true);
        //Core_Account_Group_Member__c group_mem2 = PMP_SearchTestDataFactory.createPAGMember(partner_acc_list[1].Id, intel_acc_list[1].Id, false, false, true);
        List<PMP_Company__c> comp_lst = [Select Id, Name, PMP_Account_Id__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Published_Ind__c from PMP_Company__c Where PMP_Account_Id__c IN: intel_acc_list];
        
        List<Core_Account_Group_Member__c> newList = new List<Core_Account_Group_Member__c>();
        newList.add(group_mem1);
        //newList.add(group_mem2);
        Map<Id,Core_Account_Group_Member__c> newMap = new Map<Id,Core_Account_Group_Member__c>();
        newMap.put(group_mem1.Id,group_mem1);
        //newMap.put(group_mem2.Id,group_mem2);
        
        PMP_PAG_mem_handler.onGroupMemAfterInsert(newList, newMap);
        List<PMP_Company__c> compList = [SELECT id from PMP_Company__c WHERE PMP_Account_Id__c=: intel_acc_list[0].Id];
        system.assert(compList.size() > 0);
    }
    
    @isTest static void onGroupMemAfterUpdate_Test(){
        List<Account> partner_acc_list= [Select Id, Name,Core_IPA_Partner_Role__c,Core_IPA_Partner_Speciality__c, Core_User_Defined_Website__c,recordTypeId,Website from Account where RecordTypeId =: PMP_SearchTestDataFactory.Partner_Account_Record_Type];
        List<Account> intel_acc_list = [Select Id, Name,Core_IPA_Partner_Role__c,Core_IPA_Partner_Speciality__c, Core_User_Defined_Website__c,recordTypeId,Website from Account where RecordTypeId =: PMP_SearchTestDataFactory.intel_Account_Record_Type];
        intel_acc_list[0].Core_IPA_Partner_Role__c='FPGA Designer';
        update intel_acc_list[0];  
        partner_acc_list[0].Core_IPA_Partner_Role__c='FPGA Designer';
        update partner_acc_list[0];  
        Core_Account_Group_Member__c group_mem1 = PMP_SearchTestDataFactory.createPAGMember(partner_acc_list[0].Id, intel_acc_list[0].Id, false, false, true);
        //Core_Account_Group_Member__c group_mem2 = PMP_SearchTestDataFactory.createPAGMember(partner_acc_list[1].Id, intel_acc_list[1].Id, false, false, true);
        List<PMP_Company__c> comp_lst = [Select Id, Name, PMP_Account_Id__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Published_Ind__c from PMP_Company__c Where PMP_Account_Id__c IN: intel_acc_list];
        
        
        Map<Id,Core_Account_Group_Member__c> oldMap = new Map<Id,Core_Account_Group_Member__c>();
        oldMap.put(group_mem1.Id,group_mem1);
        //oldMap.put(group_mem2.Id,group_mem2);
        
        Core_Account_Group_Member__c grp1 = group_mem1;
        //Core_Account_Group_Member__c grp2 = group_mem2;
        Map<Id,Core_Account_Group_Member__c> newMap = new Map<Id,Core_Account_Group_Member__c>();
        grp1.Core_MDA_Ind__c = true;
        update grp1;
        //grp2.Core_MDA_Ind__c = true;
        //update grp2;
        grp1 = [SELECT Id, Core_MDA_Ind__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.Website, Core_Intel_Account_Id__r.recordTypeId FROM Core_Account_Group_Member__c WHERE Id=:grp1.Id LIMIT 1];
        //grp2 = [SELECT Id, Core_MDA_Ind__c, Core_Intel_Account_Id__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__r.Name, Core_Intel_Account_Id__r.Website, Core_Intel_Account_Id__r.recordTypeId FROM Core_Account_Group_Member__c WHERE Id=:grp2.Id LIMIT 1];
        newMap.put(grp1.Id,grp1);
        //newMap.put(grp2.Id,grp2);
        List<Core_Account_Group_Member__c> newList = new List<Core_Account_Group_Member__c>();
        newList.add(grp1);
        //newList.add(grp2);
        
        PMP_PAG_mem_handler.onGroupMemAfterUpdate(newList, oldMap, newMap);
        List<PMP_Company__c> compList = [SELECT id from PMP_Company__c WHERE PMP_Account_Id__c=: intel_acc_list[0].Id];
        system.assert(compList.size() > 0);
    }
}