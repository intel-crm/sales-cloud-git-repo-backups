/****************************************************************************************************************************************
* Class Name        : Core_MDF_ExpCaseMp_TriggerServiceHandler
* Created Date      : 24-06-2019
* Modification Log
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Accenture NZ       24-06-2019          Exception Case Mapping Trigger Service Handler which handles  
*****************************************************************************************************************************************/ 
public with sharing class Core_MDF_ExpCaseMp_TriggerServiceHandler {
    
    /****************************************************************************************************************************************
    * Method Name           : ecmStatusOnDelete
    * Created Date          : 19-06-2019
    * Modification Log
    * Developer            Date             Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    Accenture NZ        19-06-2019          Exception Trigger Service Handler which will not let a record to be deleted if case status is closed      
    *****************************************************************************************************************************************/
    public static void ecmStatusOnDelete(Map <Id , Core_MDF_Exception_Case_Mapping__c> oldExceptionMap){
        List<String> closedStatusList = (Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Closed_Case_Status')).split(';');//'Closed'
        for(Core_MDF_Exception_Case_Mapping__c expt : oldExceptionMap.values()){
            if(closedStatusList.contains(expt.Core_MDF_Case_Standard_Status_nm__c)){
                expt.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ECM_OnDelete_Error'));
            }
        }
    }
    
    /****************************************************************************************************************************************
    * Method Name           : shareECMRecordWithusers
    * Created Date          : 12-09-2019
    * Modification Log
    * Developer            Date             Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    Accenture SN        12-09-2019      This method will share the ECM records with internal users.      
    *****************************************************************************************************************************************
    public static void shareECMRecordWithusers(Map <Id , Core_MDF_Exception_Case_Mapping__c> ecmIdMap){
        Map<Id,List<Id>> exceptionIdECMIdListMap = new Map<Id,List<Id>>();
        List<Core_MDF_Exception_Case_Mapping__Share> ecmShareList = new List<Core_MDF_Exception_Case_Mapping__Share>();
        try{
            //Fetch all the exceptions
            for(Core_MDF_Exception_Case_Mapping__c ecm : ecmIdMap.values()){
                if(exceptionIdECMIdListMap.containsKey(ecm.Core_MDF_Exception_id__c)){
                    exceptionIdECMIdListMap.get(ecm.Core_MDF_Exception_id__c).add(ecm.Id);
                }
                else{
                    exceptionIdECMIdListMap.put(ecm.Core_MDF_Exception_id__c, new List<Id>{(ecm.Id)});
                }
            }
            //Form all the Exception Share records
            for(Core_MDF_Exception__Share exceptionShareRecord : [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause
                                                                  FROM Core_MDF_Exception__Share
                                                                  WHERE ParentId IN :exceptionIdECMIdListMap.keySet() AND
                                                                        RowCause = 'Manual']){
                String strGroupId = exceptionShareRecord.UserOrGroupId;
                if(strGroupId.startsWithIgnoreCase('00G')){
                    for(Id ecmRecordId : exceptionIdECMIdListMap.get(exceptionShareRecord.ParentId)){
                        ecmShareList.add(createECMShare(ecmRecordId, exceptionShareRecord.UserOrGroupId));
                    } 
                }               
            }
            //Insert all Exception Share records
            if(ecmShareList != NULL && ecmShareList.size() > 0){
                insert ecmShareList;
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
    
    ****************************************************************************************************************************************
    * Method Name           : createECMShare
    * Created Date          : 12-09-2019
    * Modification Log
    * Developer              Date               Description
    * ---------------------------------------------------------------------------------------------------------------------------------------
    Accenture SN         12-09-2019         ECM Share creations          
    *****************************************************************************************************************************************
    public static Core_MDF_Exception_Case_Mapping__Share createECMShare(String ecmId, String ugId){
        Core_MDF_Exception_Case_Mapping__Share ecmShare = new Core_MDF_Exception_Case_Mapping__Share();
        ecmShare.ParentId = ecmId;
        ecmShare.RowCause = 'Manual';
        ecmShare.AccessLevel = 'Read';
        ecmShare.UserOrGroupId = ugId;
        return ecmShare;
    }*/
}