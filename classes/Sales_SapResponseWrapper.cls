/*********************************************************************************************************************
Class Name    : Sales_SapResponseWrapper
Version       : 1.0
Created Date  : March 2021
Function      : This class stores response from SAP as wrapper.
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           08-March-2021             
* *********************************************************************************************************************/
public class Sales_SapResponseWrapper{
    public Sales_SapResponseWrapper(){
     }
    public String Order;
	public String Type;
	public String Message;
    public cls_OrderResponse OrderResponse;
    public cls_OrderRejectionList OrderRejectionList;
	public class cls_OrderRejectionList {
		public String Order;	
		public String Type;	
		public String Message;	
	}
	public class cls_OrderResponse {
		public String OrderNumber;	
		public String Status;	
        public Integer SAPOrderDate;
        public Integer SAPScheduledDate;
        public String SAPOrderNum;
	}
}