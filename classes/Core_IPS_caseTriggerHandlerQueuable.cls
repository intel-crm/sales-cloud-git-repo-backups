/***************************************************************************************************
    Version     : 1.0 
    Created Date: 11 Dec 2018
    Class Name : Case Trigger handler- > Provide case access and Trigger assignment rule.
    Description: 
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Ajay                    11/12/2018              Created
****************************************************************************************************/  
public class Core_IPS_caseTriggerHandlerQueuable implements Queueable {
    List<Case> oldList;
    List<Case> newList;
    Map<Id,Case> oldMap;
    Map<Id,Case> newMap;
    public  Boolean  isLoggeInUserMigrationUser = Core_IPS_CaseTriggerHandler.isMigrationUser(string.valueof(userinfo.getuserId()));
     //triggerAssignmentRule
     public Core_IPS_caseTriggerHandlerQueuable( List<Case> newList, Map<Id,Case> oldMap) {
           this.newList= newList;
           this.oldMap= oldMap;          
     }
     
     public void execute(QueueableContext qc) { 
           if(!isLoggeInUserMigrationUser){               
               System.debug('@@@@'+this.newList.size()+'#############'+this.oldMap);
               Core_IPS_CaseTriggerHandler.executeCaseAssignmentRule(this.oldMap,this.newList); 
           }
           Core_IPS_CaseTriggerHandler.provideCaseAccessToCreatedFAE(this.newList);
        
    }
            
}