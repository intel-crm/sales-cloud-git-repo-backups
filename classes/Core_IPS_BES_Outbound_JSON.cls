/***************************************************************************************************
Apex Class Name:  Core_IPS_BES_Outbound_JSON 
Version     : 1.0 
Created Date: 14 Aug 2020
Function    : Backend Routing object to provide auto re-sequencing of Order field across all criteria records 
Used In     : Core_IPS_BackendRouting
Test Class  :  
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* Sriranjini                 14/08/2020              Created
****************************************************************************************************/

// pending to check for scenario : PMD/ Only last modified data will get upladed in bulk upload and update scenario
public with sharing class Core_IPS_BES_Outbound_JSON {
    public static List<Core_IPS_Backend_Routing__c> allDataList;
    public static void setOrder(list<Core_IPS_Backend_Routing__c> backEndRoutingObj){
        
        Set<Core_IPS_Backend_Routing__c>updateBackendRoutingSet = new Set<Core_IPS_Backend_Routing__c>();
        List<Core_IPS_Backend_Routing__c>updateBackendRoutingList = new List<Core_IPS_Backend_Routing__c>();
        map<id,integer>backendOrderMap = new Map<id,integer>();
        Set<Integer>orderSet = new Set<Integer>();
        for(Core_IPS_Backend_Routing__c routingObj:backEndRoutingObj){
            orderSet.add(integer.valueOf(routingObj.Core_IPS_Backend_Routing_Order__c));
            backendOrderMap.put(routingObj.id,integer.valueOf(routingObj.Core_IPS_Backend_Routing_Order__c));
        }
        
        //query to check if the value exists
        if(Core_IPS_Backend_Routing__c.SObjectType.getDescribe().isQueryable()){
            List<Core_IPS_Backend_Routing__c>routingDataList = [select id, Core_IPS_Backend_Routing_Order__c from Core_IPS_Backend_Routing__c where Core_IPS_Backend_Routing_Order__c IN : orderSet AND ID NOT IN:backEndRoutingObj order by Core_IPS_Backend_Routing_Order__c ASC ];
            //get all the value greater of highest value
            if(Core_IPS_Backend_Routing__c.SObjectType.getDescribe().isAccessible()){
            	allDataList = [select id, Core_IPS_Backend_Routing_Order__c from Core_IPS_Backend_Routing__c where ID NOT IN:backEndRoutingObj];
            }
            
            if(routingDataList.size()!=0){
                for(Integer test:backendOrderMap.values()){
                    for(Core_IPS_Backend_Routing__c gret:allDataList){
                        if(gret.Core_IPS_Backend_Routing_Order__c >=test){
                            /*US1021248 - 05/26/2021 - Vishal - FLS Check for security vulnerability --*/
                            if (Schema.sObjectType.Core_IPS_Backend_Routing__c.fields.Core_IPS_Backend_Routing_Order__c.isUpdateable()) {
                                gret.Core_IPS_Backend_Routing_Order__c = gret.Core_IPS_Backend_Routing_Order__c +1;  
                            } 
                            updateBackendRoutingSet.add(gret);
                        }
                    }
                }
                try{
                    updateBackendRoutingList.addAll(updateBackendRoutingSet);
                    if(Core_IPS_Backend_Routing__c.SObjectType.getDescribe().isUpdateable()){
                        update updateBackendRoutingList;
                    }
                   
                   
                }catch(exception e){
                   Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, null);
                    
                }
            }
        } 
    }   
                
}