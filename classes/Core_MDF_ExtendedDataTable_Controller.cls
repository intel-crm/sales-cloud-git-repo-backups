public Without Sharing class Core_MDF_ExtendedDataTable_Controller {
    public static String successIds='';
    public static final string ORIGIN = 'Core_MDF_ExtendedDataTable_Controller'; 
    public static final string INFOSEVERITY = 'Info';
    public static final string PROJECT = 'Core_MDF__CCP'; //project name
    public static final String ORGWIDE_EMAIL=System.label.core_MDF_CCP_FromEmail; //from email id
    public static Map<String, Map<String,Core_MDF_CCP_Maintenance_Screen__mdt>> maintainenceScreenMetaDataMap = new Map <String,Map<String,Core_MDF_CCP_Maintenance_Screen__mdt>>();   
    static{
        
        for(Core_MDF_CCP_Maintenance_Screen__mdt medataRecords: [ SELECT Id, Core_MDF_Object_Label__c,Core_MDF_Object_API_Name__c,Core_MDF_Field_Label__c,	
                                                                 Core_MDF_Field_API_Name__c,Core_MDF_Object_Record_Name__c,Core_MDF_Column_Fields__c,Core_MDF_Fields_Editable__c,
                                                                 LookupToObjectName__c,LookupNameQuery__c,Core_MDF_Data_Type_Values__c,ShareObject__c,Core_MDF_ShareObjectFields__c
                                                                 FROM Core_MDF_CCP_Maintenance_Screen__mdt where Core_MDF_IsActive__c = true] ){
                        
			            if (maintainenceScreenMetaDataMap.containsKey(medataRecords.Core_MDF_Object_API_Name__c)) {
                            maintainenceScreenMetaDataMap.get(medataRecords.Core_MDF_Object_API_Name__c).put(medataRecords.Core_MDF_Field_API_Name__c,medataRecords);
                        } else {
                           maintainenceScreenMetaDataMap.put(medataRecords.Core_MDF_Object_API_Name__c, new Map < String,Core_MDF_CCP_Maintenance_Screen__mdt > {medataRecords.Core_MDF_Field_API_Name__c => medataRecords});
                        }
        }
    }
    @AuraEnabled(cacheable = true)
    public static DataTableResponse getReadOnlyDatatable(String objectName,List<String> selectedFields,List<String> selectedIds){
        DataTableResponse finalWrapper   = new DataTableResponse();
        try{
        String query='SELECT Id';
        List<SObject> lstDataTableData= new List<SObject>();
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        List<SharingDataTableColumns> lstSharingDataColumns = new List<SharingDataTableColumns>();
        Map<String, List<sObject>> pfrShareMap = new Map<String, List<sObject>>();
        typeAttributes typeAttributesObjIns = new typeAttributes();
        String fieldType ='';
        String fieldTypeOnDataColumns ='text';
        String fieldAPIName ='';
        String shareObjectAPIName='';
        String shareObjectQuery = '';
        Map<String,Core_MDF_CCP_Maintenance_Screen__mdt> fieldsApiToMetadataMap = new Map<String,Core_MDF_CCP_Maintenance_Screen__mdt>();
        //query metaData based on objectApi 
        fieldsApiToMetadataMap = maintainenceScreenMetaDataMap.get(objectName);
        shareObjectQuery = fieldsApiToMetadataMap.values()[0].Core_MDF_ShareObjectFields__c;
        for(String fieldAPI : fieldsApiToMetadataMap.keySet()){
            fieldTypeOnDataColumns ='text';
            fieldType = fieldsApiToMetadataMap.get(fieldAPI).Core_MDF_Data_Type_Values__c;
            fieldAPIName = fieldsApiToMetadataMap.get(fieldAPI).Core_MDF_Field_API_Name__c;
            query+=  ','+String.escapeSingleQuotes(fieldAPI);
            if(fieldType == 'lookup'){
               query+= ','+String.escapeSingleQuotes(fieldsApiToMetadataMap.get(fieldAPI).LookupNameQuery__c)  ;
                fieldAPIName = fieldsApiToMetadataMap.get(fieldAPI).LookupNameQuery__c ;
            }
             if(fieldType == 'date'){ fieldTypeOnDataColumns = 'date-local';	}
            DataTableColumns datacolumns = new DataTableColumns(fieldsApiToMetadataMap.get(fieldAPI).Core_MDF_Field_Label__c , 
                                                                fieldAPIName,
                                                                fieldTypeOnDataColumns, typeAttributesObjIns,false
                                                               );  
            lstDataColumns.add(datacolumns);                                                         
        }
        query+=' FROM ' +String.escapeSingleQuotes(objectName)+' WHERE Id IN :selectedIds' ;
        list<sObject> sObjDataList = Database.query(String.escapeSingleQuotes(query));
        lstDataTableData = sObjDataList;
        pfrShareMap = fetchSampleRecs1(objectName, selectedIds);
        String result = shareObjectQuery.remove('select');
        String[] arrOfStr2 = result.split('from');
        String arrOfStr3 = arrOfStr2[0];
        String arrOfStr = arrOfStr3.remove(' ');
        String[] arrOfStr4 = arrOfStr.split(',');
        for(String fieldAPI :arrOfStr4 ){
            SharingDataTableColumns datacolumns = new SharingDataTableColumns(fieldAPI,fieldAPI,
                                                                'text',false
                                                               );  
                lstSharingDataColumns.add(datacolumns);                                                         
        }
        finalWrapper.lstDataTableData = lstDataTableData;
        finalWrapper.lstDataTableColumns = lstDataColumns;
        finalWrapper.lstSharingTableData = pfrShareMap;
        finalWrapper.shareObjectAPIName = shareObjectAPIName;
        finalWrapper.lstSharingDataTableColumns = lstSharingDataColumns;
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return finalWrapper;        
    }
    @AuraEnabled(cacheable = true)
    public static DataTableResponse getEditableDataTable(String objectName,List<String> selectedFields,List<String> selectedIds){
        DataTableResponse finalWrapper   = new DataTableResponse();
        try{
        String query='SELECT Id';
        List<SObject> lstDataTableData= new List<SObject>();
        List<optionsObj> lstOptionsObjList = new List<optionsObj>();
        List<optionsObj> blankOptionsObjList = new List<optionsObj>();
        List<DataTableColumns> lstDataColumns = new List<DataTableColumns>();
        List<Core_MDF_CCP_Maintenance_Screen__mdt> resultData = new List<Core_MDF_CCP_Maintenance_Screen__mdt>();
        
        Map<String,Core_MDF_CCP_Maintenance_Screen__mdt> fieldsApiToMetadataMap = new Map<String,Core_MDF_CCP_Maintenance_Screen__mdt>();

        fieldsApiToMetadataMap = maintainenceScreenMetaDataMap.get(objectName);
        //JSON to make cols dynamically
        
        String fieldType=''; 
        String fieldAPIName=''; 
        String fieldTypeOnDataColumns='';
        typeAttributes typeAttributesObjIns = new typeAttributes();
        DataTableColumns datacolumns = new DataTableColumns();
        for(String field : fieldsApiToMetadataMap.keySet()){
            typeAttributesObjIns = new typeAttributes();
            fieldType = fieldsApiToMetadataMap.get(field).Core_MDF_Data_Type_Values__c;
            fieldAPIName = fieldsApiToMetadataMap.get(field).Core_MDF_Field_API_Name__c;
             
            query+=  ','+field;//Dynamic query to fetch data
            if(fieldType == 'lookup'){
                query+= ','+fieldsApiToMetadataMap.get(field).LookupNameQuery__c  ;
            }
            if(selectedFields.contains(field)){
                if(fieldType == 'lookup'){
                     List<String> fields =  new List<String>{'Name'};
                     fieldName valueId = new fieldName(fieldsApiToMetadataMap.get(field).Core_MDF_Field_API_Name__c);
                     fieldName valueName = new fieldName(fieldsApiToMetadataMap.get(field).LookupNameQuery__c);
                     fieldName currentRecordId = new fieldName('Id');
                     typeAttributesObjIns = new typeAttributes('',blankOptionsObjList,fieldsApiToMetadataMap.get(field).LookupToObjectName__c,'standard:account',fieldsApiToMetadataMap.get(field).Core_MDF_Field_Label__c,
                                                                            'Select '+fieldsApiToMetadataMap.get(field).Core_MDF_Field_Label__c,fields,'Name,Name',
                                                                             fieldsApiToMetadataMap.get(field).Core_MDF_Field_API_Name__c,
                                                                             valueId,valueName,currentRecordId
                                                                            );
                }else if(fieldType == 'picklist' || fieldType == 'multiselectPicklist'){
                    fieldName parentrecord = new fieldName('Id');
                    lstOptionsObjList = getPicklistValuesForObj(objectName,fieldsApiToMetadataMap.get(field).Core_MDF_Field_API_Name__c);
                    typeAttributesObjIns = new typeAttributes(fieldsApiToMetadataMap.get(field).Core_MDF_Field_API_Name__c,lstOptionsObjList,fieldsApiToMetadataMap.get(field).Core_MDF_Field_Label__c,
                                                                            'Select '+fieldsApiToMetadataMap.get(field).Core_MDF_Field_Label__c,parentrecord);
                    
                }
                if(fieldType == 'date'){ fieldType = 'date-local';	}
                	datacolumns = new DataTableColumns(fieldsApiToMetadataMap.get(field).Core_MDF_Field_Label__c , 
                                                                    fieldsApiToMetadataMap.get(field).Core_MDF_Field_API_Name__c,
                                                                    fieldType, typeAttributesObjIns,true
                                                                   ); 
            }else{
                //for non-editable fields
                fieldTypeOnDataColumns = 'text';
                if(fieldType == 'date'){ fieldTypeOnDataColumns = 'date-local';	}
                if(fieldType == 'lookup'){
                	fieldAPIName = fieldsApiToMetadataMap.get(field).LookupNameQuery__c ;
            	}          
                datacolumns = new DataTableColumns(fieldsApiToMetadataMap.get(field).Core_MDF_Field_Label__c , 
                                                                    fieldAPIName,
                                                                    fieldTypeOnDataColumns, typeAttributesObjIns,false
                                                                   );  
            }
            
            lstDataColumns.add(datacolumns);
        }
        query+=' FROM ' +String.escapeSingleQuotes(objectName)+' WHERE Id IN :selectedIds' ;
        list<sObject> sObjDataList = Database.query(String.escapeSingleQuotes(query));
        lstDataTableData = sObjDataList;
        finalWrapper.lstDataTableData = lstDataTableData;
        finalWrapper.lstDataTableColumns = lstDataColumns;
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return finalWrapper;
    }
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;} 
        @AuraEnabled
        public Map<String, List<sObject>> lstSharingTableData {get;set;} //sharing details data
        @AuraEnabled
        public String shareObjectAPIName {get;set;}
        @AuraEnabled
        public List<String> lstSharingTableColumns {get;set;}    
        @AuraEnabled
        public List<SharingDataTableColumns> lstSharingDataTableColumns {get;set;}
    }
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Integer initialWidth {get;set;}
        @AuraEnabled
        public boolean editable {get;set;}
        @AuraEnabled
        public typeAttributes typeAttributes {get;set;}
        public DataTableColumns(){}
        public DataTableColumns(String label, String fieldName, String type,typeAttributes typeAttributesObj,Boolean isEditable)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;   
            this.initialWidth = 300;   
            this.editable  = isEditable;       
            this.typeAttributes  = typeAttributesObj;       
        }
    }
    public class SharingDataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Integer initialWidth {get;set;}
        @AuraEnabled
        public boolean editable {get;set;}
        public SharingDataTableColumns(){}
        public SharingDataTableColumns(String label, String fieldName, String type,Boolean isEditable)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;   
            this.initialWidth = 200;   
            this.editable  = isEditable;            
        }
    }
    //for type attributes
    public class typeAttributes {
        @AuraEnabled
        public String fieldnameapi {get;set;}
        @AuraEnabled
        public List<optionsObj> options {get;set;}
        @AuraEnabled
        public fieldName parentrecord {get;set;}//added for picklist
        @AuraEnabled
        public String objectname {get;set;}//added for lookup
        @AuraEnabled
        public String icon {get;set;}//added for lookup
        @AuraEnabled
        public String label {get;set;}//added for lookup
        @AuraEnabled
        public String placeholder {get;set;}//added for lookup
        @AuraEnabled
        public List<String> fields {get;set;}//added for lookup
        @AuraEnabled
        public String displayFields {get;set;}//added for lookup
        @AuraEnabled
        public String parentAPIName {get;set;}//added for lookup
        @AuraEnabled
        public fieldName valueId {get;set;}//added for lookup
        @AuraEnabled
        public fieldName valueName {get;set;}//added for lookup
        @AuraEnabled
        public fieldName currentRecordId {get;set;}//added for lookup
       
        public typeAttributes(){}
        public typeAttributes( String fieldnameapi,List<optionsObj> lstOptionsObj,String label,String placeholder,fieldName parentrecord){
            this.label = label; 
           	this.placeholder = placeholder;
            this.options = lstOptionsObj;
            this.parentrecord = parentrecord; 
            this.fieldnameapi = fieldnameapi; 
            

        }
        public typeAttributes( String fieldnameapi,List<optionsObj> lstOptionsObj,String objectname,String icon,String label,String placeholder, List<String> fields,
                             String displayFields,String parentAPIName,fieldName valueId,fieldName valueName,fieldName currentRecordId){
            
            this.fieldnameapi = fieldnameapi; 
           	this.options = lstOptionsObj;
            this.objectname = objectname;    
            this.icon = icon; 
            this.label = label; 
           	this.placeholder = placeholder;
            this.fields = fields; 
           	this.displayFields = displayFields;
            this.parentAPIName = parentAPIName; 
           	this.valueId = valueId;
            this.valueName = valueName;
            this.currentRecordId = currentRecordId; 
                                 
                                 
        }
    }
    //Option typeAttribute for picklist
    public class optionsObj {
        @AuraEnabled
        public String label {get;set;}
   		@AuraEnabled
        public String value {get;set;}

        public optionsObj(){}
        public optionsObj(String label, String value)
        {
            this.label = label;
            this.value = value;      
           
        }
    }
    //fieldName attribute
    public class fieldName {
        @AuraEnabled
        public String fieldName {get;set;}
        public fieldName(){}
        public fieldName(String fieldName)
        {
            this.fieldName = fieldName;     
        }
    }
    public static List<optionsObj> getPicklistValuesForObj(String strObjectName,String strPicklistField){
        List<optionsObj> optionsObjList = new List<optionsObj>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            optionsObj optionsObjIns1 = new optionsObj(objPickList.getLabel(),objPickList.getValue());
            optionsObjList.add(optionsObjIns1);
		}
        return optionsObjList;
    }
    //method to fetch shared record
        @AuraEnabled
    public static  Map<String, List<sObject>> fetchSampleRecs1(String ObjectName, List<String> selectedRecId) {
        String shareObjectQuery = '';
        Map<String,Core_MDF_CCP_Maintenance_Screen__mdt> fieldsApiToMetadataMap = new Map<String,Core_MDF_CCP_Maintenance_Screen__mdt>();
        Map<String, List<sObject>> pfrShareMap = new Map<String, List<sObject>>();
        try{
        fieldsApiToMetadataMap = maintainenceScreenMetaDataMap.get(objectName);
        shareObjectQuery = fieldsApiToMetadataMap.values()[0].Core_MDF_ShareObjectFields__c;
        shareObjectQuery+=' IN :selectedRecId' ;
        if(ObjectName=='PartnerFundRequest'){
			List<PartnerFundRequestShare> prfShareRecord = Database.query(shareObjectQuery);
            for(PartnerFundRequestShare rec :prfShareRecord){
                if(pfrShareMap.containsKey(rec.ParentId)){
                  List<sObject> tempList = pfrShareMap.get(rec.ParentId)  ;
                    tempList.add(rec);
					pfrShareMap.put(rec.ParentId,tempList);                     
                }else{
                    pfrShareMap.put(rec.ParentId,new List<sObject>{rec}); 
                }
            }
        }else if(ObjectName=='Campaign'){
            List<CampaignShare > prfShareRecord = Database.query(shareObjectQuery);
            for(CampaignShare  rec :prfShareRecord){
                if(pfrShareMap.containsKey(rec.CampaignId )){
                  List<sObject> tempList = pfrShareMap.get(rec.CampaignId )  ;
                    tempList.add(rec);
					pfrShareMap.put(rec.CampaignId ,tempList);                     
                }else{
                    pfrShareMap.put(rec.CampaignId ,new List<sObject>{rec}); 
                }
            }
            
        }else if(ObjectName=='Case'){
            List<CaseShare  > prfShareRecord = Database.query(shareObjectQuery);
            for(CaseShare   rec :prfShareRecord){
                if(pfrShareMap.containsKey(rec.CaseId  )){
                  List<sObject> tempList = pfrShareMap.get(rec.CaseId  )  ;
                    tempList.add(rec);
					pfrShareMap.put(rec.CaseId  ,tempList);                     
                }else{
                    pfrShareMap.put(rec.CaseId  ,new List<sObject>{rec}); 
                }
            }
        }else if(ObjectName=='Account'){
            List<AccountShare   > prfShareRecord = Database.query(shareObjectQuery);
            for(AccountShare    rec :prfShareRecord){
                if(pfrShareMap.containsKey(rec.AccountId   )){
                  List<sObject> tempList = pfrShareMap.get(rec.AccountId   )  ;
                    tempList.add(rec);
					pfrShareMap.put(rec.AccountId   ,tempList);                     
                }else{
                    pfrShareMap.put(rec.AccountId   ,new List<sObject>{rec}); 
                }
            }
        }else if(ObjectName=='PartnerMarketingBudget'){
            List<PartnerMarketingBudgetShare > prfShareRecord = Database.query(shareObjectQuery);
            for(PartnerMarketingBudgetShare rec :prfShareRecord){
                if(pfrShareMap.containsKey(rec.ParentId)){
                  List<sObject> tempList = pfrShareMap.get(rec.ParentId    )  ;
                    tempList.add(rec);
					pfrShareMap.put(rec.ParentId    ,tempList);                     
                }else{
                    pfrShareMap.put(rec.ParentId    ,new List<sObject>{rec}); 
                }
            }
        }else if(ObjectName=='PartnerFundClaim'){
            List<PartnerFundClaimShare> prfShareRecord = Database.query(shareObjectQuery);
            for(PartnerFundClaimShare     rec :prfShareRecord){
                if(pfrShareMap.containsKey(rec.ParentId)){
                  List<sObject> tempList = pfrShareMap.get(rec.ParentId    )  ;
                    tempList.add(rec);
					pfrShareMap.put(rec.ParentId    ,tempList);                     
                }else{
                    pfrShareMap.put(rec.ParentId    ,new List<sObject>{rec}); 
                }
            }
        }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return pfrShareMap;
	}
    // update SObjects dynamically 
    @AuraEnabled()
    public static dataUpdateResult  dynamicUpdateRecords(List<SObject> records, String incidentno, String ObjectName){
        Map<String,String> recordIdToReasonMap = new Map<String,String>();
        Boolean isBatchRun = false;
        Set<String> successIdSet = new Set<String>();
        Set<String> failedIdSet = new Set<String>();
        dataUpdateResult result = new dataUpdateResult();
        try{
            String incidentnoTrim = '';
        if(incidentno!=null){
            incidentnoTrim = incidentno.trim();
        }
        Schema.SObjectType sObjectType = records.getSObjectType();
        if(records.size()>50){
            isBatchRun =true;
            Core_MDF_CCP_BatchUpadateBulkData BatchUpadateBulkData= new Core_MDF_CCP_BatchUpadateBulkData(records,incidentnoTrim,ObjectName);
            Database.executeBatch(BatchUpadateBulkData,2);            
        }else{
            List<Database.SaveResult> savedResult = database.update(records, false);
            //Creating recordIdToReasonMap
            for(Integer i=0;i<savedResult.size();i++){
                if (!savedResult?.get(i)?.isSuccess()){
                    String recordId = savedResult?.get(i)?.getId();
                    Database.Error error = savedResult?.get(i)?.getErrors()?.get(0);
                    String failedDML = error?.getMessage();
                    recordIdToReasonMap.put(recordId,failedDML);
                   	failedIdSet.add(recordId);
                }   
                else{
                    String recordId = savedResult?.get(i)?.getId();
                    recordIdToReasonMap.put(recordId,'Success');
                    successIdSet.add(recordId);
                }
            }
            for(String key : recordIdToReasonMap.KeySet()){
                        if(recordIdToReasonMap.get(key)=='Success'){
                             successIds+=key + ',';
                        }
                    }
            Core_MDF_Record_Tracking__c trackingIncidentRecord = new Core_MDF_Record_Tracking__c();
            trackingIncidentRecord.Core_MDF_Object_Name_nm__c = ObjectName;
            trackingIncidentRecord.Core_MDF_Record_Ids__c = successIds;
            trackingIncidentRecord.Core_MDF_Target_Record_Id__c = incidentnoTrim; 
            insert trackingIncidentRecord;
        }
            
       
        result = new dataUpdateResult(recordIdToReasonMap,isBatchRun);
          }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
        return result;
	}
    //wrapper class to update bulk data
    public class dataUpdateResult {
        @AuraEnabled
        public Map<String,String> recordIdToReasonMap = new Map<String,String>();
        @AuraEnabled
        public Boolean isBatchRun = false;
        public dataUpdateResult(){}
        public dataUpdateResult(Map<String,String> recordIdToReasonMap, Boolean isBatchRun)
        {
            this.recordIdToReasonMap = recordIdToReasonMap;
            this.isBatchRun = isBatchRun;      
            
        }
    }
        //Method to send email to the user who performed update of data
    public static Boolean sendEmailOnExcpetion(String loggedInUserId, String objectSelected ,String errorMsg){
        
            List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL];//query email address 
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(loggedInUserId);
            mail.setToAddresses(sendTo);
            mail.setSubject(System.Label.Core_MDF_CCP_BulkUpdateEmailSubject); 
            mail.setHtmlBody(getEmailTemplateBody(loggedInUserId,objectSelected,errorMsg));
            mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
            mails.add(mail);
            
            if(mails.size()>0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);//sending mail 
                
                if (results[0].success) 
                {   
                    return true;
                    
                } else {
                }
            }
        
        return false;   
    }
    //email template 
     public static String getEmailTemplateBody( String loggedInUserId,String objectSelected ,String errorMsg){
        
      
        List<Object> parameters = new List<Object> { loggedInUserId,objectSelected,errorMsg};
        String emailBody = System.Label.Core_MDF_CCP_BulkUpdateEmail;//email body template 
	    String formattedEmailBody = String.format(emailBody, parameters);
        return formattedEmailBody;
    }

}