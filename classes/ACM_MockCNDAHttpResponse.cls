public class ACM_MockCNDAHttpResponse implements HttpCalloutMock {
    
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest request) 
	{
        // Create a fake response         
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json'); 
        res.setbody('{    "success": true,    "message": "",    "result": [        {            "intel_contact_name": "CAMERON CAMPBELL",            "counterparty_name": "LECROY CORPORATION",            "contract_type0": "NDA",            "counterparty_state_province": "New York",            "wfstate": "Active",            "counterparty_address_line_1": "700 CHESTNUT RIDGE RD",            "contract_number": "RS5395311",            "contract_subtype": "RSNDA",            "counterparty_country": "United States",            "counterparty_zip_or_postal_code": "10977-6435",            "counterparty_city": "CHESTNUT RIDGE"        },        {            "intel_contact_name": "JOHN ZAVERTNIK",            "counterparty_name": "LECROY CORPORATION",            "contract_type0": "NDA",            "counterparty_state_province": "New York",            "wfstate": "Active",            "counterparty_address_line_1": "700 CHESTNUT RIDGE ROAD",            "contract_number": "RS9568086",            "contract_subtype": "RSNDA",            "counterparty_country": "United States",            "counterparty_zip_or_postal_code": "10977-6499",            "counterparty_city": "CHESTNUT RIDGE"        }    ]}');
        res.setStatuscode(200);
        return res;
    }
}