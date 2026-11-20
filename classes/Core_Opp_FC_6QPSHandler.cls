/******************************************************************************************************************************************
Function    : Trigger handler class for the object Forecast Product Schedule
********************************************************************************************************************************************/
public without sharing class Core_Opp_FC_6QPSHandler{ //TWC3123-5338 Added without sharing keyword to fix code scan issue
    
    public static boolean recursiveFlag = false;
    public static final Set<String> Core_Status1 = new Set<String>{'Lost','Cancelled','Deleted','On Hold','Production Lost','Production Cancelled'};
    //US104061 : 6QPS: Implement Approval Tasks Adding Approval creating static variable
    public static final String CORE_SUBMITTED = 'Submitted';
    public static final String CORE_APPROVED = 'Approved';

    public static void beforeUpdateMethod(List<Core_Opp_FC_Prod_Schedule__c> newFCList, Map<Id, Core_Opp_FC_Prod_Schedule__c> oldFCMap){
        
        Set<Id> fcLineItemIdSet1 = new Set<Id>();
        //START - US104061 : 6QPS: Implement Approval Tasks Adding Approval Populating map for getting manager and delegated approver
        Set<Id> fcOpptyIdSet = new Set<Id>();
        List<Opportunity> opptyList = new List<Opportunity>();
        Map<String, ID> opptyMgrDelAppMap = new Map<String, ID>();
        List<Core_Opp_FC_Prod_Schedule__c> approvedFCList = new List<Core_Opp_FC_Prod_Schedule__c>();
        List<Core_Opp_FC_Prod_Schedule__c> rejectedFCList = new List<Core_Opp_FC_Prod_Schedule__c>();
        
        for(Core_Opp_FC_Prod_Schedule__c fc : newFCList){
            if((oldFCMap.get(fc.Id).Core_Opp_FC_Approval_Status__c != CORE_SUBMITTED && fc.Core_Opp_FC_Approval_Status__c == CORE_SUBMITTED) || 
                (oldFCMap.get(fc.Id).Core_Opp_FC_Approval_Status__c == null && fc.Core_Opp_FC_Approval_Status__c == CORE_APPROVED)){
                fcOpptyIdSet.add(fc.Core_Opp_FC_Opportunity__c);
            }
        }
        if(!fcOpptyIdSet.isEmpty()){
            opptyList = [SELECT id, OwnerId, Owner.ManagerId, Owner.Manager.DelegatedApproverId, Owner.DelegatedApproverId,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c FROM Opportunity WHERE Id IN : fcOpptyIdSet];
            if(!opptyList.isEmpty()){
                for(Opportunity opp : opptyList){
					if(opp.Core_Opportunity_Coverage_Nm__c =='Partner-Led Opportunity' && opp.Core_Coverage_Type_Nm__c =='Deal Registration')
					{
						//Adding OO as Approval manager and OO's delegate as Delegate approver
                        opptyMgrDelAppMap.put(opp.Id+'M', opp.OwnerId);
						if(opp.Owner.DelegatedApproverId != null && String.valueOf(opp.Owner.DelegatedApproverId) != ''){
							opptyMgrDelAppMap.put(opp.Id+'A', opp.Owner.DelegatedApproverId);
						}
					}
					else{
						if(opp.Owner.ManagerId != null && String.valueOf(opp.Owner.ManagerId) != ''){
							opptyMgrDelAppMap.put(opp.Id+'M', opp.Owner.ManagerId);
						}
						if(opp.Owner.Manager.DelegatedApproverId != null && String.valueOf(opp.Owner.Manager.DelegatedApproverId) != ''){
							opptyMgrDelAppMap.put(opp.Id+'A', opp.Owner.Manager.DelegatedApproverId);
						}
					}
                }
            }
        }
        //END - US104061 : 6QPS: Implement Approval Tasks Adding Approval Populating map for getting manager and delegated approver
        
        for(Core_Opp_FC_Prod_Schedule__c fc : newFCList){
            fcLineItemIdSet1.add(fc.Core_Opp_Line_Item_RecordID__c);
            if(oldFCMap.get(fc.Id).Core_Opp_FC_Quantity__c != fc.Core_Opp_FC_Quantity__c){
                fc.Core_FC_Last_Modified_Date__c = System.Today();
            }
            //START - US104061 : 6QPS: Implement Approval Tasks Adding Approval populate Manager and Delegated Approver
            //START - US104056 : 6QPS: Add Forecast Claim Date and capture Rejected Behaviour details like isRejected, Rejected By and Rejected Date
            if(((oldFCMap.get(fc.Id).Core_Opp_FC_Approval_Status__c != CORE_SUBMITTED && fc.Core_Opp_FC_Approval_Status__c == CORE_SUBMITTED) || 
                (oldFCMap.get(fc.Id).Core_Opp_FC_Approval_Status__c == null && fc.Core_Opp_FC_Approval_Status__c == CORE_APPROVED)) && 
                !opptyMgrDelAppMap.isEmpty()){
                    if(oldFCMap.get(fc.Id).Core_Opp_FC_Approval_Status__c != CORE_SUBMITTED && fc.Core_Opp_FC_Approval_Status__c == CORE_SUBMITTED){
                        fc.Core_Opp_FC_Claim_Date__c = System.today();      
                    }
                    fc.Core_Opp_FC_Rejected_By__c = null;
                    fc.Core_Opp_FC_Rejected_Date__c = null;
                    if(opptyMgrDelAppMap.get(String.valueOf(fc.Core_Opp_FC_Opportunity__c)+'M') != null){
                        fc.Core_Opp_FC_Approval_Manager__c = opptyMgrDelAppMap.get(String.valueOf(fc.Core_Opp_FC_Opportunity__c)+'M');
                    }
                    if(opptyMgrDelAppMap.get(String.valueOf(fc.Core_Opp_FC_Opportunity__c)+'A') != null){
                        fc.Core_Opp_FC_Delegated_Approver__c = opptyMgrDelAppMap.get(String.valueOf(fc.Core_Opp_FC_Opportunity__c)+'A');
                    }
            }
            
           
            if(oldFCMap.get(fc.Id).Core_Opp_FC_Approval_Status__c == CORE_SUBMITTED && (fc.Core_Opp_FC_Approval_Status__c == null || String.valueOf(fc.Core_Opp_FC_Approval_Status__c) == '')){
                fc.Core_Opp_FC_Claim_Date__c = null;
                fc.Core_Opp_FC_Rejected_By__c = UserInfo.getUserId();
                fc.Core_Opp_FC_Rejected_Date__c = System.now();
                fc.Core_Opp_FC_isTaskCreated__c = false;
                rejectedFCList.add(fc);
              
            }
            if(oldFCMap.get(fc.Id).Core_Opp_FC_Approval_Status__c == CORE_SUBMITTED && fc.Core_Opp_FC_Approval_Status__c == CORE_APPROVED){
                fc.Core_Opp_FC_Approved_By__c = UserInfo.getUserId();
                fc.Core_Opp_FC_isTaskCreated__c = false;
                approvedFCList.add(fc);
            }
        }
        if(!approvedFCList.isEmpty()){
            closeFCTaskonApproval(approvedFCList, 'Approve');
        }
        if(!rejectedFCList.isEmpty()){
            closeFCTaskonApproval(rejectedFCList, 'Reject');
        }
        //END - US104056 : 6QPS: Add Forecast Claim Date and capture Rejected Behaviour details like isRejected, Rejected By and Rejected Date
        //END - US104061 : 6QPS: Implement Approval Tasks Adding Approval populate Manager and Delegated Approver
       /* Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>([SELECT id, Core_Status__c FROM OpportunityLineItem WHERE Id IN :fcLineItemIdSet1]);
        for(Core_Opp_FC_Prod_Schedule__c fc : newFCList){           
            if(Core_Status1.contains(oliMap.get(fc.Core_Opp_Line_Item_RecordID__c).Core_Status__c)){
                if(fc.Core_Opp_FC_Quantity__c != 0){
                    fc.Core_FC_Last_Modified_Date__c = System.Today();
                    //fc.Core_Opp_FC_Quantity__c = 0;
                }
            }
        }*/
    }
    
    public static void afterUpdateMethod(List<Core_Opp_FC_Prod_Schedule__c> newFCList, Map<Id, Core_Opp_FC_Prod_Schedule__c> oldFCMap){
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> fcIdSet = new Set<Id>();
        Set<Id> fcLineItemIdSet = new Set<Id>();
        boolean isBlankFlag = false;
        //US104061 : 6QPS: Implement Approval Tasks Adding Approval declaring the varaiables to store updated Forecast Records
        boolean taskInserted = false;
        List<Task> taskOnMgrApproverList = new List<Task>();
        Map<Id, Core_Opp_FC_Prod_Schedule__c> fcTaskCreationMap = new Map<id, Core_Opp_FC_Prod_Schedule__c>();
        
        
        for(Core_Opp_FC_Prod_Schedule__c fc : newFCList){
            //US104061 : 6QPS: Implement Approval Tasks Adding the submitted only forecast records to List inorder to insert tasks
            if((oldFCMap.get(fc.Id).Core_Opp_FC_Approval_Status__c == null || String.valueOf(oldFCMap.get(fc.Id).Core_Opp_FC_Approval_Status__c) == '') && fc.Core_Opp_FC_Approval_Status__c == 'Submitted'){
                fcTaskCreationMap.put(fc.Id, fc);
            }
            if(fc.Core_Opp_FC_Quantity__c == null || String.valueOf(fc.Core_Opp_FC_Quantity__c) == ''){
                isBlankFlag = true;
                fc.addError('Cannot make quantity blank');              
            }
            if(oldFCMap.get(fc.Id).Core_Opp_FC_Quantity__c != fc.Core_Opp_FC_Quantity__c){
                fcIdSet.add(fc.Id);
                opptyIdSet.add(fc.Core_Opp_FC_Opportunity__c);
                fcLineItemIdSet.add(fc.Core_Opp_Line_Item_RecordID__c);
            }           
        }  
        //START - US104061 : 6QPS: Implement Approval Tasks Calling Create task method to insert tasks for Submitted records
        if(!fcTaskCreationMap.isEmpty()){
            taskOnMgrApproverList = createFCTasks(fcTaskCreationMap.values());
            if(!taskOnMgrApproverList.isEmpty()){
                try{
                    insert taskOnMgrApproverList;
                    taskInserted = true;
                }catch(Exception e){
                    taskInserted = false;
                }
            }
        }
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> prodSortForecastMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        List<Core_Opp_FC_Prod_Schedule__c> updateList = new List<Core_Opp_FC_Prod_Schedule__c>();
        if(!fcTaskCreationMap.isEmpty()){
            for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_isTaskCreated__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_isdeleted__c = false AND ID IN :fcTaskCreationMap.keySet()]){
                if(taskInserted){
                    fc.Core_Opp_FC_isTaskCreated__c = true;
                    updateList.add(fc);
                }
            }   
        }
        //END - US104061 : 6QPS: Implement Approval Tasks Calling Create task method to insert tasks for Submitted records  
        if(!isBlankFlag){
            List<Core_Opp_FC_Prod_Schedule__c> tempList;
            if(!opptyIdSet.isEmpty() && !fcIdSet.isEmpty()){                
                for(Core_Opp_FC_Prod_Schedule__c fc : [SELECT id, Core_Opp_FC_Opportunity__c, Core_Opp_Line_Item_RecordID__c, Core_Opp_FC_Product__c, Core_Opp_FC_Product__r.Name, Core_Opp_FC_Quarter_Date__c, Core_Opp_FC_Quarter__c, Core_Opp_FC_Quantity__c, Core_Opp_FC_isdeleted__c, lastModifiedDate, createdDate, Core_FC_4Q_Shed_Quantity__c, Core_FC_Last_Modified_Date__c, Core_FC_Vendor__c FROM Core_Opp_FC_Prod_Schedule__c WHERE Core_Opp_FC_Opportunity__c IN :opptyIdSet AND Core_Opp_Line_Item_RecordID__c IN :fcLineItemIdSet AND Core_Opp_FC_isdeleted__c = false AND Id != :fcIdSet]){
                    tempList = new List<Core_Opp_FC_Prod_Schedule__c>();
                    if(prodSortForecastMap.get(fc.Core_Opp_FC_Opportunity__c) != null){
                        tempList = prodSortForecastMap.get(fc.Core_Opp_FC_Opportunity__c);
                        tempList.add(fc); 
                        prodSortForecastMap.put(fc.Core_Opp_FC_Opportunity__c, tempList);
                    }else{
                        tempList.add(fc);
                        prodSortForecastMap.put(fc.Core_Opp_FC_Opportunity__c, tempList);
                    }      
                }
                
            }
            //US104061 : 6QPS: Implement Approval Tasks - Moving thes outside of if condition to ensure updateList has the newly updated Forecast records for isTaskCreated field update
            if(!recursiveFlag){
                recursiveFlag = true;
                for(Id opp : opptyIdSet){
                    if(prodSortForecastMap.get(opp) != null){
                        for(Core_Opp_FC_Prod_Schedule__c fc1 : prodSortForecastMap.get(opp)){
                            fc1.Core_FC_Last_Modified_Date__c = System.Today();
                            updateList.add(fc1);
                        }
                    }
                }                   
                update updateList;
            }
        }        
    }
    
    /*
    *Method Name: CreateFCTasks
    *Parameters: List<Core_Opp_FC_Prod_Schedule__c> List of Forecast records for which tasks are to be created
    *Description: This method is called to create tasks for submitted forecast records.
    */
    public static List<Task> createFCTasks(List<Core_Opp_FC_Prod_Schedule__c> fcRecTaskList){
        Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> managerApproverVsFCMap = new Map<Id, List<Core_Opp_FC_Prod_Schedule__c>>();
        Map<Id, Opportunity> fcOpptyDetailMap;
        Set<Id> opptyIdsSet = new Set<Id>();
        List<Task> taskList = new List<Task>();
        List<Core_Opp_FC_Prod_Schedule__c> tempList = new List<Core_Opp_FC_Prod_Schedule__c>();
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcRecTaskList){
            if(fc.Core_Opp_FC_Approval_Manager__c != null && managerApproverVsFCMap.get(fc.Core_Opp_FC_Approval_Manager__c) == null){
                tempList.add(fc);
                managerApproverVsFCMap.put(fc.Core_Opp_FC_Approval_Manager__c, tempList);
            }else if(fc.Core_Opp_FC_Approval_Manager__c != null && managerApproverVsFCMap.get(fc.Core_Opp_FC_Approval_Manager__c) != null){
                tempList = managerApproverVsFCMap.get(fc.Core_Opp_FC_Approval_Manager__c);
                tempList.add(fc);
                managerApproverVsFCMap.put(fc.Core_Opp_FC_Approval_Manager__c, tempList);
            }
            tempList = new List<Core_Opp_FC_Prod_Schedule__c>();
            if(fc.Core_Opp_FC_Delegated_Approver__c != null && managerApproverVsFCMap.get(fc.Core_Opp_FC_Delegated_Approver__c) == null){
                tempList.add(fc);
                managerApproverVsFCMap.put(fc.Core_Opp_FC_Delegated_Approver__c, tempList);
            }else if(fc.Core_Opp_FC_Delegated_Approver__c != null && managerApproverVsFCMap.get(fc.Core_Opp_FC_Delegated_Approver__c) != null){
                tempList = managerApproverVsFCMap.get(fc.Core_Opp_FC_Delegated_Approver__c);
                tempList.add(fc);
                managerApproverVsFCMap.put(fc.Core_Opp_FC_Delegated_Approver__c, tempList);
            }
            tempList = new List<Core_Opp_FC_Prod_Schedule__c>();
            opptyIdsSet.add(fc.Core_Opp_FC_Opportunity__c);
        }
        fcOpptyDetailMap = new Map<Id, Opportunity>([SELECT id, Name, OwnerId, Owner.Name, AccountId, Account.Name, Core_Opportunity_Coverage_Nm__c, Core_Coverage_Type_Nm__c, Core_Technical_Owner__c, Core_Technical_Owner__r.Name FROM Opportunity WHERE id IN :opptyIdsSet]);
        Set<Id> fcOpptyIdSet = new Set<Id>();
        for(Id uId : managerApproverVsFCMap.keySet()){
            for(Core_Opp_FC_Prod_Schedule__c fc : managerApproverVsFCMap.get(uId)){             
                if(!fcOpptyIdSet.contains(fc.Core_Opp_FC_Opportunity__c)){
                    if(fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Core_Opportunity_Coverage_Nm__c =='Partner-Led Opportunity' && fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Core_Coverage_Type_Nm__c =='Deal Registration')
                    {
                        if(fc.Core_Opp_FC_Approval_Manager__c != null){
                            taskList.add(new Task(Description='Hello, '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Core_Technical_Owner__r.Name+' has requested 6QPS Approval for the Opportunity'+'\n Account Name : '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Account.Name+'\n Opportunity Name : '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Name+'\n Forecast Quarter : '+fc.Core_Opp_FC_Quarter__c +'\n Click the link to Approve/Reject :  '+Label.Core_IPS_Notification_Internal_URL +fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Id, OwnerId=fc.Core_Opp_FC_Approval_Manager__c, priority='High', Status='In Progress', Subject='6QPS Approval Request for '+fc.Core_Opp_FC_Quarter__c + ' : ' + fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Name, WhatId=fc.Core_Opp_FC_Opportunity__c));
                        }
                        if(fc.Core_Opp_FC_Delegated_Approver__c != null){
                            taskList.add(new Task(Description='Hello, '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Core_Technical_Owner__r.Name+' has requested 6QPS Approval for the Opportunity'+'\n Account Name : '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Account.Name+'\n Opportunity Name : '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Name+'\n Forecast Quarter : '+fc.Core_Opp_FC_Quarter__c +'\n Click the link to Approve/Reject :  '+Label.Core_IPS_Notification_Internal_URL +fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Id, OwnerId=fc.Core_Opp_FC_Delegated_Approver__c, priority='High', Status='In Progress', Subject='6QPS Approval Request for '+fc.Core_Opp_FC_Quarter__c + ' : ' + fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Name, WhatId=fc.Core_Opp_FC_Opportunity__c));
                        }
                    }
                    else
                    {
                        if(fc.Core_Opp_FC_Approval_Manager__c != null){
                            taskList.add(new Task(Description='Hello, '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Owner.Name+' has requested 6QPS Approval for the Opportunity'+'\n Account Name : '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Account.Name+'\n Opportunity Name : '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Name+'\n Forecast Quarter : '+fc.Core_Opp_FC_Quarter__c +'\n Click the link to Approve/Reject :  '+Label.Core_IPS_Notification_Internal_URL +fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Id, OwnerId=fc.Core_Opp_FC_Approval_Manager__c, priority='High', Status='In Progress', Subject='6QPS Approval Request for '+fc.Core_Opp_FC_Quarter__c + ' : ' + fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Name, WhatId=fc.Core_Opp_FC_Opportunity__c));
                        }
                        if(fc.Core_Opp_FC_Delegated_Approver__c != null){
                            taskList.add(new Task(Description='Hello, '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Owner.Name+' has requested 6QPS Approval for the Opportunity'+'\n Account Name : '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Account.Name+'\n Opportunity Name : '+fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Name+'\n Forecast Quarter : '+fc.Core_Opp_FC_Quarter__c +'\n Click the link to Approve/Reject :  '+Label.Core_IPS_Notification_Internal_URL +fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Id, OwnerId=fc.Core_Opp_FC_Delegated_Approver__c, priority='High', Status='In Progress', Subject='6QPS Approval Request for '+fc.Core_Opp_FC_Quarter__c + ' : ' + fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Name, WhatId=fc.Core_Opp_FC_Opportunity__c));
                        }
                    }
                }
                fcOpptyIdSet.add(fc.Core_Opp_FC_Opportunity__c);
            }
        }
        return taskList;
    }

    /*
    *Method Name: closeFCTaskonApproval
    *Parameters: List<Core_Opp_FC_Prod_Schedule__c>, String : List of Forecast records for which tasks are to be closed and String parameter to decide whether its
    *            on approval or Rejection
    *Description: This method is called to create tasks for submitted forecast records.
    */
    public static void closeFCTaskonApproval(List<Core_Opp_FC_Prod_Schedule__c> fcRecTaskList, String ApprovalStatus){      
        Set<Id> opptyIdsSet = new Set<Id>();
        Set<Id> mgrAppvrIdSet = new Set<Id>();      
        List<Task> closingFCTaskList = new List<Task>();
        Map<Id, String> opptyIdvsFCQuaterMap = new Map<Id, String>();
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcRecTaskList){
            opptyIdsSet.add(fc.Core_Opp_FC_Opportunity__c);         
        }
        Map<Id, Opportunity> fcOpptyDetailMap = new Map<Id, Opportunity>([SELECT id, Name, OwnerId, Owner.ManagerId, Owner.Manager.DelegatedApproverId, Owner.DelegatedApproverId, Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c   FROM Opportunity WHERE id IN :opptyIdsSet]);
        
        for(Core_Opp_FC_Prod_Schedule__c fc : fcRecTaskList){
			if(fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Core_Opportunity_Coverage_Nm__c =='Partner-Led Opportunity' && fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Core_Coverage_Type_Nm__c =='Deal Registration')
				{
					mgrAppvrIdSet.add(fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).OwnerId);
					mgrAppvrIdSet.add(fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Owner.DelegatedApproverId);
					opptyIdvsFCQuaterMap.put(fc.Core_Opp_FC_Opportunity__c, fc.Core_Opp_FC_Quarter__c);
				}
				else{
					mgrAppvrIdSet.add(fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Owner.ManagerId);
					mgrAppvrIdSet.add(fcOpptyDetailMap.get(fc.Core_Opp_FC_Opportunity__c).Owner.Manager.DelegatedApproverId);
					opptyIdvsFCQuaterMap.put(fc.Core_Opp_FC_Opportunity__c, fc.Core_Opp_FC_Quarter__c);
				}
        }
        for(Task t : [SELECT id, Status, WhatId FROM Task WHERE WhatId IN :opptyIdsSet AND OwnerId IN :mgrAppvrIdSet]){
            t.Status = 'Completed';
            if(ApprovalStatus == 'Approve'){
                t.description = Label.Core_IPS_Notification_Internal_URL+t.WhatId+' ---- ' +opptyIdvsFCQuaterMap.get(t.WhatId)+ ' - 6QPS Approval Request has been approved by  :  '  + UserInfo.getFirstName()  + '  ' +UserInfo.getLastName();
                closingFCTaskList.add(t);
            }else if(ApprovalStatus == 'Reject'){
                t.description = Label.Core_IPS_Notification_Internal_URL+t.WhatId+' ---- ' +opptyIdvsFCQuaterMap.get(t.WhatId)+ ' - 6QPS Approval Request has been rejected by  :  '  + UserInfo.getFirstName()  + '  ' +UserInfo.getLastName();
                closingFCTaskList.add(t);
            }
        }
        if(!closingFCTaskList.isEmpty()){
            update closingFCTaskList;
        }
    }
}