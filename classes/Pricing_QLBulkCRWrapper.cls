/**
* @description       : Wrapper class is created to send reponse from 'Pricing_QLBulkCRValidationHelper' to 'Pricing_QLBulkCRValidationBatch' batch class
* @author            : Rahul Maindalkar
* @group             : 
* @last modified on  : 08-25-2022
* @last modified by  : Rahul Maindalkar
**/
public class Pricing_QLBulkCRWrapper {
    public Map<Id,String> mapSuccessError = New Map<Id,String>();
    public List<SBQQ__QuoteLine__c> revisedList=New List<SBQQ__QuoteLine__c>(); 
    public Map<Id, String> QuotelineIdProdMap = New Map<Id, String>();
    public Map<Id, SBQQ__QuoteLine__c> QuotelineResponseMap = New Map<Id, SBQQ__QuoteLine__c>();
        
    public Pricing_QLBulkCRWrapper(Map<Id,String> mapSuccessError,List<SBQQ__QuoteLine__c> revisedList, Map<Id, String> QuotelineIdProdMap, Map<Id, SBQQ__QuoteLine__c> QuotelineResponseMap){
            this.mapSuccessError = mapSuccessError;
            this.revisedList = revisedList;
            this.QuotelineIdProdMap = QuotelineIdProdMap;
            this.QuotelineResponseMap = QuotelineResponseMap;
        } 
}