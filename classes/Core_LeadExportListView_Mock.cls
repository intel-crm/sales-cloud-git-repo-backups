/****************************************************************************************************************************************
* Class Name  : Core_LeadExportListView_Mock
* Version     : 1.0 
* Created Date: 10/14/2019
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Mahesh                       10/14/2019                    Core_LeadExportListView_Mock class is created to generate dummy response for Core_Lead_ExportListview_Test test class.
*****************************************************************************************************************************************/
@isTest
global class Core_LeadExportListView_Mock implements HTTPCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-type', 'application/json');
        String strJSONResponse = 
            '{'+
            '"columns" : [ {'+
            '"ascendingLabel" : "Z-A",'+
            '"descendingLabel" : "A-Z",'+
            '"fieldNameOrPath" : "Title",'+
            '"hidden" : false,'+
            '"label" : "Claim Name",'+
            '"searchable" : true,'+
            '"selectListItem" : "Title",'+
            '"sortDirection" : "ascending",'+
            '"sortIndex" : 0,'+
            '"sortable" : true,'+
            '"type" : "string"'+
            '}, {'+
            '"ascendingLabel" : "Z-A",'+
            '"descendingLabel" : "A-Z",'+
            '"fieldNameOrPath" : "Core_MDF_Claim_Ref_Number__c",'+
            '"hidden" : false,'+
            '"label" : "Claim ID",'+
            '"searchable" : true,'+
            '"selectListItem" : "Core_MDF_Claim_Ref_Number__c",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : true,'+
            '"type" : "string"'+
            '}, {'+
            '"ascendingLabel" : "Z-A",'+
            '"descendingLabel" : "A-Z",'+
            '"fieldNameOrPath" : "Request.Title",'+
            '"hidden" : false,'+
            '"label" : "Activity",'+
            '"searchable" : true,'+
            '"selectListItem" : "Request.Title",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : true,'+
            '"type" : "string"'+
            '}, {'+
            '"ascendingLabel" : "Z-A",'+
            '"descendingLabel" : "A-Z",'+
            '"fieldNameOrPath" : "Core_MDF_Program__c",'+
            '"hidden" : false,'+
            '"label" : "Program",'+
            '"searchable" : false,'+
            '"selectListItem" : "Core_MDF_Program__c",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : true,'+
            '"type" : "string"'+
            '}, {'+
            '"ascendingLabel" : "Z-A",'+
            '"descendingLabel" : "A-Z",'+
            '"fieldNameOrPath" : "Request.ChannelPartner.Name",'+
            '"hidden" : false,'+
            '"label" : "Channel Partner",'+
            '"searchable" : true,'+
            '"selectListItem" : "Request.ChannelPartner.Name",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : true,'+
            '"type" : "string"'+
            '}, {'+
            '"ascendingLabel" : "Z-A",'+
            '"descendingLabel" : "A-Z",'+
            '"fieldNameOrPath" : "Core_MDF_Country_Location__c",'+
            '"hidden" : false,'+
            '"label" : "Country/Region",'+
            '"searchable" : false,'+
            '"selectListItem" : "Core_MDF_Country_Location__c",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : true,'+
            '"type" : "string"'+
            '}, {'+
            '"ascendingLabel" : "9-0",'+
            '"descendingLabel" : "0-9",'+
            '"fieldNameOrPath" : "Core_MDF_Requested_Reimbursement_Amt__c",'+
            '"hidden" : false,'+
            '"label" : "Requested Amount (USD)",'+
            '"searchable" : false,'+
            '"selectListItem" : "Core_MDF_Requested_Reimbursement_Amt__c",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : true,'+
            '"type" : "currency"'+
            '}, {'+
            '"ascendingLabel" : "Low to High",'+
            '"descendingLabel" : "High to Low",'+
            '"fieldNameOrPath" : "Core_MDF_Status__c",'+
            '"hidden" : false,'+
            '"label" : "Claim Status",'+
            '"searchable" : false,'+
            '"selectListItem" : "toLabel(Core_MDF_Status__c)",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : true,'+
            '"type" : "picklist"'+
            '}, {'+
            '"ascendingLabel" : "Z-A",'+
            '"descendingLabel" : "A-Z",'+
            '"fieldNameOrPath" : "Core_MDF_CreatedBy_Nm__c",'+
            '"hidden" : false,'+
            '"label" : "CreatedBy",'+
            '"searchable" : false,'+
            '"selectListItem" : "Core_MDF_CreatedBy_Nm__c",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : true,'+
            '"type" : "string"'+
            '}, {'+
            '"ascendingLabel" : "New to Old",'+
            '"descendingLabel" : "Old to New",'+
            '"fieldNameOrPath" : "CreatedDate",'+
            '"hidden" : false,'+
            '"label" : "Created Date",'+
            '"searchable" : false,'+
            '"selectListItem" : "CreatedDate",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : true,'+
            '"type" : "datetime"'+
            '}, {'+
            '"ascendingLabel" : "Low to High",'+
            '"descendingLabel" : "High to Low",'+
            '"fieldNameOrPath" : "Core_MDF_Cap_Type_nm__c",'+
            '"hidden" : false,'+
            '"label" : "Cap Type",'+
            '"searchable" : false,'+
            '"selectListItem" : "toLabel(Core_MDF_Cap_Type_nm__c)",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : true,'+
            '"type" : "picklist"'+
            '}, {'+
            '"ascendingLabel" : null,'+
            '"descendingLabel" : null,'+
            '"fieldNameOrPath" : "Id",'+
            '"hidden" : true,'+
            '"label" : "Claim ID",'+
            '"searchable" : false,'+
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
            '"searchable" : false,'+
            '"selectListItem" : "RecordTypeId",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : false,'+
            '"type" : "reference"'+
            '}, {'+
            '"ascendingLabel" : null,'+
            '"descendingLabel" : null,'+
            '"fieldNameOrPath" : "LastModifiedDate",'+
            '"hidden" : true,'+
            '"label" : "Last Modified Date",'+
            '"searchable" : false,'+
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
            '"searchable" : false,'+
            '"selectListItem" : "SystemModstamp",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : false,'+
            '"type" : "datetime"'+
            '}, {'+
            '"ascendingLabel" : null,'+
            '"descendingLabel" : null,'+
            '"fieldNameOrPath" : "Request.Id",'+
            '"hidden" : true,'+
            '"label" : "Partner Fund Request ID",'+
            '"searchable" : false,'+
            '"selectListItem" : "Request.Id",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : false,'+
            '"type" : "id"'+
            '}, {'+
            '"ascendingLabel" : null,'+
            '"descendingLabel" : null,'+
            '"fieldNameOrPath" : "RequestId",'+
            '"hidden" : true,'+
            '"label" : "Activity",'+
            '"searchable" : false,'+
            '"selectListItem" : "RequestId",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : false,'+
            '"type" : "reference"'+
            '}, {'+
            '"ascendingLabel" : null,'+
            '"descendingLabel" : null,'+
            '"fieldNameOrPath" : "Request.RecordTypeId",'+
            '"hidden" : true,'+
            '"label" : "Record Type ID",'+
            '"searchable" : false,'+
            '"selectListItem" : "Request.RecordTypeId",'+
            '"sortDirection" : null,'+
            '"sortIndex" : null,'+
            '"sortable" : false,'+
            '"type" : "reference"'+
            '} ],'+
            '"id" : "00B3D0000020tpj",'+
            '"orderBy" : [ {'+
            '"fieldNameOrPath" : "Title",'+
            '"nullsPosition" : "first",'+
            '"sortDirection" : "ascending"'+
            '}, {'+
            '"fieldNameOrPath" : "Id",'+
            '"nullsPosition" : "first",'+
            '"sortDirection" : "ascending"'+
            '} ],'+
            '"query" : "SELECT Title, Core_MDF_Claim_Ref_Number__c, Request.Title, Core_MDF_Program__c, Request.ChannelPartner.Name, Core_MDF_Country_Location__c, Core_MDF_Requested_Reimbursement_Amt__c, toLabel(Core_MDF_Status__c), Core_MDF_CreatedBy_Nm__c, CreatedDate, toLabel(Core_MDF_Cap_Type_nm__c), Id, RecordTypeId, LastModifiedDate, SystemModstamp, Request.Id, RequestId, Request.RecordTypeId FROM PartnerFundClaim WHERE Core_MDF_Status__c ='+'\''+ 'Denied' + '\'' +' ORDER BY Title ASC NULLS FIRST, Id ASC NULLS FIRST",'+
            '"relatedEntityId" : null,'+
            '"scope" : "everything",'+
            '"scopeEntityId" : null,'+
            '"sobjectType" : "PartnerFundClaim",'+
            '"whereCondition" : {'+
            ' "field" : "Core_MDF_Status__c",'+
            '"operator" : "equals",'+
            ' "values" :  [ "' + 'Denied'+ '" ]'+
            '}'+
            '}';
        
        response.setBody(strJSONResponse);        
        response.setStatusCode(200);
        return response;
    }
}