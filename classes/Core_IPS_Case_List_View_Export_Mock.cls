@isTest
global class Core_IPS_Case_List_View_Export_Mock implements HTTPCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-type', 'application/json');
        String strJSONResponse = 
        '{' + 
            '"columns" : [ {"ascendingLabel" : "Z-A","descendingLabel" : "A-Z","fieldNameOrPath" : "CaseNumber","hidden" : false,' +
                           '"label" : "Case Number","selectListItem" : "CaseNumber","sortDirection" : "ascending","sortIndex" : 0,' +
                           '"sortable" : true,"type" : "string"}, ' + 
                          '{"ascendingLabel" : "Z-A","descendingLabel" : "A-Z","fieldNameOrPath" : "Contact.Name","hidden" : false,' +
                           '"label" : "Contact Name","selectListItem" : "Contact.Name","sortDirection" : null,"sortIndex" : null,' +
                           '"sortable" : true,"type" : "string"}, ' +
                          '{"ascendingLabel" : "Z-A","descendingLabel" : "A-Z","fieldNameOrPath" : "Subject","hidden" : false,' + 
                           '"label" : "Subject","selectListItem" : "Subject","sortDirection" : null,"sortIndex" : null,' + 
                           '"sortable" : true,"type" : "string"}, ' + 
                          '{"ascendingLabel" : "Low to High","descendingLabel" : "High to Low","fieldNameOrPath" : "Status","hidden" : false,' +
                           '"label" : "Status","selectListItem" : "toLabel(Status)","sortDirection" : null,"sortIndex" : null,' + 
                           '"sortable" : true,"type" : "picklist"}, ' + 
                          '{"ascendingLabel" : "Low to High","descendingLabel" : "High to Low","fieldNameOrPath" : "Priority","hidden" : false,' +
                           '"label" : "Priority","selectListItem" : "toLabel(Priority)","sortDirection" : null,"sortIndex" : null, ' +
                           '"sortable" : true,"type" : "picklist"}, ' + 
                          '{"ascendingLabel" : "New to Old","descendingLabel" : "Old to New","fieldNameOrPath" : "CreatedDate","hidden" : false,' +
                           '"label" : "Date/Time Opened","selectListItem" : "CreatedDate","sortDirection" : null,"sortIndex" : null, ' + 
                           '"sortable" : true,"type" : "datetime"}, ' + 
                          '{"ascendingLabel" : "Z-A","descendingLabel" : "A-Z","fieldNameOrPath" : "Owner.Alias","hidden" : false,' + 
                           '"label" : "Case Owner Alias","selectListItem" : "Owner.Alias","sortDirection" : null,"sortIndex" : null, ' + 
                           '"sortable" : true,"type" : "string"}, ' + 
                          '{"ascendingLabel" : null,"descendingLabel" : null,"fieldNameOrPath" : "Id","hidden" : true,' + 
                           '"label" : "Case ID","selectListItem" : "Id","sortDirection" : null,"sortIndex" : null,' + 
                           '"sortable" : false,"type" : "id"}, ' + 
                          '{"ascendingLabel" : null,"descendingLabel" : null,"fieldNameOrPath" : "RecordTypeId","hidden" : true,' + 
                           '"label" : "Record Type ID","selectListItem" : "RecordTypeId","sortDirection" : null,"sortIndex" : null,' + 
                           '"sortable" : false,"type" : "reference"}, ' + 
                          '{"ascendingLabel" : null,"descendingLabel" : null,"fieldNameOrPath" : "LastModifiedDate","hidden" : true,' + 
                           '"label" : "Last Modified Date","selectListItem" : "LastModifiedDate","sortDirection" : null,"sortIndex" : null,' +
                           '"sortable" : false,"type" : "datetime"}, ' + 
                          '{"ascendingLabel" : null,"descendingLabel" : null,"fieldNameOrPath" : "SystemModstamp","hidden" : true,' + 
                           '"label" : "System Modstamp","selectListItem" : "SystemModstamp","sortDirection" : null,"sortIndex" : null,' + 
                           '"sortable" : false,"type" : "datetime"} ], ' + 
            '"id" : "00Bo00000046iWN", ' + 
            '"orderBy" : [ {"fieldNameOrPath" : "CaseNumber","nullsPosition" : "first","sortDirection" : "ascending"}, ' + 
                          '{"fieldNameOrPath" : "Id","nullsPosition" : "first","sortDirection" : "ascending"} ], ' + 
            '"query" : "SELECT CaseNumber, Contact.Name, Subject, toLabel(Status), toLabel(Priority), CreatedDate, Owner.Alias, Id, RecordTypeId, LastModifiedDate, SystemModstamp FROM Case ORDER BY CaseNumber ASC NULLS FIRST, Id ASC NULLS FIRST",' +
            '"scope" : "everything", ' + 
            '"sobjectType" : "Case", ' + 
            '"whereCondition" : {"conditions" : [ ],"conjunction" : "and"} ' + 
        '}';
        response.setBody(strJSONResponse);        
        response.setStatusCode(200);
        return response;
    }
}