@isTest(SeeAllData=false)
public class PMP_CheckForTranslations_Test {
}
    //IPA2.0 Offering Changes
    /*
    static testMethod  void checkForTranlations() {
        List<Id> offeringList = new List<Id>();
        
        PMP_Partner_Offering__c offeringRecTest = new PMP_Partner_Offering__c();
        offeringRecTest.Name = 'Test';
        offeringRecTest.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test';
        offeringRecTest.PMP_Partner_Offering_Dsc__c  = 'Test Desc';
        insert offeringRecTest;
        
        PMP_Partner_Offering_Translation__c partnerOfferingTranslations = new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslations.Name='name';
        partnerOfferingTranslations.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        partnerOfferingTranslations.PMP_English_Txt__c='english_test';
        partnerOfferingTranslations.PMP_Chinese_Txt__c='chinese_test';
        partnerOfferingTranslations.PMP_Japanese_Txt__c='japanese_test';
        partnerOfferingTranslations.PMP_Partner_Offering_Id__c=offeringRecTest.id;
        insert partnerOfferingTranslations;
        
        offeringList.add(offeringRecTest.ID);
        Test.startTest();
        PMP_CheckForTranslations translations = new PMP_CheckForTranslations(offeringList);
        Database.executeBatch(translations);
        Test.stopTest();
        
        system.assertNotEquals(offeringRecTest.Id,Null);
    }
}
*/