/****************************************************************************************************************************************
* Class Name      : Core_MDF_PICReviewResult_TriggerHandler 
* Version           : 1.0 
* Created Date      : 12-21-2021
* Modification Log  : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - BD       12-21-2021        Trigger Handler class.
*****************************************************************************************************************************************/
public class Core_MDF_PICReviewResult_TriggerHandler extends TriggerHandler {
    
    public override void afterInsert(){
        
        Core_MDF_PICReviewResultHelper.claimStatusChangeOnInsert(Trigger.NEW);
            
        
    }

}