/****************************************************************************************************
Apex Class Name : SWS_CampaignInfluenceBatch
Version         : 1.0
Function        : Batch job to backfill/recalculate standard Campaign Influence records
                   (EvenDistribution model) for all Opportunities created from 2025 onward,
                   regardless of open/closed status.
*****************************************************************************************************/
public class SWS_CampaignInfluenceBatch implements Database.Batchable<SObject>, Database.Stateful {

    private static final String LOG_ENTRY_CLASS_NAME = 'CampaignInfluenceBatch';
    private static final String LOG_ENTRY_OBJECT = 'CampaignInfluence';
    private static final String LOG_ENTRY_SEVERITY = 'High';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date cutoffDate = Date.newInstance(2025, 1, 1);
        return Database.getQueryLocator([
            SELECT Id
            FROM Opportunity
            WHERE CreatedDate >= :cutoffDate
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : scope) {
            oppIds.add(opp.Id);
        }

        try {
            SWS_CampaignInfluenceService.recalculateForOpportunities(oppIds);
        } catch (Exception e) { SWS_Utility.createCoreLogEntry(LOG_ENTRY_CLASS_NAME,'execute','Error while recalculating Campaign Influence for batch scope','',e,LOG_ENTRY_OBJECT,LOG_ENTRY_SEVERITY,'');
        }
    }

    public void finish(Database.BatchableContext bc) {
      
    }
}