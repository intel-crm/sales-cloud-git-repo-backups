/****************************************************************************************************************************************
* Class Name  : Core_MDF_PaymentServiceHandler 
* Version     : 1.0 
* Created Date: 31-01-2019
* Modification Log :
* Developer           HA          Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Hamza Akhtar                   31-01-2019                    Created Core_MDF_PaymentServiceHandler class to update payment details based on the payment number
*****************************************************************************************************************************************/

public with sharing class Core_MDF_PaymentServiceHandler{
    
    /*****************************************************************************************************************************************
    Method Name: updatePaymentRecords
    @return    :                                               
    @parameters: inboundMap
    Description: Updating the Payment records based on payment number from IIM                                            
    Added By   : Hamza Akhtar  -  31-01-2019
    Modified By:                  Date:                      Changes: 
    *****************************************************************************************************************************************/
    public static void updatePaymentRecords(Map<Id,Core_Integration_Inbound_Message__c> inboundMap){
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
            //Check if there are any errors while processing these IIM records for Payments
            Integer errorCnt = 0;
            String paymentNoStr = '';
            if(inboundMap.size() > 0){
                for(Core_Integration_Inbound_Message__c ciim : inboundMap.values()){
                    //Replaces ':null' with ':""' in the payload
                    String payLoad = ciim.Core_Payload__c;
                    String ignoreNull = payLoad.replaceAll(':null', ':""');
                    ignoreNull = ignoreNull.replaceAll(':Null', ':""');
                    ignoreNull = ignoreNull.replaceAll(':NULL', ':""');
                    try{
                        //Calling the Core_MDF_PaymentJSONParser class
                        jsonParsedList.addAll(Core_MDF_PaymentJSONParser.parse(ignoreNull));
                        iimIdJSONParsedListMap.put(ciim.Id, Core_MDF_PaymentJSONParser.parse(ignoreNull));
                    }catch(Exception e){errorCnt++;String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_Payment_OriginName);
                                       }
                    iimIdErrorCounterMap.put(ciim.Id, errorCnt);
                }
            }
            try{
                for(Id iimId : iimIdJSONParsedListMap.keySet()){
                    for(Core_MDF_PaymentJSONParser jsonParsed : iimIdJSONParsedListMap.get(iimId)){
                        if((Label.Core_MDF_Payment_Status_IIM).equalsIgnoreCase(jsonParsed.core_MDF_Payment_Status_Txt.trim())){//from IIM, it will come as PAID
                            //Calling the getConvertDate method to get the correct Date format
                            Date formattedDate = getConvertDate(jsonParsed.core_MDF_Payment_Made_Dt.trim());                        
                            //Creating new payment record and assigning the JSON parsed value to the Payment fields
                            Core_MDF_Payment__c paymentRecord = new Core_MDF_Payment__c();
                            paymentRecord.Core_MDF_EFT_Nbr__c = jsonParsed.core_MDF_EFT_Nbr.trim();
                            paymentRecord.Core_MDF_Payment_Status_Txt__c = Label.Core_MDF_Payment_Status_IIM;
                            paymentRecord.Core_MDF_Payment_Made_Dt__c = formattedDate;
                            paymentNoIdPaymentMap.put((jsonParsed.core_MDF_Payment_No_Txt.trim()).toUpperCase(),paymentRecord);
                            paymentNoStrIIMIdMap.put(jsonParsed.core_MDF_Payment_No_Txt.trim(), iimId);
                            paymentNoStr = jsonParsed.core_MDF_Payment_No_Txt.trim();
                        }                    
                    }
                }
                //Get all the payment records based on the payment number
                if(paymentNoIdPaymentMap.size() > 0){
                    for(Core_MDF_Payment__c paymentRecord : [SELECT Id, Core_MDF_Payment_No_Txt__c, Core_MDF_EFT_Nbr__c, Core_MDF_Payment_Made_Dt__c,
                                                                    Core_MDF_Payment_Status_Txt__c
                                                             FROM Core_MDF_Payment__c
                                                             WHERE Core_MDF_Payment_No_Txt__c IN : paymentNoIdPaymentMap.keySet() AND 
                                                                   Core_MDF_Payment_Status_Txt__c = : label.Core_MDF_Payment_Status LIMIT 50000]){
                        Core_MDF_Payment__c paymentRec = paymentNoIdPaymentMap.get(paymentRecord.Core_MDF_Payment_No_Txt__c);
                        //Check for changes in the record to prevent dummy update                                         
                        if(paymentRec != NULL && 
                           (paymentRecord.Core_MDF_EFT_Nbr__c != paymentRec.Core_MDF_EFT_Nbr__c || 
                           paymentRecord.Core_MDF_Payment_Status_Txt__c != paymentRec.Core_MDF_Payment_Status_Txt__c || 
                           paymentRecord.Core_MDF_Payment_Made_Dt__c != paymentRec.Core_MDF_Payment_Made_Dt__c)){
                           paymentRec.Id = paymentRecord.Id;
                           paymentIdSet.add(paymentRec.Id);    
                           paymentNoIdPaymentMapToBeInserted.put(paymentRecord.Core_MDF_Payment_No_Txt__c,paymentRec);
                           paymentNoStr = paymentRecord.Core_MDF_Payment_No_Txt__c;
                        }
                    }
                }
                paymentNoIdPaymentMap = NULL;
                if(paymentNoIdPaymentMapToBeInserted.size() > 0){
                    Database.update(paymentNoIdPaymentMapToBeInserted.values(), false);
                    Id batchJobId = Database.executeBatch(new Core_MDF_SendPaidPaymentEmailToAdmin(paymentIdSet),Integer.valueOf(Label.Core_MDF_BatchSize));
                }
            }
            catch(Exception e)
            {   errorCnt++;
                String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e);Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errorDetails,Label.Core_MDF_Payment_OriginName);
            	iimIdErrorCounterMap.put(paymentNoStrIIMIdMap.get(paymentNoStr), errorCnt);
            }
            finally
            {
                List<Core_Integration_Inbound_Message__c> ciimList = new List<Core_Integration_Inbound_Message__c>();
                for(Core_Integration_Inbound_Message__c ciim : [SELECT Id,Core_Processing_Status__c FROM 
                                                                 Core_Integration_Inbound_Message__c WHERE Id IN :iimIdErrorCounterMap.keySet()]){
                    errorCnt = iimIdErrorCounterMap.get(ciim.Id);                                                                                    
                    if(errorCnt == 0 && 'Pending' == ciim.Core_Processing_Status__c)
                    {
                        ciim.Core_Processing_Status__c = 'Successful';
                    }
                    else
                    {
                        ciim.Core_Processing_Status__c = 'Failed';
                    }
                    ciimList.add(ciim);
                }
                if(ciimList.size() > 0){
                    update ciimList;
                }
            }
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
        String day = dateDivided.get(0);
        String month = mapMonthList.get(dateDivided.get(1).toUpperCase());
        String year = dateDivided.get(2);
        String stringDate = year + '-' + month + '-' + day;
        return Date.valueOf(stringDate);
    }  
}