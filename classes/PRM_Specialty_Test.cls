/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Test 
Version             : 1.0
Created Date        : 09 Jan 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      09-Jan-2020                   Added a new method specActiveCheck to restrict Name change and Inative Specialty check

****************************************************************************************************************************/
@isTest
public class PRM_Specialty_Test {

    static Id getPartnerAccountGroupRTId() {
        List<RecordType> rts = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Account' AND Name = 'Partner Account Group'
        ];
        System.assert(!rts.isEmpty(), 'Missing Partner Account Group RecordType in org');
        return rts[0].Id;
    }

    @isTest
    static void testInactiveASAWithNameChangeAndInactiveUpdate() {
        Test.startTest();

        Account acc = new Account(
            Name = 'IPA Account',
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = '123456',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            RecordTypeId = getPartnerAccountGroupRTId()
        );
        insert acc;

        PRM_Specialty__c spec1 = new PRM_Specialty__c(
            Name = 'Test Specialty 1',
            PRM_Description_Txt__c = 'Test Desc 1',
            PRM_Funding_BU_Nm__c = 'Automotive Sales Group',
            PRM_Role_Nm__c = 'Service Provider',
            PRM_Tier_Nm__c = 'Partner',
            PRM_Start_Date_Dt__c = Date.today(),
            PRM_End_Date_Dt__c = Date.today().addDays(10),
            PRM_Access_Level_Nm__c = 'Public',
            PRM_Inactive_Ind__c = false
        );
        insert spec1;

        spec1.PRM_Description_Txt__c ='TEST ';
        update spec1;


        PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c(
            PRM_Account_Id__c = acc.Id,
            PRM_Specialty_Id__c = spec1.Id,
            PRM_InActive_Ind__c = false
        );
        insert asa1;

        Map<Id, PRM_Specialty__c> oldMap = new Map<Id, PRM_Specialty__c>{ spec1.Id => spec1 };

        spec1.Name = 'New Specialty Name';
        spec1.PRM_Inactive_Ind__c = true;

        List<PRM_Specialty__c> updatedList = new List<PRM_Specialty__c>{ spec1 };

        try {
            PRM_Specialty_Utility.inactiveASACheck(updatedList, oldMap);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @isTest
    static void testNoASARecord_NoValidation() {
        PRM_Specialty__c spec = new PRM_Specialty__c(
            Name = 'Standalone Spec',
            PRM_Description_Txt__c = 'Test Desc',
            PRM_Funding_BU_Nm__c = 'GMP Brazil Sales Group',
            PRM_Role_Nm__c = PRM_Specialty__c.PRM_Role_Nm__c.getDescribe().getPicklistValues()[0].getValue(),
            PRM_Tier_Nm__c = 'Partner',
            PRM_Start_Date_Dt__c = Date.today(),
            PRM_End_Date_Dt__c = Date.today().addDays(5),
            PRM_Access_Level_Nm__c = 'Public',
            PRM_Inactive_Ind__c = false
        );
        insert spec;

        Map<Id, PRM_Specialty__c> oldMap = new Map<Id, PRM_Specialty__c>{ spec.Id => spec };

        spec.PRM_Inactive_Ind__c = true;

        List<PRM_Specialty__c> updateList = new List<PRM_Specialty__c>{ spec };

        Test.startTest();
        PRM_Specialty_Utility.inactiveASACheck(updateList, oldMap);
        Test.stopTest();
    }

    @isTest
    static void testEmptyInput() {
        Test.startTest();
        PRM_Specialty_Utility.inactiveASACheck(new List<PRM_Specialty__c>(), new Map<Id, PRM_Specialty__c>());
        Test.stopTest();
    }

    @isTest
    static void testValidationErrors_NameAndInactive() {
        Account acc = new Account(
            Name = 'IPA Account Test',
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = '123456',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)',
            Core_Intel_Partner_Alliance_PartnerGroup__c = true,
            RecordTypeId = getPartnerAccountGroupRTId()
        );
        insert acc;

        PRM_Specialty__c spec = new PRM_Specialty__c(
            Name = 'Original Spec',
            PRM_Description_Txt__c = 'Test Desc',
            PRM_Funding_BU_Nm__c = 'GMP Brazil Sales Group',
            PRM_Role_Nm__c = 'Service Provider',
            PRM_Tier_Nm__c = 'Partner',
            PRM_Start_Date_Dt__c = Date.today(),
            PRM_End_Date_Dt__c = Date.today().addDays(5),
            PRM_Access_Level_Nm__c = 'Public',
            PRM_Inactive_Ind__c = false
        );
        insert spec;

        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c(
            PRM_Account_Id__c = acc.Id,
            PRM_Specialty_Id__c = spec.Id,
            PRM_InActive_Ind__c = false
        );
        insert asa;

        PRM_Specialty__c specOld = spec.clone(false, true, false, false);

        spec.Name = 'Changed Spec Name';
        spec.PRM_Inactive_Ind__c = true;

        List<PRM_Specialty__c> updateList = new List<PRM_Specialty__c>{ spec };
        Map<Id, PRM_Specialty__c> oldMap = new Map<Id, PRM_Specialty__c>{ spec.Id => specOld };

        Test.startTest();
        PRM_Specialty_Utility.inactiveASACheck(updateList, oldMap);
        Test.stopTest();
    }
}