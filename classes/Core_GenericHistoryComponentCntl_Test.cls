/********************************************************************************************************************************************************************
Apex Class Name:  Core_Opp_LastActvityDt_Schedule_Test
Version     : 1.0 
Created Date: 15/04/2020
Function    : Test class for Core_Opp_LastActvityDt_Schedule

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda               04/05/2020               Original Version developed
*******************************************************************************************************************************************************************/
@isTest
public class Core_GenericHistoryComponentCntl_Test {
    
    static testMethod void testMAGQuestionnaire_Controller1() {
        
        
        Account acct = new Account(Name = 'Test Account 03-25-2015', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345', Core_CIM_ID__c = '8675309',Core_Sales_Groups__c='DCG Sales Group');
        insert acct;
        // Set up a test opportunity that we'll use
        Opportunity opp;
        opp = Core_Test_Utility.createOpportunity(1)[0];
        opp.Core_Military_Aerospace_Govmt_End_Use__c='No';
        opp.AccountId=acct.id;
        insert opp;
        Opp.Name='updated name 1';
        update Opp;
        
        Core_MAG_Questionnaire__c MAG= new Core_MAG_Questionnaire__c();
        MAG.Core_Opportunity__c=Opp.id;
        MAG.Core_A1__c='Answer1';
        MAG.Core_A2__c='Answer2';
        MAG.Core_A3__c='Answer3';
        MAG.Core_A4__c='Answer4';
        MAG.Core_Number_of_Questions__c=10;
        Insert MAG;
        MAG.Core_A1__c='Updated Answe';
        MAG.Core_A2__c='Updated Answre';
        MAG.Core_A2__c='';
        MAG.Core_Number_of_Questions__c=5;
        update MAG;
        Core_MAG_Questionnaire__History objectHistory = new Core_MAG_Questionnaire__History(ParentId = MAG.Id, Field = 'Core_Number_of_Questions__c');
        insert objectHistory;
        objectHistory=[ Select Id,Field,CreatedById ,OldValue,NewValue From Core_MAG_Questionnaire__History   
                       Where Field ='Core_Number_of_Questions__c'];
        
        
        Core_GenericHistoryComponentController His= new Core_GenericHistoryComponentController();
        His.recordLimit=20;
        His.myObject=MAG;
        His.getObjectHistory();
        
    }
    
    
    static testMethod void testMAGQuestionnaire_Controller2() {
        
        
        
        Test.startTest();
        Account acct = new Account(Name = 'Test Account 03-25-2015', BillingStreet = '123 Fake St',
                                   BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                   BillingPostalCode = '12345',Core_Sales_Groups__c='DCG Sales Group');
        insert acct;
        Core_GenericHistoryComponentCntl_Test accHistClass = new Core_GenericHistoryComponentCntl_Test();
        List<SObject> cs = Test.loadData(AccountHistory.SObjectType, 'History');
        Test.stopTest();
        
        
        Core_GenericHistoryComponentController His= new Core_GenericHistoryComponentController();
        His.recordLimit=20;
        His.myObject=acct;
        
        His.getObjectHistory();
        
    }
    
        
    @isTest
    static void testLoadHistory(){
        
        List<SObject> cs = Test.loadData(AccountHistory.SObjectType, 'History');
        system.debug('##############History'+cs);
        
    }
    
}