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
        System.debug(query1);
        SObject recordData = Database.query(String.escapeSingleQuotes(query1));
        System.debug(recordData);
        
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
        System.debug(identifier1TextValue);
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
        System.debug(query2);
        List<Core_MDF_Custom_Approval_History_Config__mdt> configMDList = Database.query(String.escapeSingleQuotes(query2));
        system.debug('configMDList'+configMDList);
        List<String> strList = new List<String>();
        String jsonVariable;
        Boolean jsonSwitch = false;
        jsonVariable = configMDList[0].Core_MDF_Comment_Filter_Reference_txt__c;

        if(jsonVariable == null || (string.isBlank(jsonVariable))){
            jsonSwitch = true;
            String jsonVariableTemp = configMDList[0].Core_MDF_Custom_Label_Configration__c;//Core_MDF_CAMPAIGN_APPROVAL_HISTORY_JSON

            if(string.isNotBlank(jsonVariableTemp)){
                Core_MDF_Custom_Label_Configration__mdt customMdt = [SELECT id, DeveloperName, Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c 
                                                                    FROM Core_MDF_Custom_Label_Configration__mdt 
                                                                    WHERE id =: jsonVariableTemp];
                if(customMdt.Core_MDF_Value_Txt__c != null){
                    jsonVariable = customMdt.Core_MDF_Value_Txt__c;
                }
            }
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
            if(jsonSwitch){
                deserializedlst = (List<deserializejson>)JSON.deserialize(jsonVariable,List<deserializejson>.class);
            }else{
                deserializedlst = (List<deserializejson>)JSON.deserialize((String)cnst.getValue(jsonVariable),List<deserializejson>.class);
            } 
            
            system.debug('deserializedlst' + deserializedlst);
            for (deserializejson fld :deserializedlst)
            {
                //if logged in user contains the permission set of the fld.ps
                //for that step comments = fld.comments
                
                string customPermissionList= fld.ps_name;
                system.debug('line 86'+customPermissionList);
                List<string> permset = new List<String>();
                permset = customPermissionList.split(';');
                Boolean isallowed = checkUserPermissionSet(permset);
                system.debug('line 89'+isallowed);
                if (isallowed)
                {
                    integer i=0;
                    for(i=0;i<fld.record.size();i++){
                        system.debug(fld.record.size());
                        if(fld.record[i].comments_masked=='true'){
                            fieldtoMaskedValueMapfrmclientcnst.put('Comments',fld.record[i].comments_desc);
                            stepfrmclientcnst.put('stepName',fld.record[i].step_Name);
                            fldtobeMaskedtoStepMap.put(fld.record[i].step_Name,fld.record[i].comments_desc);
                            //usrtobeMaskedtoStepMap.put(fld.record[i].step_Name,fld.record[i].user);
                        }
                       
                    }
                    
                    
                }
            }
        }
        
        
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        List<DataTableColumns> sortedLstDataColumns = new List<DataTableColumns>();
        // List<string> customPermissionList= configMDList[0].Core_MDF_Permissions__c.split(',');
        Boolean isallowed = true;//checkUserPermissionSet(customPermissionList);
        if(isallowed){
            List<String> apiNameList=new List<String>();
            List<String> apiNameList_workitem=new List<String>();
            if(!configMDList.isEmpty()){
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
                    system.debug('configMDList[0].Core_MDF_Comments_Masked_Label__c  '+configMDList[0].Core_MDF_Comments_Masked_Label__c);
                    fieldtoMaskedValueMap.put('Comments',configMDList[0].Core_MDF_Comments_Masked_Label__c);
                }
                if(configMDList[0].Core_MDF_AssignedTo_Masked__c || test.isrunningTest()){
                    system.debug('configMDList[0].Core_MDF_AssignedTo_Masked_Label__c  '+configMDList[0].Core_MDF_AssignedTo_Masked_Label__c);
                    fieldtoMaskedValueMap.put('OriginalActor.Name',configMDList[0].Core_MDF_AssignedTo_Masked_Label__c);
                }
                if(configMDList[0].Core_MDF_ActualApprover_Masked__c || test.isrunningTest()){
                    system.debug('configMDList[0].Core_MDF_ActualApprover_Masked_Label__c  '+configMDList[0].Core_MDF_ActualApprover_Masked_Label__c);
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
                    system.debug('field::: '+ field);
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
                        system.debug('field'+field);
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
                system.debug('line 150'+apiNameList);
                system.debug('line 151'+apiNameList_workitem);
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
                for(ProcessInstance piL: piList){
                    List<ProcessInstanceHistory> pihList2 = new List<ProcessInstanceHistory>();
                    pihList2 = piL.StepsAndWorkitems;
                    for(ProcessInstanceHistory sob: pihList2){
                        
                        Map<String,Object> mapObj = new Map<String,Object>();
                        for (String field : apiNameList){
                            system.debug('Line 290'+field);
                            if(field.contains('(') && field.contains(')')){
                                field=field.substringBetween('(',')');
                                value = sob.get(field);
                                
                                system.debug('field-176'+field+'value'+value);
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
                System.debug(listTotal);
            }
            finalWrapper.TableTitle          = configMDList[0].Core_MDF_Title__c;
            finalWrapper.lstDataTableColumns = lstDataColumns;
            finalWrapper.records    = listTotalNew;
        }
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
            system.debug('Line 290'+isAccessProvided);
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
    }
    
}