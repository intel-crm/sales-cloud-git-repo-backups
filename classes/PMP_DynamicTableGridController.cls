public with sharing class PMP_DynamicTableGridController {
            
    @AuraEnabled
    public static sObject getlookupValue(String objectApiName, String lookupRecordId)
    {
        string query = 'select  Name from '+objectApiName+' WHERE Id = \''+lookupRecordId + '\'';
        
        sObject records = Database.query(query); 
        return records;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Core_Object_Filter__mdt> getFilterValues(String objectApiName){
        
        List<Core_Object_Filter__mdt> metadataRecord = [Select Id, DeveloperName,MasterLabel, Default_Filter__c, Filter_Label__c,Filter_Value__c from Core_Object_Filter__mdt Where MasterLabel =:objectApiName];
        System.debug('Metadata records ::: '+ metadataRecord);
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
                        column.wrapText = true ;
                        //IPA2.0 Offering changes
                        /*if(fieldSetMem.getFieldPath().contains('Hyperlink') && objectApiName == 'PMP_Partner_Offering__c') {
                            column.fieldName = 'hyperlink';
                            column.fieldType='url';
                            final TypeAttributes tAtt = new TypeAttributes();
                            final Label lab = new Label();
                            lab.fieldName = 'Offering Name';
                            tAtt.label = lab;
                            tAtt.target = '_blank';
                            column.typeAttributes = tAtt;    
                        }*/
						//IPA2.0: US-TWC729-7976
                        /*if(fieldSetMem.getFieldPath().contains('Solution_Name_Id_Txt__c') && objectApiName == 'ArdiraSurvey__Survey_Result__c') {
                            column.fieldName = 'solnamehyperlink';
                            column.fieldType='url';
                            final TypeAttributes tAtt = new TypeAttributes();
                            final Label lab = new Label();
                            lab.fieldName = 'Solution Name';
                            tAtt.label = lab;
                            tAtt.target = '_blank';
                            column.typeAttributes = tAtt;    
                        }
                        if(fieldSetMem.getFieldPath().contains('View_Offering_Txt__c') && objectApiName == 'ArdiraSurvey__Survey_Result__c') {
                            column.fieldName = 'viewoffhyperlink';
                            column.fieldType='url';
                            final TypeAttributes tAtt = new TypeAttributes();
                            final Label lab = new Label();
                            lab.fieldName = 'View Offering';
                            tAtt.label = lab;
                            tAtt.target = '_blank';
                            column.typeAttributes = tAtt;    
                        }*/
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
                        //final String fieldapi = fieldSetMem.getFieldPath();
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
            //IPA2.0 Offering changes
            /*if(fs=='hyperlink') {
                fs= 'PMP_Offering_Nm_Hyperlink__c';
            }*/
			//IPA2.0: US-TWC729-7976
            /*if(fs == 'solnamehyperlink') {
                fs = 'PSS_Solution_Name_Id_Txt__c';
            }
            if(fs == 'viewoffhyperlink') {
                fs = 'PSS_View_Offering_Txt__c';
            }*/
           if(fs != 'nameURL' && fs!='hyperlink' && fs!='solnamehyperlink' && fs!='viewoffhyperlink') {
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
            System.debug('Query in Lookup ::: '+query);
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
            //IPA2.0 Offering changes
            /*if(fs=='hyperlink') {
                fs= 'PMP_Offering_Nm_Hyperlink__c';
            }*/
            //IPA2.0: US-TWC729-7976
            /*if(fs == 'solnamehyperlink') {
                fs = 'PSS_Solution_Name_Id_Txt__c';
            }
            if(fs == 'viewoffhyperlink') {
                fs = 'PSS_View_Offering_Txt__c';
            }*/
           if(fs != 'nameURL' && fs!='hyperlink' && fs!='solnamehyperlink' && fs!='viewoffhyperlink') {
            final SObjectType rec = ((SObject)Type.forName(objectApiName).newInstance()).getSObjectType();
            final DescribeSObjectResult dre = rec.getDescribe();
            System.debug('fields '+dre.fields.getMap().get(fs).getDescribe().getType());
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
        System.debug('Cols in Search records Method ::: '+cols);
        System.debug('soqlcols in Search records Method ::: '+soqlwherequery);
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
            System.debug('the final soql query will be '+soqlsearchRecords);
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
            if(fs=='hyperlink') {
                fs= 'PMP_Offering_Nm_Hyperlink__c';
            }
            //IPA2.0: US-TWC729-7976
            /*if(fs=='solnamehyperlink') {
                fs = 'PSS_Solution_Name_Id_Txt__c';
            }
            if(fs=='viewoffhyperlink') {
                fs = 'PSS_View_Offering_Txt__c';
            }*/
           if(fs != 'nameURL' && fs!='hyperlink' && fs!='solnamehyperlink' && fs!='viewoffhyperlink') {    
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
        System.debug('Records ::: '+records);
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
            if(fs=='hyperlink') {
                fs= 'PMP_Offering_Nm_Hyperlink__c';
            }
			//IPA2.0: US-TWC729-7976
            /*if(fs=='solnamehyperlink') {
                fs ='PSS_Solution_Name_Id_Txt__c';
            }
			//IPA2.0 Offering changes
            if(fs=='viewoffhyperlink') {
                fs = 'PSS_View_Offering_Txt__c';
            }*/
			//IPA2.0: US-TWC729-7976
           if(fs != 'nameURL' && fs!='hyperlink' && fs!='solnamehyperlink' && fs!='viewoffhyperlink') {     
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
        System.debug('Query :::: '+query);
      	return Database.query(query); 
        
    }

    @AuraEnabled(cacheable=true)
    public static String downloadcsv(List<String> fDetails,String objectApiName,String filterValue) {
        String cols = '';
        string recordString ='';
        System.debug('Fdetails ::::' + fDetails);
        
        for(String fs:fDetails){
            if(fs=='nameURL'){
                fs= 'id';
            }
            /*if(fs=='hyperlink') {
                fs= 'PMP_Offering_Nm_Hyperlink__c';
            }*/
			//IPA2.0: US-TWC729-7976
            /*if(fs=='solnamehyperlink') {
                fs ='PSS_Solution_Name_Id_Txt__c';
            }
			//IPA2.0 offering Changes
            if(fs =='viewoffhyperlink') {
                fs ='PSS_View_Offering_Txt__c';
            }*/
			//IPA2.0: US-TWC729-7976
           if(fs != 'nameURL' && fs!='hyperlink' && fs!='solnamehyperlink' && fs!='viewoffhyperlink') {    
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
        query = 'Select ' + cols + ' from '+ objectApiName +' '+ filterValue;      
        System.debug('Query ::: '+query);
        List<sObject> records= new List<sObject>();
        if(query != ''){
            records = Database.query(query);   
        }
        cols = cols+'\n';
        string finalstr = cols;
        //IPA2.0 Offering changes
        /*for(sObject li : records) {
            switch on li {
              when PMP_Partner_Offering__c cr {
                  PMP_Partner_Offering__c ps = (PMP_Partner_Offering__c)cr;  
                   recordString = ps.Name+','+ps.PMP_Partner_Offering_Lifecycle_Status_Nm__c+','+ps.PMP_Offering_Nm_Hyperlink__c.stripHtmlTags()+','+ps.PMP_Company_Id__c+','+ps.PMP_Intel_Admin_Id__c+','+ps.PMP_Category_nm__c+','+ps.PMP_Sub_Category_nm__c+','+ps.PMP_Is_Published_Ind__c+','+ps.LastModifiedDate+','+ps.LastModifiedById+','+ps.PMP_Business_Segment_Nm__c+','+ps.PMP_Offering_Messages_Link_Txt__c+','+ps.PMP_Translation_Lifecycle_Status_nm__c+','+ps.CreatedDate+','+ps.PMP_View_Offerings__c.stripHtmlTags()+'\n';
                   finalstr = finalstr +recordString;
                }
               //IPA2.0: US-TWC729-7976
               /*when ArdiraSurvey__Survey_Result__c asr {
                //ArdiraSurvey__Survey_Result__c asr = (ArdiraSurvey__Survey_Result__c)carw;
                System.debug('the survey result is'+asr);
                   String intadmin = asr.PSS_Intel_Admin_Id__c!=null ? asr.PSS_Intel_Admin_Id__c : null;
                   String solappl = asr.PSS_Programs_Applicable_Nm__c!=null ? asr.PSS_Programs_Applicable_Nm__c.normalizeSpace().replace(',','-'):'';
                   String voffring = asr.PSS_View_Offering_Txt__c!=null ? asr.PSS_View_Offering_Txt__c.stripHtmlTags():'';
                   recordString = asr.PSS_Solution_Name_Id_Txt__c.stripHtmlTags()+','+asr.PSS_Partner_Solution_Lifecycle_Status_Nm__c+','+asr.PSS_Partner_Name__c+','+asr.PSS_English_Partner_Name__c+','+intadmin+','+voffring+','+solappl+','+asr.LastModifiedDate+','+asr.LastModifiedById+','+asr.PSS_Survey_Messages_Txt__c+','+asr.CreatedById+','+asr.CreatedDate+'\n';
                   System.debug('the string is '+recordString);
                   finalstr = finalstr +recordString;
               //}
              }
            }*/
       return finalstr;
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
    
    public class Lookup{
        @AuraEnabled public String fieldName{get;set;}
    }
    
    public class RowId{
        @AuraEnabled public String fieldName{get;set;}
    }
    public class Option{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String defaultfilter {get;set;}
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