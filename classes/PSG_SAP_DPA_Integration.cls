public class PSG_SAP_DPA_Integration {

	public static void sap_RequestToCreateDPA(String dpaId){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Apigee_Create_DPA_ALN/dpa/create');
        req.setMethod('POST');
        String reqBody = '{' +
        '   "DpaInterfaceAltera": {' +
        '      "ApprovalDt": "01/15/2020 00:00:00",' +
        '      "ApprovedBy": "ROFLANAG",' +
        '      "SAPDPANo": "",' +
        '      "SAPDPAStatus": "Exp Dt Chg",' +
        '      "CMCode": "6100008304",' +
        '      "HeaderComments": "rof",' +
        '      "CreatedDt": "02/27/2020 02:04:24",' +
        '      "DPANo": "1-RZBVJX",' +
        '      "DPAException": "3472",' +
        '      "DistyCustNo": "6100070362",' +
        '      "EndCustCode": "6100008304",' +
        '      "MarketBusinessGroup": "Embedded Acceleration",' +
        '      "MarketEndProductName": "",' +
        '      "MarketSegmentName": "",' +
        '      "MarketSubSegmentName": "",' +
        '      "MarketVerticalSegmentName": "Military",' +
        '      "QuoteNo": "1-RRFUHS728",' +
        '      "RFQ_Number": "1-RQ3HUV",' +
        '      "RepContact": "nurit.keshet",' +
        '      "SalesLocation": "",' +
        '      "SalesRepName": "EASTRONICS",' +
        '      "ShipExpDt": "08/31/2021 00:00:00",' +
        '      "ShipStartDt": "02/27/2020 00:00:00",' +
        '      "SyncComments": "",' +
        '      "Type": "ALN",' +
        '      "PAT_Type": "Time based",' +
        '      "SubmitterEmail": "ross.o.flanagan@intel.com",' +
        '      "PAT_Geo": "",' +
        '      "ShipCustCode": "6100008304",' +
        '      "Quote_Revision": "2",' +
        '      "BaanParent": "6100008304",' +
        '      "ExchangeRate": "",' +
        '      "ReplaceALN": "",' +
        '      "QuoteCurrency": "USD",' +
        '      "ChangeFlag": "E",' +
        '      "SAPCMCountry": "ISRAEL",' +
        '      "ListOfDpaLineItemsInterfaceAltera": {' +
        '         "DpaLineItemsInterfaceAltera": {' +
        '            "ApprovedQty": "1",' +
        '            "UpperBoundQty": "500",' +
        '            "BrokenCost": "251.16",' +
        '            "LineComments": "",' +
        '            "DPANo": "1-RZBVJX",' +
        '            "DistyValueAdded": "0",' +
        '            "LineNumber": "1",' +
        '            "ProductName": "5AGXFB1H4F35I3G",' +
        '            "ClaimedQty": "",' +
        '            "WebRegistrationNo": "SF_Approved_DR",' +
        '            "PATLineId": "1-RZBVK0",' +
        '            "MarginProgram": "Standard Registration",' +
        '            "SuggestedPrice": "299",' +
        '            "ClaimedAmount": "",' +
        '            "PriceRowId": "1-RRO2MV",' +
        '            "BookPrice": "",' +
        '            "ResaleUSD": "299",' +
        '            "ResaleYEN": "",' +
        '            "DistyMargin": "16"' +
        '         }' +
        '      }' +
        '   }' +
        '}' ;
        
        req.setBody(reqBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
	}
}