public class Retail_CPQ_DiscountScheduleEditor {
	 public without sharing class discountTierWrapper{
        @AuraEnabled public List < SBQQ__DiscountTier__c > tierList;
        public discountTierWrapper(List < SBQQ__DiscountTier__c > tierList) {
            this.tierList = tierList;
        }
    }
    @AuraEnabled (cacheable=true)
    public static discountTierWrapper fetchDisconuntTiers(String quoteLineId){
		List<SBQQ__DiscountTier__c> tierList= [SELECT  Name,SBQQ__UpperBound__c,SBQQ__LowerBound__c,core_cpq_Rebate__c,SBQQ__Number__c from SBQQ__DiscountTier__c WHERE SBQQ__Schedule__r.SBQQ__QuoteLine__c=:quoteLineId order by CreatedDate];
		return new discountTierWrapper(tierList);
    }
    @AuraEnabled
    public static discountTierWrapper addNewTier(Id recordId,List < SBQQ__DiscountTier__c > tierLst){
        
        SBQQ__DiscountTier__c newTier = new SBQQ__DiscountTier__c();
        Integer length=tierLst.size();
        System.debug('Length'+length);
        newTier.Name=null;
        newTier.SBQQ__Number__c=length+1;
        newTier.SBQQ__DiscountAmount__c=null;
        newTier.SBQQ__LowerBound__c=null;
        newTier.SBQQ__UpperBound__c=null;
        SBQQ__DiscountSchedule__c tempLine=[SELECT id,name from SBQQ__DiscountSchedule__c WHERE SBQQ__QuoteLine__r.id=:recordId limit 1];
        newTier.SBQQ__Schedule__c=tempLine.Id;
        tierLst.add(newTier);
        return new discountTierWrapper(tierLst);
    }
    @AuraEnabled
    public static void deleteRecord(Id recordId){
        If(recordId!=null){
             DataBase.delete(recordId);
        }
       
    }
    @AuraEnabled
    public static void updateTiers(Id recordId,List<SBQQ__DiscountTier__c> updatedTiers){  
        //try{
        SBQQ.TriggerControl.disable();
            List<SBQQ__DiscountTier__c> listToUpdate = new List<SBQQ__DiscountTier__c>();
            List<Id> tirlst=new List<Id>();
            for(SBQQ__DiscountTier__c tier : updatedTiers){
                if (!('' + tier.Id).contains('row')){
                    tirlst.add(tier.Id);
                }
            }
            Map<id,SBQQ__DiscountTier__c> tierPriceMap=new Map<id,SBQQ__DiscountTier__c>([SELECT id,core_cpq_Rebate__c FROM SBQQ__DiscountTier__c WHERE ID IN :tirlst]);
            //SBQQ__QuoteLine__c tempLine=[SELECT id,name,SBQQ__DiscountSchedule__r.Id from SBQQ__QuoteLine__c WHERE SBQQ__QuoteLine__c.Id =: recordId LIMIT 1];
            SBQQ__DiscountTier__c tempLine=[SELECT id,name,SBQQ__Schedule__r.id,SBQQ__Schedule__r.SBQQ__QuoteLine__r.SBQQ__ListPrice__c from SBQQ__DiscountTier__c  WHERE SBQQ__Schedule__r.SBQQ__QuoteLine__r.ID =: recordId LIMIT 1];
            
            for(SBQQ__DiscountTier__c tier : updatedTiers){
                //Id disTierRecId= Schema.SObjectType.SBQQ__DiscountTier__c.getRecordTypeInfosByDeveloperName().get('p2c_disTierRecType').getRecordTypeId();
                //tier.RecordTypeId = disTierRecId;
                if (('' + tier.Id).contains('row')){
                    tier.Id = null;
                    tier.SBQQ__Schedule__c=tempLine.SBQQ__Schedule__r.ID;
                    //if(tier.p2c_discount_price__c!=null){
                        //tier.SBQQ__DiscountAmount__c=tempLine.SBQQ__Schedule__r.SBQQ__QuoteLine__r.SBQQ__ListPrice__c-tier.core_cpq_Rebate__c;
                    //}
                    
                    listToUpdate.add(tier);
                }
                else{
                  /*  if(tier.core_cpq_Rebate__c==null){
                         tier.SBQQ__DiscountAmount__c=tempLine.SBQQ__Schedule__r.SBQQ__QuoteLine__r.SBQQ__ListPrice__c-tierPriceMap.get(tier.ID).core_cpq_Rebate__c;
                    }*/
                   
                    listToUpdate.add(tier);
                }
            }
            
            
            if(!listToUpdate.isEmpty()){
                 upsert listToUpdate;
            }
        SBQQ.TriggerControl.enable();
         // return 'Success: updated successfully '+'---->>>>'+ listToUpdate;
           
        //}catch(Exception ex){
            //System.debug('ExceptionTier'+ex.getMessage());
            //return 'Failed: updated failed '+'---->>>>'+ ex.getMessage();
            
       // }  
          

    }
    
}