@isTest
public class Core_ProspectHandlerTest {
    static testMethod void testUtilitymethods() {
        List<Core_Prospect__c> lstPros = new List<Core_Prospect__c>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name=:System.label.Core_IntegrationUser]; 
        
        List<User> lstUser = Core_Test_Utility.Core_User(2);
        lstUser[0].Profileid = p.id;
        insert lstUser;
        
        Core_Trigger_Executions__c sobjPros = new Core_Trigger_Executions__c();
        sobjPros.Name = 'prospectObjectBeforeHandler';
        sobjPros.Core_Object__c= 'Core_Prospect__c';
        sobjPros.Core_Description__c= 'Used for Prospect trigger';
        sobjPros.Core_Class_Name__c= 'Core_Prospect__c';
        sobjPros.Core_Trigger_Events__c = 'before insert,before update';
        sobjPros.Core_Active__c=True;
        insert sobjPros;
        system.assertEquals('prospectObjectBeforeHandler', sobjPros.Name);
        List <Core_Prospect__c> prosList = new List <Core_Prospect__c> ();
        for (integer i = 0; i <100; i++) {
            Core_Prospect__c  prosInstance= new Core_Prospect__c();
            //prosInstance.Core_Country_Pkt__c = 'USA';
            prosInstance.Core_Source_Pkt__c='Sales AI';
            prosInstance.Core_URLElectronicAddressTxt__c='google.com';
            prosList.add(prosInstance);
            
        }
        if(prosList.size() > 0){
            system.runAs(lstUser[0]){
                insert prosList;
            }
        }        
        system.assertEquals(100, prosList.size());
       
        
    }
}