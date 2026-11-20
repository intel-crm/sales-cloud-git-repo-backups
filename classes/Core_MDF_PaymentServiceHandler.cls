/****************************************************************************************************************************************
* Class Name  : Core_MDF_PaymentServiceHandler 
* Version     : 1.0 
* Created Date: 31-01-2019
* Modification Log :
* Developer           HA          Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hamza Akhtar                   31-01-2019                    Created Core_MDF_PaymentServiceHandler class to update payment details based on the payment number
*****************************************************************************************************************************************/

public with sharing class Core_MDF_PaymentServiceHandler {
    
    //Check if map(id,payment) is empty or not
    /*public static Boolean isMapNotEmpty(Map<Id,Core_MDF_Payment__c> eMap) {
        return (eMap!=null && eMap.size()>0);
    }*/
    //Check if map(id,Core_Integration_Inbound_Message__c) is empty or not
    public static Boolean isMapNotEmpty(Map<Id,Core_Integration_Inbound_Message__c> eMap) {
        return (eMap!=null && eMap.size()>0);
    }

    //check if map(string,payment) is not empty
    public static Boolean isMapNotNull(Map<String, Core_MDF_Payment__c> strMap) {
        return (strMap != NULL && strMap.size() > 0);
    }

    //Check for changes in the record to prevent dummy update
    public static Boolean isPaymentRecUpdated(Core_MDF_Payment__c paymentRec, Core_MDF_Payment__c paymentRecord) {
        Boolean isUpdated = false;
        if(paymentRec != NULL && (paymentRecord.Core_MDF_EFT_Nbr__c != paymentRec.Core_MDF_EFT_Nbr__c || 
            paymentRecord.Core_MDF_Payment_Status_Txt__c != paymentRec.Core_MDF_Payment_Status_Txt__c || 
            paymentRecord.Core_MDF_Payment_Made_Dt__c != paymentRec.Core_MDF_Payment_Made_Dt__c)) {
                isUpdated = true;
            }
        return isUpdated;
    }

    //checking if the payment number is RMF or IPA or COGTM
    public static string checkIIMPayment(string paymentRefNo) {
        string paymentNo  = '';
        // if (string.isNotBlank(paymentRefNo) && paymentRefNo.contains('MDF') && (paymentRefNo.contains('RSA') || paymentRefNo.contains('IPA'))) {
        if (string.isNotBlank(paymentRefNo) && paymentRefNo.contains('MDF') &&
            (paymentRefNo.contains('RSA') || paymentRefNo.contains('IPA') || paymentRefNo.contains('COGTM'))) {
                paymentNo = getPaymentNFromIIMString(paymentRefNo);
        } else{
            paymentNo = paymentRefNo;
        }
        return paymentNo;
    }

    //check and update the IIM process status
    public static string checkProcessStatus(Integer errorCnt, string processStatus) {
        string updatedProcessStatus = '';
        if(errorCnt == 0 && 'Pending' == processStatus)
        {
            updatedProcessStatus = 'Successful';
        }
        else
        {
            updatedProcessStatus = 'Failed';
        }
        return updatedProcessStatus;
    }

    //update status on iim record: Map to update all the IIM records to Success
    public static void updateIIMRecords(Map<String,Integer> iimIdErrorCounterMap) {
        List<Core_Integration_Inbound_Message__c> ciimList = new List<Core_Integration_Inbound_Message__c>();
        string processStatus;
        for(Core_Integration_Inbound_Message__c ciim : [SELECT Id,Core_Processing_Status__c FROM 
                                                            Core_Integration_Inbound_Message__c WHERE Id IN :iimIdErrorCounterMap.keySet()]) {
            Integer errorCnt = 0;
            if(iimIdErrorCounterMap.containsKey(ciim.Id)) {
                errorCnt = iimIdErrorCounterMap.get(ciim.Id);
            }
            processStatus = ciim.Core_Processing_Status__c;
            ciim.Core_Processing_Status__c = checkProcessStatus(errorCnt,processStatus);
            ciimList.add(ciim);
        }
        if(ciimList.size() > 0) {
            update ciimList;
        }
    }

    //Get all the payment records based on the payment number
     /*****************************************************************************************************************************************
    Method Name: prepareJsonParserList
    @return    : PaymentJsonWrapper                                              
    @parameters: inboundMap
    Description: prepare payment json parser lists                                         
    Modified By: Accenture NB                  Date:   08-12-2023                   Changes: modularize huge method
    *****************************************************************************************************************************************/
    public static PaymentJsonWrapper prepareJsonParserList(Map<Id,Core_Integration_Inbound_Message__c> inboundMap) {
        PaymentJsonWrapper ptmWrapper =  new PaymentJsonWrapper();
        List<Core_MDF_PaymentJSONParser> jsonParsedList = new List<Core_MDF_PaymentJSONParser>();           
        Map<Id, List<Core_MDF_PaymentJSONParser>> iimIdJSONParsedListMap = new Map<Id, List<Core_MDF_PaymentJSONParser>>();
        Map<String,Integer> iimIdErrorCounterMap=new Map<String,Integer>();
        if(isMapNotEmpty(inboundMap)) {
            for(Core_Integration_Inbound_Message__c ciim : inboundMap.values()){
                //Check if there are any errors while processing these IIM records for Payments
            Integer errorCnt = 0;
                //Replaces ':null' with ':""' in the payload
                String payLoad = ciim.Core_Payload__c;
                String ignoreNull = payLoad.replaceAll(':null', ':""');
                ignoreNull = ignoreNull.replaceAll(':Null', ':""');
                ignoreNull = ignoreNull.replaceAll(':NULL', ':""');
                try {
                    //Calling the Core_MDF_PaymentJSONParser class
                    jsonParsedList.addAll(Core_MDF_PaymentJSONParser.parse(ignoreNull));
                    iimIdJSONParsedListMap.put(ciim.Id, Core_MDF_PaymentJSONParser.parse(ignoreNull));
                }
                catch(Exception e) {
                    errorCnt++;
                    String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);
                    Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_Payment_OriginName);
                }
                iimIdErrorCounterMap.put(ciim.Id, errorCnt);
            }
            ptmWrapper.jsonParsedList = jsonParsedList;
            ptmWrapper.iimIdJSONParsedListMap = iimIdJSONParsedListMap;
            ptmWrapper.iimIdErrorCounterMap = iimIdErrorCounterMap;
        }
        return ptmWrapper;
    }

    //prepare errorCount map
    public static Map<String,Integer> prepareErrorCounterMap(Map<String,Integer> errorCounterMap,Map<String,Id> paymentNoStrIIMIdMap,String paymentNoStr) {
        Map<String,Integer> iimIdErrorCounterMap = new Map<String,Integer>();
        iimIdErrorCounterMap.putAll(errorCounterMap);
        if(iimIdErrorCounterMap.containsKey(paymentNoStrIIMIdMap.get(paymentNoStr))) {
            Integer tempErrorCount = iimIdErrorCounterMap.get(paymentNoStrIIMIdMap.get(paymentNoStr)); 
            iimIdErrorCounterMap.put(paymentNoStrIIMIdMap.get(paymentNoStr), tempErrorCount);
        }
        else {
           iimIdErrorCounterMap.put(paymentNoStrIIMIdMap.get(paymentNoStr), 1); 
        }
        return iimIdErrorCounterMap;
    }


    /*****************************************************************************************************************************************
    Method Name: updatePaymentRecords
    @return    : PaymentWrapper                                              
    @parameters: inboundMap
    Description: Updating the Payment records based on payment number from IIM                                            
    Added By   : Hamza Akhtar  -  31-01-2019
    Modified By:                  Date:                      Changes: 
    *****************************************************************************************************************************************/
    public static void updatePaymentRecords(Map<Id,Core_Integration_Inbound_Message__c> inboundMap) {
        Integer eftCharLimit = Core_MDF_CCP_ConstantClass.EFT_Char_Limit;
        //Checks whether the trigger is Active
        if (TriggerHandler.isActive('Core_MDF_UpdatePaymentRecordsFromIIM')) {
            List<Core_MDF_PaymentJSONParser> jsonParsedList = new List<Core_MDF_PaymentJSONParser>();           
            Map<Id, List<Core_MDF_PaymentJSONParser>> iimIdJSONParsedListMap = new Map<Id, List<Core_MDF_PaymentJSONParser>>();           
            //Creates a new instance of the Map class. String is the data type of keys and the values is Custom Object.
            Map<String, Core_MDF_Payment__c> paymentNoIdPaymentMap = new Map<String, Core_MDF_Payment__c>();           
            //Creates a new instance of the Map class. String is the data type of keys and the values is Custom Object.
            Map<String, Core_MDF_Payment__c> paymentNoIdPaymentMapToBeInserted = new Map<String, Core_MDF_Payment__c>();            
            //Create set to add all updated paymentIds
            Set<Id> paymentIdSet = new Set<Id>();            
            //Map to update all the IIM records to Success
            Map<String,Integer> iimIdErrorCounterMap=new Map<String,Integer>();
            Map<String,Id> paymentNoStrIIMIdMap = new Map<String,Id>();
            String paymentNoStr = '';
            PaymentJsonWrapper ptmWrapper =  prepareJsonParserList(inboundMap);
            jsonParsedList = ptmWrapper.jsonParsedList;
            iimIdJSONParsedListMap = ptmWrapper.iimIdJSONParsedListMap;
            iimIdErrorCounterMap = ptmWrapper.iimIdErrorCounterMap;
            //Check if there are any errors while processing these IIM records for Payments
            //Integer errorCnt = 0;
            try{
                for(Id iimId : iimIdJSONParsedListMap.keySet()) {
                    for(Core_MDF_PaymentJSONParser jsonParsed : iimIdJSONParsedListMap.get(iimId)) {
                        if((Label.Core_MDF_Payment_Status_IIM).equalsIgnoreCase(jsonParsed.core_MDF_Payment_Status_Txt.trim())) {//from IIM, it will come as PAID
                            //Calling the getConvertDate method to get the correct Date format
                            Date formattedDate = getConvertDate(jsonParsed.core_MDF_Payment_Made_Dt.trim());                        
                            //Creating new payment record and assigning the JSON parsed value to the Payment fields
                            Core_MDF_Payment__c paymentRecord = new Core_MDF_Payment__c();
                            String eftNo = jsonParsed.core_MDF_EFT_Nbr.trim();
                            paymentRecord.Core_MDF_EFT_Nbr__c = (eftNo.length()<=eftCharLimit) ? eftNo : eftNo.substring(0, eftCharLimit-1);
                            paymentRecord.Core_MDF_Payment_Status_Txt__c = Label.Core_MDF_Payment_Status_IIM;
                            if(formattedDate != null) {
                              paymentRecord.Core_MDF_Payment_Made_Dt__c = formattedDate;
                            }
                            // Get payment number
                            string paymentRefNo = jsonParsed.core_MDF_Payment_No_Txt.trim().toUpperCase();
                            string paymentNo  = checkIIMPayment(paymentRefNo);                            
                            paymentNoIdPaymentMap.put(paymentNo,paymentRecord);
                            paymentNoStrIIMIdMap.put(jsonParsed.core_MDF_Payment_No_Txt.trim(), iimId);
                            paymentNoStr = jsonParsed.core_MDF_Payment_No_Txt.trim();
                        }                    
                    }
                }
                //updatePymtAndClaim(paymentNoIdPaymentMap)
                //Get all the payment records based on the payment number
                if(isMapNotNull(paymentNoIdPaymentMap)) {
                    for(Core_MDF_Payment__c paymentRecord : [SELECT Id, Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c, Core_MDF_Payment_Status_Txt__c FROM 
                                                            Core_MDF_Payment__c WHERE Core_MDF_Payment_No_Txt__c IN : paymentNoIdPaymentMap.keySet() AND 
                                                                   Core_MDF_Payment_Status_Txt__c = : label.Core_MDF_Payment_Status LIMIT 50000]) {
                        Core_MDF_Payment__c paymentRec = paymentNoIdPaymentMap.get(paymentRecord.Core_MDF_Payment_No_Txt__c.toUpperCase());
                        //Check for changes in the record to prevent dummy update                                        
                        if(isPaymentRecUpdated(paymentRec,paymentRecord)) { 
                           paymentRec.Id = paymentRecord.Id;
                           paymentIdSet.add(paymentRec.Id);    
                           paymentNoIdPaymentMapToBeInserted.put(paymentRecord.Core_MDF_Payment_No_Txt__c,paymentRec);
                           paymentNoStr = paymentRecord.Core_MDF_Payment_No_Txt__c;
                        }
                    }
                }
                paymentNoIdPaymentMap = NULL;
                if(isMapNotNull(paymentNoIdPaymentMapToBeInserted)) {
                    Database.update(paymentNoIdPaymentMapToBeInserted.values(), false);
                    Database.executeBatch(new Core_MDF_SendPaidPaymentEmailToAdmin(paymentIdSet),Integer.valueOf(Label.Core_MDF_BatchSize));
                }
            }
            catch(Exception e) {   
                iimIdErrorCounterMap = prepareErrorCounterMap(iimIdErrorCounterMap,paymentNoStrIIMIdMap,paymentNoStr);
                String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);
                Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_Payment_OriginName);              
            }
            finally {
                updateIIMRecords(iimIdErrorCounterMap);
            }
        }
    }
    private static string getPaymentNFromIIMString(String paymentNo){
        List<String> payNoSplits = paymentNo.split('/');
    // Retail MDF program type format Example - Q420/MDF/RSA000123-APJ
        if (payNoSplits.size() > 2 && payNoSplits[2].contains('RSA') && payNoSplits[1].contains('MDF')) { 
            return payNoSplits[2].substring(3, 9) + ' - ' + 'RMF' + ' - ' + payNoSplits[1];
        }
    	// IPA program type format Example - Q420/MDF/IPA000123-APJ
        else if(payNoSplits.size() == 3 && payNoSplits[2].contains('IPA') && payNoSplits[1].contains('MDF')) 
        {
            return payNoSplits[2].substring(3, 9) + ' - ' + 'IPA';
        }
        // COGTM program: CSAR Cash type format Example: CSAR:120381 Q425/MDF/COGTM272117
        else if(payNoSplits.size() == 3 && payNoSplits[2].contains('COGTM') && payNoSplits[1].contains('MDF')) 
        {
            return payNoSplits[2].substring(5, 11) + ' - ' + 'COGTM';
        }
        else if(payNoSplits.size() == 4 && payNoSplits[3].contains('IPA') && payNoSplits[2].contains('MDF')) 
        { 
            return payNoSplits[3].substring(3, 9) + ' - ' + 'IPA';        
        }
        // COGTM program: CSAR Credit type format Example: CSAR#1293454/1 Q425/MDF/COGTM272117
        else if(payNoSplits.size() == 4 && payNoSplits[3].contains('COGTM') && payNoSplits[2].contains('MDF')) 
        { 
            return payNoSplits[3].substring(5, 11) + ' - ' + 'COGTM';       
        }
        else{
            return paymentNo;
        }        
    }
    /*****************************************************************************************************************************************
    Method Name:   getConvertDate                                          
    @return    :   Date                                            
    @parameters:   dateFormatChange
    Description:   Parsing the date which is coming from Json as a string in different format.                                        
    Added By   :   Hamza Akhtar  -  31-01-2019
    Modified By:                  Date:                      Changes: 
    *****************************************************************************************************************************************/   
    public static Date getConvertDate(String dateFormatChange)
    {
    Date convertedDate;
        if(dateFormatChange.contains('/')){
            List<String> dateDivided = dateFormatChange.split('/');
            if(dateDivided.size() > 2) {
                String month = dateDivided.get(0);
                String day = dateDivided.get(1);
                String year = dateDivided.get(2);
                String stringDate =  year + '-' + month + '-' + day;
                convertedDate = Date.valueOf(stringDate);
            }
        }
        else if(dateFormatChange.contains('-')){
            Map<String,String> mapMonthList = new Map<String,String>();
            mapMonthList.put('JAN','01');
            mapMonthList.put('FEB','02');
            mapMonthList.put('MAR','03');
            mapMonthList.put('APR','04');
            mapMonthList.put('MAY','05');
            mapMonthList.put('JUN','06');
            mapMonthList.put('JUL','07');
            mapMonthList.put('AUG','08');
            mapMonthList.put('SEP','09');
            mapMonthList.put('OCT','10');
            mapMonthList.put('NOV','11');
            mapMonthList.put('DEC','12');
            
            List<String> dateDivided = dateFormatChange.split('-');
            if(dateDivided.size() > 2) {
                String day = dateDivided.get(0);
                String month = mapMonthList.get(dateDivided.get(1).toUpperCase());
                String year = dateDivided.get(2);
                String stringDate = year + '-' + month + '-' + day;
                convertedDate = Date.valueOf(stringDate);
            }
        }
        return convertedDate;
    }

    public class PaymentJsonWrapper{
        List<Core_MDF_PaymentJSONParser> jsonParsedList;          
        Map<Id, List<Core_MDF_PaymentJSONParser>> iimIdJSONParsedListMap;
        Map<String,Integer> iimIdErrorCounterMap;
    }
}