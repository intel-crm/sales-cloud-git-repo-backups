@isTest
global class Core_MDF_ClaimEzy_Callout_Mock implements HttpCalloutMock {
		 global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Operation-Location', 'https://di-opnai1-dev-frte.cognitiveservices.azure.com/formrecognizer/documentModels/prebuilt-read/analyzeResults/fa6fa2ae-d85a-4a5c-9bdb-6efda0158a0e?api-version=2023-07-31');
        res.setHeader('apim-request-id', '691c7a49-2e80-4b8a-9095-22496e41ae83');
        //res.setBody('{"token_type":"Bearer","scope":"Content.Create Dashboard.Read.All Data.Alter_Any Dataset.Read.All Dataset.ReadWrite.All Group.Read Group.Read.All Metadata.View_Any Report.Read.All","expires_in":"3599","ext_expires_in":"0","expires_on":"1482242395","not_before":"1482238495","resource":"https://analysis.windows.net/powerbi/api","access_token":"accessCookieToken","refresh_token":"refreshCookieToken","id_token":"idToken"}');
         res.setBody('{ "status": "succeeded","analyzeResult": {"content": "Amount : $10\\nTax : $1\\nInvoice Date : 12-02-2024\\nInvoice Number : 11111"}, "choices": [{"message": {"content": "Invoice Number: INV-3337\\nInvoice Amount: $93.50\\nInvoice Date: 25/01/2016\\nTax: $8.50\\nCurrency Code: USD"}}]}');
         res.setStatusCode(200);
        return res;
    }
}