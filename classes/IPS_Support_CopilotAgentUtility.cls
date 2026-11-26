@RestResource(urlMapping='/support/v1.0/cases/*')
global class IPS_Support_CopilotAgentUtility {
    
    @HttpGet
    global static IPS_Support_CopilotHandler.ResponseWrapper getCasesForUser()
    {
        try{
            RestRequest req = RestContext.request;
            String actionType = req.requestURI.substring(req.requestURI.lastIndexOf('cases/') + 1);
            if(actionType !=null && actionType == 'getCases'){
                IPS_Support_CopilotHandler getCasesForUserHandler = new IPS_Support_CopilotHandler();
                return  getCasesForUserHandler.getCasesForUser(req); 
            } 
        } catch (Exception e){
            System.debug(e.getMessage());
        }
        return null;       
        
    }  
    
    @HttpPost
    global static IPS_Support_CopilotHandler.ResponseWrapper caseCreate()
    {
        try{
            RestRequest req = RestContext.request;
            String actionType = req.requestURI.substring(req.requestURI.lastIndexOf('cases/') + 1);
            if(actionType !=null && actionType == 'createCase'){
                IPS_Support_CopilotHandler createCaseFromCopilot = new IPS_Support_CopilotHandler();
                return  createCaseFromCopilot.createCaseFromCopilot(req);
            } 
        } catch (Exception e){
            System.debug(e.getMessage());
        }
        return null;       
        
    } 
    
}