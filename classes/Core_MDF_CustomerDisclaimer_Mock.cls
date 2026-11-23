//Core_MDF_CustomerDisclaimer_Mock class created to generate dummy response for CustomerDisclaimer Test class.
@isTest
global class Core_MDF_CustomerDisclaimer_Mock implements HTTPCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        
        System.debug('In Core_MDF_CustomerDisclaimer_Mock.respond() method.');
       // System.assertEquals('http://test.com', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());
        String s='<div align=center>';
s+='<p>This Issue Management application is subject to the of the Business Portal and the Terms and Conditions of Companys Corporate Non-Disclosure </p>';
s+='</div>';
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(s);//{"example":"test"}
        response.setStatusCode(200);
        return response;
        
        //String strJSONResponse = '';
        /*'{'+
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
          '}';

         response.setBody(strJSONResponse); */       
         
    }
}