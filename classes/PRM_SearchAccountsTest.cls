/**************************************************************************************************************
Apex Class Name:  PRM_SearchAccountsTest
Version     : 1.0 
Created Date: 28 Jan 2020
Function    : Test class for PRM_SearchAccounts
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Prasant Sahu         02/06/2020        Initial version
***************************************************************************************************************/


@isTest
public class PRM_SearchAccountsTest {

    @isTest
    public static void testAccountSortBasedOnScore(){
        id accRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        List<PRM_SearchAccounts> listOfAccount = new List<PRM_SearchAccounts>();
        Account acc = new Account();
        acc.name='Test';
        acc.RecordTypeId = accRecordTypeId;
        acc.Core_CIM_ID__c = '22213672';
        acc.BillingCountry='USA';
        acc.BillingStreet='700 Chestnut Ridge Rd New';
        acc.BillingCity='Chestnut Ridge';
        acc.BillingPostalCode='109776435';
        acc.BillingState=null;
        acc.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc.Core_IPA_Partner_Role__c = 'Distributor';
        acc.Core_Account_Type__c = 'Distributor';
        acc.Industry = '';
        insert acc;
        
        Account acc1 = new Account();
        acc1.name='Test123';
        acc1.RecordTypeId = accRecordTypeId;
        acc1.Core_CIM_ID__c = '22213672';
        acc1.BillingCountry='USA';
        acc1.BillingStreet='700 Chestnut Ridge Rd New';
        acc1.BillingCity='Chestnut Ridge';
        acc1.BillingPostalCode='109776435';
        acc1.BillingState=null;
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        acc1.Core_Account_Type__c = 'Distributor';
        acc1.Industry = '';
        insert acc1;
        
        Account acc2 = new Account();
        acc2.name='Test456';
        acc2.RecordTypeId = accRecordTypeId;
        acc2.Core_CIM_ID__c = '22213672';
        acc2.BillingCountry='USA';
        acc2.BillingStreet='700 Chestnut Ridge Rd New';
        acc2.BillingCity='Chestnut Ridge';
        acc2.BillingPostalCode='109776435';
        acc2.BillingState=null;
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c = false;
        acc2.Core_IPA_Partner_Role__c = 'Distributor';
        acc2.Core_Account_Type__c = 'Distributor';
        acc2.Industry = '';
        insert acc2;
        
        RelatedACMRecords relACMRecord1 = new RelatedACMRecords(null,null);
        
        PRM_SearchAccounts prmObj1 = new PRM_SearchAccounts(acc.id,'22213672',acc,70);
        PRM_SearchAccounts prmObj2 = new PRM_SearchAccounts(acc1.id,'22213672',acc1,80);
        PRM_SearchAccounts prmObj3 = new PRM_SearchAccounts(acc2.id,'22213672',acc2,20);
        prmObj1.relatedACM = relACMRecord1;
        prmObj2.relatedACM = relACMRecord1;
        prmObj3.relatedACM = relACMRecord1;
        listOfAccount.add(prmObj1);
        listOfAccount.add(prmObj2);
        listOfAccount.add(prmObj3);
        
        listOfAccount.sort();
        
        System.assertEquals(listOfAccount[0].AccountId, acc1.Id);
        System.assertEquals(listOfAccount[1].AccountId, acc.Id);
        System.assertEquals(listOfAccount[2].AccountId, acc2.Id);
        
    }
}