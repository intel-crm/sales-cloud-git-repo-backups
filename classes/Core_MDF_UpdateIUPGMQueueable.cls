/****************************************************************************************************************************************
* Class Name        : Core_MDF_UpdateIUPGMQueueable
* Created Date      : 04-04-2023
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - BD       04-04-2023         Queueable class to inactivate IUPGM records when user is deactivated
*****************************************************************************************************************************************/
public class Core_MDF_UpdateIUPGMQueueable implements Queueable{
    List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmToBeDeactivated = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
    
    public Core_MDF_UpdateIUPGMQueueable(List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmList)
    {
        if(iupgmList != NULL && iupgmList.Size() > 0){
            iupgmToBeDeactivated = iupgmList;
        }
    }
    
    public void execute(QueueableContext context){ 
        
        if(iupgmToBeDeactivated != NULL && iupgmToBeDeactivated.Size() > 0){
        Database.update(iupgmToBeDeactivated);
        }
        
    }

}