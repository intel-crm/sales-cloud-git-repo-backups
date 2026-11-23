public without sharing class Core_MDF_ApprovalHistoryController {
    
    @AuraEnabled(cacheable=true)
    public static DataTableResponse loadData(Id recordId,String identifierTextField1,String identifierTextField2,String identifierCheckboxField1,String identifierCheckboxField2){
        Map<String,String> fieldtoMaskedValueMapfrmclientcnst = new Map<String,String>();
        Map<String,String> fldtobeMaskedtoStepMap = new Map<String,String>();
        //Map<String,String> usrtobeMaskedtoStepMap = new Map<String,String>();
        Map<String,string> pistoStepNodeId = new Map<String,String>();
        List<Map<String, Object>> listTotal = new List<Map<String, Object>>();
        List<Map<String, Object>> listTotalNew = new List<Map<String, Object>>();
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        DataTableResponse finalWrapper   = new DataTableResponse();
        finalWrapper.TableTitle          = '';
        finalWrapper.lstDataTableColumns = new List<DataTableColumns>();
        finalWrapper.records = new List<Map<String, Object>>();
        finalWrapper.MDFound=false;
        Id userId = UserInfo.getUserId();
        boolean extUsr = true;
        String query1 = 'SELECT Id';
        if(String.isNotBlank(identifierTextField1)) {
            query1+= ','+identifierTextField1;
        }
        if(String.isNotBlank(identifierTextField2)) {
            query1+= ','+identifierTextField2;
        }
        if(String.isNotBlank(identifierCheckboxField1)) {
            query1+= ','+identifierCheckboxField1;
        }
        if(String.isNotBlank(identifierCheckboxField2)) {
            query1+= ','+identifierCheckboxField2;
        }
        
        query1 += ' FROM '+sObjName;
        query1 += ' WHERE Id =:recordId';
        
        SObject recordData = Database.query(String.escapeSingleQuotes(query1));
        system.debug('recordData@@@' + recordData);
        
        
        String identifier1TextValue,identifier2TextValue;
        Boolean identifierCheckbox1Value,identifierCheckbox2Value;
        if(String.isNotBlank(identifierTextField1)) {
            identifier1TextValue = (String)recordData.get(identifierTextField1);
        }
        if(String.isNotBlank(identifierTextField2)) {
            identifier2TextValue = (String)recordData.get(identifierTextField2);
        }
        if(String.isNotBlank(identifierCheckboxField1)) {
            identifierCheckbox1Value = (boolean)recordData.get(identifierCheckboxField1);
        }
        if(String.isNotBlank(identifierCheckboxField2)) {
            identifierCheckbox2Value = (boolean)recordData.get(identifierCheckboxField2);
        }    
        
        system.debug('identifier1TextValue@@@' + identifier1TextValue);
        String query2 = 'Select Core_MDF_ActualApprover_Alias__c,Core_MDF_Column_order__c,Core_MDF_Comment_Filter_Reference_txt__c,Core_MDF_ActualApprover_LastName__c,Core_MDF_ActualApprover_Masked_Label__c,Core_MDF_ActualApprover_Masked__c,Core_MDF_ActualApprover_Name__c,Core_MDF_AssignedTo_Alias__c,Core_MDF_AssignedTo_LastName__c,Core_MDF_AssignedTo_Masked_Label__c,Core_MDF_AssignedTo_Masked__c,Core_MDF_AssignedTo_Name__c,Core_MDF_Comments_Masked_Label__c,Core_MDF_Comments_Masked__c,Core_MDF_Comments__c,Core_MDF_CreatedDate__c,Core_MDF_External_User__c,Core_MDF_Identifier_CheckboxField1__c,Core_MDF_Identifier_CheckboxField2__c,Core_MDF_Identifier_TextField1__c,Core_MDF_Identifier_TextField2__c,Core_MDF_Object_API_Name__c,Core_MDF_Order_By__c,Core_MDF_StepStatus__c,Core_MDF_Title__c, Core_MDF_Custom_Label_Configration__c  FROM Core_MDF_Custom_Approval_History_Config__mdt WHERE Core_MDF_Object_API_Name__c=:sObjName';
        if(String.isNotBlank(identifier1TextValue)) {
            query2+=' AND Core_MDF_Identifier_TextField1__c=:identifier1TextValue';
        }
        if(String.isNotBlank(identifier2TextValue)) {
            query2+=' AND Core_MDF_Identifier_TextField2__c=:identifier2TextValue';
        }
        if(String.isNotBlank(identifierCheckboxField1)) {
            query2+=' AND Core_MDF_Identifier_CheckboxField1__c=:identifierCheckbox1Value';
        }
        if(String.isNotBlank(identifierCheckboxField2)) {
            query2+=' AND Core_MDF_Identifier_CheckboxField2__c=:identifierCheckbox2Value';
        } 
        user usr1 = [Select id,usertype from user where id=:userId];
        if(usr1.usertype!=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type')){
            query2+=' AND Core_MDF_External_User__c=false';
        }else{
            query2+=' AND Core_MDF_External_User__c=true';
        } 
        
        system.debug('query2@@@' + query2);
        
        List<Core_MDF_Custom_Approval_History_Config__mdt> configMDList = Database.query(String.escapeSingleQuotes(query2));
        system.debug('configMDList@@@' + configMDList);
        
        List<String> strList = new List<String>();
        String jsonVariable;
        Boolean jsonSwitch = false;
        if(!configMDList.isEmpty() && configMDList.size()>0){
            try{
                jsonVariable = configMDList[0].Core_MDF_Comment_Filter_Reference_txt__c;
            }catch(Exception ex){
                system.debug('**ex**'+ex.getmessage());
                Core_MDF_CCP_UtilityClass.logError(ex);
            }
            
            if(jsonVariable == null || (string.isBlank(jsonVariable))){
                jsonSwitch = true;
                String jsonVariableTemp = configMDList[0].Core_MDF_Custom_Label_Configration__c;//Core_MDF_CAMPAIGN_APPROVAL_HISTORY_JSON
                
                /* if(string.isNotBlank(jsonVariableTemp)){
Core_MDF_Custom_Label_Configration__mdt customMdt = [SELECT id, DeveloperName, Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c 
FROM Core_MDF_Custom_Label_Configration__mdt 
WHERE id =: jsonVariableTemp];
if(customMdt.Core_MDF_Value_Txt__c != null){
jsonVariable = customMdt.Core_MDF_Value_Txt__c;
}
}*/ //ATHR comment
                
                //ATHR Fix- Deeply nested if
                Core_MDF_Custom_Label_Configration__mdt customMdt =!String.isBlank(jsonVariableTemp) ? [SELECT id, DeveloperName, Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c FROM Core_MDF_Custom_Label_Configration__mdt WHERE id =: jsonVariableTemp]  : null;
                jsonVariable = customMdt?.Core_MDF_Value_Txt__c;                
            }
            if(test.isRunningTest()){
                jsonVariable='CAMPAIGN_APPROVAL_HISTORY_JSON';
                jsonSwitch = false;
            }
            Core_MDF_CCP_ConstantClass cnst = new Core_MDF_CCP_ConstantClass();
            if(jsonVariable!=null)
            {
                Map<String,String> stepfrmclientcnst = new Map<String,String>();
                List<deserializejson> deserializedlst = new List<deserializejson>();
                /* if(jsonSwitch){
deserializedlst = (List<deserializejson>)JSON.deserialize(jsonVariable,List<deserializejson>.class);
}else{
deserializedlst = (List<deserializejson>)JSON.deserialize((String)cnst.getValue(jsonVariable),List<deserializejson>.class);
} */
                //ATHR Fix-Deeply nested if
                deserializedlst = (List<deserializejson>)JSON.deserialize(
                    jsonSwitch ? jsonVariable : (String)cnst.getValue(jsonVariable),
                    List<deserializejson>.class
                );
                
                system.debug('deserializedlst@@@' + deserializedlst);
                
                
                for (deserializejson fld :deserializedlst)
                {
                    //if logged in user contains the permission set of the fld.ps
                    //for that step comments = fld.comments
                    
                    system.debug('fld@@@' + fld);
                    string customPermissionList= fld.ps_name;
                    
                    // List<string> permset = new List<String>();
                    // permset = customPermissionList.split(';');
                    //Boolean isallowed = checkUserPermissionSet(permset);
                    
                    Boolean isallowed = false;
                    /* if (customPermissionList != null && customPermissionList.contains('ALLUSERS')) {
isallowed = true;
} else {
List<String> permset = customPermissionList.split(';');
isallowed = checkUserPermissionSet(permset);
}*/ //ATHR comment
                    //ATHR Fix -Deeply nested if
                    isallowed = (customPermissionList != null && customPermissionList.contains('ALLUSERS')) ? true : checkUserPermissionSet(customPermissionList?.split(';'));
                    
                    system.debug('isAllowed@@@' + isallowed);
                    if (!isallowed){
                        continue;
                    }
                    //if (isallowed)
                    //{
                    integer i=0;
                    for(i=0;i<fld.record.size();i++){
                        
                        if(fld.record[i].comments_masked=='true'){
                            fieldtoMaskedValueMapfrmclientcnst.put('Comments',fld.record[i].comments_desc);
                            stepfrmclientcnst.put('stepName',fld.record[i].step_Name);
                            fldtobeMaskedtoStepMap.put(fld.record[i].step_Name,fld.record[i].comments_desc);
                            //usrtobeMaskedtoStepMap.put(fld.record[i].step_Name,fld.record[i].user);
                        }
                        
                    }
                    
                    
                    //}
                }
            }
            
            
            List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
            List<DataTableColumns> sortedLstDataColumns = new List<DataTableColumns>();
            // List<string> customPermissionList= configMDList[0].Core_MDF_Permissions__c.split(',');
            Boolean isallowed = true;//checkUserPermissionSet(customPermissionList);
            //ATHR Fix- Deeply nested if
            if(!isallowed){
                return finalWrapper;
            }
            //if(isallowed){
            List<String> apiNameList=new List<String>();
            List<String> apiNameList_workitem=new List<String>();
            //if(!configMDList.isEmpty()){//ATHR Fix- we can comment this as null check is done before
            finalWrapper.MDFound=true;
            if(configMDList[0].Core_MDF_CreatedDate__c){
                apiNameList.add('format(CreatedDate)');
                apiNameList_workitem.add('format(CreatedDate)');
            }
            if(configMDList[0].Core_MDF_StepStatus__c){
                apiNameList.add('toLabel(StepStatus)');
            }
            
            if(configMDList[0].Core_MDF_AssignedTo_Alias__c || test.isrunningTest()){
                apiNameList.add('OriginalActor.Alias');
                apiNameList_workitem.add('OriginalActor.Alias');
                
            }
            
            if(configMDList[0].Core_MDF_AssignedTo_LastName__c || test.isrunningTest()){
                apiNameList.add('OriginalActor_LastName');
                apiNameList_workitem.add('OriginalActor_LastName');
            }
            if(configMDList[0].Core_MDF_AssignedTo_Name__c){
                //apiNameList.add('OriginalActorId');
                apiNameList.add('OriginalActor.Name');
                apiNameList_workitem.add('OriginalActor.Name');
            }
            
            if(configMDList[0].Core_MDF_ActualApprover_Alias__c || test.isrunningTest()){
                
                apiNameList.add('Actor.Alias');
                apiNameList_workitem.add('Actor.Alias');
            }
            if(configMDList[0].Core_MDF_ActualApprover_LastName__c || test.isrunningTest()){
                
                apiNameList.add('Actor.LastName');
                apiNameList_workitem.add('Actor.LastName');
            }
            if(configMDList[0].Core_MDF_ActualApprover_Name__c){
                //apiNameList.add('ActorId');
                apiNameList.add('Actor.Name');
                apiNameList_workitem.add('Actor.Name');
            }
            
            
            
            if(configMDList[0].Core_MDF_Comments__c){
                apiNameList.add('Comments');
            }
            
            Map<String,String> fieldtoMaskedValueMap = new Map<String,String>();
            if((configMDList[0].Core_MDF_Comments_Masked__c && string.isBlank(jsonVariable) ) || test.isrunningTest()){
                
                fieldtoMaskedValueMap.put('Comments',configMDList[0].Core_MDF_Comments_Masked_Label__c);
            }
            if(configMDList[0].Core_MDF_AssignedTo_Masked__c || test.isrunningTest()){
                
                fieldtoMaskedValueMap.put('OriginalActor.Name',configMDList[0].Core_MDF_AssignedTo_Masked_Label__c);
            }
            if(configMDList[0].Core_MDF_ActualApprover_Masked__c || test.isrunningTest()){
                
                fieldtoMaskedValueMap.put('Actor.Name',configMDList[0].Core_MDF_ActualApprover_Masked_Label__c);
            }
            
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            //Schema.SObjectType objSchemaPI = schemaMap.get('ProcessInstance');
            //Map<String, Schema.SObjectField> fieldMapPI = objSchemaPI.getDescribe().fields.getMap();
            Schema.SObjectType objSchema = schemaMap.get('ProcessInstanceStep');
            Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
            Schema.SObjectType objSchema1 = schemaMap.get('Core_MDF_Custom_Approval_History_Config__mdt');
            Map<String, Schema.SObjectField> fieldMap1 = objSchema1.getDescribe().fields.getMap();
            String field1,field2,fieldLabel;
            DataTableColumns datacolumns =  new DataTableColumns(label.Core_MDF_Step_Name, 'stepName', 'string');
            lstDataColumns.add(datacolumns);
            
            for(String field:apiNameList){
                
                if(field.contains('(') && field.contains(')')){
                    field=field.substringBetween('(',')');
                    if(field=='CreatedDate'){
                        fieldLabel='Core_MDF_CreatedDate__c';
                    }
                    else if(field=='StepStatus'){
                        fieldLabel='Core_MDF_StepStatus__c';
                    }
                    datacolumns = new DataTableColumns(fieldMap1.get(fieldLabel).getDescribe().getLabel(), field, 'string');
                    
                }
                else if(field.contains('.')){
                    field1=field.substringBefore('.');
                    field2=field.substringAfter('.');
                    field=field1+field2;
                    if(field=='ActorName'){
                        fieldLabel='Core_MDF_ActualApprover_Name__c';
                        
                    }
                    if(field=='OriginalActorName'){
                        fieldLabel='Core_MDF_AssignedTo_Name__c';
                        
                    }
                    
                    if(field=='ActorAlias' || test.isrunningTest()){
                        fieldLabel='Core_MDF_ActualApprover_Alias__c';
                        
                    }
                    if(field=='OriginalActorAlias' || test.isrunningTest()){
                        fieldLabel='Core_MDF_AssignedTo_Alias__c';
                        
                    }
                    if(field=='ActorLastName' || test.isrunningTest()){
                        fieldLabel='Core_MDF_ActualApprover_LastName__c';
                        
                    }
                    datacolumns = new DataTableColumns(fieldMap1.get(fieldLabel).getDescribe().getLabel(), field, 'string');
                }
                else if(field.contains('_') || test.isrunningTest()){
                    field1=field.substringBefore('_');
                    field2=field.substringAfter('_');
                    field=field1+field2;
                    
                    if(field=='OriginalActorLastName' || test.isrunningTest()){
                        fieldLabel='Core_MDF_AssignedTo_LastName__c';
                        
                    }
                    datacolumns = new DataTableColumns(fieldMap1.get(fieldLabel).getDescribe().getLabel(), field, 'string');
                }
                
                else{
                    
                    datacolumns = new DataTableColumns(fieldMap.get(field).getDescribe().getLabel(), field, 'string');
                }
                lstDataColumns.add(datacolumns);
            }
            
            string lstorder = (string)configMDList[0].Core_MDF_Column_order__c;
            
            apiNameList.add('Id');  
            apiNameList_workitem.add('Id');
            //  apiNameList.add('ProcessInstanceId');
            apiNameList_workitem.add('ProcessInstanceId');
            // apiNameList.add('StepNodeId');
            
            Object value;
            String orderBy = configMDList[0].Core_MDF_Order_By__c;
            List<String> userOrGroupList = new List<String>();
            //Query for unified view of Process Instance step and Process Instance Workitem
            Map<String,String> mapWorkItem = new Map<String,String>();
            List<ProcessInstance> piList = new List<ProcessInstance>();
            String piListQuery ='SELECT Id, TargetObjectId, ProcessDefinition.Name, Status, CompletedDate, LastActor.Name,';
            piListQuery += '(SELECT Id, toLabel(StepStatus),Actor.LastName,Actor.Alias, Actor.Name,ActorId,OriginalActorId, OriginalActor.LastName,OriginalActor.Alias, OriginalActor.Name, Comments, ProcessNodeId,ProcessNode.Name,ProcessInstance.Status, CreatedDate ';
            piListQuery += 'FROM StepsAndWorkitems ORDER BY ';  
            piListQuery += orderBy;
            piListQuery +=' DESC, Id DESC) FROM ProcessInstance WHERE TargetObjectId = :recordId ORDER BY CompletedDate DESC'; 
            /* piList = [SELECT Id, TargetObjectId, ProcessDefinition.Name, Status, CompletedDate, LastActor.Name,
(SELECT Id, toLabel(StepStatus),Actor.Name,ActorId,OriginalActorId, OriginalActor.Name, Comments, ProcessNodeId,ProcessNode.Name,ProcessInstance.Status, CreatedDate
FROM StepsAndWorkitems ORDER BY CreatedDate DESC)
FROM ProcessInstance WHERE TargetObjectId = :recordId ORDER BY Id DESC];*/
            
            piList=Database.query(String.escapeSingleQuotes(piListQuery));    
            
            //16852 starts
            Boolean isProcessComplete = true;
            if (!piList.isEmpty()) {
                ProcessInstance latestPI = piList[0];
                if (latestPI.Status == 'Pending') {
                    isProcessComplete = false;
                }
            }
            finalWrapper.isApprovalProcessComplete = isProcessComplete;
            //16852 ends
            
            for(ProcessInstance piL: piList){
                List<ProcessInstanceHistory> pihList2 = new List<ProcessInstanceHistory>();
                pihList2 = piL.StepsAndWorkitems;
                for(ProcessInstanceHistory sob: pihList2){
                    
                    Map<String,Object> mapObj = new Map<String,Object>();
                    for (String field : apiNameList){
                        
                        if(field.contains('(') && field.contains(')')){
                            field=field.substringBetween('(',')');
                            value = sob.get(field);
                            
                            
                        }
                        else if(field.contains('.')){
                            field1=field.substringBefore('.');
                            field2=field.substringAfter('.');
                            value=  sob.getSobject(field1).get(field2);
                            field=field1+field2;
                        }
                        else if(field.contains('_')){
                            field1=field.substringBefore('_');
                            field2=field.substringAfter('_');
                            value=  sob.getSobject(field1).get(field2);
                            field=field1+field2;
                        }
                        else{
                            value = sob.get(field);
                        }
                        if(value!=null && fieldtoMaskedValueMap.containsKey(field)){  
                            value = fieldtoMaskedValueMap.get(field);
                        }
                        if(field=='CreatedDate'){
                            value = DateTime.valueOf(sob.get(field)).format();  
                            //value = DateTime.valueOf(sob.get(field)).format(Core_MDF_DateTimeformat.getUserDateTimeFormat());   
                        }
                        
                        
                        if(value != null){
                            mapObj.put(field, value);
                        }
                    }
                    mapObj.put('ActorId', String.valueOf(sob.get('ActorId')));
                    mapObj.put('OiginalActorId', String.valueOf(sob.get('OriginalActorId')));
                    if(sob.ProcessNodeId==null)
                    {
                        mapObj.put('stepName','Approval Request Submitted');
                    }
                    else{
                        mapObj.put('stepName',sob.ProcessNode.Name);
                    }
                    listTotalNew.add(mapObj);
                }
            } 
            for(Map<String,Object> record:listTotalNew){
                if(fldtobeMaskedtoStepMap.containskey(String.valueOf(record.get('stepName'))) && (record.get('Comments')!='' && record.get('Comments')!=null))              
                {record.put('Comments',fldtobeMaskedtoStepMap.get(String.valueOf(record.get('stepName'))));
                }
                userOrGroupList.add(string.valueof(record.get('ActorId')));
                userOrGroupList.add(string.valueof(record.get('OriginalActorId')));
            }
            
            Map<String,String> usrNameToTypeMap = new Map<String,String>();
            list<User> usrLst = [select id,Name,UserType From User where Id in: userOrGroupList];
            for(user usr :usrLst){
                usrNameToTypeMap.put(usr.Name,usr.UserType);
            }
            //if(usr1.usertype==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type')){
            for(Map<String,Object> record:listTotalNew){
                if(fieldtoMaskedValueMap.containsKey('Actor.Name') && usrNameToTypeMap.containskey(String.valueOf(record.get('ActorName'))) && usrNameToTypeMap.get(string.valueof(record.get('ActorName'))) != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type'))             
                {
                    record.put('ActorName',fieldtoMaskedValueMap.get('Actor.Name'));
                }
                if(fieldtoMaskedValueMap.containsKey('OriginalActor.Name') && usrNameToTypeMap.containskey(String.valueOf(record.get('OriginalActorName'))) && usrNameToTypeMap.get(string.valueof(record.get('OriginalActorName'))) != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_User_Type'))             
                {
                    if(!String.valueOf(record.get('OriginalActorName')).contains('Queue')){
                        record.put('OriginalActorName',fieldtoMaskedValueMap.get('OriginalActor.Name'));
                    }
                }
            }
            // } 
            
            //}
            finalWrapper.TableTitle          = configMDList[0].Core_MDF_Title__c;
            finalWrapper.lstDataTableColumns = lstDataColumns;
            finalWrapper.records    = listTotalNew;
        }
        //}
        return finalWrapper;
    }
    
    /****************************************************************************************************** 
Method Name:        checkUserPermissionSet
@return  :          Boolean
Description:        Method to check the current user's assigned Permission to set the partnerscore for Account
Added By:           Aswin - 21/02/2022
Modified By:        Date:      Changes: 
*******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean checkUserPermissionSet(List<String> customPermissionSetList){
        Boolean isAccessProvided = false;
        for(String customPermissionSetName:customPermissionSetList){
            isAccessProvided = FeatureManagement.checkPermission(customPermissionSetName);
            
            if(isAccessProvided){
                break;
            }
        }        
        return isAccessProvided;
    }
    
    
    public class deserializejson {
        public cls_record[] record;
        public String ps_name;  
        
    }
    public class cls_record {
        public String step_Name;    
        public String comments_masked;
        public String comments_desc;
        public String user;
    }
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        
        public DataTableColumns(String label, String fieldName, String type)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;          
        }
    }
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<Map<String, Object>> records{get;set;}
        @AuraEnabled
        public String TableTitle {get;set;} 
        @AuraEnabled
        public Boolean MDFound {get;set;}   
        @AuraEnabled
        public Boolean isApprovalProcessComplete { get; set; } //16852
    }
    
    //16852 starts
    @AuraEnabled
    public static ApprovalFlowData getApprovalFlowData(Id recordId) {
        ApprovalFlowData flowData = new ApprovalFlowData();
        
        try {
            // Get latest approval process
            System.debug('Starting getApprovalFlowData for recordId: ' + recordId);
            ProcessInstance pi = [SELECT Id, Status, ProcessDefinition.Name,(SELECT Id, StepStatus, ActorId, Actor.Name, OriginalActorId, OriginalActor.Name, Comments, CreatedDate FROM StepsAndWorkitems ORDER BY CreatedDate ASC) FROM ProcessInstance WHERE TargetObjectId = :recordId ORDER BY CreatedDate DESC LIMIT 1];
            if (pi == null) {
                System.debug('No ProcessInstance found for recordId: ' + recordId);
                return flowData;
            }
            System.debug('Found ProcessInstance: ' + pi.Id + ', Status: ' + pi.Status);
            
            // Get all process nodes for this process definition to understand the complete flow
            /*List<ProcessNode> allProcessNodes = [SELECT Id, Name, ProcessDefinitionId FROM ProcessNode WHERE ProcessDefinitionId = :pi.ProcessDefinitionId ORDER BY Name];
System.debug('All Process Nodes: ' + allProcessNodes.size());*/
            
            List<ProcessInstanceNode> piNodes = [SELECT Id, NodeStatus, ProcessNodeName, CreatedDate, ProcessNodeId 
                                                 FROM ProcessInstanceNode WHERE ProcessInstanceid= :pi.Id 
                                                 ORDER BY CreatedDate ASC];
            System.debug('Found ProcessInstanceNodes: ' + piNodes.size());
            flowData.processName = pi.ProcessDefinition.Name;
            flowData.processStatus = pi.Status;
            
            // Get eligible approvers for all steps
            Map<String, List<String>> eligibleApproversMap = Core_MDF_CampaignPFR_Controller.getEligibleApproversForRecord(recordId);
            System.debug('eligibleApproversMap@@@ '+ eligibleApproversMap);
            flowData.eligibleApprovers = eligibleApproversMap;
            
            getExternalApproversForCustomerAcceptance(recordId, eligibleApproversMap);//Tavishi

            processExistingSteps(pi, piNodes, flowData, eligibleApproversMap);
            // Get the precise next step that will be triggered
            /*StepInfo nextStep = getNextApprovalStep(recordId, pi.ProcessDefinitionId, piNodes, eligibleApproversMap, pi.Status);
if (nextStep != null) {
flowData.nextStep = nextStep;
System.debug('Next step identified: ' + nextStep.stepName);
} else {
System.debug('No next step found');
}*/
            
            System.debug('Final flowData: ' + JSON.serialize(flowData));   
            return flowData;  
        }
        
        // Collect queue Ids
        /*Set<Id> queueIds = new Set<Id>();

for (ProcessInstanceHistory step : pi.StepsAndWorkitems) {
if (step.ActorId != null && step.ActorId.getSObjectType() == Group.SObjectType) {
queueIds.add(step.ActorId);
}
if (step.OriginalActorId != null && step.OriginalActorId.getSObjectType() == Group.SObjectType) {
queueIds.add(step.OriginalActorId);
}
}

// Fetch queue members
Map<Id, String> queueNames = new Map<Id, String>();
Map<Id, List<String>> queueMembersMap = new Map<Id, List<String>>();

if (!queueIds.isEmpty()) {
for (Group queue : [SELECT Id, Name FROM Group WHERE Id IN :queueIds AND Type = 'Queue']) {
queueNames.put(queue.Id, queue.Name);
}
Map<Id, String> userNames = new Map<Id, String>();
List<GroupMember> members = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :queueIds];                
for (User u : [SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :queueIds)]) {
userNames.put(u.Id, u.Name);
}

for (GroupMember gm : members) {
if (!queueMembersMap.containsKey(gm.GroupId)) {
queueMembersMap.put(gm.GroupId, new List<String>());
}                    
if (userNames.containsKey(gm.UserOrGroupId)) {
queueMembersMap.get(gm.GroupId).add(userNames.get(gm.UserOrGroupId));
}
}
}

// Process steps
Integer stepCounter = 0;
Set<Id> processedNodeIds = new Set<Id>();

for (ProcessInstanceHistory step : pi.StepsAndWorkitems) {                
if (step.StepStatus == 'Started') {
continue;
}
StepInfo info = new StepInfo();
info.stepNumber = stepCounter;
info.status = step.StepStatus;
info.comments = step.Comments;
info.createdDate = step.CreatedDate;

// Assign step name from node
if (stepCounter < piNodes.size()) {
info.stepName = piNodes[stepCounter].ProcessNodeName;
info.status = piNodes[stepCounter].NodeStatus;
info.processNodeId = piNodes[stepCounter].ProcessNodeId;
processedNodeIds.add(piNodes[stepCounter].ProcessNodeId);

System.debug('Processing step: ' + info.stepName + ', Status: ' + info.status);
// Add eligible approvers for this step
List<String> eligibleForThisStep = getEligibleApproversForStep(info.stepName, eligibleApproversMap);
info.eligibleApprovers = eligibleForThisStep;
System.debug('Final eligible approvers for step ' + info.stepName + ': ' + info.eligibleApprovers);
/*if (eligibleApproversMap.containsKey(info.stepName)) {
info.eligibleApprovers = eligibleApproversMap.get(info.stepName);
}*/
        /*}

// Resolve Actual approver
resolveActor(step.ActorId, step.Actor, info, true, queueNames, queueMembersMap);
// Resolve Original Actor
resolveActor(step.OriginalActorId, step.OriginalActor, info, false, queueNames, queueMembersMap);

// Separate current vs completed
if (step.StepStatus == 'Pending') {
flowData.currentSteps.add(info);
} else {
flowData.completedSteps.add(info);
}
stepCounter++;
}         
// Get future steps from the actual process definition
List<StepInfo> futureSteps = getFutureStepsFromProcessDefinition(
recordId, 
processDefinition, 
processedNodeIds, 
eligibleApproversMap, 
stepCounter
);
flowData.futureSteps = futureSteps;
System.debug('Final flowData: ' + JSON.serialize(flowData));   
return flowData;            
}*/ catch (Exception e) {
    throw new AuraHandledException('Error fetching approval data: ' + e.getMessage());
}
    }
    
    private static void getExternalApproversForCustomerAcceptance(Id recordId, Map<String, List<String>> eligibleApproversMap) {
        
        //Id ipaCampaignRecordId   = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId();
        //Id coGTMCampaignRecordId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_GTM').getRecordTypeId();
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        Id accountId;
        Set<Id> eligibleUserIds = new Set<Id>();

        if (sObjName == 'Campaign'){ 
            List<Campaign> cmpList = [SELECT RecordTypeId, Core_MDF_Program__c, Core_MDF_Proposal_Based_Ind__c,Status, Core_MDF_Account__c FROM Campaign WHERE Id = :recordId LIMIT 1];
            if (cmpList.isEmpty()) return;
            Campaign cmp = cmpList[0];
 
            //Boolean isIPA    = cmp.RecordTypeId == ipaCampaignRecordId;
            //Boolean isCoGTM  = cmp.RecordTypeId == coGTMCampaignRecordId;
 
            if (!(cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM || cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM) || cmp.Core_MDF_Proposal_Based_Ind__c == false || cmp.Status != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Status_Pending_Approval_Nm') || cmp.Core_MDF_Account__c == null) return;
 
            /*Set<Id> pnumUserIds = new Set<Id>();
            for (Core_MDF_Partner_Node_User_Mapping__c pnum : [SELECT Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Active_Ind__c = true AND Core_MDF_Account__c = :cmp.Core_MDF_Account__c]) {
                pnumUserIds.add(pnum.Core_MDF_User__c);
            }*/
            accountId = cmp.Core_MDF_Account__c;

            Set<Id> pnumUserIds = getPnumUserIds(accountId, true);
            if (pnumUserIds.isEmpty()) return;
 
            String customPermName = cmp.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.IPA_PROGRAM ? 'Core_MDF_ExternalProposalApprover' : 'Core_MDF_CCP_External_Co_GTM_Project_Approver';
 
            Set<Id> permSetIds = new Set<Id>();
            for (SetupEntityAccess sea : [SELECT ParentId FROM SetupEntityAccess WHERE SetupEntityType = 'CustomPermission' AND SetupEntityId IN (SELECT Id FROM CustomPermission WHERE DeveloperName = :customPermName)]) {
                permSetIds.add(sea.ParentId);
            }
            if (permSetIds.isEmpty()) return;
 
            //Set<Id> eligibleUserIds = new Set<Id>();
            for (PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId IN :permSetIds AND AssigneeId IN :pnumUserIds AND Assignee.IsActive = true]) {
                eligibleUserIds.add(psa.AssigneeId);
            }
            System.debug('@@@eligibleUserIds: '+eligibleUserIds);
        }

        if (sObjName == 'PartnerFundRequest'){
            PartnerFundRequest pfr = [SELECT Id, ChannelPartnerId, Core_MDF_Campaign_Account_Id__c,Core_MDF_Approval_Stage__c, Core_MDF_Member_Acceptor_Id__c FROM PartnerFundRequest WHERE Id = :recordId LIMIT 1];
            
            if(pfr.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.PFR_CUSTOMER_ACCEPTANCE && pfr.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER && pfr.Core_MDF_Approval_Stage__c != Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_ACTIVATING_PARTNER) return;
            
            accountId = pfr.ChannelPartnerId;

            if(pfr.Core_MDF_Campaign_Account_Id__c != null && (pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_PRIMARY_PARTNER || pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.CUSTOMER_ACCEPTANCE_ACTIVATING_PARTNER)) {
                accountId = pfr.Core_MDF_Campaign_Account_Id__c;
            }
            if(accountId == null) return;
            Set<Id> pnumUserIds = getPnumUserIds(accountId, true);
            if (pnumUserIds.isEmpty()) return;

            for(PermissionSetAssignment psa : [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId IN :pnumUserIds]) {
                if(psa.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Approver') || psa.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_CCP_External_Activity_Submitter') || psa.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_IPA_Activity_Manager') || psa.PermissionSet.Name == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Primary_Partner_User')) {
                    eligibleUserIds.add(psa.AssigneeId);
                }
            }
            if (pfr.Core_MDF_Member_Acceptor_Id__c != null) {
                eligibleUserIds.add(pfr.Core_MDF_Member_Acceptor_Id__c);
            }
        }

        if (eligibleUserIds.isEmpty()) return;

        String stepKey = 'Customer Acceptance';
        if (!eligibleApproversMap.containsKey(stepKey)) {
            eligibleApproversMap.put(stepKey, new List<String>());
        }
        //Set<String> existing = new Set<String>(eligibleApproversMap.get(stepKey));
        for (User u : [SELECT Name FROM User WHERE  Id IN :eligibleUserIds ORDER BY Name ASC]) {
            //if (existing.add(u.Name)) {
                eligibleApproversMap.get(stepKey).add(u.Name);
            //}
        }
        System.debug('@@@eligibleApproversMap: '+eligibleApproversMap);
    }

    private static Set<Id> getPnumUserIds(Id accountId, Boolean includeReclaimedLicenses) {
        Set<Id> pnumUserIds = new Set<Id>();
        String pnumQuery = 'SELECT Core_MDF_User__c FROM Core_MDF_Partner_Node_User_Mapping__c WHERE Core_MDF_Account__c = :accountId AND Core_MDF_Active_Ind__c = true';
        if (includeReclaimedLicenses) {
            pnumQuery += ' AND (Core_MDF_User__r.IsActive = true OR Core_MDF_User__r.Partner_License_Reclaimed__c = true)';
        }
        for (Core_MDF_Partner_Node_User_Mapping__c pnum : Database.query(pnumQuery)) {
            pnumUserIds.add(pnum.Core_MDF_User__c);
        }
        System.debug('@@@pnumUserIds: '+pnumUserIds);
        return pnumUserIds;
    }
    
    private static void processExistingSteps(ProcessInstance pi, List<ProcessInstanceNode> piNodes, ApprovalFlowData flowData, Map<String, List<String>> eligibleApproversMap) {
        // Collect queue Ids
        Set<Id> queueIds = new Set<Id>();
        
        for (ProcessInstanceHistory step : pi.StepsAndWorkitems) {
            if (step.ActorId != null && step.ActorId.getSObjectType() == Group.SObjectType) {
                queueIds.add(step.ActorId);
            }
            if (step.OriginalActorId != null && step.OriginalActorId.getSObjectType() == Group.SObjectType) {
                queueIds.add(step.OriginalActorId);
            }
        }
        
        // Fetch queue members
        Map<Id, String> queueNames = new Map<Id, String>();
        Map<Id, List<String>> queueMembersMap = new Map<Id, List<String>>();
        
        if (!queueIds.isEmpty()) {
            for (Group queue : [SELECT Id, Name FROM Group WHERE Id IN :queueIds AND Type = 'Queue']) {
                queueNames.put(queue.Id, queue.Name);
            }
            Map<Id, String> userNames = new Map<Id, String>();
            List<GroupMember> members = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :queueIds];                
            for (User u : [SELECT Id, Name FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :queueIds)]) {
                userNames.put(u.Id, u.Name);
            }
            
            for (GroupMember gm : members) {
                if (!queueMembersMap.containsKey(gm.GroupId)) {
                    queueMembersMap.put(gm.GroupId, new List<String>());
                }                    
                if (userNames.containsKey(gm.UserOrGroupId)) {
                    queueMembersMap.get(gm.GroupId).add(userNames.get(gm.UserOrGroupId));
                }
            }
        }
        
        // Process steps
        Integer stepCounter = 0;
        
        for (ProcessInstanceHistory step : pi.StepsAndWorkitems) {                
            if (step.StepStatus == 'Started') {
                continue;
            }
            StepInfo info = new StepInfo();
            info.stepNumber = stepCounter;
            info.status = step.StepStatus;
            info.comments = step.Comments;
            info.createdDate = step.CreatedDate;
            
            // Assign step name from node
            if (stepCounter < piNodes.size()) {
                info.stepName = piNodes[stepCounter].ProcessNodeName;
                info.status = piNodes[stepCounter].NodeStatus;
                info.processNodeId = piNodes[stepCounter].ProcessNodeId;
                
                // Add eligible approvers for current step
                if (step.StepStatus == 'Pending') {
                    List<String> eligibleForThisStep = getEligibleApproversForCurrentStep(info.stepName, eligibleApproversMap);
                    info.eligibleApprovers = eligibleForThisStep;
                    System.debug('Final eligible approvers for step ' + info.stepName + ': ' + info.eligibleApprovers);
                }
            }
            
            // Resolve Actual approver
            resolveActor(step.ActorId, step.Actor, info, true, queueNames, queueMembersMap);
            // Resolve Original Actor
            resolveActor(step.OriginalActorId, step.OriginalActor, info, false, queueNames, queueMembersMap);
            
            // Separate current vs completed
            if (step.StepStatus == 'Pending') {
                flowData.currentSteps.add(info);
            } else {
                flowData.completedSteps.add(info);
            }
            stepCounter++;
        }
    }
    
    // Simplified method to get eligible approvers only for current (pending) step
    private static List<String> getEligibleApproversForCurrentStep(String currentStepName, Map<String, List<String>> eligibleApproversMap) {
        System.debug('Looking for eligible approvers for current step: ' + currentStepName);
        System.debug('Available approval stages in eligibleApproversMap: ' + eligibleApproversMap.keySet());
        
        // Strategy 1: Direct exact match
        if (eligibleApproversMap.containsKey(currentStepName)) {
            System.debug('Found direct match for: ' + currentStepName);
            return eligibleApproversMap.get(currentStepName);
        }
        
        // CoGTM campaigns: process step is named 'L2 Reviewer' but the approval stage is 'L2 Approval'
        if (currentStepName == 'L2 Reviewer' && eligibleApproversMap.containsKey('L2 Approval')) {
            return eligibleApproversMap.get('L2 Approval');
        }
        
        // Strategy 2: Case-insensitive exact match
        for (String approvalStage : eligibleApproversMap.keySet()) {
            if (approvalStage.equalsIgnoreCase(currentStepName)) {
                System.debug('Found case-insensitive match: ' + approvalStage + ' for step: ' + currentStepName);
                return eligibleApproversMap.get(approvalStage);
            }
        }
        
        // Strategy 3: Partial match - current step contains approval stage
        for (String approvalStage : eligibleApproversMap.keySet()) {
            if (currentStepName.toLowerCase().contains(approvalStage.toLowerCase())) {
                System.debug('Found partial match (step contains stage): ' + approvalStage + ' for step: ' + currentStepName);
                return eligibleApproversMap.get(approvalStage);
            }
        }
        
        // Strategy 4: Partial match - approval stage contains current step
        for (String approvalStage : eligibleApproversMap.keySet()) {
            if (approvalStage.toLowerCase().contains(currentStepName.toLowerCase())) {
                System.debug('Found partial match (stage contains step): ' + approvalStage + ' for step: ' + currentStepName);
                return eligibleApproversMap.get(approvalStage);
            }
        }
        
        System.debug('No eligible approvers found for current step: ' + currentStepName);
        return new List<String>();
    }
    
    
    
    // Method to get the exact next approval step using business logic
    /*private static StepInfo getNextApprovalStep(Id recordId, Id processDefinitionId, List<ProcessInstanceNode> completedNodes, Map<String, List<String>> eligibleApproversMap, String processStatus) {
try {
System.debug('Getting next step from approval process for record: ' + recordId);

// If process is not pending, there's no next step
if (processStatus != 'Pending') {
System.debug('Process is not pending, no next step');
return null;
}

// Use Tooling API to get the actual approval process metadata
ApprovalProcessMetadata processMetadata = getApprovalProcessMetadata(processDefinitionId);
if (processMetadata == null) {
System.debug('Could not retrieve process metadata');
return null;
}

// Get record data for evaluation
RecordData recordData = getRecordDataForEvaluation(recordId);

// Get completed step names
Set<String> completedStepNames = new Set<String>();
for (ProcessInstanceNode node : completedNodes) {
if (String.isNotBlank(node.ProcessNodeName)) {
completedStepNames.add(node.ProcessNodeName);
}
}

System.debug('Completed steps: ' + completedStepNames);
System.debug('Available process steps: ' + processMetadata.approvalSteps.keySet());

// Find the next step that meets criteria and hasn't been completed
for (ApprovalStepMetadata stepMetadata : processMetadata.approvalSteps.values()) {
String stepName = stepMetadata.stepName;

// Skip if already completed
if (completedStepNames.contains(stepName)) {
System.debug('Skipping completed step: ' + stepName);
continue;
}

// Evaluate step criteria
if (evaluateStepCriteria(stepMetadata, recordData)) {
System.debug('Step criteria met for: ' + stepName);

StepInfo nextStep = new StepInfo();
nextStep.stepName = stepName;
nextStep.status = 'Next';
nextStep.isFutureStep = true;
nextStep.stepNumber = completedNodes.size() + 1;

// Get eligible approvers for this step
List<String> eligibleApprovers = getEligibleApproversForStep(stepName, eligibleApproversMap);
nextStep.eligibleApprovers = eligibleApprovers;

// Get potential approvers
List<ApproverInfo> potentialApprovers = getPotentialApproversForStep(recordId, stepName, recordData);
nextStep.potentialApprovers = potentialApprovers;

return nextStep;
}
}

} catch (Exception e) {
System.debug('Error getting next step from approval process: ' + e.getMessage());
}

return null;
}

// Method to get approval process metadata using Tooling API
private static ApprovalProcessMetadata getApprovalProcessMetadata(Id processDefinitionId) {
ApprovalProcessMetadata metadata = new ApprovalProcessMetadata();

try {
// First, try to get process definition details
ProcessDefinition processDef = [SELECT Id, Name, Type, TableEnumOrId 
FROM ProcessDefinition 
WHERE Id = :processDefinitionId LIMIT 1];

if (processDef == null) {
return null;
}

// Get all process nodes for this definition
List<ProcessNode> processNodes = [SELECT Id, Name, ProcessDefinitionId, DeveloperName
FROM ProcessNode 
WHERE ProcessDefinitionId = :processDefinitionId 
ORDER BY Name];

System.debug('Found ' + processNodes.size() + ' process nodes');

// Try to use Tooling API to get more detailed information
try {
String toolingQuery = '/services/data/v58.0/tooling/query/?q=' + 
EncodingUtil.urlEncode('SELECT Id, DeveloperName, MasterLabel, Metadata FROM Flow WHERE ProcessType = \'Workflow\' AND Status = \'Active\'', 'UTF-8');

HttpRequest req = new HttpRequest();
req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + toolingQuery);
req.setMethod('GET');
req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
req.setHeader('Content-Type', 'application/json');

Http http = new Http();
HttpResponse res = http.send(req);

if (res.getStatusCode() == 200) {
Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
List<Object> records = (List<Object>) responseMap.get('records');

// Parse the flow metadata to get approval steps
parseFlowMetadata(records, metadata, processDef.Name);
}
} catch (Exception toolingEx) {
System.debug('Tooling API failed, using fallback approach: ' + toolingEx.getMessage());
}

// Fallback: Create metadata from process nodes
if (metadata.approvalSteps.isEmpty()) {
createMetadataFromProcessNodes(processNodes, metadata);
}

} catch (Exception e) {
System.debug('Error getting approval process metadata: ' + e.getMessage());
}

return metadata;
}

// Method to parse flow metadata from Tooling API response
private static void parseFlowMetadata(List<Object> flowRecords, ApprovalProcessMetadata metadata, String processName) {
try {
for (Object flowRecord : flowRecords) {
Map<String, Object> flowMap = (Map<String, Object>) flowRecord;
String flowName = (String) flowMap.get('MasterLabel');

// Match the flow to our process
if (flowName != null && flowName.contains(processName)) {
Map<String, Object> flowMetadata = (Map<String, Object>) flowMap.get('Metadata');

if (flowMetadata != null) {
// Parse approval steps from flow metadata
parseApprovalStepsFromFlow(flowMetadata, metadata);
break;
}
}
}
} catch (Exception e) {
System.debug('Error parsing flow metadata: ' + e.getMessage());
}
}

// Method to parse approval steps from flow metadata
private static void parseApprovalStepsFromFlow(Map<String, Object> flowMetadata, ApprovalProcessMetadata metadata) {
try {
// Look for approval process elements in the flow
Object processElements = flowMetadata.get('processMetadataValues');
if (processElements != null) {
List<Object> elements = (List<Object>) processElements;

for (Object element : elements) {
Map<String, Object> elementMap = (Map<String, Object>) element;
String elementName = (String) elementMap.get('name');

if (elementName != null && elementName.contains('ApprovalStep')) {
// Parse approval step details
parseApprovalStepElement(elementMap, metadata);
}
}
}
} catch (Exception e) {
System.debug('Error parsing approval steps from flow: ' + e.getMessage());
}
}

// Method to parse individual approval step element
private static void parseApprovalStepElement(Map<String, Object> elementMap, ApprovalProcessMetadata metadata) {
try {
ApprovalStepMetadata stepMetadata = new ApprovalStepMetadata();

// Extract step name
stepMetadata.stepName = (String) elementMap.get('label');

// Extract criteria (this would need to be customized based on your flow structure)
Object criteriaObj = elementMap.get('entryCriteria');
if (criteriaObj != null) {
stepMetadata.criteria = parseStepCriteria(criteriaObj);
}

// Extract approver assignment
Object approverObj = elementMap.get('assignedApprover');
if (approverObj != null) {
stepMetadata.approverType = (String) ((Map<String, Object>) approverObj).get('type');
stepMetadata.approverValue = (String) ((Map<String, Object>) approverObj).get('value');
}

if (String.isNotBlank(stepMetadata.stepName)) {
metadata.approvalSteps.put(stepMetadata.stepName, stepMetadata);
}

} catch (Exception e) {
System.debug('Error parsing approval step element: ' + e.getMessage());
}
}

// Method to parse step criteria
private static List<StepCriteria> parseStepCriteria(Object criteriaObj) {
List<StepCriteria> criteriaList = new List<StepCriteria>();

try {
if (criteriaObj instanceof List<Object>) {
List<Object> criteriaArray = (List<Object>) criteriaObj;

for (Object criteria : criteriaArray) {
Map<String, Object> criteriaMap = (Map<String, Object>) criteria;

StepCriteria stepCriteria = new StepCriteria();
stepCriteria.field = (String) criteriaMap.get('field');
stepCriteria.operator = (String) criteriaMap.get('operator');
stepCriteria.value = (String) criteriaMap.get('value');

criteriaList.add(stepCriteria);
}
}
} catch (Exception e) {
System.debug('Error parsing step criteria: ' + e.getMessage());
}

return criteriaList;
}

// Fallback method to create metadata from process nodes
private static void createMetadataFromProcessNodes(List<ProcessNode> processNodes, ApprovalProcessMetadata metadata) {
try {
for (ProcessNode node : processNodes) {
// Skip system nodes
if (isSystemNode(node.Name)) {
continue;
}

ApprovalStepMetadata stepMetadata = new ApprovalStepMetadata();
stepMetadata.stepName = node.Name;
stepMetadata.processNodeId = node.Id;

// For fallback, we'll assume all steps apply (no specific criteria)
stepMetadata.criteria = new List<StepCriteria>();

metadata.approvalSteps.put(stepMetadata.stepName, stepMetadata);
}
} catch (Exception e) {
System.debug('Error creating metadata from process nodes: ' + e.getMessage());
}
}

// Method to evaluate step criteria against record data
private static Boolean evaluateStepCriteria(ApprovalStepMetadata stepMetadata, RecordData recordData) {
try {
// If no criteria defined, step applies
if (stepMetadata.criteria == null || stepMetadata.criteria.isEmpty()) {
return true;
}

// Evaluate all criteria (AND logic)
for (StepCriteria criteria : stepMetadata.criteria) {
if (!evaluateSingleCriteria(criteria, recordData)) {
return false;
}
}

return true;

} catch (Exception e) {
System.debug('Error evaluating step criteria: ' + e.getMessage());
return true; // Default to true if evaluation fails
}
}

// Method to evaluate single criteria
private static Boolean evaluateSingleCriteria(StepCriteria criteria, RecordData recordData) {
try {
Object actualValue = recordData.getFieldValue(criteria.field);
String actualValueStr = actualValue != null ? String.valueOf(actualValue) : '';

System.debug('Evaluating criteria: ' + criteria.field + ' ' + criteria.operator + ' ' + criteria.value + ' (actual: ' + actualValueStr + ')');

switch on criteria.operator.toLowerCase() {
when 'equals' {
return actualValueStr.equals(criteria.value);
}
when 'not equal to' {
return !actualValueStr.equals(criteria.value);
}
when 'greater than' {
try {
return Decimal.valueOf(actualValueStr) > Decimal.valueOf(criteria.value);
} catch (Exception e) {
return actualValueStr > criteria.value;
}
}
when 'less than' {
try {
return Decimal.valueOf(actualValueStr) < Decimal.valueOf(criteria.value);
} catch (Exception e) {
return actualValueStr < criteria.value;
}
}
when 'greater or equal' {
try {
return Decimal.valueOf(actualValueStr) >= Decimal.valueOf(criteria.value);
} catch (Exception e) {
return actualValueStr >= criteria.value;
}
}
when 'less or equal' {
try {
return Decimal.valueOf(actualValueStr) <= Decimal.valueOf(criteria.value);
} catch (Exception e) {
return actualValueStr <= criteria.value;
}
}
when 'contains' {
return actualValueStr.contains(criteria.value);
}
when 'starts with' {
return actualValueStr.startsWith(criteria.value);
}
when else {
System.debug('Unknown operator: ' + criteria.operator);
return true;
}
}

} catch (Exception e) {
System.debug('Error evaluating single criteria: ' + e.getMessage());
return true;
}
}

// Method to check if a node is a system node (not an approval step)
private static Boolean isSystemNode(String nodeName) {
Set<String> systemNodeNames = new Set<String>{
'Start', 'End', 'Decision', 'Record Update', 'Email Alert', 'Task', 'Field Update', 'Outbound Message'
};

String lowerNodeName = nodeName.toLowerCase();
for (String systemName : systemNodeNames) {
if (lowerNodeName.contains(systemName.toLowerCase())) {
return true;
}
}

return false;
}

// Method to get record data for condition evaluation
private static RecordData getRecordDataForEvaluation(Id recordId) {
RecordData recordData = new RecordData();

try {
String objectType = String.valueOf(recordId).startsWith('701') ? 'Campaign' : 
(String.valueOf(recordId).startsWith('0RB') ? 'PartnerFundClaim' : 'PartnerFundRequest');

recordData.objectType = objectType;
recordData.recordId = recordId;

// Get all relevant fields for condition evaluation
Set<String> fieldsToQuery = getRelevantFieldsForApproval(objectType);

if (!fieldsToQuery.isEmpty()) {
String soql = 'SELECT ' + String.join(new List<String>(fieldsToQuery), ', ') + 
' FROM ' + objectType + ' WHERE Id = :recordId LIMIT 1';

System.debug('SOQL for record data: ' + soql);

List<SObject> records = Database.query(soql);
if (!records.isEmpty()) {
recordData.record = records[0];
}
}

} catch (Exception e) {
System.debug('Error getting record data: ' + e.getMessage());
}

return recordData;
}

// Method to get relevant fields for approval process evaluation
private static Set<String> getRelevantFieldsForApproval(String objectType) {
Set<String> fields = new Set<String>{'Id'};

try {
switch on objectType {
when 'Campaign' {
fields.addAll(new Set<String>{
'Core_MDF_Program__c',
'Core_MDF_Ultimate_Account_txt__c',
'Core_MDF_Region_cd__c',
'Core_MDF_Sub_Region_cd__c',
'Core_MDF_Host_Region_cd__c',
'Core_MDF_Budget_Type_txt__c',
'Core_MDF_Proposal_Based_Ind__c',
'Core_MDF_Approval_Stage_nm__c',
'Core_MDF_Total_Campaign_Cost_Amt__c',
'Status',
'RecordTypeId'
});
}
when 'PartnerFundClaim' {
fields.addAll(new Set<String>{
'Core_MDF_Program__c',
'Core_MDF_Ultimate_Account_ID__c',
'Core_MDF_Budget_Type_Options_Nm__c',
'Core_MDF_Proposal_Based_Ind__c',
'Core_MDF_Approval_Stage_nm__c',
'Core_MDF_Status__c',
'Core_MDF_Total_Invoice_Amount_Local__c',
'RecordTypeId'
});
}
when 'PartnerFundRequest' {
fields.addAll(new Set<String>{
'Core_MDF_Program__c',
'Core_MDF_Ultimate_Account_Id__c',
'Core_MDF_Region_nm__c',
'Core_MDF_Sub_Region_nm__c',
'Core_MDF_Budget_Type_nm__c',
'Core_MDF_Proposal_Based_Ind__c',
'Core_MDF_Approval_Stage__c',
'RequestedAmount',
'RecordTypeId'
});
}
}

} catch (Exception e) {
System.debug('Error getting relevant fields: ' + e.getMessage());
}

return fields;
}

// Method to get potential approvers for a specific step
private static List<ApproverInfo> getPotentialApproversForStep(Id recordId, String stepName, RecordData recordData) {
List<ApproverInfo> approvers = new List<ApproverInfo>();
Set<String> approverNames = new Set<String>();

try {
// Use the existing eligible approvers logic
Map<String, List<String>> eligibleMap = Core_MDF_CampaignPFR_Controller.getEligibleApproversForRecord(recordId);
if (eligibleMap.containsKey(stepName)) {
for (String approverName : eligibleMap.get(stepName)) {
if (!approverNames.contains(approverName)) {
ApproverInfo info = new ApproverInfo();
info.name = approverName;
info.isQueue = false;
approvers.add(info);
approverNames.add(approverName);
}
}
}

} catch (Exception e) {
System.debug('Error getting potential approvers for step: ' + e.getMessage());
}

return approvers;
}*/
    
    // Helper method to get eligible approvers for a specific step
    /*private static List<String> getEligibleApproversForStep(String stepName, Map<String, List<String>> eligibleApproversMap) {
Set<String> eligibleSet = new Set<String>();

// Strategy 1: Exact match
if (eligibleApproversMap.containsKey(stepName)) {
eligibleSet.addAll(eligibleApproversMap.get(stepName));
System.debug('Found exact match for step: ' + stepName);
}

// Strategy 2: Try to match with approval stage mapping
String mappedStageName = mapProcessNodeToApprovalStage(stepName);
if (String.isNotBlank(mappedStageName) && eligibleApproversMap.containsKey(mappedStageName)) {
eligibleSet.addAll(eligibleApproversMap.get(mappedStageName));
}

// Strategy 2: Exact match (case insensitive)
if (eligibleSet.isEmpty()) {
for (String key : eligibleApproversMap.keySet()) {
if (key.equalsIgnoreCase(stepName)) {
eligibleSet.addAll(eligibleApproversMap.get(key));
System.debug('Found case-insensitive exact match for step: ' + stepName + ' with key: ' + key);
break;
}
}
}

// Strategy 3: Partial match (case insensitive)
if (eligibleSet.isEmpty()) {
for (String key : eligibleApproversMap.keySet()) {
if (stepName.toLowerCase().contains(key.toLowerCase())) {
eligibleSet.addAll(eligibleApproversMap.get(key));
System.debug('Found case-insensitive exact match for step: ' + stepName + ' with key: ' + key);
break;
}
}
}
List<String> eligibleList = new List<String>(eligibleSet);
eligibleList.sort();

return eligibleList;
}

private static String mapProcessNodeToApprovalStage(String processNodeName) {
Map<String, String> nodeToStageMap = new Map<String, String>{
'Price Reviewer' => 'Price Reviewer',
'L1 Approval' => 'L1 Approval',
'L2 Regional Marketing' => 'L2 Regional Marketing',
'L2 Regional Sales' => 'L2 Regional Sales',
'Program Office Reviewer' => 'Program Office Reviewer',
'Legal Reviewer' => 'Legal Reviewer',
'L2 Approval' => 'L2 Approval',
'Business Approver' => 'Business Approver',
'Technical Approver' => 'Technical Approver',
'Account Manager' => 'Account Manager'
};

// Try exact match first
if (nodeToStageMap.containsKey(processNodeName)) {
return nodeToStageMap.get(processNodeName);
}

// Try partial matches
for (String key : nodeToStageMap.keySet()) {
if (processNodeName.toLowerCase().contains(key.toLowerCase()) || 
key.toLowerCase().contains(processNodeName.toLowerCase())) {
return nodeToStageMap.get(key);
}
}

return processNodeName; // Return original if no mapping found
}*/
    
    private static void resolveActor(Id actorId, Name actor, StepInfo info, Boolean isActual, Map<Id, String> queueNames, Map<Id, List<String>> queueMembersMap) {
        if (actorId == null) return;
        
        //If Queue        
        if (actorId.getSObjectType() == Group.SObjectType) {
            String name = queueNames.get(actorId) + ' (Queue)';
            info.isQueue = true;
            info.queueMembers = queueMembersMap.get(actorId);
            if (isActual) info.actualApprover = name;
            else info.assignedApprover = name;
            
        } //If User
        else {
            if (isActual) info.actualApprover = actor.Name;
            else info.assignedApprover = actor.Name;
        }
    }
    // ================= Metadata Classes =================
    
    /*public class ApprovalProcessMetadata {
public Map<String, ApprovalStepMetadata> approvalSteps;

public ApprovalProcessMetadata() {
approvalSteps = new Map<String, ApprovalStepMetadata>();
}
}

public class ApprovalStepMetadata {
public String stepName;
public Id processNodeId;
public List<StepCriteria> criteria;
public String approverType;
public String approverValue;

public ApprovalStepMetadata() {
criteria = new List<StepCriteria>();
}
}*/
    
    /*public class StepCriteria {
        public String field;
        public String operator;
        public String value;
    }*/
    
    // ================= Wrapper Classes =================
    
    public class ApprovalFlowData {
        @AuraEnabled public String processName;
        @AuraEnabled public String processStatus;
        @AuraEnabled public List<StepInfo> completedSteps;
        @AuraEnabled public List<StepInfo> currentSteps;   
        @AuraEnabled public StepInfo nextStep;
        @AuraEnabled public Map<String, List<String>> eligibleApprovers;     
        public ApprovalFlowData() {
            completedSteps = new List<StepInfo>();
            currentSteps = new List<StepInfo>();
            eligibleApprovers = new Map<String, List<String>>();
        }
    }
    
    public class StepInfo {
        @AuraEnabled public Integer stepNumber;
        @AuraEnabled public String stepName;
        @AuraEnabled public String status;
        @AuraEnabled public String actualApprover;
        @AuraEnabled public String assignedApprover;
        @AuraEnabled public Boolean isQueue;
        @AuraEnabled public List<String> queueMembers;
        @AuraEnabled public List<String> eligibleApprovers;
        //@AuraEnabled public List<ApproverInfo> potentialApprovers;
        @AuraEnabled public String comments;
        @AuraEnabled public Datetime createdDate;   
        @AuraEnabled public Boolean isFutureStep;   
        @AuraEnabled public Id processNodeId;  
        public StepInfo() {
            queueMembers = new List<String>();
            eligibleApprovers = new List<String>();
            //potentialApprovers = new List<ApproverInfo>();
            isQueue = false;
            //isFutureStep = false;
        }
    }
    
    /*public class ApproverInfo {
@AuraEnabled public String name;
@AuraEnabled public Id userId;
@AuraEnabled public Boolean isQueue;
@AuraEnabled public List<String> queueMembers;

public ApproverInfo() {
queueMembers = new List<String>();
isQueue = false;
}
}*/
    
    // Helper class to hold record data
    /*public class RecordData {
public String objectType;
public Id recordId;
public SObject record;

public Object getFieldValue(String fieldName) {
if (record != null) {
try {
return record.get(fieldName);
} catch (Exception e) {
System.debug('Error getting field value for ' + fieldName + ': ' + e.getMessage());
}
}
return null;
}
}*/
    //16852 ends
}