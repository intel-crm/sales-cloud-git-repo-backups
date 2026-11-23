/*
global class PSG_Integration_DPA_MockTest implements HttpCalloutMock {
    
	global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ListOfDpaInterfaceAltera" : { "DpaInterfaceAltera" : { "DPANo" : "1-GDVAMJ", "SAPDPANo" : "1-GDVAMJ", "SAPDPAStatus" : "AWRDApproved - Awarded" , "Type" : "ALN"}}}');
        res.setStatusCode(Integer.ValueOf(System.Label.PSG_DPAALNSuccessCode));
        return res;
    }
    
}*/
@isTest
public class PSG_Integration_DPA_MockTest{
}