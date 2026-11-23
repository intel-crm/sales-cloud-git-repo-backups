/****************************************************************************************************************************************
* Class Name  : Core_MDF_Partnership_ScoreTriggerHandler 
* Version     : 1.0 
* Created Date: 2-17-2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Navneet Kaur                 2/17/2022                        Created 
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Partnership_ScoreTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        if (isActive('Core_MDF_PartnershipScore_Before_Insert')){
            if(!Core_MDF_Utility.byPassFeature('Bypass_PopulateandValidateExternalId')){
                Core_MDF_Partnership_ScoreServiceHandler.populateAndValidateFields((List<Core_MDF_Partnership_Score__c>) Trigger.new);
                
            }
            if(!Core_MDF_Utility.byPassFeature('Bypass_ValidatePartnerScoreforUpdate')){
                Core_MDF_Partnership_ScoreServiceHandler.validatePartnerScoreforUpdate((List<Core_MDF_Partnership_Score__c>) Trigger.new,null);
            }      

            if(!Core_MDF_Utility.byPassFeature('Bypass_PopulateZonePercentage')){
                Core_MDF_Partnership_ScoreServiceHandler.populateZonePercentage((List<Core_MDF_Partnership_Score__c>)Trigger.new, null);
            }
        }
    }
    public override void beforeUpdate() {
        if (isActive('Core_MDF_PartnershipScore_Before_Update')){
            if(!Core_MDF_Utility.byPassFeature('Bypass_ValidatePartnerScoreforUpdate'))
                Core_MDF_Partnership_ScoreServiceHandler.validatePartnerScoreforUpdate((List<Core_MDF_Partnership_Score__c>) Trigger.new,(Map<Id,Core_MDF_Partnership_Score__c>) Trigger.oldMap);
            //Update Partnershipscore share flag to false if there is owner update
            if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassSharingAfterOwnerUpdate'))
                Core_MDF_Partnership_ScoreServiceHandler.resetIsRecordSharedFlagAfterOwnerUpdate((Map<Id,Core_MDF_Partnership_Score__c>) Trigger.oldMap,
                                                               (Map<Id,Core_MDF_Partnership_Score__c>) Trigger.newMap);

            if(!Core_MDF_Utility.byPassFeature('Bypass_PopulateZonePercentage')){
                Core_MDF_Partnership_ScoreServiceHandler.populateZonePercentage((List<Core_MDF_Partnership_Score__c>)Trigger.new, (Map<Id,Core_MDF_Partnership_Score__c>)Trigger.oldMap);
            }
        }    
    }
    
    public override void afterInsert() {
        Integer PartnershipSharingSyncBatchSize=Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PartnershipSharingSyncBatchSize'));
        Integer PartnershipShareASyncBatchSize=Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PartnershipShareASyncBatchSize'));
        //ATHR - Deeply Nested if 16209
        if(!isActive('Core_MDF_PartnershipScore_After_Insert')) return;
        if(System.isBatch()) return;
        if(Core_MDF_Utility.byPassFeature('Core_MDF_BypassPartnership_Sharing')) return;
        /*if (isActive('Core_MDF_PartnershipScore_After_Insert')){
            if(!system.isbatch())
            {
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassPartnership_Sharing')){*/
                    //calling batch class if there are more than one records are inserted
                    if(trigger.new.size()>PartnershipSharingSyncBatchSize){ 
                        Core_MDF_Batch_Partnership_Score_Sharing batchInstance=new Core_MDF_Batch_Partnership_Score_Sharing((List<Core_MDF_Partnership_Score__c>) Trigger.new);
                        Id batchId = Database.executeBatch(batchInstance,PartnershipShareASyncBatchSize);
                    }
                    else
                    {
                        Core_MDF_Partnership_ScoreServiceHandler.partnershipscoreSharingMainMethod((List<Core_MDF_Partnership_Score__c>) Trigger.new);
                    }
                /*}
                
            }
        }*/
    }
    public override void afterUpdate(){
        //ATHR - Deeply Nested if 16209
        if(!isActive('Core_MDF_PartnershipScore_After_Update')) return;
        if(System.isBatch()) return;
        /*if (isActive('Core_MDF_PartnershipScore_After_Update')){
            if(!system.isbatch()){*/
                //resharePartnershipScoreRecords will do the sharing after checking if owner is updated 
                if(!Core_MDF_Utility.byPassFeature('Core_MDF_BypassSharingAfterOwnerUpdate')){
                    Core_MDF_Partnership_ScoreServiceHandler.resharePartnershipScoreRecords((Map<Id,Core_MDF_Partnership_Score__c>) Trigger.oldMap,
                                                                   (Map<Id,Core_MDF_Partnership_Score__c>) Trigger.newMap);
                }
            //}
        //}
    }
}