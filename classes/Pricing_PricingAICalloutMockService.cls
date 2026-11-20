global class Pricing_PricingAICalloutMockService implements HttpCalloutMock {
	global HttpResponse respond(HTTPRequest req){
        String respJSON = '{"successContent": [{"recommendedPrice": 831.9751712861158, "probability": {"ranges": [[1020, 1140], ["null", null], [null, null]], "plots": {"low_risk": [[1020, 0.6890723580059847], [1040, 0.6876656083613704], [1060, 0.6853981259579003], [1080, 0.6828784010140679], [1100, 0.6806413263611588], [1120, 0.6790313010291351], [1140, 0.6782026882869446]], "high_risk": [], "severe_risk": []}, "ecapPrice": 831.9751712861158, "requestedPrice": 0, "priceAxisRange": [831.9751712861158, 1140]}, "priceInterval": "749-915", "cap": 1169.0, "discount": "0.29%", "probabilityOfWwinning": false, "quoteLineNumber": "Q-95723-010"}], "errorContent": []}';
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(300);
        res.setBody(respJSON);
        return res;
    }
}