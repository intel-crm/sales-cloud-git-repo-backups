/******************************************************************************************************************************************
Class Name:  Core_Opp_FC_6QPSHandler
Version     : 1.0 
Created Date: 13 OCT 2017
Function    : Trigger handler class for the object Forecast Product Schedule
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash               10/13/2017              Original Version
********************************************************************************************************************************************/
public class Core_Opp_FC_6QPSHandler{
    
    public static boolean recursiveFlag = false;
    public static final Set<String> Core_Status1 = new Set<String>{'Lost','Cancelled','Deleted','On Hold','Production Lost','Production Cancelled'};

    public static void beforeUpdateMethod(List<Core_Opp_FC_Prod_Schedule__c> newFCList, Map<Id, Core_Opp_FC_Prod_Schedule__c> oldFCMap){
        Set<Id> fcLineItemIdSet1 = new Set<Id>();
        for(Core_Opp_FC_Prod_Schedule__c fc : newFCList){
            fcLineItemIdSet1.add(fc.Core_Opp_Line_Item_RecordID__c);
            if(oldFCMap.get(fc.Id).Core_Opp_FC_Quantity__c != fc.Core_Opp_FC_Quantity__c){
                fc.Core_FC_Last_Modified_Date__c = System.Today();
            } 
        }
        Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>([SELECT id, Core_Status__c FROM OpportunityLineItem WHERE Id IN :fcLineItemIdSet1]);
        for(Core_Opp_FC_Prod_Schedule__c fc : newFCList){           
            if(Core_Status1.contains(oliMap.get(fc.Core_Opp_Line_Item_RecordID__c).Core_Status__c)){
                if(fc.Core_Opp_FC_Quantity__c != 0){
                    fc.Core_FC_Last_Modified_Date__c = System.Today();
                    fc.Core_Opp_FC_Quantity__c = 0;
                }
            }
        }
    }
    
    public static void afterUpdateMethod(List<Core_Opp_FC_Prod_Schedule__c> newFCList, Map<Id, Core_Opp_FC_Prod_Schedule__c> oldFCMap){
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> fcIdSet = new Set<Id>();
        Set<Id> fcLineItemIdSet = new Set<Id>();
        boolean isBlankFlag = false;
        
        for(Core_Opp_FC_Prod_Schedule__c fc : newFCList){
            if(fc.Core_Opp_FC_Quantity__c == null || String.valueOf(fc.Core_Opp_FC_Quantity__c) == ''){
                isBlankFlag = true;
                fc.addError('Cannot make quantity blank');              
            }
            if(oldFCMap.get(fc.Id).Core_Opp_FC_Quantity__c != fc.Core_Opp_FC_Quantity__c){
                fcIdSet.add(fc.Id);
                opptyIdSet.add(fc.Core_Opp_FC_Opportunity__c);
                fcLineItemIdSet.add(fc.Core_Opp_Line_Item_RecordID__c);
            }           
        }       
        if(!isBlankFlag){
            List<Core_Opp_FC_Prod_Schedule__c> tempList;
            if(!opptyIdSet.isEmpty() && !fcIdSet.isEmpty()){
                Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> prodSortForecastMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
                for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, lastModifiedDate, createdDate, Core_FC_4Q_Shed_Quantity__c, Core_FC_Last_Modified_Date__c, Core_FC_Vendor__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c IN :opptyIdSet AND Core_Opp_Line_Item_RecordID__c IN :fcLineItemIdSet AND Core_Opp_FC_isdeleted__c = false AND Id != :fcIdSet]){
                    tempList = new List<Core_Opp_FC_Prod_Schedule__c>();
                    if(prodSortForecastMap.get(fc.Core_Opp_FC_Opportunity__c) != null){
                        tempList = prodSortForecastMap.get(fc.Core_Opp_FC_Opportunity__c);
                        tempList.add(fc); 
                        prodSortForecastMap.put(fc.Core_Opp_FC_Opportunity__c, tempList);
                    }else{
                        tempList.add(fc);
                        prodSortForecastMap.put(fc.Core_Opp_FC_Opportunity__c, tempList);
                    }      
                }
                System.debug('***DebugList - '+prodSortForecastMap);
                List<Core_Opp_FC_Prod_Schedule__c> updateList = new List<Core_Opp_FC_Prod_Schedule__c>();
                if(!recursiveFlag){
                    recursiveFlag = true;
                    for(Id opp : opptyIdSet){
                        if(prodSortForecastMap.get(opp) != null){
                            for(Core_Opp_FC_Prod_Schedule__c fc1 : prodSortForecastMap.get(opp)){
                                fc1.Core_FC_Last_Modified_Date__c = System.Today();
                                updateList.add(fc1);
                            }
                        }
                    }                   
                    update updateList;
                }
            }
        }
        
    }
}