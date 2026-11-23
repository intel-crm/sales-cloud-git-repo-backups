public without sharing class Core_BatchToSyncLeadPartnerSegment implements schedulable {
    
    public void execute(SchedulableContext sc){
        Set<id> mpIdSet = new Set<id>();
        List<Lead> leadList = new List<Lead>();
        for(PMP_Company__c mpi : [Select Id from PMP_Company__c where IsPartnerSegmentChanged__c = true])
        {
            mpIdSet.add(mpi.Id);
        }
        system.debug('mpIdSet-'+mpIdSet.size());
        if(mpIdSet.size()>0 && !mpIdSet.isEmpty()){
            leadList = [SELECT id,Core_Remove_Current_Sharing_Ind__c, Core_Reprocess_Lead_Sharing__c from LEAD where Core_MPI_Id__c in:mpIdSet and RecordType.DeveloperName = 'Partner_Lead' limit 1];
        }
        if(leadList.size()>0){
            database.executeBatch(new Core_Batch_ReprocessLeadShare(mpIdSet),100);
        }
    }
}