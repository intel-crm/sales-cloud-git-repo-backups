global class Core_IPS_myIntelHttpCalloutMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request){
        HttpResponse response = new HttpResponse();
        /*Apex SFDX deployment test 15&17122025*/
		//Added by Sowmya - Start - 19/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
		if (request.getBody().contains('error404')) {
            response.setStatusCode(404);
            response.setStatus('Failed');
            response.setBody('{"message": "Not Found"}');
        }
        else if(request.getEndpoint() == 'callout:Core_IPS_MyIntel_Integration'){
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Message sent to the Queue');
            response.setStatusCode(200);
        }
		//Sowmya - End - 19/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
     
        return response;
    }
}