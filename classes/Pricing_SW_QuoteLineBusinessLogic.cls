/****************************************************************************************************
Apex Class Name : Pricing_SW_QuoteLineBusinessLogic 
Version         : 1.0 
Created Date    : 09/17/2024
Function        : Update List unit price of Custom Additional Workload Product when quoteline is cloned
*****************************************************************************************************/
public without sharing class Pricing_SW_QuoteLineBusinessLogic {
    public static void isCloneBeforeInsertUpdateoperation(
           List<SBQQ__QuoteLine__c> quoteLineList,
           Map<Id, SBQQ__QuoteLine__c> oldMap,
           Boolean isInsert
    ){        
           Boolean isUpdate = !isInsert;

           Set<Id> quoteIds = getQuoteIds(quoteLineList);
           Set<Id> opportunityIds = getOpportunityIds(quoteIds);
           Map<Id, Boolean> opportunityLostStatusMap = getOpportunityLostStatusMap(opportunityIds);
           
           if(isInsert){
               for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                   validateQuoteLineRestrictions(quoteLine, null, opportunityLostStatusMap, isInsert);
               }
           }else{
               for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
                   validateQuoteLineRestrictions(quoteLine, oldMap, opportunityLostStatusMap, isUpdate);
               }
           }

           for(SBQQ__QuoteLine__c quoteLine:quoteLineList){  
               if(quoteLine.isclone()){
                   quoteLine.SBQQ__Discount__c = null; 
                   quoteLine.SBQQ__AdditionalDiscountAmount__c = null;
                   quoteLine.SBQQ__PartnerDiscount__c = null; 
                   quoteLine.SBQQ__DistributorDiscount__c = null;
               }
                if(quoteLine.isclone()&& quoteLine.SBQQ__ProductName__c == Label.Pricing_SW_PLI_Support_ProductName){
                   quoteLine.SBQQ__ListPrice__c = 0;
                   quoteLine.SBQQ__Discount__c = null; 
                   quoteLine.SBQQ__AdditionalDiscountAmount__c = null;
                   quoteLine.SBQQ__PartnerDiscount__c = null; 
                   quoteLine.SBQQ__DistributorDiscount__c = null;
                }   
           }
       }

   private static Set<Id> getQuoteIds(List<SBQQ__QuoteLine__c> quoteLineList) {
       Set<Id> quoteIds = new Set<Id>();
       for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
           if (quoteLine.SBQQ__Quote__c!= null) {
               quoteIds.add(quoteLine.SBQQ__Quote__c);
           }
       }
       return quoteIds;
   }

   /************************************************************************************************************
   *Method Name : getOpportunityIds
   *Created Date: 10/10/2024
   *Author: Prasad Kulkarni
   *Description : Get Opportunity Ids from Quote Ids
   ************************************************************************************************************/ 
   private static Set<Id> getOpportunityIds(Set<Id> quoteIds) {
       Set<Id> opportunityIds = new Set<Id>();
       for (Opportunity opp : [SELECT Id FROM Opportunity WHERE Id IN (SELECT SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds)]) {
           opportunityIds.add(opp.Id);
       }
       return opportunityIds;
   }

   /************************************************************************************************************
   *Method Name : getOpportunityLostStatusMap
   *Created Date: 10/10/2024
   *Author: Prasad Kulkarni
   *Description : Get Opportunity Product with Lost status
   ************************************************************************************************************/ 
   public static Map<Id, Boolean> getOpportunityLostStatusMap(Set<Id> opportunityIds) {
       Map<Id, Boolean> opportunityLostStatusMap = new Map<Id, Boolean>();
       
       for (OpportunityLineItem oppLineItem : [SELECT OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :opportunityIds AND Core_Status__c = 'Lost']) {
           opportunityLostStatusMap.put(oppLineItem.OpportunityId, true);
       }
       
       return opportunityLostStatusMap;
   }

   public static void validateQuoteLineRestrictions(
   SBQQ__QuoteLine__c quoteLine,
   Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap,
   Map<Id, Boolean> opportunityLostStatusMap,
   Boolean isInsert
   ) {
       // Retrieve the related Quote record
       SBQQ__Quote__c relatedQuote = [SELECT SBQQ__Primary__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id = :quoteLine.SBQQ__Quote__c LIMIT 1];

       // Check if the related Opportunity has any OpportunityLineItems with Core_Status__c = 'Lost'
       if (opportunityLostStatusMap.containsKey(relatedQuote.SBQQ__Opportunity2__c)) {
           // Restrict actions on quote lines if the parent Quote is Primary
           if (isInsert) {
               if (relatedQuote.SBQQ__Primary__c == true) {
                   quoteLine.addError(Label.Pricing_SW_OppLostQLInsertErrorCheck);//Label.Pricing_SW_OppLostInsertErrorCheck
               }                
           }
           else {
               // Prevent updating any fields on the quote line for Primary Quote
               if (relatedQuote.SBQQ__Primary__c == true) {
                   quoteLine.addError(Label.Pricing_SW_OppLostQLUpdateErrorCheck);
               }
           }
       }
   }   
}