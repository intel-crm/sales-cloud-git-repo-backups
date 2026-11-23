public class PRM_makeCallout implements Queueable,Database.AllowsCallouts {    
    /*List<id> OBMId = new List<id>();  
    set<id> tagIds=new set<id>();
    Map<id,Core_Integration_Outbound_Message__c> statusMap=new Map<id,Core_Integration_Outbound_Message__c>();
    
    public PRM_makeCallout(List<Id> Ids) {        
        OBMId.addAll(Ids);
    }*/
    
    public void execute(QueueableContext context) { 
        /*try{
            for(Core_Integration_Outbound_Message__c obms : [SELECT Id, Core_Payload__c, Core_Tags__c, Core_Status__c, Core_MessageType__c,
                                                             Core_Retry_Number__c 
                                                             FROM Core_Integration_Outbound_Message__c WHERE Id in:OBMId])
            {                                                           
                statusMap.putAll(PRM_CIMOutboundCallout.invokeCalloutToCIM(obms));   
                tagIds.add(obms.Core_Tags__c);
            } 
            if(statusMap.size()>0){    
                Database.update(statusMap.values(),false); 
                
            }        
            //TWC729-8055        - class EOLed
            //PRM_VXRecommendation_Utility.statusCheck(tagIds);                
            
        }catch(Exception exp){
            Core_Log_Entry.logEntryWithDetails('PRM_CIMOutboundCallout', 'IPA','CIM_Outbound_Integration', 'exception','Exception occured while processing',exp.getMessage()+';;;'+exp.getStackTraceString() , ' ', ' ', ' ');                   
        }finally{
            //Log Entry To Capture the Complete Transaction Details 
            Core_Log_Entry.logEntryWithDetails('PRM_CIMOutboundCallout', 'IPA','CIM_Outbound_Integration','Transaction Completed','Message',PRM_CIMOutboundCallout.strResponse, ' ', ' ', ' ');        
        }*/
        
    }
}