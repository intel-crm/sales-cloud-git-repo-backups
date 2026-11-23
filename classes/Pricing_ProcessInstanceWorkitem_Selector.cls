public class Pricing_ProcessInstanceWorkitem_Selector extends fflib_SObjectSelector {
    public static Pricing_ProcessInstanceWorkitem_Selector newInstance() {
        
        
        return (Pricing_ProcessInstanceWorkitem_Selector) Pricing_IQR_Application.selector.newInstance(ProcessInstanceWorkitem.SObjectType);
    }
    
    public Schema.SObjectType getSObjectType(){
        return ProcessInstanceWorkitem.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<ProcessInstanceWorkitem> selectbyQliIdandStatus(Id quoteLineId,String status){
        return [SELECT p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,p.ProcessInstanceId, p.OriginalActorId, p.Id FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.TargetObjectId = : quoteLineId AND ProcessInstance.Status =: status];
    }
    
    public List<ProcessInstanceWorkitem> selectbyQliIdsandStatus(Set<Id> quoteLineIds,String status){
        return [SELECT p.ProcessInstance.Status, p.ProcessInstance.TargetObjectId,p.ProcessInstanceId, p.OriginalActorId, p.Id FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.TargetObjectId IN : quoteLineIds AND ProcessInstance.Status =: status];
    }
}