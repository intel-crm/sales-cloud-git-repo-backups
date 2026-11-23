/********************************************************************************************************************
Apex Class Name:  Core_UpdateEOLOppProd
Version      : 1.0 
Created Date : 11/19/21
Function     : Class to handle new Lead routing logic.
Modification Log :
* Developer                   Date                   Description
* -----------------------------------------------------------------------------------------------------------------
* Sanket Mahajan               11/19/2021            
*******************************************************************************************************************/

public WITHOUT SHARING class Core_UpdateEOLOppProd {
    
    /*
    * Method name  : updateEOLonInsert
    * Description  : reprocess lead sharing on insert of junction object 
    * Return Type  : void
    * Parameter    : List<product2> newList
    */
    /*public static void updateEOL(List<product2> newList){
        system.debug('in updateEOLonInsert');
        callBatch(newList);
    }*/
    
    
    /*
    * Method name  : updateEOLonUpdate
    * Description  : reprocess lead sharing on insert of junction object 
    * Return Type  : void
    * Parameter    : List<product2> newList,Map<Id, product2> prodOldMap
    */
     public static void updateEOLonUpdate(List<product2> newList,Map<Id, product2> prodOldMap) {
        List<product2> prodList = new List<product2>();
        for(product2 p : newList) {
            if(p.Core_SA_Is_EOL__c <> prodOldMap.get(p.Id).Core_SA_Is_EOL__c ) {
                prodList.add(p);
            }
        }
        if(!prodList.isEmpty()) {
            callBatch(prodList);
        }
    }
    public static void callBatch(List<product2> newList) {
        
        database.executeBatch(new Core_Batch_updateEOL(newList),integer.valueof(system.label.Core_Batch_updateEOL_BatchSize));
    }
}