/****************************************************************************************************************************************
* Class Name  : Core_MDF_ContentVersionTriggerHandler 
* Version     : 1.0 
* Created Date: 29-JAN-2021
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - TS    29-JAN-2021       Trigger Handler Class for upload content version file
*****************************************************************************************************************************************/
public class Core_MDF_ContentVersionTriggerHandler extends TriggerHandler {
	//Description : Using AfterInsert event as FileType & FileExtension of ContentVersion are coming as null in beforeInsert.
    public override void afterInsert() {
     //Metadata function switch - isActive
     if (isActive('Core_MDF_ValidateFileVersionAfterInsert')){
        //Invoke function to restrict file upload on content version manually 
    	Core_MDF_ContentVersionServiceHandler.validateVATFileSizeAndExtension(Trigger.New);
     }
        
    }
}