/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_opptyTeamAccessHandler
Version     : 1.0 
Created Date: 19th-June-2017
Function    : Utility methods to handle Opportunity Team Access Trigger functions
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash             19th-June-2017             Original Version
*****************************************************************************************************************************************************************************************************/
public class Core_opptyTeamAccessHandler{

    public static void createOpptyTeamMember(List<Core_Oppty_Team_Access__c> newListOTA, Map<Id, Core_Oppty_Team_Access__c> oldMapOTA, Map<Id,Core_Oppty_Team_Access__c> newMapOTA){
        Set<Id> opptyIdSet = new Set<Id>();
        Map<Id, OpportunityTeamMember> opptyTeamMemberMap = new Map<Id, OpportunityTeamMember>();
        List<OpportunityTeamMember> newListofTeamMember = new List<OpportunityTeamMember>();
    
        for(Core_Oppty_Team_Access__c otm : newListOTA){
            opptyIdSet.add(otm.Opportunity_Name__c);
        }
        
        for(OpportunityTeamMember optm : [SELECT Name,OpportunityAccessLevel,OpportunityId,UserId FROM OpportunityTeamMember WHERE OpportunityId IN :opptyIdSet]){
            opptyTeamMemberMap.put(optm.OpportunityId, optm);
        }
        
        for(Core_Oppty_Team_Access__c otm : newListOTA){
            if(oldMapOTA.get(otm.Id).Approval_Status__c != newMapOTA.get(otm.Id).Approval_Status__c && newMapOTA.get(otm.Id).Approval_Status__c == 'Approved'){
                if(opptyTeamMemberMap.get(otm.Opportunity_Name__c) != null){
                    newListofTeamMember.add(new OpportunityTeamMember(OpportunityAccessLevel = otm.Opportunity_Access__c, OpportunityId = otm.Opportunity_Name__c, UserId = otm.OwnerId, TeamMemberRole = otm.Opportunity_Team_Role__c));
                }
            }
        }
        System.debug('******List of Team Members - '+newListofTeamMember);
        if(!newListofTeamMember.isEmpty()){
            insert newListofTeamMember;
        }
    }

}