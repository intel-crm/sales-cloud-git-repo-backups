/****************************************************************************************************************************************
* Class Name  : Core_MDF_CategoryBudgetHandler 
* Version     : 1.0 
* Created Date: 09-05-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Raj Dubey                    09/05/2018                    Created for applying Trigger framework to process Sharing of Categorywise
															 records related to Campaign
*****************************************************************************************************************************************/

public class Core_MDF_CategoryBudgetHandler extends TriggerHandler {
    
    
    boolean shareCategorywiseRecords = isActive('Core_MDF_Categorywise_Share');
    public override void afterInsert(){
        if(shareCategorywiseRecords){
        Core_MDF_ProcessCCP_CategorywiseSharing.shareCategorywiseRecords((List<Core_MDF_Categorywise_Campaign_Budget__c>) Trigger.new, (Map<Id, Core_MDF_Categorywise_Campaign_Budget__c>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        }
    }
    
    public override void afterUpdate(){
        
        if(shareCategorywiseRecords){
        Core_MDF_ProcessCCP_CategorywiseSharing.shareCategorywiseRecords((List<Core_MDF_Categorywise_Campaign_Budget__c>) Trigger.new, (Map<Id, Core_MDF_Categorywise_Campaign_Budget__c>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        }
        
    }
    
    /*****************************************************************************************************************************************
    Method Name:                                             beforeUpdate
    @return  :                                               
    @parameters:                                             List of Core_MDF_Categorywise_Campaign_Budget__c records
    Description:                                             Business logic methods will be called in this method in before update trigger context.
    Added By:                                                Accenture – Varun  -  12/05/2019
    Modified By:                  Date:                      Changes: 
	*****************************************************************************************************************************************/           
    public override void beforeUpdate(){
        Core_MDF_ProcessCCP_CategorywiseSharing.checkUserPermission((List<Core_MDF_Categorywise_Campaign_Budget__c>) Trigger.new);        
    }
    
    /*****************************************************************************************************************************************
    Method Name:                                             beforeInsert
    @return  :                                               
    @parameters:                                             List of Core_MDF_Categorywise_Campaign_Budget__c records
    Description:                                             Business logic methods will be called in this method in before insert trigger context.
    Added By:                                                Accenture – Varun  -  12/05/2019
    Modified By:                  Date:                      Changes: 
	*****************************************************************************************************************************************/           
    public override void beforeInsert(){        
        Core_MDF_ProcessCCP_CategorywiseSharing.checkUserPermission((List<Core_MDF_Categorywise_Campaign_Budget__c>) Trigger.new);
    }
}