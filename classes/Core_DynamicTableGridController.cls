public with sharing class Core_DynamicTableGridController {
            
    @AuraEnabled
    public static sObject getlookupValue(String objectApiName, String lookupRecordId)
    {
        string query = 'select  Name from '+objectApiName+' WHERE Id = \''+lookupRecordId + '\'';
        
        sObject records = Database.query(query); 
        return records;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Core_Object_Filter__mdt> getFilterValues(String objectApiName){
        Boolean isPartnerUser = false;
        List<Core_Object_Filter__mdt> metadataRecord = new List<Core_Object_Filter__mdt>();
        final User userRecord = Core_UtilityController.fetchUser();
        if(userRecord != null && userRecord.ContactId != null) {
            isPartnerUser = true;
        }
        if(isPartnerUser == false) {
                metadataRecord = [Select Id, DeveloperName,MasterLabel,Enabled_for_Partners__c,Default_for_Partner__c, Default_Filter__c, Filter_Label__c,Filter_Value__c from Core_Object_Filter__mdt Where MasterLabel =:objectApiName];
        }
        else {
            metadataRecord = [Select Id, DeveloperName,MasterLabel,Enabled_for_Partners__c,Default_for_Partner__c, Default_Filter__c, Filter_Label__c,Filter_Value__c from Core_Object_Filter__mdt Where MasterLabel =:objectApiName AND Enabled_for_Partners__c=true];
        }
        return metadataRecord;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<columnWrapper> getColumns(String objectApiName, String fieldSetName, Boolean EnableInlineEdit) {
        final List<columnWrapper> columnList = new List<columnWrapper>();
        
        List<Schema.FieldSetMember> fieldSetMember = new List<Schema.FieldSetMember>();        
        fieldSetMember= ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
        System.debug('FieldSetMember ::: '+fieldSetMember);
        for(Schema.FieldSetMember fieldSetMem : fieldSetMember) {
            
            if( fieldSetMem.getFieldPath().toUpperCase()!='NAME') {
                final columnWrapper column = new columnWrapper();
                column.editable=true;
                if(fieldSetMem.getFieldPath().toUpperCase()=='ID') {
                    column.fieldType='String';
                    column.sortable=true;   
                    column.editable=false;
                    final TypeAttributes tAtt = new TypeAttributes();
                    tAtt.target = '_blank';
                    column.fieldName = 'nameURL';
                    final Label lab = new Label();
                    lab.fieldName = 'Name';
                    tAtt.label = lab;
                    column.typeAttributes = tAtt;
                    column.fieldType= 'url';
                    column.label = fieldSetMem.getFieldPath();
                    column.wrapText = true ;
                }
                if(fieldSetMem.getFieldPath().toUpperCase()!='ID') {
                    column.label = fieldSetMem.getLabel();
                    column.fieldName = fieldSetMem.getFieldPath();
                    if( fieldSetMem.getType() ==  Schema.DisplayType.String || fieldSetMem.getType() ==  Schema.DisplayType.ID ) {                       
                        column.sortable=true;                        
                        column.wrapText = true;
                        Map<String, Schema.SObjectType> globalMap = Schema.getGlobalDescribe();  
                        for ( String key: globalMap.keySet() ) {  
                            if(key == objectApiName.toLowerCase()) {
                                Map<String, Schema.SObjectField> fieldsMap = globalMap.get( key ).getDescribe().fields.getMap();  
                                for ( String fieldKey: fieldsMap.keySet() ) {
                                    if(fieldkey == fieldSetMem.getFieldPath().toLowerCase()) {
                                        DescribeFieldResult dfr = fieldsMap.get( fieldKey ).getDescribe();
                                        if ( dfr.isCalculated() ) {  
                                            String frml = dfr.getCalculatedFormula();
                                            if(frml.contains('HYPERLINK')) {
                                                column.fieldType='url';
                                                final TypeAttributes tAtt = new TypeAttributes();
                                                final Label lab = new Label();
                                                lab.fieldName = dfr.getLabel();
                                                tAtt.label = lab;
                                                tAtt.target = '_blank';
                                                column.typeAttributes = tAtt;     
                                            }  
                                        } 
                                    }
                                }
                            }                         
                          }
                    }
                    else if(  fieldSetMem.getType() ==  Schema.DisplayType.URL) {
                        column.fieldType='String';
                        column.sortable=true;
                        final TypeAttributes tAtt = new TypeAttributes();
                        tAtt.target = '_blank';
                        column.typeAttributes = tAtt;   
                        column.wrapText = true ;
                    }
                    else if( fieldSetMem.getType() == Schema.DisplayType.DATETIME || fieldSetMem.getType() == Schema.DisplayType.DATE) {
                        column.fieldType='date';
                        column.sortable=true;
                        final TypeAttributes tAtt = new TypeAttributes();
                        tAtt.day = 'numeric';
                        tAtt.month = 'short';
                        tAtt.year = 'numeric';
                        tAtt.hour = '2-digit';                                                             
                        tAtt.minute = '2-digit';                                                           
                        tAtt.second = '2-digit';  
                        tAtt.hour12= true;
                        column.typeAttributes = tAtt;    
                        column.wrapText = true ;
                    }
                    else if(fieldSetMem.getType()==Schema.DisplayType.Picklist) {
                        column.fieldType='picklist';
                        column.sortable=true;
                        column.wrapText = true ;
                        final TypeAttributes tAtt = new TypeAttributes();
                        tAtt.placeholder='Choose';
                        final Value value = new Value();
                        value.fieldName = fieldSetMem.getFieldPath();
                        tAtt.value = value;
                        tAtt.fieldApiName=fieldSetMem.getFieldPath();
                        tAtt.objectApiName = objectApiName;
                        tAtt.EnableInlineEdit = EnableInlineEdit;
                        final Context context = new Context();
                        context.fieldName = 'Id';
                        tAtt.context = context;
                        
                        tAtt.options =  getPicklistOptions(objectApiName,fieldSetMem.getFieldPath());
                        column.typeAttributes = tAtt;
                    }
                    else if(fieldSetMem.getType()==Schema.DisplayType.REFERENCE) {
                        column.fieldType= 'lookup';
                        column.sortable=true;
                        column.wrapText = true ;
                        final TypeAttributes tAtt = new TypeAttributes();
                        final lookup lookup = new lookup();
                        lookup.fieldName = fieldSetMem.getFieldPath();
                        tAtt.lookup = lookup; 
                        final String fieldapi = fieldSetMem.getFieldPath();
                        tAtt.fieldApiName=fieldSetMem.getFieldPath();
                        tAtt.objectApiName = objectApiName;
                        tAtt.EnableInlineEdit = EnableInlineEdit;
                        final RowId rowId = new RowId();
                        rowId.fieldName = 'Id';
                        tAtt.rowId = rowId; 
                        final Value value = new Value();
                        value.fieldName = fieldSetMem.getFieldPath();
                        tAtt.value = value;
                        final ValueName valueName = new ValueName();
                        valueName.fieldName = String.valueOf(fieldSetMem.getFieldPath()).replace('__c','__r.Name') ;
                        //valueName.fieldName = fieldSetMem.getFieldPath() + '.Name';
                        tAtt.valueName = valueName;
                        
                        column.typeAttributes = tAtt;
                        
                    }
                    else {
                        column.sortable=true;
                        
                        column.wrapText = true ;
                    }
                }
                columnList.add(column);
            }
            else {
                final columnWrapper column = new columnWrapper();
                column.editable=false;
                column.wrapText = true ;
                column.label = fieldSetMem.getLabel();
                column.fieldName = fieldSetMem.getFieldPath();
                column.fieldType='String';
                column.sortable=true;
                columnList.add(column);
                
            }
        }        
        return columnList;
    }
  
    // method will return option values in List<>
    public static List<Option> getPicklistOptions(String objectName,String fieldAPIName) {        
        final List<Option> options = new List<Option>();
        final Schema.SObjectType objectType= Schema.getGlobalDescribe().get(objectName) ;
        final Schema.DescribeSObjectResult objectResult = objectType.getDescribe() ;
        final Map<String,Schema.SObjectField> fields = objectResult.fields.getMap() ;
        final Schema.DescribeFieldResult fieldResult = fields.get(fieldAPIName).getDescribe();
        final List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple) {
            
            final Option opt = new Option();
            opt.label=pickListVal.getLabel();
            opt.value=pickListVal.getValue();
            
            options.add(opt);
        } 
        return options;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> fetchRecordswithlookup(List<String> fDetails,String objectApiName,Integer pageSize, Integer pageNumber){
        final Integer ps = Integer.valueOf(pageSize);
        final Integer pn = Integer.valueOf(pageNumber)-1;
        
        String cols = '';
        
        
        for(String fs:fDetails) {
            if(fs=='nameURL') {
                fs= 'id';
            }
           if(fs != 'nameURL') {
                if(cols == '') {
                    cols = fs;
                }
                else {
                    cols = cols + ',' + fs;
                } 
           }
        }
        System.debug('Cols in lookup Method ::: '+cols);
        List<sObject> records= new List<sObject>();
        if(cols != ''){
            string query = 'select '+cols+' FROM '+objectApiName+' LIMIT '+Integer.valueOf(ps)+' OFFSET '+(ps*pn);
        	records = Database.query(query); 
        }        
        return records;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getSearchedRecords(List<String> fDetails,String objectApiName, Integer pageSizeNumber, Integer pageNumberValue, String filterValue,String key){
        
        System.debug('Inside Method');
        Integer ps = Integer.valueOf(pageSizeNumber);
        Integer pn = Integer.valueOf(pageNumberValue)-1;
        Integer offsetValue = ps*pn;
        String cols = '';
        String fs1 = '';
        String soqlwherequery = '';
        System.debug('Fdetails ::::' + fDetails);
        
        for(String fs:fDetails) {
            if(fs=='nameURL') {
                fs= 'id';
            }
           if(fs != 'nameURL') {
            final SObjectType rec = ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType();
            final DescribeSObjectResult dre = rec.getDescribe();
            if(dre.fields.getMap().get(fs).getDescribe().getType() == Schema.DisplayType.REFERENCE) {
                if(fs.contains('__c')) {
                    fs1 = fs.replace('__c','__r.Name');          
                }
                else {
                    fs1 = fs.substring(0,fs.length()-2)+'.Name'; 
                }
                if(soqlwherequery == '') {
                    soqlwherequery = 'Where '+fs1+' LIKE \'%'+key+'%\'';            
                } 
                else {  
                    soqlwherequery = soqlwherequery + ' OR ' + fs1+' LIKE \'%'+key+'%\'';
                } 
              }
                if(cols == '') {
                    cols = fs;                    
                } 
                else {                    
                    cols = cols + ',' + fs; 
                } 
           }
        }
        cols = cols.removeEnd(',');
        soqlwherequery = soqlwherequery.removeEnd(',');
        String keyString = '*' + key + '*';
        String returningQuery = objectApiName+' ( '+cols;
        String searchRecords = '';
        String soqlsearchRecords = '';
        String query = '';
        List<List<sObject>> sobjectList = new List<List<sObject>>();
        List<sObject> soqlsobjectList = new List<sObject>();
        List<sObject> finalsoqlres = new List<sObject>();
        try {
            if(filterValue != 'All') {
            	searchRecords = 'Find :keyString IN ALL FIELDS RETURNING '+ returningQuery+' '+filterValue+' LIMIT ' +ps+' OFFSET '+offsetValue+')';
                soqlsearchRecords = 'Select Id,'+cols+' From '+objectApiName+' '+filterValue+' AND '+'( '+soqlwherequery.substring(6)+' )'+' LIMIT '+Integer.valueOf(ps)+' OFFSET '+Integer.valueOf(ps*pn);
        	}
        	else {
				searchRecords = 'Find :keyString IN ALL FIELDS RETURNING '+ returningQuery+' LIMIT ' +ps+' OFFSET '+offsetValue+')';
                soqlsearchRecords = 'Select Id,'+cols+' From '+objectApiName+' '+soqlwherequery+' LIMIT '+Integer.valueOf(ps)+' OFFSET '+Integer.valueOf(ps*pn);
        	}
            sobjectList = search.query(searchRecords);
            soqlsobjectList = Database.query(soqlsearchRecords);
            if(sobjectList[0].size() > 0) {
                finalsoqlres.addAll(sobjectList[0]);
            }
            if (soqlsobjectList.size() > 0) {
                finalsoqlres.addAll(soqlsobjectList);
            } 
        }
        catch(SearchException e) {
           searchRecords = '';
           if(filterValue == 'All') {
            	query = 'Select ' + cols + ' from ' + objectApiName +' LIMIT '+Integer.valueOf(ps)+' OFFSET '+Integer.valueOf(ps*pn);
        	}
        	else {
            	query = 'Select ' + cols + ' from '+ objectApiName +' '+filterValue+' LIMIT '+Integer.valueOf(ps)+' OFFSET '+Integer.valueOf(ps*pn);
        	}
        }
        if(searchRecords == '') {
            finalsoqlres = Database.query(query);
        }        
        return (List<sObject>)finalsoqlres;
    }
  
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> fetchRecords(List<String> fDetails,String objectApiName, Integer pageSizeNumber, Integer pageNumberValue, String filterValue){
        Integer ps = Integer.valueOf(pageSizeNumber);
        Integer pn = Integer.valueOf(pageNumberValue)-1;
        
        String cols = '';
        System.debug('Fdetails ::::' + fDetails);
        
        for(String fs:fDetails){
            if(fs=='nameURL'){
                fs= 'id';
            }
           if(fs != 'nameURL') {    
                if(cols == ''){
                    cols = fs;
                }
                else{
                    
                    cols = cols + ',' + fs;
                } 
           }
        }
        cols = cols.removeEnd(',');
        String query = '';
        query = 'Select ' + cols + ' from '+ objectApiName +' '+ filterValue +' LIMIT '+Integer.valueOf(ps)+' OFFSET '+Integer.valueOf(ps*pn);      
        System.debug('Query ::: '+query);
        List<sObject> records= new List<sObject>();
        if(query != ''){
            records = Database.query(query);   
        }
        return records;
        
    }
   
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRowCount(String objectApiName, String filterValue)  {
        
        string query;
        if(filterValue == 'All'){
            query  = 'select  count(id)  from '+objectApiName;
        }
        else{
            query = 'select  count(id)  from '+objectApiName +' '+filterValue;
        }
         return Database.query(query);     
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getSearchRecords(List<String> fDetails, String objectApiName, String filterValue )  {
        
        string query = '';
        String cols = '';
        System.debug('Fdetails ::::' + fDetails);
        
        for(String fs:fDetails){
            if(fs=='nameURL') {
                fs= 'id';
            }
           if(fs != 'nameURL') {     
                if(cols == ''){
                    cols = fs;
                }
                else{     
                    cols = cols + ',' + fs;
                } 
           }
        }
        cols = cols.removeEnd(',');
        if(filterValue == 'All'){
            query  = 'select '+ cols +  ' from '+objectApiName;
        }
        else{
            query = 'select '+ cols +  ' from '+objectApiName +' '+filterValue;
        }
      	return Database.query(query); 
        
    }

    @AuraEnabled(cacheable=true)
    public static String downloadcsv(String fieldSetName,String objectApiName,String filterValue) {
        String cols = '';
        String labels = '';
        List<Schema.FieldSetMember> fieldSetMember = new List<Schema.FieldSetMember>();        
        fieldSetMember= ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
        for(Schema.FieldSetMember fieldSetMem : fieldSetMember) {
            if(labels == '') {
                labels = fieldSetMem.getLabel();
            }
             else {
                 labels = labels+','+fieldSetMem.getLabel();
             }
           if(cols=='') {
            final SObjectType rec = ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType();
            final DescribeSObjectResult dre = rec.getDescribe();
            if(dre.fields.getMap().get(fieldSetMem.getFieldPath()).getDescribe().getType() == Schema.DisplayType.REFERENCE) {
                if(fieldSetMem.getFieldPath().contains('__c')) {
                    cols = fieldSetMem.getFieldPath().replace('__c','__r.Name');          
                }
                else {
                    cols = fieldSetMem.getFieldPath().substring(0,fieldSetMem.getFieldPath().length()-2)+'.Name'; 
                }
            } 
            else {
                cols = fieldSetMem.getFieldPath();
            } 
           } 
           else {
            final SObjectType rec = ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType();
            final DescribeSObjectResult dre = rec.getDescribe();
            if(dre.fields.getMap().get(fieldSetMem.getFieldPath()).getDescribe().getType() == Schema.DisplayType.REFERENCE) {
                if(fieldSetMem.getFieldPath().contains('__c')) {
                    cols = cols+','+fieldSetMem.getFieldPath().replace('__c','__r.Name');          
                }
                else {
                    cols = cols+','+fieldSetMem.getFieldPath().substring(0,fieldSetMem.getFieldPath().length()-2)+'.Name'; 
                }
            }
            else {
                cols = cols+','+fieldSetMem.getFieldPath();
            }
           }
        }
        cols = cols.removeEnd(',');
        labels = labels.removeEnd(',');
        String query = '';
        query = 'Select ' + cols + ' from '+ objectApiName +' '+ filterValue;
        List<sObject> records= new List<sObject>();
        if(query != '') {
            records = Database.query(query);
        }
        final List<Map<String, Object>> csvValues = new List<Map<String, Object>>();
        final Set<String> fieldNames = new Set<String>();
        for(sObject li : records) {
            final Map<String,Object> fieldValues = li.getPopulatedFieldsAsMap();
            fieldValues.keySet().remove('Id');
            csvValues.add(fieldValues);
            fieldNames.addAll(fieldValues.keySet());
            System.debug('the key set inside is'+fieldValues.keySet());
        } 
        System.debug('the field names from here'+fieldNames);
        final String[] allData = new String[0];
        final String[] tempRow = new String[0];
        for(String fieldName: fieldNames) {
           tempRow.add(fieldName.escapeCSV());
         }
         allData.add(String.join(tempRow,','));
         for(Map<String, Object> valuesFromRecord: csvValues) {
         tempRow.clear();
         for(String fieldName: fieldNames) {
         Object value = valuesFromRecord.get(fieldName);
         System.debug('the value you are looking for '+value);
         if(value == null) {
            value = '';
           }
         else if(value.toString().contains('</a>') || value.toString().contains('</img>')) {
             value = value.toString().stripHtmlTags();
         }
          else if(value.toString().contains('{') && value.toString().contains('}')) {
             value = value.toString().substring(value.toString().indexOf('=')+1,value.toString().indexOf(',')-1);
         }
         tempRow.add((''+value).escapeCSV());
           }
         allData.add(String.join(tempRow,','));
         }
          final String finalCsv = String.join(allData,'\n');
          allData.clear();
         return finalCsv;
    }
    
    public class ColumnWrapper{
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String fieldType {get;set;}
        @AuraEnabled public Boolean sortable {get;set;}
        @AuraEnabled public Boolean editable {get;set;}
        @AuraEnabled public Boolean wrapText {get;set;}     
        @AuraEnabled public TypeAttributes typeAttributes{get;set;}
    }
    
    public class TypeAttributes {
        @AuraEnabled public String day {get;set;}
        @AuraEnabled public String month {get;set;}
        @AuraEnabled public String year {get;set;}
        @AuraEnabled public String hour {get;set;}
        @AuraEnabled public String minute {get;set;} 
        @AuraEnabled public String second {get;set;} 
        @AuraEnabled public Boolean hour12 {get;set;} 
        @AuraEnabled public String target {get;set;}
        @AuraEnabled public Label label {get;set;}
        @AuraEnabled public lookup lookup {get;set;}
        @AuraEnabled public Value value {get;set;}
        @AuraEnabled public ValueName valueName {get;set;}
        @AuraEnabled public Context context {get;set;}
        @AuraEnabled public RowId rowId {get;set;}
        @AuraEnabled public Boolean enableInlineEdit {get;set;}
        @AuraEnabled public String fieldApiName {get;set;}
        @AuraEnabled public String objectApiName {get;set;}
        @AuraEnabled public String placeholder {get;set;} 
        @AuraEnabled public List<Option> options {get;set;}
    }
    
    public class Label{
        @AuraEnabled public String fieldName{get;set;}
    }
    
    public class lookup{
        @AuraEnabled public String fieldName{get;set;}
    }
    
    public class RowId{
        @AuraEnabled public String fieldName{get;set;}
    }
    public class Option{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String defaultfilter {get;set;}
        @AuraEnabled public String defaultfilterPartner {get;set;}
    }
    public class Value{
        @AuraEnabled public String fieldName{get;set;}
    }
    
    public class ValueName{
        @AuraEnabled public String fieldName{get;set;}
    }
     public class Context{
        @AuraEnabled public String fieldName{get;set;}
    }

}