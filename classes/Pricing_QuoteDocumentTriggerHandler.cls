public without sharing class Pricing_QuoteDocumentTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> quoteLineIds = new Set<Id>();
        Set<Id> fiquoteLineIds = new Set<Id>();
        for(SBQQ__QuoteDocument__c qDoc : (List<SBQQ__QuoteDocument__c>) trigger.new){
            quoteIds.add(qDoc.SBQQ__Quote__c);
        }
        Map<Id,SBQQ__QuoteLine__c> quotesLinesMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT id,Pricing_Quote_Program_Nm__c FROM SBQQ__QuoteLine__c 
                                                                                    WHERE Pricing_Ready_for_QuoteLetter_cb__c = TRUE AND 
                                                                                    SBQQ__Quote__r.Pricing_Auto_generate_Quote_Letter__c=TRUE 
                                                                                    AND SBQQ__Quote__c IN :quoteIds]);
        for(SBQQ__QuoteLine__c quoteLine :quotesLinesMap.values()){  
            if(quoteLine.Pricing_Quote_Program_Nm__c == Label.Pricing_Tender_Quote_Program){
                quoteLineIds.add(quoteLine.id); 
            }else{
                fiquoteLineIds.add(quoteLine.id);
            }
            
        }
        
        //Tender QuoteLetter
        if(quoteLineIds.size() > 0){
            Pricing_EmailUtility.sendEmail(quoteLineIds, Label.Pricing_QuoteLetter_Template_Name);
        }
        //FI QuoteLetter
        if(fiquoteLineIds.size() > 0){
            Pricing_EmailUtility.sendEmail(fiquoteLineIds, Label.Pricing_FI_QuoteLetter_Template_Name);
        }
    }
    
    
}