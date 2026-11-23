@isTest 
public class testWrap{
@isTest
    static void testWrap(){
        Sales_SapResponseWrapper wrap = new Sales_SapResponseWrapper();
        wrap.Order= 'Test';
        wrap.Type= 'Sample Order';
        wrap.Message= 'Test';
       
        Sales_SapResponseWrapper.cls_OrderRejectionList testWrap = new Sales_SapResponseWrapper.cls_OrderRejectionList();
        testWrap.Order= 'Test';
        testWrap.Type= 'Licensed Tools Order';
        testWrap.Message= 'Test';
       
        Sales_SapResponseWrapper.cls_OrderResponse testWrap1 = new Sales_SapResponseWrapper.cls_OrderResponse();
        testWrap1.OrderNumber = '00002734';
        testWrap1.Status = 'Draft';
        testWrap1.SAPOrderDate = 20210907;
        testWrap1.SAPScheduledDate = 20210909;  

}

}