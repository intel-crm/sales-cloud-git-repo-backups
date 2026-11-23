/*********************************************************************************************************************
Apex Class Name  : UCD_ACM_AccountDeactivationService
Author And Date  : Ankit Sharma, 6 September 2023
Function         : This class has code for removing crosswalks on deactivation
Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Ankit Sharma             6/9/2023                Created
* Chethan Kunder           17/10/2024              Created removeCWLXwalk(),created & updated some variables
*********************************************************************************************************************/
public with sharing class UCD_ACM_AccountDeactivationService {
    
    private static final String HTTP_PATCH = 'PATCH';
    //table variables to be passed to buildRequestModel() 
    private static final String OBJ_ACCT = 'Account';
    private static final String OBJ_CPE = 'Account_Business_Types__c';
    
    public UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation removeAcctXwalk(String bpid, String accId,String action) {
        String finalResponseJson = '';
        UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation responseFromReltio ;
        if(String.isBlank(bpid) || String.isBlank(accId)){
            return null;
        }
        UCD_ACM_AccountDeactivationService.RequestModelForDeactivation requestModel = buildRequestModel(accId,action,OBJ_ACCT);
        finalResponseJson = callAPI(Json.serialize(requestModel), bpid);
        if(String.isNotBlank(finalResponseJson)){
            responseFromReltio  = (UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation) System.JSON.deserialize(finalResponseJson, UCD_ACM_AccountDeactivationService.ResponseModelForDeactivation.class);   
        }
        return responseFromReltio;
    }

    public void removeCPEXwalk(String bpid, String action, Set<Id> cpeIds) {
        if(String.isNotBlank(bpid)) {
            for (Id cplId : cpeIds) {
                UCD_ACM_AccountDeactivationService.RequestModelForDeactivation requestModelCPE = buildRequestModel(cplId,action,OBJ_CPE);
                callAPI(Json.serialize(requestModelCPE), bpid);
            }
        }
    }

    private static String callAPI(String requestModel, String bpid) {
        Map < String , String > mapOfHeaders = new Map < String, String> { 'Content-Type' => 'application/json' };   
        String endPointReltio = 'callout:SalesCRM_UCD_App/ucd/v1/crosswalks/' + bpid ;
        Core_RestClient restClient = new Core_RestClient(endPointReltio, HTTP_PATCH, mapOfHeaders, requestModel, Integer.valueOf(System.Label.Reltio_Timeout));    
        restClient.invokeAPI();
        return restClient.getHttpResponseBody();
    }

    private static UCD_ACM_AccountDeactivationService.RequestModelForDeactivation buildRequestModel(String objId,String action,String table) {
        UCD_ACM_AccountDeactivationService.RequestModelForDeactivation requestModel = new UCD_ACM_AccountDeactivationService.RequestModelForDeactivation();
        requestModel.action = action == 'Deactivate' ? 'inactivate' : 'activate';
        requestModel.type = 'configuration/sources/Salesforce' ;
        requestModel.value = objId ;
        requestModel.table = table ;
        return requestModel;
    }

    //chnaged access modifier of the function from public to private
    private class RequestModelForDeactivation { 
        public String action {set;get;}
        public String type {set;get;}
        public String value {set;get;}
        public String table {set;get;}
    }

    public class ResponseModelForDeactivation { 
        public String status {set;get;}
        public List<String> crosswalks {set;get;}
        public String message {set;get;}
    }
}