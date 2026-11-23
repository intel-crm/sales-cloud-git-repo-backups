public with sharing class AdvancedSearchController {
    
    @AuraEnabled (cacheable=true)
    public static String getObjectName(String objectApiName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectApiName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        String objNm = DescribeSObjectResultObj.getLabel();
        return objNm;
    }
    
    @AuraEnabled (cacheable=true)
    public static String getFieldsAndRecords(String strObjectApiName, String strfieldSetName,
                                             String criteriaField, String criteriaFieldValue, String keyword){
        Map<String, String> returnMap = new Map<String,String>();
        if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName)){
            //get fields from FieldSet
            SObject sObj = (SObject)(Type.forName('Schema.'+ strObjectApiName).newInstance());
            List<Schema.FieldSetMember> lstFSMember = sObj.getSObjectType().getDescribe().fieldSets.getMap().get(strfieldSetName).getFields();
            List<FieldSetWrapper> fieldList = new List<FieldSetWrapper>();
            List<Schema.FieldSetMember> fieldsLst = new List<Schema.FieldSetMember>();
            Map<String,Schema.SObjectField> fieldsMap = sObj.getSObjectType().getDescribe().fields.getMap();
            
             for(Schema.FieldSetMember fsMemberObj : lstFSMember)
        	{  
                FieldSetWrapper fs = new FieldSetWrapper();
                fs.fieldName = (String)fsMemberObj.getFieldPath();
                fs.dataType = String.valueOf(fsMemberObj.getType()).toLowerCase();
                fs.label = String.valueOf(fsMemberObj.getLabel());
                
                if (fs.dataType == 'reference') {
                fs.dataType = 'lookupColumn';
                fs.lookupNameRef = String.valueOf(fsMemberObj.getLabel()).replace(' ','_');
                fs.fieldName = fs.fieldName.contains('__c') ? fs.fieldName.replace('__c','__r')+'.Name':fs.fieldName.replace('Id','')+'.Name';
                fs.refObjName = fieldsMap.get(fsMemberObj.getFieldPath()).getDescribe().getReferenceTo()[0].getDescribe().getName();
            }
			 fieldList.add(fs);
         		/*if (fsObj.type.equals('reference') && fsObj.fieldPath.contains('__c')) {
                    fsObj.fieldPath = fsObj.fieldPath.replace('__c','__r')+'.Name';
                 //   fsObj.fieldPath = fsObj.fieldPath.contains('__c') ? fsObj.fieldPath.replace('__c','__r')+'.Name':fsObj.fieldPath.replace('Id','')+'.Name';
                }
                else if(fsObj.type.equals('reference') && !fsObj.fieldPath.contains('__c')) {
                	fsObj.fieldPath = fsObj.fieldPath.replace('Id','')+'.Name';
                }
                fieldsLst.add(fsObj); */
        	}

	    //prepare SOQL query based on fieldAPIs	
	    String query = 'SELECT ';
	    for(Schema.FieldSetMember f : lstFSMember) {
	        query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM ' + strObjectApiName ;

            //Just in case criteria field not specified then it will return all records
            if(!(String.isEmpty(criteriaField) && String.isEmpty(criteriaFieldValue))){
                query += ' WHERE ' + criteriaField + '=\'' + criteriaFieldValue + '\'';
            }
             system.debug('@@query=='+query);           
	    //execute query
             List<SObject> lstRecords =Database.query(query);
            
             //prepare a map which will hold fieldList and recordList and return it
             //
          String strQuery = 'FIND '+'\''+keyword+'\''+' IN ALL FIELDS RETURNING '+strObjectApiName+' (';
          Integer counter = 0;
          /*for(Schema.FieldSetMember f : lstFSMember) {
              if(counter == lstFSMember.size()-1){
                  strQuery += f.getFieldPath();
              }else{
                	strQuery += f.getFieldPath() + ', '; 
                  	counter++;
              }
	        	
            }*/
            for(FieldSetWrapper f : fieldList) {
              if(counter == fieldList.size()-1){
                  strQuery += f.fieldName;
              }else{
                	strQuery += f.fieldName + ', '; 
                  	counter++;
              }
	        	
            }
           if(!(String.isEmpty(criteriaField) && String.isEmpty(criteriaFieldValue))){
                strQuery += ' WHERE ' + criteriaField + '=\'' + criteriaFieldValue + '\'';
            }
            
           strQuery += ')'; 
            system.debug('@@strQuery=='+strQuery);
            List<List<SObject>> searchResults = search.query(strQuery);
            system.debug('##searchResults=='+searchResults);
            system.debug('##fieldList=='+fieldList);
            system.debug('##lstFSMember=='+lstFSMember);
			/*Conversion of List<List<SObject>> to List<SObject> to render in the JSON format */
            List<SObject> lstSearch = new List<SObject>();
            for(List<SObject> s : searchResults){
              lstSearch.addAll(s);
            }
            
	     returnMap.put('FIELD_LIST', JSON.serialize(fieldList));
	     returnMap.put('RECORD_LIST', JSON.serialize(lstRecords));
         returnMap.put('SEARCH_LIST', JSON.serialize(lstSearch));
	     return JSON.serialize(returnMap);
         /*returnMap.put('FIELD_LIST', lstFSMember);
	     returnMap.put('RECORD_LIST', lstRecords);
         returnMap.put('SEARCH_LIST', searchResults);
	     return returnMap;*/
        }
        return null;
    }
    
    public class FieldSetWrapper {
        @AuraEnabled
        public string fieldName;
		@AuraEnabled
        public string dataType;
		@AuraEnabled
        public string label;
		@AuraEnabled
        public string lookupNameRef;
		@AuraEnabled
        public string refObjName;
    }


}