/*********************************************************************************************************************
Class Name    : Sales_SapIntegrationUtility
Version       : 1.0
Created Date  : Feb 2021
Function      : This is controller class of Sales_SAPIntegration.cmp and Sales_SAPIntegrationRecall.cmp
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           09-Feb-2021              US862545:Order submission from SFDC to SAP via new Integration
* Srishty Sharma           18-Feb-2021              US862553: Implementation of US870456 : Retry mechanism for failed Orders from SFDC to SAP via new Integration
* *********************************************************************************************************************/
public with sharing class Sales_SapIntegrationUtility {
    private static final string ORIGIN = 'Sales_SapIntegrationUtility';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'Sales';
    private static String accessToken;
    private static Integer levelOne=1;
    private static Integer levelTwo=2;
    private static Integer levelThree=3;
    private static final String SALES_STATUS_SUBMITTED = 'Order created successfully';
    //private static final String SALES_STATUS_DRAFT_ORDER = 'Draft Order';--Unused
    private static final String STATUS_ACTIVATED = 'Activated';
    //private static final String STATUS_DRAFT = 'Draft';--Unused
    //private static final String STATUS_ACKNOWLEDGED = 'Acknowledged';--Unused
    private static final String ORDER_TYPE_NON_COMMERCIAL = 'Non Commercial Order';
    private static final String SALES_ORDER_SUBTYPE_CORPORATE = 'Corporate Order';
    private static final String LICENSE_TOOL_TYPE_CORPORATE = 'CORPORATE';
    private static final String LICENSE_OPTIONAL='Optional';
    private static final String LICENSE_CANCELLED='Cancelled';
    private static final String SALES_STATUS_CREATION_FAILED = 'SAP Order Creation Failed';
    private static final String STATUS_ORDER_CANCELLED_BY_SAP='Order Cancelled by SAP';
    private static final String STATUS_ORDER_CANCELLED='Order Cancelled';
    private static final String SALES_STATUS_RESUBMISSION = 'SAP Resubmission In Progress';
    private static final String SAP_CREATE_ORDER_ENDPOINT = 'callout:Sales_Order_SAP_Integration';
    //private static final String SAP_RECALL_ORDER_ENDPOINT = 'callout:Sales_Order_SAP_Integration/';--	Unused
    private static final String HTTP_POST = 'POST';
    private static final String HTTP_DELETE = 'DELETE';
    private static final String JOB_PREFIX = 'RetryOrderCreationBatch@';
    private static final String RETRY_MASTER_COUNT = 'Resubmit_to_SAP_Count';
    private static final String RETRY_RESUBMISSION_MASTER_COUNT = 'Resubmission_Time_Interval';
    private static final String RETRY_RESUBMISSION_BATCH_SIZE = 'Batch_Size';
    private static final String RETRY_FAILED_STRING='SAP Order Creation Failed on retry ';
    //private static final String RESPONSE_KEY_ORDERRESPONSE='OrderResponse';--Unused
    //private static final String RESPONSE_KEY_COMMENTS='Comments';--Unused
    //private static final String RESPONSE_KEY_COMMENT='comment';--Unused
    //private static final String RESPONSE_KEY_ORDERNUMBER='OrderNumber';--Unused
    //private static final String RESPONSE_KEY_STATUS='Status';Unused
    private static final String SUCCESS='Success';
    private static final String DUPLICATE='Duplicate';
    private static final String BEARER='Bearer ';
    private static final String DEF_TOKEN_ENDPOINT = 'callout:Order_SAP_Integration_Token';
    private static Map<String, Sales_Order_SAP_Integration_Mapping__mdt> firstLevelFieldConfiMapping;
    private static Map<String, Sales_Order_SAP_Integration_Mapping__mdt> secondLevelFieldConfiMapping;
    private static Map<String, Sales_Order_SAP_Integration_Mapping__mdt> thirdLevelFieldConfiMapping;
    private static List<String> orderSfFields;
    private static List<String> sfFieldsOrderItem;
    private static List<String> sfFieldsLicense;
    private static Map<Id,List<OrderItem>> orderWithOrderItemMap;
    private static Map<Id,List<OrderItem>> orderWithOrderItemMapWithCorporate;
    private static Map<Id,List<Sales_License__c>> licenseWithOrderProdMap;
    private static Map<Id,Boolean> corporateOrderMap;
    private static Map<Id,MetadataFieldConfigWrapper> orderWithExceptionMap = new  Map<Id,MetadataFieldConfigWrapper>();
    private static Map<String,String> lovSapMappingMap = new Map<String,String>();
    private static List<Sales_SAP_Token_Detail__c> connectSettingRecordList = new List<Sales_SAP_Token_Detail__c>();
    private static List<LogEntryWrapper> logEntriesToCreate = new List<LogEntryWrapper>();
    public static final String ORGWIDE_EMAIL='wsm-postmaster@intel.com';
    public static String ordNumber='';
    @AuraEnabled
    public static void verifyOrder(List<String> orderIds){
        List<Id> orderIdList = (List<Id>) orderIds;
        List<Order> orderVerifiedList =new List<Order>();
        String readonlyRecordId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Sales_Read_Only_Record').getRecordTypeId();
        //String activeRecordId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Sales_Order_Record').getRecordTypeId();--Unused
        for(Order orderVerified:[Select Id,Sales_Is_Verified__c,RecordTypeId,Sales_status__c,Type,Status from Order where Sales_status__c!=:STATUS_ORDER_CANCELLED and Id IN:orderIdList ]){
            if(orderVerified.Type==ORDER_TYPE_NON_COMMERCIAL && orderVerified.Status!=STATUS_ACTIVATED && !System.isBatch()){ 
                orderVerified.Status=STATUS_ACTIVATED;
                orderVerified.Sales_status__c=SALES_STATUS_SUBMITTED;
            }
            else if(orderVerified.Type!=ORDER_TYPE_NON_COMMERCIAL && orderVerified.Sales_status__c ==SALES_STATUS_SUBMITTED && orderVerified.Status==STATUS_ACTIVATED && !System.isBatch()){throw new AuraHandledException(System.Label.Sales_Submitted_SubmitSAPError);
                                                                                                                                                                                           }
            else if(orderVerified.Sales_status__c == SALES_STATUS_RESUBMISSION && !System.isBatch()){throw new AuraHandledException(System.Label.Sales_Resubmission_SubmitSAPError);
                                                                                                    }
            orderVerified.Sales_Is_Verified__c=true;
            orderVerified.RecordTypeId=readonlyRecordId;
            orderVerifiedList.add(orderVerified);
        }
        try{
            update orderVerifiedList; }
        catch(DmlException e){
            throw new AuraHandledException(e.getDmlMessage(0)); }
    }
    @AuraEnabled
    public static Boolean updateSapOrderStatus(List<String> orderIdList){
        List<Id> orderIdSet = (List<Id>) orderIdList;
        List<Database.SaveResult> saveResultList = new  List<Database.SaveResult>();
        List<Order> orderUpdateList = new List<Order>();
        Integer retryCountForSubmitToSap = getRetryMasterData(RETRY_MASTER_COUNT);
        MetadataFieldConfigWrapper metadataConfigWrapper = getLevelFieldConfiMapping();
        populateSapLovMapping();
        Map<Integer,Map<String, Sales_Order_SAP_Integration_Mapping__mdt>> fieldConfiMap = metadataConfigWrapper.levelFieldConfiMapping;
        Map<Integer,List<String>> sfFieldsConfig = metadataConfigWrapper.levelToSalesforceFields;
        firstLevelFieldConfiMapping = fieldConfiMap.get(levelOne);
        secondLevelFieldConfiMapping = fieldConfiMap.get(levelTwo);
        thirdLevelFieldConfiMapping = fieldConfiMap.get(levelThree);
        orderSfFields = sfFieldsConfig.get(levelOne);
        sfFieldsOrderItem = sfFieldsConfig.get(levelTwo);
        sfFieldsLicense = sfFieldsConfig.get(levelThree);
        Set<String> orderSfFieldsSet = new Set<String>{'Id', 'Sales_status__c','Sales_Sync_Comments_Txt__c','Sales_ERP_SO_Txt__c','SBQQ__Contracted__c','Sales_Retry_Count__c','Sales_Order_Sub_Type__c','Sales_ERP_Entry_Date_Dt__c'};
            orderSfFieldsSet.addAll(orderSfFields);
        orderSfFields.clear();
        orderSfFields.addAll(orderSfFieldsSet);
        String orderQuery = 'Select ' + String.join(orderSfFields, ', ') + ' from Order where Id IN:orderIdSet';        
        List<Order> orderList =  Database.query(orderQuery);
        populateMaps(orderList);
        Boolean makeCalloutForResubmission=true;
        Boolean throwException = false;
        String exceptionMessage='';
        for(Order order:orderList){
            if(!System.isBatch() && order.Sales_status__c==SALES_STATUS_RESUBMISSION){makeCalloutForResubmission=false;
                                                                                      ordNumber=order.OrderNumber;
                                                                                     }
            if(order.Sales_status__c !=SALES_STATUS_SUBMITTED && order.Type!=ORDER_TYPE_NON_COMMERCIAL && order.Status!=STATUS_ACTIVATED && makeCalloutForResubmission){
                HttpResponse response = Sales_SapIntegrationUtility.submitOrderToSAP(order);
                if(response!=null){
                    if(response.getStatusCode()==200){
                        String comment;
                        String orderNumber;
                        String status;
                        Date orderDate;
                        Date scheduledDate;
                        Type resultType = Type.forName('Sales_SapResponseWrapper');
                        Sales_SapResponseWrapper deserializedResponse = (Sales_SapResponseWrapper) JSON.deserialize(response.getBody(), resultType);
                        Sales_SapResponseWrapper.cls_OrderResponse orderResponse = deserializedResponse?.OrderResponse;
                        if(orderResponse!=null){
                            orderNumber = orderResponse.SAPOrderNum;
                            status = orderResponse.Status;
                            Integer sapDate = orderResponse.SAPOrderDate;
                            Integer sapscheduledDate = orderResponse.SAPScheduledDate;
                            if(sapDate!=null){
                                String sapDateString=String.valueOf(sapDate);
                                String sapDateInSfFormat = sapDateString.substring(0,4) + '-' + 
                                    sapDateString.substring(4,6) + '-' +
                                    sapDateString.substring(6,8);
                                orderDate = date.valueOf(sapDateInSfFormat);
                            }
                            if(sapscheduledDate!=null){
                                String sapSchedDateString=String.valueOf(sapscheduledDate);
                                String sapSchedDateInSfFormat = sapSchedDateString.substring(0,4) + '-' + 
                                    sapSchedDateString.substring(4,6) + '-' +
                                    sapSchedDateString.substring(6,8);
                                scheduledDate = date.valueOf(sapSchedDateInSfFormat);                           
                            }
                            System.JSONParser parser = JSON.createParser(response.getBody());
                            while (parser.nextToken() != null) {
                                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                                    (parser.getText() == 'comment')) {
                                        parser.nextToken();
                                        comment= comment+'\n'+parser.getText();
                                        comment=comment.remove('null');
                                    }
                            }
                        }
                        if(status!=null && (status.equalsIgnoreCase(SUCCESS) || status.equalsIgnoreCase(DUPLICATE))){
                            order.Sales_status__c = SALES_STATUS_SUBMITTED;  
                            order.Status=STATUS_ACTIVATED;
                        }
                        else{
                            order.Sales_Retry_Count__c = 0;
                            order.Sales_status__c=SALES_STATUS_CREATION_FAILED;
                            order.RecordTypeId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Sales_Order_Record').getRecordTypeId();
                            throwException=true;
                        }
                        if(status.equalsIgnoreCase(DUPLICATE)){
                            order.Sales_Sync_Comments_Txt__c=''; 
                        }
                        else{
                            order.Sales_Sync_Comments_Txt__c=comment!=null?comment:''; 
                        }
                        order.Sales_ERP_SO_Txt__c=orderNumber!=null?orderNumber:'';
                        if(orderDate!=null){
                            order.Sales_ERP_Entry_Date_Dt__c = orderDate;
                        }
                        if(scheduledDate!=null){
                            order.Sales_Sched_Date_Dt__c = scheduledDate;
                        }
                        orderUpdateList.add(order);
                    }
                    else{
                        throwException=true;
                        exceptionMessage=response.getBody();
                        order.Sales_Sync_Comments_Txt__c = order.Sales_Sync_Comments_Txt__c!=null? order.Sales_Sync_Comments_Txt__c+'\n'+System.Now().format()+'----'+RETRY_FAILED_STRING+order.Sales_Retry_Count__c+' with reason '+response.getBody():System.Now().format()+'----'+RETRY_FAILED_STRING+order.Sales_Retry_Count__c+' with reason '+response.getBody();
                        if(order.Sales_Retry_Count__c==retryCountForSubmitToSap){
                            order.Sales_status__c = SALES_STATUS_CREATION_FAILED;
                            order.Sales_Retry_Count__c=0;
                            order.RecordTypeId=Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Sales_Order_Record').getRecordTypeId();
                        }
                        else{
                            order.Sales_status__c = SALES_STATUS_RESUBMISSION;
                            if(order.Sales_Retry_Count__c==0){order.Sales_Retry_Count__c = order.Sales_Retry_Count__c+1;}
                        }
                        orderUpdateList.add(order);
                    }
                }
                else{
                    throwException=true;
                }
            }
            else if(order.Type==ORDER_TYPE_NON_COMMERCIAL && !System.isBatch()){
                //throw new AuraHandledException(System.Label.Sales_NonComm_SubmitSAPError);
                AuraHandledException e = new AuraHandledException(System.Label.Sales_NonComm_SubmitSAPError);
                e.setMessage(System.Label.Sales_NonComm_SubmitSAPError);
                system.debug('AuraHandledException is:' + e);
                throw e;
                }
            else if(order.Sales_status__c ==SALES_STATUS_SUBMITTED && order.Status==STATUS_ACTIVATED && !System.isBatch()){throw new AuraHandledException(System.Label.Sales_Submitted_SubmitSAPError);}
            else if(order.Sales_status__c == SALES_STATUS_RESUBMISSION && !System.isBatch()){throw new AuraHandledException(System.Label.Sales_Resubmission_SubmitSAPError);}
        }
        if(connectSettingRecordList.size()>0){
            upsert connectSettingRecordList;
        }
        if(logEntriesToCreate.size()>0){
            for(LogEntryWrapper logWrapper : logEntriesToCreate){
                Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, logWrapper.message,logWrapper.details, logWrapper.objectId,logWrapper.objectType, '');
            }
        }
        if(!orderWithExceptionMap.isEmpty()){updateOrderStatusToFailureForBatch(orderUpdateList);}
        if(orderUpdateList.size()>0){
            Map<Id,Order> orderUpdateMap = new Map<Id,Order>();
            orderUpdateMap.putAll(orderUpdateList);
            saveResultList = Database.update(orderUpdateMap.values(),false);
            for(Integer i=0;i<saveResultList.size();i++){
                if (!saveResultList.get(i).isSuccess()){ 
                    Database.Error error = saveResultList.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    orderUpdateList.get(i);
                    sendEmailOnExcpetion(String.valueOf(orderUpdateList.get(i).OrderNumber),failedDML);
                }
            }
            Sales_CreateLogRecords.createLogRecords(saveResultList,orderUpdateMap.values(),ORIGIN);
        }
        return throwException;
    }
    public static String getCancelReasonCode(String cancelReason){
        String cancelCode='';
        Schema.DescribeFieldResult fieldResult = Order.Sales_SAP_OrderCancelledReason__c.getDescribe(); 
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues(); 
        for( Schema.PicklistEntry v : values) {   
            if(v.getValue() == cancelReason){
                cancelCode =  v.getLabel();}
        }
        return cancelCode;} 
    @AuraEnabled
    public static Boolean updateOrderRecallStatus(Id orderId, String cancelReason){
        Boolean isSuccess= false;
        Order order = [Select id,status,OrderNumber,Type,Sales_Contract_Id__c,Sales_Cancelled_Quote_No__c,SBQQ__Quote__c,Sales_Cancelled_Reason_Dsc__c, Sales_SAP_OrderCancelledReason__c, Sales_status__c,Sales_ERP_SO_Txt__c,Sales_Sync_Comments_Txt__c,Sales_Order_Sub_Type__c from Order where Id=:orderId];   
        if((order.Sales_status__c==SALES_STATUS_SUBMITTED && order.Sales_ERP_SO_Txt__c!=null && cancelReason!=null) || (Test.isRunningTest())){  
            HttpResponse response = Sales_SapIntegrationUtility.recallOrderFromSAP(order, cancelReason);
            if(response.getStatusCode()==200){
                try{
                    Type resultType = Type.forName('Sales_SapResponseWrapper');
                    Sales_SapResponseWrapper deserializedResponse = (Sales_SapResponseWrapper) JSON.deserialize(response.getBody(), resultType);
                    order.Sales_Sync_Comments_Txt__c = deserializedResponse?.Message!=null?deserializedResponse.Message:'';
                    if(deserializedResponse?.Type=='Success'){
                        isSuccess = true;
                        order.Sales_Is_Recalled__c = true;
                        order.Sales_status__c = STATUS_ORDER_CANCELLED_BY_SAP;
                        String cancelRsn = getCancelReasonCode(cancelReason);
                        order.Sales_Cancelled_Reason_Dsc__c = cancelRsn;
                        order.Sales_SAP_OrderCancelledReason__c = cancelReason;
                        if(String.isEmpty(order.Sales_Cancelled_Quote_No__c)){
                            order.Sales_Cancelled_Quote_No__c = order.SBQQ__Quote__c;
                            order.SBQQ__Quote__c=null; 
                        }
                    }
                    Database.SaveResult saveResult = Database.update(order,false);
                    Sales_CreateLogRecords.createLogRecords(new List<Database.SaveResult>{saveResult},new List<sObject>{order},ORIGIN);
                    if(saveResult!=null){
                        Sales_LicenseTriggerUtility.cancelLicense(orderId);                   
                          	if(order.Sales_Contract_Id__c != null && order.Sales_status__c==STATUS_ORDER_CANCELLED_BY_SAP) {
                                Sales_OrderTriggerUtility.contractStatusToUpdate(order);	
                            }                            
                    }
                    if(!saveResult.isSuccess()){
                         Database.Error error = saveResult.getErrors().get(0);
                    String failedDML = error.getMessage();
                         sendEmailOnExcpetion(String.valueOf(order.OrderNumber),failedDML);
                    }
                }
                catch(Exception ex){
                    Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, 'Order Recall - Exception occured for the Order: '+order.OrderNumber,'\n'+ex.getStackTraceString(), order.Id,'Order', '');
                    throw new AuraHandledException(ex.getMessage());
                }
            }
        }
        else{
            throw new AuraHandledException(System.Label.Sales_Recall_NotAllowedError);
        }
        return isSuccess;
    }
    private static HttpResponse submitOrderToSAP(Order order){
        try{
            Id orderId=order.Id;
            Boolean corporateOrder = corporateOrderMap.get(orderId);
            List<OrderItem> orderItemList = new List<OrderItem>();
            if(corporateOrder){
                if(orderWithOrderItemMapWithCorporate.containsKey(orderId)){orderItemList.addAll(orderWithOrderItemMapWithCorporate.get(orderId));                                                          }        
            }
            else{
                if(orderWithOrderItemMap.containsKey(orderId)){
                    orderItemList.addAll(orderWithOrderItemMap.get(orderId));
                } 
            }
            setAccessToken();
            Http http = new Http();
            String payLoad = generateRequestBody(order,orderItemList,licenseWithOrderProdMap);
            HttpRequest request = new HttpRequest();
            request.setEndpoint(SAP_CREATE_ORDER_ENDPOINT);
            request.setMethod(HTTP_POST);
            request.setBody(payLoad);
            request.setTimeout(120000);	
            request.setHeader('Authorization', BEARER + accessToken);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            HttpResponse response = http.send(request);
            LogEntryWrapper logWrapper = new LogEntryWrapper();
            logWrapper.message = 'Order Submission - SAP Payload generated for Order: '+order.OrderNumber;
            logWrapper.details = '\n'+payload;
            logWrapper.objectId = orderId;
            logWrapper.objectType = 'Order';
            logEntriesToCreate.add(logWrapper);
            logWrapper = new LogEntryWrapper();
            logWrapper.message = 'Order Submission - Response from SAP for the Order: '+order.OrderNumber;
            logWrapper.details = '\nResponse Code:'+response.getStatusCode()+'\nResponse Body:\n'+response.getBody();
            logWrapper.objectId = order.Id;
            logWrapper.objectType = 'Order';
            logEntriesToCreate.add(logWrapper);
            return response;
        }
        catch(Exception ex){
            MetadataFieldConfigWrapper orderExceptionErrorWrapper = new MetadataFieldConfigWrapper(order,ex.getMessage());
            orderWithExceptionMap.put(order.Id,orderExceptionErrorWrapper);
            String strDetailsAndEx = '';
            strDetailsAndEx += 'Message: ' + ex.getMessage() + '\n';
            strDetailsAndEx += 'Cause: ' + ex.getCause() + '\n';
            strDetailsAndEx += 'Line Number: ' + ex.getLineNumber() + '\n';
            strDetailsAndEx += 'Stack Trace: ' + ex.getStackTraceString() + '\n';
            strDetailsAndEx += 'Type Name: ' + ex.getTypeName() + '\n';
            LogEntryWrapper logWrapper = new LogEntryWrapper();
            logWrapper.message = 'Order Submission - Exception occured for the Order: '+order.OrderNumber;
            logWrapper.details = strDetailsAndEx;
            logWrapper.objectId = order.Id;
            logWrapper.objectType = 'Order';
            logEntriesToCreate.add(logWrapper);
            /*if(!System.isBatch()){
throw new AuraHandledException(ex.getMessage());
}*/return null;
        }
    }
    private static String generateRequestBody(Order orderRecord, List<OrderItem> orderItemList,Map<Id,List<Sales_License__c>> licenseWithOrderProdMap) {
        JSONGenerator payloadObj = JSON.createGenerator(false); 
        payloadObj.writeStartObject(); 
        payloadObj.writeFieldName('OrderEntry_Orders'); 
        payloadObj.writeStartObject();
        for(String key : firstLevelFieldConfiMapping.keyset()){
            Sales_Order_SAP_Integration_Mapping__mdt firstRankMappingRecord = firstLevelFieldConfiMapping.get(key);
            String sfdcField = firstRankMappingRecord.Sales_Salesforce__c; 
            List<String> fieldParts = sfdcField.split('\\.');
            Object value;
            if(fieldParts.size()>1){
                value= orderRecord.getSobject(fieldParts[0])?.get(fieldParts[1]);
            }
            else{
                if(sfdcField.equalsIgnoreCase('Sales_Sync_Comments_Txt__c')){
                    value='';
                }
                else{
                    value = orderRecord.get(sfdcField);
                }
            }
            if(firstRankMappingRecord.Sales_SAP_LOV_Available__c){
                String orderKey = firstRankMappingRecord.Sales_Object_Name__c+sfdcField+String.valueOf(value);
                if(lovSapMappingMap.containsKey(orderKey)){
                    value = lovSapMappingMap.get(orderKey);
                }
            }
            payloadObj.writeFieldName(key);
            if(value != null && firstRankMappingRecord.Sales_Type__c.equalsIgnoreCase('String')){
                payloadObj.writeObject(String.valueOf(value));
            }
            else if(value != null && firstRankMappingRecord.Sales_Type__c.equalsIgnoreCase('Date')){
                Date dateValue = Date.valueOf(value);
                DateTime dt = DateTime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
                String dateStr = dt.format('MM/dd/yyyy');
                payloadObj.writeObject(dateStr);}
            else{
                payloadObj.writeObject('');}
        }
        if(orderItemList!= null && !orderItemList.isEmpty()){
            payloadObj.writeFieldName('ListOfOrderEntry_LineItems');
            payloadObj.writeStartObject();
            payloadObj.writeFieldName('OrderEntry_LineItems');
            payloadObj.writeStartArray(); 
            for(Sobject record : orderItemList){
                payloadObj.writeStartObject();
                for(String key : secondLevelFieldConfiMapping.keyset()){
                    Sales_Order_SAP_Integration_Mapping__mdt secondRankMappingRecord = secondLevelFieldConfiMapping.get(key);
                    String sfdcField = secondRankMappingRecord.Sales_Salesforce__c;
                    Object value;
                    List<String> fieldParts = sfdcField.split('\\.');
                    if(fieldParts.size()>1){
                        value= record.getSobject(fieldParts[0])?.get(fieldParts[1]);}
                    else{
                        value =  record.get(sfdcField); }
                    if(secondRankMappingRecord.Sales_SAP_LOV_Available__c){
                        String orderItemKey = secondRankMappingRecord.Sales_Object_Name__c+sfdcField+String.valueOf(value);
                        if(lovSapMappingMap.containsKey(orderItemKey)){
                            value = lovSapMappingMap.get(orderItemKey);
                        }
                    }
                    payloadObj.writeFieldName(key);
                    if(value != null && secondRankMappingRecord.Sales_Type__c.equalsIgnoreCase('String')){
                        payloadObj.writeObject(String.valueOf(value));
                    }
                    else if(value != null && secondRankMappingRecord.Sales_Type__c.equalsIgnoreCase('Date')){
                        Date dateValue = Date.valueOf(value);
                        DateTime dt = DateTime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
                        String dateStr = dt.format('MM/dd/yyyy');
                        payloadObj.writeObject(dateStr);
                    }
                    else{
                        payloadObj.writeObject('');}
                }
                List<Sales_License__c> licenseList =licenseWithOrderProdMap.containsKey(record.Id)&&!corporateOrderMap.get(orderRecord.Id)?licenseWithOrderProdMap.get(record.Id):null;
                if(licenseList!=null && !licenseList.isEmpty()){
                    payloadObj.writeFieldName('ListOfOrderEntryLine_LraProduct');
                    payloadObj.writeStartObject();
                    payloadObj.writeFieldName('OrderEntryLine_LraProduct');
                    payloadObj.writeStartArray();
                    for(sObject licenseRecord :licenseList){
                        payloadObj.writeStartObject();
                        for(String key : thirdLevelFieldConfiMapping.keyset()){
                            Sales_Order_SAP_Integration_Mapping__mdt thirdRankMappingRecord = thirdLevelFieldConfiMapping.get(key);
                            String sfdcField = thirdRankMappingRecord.Sales_Salesforce__c;
                            Object value;
                            List<String> fieldParts = sfdcField.split('\\.');
                            if(fieldParts.size()>1){value= licenseRecord.getSobject(fieldParts[0])?.get(fieldParts[1]);
                                                   }
                            else{value = licenseRecord.get(sfdcField);}
                            payloadObj.writeFieldName(key);
                            if(value != null && thirdRankMappingRecord.Sales_Type__c.equalsIgnoreCase('String')){
                                payloadObj.writeObject(String.valueOf(value));
                            }
                            else{payloadObj.writeObject('');}
                        }
                        payloadObj.writeEndObject();
                    }
                    payloadObj.writeEndArray();
                    payloadObj.writeEndObject();
                }
                payloadObj.writeEndObject();
            }
            payloadObj.writeEndArray();
            payloadObj.writeEndObject();
        }
        payloadObj.writeEndObject();
        payloadObj.writeEndObject();
        return payloadObj.getAsString(); 
    }    
    public static HttpResponse recallOrderFromSAP(Order order, String cancelReasonCode){
        try{
            setAccessToken();
            HTTP http = new HTTP();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Sales_Order_SAP_Integration/'+order.Sales_ERP_SO_Txt__c+ '&'+ cancelReasonCode);
            request.setMethod(HTTP_DELETE);
            request.setTimeout(120000);
            request.setHeader('Authorization', BEARER + accessToken);
            HttpResponse response = http.send(request);
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, 'Order Recall - SAP Payload generated for Order: '+order.OrderNumber,'\n'+request.getEndpoint(), order.Id,'Order', '');
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, 'Order Recall - Response from SAP for the Order: '+order.OrderNumber,'\nResponse Code:'+response.getStatusCode()+'\nResponse Body:\n'+response.getBody(), order.Id,'Order', '');
            return response; 
        }
        catch(Exception ex){
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, 'Order Recall - Exception occured for the Order: '+order.OrderNumber,'\n'+ex.getStackTraceString(), order.Id,'Order', '');
            throw new AuraHandledException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static void updateOrderStatusToFailure(Id orderId,String message){
        Integer retryCountForSubmitToSap = getRetryMasterData(RETRY_MASTER_COUNT);
        Order order =[Select id,Type, Sales_status__c,Sales_Sync_Comments_Txt__c,Sales_ERP_SO_Txt__c,SBQQ__Contracted__c,Sales_Retry_Count__c from Order where id=:orderId Limit 1];
        if(order.Type!=ORDER_TYPE_NON_COMMERCIAL){
            order.Sales_Sync_Comments_Txt__c = order.Sales_Sync_Comments_Txt__c!=null? order.Sales_Sync_Comments_Txt__c+'\n'+System.Now().format()+'----'+RETRY_FAILED_STRING+order.Sales_Retry_Count__c+' with reason '+message:System.Now().format()+'----'+RETRY_FAILED_STRING+order.Sales_Retry_Count__c+' with reason '+message;
            if(order.Sales_Retry_Count__c==retryCountForSubmitToSap){
                order.Sales_status__c = SALES_STATUS_CREATION_FAILED;
                order.Sales_Retry_Count__c=0;
                order.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Sales_Order_Record').getRecordTypeId();
            }
            else {
                order.Sales_status__c = SALES_STATUS_RESUBMISSION;
                if(order.Sales_Retry_Count__c==0){
                    order.Sales_Retry_Count__c = order.Sales_Retry_Count__c+1;
                }
            }
        }
        Database.SaveResult saveResult = Database.update(order);
        Sales_CreateLogRecords.createLogRecords(new List<Database.SaveResult>{saveResult},new List<sObject>{order},ORIGIN);
    }
    public static void updateOrderStatusToFailureForBatch(List<Order> orderUpdateList){
        Integer retryCountForSubmitToSap = getRetryMasterData(RETRY_MASTER_COUNT);
        for(Id orderId:orderWithExceptionMap.keySet()){
            MetadataFieldConfigWrapper orderExceptionWrapper = orderWithExceptionMap.get(orderId);
            Order order = orderExceptionWrapper.orderRecord;
            String message = orderExceptionWrapper.exceptionMessage;
            order.Sales_Sync_Comments_Txt__c = order.Sales_Sync_Comments_Txt__c!=null? order.Sales_Sync_Comments_Txt__c+'\n'+System.Now().format()+'----'+RETRY_FAILED_STRING+order.Sales_Retry_Count__c+' with reason '+message:System.Now().format()+'----'+RETRY_FAILED_STRING+order.Sales_Retry_Count__c+' with reason '+message;
            if(order.Sales_Retry_Count__c==retryCountForSubmitToSap){
                order.Sales_status__c = SALES_STATUS_CREATION_FAILED;
                order.Sales_Retry_Count__c=0;
                order.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Sales_Order_Record').getRecordTypeId();
            }
            else{
                order.Sales_status__c = SALES_STATUS_RESUBMISSION;
                if(order.Sales_Retry_Count__c==0){order.Sales_Retry_Count__c = order.Sales_Retry_Count__c+1;
                                                 }
            }
            orderUpdateList.add(order);
        }
    }
    @InvocableMethod(label='Retry Failed Order')
    public static void retryFailedOrder() {
        Integer retrytimeInterval = getRetryMasterData(RETRY_RESUBMISSION_MASTER_COUNT);
        Integer batchSize = getRetryMasterData(RETRY_RESUBMISSION_BATCH_SIZE);
        List<CronTrigger> cronTriggers = [SELECT Id, NextFireTime, CronJobDetail.Name FROM CronTrigger
                                          WHERE CronJobDetail.Name LIKE :'%' + JOB_PREFIX + '%' AND NextFireTime != NULL];
        if(cronTriggers.isEmpty()){
            Sales_SapIntegrationRetryBatch batchJob = new Sales_SapIntegrationRetryBatch();
            String jobDescription = JOB_PREFIX + System.now();
            System.scheduleBatch(batchJob, jobDescription, retrytimeInterval, batchSize);
        }
    }
    public static Integer getRetryMasterData(String DeveloperName){
        Sales_Retry_Count__mdt retryMasterData = Sales_Retry_Count__mdt.getInstance(DeveloperName);
        return (Integer)retryMasterData.Sales_Value__c;
    }
    @TestVisible private static void populateMaps(List<Order> orderList){
        corporateOrderMap = new Map<Id,Boolean>();
        orderWithOrderItemMap = new Map<Id,List<OrderItem>>();
        orderWithOrderItemMapWithCorporate = new Map<Id,List<OrderItem>>();
        licenseWithOrderProdMap = new Map<Id,List<Sales_License__c>>();
        Set<Id> orderIdSet = new Set<Id>();
        for(Order order : orderList){
            orderIdSet.add(order.Id);
            if(order.Sales_Order_Sub_Type__c==SALES_ORDER_SUBTYPE_CORPORATE){
                corporateOrderMap.put(order.Id,true);
            }
            else{
                corporateOrderMap.put(order.Id,false);
            }
        }
        Set<Id> tempProductId =new Set<Id>();
        Set<Id> corporateProd =new Set<Id>();
        Set<String> orderItemSfFieldsSet = new Set<String>{'Id','OrderId','Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c'};
            orderItemSfFieldsSet.addAll(sfFieldsOrderItem);
        sfFieldsOrderItem.clear();
        sfFieldsOrderItem.addAll(orderItemSfFieldsSet);
        String orderItemQuery = 'Select ' + String.join(sfFieldsOrderItem, ', ') + ' from OrderItem where OrderId IN:orderIdSet order by Sales_SAPLine_Nbr__c ASC';
        Map<Id,OrderItem> orderItemMap = new Map<Id,OrderItem>((List<OrderItem>)Database.query(orderItemQuery));
        for(OrderItem orderProd: orderItemMap.values()){
            tempProductId.add(orderProd.Product2Id);
            if(orderProd.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c==LICENSE_TOOL_TYPE_CORPORATE){
                corporateProd.add(orderProd.Product2Id) ;
            }
        } 
        for(OrderItem orderItem : orderItemMap.values()){
            if(orderWithOrderItemMap.containsKey(orderItem.OrderId)){
                List<OrderItem> tempList = orderWithOrderItemMap.get(orderItem.OrderId);
                tempList.add(orderItem);
                orderWithOrderItemMap.put(orderItem.OrderId,tempList);
            }
            else{
                List<OrderItem> tempList = new List<OrderItem>();
                tempList.add(orderItem);
                orderWithOrderItemMap.put(orderItem.OrderId,tempList);
            }
            if(corporateProd.contains(orderItem.Product2Id)){
                if(orderWithOrderItemMapWithCorporate.containsKey(orderItem.OrderId)){
                    List<OrderItem> tempList = orderWithOrderItemMapWithCorporate.get(orderItem.OrderId);
                    tempList.add(orderItem);
                    orderWithOrderItemMapWithCorporate.put(orderItem.OrderId,tempList);
                }
                else{
                    List<OrderItem> tempList = new List<OrderItem>();
                    tempList.add(orderItem);
                    orderWithOrderItemMapWithCorporate.put(orderItem.OrderId,tempList);
                }
            }
        }
        Set<Id> orderProductIdSet = orderItemMap.keyset();
        Set<String> licenseSfFieldsSet = new Set<String>{'Id'};
            licenseSfFieldsSet.addAll(sfFieldsLicense);
        sfFieldsLicense.clear();
        sfFieldsLicense.addAll(licenseSfFieldsSet);
        String licenseQuery ='Select '+String.join(sfFieldsLicense, ', ')+',Sales_License_Order_Product__c from Sales_License__c where Sales_License_Order_Product__c IN:orderProductIdSet AND Sales_License_Type__c !=:LICENSE_OPTIONAL AND Sales_License_Status__c !=:LICENSE_CANCELLED order by Sales_License_SAPLine_Nbr__c ASC';
        List<Sales_License__c> licenseList =Database.query(licenseQuery);
        for(Sales_License__c license:licenseList){
            if(licenseWithOrderProdMap.containsKey(license.Sales_License_Order_Product__c)){
                List<Sales_License__c> temp =licenseWithOrderProdMap.get(license.Sales_License_Order_Product__c);
                temp.add(license);
                licenseWithOrderProdMap.put(license.Sales_License_Order_Product__c, temp);}
            else{
                List<Sales_License__c> temp =new List<Sales_License__c>();
                temp.add(license);
                licenseWithOrderProdMap.put(license.Sales_License_Order_Product__c, temp); 
            }
        }
    }
    private static MetadataFieldConfigWrapper getLevelFieldConfiMapping(){
        Map<Integer,Map<String, Sales_Order_SAP_Integration_Mapping__mdt>> levelFieldConfiMapping =new Map<Integer,Map<String, Sales_Order_SAP_Integration_Mapping__mdt>>();
        Map<Integer,List<String>> levelToSalesforceFields = new Map<Integer,List<String>>();
        for(Sales_Order_SAP_Integration_Mapping__mdt orderSAPFieldMapp :[SELECT MasterLabel, DeveloperName, Sales_Target_Field__c ,Sales_Salesforce__c,Sales_Object_Name__c,Sales_Level__c,Sales_Type__c,Sales_SAP_LOV_Available__c FROM Sales_Order_SAP_Integration_Mapping__mdt where Sales_InActive_Indicator__c=false Order by DeveloperName]){
            if(levelToSalesforceFields.containsKey(Integer.valueOf(orderSAPFieldMapp.Sales_Level__c))){
                List<String> tempList = levelToSalesforceFields.get(Integer.valueOf(orderSAPFieldMapp.Sales_Level__c));
                tempList.add(orderSAPFieldMapp.Sales_Salesforce__c);
                levelToSalesforceFields.put(Integer.valueOf(orderSAPFieldMapp.Sales_Level__c),tempList);
            }
            else{
                List<String> tempList = new List<String>();
                tempList.add(orderSAPFieldMapp.Sales_Salesforce__c);
                levelToSalesforceFields.put(Integer.valueOf(orderSAPFieldMapp.Sales_Level__c),tempList);
            }
            if(levelFieldConfiMapping.containsKey(Integer.valueOf(orderSAPFieldMapp.Sales_Level__c))){
                Map<String, Sales_Order_SAP_Integration_Mapping__mdt> tempMap=levelFieldConfiMapping.get(Integer.valueOf(orderSAPFieldMapp.Sales_Level__c));
                tempMap.put(orderSAPFieldMapp.Sales_Target_Field__c, orderSAPFieldMapp);
                levelFieldConfiMapping.put(Integer.valueOf(orderSAPFieldMapp.Sales_Level__c),tempMap);
            }
            else{
                Map<String, Sales_Order_SAP_Integration_Mapping__mdt> tempMap=new Map<String, Sales_Order_SAP_Integration_Mapping__mdt>(); 
                tempMap.put(orderSAPFieldMapp.Sales_Target_Field__c, orderSAPFieldMapp);
                levelFieldConfiMapping.put(Integer.valueOf(orderSAPFieldMapp.Sales_Level__c),tempMap); 
            }
        }
        MetadataFieldConfigWrapper metadataWrapper = new MetadataFieldConfigWrapper(levelFieldConfiMapping,levelToSalesforceFields);
        return metadataWrapper;
    }
    private static void populateSapLovMapping(){
        for(Sales_OrderSAP_LOVMapping__mdt lovSapMapping:[Select Sales_Object__c,Sales_Salesforce_Field__c,Sales_SF_LOV_Value__c,Sales_SAP_LOV_Value__c from Sales_OrderSAP_LOVMapping__mdt where Sales_InActive_Indicator__c=false]){
            String lovKey = lovSapMapping.Sales_Object__c+lovSapMapping.Sales_Salesforce_Field__c+lovSapMapping.Sales_SF_LOV_Value__c;
            lovSapMappingMap.put(lovKey,lovSapMapping.Sales_SAP_LOV_Value__c);
        }
    }
    private static HttpRequest getAccessTokenRequest() {
        String clientId = '{!$Credential.Username}';
        String clientSecret = '{!$Credential.Password}';
        String payload = 'client_id=' + clientId + '&client_secret=' + clientSecret + '&refresh_token=' + '&grant_type=client_credentials';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(DEF_TOKEN_ENDPOINT);
        req.setMethod(HTTP_POST);
        req.setBody(payload);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');
        return req;
    }
    private static void setAccessToken() {
        List<Sales_SAP_Token_Detail__c> connectSettingInfos = [Select Id, Name,Sales_Access_Token__c,Sales_Expires_In_Time__c,Sales_Expires_In_Seconds__c From Sales_SAP_Token_Detail__c 
                                                               Where Name ='SAP Token Details'];
        if(connectSettingInfos != null && connectSettingInfos.size()>0 && connectSettingInfos[0].Sales_Expires_In_Time__c >= System.Now()){
            accessToken=connectSettingInfos[0].Sales_Access_Token__c;			            
        }
        else{
            Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
            String accessTokenKey = 'access_token';
            HttpResponse response = new Http().send(getAccessTokenRequest());
            if(response.getStatusCode()==200){
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if(responseMap.containsKey(accessTokenKey)) {
                    accessToken = (String) responseMap.get(accessTokenKey);
                    String expiresIn=(String)responseMap.get('expires_in');
                    connectSettingRecord.Sales_Access_Token__c=accessToken;
                    connectSettingRecord.Sales_Expires_In_Seconds__c=Decimal.valueOf(expiresIn);
                    connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(expiresIn));
                    connectSettingRecord.Name ='SAP Token Details';
                    if(connectSettingInfos!=null && connectSettingInfos.size()>0){
                        connectSettingRecord.Id=connectSettingInfos[0].Id;}
                    connectSettingRecordList.clear();
                    connectSettingRecordList.add(connectSettingRecord); 
                }
            }
        }
    }
    public class MetadataFieldConfigWrapper {
        public Map<Integer,Map<String, Sales_Order_SAP_Integration_Mapping__mdt>> levelFieldConfiMapping { get; set;}
        public Map<Integer,List<String>> levelToSalesforceFields  { get; set;} 
        public Order orderRecord  { get; set;} 
        public String exceptionMessage  { get; set;} 
        public MetadataFieldConfigWrapper(Map<Integer,Map<String, Sales_Order_SAP_Integration_Mapping__mdt>> levelFieldConfiMapping, Map<Integer,List<String>> levelToSalesforceFields){
            this.levelFieldConfiMapping = levelFieldConfiMapping;
            this.levelToSalesforceFields = levelToSalesforceFields;
        }
        public MetadataFieldConfigWrapper(Order orderRecord, String exceptionMessage){
            this.orderRecord = orderRecord;
            this.exceptionMessage = exceptionMessage;
        }
    }
    public class LogEntryWrapper {
        public String message { get; set;}  
        public String details { get; set;} 
        public String objectId { get; set;} 
        public String objectType { get; set;} 
    }
    public static Boolean sendEmailOnExcpetion(String OrderNumber  , String errorMsg){
        if(OrderNumber != null){
            List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL];
            Order order = [SELECT Id, OrderNumber, CreatedById, CreatedBy.Email, AccountId, Account.Name,Sales_ERP_SO_Txt__c,Sales_Cancelled_Reason_Dsc__c FROM Order WHERE OrderNumber =: OrderNumber LIMIT 1 ];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            List<String> sendToBcc = new List<String>();
            sendTo.add(UserInfo.getUserEmail()); 
            sendToBcc=System.Label.Sales_Support_Email_ID.split(',');
            mail.setToAddresses(sendTo);
            mail.setBccAddresses(sendToBcc) ;
            if(order.Sales_ERP_SO_Txt__c!=null){
                mail.setSubject(System.Label.Sales_Cancle_Order_failed+' '+order.OrderNumber); 
            }else{
                mail.setSubject(System.Label.Sales_Email_Failure_Subject1+' '+order.OrderNumber); 
            }
            mail.setHtmlBody(getEmailTemplateBody(order.Account.Name,order.OrderNumber,errorMsg ));
            mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
            mails.add(mail);
            if(mails.size()>0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                if (results[0].success) 
                {   
                    return true;
                } else {
                }
            }
        }
        return false;      
    }
    public static String getEmailTemplateBody(String accountName, String orderNumber , String errorMessage){
        String logoUrl = System.Label.Sales_Intel_Logo;       
        List<Object> parameters = new List<Object> {logoUrl, accountName, orderNumber, errorMessage};
            String emailBody = System.Label.Sales_Email_Failure_Body+System.Label.Sales_Email_Failure_Body1;
        String formattedEmailBody = String.format(emailBody, parameters);
        return formattedEmailBody;
    }
}