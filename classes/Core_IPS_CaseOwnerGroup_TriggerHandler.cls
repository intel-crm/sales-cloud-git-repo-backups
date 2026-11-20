public without sharing class Core_IPS_CaseOwnerGroup_TriggerHandler {
    public static void assignUserValues(list<Core_IPS_Case_Owner_Group__c>ownerListValues){
        
        list<id>userIDlist = new list<id>();
        for(Core_IPS_Case_Owner_Group__c cc:ownerListValues){
            userIDlist.add(cc.Core_IPS_Case_Owner__c);
        }
        //get user records
        map<id,user> userMap = new map<id,user>([select id, ManagerId,Manager.Name, Email, Manager.Manager.Name from user where id in:userIDlist]);
       
        for(Core_IPS_Case_Owner_Group__c cc:ownerListValues){
            if(cc.Core_IPS_Case_Owner__c!=null){
                if(userMap.containsKey(cc.Core_IPS_Case_Owner__c)){
                     if(cc.Core_IPS_Case_Owner__c == userMap.get(cc.Core_IPS_Case_Owner__c).id){
                        cc.Core_IPS_Case_Owner_Email__c = userMap.get(cc.Core_IPS_Case_Owner__c).Email;
                        if(String.isBlank(cc.Core_IPS_Owner_Team_1__c)){
                            cc.Core_IPS_Owner_Team_1__c = userMap.get(cc.Core_IPS_Case_Owner__c).Manager.Name;
                        }
                        if(String.isBlank(cc.Core_IPS_Owner_Team_2__c)){
                            cc.Core_IPS_Owner_Team_2__c = userMap.get(cc.Core_IPS_Case_Owner__c).Manager.Manager.Name;
                        }
                        //else{cc.Core_IPS_Owner_Team_2__c ='';}
                    }
                }
            }
            
        }
        
        
    }
    
    /****************************************************************************************************************************************
* Method Name  : updateCOGRecords
* Version     : 1.0 
* Created Date: 11 Feb,2020
* Input Parameters: Case Owner Group Old Map, Case Owner Group New Map
* Output Parameters: None
* Transactions: Before Update
* Description: This method will execute whenever a COG record is to be updated 
apart from the default values assigned during insertion
* Used in     : Core_IPS_CaseOwnerGroup_Dispatcher
* Number of Queries Within this Method: 0
* Number of Queries in Loop: 0
* Number of Queries from Called methods:0
* Number of times called: Once for trigger execution  
* Modification Log :
* Developer                 Date                    Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
*Aparna                   11 Feb,2020               Created for US578599
****************************************************************************************************************************************/
    
    public static void updateCOGRecords(Map<Id,Core_IPS_Case_Owner_Group__c> oldMap, Map<Id,Core_IPS_Case_Owner_Group__c> newMap){
        
        if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateCOGRecords'))
            return;
        
        try{
            
            if(newMap!=null){
                
                for(Core_IPS_Case_Owner_Group__c cc :newMap.values()){
                    if(trigger.isUpdate && oldMap.get(cc.Id).Core_IPS_Case_Owner_Email__c != null && oldMap.get(cc.Id).Core_IPS_Case_Owner_Email__c != newMap.get(cc.Id).Core_IPS_Case_Owner_Email__c){
                        cc.Core_IPS_Case_Owner_Email__c = newMap.get(cc.Id).Core_IPS_Case_Owner_Email__c;
                        
                    }
                    if(trigger.isUpdate && oldMap.get(cc.Id).Core_IPS_Owner_Group_1__c != null && oldMap.get(cc.Id).Core_IPS_Owner_Group_1__c != newMap.get(cc.Id).Core_IPS_Owner_Group_1__c){
                        cc.Core_IPS_Owner_Group_1__c = newMap.get(cc.Id).Core_IPS_Owner_Group_1__c;
                    }
                    if(trigger.isUpdate && oldMap.get(cc.Id).Core_IPS_Owner_Group_2__c != null && oldMap.get(cc.Id).Core_IPS_Owner_Group_2__c != newMap.get(cc.Id).Core_IPS_Owner_Group_2__c){
                        cc.Core_IPS_Owner_Group_2__c = newMap.get(cc.Id).Core_IPS_Owner_Group_2__c;
                    }
                    if(trigger.isUpdate && oldMap.get(cc.Id).Core_IPS_Owner_Group_3__c != null && oldMap.get(cc.Id).Core_IPS_Owner_Group_3__c != newMap.get(cc.Id).Core_IPS_Owner_Group_3__c){
                        cc.Core_IPS_Owner_Group_3__c = newMap.get(cc.Id).Core_IPS_Owner_Group_3__c;
                    }
                    if(trigger.isUpdate && oldMap.get(cc.Id).Core_IPS_Owner_Team_1__c != null && oldMap.get(cc.Id).Core_IPS_Owner_Team_1__c != newMap.get(cc.Id).Core_IPS_Owner_Team_1__c){
                        cc.Core_IPS_Owner_Team_1__c = newMap.get(cc.Id).Core_IPS_Owner_Team_1__c;
                    }
                    if( oldMap.get(cc.Id).Core_IPS_Owner_Team_2__c != null && oldMap.get(cc.Id).Core_IPS_Owner_Team_2__c != newMap.get(cc.Id).Core_IPS_Owner_Team_2__c){
                        cc.Core_IPS_Owner_Team_2__c = newMap.get(cc.Id).Core_IPS_Owner_Team_2__c;
                    }
                    if(trigger.isUpdate && oldMap.get(cc.Id).Core_IPS_Owner_Team_3__c != null && oldMap.get(cc.Id).Core_IPS_Owner_Team_3__c != newMap.get(cc.Id).Core_IPS_Owner_Team_3__c){
                        cc.Core_IPS_Owner_Team_3__c = newMap.get(cc.Id).Core_IPS_Owner_Team_3__c;
                    }
                }
            } 
        }catch(Exception e){ Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case Owner Group', 'Core_IPS_CaseOwnerGroup_TriggerHandler');}        

    }
    
    //end
    
}