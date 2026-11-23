/*********************************************************************************************************************
Apex Class Name  : PRM_CDB_CompanyValidation_APICallout
Version       : 1.0
Created Date  : Oct 2025
Function      : Class to callout CDB Agent for Company Validation

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Saba                  15/10/2025               Created class to callout CDB Agent for Company Validation
*Shubhra                                         Added processWebsiteValidationRequest,makeCDBCallout,sendCDBPayload and 
related wrappers
*********************************************************************************************************************/

public class PRM_CDB_CompanyValidation_APICallout {
    public static Final String ORIGIN  = 'PRM_CDB_CompanyValidation_APICallout';
    public static Final String SEVERITY  = 'Error';
    public static Final String PROJECT  = 'IPA';
    public static final String SCOPE    = 'PRM_CDB_CompanyValidation_APICallout'; 
    
    public static void processWebsiteValidationRequest(List<PRM_Registration_Request__c> newRegRecords)
    {
        if (newRegRecords == null || newRegRecords.isEmpty()) { return; }
        
        system.debug('newRegRecords>>'+newRegRecords);
        
        Map<Id,CDBOutboundWrapper> newRegIdToCDBOutBndMap = new Map<Id,CDBOutboundWrapper>();
        Map<String,String> compKeyToJsonMap = new Map<String,String>();
        
        Map<Id,PRM_Registration_AI_Agent_Info__c> newRegIdToAgentInfoMap = new Map<Id,PRM_Registration_AI_Agent_Info__c>();
        
        String compositeKey='';
        String recordKey='' ;
        String errorMessage='';
        
        if(newRegRecords != null && !newRegRecords.isEmpty()){
            // Creating newRegAgentInfoWrap for each New Reg
            for(PRM_Registration_Request__c newRegRecord:[Select id,PRM_Email_ID__c, PRM_Account_Name__c, 
                                                          PRM_Account_URL__c, PRM_State_Province__c,PRM_City__c,PRM_Address_Line_1__c from PRM_Registration_Request__c where Id IN:newRegRecords])
            {
                // Build New Reg wrapper and outbound wrapper
                Map<String,object> newRegDetails = new Map<String,object>();
                newRegDetails = buildNewRegWrapper(newRegRecord);
                
                // Build outbound wrapper
                CDBOutboundWrapper newRegAgentInfoWrap = new CDBOutboundWrapper();
                newRegAgentInfoWrap.newRegAgentInfoDetails  = newRegDetails;
                
                // Build Agent Info
                PRM_Registration_AI_Agent_Info__c agentInfoRec = buildAgentInfoRecord(newRegRecord.Id);
                
                newRegIdToAgentInfoMap.put(newRegRecord.Id, agentInfoRec);
                newRegIdToCDBOutBndMap.put(newRegRecord.Id, newRegAgentInfoWrap);
                
                System.debug('Prepared new Agent Info record for New Reg ' + newRegRecord.Id );
            }
        }
        
        if (!newRegIdToAgentInfoMap.isEmpty()) {
            List<PRM_Registration_AI_Agent_Info__c> newAgentInfoLst = new List<PRM_Registration_AI_Agent_Info__c>();
            List<id> newRegIdLst = new List<id>();
            newAgentInfoLst.addAll(newRegIdToAgentInfoMap.values());
            newRegIdLst.addAll(newRegIdToAgentInfoMap.keySet());
            
            System.debug('Inserting new agent info record for ' + newAgentInfoLst.size() + ' new reg');
            Database.SaveResult[] results = Database.insert(newAgentInfoLst, false);
            
            // Process only successful inserts to build wrappers/json
            Map<String, String> newRegIdToBaseMessage = new Map<String, String>();
            for (Integer i = 0; i < results.size(); i++) {
                Id newRegId = newRegIdLst[i];
                Database.SaveResult result = results[i];
                
                if (result.isSuccess()) {
                    object agentInfoId = result.getId();
                    if (newRegIdToCDBOutBndMap.containsKey(newRegId)) {
                        CDBOutboundWrapper newRegAgentInfoWrap = newRegIdToCDBOutBndMap.get(newRegId);
                        newRegAgentInfoWrap.newRegAgentInfoDetails.put('PRM_Registration_AI_Agent_Info__c',agentInfoId);
                        //newRegAgentInfoWrap.PRM_Registration_AI_Agent_Info_c = agentInfoId;
                        String jsonPayload = JSON.serialize(newRegAgentInfoWrap.newRegAgentInfoDetails);
                        compositeKey = String.valueOf(newRegId) + '-' + String.valueOf(agentInfoId);
                        compKeyToJsonMap.put(compositeKey, jsonPayload);
                    }
                } else {
                    recordKey = String.valueOf(newRegId);
                    errorMessage = stringifyErrors(result.getErrors());
                    Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,SCOPE, SEVERITY, 'AI Agent Info insert failed for New Reg: '+ recordKey,
                                                       errorMessage, '', 'PRM_Registration_AI_Agent_Info__c','');
                }
            }
            
        }
        
