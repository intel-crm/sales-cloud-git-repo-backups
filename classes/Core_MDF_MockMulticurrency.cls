@isTest
global class Core_MDF_MockMulticurrency implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        
        System.assertEquals('callout:APIJEE_Multicurrency_URL', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        //Create resopnse body
        /*String responseBody ='[{"WeeklyCurrencyCode": "ADP",' +
            '"WeeklyRateDetails": 0.0068431211,'+
            '"MarketDate": "07-19-2020"'+
            '}]'; */    
            
            // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-type', 'application/json');
        res.setBody('Error');
        res.setStatusCode(200);
        return res;
    }
}