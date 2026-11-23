/****************************************************************************************************************************************
* Class Name  : Core_MDF_ConfirmationPopUpController 
* Version     : 1.0 
* Created Date: 06-09-2020
* Modification Log :
* Developer                          Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Bikram Bebarta         06/09/2020               Process specific action as per object after confirmation
*****************************************************************************************************************************************/
public class Core_MDF_ConfirmationPopUpController {
	@AuraEnabled
    public static string processConfirmation(string objectName, id recordId, string action){
        string result = '';
        if(action.equalsIgnoreCase('ReverseAudit')){
            result = Core_MDF_ReverseAuditDecision.processAuditReverse(recordId);
        }
        return result;
    }
}