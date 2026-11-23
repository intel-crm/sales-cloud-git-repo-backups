/****************************************************************************************************************************************
* Class Name        : Core_MDF_CloseActivity_AmtUpdateBatch
* Test Class Name   :
* Created Date      : 4/21/2022
* Modification Log
* Created By        : Hemapriyadharshini.k
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture- Weezer         4/22/2022         Batch class to close activities based on end date
*****************************************************************************************************************************************/
global class Core_MDF_CloseActivity_AmtUpdateBatch implements Database.Batchable<sObject>,Database.Stateful {
    public String pfrActivityClosureAuto;
    Public string pfrAutoClosureType;
    public String pfrActivityClose;
    public Date pfrEndDate;
    Public List<Database.SaveResult> pfrListAfterSave = new List<Database.SaveResult>();
    Map<Id,PartnerFundRequest> pfrMap = new Map<Id,PartnerFundRequest>();
    public List<String> pfrListIDs = new List<String>();
  
 global Database.QueryLocator start(Database.BatchableContext bc)
    {
        pfrEndDate = system.today();
        pfrActivityClose = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_ClosedStatus');
        pfrAutoClosureType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_ActvityClosureType').split(';')[1];
  
        String pfrActivity = 'SELECT Id,Core_MDF_Budget_Type_nm__c,Core_MDF_Program__c,Core_MDF_Fund_Request_Status__c'+
                             ' FROM PartnerFundRequest'+
                             ' WHERE Core_MDF_ToBeClosedDate__c <:pfrEndDate AND Core_MDF_Fund_Request_Status__c !=:pfrActivityClose'; 
        
        system.debug('databaseQuery'+Database.getQueryLocator(pfrActivity));
        return Database.getQueryLocator(pfrActivity);
    }
    
 global void execute(Database.BatchableContext bc, List<PartnerFundRequest> pfrActivity)
    {
        system.debug('pfrActivity'+pfrActivity);
        try{
            if(pfrActivity != null && !pfrActivity.isEmpty())
            {
                for(PartnerFundRequest pfrList : pfrActivity)
                {
                    pfrMap.put(pfrList.Id, pfrList);
                }
                system.debug('pfrMap>>>>>'+pfrMap);
               pfrListAfterSave.addAll(Core_MDF_CloseActivity.closeActivityAmountCalculation(pfrMap,pfrAutoClosureType)); 
               system.debug('pfrUpdatedListSize'+pfrListAfterSave);
            } 
           
        }
        catch (Exception e)
        {
            Core_MDF_CCP_UtilityClass.logError(e);throw e;
        }                  
        
    }
 global void finish(Database.BatchableContext bc)
    {
            system.debug('Success');
            // Iterating saveResult record Ids
            if(pfrListAfterSave !=null && !pfrListAfterSave.isEmpty())
            {
                for(Database.SaveResult pfrSaveResult : pfrListAfterSave)
                {
                    if(pfrSaveResult.isSuccess() == True)
                    {
                        pfrListIDs.add(pfrSaveResult.getId());
                    }      
                }
            }
            system.debug('pfrIDs'+pfrListIDs);
            Core_MDF_CloseActivity_Notification.autoClosureNotification(pfrListIDs);
    }
}