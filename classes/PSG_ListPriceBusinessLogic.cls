public class PSG_ListPriceBusinessLogic {
    public static void beforeInsertUpdateOperations(List<core_cpq_list_price__c> listPriceList,Map<Id,core_cpq_list_price__c> oldMap,Boolean isInsert){
        if(isInsert){
           /* for(core_cpq_list_price__c listPrice : listPriceList){
                listPrice.core_cpq_unique_id__c = String.ValueOf(listPrice.core_cpq_lowerbound_qty__c) + String.ValueOf(listPrice.core_cpq_upperbound_qty__c) + String.ValueOf(listPrice.core_cpq_product_name__c) + String.ValueOf(listPrice.Pricebookentry__c); 
            }*/
        }
    }
}