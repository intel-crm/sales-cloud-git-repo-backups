@RestResource(urlMapping='/v1.0/cases/')
global class IPS_ILM_Test_ILM_Pagination {
    /*{
"customer_data":[
 {
   "id_customerid":"0039000000CEWDD",
   your json structure ...
},....
 {
   "id_customerid":"0039000000CEWD2",//last record of this chunk
   your json structure ...
}],
"api_factory"{
  
  "customer_idcursor":"0039000000CEWD2",
  "pagenumber_total": "10",
  "pagenumber_thisrequest":"2"
}
}*/
    Private static String caseId;
    private static Integer pageNumber=1;
    private static Integer Total_Pages;
    Private Static Integer Page_Limit=20;
    private static final String ORDER_BY =' Order by Id ASC ';
    @httpPost
    global static string getcases(){
       RestRequest request = RestContext.request;
        Integer PageNumber = Integer.valueOf(request.params.get('pagenumber'));
           Integer limitSize = Integer.valueOf(request.params.get('limit'));
           String productId = request.params.get('EpmId');
           String accountId = request.params.get('CIMId');
           String contactId = request.params.get('contactId');
           String contactEmail = request.params.get('contactEmail');
           String contactName = request.params.get('contactName');
           String productName = request.params.get('productName');
           String accountName = request.params.get('accountName');
           String CustomerId_Cursor = request.params.get('customer_idcursor');
           Integer page_Requested = Integer.Valueof(request.params.get('pagenumber_thisrequest'));
           Integer pagenumber_total = Integer.valueOf(request.params.get('pagenumber_total'));
        if( page_Requested==null){
            page_Requested =pageNumber;
        }
        return null;
    }
        
}