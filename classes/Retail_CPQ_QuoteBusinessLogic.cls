public class Retail_CPQ_QuoteBusinessLogic {
    
    
    public static void beforeInsertUpdateOperations(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap,Boolean isInsert){
        System.debug('Retail before');
        Id saveRecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c','Retail_Quote_Save');
        
        if(quoteList != null && !quoteList.isEmpty()){
            
            
            
            if(isInsert){
                
                System.debug('assign record Type');
                for(SBQQ__Quote__c quote : quoteList){
                    quote.RecordTypeId=saveRecordTypeId; 
                    system.debug('assignrd a save record type');
                }
                updateQuotefields(quoteList);
                
            }
            if(!isInsert){
                updateQuotefields(quoteList);
            }
        }
    }
    
    public static void afterInsertUpdateOperations(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap,Boolean isInsert){
        System.debug('Retail after');
    }
    
    
    public static void updateQuotefields(List<SBQQ__Quote__c> quoteList)   {
        Set<id> accIdSet = new Set<id>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Map<Id,Core_MDF_Bank__c> accBankMap = new Map<Id,Core_MDF_Bank__c>();
        
        for(SBQQ__Quote__c quote : quoteList){
            if(quote.core_cpq_Account__c != null){
                accIdSet.add(quote.core_cpq_Account__c);
            }
        }
        
        if(!accIdSet.isEmpty()){ 
            
            accountMap =  new Map<Id,Account>([select id, name, Core_Geo__c from Account where id IN:accIdSet]);
            for(Core_MDF_Bank__c bankacc : [select id,Core_MDF_Supplier_Number__c, Core_MDF_Account__c, Core_MDF_Account__r.name,Core_MDF_Account__r.RecordType.name, Core_MDF_Account__r.Core_MDF_CoMarketingActive__c from Core_MDF_Bank__c where Core_MDF_Supplier_Number__c != null]){
                accBankMap.put(bankacc.Core_MDF_Account__c,bankacc ) ;  
            }
            
        }
        for(SBQQ__Quote__c quote : quoteList) {
            if(quote.core_cpq_Account__c != null && accountMap.containsKey(quote.core_cpq_Account__c)){
                quote.core_cpq_Geo__c = accountMap.get(quote.core_cpq_Account__c).Core_Geo__c;
            }
            if(quote.core_cpq_Account__c != null && accBankMap.containskey(quote.core_cpq_Account__c)){
                quote.core_cpq_ESD_ID__c = accBankMap.get(quote.core_cpq_Account__c).Core_MDF_Supplier_Number__c ;
            }
            else{
                //quote.addError('The selected account is not valid Account.');
            }
        }
        
    } 
    
}