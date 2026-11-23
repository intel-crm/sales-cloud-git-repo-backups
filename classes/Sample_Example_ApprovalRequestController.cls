public class Sample_Example_ApprovalRequestController {
  public static Map<String,Core_MDF_Approval_Req_Object_Config__mdt> mapOfTypeAndObjectConfiguration = new  Map<String,Core_MDF_Approval_Req_Object_Config__mdt>();
        public static List<String> apiToLabelString = new List<String>();
        public static Map<String,Core_MDF_Approval_Req_Object_Config__mdt> approvalReqMetadataMap = new  Map<String,Core_MDF_Approval_Req_Object_Config__mdt>();
        //public static Map<String,String> mapOfobjIdToProcessId = new Map<String,String>();
        /***************************************************************************************************** 
        Method Name   :        getSubmittedRecords
        @return       :        void
        @parameters   :        null
        Description   :        Display Data in New Approval Request Tab
        Added By      :        Accenture - Bishal - 15/04/2021
        Modified By   :        Date:           Changes: 
        ******************************************************************************************************/  
        @AuraEnabled(Cacheable=true)
        public static String getSubmittedRecords(){
            //Map<String,List<Id>> mapOfObjectTypeAndIds = new  Map<String,List<Id>>();   
            Map<String,String> mapOfObjectTypeAndQueryString = new  Map<String,String>();
            //Map<String,Core_MDF_Approval_Req_Object_Config__mdt> mapOfTypeAndObjectConfiguration = new  Map<String,Core_MDF_Approval_Req_Object_Config__mdt>();
            //List<String> apiToLabelString = new List<String>();
            Set<Id> groupwithUser = new Set<Id>();
            Set<Id> groupIdSet = new Set<Id>();
            Set<String> objectAPINameSet = new Set<String>();
            //for redirect link
            //TargetObejctId,WorkInstance object id
            //Map<String,String> mapOfobjIdToProcessId = new Map<String,String>();
            Map<String,ProcessInstanceWorkItem> ProcessIntanceIdToObjIdMap = new Map<String,ProcessInstanceWorkItem>();
            Map<Id,String> processInstIdObjTypeMap = new Map<Id,String>();
            Map<Id,Id> processInstIdRecIdMap = new Map<Id,Id>();
            Map<String,String> targetObjectIdAndTypeMap = new Map<String,String>();
            Map<String,String> targetObjectIdAndNameMap = new Map<String,String>();
            List<ProcessInstanceWorkItem> standardPIWIList = new List<ProcessInstanceWorkItem>();
            List<ProcessInstanceWorkItem> customPIWIList = new List<ProcessInstanceWorkItem>();
            //Map<String,Core_MDF_Approval_Req_Object_Config__mdt> approvalReqMetadataMap = new  Map<String,Core_MDF_Approval_Req_Object_Config__mdt>();
            List<PendingApprovalRecord> listOfApprovalRecords = new List<PendingApprovalRecord>();   
            try{
                for(Core_MDF_Approval_Req_Object_Config__mdt ApprovalReq : [Select id,Core_MDF_Fields_Name__c,Core_MDF_Program__c,Core_MDF_Object_Name__c,Core_MDF_Field_Name__c,Core_MDF_Title_Field__c,Core_MDF_Field_Propertie__c,Core_MDF_Field_Properties__c,Core_MDF_Navigate_Standard_Page_Ind__c,Core_MDF_PrgorRecType__c,Core_MDF_Record_Properties__c from Core_MDF_Approval_Req_Object_Config__mdt where Core_MDF_Active__c=true]){
                    String key = '';
                    mapOfTypeAndObjectConfiguration.put(ApprovalReq.Core_MDF_Object_Name__c,ApprovalReq);
                    if(ApprovalReq.Core_MDF_PrgorRecType__c != 'Not Applicable' && String.isNotBlank(ApprovalReq.Core_MDF_Object_Name__c)){
                        key = ApprovalReq.Core_MDF_Object_Name__c+';'+ApprovalReq.Core_MDF_PrgorRecType__c;
                    }else{
                        key = ApprovalReq.Core_MDF_Object_Name__c;
                    }
                    if(String.isNotBlank(key) && !approvalReqMetadataMap.containsKey(key)){
                        approvalReqMetadataMap.put(key,ApprovalReq); 
                    }
                    objectAPINameSet.add(ApprovalReq.Core_MDF_Object_Name__c);
                }    
                String userId = UserInfo.getUserId();
                Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
                Set<Id> queueIds = new Set<Id>();
                if(groupIds != null && !groupIds.isEmpty()){
                    system.debug('groupIds'+groupIds);
                
                    for(GroupMember gm : [select group.name,group.id,group.type from GroupMember where UserOrGroupId =: groupIds or group.id =: groupIds]){
                    
                        if(gm.group.type == 'Queue'){
                            queueIds.add(gm.group.id);    
                        }
                    }
                }
                system.debug('Queue Id'+queueIds);
                
                for(ProcessInstanceWorkItem piwi : [select id,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type,ProcessInstance.TargetObject.Name,CreatedBy.name,CreatedDate from ProcessInstanceWorkItem
                                                        where /*ProcessInstance.Status = 'Pending' and */(Actor.Id = :UserInfo.getUserId() OR Actor.Id IN :queueIds)  order by CreatedDate desc])
                {
                    /*if(mapOfObjectTypeAndIds.containsKey(piwi.ProcessInstance.TargetObject.Type)){
                        mapOfObjectTypeAndIds.get(piwi.ProcessInstance.TargetObject.Type).add(piwi.ProcessInstance.TargetObjectId);
                        
                    }
                    else{
                        mapOfObjectTypeAndIds.put(piwi.ProcessInstance.TargetObject.Type,new List<Id>{piwi.ProcessInstance.TargetObjectId});
                    }
                    mapOfobjIdToProcessId.put(piwi.ProcessInstance.TargetObjectId,piwi.id);
                    ProcessIntanceIdToObjIdMap.put(piwi.id,piwi);
                    targetObjectIdAndTypeMap.put(piwi.ProcessInstance.TargetObjectId,piwi.ProcessInstance.TargetObject.Type);
                    targetObjectIdAndNameMap.put(piwi.ProcessInstance.TargetObjectId,piwi.CreatedBy.name);*/
                    //System.debug('Objecct Type =>'+piwi.ProcessInstance.TargetObject.Type);
                    if(objectAPINameSet.contains(piwi.ProcessInstance.TargetObject.Type)){
                        /*PendingApprovalRecord customPARecord = getCustomPageData(piwi);
                        listOfApprovalRecords.add(customPARecord);*/
                        customPIWIList.add(piwi);
                        
                    }else{
                        /*PendingApprovalRecord standardPARecord = getStandardPageData(piwi);
                        listOfApprovalRecords.add(standardPARecord);*/
                        standardPIWIList.add(piwi);
                    }
                }
                system.debug('customRecord'+customPIWIList);
                system.debug('standardRecord'+standardPIWIList);
                if(customPIWIList != null && customPIWIList.size()>0){
               listOfApprovalRecords.addAll(getCustomPageData(customPIWIList));
                }
                if(standardPIWIList != null && standardPIWIList.size()>0){
                listOfApprovalRecords.addAll(getStandardPageData(standardPIWIList));
                }
            return JSON.serialize(listOfApprovalRecords);       
        }
        catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
        }

      //  public static PendingApprovalRecord getCustomPageData(ProcessInstanceWorkItem piwi){
        public static List<PendingApprovalRecord> getCustomPageData(List<ProcessInstanceWorkItem> piwiList){
            //String type = piwilist[0].ProcessInstance.TargetObject.Type;
            List<ProcessInstanceWorkItem> piStandardPageList = new List<ProcessInstanceWorkItem>();
            Map<String,ProcessInstanceWorkItem> mapOfobjIdToProcessId = new Map<String,ProcessInstanceWorkItem>();
            Map<String,List<Id>> mapOfObjectTypeAndIds = new  Map<String,List<Id>>();   
            for(ProcessInstanceWorkItem piwi : piwilist){
                mapOfobjIdToProcessId.put(piwi.ProcessInstance.TargetObjectId,piwi);
                if(mapOfObjectTypeAndIds.containsKey(piwi.ProcessInstance.TargetObject.Type)){
                    mapOfObjectTypeAndIds.get(piwi.ProcessInstance.TargetObject.Type).add(piwi.ProcessInstance.TargetObjectId);                    
                }
                else{
                    mapOfObjectTypeAndIds.put(piwi.ProcessInstance.TargetObject.Type,new List<Id>{piwi.ProcessInstance.TargetObjectId});
                }
            }
            List<PendingApprovalRecord> paRecordList = new List<PendingApprovalRecord>();
            
            for(String type : mapOfObjectTypeAndIds.keyset()){
                List<Id> ids = mapOfObjectTypeAndIds.get(type);
                String Query = 'Select '+mapOfTypeAndObjectConfiguration.get(type).Core_MDF_Field_Name__c +' From ' + type + ' Where Id IN: ids order by CreatedDate desc';
                System.debug('Query ==> '+Query);
                for(Sobject obj : Database.query(Query)){
                    String objAPIName = type;
                    String key ='';
                    String progKey = mapOfTypeAndObjectConfiguration.get(type).Core_MDF_program__c;
                    if(progKey != 'Not Applicable'){
                        key = objAPIName+';'+(String)obj.get(mapOfTypeAndObjectConfiguration.get(type).Core_MDF_program__c);
                    } else {
                        key = objAPIName;
                    }
                    System.debug('Key in custom page -> '+key);
                    if(approvalReqMetadataMap.containsKey(key) && approvalReqMetadataMap.get(key) != null){
                        System.debug('Inside if condition key=> '+key);
                        System.debug('Approval Req key Data=> '+approvalReqMetadataMap.get(key).Core_MDF_Title_Field__c);
                        PendingApprovalRecord paRecord = new PendingApprovalRecord();
                        //paRecord.type = type;
                        //String headerField = approvalReqMetadataMap.get(key).Core_MDF_Title_Field__c;
                        //String titleField = obj.Title;
                        String titleField = (String)obj.get(approvalReqMetadataMap.get(key).Core_MDF_Title_Field__c);
                        paRecord.name = titleField;
                        paRecord.naviagteToStandardPage = approvalReqMetadataMap.get(key).Core_MDF_Navigate_Standard_Page_Ind__c;
                        List<DetailPageDispalyFieldsWrapper> detailPageFieldsList = new List<DetailPageDispalyFieldsWrapper>();
                        List<UIDispalyFieldsWrapper> uiDispalyFieldsList = new List<UIDispalyFieldsWrapper>();

                        for(String str : approvalReqMetadataMap.get(key).Core_MDF_Field_Propertie__c.split(';')){
                            apiToLabelString = str.split(':');
                            UIDispalyFieldsWrapper field = new UIDispalyFieldsWrapper();
                            field.fieldLabel = apiToLabelString[1];
                             if(String.isNotEmpty(String.valueof(obj.get(apiToLabelString[0]))) && String.valueof(obj.get(apiToLabelString[0])).Startswith('001')){
                                 string findApiName = apiToLabelString[0].removeEnd('Id');
                                 field.hasFieldValue = true;
                                 field.fieldValue = String.valueOf(obj.getSObject(findApiName).get('Name'));
                             } else if(apiToLabelString[1] == 'Start Date') {
                                DateTime dateConvertToTime = (DateTime)(obj.get(apiToLabelString[0]));
                                 field.hasFieldValue = false;
                                 field.fieldValue = null;
                                 field.dateTimeFieldValue = String.valueOf(dateConvertToTime.date());   
                             } else if(apiToLabelString[1] == 'Budget Amount(USD)'){
                                 Decimal Amount = (Decimal)obj.get(apiToLabelString[0]);
                                 Long AmountWithoutDecimal = Amount.round();
                                 field.hasFieldValue = true;
                                 field.fieldValue = '$'+string.valueof(AmountWithoutDecimal.format());
                             } else{
                                field.hasFieldValue = true;
                                field.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
                             }
                            uiDispalyFieldsList.add(field);
                        }
                        paRecord.uiDispalyFields = uiDispalyFieldsList;
                        for(String str : approvalReqMetadataMap.get(key).Core_MDF_Record_Properties__c.split(';')){			
                         //   system.debug('String'+str);
                            apiToLabelString = str.split(':');
                            DetailPageDispalyFieldsWrapper detailPageFields = new DetailPageDispalyFieldsWrapper();
                            detailPageFields.fieldLabel = apiToLabelString[1];
                            
                            
                            detailPageFields.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
                            detailPageFieldsList.add(detailPageFields);
                        }
                        paRecord.detailDispalyFields = detailPageFieldsList;
                        paRecord.redirectLink = '/'+obj.id;
                        paRecord.recordId = obj.id;
                        system.debug('Wrapper paRecord'+paRecord);
                        paRecordList.add(paRecord);
                       // system.debug('%%%%'+mapOfobjIdToProcessId.remove(paRecord.recordId));
                       // mapOfobjIdToProcessId.remove(paRecord.recordId);
                      // system.debug('mapofidafterremoval'+mapOfobjIdToProcessId.size());
                        
                    } else {
                        system.debug('mapofid'+mapOfobjIdToProcessId.size());
                        system.debug('ProcessInstanceId '+mapOfobjIdToProcessId.get(obj.Id));
                        if(mapOfobjIdToProcessId.containsKey(obj.Id) && mapOfobjIdToProcessId.get(obj.Id) != null){
                            piStandardPageList.add(mapOfobjIdToProcessId.get(obj.Id));
                        }
                        
                        /*system.debug('piwiList'+piwiList);
                        paRecordList = getStandardPageData(piwiList);*/
                    }
                }
            }
            if(piStandardPageList != null && !piStandardPageList.isEmpty()){
                paRecordList.addAll(getStandardPageData(piStandardPageList));
            }
            system.debug('paRecordList'+paRecordList);
            return paRecordList;
        }

        //public static PendingApprovalRecord getStandardPageData(ProcessInstanceWorkItem piwi){
        public static List<PendingApprovalRecord> getStandardPageData(List<ProcessInstanceWorkItem> piwiList){

            List<PendingApprovalRecord> paRecordList = new List<PendingApprovalRecord>();
            for(ProcessInstanceWorkItem piwi:piwiList){
                List<UIDispalyFieldsWrapper> uiFieldsList = new List<UIDispalyFieldsWrapper>();
                PendingApprovalRecord paRecord = new PendingApprovalRecord();

                paRecord.name = piwi.ProcessInstance.TargetObject.Name;
                paRecord.type = piwi.ProcessInstance.TargetObject.Type;
                paRecord.recordId = piwi.Id;
                paRecord.redirectLink = '/'+piwi.Id;
                paRecord.naviagteToStandardPage = true;
                UIDispalyFieldsWrapper field = new UIDispalyFieldsWrapper();
                field.hasFieldValue = true;
                field.fieldLabel = 'Type';
                field.fieldValue = ObjectApINameToLabel(piwi.ProcessInstance.TargetObject.Type);
                uiFieldsList.add(field);
                UIDispalyFieldsWrapper field2 = new UIDispalyFieldsWrapper();
                field2.hasFieldValue = true;
                field2.fieldLabel = 'Most Recent Approver';
                field2.fieldValue = piwi.CreatedBy.Name;
                uiFieldsList.add(field2);
                UIDispalyFieldsWrapper field3 = new UIDispalyFieldsWrapper();
                field3.hasFieldValue = true;
                field3.fieldLabel = 'Date Submitted';
                DateTime submittedDate = (DateTime)piwi.CreatedDate;
                field3.fieldValue = submittedDate.format('MMM dd, YYYY h:mm a');
                uiFieldsList.add(field3);
                paRecord.uiDispalyFields = uiFieldsList;
                paRecord.detailDispalyFields = null;
                paRecordList.add(paRecord);
            }

            return paRecordList;
        }
        
        public static string getObjectAPIName( String recordId ){
            System.debug(' Record Id in getobj method => '+recordId);
            if(String.isBlank(recordId)){
                return null;
            }
            String objectAPIName = '';
            String keyPrefix = recordId.substring(0,3);
             for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
                  String prefix = obj.getDescribe().getKeyPrefix();
                   if(prefix == keyPrefix){
                             objectAPIName = obj.getDescribe().getName();
                              break;
                    }
             }
             return objectAPIName;
        }
    
        public static String ObjectApINameToLabel(String objApiName){
        
            List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objApiName});
            String objectLabelName = describeSobjectsResult[0].getLabel();
            system.debug(objectLabelName);
            return objectLabelName;
        }
        
        public static Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){
            Set<Id> output = new Set<Id>();
            Set<Id> nestedGroupIds = new Set<Id>();
            // only query actual groups and not roles and queues
            list<GroupMember> records = [select id,GroupId,Group.Name,UserOrGroupId from GroupMember where UserOrGroupId =: userOrGroupIds and UserOrGroupId != null];
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
        
        Public class PendingApprovalRecord{
           @AuraEnabled public String name{get;set;} 
           @AuraEnabled public String type{get;set;}
           @AuraEnabled public String redirectLink{get;set;} 
           @AuraEnabled public String recordId{get;set;}
           @AuraEnabled public List<UIDispalyFieldsWrapper> uiDispalyFields{get;set;}
           @AuraEnabled public List<DetailPageDispalyFieldsWrapper> detailDispalyFields{get;set;}
           @AuraEnabled public Boolean naviagteToStandardPage	{get;set;}
            
        }
        Public class UIDispalyFieldsWrapper{
                @AuraEnabled public String fieldLabel{get;set;}
                @AuraEnabled public String fieldValue{get;set;}
              //  @AuraEnabled public String fieldType{get;set;}
                //@AuraEnabled public DateTime dateTimeFieldValue{get;set;}
                @AuraEnabled public String dateTimeFieldValue{get;set;}
                @AuraEnabled public Boolean hasFieldValue{get;set;}
        }
        Public class DetailPageDispalyFieldsWrapper{
                @AuraEnabled public String fieldLabel{get;set;}
                @AuraEnabled public String fieldValue{get;set;}
             //   @AuraEnabled public String fieldType{get;set;}
        }
}