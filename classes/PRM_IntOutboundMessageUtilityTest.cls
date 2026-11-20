/*********************************************************************************************************************
Class Name  : PRM_IntOutboundMessageUtilityTest
Version       : 1.0
Created Date  : 18th May 2020
Function      : Test Class for 'PRM_IntegrationOutboundMessageUtility'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Saba Husain               18/05/2020              PRM_IntOutboundMessageUtilityTest

*********************************************************************************************************************/

@isTest
private class PRM_IntOutboundMessageUtilityTest{
    
   @testSetup
    //test data creation
    static void setupData(){ 
        List<Account> accList = new List<Account>();
        Account a1 = new Account();
        a1.Name = 'Test account 1';
        a1.Core_Account_Type__c ='Distributor';
        a1.Industry='Agriculture';
        a1.Core_IPA_Partner_Role__c = 'Service Provider';
        a1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        a1.BillingCity='Bengaluru';
        a1.BillingCountry='India';
        a1.BillingStreet='4th Floor,ITPL,Brookfield';
        a1.BillingPostalCode='560037';
        accList.add(a1);
        
        Account a2 = new Account();
        a2.Name = 'Test account 2';
        a2.Core_Account_Type__c ='Distributor';
        a2.Industry='Agriculture';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        a2.BillingCity='Mumbai';
        a2.BillingCountry='India';
        a2.BillingStreet='3rd Floor,Block 4';
        a2.BillingPostalCode='654356';
        accList.add(a2);
        
        insert accList;
    }
    
     @isTest static void testMehod1(){
        List<Account> accList = [Select Id from Account limit 2];
         
        PRM_IntegrationOutboundMessageUtility.OPIDRecommendation opid1 = new PRM_IntegrationOutboundMessageUtility.OPIDRecommendation();
        opid1.accountId = accList[0].id;
        opid1.cimId = '123123';
        opid1.groupingMethod = 'test method';
        opid1.groupingValue = 'test value';
        opid1.recommendationId = 'recommendation id';
        
        PRM_IntegrationOutboundMessageUtility.OPIDRecommendation opid2 = new PRM_IntegrationOutboundMessageUtility.OPIDRecommendation();
        opid2.accountId = accList[1].id;
        opid2.cimId = '123123';
        opid2.groupingMethod = 'test method';
        opid2.groupingValue = 'test value';
        opid2.recommendationId = 'recommendation id';
        
        List<PRM_IntegrationOutboundMessageUtility.OPIDRecommendation> opidRecommendationList = new List<PRM_IntegrationOutboundMessageUtility.OPIDRecommendation>();
        opidRecommendationList.add(opid1);
        opidRecommendationList.add(opid2);
        
         List<String> intOutboundMessageList = PRM_IntegrationOutboundMessageUtility.createOPIDRequestMessage(opidRecommendationList);
        
        System.assertEquals(intOutboundMessageList.size(), 4, 'Integration Outbound Message not created appropriately');

     }
     
 }