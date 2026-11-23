public class Approval_Request_Shr {
/* @AuraEnabled(Cacheable=true)
    public static String approvalDetails(){
        List<ProcessInstanceWorkItem> pi = new List<ProcessInstanceWorkItem>();
        		for(ProcessInstanceWorkItem piwi : [Select id,ProcessInstance.TargetObject.Name,ProcessInstance.TargetObject.Type,CreatedBy.name,ProcessInstance.CreatedDate 
                                                    from ProcessInstanceWorkitem 
                                                    where ProcessInstance.status = 'Pending'])
                {
                    pi.add(piwi);
                }
         return JSON.serialize(pi);
    }
      Public class PendingApprovalField{
        @AuraEnabled public String fieldLabel{get;set;}
        @AuraEnabled public String fieldValue{get;set;}
        @AuraEnabled public String fieldType{get;set;}
        @AuraEnabled public String recordLink{get;set;}
        @AuraEnabled public Boolean hasRecordLink{get;set;}
  }
    Public class PendingApprovalRecord{
       @AuraEnabled public String name{get;set;} 
       @AuraEnabled public String type{get;set;}
       @AuraEnabled public String redirectLink{get;set;} 
       @AuraEnabled public String recordId{get;set;}
       @AuraEnabled public List<PendingApprovalField> fields{get;set;}
        
    }
 @AuraEnabled(Cacheable=true)
        public static String getSubmittedRecords(){
            Map<String,List<Id>> mapOfObjectTypeAndIds = new  Map<String,List<Id>>();   
            Map<String,String> mapOfObjectTypeAndQueryString = new  Map<String,String>();
            Map<String,CCP_Approval_Req_Object_Configuration__mdt> mapOfTypeAndObjectConfiguration = new  Map<String,CCP_Approval_Req_Object_Configuration__mdt>();
            List<String> apiToLabelString = new List<String>();
            Set<Id> groupwithUser = new Set<Id>();
            Set<Id> groupIdSet = new Set<Id>();
            //for redirect link
            //TargetObejctId,WorkInstance object id
            Map<String,String> mapOfobjIdToProcessId = new Map<String,String>();
            //custom field bnao apiname:fieldValue krke and split
            for(CCP_Approval_Req_Object_Configuration__mdt ApprovalReq : [Select id,Fields_Name__c,Program__c,Object_Name__c,Title_Field__c,Field_Propertie__c,Field_Properties__c from CCP_Approval_Req_Object_Configuration__mdt where Active__c=true]){
             mapOfTypeAndObjectConfiguration.put(ApprovalReq.Object_Name__c,ApprovalReq);  
            }
            system.debug('##'+mapOfTypeAndObjectConfiguration);
            
          /*  Group g = [Select Id from Group where type='Queue' And name = 'CCP Program Office Queue'];
            String s = g.id;
            system.debug('***'+s);
            for(GroupMember  u :[select UserOrGroupId from GroupMember where groupId=:g.id]){
                groupwithUser.add(u.UserOrGroupId);
            }
             String userId = UserInfo.getUserId(); 
             Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
            Set<Id> queueIds = new Set<Id>();
            if(groupIds!=null){
                for(GroupMember gm : [select group.name,group.id,group.type from GroupMember where UserOrGroupId =: groupIds]){
                    queueIds.add(gm.group.id);
                }
                system.debug('&&&'+queueIds);
            }
             
            for(ProcessInstanceWorkItem piwi : [select id,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type 
                                                from ProcessInstanceWorkItem
                                                where ProcessInstance.TargetObject.Type IN: mapOfTypeAndObjectConfiguration.keyset() 
                                                And ProcessInstance.Status = 'Pending' And id IN ('04ig0000001HPFYAA4','04ig0000001HPI3AAO','04ig0000001HQgeAAG','04ig0000001UYI1AAO',
                                                                                                  '04ig0000001HRFUAA4','04ig0000001HREeAAO','04ig0000001WJtQAAW',
                                                                                                  '04ig0000001WLx7AAG','04ig00000018i0FAAQ','04ig00000018hzrAAA','04ig0000001BcQLAA0','04ig0000001BcnKAAS','04ig0000001BdJJAA0','04ig00000018jcEAAQ')
                                               ])
           {
               if(mapOfObjectTypeAndIds.containsKey(piwi.ProcessInstance.TargetObject.Type)){
                   mapOfObjectTypeAndIds.get(piwi.ProcessInstance.TargetObject.Type).add(piwi.ProcessInstance.TargetObjectId);
                   
               }
               else{
                   mapOfObjectTypeAndIds.put(piwi.ProcessInstance.TargetObject.Type,new List<Id>{piwi.ProcessInstance.TargetObjectId});
               }
               mapOfobjIdToProcessId.put(piwi.ProcessInstance.TargetObjectId,piwi.id);
            //   mapOfobjIdToProcessId.put(piwi.ProcessInstance.TargetObjectId,piwi.id);
           }
          /*  String Ids;
            Set
            Map<String,String> mapOfTypeAndFinalString = new  Map<String,String>();
            for(String type : mapOfObjectTypeAndIds.keyset()){
                Ids = '\''+mapOfObjectTypeAndIds.get(type)+'\'' + Ids;
                if(mapOfTypeAndFinalString.containskey(type)){
                    mapOfTypeAndFinalString.get(type).add(Ids);
                }
                else{
                    mapOfTypeAndFinalString.put(type,Ids);
                }
            }
            List<PendingApprovalRecord> listOfApprovalRecords = new List<PendingApprovalRecord>();
            system.debug('Process Instance'+mapOfobjIdToProcessId);
            for(String type : mapOfObjectTypeAndIds.keyset()){
               List<Id> ids = mapOfObjectTypeAndIds.get(type);
                System.debug('@@@id'+ids);
                String Query = 'Select '+mapOfTypeAndObjectConfiguration.get(type).Fields_Name__c + ',' +
                    mapOfTypeAndObjectConfiguration.get(type).Title_Field__c +','+mapOfTypeAndObjectConfiguration.get(type).program__c+
                    ' From ' + type + ' Where Id IN: ids';
              //  String Query = 'Select Id,RequestedAmount,Core_MDF_Activity_Number__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Ultimate_Account_Name__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Previous_Close_Dt__c,ChannelPartner.Name,Title From PartnerFundRequest Where Id IN: ids';
                mapOfObjectTypeAndQueryString.put(type,Query);
                system.debug('Query Formation' + Query);
                for(Sobject obj : Database.query(Query)){
                    system.debug('Object:'+obj);
                    system.debug('channel partner'+(String)obj.get(mapOfTypeAndObjectConfiguration.get(type).program__c));
                    PendingApprovalRecord record = new PendingApprovalRecord();
                    List<PendingApprovalField> listofPendingApprovalField = new List<PendingApprovalField>();
                    record.recordId = obj.Id;
                    record.type = type;
                    record.name = (String)obj.get(mapOfTypeAndObjectConfiguration.get(type).Title_Field__c);
                   // String recordLink = mapOfobjIdToProcessId.get(obj.id);
                  //  record.redirectLink = '/'+mapOfobjIdToProcessId.get(obj.id);
                    record.redirectLink = '/'+obj.id;
                    //Use this inside <a> tag
                    for(String str : mapOfTypeAndObjectConfiguration.get(type).Field_Propertie__c.split(';')){
                        system.debug('String'+str);
                        apiToLabelString = str.split(':');
                        system.debug('ApiToString'+apiToLabelString);
                        system.debug('FirstValue'+apiToLabelString[0]);
                        system.debug('FirstValue'+apiToLabelString[1]);
                        PendingApprovalField field = new PendingApprovalField();
                        field.fieldLabel = apiToLabelString[1];
                        
                        field.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
                         
                        listofPendingApprovalField.add(field);
                   }
                    record.fields = listofPendingApprovalField;
                    listOfApprovalRecords.add(record);
                }
                  
            }
            system.debug('Size'+mapOfObjectTypeAndQueryString.size());
           
            system.debug('List of Approval Record'+json.serializePretty(listOfApprovalRecords));
             
            return JSON.serialize(listOfApprovalRecords);
            
            } 
        
     @AuraEnabled
    public static String getFieldsOfSelectedRecords(String recordId){
        system.debug('@@@'+recordId);
        List<String> objectRecordId = recordId.split('/');
        system.debug('@@ RecordId'+objectRecordId[1]);
        String id = objectRecordId[1];
        String ObjectLabelName = getObjectName(objectRecordId[1]);
        List<id> recId = recordId.split('/');
        system.debug('****'+recId);
       
        
        system.debug('&&&&'+recId);
          Map<String,CCP_Approval_Req_Object_Configuration__mdt> mapOfObjectLabelObjectApi = new  Map<String,CCP_Approval_Req_Object_Configuration__mdt>();
         for(CCP_Approval_Req_Object_Configuration__mdt objLabelApiName : [Select id,Fields_Name__c,Core_MDF_Field_Name__c,Object_Name__c,Details_Properties__c,Record_Properties__c,Title_Field__c,Field_Propertie__c,Field_Properties__c,Object_Label_Name__c from CCP_Approval_Req_Object_Configuration__mdt where Active__c=true AND Core_MDF_Navigate_Standard_Page_Ind__c =false]){
             mapOfObjectLabelObjectApi.put(objLabelApiName.Object_Name__c,objLabelApiName);  
            }
        system.debug('$$$'+mapOfObjectLabelObjectApi);
   //     String apiName = mapOfObjectLabelObjectApi.get(ObjectLabelName);
        
        List<PendingApprovalRecord> listOfApprovalRecords = new List<PendingApprovalRecord>();
         List<String> apiToLabelString = new List<String>();
         for(String objectApiName : mapOfObjectLabelObjectApi.keyset()){
          
              /* String Query = 'Select '+mapOfObjectLabelObjectApi.get(objectApiName).Fields_Name__c + ',' +
                    mapOfObjectLabelObjectApi.get(objectApiName).Title_Field__c +
                    ' From ' + objectApiName + ' Where Id IN: recId';
             
            String Query ='Select '+ mapOfObjectLabelObjectApi.get(objectApiName).Core_MDF_Field_Name__c +' From '  + objectApiName + ' Where Id IN: recId';
              //  String Query = 'Select 
                system.debug('Query Formation' + Query);
                for(Sobject obj : Database.query(Query)){
                    system.debug('Object:'+obj);
                    PendingApprovalRecord record = new PendingApprovalRecord();
                    List<PendingApprovalField> listofPendingApprovalField = new List<PendingApprovalField>();
                    record.recordId = obj.Id;
                    record.type = objectApiName;
                    record.name = (String)obj.get(mapOfObjectLabelObjectApi.get(objectApiName).Title_Field__c);
                   // String recordLink = mapOfobjIdToProcessId.get(obj.id)
                   // record.redirectLink = '/'+mapOfobjIdToProcessId.get(obj.id);
                    record.redirectLink = '/'+obj.id;
                    //Use this inside <a> tag
                    for(String str : mapOfObjectLabelObjectApi.get(objectApiName).Details_Properties__c.split(';')){
                        system.debug('String'+str);
                        apiToLabelString = str.split(':');
                        system.debug('ApiToString'+apiToLabelString);
                        system.debug('FirstValue'+apiToLabelString[0]);
                        system.debug('FirstValue'+apiToLabelString[1]);
                        PendingApprovalField field = new PendingApprovalField();
                        field.fieldLabel = apiToLabelString[1];
                        
                          if(field.fieldLabel == 'Activity Number'){
                            field.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
                            field.hasRecordLink = true;
                             field.recordLink = recordId;
                              system.debug('***'+json.serialize(field));
                        }
                        
                        if(String.isNotEmpty(String.valueof(obj.get(apiToLabelString[0]))) && String.valueof(obj.get(apiToLabelString[0])).Startswith('701')){
                             string fiendApiName = apiToLabelString[0].removeEnd('Id');
                               system.debug('@@@@@@@@@'+fiendApiName);
                            field.fieldValue = String.valueOf(obj.getSObject(fiendApiName).get('Name'));
                            field.hasRecordLink = true;
                            field.recordLink ='/' + String.valueof(obj.get(apiToLabelString[0]));
                         }else{
                        field.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
                         }   
                      
                         
                        listofPendingApprovalField.add(field);
                }
                    record.fields = listofPendingApprovalField;
                    listOfApprovalRecords.add(record);
                }
				}
       /* PartnerFundRequest pfr = new PartnerFundRequest(); 
        pfr = [select Id,RequestedAmount,Core_MDF_Activity_Number__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Ultimate_Account_Name__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Previous_Close_Dt__c From PartnerFundRequest where id =: objectRecordId[1]];
        system.debug('####'+pfr);
        system.debug('%%%%'+listOfApprovalRecords);
        return json.serialize(listOfApprovalRecords);
        
        
    }
    
      @AuraEnabled
    public static String getNewRecords(String recordId){
        system.debug('@@@'+recordId);
        List<String> objectRecordId = recordId.split('/');
        system.debug('@@ RecordId'+objectRecordId[1]);
        String id = objectRecordId[1];
        String ObjectLabelName = getObjectName(objectRecordId[1]);
        List<id> recId = recordId.split('/');
        system.debug('****'+recId);
       
        
        system.debug('&&&&'+recId);
          Map<String,CCP_Approval_Req_Object_Configuration__mdt> mapOfObjectLabelObjectApi = new  Map<String,CCP_Approval_Req_Object_Configuration__mdt>();
         for(CCP_Approval_Req_Object_Configuration__mdt objLabelApiName : [Select id,Fields_Name__c,Object_Name__c,Core_MDF_Field_Name__c,Record_Properties__c,Title_Field__c,Field_Propertie__c,Field_Properties__c,Object_Label_Name__c from CCP_Approval_Req_Object_Configuration__mdt where Active__c=true AND Core_MDF_Navigate_Standard_Page_Ind__c =false]){
             mapOfObjectLabelObjectApi.put(objLabelApiName.Object_Name__c,objLabelApiName);  
            }
        system.debug('$$$'+mapOfObjectLabelObjectApi);
   //     String apiName = mapOfObjectLabelObjectApi.get(ObjectLabelName);
        
        List<PendingApprovalRecord> listOfApprovalRecords = new List<PendingApprovalRecord>();
         List<String> apiToLabelString = new List<String>();
         for(String objectApiName : mapOfObjectLabelObjectApi.keyset()){
          
             /*   String Query = 'Select '+mapOfObjectLabelObjectApi.get(objectApiName).Fields_Name__c + ',' +
                    mapOfObjectLabelObjectApi.get(objectApiName).Title_Field__c +
                    ' From ' + objectApiName + ' Where Id IN: recId';
             String Query = 'Select '+mapOfObjectLabelObjectApi.get(objectApiName).Core_MDF_Field_Name__c +' From ' + objectApiName + ' Where Id IN: recId';
              //  String Query = 'Select 
                system.debug('Query Formation' + Query);
                for(Sobject obj : Database.query(Query)){
                    system.debug('Object:'+obj);
                    PendingApprovalRecord record = new PendingApprovalRecord();
                    List<PendingApprovalField> listofPendingApprovalField = new List<PendingApprovalField>();
                    record.recordId = obj.Id;
                    record.type = objectApiName;
                    record.name = (String)obj.get(mapOfObjectLabelObjectApi.get(objectApiName).Title_Field__c);
                   // String recordLink = mapOfobjIdToProcessId.get(obj.id)
                   // record.redirectLink = '/'+mapOfobjIdToProcessId.get(obj.id);
                    record.redirectLink = '/'+obj.id;
                    //Use this inside <a> tag
                    for(String str : mapOfObjectLabelObjectApi.get(objectApiName).Record_Properties__c.split(';')){
                        system.debug('String'+str);
                        apiToLabelString = str.split(':');
                        system.debug('ApiToString'+apiToLabelString);
                        system.debug('FirstValue'+apiToLabelString[0]);
                        system.debug('FirstValue'+apiToLabelString[1]);
                        PendingApprovalField field = new PendingApprovalField();
                        field.fieldLabel = apiToLabelString[1];
                         if(String.isNotEmpty(String.valueof(obj.get(apiToLabelString[0]))) && String.valueof(obj.get(apiToLabelString[0])).Startswith('001')){
                             string fiendApiName = apiToLabelString[0].removeEnd('Id');
                               //system.debug('@@@@@@@@@'+fiendApiName);
                            field.fieldValue = String.valueOf(obj.getSObject(fiendApiName).get('Name'));
                         }else{
                        field.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
                         }     
                        listofPendingApprovalField.add(field);
                   }
                    record.fields = listofPendingApprovalField;
                    listOfApprovalRecords.add(record);
                }
				}
       /* PartnerFundRequest pfr = new PartnerFundRequest(); 
        pfr = [select Id,RequestedAmount,Core_MDF_Activity_Number__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Ultimate_Account_Name__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Previous_Close_Dt__c From PartnerFundRequest where id =: objectRecordId[1]];
        system.debug('####'+pfr);
        system.debug('%%%%'+listOfApprovalRecords);
        return json.serialize(listOfApprovalRecords);
        
        
    }
      public static String getObjectName(String recordId){
        //To get the label of the object name using Schema methods
        String keyPrefix = recordId.subString(0,3);
        String objectName = '';
        Map<String,Schema.SObjectType> sobjectTypeMap = Schema.getGlobalDescribe();
        for(String obj : sobjectTypeMap.keySet()){
            Schema.DescribeSObjectResult sobjectResult = sobjectTypeMap.get(obj).getDescribe();
            if(sobjectResult.getKeyPrefix() == keyPrefix){
                objectName = sobjectResult.getLabel();
                break;
            }
        }
        return objectName;
    }
    
   public static Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = null;

        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p
            where p.ProcessInstance.TargetObjectId =: targetObjectId])
        {
            retVal  =  workItem.Id;
        }

        return retVal;
    }
    
    public static void rejectRecord(String recordId){
          List<String> objectRecordId = recordId.split('/');
        system.debug('@@ RecordId'+objectRecordId[1]);
        String id = objectRecordId[1];
        
       
        //req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Id workItemId = getWorkItemId(id); 

         Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Rejected request using Trigger');
        req.setAction('Reject');
        
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
            system.debug('$$$'+result);
        
    }
    public static void approveRecord(String recordId){
          List<String> objectRecordId = recordId.split('/');
        system.debug('@@ RecordId'+objectRecordId[1]);
        String id = objectRecordId[1];

        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request using Trigger');
        req.setAction('Approve');
  Id workItemId = getWorkItemId(id); 
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
  system.debug('$$$'+result);
        }
    public static void ObjectApINameToLabel(String objApiName){
      
        List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objApiName});
        String objectLabelName = describeSobjectsResult[0].getLabel();
        system.debug(objectLabelName);
    }
    public static Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){
        Set<Id> output = new Set<Id>();
        Set<Id> nestedGroupIds = new Set<Id>();
        // only query actual groups and not roles and queues
        list<GroupMember> records = [select id, GroupId,Group.Name, UserOrGroupId from GroupMember where UserOrGroupId =: userOrGroupIds and UserOrGroupId != null];
        for (GroupMember record:records)
        {
        // found a group, remember for traversal
        if (!(record.UserOrGroupId + '').startsWith('005'))
        {
        nestedGroupIds.add(record.UserOrGroupId);   
        }
        else
        {
        output.add(record.GroupId);
        }
        }

        // call self to get nested groups we found
        if (nestedGroupIds.size() > 0)
        {
        output.addAll(getGroupsForIds(nestedGroupIds));
        }
        system.debug('****'+output);
        return output;
    }

    @AuraEnabled
    public static Boolean approveRejectActivity(String recordId,String approvalComments,String action){
        Map<Id,Id>  piMap = new Map<Id,Id>();
        List<Id> pfrIds = new List<Id>();
        List<PartnerFundRequest> pfrsToBeUpdated = new List<PartnerFundRequest>();

        try {
            if(String.isNotBlank(recordId)){
                pfrIds.add(recordId);
            }

            for(ProcessInstanceWorkItem piwitm : [SELECT Id,ProcessInstance.TargetObjectId,ActorId FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId IN:pfrIds and ActorId = :UserInfo.getUserId()]){
                 piMap.put(piwitm.ProcessInstance.TargetObjectId, piwitm.Id);
            }

            System.debug('Process Instance Workitem Map => '+piMap);
		
            for(Id pfrId : piMap.keySet()) { 
                                
                Approval.ProcessResult processResult = null;
                Approval.ProcessWorkitemRequest aprReq = new Approval.ProcessWorkitemRequest();
                aprReq.setComments(approvalComments);
                aprReq.setAction(action);
                aprReq.setWorkitemId(piMap.get(pfrId));
                aprReq.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                
                processResult = Approval.process(aprReq);
                
                if (processResult != null && !processResult.isSuccess()){
                    
                    string errorlog = 'Approval failed for activiy ->' + pfrId + ';' ; 
                    for(Database.Error errDet : processResult.getErrors()){
                        errorlog += errDet.getMessage();
                    } 
                    Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorlog,'approveRejectActivity Method');
                    return false;
                }
                System.debug('Prrocess Result => '+processResult);
            }
        }catch (Exception e) {
            string logerror = '';logerror += 'PFRIDs->' + string.join(pfrIds, ',->');
            logerror += e.getLineNumber() + '->';logerror += e.getMessage() + '->';
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(logerror,'approveRejectActivity Method');
            System.debug('Exception Message => '+ e.getMessage());
            return false;
        }
        return true;
    }*/
}