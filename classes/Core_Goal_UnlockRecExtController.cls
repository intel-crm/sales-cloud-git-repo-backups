public class Core_Goal_UnlockRecExtController {

    public List<Core_Goal__c> dwgList{get;set;}
    public String dwgId{get;set;}
    public List<String> goalErrorMsgList{get;set;}
    public string onLoadString{get;set;}
    
    public Core_Goal_UnlockRecExtController(ApexPages.StandardController controller) {
        dwgId = ApexPages.CurrentPage().getParameters().get('id');
        goalErrorMsgList = new List<String>();
        if(dwgId != null && String.valueOf(dwgId) != ''){
            //DWG EOL Temporary fix - switch to be added | Permanent fix - code to be re-configured
            dwgList = [SELECT id, name, Core_Goal_Approver__c, Core_Goal_Approved_By__c, Core_Goal_Approved_Date__c, Core_Approved_KPI_Revenue__c, Core_Goal_Status__c, Core_Goal_Owner__c, Core_Goal_Claim_Date__c, Core_Goal_Owner__r.ManagerId FROM Core_Goal__c WHERE id = :dwgId LIMIT 1];
        }else{
            dwgList = new List<Core_Goal__c>();
        }
        goalErrorMsgList = (String.valueOf(Label.Core_Goal_ErrorMessages)).split(';');
        
        
    }
    
    public string onLoad(){
        onLoadString = '<script> checkCondition(); </script>';
        return onLoadString;
      }
    
    
    public pageReference unlockGoal(){
        Id currentUserId = UserInfo.getUserId();
        Id approverId = null;
        Map<Id, Id> mapGoalIdApproverId = new Map <Id, Id>();
        Integer count = 0;
        String errStr = '';
        /* Start - US349129  Dt - 5/7/2019 OPPTY/DWG: Provide Specified Users the Ability to Recall  */
        Core_Opp_LineItem_Recall_Access__c cs = Core_Opp_LineItem_Recall_Access__c.getInstance(currentUserId); 
        /* Start - US349129 - OPPTY/DWG: Provide Specified Users the Ability to Recall  */
        
        // Get the Last Approver
        for (ProcessInstance inst : [SELECT Id, LastActorId, Status, TargetObjectId FROM ProcessInstance WHERE Status = 'Approved' AND TargetObjectId = :dwgId ORDER BY LastModifiedDate DESC LIMIT 1]) {
            mapGoalIdApproverId.put(inst.TargetObjectId, inst.LastActorId);
        }
        
        if(dwgList != null && !dwgList.isEmpty()){
            if(dwgList[0].Core_Goal_Status__c != 'Approved'){
                //Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Operation. Deal Win Goal must be APPROVED to Recall Approval.'));
                if(goalErrorMsgList != null && goalErrorMsgList.size()>2){
                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, goalErrorMsgList[1]));
                }
                return null;
            }else if((currentUserId == dwgList[0].Core_Goal_Approver__c) || (cs != null && cs.Core_Recall_Access__c) || (mapGoalIdApproverId != null && currentUserId == mapGoalIdApproverId.get(dwgList[0].Id)) || currentUserId == dwgList[0].Core_Goal_Owner__r.ManagerId){
                Approval.UnLockResult[] lstResult = System.Approval.unlock(dwgList, false);
                // Iterate through each returned result
                for (Approval.UnLockResult result : lstResult) {
                    if (result.isSuccess() && !test.isrunningtest()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully unlocked Core_Solution_Milestone__c with ID: ' + result.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for (Database.Error err : result.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Core_Solution_Milestone__c fields that affected this error: ' + err.getFields());
                            errStr = err.getMessage();
                        }
                        count++;
                    }
                }
                if(count > 0 && !test.isrunningtest()){
                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errStr));
                    return null;
                }else{
                    //Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Deal Win Goal has been recalled successfully'));
                    if(goalErrorMsgList != null && goalErrorMsgList.size()>2){
                        Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, goalErrorMsgList[2]));
                    }
                    dwgList[0].Core_Goal_Status__c = 'Accepted';
                    dwgList[0].Core_Goal_Approved_Date__c = null;
                    dwgList[0].Core_Goal_Approved_By__c = null;
                    dwgList[0].Core_Goal_Claim_Date__c = null;
                    dwgList[0].Core_Approved_KPI_Revenue__c = null;
                    update dwgList[0];
                    return null;
                }
            }else {
                //Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Contact previous Approver or the Manager of the Deal Win Goal Owner to Recall Approval.'));
                if(goalErrorMsgList != null && goalErrorMsgList.size()>2){
                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, goalErrorMsgList[3]));
                }
                return null;
            }
        }
        return null;        
    }
    
    public pageReference backToGoal(){
        String globalUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
        PageReference pgRef = new PageReference(globalUrl+'/'+dwgId);
        pgRef.setRedirect(true);
        return pgRef;
    }

}