public without sharing class PRM_AccChange_ResponseParser {

    public class ResponseData {
        @InvocableVariable
        public String jsonData;
    }

    public class OutputData {
        @InvocableVariable
        public String recordType;
        
        @InvocableVariable
        public Id accID;

        @InvocableVariable
        public Integer unifiedID;
    }

    @InvocableMethod(label='Parse ACM Account Change Event JSON Content' description='Parse JSON data and return RecordType,AccountId and UnifiedId values') 
    public static List<OutputData> parseJson(List<ResponseData> responseDataList) {
        String logEntryMsg='';
        List<OutputData> outputDataList = new List<OutputData>();
        try {
            for (ResponseData responseData : responseDataList) {
            // Parse JSON data
            Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(responseData.jsonData);           
            // Extract field values
            String recordType = (String) parsedData.get('RecordType');   
            String accountID = (String) parsedData.get('AccountId'); 
            String uID = (String) parsedData.get('BusinessPartyIdentifier'); 

            Integer unifiedID = Integer.valueOf(uID);
            Id accID = Id.valueOf(accountID);

            //set field values
            OutputData outputData = new OutputData();
            outputData.recordType = recordType;
            outputData.accID = accID;
            outputData.unifiedID = unifiedID;         
            outputDataList.add(outputData);
            }
            return outputDataList;
        }
        catch(Exception ex) {
            logEntryMsg+=ex.getMessage();
            outputDataList.add(new OutputData());
        return outputDataList;
        } finally {
            Core_Log_Entry.logEntryWithDetails('PRM_AccChange_ResponseParser', 'IPA','PRM_AccChange_ResponseParser','Medium', 'parseJsonfromEvent',logEntryMsg , '', '', '');
        }

    }
}