public class Retail_CPQ_ProductGroupingBusinessLogic {
    public static void beforeInsertUpdateOperations(List<Core_CPQ_Product_Group__c> grpList,Map<id,Core_CPQ_Product_Group__c> oldMap,Boolean isInsert){
        Set<String> exNameSet= new Set<String>();
        for(Core_CPQ_Product_Group__c rec:[SELECT id,name from Core_CPQ_Product_Group__c]){
            exNameSet.add(rec.Name.toUpperCase());
        }
        for(Core_CPQ_Product_Group__c rec:grpList){
           if(exNameSet.contains(rec.Name.toUpperCase())){
               rec.addError('Duplicate Group Name not allowed');
           }
        }
    }
}