@isTest
public class core_BuMappingTable_Test {
static testMethod void BuMappingTableTest(){    
        
           
             List<Core_Trigger_Executions__c> triggerExec14 = new List<Core_Trigger_Executions__c>();
            triggerExec14.add(new Core_Trigger_Executions__c(Name='BuMappingTable',Core_Class_Name__c='core_BuMappingTable',
                                                             Core_Object__c='Core_BU_Mapping_Table__c',Core_Trigger_Events__c='after insert',
                                                             Core_Active__c=true,Core_Description__c = 'This is For Bu Mapping Table'));
            Insert triggerExec14;
            
            List<Core_BU_Mapping_Table__c> oSAList= new List<Core_BU_Mapping_Table__c>();
            Core_BU_Mapping_Table__c oSA= new Core_BU_Mapping_Table__c();
            oSA.Core_BU_Segment__c = 'CGS';
            oSA.Core_BU_Shortname__c ='CGS-comma';
            insert oSA;
            oSAList.add(oSA);
            Test.startTest();
            Core_BUMapping_Handler.createBUOwnerRecord(oSAList);
            Test.stopTest();
        
        
    }
}