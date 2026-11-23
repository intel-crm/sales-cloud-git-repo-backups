/****************************************************************************************************************************************
* Class Name  : Core_MDF_RegionBudgetHandler 
* Version     : 1.0 
* Created Date: 09-05-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Raj Dubey                    09/05/2018                    Created for applying Trigger framework to process Sharing of Regionwise
records related to Campaign
*****************************************************************************************************************************************/
public class Core_MDF_RegionBudgetHandler extends TriggerHandler{  
    
    
    private boolean shareRegionwiseRecords = isActive('Core_MDF_Regionwise_Share');
    
    /*****************************************************************************************************************************************
Method Name:                                             afterInsert
@return  :                                               
@parameters:                                             List of Core_MDF_Regionwise_Campaign_Budget__c records, oldMap of Core_MDF_Regionwise_Campaign_Budget__c, Trigger Context boolean values.
Description:                                             Business logic methods will be called in this method in after insert trigger context.
Added By:                                                Accenture – Raj D  -  09/05/2018
Modified By:                  Date:                      Changes: 
Accenture – Raj D        09/05/2018                      Created.
*****************************************************************************************************************************************/           
    public override void afterInsert(){
        
        System.debug('shareRegionwiseRecords: '+shareRegionwiseRecords);
        if(shareRegionwiseRecords){            
            Core_MDF_ProcessCCP_RegionwiseSharing.shareRegionwiseRecords((List<Core_MDF_Regionwise_Campaign_Budget__c>) Trigger.new, (Map<Id, Core_MDF_Regionwise_Campaign_Budget__c>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        }
    }
    
    /*****************************************************************************************************************************************
Method Name:                                             afterUpdate
@return  :                                               
@parameters:                                             List of Core_MDF_Regionwise_Campaign_Budget__c records, oldMap of Core_MDF_Regionwise_Campaign_Budget__c, Trigger Context boolean values.
Description:                                             Business logic methods will be called in this method in after update trigger context.
Added By:                                                Accenture – Raj D  -  09/05/2018
Modified By:                  Date:                      Changes: 
Accenture – Raj D        09/05/2018                      Created.
*****************************************************************************************************************************************/      
    public override void afterUpdate(){
        if(shareRegionwiseRecords){
            Core_MDF_ProcessCCP_RegionwiseSharing.shareRegionwiseRecords((List<Core_MDF_Regionwise_Campaign_Budget__c>) Trigger.new, (Map<Id, Core_MDF_Regionwise_Campaign_Budget__c>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
        }
    }
    
    /*****************************************************************************************************************************************
    Method Name:                                             beforeUpdate
    @return  :                                               
    @parameters:                                             List of Core_MDF_Regionwise_Campaign_Budget__c records
    Description:                                             Business logic methods will be called in this method in before update trigger context.
    Added By:                                                Accenture – Varun  -  12/05/2019
    Modified By:                  Date:                      Changes: 
	*****************************************************************************************************************************************/           
    public override void beforeUpdate(){
        Core_MDF_ProcessCCP_RegionwiseSharing.checkUserPermission((List<Core_MDF_Regionwise_Campaign_Budget__c>) Trigger.new);
    }
    
    /*****************************************************************************************************************************************
    Method Name:                                             beforeInsert
    @return  :                                               
    @parameters:                                             List of Core_MDF_Regionwise_Campaign_Budget__c records
    Description:                                             Business logic methods will be called in this method in before insert trigger context.
    Added By:                                                Accenture – Varun  -  12/05/2019
    Modified By:                  Date:                      Changes: 
	*****************************************************************************************************************************************/
    public override void beforeInsert(){
        Core_MDF_ProcessCCP_RegionwiseSharing.checkUserPermission((List<Core_MDF_Regionwise_Campaign_Budget__c>) Trigger.new);
    }
}