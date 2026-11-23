@isTest(SeeAllData=false)
public class PMP_CheckForTranslations_Test {
    
    static testMethod  void checkForTranlations() {
        List<Id> offeringList = new List<Id>();
        
        PMP_Partner_Offering__c offeringRecTest = new PMP_Partner_Offering__c();
        offeringRecTest.Name = 'Test';
        offeringRecTest.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test';
        offeringRecTest.PMP_Partner_Offering_Dsc__c  = 'Test Desc';
        insert offeringRecTest;
        
        offeringList.add(offeringRecTest.ID);
        Test.startTest();
        PMP_CheckForTranslations translations = new PMP_CheckForTranslations(offeringList);
        Database.executeBatch(translations);
        Test.stopTest();
    }
}