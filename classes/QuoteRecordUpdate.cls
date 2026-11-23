public class QuoteRecordUpdate{
    //Counter to avoid recalling future method.
    public static Integer counter ;
    

    public static void updateContractforAmendmentQuotes(List<SBQQ__Quote__c> quoteList){
        
        
        Set<Id> quoteIds = new Set<Id>();
        //Set<Id> contractIdSet = new Set<Id>();
       Id contractId;
       Id originalQuoteId;
       
        if(counter == null || counter == 0){
            counter=0;
            
            //Iterate over Amended Quote List and get it Id and Master Contract
            for(SBQQ__Quote__c amendedquoteRecord: quoteList){
                quoteIds.add(amendedquoteRecord.id);
                //contractIdSet.add(amendedquoteRecord.SBQQ__MasterContract__c);
                contractId = amendedquoteRecord.SBQQ__MasterContract__c;
           }
           
           for(SBQQ__Quote__c originalQuote : [Select id,SBQQ__MasterContract__r.SBQQ__Quote__c from SBQQ__Quote__c where id IN :  quoteIds] ){
                originalQuoteId = originalQuote.SBQQ__MasterContract__r.SBQQ__Quote__c;
                
            }
           }
            
            if(quoteIds != null && contractId != null ){
                updateQuotesasInactive(quoteIds,contractId,originalQuoteId); 
            }
            if(quoteIds != null){
                deleteAmendedOpportunity(quoteIds);
            }
        }
    
    
    
    public static void updateQuotesAsInactive(Set<Id> quoteIdSet,Id contractId,Id originalQuoteId){
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> updatequoteList = new List<SBQQ__Quote__c>();
        Set<Id> quoteIdsforInactive = new Set<Id>();
        
        quoteList = [Select id,core_cpq_active_cb__c,Name,SBQQ__MasterContract__c,SBQQ__MasterContract__r.SBQQ__Quote__c 
        from SBQQ__Quote__c where SBQQ__MasterContract__c =: contractId and id NOT IN : quoteIdSet];

        if(quoteList != null && !quoteList.isEmpty()){
            for(SBQQ__Quote__c quoteRecord : quoteList){
                quoteIdsforInactive.add(quoteRecord.id);
                quoteIdsforInactive.add(quoteRecord.SBQQ__MasterContract__r.SBQQ__Quote__c);
            }
        }
        else{
            quoteIdsforInactive.add(originalQuoteId);
        }
        
        
        for(Id id : quoteIdsforInactive){
            SBQQ__Quote__c quoteRecord = new SBQQ__Quote__c();
            quoteRecord.id = Id;
            quoteRecord.core_cpq_active_cb__c = false;
            updatequoteList.add(quoteRecord);
        }
        counter++;
        
        if(updatequoteList!=null){
            update updatequoteList;
        }
    }
    
    
    @future
    public static void deleteAmendedOpportunity(Set<Id> quoteIdSet){
        
        Set<Id> masterContractIdSet = new Set<Id>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        //Set<Id> originalQuoteId = new Set<Id>;
        //List<SBQQ__Quote__c> quoteList = [Select id,SBQQ__MasterContract__c from SBQQ__Quote__c where id IN : quoteIdList AND SBQQ__MasterContract__c != null];
        //SBQQ__MasterContract__r.Amendment_Opportunity__c
        for(SBQQ__Quote__c amendedquoteRecord: [Select id,SBQQ__MasterContract__c,
                                                SBQQ__MasterContract__r.Sales_Amended_Quote_Id__c
                                                FROM SBQQ__Quote__c 
                                                WHERE id IN : quoteIdSet 
                                                AND SBQQ__MasterContract__c != null]){
            //masterContractIdSet.add(amendedquoteRecord.SBQQ__MasterContract__c);
            //originalQuoteId.add(amendedquoteRecord.SBQQ__MasterContract__r.Amendment_Opportunity__c);
        //}
        
        /*if(masterContractIdSet != null && !masterContractIdSet.isEmpty()){
            List<Contract> contractList = [Select id, Amendment_Opportunity__c from Contract 
            where id IN : masterContractIdSet AND Amendment_Opportunity__c != null ];
        
            for(Contract contractRecord : contractList){*/
                Opportunity oppRecord = new Opportunity();
                //oppRecord.id = contractRecord.Amendment_Opportunity__c;
                oppRecord.id = amendedquoteRecord.SBQQ__MasterContract__r.Sales_Amended_Quote_Id__c;
                opportunityList.add(oppRecord);
            //}
        }
       // }
        if(opportunityList != null){
            delete opportunityList;
        }
    }
}