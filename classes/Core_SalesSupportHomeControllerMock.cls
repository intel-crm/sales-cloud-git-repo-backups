@isTest
global class Core_SalesSupportHomeControllerMock implements HTTPCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        
        System.assertEquals('GET', request.getMethod());
        String jsonStr = ' ['+
    '{'+
        '"quote_name": "869476.01",'+
        '"creator": null,'+
        '"cre_dt": "2023-02-27",'+
        '"quote_type": "Volume",'+
        '"quote_status": "DPA Closed",'+
        '"prd_dsc": null,'+
        '"aprv_prc": 194.0000,'+
        '"aprv_qty": 500,'+
        '"dpa_vld_fr_dt": "2023-02-28",'+
        '"dpa_expr_dt": "2023-07-31",'+
        '"DPA Number": 40692590'+
    '},'+
    '{'+
        '"quote_name": "869476.02",'+
        '"creator": null,'+
        '"cre_dt": "2023-02-27",'+
        '"quote_type": "Volume",'+
        '"quote_status": "DPA Closed",'+
        '"prd_dsc": null,'+
        '"aprv_prc": 57.0000,'+
        '"aprv_qty": 500,'+
        '"dpa_vld_fr_dt": "2023-02-28",'+
        '"dpa_expr_dt": "2023-07-31",'+
        '"DPA Number": 40692590'+
    '},'+
   ' {'+
        '"quote_name": "869476.03",'+
        '"creator": null,'+
        '"cre_dt": "2023-02-27",'+
        '"quote_type": "Volume",'+
        '"quote_status": "DPA Closed",'+
        '"prd_dsc": null,'+
        '"aprv_prc": 88.0000,'+
        '"aprv_qty": 500,'+
        '"dpa_vld_fr_dt": "2023-02-28",'+
        '"dpa_expr_dt": "2023-07-31",'+
        '"DPA Number": 40692590'+
   ' }'+
	']';
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(jsonStr);
        response.setStatusCode(200);
        response.setStatus('SUCCESS');
        return response;
             
         
    }
	
}