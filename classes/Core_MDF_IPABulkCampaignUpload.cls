public without sharing class Core_MDF_IPABulkCampaignUpload {

    public static Map<String,Map<String, Schema.SObjectField>> fieldAPINameToFieldNameMap = new Map<String,Map<String, Schema.SObjectField>>();
    public static List<String> columnHeaderNamesList = new List<String>();
    public static List<columnsWrapper> columnsWrapperList = new List<columnsWrapper>();
    public static Map<String,Set<String>> objectNameToFieldNameSetMap = new Map<String,Set<String>>();
    public static Map<String,String> fieldNameToFieldNameAPIMap = new Map<String,String>();
    public static List<Map<String,String>> csvDataMapList = new List<Map<String,String>>();    

    static{

        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Program','Core_MDF_Program__c');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Account','Core_MDF_Account__c');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Name','Name');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Description','Description');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Start Date','StartDate');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'End Date','EndDate');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Budget Type','Core_MDF_Budget_Type_txt__c');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Reimbursement Rate','Core_MDF_Reimbursement_Rate__c');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Total Campaign Cost','Core_MDF_Total_Campaign_Cost_Amt__c');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Country/Region','Core_MDF_Market__c');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Audience','Core_MDF_Audience__c');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Technology','Core_MDF_Technology__c');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Brand','Core_MDF_Brand__c');
        fieldNameToFieldNameAPIMap.put(''+'Campaign'+'Priority','Core_MDF_IPA_Priority_nm__c');

        if(!objectNameToFieldNameSetMap.containsKey('Campaign')){
            objectNameToFieldNameSetMap.put('Campaign',new Set<String>{
                'Program',
                'Account',
                'Name',
                'Description',
                'Start Date',
                'End Date',
                'Budget Type',
                'Reimbursement Rate',
                'Total Campaign Cost',
                'Country/Region',
                'Audience',
                'Technology',
                'Brand',
                'Priority'
            });
        }
    }






    public class columnsWrapper{
        String label;
        String fieldName;
        String sortable;
        Integer initialWidth;
        public columnsWrapper(String label,String fieldName,String sortable){
            this.label = label;
            this.fieldName = fieldName;
            this.sortable = sortable;
            this.initialWidth = 34;
        }
    }

    public class outputWrapper{
        String errorCount;
        List<columnsWrapper> columns;
        List<Map<String,String>> csvDataMapList;
        Boolean synchronousProcess;
        //Id batchJobId;
        //,List<Map<String,String>> csvDataMapList

        public outputWrapper(String errorCount,List<columnsWrapper> columns,List<Map<String,String>> csvDataMapList,Boolean synchronousProcess){
            this.errorCount = errorCount;    
            this.columns = columns;
            this.csvDataMapList = csvDataMapList;
            this.synchronousProcess = synchronousProcess;
            //this.batchJobId = batchJobId;
        }
    }


    



    @AuraEnabled(cacheable=true)
    public static List<Core_MDF_Upload_File_Mapping__mdt> getUploadData() {
        return [Select Core_MDF_Platform__c,Core_MDF_Object_API_Name__c,Core_MDF_Is_Required_Ind__c,Core_MDF_ValidationRuleName__c,Core_MDF_ValidationToBeChecked__c,Core_MDF_LWCValidationMethodName__c,Core_MDF_Data_Type_nm__c,Core_MDF_Field_API_Name__c,Core_MDF_Field_Name__c,Core_MDF_Mapping_Type__c,Core_MDF_Object_Name__c, Core_MDF_Sequence_No_Nbr__c from Core_MDF_Upload_File_Mapping__mdt ORDER BY Core_MDF_Sequence_No_Nbr__c ASC];
    }


    @AuraEnabled(cacheable=true)
    public static Map<String,String> getChannelProgram() {
        Map<String, String> mapProgPickListValues = new Map<String, String>();
        for(ChannelProgram cp : [SELECT Id,Name from ChannelProgram]){
            mapProgPickListValues.put(cp.Id,cp.Name);
        }
        return mapProgPickListValues;
    }

    



    @AuraEnabled(cacheable=true)
    public static Map<String,String> getRecTypeValues(String objectName) {
        Map<String, String> mapProgPickListValues = new Map<String, String>();
        for(RecordType rt : [SELECT Id,Name,DeveloperName from RecordType WHERE SobjectType=: objectName]){
            mapProgPickListValues.put(rt.Name,rt.DeveloperName);
        }


       /*String strObjectName = objectName;
       String strPicklistField = programName;
       Map<String, String> mapProgPickListValues = new Map<String, String>();
       Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
       Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
       Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
       List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
       for (Schema.PicklistEntry objPickList : lstPickListValues) {
        mapProgPickListValues.put(objPickList.getLabel(),objPickList.getValue());
        System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
        }*/


        return mapProgPickListValues;
    }


    



    @AuraEnabled
    public static list<Sobject> readCSVFile(Id idContentDocument){
        list<Campaign> lstAccsToInsert = new list<Campaign>();
        List<Sobject> recordstoupload;
    List<String> headervalues = new List<String>();
    String csvContent;
    String[] filelines = new String[]{};
        
        Map<String,String> fieldNameToAPINameMap = new Map<String,String>();
        String a_Object_API_Name = 'Campaign';
        
        List<Core_MDF_Upload_File_Mapping__mdt> mdt = getUploadData();
        
       for( Core_MDF_Upload_File_Mapping__mdt m : mdt ) {
           if(m.Core_MDF_Object_Name__c == a_Object_API_Name){
               fieldNameToAPINameMap.put(m.Core_MDF_Field_Name__c,m.Core_MDF_Field_API_Name__c);
           }
            
        }
        System.debug('fieldNameToAPINameMap:'+ fieldNameToAPINameMap);
        
        if(idContentDocument != null) {
            
            Core_MDF_BulkAPIUtility.BulkDataWrapper x = new Core_MDF_BulkAPIUtility.BulkDataWrapper();
            List<Id> idList= new List<Id>();
            idList.add(idContentDocument);
            List<Core_MDF_BulkAPIUtility.BulkDataWrapper> bulkInsert =  new List<Core_MDF_BulkAPIUtility.BulkDataWrapper>();
            x.objectName = 'Campaign';
            x.operation = 'insert';
            x.fileIdList = idList;
            bulkInsert.add(x);
            List<Core_MDF_BulkAPIUtility.ResponseWrapper> res = Core_MDF_BulkAPIUtility.importBulkdata(bulkInsert);
            system.debug('res:'+res);
            
            // getting File Data based on document id 
            /*ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:idContentDocument];
            
            String nameFile =blobToString( objVersion.VersionData,'ISO-8859-1');
            
            filelines = nameFile.split('\n');

            
            recordstoupload= new List<Sobject>();
            headerValues =new List<String>();
            headerValues = filelines[0].trim().split(',');
            System.debug('**headerValues**'+headerValues );

            for (Integer i=1;i<filelines.size();i++)
    {
        String[] inputvalues = new String[]{};
        inputvalues = filelines[i].split(',');
        System.debug('**inputvalues**'+inputvalues);
        sObject sObj = Schema.getGlobalDescribe().get('Campaign').newSObject() ;
        SObjectType sObjType = Schema.getGlobalDescribe().get('Campaign');
        Map<String,Schema.SObjectField> fields = sObjType.getDescribe().fields.getMap();
        for(Integer j=0;j<headerValues.size();j++){
            system.debug('headerValues[j]:'+headerValues[j]);
            system.debug('fields.get(fieldNameToAPINameMap.get(headerValues[j])):'+fields.get(fieldNameToAPINameMap.get(headerValues[j])));
    Schema.DescribeFieldResult currentField = fields.get(fieldNameToAPINameMap.get(headerValues[j])).getDescribe();
    if(currentField.getType() == Schema.DisplayType.Date){
        sObj.put(fieldNameToAPINameMap.get(headerValues[j]),Date.parse(inputvalues[j])) ;
    } else if(currentField.getType() == Schema.DisplayType.CURRENCY){
        sObj.put(fieldNameToAPINameMap.get(headerValues[j]),Decimal.valueOf(inputvalues[j])) ;
    }
    else {
        sObj.put(fieldNameToAPINameMap.get(headerValues[j]),String.ValueOf(inputvalues[j])) ;
    }
}
        
        System.debug('**sObj**'+sObj);
        recordstoupload.add(sObj);
    }

    csvContent = headerValues +'\n';

    try{  
    Database.SaveResult[] srList = Database.insert(recordstoupload, false);
    for (Database.SaveResult sr : srList) {
        if (sr.isSuccess()) {
        System.debug('**SUCCESS**'+sr.getId());
            csvContent = csvContent+'\n';
        }
        else{
            for(Database.Error err : sr.getErrors()) {
                csvContent = csvContent + sr.getErrors()  + '\n';
                System.debug('If object is not present Exception'+sr.getErrors());
            }
        } 

    }
            
            
}

            catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            } */
        }
        return recordstoupload;    
    }


    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }  





    @AuraEnabled
    public static String saveFile(String base64Data, String objectName){

        List<Sobject> recordstoupload;
        system.debug('base64Data:'+base64Data);
        system.debug('objectName:'+objectName);
       
        String data = JSON.deserializeUntyped(base64Data).toString();
        List<sobject> lstCCToInsert = new List<sobject>();
        List<String> lstCSVLines = data.split('\n');
        system.debug('lstCSVLines:'+lstCSVLines);

        Map<String,String> fieldNameToAPINameMap = new Map<String,String>();
        String a_Object_API_Name = objectName;
        Map<String, Schema.SObjectField> M_Objects_Schema_Field = Schema.getGlobalDescribe().get(a_Object_API_Name).getDescribe().fields.getMap();
        // for( String a_Field_Name : M_Objects_Schema_Field.keySet() ) {
        //     Schema.DescribeFieldResult a_Field_Description = M_Objects_Schema_Field.get( a_Field_Name ).getDescribe();
        //     fieldNameToAPINameMap.put(a_Field_Description.getLabel(),a_Field_Description.getName());
        // }
        for(Core_MDF_Upload_File_Mapping__mdt mappedData : [Select Core_MDF_Field_Name__c, Core_MDF_Field_API_Name__c FROM Core_MDF_Upload_File_Mapping__mdt Where Core_MDF_Object_API_Name__c= :objectName]){
            fieldNameToAPINameMap.put(mappedData.Core_MDF_Field_Name__c, mappedData.Core_MDF_Field_API_Name__c);
        }
        System.debug('fieldNameToAPINameMap.keySet()'+ fieldNameToAPINameMap.keySet());
        System.debug('fieldNameToAPINameMap.values()'+ fieldNameToAPINameMap.values());
        List<String> headerModified = new List<String>();
        //if(objectName == 'Campaign'){
            String[] header = lstCSVLines[0].split(',');
            system.debug('header:'+header);

            List<String> lstCSVLinesTemp = new List<String>(lstCSVLines);
            lstCSVLinesTemp.remove(0);
            recordstoupload= new List<Sobject>();           
            for(Integer i=0 ; i<header.size();i++){
                String h = header[i];
                System.debug('h:'+h);
                headerModified.add(fieldNameToAPINameMap.get(h));
            }

            system.debug('headerModified:'+headerModified);

            
            for(Integer i=1;i<lstCSVLines.size()-1;i++){
                String[] inputvalues = new String[]{};
                inputvalues = lstCSVLines[i].split(',');
                System.debug('**inputvalues**'+inputvalues);
                sObject sObj = Schema.getGlobalDescribe().get('Core_MDF_BulkProposal_Line_Item__c').newSObject() ;
                Schema.SObjectType sObjType = Schema.getGlobalDescribe().get('Core_MDF_BulkProposal_Line_Item__c');
                System.debug('**sObj**'+sObj);

                Map<String,Schema.SObjectField> fields = sObjType.getDescribe().fields.getMap();
                System.debug('fields'+fields);
                for(Integer j=0;j<headerModified.size();j++){
                    System.debug('headerModified[j]:'+headerModified[j]);
                    if(headerModified[j] != null){
                        Schema.DescribeFieldResult currentField = fields.get(headerModified[j]).getDescribe();
                        if(currentField.getType() == Schema.DisplayType.Date){
                            System.debug('currentField.getType()'+currentField.getType());
                            sObj.put(headerModified[j],Date.parse(inputvalues[j])) ;
                        } 
                        else if(currentField.getType() == Schema.DisplayType.DOUBLE){
                            System.debug('currentField.getType()'+currentField.getType());
                            sObj.put(headerModified[j],Decimal.valueOf(inputvalues[j])) ;
                        }
                        else{
                            System.debug('currentField.getType()'+currentField.getType());
                            sObj.put(headerModified[j],String.ValueOf(inputvalues[j])) ;
                        }
                    }
                }
                System.debug('**sObj**'+sObj);
                recordstoupload.add(sObj);
            }
            Database.SaveResult[] uploadedrec =  Database.insert(recordstoupload,false);
            System.debug(uploadedrec);
            for (Database.SaveResult sr : uploadedrec) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted Bulk Proposal line item. Core_MDF_BulkProposal_Line_Item__c ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }

        //}

        Integer lastRowToBeProcessed = lstCSVLines.size();
        csvDataMapList = sendCSVEmail(lstCSVLines,headerModified,objectName,lastRowToBeProcessed);
        return 'true';
        //return JSON.serialize(new outputWrapper(''+1+'/'+1+ ' Records uploaded Successfully',columnsWrapperList,csvDataMapList,true));

    }

    public static List<Map<String,String>> sendCSVEmail(List<String> lstCSVLines,List<String> columnHeaderNamesList,String objectName,Integer lastRowToBeProcessed){
        string mainContent = ''; 
        columnHeaderNamesList.add('Result');  
        columnHeaderNamesList.add('Reason');      
        List<Map<String,String>> csvDataMapList = new List<Map<String,String>>();
        for(Integer i = 0; i < lstCSVLines.size(); i++){
            String csvLine = lstCSVLines[i];
            String prevLine = csvLine;
            Integer startIndex;
            Integer endIndex;
            
            while(csvLine.indexOf('"') > -1){
                if(startIndex == null){
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                }else{
                    if(endIndex == null){
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                    }
                }
                if(startIndex != null && endIndex != null){
                    String sub = csvLine.substring(startIndex, endIndex);
                    sub = sub.replaceAll(',', ':comma:');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                    startIndex = null;
                    endIndex = null;
                }
            }
            List<String> columnList = new List<String>();
            Map<String,String> dataMap = new Map<String,String>();
            Integer k = 0;
            for(String column : csvLine.split(',')){
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                column = column.removeEnd('\r');
                columnList.add(column);
                if(i!=0){
                    dataMap.put(columnHeaderNamesList[k],column);
                }
                k = k+1;
            }
            if(i == 0){
                columnList.add('Result');
                columnList.add('Reason');
            }else{
                if(i <= lastRowToBeProcessed){
                    columnList.add('Failure');
                    dataMap.put(columnHeaderNamesList[k],'Failure');
                }
            }
            if(!dataMap.isEmpty()){
                csvDataMapList.add(dataMap);
            }
            mainContent = mainContent + String.join(columnList,',')+'\n';
        }
                                                            
        return csvDataMapList;
    }





    public static String getFieldType(String objectName,String fieldName){
        Schema.SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        return d.fields.getMap().get(fieldName).getDescribe().getType().name();
    }

    public static String getFieldReferenceFieldObjectName(String objectName,String fieldName){
        String referenceObjectName = '';
        Schema.SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        for(Schema.SObjectType reference : d.fields.getMap().get(fieldName).getDescribe().getReferenceTo()){
            referenceObjectName = reference.getDescribe().getName();
        }
        return referenceObjectName;
    }




    public static Map<String,Set<String>> getAllRequiredFields(Set<String> objNameSet){
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new List<String>(objNameSet));
        Map<String,Set<String>> objToRequiredFieldsMap = new Map<String,Set<String>>();
        Set<String> requiredFieldSet = new Set<String>();
        for(Schema.DescribeSObjectResult dsr : descResult){
            Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
            for(String str : fieldMap.keySet()){
                Schema.DescribeFieldResult f = fieldMap.get(str).getDescribe();
                if(f.getType() != Schema.DisplayType.Boolean && !f.isNillable()){
                    if(f.getName().contains('__c')){
                        requiredFieldSet.add(f.getName());
                    }
                }
            }
            objToRequiredFieldsMap.put(dsr.getName(),requiredFieldSet);
        }
        system.debug('objToRequiredFieldsMap:'+objToRequiredFieldsMap);
        return objToRequiredFieldsMap;
    }


    public static Map<String,Set<String>> getAllRequiredFieldsOnLayout(Map<String,String> objectNameToLayoutMap){
        Map<String,Set<String>> objectNameToRequiredFieldSetMap = new Map<String,Set<String>>();
        for(String objectName : objectNameToLayoutMap.keySet()){
            Set<String> requiredFieldSet = new Set<String>();
            List<String> layoutNameList = new List<String>();
            layoutNameList.add(objectNameToLayoutMap.get(objectName));
            List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout,layoutNameList);
            system.debug('layouts:'+layouts);
            for(Metadata.Metadata layoutMd1 : layouts){
                Metadata.Layout layoutMd = (Metadata.Layout)layoutMd1;
                for(Metadata.LayoutSection section: layoutMd.layoutSections) {
                    for(Metadata.LayoutColumn column: section.layoutColumns) {
                        if(column.layoutItems != null) {
                            for(Metadata.LayoutItem item : column.layoutItems) {
                                if(item.behavior == Metadata.UiBehavior.Required){
                                    requiredFieldSet.add(item.field);   
                                }
                            }
                        }
                    }
                }
            }
            objectNameToRequiredFieldSetMap.put(objectName,requiredFieldSet);
        }
        return objectNameToRequiredFieldSetMap;
    }

}