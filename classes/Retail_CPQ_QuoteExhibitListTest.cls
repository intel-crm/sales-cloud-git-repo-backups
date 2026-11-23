@isTest
public class Retail_CPQ_QuoteExhibitListTest {
   @testSetup
    public static void setUpData(){}
    
    public static testmethod void createQuoteRecords(){
        //SBQQ.TriggerControl.disable();
        Retail_CPQ_QuoteExhibitList.fetchRecordTypeValues('SBQQ__QuoteLine__c');
    }
}