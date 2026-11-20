@isTest
private class QuoteExtControllerTests { 
    
    testMethod static void testSubmit() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
    	List<User> lstUser = PSG_Test_Utility.createBMUser();
        system.runAs(lstUser[0]){
            Test.startTest();
            QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
            con.onSubmit();
            quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
            Test.stopTest();
            con.goToRecord();        
        	System.assertEquals('Approved', quote.ApprovalStatus__c);
        }
    }
    
    testMethod static void testRecall() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        List<User> lstUser = PSG_Test_Utility.createBMUser();
        System.runAs(lstUser[0]){
            Test.startTest();
            QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
            con.onRecall();
            quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
            Test.stopTest();
            System.assertEquals('Recalled', quote.ApprovalStatus__c);
        }
    }
}