        System.debug('Print final map:'+compKeyToJsonMap);
        if(!compKeyToJsonMap.isEmpty())
        {
            makeCDBCallout(compKeyToJsonMap);
        }
        
    }
    @future(callout=true)
    public static void makeCDBCallout( Map<String, String> compositeKeyToJsonMap)
    {
        try {
            List<Core_CDB_Integration_Log__c> insertCDBLogList = new List<Core_CDB_Integration_Log__c>();
            
            // Process each payload
            for (String compositeKey : compositeKeyToJsonMap.keySet()) {
                String payload = compositeKeyToJsonMap.get(compositeKey);
                
                if (String.isBlank(payload)) { continue; }
                
                // Send payload to CDB
                system.debug('Payload for CDB>> '+payload);	
                HttpResponse res = sendCDBPayload(payload);
                String statusCode=(res != null) ? String.valueOf(res.getStatusCode()) : '';
                
                Boolean isSuccess = (res != null && (statusCode == '200')) ? true : false;
                
                Integer newRetryCounter = 0;
                
                // Create log record
                Core_CDB_Integration_Log__c logRec = new Core_CDB_Integration_Log__c();
                logRec.Core_Integration_Type__c = 'IPA AI Agent Info ';
                logRec.Core_Record_Id__c = compositeKey;
                logRec.Core_Log_Status_Nm__c = isSuccess ? 'Successful' : 'Failed';
                logRec.Core_Retry_Number_Nbr__c = newRetryCounter;
                logRec.Core_Status_Code__c = statusCode;
                logRec.Core_Status_Message__c = (res != null) ? res.getStatus() : '';
                insertCDBLogList.add(logRec);
                System.debug('added CDB Log for Upsert:'+logRec);
            }
            
            // Insert log records 
            if (!insertCDBLogList.isEmpty()) {
                
                PRM_DMLUtility.doinsert(insertCDBLogList,'Core_CDB_Integration_Log__c', 'PRM_CDB_CompanyValidation_APICallout.makeCDBCallout'); 
            }
        } catch (Exception exp) {
            Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY,'', exp.getMessage() ,'' ,'PRM_CDB_CompanyValidation_APICallout' ,'' ,exp);  
            System.debug('Exception in PRM_CDB_CompanyValidation_APICallout.makeCDBCallout: ' + exp);
        }
    }
    
    public static HttpResponse sendCDBPayload(String payload)
    {
        try{
            system.debug('Payload for CDB>> '+payload);
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:PRM_CDB_Website_Validation');
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');
            req.setBody(payload);
            HttpResponse response = new Http().send(req);
            system.debug('response body and status code'+response.getBody()+''+response.getStatusCode());
            
            return response;
            
        }catch(Exception exp){
            Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY,'', exp.getMessage() ,'' ,'PRM_CDB_CompanyValidation_APICallout' ,'' ,exp);  
            System.debug('Exception while sending payloads to CDB for Company Validation :'+exp);
            return null;
        }
        
    }
    
    private static Map<String,object> buildNewRegWrapper(PRM_Registration_Request__c reg) {
        /* NewRegWrapper wrap = new NewRegWrapper();
wrap.PRM_Registration_Request_c = reg.Id;
wrap.PRM_Email_ID_c = reg.PRM_Email_ID__c;
wrap.PRM_Account_Name_c = reg.PRM_Account_Name__c;
wrap.PRM_Account_URL_c = reg.PRM_Account_URL__c;
wrap.PRM_Address_Line_1_c = reg.PRM_Address_Line_1__c;
wrap.PRM_City_c = reg.PRM_City__c;
wrap.PRM_State_Province_c = reg.PRM_State_Province__c;*/
        Map<String, object> newRegDetails = new Map<String, object>();
        newRegDetails.put('PRM_Registration_Request__c', reg.Id);
        newRegDetails.put('PRM_Email_ID__c', reg.PRM_Email_ID__c);
        newRegDetails.put('PRM_Account_Name__c', reg.PRM_Account_Name__c);
        newRegDetails.put('PRM_Account_URL__c', reg.PRM_Account_URL__c);
        newRegDetails.put('PRM_Address_Line_1__c', reg.PRM_Address_Line_1__c);
        newRegDetails.put('PRM_City__c', reg.PRM_City__c);
        newRegDetails.put('PRM_State_Province__c', reg.PRM_State_Province__c);
        
        return newRegDetails;
    }
    
    private static PRM_Registration_AI_Agent_Info__c buildAgentInfoRecord(Id newRegId) {
        PRM_Registration_AI_Agent_Info__c aiInfoRec = new PRM_Registration_AI_Agent_Info__c();
        aiInfoRec.PRM_Registration_Request__c = newRegId;
        aiInfoRec.PRM_Status__c = 'In Progress';
        return aiInfoRec;
    }
    
    public static String stringifyErrors(List<Database.Error> errs) {
        if (errs == null || errs.isEmpty()) return '';
        List<String> parts = new List<String>();
        for (Database.Error e : errs) {
            parts.add(String.valueOf(e.getStatusCode()) + '[' + String.valueOf(e.getFields()) + ']: ' + String.valueOf(e.getMessage()));
        }
        return String.join(parts, ' | ');
    }
    @InvocableMethod(label='Re_Validate_Company_Details_Callout_to_CDB')
    public static void reValidateCompanyDetails(List<FlowInputs> newRegRecordFromFlow)
    {
        try{ 
            processWebsiteValidationRequest(newRegRecordFromFlow[0].reValidateNewReg);
        }catch(Exception ex){
            Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, SCOPE, SEVERITY,'', ex.getMessage() ,'' ,'PRM_CDB_CompanyValidation_APICallout' ,'' ,ex);   
            System.debug('Exception in processWebsiteValidationRequest -flow:'+ex);
        }
        
    }
    /*   public class NewRegWrapper
{
public String PRM_Registration_Request_c;
public String PRM_Email_ID_c;
public String PRM_Account_Name_c;
public String PRM_Account_URL_c;
public String PRM_Address_Line_1_c;
public String PRM_City_c;
public string PRM_State_Province_c;

}*/
    
    public class CDBOutboundWrapper {
        //  public Id PRM_Registration_AI_Agent_Info_c;
        Map<String, object> newRegAgentInfoDetails;
        
    }
    //Stores input received from Flow
    public class FlowInputs{
        @InvocableVariable public List<PRM_Registration_Request__c> reValidateNewReg;
    }
    
}