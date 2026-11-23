/***********************************************************************************************
    Version     : 1.0 
    Created Date: 14 Feb 2016
    Used in     : Core_IPS_CommentScreen,Core_IPS_CaseComments pages
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Manoj Kumar                06/06/2017              Optmized the Case Comments Logic for Profile checks to reduce Profile level query
                                                         Modified all Profile Variables to compare with Profile Ids instead of Names
    * Sumukh                    03/07/2017              Added visibility for case comments                                                     
    * Ajay                      10/24/2017              Added private to agents functionality
 
    ****************************************************************************************************/  


public class Core_IPS_CommentScreenController_v1{

    public Static Case newcase = new Case();
    public Static List<Core_IPS_Case_Comments__c> commentRecords;
    public Static Integer CommentsLimit = Integer.valueof(system.label.Core_IPS_CaseComments_Limit);   
    public string contentType{get;set;}
    
    public Map<Id,User> UserMap{get;set;} //Added By Manoj

    Public boolean externalUser{get;set;}    
    public Boolean userHasAccess{get;set;}
    public static string PRIVATE_TO_AGENTS{get;set;}{PRIVATE_TO_AGENTS= Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c;}
    public static string PUBLIC_TO_CUSTOMERS{get;set;}{PUBLIC_TO_CUSTOMERS=Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;}
    public static string PRIVATE_TO_INTEL{get;set;}{PRIVATE_TO_INTEL=Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;}
    
    public Core_IPS_CommentScreenController_v1(ApexPages.StandardController controller) {        
        newCase=(Case)controller.getRecord();
        externalUser=Network.getNetworkId() != null? true:false; // added by venki for identifying customer user 2/8/17
        userHasAccess = Label.Agents_Profile_List.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));
        getcaseComments();
    }     

    public List<Core_IPS_Case_Comments__c> getcaseComments(){
    try{
            if(!externalUser){
                commentRecords = [select id,name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,createdbyId,CreatedBy.Profileid,
                        CreatedBy_FirstName__c,CreatedBy_Name__c,CreatedDate,Core_IPS_BgColor__c,Core_IPS_Comment_Author_Type__c,Core_IPS_Note_From_Customer__c,Core_IPS_Note_to_Customer__c,Core_IPS_Notetype__c,Core_IPS_NickName__c,CreatedBy.Email,Core_IPS_Case_Comment_Type__c 
                        from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id ORDER BY CreatedDate DESC NULLS LAST Limit :CommentsLimit];      
            }
            else{
                commentRecords = [select id,name,Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,createdbyId,CreatedBy.Profileid,
                        CreatedDate,CreatedBy_FirstName__c,Core_IPS_Comment_Author_Type__c,CreatedBy_Name__c,Core_IPS_BgColor__c,Core_IPS_Note_From_Customer__c,Core_IPS_Note_to_Customer__c,Core_IPS_Notetype__c,Core_IPS_NickName__c,CreatedBy.Email,Core_IPS_Case_Comment_Type__c 
                        from Core_IPS_Case_Comments__c where Core_IPS_Case__c=:newCase.id and Core_IPS_Case_Comment_Type__c=:PUBLIC_TO_CUSTOMERS ORDER BY CreatedDate DESC NULLS LAST Limit :CommentsLimit];        
            }
                            
            return commentRecords;
        }
        catch(exception ex){ Core_IPS_ExceptionHandling.logEntryWithException(ex,'Core_IPS_CommentScreenController.getcaseComments','Case');   return null;}
   }
}