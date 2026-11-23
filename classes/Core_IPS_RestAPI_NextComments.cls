@RestResource(urlMapping='/nextcomments/*')
global class Core_IPS_RestAPI_NextComments {
    
    @HttpPost
    global static void caseComments() {
        List<Core_IPS_Case_Comments__c> commentList = new List<Core_IPS_Case_Comments__c>();
        
        RestRequest request = RestContext.request;
        try{
           String recordId = request.requestURI.substring(request.requestURI.lastIndexof('/')+1);
           Core_Log_Entry__c le = [SELECT Id,Core_Details__c FROM Core_Log_Entry__c WHERE Id=:recordId LIMIT 1];
           Core_IPS_Comment_Handler handler = new Core_IPS_Comment_Handler();
           handler.getCaseComments(le.Core_Details__c);
           //return response;
        }
        catch(Exception e){
            system.debug('error in post');
        }
         
    }

  
}