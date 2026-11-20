/**************************************************************************************
* Apex Class Name   : Core_SSR_Update_Rest 
* Created Date      : July 27th, 2017
* Description       : DRD system makes a REST Call to SMG system
*					  Below Webservice is executed to Update
*					  Status, CaseOwner in Core_Sales_Support_Request__C 
* Modification Log  :
* Developer           Date               Description
* ----------------------------------------------------------------------------    
* Rangesh Kona	  : Version 1:  Aug 22nd, 2017  Initial Deployed Version
*************************************************************************************/

@RestResource(urlMapping='/UpdateSSRStatus/*')
global with sharing class Core_SSR_Update_Rest {
    
    /* Update SSR Status REST Service */
    @HttpPost
    global static String updateStatus() {
        
        String SSR_ID;
        String status;
        String returnValue;
        String CaseOwner;
        String jsonInput = RestContext.request.requestBody.toString();
        // JSonParser parser = JSON.createParser(jsonString);
        
         Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        List<Object> drdJsonList = (List<Object>)m.get('ssrobj');
        Map<String, Object> m0 =  (Map<String, Object>) drdJsonList[0];


        		SSR_ID 		= (String) m0.get('SSR_ID');
        		Status 		= (String) m0.get('Status');
        	 	CaseOwner 	= (String) m0.get('CaseOwner');
        
        try {    
            // update Core_Sales_Support_Request__C with DRD Case Status and DRD Case Owner 
            Core_Sales_Support_Request__C SSR_Obj =  [select Id,Status__c,Core_DRD_Case_Owner__c from Core_Sales_Support_Request__C where core_external_id__C  = :SSR_ID];
            
            SSR_Obj.Status__c = Status;
            SSR_Obj.Core_DRD_Case_Owner__c = CaseOwner;
            update SSR_Obj;
            
            // DRD system excepts what's the stored value to cross verify whether update thru fine or not            
            Core_Sales_Support_Request__C SSR_Obj_After_Update =  [select Id,Status__c, Core_DRD_Case_Owner__c from Core_Sales_Support_Request__C where core_external_id__C  = :SSR_ID];
            String Status_After_Update = SSR_Obj_After_Update.Status__C;

            returnValue = Status_After_Update;
        }
        catch(DmlException e) {
            returnValue = e.getMessage();
        }
        return returnValue;
    }
}