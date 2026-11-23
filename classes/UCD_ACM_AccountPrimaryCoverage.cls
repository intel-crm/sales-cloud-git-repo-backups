public with sharing class UCD_ACM_AccountPrimaryCoverage {
    public static final String Post_Method = 'POST';

    @future(callout=true)
    public static void AccountPrimaryCoverage(String field1, String field2){
        string finalResponse = '';
        List<RequestModel> sending=new List<RequestModel>();
        sending = buildRequestModel(field1,field2);
        finalResponse = json.serialize(sending);
            if(sending!=null){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:SalesCRM_Apigee/'+System.Label.Primary_Coverage_API_EndPoint); // Replace with actual endpoint
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(finalResponse);
            System.debug('Final Response '+ finalResponse);

            try {
            HttpResponse response = http.send(request);
            System.debug('Response Body '+response.getBody());
            } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            }
            
        //finalResponse = callApi(json.serialize(requestModel));
        }    
    }
    private static string callAPI(String requestModel){
        string raj = '';
        Map<String,string>  mapOfHeaders = new Map<String,string> {
            'content-Type'=> 'application.json'};
            string endpoint = 'callout:SalesCRM_Apigee/'+System.Label.Primary_Coverage_API_EndPoint;
            Core_RestClient restClient = new Core_RestClient(endPoint, Post_Method, mapOfHeaders, requestModel, Integer.valueOf(System.Label.Reltio_Timeout));
            restClient.invokeAPI();
            raj = restClient.getHttpResponseStatus();
            System.debug('Response'+raj);
            return raj;
    }    
    public static List<RequestModel> buildRequestModel(Id accountId,String CustomerSalesCoverageTypeCd){
        List<RequestModel> requestBodyList=new List<RequestModel>();
        RequestCrossWalk reqCrosswalk = new RequestCrossWalk();
        CustomerSalesCoverageTypeCd reqattribute =  new CustomerSalesCoverageTypeCd();
        RequestModel requestModel = new RequestModel();
        Attribute attribute = new Attribute();
        attribute.CustomerSalesCoverageTypeCd =  new List<CustomerSalesCoverageTypeCd>{reqattribute};
        requestModel.type = 'configuration/entityTypes/BusinessOrganization';
        reqCrosswalk.type = 'configuration/sources/Salesforce';
        reqCrosswalk.sourceTable = 'Account';
        reqCrosswalk.Value = accountId;
        reqCrosswalk.dataProvider = true;
        reqattribute.type = 'configuration/entityTypes/BusinessOrganization/attributes/CustomerSalesCoverageTypeCd';
        reqattribute.value = CustomerSalesCoverageTypeCd;
        requestModel.crosswalks = new List<RequestCrossWalk>{reqCrosswalk};
        requestModel.attributes = attribute;
        requestBodyList.add(requestModel);
        System.debug('RAJVEER' + requestBodyList);   
        return requestBodyList;
    }

    public class UCD_ACM_JSONRequestModel12 {
    
        @InvocableVariable(required=true)  
        public string AccountId;
        @InvocableVariable(required=true)  
        public String primarycoverge;

    }

        public class RequestModel{
            public List<RequestCrossWalk> crosswalks{set;get;}
            public String type{set;get;}
            public Attribute attributes{set;get;}
        }
        public class Attribute {
            public List<CustomerSalesCoverageTypeCd> CustomerSalesCoverageTypeCd;
        }
        public class CustomerSalesCoverageTypeCd {
            public string type;
            public string value;
        }
        public class RequestCrossWalk {
            public String type;
            public String sourceTable;
            public String value;
            public Boolean dataProvider;
        }
    
}