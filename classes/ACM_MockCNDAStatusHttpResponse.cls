public class ACM_MockCNDAStatusHttpResponse implements HttpCalloutMock {
    
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) 
	{
        // Create a fake response         
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); 
        res.setbody('{    "success": true,    "message": "",    "result": [        {            "contract_number": "cnda003412",            "wfstate": "Active"        },        {            "contract_number": "IPLA1392",            "wfstate": "TAP Archive"        }    ]}');
        res.setStatuscode(200);
        return res;
    }
}