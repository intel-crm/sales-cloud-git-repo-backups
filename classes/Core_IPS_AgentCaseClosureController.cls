/******************************************************
*Class Name:  Core_IPS_AgentCaseClosureController
*Version     : 1.0 
*Created Date: Dec 11 2017
*Description:  Controller for Agent Case Closure Page
*No of Query:  2
*Modification Log :
* Developer                   Date                        Description
* ----------------------------------------------------------------------------                 
* Sugandha                    11/12/2017              Created(UserStory US72550 Iteration 4)
* Sugandha                    02/05/2018              Modified(Defect DE38340/DE38341 Iteration 10)
* Aayushi                     23/05/2018              Modified US106550
******************************************************/
public class  Core_IPS_AgentCaseClosureController{

    public String Close_Pending_SubStatus {get;set;} 
    public String Case_Status_Open {get;set;}
    public String ClosureComments {get;set;}    
    public Case newCase {get;set;}
    public Boolean isEditable {get;set;}
    public Boolean showError {get;set;}
    public Boolean showReturnBtn {get;set;}
    public String caseRTName;
    
    public  Core_IPS_AgentCaseClosureController(ApexPages.StandardController controller){    
        showReturnBtn = true;
        if(ApexPages.currentPage().getParameters().get('id') == null)
        {
            showError = true;
            showReturnBtn = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Err_Msg_Agent_CaseClosure')));
            return;
        }              
        if(!Test.isRunningTest())
            controller.addFields(new List<String>{'RecordType.DeveloperName'});
        
        showError = false;
        Close_Pending_SubStatus = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Close_Pending_SubStatus');
        Case_Status_Open = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Case_Status_Open');
        
        newCase = (Case)controller.getRecord();     

        isEditable = [SELECT HasEditAccess, RecordId 
                      FROM UserRecordAccess 
                      WHERE UserId =:userinfo.getuserId() 
                        AND RecordId = :newCase.Id].HasEditAccess;
        
        User loggedInUser = [SELECT ProfileId, Profile.Name 
                                FROM User
                                WHERE Id =:userinfo.getuserId()];

        if (!isEditable) {showError = true;                    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Insufficient_Privileges_Case')));
            return;
        }
     // start modified If condition by Aayushi US106550
       /* if(!System.Label.Core_IPS_Agent_Profile_Ids.Contains(String.ValueOf(loggedInUser.ProfileId).substring(0,15)) && 
            !System.Label.Core_IPS_Button_Override_ITAdmins.contains(loggedInUser.Profile.Name) &&
            loggedInUser.Profile.Name != Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Profile_IPS_Agent_Partner')){showError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Insuff_Access_Req_CaseClosure')));
        }*/
         if(!System.Label.Core_IPS_Agent_Profile_Ids.Contains(String.ValueOf(loggedInUser.ProfileId).substring(0,15)) && 
            !System.Label.Core_IPS_Button_Override_ITAdmins.contains(loggedInUser.Profile.Name) && !System.Label.Core_IPS_DataOps.contains(loggedInUser.ProfileId) &&
            loggedInUser.Profile.Name != Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Profile_IPS_Agent_Partner')){showError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Insuff_Access_Req_CaseClosure')));
        }
        //end
        if (!String.isBlank(newCase.Core_Sub_Status__c) && newCase.Core_Sub_Status__c.equals(Close_Pending_SubStatus)){
            showError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Case_Close_Pending_Msg')));           
        }               
              
         newCase.Status             = Case_Status_Open;
         newCase.Core_Sub_Status__c = Close_Pending_SubStatus;
         caseRTName                 = newCase.RecordType.DeveloperName;
    }
    
    /*********************************************************
    Version     : 1.0 
    Created Date: 11 Dec 2017
    Function    : Update Case on Case Closure request by Agent.
    Input Parameters: NA
    Output Parameters: Returns a case detail page.
    Description: Capture all the field needed to filled by an Agent while case closure.
    Used in     : Core_IPS_AgentCaseClosure Page
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sugandha                    12/11/2017              Created (UserStory US79834)
    * Sugandha                    02/05/2018              Modified(Defect DE38340/DE38341)
    *********************************************************/
    public PageReference RequestCaseClosure(){
        
        ApexPages.StandardController Controller = new ApexPages.StandardController(newCase);
        
        try{
            if (String.isBlank(ClosureComments) || ClosureComments.length() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Error_Msg_Case_Comment')));
                return null;
            }  
                       
            newCase.Status                              = Case_Status_Open;
            newCase.Core_Sub_Status__c                  = Close_Pending_SubStatus; 
            system.debug('newCase.Core_IPS_Date_Time_Close_Pending__c::'+newCase.Core_IPS_Date_Time_Close_Pending__c);
            //if(newCase.Core_IPS_Date_Time_Close_Pending__c == null)
            newCase.Core_IPS_Date_Time_Close_Pending__c = DateTime.Now(); // added by Sugandha for US84433 Iteration 4

            update newCase;
            
            //Adding a case comment on Case.Sub Status Close-Pending
            Core_IPS_Case_Comments__c newComment        = new Core_IPS_Case_Comments__c();
            newComment.Core_IPS_Case__c                 = newCase.Id;
            newComment.Core_IPS_Rich_Comment__c         = ClosureComments;
            newComment.Core_IPS_Case_Comment_Type__c    = Core_IPS_Helper_Utility.getIPSLabel('PUBLIC_TO_CUSTOMERS');
            //getAuthr method signature was changed for defect DE38340/DE38341 fix,so modified that method reference as per new changes by Sugandha 
            newComment.Core_IPS_Comment_Author_Type__c  = Core_IPS_AddCommentController.getAuthr(String.valueOf(userInfo.getProfileId()).substring(0,15),String.valueOf(userinfo.getuserId()).substring(0,15)); 
            
            insert newComment;
            return Controller.View();
        }
        catch(DMLException e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getdmlMessage(0)));}
        catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Something went wrong, Please contact system Administrator.'));Core_Exceptionclass Exce =  new Core_Exceptionclass();string  Str = Exce.InsertException('','Core_IPS_AgentCaseClosureController','Case','','RequestCaseClosure',e);}
        return Null;
    }

    public PageReference CancelOperation(){      
        return new ApexPages.StandardController(newCase).view();
    }
}