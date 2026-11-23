trigger ProductGroupingTrigger on Core_CPQ_Product_Group__c (before insert,before update) {
    /*if((Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore){
        Set<String> exNameSet= new Set<String>();
        for(Core_CPQ_Product_Group__c rec:[SELECT id,name from Core_CPQ_Product_Group__c]){
            exNameSet.add(rec.Name.toUpperCase());
        }
        for(Core_CPQ_Product_Group__c rec:Trigger.new){
           if(exNameSet.contains(rec.Name.toUpperCase())){
               rec.Name.addError('Duplicate Group Name not allowed');
           }
        }
    }*/
    new ProductGroupingTriggerHandler().run();
    
}