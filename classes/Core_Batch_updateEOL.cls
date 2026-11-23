/********************************************************************************************************************
Apex Class Name:  Core_Batch_updateEOL
Version     : 1.0 
Created Date: 19 Nov 2021
Function    : Batch class to update eol flag on Opp Product when sales assist updates the products.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Sanket Mahajan            11/29/21                Initial Creation
*********************************************************************************************************************/

global class Core_Batch_updateEOL implements Database.Batchable<sObject>,Database.Stateful {
    List<product2> prdList = new List<product2>();
    Set<String> finalOppLineIds = new Set<String>();
    private Integer retryCount=0;
    global Core_Batch_updateEOL(List<product2> prList){
        prdList = prList;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String query = 'SELECT id,product2Id,product2.Core_SA_Is_EOL__c from Opportunitylineitem where product2id in : prdList and core_status__c in'+Label.Core_SA_Pending_Status+'order by Opportunity.AccountId';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<Opportunitylineitem> scope){
        /*set<id> prIdSet= new Set<id>();
        for(Opportunitylineitem o : scope){
            prIdSet.add(o.Product2Id);
        }*/
        Map<id,List<OpportunityLineItem>> ProdOppLineMap = new Map<id,List<OpportunityLineItem>>();
        //List<OpportunityLineItem> OppItemList  = [select id,product2Id,product2.Core_SA_Is_EOL__c from Opportunitylineitem where product2id in : prIdSet and core_status__c in ('On Hold','Pending')];
        //system.debug('OppLineList->'+OppItemList.size());
        //if(OppItemList.size()>0){
            for(OpportunityLineItem oppLineRec : scope) {
                if(ProdOppLineMap.containsKey(oppLineRec.product2Id)) {
                    ProdOppLineMap.get(oppLineRec.product2Id).add(oppLineRec);
                } else {
                    ProdOppLineMap.put(oppLineRec.product2Id,new List<OpportunityLineItem>{oppLineRec});
                }
            }
        //}
        system.debug('ProdOppLineMap->'+ProdOppLineMap);
        
        system.debug('prdList->'+prdList);
        List<Opportunitylineitem> oliList = new List<Opportunitylineitem>();
        for(Product2 p : prdList){
            if(ProdOppLineMap.containskey(p.id)){
                system.debug('!ProdOppLineMap.isEmpty()->'+!ProdOppLineMap.isEmpty());
                system.debug('ProdOppLineMap.get(p.id).size()->'+ProdOppLineMap.get(p.id).size());
                
                if(!ProdOppLineMap.isEmpty() && ProdOppLineMap.get(p.id).size()>0){
                    List<OpportunityLineItem> oList = ProdOppLineMap.get(p.id);
                    system.debug('oList.size()-->'+oList.size());
                    if(oList.size()>0){
                        for(OpportunityLineItem o : oList){
                            system.debug('current opp-'+o.id);
                            o.Core_Is_Product_EOL__c = p.Core_SA_Is_EOL__c;
                            oliList.add(o);
                        }
                        //update oliList;
                    }
                }
            }
        }
        system.debug('oliList-->'+oliList);
        Database.SaveResult[] srList = database.update(oliList,false);
        Integer i=0;
        system.debug('in srList->'+srList);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                system.debug('in fail->'+sr);
                for(Database.Error err : sr.getErrors()) { 
                    System.debug(oliList.get(i).Id + ': ' + err.getMessage());
                    finalOppLineIds.add(oliList.get(i).Id);
                }
            }
        i++;
        }
        
    } 
    global void finish(Database.BatchableContext BC){
        system.debug('finalOppLineIds->'+finalOppLineIds);
        
        //TWC3123-5360---Core_ProductOpportunity_Test class apex cpu time limit exceeded issue fix
        if(finalOppLineIds.size()>0) //while(retryCount < 5)
        {
            while(retryCount < 5) { //if(finalOppLineIds.size()>0){
                system.debug('Line 83'+retryCount);
                Core_Batch_updateEOL_Retry b=new Core_Batch_updateEOL_Retry(finalOppLineIds,prdList,retryCount++);
                database.executebatch(b,integer.valueof(system.label.Core_Batch_updateEOL_Retry_BatchSize));
            }
        }
    }
}