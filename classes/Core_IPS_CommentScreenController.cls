/***************************************************************************************************
    Version     : 1.0 
    Modified Date: 11 NOV 2017
    Function    : This method adds  
    Input Parameters: List<User>
    Output Parameters: None
    Transactions: 
    Description: THis controller is responsible for Displaying case comment in recent section of theCase detail page.
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sumukh                        11/08/2017              MODIFIED as part of - US67444,US67633,US83446
    ****************************************************************************************************/ 
   
public with sharing class Core_IPS_CommentScreenController{
    
    public Static Case newcase = new Case();
    public Static List<Core_IPS_Case_Comments__c> commentRecords;
    public Static Integer CommentsLimit{get;set;}{CommentsLimit = Integer.valueof(system.label.Core_IPS_CaseComments_Limit);}  
    public string contentType{get;set;}
   // public String LogUserCon{get;set;}
    
    public Map<Id,User> UserMap{get;set;} //Added By Manoj

    Public boolean externalUser{get;set;}    
    public Boolean userHasAccess{get;set;}
    public static string PRIVATE_TO_AGENTS{get;set;}{PRIVATE_TO_AGENTS= Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c;}
    public static string PUBLIC_TO_CUSTOMERS{get;set;}{PUBLIC_TO_CUSTOMERS=Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;}
    public static string PRIVATE_TO_INTEL{get;set;}{PRIVATE_TO_INTEL=Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;}
    
    public Core_IPS_CommentScreenController(ApexPages.StandardController controller) {        
        newCase=(Case)controller.getRecord();
        
        externalUser=Network.getNetworkId() != null? true:false; // added by venki for identifying customer user 2/8/17

        userHasAccess = Label.Core_IPS_Agent_Profiles.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));
        getcaseComments();       
        
    }     
    public List<Core_IPS_Case_Comments__c> getcaseComments(){
    try{
            if(!externalUser){
                commentRecords = [select id,name,CreatedBy.contactid,CreatedBy.Accountid,CreatedBy.Account.Name,CreatedBy.Name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,createdbyId,CreatedBy.Profileid,CreatedBy.FirstName,
                        CreatedBy_FirstName__c,CreatedBy_Name__c,CreatedDate,Core_IPS_BgColor__c,Core_IPS_Comment_Author_Type__c,Core_IPS_NickName__c,Core_IPS_Migrated_Note_Type__c,CreatedBy.Email,Core_IPS_Case_Comment_Type__c 
                        from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id ORDER BY CreatedDate DESC NULLS LAST Limit :CommentsLimit];      
            }
            else{
                commentRecords = [select id,CreatedBy_Name__c, CreatedBy.Name,name,Core_IPS_Comment__c,CreatedBy.Accountid,CreatedBy.Account.Name,Core_IPS_Rich_Comment__c,createdbyId,CreatedBy.ContactId,CreatedBy.Profileid,CreatedBy.FirstName,
                        CreatedDate,CreatedBy_FirstName__c,Core_IPS_Comment_Author_Type__c,Core_IPS_BgColor__c,Core_IPS_Migrated_Note_Type__c,Core_IPS_NickName__c,CreatedBy.Email,CreatedBy.Contact.Account.Name,Core_IPS_Case_Comment_Type__c
                        from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id and Core_IPS_Case_Comment_Type__c=:PUBLIC_TO_CUSTOMERS ORDER BY CreatedDate DESC NULLS LAST Limit :CommentsLimit];     //  Added By Prem CreatedBy.Name external user to this query  
            }
            return commentRecords;
        }
        catch(exception ex){ 
        Core_IPS_ExceptionHandling.logEntryWithException(ex,'Core_IPS_CommentScreenController.getcaseComments','Case');
        return null;
        }
   }   
       
}