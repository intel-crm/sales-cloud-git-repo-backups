global class Sales_Orders{
    global Shipping_Info shippingInfo;   

    global class Shipping_Info
    { 
        global String ShipmentDate;     
        global String SAPOrderNum; 
        global String ShipmentNum; 
        global String OrderNumber; 
        global String Status; 
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
        //global List<Sales_Order_Licenses> Order_Lines_Licenses;
    }
    
    global class Sales_ListOfOrder_Line_Licenses{
    	global List<Sales_Order_Licenses> Order_Lines_Licenses;    
    }

    global class Sales_Order_Licenses
    { 
        global String LRASerialNum; 
        global String OrderLicenseNumber;
        global String OrderItemLineNumber; 
    }

    global class Sales_Response_Wrapper
    { 
        global String Status; 
        global String Comments;
    }
}