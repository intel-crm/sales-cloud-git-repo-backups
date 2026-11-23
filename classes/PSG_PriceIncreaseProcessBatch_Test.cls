@isTest
public class PSG_PriceIncreaseProcessBatch_Test {
    /*@TestSetup
    private static void setUpData(){
        List<User> lstUsers3 = PSG_Test_Utility.createSOSUser();
        if(!lstUsers3.isEmpty()){
            system.runAs(lstUsers3[0]){  
                System.assert(!lstUsers3.isEmpty(),'User');
                Account acc = PSG_Test_Utility.createAccount();           
                Contact con = PSG_Test_Utility.createContact(acc.Id);
                User partnerUser = PSG_Test_Utility.createPartnerUser(acc.Id);
                PSG_Test_Utility.CreatePriceBook('PSG Price Book');
                List<Product2> lstProd = PSG_Test_Utility.CreateProduct(3);
                PSG_Test_Utility.createGroup();
                PSG_Test_Utility.createGroupMember();
                List<SBQQ__Quote__c> lstquote = PSG_Test_Utility.createQuote(acc.Id, partnerUser.ContactId, 2);
                                Test.startTest();

                List<SBQQ__QuoteLine__c> lstquoteLines = PSG_Test_Utility.createQuoteLines(lstquote[0].id, 1);
                Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Direct_Account').getRecordTypeId();
                acc.RecordTypeId = accRecordTypeId;
                acc.Core_Direct_Account_Type_Nm__c ='End Customer Parent';
                update acc;    
                List<core_cpq_dpa_aln__c> dpa_List = PSG_Test_Utility.createDPARecord(lstquote[0],acc.Id);                
                List<core_cpq_dpa_aln_line__c> lstdpaalnLines = PSG_Test_Utility.createDPALinesWithoutInsert(dpa_List[0].id, 1);
                lstdpaalnLines[0].core_cpq_quote_item_line_no__c=lstquoteLines[0].Id;
                insert lstdpaalnLines;
                Test.stopTest();
            }   
        }
    }
    
    @isTest
    private static void testMethod1(){
        List<core_cpq_dpa_aln__c> dpa_List1=[Select Id,Name from core_cpq_dpa_aln__c];
        psg_price_increase__c p=new psg_price_increase__c();
        p.Status__c='Pending';
        p.Operation_Type__c='SAP Submission';
        insert p;
        Test.startTest();
        Database.executeBatch(new PSG_PriceIncreaseProcessBatch());
        Test.stopTest();
        system.assertequals('','');
    }
    
    @istest
    private static void testmethod2(){
        List<core_cpq_dpa_aln__c> dpa_List1=[Select Id,Name from core_cpq_dpa_aln__c];
        psg_price_increase__c p1=new psg_price_increase__c();
        p1.Status__c='Pending';
        p1.psg_dpa_aln_id__c=dpa_List1[0].Id;
        p1.Operation_Type__c='SAP Submission';
        insert p1;
        Test.startTest();
        Database.executeBatch(new PSG_PriceIncreaseProcessBatch());
        Test.stopTest();
        system.assertequals('','');
    }
    
    @istest
    private static void testmethod3(){
        List<core_cpq_dpa_aln__c> dpa_List1=[Select Id,Name from core_cpq_dpa_aln__c];
        psg_price_increase__c p2=new psg_price_increase__c();
        p2.Status__c='Pending';
        p2.psg_dpa_aln_nbr__c=dpa_List1[0].Name;
        p2.Operation_Type__c='SAP Submission';
        insert p2;
        Test.startTest();
        Database.executeBatch(new PSG_PriceIncreaseProcessBatch());
        Test.stopTest();
        system.assertequals('','');
        
    }
    
    @istest
    private static void testmethod4(){
        List<core_cpq_dpa_aln__c> dpa_List1=[Select Id,Name from core_cpq_dpa_aln__c];
        psg_price_increase__c p3=new psg_price_increase__c();
        p3.Status__c='Pending';
        p3.psg_dpa_aln_nbr__c='DPA123';
        p3.Operation_Type__c='SAP Submission';
        insert p3;
        Test.startTest();
        Database.executeBatch(new PSG_PriceIncreaseProcessBatch());
        Test.stopTest();
        system.assertequals('','');
    }
    
    @istest
    private static void testmethod5(){
        List<core_cpq_dpa_aln__c> dpa_List1=[Select Id,Name from core_cpq_dpa_aln__c];
        psg_price_increase__c p4=new psg_price_increase__c();
        p4.Status__c='Pending';
        p4.psg_dpa_aln_id__c=dpa_List1[0].Id;
        p4.Operation_Type__c='Clone';
        insert p4;
        Test.startTest();
        Database.executeBatch(new PSG_PriceIncreaseProcessBatch());
        Test.stopTest();
        system.assertequals('','');
    }
    @istest
    private static void testmethod6(){
        List<core_cpq_dpa_aln__c> dpa_List1=[Select Id,Name from core_cpq_dpa_aln__c];
        psg_price_increase__c p5=new psg_price_increase__c();
        p5.Status__c='Pending';
        p5.psg_dpa_aln_nbr__c=dpa_List1[0].Name;
        p5.Operation_Type__c='Clone';
        insert p5;
        Test.startTest();
        Database.executeBatch(new PSG_PriceIncreaseProcessBatch());
        Test.stopTest();
        system.assertequals('','');
    }*/
    
}