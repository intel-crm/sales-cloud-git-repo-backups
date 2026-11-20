@isTest
public class Core_IPS_OppParNote_Test {
	@testSetup
    static void setup() {
        Core_IPS_Project__c projectRec1 = new Core_IPS_Project__c();
        projectRec1.Core_Status__c = 'Draft';
        insert projectRec1;
        Core_IPS_Project__c projectRec2 = new Core_IPS_Project__c();
        projectRec2.Core_Status__c = 'Draft';
        insert projectRec2;
        projectRec2.Core_Status__c = 'inactive';
        update projectRec2;
        Core_IPS_Opportunity_PAR__c parRec1 = new Core_IPS_Opportunity_PAR__c();
        insert parRec1;
        Core_IPS_Opportunity_PAR__c parRec2 = new Core_IPS_Opportunity_PAR__c();
        parRec2.Core_IPS_Premier_Support_Project__c = projectRec1.Id;
        insert parRec2;
        Core_IPS_Opportunity_PAR__c parRec3 = new Core_IPS_Opportunity_PAR__c();
        parRec3.Core_IPS_Premier_Support_Project__c = projectRec2.Id;
        insert parRec3;
    }
    @isTest
    static void testWithNoProject() {
        Core_IPS_Opportunity_PAR__c parRec = [SELECT Id,Core_IPS_Premier_Support_Project__c FROM Core_IPS_Opportunity_PAR__c WHERE Core_IPS_Premier_Support_Project__c = null];
        PageReference pageRef = Page.OpportunityPARNote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(parRec.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(parRec);
        Core_IPS_OppParNote noteObj = new Core_IPS_OppParNote(sc);
        System.assertEquals(true, noteObj.show);
    }
    @isTest
    static void testWithDraftProject() {
        Core_IPS_Opportunity_PAR__c parRec = [SELECT Id, Core_IPS_Premier_Support_Project__c FROM Core_IPS_Opportunity_PAR__c WHERE Core_IPS_Premier_Support_Project__c != null AND Core_IPS_Premier_Support_Project__r.Core_Status__c = 'Draft'];
        PageReference pageRef = Page.OpportunityPARNote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(parRec.Id));
        ApexPages.StandardController sc = new ApexPages.standardController(parRec);
        Core_IPS_OppParNote noteObj = new Core_IPS_OppParNote(sc);
        System.assertEquals(true, noteObj.show);
    }
    @isTest
    static void testWithNonDraftProject() {
        Core_IPS_Opportunity_PAR__c parRec = [SELECT Id, Core_IPS_Premier_Support_Project__c FROM Core_IPS_Opportunity_PAR__c WHERE Core_IPS_Premier_Support_Project__c != null AND Core_IPS_Premier_Support_Project__r.Core_Status__c != 'Draft'];
        PageReference pageRef = Page.OpportunityPARNote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(parRec.Id));
        ApexPages.StandardController sc = new ApexPages.standardController(parRec);
        Core_IPS_OppParNote noteObj = new Core_IPS_OppParNote(sc);
        System.assertEquals(false, noteObj.show);
    }
}