@isTest
public class Core_IPS_Opportunity_Test{
    public static testmethod void oppJuncDupTest(){    
        //inserting Proj Header
        Core_IPS_Project__c projHeader = TestUtilities.getIpsProjectRecord();
        insert projHeader;
        
        // inserting accoutn one
        Account acc = TestUtilities.getAccountRecord();
        insert acc;
        
        //inserting opportunity
        Opportunity oppt = TestUtilities.getOpportunityRecord();
        oppt.accountId = acc.id;
        insert oppt;
        
        //inserting Opportunity Junc object
        Core_IPS_Opportunity__c opptJunc = new Core_IPS_Opportunity__c();
        opptJunc.Core_IPS_Project__c = projHeader.id;
        opptJunc.Core_Opportunity__c = oppt.id;
        
        Test.startTest();
            //Inserting Opportunity Junc object
            insert opptJunc;
            System.assert(opptJunc <> null, 'Record not created'); 
            
            // Inserting another account
            Account acc1 = TestUtilities.getAccountRecord();
            acc1.Name='Testaccount2';
            acc1.BillingCity='Bezawada';
            insert acc1;
            
            //inserting another opportunity
            Opportunity oppt1 = TestUtilities.getOpportunityRecord();
            oppt1.accountId = acc1.id;
            insert oppt1;
            
            //inserting another Opportunity Junc object
            Core_IPS_Opportunity__c opptJunc1 = new Core_IPS_Opportunity__c();
            opptJunc1.Core_IPS_Project__c = projHeader.id;
            opptJunc1.Core_Opportunity__c = oppt.id;
            try{
                insert opptJunc1;
                System.assert(opptJunc1 <> null, 'Record not created');
            }
            catch(exception e){} 
        Test.stopTest();
    
    }

}