/****************************************************************************************************************************************
* Class Name  : Core_MDF_GenericApprovalProcess 
* Version     : 1.0 
* Created Date: 08-03-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Shridhar K        08/03/2018                    Created Core_MDF_GenericApprovalProcess class to assign Approvers based on criteria.
*****************************************************************************************************************************************/
public Without Sharing class Core_MDF_GenericApprovalProcess {

/****************************************************************************************************************************************
    Method Name:                                             setApprovers
    @return  :                                               --
    @parameters:                                             List of SObject, campaigns oldMap, isInsert and isUpdate                                 
    Description:                                             Setting approvers based on criteria.
    Added By:                                                Accenture – Shridhar K  -  08/03/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        08/03/2018                 Created.
*****************************************************************************************************************************************/ 
    /*public static Map<String, Map<String, list<Id>>> setApprovers(list<SObject> sObjectList){ 
    	
        //Putting required data in collections
        
        //Mapping criteria rules with approvers set.
        Map<Id,list<Core_MDF_Criteria_Rule__c>> approverWithRules = new Map<Id,list<Core_MDF_Criteria_Rule__c>>{};
        
        for(Core_MDF_Criteria_Rule__c cr: [SELECT Id, Core_MDF_Approver__c, Core_MDF_Field_Name__c, Core_MDF_Object_Type__c, Core_MDF_Operator__c,
                            Core_MDF_Value__c FROM Core_MDF_Criteria_Rule__c WHERE Core_MDF_Approver__r.Core_MDF_Active__c = TRUE] ){
            if(approverWithRules.containsKey(cr.Core_MDF_Approver__c)){
                approverWithRules.get(cr.Core_MDF_Approver__c).add(cr);
            }
            else{
                List<Core_MDF_Criteria_Rule__c> tempCRList = new List<Core_MDF_Criteria_Rule__c>();
                tempCRList.add(cr);
                approverWithRules.put(cr.Core_MDF_Approver__c,tempCRList);              
            }
        }
        
        // Mapping approval criteria with approvers set.
        Map<Id,List<Core_MDF_Approver__c>> crtWithApprovers = new Map<Id,List<Core_MDF_Approver__c>>{}; 
        Map<Id,Core_MDF_Criteria__c> approvalCriteriaMap = new Map<Id,Core_MDF_Criteria__c>();
        
        //ApproverId to Group Developer Name Map
        Map<Id, String> approverIdToGroupNameMap = new Map<Id,String>();
        
        for(Core_MDF_Approver__c appr: [SELECT Id, Core_MDF_Step_Number__c, Core_MDF_Approver_1__c, Core_MDF_Approver_2__c, Core_MDF_Approver_3__c, Core_MDF_Approver_4__c,
                                        Core_MDF_Approver_5__c, Core_MDF_Approver_6__c, Core_MDF_Approver_7__c, Core_MDF_Approver_8__c, Core_MDF_Approver_9__c,
                                        Core_MDF_Approver_10__c, Core_MDF_Criteria__r.Core_MDF_Approval_Process__c, Core_MDF_Criteria__r.Core_MDF_Field_Name_1__c,
                                        Core_MDF_Criteria__r.Core_MDF_Field_Name_2__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_3__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_4__c,
                                        Core_MDF_Criteria__r.Core_MDF_Field_Name_5__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_6__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_7__c,
                                        Core_MDF_Criteria__r.Core_MDF_Field_Name_8__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_9__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_10__c,
                                        Core_MDF_Criteria__r.Core_MDF_Object_Type__c, Core_MDF_Criteria__r.Core_MDF_Operator_1__c,Core_MDF_Criteria__r.Core_MDF_Operator_10__c,
                                        Core_MDF_Criteria__r.Core_MDF_Operator_2__c, Core_MDF_Criteria__r.Core_MDF_Operator_3__c,Core_MDF_Criteria__r.Core_MDF_Operator_4__c,
                                        Core_MDF_Criteria__r.Core_MDF_Operator_5__c,Core_MDF_Criteria__r.Core_MDF_Operator_6__c,Core_MDF_Criteria__r.Core_MDF_Operator_7__c,Core_MDF_Criteria__r.Core_MDF_Operator_8__c,
                                        Core_MDF_Criteria__r.Core_MDF_Operator_9__c,Core_MDF_Criteria__r.Core_MDF_Value_1__c, Core_MDF_Criteria__r.Core_MDF_Value_2__c,
                                        Core_MDF_Criteria__r.Core_MDF_Value_3__c,Core_MDF_Criteria__r.Core_MDF_Value_4__c,Core_MDF_Criteria__r.Core_MDF_Value_5__c,
                                        Core_MDF_Criteria__r.Core_MDF_Value_6__c,Core_MDF_Criteria__r.Core_MDF_Value_7__c,Core_MDF_Criteria__r.Core_MDF_Value_8__c,
                                        Core_MDF_Criteria__r.Core_MDF_Value_9__c,Core_MDF_Criteria__r.Core_MDF_Value_10__c,
                                        Core_MDF_Approver_1__r.IsActive, Core_MDF_Approver_2__r.IsActive,Core_MDF_Approver_3__r.IsActive,Core_MDF_Approver_4__r.IsActive,Core_MDF_Approver_5__r.IsActive,
                                        Core_MDF_Approver_6__r.IsActive, Core_MDF_Approver_7__r.IsActive,Core_MDF_Approver_8__r.IsActive,Core_MDF_Approver_9__r.IsActive,Core_MDF_Approver_10__r.IsActive,
                                        Core_MDF_Is_Approver_From_Group_ind__c, Core_MDF_Group_Name_txt__c
                                        FROM Core_MDF_Approver__c WHERE (Core_MDF_Criteria__r.Core_MDF_Active__c = TRUE AND Core_MDF_Active__c = TRUE)
                                        ORDER BY Core_MDF_Step_Number__c LIMIT 50000]){
            if(appr.Core_MDF_Is_Approver_From_Group_ind__c){
                approverIdToGroupNameMap.put(appr.Id, appr.Core_MDF_Group_Name_txt__c);
            }
                                            
            if(crtWithApprovers.containsKey(appr.Core_MDF_Criteria__c)){
                crtWithApprovers.get(appr.Core_MDF_Criteria__c).add(appr);
            }
            else{
                List<Core_MDF_Approver__c> tempApprList = new List<Core_MDF_Approver__c>();
                tempApprList.add(appr);
                crtWithApprovers.put(appr.Core_MDF_Criteria__c,tempApprList);                                           
            }
            
            if(!approvalCriteriaMap.containsKey(appr.Core_MDF_Criteria__c)){
                //Create instance of Approval Criteria 
                Core_MDF_Criteria__c tempAC = new Core_MDF_Criteria__c();
                tempAC.Id = appr.Core_MDF_Criteria__c;
                tempAC.Core_MDF_Approval_Process__c = appr.Core_MDF_Criteria__r.Core_MDF_Approval_Process__c;
                tempAC.Core_MDF_Object_Type__c = appr.Core_MDF_Criteria__r.Core_MDF_Object_Type__c;                                         
                tempAC.Core_MDF_Field_Name_1__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_1__c;
                tempAC.Core_MDF_Field_Name_2__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_2__c;
                tempAC.Core_MDF_Field_Name_3__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_3__c;
                tempAC.Core_MDF_Field_Name_4__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_4__c;
                tempAC.Core_MDF_Field_Name_5__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_5__c;
                tempAC.Core_MDF_Field_Name_6__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_6__c;
                tempAC.Core_MDF_Field_Name_7__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_7__c;
                tempAC.Core_MDF_Field_Name_8__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_8__c;
                tempAC.Core_MDF_Field_Name_9__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_9__c;
                tempAC.Core_MDF_Field_Name_10__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_10__c;
                tempAC.Core_MDF_Operator_1__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_1__c;
                tempAC.Core_MDF_Operator_2__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_2__c;
                tempAC.Core_MDF_Operator_3__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_3__c;
                tempAC.Core_MDF_Operator_4__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_4__c;
                tempAC.Core_MDF_Operator_5__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_5__c;
                tempAC.Core_MDF_Operator_6__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_6__c;
                tempAC.Core_MDF_Operator_7__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_7__c;
                tempAC.Core_MDF_Operator_8__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_8__c;
                tempAC.Core_MDF_Operator_9__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_9__c;
                tempAC.Core_MDF_Operator_10__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_10__c;
                tempAC.Core_MDF_Value_1__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_1__c;
                tempAC.Core_MDF_Value_2__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_2__c;
                tempAC.Core_MDF_Value_3__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_3__c;
                tempAC.Core_MDF_Value_4__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_4__c;
                tempAC.Core_MDF_Value_5__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_5__c;
                tempAC.Core_MDF_Value_6__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_6__c;
                tempAC.Core_MDF_Value_7__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_7__c;
                tempAC.Core_MDF_Value_8__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_8__c;
                tempAC.Core_MDF_Value_9__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_9__c;
                tempAC.Core_MDF_Value_10__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_10__c;
                
                approvalCriteriaMap.put(tempAC.Id,tempAC);                
            }
        }
        
        //GroupId to Group Developer Name Map
        Map<Id,String> groupIdToNameMap = new Map<Id,String>();
        //Group Developer Name to List of User Id Map
        Map<String,List<Id>> groupNameToUserIdListMap = new Map<String,List<Id>>();
        
       
        if(approverIdToGroupNameMap != NULL && approverIdToGroupNameMap.Size() > 0){
            //Get GroupId
            for(Group grp : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN: approverIdToGroupNameMap.values()]){
                groupIdToNameMap.put(grp.Id, grp.DeveloperName);
            }
            
            //Get GroupMembers
            if(groupIdToNameMap != NULL && groupIdToNameMap.Size() > 0){
                for(GroupMember gm : [SELECT Id, UserOrGroupId, GroupId, Group.DeveloperName FROM GroupMember WHERE GroupId IN: groupIdToNameMap.keySet()]){                    
                    if(groupNameToUserIdListMap.containsKey(gm.Group.DeveloperName) &&
                       groupNameToUserIdListMap.get(gm.Group.DeveloperName) != NULL &&
                       groupNameToUserIdListMap.get(gm.Group.DeveloperName).Size() <= 10){
                        groupNameToUserIdListMap.get(gm.Group.DeveloperName).add(gm.UserOrGroupId);
                    }
                    else{
                        groupNameToUserIdListMap.put(gm.Group.DeveloperName, new List<Id>{gm.UserOrGroupId});
                    }                   
                }
            }
            
            //Check if 10 approvers are present in a group
            if(groupNameToUserIdListMap != NULL && groupNameToUserIdListMap.Size() > 0){
                for(String groupName : groupNameToUserIdListMap.keySet()){
                    integer approverCount = 10;
                    if(groupNameToUserIdListMap.get(groupName) != NULL){
                        integer userCountInGroup = groupNameToUserIdListMap.get(groupName).Size();                    
                        if(approverCount != userCountInGroup && userCountInGroup < approverCount){
                            Id userId = groupNameToUserIdListMap.get(groupName)[0];
                            integer usersToBeAdded = approverCount - userCountInGroup;                        
                            for(integer i = 0; i < usersToBeAdded; i++){                            
                                groupNameToUserIdListMap.get(groupName).add(userId);
                            }
                        }
                    }
                }
            }
        }
        
        boolean result = false;
        Map<SObject,Core_MDF_Criteria__c> sObjWithCriteria = new Map<SObject,Core_MDF_Criteria__c>{};
        // sObjWithCriteria map will have sObject as key and approval criteria as value.
        // This map will be used to avoid criteria determination if record is not qualified for auto approval.
        
        Map<String, Map<String, list<Id>>> sObjResultMap = new Map<String, Map<String, list<Id>>>();
        // sObjResultMap map will have sObject Id, autoApproved and approvalRequired as keys and Map<String, list<Id> as value.
        // The inner map will hold SobjectId and list of approvers if the sObject is not qualified for auto approval.
        Map<String,list<Id>> autoApprovedSObjects = new Map<String, List<Id>>();
        Map<String,list<Id>> nonAutoApprovedSObjects = new Map<String, List<Id>> ();
               
        Schema.DescribeSObjectResult sObjRes;
        Schema.DescribeFieldResult sObjField;
        
        //Classify the SObjects into auto Approval and non auto Approval
        for(SObject sObj: sObjectList){
            result = false;
            //Traversing all the criteria
            for(Core_MDF_Criteria__c cr : approvalCriteriaMap.values()){
                if(cr.Core_MDF_Object_Type__c == string.valueOf(sObj.getSObjectType())){
                    
                    //Validating first criteria
                    if(cr.Core_MDF_Field_Name_1__c != NULL){
                        sObjRes = sObj.getSObjectType().getDescribe();
                        System.debug('Result:' +sObjRes);
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_1__c).getDescribe();
                        System.debug('Result:::' +sObjField);
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_1__c)),cr.Core_MDF_Value_1__c,cr.Core_MDF_Operator_1__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 1:'+cr.Core_MDF_Field_Name_1__c+':'+result);
                    }
                    
                    //Validating second criteria
                    if(result && cr.Core_MDF_Field_Name_2__c != NULL){                        
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_2__c).getDescribe();
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_2__c)),cr.Core_MDF_Value_2__c,cr.Core_MDF_Operator_2__c,string.valueOf(sObjField.getType()));                      
                        System.debug('Result 2:'+cr.Core_MDF_Field_Name_2__c+':'+result);
                    }   
                    
                    //Validating third criteria
                    if(result && cr.Core_MDF_Field_Name_3__c != NULL){                        
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_3__c).getDescribe();
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_3__c)),cr.Core_MDF_Value_3__c,cr.Core_MDF_Operator_3__c,string.valueOf(sObjField.getType()));                        
                        System.debug('Result 3:'+cr.Core_MDF_Field_Name_3__c+':'+result);
                    }   
                    system.debug('field4::' + cr.Core_MDF_Field_Name_4__c);
                    //Validating fourth criteria
                    if(result && cr.Core_MDF_Field_Name_4__c != NULL){                        
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_4__c).getDescribe();
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_4__c)),cr.Core_MDF_Value_4__c,cr.Core_MDF_Operator_4__c,string.valueOf(sObjField.getType()));                       
                        System.debug('Result 4:'+result);
                    }
                    
                    //Validating fifth criteria
                    if( result && cr.Core_MDF_Field_Name_5__c != NULL){                       
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_5__c).getDescribe();
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_5__c)),cr.Core_MDF_Value_5__c,cr.Core_MDF_Operator_5__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 5:'+result);
                    }
                    
                    //Validating sixth criteria
                    if(result && cr.Core_MDF_Field_Name_6__c != NULL){
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_6__c).getDescribe();                     
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_6__c)),cr.Core_MDF_Value_6__c,cr.Core_MDF_Operator_6__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 6:'+result);
                    }
                   
                    //Validating seventh criteria
                    if(result && cr.Core_MDF_Field_Name_7__c != NULL){
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_7__c).getDescribe();                     
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_7__c)),cr.Core_MDF_Value_7__c,cr.Core_MDF_Operator_7__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 7:'+result);
                    }
                    
                    //Validating eighth criteria
                    if(result && cr.Core_MDF_Field_Name_8__c != NULL){
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_8__c).getDescribe();                     
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_8__c)),cr.Core_MDF_Value_8__c,cr.Core_MDF_Operator_8__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 8:'+result);
                    }
                    
                    //Validating ninth criteria
                    if(result && cr.Core_MDF_Field_Name_9__c != NULL){
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_9__c).getDescribe();                     
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_9__c)),cr.Core_MDF_Value_9__c,cr.Core_MDF_Operator_9__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 9:'+result);
                    }
                    
                    //Validating tenth criteria
                    if(result && cr.Core_MDF_Field_Name_10__c != NULL){
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_10__c).getDescribe();                     
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_10__c)),cr.Core_MDF_Value_10__c,cr.Core_MDF_Operator_10__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 10:'+result);
                    }
                                        
                    if(result){           
                        sObjWithCriteria.put(sObj,cr);
                        break; // Skip remaining criteria
                    }  
                }                           
            }
            if(!result){
                autoApprovedSObjects.put(String.valueOf(sObj.get('Id')),null);
            }
        }
        if(autoApprovedSObjects.keySet().size() >0){
            sObjResultMap.put('autoApproved',autoApprovedSObjects); 
        }
 
        //Assigning approvers for sObjects which are not qualified for auto approval                
        boolean ruleSetResult = false;
        Id crtId;
        for(SObject sObj: sObjWithCriteria.keySet()){
            //Traversing all the criteria
            crtId = sObjWithCriteria.get(sObj).Id;
            
            for(Core_MDF_Approver__c appr: crtWithApprovers.get(crtId)){
                
                for(Core_MDF_Criteria_Rule__c crRule: approverWithRules.get(appr.Id)){
                    system.debug('Approver:'+ crRule);
                    sObjField = sObjRes.fields.getMap().get(crRule.Core_MDF_Field_Name__c).getDescribe(); 
                    ruleSetResult = validateRule(String.valueOf(sObj.get(crRule.Core_MDF_Field_Name__c)),crRule.Core_MDF_Value__c,crRule.Core_MDF_Operator__c,string.valueOf(sObjField.getType()));
                    system.debug('ruleSetResult::' +ruleSetResult);
                    if(!ruleSetResult){
                        break; // Skip remaining criteria rules                        
                    }
                }
                        
                if(ruleSetResult){
                    System.debug('Approver Id:'+appr.Id);
                    list<Id> userIdList = new list<Id>();
                    
                    //If the approvers are from group
                    if(appr.Core_MDF_Is_Approver_From_Group_ind__c && appr.Core_MDF_Group_Name_txt__c != NULL &&
                       groupNameToUserIdListMap.containsKey(appr.Core_MDF_Group_Name_txt__c) &&
                       groupNameToUserIdListMap.get(appr.Core_MDF_Group_Name_txt__c) != NULL){
                           
                        userIdList.addAll(groupNameToUserIdListMap.get(appr.Core_MDF_Group_Name_txt__c));                                                   
                        
                        nonAutoApprovedSObjects.put(String.valueOf(sObj.get('Id')),userIdList);
                        
                        Map<String, List<Id>> approvalProcessMap = new Map<String, List<Id>>();
                        approvalProcessMap.put(sObjWithCriteria.get(sObj).Core_MDF_Approval_Process__c,null);
                        sObjResultMap.put(String.valueOf(sObj.get('Id')),approvalProcessMap);
                           
                        break; // Skip remaining approvers
                        
                    }else{
                    Id defaultApproverId;
                    if(appr.Core_MDF_Approver_1__c != NULL){
                        if(appr.Core_MDF_Approver_1__c != NULL && appr.Core_MDF_Approver_1__r.isActive){
                            userIdList.add(appr.Core_MDF_Approver_1__c);
                            defaultApproverId = appr.Core_MDF_Approver_1__c;
                        }
                        //Setting approver 1 as approvers 2, if approver 2 is not available.
                        if(appr.Core_MDF_Approver_2__c != NULL && appr.Core_MDF_Approver_2__r.isActive){
                            userIdList.add(appr.Core_MDF_Approver_2__c);
                            if(defaultApproverId == NULL){ 
                                defaultApproverId = appr.Core_MDF_Approver_2__c;
                            }
                        }
                        else{
                            if(defaultApproverId != NULL){
                                userIdList.add(defaultApproverId);
                            }
                        }
                          
                        //Setting approver 1 as approvers 3, if approver 3 is not available.
                        if(appr.Core_MDF_Approver_3__c != NULL && appr.Core_MDF_Approver_3__r.isActive){
                            userIdList.add(appr.Core_MDF_Approver_3__c);
                            if(defaultApproverId == NULL){ 
                                defaultApproverId = appr.Core_MDF_Approver_3__c;
                            }
                        }
                        else{
                            if(defaultApproverId != NULL){
                                userIdList.add(defaultApproverId);
                            }
                        }
                        System.debug('appr.Core_MDF_Approver_4__c '+appr.Core_MDF_Approver_4__c);
                        System.debug('appr.Core_MDF_Approver_4__r.isActive '+appr.Core_MDF_Approver_4__r.isActive);
                        //Setting approver 1 as approvers 4, if approver 4 is not available.                            
                        if(appr.Core_MDF_Approver_4__c != NULL && appr.Core_MDF_Approver_4__r.isActive){
                            userIdList.add(appr.Core_MDF_Approver_4__c);
                            if(defaultApproverId == NULL){ 
                                defaultApproverId = appr.Core_MDF_Approver_4__c;
                            }
                        }
                        else{
                            if(defaultApproverId != NULL){
                                userIdList.add(defaultApproverId);
                            }
                        }
                        
                        //Setting approver 1 as approvers 5, if approver 5 is not available.    
                        if(appr.Core_MDF_Approver_5__c != NULL && appr.Core_MDF_Approver_5__r.isActive){
                            userIdList.add(appr.Core_MDF_Approver_5__c);
                            if(defaultApproverId == NULL){ 
                                defaultApproverId = appr.Core_MDF_Approver_5__c;
                            }
                        }
                        else{
                            if(defaultApproverId != NULL){
                                userIdList.add(defaultApproverId);
                            }
                        }
                        
                        //Setting approver 1 as approvers 6, if approver 6 is not available.                            
                        if(appr.Core_MDF_Approver_6__c != NULL && appr.Core_MDF_Approver_6__r.isActive){
                            userIdList.add(appr.Core_MDF_Approver_6__c);
                            if(defaultApproverId == NULL){ 
                                defaultApproverId = appr.Core_MDF_Approver_6__c;
                            }
                        }
                        else{
                            if(defaultApproverId != NULL){
                                userIdList.add(defaultApproverId);
                            }
                        }
                        
                         //Setting approver 1 as approvers 7, if approver 7 is not available.                            
                        if(appr.Core_MDF_Approver_7__c != NULL && appr.Core_MDF_Approver_7__r.isActive){
                            userIdList.add(appr.Core_MDF_Approver_7__c);
                            if(defaultApproverId == NULL){ 
                                defaultApproverId = appr.Core_MDF_Approver_7__c;
                            }
                        }
                        else{
                            if(defaultApproverId != NULL){
                                userIdList.add(defaultApproverId);
                            }
                        }
                        
                         //Setting approver 1 as approvers 8, if approver 8 is not available.                            
                        if(appr.Core_MDF_Approver_8__c != NULL && appr.Core_MDF_Approver_8__r.isActive){
                            userIdList.add(appr.Core_MDF_Approver_8__c);
                            if(defaultApproverId == NULL){ 
                                defaultApproverId = appr.Core_MDF_Approver_8__c;
                            }
                        }
                        else{
                            if(defaultApproverId != NULL){
                                userIdList.add(defaultApproverId);
                            }
                        }
                        
                         //Setting approver 1 as approvers 9, if approver 9 is not available.                            
                        if(appr.Core_MDF_Approver_9__c != NULL && appr.Core_MDF_Approver_9__r.isActive){
                            userIdList.add(appr.Core_MDF_Approver_9__c);
                            if(defaultApproverId == NULL){ 
                                defaultApproverId = appr.Core_MDF_Approver_9__c;
                            }
                        }
                        else{
                            if(defaultApproverId != NULL){
                                userIdList.add(defaultApproverId);
                            }
                        }
                        
                         //Setting approver 1 as approvers 10, if approver 10 is not available.                            
                        if(appr.Core_MDF_Approver_10__c != NULL && appr.Core_MDF_Approver_10__r.isActive){
                            userIdList.add(appr.Core_MDF_Approver_10__c);
                            if(defaultApproverId == NULL){ 
                                defaultApproverId = appr.Core_MDF_Approver_10__c;
                            }
                        }
                        else{
                            if(defaultApproverId != NULL){
                                userIdList.add(defaultApproverId);
                            }
                        }

                        if(userIdList != NULL && !userIdList.isEmpty()){
                            if(userIdList.size() < 10){
                                for(Integer loopOver = 0; loopOver < (10 - userIdList.size()); loopOver++){
                                    userIdList.add(defaultApproverId);
                                }
                            }
                            nonAutoApprovedSObjects.put(String.valueOf(sObj.get('Id')),userIdList);
                        }                        
                                
                        Map<String, List<Id>> approvalProcessMap = new Map<String, List<Id>>();
                        approvalProcessMap.put(sObjWithCriteria.get(sObj).Core_MDF_Approval_Process__c,null);
                        sObjResultMap.put(String.valueOf(sObj.get('Id')),approvalProcessMap);
                        break; // Skip remaining approvers 
                    } 
                    }
                }
            }
                

            if(!nonAutoApprovedSObjects.containsKey(String.valueOf(sObj.get('Id')))){
                //Sobjects which are not qualified for auto approval and does not satisfies any of the rule set 
                nonAutoApprovedSObjects.put(String.valueOf(sObj.get('Id')),NULL);
            }
        }    
        //Adding SObject into map
        if(nonAutoApprovedSObjects != NULL){
            sObjResultMap.put('approvalRequired', nonAutoApprovedSObjects);
        }       
        System.debug('sObjResultMap:'+sObjResultMap);
        return sObjResultMap;
    }*/


    /****************************************************************************************************************************************
    Method Name:                                             setApprovers
    @return  :                                               --
    @parameters:                                             List of SObject, campaigns oldMap, isInsert and isUpdate                                 
    Description:                                             Setting approvers based on criteria. This method allow to add the user as Approvers from multiple Approver records
    Added By:                                                Accenture – JB  -  07/18/2022
    Modified By:                  Date:                      Changes: 
    Accenture – JB                07/18/2022                 Created.
    *****************************************************************************************************************************************/ 
    /*public static Map<String, Map<String, list<Id>>> setApproversFromMultipleRecords(list<SObject> sObjectList){ 
            
        //Putting required data in collections
        
        //Mapping criteria rules with approvers set.
        Map<Id,list<Core_MDF_Criteria_Rule__c>> approverWithRules = new Map<Id,list<Core_MDF_Criteria_Rule__c>>{};
        
        for(Core_MDF_Criteria_Rule__c cr: [SELECT Id, Core_MDF_Approver__c, Core_MDF_Field_Name__c, Core_MDF_Object_Type__c, Core_MDF_Operator__c,
                            Core_MDF_Value__c FROM Core_MDF_Criteria_Rule__c WHERE Core_MDF_Approver__r.Core_MDF_Active__c = TRUE] ){
            if(approverWithRules.containsKey(cr.Core_MDF_Approver__c)){
                approverWithRules.get(cr.Core_MDF_Approver__c).add(cr);
            }
            else{
                List<Core_MDF_Criteria_Rule__c> tempCRList = new List<Core_MDF_Criteria_Rule__c>();
                tempCRList.add(cr);
                approverWithRules.put(cr.Core_MDF_Approver__c,tempCRList);              
            }
        }
        system.debug('<<approverWithRules>>'+approverWithRules);
        // Mapping approval criteria with approvers set.
        Map<Id,List<Core_MDF_Approver__c>> crtWithApprovers = new Map<Id,List<Core_MDF_Approver__c>>{}; 
        Map<Id,Core_MDF_Criteria__c> approvalCriteriaMap = new Map<Id,Core_MDF_Criteria__c>();
        
        //ApproverId to Group Developer Name Map
        Map<Id, String> approverIdToGroupNameMap = new Map<Id,String>();
        
        for(Core_MDF_Approver__c appr: [SELECT Id, Core_MDF_Step_Number__c, Core_MDF_Approver_1__c, Core_MDF_Approver_2__c, Core_MDF_Approver_3__c, Core_MDF_Approver_4__c,
                                        Core_MDF_Approver_5__c, Core_MDF_Approver_6__c, Core_MDF_Approver_7__c, Core_MDF_Approver_8__c, Core_MDF_Approver_9__c,
                                        Core_MDF_Approver_10__c, Core_MDF_Criteria__r.Core_MDF_Approval_Process__c, Core_MDF_Criteria__r.Core_MDF_Field_Name_1__c,
                                        Core_MDF_Criteria__r.Core_MDF_Field_Name_2__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_3__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_4__c,
                                        Core_MDF_Criteria__r.Core_MDF_Field_Name_5__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_6__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_7__c,
                                        Core_MDF_Criteria__r.Core_MDF_Field_Name_8__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_9__c,Core_MDF_Criteria__r.Core_MDF_Field_Name_10__c,
                                        Core_MDF_Criteria__r.Core_MDF_Object_Type__c, Core_MDF_Criteria__r.Core_MDF_Operator_1__c,Core_MDF_Criteria__r.Core_MDF_Operator_10__c,
                                        Core_MDF_Criteria__r.Core_MDF_Operator_2__c, Core_MDF_Criteria__r.Core_MDF_Operator_3__c,Core_MDF_Criteria__r.Core_MDF_Operator_4__c,
                                        Core_MDF_Criteria__r.Core_MDF_Operator_5__c,Core_MDF_Criteria__r.Core_MDF_Operator_6__c,Core_MDF_Criteria__r.Core_MDF_Operator_7__c,Core_MDF_Criteria__r.Core_MDF_Operator_8__c,
                                        Core_MDF_Criteria__r.Core_MDF_Operator_9__c,Core_MDF_Criteria__r.Core_MDF_Value_1__c, Core_MDF_Criteria__r.Core_MDF_Value_2__c,
                                        Core_MDF_Criteria__r.Core_MDF_Value_3__c,Core_MDF_Criteria__r.Core_MDF_Value_4__c,Core_MDF_Criteria__r.Core_MDF_Value_5__c,
                                        Core_MDF_Criteria__r.Core_MDF_Value_6__c,Core_MDF_Criteria__r.Core_MDF_Value_7__c,Core_MDF_Criteria__r.Core_MDF_Value_8__c,
                                        Core_MDF_Criteria__r.Core_MDF_Value_9__c,Core_MDF_Criteria__r.Core_MDF_Value_10__c,
                                        Core_MDF_Approver_1__r.IsActive, Core_MDF_Approver_2__r.IsActive,Core_MDF_Approver_3__r.IsActive,Core_MDF_Approver_4__r.IsActive,Core_MDF_Approver_5__r.IsActive,
                                        Core_MDF_Approver_6__r.IsActive, Core_MDF_Approver_7__r.IsActive,Core_MDF_Approver_8__r.IsActive,Core_MDF_Approver_9__r.IsActive,Core_MDF_Approver_10__r.IsActive,
                                        Core_MDF_Is_Approver_From_Group_ind__c, Core_MDF_Group_Name_txt__c
                                        FROM Core_MDF_Approver__c WHERE (Core_MDF_Criteria__r.Core_MDF_Active__c = TRUE AND Core_MDF_Active__c = TRUE)
                                        ORDER BY Core_MDF_Step_Number__c, Core_MDF_Criteria_Rule_Count__c DESC LIMIT 50000]){
                                            system.debug('Entered inside approvers');
                                            system.debug('appr.Core_MDF_Approver_1__c:'+appr.Core_MDF_Approver_1__c);
            if(appr.Core_MDF_Is_Approver_From_Group_ind__c){
                approverIdToGroupNameMap.put(appr.Id, appr.Core_MDF_Group_Name_txt__c);
            }
                                            
            if(crtWithApprovers.containsKey(appr.Core_MDF_Criteria__c)){
                crtWithApprovers.get(appr.Core_MDF_Criteria__c).add(appr);
                system.debug('<<CRTWithApprovers>>'+crtWithApprovers);
            }
            else{
                List<Core_MDF_Approver__c> tempApprList = new List<Core_MDF_Approver__c>();
                tempApprList.add(appr);
                crtWithApprovers.put(appr.Core_MDF_Criteria__c,tempApprList);                                           
            }
            
            if(!approvalCriteriaMap.containsKey(appr.Core_MDF_Criteria__c)){
                //Create instance of Approval Criteria 
                system.debug('<<Entered Inside>>');
                Core_MDF_Criteria__c tempAC = new Core_MDF_Criteria__c();
                tempAC.Id = appr.Core_MDF_Criteria__c;
                tempAC.Core_MDF_Approval_Process__c = appr.Core_MDF_Criteria__r.Core_MDF_Approval_Process__c;
                tempAC.Core_MDF_Object_Type__c = appr.Core_MDF_Criteria__r.Core_MDF_Object_Type__c;                                         
                tempAC.Core_MDF_Field_Name_1__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_1__c;
                tempAC.Core_MDF_Field_Name_2__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_2__c;
                tempAC.Core_MDF_Field_Name_3__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_3__c;
                tempAC.Core_MDF_Field_Name_4__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_4__c;
                tempAC.Core_MDF_Field_Name_5__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_5__c;
                tempAC.Core_MDF_Field_Name_6__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_6__c;
                tempAC.Core_MDF_Field_Name_7__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_7__c;
                tempAC.Core_MDF_Field_Name_8__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_8__c;
                tempAC.Core_MDF_Field_Name_9__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_9__c;
                tempAC.Core_MDF_Field_Name_10__c = appr.Core_MDF_Criteria__r.Core_MDF_Field_Name_10__c;
                tempAC.Core_MDF_Operator_1__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_1__c;
                tempAC.Core_MDF_Operator_2__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_2__c;
                tempAC.Core_MDF_Operator_3__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_3__c;
                tempAC.Core_MDF_Operator_4__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_4__c;
                tempAC.Core_MDF_Operator_5__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_5__c;
                tempAC.Core_MDF_Operator_6__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_6__c;
                tempAC.Core_MDF_Operator_7__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_7__c;
                tempAC.Core_MDF_Operator_8__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_8__c;
                tempAC.Core_MDF_Operator_9__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_9__c;
                tempAC.Core_MDF_Operator_10__c = appr.Core_MDF_Criteria__r.Core_MDF_Operator_10__c;
                tempAC.Core_MDF_Value_1__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_1__c;
                tempAC.Core_MDF_Value_2__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_2__c;
                tempAC.Core_MDF_Value_3__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_3__c;
                tempAC.Core_MDF_Value_4__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_4__c;
                tempAC.Core_MDF_Value_5__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_5__c;
                tempAC.Core_MDF_Value_6__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_6__c;
                tempAC.Core_MDF_Value_7__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_7__c;
                tempAC.Core_MDF_Value_8__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_8__c;
                tempAC.Core_MDF_Value_9__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_9__c;
                tempAC.Core_MDF_Value_10__c = appr.Core_MDF_Criteria__r.Core_MDF_Value_10__c;
                
                approvalCriteriaMap.put(tempAC.Id,tempAC);                
            }
        }
        system.debug('<<approvalCriteriaMap>>'+approvalCriteriaMap);
        //GroupId to Group Developer Name Map
        Map<Id,String> groupIdToNameMap = new Map<Id,String>();
        //Group Developer Name to List of User Id Map
        Map<String,List<Id>> groupNameToUserIdListMap = new Map<String,List<Id>>();
        
    
        if(approverIdToGroupNameMap != NULL && approverIdToGroupNameMap.Size() > 0){
            //Get GroupId
            for(Group grp : [SELECT Id, DeveloperName FROM Group WHERE DeveloperName IN: approverIdToGroupNameMap.values()]){
                groupIdToNameMap.put(grp.Id, grp.DeveloperName);
            }
            
            //Get GroupMembers
            if(groupIdToNameMap != NULL && groupIdToNameMap.Size() > 0){
                for(GroupMember gm : [SELECT Id, UserOrGroupId, GroupId, Group.DeveloperName FROM GroupMember WHERE GroupId IN: groupIdToNameMap.keySet()]){                    
                    if(groupNameToUserIdListMap.containsKey(gm.Group.DeveloperName) &&
                    groupNameToUserIdListMap.get(gm.Group.DeveloperName) != NULL &&
                    groupNameToUserIdListMap.get(gm.Group.DeveloperName).Size() <= 10){
                        groupNameToUserIdListMap.get(gm.Group.DeveloperName).add(gm.UserOrGroupId);
                    }
                    else{
                        groupNameToUserIdListMap.put(gm.Group.DeveloperName, new List<Id>{gm.UserOrGroupId});
                    }                   
                }
            }
            
        }
        
        boolean result = false;
        Map<SObject,Core_MDF_Criteria__c> sObjWithCriteria = new Map<SObject,Core_MDF_Criteria__c>{};
        // sObjWithCriteria map will have sObject as key and approval criteria as value.
        // This map will be used to avoid criteria determination if record is not qualified for auto approval.
        
        Map<String, Map<String, list<Id>>> sObjResultMap = new Map<String, Map<String, list<Id>>>();
        // sObjResultMap map will have sObject Id, autoApproved and approvalRequired as keys and Map<String, list<Id> as value.
        // The inner map will hold SobjectId and list of approvers if the sObject is not qualified for auto approval.
        Map<String,list<Id>> autoApprovedSObjects = new Map<String, List<Id>>();
        Map<String,list<Id>> nonAutoApprovedSObjects = new Map<String, List<Id>> ();
            
        Schema.DescribeSObjectResult sObjRes;
        Schema.DescribeFieldResult sObjField;
        
        //Classify the SObjects into auto Approval and non auto Approval
        for(SObject sObj: sObjectList){
            result = false;
            //Traversing all the criteria
            for(Core_MDF_Criteria__c cr : approvalCriteriaMap.values()){
                if(cr.Core_MDF_Object_Type__c == string.valueOf(sObj.getSObjectType())){
                    
                    //Validating first criteria
                    if(cr.Core_MDF_Field_Name_1__c != NULL){
                        sObjRes = sObj.getSObjectType().getDescribe();
                        System.debug('Result:' +sObjRes);
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_1__c).getDescribe();
                        System.debug('Result:::' +sObjField);
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_1__c)),cr.Core_MDF_Value_1__c,cr.Core_MDF_Operator_1__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 1:'+cr.Core_MDF_Field_Name_1__c+':'+result);
                    }
                    
                    //Validating second criteria
                    if(result && cr.Core_MDF_Field_Name_2__c != NULL){                        
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_2__c).getDescribe();
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_2__c)),cr.Core_MDF_Value_2__c,cr.Core_MDF_Operator_2__c,string.valueOf(sObjField.getType()));                      
                        System.debug('Result 2:'+cr.Core_MDF_Field_Name_2__c+':'+result);
                    }   
                    
                    //Validating third criteria
                    if(result && cr.Core_MDF_Field_Name_3__c != NULL){                        
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_3__c).getDescribe();
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_3__c)),cr.Core_MDF_Value_3__c,cr.Core_MDF_Operator_3__c,string.valueOf(sObjField.getType()));                        
                        System.debug('Result 3:'+cr.Core_MDF_Field_Name_3__c+':'+result);
                    }   
                    system.debug('field4::' + cr.Core_MDF_Field_Name_4__c);
                    //Validating fourth criteria
                    if(result && cr.Core_MDF_Field_Name_4__c != NULL){                        
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_4__c).getDescribe();
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_4__c)),cr.Core_MDF_Value_4__c,cr.Core_MDF_Operator_4__c,string.valueOf(sObjField.getType()));                       
                        System.debug('Result 4:'+result);
                    }
                    
                    //Validating fifth criteria
                    if( result && cr.Core_MDF_Field_Name_5__c != NULL){                       
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_5__c).getDescribe();
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_5__c)),cr.Core_MDF_Value_5__c,cr.Core_MDF_Operator_5__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 5:'+result);
                    }
                    
                    //Validating sixth criteria
                    if(result && cr.Core_MDF_Field_Name_6__c != NULL){
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_6__c).getDescribe();                     
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_6__c)),cr.Core_MDF_Value_6__c,cr.Core_MDF_Operator_6__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 6:'+result);
                    }
                
                    //Validating seventh criteria
                    if(result && cr.Core_MDF_Field_Name_7__c != NULL){
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_7__c).getDescribe();                     
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_7__c)),cr.Core_MDF_Value_7__c,cr.Core_MDF_Operator_7__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 7:'+result);
                    }
                    
                    //Validating eighth criteria
                    if(result && cr.Core_MDF_Field_Name_8__c != NULL){
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_8__c).getDescribe();                     
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_8__c)),cr.Core_MDF_Value_8__c,cr.Core_MDF_Operator_8__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 8:'+result);
                    }
                    
                    //Validating ninth criteria
                    if(result && cr.Core_MDF_Field_Name_9__c != NULL){
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_9__c).getDescribe();                     
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_9__c)),cr.Core_MDF_Value_9__c,cr.Core_MDF_Operator_9__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 9:'+result);
                    }
                    
                    //Validating tenth criteria
                    if(result && cr.Core_MDF_Field_Name_10__c != NULL){
                        sObjField = sObjRes.fields.getMap().get(cr.Core_MDF_Field_Name_10__c).getDescribe();                     
                        result = validateRule(String.valueOf(sObj.get(cr.Core_MDF_Field_Name_10__c)),cr.Core_MDF_Value_10__c,cr.Core_MDF_Operator_10__c,string.valueOf(sObjField.getType()));
                        System.debug('Result 10:'+result);
                    }
                                        
                    if(result){           
                        sObjWithCriteria.put(sObj,cr);
                        break; // Skip remaining criteria
                    }  
                }                           
            }
            if(!result){
                autoApprovedSObjects.put(String.valueOf(sObj.get('Id')),null);
            }
        }
        if(autoApprovedSObjects.keySet().size() >0){
            sObjResultMap.put('autoApproved',autoApprovedSObjects); 
        }

        //Assigning approvers for sObjects which are not qualified for auto approval                
        boolean ruleSetResult = false;
        Id defaultApproverId;
        Id crtId;
        for(SObject sObj: sObjWithCriteria.keySet()){
            //Traversing all the criteria
            crtId = sObjWithCriteria.get(sObj).Id;
            
            list<Id> userIdList = new list<Id>();
            Set<Id> userIdSet = new Set<Id>();

            for(Core_MDF_Approver__c appr: crtWithApprovers.get(crtId)){
                //approverNotFromGroup = false;
                system.debug('Approver Record:'+ appr);
                for(Core_MDF_Criteria_Rule__c crRule: approverWithRules.get(appr.Id)){
                    system.debug('Approver:'+ crRule);
                    sObjField = sObjRes.fields.getMap().get(crRule.Core_MDF_Field_Name__c).getDescribe(); 
                    ruleSetResult = validateRule(String.valueOf(sObj.get(crRule.Core_MDF_Field_Name__c)),crRule.Core_MDF_Value__c,crRule.Core_MDF_Operator__c,string.valueOf(sObjField.getType()));
                    system.debug('ruleSetResult::' +ruleSetResult);
                    if(!ruleSetResult){
                        break; // Skip remaining criteria rules                        
                    }
                }
                        
                if(ruleSetResult){
                    System.debug('Approver Id:'+appr.Core_MDF_Approver_1__r.Id);
                    
                    //If the approvers are from group
                    if(appr.Core_MDF_Is_Approver_From_Group_ind__c && appr.Core_MDF_Group_Name_txt__c != NULL &&
                        groupNameToUserIdListMap.containsKey(appr.Core_MDF_Group_Name_txt__c) &&
                        groupNameToUserIdListMap.get(appr.Core_MDF_Group_Name_txt__c) != NULL){
                        
                        userIdSet.addAll(new Set<Id>(groupNameToUserIdListMap.get(appr.Core_MDF_Group_Name_txt__c)));
                        
                        //Set first user from group as default Approver
                        if(defaultApproverId == null && groupNameToUserIdListMap.get(appr.Core_MDF_Group_Name_txt__c).size() > 0){
                            defaultApproverId = groupNameToUserIdListMap.get(appr.Core_MDF_Group_Name_txt__c)[0];
                        }
                    }else{
                        System.debug('appr.Core_MDF_Approver_1__c '+ appr.Core_MDF_Approver_1__c);

                        if(appr.Core_MDF_Approver_1__c != NULL){
                            if(appr.Core_MDF_Approver_1__c != NULL && appr.Core_MDF_Approver_1__r.isActive){
                                userIdSet.add(appr.Core_MDF_Approver_1__c);
                                if(defaultApproverId == NULL){
                                    defaultApproverId = appr.Core_MDF_Approver_1__c;
                                }
                            }

                            //Setting approver 1 as approvers 2, if approver 2 is not available.
                            if(appr.Core_MDF_Approver_2__c != NULL && appr.Core_MDF_Approver_2__r.isActive){
                                userIdSet.add(appr.Core_MDF_Approver_2__c);
                                if(defaultApproverId == NULL){ 
                                    defaultApproverId = appr.Core_MDF_Approver_2__c;
                                }
                            }
                            
                            //Setting approver 1 as approvers 3, if approver 3 is not available.
                            if(appr.Core_MDF_Approver_3__c != NULL && appr.Core_MDF_Approver_3__r.isActive){
                                userIdSet.add(appr.Core_MDF_Approver_3__c);
                                if(defaultApproverId == NULL){ 
                                    defaultApproverId = appr.Core_MDF_Approver_3__c;
                                }
                            }

                            //Setting approver 1 as approvers 4, if approver 4 is not available.                            
                            if(appr.Core_MDF_Approver_4__c != NULL && appr.Core_MDF_Approver_4__r.isActive){
                                userIdSet.add(appr.Core_MDF_Approver_4__c);
                                if(defaultApproverId == NULL){ 
                                    defaultApproverId = appr.Core_MDF_Approver_4__c;
                                }
                            }
                            
                            //Setting approver 1 as approvers 5, if approver 5 is not available.    
                            if(appr.Core_MDF_Approver_5__c != NULL && appr.Core_MDF_Approver_5__r.isActive){
                                userIdSet.add(appr.Core_MDF_Approver_5__c);
                                if(defaultApproverId == NULL){ 
                                    defaultApproverId = appr.Core_MDF_Approver_5__c;
                                }
                            }
                            
                            //Setting approver 1 as approvers 6, if approver 6 is not available.                            
                            if(appr.Core_MDF_Approver_6__c != NULL && appr.Core_MDF_Approver_6__r.isActive){
                                userIdSet.add(appr.Core_MDF_Approver_6__c);
                                if(defaultApproverId == NULL){ 
                                    defaultApproverId = appr.Core_MDF_Approver_6__c;
                                }
                            }
                            
                            //Setting approver 1 as approvers 7, if approver 7 is not available.                            
                            if(appr.Core_MDF_Approver_7__c != NULL && appr.Core_MDF_Approver_7__r.isActive){
                                userIdSet.add(appr.Core_MDF_Approver_7__c);
                                if(defaultApproverId == NULL){ 
                                    defaultApproverId = appr.Core_MDF_Approver_7__c;
                                }
                            }
                            
                            //Setting approver 1 as approvers 8, if approver 8 is not available.                            
                            if(appr.Core_MDF_Approver_8__c != NULL && appr.Core_MDF_Approver_8__r.isActive){
                                userIdSet.add(appr.Core_MDF_Approver_8__c);
                                if(defaultApproverId == NULL){ 
                                    defaultApproverId = appr.Core_MDF_Approver_8__c;
                                }
                            }
                            
                            //Setting approver 1 as approvers 9, if approver 9 is not available.                            
                            if(appr.Core_MDF_Approver_9__c != NULL && appr.Core_MDF_Approver_9__r.isActive){
                                userIdSet.add(appr.Core_MDF_Approver_9__c);
                                if(defaultApproverId == NULL){ 
                                    defaultApproverId = appr.Core_MDF_Approver_9__c;
                                }
                            }
                            
                            //Setting approver 1 as approvers 10, if approver 10 is not available.                            
                            if(appr.Core_MDF_Approver_10__c != NULL && appr.Core_MDF_Approver_10__r.isActive){
                                userIdSet.add(appr.Core_MDF_Approver_10__c);
                                if(defaultApproverId == NULL){ 
                                    defaultApproverId = appr.Core_MDF_Approver_10__c;
                                }
                            }
                        }
                    }

                    //Skip if we have 10 or more approvers
                    if(!userIdSet.isEmpty() && userIdSet.size() >= 10){
                        break; // Skip remaining approvers 
                    }
                }
            }
            
            if(userIdSet != null && !userIdSet.isEmpty()){
                System.debug('userIdSet:'+ userIdSet + ' SIZE::' + userIdSet.size());

                if(userIdSet.size() < 10){ // Add default Approver as approver for the remaining Approvers
                    userIdList = new List<Id>(userIdSet);
                    for(Integer loopOver = 0; loopOver < (10 - userIdSet.size()); loopOver++){
                        userIdList.add(defaultApproverId);
                    }
                }else if(userIdSet.size() >= 10){ // Get first 10 approvers if we have more than 10 Approvers
                    userIdList = new List<Id>();
                    
                    Integer approverCount = 0;
                    for(Id approverId : userIdSet){
                        userIdList.add(approverId);
                        approverCount++;

                        //Skip if we added 10 approvers in the final List
                        if(approverCount == 10) break;
                    }
                }

                System.debug('userIdList:'+ userIdList + ' SIZE::' + userIdList.size());

                nonAutoApprovedSObjects.put(String.valueOf(sObj.get('Id')), userIdList);

                Map<String, List<Id>> approvalProcessMap = new Map<String, List<Id>>();
                approvalProcessMap.put(sObjWithCriteria.get(sObj).Core_MDF_Approval_Process__c,null);
                sObjResultMap.put(String.valueOf(sObj.get('Id')),approvalProcessMap);
            }

            if(!nonAutoApprovedSObjects.containsKey(String.valueOf(sObj.get('Id')))){
                //Sobjects which are not qualified for auto approval and does not satisfies any of the rule set 
                nonAutoApprovedSObjects.put(String.valueOf(sObj.get('Id')),NULL);
            }
        }    
        //Adding SObject into map
        if(nonAutoApprovedSObjects != NULL){
            sObjResultMap.put('approvalRequired', nonAutoApprovedSObjects);
        }       
        System.debug('sObjResultMap:'+sObjResultMap);
        return sObjResultMap;
    }*/
    
      
/****************************************************************************************************************************************
    Method Name:                                             validateRule
    @return  :                                               return boolean.
    @parameters:                                             recordValue, Operator, Value and fieldType
    Description:                                             Compares fieldValue with criteria rule value based on criteria operator.
    Added By:                                                Accenture – Shridhar K  -  08/06/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Shridhar K        08/06/2018                 Created.
*****************************************************************************************************************************************/ 
    public static boolean validateRule(String recValue, String crtValue, String operator, String fieldType){
        
        // Classifying the field type.
        // String comparison
        String stringType = 'REFERENCE;STRING;BOOLEAN;EMAIL;PICKLIST;PHONE;ENCRYPTEDSTRING;TEXTAREA;URL';
        String numberType = 'CURRENCY;DOUBLE;PERCENT';
        String dateType = 'DATE;DATETIME;TIME';
        String multiSelectType = 'MULTIPICKLIST';
        
        //Comparing Null/Blank values
        if(String.isBlank(crtValue) &&
            ((operator == 'Equal' &&  String.isBlank(recValue)) || 
            (operator == 'Not Equal' && !(String.isBlank(recValue))) ||
            (operator == 'In' && String.isBlank(recValue)) ||
            (operator == 'Not In' && !String.isBlank(recValue)))){
                return true;
        }
        if(String.isBlank(recValue) &&
            ((operator == 'Equal' &&  String.isBlank(crtValue)) || 
            (operator == 'Not Equal' && !(String.isBlank(crtValue))) ||
            (operator == 'In' && String.isBlank(crtValue)) ||
            (operator == 'Not In' && !String.isBlank(crtValue)))){
                return true;
        }
        if(String.isBlank(crtValue) || String.isBlank(recValue)){
            return false;
        }
        
        //Comparing other than blank values        
        //String type comparison with all appropriate operators
        if(stringType.contains(fieldType)){
            if((operator == 'Not Equal' && recValue != crtValue) || (operator == 'Equal' && recValue == crtValue)){            
                return true;
            }
            if(operator == 'In'){
                list<String> mainString = crtValue.toLowerCase().split(';');
                /*if(mainString.contains(recValue.toLowerCase())){
                    return true;
                }
                else{
                    return false;
                }*/
                return mainString.contains(recValue.toLowerCase());
            }
            if(operator == 'Not In'){
                list<String> mainString = crtValue.toLowerCase().split(';');
                /*if(!mainString.contains(recValue.toLowerCase())){
                    return true;
                }
                else{
                    return false;
                }*/
                return !mainString.contains(recValue.toLowerCase());
            }               
            return false;
        }
        
        //Number type comparison with all appropriate operators
        if(numberType.contains(fieldType)){
            if((operator == 'Not Equal' && Decimal.valueof(recValue) != Decimal.valueof(crtValue)) || (operator == 'Equal' && Decimal.valueof(recValue) == Decimal.valueof(crtValue)) 
                || (operator == 'Greater Than' && Decimal.valueof(recValue) > Decimal.valueof(crtValue)) || (operator == 'Greater Than or Equal' && Decimal.valueof(recValue) >= Decimal.valueof(crtValue))
                || (operator == 'Less Than' && Decimal.valueof(recValue) < Decimal.valueof(crtValue)) || (operator == 'Less Than or Equal' && Decimal.valueof(recValue) <= Decimal.valueof(crtValue))){
                return true;
            }
            else
            {
                return false;
            }
        }
        
        //Date type comparison with all appropriate operators
        if(dateType.contains(fieldType)){
            if((operator == 'Not Equal' && Date.valueof(recValue) != Date.valueof(crtValue)) || (operator == 'Equal' && Date.valueof(recValue) == Date.valueof(crtValue)) 
                || (operator == 'Greater Than' && Date.valueof(recValue) > Date.valueof(crtValue)) || (operator == 'Greater Than or Equal' && Date.valueof(recValue) >= Date.valueof(crtValue))
                || (operator == 'Less Than' && Date.valueof(recValue) < Date.valueof(crtValue)) || (operator == 'Less Than or Equal' && Date.valueof(recValue) <= Date.valueof(crtValue))){
               
                return true;
            }
            else{
                return false;
            }
        }
        //Multi-Select type comparison with all appropriate operators
        if(multiSelectType.contains(fieldType)){
            //ATHR Fix WW19 - Start
            Set<String> mainValues = new Set<String>(crtValue.toLowerCase().split(';'));
            List<String> recValues = recValue.toLowerCase().split(';');
            switch on operator {
                when 'Equal' {
                    if (mainValues.size() != recValues.size()) {
                        return false;
                    }
                    for (String val : recValues) {
                        if (!mainValues.contains(val)) {
                            return false;
                        }
                    }
                    return true;
                }
                when 'Not Equal' {
                    for (String val : recValues) {
                        if (!mainValues.contains(val)) {
                            return true;
                        }
                    }
                    return false;
                }
                when 'In' {
                    for (String val : recValues) {
                        if (!mainValues.contains(val)) {
                            return false;
                        }
                    }
                    return true;
                }
                when 'Any' {
                    for (String val : recValues) {
                        if (mainValues.contains(val)) {
                            return true;
                        }
                    }
                    return false;
                }
                when 'Not In' {
                    for (String val : recValues) {
                        if (mainValues.contains(val)) {
                            return false;
                        }
                    }
                    return true;
                }
            }
            //ATHR Fix WW19 - End
            /*if(operator == 'Equal'){
                if(crtValue.split(';').size() != recValue.split(';').size()){
                    return false;
                }
                list<String> mainString = crtValue.toLowerCase().split(';');
                for(String str: recValue.split(';')){
                    if(!mainString.contains(str.toLowerCase())){
                        return false;
                    }
                }
                return true;
            }
            if(operator == 'Not Equal'){
                list<String> mainString = crtValue.toLowerCase().split(';');                
                for(String str: recValue.split(';')){
                    if(!mainString.contains(str.toLowerCase())){
                        return true;
                    }
                }
                return false;
            }
            if(operator == 'In'){
                list<String> mainString = crtValue.toLowerCase().split(';');
               
                for(String str: recValue.toLowerCase().split(';')){  
                   
                    if(!mainString.contains(str.toLowerCase())){
                        return false;
                    }
                }
                return true;
            }
            if(operator == 'Any'){
                list<String> mainString = crtValue.toLowerCase().split(';');
                
                Boolean categoryPresent = false;
                for(String str: recValue.toLowerCase().split(';')){  
                    
                    if(mainString.contains(str.toLowerCase())){
                        categoryPresent = true;
                    }
                }
                return categoryPresent;
            }
            if(operator == 'Not In'){
                list<String> mainString = crtValue.toLowerCase().split(';');
                for(String str: recValue.toLowerCase().split(';')){                 
                    if(mainString.contains(str.toLowerCase())){
                        return false;
                    }
                }
                return true;
            }*/    
            return false;
        }
        //Returning false if user selects inappropriate operator 
        return false;
    }          
}