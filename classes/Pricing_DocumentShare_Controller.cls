public without sharing class Pricing_DocumentShare_Controller {

    @AuraEnabled
    public static DocumentShare getDocumentShare(String quoteId){
        List<Pricing_Document__c> doc = [Select Id, Name from Pricing_Document__c where Pricing_Quote_Id__c=:quoteId];
        Integer attachedNo =  Database.countQuery('SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId =\''+doc[0].Id+'\'');
        DocumentShare docShare = new DocumentShare();
        docShare.name = doc[0].Name;
        docShare.noOfAttachment = attachedNo;
        docShare.recordId = doc[0].Id;
        return docShare;
    }

    public class DocumentShare {
        @AuraEnabled public String name {set;get;}
        @AuraEnabled public String recordId {set;get;}
        @AuraEnabled public Integer noOfAttachment {set;get;}     
    }
}