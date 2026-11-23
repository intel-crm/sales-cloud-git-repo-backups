public without sharing class Pricing_QuoteGroupUnlinkControllerDummy {
    public static void getQuoteGroupToDelete(Id grpId){
        Pricing_Quote_Group__c quoteGrp = [SELECT Id, Name FROM Pricing_Quote_Group__c 
                                           WHERE Id =: grpId];
        delete quoteGrp;
    }
}