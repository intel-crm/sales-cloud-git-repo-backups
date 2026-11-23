public class Core_MDF_Approval_Request_Shreyansh {
  /*  Public class PendingApprovalField{
        @AuraEnabled public String fieldLabel{get;set;}
        @AuraEnabled public String fieldValue{get;set;}
        @AuraEnabled public String fieldType{get;set;}
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
            //for redirect link
            //TargetObejctId,WorkInstance object id
            Map<String,String> mapOfobjIdToProcessId = new Map<String,String>();
            //custom field bnao apiname:fieldValue krke and split
            for(CCP_Approval_Req_Object_Configuration__mdt ApprovalReq : [Select id,Fields_Name__c,Object_Name__c,Title_Field__c,Field_Propertie__c,Field_Properties__c from CCP_Approval_Req_Object_Configuration__mdt where Active__c=true]){
             mapOfTypeAndObjectConfiguration.put(ApprovalReq.Object_Name__c,ApprovalReq);  
            }
           for(ProcessInstanceWorkItem piwi : [select id,ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Type 
                                                from ProcessInstanceWorkItem
                                                where ProcessInstance.TargetObject.Type IN: mapOfTypeAndObjectConfiguration.keyset() 
                                                And ProcessInstance.Status = 'Pending' And id IN ('04ig0000001Kz3fAAC','04ig0000001KxnjAAC','04ig0000001KxZFAA0',
                                                                                                  '04ig0000001KxHWAA0','04ig0000001KxZSAA0','04ig0000001KlLXAA0',
                                                                                                 '04ig0000001KlN4AAK','04ig0000001KlrvAAC','04ig0000001KlwWAAS',
                                                                                                 '04ig00000018h0YAAQ')
                                               
                                                ])
               

           {
               if(mapOfObjectTypeAndIds.containsKey(piwi.ProcessInstance.TargetObject.Type)){
                   mapOfObjectTypeAndIds.get(piwi.ProcessInstance.TargetObject.Type).add(piwi.ProcessInstance.TargetObjectId);
                   
               }
               else{
                   mapOfObjectTypeAndIds.put(piwi.ProcessInstance.TargetObject.Type,new List<Id>{piwi.ProcessInstance.TargetObjectId});
               }
               mapOfobjIdToProcessId.put(piwi.ProcessInstance.TargetObjectId,piwi.id);
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
            
            for(String type : mapOfObjectTypeAndIds.keyset()){
               List<Id> ids = mapOfObjectTypeAndIds.get(type);
                String Query = 'Select '+mapOfTypeAndObjectConfiguration.get(type).Fields_Name__c + ',' +
                    mapOfTypeAndObjectConfiguration.get(type).Title_Field__c +
                    ' From ' + type + ' Where Id IN: ids';
              //  String Query = 'Select Id,RequestedAmount,Core_MDF_Activity_Number__c,Core_MDF_Fund_Request_Status__c,Core_MDF_Ultimate_Account_Name__c,Core_MDF_Activity_SubType_nm__c,Core_MDF_Previous_Close_Dt__c,ChannelPartner.Name,Title From PartnerFundRequest Where Id IN: ids';
                mapOfObjectTypeAndQueryString.put(type,Query);
                system.debug('Query Formation' + Query);
                for(Sobject obj : Database.query(Query)){
                    system.debug('Object:'+obj);
                    PendingApprovalRecord record = new PendingApprovalRecord();
                    List<PendingApprovalField> listofPendingApprovalField = new List<PendingApprovalField>();
                    record.recordId = obj.Id;
                    record.type = type;
                    record.name = (String)obj.get(mapOfTypeAndObjectConfiguration.get(type).Title_Field__c);
                   // String recordLink = mapOfobjIdToProcessId.get(obj.id)
                   // record.redirectLink = '/'+mapOfobjIdToProcessId.get(obj.id);
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
    public static void selectedRecords(String recordId){
        List<String> objectRecordId = recordId.split('/');
        system.debug('@@ RecordId'+objectRecordId[1]);
        String id = objectRecordId[1];
        for(ProcessInstance pi : [select id,TargetObjectId,TargetObject.Type,Status 
                from ProcessInstance 
                where TargetObjectId=: id ])
     
        {
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Rejected request using Trigger');
        req.setAction('Reject');
        }
    }
    
    
    @AuraEnabled
    public static String getFieldsOfSelectedRecords(String recordId){
        List<String> objectRecordId = recordId.split('/');
        system.debug('@@ RecordId'+objectRecordId[1]);
        String id = objectRecordId[1];
        String ObjectLabelName = getObjectName(objectRecordId[1]);
        List<id> recId = recordId.split('/');
        system.debug('****'+recId);
       
                  
        system.debug('&&&&'+recId);
          Map<String,CCP_Approval_Req_Object_Configuration__mdt> mapOfObjectLabelObjectApi = new  Map<String,CCP_Approval_Req_Object_Configuration__mdt>();
         for(CCP_Approval_Req_Object_Configuration__mdt objLabelApiName : [Select id,Fields_Name__c,Object_Name__c,Details_Properties__c,Record_Properties__c,Title_Field__c,Field_Propertie__c,Field_Properties__c,Object_Label_Name__c from CCP_Approval_Req_Object_Configuration__mdt where Active__c=true AND Object_Label_Name__c =: ObjectLabelName]){
             mapOfObjectLabelObjectApi.put(objLabelApiName.Object_Name__c,objLabelApiName);  
            }
        system.debug('$$$'+mapOfObjectLabelObjectApi);
   //     String apiName = mapOfObjectLabelObjectApi.get(ObjectLabelName);
        
        List<PendingApprovalRecord> listOfApprovalRecords = new List<PendingApprovalRecord>();
         List<String> apiToLabelString = new List<String>();
         for(String objectApiName : mapOfObjectLabelObjectApi.keyset()){
          
                String Query = 'Select '+mapOfObjectLabelObjectApi.get(objectApiName).Fields_Name__c + ',' +
                    mapOfObjectLabelObjectApi.get(objectApiName).Title_Field__c +
                    ' From ' + objectApiName + ' Where Id IN: recId';
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
                        
                        field.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
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
        List<String> objectRecordId = recordId.split('/');
        system.debug('@@ RecordId'+objectRecordId[1]);
        String id = objectRecordId[1];
        String ObjectLabelName = getObjectName(objectRecordId[1]);
        List<id> recId = recordId.split('/');
        system.debug('****'+recId);
       
        
        system.debug('&&&&'+recId);
          Map<String,CCP_Approval_Req_Object_Configuration__mdt> mapOfObjectLabelObjectApi = new  Map<String,CCP_Approval_Req_Object_Configuration__mdt>();
         for(CCP_Approval_Req_Object_Configuration__mdt objLabelApiName : [Select id,Fields_Name__c,Object_Name__c,Record_Properties__c,Title_Field__c,Field_Propertie__c,Field_Properties__c,Object_Label_Name__c from CCP_Approval_Req_Object_Configuration__mdt where Active__c=true AND Object_Label_Name__c =: ObjectLabelName]){
             mapOfObjectLabelObjectApi.put(objLabelApiName.Object_Name__c,objLabelApiName);  
            }
        system.debug('$$$'+mapOfObjectLabelObjectApi);
   //     String apiName = mapOfObjectLabelObjectApi.get(ObjectLabelName);
        
        List<PendingApprovalRecord> listOfApprovalRecords = new List<PendingApprovalRecord>();
         List<String> apiToLabelString = new List<String>();
         for(String objectApiName : mapOfObjectLabelObjectApi.keyset()){
          
                String Query = 'Select '+mapOfObjectLabelObjectApi.get(objectApiName).Fields_Name__c + ',' +
                    mapOfObjectLabelObjectApi.get(objectApiName).Title_Field__c +
                    ' From ' + objectApiName + ' Where Id IN: recId';
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
                        
                        field.fieldValue = String.valueof(obj.get(apiToLabelString[0]));
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
    }*/
}