global with sharing class autoCompleteController {
     public string objectname{get;set;}
     public string additionalfield{get;set;}
     public string hiddenProdIdField{get;set;}
     public string prodName{get;set;}
     public string fieldSetName{get;set;}
     public string relatedId{get;set;}
     public autoCompleteController()
     {
      additionalfield ='';
      fieldSetName = '';
     }
    /*public String getColumnsName() {
       String ColumnList = '';
        integer counter = 0;
        //String type='objectname';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectname);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        ColumnList += '{"mDataProp": "ID","sTitle":"","defaultContent":"","render": function( oObj,row,set ) { return "<input type=\'radio\' name=\''+objectname+'_group\' value=\'" + set.Id + " \'/>";}},'; 
               ColumnList += '{"mDataProp": "Name","sTitle":"Name","defaultContent":""},';   
         if(additionalfield !=null && additionalfield.length() > 0)
         { 
               for(string f : additionalfield.split(',')) {
                
                      ColumnList += '{"mDataProp": "' + f + '","sTitle":"' + fieldMap.get(f).getDescribe().getLabel() + '","defaultContent":""},';
                    
                    counter++;
                }
                
                 ColumnList = ColumnList.substring(0,ColumnList.length()-1);
         }
        return ColumnList;
    }*/

    public String getAutocomplete_fieldset_feilds() {
        return null;
    }

    @RemoteAction
    global static SObject[] findSObjects(string obj, string qry, string fieldSetName, string relatedId) {
            // more than one field can be passed in the addFields parameter
            // split it into an array for later use
            List<String> fieldList;
            // check to see if the object passed is valid
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sot = gd.get(obj);
            if (sot == null) {
                // Object name not valid
                return null;
            }
            // create the filter text
            String filter = ' like \'%' + String.escapeSingleQuotes(qry) + '%\'';
            //begin building the dynamic soql query
            String soql = 'select Name';
            // if an additional field was passed in add it to the soql
            if (fieldSetName != null && fieldSetName != '') {
                /*for (String s : fieldList) {
                    soql += ', ' + s;
                }*/
                for(Schema.FieldSetMember f : Core_Utility.readFieldSet(fieldSetName,obj)) {                        
                    //ColumnList += '{"mDataProp": "' + f.getFieldPath() + '","sTitle":"' + f.getLabel() + '","defaultContent":""'+ (string.valueOf(f.getType()).contains('DATE') ? ',"Type":"date"':'') +'},';            
                    soql += ', ' + f.getFieldPath();
                }
            }
            // add the object and filter by name to the soql
            soql += ' from ' + obj + ' Where ' ;
            if(qry.length() > 0)
            {
             soql += '( name ' + filter  + ' OR Core_Code_Name__c ' + filter  + ' OR Core_Platform__c ' + filter + ' OR Core_Alias__c ' + filter + ' ) ';             
            }
            
            soql += (soql.contains('name')? 'AND':'' ) + ' status!=\'Inactive\''; 
            system.debug('relatedId ='  + relatedId);
            if(relatedId =='NoProj'){
                relatedId='';
            }
            if(!String.isBlank(relatedId) && relatedId!='NA' ){
                soql += ' and core_ips_project__c =: relatedId';
            }//else 
            if( relatedId=='' ){ // Seperating Logic For Select One And Not Applicable on project Selection. Project Change Bug BY Prem.
                soql += ' and core_ips_project__c=null';
            }
            
            // add the filter by additional fields to the soql
            /*if (fieldList != null) {
                for (String s : fieldList) {
                    soql += ' or ' + s + filter;
                }
            }*/
            soql += ' order by Name';
            system.debug(soql);
            
            List<sObject> L = new List<sObject>();
            try {
                L = Database.query(soql);
            }
            catch (QueryException e) {
                return null;
            }
            return L;        
        
        // else if(qry.trim().length()>1){
            // List<List <sObject>> searchList;
            // String soslQuery = '';
            // soslQuery = 'find {'+String.escapeSingleQuotes(qry)+'*} IN ALL FIELDS RETURNING '+obj+' (';
            // List<Schema.FieldSetMember> fieldSetMemberList =  Core_Utility.readFieldSet(fieldSetName,obj);
            // for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                // soslQuery += fieldSetMemberObj.getFieldPath() + ', ';
            // }
            // //soslQuery += 'id where Core_EOIS__c != True) ';
            // soslQuery += 'id,Name where status!=\'Inactive\'';
            // system.debug('relatedid==>'+relatedId);
            // if(relatedId!=null && relatedId!='NA' && relatedId!=''){
                // soslQuery += ' and core_ips_project__c=: relatedId LIMIT 20)';
            // }else{
                // soslQuery += ' and core_ips_project__c=null LIMIT 20)';
                // //soslQuery += ')';
            // }
            // system.debug('####soslQuery####'+soslQuery);        
            // List<sObject> L = new List<sObject>();
            // try {
                // searchList = search.query(soslQuery);
                // L = ((List<SObject>)searchList[0]);    
            // }
            // catch (QueryException e) {
                // return null;
            // }
            // return L;
       // }
       //return null;                        
   }
   
    /***************************************************************************************************
    Method Name:  getColumnsName
    Method Type: get Method 
    Version     : 1.0 
    Created Date: Dec-22-2015
    Function    : This method get the fields from field-set of asset also set  first column as link.
    Input Parameters: None
    Output Parameters: None
    Description: This method is called when product search in progress. 
    Used in     : ProjectComponent
    Modification Log :
                   
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sunil Chandani           11/12/2015                 Created
    ****************************************************************************************************/
     public string getColumnsName() {
        String ColumnList = '';
        integer counter = 0;
        ColumnList += '{"mDataProp": "ID","sTitle":"Name","defaultContent":"","render": function( oObj,row,set ) { return "<input type=\'radio\' name=\''+objectname+'_group\' title=\'"+set.Name+"\' value=\'" + set.Id + " \'/>" + set.Name;}},'; 
        //ColumnList += '{"mDataProp": "Name","sTitle":"Name","defaultContent":""},';            
        for(Schema.FieldSetMember f : Core_Utility.readFieldSet(fieldSetName,objectname)) {                        
            ColumnList += '{"mDataProp": "' + f.getFieldPath() + '","sTitle":"' + f.getLabel() + '","defaultContent":""'+ (string.valueOf(f.getType()).contains('DATE') ? ',"Type":"date"':'') +'},';            
        }
        ColumnList = ColumnList.substring(0,ColumnList.length()-1);
        //ColumnList += '{"mDataProp": "Id"}';
        return ColumnList;
    } 
}