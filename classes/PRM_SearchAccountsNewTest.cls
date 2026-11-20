/**************************************************************************************************************
Apex Class Name:  PRM_SearchAccountsNewTest
Version     : 1.0 
Created Date: 28 Jan 2020
Function    : Test class for PRM_SearchAccounts
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Prasant Sahu         02/06/2020        Initial version
***************************************************************************************************************/


@isTest
public class PRM_SearchAccountsNewTest {

    @isTest
    public static void testAccountSortBasedOnScore(){
        id accRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        List<PRM_SearchAccountsNew> listOfAccount = new List<PRM_SearchAccountsNew>();
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
        list<PRM_SearchAccountsNew.PartnerRoleInfo> prlist=new list<PRM_SearchAccountsNew.PartnerRoleInfo>();
        PRM_SearchAccountsNew.PartnerRoleInfo pr=new PRM_SearchAccountsNew.PartnerRoleInfo('Cosp','Member','Approved',System.now());
        prlist.add(pr);
        PRM_SearchAccountsNew.AccountLegalAgreement agre=new PRM_SearchAccountsNew.AccountLegalAgreement(system.NOW());
        list<PRM_SearchAccountsNew.AccountLegalAgreement> agre1=new list<PRM_SearchAccountsNew.AccountLegalAgreement>();
        agre1.add(agre);
        RelatedACMRecords relACMRecord1 = new RelatedACMRecords(null,null);
        
        PRM_SearchAccountsNew prmObj1 = new PRM_SearchAccountsNew(acc.id,'1234','4567',acc,30,'Member',1,3,prlist);
        PRM_SearchAccountsNew prmObj2 = new PRM_SearchAccountsNew(acc1.id,'456','1234',acc1,40,'Member',2,1,prlist);
        PRM_SearchAccountsNew prmObj3 = new PRM_SearchAccountsNew(acc2.id,'789','1122',acc2,20,'Member',3,2,prlist);
        PRM_SearchAccountsNew prmObj4 = new PRM_SearchAccountsNew(acc2.id,'789','1122',acc2,20,'Member',1,2,prlist);
        PRM_SearchAccountsNew prmObj5 = new PRM_SearchAccountsNew(acc2.id,'789','1122',acc2,60,'Member',1,2,prlist);
       // prmObj1.relatedACM = relACMRecord1;
        //prmObj2.relatedACM = relACMRecord1;
        //prmObj3.relatedACM = relACMRecord1;
        listOfAccount.add(prmObj1);
        listOfAccount.add(prmObj2);
        listOfAccount.add(prmObj3);
        listOfAccount.add(prmObj4);
        listOfAccount.add(prmObj5);
        
        listOfAccount.sort();
        
       // System.assertEquals(listOfAccount[0].AccountId, acc1.Id);
        //System.assertEquals(listOfAccount[1].AccountId, acc.Id);
        //System.assertEquals(listOfAccount[2].AccountId, acc2.Id);
        
    }
}