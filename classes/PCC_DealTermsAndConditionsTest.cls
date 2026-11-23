/*************************************************************************************************************************************
Apex Class Name     : PCC_DealTermsAndConditionsTest 
Created Date        : April 2024
Function            : Test class for PCC_DealTermsAndConditions
Developer           : Utkarsh
************************************************************************************************************************************************/
@isTest
public class PCC_DealTermsAndConditionsTest {
    static testMethod void testPartnerLegalAgreement(){
        Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        insert LstAcc;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = LstAcc[0].Id;
        c1.Email='test.user@intel.com';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.Email = 'test.diqhwqi@test.com';
        insert c1;
        
        PRM_PartnerAgreement__c partnerAgreement = new PRM_PartnerAgreement__c();
        partnerAgreement.Name = 'Deal_Registration_Terms_and_Conditions';
        partnerAgreement.PRM_Agreement_Cd__c = 'Deal_Terms_Condition';
        insert partnerAgreement;
        
        PRM_AccountLegalAgreemntAssociation__c PartnerLegalAgreement = new PRM_AccountLegalAgreemntAssociation__c();
        PartnerLegalAgreement.PRM_Account_Id__c = LstAcc[0].Id;
        PartnerLegalAgreement.PRM_Contact__c = c1.Id;
        PartnerLegalAgreement.PRM_Partner_Agreement_Id__c = partnerAgreement.Id;
        PartnerLegalAgreement.PRM_Agreement_Sign_Dt__c = Datetime.now();
        insert PartnerLegalAgreement;
        
        Test.startTest();
        PCC_DealTermsAndConditions.CheckPartnerTermsAndCondition();
        System.assertEquals(PartnerLegalAgreement.PRM_Account_Id__c, LstAcc[0].Id);
        Test.stopTest();
     
     }
}