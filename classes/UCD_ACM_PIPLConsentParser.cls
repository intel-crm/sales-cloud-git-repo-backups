public without sharing class UCD_ACM_PIPLConsentParser {
 
    public class RequestData {
        @InvocableVariable
        public String jsonData;
    }

    public class OutputData {
        @InvocableVariable
        public String emailId;
        @InvocableVariable
        public Datetime cnsntDate;
        @InvocableVariable
        public String cnsntCode;
    }

    @InvocableMethod(label='Parse PIPL JSON Content' description='Parse JSON data and return EmailId, Consent code and Cnsnt_Date values')
    public static List<OutputData> parseJson(List<RequestData> requestDataList) {
        List<OutputData> outputDataList = new List<OutputData>();
        try{
        for (RequestData requestData : requestDataList) {
            // Parse JSON data
            Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(requestData.jsonData);           
            // Extract specific field values
            String emailId = (String) parsedData.get('EmailId');   
            String cnsntCode = null;
            Datetime consentDate=null;
            if(parsedData.containsKey('Data')){     
            List<Object> dataList = (List<Object>) parsedData.get('Data');           
            if (dataList != null && !dataList.isEmpty()) {
                Map<String, Object> dataMap = (Map<String, Object>) dataList[0];
                String strDateTime = (String)dataMap.get('Cnsnt_Date');     
                if(strDateTime!=null){       
                consentDate=convertDatetimeStringToDatetime(strDateTime);
                }
                cnsntCode = (String) dataMap.get('Cnsnt_Cd');
                
            }
        }
            // Create an OutputData instance and set field values
            OutputData outputData = new OutputData();
            outputData.emailId = emailId;
            outputData.cnsntDate = consentDate;
            outputData.cnsntCode = cnsntCode;            
            outputDataList.add(outputData);
        }
        return outputDataList;
    }
    catch(Exception ex) {
        UCD_ACM_Logger.error('UCD_ACM_PIPLConsentParser','parseJson','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        outputDataList.add(new OutputData());
        return outputDataList;
    } finally {
        UCD_ACM_Logger.setLogDetails();   
    }
    }

    // Helper method to convert the ERPM/Eloqua style datetime string (e.g. '2024-05-24 16:41:30.000') to datetime
    public static Datetime convertDatetimeStringToDatetime(String datetimeString) {
        Integer year  = Integer.valueOf(datetimeString.split('-')[0].right(4));
        Integer month = Integer.valueOf(datetimeString.split('-')[1]);
        Integer day   = Integer.valueOf(datetimeString.split('-')[2].left(2));
        Integer hour  = Integer.valueOf(datetimeString.split(':')[0].right(2));
        Integer minute= Integer.valueOf(datetimeString.split(':')[1]);
        Integer second= Integer.valueOf(datetimeString.split(':')[2].left(2));

        Datetime convertedDatetime = null;
        try {
            convertedDatetime = Datetime.newInstanceGmt(year, month, day, hour, minute, second);
        }
        catch (Exception ex) {
            UCD_ACM_Logger.error('UCD_ACM_PIPLConsentParser','convertDatetimeStringToDatetime','Message: '+ex.getMessage()+'. StackTrace: '+ex.getStackTraceString(),NULL);
        }
        finally {
            UCD_ACM_Logger.setLogDetails();
        }
        return convertedDatetime;        
    }

}