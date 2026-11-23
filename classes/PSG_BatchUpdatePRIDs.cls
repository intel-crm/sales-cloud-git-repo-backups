/****************************************************************************************************
Apex Class Name : PSG_BatchUpdatePRIDs
Version         : 1.0 
Created Date    : 7/4/2021
Function        : This class is used as a part of Updating PRIDS POS through Batch process
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Lata                        7/4/2021                Created
*****************************************************************************************************/
global class PSG_BatchUpdatePRIDs  implements Database.Batchable<Sobject>, Database.Stateful,Schedulable{
    public List<SObject> start(Database.BatchableContext bc) {
        //DateTime twentyFourHoursAgo = System.now().addHours(-24);

        return database.query('select Id,Name,Price_PRID__c,core_cpq_pos_quantity__c,LastModifiedDate from PRID_POS_Stage__c where LastModifiedDate ='+ Label.PSG_PridToPos_Last_N_Days);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> sobjLst) {
        try{
        //List<PRID_POS_Stage__c> pridPosLst=PRIDBusinessLogic.pridPosLogic();
        List<price_prid__c> pridLstToUpdate=new List<price_prid__c>();
        Map<string,Decimal> posPRIDToQuantityMap=new Map<string,Decimal>();
        for(PRID_POS_Stage__c pos : (List<PRID_POS_Stage__c>)sobjLst){
            posPRIDToQuantityMap.put(pos.Price_PRID__c,pos.core_cpq_pos_quantity__c);
           
        }
             for(price_prid__c prid:[select Id, Name, core_cpq_prid_pos__c from price_prid__c where Name in :posPRIDToQuantityMap.keySet()]){
                if(posPRIDToQuantityMap.containsKey(prid.Name)){
                    if(posPRIDToQuantityMap.get(prid.Name)<>prid.core_cpq_prid_pos__c){
                        prid.core_cpq_prid_pos__c=posPRIDToQuantityMap.get(prid.Name);
                        pridLstToUpdate.add(prid);
                    }
                }
            }
        if(pridLstToUpdate !=null && pridLstToUpdate.size()>0){
            update pridLstToUpdate;
        }
      }catch(Exception e){
         PSG_Utility.logError(e);                                             
       }
    }
    
    public void finish(Database.BatchableContext bc) {
        PSG_BatchCreateApprovers createApprover = new PSG_BatchCreateApprovers();
        Database.executeBatch(createApprover);
     
    }
     global void execute(SchedulableContext sc) {
        Database.executeBatch(new PSG_BatchUpdatePRIDs());
    }
}