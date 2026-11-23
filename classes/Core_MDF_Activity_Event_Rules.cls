/****************************************************************************************************************************************
* Class Name  : Core_MDF_Activity_Event_Rules 
* Version     : 1.0 
* Created Date: 08-23-2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hamza                       08/23/2019                    Contains the logic for Event rules on Activity for specific programs
*****************************************************************************************************************************************/
public class Core_MDF_Activity_Event_Rules {
    
    /****************************************************************************************************** 
Method Name:        checkEventRules
@return  :          void
@parameters:        PFR List
Description:        This method is used to check the event rules on activity
Added By:           
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    
    /*public static void checkEventRules(List<PartnerFundRequest> pfrList, List<PartnerFundRequest> oldpfrList) {
        
        Boolean hasCustomPermission = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Custom_Permission_IAM'));
        List<Core_MDF_PFR_Event_Rule__mdt> metadataList = [SELECT Id, 
                                                           Core_MDF_PFR_RecordType__c, Core_MDF_Activity_Category__c, 
                                                           Core_MDF_Requested_Amount__c, Core_MDF_Activity_Types__c, 
                                                           Core_MDF_Days_Difference__c, Core_MDF_PFR_RecordType_Id__c FROM Core_MDF_PFR_Event_Rule__mdt];
        if(!hasCustomPermission){
            
            Map<Id, Date> oldPfrMap = new Map<Id, Date>();
            if(oldpfrList != NULL && oldpfrList.size() > 0){
                for(PartnerFundRequest oldPfr : oldpfrList){
                    oldPfrMap.put(oldPfr.Id, oldPfr.Core_MDF_Start_Date__c);
                    
                }
            }
            
            if(pfrList != NULL && pfrList.size() > 0){
                for(PartnerFundRequest pfr : pfrList){
                    Date startDate = pfr.Core_MDF_Start_Date__c;
                    Date todayDate = system.today();
                    Integer daysDifference = todayDate.daysBetween(startDate);
                    Boolean errorthrown = false;
                    if(oldPfrMap.get(pfr.Id) != pfr.Core_MDF_Start_Date__c && oldPfrMap.size() > 0 || pfr.Id == NULL){
                        
                        for(Core_MDF_PFR_Event_Rule__mdt customMetadata : metadataList){
                            
                            if(customMetadata.Core_MDF_PFR_RecordType_Id__c == pfr.RecordTypeId 
                               && customMetadata.Core_MDF_Activity_Category__c == pfr.Core_MDF_ActivityCategory__c
                               && customMetadata.Core_MDF_Activity_Types__c.contains(pfr.Core_MDF_Activity_Types__c)    
                               && pfr.Id == NULL 
                               && !(pfr.Core_MDF_Fund_Request_Status__c.Contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status')))) {
                                   
                                   if(Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_30_Days_Less_Than_50K')) > daysDifference
                                      && (Double.valueof(customMetadata.Core_MDF_Requested_Amount__c)) > pfr.RequestedAmount){
                                          pfr.addError(Label.Core_MDF_Activity_Event_30_Days);
                                          errorthrown = true;
                                      }
                                   
                                   else if(customMetadata.Core_MDF_Days_Difference__c > daysDifference 
                                           && pfr.RequestedAmount >= (Double.valueof(customMetadata.Core_MDF_Requested_Amount__c))){
                                               if(pfr.RecordTypeId != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_RecordType_Id')){
                                                   pfr.addError(Label.Core_MDF_Activity_Event_60_Days);  
                                                   errorthrown = true;
                                               }
                                               else{
                                                   pfr.addError(Label.Core_MDF_Activity_Event_22_Days);
                                                   errorthrown = true;
                                               }
                                               
                                           }
                                   if(errorthrown){
                                       break; 
                                   }
                               }
                        }
                    }
                }
            }
        }
    }














/* else if(customMetadata.Core_MDF_Days_Difference__c > daysDifference && (Double.valueof(customMetadata.Core_MDF_Requested_Amount__c)) > pfr.RequestedAmount){
system.debug('abc8'+(Double.valueof(customMetadata.Core_MDF_Requested_Amount__c))+'abc8b'+pfr.RequestedAmount);
pfr.addError(Label.Core_MDF_Activity_Event_30_Days);
}*/

// oldMtd = Integer.valueOf(customMetadata.Core_MDF_Days_Difference__c);

/*         else if(pfr.Id != NULL && oldpfrList.size() > 0){
for(PartnerFundRequest oldPfr : oldpfrList){
Date oldStartDate = oldPfr.Core_MDF_Start_Date__c;
Date oldTodayDate = system.today();
Integer oldDaysDifference = startDate.daysBetween(oldTodayDate);
system.debug('abc9'+startDate+'-->'+todayDate+'-->>'+daysDifference);
if(oldPfr.Core_MDF_Start_Date__c != pfr.Core_MDF_Start_Date__c
&& !(oldPfr.Core_MDF_Fund_Request_Status__c.Contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status')))
&& oldPfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Revision_Required')
&& customMetadata.Core_MDF_PFR_RecordType_Id__c == oldPfr.RecordTypeId 
&& customMetadata.Core_MDF_Activity_Category__c == oldPfr.Core_MDF_ActivityCategory__c
&& oldPfr.Core_MDF_Activity_Types__c.contains(customMetadata.Core_MDF_Activity_Types__c)
&& customMetadata.Core_MDF_Days_Difference__c > oldDaysDifference)

system.debug('abc10'+oldPfr.Core_MDF_Fund_Request_Status__c+'abc10b'+oldPfr.RecordTypeId+'abc10c'+customMetadata.Core_MDF_PFR_RecordType_Id__c
+'abc10d'+customMetadata.Core_MDF_Activity_Category__c+'abc10e'+oldPfr.Core_MDF_ActivityCategory__c
+'abc10f'+customMetadata.Core_MDF_Activity_Types__c+'abc10g'+oldPfr.Core_MDF_Activity_Types__c
+'abc10h'+customMetadata.Core_MDF_Days_Difference__c+'abc10i'+oldDaysDifference
+'abc10j'+oldPfr.Id);

{
if(oldPfr.RequestedAmount >= (Double.valueof(customMetadata.Core_MDF_Requested_Amount__c))){
system.debug('abc11'+oldPfr.RequestedAmount+'abc11b'+(Double.valueof(customMetadata.Core_MDF_Requested_Amount__c)));
if(oldPfr.RecordType.DeveloperName != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_SPCF')){
system.debug('abc12'+oldPfr.RecordTypeId+'abc12b'+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_RecordType_Id'));
oldPfr.addError(Label.Core_MDF_Activity_Event_60_Days);  
}   
oldPfr.addError(Label.Core_MDF_Activity_Event_22_Days);
}
else if(oldPfr.RequestedAmount < (Double.valueof(customMetadata.Core_MDF_Requested_Amount__c))){
system.debug('abc13');
pfr.addError(Label.Core_MDF_Activity_Event_30_Days);
}
}
}

}    */

/*****************************************************************************************************

public static void processPFRRecords(List<PartnerFundRequest> pfrList, List<PartnerFundRequest> oldpfrList)
{
    Map<string,Integer> metadtMap = new Map<string,Integer>();
    Map<Id,string> ccpRecordTypeIds = new Map<Id,string>();
    Date endDate = null;
    
    metadtMap = getMetaDataValues();
    ccpRecordTypeIds = getCCPRTNames(metadtMap);
    
    Boolean hasCustomPermission = FeatureManagement.checkPermission(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Custom_Permission_IAM'));
    List<Core_MDF_PFR_Event_Rule__mdt> metadataList = [SELECT Id, 
                                                       Core_MDF_PFR_RecordType__c, Core_MDF_Activity_Category__c, 
                                                       Core_MDF_Requested_Amount__c, Core_MDF_Activity_Types__c, Operator__c, 
                                                       Core_MDF_Days_Difference__c, Core_MDF_PFR_RecordType_Id__c FROM Core_MDF_PFR_Event_Rule__mdt];
    
            Map<Id, Date> oldPfrMap = new Map<Id, Date>();
            if(oldpfrList != NULL && oldpfrList.size() > 0){
                for(PartnerFundRequest oldPfr : oldpfrList){
                    oldPfrMap.put(oldPfr.Id, oldPfr.Core_MDF_Start_Date__c);
                    
                }
            }
    
    if(pfrList != NULL && pfrList.size() > 0){
    for(PartnerFundRequest pfr: pfrList)
    {
        if(!hasCustomPermission){
            
                    Date startDate = pfr.Core_MDF_Start_Date__c;
                    Date todayDate = system.today();
                    Integer daysDifference = todayDate.daysBetween(startDate);
                    Boolean errorthrown = false;
                    if(oldPfrMap.get(pfr.Id) != pfr.Core_MDF_Start_Date__c && oldPfrMap.size() > 0 || pfr.Id == NULL){
                        
                        for(Core_MDF_PFR_Event_Rule__mdt customMetadata : metadataList){
                            
                            if(customMetadata.Core_MDF_PFR_RecordType_Id__c == pfr.RecordTypeId 
                               && customMetadata.Core_MDF_Activity_Category__c == pfr.Core_MDF_ActivityCategory__c
                               && customMetadata.Core_MDF_Activity_Types__c.contains(pfr.Core_MDF_Activity_Types__c)    
                               && pfr.Id == NULL 
                               && !(pfr.Core_MDF_Fund_Request_Status__c.Contains(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PFR_Status')))) {
                                   
                                   if(Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_30_Days_Less_Than_50K')) > daysDifference
                                      && (Double.valueof(customMetadata.Core_MDF_Requested_Amount__c)) > pfr.RequestedAmount){
                                          pfr.addError(Label.Core_MDF_Activity_Event_30_Days);
                                          errorthrown = true;
                                      }
                                   
                                   else if(customMetadata.Core_MDF_Days_Difference__c > daysDifference 
                                           && pfr.RequestedAmount >= (Double.valueof(customMetadata.Core_MDF_Requested_Amount__c))){
                                               if(pfr.RecordTypeId != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_RecordType_Id')){
                                                   pfr.addError(Label.Core_MDF_Activity_Event_60_Days);  
                                                   errorthrown = true;
                                               }
                                               else{
                                                   pfr.addError(Label.Core_MDF_Activity_Event_22_Days);
                                                   errorthrown = true;
                                               }
                                               
                                           }
                                   if(errorthrown){
                                       break; 
                                   }
                               }
                        }
                    }
        }
        
        endDate = pfr.Core_MDF_End_Date__c;
        string progName = ccpRecordTypeIds.get(pfr.recordTypeId);
        if (metadtMap.containsKey(progName))
        {
            Integer actCloseDays  = (Integer)metadtMap.get(progName);
            pfr.Core_MDF_ToBeClosedDate__c = endDate.addDays(actCloseDays);
        }
        endDate = null;
    }
    
}
}*/

}