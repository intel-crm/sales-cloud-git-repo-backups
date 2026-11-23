public without sharing class Core_DWG_Recall_Cntrl {
    
    @auraEnabled
    public static String CheckRecallDWGValidations(String DWGId){
        system.debug('######1Id'+DWGId);
        Id currentUserId = UserInfo.getUserId();
        Map<Id, Id> mapGoalIdApproverId = new Map <Id, Id>();
        Core_Opp_LineItem_Recall_Access__c cs = Core_Opp_LineItem_Recall_Access__c.getInstance(currentUserId); 
        //DWG EOL Temporary fix - switch to be added | Permanent fix - code to be re-configured
        String alertmesg;
        Core_Goal__c DWGrecord = [SELECT id, name, Core_Goal_Approver__c, Core_Goal_Approved_By__c, Core_Goal_Approved_Date__c, Core_Approved_KPI_Revenue__c, Core_Goal_Status__c, Core_Goal_Owner__c, Core_Goal_Claim_Date__c, Core_Goal_Owner__r.ManagerId from Core_Goal__c where Id =: DWGId ];
        List<Core_Goal__c>DwgLst= New List<Core_Goal__c>();
        DwgLst.add(DWGrecord);
        // Get the Last Approver
        for (ProcessInstance inst : [SELECT Id, LastActorId, Status, TargetObjectId FROM ProcessInstance WHERE Status = 'Approved' AND TargetObjectId = :DWGId ORDER BY LastModifiedDate DESC LIMIT 1]) {
            mapGoalIdApproverId.put(inst.TargetObjectId, inst.LastActorId);
        }
         if(DWGrecord.Core_Goal_Status__c !='Approved'){
            alertmesg='Deal Win Goal must be APPROVED to Recall Approval.';
        }
        else if((currentUserId != DWGrecord.Core_Goal_Approver__c) && (cs != null && !cs.Core_Recall_Access__c) && (mapGoalIdApproverId != null && currentUserId != mapGoalIdApproverId.get(DWGrecord.Id)) && currentUserId != DWGrecord.Core_Goal_Owner__r.ManagerId){
            alertmesg='Contact previous Approver or the Manager of the Deal Win Goal Owner to Recall Approval.';
        }
        
        return alertmesg;
    }
    
    @auraEnabled
    public static String UpdateDWG(String DWGId, String RecallReason){
        system.debug('*****Inside'+DWGId);
        system.debug('*****Inside1'+RecallReason);
        String alertMsg = '';
        //DWG EOL Temporary fix - switch to be added | Permanent fix - code to be re-configured
        Core_Goal__c DWGrecord = [SELECT id, name, Core_Goal_Approver__c, Core_Goal_Approved_By__c, Core_Goal_Approved_Date__c, Core_Approved_KPI_Revenue__c, Core_Goal_Status__c, Core_Goal_Owner__c, Core_Goal_Claim_Date__c, Core_Goal_Owner__r.ManagerId from Core_Goal__c where Id =: DWGId ];
        List<Core_Goal__c>DwgLst= New List<Core_Goal__c>();
        DwgLst.add(DWGrecord);
        try{
            Approval.UnLockResult[] lstResult = System.Approval.unlock(DwgLst, false); 
               for (Approval.UnLockResult result : lstResult) {
                    if (result.isSuccess() && !test.isrunningtest()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully unlocked DWG with ID: ' + result.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for (Database.Error err : result.getErrors()) {
                            System.debug('The following error has occurred.');   
                            
							Core_Exceptions__c excep = new Core_Exceptions__c(Core_Class_Name__c = 'Core_DWG_Recall_Cntrl',Core_Method_Name__c = 'ApprovalUnlockLogic',Core_Record_Id__c = DWGrecord.Id,Core_Exception__c = err.getMessage(),Core_IPS_Object_Name__c = 'Core_Goal',Core_Login_User_Id__c = userInfo.getUserId());
                          
                            insert excep;
                            
                        }
                    }
                }
            DWGrecord.Core_Goal_Status__c='Recalled';
            DWGrecord.Core_Recall_Reason__c=RecallReason;
            DWGrecord.Core_Goal_Approved_Date__c = null;
            DWGrecord.Core_Goal_Approved_By__c = null;
            DWGrecord.Core_Goal_Claim_Date__c = null;
            DWGrecord.Core_Approved_KPI_Revenue__c = null;
            update DWGrecord;
            alertMsg='DWG has been Recalled Successfully';
            //if(Test.isRunningTest())
              //  {
                //    throw new MyException();
                //}
        }
        catch(Exception e){
            alertMsg='Failed to Recall,please contact system admin for more details';
            Core_Exceptions__c excep = new Core_Exceptions__c(Core_Class_Name__c = 'Core_DWG_Recall_Cntrl',Core_Method_Name__c = 'DWGRecallMethod',Core_Record_Id__c = DWGrecord.Id,Core_Exception__c = e.getStackTraceString() + ';' + e.getCause() + ';' + e.getMessage(),Core_IPS_Object_Name__c = 'Core_Goal',Core_Login_User_Id__c = userInfo.getUserId());
                          
             insert excep;
			//Core_Exceptions__c excep = new Core_Exceptions__c(); 
           // excep.Core_Class_Name__c = 'Core_DWG_Recall_Cntrl';
            //excep.Core_Method_Name__c = 'DWGRecallMethod';
            //excep.Core_Record_Id__c = DWGrecord.Id;
            //excep.Core_Exception__c = e.getStackTraceString() + ';' + e.getCause() + ';' + e.getMessage();
           // excep.Core_IPS_Object_Name__c = 'Core_Goal';                                                   
            //excep.Core_Login_User_Id__c = userInfo.getUserId();
            //insert excep;
        }
        return alertMsg;
    }
    
}