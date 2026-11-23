public class Bishal_Approval {
  @AuraEnabled(Cacheable=true)
        public static String getSubmittedRecords(){
            Map<String,List<Id>> mapOfObjectTypeAndIds = new  Map<String,List<Id>>();   
            Map<String,String> mapOfObjectTypeAndQueryString = new  Map<String,String>();
            Map<String,Core_MDF_Approval_Req_Object_Config__mdt> mapOfTypeAndObjectConfiguration = new  Map<String,Core_MDF_Approval_Req_Object_Config__mdt>();
            List<String> apiToLabelString = new List<String>();
            Set<Id> groupwithUser = new Set<Id>();
            Set<Id> groupIdSet = new Set<Id>();
            //for redirect link
            //TargetObejctId,WorkInstance object id
            Map<String,String> mapOfobjIdToProcessId = new Map<String,String>();
            Map<String,ProcessInstanceWorkItem> ProcessIntanceIdToObjIdMap = new Map<String,ProcessInstanceWorkItem>();
            Map<Id,String> processInstIdObjTypeMap = new Map<Id,String>();
            Map<Id,Id> processInstIdRecIdMap = new Map<Id,Id>();
            Map<String,String> targetObjectIdAndTypeMap = new Map<String,String>();
            Map<String,String> targetObjectIdAndNameMap = new Map<String,String>();
            Map<String,Core_MDF_Approval_Req_Object_Config__mdt> approvalReqMetadataMap = new  Map<String,Core_MDF_Approval_Req_Object_Config__mdt>();
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
            }
            system.debug('approvalReqMetadataMap'+approvalReqMetadataMap.keyset());
            system.debug('##'+mapOfTypeAndObjectConfiguration.keySet());       
            String userId = UserInfo.getUserId();
            Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
            Set<Id> queueIds = new Set<Id>();
            if(groupIds != null && !groupIds.isEmpty()){
               // system.debug('groupIds'+groupIds);
               
                for(GroupMember gm : [select group.name,group.id,group.type from GroupMember where UserOrGroupId =: groupIds or group.id =: groupIds]){
                  // system.debug('@@@'+gm);
                    if(gm.group.type == 'Queue'){
                        queueIds.add(gm.group.id);    
                    }
                }
             // system.debug('&&&'+queueIds);
            }
    
           for(ProcessInstanceWorkItem piwi : [select id,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type,CreatedBy.name,CreatedDate from ProcessInstanceWorkItem
                                                where ProcessInstance.Status = 'Pending' order by CreatedDate desc Limit 100])
           {
               if(mapOfObjectTypeAndIds.containsKey(piwi.ProcessInstance.TargetObject.Type)){
                   mapOfObjectTypeAndIds.get(piwi.ProcessInstance.TargetObject.Type).add(piwi.ProcessInstance.TargetObjectId);
                   
               }
               else{
                   mapOfObjectTypeAndIds.put(piwi.ProcessInstance.TargetObject.Type,new List<Id>{piwi.ProcessInstance.TargetObjectId});
               }
               mapOfobjIdToProcessId.put(piwi.ProcessInstance.TargetObjectId,piwi.id);
               system.debug('mapOfobj'+mapOfobjIdToProcessId);
               ProcessIntanceIdToObjIdMap.put(piwi.id,piwi);
               targetObjectIdAndTypeMap.put(piwi.ProcessInstance.TargetObjectId,piwi.ProcessInstance.TargetObject.Type);
               targetObjectIdAndNameMap.put(piwi.ProcessInstance.TargetObjectId,piwi.CreatedBy.name);
               //System.debug('Objecct Type =>'+piwi.ProcessInstance.TargetObject.Type);
               if(approvalReqMetadataMap.containsKey(piwi.ProcessInstance.TargetObject.Type)){
                   system.debug('Entered');
               }
           }
            List<PendingApprovalRecord> listOfApprovalRecords = new List<PendingApprovalRecord>();
            //system.debug('All Keysets from WokItem =>'+mapOfObjectTypeAndIds.keyset());
            //system.debug('ProcessInstanceRecord'+mapOfobjIdToProcessId);        
            for(String type : mapOfObjectTypeAndIds.keyset()){
                
               List<Id> ids = mapOfObjectTypeAndIds.get(type);
                system.debug('Objectids'+ids);
                String Query = 'Select '+mapOfTypeAndObjectConfiguration.get(type).Core_MDF_Field_Name__c +' From ' + type + ' Where Id IN: ids order by CreatedDate desc';
                mapOfObjectTypeAndQueryString.put(type,Query);
               // system.debug('MetaData Records'+mapOfTypeAndObjectConfiguration.get(type));
             //   system.debug('Query Formation' + Query);
                List<Sobject> queryList = Database.query(Query);
                system.debug('Query List Size =>' + queryList.size());
                for(Sobject obj : Database.query(Query)){
                  //system.debug('Object:'+obj);
                    String objAPIName = getObjectAPIName(obj.Id);
                    String key ='';
                   String progKey = mapOfTypeAndObjectConfiguration.get(type).Core_MDF_program__c;
                 //  system.debug('program value'+ progKey);
                    if(  progKey != 'Not Applicable'){
                     key = objAPIName+';'+(String)obj.get(mapOfTypeAndObjectConfiguration.get(type).Core_MDF_program__c);
                    }else{
                     key = objAPIName;
                    }
              
                    PendingApprovalRecord record = new PendingApprovalRecord();
                   
                    record.type = type;
                    system.debug('RecType'+record.type);
                    String titleField = (String)obj.get(approvalReqMetadataMap.get(key).Core_MDF_Title_Field__c);
                    record.name = titleField;
                    record.naviagteToStandardPage = approvalReqMetadataMap.get(key).Core_MDF_Navigate_Standard_Page_Ind__c;
                    List<DetailPageDispalyFieldsWrapper> detailPageFieldsList = new List<DetailPageDispalyFieldsWrapper>();
                    List<UIDispalyFieldsWrapper> uiDispalyFieldsList = new List<UIDispalyFieldsWrapper>();
                    
                    if(approvalReqMetadataMap.get(key).Core_MDF_Navigate_Standard_Page_Ind__c){
                        for(String str : approvalReqMetadataMap.get(key).Core_MDF_Field_Propertie__c.split(';')){
                            apiToLabelString = str.split(':');
                            UIDispalyFieldsWrapper field = new UIDispalyFieldsWrapper();
                            field.fieldLabel = apiToLabelString[1];
                             String processInsatceField  = apiToLabelString[0];
                            if(processInsatceField == 'ObjectType'){
                                field.hasFieldValue = true;
                                field.fieldValue = ObjectApINameToLabel(targetObjectIdAndTypeMap.get(obj.Id));
                            }else if (processInsatceField == 'Name'){
                                field.hasFieldValue = true;
                                field.fieldValue = targetObjectIdAndNameMap.get(obj.Id);
                            }else if (processInsatceField == 'CreatedDate'){
                                SObject piwiRecord = ProcessIntanceIdToObjIdMap.get(mapOfobjIdToProcessId.get(obj.Id));
                                field.fieldValue = null;
                                field.hasFieldValue = false;
                                DateTime submittedDate = (DateTime)piwiRecord.get(processInsatceField);
                                field.dateTimeFieldValue = submittedDate.format('MMM dd, YYYY h:mm a');
                                //field.dateTimeFieldValue = (DateTime)piwiRecord.get(processInsatceField);
                            }else{
                                SObject piwiRecord = ProcessIntanceIdToObjIdMap.get(mapOfobjIdToProcessId.get(obj.Id));
                                System.debug('piwi rec => '+piwiRecord);
                                field.hasFieldValue = true;
                                field.fieldValue = (String)piwiRecord.get(processInsatceField);
                            }             
                            
                            uiDispalyFieldsList.add(field);
                        }
                        record.uiDispalyFields = uiDispalyFieldsList;
                        record.detailDispalyFields = null;
                        record.redirectLink = '/'+mapOfobjIdToProcessId.get(obj.id);
                        record.recordId = mapOfobjIdToProcessId.get(obj.id);                    
                    } else{
                        //Constructing wrapper to dispaly fields on Aprroval Tab
                        for(String str : approvalReqMetadataMap.get(key).Core_MDF_Field_Propertie__c.split(';')){
                           
                            apiToLabelString = str.split(':');
                            UIDispalyFieldsWrapper field = new UIDispalyFieldsWrapper();
                            field.fieldLabel = apiToLabelString[1];
                            //system.debug('value:'+String.valueof(obj.get(apiToLabelString[0])));
                           
                             if(String.isNotEmpty(String.valueof(obj.get(apiToLabelString[0]))) && String.valueof(obj.get(apiToLabelString[0])).Startswith('001')){
                                 string findApiName = apiToLabelString[0].removeEnd('Id');
                                   
                                 field.hasFieldValue = true;
                                field.fieldValue = String.valueOf(obj.getSObject(findApiName).get('Name'));
                             }else if(apiToLabelString[1] == 'Start Date')
                             {
                                DateTime dateConvertToTime = (DateTime)(obj.get(apiToLabelString[0]));
                                
                                 field.hasFieldValue = false;
                                 field.fieldValue = null;
                                field.dateTimeFieldValue = String.valueOf(dateConvertToTime.date());
                                
                             }
                            else if(apiToLabelString[1] == 'Budget Amount(USD)'){
                                 Decimal Amount = (Decimal)obj.get(apiToLabelString[0]);
                                 Long AmountWithoutDecimal = Amount.round();
                                 field.hasFieldValue = true;
                                 field.fieldValue = '$'+string.valueof(AmountWithoutDecimal.format());
                             }
                            else{
                                field.hasFieldValue = true;
                            field.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
                             }     
    
                         //   field.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
                           // field.hasFieldValue = true;
                            uiDispalyFieldsList.add(field);
                        }
                        record.uiDispalyFields = uiDispalyFieldsList;
                        for(String str : approvalReqMetadataMap.get(key).Core_MDF_Record_Properties__c.split(';')){			
                         //   system.debug('String'+str);
                            apiToLabelString = str.split(':');
                            DetailPageDispalyFieldsWrapper detailPageFields = new DetailPageDispalyFieldsWrapper();
                            detailPageFields.fieldLabel = apiToLabelString[1];
                            
                            
                            detailPageFields.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
                            detailPageFieldsList.add(detailPageFields);
                        }
                        record.detailDispalyFields = detailPageFieldsList;
                        record.redirectLink = '/'+obj.id;
                        record.recordId = obj.id;
                    }
                    listOfApprovalRecords.add(record);
                }
                  
            }
            system.debug('Size'+mapOfObjectTypeAndQueryString.size());
           
            //system.debug('List of Approval Record'+json.serializePretty(listOfApprovalRecords));
             
                return JSON.serialize(listOfApprovalRecords);
            }
            
            catch (Exception e) { Core_MDF_CCP_UtilityClass.logError(e); return null; }
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
                @AuraEnabled public String fieldType{get;set;}
                //@AuraEnabled public DateTime dateTimeFieldValue{get;set;}
                @AuraEnabled public String dateTimeFieldValue{get;set;}
                @AuraEnabled public Boolean hasFieldValue{get;set;}
        }
        Public class DetailPageDispalyFieldsWrapper{
                @AuraEnabled public String fieldLabel{get;set;}
                @AuraEnabled public String fieldValue{get;set;}
                @AuraEnabled public String fieldType{get;set;}
        }

}