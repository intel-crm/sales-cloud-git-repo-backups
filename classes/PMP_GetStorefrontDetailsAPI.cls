@RestResource(urlMapping='/v1.0/storefrontDetails')
global without sharing class PMP_GetStorefrontDetailsAPI {
	
    global class ResponseWrapper {
        public Boolean success;
        public List<Id> ids;
        public String message;
    }
    
    @HttpGet
    global static ResponseWrapper getStorefrontRecords(){
    	 ResponseWrapper res = new ResponseWrapper();
        
         try {
            List<PMP_Company__c> companyLst = [select id from PMP_Company__c where PMP_Company_Lifecycle_Status_Nm__c = 'Published' and PMP_Benefit_Update_Ind__c = false];
            
            res.ids = new List<Id>();
            for (PMP_Company__c cmp : companyLst) {
                res.ids.add(cmp.Id);
            }
            
            res.success = true;
            res.message = 'Fetched successfully';
            
        } catch (Exception e) {
            res.success = false;
            res.message = e.getMessage();
        }
        
        return res;
    }    
}