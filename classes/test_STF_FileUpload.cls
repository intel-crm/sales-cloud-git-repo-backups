public class test_STF_FileUpload {
    
    @auraEnabled
    public static string prepareUrl(){
        
        //System.debug(caseId +' CaseId');
        string URL = null;
        ID recID = System.currentPageReference().getParameters().get('id');
            URL = 'https://eftlab.intel.com/sftipsupload/index.html?application=IPS_SFT'+ '&caseId=' + '5001J00000gqVwp' + '&visibility=Public_to_Customers';
        return URL;
    }
    
    @AuraEnabled
	public static String returnClassic(Id recId){
    string URL = null;
        //ID recID = System.currentPageReference().getParameters().get('id');
            //URL = 'https://eftlab.intel.com/sftipsupload/index.html?application=IPS_SFT'+ '&caseId=' + '500g000000YZoMfAAL' + '&visibility=Public_to_Customers';
        URL = 'https://eftlab.intel.com/sftipsupload/index.html?application=IPS_SFT'+ '&caseId=' + recId + '&visibility=Public_to_Customers';
        return URL;
}
//https://eftlab.intel.com/sftipsupload/index.html?application=IPS_SFT&caseId=500o000000FLaJeAAL&visibility=Public_to_Customers
	@AuraEnabled
	public static id auditDocumentInsertion(String myString){
    //list<Core_MDF_Audit_Document__c> auditDocList = new list<Core_MDF_Audit_Document__c>();
    	System.debug(myString);
        list<Core_IPS_Case_Attachments__c> attchments = [select id,CreatedBy.name,CreatedDate,Core_File_Description__c, Name from Core_IPS_Case_Attachments__c limit 5];
        
		System.debug(attchments);    
    	Core_MDF_Audit_Document__c auditDoc = new Core_MDF_Audit_Document__c();
        try {
    	
                    auditDoc.Core_MDF_Proof_of_Branding__c = true;
                    auditDoc.Core_MDF_Proof_of_Cost__c = true;
                    auditDoc.Core_MDF_Proof_of_Execution__c = true;  
                    auditDoc.Core_MDF_App_Document_Types_nm__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
                    auditDoc.Core_MDF_Document_Types__c = 'Proof of Cost;Proof of Execution;Proof of Attribution';
        			auditDoc.testSFTFileUploadId__c = myString;
                    //auditDocList.add(auditDoc);
        insert auditDoc;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        return auditDoc.id;
	}
}