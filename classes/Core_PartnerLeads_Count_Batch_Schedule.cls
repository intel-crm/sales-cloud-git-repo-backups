global without sharing class Core_PartnerLeads_Count_Batch_Schedule implements Schedulable {

    global void execute(SchedulableContext sc){
        Database.executeBatch(new Core_PartnerLeads_Count_Batch(), 10);
    }
}