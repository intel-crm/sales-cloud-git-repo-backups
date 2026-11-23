public class PRM_SubscriptionOutboundToErpm implements Queueable {    
    List<PRM_ContactSubscriptionAssociation__c> subListAll = new List<PRM_ContactSubscriptionAssociation__c>();  
    set<id> tagIds=new set<id>();
    Map<id,contact> contAllMap =new Map<id,contact>();
    List<contact> contactListErmpOutbound = new List<contact>();
    
    public PRM_SubscriptionOutboundToErpm(List<PRM_ContactSubscriptionAssociation__c> subList, Map<id,contact> contMap) {        
        subListAll.addAll(subList);
        contAllMap.putall(contMap);
    }
    
    public void execute(QueueableContext context) { 
        try{
            
            //Added to send subscription outbound to ERPM. Only those records which were part of Upsert will be considered here. The status of ERPM integration will be made as Pending. Outbound would be generated to ERPM for the same.
            if(!subListAll.IsEmpty()){
                for(PRM_ContactSubscriptionAssociation__c subListTemp :subListAll){
                    contact contToBeUpdated = new contact();
                    contToBeUpdated = contAllMap.get(subListTemp.PRM_Contact_Id__c);
                    contToBeUpdated.Core_ERPM_Integration_Status__c = 'Pending';
                    contactListErmpOutbound.add(contToBeUpdated);
                }
            }
            
            if(!contactListErmpOutbound.IsEmpty()){
                update contactListErmpOutbound;
            }
            
            //End-changes
            
        }catch(Exception exp){
            Core_Log_Entry.logEntryWithDetails('PRM_SubscriptionOutboundToErpm', 'IPA','ERPM-Outbound', 'exception','Exception occured while processing',exp.getMessage()+';;;'+exp.getStackTraceString() , ' ', ' ', ' ');                   
        }
    }
}