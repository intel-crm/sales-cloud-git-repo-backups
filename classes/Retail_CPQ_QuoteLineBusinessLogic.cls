public class Retail_CPQ_QuoteLineBusinessLogic {
    public static void beforeInsertUpdateOperations(List<SBQQ__QuoteLine__c> quoteLineList,
                                                    Boolean isInsert,Map<id,SBQQ__QuoteLine__c> oldMap){
        if(isInsert){
        }
    }
    public static void afterInsertUpdateOperations(List<SBQQ__QuoteLine__c> quoteLineList,
                                                    Boolean isInsert,Map<Id,SBQQ__QuoteLine__c> oldMap,Map<Id,SBQQ__QuoteLine__c> newMap){
        System.debug('Retail_CPQ_QuoteLineBusinessLogic after');
        Set<id> quoteLineIdSet = new Set<id>();
        List<SBQQ__DiscountSchedule__c> discountScheduleToInsertList = new  List<SBQQ__DiscountSchedule__c>();  
        List<SBQQ__DiscountTier__c> discountTierToInsertList = new  List<SBQQ__DiscountTier__c>();                                                                                            
        if(isInsert){
            for(SBQQ__QuoteLine__c quoteLine : quoteLineList) {
                
                SBQQ__DiscountSchedule__c ds = new SBQQ__DiscountSchedule__c();
                ds.Name=''+'DS-'+quoteLine.Name.split('-')[1];
                ds.SBQQ__UsePriceForAmount__c=true;
                ds.SBQQ__PriceScale__c=2;
                ds.SBQQ__Type__c='Slab';
                ds.SBQQ__OverrideBehavior__c='All';
                ds.SBQQ__DiscountUnit__c='Price';
                ds.SBQQ__Quote__c = quoteLine.SBQQ__Quote__c;
                ds.SBQQ__QuoteLine__c =quoteLine.Id;
                discountScheduleToInsertList.add(ds);
            }
            if(!discountScheduleToInsertList.isEmpty()){
                insert discountScheduleToInsertList;
                for(SBQQ__DiscountSchedule__c ds : discountScheduleToInsertList){
                    SBQQ__DiscountTier__c dt1 = new SBQQ__DiscountTier__c();
                    dt1.Name='Tier1';
                    dt1.SBQQ__LowerBound__c=1;
                    dt1.SBQQ__UpperBound__c=11;
                    dt1.SBQQ__Schedule__c=ds.Id;
                    dt1.SBQQ__Number__c =1;
                    
                   	SBQQ__DiscountTier__c dt2 = new SBQQ__DiscountTier__c();
                    dt2.Name='Tier2';
                    dt2.SBQQ__LowerBound__c=11;
                    dt2.SBQQ__UpperBound__c=20;
                    dt2.SBQQ__Schedule__c=ds.Id;
                    dt2.SBQQ__Number__c =2;
                    discountTierToInsertList.add(dt1);
                    discountTierToInsertList.add(dt2);
                }
                if(!discountTierToInsertList.isEmpty()){
                    insert discountTierToInsertList;
                }
            }
        }
    }
}