/****************************************************************************************************************************************
* Class Name        : Core_MDF_DetermineRecipientsWithGroup
* Created Date      : 
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture -               Class to identify the email recipients 
*****************************************************************************************************************************************/
public without sharing class Core_MDF_DetermineRecipientsWithGroup {
	/***************************************************************************************************** 
    Class Name    :        InputsWithGroupIdList
    Description   :        contains all the invocable variables
    Added By      :        Accenture - 
    Modified By   :        Date:       Changes: 
    ******************************************************************************************************/
	public class InputsWithGroupList{
		
        @InvocableVariable(label = 'recordId' required = true)
        public Id recordId;
        
        @InvocableVariable(label = 'permissionSet')
        public String permissionSetName;
        
        @InvocableVariable(label = 'templateDeveloperName' required = true)
        public String templateName;
		
		@InvocableVariable(label = 'groupRecords')
        public List<Core_MDF_Partner_Group_Mapping__c> pgmRecords;
        
        @InvocableVariable(label = 'Recipients')
        public string recipients; 
        
        @InvocableVariable(label = 'sendDiff')
        public Boolean sendDiff = TRUE;
	}
    /***************************************************************************************************** 
    Method Name   :        determineRecipients
    @return       :        void
    @parameters   :        List of InputsWithGroupIdList defined
    Description   :        Analyse the input parameters and update the group id string with semicolon
    Added By      :        Accenture 
    Modified By   :        Date:           Changes: 
    ******************************************************************************************************/
	@InvocableMethod
    public static void determineRecipients(List<InputsWithGroupList> processInput){
        //List to Prepare the input variables for Core_MDF_DetermineEmailRecipients Class
        List<Core_MDF_DetermineEmailRecipients.InitialInputs> initialInputList = new List<Core_MDF_DetermineEmailRecipients.InitialInputs>();
        
		for(InputsWithGroupList inputs : processInput){
            Set<String> setOfGroupId = new Set<String>();
            String groupIdWithSemiColon;
            List<String> lstOfGroupId = new List<String>();

			for(Core_MDF_Partner_Group_Mapping__c pgm : inputs.pgmRecords){
				if(pgm.Core_MDF_Group_Id__c!=null){
					setOfGroupId.add(pgm.Core_MDF_Group_Id__c);
				}
                if(pgm.Core_MDF_All_Access_Group_Id__c!=null){
					setOfGroupId.add(pgm.Core_MDF_All_Access_Group_Id__c);
				}
			}
			if(setOfGroupId!=null && setOfGroupId.size()>0){
				lstOfGroupId.addAll(setOfGroupId);
				groupIdWithSemiColon = String.join(lstOfGroupId,';');//join can be used on a set directly -> String.join(setOfGroupId,';')
			}
            System.debug('**groupId**'+groupIdWithSemiColon);
			
            Core_MDF_DetermineEmailRecipients.InitialInputs initialInput = new Core_MDF_DetermineEmailRecipients.InitialInputs();
            
            initialInput.groupId = groupIdWithSemiColon!=null?groupIdWithSemiColon:null;
            initialInput.recordId = inputs.recordId;
            initialInput.templateName = inputs.templateName;
            initialInput.permissionSetName = inputs.permissionSetName;
            initialInput.recipients = inputs.recipients;
            initialInput.sendDiff = inputs.sendDiff;
            initialInputList.add(initialInput);
            system.debug('initialInputList@@@' + initialInputList);
		}
		if(initialInputList!=null && initialInputList.size()>0){
            //calling the generic Email class to send the notifications
			Core_MDF_DetermineEmailRecipients.determineRecipients(initialInputList);
		}
	}
    
}