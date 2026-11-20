/****************************************************************************************************************************************
* Class Name  : Core_MDF_ExportToExcel_Mock
* Version     : 1.0 
* Created Date: 05/01/2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Shridhar K       05/01/2019                    Core_MDF_ExportToExcel_Mock class is created to generate dummy response for ExportToExcel test class.
*****************************************************************************************************************************************/

@isTest
global class Core_MDF_ExportToExcelAccount_Mock implements HTTPCalloutMock {
  @SuppressWarnings('PMD') 
    global HTTPResponse respond(HTTPRequest request) {
    
        Id accountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_MDF_Co_Marketing').getRecordTypeId();
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-type', 'application/json');
        String strJSONResponse = 
            '{'+
              '"columns" : [ {'+
                '"ascendingLabel" : "Z-A",'+
                '"descendingLabel" : "A-Z",'+
                '"fieldNameOrPath" : "Name",'+
                '"hidden" : false,'+
                '"label" : "Account Name",'+
                '"selectListItem" : "Name",'+
                '"sortDirection" : "ascending",'+
                '"sortIndex" : 0,'+
                '"sortable" : true,'+
                '"type" : "string"'+
              '}, {'+
                '"ascendingLabel" : "Ascending",'+
                '"descendingLabel" : "Descending",'+
                '"fieldNameOrPath" : "Core_MDF_Parent_Fund_Account__r.Name",'+
                '"hidden" : false,'+
                '"label" : "Parent Fund Account",'+
                '"selectListItem" : "Core_MDF_Parent_Fund_Account__r.Name",'+
                '"sortDirection" : null,'+
                '"sortIndex" : null,'+
                '"sortable" : true,'+
                '"type" : "reference"'+
              '}, {'+
                '"ascendingLabel" : "Ascending",'+
                '"descendingLabel" : "Descending",'+
                '"fieldNameOrPath" : "Core_MDF_Channel_Program__r.Name",'+
                '"hidden" : false,'+
                '"label" : "Channel Program",'+
                '"selectListItem" : "Core_MDF_Channel_Program__r.Name",'+
                '"sortDirection" : null,'+
                '"sortIndex" : null,'+
                '"sortable" : true,'+
                '"type" : "reference"'+
              '}, {'+
                '"ascendingLabel" : "Z-A",'+
                '"descendingLabel" : "A-Z",'+
                '"fieldNameOrPath" : "Core_Account_Owner__c",'+
                '"hidden" : false,'+
                '"label" : "Account Owner",'+
                '"selectListItem" : "Core_Account_Owner__c",'+
                '"sortDirection" : null,'+
                '"sortIndex" : null,'+
                '"sortable" : true,'+
                '"type" : "string"'+
              '}, {'+
                '"ascendingLabel" : null,'+
                '"descendingLabel" : null,'+
                '"fieldNameOrPath" : "Id",'+
                '"hidden" : true,'+
                '"label" : "Account ID",'+
                '"selectListItem" : "Id",'+
                '"sortDirection" : null,'+
                '"sortIndex" : null,'+
                '"sortable" : false,'+
                '"type" : "id"'+
              '}, {'+
                '"ascendingLabel" : null,'+
                '"descendingLabel" : null,'+
                '"fieldNameOrPath" : "RecordTypeId",'+
                '"hidden" : true,'+
                '"label" : "Record Type ID",'+
                '"selectListItem" : "RecordTypeId",'+
                '"sortDirection" : null,'+
                '"sortIndex" : null,'+
                '"sortable" : false,'+
                '"type" : "reference"'+
              '}, {'+
                '"ascendingLabel" : null,'+
                '"descendingLabel" : null,'+
                '"fieldNameOrPath" : "CreatedDate",'+
                '"hidden" : true,'+
                '"label" : "Created Date",'+
                '"selectListItem" : "CreatedDate",'+
                '"sortDirection" : null,'+
                '"sortIndex" : null,'+
                '"sortable" : false,'+
                '"type" : "datetime"'+
              '}, {'+
                '"ascendingLabel" : null,'+
                '"descendingLabel" : null,'+
                '"fieldNameOrPath" : "LastModifiedDate",'+
                '"hidden" : true,'+
                '"label" : "Last Modified Date",'+
                '"selectListItem" : "LastModifiedDate",'+
                '"sortDirection" : null,'+
                '"sortIndex" : null,'+
                '"sortable" : false,'+
                '"type" : "datetime"'+
              '}, {'+
                '"ascendingLabel" : null,'+
                '"descendingLabel" : null,'+
                '"fieldNameOrPath" : "SystemModstamp",'+
                '"hidden" : true,'+
                '"label" : "System Modstamp",'+
                '"selectListItem" : "SystemModstamp",'+
                '"sortDirection" : null,'+
                '"sortIndex" : null,'+
                '"sortable" : false,'+
                '"type" : "datetime"'+
              '} ],'+
              '"id" : "00B3D000001ofHj",'+
              '"orderBy" : [ {'+
                '"fieldNameOrPath" : "Name",'+
                '"nullsPosition" : "first",'+
                '"sortDirection" : "ascending"'+
              '}, {'+
                '"fieldNameOrPath" : "Id",'+
                '"nullsPosition" : "first",'+
                '"sortDirection" : "ascending"'+
              '} ],'+
              '"query" : "SELECT Name, Core_MDF_Parent_Fund_Account__r.Name, Core_MDF_Channel_Program__r.Name, Core_Account_Owner__c, Id, RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp FROM Account WHERE RecordTypeId ='+ '\''+accountRecordType+'\''+ 'AND Core_MDF_Active_Ind__c = true ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST",'+
              '"scope" : "everything",'+
              '"sobjectType" : "Account",'+
              '"whereCondition" : {'+
                '"conditions" : [ {'+
                  '"field" : "RecordTypeId",'+
                  '"operator" : "equals",'+
                  '"values" : [ "' + '0123D0000003q1j'+ '" ]'+
                '}, {'+
                  '"field" : "Core_MDF_Active_Ind__c",'+
                  '"operator" : "equals",'+
                  '"values" : [ "true" ]'+
                '} ],'+
                '"conjunction" : "and"'+
              '}'+
            '}';

        response.setBody(strJSONResponse);        
        response.setStatusCode(200);
        return response;
    }
}