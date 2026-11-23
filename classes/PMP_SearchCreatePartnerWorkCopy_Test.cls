@isTest
public class PMP_SearchCreatePartnerWorkCopy_Test {

    @testSetup
    public static void setup(){
        Account acc = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type , true);
        PMP_Company__c cmp = new PMP_Company__c(Name = 'testCompany');
     //   cmp.PMP_Account_Id__c = acc.Id;
        cmp.PMP_Account_Website__c = 'www.test.com';
        cmp.PMP_Account_Program_Membership__c = 'ISA - GENERAL';
        cmp.PMP_Partner_Program_nm__c = 'ISA';
        cmp.PMP_Account_Specialty__c = 'Enthusiast PC Specialty';        
        insert cmp;
           
    }
    
    @isTest
    public static void testCreatPartnerWorkCopy(){
        List<PMP_Company__c> compList = [SELECT id, Name, /*PMP_Account_Id__c,*/ PMP_Account_Website__c
                                         ,PMP_Account_Program_Membership__c ,PMP_Partner_Program_nm__c
                                         ,PMP_Account_Specialty__c,PMP_One_Partner_ID__c,PMP_Partner_Benefit_Type__c,PMP_IPA_Badge_Tier_Txt__c,PMP_Partner_Segment_Nm__c from PMP_Company__c LIMIT 10];
        
        Test.startTest();
        PMP_SearchCreatePartnerWorkCopy obj = new PMP_SearchCreatePartnerWorkCopy(compList);
        ID jobID = System.enqueueJob(obj);
        system.assert(true,jobID);
        Test.stopTest();
    }
    
}