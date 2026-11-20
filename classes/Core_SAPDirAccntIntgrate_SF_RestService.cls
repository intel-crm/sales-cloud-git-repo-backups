/******************************************************************************************************************************************
Class Name:  Core_SAPDirAccntIntgrate_SF_RestService
Version     : 1.0 
Created Date: 26 MAR 2021
Function    : Rest Service class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gireesh K             11/05/2021              Original Version
*****************************************************************************************************************************************/

@RestResource(urlMapping='/utils/SAPAccountInboundintegration/*')
global with sharing class Core_SAPDirAccntIntgrate_SF_RestService {
    @HttpPost
    global static Core_SAPXMLUtility.JsonResponse doPost(){
        String xmlMessage = RestContext.request.requestBody.toString(); //XML Message from POST API
        Core_SAPXMLUtility.JsonResponse response = null;
        List<Core_PSG_SAP_integration__c> psgSAPIntegrationCustomSettingsList = [SELECT Id, isDeactivated__c FROM Core_PSG_SAP_integration__c WITH SECURITY_ENFORCED limit 1];
       
        if(psgSAPIntegrationCustomSettingsList!=null && psgSAPIntegrationCustomSettingsList.size()>0 && !psgSAPIntegrationCustomSettingsList[0].isDeactivated__c && !String.isEmpty(xmlMessage)){
            response = Core_SAPXMLParser.insertXMLData(RestContext.request.requestBody.toString());
        }
        
        return response;
    }    
}