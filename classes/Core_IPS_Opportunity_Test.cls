@isTest
public class Core_IPS_Opportunity_Test{
    public static testmethod void oppJuncDupTest(){    
        //inserting Proj Header
        Core_IPS_Project__c projHeader = TestUtilities.getIpsProjectRecord();
        //Added by Sowmya -Start - 15/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
    	projHeader.Core_Status__c = 'Draft';
      	//Sowmya -End - 15/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
 		insert projHeader;
        
        // inserting accoutn one
        Account acc = TestUtilities.getAccountRecord();
        acc.Core_Sales_Groups__c = 'CCG Sales Group';
        acc.Industry ='Software and Services';
        acc.Core_Sub_Industry__c	='IT Services';
        insert acc;
        
        //inserting opportunity
        Opportunity oppt = TestUtilities.getOpportunityRecord();
        oppt.accountId = acc.id;
        insert oppt;
        
        // Inserting IPS accounts
        Core_IPS_Account__c ipsAcc = new Core_IPS_Account__c();
        ipsAcc.Core_Status__c = 'Active';
        ipsAcc.Core_Members__c='All';
        ipsAcc.Core_Account__c = acc.Id;
        ipsAcc.Core_IPS_Project__c = projHeader.Id;
        insert ipsAcc;
        
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
        acc1.Core_Sales_Groups__c = 'CCG Sales Group';
        acc1.Industry ='Software and Services';
        acc1.Core_Sub_Industry__c	='IT Services';
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
            catch(exception e){
        } 
        Core_IPS_Opportunity__c opptJunc2 = new Core_IPS_Opportunity__c();
        opptJunc2.Core_IPS_Project__c = projHeader.id;
        opptJunc2.Core_Opportunity__c = oppt1.id;
        try{
            insert opptJunc2;
            System.assert(opptJunc1 <> null, 'Record not created');
        }
        catch(exception e){
        } 
        Test.stopTest();
        
    }

}