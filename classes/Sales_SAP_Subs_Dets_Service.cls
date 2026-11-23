/****************************************************************************************************
Apex Class Name : Sales_SAP_Subs_Dets_Service
Version         : 1.0 
Created Date    : 12/Feb/2021
Function        : This class is used to receive the license subscription details from SAP
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sridhar                     12/Feb/2021               Created
*/
@RestResource(urlMapping='/sales/v1/*')
global without sharing class Sales_SAP_Subs_Dets_Service {    
    private static final string ORIGIN = 'Sales_SAP_Subs_Dets_Service';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'PSG_Sales';
    @HttpPost
    global static Sales_Response_Wrapper postSubscriptions(Shipping_Info shippingInfo) {
        Sales_Response_Wrapper response = new Sales_Response_Wrapper();	
        try{       
            String incomingResponse = JSON.serialize(shippingInfo);
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','',incomingResponse, '', '', '');
            if (shippinginfo != null){
                Sales_SAP_Subs_Dets_ServiceUtility.updateSalesLicenseDetails(shippingInfo);
                response.Status = 'Success';
                response.Comments = 'Shipping records processed successfully';
            }
            else{
                response.Status = 'Failed';
                response.Comments = 'Input paylaod is empty or null';
            }
        }catch(Exception e){
            Boolean emailSent ;
            emailSent = Sales_SAP_Subs_Dets_ServiceUtility.sendEmailOnExcpetion(shippingInfo, e.getMessage());
            if(emailSent){            
                String emailText = System.Label.Sales_Email_Sync_Failure_Text;
                Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, 'Message', SEVERITY, e.getMessage(), emailText + e.getStackTraceString(), '', '', '',e);
            }else {
                Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, 'Message', SEVERITY, e.getMessage() , e.getStackTraceString(), '', '', '',e);  
            }
            response.Status = 'Failed';
            response.Comments = e.getMessage();
        }
        return response;
    }
    global class Sales_Orders{
        global Shipping_Info shippingInfo;
    }
    global class Shipping_Info
    { 
        global String ShipmentDate;     
        global String SAPOrderNum; 
        global String ShipmentNum; 
        global String OrderNumber; 
        global String Status; 
        global String AirBillNum;
        global Sales_ListOfOrder_LineItems ListOfOrder_LineItems;
    }
    global class Sales_ListOfOrder_LineItems
    {
        global List<Sales_Order_LineItems> Order_LineItems;
    }
    global class Sales_Order_LineItems
    { 
        global String RUGuardId;     
        global String DueDate; 
        global String LineNumber; 
        global String PartNumber; 
        global String Status; 
        global Sales_ListOfOrder_Line_Licenses ListOfOrder_Line_Licenses;
    }
    global class Sales_ListOfOrder_Line_Licenses{
        global List<Sales_Order_Licenses> Order_Lines_Licenses;    
    }
    global class Sales_Order_Licenses
    { 
        global String LRASerialNum; 
        global String OrderItemLineNumber; 
    }
    global class Sales_Response_Wrapper
    { 
        global String Status; 
        global String Comments;
    }
}