@isTest
public class Core_IPS_BES_BackendRoutingHandler_Test {
    
     @testSetup static void setupMethod() {
         Core_IPS_Backend_System2__c backendSystem1 = new Core_IPS_Backend_System2__c();
        backendSystem1.Name = 'HSDES-PSG0';

        backendSystem1.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem1;
        
        List<Core_IPS_Backend_Routing__c> backendRoutingRuleList = new List<Core_IPS_Backend_Routing__c>();
        backendRoutingRuleList.add(new Core_IPS_Backend_Routing__c(Core_IPS_Backend_Routing_Order__c = 1, Core_IPS_Queue__c = 'IPS - Unassigned Cases',
                                                                   Core_IPS_Auto_Promote__c = true, Core_IPS_New_Backend_System__c = backendSystem1.Id));
        
        backendRoutingRuleList.add(new Core_IPS_Backend_Routing__c(Core_IPS_Backend_Routing_Order__c = 3, Core_IPS_Queue__c = 'IPS - Unassigned Cases1',
                                                                   Core_IPS_Auto_Promote__c = true, Core_IPS_New_Backend_System__c = backendSystem1.Id));
        
        backendRoutingRuleList.add(new Core_IPS_Backend_Routing__c(Core_IPS_Backend_Routing_Order__c = 2, Core_IPS_Queue__c = 'IPS - Unassigned Cases2',
                                                                   Core_IPS_Auto_Promote__c = true, Core_IPS_New_Backend_System__c = backendSystem1.Id));
        insert backendRoutingRuleList;
         
     }
    public static testMethod void testMethod1(){
         Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';

        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
         System.assert(backendSystem.id != null  );
        
        Core_IPS_Backend_Routing__c backendRoutingRule = new Core_IPS_Backend_Routing__c();
        backendRoutingRule.Core_IPS_Backend_Routing_Order__c = 3;
        backendRoutingRule.Core_IPS_Queue__c = 'IPS - Unassigned Cases3';
        backendRoutingRule.Core_IPS_Auto_Promote__c = true;
        backendRoutingRule.Core_IPS_New_Backend_System__c = backendSystem.Id;
        insert backendRoutingRule;
        
        Core_IPS_Backend_Routing__c backendRoutingRule1 = [SELECT ID, Core_IPS_Backend_Routing_Order__c, Core_IPS_Queue__c FROM Core_IPS_Backend_Routing__c
                                                           WHERE Core_IPS_Queue__c='IPS - Unassigned Cases1'];
       
    }
    
}