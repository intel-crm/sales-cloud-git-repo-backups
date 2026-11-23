@isTest
public class Sales_UpdateRenewalController_Test {
    
    
    static testmethod void test(){
	    Account intelAccount=Sales_TestFactory_Utility.createAccount();
        Sales_License__c ls=new Sales_License__c();
        
        ls.Sales_License_Type__c='Renewal';
        insert ls;
        Sales_License_Order_Product__c sp=new Sales_License_Order_Product__c();
        sp.Sales_License__c=ls.Id;
        insert sp;
		
        test.startTest();
        Sales_UpdateRenewalController.updaterenewal(intelAccount.id);
        test.stopTest();
       
       }
    
    
	   
    
    
}