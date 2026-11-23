public class Core_EntitlementDetailReq_Queueable implements Queueable, Database.AllowsCallouts{
    public static Map<Id,String> ententReqIdMap = new Map<Id,String>();
    public Core_EntitlementDetailReq_Queueable(Map<Id,String> ententReqIdMapInput){
       ententReqIdMap = ententReqIdMapInput;
    }
    public static void execute(QueueableContext qc){
        system.debug('in Queueable');
        Core_EntitlementDetailReq_Handler.addEntitlementToProfileAccessPickList(ententReqIdMap);
    }
}