/******************************************************************************************************************************************
Class Name  : Core_SM_redirectApprovalProcessExtension 
Version     : 1.0 
Created Date: 3rd July, 2015
Function    : Extension controller for Core_SM_redirectApprovalProcess contains logic for submitting the Milestone record for approval if the submitter is the Owner of the record.
Modification Log :
* Developer         Date            Description
* ----------------------------------------------------------------------------                 
* Ashwin Dash      07/03/2017       Original Version
* Ashwin Dash      08/21/2017       DE29752 : Added try catch block to show proper error message to the user
*****************************************************************************************************************************************/
public with sharing class Core_SM_redirectApprovalProcessExtension {
    
    /*public String milestoneId{get;set;}
    public Core_Solution_Milestone__c milestoneObj{get;set;}

    public Core_SM_redirectApprovalProcessExtension(ApexPages.StandardController controller) {
        milestoneId = ApexPages.currentPage().getParameters().get('id');
        milestoneObj = [SELECT id, Core_Owner__r.Id, Core_Owner__r.ManagerId, Core_Results_Key_Learnings__c FROM Core_Solution_Milestone__c  WHERE id = :milestoneId LIMIT 1];
    }
    
    public PageReference checkSubmitterEqualOwner(){
        Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
        User usr = [SELECT id, name, ManagerId FROM User WHERE id=:UserInfo.getUserId()];
        
        //Getting the error messages from the Labels
        List<String> errorMsgsList = System.Label.Core_Milestone_Error_Message.split(';');
        
        //Checking if the list of error messages is empty or not.
        if(!errorMsgsList.isEmpty() && errorMsgsList.size() > 3){
            if(UserInfo.getUserId() != milestoneObj.Core_Owner__r.Id){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMsgsList[0]));//Error message for owner different than submitter.
                return null;
            }else if(usr.ManagerId == null || String.valueOf(usr.ManagerId) == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMsgsList[1]));//Error message for submitter doesn't have a manager.
                return null;
            }else if(milestoneObj.Core_Results_Key_Learnings__c == null || milestoneObj.Core_Results_Key_Learnings__c == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMsgsList[2]));// Error message for Key learnings missing.
                return null;
            }else if(Approval.isLocked(milestoneObj.id)){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMsgsList[3]));// Error message for Record already submitted.
                return null;
            }else{
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(milestoneObj.id);
                req1.setComments('Submitting request for approval.');
                req1.setNextApproverIds(new Id[] {milestoneObj.Core_Owner__r.ManagerId});                
                
                // Submit on behalf of a specific submitter
                req1.setSubmitterId(UserInfo.getUserId()); 
                
                // Submit the record to specific process and skip the criteria evaluation
                //req1.setProcessDefinitionNameOrId('Solution Milestone Approval');
                req1.setSkipEntryCriteria(false);
                
                //DE29752 - Added try catch block to show proper error message to the user - Ashwin
                try{
                    // Submit the approval request for the account
                    Approval.ProcessResult result = Approval.process(req1);
                }catch(Exception e){
                    //Capturing a log entry for failed records
                    logEntry = new Core_Log_Entry__c(Core_Message__c = 'Type: '+e.getTypeName()+'Msg: '+e.getMessage()+'Stack: '+e.getStackTraceString(), Core_Origin__c='Core_SM_redirectApprovalProcessExtension.checkSubmitterEqualOwner', Core_Severity__c='Low', Core_When__c=System.Now(), Core_Project__c = 'Sales Evolve', Core_sObjectId__c = milestoneObj.Id);
                    insert logEntry;
                    //Showing custom error message for user on failure.
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMsgsList[4]));// Error message for any other failures while submitting.
                    return null;
                }
                return new PageReference('/'+milestoneObj.Id);
            }
        }
        return null;
    }*/

}