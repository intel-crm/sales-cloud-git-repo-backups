/********************************************************************************************************************
Apex Class Name:  Core_UpdateEOLOppProd3
Version      : 1.0 
Created Date : 11/19/21
Function     : Class to handle new Lead routing logic.
Modification Log :
* Developer                   Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Sanket Mahajan               11/19/2021            
*******************************************************************************************************************/

public class Core_UpdateEOLOppProd3{
    
    /*
    * Method name  : updateEOLonInsert
    * Description  : reprocess lead sharing on insert of junction object 
    * Return Type  : void
    * Parameter    : List<Product3__c> newList
    */
    /*public static void updateEOL(List<Product3__c> newList){
        system.debug('in updateEOLonInsert');
        callBatch(newList);
    }*/
    
    
    /*
    * Method name  : updateEOLonUpdate
    * Description  : reprocess lead sharing on insert of junction object 
    * Return Type  : void
    * Parameter    : List<Product3__c> newList,Map<Id, Product3__c> prodOldMap
    */
     public static void updateEOLonUpdate(List<Product3__c> newList,Map<Id, Product3__c> prodOldMap){
        system.debug('in updateEOLonUpdate');
        List<Product3__c> prodList = new List<Product3__c>();
        for(Product3__c p : newList){
            if(p.Core_SA_Is_EOL__c <> prodOldMap.get(p.Id).Core_SA_Is_EOL__c ){
                prodList.add(p);
            }
        }
        if(prodList.size()>0){
            callBatch(prodList);
        }
    }
    public static void callBatch(List<Product3__c> newList){
        // Commented By Abhigna
       // database.executeBatch(new Core_Batch_updateEOL(newList),integer.valueof(system.label.Core_Batch_updateEOL_BatchSize));
    }
}