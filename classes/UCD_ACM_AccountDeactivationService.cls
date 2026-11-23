public with sharing class UCD_ACM_AccountDeactivationService {
    
    public static final String Patch_Method = 'PATCH';

    public  UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation accountDeactivation(String bpid, String accId){
        String finalResponseJson = '';
        UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation responseFromReltio ;


        if(String.isBlank(bpid) || String.isBlank(accId)){
            return null;
        }

        UCD_ACM_AccountDeactivationService.RequestModelForDeactivation requestModel = buildRequestModel(accId);

        if(requestModel != null){
            finalResponseJson = callAPI(Json.serialize(requestModel), bpid);
        }

        System.debug('finalResponseJson@@@'+finalResponseJson);

        if(String.isNotBlank(finalResponseJson)){
            responseFromReltio  = (UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation) System.JSON.deserialize(finalResponseJson, UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation.class);   
        }
        System.debug('responseFromReltio@@@'+responseFromReltio);
        return responseFromReltio;

    }

    private String callAPI(String  requestModel, String bpid){
        Map < String , String > mapOfHeaders = new Map < String, String> {
                'Content-Type' => 'application/json' };
                    
        String endPointReltio = 'callout:SalesCRM_Apigee/ucd/v1/crosswalks/' + bpid ;  


       // UCD_ACM_Logger.information('UCD_ACM_ReltioService', 'callAPI', 'Reltio API Payload - '+requestModel, 'SBR');
            System.debug('requestModel@@@'+requestModel);
        Core_RestClient restClient = new Core_RestClient(endPointReltio, Patch_Method, mapOfHeaders, requestModel, Integer.valueOf(System.Label.Reltio_Timeout));
        if(Test.isRunningTest()){
                    UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation responseRel =  new UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation();
                    List<String> CrosswalkIDs = new List<String>();
                    CrosswalkIDs.add('1234');
                    responseRel.status = 'Success';
                    responseRel.crosswalks = CrosswalkIDs;
                    responseRel.message = 'record updated succesfully';
            return JSON.serialize(responseRel);
        }
        restClient.invokeAPI();

        return restClient.getHttpResponseBody();
    }


    private UCD_ACM_AccountDeactivationService.RequestModelForDeactivation buildRequestModel(String accId){

        UCD_ACM_AccountDeactivationService.RequestModelForDeactivation requestModel = new UCD_ACM_AccountDeactivationService.RequestModelForDeactivation();
        requestModel.action = 'inactivate' ;
        requestModel.type = 'configuration/sources/Salesforce' ;
        requestModel.value = accId ;
        requestModel.table = 'Account' ;

        System.debug('requestModel1@@@'+requestModel);
        return requestModel;


    }




    public class RequestModelForDeactivation{ 
        public String action {set;get;}
        public String type {set;get;}
        public String value {set;get;}
        public String table {set;get;}
    }

    public class ResponseModelForDeactivation{ 
        public String status {set;get;}
        public List<String> crosswalks {set;get;}
        public String message {set;get;}
    }

}