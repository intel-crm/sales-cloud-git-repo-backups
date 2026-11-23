/***************************************************************************************************
* Apex Class Name: Core_IPS_Entitlement_For_Migrated_Cases
* Version     : 1.0 
* Created Date: 3/13/2016
* Function    : Core_IPS_Entitlement_For_Migrated_Cases
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Neeti Jain                 9/1/2018               Modified
* Cornelius Nath         21/02/2018             Modified the Batch query and added custom label                                                 
****************************************************************************************************/
global class Core_IPS_Entitlement_For_Migrated_Cases implements Database.Batchable<sObject>{

         // Start Method
        global Database.QueryLocator start(Database.BatchableContext BC){
         /*Modified the Query by Neeti Jain as per US91031*/
         /*Modified the Query by Cornelius Nath as per US96727*/
        /*Added the condition for status check to create milestone for New and Open Cases*/
        string caseMQuery = 'Select id,status,Core_Next_Response_Due_Date__c,BusinessHoursId,AccountId,SlaStartDate,Core_First_Response_Completed__c,SlaExitDate,Core_IPS_Supported_Contact__c,ContactId,EntitlementID, Core_IPS_Legacy_IPS_ID__c,Core_IPS_GEC_Flag__c from Case' +' '+ System.Label.Core_IPS_Case_Milestone_Batch;
      return Database.getQueryLocator(caseMQuery);
     
        }
      
      // Execute Logic
       global void execute(Database.BatchableContext BC, List<sObject>scope){
            Core_IPS_CaseTriggerHandler.assignEntitlementToCase(scope);
            for(sobject s : scope){
                Case cs = (case)s;
                if(!cs.Core_First_Response_Completed__c) cs.Core_First_Response_Completed__c=true;
                 cs.Core_Next_Response_Due_Date__c = BusinessHours.add(cs.BusinessHoursId, System.now(), Integer.valueof(System.Label.IPS_Next_Response_Due_Default_in_Minutes) * (60*1000));
             }
             
            update scope;
            system.debug('scope'+scope);
            Map<Id,List<CaseMilestone>> CaseMilestoneByCaseId = milestoneUtils.getActiveMileStone(scope);
            List<CaseMilestone> LstCaseMilestoneToUpdate = new List<CaseMilestone>();
            for(sobject s : scope){
            Case cs = (case)s;
                List<CaseMileStone> milestoneList = CaseMilestoneByCaseId.get(cs.id);
               system.debug('milestoneList'+milestoneList);
                if(milestoneList !=null)
                {
                if(milestoneList.size()>1){             
                }else{
                
                    milestoneList[0].completionDate = system.now() ;
                    LstCaseMilestoneToUpdate.add(milestoneList[0]);
                    //update milestoneList[0];
                }
              }
            }
            if(LstCaseMilestoneToUpdate.size() > 0)
            {
                update LstCaseMilestoneToUpdate;
                
                
            } 
        }
     
       global void finish(Database.BatchableContext BC){
            // Logic to be Executed at finish
       }
    }