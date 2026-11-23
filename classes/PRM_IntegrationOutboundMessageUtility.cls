/*********************************************************************************************************************
Apex Class Name  : PRM_IntegrationOutboundMessageUtility
Version       : 1.0
Created Date  : 18th May 2020
Function      : Utility class for Integration Outbound Messages

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Saba Husain               18/05/2020              Utility class for Integration Outbound Messages
* Neha Sharma               13/02/2024              Updated the class to reduce cognitive complexity. Divided the method 'createOPIDRequestMessage'
                                                    into smaller methods.
*********************************************************************************************************************/

public without sharing class PRM_IntegrationOutboundMessageUtility{
  public static String CimPrimeEol=System.label.PRM_CIM_PRIME_Switch;// TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing  
    /**
* @description      : This method creates two integration outbound messages for each OPIDRecommendation(wrapper class) of different request types
* @name             : createOPIDRequestMessage
* @param            : List<OPIDRecommendation>
* @return           : List<String> createOPIDRequestMessage - List of succesfull OPID recommendation records
* @throws exception : NONE
**/
//TWC729-6800 EOL activities--Start
public static List<String> createOPIDRequestMessage(List<OPIDRecommendation> opidRecommendationList) {
    List<Core_Integration_Outbound_Message__c> intOutboundMessageList = new List<Core_Integration_Outbound_Message__c>();
    List<String> listOfRecommendationIds = new List<String>();
    List<String> successfulRecordIds = new List<String>();
    /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
    if (opidRecommendationList != null) {
        for (OPIDRecommendation opidRecom : opidRecommendationList) {
            addIntegrationOutboundMessage(intOutboundMessageList, opidRecom, System.label.Setup_Prime_Hierarchy);
            addIntegrationOutboundMessage(intOutboundMessageList, opidRecom, System.label.Setup_Partner_Account_Hierarchy);
        }

        List<Database.SaveResult> srList = Database.insert(intOutboundMessageList, false);

        for (Database.SaveResult sr : srList) {
            processSaveResult(sr, successfulRecordIds);
        }

        listOfRecommendationIds = getRecommendationIds(successfulRecordIds);
    }
    }*/
    return listOfRecommendationIds;
    } //TWC729-6800 EOL activities--End

private static void addIntegrationOutboundMessage(List<Core_Integration_Outbound_Message__c> intOutboundMessageList, OPIDRecommendation opidRecom, String groupingMethod) {
    /*if ((String.IsNotBlank(opidRecom.accountId) && String.IsNotBlank(opidRecom.cimId) && String.IsNotBlank(opidRecom.groupingMethod) && String.IsNotBlank(opidRecom.groupingValue) && String.isNotBlank(opidRecom.recommendationId) &&CimPrimeEol!='TRUE') || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
        Core_Integration_Outbound_Message__c intOutboundMessage = new Core_Integration_Outbound_Message__c();
        intOutboundMessage.Core_Payload__c = createPayload(groupingMethod, opidRecom.accountId, opidRecom.cimId, opidRecom.groupingMethod, UserInfo.getUserId(), opidRecom.website);
        intOutboundMessage.Core_MessageType__c = System.label.PRM_Message_Type;
        intOutboundMessage.Core_Tags__c = opidRecom.recommendationId;
        intOutboundMessage.Core_Status__c = 'Pending';
        intOutboundMessageList.add(intOutboundMessage);
    }*/
}

//TWC729-6800 EOL activities--Start
private static void processSaveResult(Database.SaveResult sr, List<String> successfulRecordIds) {
    /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
    if (sr.isSuccess()) {
        successfulRecordIds.add(sr.getId());
    } else {
       
        for (Database.Error err : sr.getErrors()) {
            Core_Log_Entry.logEntryWithDetails('PRM_IntegrationOutboundMessageUtility', 'IPA', 'createOPIDRequestMessage', 'exception', 'Exception occurred while inserting Core_Integration_Outbound_Message__c', err.getMessage(), ' ', 'Core_Integration_Outbound_Message__c', ' ');
        }
    }
    }*/} //TWC729-6800 EOL activities--End

private static List<String> getRecommendationIds(List<String> successfulRecordIds) {
    List<String> listOfRecommendationIds = new List<String>();
	/*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
    for (Core_Integration_Outbound_Message__c outboundMsg : [SELECT Id, Core_Tags__c FROM Core_Integration_Outbound_Message__c WHERE Id IN :successfulRecordIds]) {
        if (outboundMsg.Id != null && outboundMsg.Core_Tags__c != null) {
            listOfRecommendationIds.add(outboundMsg.Core_Tags__c);
        }
    }
}*/
    return listOfRecommendationIds;
}

    
    /**
* @description      : This method creates payload for integration outbound messages
* @name             : createPayload
* @param            : String requestType, String accId, String cimId, String groupingMethod
* @throws exception : NONE
**/
    
    public static String createPayload(String requestType, String accId, String cimId, String groupingMethod, String federationId ,string website){
        String payload = '';
        /*if(CimPrimeEol!='TRUE' || test.isrunningtest()){ // TWC729-6990 : CIM Prime EOL – Code changes switch set up for regression testing//IPA2.0 -TWC729-8008 - commenting out as part of IPA refresh cim prime code removal
        GeneratePayload genPayload = new GeneratePayload();
        
        genPayload.RegistryId = Integer.valueOf(System.label.PRM_Registry_Id);
        genPayload.RequestType = requestType;
        genPayload.Status = System.label.PRM_OPIDRequest_Status;
        genPayload.CustomerApplicationSystemNm = System.label.PRM_Agent_Id;
        genPayload.ApplicationSystemCustomerId = accId;
        genPayload.PriorityNbr = Integer.valueOf(System.label.PRM_Priority_Nbr);
        genPayload.RequesterId = federationId;
        genPayload.MasterDataRecordID = cimId; 
        genPayload.PrimeCustomerRowId = '';
        genPayload.CustomerAggregrationMethodType = groupingMethod;
        genPayload.LineOfBusiness = '';
        genPayload.ErrorCd = '';
        genPayload.ErrorDsc = '';
        genPayload.ErrorDetailTxt = '';
        genPayload.CreateAgentID = System.label.PRM_Agent_Id;
        Timezone tz = Timezone.getTimeZone('America/Los_Angeles');
        genPayload.CreateDtm = DateTime.newInstance(System.Now().getTime() + tz.getOffset(System.Now()));
        genPayload.ChangeAgentID = System.label.PRM_Agent_Id;
        genPayload.ChangeDtm = DateTime.newInstance(System.Now().getTime() + tz.getOffset(System.Now()));
        genPayload.Website = website;
        payload += JSON.serialize(genPayload);
        
        }*/
        return payload;
    }
    
    public class OPIDRecommendation{
        public String accountId;
        public String cimId;
        public String groupingMethod;
        public String groupingValue;
        public String recommendationId;
        public string website;
    }
    
    public class GeneratePayload{
        public Integer RegistryId;
        public String RequestType;
        public String Status;
        public String CustomerApplicationSystemNm;
        public String ApplicationSystemCustomerId;
        public Integer PriorityNbr;
        public String RequesterId;
        public String MasterDataRecordID;
        public String PrimeCustomerRowId;
        public String CustomerAggregrationMethodType;
        public String LineOfBusiness;
        public String ErrorCd;
        public String ErrorDsc;
        public String ErrorDetailTxt;
        public String CreateAgentID;
        public DateTime CreateDtm;
        public String ChangeAgentID;
        public DateTime ChangeDtm;
        public string Website;
    } 
}