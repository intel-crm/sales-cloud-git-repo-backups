/****************************************************************************************************************************************
* Class Name  : Core_MDF_CampaignTriggerHandler 
* Version     : 1.0 
* Created Date: 7-18-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Raj Dubey                    7/18/2018                    Created for extending Trigger framework to process campaign business logic methods.
* Accenture - Shridhar K        7/31/2018                   Commented block campaign creation logic as the US95990 is deleted.
*****************************************************************************************************************************************/
public class Core_MDF_CampaignTriggerHandler extends TriggerHandler {     
    
    /*public override void beforeUpdate() {
        boolean determineAttributeFlag = isActive('Core_MDF_Campaign_Attributes');
       
        if(determineAttributeFlag){
            Core_MDF_ProcessCCP_Campaign.determineCampaignAttributes((List<Campaign>) Trigger.new, (Map<Id, Campaign>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        }
        /*if(coMarketingCampaignsWithBudget != NULL && !coMarketingCampaignsWithBudget.isEmpty()){
            Core_MDF_ProcessCCP_Campaign.validate_CCP_Campaigns(coMarketingCampaignsWithBudget, Trigger.isInsert, (Map<Id, Campaign>) Trigger.newMap,Trigger.isUpdate);                
        }*/
        
        //Core_MDF_CustomApprovalProcess.setApprovers(Trigger.New);
    //}
    /*
    public override void beforeInsert() {        
        boolean determineAttributeFlag = isActive('Core_MDF_Campaign_Attributes');
        
        if(determineAttributeFlag){            
         Core_MDF_ProcessCCP_Campaign.determineCampaignAttributes((List<Campaign>) Trigger.new, (Map<Id, Campaign>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        
        }
        
        */
        /*if(coMarketingCampaignsWithBudget != NULL && !coMarketingCampaignsWithBudget.isEmpty()){
            Core_MDF_ProcessCCP_Campaign.validate_CCP_Campaigns(coMarketingCampaignsWithBudget, Trigger.isInsert, (Map<Id, Campaign>) Trigger.newMap,Trigger.isUpdate);     
        }*/ 
        
        //Core_MDF_CustomApprovalProcess.setApprovers(Trigger.New);        
    //}
    /*
    public override void afterInsert(){
        boolean shareFlag = isActive('Core_MDF_ShareUnshareCampaign');
        boolean insertFlag = isActive('Core_MDF_insertRelatedRecords');
        if(shareFlag){
        Core_MDF_ProcessCCP_Campaign.shareUnshareCampaign((List<Campaign>) Trigger.new, (Map<Id, Campaign>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        }
        if(insertFlag){    
            Core_MDF_ProcessCamp_RelatedRecords.insertUpdateCategoryOrRegionRecords((List<Campaign>) Trigger.new, (Map<Id, Campaign>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        }
        }
    */
    /*
    public override void afterUpdate(){
        boolean shareFlag = isActive('Core_MDF_ShareUnshareCampaign');
        boolean insertFlag = isActive('Core_MDF_insertRelatedRecords');
        
       if(shareFlag){ 
        Core_MDF_ProcessCCP_Campaign.shareUnshareCampaign((List<Campaign>) Trigger.new, (Map<Id, Campaign>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
       
       }
        if(insertFlag){  
        Core_MDF_ProcessCamp_RelatedRecords.insertUpdateCategoryOrRegionRecords((List<Campaign>) Trigger.new, (Map<Id, Campaign>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        }
        } 
    */
   /* public override void afterDelete(){
        
    }

    public override void afterUndelete(){
        
    }*/    
}