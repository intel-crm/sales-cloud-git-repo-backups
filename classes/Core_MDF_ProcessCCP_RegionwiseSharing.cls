/********************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCCP_RegionwiseSharing 
* Version     : 1.0 
* Created Date: 8-27-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Raj D        8/27/2018                    Create for Regionwise Budget object records sharing on insert of campaigns. 
*********************************************************************************************************************************************/
public without sharing class Core_MDF_ProcessCCP_RegionwiseSharing {
    
/*****************************************************************************************************************************************
Method Name:                                             shareRegionwiseRecords
@return  :                                               
@parameters:                                             List of Core_MDF_Regionwise_Campaign_Budget__c records, oldMap of Core_MDF_Regionwise_Campaign_Budget__c, Trigger Context boolean values.
Description:                                             Business logic methods will be called in this method in after insert trigger context.
Added By:                                                Accenture – Raj D  -  8/27/2018
Modified By:                  Date:                      Changes: 
Accenture – Raj D        8/27/2018                   Created.
*****************************************************************************************************************************************/      
        public static void shareRegionwiseRecords(List<Core_MDF_Regionwise_Campaign_Budget__c> newRegionwiseList, Map<Id,Core_MDF_Regionwise_Campaign_Budget__c> regionwiseOldMap, boolean isInsert, boolean isUpdate){ 
        
        Map<Id,List<Id>> objectIdUserGroupIdListMapToShare = new Map<Id,List<Id>> ();       
                
        Map<Id,List<CampaignShare>> cmpWithCampaignShare = new Map<Id,List<CampaignShare>>{};
        Set<Id> cmpId = new Set<Id>();
        
        for (Core_MDF_Regionwise_Campaign_Budget__c regwise : newRegionwiseList){
            cmpId.add(regwise.Core_MDF_Campaign__c);
        }
        
        // Map of Campaign and List of campaignShare
        for (Campaign cmp : [Select Id, (SELECT Id, CampaignId, UserOrGroupId, RowCause FROM Shares WHERE RowCause!='Rule') FROM Campaign WHERE Id IN :cmpId LIMIT 50000]){         
            cmpWithCampaignShare.put(cmp.Id, cmp.Shares);
        }                   
        System.debug('cmpWithCampaignShare:'+cmpWithCampaignShare);
        
        for(Core_MDF_Regionwise_Campaign_Budget__c regwise : newRegionwiseList) {            
            List<Id> userorGroupIdToShare = new List<Id> ();                            
            // Creating list of user or group Id to share the records
            if(isInsert || (isUpdate && (regwise.OwnerId != regionwiseOldMap.get(regwise.Id).OwnerId))){                                    
                for(Campaignshare cmpShare : cmpWithCampaignShare.get(regwise.Core_MDF_Campaign__c)){
                    
                    userorGroupIdToShare.add(cmpShare.UserOrGroupId);                        
                }
                system.debug('userorGroupIdToShare:'+userorGroupIdToShare);                
            }            
            
            if(userorGroupIdToShare.size() > 0){
                objectIdUserGroupIdListMapToShare.Put(regwise.Id, userorGroupIdToShare);    
            }                             
        }
        //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Core_MDF_Regionwise_Campaign_Budget__c', objectIdUserGroupIdListMapToShare);               
        Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Regionwise_Campaign_Budget__c', objectIdUserGroupIdListMapToShare, 'Edit');
		Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
    }
    
    /*****************************************************************************************************************************************
    Method Name:                                             checkUserPermission
    @return  :                                               
    @parameters:                                             List of Core_MDF_Regionwise_Campaign_Budget__c records
    Description:                                             To have a check on who is editing the region wise records
    Added By:                                                Accenture – Varun  -  12/05/2019
    Modified By:                  Date:                      Changes: 
	*****************************************************************************************************************************************/
    public static void checkUserPermission(List<Core_MDF_Regionwise_Campaign_Budget__c> regionWiseList){
        
        Set<Id> campaignIdSet = new Set<Id>();
        Map<Id,Boolean> accessMap = new Map<Id, Boolean>();
        
        for(Core_MDF_Regionwise_Campaign_Budget__c rwc : regionWiseList){
            campaignIdSet.add(rwc.Core_MDF_Campaign__c);
        }
        
        for(UserRecordAccess userAccess : [SELECT RecordId, HasEditAccess
                                           FROM UserRecordAccess 
                                           WHERE UserId=:UserInfo.getUserId() AND RecordId IN : campaignIdSet LIMIT 200]){
            accessMap.put(userAccess.RecordId, userAccess.HasEditAccess);
        }

        
        //Iterate over each record
        for(Core_MDF_Regionwise_Campaign_Budget__c rwc : regionWiseList){
            if(accessMap.containsKey(rwc.Core_MDF_Campaign__c) && accessMap.get(rwc.Core_MDF_Campaign__c) != TRUE){
                rwc.addError(Label.Core_MDF_CannotUpdateCampaignChild);
            }        
            
        }
    }
}