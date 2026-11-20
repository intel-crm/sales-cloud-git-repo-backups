/****************************************************************************************************************************************
* Class Name  : Core_MDF_MockHttpResponseGenerator_Test
* Version     : 1.0 
* Created Date: 12/10/2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Shridhar K       12/10/2018                    Core_MDF_MockHttpResponseGenerator class is created to generate fake response for test class.
*****************************************************************************************************************************************/
@isTest
global class Core_MDF_MockHttpResponseGenerator_Test implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('callout:Core_MDF_Predictive_API', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        //Create resopnse body
        
        String responseBody ='<soapenv:Envelope><soapenv:Body>'+
                             '<AdvancedBI>'+
                            '<header>'+
                            '<CycleID>07122018032444</CycleID>'+
                            '<RecordsNumber>1</RecordsNumber>'+
                            '<PredictionTimeStamp>2018-12-09T20:45:22</PredictionTimeStamp>'+
                            '</header>'+
                            '<Request>'+
                            '<Line Number="1">'+
                            '<ProjectId ID="118">'+
                            '<RequestID>00001320-343</RequestID>'+
                            '<Program>Client Co-Marketing Fund</Program>'+
                            '<PredictionResult>Non-compliant High</PredictionResult>'+
                            '<PredictionScore>0.921954</PredictionScore>'+
                            '<ThresholdFlag>Yes</ThresholdFlag>'+
                            '<Probability>0.5666667</Probability>'+
                            '<ModelTimeStamp>11/1/2018 3:17:30 PM</ModelTimeStamp>'+
                            '<IdealModelResult>Non-Compliant</IdealModelResult>'+
                            '</ProjectId>'+
                            '</Line>'+
                            '</Request>'+
                            '</AdvancedBI>'+
                            '</soapenv:Body></soapenv:Envelope>';        
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(responseBody);
        return res;
    }
}