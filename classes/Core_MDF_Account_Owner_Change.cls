/******************************************************************************************************
* Class Name  : Core_MDF_Account_Owner_Change 
* Version     : 1.0 
* Created Date: 01-04-2022
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - NK      01-04-2022          Class for Account sharing recalculation on owner change
*******************************************************************************************************/
public without sharing class Core_MDF_Account_Owner_Change {
    
/*****************************************************************************************************
Method Name:        fetchPartnerNodeUserMapping
@return  :          void
@parameters:        accountIdsList
Description:        Whenever an account owner is changed,recalculate sharing
Added By:           Accenture - NK  01-04-2022 
******************************************************************************************************/
    @InvocableMethod
    public static void recalculateSharingOnOwnerUpdate(List<Id> accountIdsList) {
        try{           
            if(accountIdsList.size() > 0 ) {
                List<Account> accList = [Select Id,Core_MDF_External_Group_Id__c from  Account where id in: accountIdsList ];
                Map<Id,List<Id>> accIdToGrpIdLstMap = new Map<Id,List<Id>>();
                
                for(account acc : accList){
                    accIdToGrpIdLstMap.put(acc.Id,new List<Id>{acc.Core_MDF_External_Group_Id__c});
                }
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Account',accIdToGrpIdLstMap, 'Edit','Manual','Read');
                List<AccountShare> accountShareList = Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst); 
                
                
            }
        }catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e); 
            throw e;
        }
    }
    
}