/***************************************************************************
Class Name    : PSG_Quote_Price_MockTest
Version       : 1.0
Created Date  : 26/08/2024             
Modification Log :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Ranjit                26/08/2024                           Mock class for PSG_Quote_Price_Prediction_Test.
*****************************************************************************************************************************************/
@isTest
public class PSG_Quote_Price_MockTest implements HttpCalloutMock {

    public HTTPResponse respondClassification(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string json='{"strData":"[{\\\"predicted_value\\\":0,\\\"EndCustomerName\\\":\\\"Wistron Corporation\\\",\\\"EndCustomerRegion\\\":\\\"APJ\\\",\\\"QuoteLineNumber\\\":128548}]" }';
        res.setBody(json);
        res.setStatusCode(Integer.valueOf(System.Label.PSG_ALN_SuccessCode));
        return res;
    }

    public HTTPResponse respondPrediction(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        string json='{"strData":"[{\\\"predicted_value\\\":453.23,\\\"EndCustomerName\\\":\\\"Wistron Corporation\\\",\\\"EndCustomerRegion\\\":\\\"APJ\\\",\\\"QuoteLineNumber\\\":128548}]" }';
        res.setBody(json);
        res.setStatusCode(Integer.valueOf(System.Label.PSG_ALN_SuccessCode));
        return res;
    }

    public HTTPResponse respond(HTTPRequest req) {
        if (req.getEndpoint().contains('classification')) {
            return respondClassification(req);
        } else if (req.getEndpoint().contains('prediction')) {
            return respondPrediction(req);
        } else {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(404);
            res.setBody('{"error": "Invalid endpoint"}');
            return res;
        }
    }
}