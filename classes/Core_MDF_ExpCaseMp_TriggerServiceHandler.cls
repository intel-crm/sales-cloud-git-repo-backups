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
    

}