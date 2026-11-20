/******************************************************************************************************
* Class Name  : Core_MDF_EmailTemplateTranslation 
* Version     : 1.0 
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture SS      12/10/2018          Added with sharing 
Aura enabled class calling from Create claim lightning component.
*******************************************************************************************************/

public without sharing class Core_MDF_EmailTemplateTranslation {
    //ActivityId is set in the Apex component Core_MDF_EmailTemplateDataComponent
    public static Id activityId {get;set;}  
    
    /***************************************************************************************************** 
    Method Name :   getActivityType
    @return     :   String
    @parameters :   None
    Description :   US209183: MVP 1 Carry forward
    Added By    :   Accenture - AS 
    Modified By :                      Date:11/02/2018                     Changes:None                               
    ******************************************************************************************************/
    public static String getActivityType(){
        if(activityId != NULL){
            List<PartnerFundRequest> actTypeList = [SELECT toLabel(Core_MDF_Activity_Types__c) from PartnerFundRequest
                                                    where Id =: activityId];
            return(actTypeList[0].Core_MDF_Activity_Types__c);
        }
        else
            return('');
    }
    
    /***************************************************************************************************** 
    Method Name :   getActivityRecordTypeName
    @return     :   String
    @parameters :   None
    Description :   US209183: MVP 1 Carry forward
    Added By    :   Accenture - AS 
    Modified By :                      Date:11/02/2018                     Changes:None                               
    ******************************************************************************************************/

    public static String getActivityRecordTypeName(){
        if(activityId != NULL){
            List<PartnerFundRequest> actRecordTypeList = [SELECT toLabel(RecordType.Name) from PartnerFundRequest
                                                          where Id =: activityId];
            return(actRecordTypeList[0].RecordType.Name);
        }
        else
            return('');
    }
    
    /***************************************************************************************************** 
    Method Name :   getActivityPriorStatus
    @return     :   String
    @parameters :   None
    Description :   US209183: MVP 1 Carry forward
    Added By    :   Accenture - AS 
    Modified By :                      Date:11/02/2018                     Changes:None                               
    ******************************************************************************************************/

    public static String getActivityPriorStatus(){
        if(activityId != NULL){
            List<PartnerFundRequest> actPriorStatusList = [SELECT toLabel(Core_MDF_PriorValueStatusForExternalUser__c)  from PartnerFundRequest
                                                           where Id =: activityId];
            System.debug('Priorstatus->> '+actPriorStatusList[0].Core_MDF_PriorValueStatusForExternalUser__c);
            return(actPriorStatusList[0].Core_MDF_PriorValueStatusForExternalUser__c );
        }
        else
            return('');
    }
    
    /***************************************************************************************************** 
    Method Name :   getActivityStatus
    @return     :   String
    @parameters :   None
    Description :   US209183: MVP 1 Carry forward
    Added By    :   Accenture - AS 
    Modified By :                      Date:11/02/2018                     Changes:None                               
    ******************************************************************************************************/

    public static String getActivityStatus(){
        if(activityId != NULL){
            List<PartnerFundRequest> actStatusList = [SELECT toLabel(Core_MDF_Fund_Request_Status__c) from PartnerFundRequest
                                                      where Id =: activityId];
            return(actStatusList[0].Core_MDF_Fund_Request_Status__c);
        }
        else
            return('');
    }
}