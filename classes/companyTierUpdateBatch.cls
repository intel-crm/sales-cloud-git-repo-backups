global class companyTierUpdateBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Integer totalUpdated = 0;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, PMP_IPA_Badge_Tier_Txt__c ' +
                       'FROM PMP_Company__c ' +
                       'WHERE PMP_IPA_Badge_Tier_Txt__c IN (\'Member\', \'Gold\', \'Titanium\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<PMP_Company__c> recordsToUpdate = new List<PMP_Company__c>();

        for (PMP_Company__c mpi : (List<PMP_Company__c>)scope) {
            Boolean isUpdated = false;

            if (mpi.PMP_IPA_Badge_Tier_Txt__c == 'Titanium') {
                mpi.PMP_IPA_Badge_Tier_Txt__c = 'Prestige';
                isUpdated = true;
            } else if (mpi.PMP_IPA_Badge_Tier_Txt__c == 'Member' ||
                       mpi.PMP_IPA_Badge_Tier_Txt__c == 'Gold') {
                mpi.PMP_IPA_Badge_Tier_Txt__c = 'Partner';
                isUpdated = true;
            }
            if (isUpdated) {
                recordsToUpdate.add(mpi);
            }
        }
        if (!recordsToUpdate.isEmpty()) {
            update recordsToUpdate;
            totalUpdated += recordsToUpdate.size(); // Track total updated
            System.debug('Updated ' + recordsToUpdate.size() + ' records in this chunk.');
        }
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch processing completed. Total records updated: ' + totalUpdated);
    }
}