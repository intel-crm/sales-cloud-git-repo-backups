/*********************************************************************************************************************
Class Name    : Sales_BulkHostProcessLicGenQueueable
Version       : 1.0
Created Date  : Aur 2021
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Ananga Mohan Sen           31-Aug-2021              US1085041:optimization license generation
* *********************************************************************************************************************/
public class Sales_BulkHostProcessLicGenQueueable implements Queueable,Database.AllowsCallouts {
    set<Id> hostIds=new set<Id>();
    String eventType;
    public Sales_BulkHostProcessLicGenQueueable(Set<Id> hostId,String eventType){
        this.hostIds = hostId ;
        this.eventType=eventType;
    }
    public void execute(QueueableContext context) {
        String hostIdLogTable='';
        Integer counter=0;
        boolean flagForNewQueue = false;
        for(Id idStr:hostIds){
            counter++;
            Sales_LicenseGenIntegration_Utility.returnHostIdDetail(idStr,'HostId',eventType);
            hostIds.remove(idStr);
            if(counter>Integer.valueOf(system.label.Sales_batchcount)){
                flagForNewQueue=true;
                break;
            } 
        }
        if(flagForNewQueue){
            System.enqueueJob(new Sales_BulkHostProcessLicGenQueueable(hostIds,eventType));
        }
    }
}