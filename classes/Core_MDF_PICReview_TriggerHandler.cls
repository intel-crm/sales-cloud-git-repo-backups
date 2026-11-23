/****************************************************************************************************************************************
* Trigger Name      : Core_MDF_PICReview_TriggerHandler 
* Version           : 1.0 
* Created Date      : 01-16-2022
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - BD       01-16-2022        Trigger Handler class.
*****************************************************************************************************************************************/
public class Core_MDF_PICReview_TriggerHandler extends TriggerHandler{
    
    public override void afterInsert()
    {
         if(isActive('Core_MDF_UpdateClaimOnAfterInsert'))
         {
        	Core_MDF_PICReviewHelper.claimUpdateOperations(Trigger.NEW);
         }
    }

}