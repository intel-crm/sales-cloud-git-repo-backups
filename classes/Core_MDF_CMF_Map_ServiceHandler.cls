public class Core_MDF_CMF_Map_ServiceHandler {

/****************************************************************************************************************************************
Method Name:                                             updateUniqueKey
@return  :                                               --
@parameters:                                             List of new CMF Map,oldMap CMF Map
Description:                                            
Added By:                                                
Modified By:                  Date:                      Changes: 
Accenture –                   Created.
*****************************************************************************************************************************************/ 

public static void updateUniqueKey(List<Core_MDF_Comarketing_CMF_Map__c> newCMFList, Map<id,Core_MDF_Comarketing_CMF_Map__c> oldCMFList){
        try{
            
            //to update AccountProgramid in PGM for external type of access
            for(Core_MDF_Comarketing_CMF_Map__c cmfRecord : newCMFList){
                    if((oldCMFList==null)||((oldCMFList.get(cmfRecord.id) != NULL) && (cmfRecord.Core_MDF_Account_Id__c != oldCMFList.get(cmfRecord.id).Core_MDF_Account_Id__c))){
                        cmfRecord.Core_MDF_AccountIdKey_txt__c = (String)cmfRecord.Core_MDF_Account_Id__c;                        
                    }
                }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }

}