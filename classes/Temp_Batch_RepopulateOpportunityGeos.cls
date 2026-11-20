global class Temp_Batch_RepopulateOpportunityGeos implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Database.QueryLocator openOpportunities;
        
        if (Test.isRunningTest()) {
            openOpportunities = Database.getQueryLocator([
                select Id, StageName, (select Id from OpportunityTeamMembers where (User.Profile.Name = :Label.Core_IT_Intel_Profile_Name) or
                                       (TeamMemberRole = :Label.Core_Opportunity_Team_Role_Viewer) limit 1)
                from Opportunity
                where IsClosed = false and Id in (select OpportunityId from OpportunityTeamMember where (User.Profile.Name = :Label.Core_IT_Intel_Profile_Name) or
                                                  (TeamMemberRole = :Label.Core_Opportunity_Team_Role_Viewer))
                limit 10
            ]);
        }
        else {
            openOpportunities = Database.getQueryLocator([
                select Id, StageName, (select Id from OpportunityTeamMembers where (User.Profile.Name = :Label.Core_IT_Intel_Profile_Name) or
                                       (TeamMemberRole = :Label.Core_Opportunity_Team_Role_Viewer) limit 1)
                from Opportunity
                where IsClosed = false and Id in (select OpportunityId from OpportunityTeamMember where (User.Profile.Name = :Label.Core_IT_Intel_Profile_Name) or
                                                  (TeamMemberRole = :Label.Core_Opportunity_Team_Role_Viewer))
                order by Id
            ]);
        }
        
        return openOpportunities;
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> openOpportunities) {
        
        //System.debug('##### ' + openOpportunities);
        
        Set<Id> teamMemberIds = new Set<Id>();
        
        for (Opportunity opp : openOpportunities) {
            teamMemberIds.add(opp.OpportunityTeamMembers[0].Id);
            //System.debug('##### ' + opp.OpportunityTeamMembers[0].Id);
        }
        
        List<OpportunityTeamMember> teamMembers = [select Id, OpportunityId from OpportunityTeamMember where Id in :teamMemberIds];
        
        /*System.debug('##### APJ: ' + [select Core_Opportunity_Geo_APJ__c, count(Id) from Opportunity group by Core_Opportunity_Geo_APJ__c][1]);
        System.debug('##### ASMO: ' + [select Core_Opportunity_Team_Geo_ASMO__c, count(Id) from Opportunity group by Core_Opportunity_Team_Geo_ASMO__c][1]);
        System.debug('##### EMEA: ' + [select Core_Opportunity_Team_Geo_EMEA__c, count(Id) from Opportunity group by Core_Opportunity_Team_Geo_EMEA__c][1]);
        System.debug('##### PRC: ' + [select Core_Opportunity_Team_Geo_PRC__c, count(Id) from Opportunity group by Core_Opportunity_Team_Geo_PRC__c][1]);*/
        
        Core_OpportunityTeamMemberHandler.updateGeoFlags(null, null, teamMembers);
        
        /*System.debug('##### APJ: ' + [select Core_Opportunity_Geo_APJ__c, count(Id) from Opportunity group by Core_Opportunity_Geo_APJ__c][1]);
        System.debug('##### ASMO: ' + [select Core_Opportunity_Team_Geo_ASMO__c, count(Id) from Opportunity group by Core_Opportunity_Team_Geo_ASMO__c][1]);
        System.debug('##### EMEA: ' + [select Core_Opportunity_Team_Geo_EMEA__c, count(Id) from Opportunity group by Core_Opportunity_Team_Geo_EMEA__c][1]);
        System.debug('##### PRC: ' + [select Core_Opportunity_Team_Geo_PRC__c, count(Id) from Opportunity group by Core_Opportunity_Team_Geo_PRC__c][1]);*/
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}