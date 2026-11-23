/****************************************************************************************************
Apex Class Name : Sales_SAP_Subs_Dets_ServiceUtility
Version         : 1.0 
Created Date    : 11/Mar/2021
Function        : This class is used as a utility class to update the license subscription details from SAP
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description]
* ----------------------------------------------------------------------------                 
* Saba Husain               11/Mar/2021               Created
*/ 
@isTest
public without sharing class Sales_SAP_Subs_Dets_ServiceUtility { 
/*
    private static final string ORIGIN = 'Sales_SAP_Subs_Dets_ServiceUtility';
    private static final String CORPORATE_ORDER = 'Corporate Order';
    private static final String RENEWAL_LICENSE = 'Renewal';
    private static final String AMEND_LICENSE = 'Add Seat';
    private static final String OPTIONAL_LICENSE = 'Optional';
    private static final String ORDER_STATUS_ACTIVATED = 'Activated';
    private static final String ORDER_SAP_SHIPPED_STATUS = 'SAP Order Shipped';
    private static final String ARM_PRODUCT_CLASS_VALUE = 'SV';
    private static final String ARM_PRODUCT_SUBCATEGORY_VALUE = 'A';
    private static final String LICENSE_TYPE_ORIGINAL = 'Original';
    private static final String PRODUCT_TOOLTYPE_ADDSEAT = 'ADD SEAT';
    private static final String PRODUCT_TOOLTYPE_RENEWAL = 'RENEWAL';
    private static final String LICENSE_TYPE_RENEWAL = 'Renewal';
    private static final String LICENSE_TYPE_AMEND = 'Add Seat';
    public static final String ORGWIDE_EMAIL='wsm-postmaster@intel.com';
    public static void updateSalesLicenseDetails(Sales_SAP_Subs_Dets_Service.Shipping_Info shippingInfo){       
        if(shippingInfo != null){
            String orderId;
            String orderSubType;
            String contractID;
            List<Contract> conList = new List<Contract>();
            List<String> orderNumberList = new List<String>();
            List<OrderItem> ordItmListToUpdate = new List<OrderItem>();
            Map<Id,Sales_License__c> licMapToUpdate = new Map<Id,Sales_License__c>();
            Map<String, List<Sales_License__c>> licMap = new Map<String, List<Sales_License__c>>();
            List<Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses> orderLicensesList = new List<Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses>();                        
            Map<Integer,Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems> ordItemNumMap = new Map<Integer,Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems>();     
            Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_LineItems listOfOrder_LineItems = shippingInfo.ListOfOrder_LineItems;            
            if(listOfOrder_LineItems != null){
                List<Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems> orderItemsList = listOfOrder_LineItems.Order_LineItems;
                if(orderItemsList != null){
                    for(Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems orderItem: orderItemsList){
                        ordItemNumMap.put(Integer.valueOf(orderItem.LineNumber), orderItem);
                        if(orderItem.ListOfOrder_Line_Licenses != null && orderItem.ListOfOrder_Line_Licenses.Order_Lines_Licenses != null){
                            orderLicensesList.addAll(orderItem.ListOfOrder_Line_Licenses.Order_Lines_Licenses);    
                        }
                    }
                }
                Set<Id> orderproductIds = new Set<Id>();
                for(OrderItem ordItm: [Select Id, OrderItemNumber, Order.Id, Order.Sales_Order_Sub_Type__c,Sales_SAPLine_Nbr__c, Sales_Due_Date_Dt__c, Sales_RU_Guard_Id_Txt__c,SBQQ__Contract__c from OrderItem where Order.OrderNumber = :shippingInfo.OrderNumber]){
                    orderproductIds.add(ordItm.Id);
                    if(String.IsBlank(orderId)){
                        orderId = ordItm.Order.Id;
                        orderSubType = ordItm.Order.Sales_Order_Sub_Type__c;
                    }
                    if(String.IsBlank(contractID) && ordItm.SBQQ__Contract__c!=null){
                        contractID = ordItm.SBQQ__Contract__c;
                    }
                    Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems ordLineItem = ordItemNumMap.get((ordItm.Sales_SAPLine_Nbr__c).intValue());    
                    if(ordLineItem != null){
                        ordItm.Sales_Due_Date_Dt__c = convertToSFDateFormat(ordLineItem.DueDate);
                        ordItm.Sales_RU_Guard_Id_Txt__c = ordLineItem.RUGuardId;
                        ordItmListToUpdate.add(ordItm);
                        orderNumberList.add(ordItm.OrderItemNumber);
                    }
                }
                Set<Id> licenseIdFromJunction = new Set<Id>();
                for(Sales_License_Order_Product__c junctionRecord:[Select Id, Sales_License__c from Sales_License_Order_Product__c where Sales_Order_Product__c IN :orderproductIds]){
                    licenseIdFromJunction.add(junctionRecord.Sales_License__c);
                }
                if(orderId != null){
                    List<Sales_License__c> licList = [Select Id,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Web_Displayable_Ind__c,
                                                      Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c,Name,Sales_License_Order__r.Sales_Order_Sub_Type__c ,Sales_License_SAPLine_Nbr__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Order_Product__r.Product2.Core_Item_Class_Nm__c,
                                                      Sales_License_Order_Product__r.Product2.Core_Item_Sub_Component_Category_Nm__c,Sales_License_Web_Display_Flag__c,Sales_License_Activation_Code__c, Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__r.Sales_SAPLine_Nbr__c, Sales_License_Type__c from Sales_License__c where Id IN :licenseIdFromJunction and 
                                                      (Sales_License_Type__c =: LICENSE_TYPE_ORIGINAL or (Sales_License_Type__c =: LICENSE_TYPE_AMEND and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c =: PRODUCT_TOOLTYPE_ADDSEAT) or (Sales_License_Type__c =: LICENSE_TYPE_RENEWAL and 
                                                                                                                                                                                                                                                                               Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c =: PRODUCT_TOOLTYPE_RENEWAL))];
                    Order ordRecord=[Select Id, Sales_Order_Sub_Type__c from Order where Id=:orderId Limit 1];
                    for(Sales_License__c lic: licList){ 
                        if(ordRecord.Sales_Order_Sub_Type__c == CORPORATE_ORDER && lic.Sales_License_Type__c!=RENEWAL_LICENSE && lic.Sales_License_Type__c!=AMEND_LICENSE && lic.Sales_License_Type__c!=OPTIONAL_LICENSE){
                            if((lic.Sales_License_Order_Product__r.Product2.Core_Item_Class_Nm__c != ARM_PRODUCT_CLASS_VALUE || lic.Sales_License_Order_Product__r.Product2.Core_Item_Sub_Component_Category_Nm__c != ARM_PRODUCT_SUBCATEGORY_VALUE)||(lic.Sales_License_Order_Product__r.Product2.Core_Item_Class_Nm__c == ARM_PRODUCT_CLASS_VALUE && lic.Sales_License_Order_Product__r.Product2.Core_Item_Sub_Component_Category_Nm__c == ARM_PRODUCT_SUBCATEGORY_VALUE)){
                                lic.Sales_License_Web_Display_Flag__c=lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Web_Displayable_Ind__c;
                                if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c == true)
                                {  
                                    lic.Sales_License_Avbl_Rehost_Nbr__c=lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c;
                                }
                            }
                            lic.Sales_License_Avbl_Rehost_Nbr__c = Integer.valueOf(System.label.Sales_AvailableRehostNbr_Value);
                            licMapToUpdate.put(lic.Id,lic);
                        }
                        String key=String.valueOf(lic.Sales_License_Order_Product__r.Sales_SAPLine_Nbr__c)+String.valueOf(lic.Sales_License_SAPLine_Nbr__c);
                        if(licMap.containsKey(key)){
                            List<Sales_License__c> temLicenseList =licMap.get(key);
                            temLicenseList.add(lic);
                            licMap.put(key,temLicenseList);
                        }
                        else{
                            licMap.put(key,new List<Sales_License__c>{lic});
                        }
                    } 
                    for(Sales_SAP_Subs_Dets_Service.Sales_Order_LineItems orderItem: orderItemsList){                                    
                        if(orderItem.ListOfOrder_Line_Licenses != null && orderItem.ListOfOrder_Line_Licenses.Order_Lines_Licenses != null){
                            Sales_SAP_Subs_Dets_Service.Sales_ListOfOrder_Line_Licenses ListOfOrder_Line_Licenses= orderItem.ListOfOrder_Line_Licenses;
                            for(Sales_SAP_Subs_Dets_Service.Sales_Order_Licenses ordLic: ListOfOrder_Line_Licenses.Order_Lines_Licenses){
                                List<Sales_License__c> salelicList=licMap.get(String.valueOf(orderItem.LineNumber+ordLic.OrderItemLineNumber)); 
                                if(salelicList != null && salelicList.size()>0){
                                    for(Sales_License__c salelic:salelicList){
                                        saleLic.Sales_License_Activation_Code__c = ordLic.LRASerialNum;
                                        saleLic.Sales_License_Avbl_Rehost_Nbr__c = Integer.valueOf(System.label.Sales_AvailableRehostNbr_Value);
                                        if(saleLic.Sales_License_Order_Product__r.Product2.Core_Item_Class_Nm__c != ARM_PRODUCT_CLASS_VALUE || saleLic.Sales_License_Order_Product__r.Product2.Core_Item_Sub_Component_Category_Nm__c != ARM_PRODUCT_SUBCATEGORY_VALUE && saleLic.Sales_License_Type__c!=OPTIONAL_LICENSE){
                                            salelic.Sales_License_Web_Display_Flag__c=salelic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Web_Displayable_Ind__c;
                                            if(salelic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c == true)
                                            {salelic.Sales_License_Avbl_Rehost_Nbr__c=salelic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c;
                                            }
                                        }
                                        licMapToUpdate.put(salelic.Id,salelic);
                                    }}    
                            }    
                        }                                       
                    }
                    if(orderSubType == CORPORATE_ORDER){
                        Id contractActivtatedRTId = [Select Id from RecordType where DeveloperName = 'Sales_Contract_Activated' limit 1][0].Id; 
                        conList = [Select Id, Status,RecordTypeId,Sales_Is_Amendment_Completed__c,Sales_Order_Shipped_Count__c  from Contract where Id = :contractID]; 
                        for(Contract cont: conList){
                            if(cont.Status == 'Draft'){
                                cont.Status = ORDER_STATUS_ACTIVATED;
                                cont.RecordTypeId = contractActivtatedRTId;
                                cont.Sales_Is_Amendment_Completed__c = true;
                            }
                            cont.Sales_Order_Shipped_Count__c = cont.Sales_Order_Shipped_Count__c + 1;
                        }
                    }
                    update licMapToUpdate.values();                    
                    Order ord = [Select Id, Sales_Ship_Date_Dt__c, Sales_Shipment_Number_Txt__c, Sales_ERP_SO_Txt__c, Sales_Airbill_Number_Txt__c, Sales_status__c from Order where Id=:orderId LIMIT 1 FOR UPDATE];
                    ord.Sales_Ship_Date_Dt__c = convertToSFDateFormat(shippingInfo.ShipmentDate); 
                    ord.Sales_Shipment_Number_Txt__c =  shippingInfo.ShipmentNum;
                    ord.Sales_ERP_SO_Txt__c = shippingInfo.SAPOrderNum;
                    ord.Sales_Airbill_Number_Txt__c = shippingInfo.AirBillNum;
                    ord.Sales_status__c = ORDER_SAP_SHIPPED_STATUS;                  
                    Database.SaveResult saveResult = Database.update(ord);
                    Sales_CreateLogRecords.createLogRecords(new List<Database.SaveResult>{saveResult},new List<sObject>{ord},ORIGIN);
                    List<Database.SaveResult> saveResultList = Database.update(ordItmListToUpdate);
                    Sales_CreateLogRecords.createLogRecords(saveResultList,ordItmListToUpdate,ORIGIN);
                    if(conList.size() > 0){
                        List<Database.SaveResult> saveResultContractList = Database.update(conList);
                        Sales_CreateLogRecords.createLogRecords(saveResultContractList,conList,ORIGIN);
                    }
                }                
            }
        }        
    } 
    public static Date convertToSFDateFormat(String dateStr){
        String newDate;
        Date dateResult;
        if(dateStr != null){
            newDate = dateStr.left(10);
            if(dateStr.contains('/')){              
                dateResult = Date.parse(newDate);
            }else if(dateStr.contains('-')){                
                dateResult = Date.valueOf(newDate);
            }
        }
        return dateResult;
    }
    public static Boolean sendEmailOnExcpetion(Sales_SAP_Subs_Dets_Service.Shipping_Info shippingInfo , String errorMsg){
        if(shippingInfo != null){
            List<Messaging.SingleEmailMessage> mails =new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address=:ORGWIDE_EMAIL];
            Order order = [SELECT Id, OrderNumber, CreatedById, CreatedBy.Email, AccountId, Account.Name FROM Order WHERE OrderNumber =: shippingInfo.OrderNumber LIMIT 1 ];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(order.CreatedBy.Email); 
            mail.setToAddresses(sendTo);           
            mail.setSubject(System.Label.Sales_Email_Failure_Subject); 
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
            String emailBody = System.Label.Sales_Email_Sync_Failure_Body+System.Label.Sales_Email_Sync_Failure_Body1;
        String formattedEmailBody = String.format(emailBody, parameters);
        return formattedEmailBody;
    }
*/
}