/****************************************************************************************************************************************
* Class Name  : Core_MDF_BudgetCapTriggerHandler  
* Version     : 1.0 
* Created Date: 05-09-2019 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Harika P                    5/09/2019                    Created for extending Trigger framework to process budget cap business logic methods.
*****************************************************************************************************************************************/
public class Core_MDF_BudgetCapTriggerHandler extends TriggerHandler {
    
    // Map of Budget Cap's Record Type id and Record type info
    public static Map<ID, Schema.RecordTypeInfo> budgetCapRecTypeMap = Schema.SObjectType.Core_MDF_Budget_Cap__c.getRecordTypeInfosById();
    
    public override void beforeInsert() {
    // ccp budget caps to be processed in before insert        
        List<Core_MDF_Budget_Cap__c> ccpBudgetCapOnBeforeInsert = new List<Core_MDF_Budget_Cap__c>();
        // budget type caps to be processed in before insert ('IPA')
        List<Core_MDF_Budget_Cap__c> budgetTypeCapOnBeforeInsert = new List<Core_MDF_Budget_Cap__c>();
        for(Core_MDF_Budget_Cap__c budgetCap : (List<Core_MDF_Budget_Cap__c>)Trigger.new){
            if(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName() == 'Core_MDF_CCP_Budget_Cap'){
                ccpBudgetCapOnBeforeInsert.add(budgetCap);
            }
            else if(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName() == 'Core_MDF_IPA_Budget_Type_Cap'){
                budgetTypeCapOnBeforeInsert.add(budgetCap);
            }
        }
        boolean insertFlag = isActive('Core_MDF_budgetCapProcessOnBeforeInsert');
        //ATHR - Deeply Nested if 16209
        if(!insertFlag){
            return;
        }
            /*********** CCP Budget Caps Method *************/
            if(ccpBudgetCapOnBeforeInsert != NULL && ccpBudgetCapOnBeforeInsert.size()>0){
             // Core_MDF_ProcessCCP_BudgetCap.getSumOfClaimedAmount(ccpBudgetCapOnBeforeInsert, (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);  
              // ATHR Avoid long parameter lists - US 14285 - Indira
              // Create wrapper and call method
           Core_MDF_ProcessCCP_BudgetCap.BudgetCapProcessWrapper context = new Core_MDF_ProcessCCP_BudgetCap.BudgetCapProcessWrapper(
                ccpBudgetCapOnBeforeInsert, 
                (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, 
                Trigger.isInsert, 
                Trigger.isUpdate
            );
            Core_MDF_ProcessCCP_BudgetCap.getSumOfClaimedAmount(context);    
            }
            /*********** Budget Type Caps Method *************/
            //ATHR - Deeply Nested if 16209
            if(budgetTypeCapOnBeforeInsert == null || budgetTypeCapOnBeforeInsert.isEmpty()){
                return;
            }
                
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassBudgCapIUPGMValidation')){
                    // Throw Error on the Budget Caps if the running user is not having required access
                    Core_MDF_BudgetTypeCap_Utility.validateBudgetTypeCapCreationOrUpdateAccess(budgetTypeCapOnBeforeInsert);
                }
                
                if(isActive('Core_MDF_BudgetTypeCapOverlapDupCheck')){
                    // Throw Error on the Budget Caps which are either Deplicate or time period overlaps with New or existing records
                    Core_MDF_BudgetTypeCap_Utility.budgetTypeCapOverlapDupCheck(budgetTypeCapOnBeforeInsert, (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate); 
                }
                
                
                
                if(isActive('Core_MDF_BudgetTypeCapProcessingonInsert')){
                    // Calculate Claimed cap Amount for Budget caps By summing up required campaigns
                    Core_MDF_BudgetTypeCap_Utility.getClaimedAmtOfBudgetCapsOnInsert(budgetTypeCapOnBeforeInsert);
                }
    }
    public override void beforeUpdate() {
        // ccp budget caps to be processed in before Update
        List<Core_MDF_Budget_Cap__c> ccpBudgetCapOnBeforeUpdate = new List<Core_MDF_Budget_Cap__c>();
        // budget type caps to be processed in before Update ('IPA')
        List<Core_MDF_Budget_Cap__c> budgetTypeCapOnBeforeUpdate = new List<Core_MDF_Budget_Cap__c>();
        for(Core_MDF_Budget_Cap__c budgetCap : (List<Core_MDF_Budget_Cap__c>)Trigger.new){
            if(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName() == 'Core_MDF_CCP_Budget_Cap'){
                ccpBudgetCapOnBeforeUpdate.add(budgetCap);
            }
            else if(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName() == 'Core_MDF_IPA_Budget_Type_Cap'){
                budgetTypeCapOnBeforeUpdate.add(budgetCap);
            }
        }
        boolean updateFlag = isActive('Core_MDF_budgetCapProcessOnBeforeUpdate');
        //ATHR - Deeply Nested if 16209
        if(!updateFlag){
            return;
        }

        //if(updateFlag){            
            /*********** CCP Budget Caps Method *************/
            if(ccpBudgetCapOnBeforeUpdate != NULL && ccpBudgetCapOnBeforeUpdate.size()>0){
            //  Core_MDF_ProcessCCP_BudgetCap.getSumOfClaimedAmount(ccpBudgetCapOnBeforeUpdate, (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
             // ATHR Avoid long parameter lists - US 14285 - Indira
             // Create wrapper and call method
                Core_MDF_ProcessCCP_BudgetCap.BudgetCapProcessWrapper context = new Core_MDF_ProcessCCP_BudgetCap.BudgetCapProcessWrapper(
                ccpBudgetCapOnBeforeUpdate, 
                (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, 
                Trigger.isInsert, 
                Trigger.isUpdate
            );
            Core_MDF_ProcessCCP_BudgetCap.getSumOfClaimedAmount(context);
        
            }
            /***********Budget Type Caps Method *************/
            //ATHR - Deeply Nested if 16209
            if(budgetTypeCapOnBeforeUpdate == NULL || budgetTypeCapOnBeforeUpdate.isEmpty()){
                return;
            }
            //if(budgetTypeCapOnBeforeUpdate != NULL && budgetTypeCapOnBeforeUpdate.size()>0){
                
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassBudgCapIUPGMValidation')){
                    // Throw Error on the Budget Caps if the running user is not having required access
                    Core_MDF_BudgetTypeCap_Utility.validateBudgetTypeCapCreationOrUpdateAccess(budgetTypeCapOnBeforeUpdate);
                }
                
                if(isActive('Core_MDF_BudgetTypeCapOverlapDupCheck')){
                    // Throw Error on the Budget Caps which are either Deplicate or time period overlaps with existing records
                    Core_MDF_BudgetTypeCap_Utility.budgetTypeCapOverlapDupCheck(budgetTypeCapOnBeforeUpdate, (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, Trigger.isInsert,Trigger.isUpdate);
                }
                
                
                
                if(isActive('Core_MDF_BudgetTypeCapProcessingonUpdate')){
                    // Set of Budget Cap Id that will be Used for delinking campaigns
                    Set<Id> budgetCapIdsForDelinkingSet = new Set<Id>();
                    // Separate out Budget caps For Delinking and Linking
                    budgetCapIdsForDelinkingSet = Core_MDF_BudgetTypeCap_Utility.identifyBudgetTypesCapsForLinkDelink(budgetTypeCapOnBeforeUpdate,(Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap);
                    // Run the Delinking Logic for Campaigns from Budget caps which are either inactivated or theirs dates are changed
                    Core_MDF_BudgetTypeCap_Utility.delinkCampaignsFromBudgetTypeCap(budgetCapIdsForDelinkingSet);
                    // Calculate Claimed cap Amount on Budget caps By summing up campaigns of required statuses
                    Core_MDF_BudgetTypeCap_Utility.getClaimedCapAmtOfBudgetCapsOnUpdate();
                    
                }
            //}
        //}        
    }
    
    /***************************************************************************************************** 
    Method Name   :        afterUpdate
    @return       :        void
    @parameters   :        No parameters
    Added By      :        Accenture - VK - 12/16/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public override void afterUpdate() {
        // ccp budget caps to be processed in After Update
        List<Core_MDF_Budget_Cap__c> ccpBudgetCapOnAfterUpdate = new List<Core_MDF_Budget_Cap__c>();
        // budget type caps to be processed in After Update ('IPA')
        List<Core_MDF_Budget_Cap__c> budgetTypeCapOnAfterUpdate = new List<Core_MDF_Budget_Cap__c>();
        for(Core_MDF_Budget_Cap__c budgetCap : (List<Core_MDF_Budget_Cap__c>)Trigger.new){
            if(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName() == 'Core_MDF_CCP_Budget_Cap'){
                ccpBudgetCapOnAfterUpdate.add(budgetCap);
            }
            else if(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName() == 'Core_MDF_IPA_Budget_Type_Cap'){
                budgetTypeCapOnAfterUpdate.add(budgetCap);
            }
        }
        boolean afterUpdateFlag = isActive('Core_MDF_budgetCapProcessOnAfterUpdate');
        //ATHR - Deeply Nested if 16209
        if(!afterUpdateFlag){
            return;
        }
            /*********** CCP Budget Caps Method *************/
            if(ccpBudgetCapOnAfterUpdate != NULL && ccpBudgetCapOnAfterUpdate.size()>0){
             /*   Core_MDF_ProcessCCP_BudgetCap.shareWithFinMgr(ccpBudgetCapOnAfterUpdate, 
                                                              (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, 
                                                              Trigger.isInsert,
                                                              Trigger.isUpdate);  */
                // ATHR Avoid long parameter lists - US 14285 - Indira
                // Create wrapper and call method
                Core_MDF_ProcessCCP_BudgetCap.ShareWithFinMgrWrapper shareContext = new Core_MDF_ProcessCCP_BudgetCap.ShareWithFinMgrWrapper(
                    ccpBudgetCapOnAfterUpdate, 
                    (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, 
                    Trigger.isInsert,
                    Trigger.isUpdate
                );
                Core_MDF_ProcessCCP_BudgetCap.shareWithFinMgr(shareContext);
            }
            /*********** Budget Type Caps Method *************/
            //ATHR - Deeply Nested if 16209
            if(budgetTypeCapOnAfterUpdate == NULL || budgetTypeCapOnAfterUpdate.isEmpty()){
                return;
            }
                if(isActive('Core_MDF_BudgetTypeCapProcessingonUpdate')){
                    // linking Logic for Campaigns with Budget caps which are either newly Activated or theirs dates are changed
                    
                    if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassCampaignLinking')){ 
                      Core_MDF_BudgetTypeCap_Utility.linkCampaignsToBudgetTypeCapOnUpdate(budgetTypeCapOnAfterUpdate);
                    }
                    if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassSharingOwner_GeoUpdate')){
                        //To share record after Owner/Geo Update
                      Core_MDF_BudgetTypeCap_Utility.reshareBudgetCapRecords(budgetTypeCapOnAfterUpdate,(Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap);
                    }
                }
    }
    
    /***************************************************************************************************** 
    Method Name   :        afterInsert
    @return       :        void
    @parameters   :        No parameters
    Added By      :        Accenture - VK - 12/16/2019
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
    public override void afterInsert() {
        // ccp budget caps to be processed in After Insert
        List<Core_MDF_Budget_Cap__c> ccpBudgetCapOnAfterInsert = new List<Core_MDF_Budget_Cap__c>();
        //budget type caps to be processed in After Insert ('IPA')
        List<Core_MDF_Budget_Cap__c> budgetTypeCapOnAfterInsert = new List<Core_MDF_Budget_Cap__c>();
        for(Core_MDF_Budget_Cap__c budgetCap : (List<Core_MDF_Budget_Cap__c>)Trigger.new){
            if(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName() == 'Core_MDF_CCP_Budget_Cap'){
                ccpBudgetCapOnAfterInsert.add(budgetCap);
            }
            else if(budgetCapRecTypeMap.get(budgetCap.RecordTypeId).getDeveloperName() == 'Core_MDF_IPA_Budget_Type_Cap'){
                budgetTypeCapOnAfterInsert.add(budgetCap);
            }
        }
        boolean afterInsertFlag = isActive('Core_MDF_budgetCapProcessOnAfterInsert');
        //ATHR - Deeply Nested if 16209
        if(!afterInsertFlag){
            return;
        }
            /*********** CCP Budget Caps Method *************/
            if(ccpBudgetCapOnAfterInsert != NULL && ccpBudgetCapOnAfterInsert.size()>0){
             /*   Core_MDF_ProcessCCP_BudgetCap.shareWithFinMgr(ccpBudgetCapOnAfterInsert, 
                                                              (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, 
                                                              Trigger.isInsert,
                                                              Trigger.isUpdate);  */
                // ATHR Avoid long parameter lists - US 14285 - Indira
                // Create wrapper and call method
                Core_MDF_ProcessCCP_BudgetCap.ShareWithFinMgrWrapper shareContext = new Core_MDF_ProcessCCP_BudgetCap.ShareWithFinMgrWrapper(
                    ccpBudgetCapOnAfterInsert, 
                    (Map<Id,Core_MDF_Budget_Cap__c>) Trigger.oldMap, 
                    Trigger.isInsert,
                    Trigger.isUpdate
                );
                Core_MDF_ProcessCCP_BudgetCap.shareWithFinMgr(shareContext);
            }
            /*********** Budget Type Caps Method *************/
            //ATHR - Deeply Nested if 16209
            if(budgetTypeCapOnAfterInsert == null || budgetTypeCapOnAfterInsert.isEmpty()){
                return;
            }
                if(isActive('Core_MDF_BudgetTypeCapProcessingonInsert')){
                    // linking Logic for Campaigns with Budget caps which are which are newly created
                    
                    if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassCampaignLinking')){
                      Core_MDF_BudgetTypeCap_Utility.linkCampaignsToBudgetTypeCap(budgetTypeCapOnAfterInsert);
                    }
                    if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassBudgetTypeCap_Sharing')){
                      Core_MDF_BudgetTypeCap_Utility.shareRecordToGeoGroup(budgetTypeCapOnAfterInsert);
                    }
                }
    }
}