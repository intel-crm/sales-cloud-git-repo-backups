/****************************************************************************************************************************************
* Class Name        : Core_MDF_InactivateIUPGM
* Created Date      : 08-27-2019
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - VK       08-27-2019         Batch class to inactivate IUPGM records when user is deactivated
*****************************************************************************************************************************************/
global class Core_MDF_InactivateIUPGM implements Database.Batchable<sObject>, Database.Stateful {
    
    /***************************************************************************************************** 
    Method Name :   start
    @return     :   List of Internal Users Partner Geo Mapping records
    @parameters :   Database.BatchableContext
    Description :   It fetches all IUPGM records where user is inactive but the record is active
    Added By    :   Accenture - VK - 08-27-2019 
    Modified By :                               Date:                   Changes:
    ******************************************************************************************************/  
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        try{
            String strQuery = '';
            strQuery = 'SELECT Id, Core_MDF_Active_Ind__c, Core_MDF_is_User_Active_ind__c FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c WHERE Core_MDF_Active_Ind__c = TRUE AND Core_MDF_is_User_Active_ind__c = FALSE LIMIT 50000';
            return Database.getQueryLocator(strQuery);
        }catch(Exception e){Core_MDF_CCP_UtilityClass.getErrorDetails(e);return NULL;
        }
    }

    /******************************************************************************************************** 
    Method Name :   execute
    @return     :   void
    @parameters :   Database.BatchableContext
    Description :   Inactivates the IUPGM record
    Added By    :   Accenture - VK - 08-27-2019
    Modified By :                               Date:11/30/2018         Changes:None  
    **********************************************************************************************************/     
    global void execute(Database.BatchableContext bc, List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> scope){
        
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> updateIUPGMList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        try{
            if(scope.size() > 0)
            {
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : scope){
                    iupgm.Core_MDF_Active_Ind__c = FALSE;
                    updateIUPGMList.add(iupgm);
                }
            }
            if(updateIUPGMList.size() > 0)
            {
                Database.update(updateIUPGMList);}}catch(Exception e){Core_MDF_CCP_UtilityClass.getErrorDetails(e);}
    }

    /***************************************************************************************************** 
    Method Name :   finish
    @return     :   void
    @parameters :   Database.BatchableContext
    Description :   
    Added By    :   Accenture - VK - 08-27-2918
    Modified By :                               Date:                     Changes:None                         
    ******************************************************************************************************/
    global void finish(Database.BatchableContext bc)
    {
        
    }   
}