/****************************************************************************************************************************************
* Class Name  : Core_MDF_CampGridController 
* Version     : 1.0 
* Created Date: 8-10-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Raj D             8/10/2018                    Created Core_MDF_CampGridController class to handle sever interaction of Campaign grid 
                                                             component.
*****************************************************************************************************************************************/

public without sharing class Core_MDF_CampGridController {
    
    @AuraEnabled
    public static Boolean checkSObjectEditPermission(String objectName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(objectName);
        
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        Boolean checkEdit = r.updateable;
        return checkEdit;  
    }
    
    @AuraEnabled
    public static List<Core_MDF_Regionwise_Campaign_Budget__c> regionalData(Id cmpId){         

        List<Core_MDF_Regionwise_Campaign_Budget__c> regionalData = [SELECT Id, Name, Core_MDF_Campaign__c, Core_MDF_First_Year_Budget__c,
                         Core_MDF_Second_Year_Budget__c,toLabel(Core_MDF_Region__c),  Core_MDF_Campaign__r.Core_MDF_Opal_Budget_Type_Txt__c,
                         Core_MDF_Campaign__r.RecordType.DeveloperName FROM 
                         Core_MDF_Regionwise_Campaign_Budget__c WHERE Core_MDF_Campaign__c = :cmpId LIMIT 1000]; 
        
        return regionalData;
        
    }
    
    @AuraEnabled
    public static List<Core_MDF_Categorywise_Campaign_Budget__c> categoryData(Id cmpId){     
        
        List<Core_MDF_Categorywise_Campaign_Budget__c> categoryData = [SELECT Id, Name, toLabel(Core_MDF_Activity_Category__c),Core_MDF_Second_Year_Budget__c,
                        Core_MDF_First_Year_Budget__c,Core_MDF_Campaign__c,Core_MDF_Campaign__r.RecordType.DeveloperName FROM
                        Core_MDF_Categorywise_Campaign_Budget__c WHERE Core_MDF_Campaign__c = :cmpId LIMIT 1000];
        
        return categoryData;       
    }    
    
    @AuraEnabled
    public static void saveRegionWiseData(List<Core_MDF_Regionwise_Campaign_Budget__c> rWList){         
        try{
            if (rWList != null && !rWList.isEmpty()) {
                checkUserPermissionOnObj((List<SObject>)rWList);
                Database.Update (rWList);
            }            
        }
        catch(AuraHandledException e){ throw e; }        
    }
    
    @AuraEnabled
    public static void saveCategoryWiseData(List<Core_MDF_Categorywise_Campaign_Budget__c> cWList){        
        try{
            if (cWList != null && !cWList.isEmpty()) {
                checkUserPermissionOnObj((List<SObject>)cWList);
                Database.Update (cWList);
            }            
        }
        catch(AuraHandledException e){ throw e; }                       
    }    
    
    @AuraEnabled
    public static void savecampaignRecord(Id cRecord){
        List<campaign> cmpLst = new List<campaign>();
        Campaign cmp = [SELECT Id, Name,RecordTypeId, StartDate, EndDate, Core_MDF_Show_DCF_Modal__c  
                        FROM Campaign WHERE Id = :cRecord Limit 1 ];
        cmp.Core_MDF_Show_DCF_Modal__c = false;        
        cmpLst.add(cmp);
        
        try{
            Update cmpLst;
        }
        catch (AuraHandledException e){throw new AuraHandledException(e.getMessage());}
    }
    
    public static void checkUserPermissionOnObj(List<SObject> childList) {
        Set<Id> campaignIdSet = new Set<Id>();
        Map<Id, Boolean> accessMap = new Map<Id, Boolean>();
		Boolean hasNoEditAccess = false;
        
        // Dynamically get campaign Ids
        for (SObject childRecord : childList) {
            Id campaignId = (Id) childRecord.get('Core_MDF_Campaign__c');
            campaignIdSet.add(campaignId);
        }
        
        // Query UserRecordAccess
        for (UserRecordAccess userAccess : [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
            WHERE UserId = :UserInfo.getUserId() AND RecordId IN :campaignIdSet LIMIT 200]) {
            accessMap.put(userAccess.RecordId, userAccess.HasEditAccess); // userAccess.HasEditAccess
        }
        
        // Add errors to records without access
        for (SObject childRecord : childList) {
            Id campaignId = (Id) childRecord.get('Core_MDF_Campaign__c');
            if (accessMap.containsKey(campaignId) && accessMap.get(campaignId) != true) {
                hasNoEditAccess = true;
                break;
            }
        }
        if (hasNoEditAccess) {
            throw new AuraHandledException(Label.Core_MDF_CannotUpdateCampaignChild);
        }
    }
    
}