/*********************************************8
* Name : Core_AAQC_Case_Close_Onemail 
* Author : Nikhil Godhani
* Date Created : 31-October-2018
* Description : This is being used for Close the case through Email templates
* Version Updates : 
*   
* Date          By                      User-Story              Details 
* 25-10-18      Nikhil                  US90414                 created 
************************************************/

public class Core_AAQC_Case_Close_Onemail {
    
    public id caseId;
    public case objCase{get;set;}
    public List<Core_AAQC_Commissions_Case__c> objComInquiry{get;set;}
    public string resolutionComment{get;set;}
    
    
    public Core_AAQC_Case_Close_OnEmail(ApexPages.StandardController controller) {
        caseId = ApexPages.currentPage().getParameters().get('Caseid');
        system.debug('==caseId=='+caseId);
        getRecords();
    }
    
    /*  Method Name : getRecords()
    *   Input Parameters: None
    *   Output Parameters: None  
    *   Author : Nikhil Godhani
    *   Date Created : 13-11-18
    *   Description : This method will load Case details as well as latest case Comment Detail
    */
    
    public PageReference getRecords(){
        
        if(caseId != null){
            objCase =[select id,Core_AAQC_Resolution_Type__c,CaseNumber,Status from case where id =:caseId];
        }
        
        if(objCase != null){
            objComInquiry = [select id,name,Core_AAQC_Resolution_Comments__c,(select id,Name,Core_AAQC_Comment__c from Commissions_Case_Comments__r order by LastModifiedDate DESC) 
                                    from Core_AAQC_Commissions_Case__c where Core_AAQC_Case__c =:objCase.Id];
        }
        
        if(objComInquiry != null && objComInquiry.size() > 0  && objComInquiry[0].Commissions_Case_Comments__r != null &&
                    (objComInquiry[0].Commissions_Case_Comments__r).size()>0){
           resolutionComment = objComInquiry[0].Commissions_Case_Comments__r[0].Core_AAQC_Comment__c; 
        }
        else{
            resolutionComment ='';
        }
        return null;
    }
    
    /*  Method Name : redirectYes()
    *   Input Parameters: None
    *   Output Parameters: None  
    *   Author : Nikhil Godhani
    *   Date Created : 13-11-18
    *   Description : This method will redirect user to case inquiry details page and update case statue to 'Closed'
    */
    
    public PageReference redirectYes()
    {
    
        if(objComInquiry != null && objComInquiry.size() > 0 && objCase != null  && Schema.sObjectType.case.isUpdateable() 
                            && Schema.sObjectType.case.isCreateable()){
                
                objCase.Status ='Closed';
                update objCase;
                PageReference saveRedirect  = new PageReference('/apex/Core_AAQC_Commissions_Inquiry_Details?id='+objComInquiry[0].Id);
                saveRedirect.getParameters().put('message', 'ClosedYes');
                saveRedirect.getParameters().put('referer', 'CaseCloseOnEmail');
                saveRedirect.setRedirect(true);
                return saveRedirect;        
        }
        return null;
        
    }
    
    /*  Method Name : redirectNo()
    *   Input Parameters: None
    *   Output Parameters: None  
    *   Author : Nikhil Godhani
    *   Date Created : 13-11-18
    *   Description : This method will redirect user to case inquiry details page
    */
    
    public PageReference redirectNo()
    {
        if(objComInquiry != null && objComInquiry.size() > 0 && Schema.sObjectType.case.isUpdateable() 
                            && Schema.sObjectType.case.isCreateable()){
                                
                               
                if(objComInquiry != null && objComInquiry.size() > 0){
                    Core_AAQC_Case_Comments__c newCommissioComment = new Core_AAQC_Case_Comments__c();                
                    newCommissioComment.Core_AAQC_Comment__c = LABEL.Core_AAQC_Resolution_Denied;
                    newCommissioComment.Core_AAQC_Commissions_Case__c = objComInquiry[0].Id;
                    INSERT newCommissioComment;
                }
                
                PageReference saveRedirect  = new PageReference('/apex/Core_AAQC_Commissions_Inquiry_Details?id='+objComInquiry[0].Id);
                saveRedirect.getParameters().put('message', 'ClosedNo');
                saveRedirect.getParameters().put('referer', 'CaseCloseOnEmail');
                saveRedirect.setRedirect(true);
                return saveRedirect;
        }
        return null;
    }

}