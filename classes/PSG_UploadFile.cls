/****************************************************************************************************
Apex Class Name : PSG_UploadFile
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is controller of Bulk Upload Component.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay                    08/13/2021                Created
*****************************************************************************************************/
@isTest
public without sharing class PSG_UploadFile{
    /*public static Map<String,String> fieldNameToFieldNameAPIMap = new Map<String,String>();
    public static Map<String,Map<String, Schema.SObjectField>> fieldAPINameToFieldNameMap = new Map<String,Map<String, Schema.SObjectField>>();
    public static Map<String,String> fieldNameToCustomFieldTypeMap = new Map<String,String>();
    public static Map<String,String> objectNameToObjectNameAPIMap = new Map<String,String>();
    public static Map<String,Set<String>> objectNameToFieldNameSetMap = new Map<String,Set<String>>();
    public static Map<String,String> parentToChildMap = new Map<String,String>();
    public static Map<String,String> childToChildRelationshipMap = new Map<String,String>();
    public static Map<String,String> lookupFieldsMap = new Map<String,String>();
    public static Boolean bulkMode = false;
    public static Integer baseNumber = 0;
    public static Integer lastRowToBeProcessed = 0;
    public static Map<Integer,String> rowErrorMap = new Map<Integer,String>();
    public static Integer successCount = 0;
    public static Integer totalCount = 0;
    public static List<Map<String,String>> csvDataMapList = new List<Map<String,String>>();
    public static Set<Integer> invalidRowSet = new Set<Integer>();
    public static String quoteNumber = '';
    public static List<String> columnHeaderNamesList = new List<String>();
    public static core_cpq_bulk_upload_batch__c bulkUploadRecord = new core_cpq_bulk_upload_batch__c();
    public static List<columnsWrapper> columnsWrapperList = new List<columnsWrapper>();
    
    static{
        for(PSG_Upload_File_Mapping__mdt mapRec : [SELECT Id,PSG_Order_Nbr__c,PSG_Custom_Type__c,PSG_Field_API_Name__c,PSG_Field_Name__c,PSG_Object_API_Name__c,
                                                   PSG_Object_Name__c,PSG_Lookup_Field_Name_nm__c,PSG_Mapping_Type__c,PSG_Parent_Object__c,PSG_Child_Object__c ,
                                                   PSG_Child_Relationship_Field_Name__c from PSG_Upload_File_Mapping__mdt 
                                                   where PSG_isActive_cb__c = true order by PSG_Order_Nbr__c asc]){
            if(mapRec.PSG_Mapping_Type__c == 'Field Mapping'){                                        
                fieldNameToFieldNameAPIMap.put(''+mapRec.PSG_Object_Name__c+mapRec.PSG_Field_Name__c,mapRec.PSG_Field_API_Name__c);
                objectNameToObjectNameAPIMap.put(mapRec.PSG_Object_Name__c,mapRec.PSG_Object_API_Name__c);
                if(!objectNameToFieldNameSetMap.containsKey(mapRec.PSG_Object_Name__c)){
                    objectNameToFieldNameSetMap.put(mapRec.PSG_Object_Name__c,new Set<String>{mapRec.PSG_Field_Name__c});
                }else{
                    objectNameToFieldNameSetMap.get(mapRec.PSG_Object_Name__c).add(mapRec.PSG_Field_Name__c);
                }
                fieldNameToCustomFieldTypeMap.put(''+mapRec.PSG_Object_Name__c+mapRec.PSG_Field_Name__c,mapRec.PSG_Custom_Type__c);
                if(String.isNotBlank(mapRec.PSG_Lookup_Field_Name_nm__c)){
                    lookupFieldsMap.put(''+mapRec.PSG_Object_API_Name__c+mapRec.PSG_Field_API_Name__c,mapRec.PSG_Lookup_Field_Name_nm__c);
                }
            }else{
                parentToChildMap.put(mapRec.PSG_Parent_Object__c,mapRec.PSG_Child_Object__c);
                childToChildRelationshipMap.put(mapRec.PSG_Child_Object__c,mapRec.PSG_Child_Relationship_Field_Name__c);
            }
        }
    }
    
    /************************************************************************************************************
	*Method Name : getAllRequiredFields
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Returns all the required fields in requested objects.
	************************************************************************************************************/
    /*public static Map<String,Set<String>> getAllRequiredFields(Set<String> objNameSet){
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
        return objToRequiredFieldsMap;
    }
    
    /************************************************************************************************************
	*Method Name : getAllRequiredFieldsOnLayout
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Returns all the required fields in layout for requested object and layout.
	************************************************************************************************************/
    /*public static Map<String,Set<String>> getAllRequiredFieldsOnLayout(Map<String,List<String>> objectNameToLayoutMap){
        Map<String,Set<String>> objectNameToRequiredFieldSetMap = new Map<String,Set<String>>();
        for(String objectName : objectNameToLayoutMap.keySet()){
            Set<String> requiredFieldSet = new Set<String>();
            List<String> layoutNameList = new List<String>();
            layoutNameList.addAll(objectNameToLayoutMap.get(objectName));
            List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout,layoutNameList);
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
    
    /************************************************************************************************************
	*Method Name : saveFile
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Insert the records from Uploaded file and returns the result.
	************************************************************************************************************/
    /*@AuraEnabled
    public static String saveFile(String base64Data, String objectName,Id recordId,String priceBookName){
        objectName=(objectName==null?objectName:String.escapeSingleQuotes(objectName));
        priceBookName=(priceBookName==null?priceBookName:String.escapeSingleQuotes(priceBookName));
        String data = JSON.deserializeUntyped(base64Data).toString();
        data=String.escapeSingleQuotes(data);
        List<String> lstCSVLines = data.split('\n');
        List<String> priceBookIdList = new List<String>();
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        Map<String,String> pbMap = new Map<String,String>();
        Map<String,Set<String>> requiredFieldsMap = new Map<String,Set<String>>();
        String originalObjectName = objectName;
        if(String.isNotBlank(priceBookName)){
            if(priceBookName != 'All'){
                priceBookList = [SELECT Id,Name from PriceBook2 where Name =: priceBookName];
            }else{
                //Changes for dynamic pricebook
                //priceBookList = [SELECT Id,Name from PriceBook2 where Name IN ('APJ','EMEA','ASMO','PRC','OEM','JAPAN')];                
                priceBookList = [SELECT Id, Name FROM Pricebook2 WHERE Name IN :Label.PSG_PriceBooks_Names.split(',')];
            }
            if(!priceBookList.isEmpty()){
                /*for(PriceBook2 pb : priceBookList){
                    if(pb.Name == 'OEM'){
                        priceBookIdList.add(pb.Id);
                        pbMap.put(pb.Id,pb.Name);
                    }
                }
                for(PriceBook2 pb : priceBookList){
                    if(pb.Name != 'OEM'){
                        priceBookIdList.add(pb.Id);
                        pbMap.put(pb.Id,pb.Name);
                    }
                }
                for(PriceBook2 pb : priceBookList){
                    priceBookIdList.add(pb.Id);
                    pbMap.put(pb.Id,pb.Name);
                }
            }
        }
        Set<String> sObjSet = new Set<String>();
        Set<String> sObjAPISet = new Set<String>();
        Boolean isSingleObjectLoad = true;
        Boolean isMultiObjectLoad = false;
        if(objectName == 'Components Price Book' || objectName == 'Tools SW Price Book'){
            objectName = 'Price Book Entry -- Components Price Book';
        }
        if(!objectName.contains(' and ') && !objectName.contains(' -- ')){
            sObjSet.add(objectName);
            sObjAPISet.add(objectNameToObjectNameAPIMap.get(objectName));
        }else if(objectName.contains(' and ')){
            sObjSet = new Set<String>(objectName.split(' and '));
            for(String temp : sObjSet){
                if(objectNameToObjectNameAPIMap.containsKey(temp)){
                    sObjAPISet.add(objectNameToObjectNameAPIMap.get(temp));
                }
            }
            isSingleObjectLoad = false;
        }else if(objectName.contains(' -- ')){
            sObjSet = new Set<String>(objectName.split(' -- '));
            isMultiObjectLoad = true;
            for(String temp : sObjSet){
                if(objectNameToObjectNameAPIMap.containsKey(temp)){
                    sObjAPISet.add(objectNameToObjectNameAPIMap.get(temp));
                }
            }
        }
        Map<String,List<String>> objectNameToLayoutListName = new Map<String,List<String>>();
        objectNameToLayoutListName.put('SBQQ__Quote__c',Label.PSG_Bulk_Upload_Quote_Layout.split(','));
        if(objectName=='Quote Line CP'){
            objectNameToLayoutListName.put('SBQQ__QuoteLine__c',Label.PSG_Bulk_Upload_Quote_Line_CP_Layout.split(','));
        }else{
            objectNameToLayoutListName.put('SBQQ__QuoteLine__c',Label.PSG_Bulk_Upload_Quote_Line_Layout.split(','));
        }
        objectNameToLayoutListName.put('core_cpq_distributor_margin__c',Label.PSG_Bulk_Upload_Distributor_Margin_Layout.split(','));
        objectNameToLayoutListName.put('core_cpq_list_price__c',Label.PSG_Bulk_Upload_List_Price_Layout.split(','));
        objectNameToLayoutListName.put('price_forward_cost__c',Label.PSG_Bulk_Upload_Forward_Cost_Layout.split(','));
        objectNameToLayoutListName.put('price_msvp__c',Label.PSG_Bulk_Upload_MSVP_Layout.split(','));
        objectNameToLayoutListName.put('pricebookentry',Label.PSG_Bulk_Upload_PriceBookEntry_Layout.split(','));
        
        requiredFieldsMap = getAllRequiredFields(sObjAPISet);
        requiredFieldsMap.putAll(getAllRequiredFieldsOnLayout(objectNameToLayoutListName));
        for(String objAPIStr : sObjAPISet){
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType objSchema = schemaMap.get(objAPIStr);
            Map<String, Schema.SObjectField> fieldMap = objSchema.getDescribe().fields.getMap();
            fieldAPINameToFieldNameMap.put(objAPIStr,fieldMap);
        }
        
        if(lstCSVLines.size() > Integer.valueOf(Label.PSG_QL_FileUploadBulkLimit) && (objectName == 'Quote Line' || objectName == 'Quote Line CP')){
            String firstLine = lstCSVLines[0];
            List<String> lstCSVLinesTemp = new List<String>(lstCSVLines);
            lstCSVLinesTemp.remove(0);
            /*PSG_BatchUploadFile batchRec = new PSG_BatchUploadFile(lstCSVLines,isSingleObjectLoad,isMultiObjectLoad,objectName,recordId,priceBookIdList,pbMap,originalObjectName,requiredFieldsMap);
            batchRec.firstLine = firstLine;
            batchRec.batchSize = Integer.valueOf(Label.PSG_QL_FileUploadBatchSize);
            Id batchJobId = DataBase.executeBatch(batchRec,Integer.valueOf(Label.PSG_QL_FileUploadBatchSize));
            return JSON.serialize(new outputWrapper('Due to the File Size, File Upload will run in the background and User will receive the email with results once the Load is complete.',null,null,false,batchJobId));*/
        /*}  
        if(lstCSVLines.size() > Integer.valueOf(Label.PSG_NonQL_FileUploadBulkLimit) && objectName != 'Quote Line' && objectName != 'Quote Line CP'){
            String firstLine = lstCSVLines[0];
            List<String> lstCSVLinesTemp = new List<String>(lstCSVLines);
            lstCSVLinesTemp.remove(0);
            /*PSG_BatchUploadFile batchRec = new PSG_BatchUploadFile(lstCSVLines,isSingleObjectLoad,isMultiObjectLoad,objectName,recordId,priceBookIdList,pbMap,originalObjectName,requiredFieldsMap);
            batchRec.firstLine = firstLine;
            batchRec.batchSize = Integer.valueOf(Label.PSG_NonQL_FileUploadBatchSize);
            Id batchJobId = DataBase.executeBatch(batchRec,Integer.valueOf(Label.PSG_NonQL_FileUploadBatchSize));
            return JSON.serialize(new outputWrapper('Due to the File Size, File Upload will run in the background and User will receive the email with results once the Load is complete.',null,null,false,batchJobId));*/
        /*}  
        return JSON.serialize(getObjectList(lstCSVLines,isSingleObjectLoad,isMultiObjectLoad,objectName,recordId,priceBookIdList,pbMap,originalObjectName,requiredFieldsMap));
    }
    
    /************************************************************************************************************
	*Method Name : getObjectList
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Converts csvlines to SOBject instances.
	************************************************************************************************************/
    /*public static outputWrapper getObjectList(List<String> lstCSVLines,Boolean isSingleObjectLoad,Boolean isMultiObjectLoad, String objectName,Id recordId,
                                              List<String> priceBookIdList,Map<String,String> pbMap,String originalObjectName,
                                              Map<String,Set<String>> requiredFieldsMap){
        Map<String,Set<String>> objectAPINameToRecordSetMap = new Map<String,Set<String>>();
        Map<String,String> objectAPINameToLookUpFieldNameMap = new Map<String,String>();
        Map<String,relationShipWrapper> groupIdToObjectMap = new Map<String,relationShipWrapper>();
        Integer objectColumnIndex;
        Integer groupIdColumnIndex;
        Integer distiCostColumnIndex;
        Integer oneToTwentyFourColumnIndex;
        Integer oneToNineColumnIndex;
        Integer opnColumnIndex;
        Integer unitPriceColumnIndex;
        Set<String> opnSet = new Set<String>();
        List<Decimal> unitCostList = new List<Decimal>();
        
        Integer emptyRowsContinuityNumber = 0;
        Integer currentRowNumber = 0;
        String currentColumnName = '';
        List<columnsWrapper> columnsWrapperList = new List<columnsWrapper>();
        Map<String,List<String>> objectRowConsiderationMap = new Map<String,List<String>>();
        objectRowConsiderationMap.put('price_forward_cost__c',new List<String>{'core_cpq_forward_cost_period_name_nm__c','core_cpq_product_opn_txt__c'});
        objectRowConsiderationMap.put('price_msvp__c',new List<String>{'core_cpq_product_nm__c','core_cpq_effective_date_dt__c'});
        objectRowConsiderationMap.put('core_cpq_distributor_margin__c',new List<String>{'core_cpq_Margin_GEO_Txt__c','core_cpq_Account_Tier_Txt__c','core_cpq_Approved_Registration_Txt__c','core_cpq_Partner_Program_Txt__c','core_cpq_Registered_Product_Txt__c','core_cpq_Effective_Date_Dt__c','core_cpq_Price_Book__c','core_cpq_product_family_txt__c','core_cpq_dm_type__c','core_cpq_end_date__c'});
        objectRowConsiderationMap.put('core_cpq_list_price__c',new List<String>{'core_cpq_lowerbound_qty__c','core_cpq_upperbound_qty__c','core_cpq_product_name__c','Pricebookentry__c'});
        objectRowConsiderationMap.put('pricebookentry',new List<String>{'Product2Id','Pricebook2Id'});
        if(objectName=='Quote Line CP'){
            objectRowConsiderationMap.put('SBQQ__QuoteLine__c',new List<String>{'SBQQ__Quote__c','recordtypeid','SBQQ__Product__c'});
        }else{
            objectRowConsiderationMap.put('SBQQ__QuoteLine__c',new List<String>{'SBQQ__Quote__c','recordtypeid','core_cpq_product_nm__c',
                'core_cpq_quote_line_type_txt__c',
                'core_cpq_lower_bound_qty_qty__c',
                'core_cpq_upper_bound_qty_nbr__c'});
            
        }
        
         //Margin Geo Excluding                                         
        Map<String,List<String>> excludeReqUniqueIdFieldMap=new Map<String,List<String>>();
        excludeReqUniqueIdFieldMap.put('core_cpq_distributor_margin__c',new List<String>{'core_cpq_Margin_GEO_Txt__c','core_cpq_product_family_txt__c'});    
                                                  
                                                  
        objectRowConsiderationMap.put('core_cpq_product_details__c',new List<String>{'core_cpq_product_application_nm__c','core_cpq_product_segment_nm__c'});                                                                   
        Map<String,Set<Integer>> objectRowNumberConsiderationMap = new Map<String,Set<Integer>>();
        for(Integer i = 0; i < lstCSVLines.size(); i++){
            String csvLine = lstCSVLines[i];
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
            
            List<String> csvRowData = new List<String>();
            for(String column : csvLine.split(',')){
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                if(String.isNotBlank(column)){
                    csvRowData.add(column.trim());
                }else{
                    csvRowData.add('');
                }
            }
            if(i == 0){
                String objectAPIName;
                Set<String> objectNameSet = new Set<String>();
                if(!isSingleObjectLoad){
                    objectNameSet.add(objectName);
                    objectName = csvRowData[objectColumnIndex];
                }else if(!isMultiObjectLoad && isSingleObjectLoad){
                    objectNameSet.add(objectName);
                }else{
                    objectNameSet = new Set<String>(objectName.split(' -- '));
                }
                
                for(Integer j=0;j<csvRowData.size();j++){
                    if(String.isNotBlank(csvRowData[j])){
                        columnHeaderNamesList.add(csvRowData[j].trim());
                        columnsWrapperList.add(new columnsWrapper(csvRowData[j].trim(),csvRowData[j].trim(),'true'));
                    }else{
                        columnHeaderNamesList.add('');
                        columnsWrapperList.add(new columnsWrapper('','','true'));
                    }
                    if(csvRowData[j] == 'Object'){
                        objectColumnIndex = j;
                    }else if(csvRowData[j] == 'GroupId'){
                        groupIdColumnIndex = j;
                    }else if(csvRowData[j] == 'Unit Cost'){
                        distiCostColumnIndex = j;
                    }else if(csvRowData[j] == '(1-24)'){
                        oneToTwentyFourColumnIndex = j;
                    }else if(csvRowData[j] == '(1-9)'){
                        oneToNineColumnIndex = j;
                    }else if(csvRowData[j] == 'Unit Price'){
                        unitPriceColumnIndex = j;
                    }
                    
                    for(String objectNameStr : objectNameSet){
                        objectAPIName = objectNameToObjectNameAPIMap.get(objectNameStr);
                        if(objectRowConsiderationMap.containsKey(objectAPIName) 
                           && fieldNameToFieldNameAPIMap.containsKey(objectNameStr+csvRowData[j])
                           && objectRowConsiderationMap.get(objectAPIName).contains(fieldNameToFieldNameAPIMap.get(objectNameStr+csvRowData[j]))
                           && (!excludeReqUniqueIdFieldMap.containsKey(objectAPIName) || !excludeReqUniqueIdFieldMap.get(objectAPIName).contains(fieldNameToFieldNameAPIMap.get(objectNameStr+csvRowData[j])))){
                               if(objectRowNumberConsiderationMap.containsKey(objectAPIName)){
                                   objectRowNumberConsiderationMap.get(objectAPIName).add(j);
                               }else{
                                   objectRowNumberConsiderationMap.put(objectAPIName,new Set<Integer>{j});
                               }
                           }
                    }
                    if(csvRowData[j] == 'Part Number'){
                        opnColumnIndex = j;
                    }
                }
                columnsWrapperList.add(new columnsWrapper('Result','Result','true'));
                columnsWrapperList.add(new columnsWrapper('Reason','Reason','true'));
            }else{
                String objectAPIName;
                Set<String> objectNameSet = new Set<String>();
                if(!isSingleObjectLoad){
                    objectNameSet.add(objectName);
                    objectName = csvRowData[objectColumnIndex];
                }else if(!isMultiObjectLoad && isSingleObjectLoad){
                    objectNameSet.add(objectName);
                }else{
                    objectNameSet = new Set<String>(objectName.split(' -- '));
                }
                for(String objectNameStr : objectNameSet){
                    objectAPIName = objectNameToObjectNameAPIMap.get(objectNameStr);
                    for(Integer k=0;k<csvRowData.size();k++){
                        if(String.isNOTBlank(csvRowData[k])){
                            if(objectNameToFieldNameSetMap.containsKey(objectNameStr) 
                               && (objectNameToFieldNameSetMap.get(objectNameStr).contains(columnHeaderNamesList[k])) 
                               && fieldNameToFieldNameAPIMap.containsKey(''+objectNameStr+columnHeaderNamesList[k])){
                                   String fieldAPIName = fieldNameToFieldNameAPIMap.get(''+objectNameStr+columnHeaderNamesList[k]);
                                   String type;
                                   if(fieldAPIName == 'Custom'){
                                       type = fieldNameToCustomFieldTypeMap.get(''+objectNameStr+columnHeaderNamesList[k]);
                                   }else{
                                       type = getFieldType(objectAPIName,fieldAPIName);   
                                   }
                                   if(type == Schema.DisplayType.Reference.name()){
                                       String referenceObjectAPIName = getFieldReferenceFieldObjectName(objectAPIName,fieldAPIName);
                                       if(lookupFieldsMap.containsKey(''+ objectAPIName + fieldAPIName)){
                                           objectAPINameToLookUpFieldNameMap.put(referenceObjectAPIName,
                                                                                 lookupFieldsMap.get(''+ objectAPIName + fieldAPIName));
                                       }
                                       if(!objectAPINameToRecordSetMap.containsKey(referenceObjectAPIName)){
                                           objectAPINameToRecordSetMap.put(referenceObjectAPIName,new Set<String>{csvRowData[k]});
                                       }else{
                                           objectAPINameToRecordSetMap.get(referenceObjectAPIName).add(csvRowData[k]);
                                       }
                                   }
                               }
                            if(opnColumnIndex == k){
                                opnSet.add(csvRowData[k]);
                            }
                        }
                    }
                }
            }
        }
        Set<String> productWithPriceBookEntrySet = new Set<String>();
        List<pricebook2> priceBookList = new List<pricebook2>([SELECT Id from pricebook2 where Name = 'Standard Price Book']);
        Id standardPriceBookId;
        if(!priceBookList.isEmpty()){
            standardPriceBookId = priceBookList[0].Id;
        }
        if(!opnSet.isEmpty()){
            for(pricebookentry pbe : [SELECT Id,Product2.Core_OPN__c,Product2Id from pricebookentry where Pricebook2.Name = 'Standard Price Book' AND Product2.Core_OPN__c IN: opnSet]){
                productWithPriceBookEntrySet.add(pbe.Product2Id);
            }
        }
        Map<String,Map<String,Id>> referenceMap = new Map<String,Map<String,Id>>();
        //Added for TWC3133-5529 
	    Map<Id,String> productOPNMap = new Map<Id,String>();
        Set<Id> productRecIdSet = new Set<Id>();
        for(String objName : objectAPINameToRecordSetMap.keySet()){
            Map<String,Id> referenceRecNameToIdMap = new Map<String,Id>();
            Set<String> recordNameSet = new Set<String>();
            String lookupField = 'Name';
            String FPGAs='Intel® FPGAs';
            String productOrg = 'Sales';
            if(objectAPINameToLookUpFieldNameMap.containsKey(objName)){
                lookupField = objectAPINameToLookUpFieldNameMap.get(objName);
            }
            for(Set<String> tempSet : objectAPINameToRecordSetMap.values()){
                recordNameSet.addAll(tempSet);
            }
            if(!recordNameSet.isEmpty()){
                String query = '';
                if(objName == 'Product2'){
                    query = 'Select Id,'+lookupField+' from '+String.escapeSingleQuotes(objName)+' where '+lookupField+' IN : recordNameSet and IsActive = true and Core_Product_Type__c =: FPGAs and Core_Product_Org__c =: productOrg';
                }else{
                    query = 'Select Id,'+lookupField+' from '+String.escapeSingleQuotes(objName)+' where '+lookupField+' IN : recordNameSet';
                }
                if(String.isNotBlank(query)){
                for(sObject rec : DataBase.Query(query)){
                    referenceRecNameToIdMap.put(((String)rec.get(lookupField)),rec.Id);
                    //Added for TWC3133-5529 
		            productRecIdSet.add(rec.Id);
                 }   
                }
            }
            referenceMap.put(objName,referenceRecNameToIdMap);
        }
	    //Added for TWC3133-5529 
        if(!productRecIdSet.isEmpty()){
            for(Product2 Productrec : [Select Id,Core_OPN__c from Product2 where Id IN : productRecIdSet]){
                productOPNMap.put(Productrec.Id,Productrec.Core_OPN__c);
            }
        }
        
        for(Integer i = 0; i < lstCSVLines.size(); i++){
            String csvLine = lstCSVLines[i];

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
            
            List<String> csvRowData = new List<String>();
            for(String column : csvLine.split(',')){
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                if(String.isNotBlank(column)){
                    csvRowData.add(column.trim());
                }else{
                    csvRowData.add('');
                }
            }
            if(i==0){
                for(Integer j=0;j<csvRowData.size();j++){
                    if(String.isNotBlank(csvRowData[j])){
                    }
                    if(csvRowData[j] == 'Object'){
                        objectColumnIndex = j;
                    }else if(csvRowData[j] == 'GroupId'){
                        groupIdColumnIndex = j;
                    }
                }
            }else{
                Set<String> objectNameSet = new Set<String>();
                String objectAPIName;
                if(!isSingleObjectLoad){
                    objectAPIName = objectNameToObjectNameAPIMap.get(csvRowData[objectColumnIndex]);
                    objectNameSet.add(objectName);
                    objectName = csvRowData[objectColumnIndex];
                }else if(!isMultiObjectLoad && isSingleObjectLoad){
                    objectNameSet.add(objectName);
                    objectAPIName = objectNameToObjectNameAPIMap.get(objectName);
                }else{
                    objectNameSet = new Set<String>(objectName.split(' -- '));
                }
                Integer objectCount = 0;
                for(String objectNameStr : objectNameSet){
                    objectAPIName = objectNameToObjectNameAPIMap.get(objectNameStr);
                    sobject currentObjectRec = getNewSobject(objectAPIName);
                    Set<String> mandatoryFieldsFilled = new Set<String>();
                    dataAssignment(new List<sObject>{currentObjectRec},mandatoryFieldsFilled,objectAPIName,recordId,priceBookIdList,objectRowConsiderationMap,objectName);
                    List<sobject> currentObjectRecList = new List<sobject>();
                    Set<String> mandatoryFieldsToBeFilled = new Set<String>();
                    if(requiredFieldsMap.containsKey(objectAPIName)){
                        mandatoryFieldsToBeFilled.addAll(requiredFieldsMap.get(objectAPIName));
                    }
                    Boolean countUpdated = false;
                    Boolean byPassRow = false;
                    for(Integer k=0;k<csvRowData.size();k++){
                        byPassRow = false;
                        if(!objectRowNumberConsiderationMap.containsKey(objectAPIName)){
                            byPassRow = false;
                        }else{
                            for(Integer columnNumber : objectRowNumberConsiderationMap.get(objectAPIName)){
                                if(String.isBlank(csvRowData[columnNumber])){
                                    byPassRow = true;
                                    break;
                                }
                            }
                        }
                        if(!byPassRow){
                            if(!countUpdated){
                                countUpdated = true;
                            }
                            emptyRowsContinuityNumber = 0;
                            currentRowNumber = i;
                            if(k == 0 && objectCount == 0){
                                totalCount = totalCount + 1;
                            }
                            if(objectNameToFieldNameSetMap.containsKey(objectNameStr) 
                               && (objectNameToFieldNameSetMap.get(objectNameStr).contains(columnHeaderNamesList[k])) 
                               && fieldNameToFieldNameAPIMap.containsKey(''+objectNameStr+columnHeaderNamesList[k])){
                                   String fieldAPIName = fieldNameToFieldNameAPIMap.get(''+objectNameStr+columnHeaderNamesList[k]);
                                   String type;
                                   if(fieldAPIName == 'Custom'){
                                       type = fieldNameToCustomFieldTypeMap.get(''+objectNameStr+columnHeaderNamesList[k]);
                                   }else{
                                       type = getFieldType(objectAPIName,fieldAPIName);   
                                   }
                                   String currentColumnData = csvRowData[k];
                                   currentColumnName = columnHeaderNamesList[k];
                                   if(requiredFieldsMap.containsKey(objectAPIName) && requiredFieldsMap.get(objectAPIName).contains(fieldAPIName) 
                                      && String.isNotBlank(currentColumnData)){
                                          mandatoryFieldsFilled.add(fieldAPIName);
                                      }
                                   if(String.isNotBlank(currentColumnData)){
                                       try{
                                           typeConversion(type,currentObjectRec,fieldAPIName,currentColumnData,
                                                          rowErrorMap,currentColumnName,mandatoryFieldsFilled,
                                                          objectNameStr,objectAPIName,currentObjectRecList,
                                                          referenceMap,i,mandatoryFieldsToBeFilled,pbMap,
                                                          columnHeaderNamesList,k,unitCostList,objectName,
                                                          oneToNineColumnIndex,oneToTwentyFourColumnIndex,
                                                          csvRowData,unitPriceColumnIndex);
                                       }catch(Exception ex){
                                           String error = '';
                                           error = currentColumnName +': '+ ex.getMessage();
                                           if(rowErrorMap.containsKey(i)){
                                               rowErrorMap.put(baseNumber+i,rowErrorMap.get(baseNumber+i)+'    >>>>    '+objectNameStr+' : '+error); 
                                           }else{
                                               rowErrorMap.put(baseNumber+i,objectNameStr+' : '+error);   
                                           }
                                       }
                                   }else if(fieldAPIName != 'Custom'){
                                       currentObjectRec.put(fieldAPIName,null);
                                   }
                               }
                            
                            if(!rowErrorMap.containsKey(baseNumber+i)){
                                if(!isSingleObjectLoad){
                                    if(k == groupIdColumnIndex){
                                        if(parentToChildMap.containsKey(objectAPIName)){
                                            groupIdToObjectMap.put(csvRowData[groupIdColumnIndex],new relationShipWrapper(currentObjectRec,new List<relationShipWrapper>(),baseNumber+i,objectNameStr,objectAPIName));   
                                        }else if(groupIdToObjectMap.containsKey(csvRowData[groupIdColumnIndex])){
                                            groupIdToObjectMap.get(csvRowData[groupIdColumnIndex]).childList.add(new relationShipWrapper(currentObjectRec,new List<relationShipWrapper>(),baseNumber+i,objectNameStr,objectAPIName));
                                        }else{
                                            groupIdToObjectMap.put(csvRowData[groupIdColumnIndex],new relationShipWrapper(null,new List<relationShipWrapper>{new relationShipWrapper(currentObjectRec,new List<relationShipWrapper>(),baseNumber+i,objectNameStr,objectAPIName)},null,null,null)); 
                                        }
                                    }
                                }else if(k == (csvRowData.size()-1)){
                                    if(currentObjectRecList.isEmpty()){
                                        currentObjectRecList.add(currentObjectRec);
                                    }
                                    for(sObject currentObjectRecVar : currentObjectRecList){
                                        if(parentToChildMap.containsKey(objectAPIName)){
                                            groupIdToObjectMap.put(objectNameStr,new relationShipWrapper(currentObjectRecVar,new List<relationShipWrapper>(),baseNumber+i,objectNameStr,objectAPIName));   
                                        }else if(groupIdToObjectMap.containsKey(objectNameStr)){
                                            groupIdToObjectMap.get(objectNameStr).childList.add(new relationShipWrapper(currentObjectRecVar,new List<relationShipWrapper>(),baseNumber+i,objectNameStr,objectAPIName));
                                        }else{
                                            groupIdToObjectMap.put(objectNameStr,new relationShipWrapper(null,new List<relationShipWrapper>{new relationShipWrapper(currentObjectRecVar,new List<relationShipWrapper>(),baseNumber+i,objectNameStr,objectAPIName)},null,null,null)); 
                                        }
                                    }
                                }  
                            }
                        }else{
                            invalidRowSet.add(baseNumber+i);
                            currentObjectRec = null;
                            emptyRowsContinuityNumber = emptyRowsContinuityNumber + 1;
                            break;
                        }
                    }
                    if(!byPassRow){
                        dataAssignment(currentObjectRecList,mandatoryFieldsFilled,objectAPIName,recordId,priceBookIdList,objectRowConsiderationMap,objectName);
                        mandatoryFieldsToBeFilled.removeAll(mandatoryFieldsFilled);
                        for(String fieldStr : mandatoryFieldsToBeFilled){
                            if(fieldAPINameToFieldNameMap.get(objectAPIName) != null){
                                String field = (fieldAPINameToFieldNameMap.get(objectAPIName)).get(fieldStr).getDescribe().getLabel();
                                if(rowErrorMap.containsKey(i)){
                                    rowErrorMap.put(baseNumber+i,rowErrorMap.get(baseNumber+i)+'    >>>>    '+objectNameStr+' : '+' Mandatory field missing '+field); 
                                }else{
                                    rowErrorMap.put(baseNumber+i,objectNameStr+' : '+' Mandatory field missing '+field);   
                                }
                            }
                        }
                    }
                    if(currentObjectRec != null){
                    }
                    objectCount = objectCount + 1;
                }
            }
            lastRowToBeProcessed = i;
            if(emptyRowsContinuityNumber >= 10){
                break;
            }
        }
        List<sObject> parentList = new List<sObject>();
        List<sObject> childList = new List<sObject>();
        List<String> parentNameList = new List<String>();
        List<String> childNameList = new List<String>();
        Database.UpsertResult[] srList1;
        Database.UpsertResult[] srList2;
        Database.UpsertResult[] srList3;
        Map<Id,Integer> rowNumberToIdMap = new Map<Id,Integer>();
        Map<Integer,Integer> insertListNumberToRowNumberMap1 = new Map<Integer,Integer>();
        Map<Integer,Integer> insertListNumberToRowNumberMap2 = new Map<Integer,Integer>();
        Map<String,Map<Integer,Integer>> insertListNumberToRowNumberObjectMap = new Map<String,Map<Integer,Integer>>();
        Map<String,List<sObject>> childObjectToUpdateMap = new Map<String,List<sObject>>();

        if(!groupIdToObjectMap.isEmpty()){
            Integer m = 0;
            String parentObjectAPIName;
            for(relationShipWrapper relationShipRec : groupIdToObjectMap.values()){
                if(relationShipRec.parent != null){
                    parentList.add(relationShipRec.parent);
                    parentNameList.add(relationShipRec.objectName);
                    parentObjectAPIName = relationShipRec.objectAPIName;
                    insertListNumberToRowNumberMap1.put(m,relationShipRec.rowNumber);
                    m = m + 1;
                }
            }
            if(!parentList.isEmpty()){
                Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(parentObjectAPIName).getDescribe().fields.getMap();
                Schema.SObjectField ftoken = fields.get('core_cpq_unique_id__c');
                srList1 = Database.upsert(parentList,ftoken,false);
            }
            for(relationShipWrapper relationShipRec : groupIdToObjectMap.values()){
                if(relationShipRec.parent != null){}
            }
        }
        List<String> objectAPINameList = new List<String>();
        List<String> objectNameList = new List<String>();
        if(!groupIdToObjectMap.isEmpty()){
            Integer n = 0;
            for(relationShipWrapper relationShipRec : groupIdToObjectMap.values()){
                for(relationShipWrapper subRelationShipRec : relationShipRec.childList){
                    if(relationShipRec.parent != null){
                        subRelationShipRec.Parent.put(childToChildRelationshipMap.get('SBQQ__QuoteLine__c'),relationShipRec.parent.Id);
                    }
                    if(subRelationShipRec.Parent != null && !rowErrorMap.containsKey(subRelationShipRec.rowNumber)){
                        childList.add(subRelationShipRec.Parent);
                        childNameList.add(subRelationShipRec.objectName);
                        insertListNumberToRowNumberMap2.put(n,subRelationShipRec.rowNumber);
                        if(!childObjectToUpdateMap.containsKey(subRelationShipRec.objectAPIName)){
                            childObjectToUpdateMap.put(subRelationShipRec.objectAPIName,new List<sObject>{subRelationShipRec.Parent});
                            objectNameList.add(subRelationShipRec.objectName);
                            Map<Integer,Integer> temp = new Map<Integer,Integer>();
                            temp.put(0,subRelationShipRec.rowNumber);
                            insertListNumberToRowNumberObjectMap.put(subRelationShipRec.objectAPIName,temp);
                        }else{
                            childObjectToUpdateMap.get(subRelationShipRec.objectAPIName).add(subRelationShipRec.Parent);
                            insertListNumberToRowNumberObjectMap.get(subRelationShipRec.objectAPIName).put(((childObjectToUpdateMap.get(subRelationShipRec.objectAPIName)).size()) - 1,subRelationShipRec.rowNumber);
                        }
                        n = n + 1;
                    }
                }
            }
            if(!childObjectToUpdateMap.isEmpty()){
                Map<Id,Id> productIdToPBEMap = new Map<Id,Id>();
                Map<Id,Id> productIdToPBMap = new Map<Id,Id>();
                objectAPINameList = new List<String>(childObjectToUpdateMap.keySet());
                List<sObject> newChildList = new List<sObject>();
                List<sObject> missingPBEChildList = new List<sObject>();
                Map<Id,List<sObject>> pbeIdToNewChildListMap = new Map<Id,List<sObject>>();
                List<sObject> newChildList2 = new List<sObject>();
                Map<Id,List<sObject>> pbeToListPriceMap = new Map<Id,List<sObject>>();
                if(objectAPINameList.size() > 0){
                    Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectAPINameList[0]).getDescribe().fields.getMap();
                    Schema.SObjectField ftoken = fields.get('core_cpq_unique_id__c');
                    for(sObject obj : childObjectToUpdateMap.get(objectAPINameList[0])){
                        if(objectAPINameList[0] == 'pricebookentry' && obj.get('Product2Id') != null){ 
                            if(!productWithPriceBookEntrySet.contains((Id)obj.get('Product2Id'))){
                                sObject tempObj = obj.clone(false, true, false, false);
                                tempObj.put('Pricebook2Id',standardPriceBookId);
                                tempObj.put('UnitPrice',0);
                                tempObj.put('core_cpq_unique_id__c','');
                                missingPBEChildList.add(tempObj);
                                productWithPriceBookEntrySet.remove((Id)obj.get('Product2Id'));
                            }
                        }
                    }
                    if(!missingPBEChildList.isEmpty()){
                        Database.insert(missingPBEChildList,false);
                    }
                    srList2 = Database.upsert(childObjectToUpdateMap.get(objectAPINameList[0]),ftoken,false);
                    List<sObject> IPListPriceList = new List<sObject>();
                    for(sObject obj : childObjectToUpdateMap.get(objectAPINameList[0])){
                        if(obj.get('Id') != null && originalObjectName == 'Tools IP/Devkit Price Book'){
                            sObject tempObj2 = getNewSobject('core_cpq_list_price__c');
                            tempObj2.put('Pricebookentry__c',((Id)obj.get('Id')));
                            tempObj2.put('core_cpq_Price_Book__c',((Id)obj.get('Pricebook2Id')));
                            tempObj2.put('core_cpq_product_name__c',((Id)obj.get('Product2Id')));
                            tempObj2.put('core_cpq_lowerbound_qty__c',1);
                            tempObj2.put('core_cpq_upperbound_qty__c',999999);
                            tempObj2.put('core_cpq_list_price_amt__c',((Decimal)obj.get('UnitPrice')));
                            //Added for TWC3133-5529 
			                if(productOPNMap.containsKey((Id)obj.get('Product2Id'))){
                            tempObj2.put('core_cpq_product_opn_txt__c',productOPNMap.get((Id)obj.get('Product2Id')));
                            }
                            if(objectRowConsiderationMap.containsKey('core_cpq_list_price__c')){
                                String uniqueValue = '';
                                for(String field : objectRowConsiderationMap.get('core_cpq_list_price__c')){
                                    uniqueValue = uniqueValue + tempObj2.get(field);
                                }
                                tempObj2.put('core_cpq_unique_id__c',uniqueValue);
                            }
                            IPListPriceList.add(tempObj2);
                        }
                    }
                    if(!IPListPriceList.isEmpty()){
                        Map<String,Schema.SObjectField> fields2 = Schema.getGlobalDescribe().get('core_cpq_list_price__c').getDescribe().fields.getMap();
                        Schema.SObjectField ftokenIP = fields2.get('core_cpq_unique_id__c');
                        Database.upsert(IPListPriceList,ftokenIP,false);
                        Integer i =0;
                        for(sObject obj : childObjectToUpdateMap.get(objectAPINameList[0])){
                            if(i < IPListPriceList.size()){
                                pbeToListPriceMap.put(((Id)obj.get('Id')),new List<sObject>{IPListPriceList[i]});
                            }
                            i = i + 1;
                        } 
                    }
                    if(objectName == 'Price Book Entry -- Components Price Book'){
                        for(sObject obj : childObjectToUpdateMap.get(objectAPINameList[0])){
                            productIdToPBEMap.put((Id)obj.get('Product2Id'),(Id)obj.get('Id'));
                            productIdToPBMap.put((Id)obj.get('Product2Id'),(Id)obj.get('Pricebook2Id'));
                        }
                    }
                }
                if(objectAPINameList.size() > 1){
                    Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectAPINameList[1]).getDescribe().fields.getMap();
                    Schema.SObjectField ftoken = fields.get('core_cpq_unique_id__c');
                    for(Integer g = 0;g < (childObjectToUpdateMap.get(objectAPINameList[1])).size();g++){
                        if(productIdToPBEMap.containsKey((Id)((childObjectToUpdateMap.get(objectAPINameList[1]))[g]).get('core_cpq_product_name__c'))){
                            ((childObjectToUpdateMap.get(objectAPINameList[1]))[g]).put('Pricebookentry__c',
                                                                                        productIdToPBEMap.get((Id)((childObjectToUpdateMap.get(objectAPINameList[1]))[g]).get('core_cpq_product_name__c')));
                            ((childObjectToUpdateMap.get(objectAPINameList[1]))[g]).put('core_cpq_Price_Book__c',
                                                                                        productIdToPBMap.get((Id)((childObjectToUpdateMap.get(objectAPINameList[1]))[g]).get('core_cpq_product_name__c')));
                            if(!pbeToListPriceMap.containsKey((Id)((childObjectToUpdateMap.get(objectAPINameList[1]))[g]).get('Pricebookentry__c'))){
                                pbeToListPriceMap.put((Id)((childObjectToUpdateMap.get(objectAPINameList[1]))[g]).get('Pricebookentry__c'),new List<sObject>{((childObjectToUpdateMap.get(objectAPINameList[1]))[g])});
                            }else{
                                pbeToListPriceMap.get((Id)((childObjectToUpdateMap.get(objectAPINameList[1]))[g]).get('Pricebookentry__c')).add((childObjectToUpdateMap.get(objectAPINameList[1]))[g]);
                            }
                            if(objectRowConsiderationMap.containsKey('core_cpq_list_price__c')){
                                String uniqueValue = '';
                                for(String field : objectRowConsiderationMap.get('core_cpq_list_price__c')){
                                    uniqueValue = uniqueValue + ((childObjectToUpdateMap.get(objectAPINameList[1]))[g]).get(field);
                                }
                                ((childObjectToUpdateMap.get(objectAPINameList[1]))[g]).put('core_cpq_unique_id__c',uniqueValue);
                            }
                        }
                    }
                    srList3 = Database.upsert(childObjectToUpdateMap.get(objectAPINameList[1]),ftoken,false);
                }
                for(List<sObject> objList : childObjectToUpdateMap.values()){
                    Integer objInt = 0;
                    for(sObject obj : objList){
                        if(obj.Id != null && (obj.Id).getSobjectType().getDescribe().getName() == 'pricebookentry'
                           && obj.get('Pricebook2Id') != null){
                               
                               Integer i = 0;
                               for(String priceBookId : priceBookIdList){
                                   if(i != 0){
                                       sObject tempObj = obj.clone(false, true, false, false);
                                       tempObj.put('Pricebook2Id',priceBookId);
                                       if(objectRowConsiderationMap.containsKey('pricebookentry')){
                                           String uniqueValue = '';
                                           for(String field : objectRowConsiderationMap.get('pricebookentry')){
                                               uniqueValue = uniqueValue + tempObj.get(field);
                                           }
                                           tempObj.put('core_cpq_unique_id__c',uniqueValue);
                                           if(unitCostList != null && objInt < unitCostList.size()){
                                               tempObj.put('price_disty_cost__c',unitCostList[objInt]);
                                           }
                                       }
                                       if(!pbeIdToNewChildListMap.containsKey(obj.Id)){
                                           pbeIdToNewChildListMap.put(obj.Id,new List<sObject>{tempObj});
                                       }else{
                                           (pbeIdToNewChildListMap.get(obj.Id)).add(tempObj);
                                       }
                                       newChildList.add(tempObj);
                                   }
                                   i = i + 1;
                               }
                               
                           }
                        objInt = objInt + 1;
                    }
                }
                Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get('pricebookentry').getDescribe().fields.getMap();
                Schema.SObjectField ftoken = fields.get('core_cpq_unique_id__c');
                if(!newChildList.isEmpty()){
                    Database.upsert(newChildList,ftoken,false);
                    for(Id pbeId : pbeToListPriceMap.keySet()){
                        if(pbeIdToNewChildListMap.containsKey(pbeId)){
                            for(sObject obj : pbeIdToNewChildListMap.get(pbeId)){
                                for(sObject obj2 : pbeToListPriceMap.get(pbeId)){
                                    sObject tempObj2 = obj2.clone(false, true, false, false);
                                    tempObj2.put('Pricebookentry__c',((Id)obj.get('Id')));
                                    tempObj2.put('core_cpq_Price_Book__c',((Id)obj.get('Pricebook2Id')));
                                    if(objectRowConsiderationMap.containsKey('core_cpq_list_price__c')){
                                        String uniqueValue = '';
                                        for(String field : objectRowConsiderationMap.get('core_cpq_list_price__c')){
                                            uniqueValue = uniqueValue + tempObj2.get(field);
                                        }
                                        tempObj2.put('core_cpq_unique_id__c',uniqueValue);
                                    }
                                    newChildList2.add(tempObj2);
                                }
                            }
                        }
                    }
                    Map<String,Schema.SObjectField> fields2 = Schema.getGlobalDescribe().get('core_cpq_list_price__c').getDescribe().fields.getMap();
                    Schema.SObjectField ftoken2 = fields2.get('core_cpq_unique_id__c');
                    if(!newChildList2.isEmpty()){
                        Database.upsert(newChildList2,ftoken2,false);
                    }
                }
            }
            for(relationShipWrapper relationShipRec : groupIdToObjectMap.values()){
                for(relationShipWrapper subRelationShipRec : relationShipRec.childList){
                    if(relationShipRec.parent != null){}
                    if(subRelationShipRec.Parent != null){
                        rowNumberToIdMap.put(subRelationShipRec.Parent.Id,relationShipRec.rowNumber);
                    }
                }
            }
        }
        if(srList1 != null){
            for(Integer i=0; i<srList1.size();i++){
                Boolean isSuccess = srList1[i].isSuccess();
                if(isSuccess){}else{
                    String error = '';
                    for(Database.Error err : srList1[i].getErrors()) {
                        error = err.getMessage();
                    }
                    Integer actualRowNumber = insertListNumberToRowNumberMap1.get(i);
                    if(rowErrorMap.containsKey(actualRowNumber)){
                        String errorMsg=rowErrorMap.get(baseNumber+actualRowNumber);
                        if(!errorMsg.containsIgnoreCase(parentNameList[i]+' : '+error)){
                        rowErrorMap.put(baseNumber+actualRowNumber,rowErrorMap.get(baseNumber+actualRowNumber)+'    >>>>    '+parentNameList[i]+' : '+error); 
                        }
                    }else{
                        rowErrorMap.put(baseNumber+actualRowNumber,parentNameList[i]+' : '+error);   
                    }
                }
            }
        }
        if(srList2 != null){
            for(Integer i=0; i<srList2.size();i++){
                Boolean isSuccess = srList2[i].isSuccess();
                if(isSuccess){}else{
                    String error = '';
                    for(Database.Error err : srList2[i].getErrors()) {
                        error = err.getMessage();
                    } 
                    Integer actualRowNumber = insertListNumberToRowNumberObjectMap.get(objectAPINameList[0]).get(i);
                    if(error.containsIgnoreCase('Duplicate external id specified')){
                        if(objectName == 'Quote Line CP'){
                            error = 'FAILED. OPN already exists';
                        }else{
                            error = 'Duplicate records found';
                        }
                    }
                    if(rowErrorMap.containsKey(actualRowNumber)){
                        String errorMsg=rowErrorMap.get(actualRowNumber);
                        if(!errorMsg.containsIgnoreCase(objectNameList[0]+' : '+error)){
                        rowErrorMap.put(actualRowNumber,rowErrorMap.get(actualRowNumber)+'    >>>>    '+objectNameList[0]+' : '+error); 
                        }
                    }else{
                        rowErrorMap.put(actualRowNumber,objectNameList[0]+' : '+error);   
                    }
                }
            }
        }
        if(srList3 != null){
            for(Integer i=0; i<srList3.size();i++) {
                Boolean isSuccess = srList3[i].isSuccess();
                if(isSuccess){}else{
                    String error = '';
                    for(Database.Error err : srList3[i].getErrors()){
                        error = err.getMessage();
                    } 
                    Integer actualRowNumber = insertListNumberToRowNumberObjectMap.get(objectAPINameList[1]).get(i); 
                    if(error.containsIgnoreCase('Duplicate external id specified')){
                        error = 'Duplicate records found';
                    }
                    if(rowErrorMap.containsKey(actualRowNumber)){
                        String errorMsg=rowErrorMap.get(baseNumber+actualRowNumber);
                        if(errorMsg != Null && !errorMsg?.containsIgnoreCase(objectNameList[1]+' : '+error)){
                            rowErrorMap.put(actualRowNumber,rowErrorMap.get(baseNumber+actualRowNumber)+'    >>>>    '+objectNameList[1]+' : '+error); 
                        }
                        //rowErrorMap.put(baseNumber+actualRowNumber,rowErrorMap.get(baseNumber+actualRowNumber)+'    >>>>    '+objectNameList[1]+' : '+error); 
                    }else{
                        rowErrorMap.put(baseNumber+actualRowNumber,objectNameList[1]+' : '+error);   
                    }
                }
            }
        }       
        
        successCount = totalCount - rowErrorMap.size();
        if(recordId != null){
            quoteNumber = [SELECT Id,name from SBQQ__Quote__c where Id =: recordId].name;
        }
        if(!bulkMode){
            bulkUploadRecord = createBatchRecord(successCount,totalCount-successCount,totalCount,originalObjectName,recordId,quoteNumber);
            csvDataMapList = sendCSVEmail(lstCSVLines,rowErrorMap,columnHeaderNamesList,objectName,bulkUploadRecord,recordId,invalidRowSet,lastRowToBeProcessed,originalObjectName);
            return new outputWrapper(''+successCount+'/'+totalCount+ ' Records uploaded Successfully',columnsWrapperList,csvDataMapList,true,null);
        }else{
            return null;
        }
    }
    
    /************************************************************************************************************
	*Method Name : sendMail
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Sends Email once the upload process finished.
	************************************************************************************************************/
    /*public static outputWrapper sendMail(Integer successCount,Integer totalCount,String objectName,Id recordId,String quoteNumber,List<String> lstCSVLines,
                                         Map<Integer,String> rowErrorMap,List<String> columnHeaderNamesList,core_cpq_bulk_upload_batch__c bulkUploadRecord,
                                         Set<Integer> invalidRowSet,Integer lastRowToBeProcessed,String originalObjectName,
                                         List<Map<String,String>> csvDataMapList,List<columnsWrapper> columnsWrapperList){
        bulkUploadRecord = createBatchRecord(successCount,totalCount-successCount,totalCount,originalObjectName,recordId,quoteNumber);
        csvDataMapList = sendCSVEmail(lstCSVLines,rowErrorMap,columnHeaderNamesList,objectName,bulkUploadRecord,recordId,invalidRowSet,lastRowToBeProcessed,originalObjectName);
        return new outputWrapper(''+successCount+'/'+totalCount+ ' Records uploaded Successfully',columnsWrapperList,csvDataMapList,true,null);
    }
    
    /************************************************************************************************************
	*Method Name : getFieldType
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Returns field datatype.
	************************************************************************************************************/
    /*public static String getFieldType(String objectName,String fieldName){
        SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        return d.fields.getMap().get(fieldName).getDescribe().getType().name();
    }
    
    /************************************************************************************************************
	*Method Name : getFieldReferenceFieldObjectName
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Returns sObject name.
	************************************************************************************************************/
    /*public static String getFieldReferenceFieldObjectName(String objectName,String fieldName){
        String referenceObjectName = '';
        SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        for(Schema.SObjectType reference : d.fields.getMap().get(fieldName).getDescribe().getReferenceTo()){
            referenceObjectName = reference.getDescribe().getName();
        }
        return referenceObjectName;
    }
    
    /************************************************************************************************************
	*Method Name : getNewSobject
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Returns sObject instance.
	************************************************************************************************************/
    public static SObject getNewSobject(String objectName){
        Map<String,Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectType = objectMap.get(objectName);
        Sobject dynamicObject = objectType.newSobject();
        return dynamicObject;
    }
    
    /************************************************************************************************************
	*Method Name : sendCSVEmail
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Returns records result in csv format.
	************************************************************************************************************/
    /*public static List<Map<String,String>> sendCSVEmail(List<String> lstCSVLines,Map<Integer,String> rowErrorMap,List<String> columnHeaderNamesList, 
                                                        String objectName,core_cpq_bulk_upload_batch__c bulkUploadRecord,Id recordId,
                                                        Set<Integer> invalidRowSet,Integer lastRowToBeProcessed,String originalObjectName){
        string mainContent = ''; 
        columnHeaderNamesList.add('Result');  
        columnHeaderNamesList.add('Reason');      
        List<Map<String,String>> csvDataMapList = new List<Map<String,String>>();
        for(Integer i = 0; i < lstCSVLines.size(); i++){
            String csvLine = lstCSVLines[i];

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
                    if(!rowErrorMap.containsKey(i)){
                        if(invalidRowSet.contains(i)){
                            columnList.add('Insufficient Data');
                            dataMap.put(columnHeaderNamesList[k],'Insufficient Data');                     
                        }else{
                            columnList.add('Success');
                            dataMap.put(columnHeaderNamesList[k],'Success');                    
                        }
                    }else{
                        columnList.add('Failure');
                        dataMap.put(columnHeaderNamesList[k],'Failure');
                    }
                }
                if(!rowErrorMap.containsKey(i)){
                    dataMap.put(columnHeaderNamesList[k+1],'');
                }else{
                    columnList.add(rowErrorMap.get(i).replaceAll(',',' '));
                    dataMap.put(columnHeaderNamesList[k+1],rowErrorMap.get(i).replaceAll(',',' '));
                }
            }
            if(!dataMap.isEmpty()){
                csvDataMapList.add(dataMap);
            }
            mainContent = mainContent + String.join(columnList,',')+'\n';
        }
                                                            
        String emailTemplateName = Label.PSG_Bulk_Upload_Template;
        OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address='wsm-postmaster@intel.com'];
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        if(String.isNotBlank(emailTemplateName)){
            emailTemplateList = new List<EmailTemplate>([SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: emailTemplateName LIMIT 1]);
        }
        Messaging.EmailFileAttachment csvAttcmnt = new Messaging.EmailFileAttachment ();
        blob csvBlob = Blob.valueOf (mainContent);
        string csvname = originalObjectName + '_BULKUPLOAD.csv';
        csvAttcmnt.setFileName (csvname);
        csvAttcmnt.setBody (csvBlob);
        Messaging.SingleEmailMessage singEmail = new Messaging.SingleEmailMessage();
        String [] toAddresses = new list<string> {userInfo.getUserEmail()};
            singEmail.setToAddresses (toAddresses);
        String subject = 'BulkUpload Results CSV';
        singEmail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
        singEmail.setUseSignature(false); 
        singEmail.setBccSender(false);  
        singEmail.setSaveAsActivity(false);
        if(!emailTemplateList.isEmpty()){
            singEmail.setTemplateID(emailTemplateList[0].Id); 
            singEmail.setTargetObjectId(userInfo.getUserId());
            singEmail.setWhatId(bulkUploadRecord.Id);
        }else{
            singEmail.setSubject (subject);
            singEmail.setPlainTextBody ('BulkUpload Results CSV');
        }
        singEmail.setFileAttachments (new Messaging.EmailFileAttachment []{csvAttcmnt});
        Messaging.sendEmail (new Messaging.SingleEmailMessage [] {singEmail});
        return csvDataMapList;
    }
    
    /************************************************************************************************************
	*Method Name : createBatchRecord
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Inserts core_cpq_bulk_upload_batch__c record.
	************************************************************************************************************/
    /*public static core_cpq_bulk_upload_batch__c createBatchRecord(Integer sucessCount,Integer failureCount,Integer totalCount,String objectName,Id quoteId,String quoteNumber){
        core_cpq_bulk_upload_batch__c batchRec = new core_cpq_bulk_upload_batch__c(core_cpq_total_rows_Nbr__c = totalCount,
                                                                                   core_cpq_failure_count_nbr__c = failureCount,
                                                                                   core_cpq_success_count_nbr__c = sucessCount,
                                                                                   core_cpq_object_name_nm__c = objectName,
                                                                                   core_cpq_quoteId_Id__c = quoteId
                                                                                  );
        insert batchRec;
        return batchRec;                                                            
    
    }
    /************************************************************************************************************
	*Method Name : typeConversion
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Assign values to fields in salesforce object instance.
	************************************************************************************************************/
    /*public static void typeConversion(String type,sobject currentObjectRec,String fieldAPIName,String currentColumnData,Map<Integer,String> rowErrorMap,
                                      String currentColumnName,Set<String> mandatoryFieldsFilled,String objectNameStr,String objectAPIName,
                                      List<sobject> currentObjectRecList,Map<String,Map<String,Id>> referenceMap,Integer i,Set<String> mandatoryFieldsToBeFilled,
                                      Map<String,String> pbMap,List<String> columnHeaderNamesList,Integer k,List<Decimal> unitCostList,String objectName,
                                      Integer oneToNineColumnIndex,Integer oneToTwentyFourColumnIndex,List<String> csvRowData,Integer unitPriceColumnIndex){
        if(type == Schema.DisplayType.Integer.name()){
            currentObjectRec.put(fieldAPIName,Integer.valueOf(currentColumnData));
        }else if(type == Schema.DisplayType.Double.name() || type == Schema.DisplayType.Percent.name()){
            currentObjectRec.put(fieldAPIName,Double.valueOf(currentColumnData));
        }else if(type == Schema.DisplayType.Boolean.name()){
            if(currentColumnData == 'true' || currentColumnData == 'false'){
                currentObjectRec.put(fieldAPIName,Boolean.valueOf(currentColumnData));
            }else{
                if(rowErrorMap.containsKey(i)){
                    rowErrorMap.put(baseNumber+i,rowErrorMap.get(baseNumber+i)+'    >>>>    '+objectNameStr+' : '+'Invalid value for Boolean field - '+currentColumnName); 
                }else{
                    rowErrorMap.put(baseNumber+i,objectNameStr+' : '+'Invalid value for Boolean field - '+currentColumnName);   
                }
            }
        }else if(type == Schema.DisplayType.Date.name()){
            currentObjectRec.put(fieldAPIName,Date.parse(currentColumnData));
        }else if(type == Schema.DisplayType.DateTime.name()){
            currentObjectRec.put(fieldAPIName,DateTime.valueOf(currentColumnData));
        }else if(type == Schema.DisplayType.ID.name()){
            currentObjectRec.put(fieldAPIName,ID.valueOf(currentColumnData));
        }else if(type == Schema.DisplayType.Long.name()){
            currentObjectRec.put(fieldAPIName,Long.valueOf(currentColumnData)); 
        }else if(type == Schema.DisplayType.Reference.name()){
            
            String referenceObjectAPIName = getFieldReferenceFieldObjectName(objectAPIName,fieldAPIName);
            if(referenceMap.containsKey(referenceObjectAPIName) && String.isNotBlank(currentColumnData) 
               && referenceMap.get(referenceObjectAPIName).containsKey(currentColumnData)){
                   currentObjectRec.put(fieldAPIName,referenceMap.get(referenceObjectAPIName).get(currentColumnData)); 
               }else{
                   if(rowErrorMap.containsKey(i)){
                       rowErrorMap.put(baseNumber+i,rowErrorMap.get(baseNumber+i)+'    >>>>    '+objectNameStr+' : '+'Invalid value for Reference field - '+currentColumnName); 
                   }else{
                       if(currentColumnName == 'Product'){
                           rowErrorMap.put(baseNumber+i,objectNameStr+' : '+'Invalid value for Reference field - '+currentColumnName + '- Selected Product is Not a FPGA Product' );
                       }
                       else{
                           rowErrorMap.put(baseNumber+i,objectNameStr+' : '+'Invalid value for Reference field - '+currentColumnName);
                       }                  
                   }
               }
        }else if(type == Schema.DisplayType.String.name() || type == Schema.DisplayType.TextArea.name() || type == Schema.DisplayType.Picklist.name()){
            currentObjectRec.put(fieldAPIName,currentColumnData);
        }else if (type == Schema.DisplayType.Email.name() ) {
            currentObjectRec.put(fieldAPIName,currentColumnData);
        }else if(type == Schema.DisplayType.PHONE.name()){
            currentObjectRec.put(fieldAPIName,currentColumnData);
        }else if(type == Schema.DisplayType.TIME.name()){
            currentObjectRec.put(fieldAPIName,currentColumnData);
        }else if(type == Schema.DisplayType.URL.name()){
            currentObjectRec.put(fieldAPIName,currentColumnData);
        }else if(type == Schema.DisplayType.MULTIPICKLIST.name()){
            currentObjectRec.put(fieldAPIName,currentColumnData);
        }else if(type == Schema.DisplayType.Currency.name()){
            if(fieldAPIName != 'Custom'){
                if(objectAPIName == 'pricebookentry' && (currentColumnName == '(1-24)' || currentColumnName == '(1-9)') && 
                   pbMap.get((String)currentObjectRec.get('Pricebook2Id')) == 'OEM'){
                       currentObjectRec.put(fieldAPIName,Double.valueOf(currentColumnData));
                   }else if(objectAPIName == 'pricebookentry' && currentColumnName == 'Unit Cost'){
                       unitCostList.add(Double.valueOf(currentColumnData));
                       if((pbMap.get((String)currentObjectRec.get('Pricebook2Id')) != 'OEM' && objectName != 'Tools IP/Devkit Price Book') || objectName == 'Tools IP/Devkit Price Book'){
                           if(objectName == 'Tools IP/Devkit Price Book'){
                               if(pbMap.get((String)currentObjectRec.get('Pricebook2Id')) == 'OEM'){
                                   if(String.isNotBlank(csvRowData[unitPriceColumnIndex])){
                                       currentObjectRec.put(fieldAPIName,Double.valueOf(csvRowData[unitPriceColumnIndex]));
                                   }
                               }else{
                                   currentObjectRec.put(fieldAPIName,Double.valueOf(currentColumnData));
                               }
                           }else{
                               currentObjectRec.put(fieldAPIName,Double.valueOf(currentColumnData));
                           }
                       }else{          
                           if(oneToNineColumnIndex != null && String.isNotBlank(csvRowData[oneToNineColumnIndex])){
                               currentObjectRec.put(fieldAPIName,Double.valueOf(csvRowData[oneToNineColumnIndex]));
                           }else if(oneToTwentyFourColumnIndex != null && String.isNotBlank(csvRowData[oneToTwentyFourColumnIndex])){
                               currentObjectRec.put(fieldAPIName,Double.valueOf(csvRowData[oneToTwentyFourColumnIndex]));
                           }
                       }
                   }else if(currentObjectRec.get(fieldAPIName) == null){
                       currentObjectRec.put(fieldAPIName,Double.valueOf(currentColumnData));
                   }
            }else if(fieldAPIName == 'Custom'){
                String columnName = columnHeaderNamesList[k];
                columnName = columnName.removeStartIgnoreCase('(');
                columnName = columnName.removeEndIgnoreCase(')');
                if(!columnName.containsIgnoreCase('>') && columnName.containsIgnoreCase('-')){
                    List<String> rangeList = new List<String>(columnName.split('-'));
                    if(rangeList[0].endsWithIgnoreCase('k')){
                        currentObjectRec.put('core_cpq_lowerbound_qty__c',Double.valueOf(rangeList[0].removeEndIgnoreCase('k'))*1000);
                    }else{
                        currentObjectRec.put('core_cpq_lowerbound_qty__c',Double.valueOf(rangeList[0]));
                    }
                    if(rangeList[1].endsWithIgnoreCase('k')){
                        currentObjectRec.put('core_cpq_upperbound_qty__c',Double.valueOf(rangeList[1].removeEndIgnoreCase('k'))*1000);
                    }else{
                        currentObjectRec.put('core_cpq_upperbound_qty__c',Double.valueOf(rangeList[1]));
                    }
                }else if(columnName.containsIgnoreCase('>')){
                    columnName = columnName.remove('>');
                    currentObjectRec.put('core_cpq_lowerbound_qty__c',Double.valueOf(columnName));
                    currentObjectRec.put('core_cpq_upperbound_qty__c',null);
                }
                currentObjectRec.put('core_cpq_list_price_amt__c',Double.valueOf(currentColumnData));
                mandatoryFieldsFilled.add('core_cpq_list_price_amt__c');
                currentObjectRecList.add(currentObjectRec.clone(false, true, false, false));
            }
        }
        if(objectAPIName == 'core_cpq_list_price__c' && fieldAPIName == 'core_cpq_product_name__c'){
            currentObjectRec.put('core_cpq_product_opn_txt__c',currentColumnData); 
        }else if(objectAPIName == 'price_msvp__c' && fieldAPIName == 'core_cpq_product_nm__c'){
            currentObjectRec.put('core_cpq_product_opn__c',currentColumnData);
        }else if(objectAPIName == 'price_forward_cost__c' && fieldAPIName == 'core_cpq_product_nm__c'){
            currentObjectRec.put('core_cpq_product_opn_txt__c',currentColumnData);
        }  
    }
    
    /************************************************************************************************************
	*Method Name : dataAssignment
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Prepares unique field value based on object for upsert operation.
	************************************************************************************************************/
    /*public static void dataAssignment(List<sObject> currentObjectRecList,Set<String> mandatoryFieldsFilled,String objectAPIName,
                                      Id recordId,List<String> priceBookIdList,Map<String,List<String>> objectRowConsiderationMap,String objectName){
        for(sObject currentObjectRec : currentObjectRecList){
            if(objectAPIName == 'SBQQ__Quote__c'){
                currentObjectRec.put('recordtypeid' , PSG_Utility.getRecordTypeId('SBQQ__Quote__c', 'PSG_Quote_New'));
            }else if(objectAPIName == 'SBQQ__QuoteLine__c'){
                if(objectName=='Quote Line CP'){
                    currentObjectRec.put('recordtypeid' , PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'psg_cp_quote_line'));
                }else{
                    currentObjectRec.put('recordtypeid' , PSG_Utility.getRecordTypeId('SBQQ__QuoteLine__c', 'PSG_Quote_Line_Create'));
                }
                
                if(recordId != null){
                    currentObjectRec.put('SBQQ__Quote__c',recordId);
                    mandatoryFieldsFilled.add('SBQQ__Quote__c');
                }
                if(objectRowConsiderationMap.containsKey('SBQQ__QuoteLine__c')){
                    String uniqueValue = '';
                    for(String field : objectRowConsiderationMap.get('SBQQ__QuoteLine__c')){
                        Integer lB;
                        Integer uB;
                        if(field=='core_cpq_lower_bound_qty_qty__c'){
                            lB=Integer.valueOf(currentObjectRec.get(field));
                            if(lB != null){
                                currentObjectRec.put(field,lB);
                            }
                            uniqueValue = uniqueValue + lB;
                        }else if(field=='core_cpq_upper_bound_qty_nbr__c'){
                            uB=Integer.valueOf(currentObjectRec.get(field));
                            if(uB != null){
                                currentObjectRec.put(field,uB);
                            }
                            uniqueValue = uniqueValue + uB;
                        }else{
                            uniqueValue = uniqueValue + currentObjectRec.get(field);
                        }
                    }
                    currentObjectRec.put('core_cpq_unique_id__c',uniqueValue);
                }
            }else if(objectAPIName == 'PriceBookEntry'){
                currentObjectRec.put('Pricebook2Id',priceBookIdList[0]);
                currentObjectRec.put('UseStandardPrice',false);
                currentObjectRec.put('IsActive',true);
                mandatoryFieldsFilled.add('Pricebook2Id');
                mandatoryFieldsFilled.add('UseStandardPrice');
                mandatoryFieldsFilled.add('IsActive');
                mandatoryFieldsFilled.add('Name');
                if(objectRowConsiderationMap.containsKey('pricebookentry')){
                    String uniqueValue = '';
                    for(String field : objectRowConsiderationMap.get('pricebookentry')){
                        uniqueValue = uniqueValue + currentObjectRec.get(field);
                    }
                    currentObjectRec.put('core_cpq_unique_id__c',uniqueValue);
                }
                if(objectName == 'Price Book Entry -- Components Price Book'){
                    currentObjectRec.put('unitprice',0);
                }
            }else if(objectAPIName == 'price_forward_cost__c'){
                currentObjectRec.put('recordtypeid' , PSG_Utility.getRecordTypeId('price_forward_cost__c', 'PSG_Forward_Cost_Record_Type'));
                currentObjectRec.put('name',currentObjectRec.get('core_cpq_forward_cost_period_name_nm__c'));
                mandatoryFieldsFilled.add('Name');
                if(objectRowConsiderationMap.containsKey('price_forward_cost__c')){
                    String uniqueValue = '';
                    for(String field : objectRowConsiderationMap.get('price_forward_cost__c')){
                        uniqueValue = uniqueValue + currentObjectRec.get(field);
                    }
                    currentObjectRec.put('core_cpq_unique_id__c',uniqueValue);
                }
            }else if(objectAPIName == 'price_msvp__c'){
                currentObjectRec.put('recordtypeid' , PSG_Utility.getRecordTypeId('price_msvp__c', 'PSG_MSVP_Record_Type'));
                mandatoryFieldsFilled.add('Name');
                if(objectRowConsiderationMap.containsKey('price_msvp__c')){
                    String uniqueValue = '';
                    for(String field : objectRowConsiderationMap.get('price_msvp__c')){
                        uniqueValue = uniqueValue + currentObjectRec.get(field);
                    }
                    currentObjectRec.put('core_cpq_unique_id__c',uniqueValue);
                }
            }else if(objectAPIName == 'core_cpq_list_price__c'){
                currentObjectRec.put('recordtypeid' , PSG_Utility.getRecordTypeId('core_cpq_list_price__c', 'PSG_List_Price_Record_Type'));
                currentObjectRec.put('core_cpq_Price_Book__c',priceBookIdList[0]);
                mandatoryFieldsFilled.add('Name');
                if(objectRowConsiderationMap.containsKey('core_cpq_list_price__c')){
                    String uniqueValue = '';
                    for(String field : objectRowConsiderationMap.get('core_cpq_list_price__c')){
                        uniqueValue = uniqueValue + currentObjectRec.get(field);
                    }
                    currentObjectRec.put('core_cpq_unique_id__c',uniqueValue);
                }
            }else if(objectAPIName == 'core_cpq_distributor_margin__c'){
                currentObjectRec.put('recordtypeid' , PSG_Utility.getRecordTypeId('core_cpq_distributor_margin__c', 'PSG_Distributor_Margin_Record_Type'));
                mandatoryFieldsFilled.add('Name');
                if(objectRowConsiderationMap.containsKey('core_cpq_distributor_margin__c')){
                    String uniqueValue = '';
                    for(String field : objectRowConsiderationMap.get('core_cpq_distributor_margin__c')){
                        uniqueValue = uniqueValue + currentObjectRec.get(field);
                    }
                    currentObjectRec.put('core_cpq_unique_id__c',uniqueValue);
                }
            }else if(objectAPIName == 'core_cpq_product_details__c'){
                mandatoryFieldsFilled.add('Name');
                if(objectRowConsiderationMap.containsKey('core_cpq_product_details__c')){
                    String uniqueValue = '';
                    for(String field : objectRowConsiderationMap.get('core_cpq_product_details__c')){
                        uniqueValue = uniqueValue + currentObjectRec.get(field);
                    }
                    currentObjectRec.put('core_cpq_unique_id__c',uniqueValue);
                }
            }
        }
    }
    
    /************************************************************************************************************
	*Method Name : getQuoteType
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Returns the quote record.
	************************************************************************************************************/
    /*@AuraEnabled(cacheable=true)
    public static String getQuoteType(Id recordId) {
        return [SELECT Id,core_cpq_quote_type_nm__c from SBQQ__Quote__c where Id =: recordId].core_cpq_quote_type_nm__c;
    }
    
    /************************************************************************************************************
	*Method Name : getUploadData
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Returns PSG_Upload_File_Mapping__mdt metadata records.
	************************************************************************************************************/
    /*@AuraEnabled(cacheable=true)
    public static List<PSG_Upload_File_Mapping__mdt> getUploadData() {
        return [SELECT Id,PSG_Order_Nbr__c,PSG_Field_API_Name__c,PSG_Field_Name__c,PSG_Object_API_Name__c,PSG_Object_Name__c,
                PSG_Mapping_Type__c,PSG_Parent_Object__c,PSG_Child_Object__c ,PSG_Child_Relationship_Field_Name__c
                from PSG_Upload_File_Mapping__mdt where PSG_Template_Enabler__c = true order by PSG_Order_Nbr__c asc];
    }
    
    /************************************************************************************************************
	*Method Name : getBatchJobStatus
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Returns AsyncApexJob record.
	************************************************************************************************************/
    /*@AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id =:jobID];
        return jobInfo;
    }
    
    /************************************************************************************************************
	*Method Name : getQLData
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Returns quote lines related to the quote.
	************************************************************************************************************/
    /*@AuraEnabled(cacheable=true)
    public static List<SBQQ__QuoteLine__c> getQLData(Id quoteId){
        return [SELECT Id,core_cpq_product_nm__c,core_cpq_requested_qty__c,core_cpq_years_nbr__c,price_requested_resale_amt__c,core_cpq_production_dt__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:quoteId];
    }
    
    /************************************************************************************************************
	*Method Name : validatingAccess
	*Created Date: 08/13/2021
	*Author: Vijay
	*Description : Checking User available groups.
	************************************************************************************************************/
    /*@AuraEnabled
    public static List<String> validatingAccess(){
        List<String> groupNames = new List<String>();
        Set<Id> groupIds = new Set<Id>();
        for(GroupMember gId : [select UserOrGroupId,GroupId from GroupMember where UserOrGroupId =: UserInfo.getUserId()]){
            groupIds.add(gId.GroupId);
        }
        for(GroupMember gm : [SELECT group.name,group.DeveloperName from GroupMember 
                              WHERE (UserOrGroupId =: UserInfo.getUserId() OR UserOrGroupId =:groupIds) AND group.DeveloperName IN ('ags_internal_pms','ags_manage_msvp','ags_manage_disti_margin')]){
                                  groupNames.add(gm.group.DeveloperName);
                                  
                              }
        return groupNames;
    }
    
    
    public class relationShipWrapper{
        sobject parent;
        List<relationShipWrapper> childList;
        Integer rowNumber;
        String objectName;
        String objectAPIName;
        public relationShipWrapper(sobject parent,List<relationShipWrapper> childList,Integer rowNumber,String objectName,String objectAPIName){
            this.parent = parent;
            this.childList = childList;
            this.rowNumber = rowNumber;
            this.objectName = objectName;
            this.objectAPIName = objectAPIName;
        }
    }
    
    
    public class outputWrapper{
        String errorCount;
        List<columnsWrapper> columns;
        List<Map<String,String>> csvDataMapList;
        Boolean synchronousProcess;
        Id batchJobId;
        public outputWrapper(String errorCount,List<columnsWrapper> columns,List<Map<String,String>> csvDataMapList,Boolean synchronousProcess,Id batchJobId){
            this.errorCount = errorCount;    
            this.columns = columns;
            this.csvDataMapList = csvDataMapList;
            this.synchronousProcess = synchronousProcess;
            this.batchJobId = batchJobId;
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
    }*/
}