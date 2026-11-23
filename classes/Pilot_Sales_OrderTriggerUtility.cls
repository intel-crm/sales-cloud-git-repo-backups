/*********************************************************************************************************************
Class Name    : Pilot_Sales_OrderTriggerUtility
Version       : 1.0
Created Date  : Sep 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Subhanku Ghosh            1/09/2021              Pilot Project for testing framework.
* ************************************************************************************************************************************************/
public class Pilot_Sales_OrderTriggerUtility {
    
    private static final String ORDER_SUBTYPE_ARMORDER='ARM standalone license order';
    private static final String ORDER_SUBTYPE_CORPORATEORDER='Corporate Order';
    private static final String ORDER_SUBTYPE_DEVKITORDER='Dev Kit/PAC ES with license (Quartus and/or ARM) order';
    private static final String ORDER_SUBTYPE_STANDALONEORDER='Standalone license order';
    private static final String ORDER_SUBTYPE_RENEWALORDER='Renewal order';
    private static final String ORDER_TYPE_LICENSEDORDER='Licensed Tool Order';
    private static final String ORDER_TYPE_SAMPLEORDER='Sample Order';
    private static final String ORDER_TYPE_NONCOMMERCIAL='Non Commercial Order';
    private static final String ORDER_TYPE_AMEND_NON_COMMERCIAL = 'Amend Non Commercial';
    private static final String ORDER_REASON_STOCKING_ORDER='Stocking Order';
    private static final String ORDER_REASON_NON_STOCKING_ORDER='Non Stocking Order';
    private static final String ORDER_CANCELLED = 'Order Cancelled';
    private static final String ORDER_CANCELLED_BY_SAP='Order Cancelled by SAP';
    private static final String ORDER_STATUS_ACTIVATED = 'Activated';
    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final String ORDER_SUB_STATUS_DRAFT = 'Draft Order';
    private static final String ORDER_ACCOUNT_TYPE_DISTRIBUTOR = 'Distributor';
    private static final String ORDER_ACCOUNT_TYPE_END_USER = 'End User';
    private static final String QUOTE_TYPE_AMENDMENT = 'Amendment';
    private static final String LICENSE_STATUS_CANCELLED = 'Cancelled';
    private static final String LICENSE_TYPE_RENEWAL = 'Renewal';
    private static final String LICENSE_TYPE_AMEND = 'Amend';
    private static final String PRODUCT_TOOL_TYPE_CORPORATE = 'CORPORATE';
    private static final String CONTRACT_STATUS_AMENDMENT_COMPLETED = 'Amendment Completed';
    private static final String DIRECT_ORDER_DISTI_CHANNEL='01';
    private static final String DISTI_ORDER_DISTI_CHANNEL='02';
    private static final String ORDER_TYPE_FPGA_UNIVERSITY_PROGRAM = 'FPGA university program license request';
    private static final String LICENSE_TYPE_ORIGINAL = 'Original';
    private static final String PRODUCT_TOOLTYPE_ADDSEAT = 'ADD SEAT';
    private static final String PRODUCT_TOOLTYPE_RENEWAL = 'RENEWAL';
    private static final String OPTIONAL_LICENSE = 'Optional';
    private static final String ARM_PRODUCT_CLASS_VALUE = 'SV';
    private static final String ARM_PRODUCT_SUBCATEGORY_VALUE = 'A';
    
    //Calling this method from Sales_OrderTriggerHandler for before insert
    //Setting order fields when order created from quote and Setting order start date when order is created
    public static void createOrdersfromQuote(List<Order> ordersList,Map<Id, Order> oldOrderMap){ 
        //list<Id> OrderIds=new list<Id>(); 
        Set<Id> quoteIds = new Set<Id>();
        //Map<Id, Order> orderMap = new Map<Id,Order>();       
        for(Order ord : ordersList){
            system.debug(ord);
            // added as part of US1005327 - to populate start date as current date when order is created(1.order is created from order management 2.order is created from quote both cases)
            ord.EffectiveDate=System.today();
            //Setting order fields when order created from quote 
            //making stage and status as Draft and Order reason as non - stocking order
            if(!String.isBlank(ord.SBQQ__Quote__c)){               
                quoteIds.add(ord.SBQQ__Quote__c); 
            }
        }
        System.debug('quoteIds>>>'+quoteIds);
        //Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>([select id, name,SBQQ__Ordered__c,core_cpq_end_customer_nm__c,SBQQ__Account__c,SBQQ__Account__r.Type, SBQQ__StartDate__c from SBQQ__Quote__c where id in:quoteIds]);
        Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>(SEL_Quote.newInstance().selectByIds(quoteIds));
        System.debug('quoteMap>>>'+quoteMap.values());
        for(Order ord : ordersList){            
            System.debug('line 71');
            System.debug('ord>>>'+ord);
            System.debug('quote>>>'+quoteMap.containskey(ord.SBQQ__Quote__c));
            // System.debug('ordered>>>'+quoteMap.get(ord.SBQQ__Quote__c).SBQQ__Ordered__c);
            if(quoteMap.containskey(ord.SBQQ__Quote__c) && quoteMap.get(ord.SBQQ__Quote__c).SBQQ__Ordered__c){
                System.debug('Inside line 73');
                Id qid= ord.SBQQ__Quote__c;
                SBQQ__Quote__c c =  quoteMap.get(qid);
                //ord.Sales_End_Customer_Account__c = c.core_cpq_end_customer_nm__c;    //US919632 ord.Core_PSG_End_Customer_Account__c = c.core_cpq_end_customer_nm__c;           
                ord.Status=ORDER_STATUS_DRAFT;
                ord.Sales_status__c=ORDER_SUB_STATUS_DRAFT; //Previously ord.status__c='Draft Order';    - US919632
                ord.Type= '';
                ord.Sales_Order_Reason__c=ORDER_REASON_NON_STOCKING_ORDER; //US 919632 ord.Core_PSG_Order_Reason__c='Non Stocking Order';              
                ord.Sales_Corporate_Order__c=true;     // Previously was - ord.Core_PSG_Corporate_Order__c=true; - Changed as part of US919632          
                if( quoteMap.containskey(ord.SBQQ__Quote__c) &&  quoteMap.get(ord.SBQQ__Quote__c).SBQQ__StartDate__c != null){
                    ord.EffectiveDate= quoteMap.get(ord.SBQQ__Quote__c).SBQQ__StartDate__c;
                }
                if(quoteMap.get(ord.SBQQ__Quote__c).SBQQ__Account__r.Type==ORDER_ACCOUNT_TYPE_DISTRIBUTOR || quoteMap.get(ord.SBQQ__Quote__c).SBQQ__Account__r.Type==ORDER_ACCOUNT_TYPE_END_USER){
                    ord.AccountId= quoteMap.get(ord.SBQQ__Quote__c).SBQQ__Account__c;
                }
            }
        }
    }
    
    //US862284: This method will check the validation on Order for License Vendor competitor.
    public static void checkAccountCompetitorVendor(List<Order> orderList,Map<Id,Order> orderOldMap){
        Pilot_Sales_LicenseValidationCheckUtilty.addErrorOnOrder(orderList, orderOldMap);//calling method to validation check
    }
    
    //US1044910 - This will call method to trigger Email to Order Creator 
    public static void sendEmailNotification(List<Order> orderList){
        Pilot_Sales_EmailToOrderContact.sendEmailToOrderCreator(orderList);
    }
    
    //Added by Jasmine as a part of US909064: Order Creation from Quote & Quote Line Groups
    public static void checkOrderTypeandSubType(List<Order> orderList){
        Map<Id, String> subOrderTypeMap = new Map<Id, String>();
        Map<Id, Boolean> checkforRenewalProduct = new Map<Id, Boolean>();
        Boolean renewCheck=false;
        Map<Id,Order> orderMap = new Map<Id,Order>(SEL_Order.newInstance().selectByIds(orderList));
        subOrderTypeMap = Pilot_Sales_OrderCreationValidUtility.checksubOrderType(orderList);
        checkforRenewalProduct = Pilot_Sales_OrderCreationValidUtility.isRenewalProduct(orderList);
        for(Order ord : orderList){
            if(orderMap.get(ord.id).SBQQ__Quote__c != null && orderMap.get(ord.id).SBQQ__Quote__r.SBQQ__StartDate__c != null){
                ord.EffectiveDate = orderMap.get(ord.id).SBQQ__Quote__r.SBQQ__StartDate__c;
            }
            //adding the subtype as Amend Non-commercial when quote associated is of Amendment type and order type:Non-commercial
            if(orderMap.get(ord.id).SBQQ__Quote__c != null && (orderMap.get(ord.id).SBQQ__Quote__r.SBQQ__Type__c == QUOTE_TYPE_AMENDMENT) && (ord.Type == ORDER_TYPE_NONCOMMERCIAL)){
                ord.Sales_Order_Sub_Type__c = ORDER_TYPE_AMEND_NON_COMMERCIAL;
            }
            if(subOrderTypeMap.size()> 0){
                if((subOrderTypeMap.containsKey(ord.Id))&& (ord.Type == ORDER_TYPE_LICENSEDORDER || ord.Type == ORDER_TYPE_SAMPLEORDER)&&(subOrderTypeMap.values().contains(ORDER_SUBTYPE_DEVKITORDER) || subOrderTypeMap.values().contains(ORDER_SUBTYPE_ARMORDER) || subOrderTypeMap.values().contains(ORDER_SUBTYPE_STANDALONEORDER))){
                    ord.Sales_Order_Sub_Type__c = subOrderTypeMap.get(ord.Id);
                }
                if((ord.Type == ORDER_TYPE_LICENSEDORDER || ord.Type == ORDER_TYPE_SAMPLEORDER || (ord.Type == ORDER_TYPE_NONCOMMERCIAL && orderMap.get(ord.Id).SBQQ__Quote__r.SBQQ__Type__c!=QUOTE_TYPE_AMENDMENT))&&(subOrderTypeMap.values().contains(ORDER_SUBTYPE_CORPORATEORDER))){
                    ord.Sales_Order_Sub_Type__c = subOrderTypeMap.get(ord.Id);
                }     
            }else if(ord.Type == ORDER_TYPE_LICENSEDORDER || ord.Type == ORDER_TYPE_SAMPLEORDER || ((ord.Type == ORDER_TYPE_NONCOMMERCIAL) && (ord.Sales_Order_Sub_Type__c == ORDER_SUBTYPE_CORPORATEORDER))){
                ord.Sales_Order_Sub_Type__c = '';
            }
            //}Nilesh commented
            //added as a part of Renewal US941928
            if(checkforRenewalProduct.size() > 0){//check if renewalProductmap size is > 0
                if(checkforRenewalProduct.containsKey(ord.Id)){
                    renewCheck = checkforRenewalProduct.get(ord.id);
                }
            }
            if(renewCheck){
                ord.Sales_IsRenewal__c = true;//mark the Sales_IsRenewal__c as true
            }else{
                ord.Sales_IsRenewal__c = false;//mark the Sales_IsRenewal__c as false
            }
        }
    }
    
    // added by Monika/Pooja - US925257,US932566 Checks when order is activated then all the products on that order should be Available for TOE/Orderable
    public static void validateOrder(Map<Id, Order> newOrderMap, Map<Id, Order> oldOrderMap){ 
        Map<String,Order> orderMap=new Map<String,Order>();
        Set<id> orderIds = new Set<Id>();
        Set<id> orderIdsforLicenses = new Set<Id>();
        Set<id> orderIdsfororderProducts = new Set<Id>();
        Set<id> orderIdsfornonCorporateOPN = new Set<Id>();
        Set<id> orderIdsForQuoteUpdate = new Set<Id>();
        List<String> orderIdsforPriceMismatch = new List<String>();
        for(Order o: newOrderMap.values()){
            orderMap.put(o.Id,o);
            if((o.Status == ORDER_STATUS_ACTIVATED || o.Sales_Is_Verified__c==true) && oldOrderMap.get(o.id).Status!=ORDER_STATUS_ACTIVATED){
                orderIds.add(o.id);
                orderIdsforLicenses.add(o.id);
                if(o.Sales_Order_Sub_Type__c==ORDER_SUBTYPE_CORPORATEORDER || o.Sales_Order_Sub_Type__c==ORDER_TYPE_AMEND_NON_COMMERCIAL
                   || o.Type==ORDER_TYPE_LICENSEDORDER || o.Type==ORDER_TYPE_SAMPLEORDER){
                       orderIdsfororderProducts.add(o.id);   
                   }
                if(!((o.Sales_Order_Sub_Type__c == ORDER_SUBTYPE_CORPORATEORDER) || (o.Sales_Order_Sub_Type__c == ORDER_TYPE_AMEND_NON_COMMERCIAL)) && o.Sales_Order_Reason__c==ORDER_REASON_NON_STOCKING_ORDER){
                    orderIdsfornonCorporateOPN.add(o.id);
                }
                if(((o.Type==ORDER_TYPE_LICENSEDORDER || o.Type==ORDER_TYPE_SAMPLEORDER) && (o.Sales_Disty_Channel_Txt__c!=null) && (o.OrderItemCount__c>0))||
                   ((o.Type==ORDER_TYPE_NONCOMMERCIAL) && (o.OrderItemCount__c>0) && (o.Sales_Req_Ship_Date_Dt__c >= Date.today()))){// getting the order id set for price mismatch on order activation.  && (o.Sales_Sold_To_Account__c!=null) && (o.Sales_Req_Ship_Date_Dt__c >= Date.today())
                       orderIdsforPriceMismatch.add(o.id);
                   }
            }
            if(o.SBQQ__Quote__c != null && oldOrderMap != null && oldOrderMap.get(o.id).SBQQ__Quote__c != o.SBQQ__Quote__c){
                orderIdsForQuoteUpdate.add(o.id);
            }
        }
        orderIds.addAll(orderIdsForQuoteUpdate);
        if(orderIds.size()>0){
            for(OrderItem oi: [Select Id, OrderId ,Product2Id, Product2.Core_Product_Ext_Attribute_Id__c, Product2.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c,Product2.Core_Item_Orderable_Ind__c from OrderItem where orderId in :orderIds]){
                if(oi.Product2.Core_Product_Ext_Attribute_Id__c == null|| !oi.Product2.Core_Item_Orderable_Ind__c ||
                   (oi.Product2.Core_Product_Ext_Attribute_Id__c != null && !oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c && (newOrderMap.get(oi.orderid).Sales_Is_Verified__c  || newOrderMap.get(oi.orderid).Status == ORDER_STATUS_ACTIVATED))
                   && !newOrderMap.get(oi.orderid).hasErrors()){
                       
                       PRM_Execution_Controls__c  skipValidation= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());//added check to bypass validation for integration user.
                       
                       if(!skipValidation.Skip_ValidationRule_Order_Status__c){
                           newOrderMap.get(oi.orderid).addError(System.Label.Sales_license_TOE_Error);   
                       }
                       
                   }
                if(orderIdsForQuoteUpdate.contains(oi.orderid) && !newOrderMap.get(oi.orderid).hasErrors() && !Test.isRunningTest()){//Add error to order if a Quote is associated to Order which already has Order Products                     
                    newOrderMap.get(oi.orderid).addError(System.Label.Sales_license_Quote_Error);
                }
            }
        }
        Map<Id,Boolean> showErrorForAvailableQuantity = new Map<Id,Boolean>();
        if(orderIdsforLicenses.size()>0){	// Added by Puja as part of US922937 - License Activation Code is mandatory on Licenses.
            For(Sales_License__c license : [Select Id,Sales_License_Activation_Code__c,Sales_License_Order__c,Sales_License_Quantity__c,Sales_License_Avbl_Qty_Nbr__c,Sales_License_Type__c,Sales_License_Status__c  from Sales_License__c where Sales_License_Order__c IN:orderMap.keySet()]){
                if(license.Sales_License_Activation_Code__c==null && license.Sales_License_Status__c != LICENSE_STATUS_CANCELLED){
                    orderMap.get(license.Sales_License_Order__c).Status.addError(System.label.Sales_LicenseActivationCode_Error); 
                }
                if(!showErrorForAvailableQuantity.containsKey(license.Sales_License_Order__c) 
                   && orderMap.get(license.Sales_License_Order__c).SBQQ__Quote__c!=null
                   && orderMap.get(license.Sales_License_Order__c).Sales_Order_Sub_Type__c==ORDER_SUBTYPE_CORPORATEORDER 
                   && license.Sales_License_Avbl_Qty_Nbr__c!=0
                   && (license.Sales_License_Type__c==System.Label.Sales_Renew_Contract_Qty_Decrease || license.Sales_License_Type__c==System.Label.Sales_Amend_Contract_Qty_Decrease)){
                       showErrorForAvailableQuantity.put(license.Sales_License_Order__c,true);
                       orderMap.get(license.Sales_License_Order__c).addError(System.label.Sales_CompleteActions);
                   }
            }
        }
        
        if(orderIdsfororderProducts.size()>0 || orderIdsfornonCorporateOPN.size()>0){
            For(OrderItem oi : [Select Id,OrderId,Sales_Contact__c,Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from OrderItem where Sales_Contact__c=null and (OrderId IN: orderIdsfororderProducts or OrderId IN: orderIdsfornonCorporateOPN)]){
                if(orderIdsfororderProducts.size()>0 && oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c==PRODUCT_TOOL_TYPE_CORPORATE && orderIdsfororderProducts.contains(oi.OrderId)){
                    orderMap.get(oi.OrderId).Status.addError(System.label.Sales_corporate_opn_error);
                }
                if(orderIdsfornonCorporateOPN.size()>0 && oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!=PRODUCT_TOOL_TYPE_CORPORATE && orderIdsfornonCorporateOPN.contains(oi.OrderId) && !( oldOrderMap.get(oi.OrderId).Status==ORDER_STATUS_DRAFT && newOrderMap.get(oi.OrderId).Status==ORDER_STATUS_ACTIVATED)){
                    orderMap.get(oi.OrderId).Sales_Order_Reason__c.addError(System.label.Sales_non_corporate_opn_error); //Uncommented as part of defect fix
                }
            }
        }
        //method call to check price mismatch on order activation
        if(orderIdsforPriceMismatch.size()>0){
            String message = Sales_DisplayWarning.validatePriceChange(orderIdsforPriceMismatch,'Trigger',newOrderMap);
        }
    } 
    
    /**
* @description      : This method updates the related license records with Start Date or Account based on respective fields update on Order
* @name             : updateLicenseRecords
* @param            : Map<Id, Order> ordMap, Map<Id, boolean> ordWithAccountUpdateMap
* @throws exception : NONE
**/    
    public static void updateLicenseRecords(Map<Id, Order> ordMap, Map<Id, boolean> ordWithAccountUpdateMap){
        List<Sales_License__c> licList = new List<Sales_License__c>();
        Set<Id> licSetToExcludeFromContract = new Set<Id>();
        Set<Id> contractIdsSet = new Set<Id>();
        List<Sales_License_Order_Product__c> licOrdProdToDeleteFinal = new List<Sales_License_Order_Product__c>();
        Set<Sales_License_Order_Product__c> licOrdProdToDelete = new Set<Sales_License_Order_Product__c>();
        Map<Id, Sales_License_Order_Product__c> licIdLicOrdProdMapToDelete = new Map<Id, Sales_License_Order_Product__c>(); 
        List<Sales_License_Order_Product__c> licOrdProdList = new List<Sales_License_Order_Product__c>();
        Map<Id, Sales_License_Order_Product__c> mapOfLicIdLicOrdProd = new Map<Id, Sales_License_Order_Product__c>();
        boolean result=false;
        //Get all the License order Product records where Order on Order Product of License is the order in trigger.new
        for(Sales_License_Order_Product__c licOrdProd: [Select Id,Sales_License__r.Sales_License_Type__c, Sales_License__c,Sales_License__r.Sales_License_Product__r.Core_Item_Class_Nm__c,Sales_License__r.Sales_License_Product__r.Core_Item_Sub_Component_Category_Nm__c,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c ,Sales_License__r.Sales_License_Web_Display_Flag__c,
                                                        Sales_License__r.Sales_License_Avbl_Rehost_Nbr__c,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,Sales_License__r.Sales_License_Quantity__c,Sales_License__r.Sales_License_Order__c,Sales_Order_Product__r.Quantity,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
                                                        Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Web_Displayable_Ind__c,Sales_Order_Product__c, Sales_Order_Product__r.OrderId, Sales_Order_Product__r.Order.SBQQ__Quote__r.SBQQ__Type__c, 
                                                        Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License__r.Sales_License_Start_Date_Dt__c, Sales_Order_Product__r.Order.SBQQ__Quote__r.SBQQ__MasterContract__r.StartDate,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c, 
                                                        Sales_Order_Product__r.Order.SBQQ__Quote__r.SBQQ__MasterContract__c, Sales_Order_Product__r.SBQQ__Contract__c, Sales_Order_Product__r.SBQQ__Contract__r.Status, Sales_Order_Product__r.SBQQ__Contract__r.EndDate, Sales_Order_Product__r.SBQQ__Contract__r.StartDate,Sales_License__r.Sales_License_Order_Product__r.Sales_Contact__c
                                                        from Sales_License_Order_Product__c where Sales_Order_Product__r.OrderId IN:ordMap.keyset() and (Sales_License__r.Sales_License_Type__c =: LICENSE_TYPE_ORIGINAL or (Sales_License__r.Sales_License_Type__c =:(System.Label.Sales_Licencse_Add_Seat_record_type) and Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c =: PRODUCT_TOOLTYPE_ADDSEAT) or (Sales_License__r.Sales_License_Type__c =:LICENSE_TYPE_RENEWAL and Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c =: PRODUCT_TOOLTYPE_RENEWAL))]){
                                                            
                                                            //Added aspart of US1047206
                                                            //mapofrehostAvailablerehost.put(licOrdProd.id,licOrdProd); 
                                                            Order ord = ordMap.get(licOrdProd.Sales_Order_Product__r.OrderId);                                                            
                                                            //If End customer Account is updated on order, update the same on related license records
                                                            if(ordWithAccountUpdateMap.containsKey(ord.id)){
                                                                Sales_License__c lic = new Sales_License__c();
                                                                lic.id = licOrdProd.Sales_License__c;                                                                
                                                                
                                                                if(ord.Sales_Order_Reason__c == ORDER_REASON_STOCKING_ORDER){
                                                                    lic.Sales_License_Account__c = null;
                                                                    lic.Sales_License_Primary_Admin_Contact__c = null;
                                                                }else{
                                                                    lic.Sales_License_Account__c = ord.AccountId;
                                                                    lic.Sales_License_Primary_Admin_Contact__c = licOrdProd.Sales_License__r.Sales_License_Order_Product__r.Sales_Contact__c;
                                                                }
                                                                licList.add(lic);  
                                                                //For original order/Renewal order/Amendment with increase qty, update the start date on licenses
                                                                //based on order type                                                                
                                                            } else if(licOrdProd.Sales_Order_Product__r.Quantity > 0){                                                
                                                                Sales_License__c lic = new Sales_License__c();
                                                                lic.id = licOrdProd.Sales_License__c;
                                                                //For Non-commercial order which is NOT an amendment order, update the license start date as Order activated date
                                                                if(ord.Type == ORDER_TYPE_NONCOMMERCIAL && ord.Sales_Order_Sub_Type__c != ORDER_SUBTYPE_CORPORATEORDER && (licOrdProd.Sales_Order_Product__r.Order.SBQQ__Quote__c == null || licOrdProd.Sales_Order_Product__r.Order.SBQQ__Quote__r?.SBQQ__Type__c != QUOTE_TYPE_AMENDMENT)){
                                                                   // if(ord.Sales_Order_Sub_Type__c != ORDER_SUBTYPE_CORPORATEORDER){
                                                                        lic.Sales_License_Start_Date_Dt__c = ord.ActivatedDate.date();//}
                                                                    if(licOrdProd.Sales_License__r.Sales_License_Type__c!=OPTIONAL_LICENSE)
                                                                    {
                                                                        lic.Sales_License_Web_Display_Flag__c=licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Web_Displayable_Ind__c;
                                                                        if(licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Rehostable_Ind__c == true)
                                                                        {
                                                                            lic.Sales_License_Avbl_Rehost_Nbr__c=licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c;
                                                                        }
                                                                        
                                                                    }
                                                                }                                                                                                                                
                                                                
                                                                //For commercial non-stocking order, update the license start date as ship date on order
                                                                else if(ord.Sales_Order_Sub_Type__c != ORDER_SUBTYPE_CORPORATEORDER && ord.Sales_Order_Reason__c == ORDER_REASON_NON_STOCKING_ORDER && ord.Sales_Ship_Date_Dt__c != null && (licOrdProd.Sales_Order_Product__r.Order.SBQQ__Quote__c == null || licOrdProd.Sales_Order_Product__r.Order.SBQQ__Quote__r?.SBQQ__Type__c != QUOTE_TYPE_AMENDMENT)){
                                                                    lic.Sales_License_Start_Date_Dt__c = ord.Sales_Ship_Date_Dt__c; 
                                                                    //For Amendment order (Non Commercial/Corporate), update the license start date as quote start date 
                                                                    //Update the contract id on the license and license order product
                                                                }else if(ord.Type == ORDER_TYPE_NONCOMMERCIAL || ord.Sales_Order_Sub_Type__c == ORDER_SUBTYPE_CORPORATEORDER) /*&& licOrdProd.Sales_Order_Product__r.Order.SBQQ__Quote__r?.SBQQ__Type__c == 'Amendment' && licOrdProd.Sales_Order_Product__r.Order.SBQQ__Quote__r?.SBQQ__MasterContract__r?.StartDate !=null)*/
                                                                {
                                                                    if(licOrdProd.Sales_Order_Product__r.Order.SBQQ__Quote__r?.SBQQ__Type__c == QUOTE_TYPE_AMENDMENT){
                                                                        lic.Sales_License_Start_Date_Dt__c = licOrdProd.Sales_Order_Product__r.Order.SBQQ__Quote__r?.SBQQ__MasterContract__r?.StartDate;
                                                                        lic.Sales_License_Contract__c = licOrdProd.Sales_Order_Product__r.Order.SBQQ__Quote__r?.SBQQ__MasterContract__c;
                                                                    }
                                                                    else if(licOrdProd.Sales_Order_Product__r.SBQQ__Contract__c != null && licOrdProd.Sales_Order_Product__r.SBQQ__Contract__r.Status == ORDER_STATUS_ACTIVATED && (ord.Type == ORDER_TYPE_NONCOMMERCIAL || ord.Sales_Ship_Date_Dt__c != null)){
                                                                        lic.Sales_License_Start_Date_Dt__c = licOrdProd.Sales_Order_Product__r.SBQQ__Contract__r.StartDate; 
                                                                        lic.Sales_License_Contract__c = licOrdProd.Sales_Order_Product__r.SBQQ__Contract__c;
                                                                        Integer prodExpiryDurationInDays =  (Integer)licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r?.Core_SW_Prod_Expiration_Duration_Nbr__c;
                                                                        if(prodExpiryDurationInDays != null){
                                                                            lic.Sales_License_Expiration_Date_Dt__c =  Sales_LicenseTriggerUtility.getLastDateOfMonth(lic.Sales_License_Start_Date_Dt__c?.addDays(prodExpiryDurationInDays));                  
                                                                            if(lic.Sales_License_Expiration_Date_Dt__c < licOrdProd.Sales_Order_Product__r.SBQQ__Contract__r.EndDate){
                                                                                lic.Sales_License_Expiration_Date_Dt__c = licOrdProd.Sales_Order_Product__r.SBQQ__Contract__r.EndDate;
                                                                            }
                                                                        }
                                                                        lic.Sales_License_Maintenance_Exp_Dt__c =  licOrdProd.Sales_Order_Product__r.SBQQ__Contract__r.EndDate; 
                                                                    }
                                                                    licOrdProd.Sales_License_ContractId__c = lic.Sales_License_Contract__c;
                                                                    licOrdProdList.add(licOrdProd);
                                                                    //If none of the conditions above are satisfied, continue with the loop and no further updates should be executed
                                                                }else{
                                                                    continue;
                                                                }
                                                                //If available for temp lic is true on Product, update the temporary lic qty on licesne record as the numbe of seats
                                                                if(licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c == true){
                                                                    
                                                                    lic.Sales_License_Available_Temp_Licenses__c = licOrdProd.Sales_License__r.Sales_License_Quantity__c;
                                                                }
                                                                //update the latest order product on the license record
                                                                lic.Sales_License_Order_Product__c = licOrdProd.Sales_Order_Product__c; 
                                                                lic.Sales_License_Order__c = licOrdProd.Sales_Order_Product__r.OrderId;
                                                                //  lic.Sales_License_Status__c = 'Licensed';
                                                                licList.add(lic);                                                                    
                                                            }
                                                            //For amendment order & decrease in quantity
                                                            else{
                                                                //Add to the list for further processing
                                                                licSetToExcludeFromContract.add(licOrdProd.Sales_License__c); 
                                                              //  licIdLicOrdProdMapToDelete.put(licOrdProd.Sales_License__c, licOrdProd);
                                                                contractIdsSet.add(licOrdProd.Sales_Order_Product__r.Order.SBQQ__Quote__r?.SBQQ__MasterContract__c);
                                                            }                                                                 
                                                        }        
        
        if(!licSetToExcludeFromContract.isEmpty()){
            //Query all the license order products record for the license to get the previous contract if it exists, to either cancel it or update with previous contract details
            for(Sales_License_Order_Product__c olderlicOrdProd: [Select id, Sales_Order_Product__r.OrderId,Sales_Order_Product__c, Sales_License_ContractId__c,Sales_License_ContractId__r.StartDate, Sales_License__c from Sales_License_Order_Product__c where Sales_License__c IN: licSetToExcludeFromContract and Sales_License_ContractId__c != null and Sales_License__r.Sales_License_Status__c!=:LICENSE_STATUS_CANCELLED order by Sales_License_ContractId__r.enddate desc]){
                //Add to the map if license order product is not part of current contract
                //Add only once in the map for the latest contract before current contract
                if(!contractIdsSet.contains(olderlicOrdProd.Sales_License_ContractId__c) && !mapOfLicIdLicOrdProd.containsKey(olderlicOrdProd.Sales_License__c)){
                    mapOfLicIdLicOrdProd.put(olderlicOrdProd.Sales_License__c, olderlicOrdProd);                   
                }else if(!ordMap.keySet().contains(olderlicOrdProd.Sales_Order_Product__r.OrderId)){
                    licOrdProdToDelete.add(olderlicOrdProd);
                }
            }
        }
        
        for(Sales_License_Order_Product__c licOrdProd: licOrdProdToDelete){
            if(mapOfLicIdLicOrdProd.keyset().contains(licOrdProd.Sales_License__c)){
            	licOrdProdToDeleteFinal.add(licOrdProd);    
            }    
        }
        
        for(Id licId: licSetToExcludeFromContract){
            Sales_License__c lic = new Sales_License__c();
            lic.id = licId;
            //If previous contract exists, relink the license record to previous contract
            if(mapOfLicIdLicOrdProd.containsKey(licId)){
                lic.Sales_License_Order_Product__c = mapOfLicIdLicOrdProd.get(licId).Sales_Order_Product__c;
                lic.Sales_License_Start_Date_Dt__c = mapOfLicIdLicOrdProd.get(licId).Sales_License_ContractId__r?.StartDate;
                lic.Sales_License_Order__c = mapOfLicIdLicOrdProd.get(licId).Sales_Order_Product__r.OrderId;
                lic.Sales_License_Contract__c = mapOfLicIdLicOrdProd.get(licId).Sales_License_ContractId__c;
                //Else cancel the license
            }else{
               // licIdLicOrdProdMapToDelete.remove(lic.id);
                lic.Sales_License_Status__c = LICENSE_STATUS_CANCELLED;
                lic.Sales_License_Web_Display_Flag__c = false;
            }
            licList.add(lic);
        }
     //   licOrdProdToDeleteFinal.addAll(licIdLicOrdProdMapToDelete.values());
        
        if(!licList.IsEmpty()){
            update licList;
        }
        if(!licOrdProdList.IsEmpty()){
            update licOrdProdList;
        } 
        if(!licIdLicOrdProdMapToDelete.IsEmpty()){
            delete licOrdProdToDeleteFinal;
        }
    }
    
    // Pooja Added
    public static void checkContractsisCreated(List<Order> orderList,Map<id,order>oldMap){
        List<Order> recordsToBeUpdated = new List<Order>(); 
        List<OrderItem> oiList = new List<OrderItem>();
        Set<id> orderIds = new Set<Id>();
        for (Order orderRecord : orderList) { 
            Order oldRec = oldMap.get(orderRecord.Id); 
            if((orderRecord.Sales_Order_Sub_Type__c==ORDER_SUBTYPE_CORPORATEORDER && orderRecord.SBQQ__Quote__c != null && orderRecord.Status == ORDER_STATUS_ACTIVATED && oldRec.Status != ORDER_STATUS_ACTIVATED )||
               (orderRecord.Type==ORDER_TYPE_NONCOMMERCIAL && orderRecord.Sales_Order_Sub_Type__c==ORDER_TYPE_AMEND_NON_COMMERCIAL && orderRecord.SBQQ__Quote__c != null && orderRecord.Status == ORDER_STATUS_ACTIVATED && oldRec.Status != ORDER_STATUS_ACTIVATED )){ 
                   Order rec = new Order(Id=orderRecord.Id); 
                   rec.SBQQ__Contracted__c = true; 
                   recordsToBeUpdated.add(rec); 
               }
            if(orderRecord.Sales_status__c == ORDER_CANCELLED || orderRecord.Sales_status__c == ORDER_CANCELLED_BY_SAP){
                orderIds.add(orderRecord.Id);
            }
        } 
        for(OrderItem oi : [SELECT OrderId, SBQQ__QuoteLine__c, Sales_Cancelled_Quoteline_No__c, SBQQ__Status__c from OrderItem where OrderId IN: orderIds]){                    
            if(String.isBlank(oi.Sales_Cancelled_Quoteline_No__c)){
                oi.SBQQ__Status__c = ORDER_STATUS_DRAFT;
                oi.Sales_Cancelled_Quoteline_No__c = oi.SBQQ__QuoteLine__c;//assigned the QuoteLine value to the custom field
                oi.SBQQ__QuoteLine__c = null;//for cancelled orders remove the quoteline reference from OOTB QL field
                oiList.add(oi);
            }
        }
        if(recordsToBeUpdated.size() > 0){
            update recordsToBeUpdated;
        }
        if(oiList.size() > 0){
            update oiList;//update order products list
        }
    }
    
    //Nilesh Added 
    //Updated by Shalini for Id population
    //updating the address fields and OOTB account on the order based on  order reason 
    public static void updateAddressAndAccount(List<Order> orderList,Map<Id,order>oldMap){
        Set<Id> orderIds = new Set<Id>();
        Set<Id> soldIds = new Set<Id>();
        Set<Id> shipIds = new Set<Id>();
        Set<Id> endIds = new Set<Id>();
        Boolean isChanged=false;
        Boolean isShipping=false;
        Boolean isShippingIns=false;
        Map<Id,Order> ordMap = new Map<Id,Order>();
        Map<Id,Order> oldOrdMap = new Map<Id,Order>();
        Map<Id,Account> soldAccMap = new Map<Id,Account>();
        Map<Id,Account> shipAccMap = new Map<Id,Account>();
        Map<Id,Account> endAccMap = new Map<Id,Account>();
        
        for(Order ol : orderList){
            if(ol.Status==ORDER_STATUS_DRAFT && oldMap!=null && ((ol.Sales_Sold_To_Account__c!=oldMap.get(ol.Id).Sales_Sold_To_Account__c) || (ol.Sales_Sold_To_Account__c!=null) || (ol.Sales_Ship_To_Account__c!=oldMap.get(ol.Id).Sales_Ship_To_Account__c) || 
                                                                 (ol.Sales_End_Customer_Account__c!=oldMap.get(ol.Id).Sales_End_Customer_Account__c))){
                                                                     isChanged = true;
                                                                 }
            orderIds.add(ol.Id);
            soldIds.add(ol.Sales_Sold_To_Account__c);
            shipIds.add(ol.Sales_Ship_To_Account__c);
            endIds.add(ol.Sales_End_Customer_Account__c);
        }
        //fetching the sold to account details 
        
        If(soldIds!=null || shipIds!=null || endIds!=null){
            for(Account acc : [SELECT Id, Name,Core_Direct_Account_Id__c,ParentId,BillingStreet,BillingState, BillingCountry, BillingCity, BillingPostalCode, Tolabel(BillingStateCode),ToLabel(BillingCountryCode),
                               Core_Direct_Shipping_Condition_Nm__c,Core_Direct_Sales_Organization_Nm__c,Core_Direct_Payment_Term_Nm__c,Core_Direct_Distributor_Channel_Nm__c,Core_Direct_Shipping_Instruction_Txt__c,Core_Direct_Incoterm_Dsc__c from Account where Id IN:soldIds or 
                               Id IN:shipIds or Id IN: endIds]){
                                   
                                   if(soldIds!=null && soldIds.contains(acc.id)){
                                       soldAccMap.put(acc.Id,acc);
                                   }
                                   if(shipIds!=null && shipIds.contains(acc.id)){
                                       shipAccMap.put(acc.Id,acc);   
                                   }
                                   if(endIds!=null && endIds.contains(acc.id)){
                                       endAccMap.put(acc.Id,acc);
                                   }           
                               }
        }
        for(Order ord :orderList){
            if(ord.Status==ORDER_STATUS_DRAFT && oldMap.get(ord.Id).Sales_Ship_To_Account__c != ord.Sales_Ship_To_Account__c  && oldmap.get(ord.id).Sales_Shipping_Instructions_Dsc__c == ord.Sales_Shipping_Instructions_Dsc__c){
                isShippingIns = true;
                Id acc = oldMap.get(ord.Id).Sales_Ship_To_Account__c;
                
            } 
            
            if(isChanged && ord.Status==ORDER_STATUS_DRAFT){
                //updating the sold to account on order with Direct sold to account details 
                if(ord.Sales_Sold_To_Account__c!=null && soldAccMap.containsKey(ord.Sales_Sold_To_Account__c)){
                    ord.Sales_Sold_To_Acct_Id__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).Core_Direct_Account_Id__c;
                    ord.Sales_SoldTo_Account_2_Txt__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).Name;
                    ord.Sales_SoldTo_Street_Dsc__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).BillingStreet;
                    ord.Sales_SoldTo_City_Txt__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).BillingCity;
                    ord.Sales_SoldTo_Province_Txt__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).BillingState;
                    ord.Sales_SoldTo_Country_Txt__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).BillingCountryCode;
                    ord.Sales_Disty_Channel_Txt__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).Core_Direct_Distributor_Channel_Nm__c;
                    ord.Sales_SoldTo_State_Txt__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).BillingStateCode;
                    ord.Sales_SoldTo_Zip_Txt__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).BillingPostalCode;
                    ord.Sales_Sales_Org_Txt__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).Core_Direct_Sales_Organization_Nm__c;
                    ord.Sales_Payment_Terms__c = soldAccMap.get(ord.Sales_Sold_To_Account__c).Core_Direct_Payment_Term_Nm__c;
                    
                    //OOTB account on Order is updated with Direct Sold to Account's Parent Id
                    if(ord.Sales_Order_Reason__c == ORDER_REASON_STOCKING_ORDER && ord.Type != ORDER_TYPE_NONCOMMERCIAL && soldAccMap.get(ord.Sales_Sold_To_Account__c).ParentId!=null){
                        ord.AccountId = soldAccMap.get(ord.Sales_Sold_To_Account__c).ParentId ;
                    }
                    //Error if Direct Sold to Account's Parent Id
                    else if(ord.Sales_Order_Reason__c == ORDER_REASON_STOCKING_ORDER && ord.Type != ORDER_TYPE_NONCOMMERCIAL && (ord.Sales_Sold_To_Account__c ==null || soldAccMap.get(ord.Sales_Sold_To_Account__c).ParentId == null)){
                        ord.addError('For stocking order sold to account is mandatory');
                    }
                }
                //updating the sold to account details and address on Order with blank if sold to account id is null
                else if(ord.Sales_Sold_To_Account__c==null){
                    ord.Sales_Sold_To_Acct_Id__c = '';
                    ord.Sales_SoldTo_Account_2_Txt__c = '';
                    ord.Sales_SoldTo_Street_Dsc__c = '';
                    ord.Sales_SoldTo_City_Txt__c = '';
                    ord.Sales_SoldTo_Province_Txt__c = '';
                    ord.Sales_SoldTo_Country_Txt__c = '';
                    ord.Sales_Disty_Channel_Txt__c = '';
                    ord.Sales_SoldTo_State_Txt__c = '';
                    ord.Sales_SoldTo_Zip_Txt__c = '';
                    ord.Sales_Sales_Org_Txt__c = '';
                    ord.Sales_Payment_Terms__c = '';
                }
                //updating the ship to account on order with Direct ship to account details 
                if (ord.Sales_Ship_To_Account__c!=null && shipAccMap.containsKey(ord.Sales_Ship_To_Account__c)){
                    ord.Sales_Ship_To_Acct_Id__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).Core_Direct_Account_Id__c;
                    ord.Sales_ShipTo_Account_2_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).Name;
                    ord.Sales_ShipTo_Street_Dsc__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingStreet;
                    ord.Sales_ShipTo_City_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingCity;
                    ord.Sales_ShipTo_Province_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingState;
                    ord.Sales_ShipTo_Country_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingCountryCode;
                    //Commented as part US1016231  
                    ord.Sales_Shipping_Condition_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).Core_Direct_Shipping_Condition_Nm__c;         
                    
                    ord.Sales_ShipTo_State_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingStateCode;
                    ord.Sales_ShipTo_Zip_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingPostalCode;
                    ord.Sales_Incoterms_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).Core_Direct_Incoterm_Dsc__c;                    
                    
                   if(( oldMap == null || ((ord.Type==ORDER_TYPE_LICENSEDORDER || ord.Type==ORDER_TYPE_NONCOMMERCIAL ) && oldMap.get(ord.Id).Type ==ORDER_TYPE_SAMPLEORDER && ord.Sales_Shipping_Instructions_Dsc__c==oldMap.get(ord.Id).Sales_Shipping_Instructions_Dsc__c ) )||
                       (oldMap != null && oldMap.get(ord.Id).Sales_Ship_To_Account__c != ord.Sales_Ship_To_Account__c)){ 
                           //Defaulting to Ship to Accounts Shipping Instructions                        
                           ord.Sales_Shipping_Instructions_Dsc__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).Core_Direct_Shipping_Instruction_Txt__c;  
                       } 
                    
                    //If the order reason: Non Stocking and Order type : Sample Order then updating the end customer details on the Order with the Direct Ship to account details 
                    if(ord.Sales_Order_Reason__c == ORDER_REASON_NON_STOCKING_ORDER && ord.Type == ORDER_TYPE_SAMPLEORDER && ord.Sales_End_Customer_Account__c == null){
                        ord.Sales_End_Customer_Account__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).Id;
                        ord.Sales_End_Cust_Acct_Id__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).Core_Direct_Account_Id__c;
                        ord.Sales_End_Customer_Account_2_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).Name;
                        ord.Sales_End_Customer_Street_Dsc__c =  shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingStreet;
                        ord.Sales_End_Customer_City_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingCity;
                        ord.Sales_End_Customer_Province_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingState; 
                        ord.Sales_End_Customer_Country_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingCountryCode;
                        ord.Sales_End_Customer_State_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingStateCode;
                        ord.Sales_End_Customer_Zip_Txt__c = shipAccMap.get(ord.Sales_Ship_To_Account__c).BillingPostalCode;
                        //OOTB Account on order is updated with the Direct Ship to Account's parent Id
                        if(ord.Sales_Order_Reason__c == ORDER_REASON_NON_STOCKING_ORDER && ord.Type == ORDER_TYPE_SAMPLEORDER && shipAccMap.get(ord.Sales_Ship_To_Account__c).ParentId!=null){
                            ord.AccountId = shipAccMap.get(ord.Sales_Ship_To_Account__c).ParentId;
                        }
                        //Error if the Direct Ship to Account's parent Id is null 
                        else if(ord.Sales_Order_Reason__c == ORDER_REASON_NON_STOCKING_ORDER && ord.Type == ORDER_TYPE_SAMPLEORDER && (shipAccMap.get(ord.Sales_Ship_To_Account__c).ParentId == null)){
                            ord.addError(System.label.Sales_End_Customer_Mandatory);
                        }
                    }
                }
                //updating the ship to account details and address on Order with blank if ship to account id is null
                else if (ord.Sales_Ship_To_Account__c==null){
                    ord.Sales_Ship_To_Acct_Id__c = '';
                    ord.Sales_ShipTo_Account_2_Txt__c = '';
                    ord.Sales_ShipTo_Street_Dsc__c = '';
                    ord.Sales_ShipTo_City_Txt__c = '';
                    ord.Sales_ShipTo_Province_Txt__c = '';
                    ord.Sales_ShipTo_Country_Txt__c = '';
                    ord.Sales_Shipping_Condition_Txt__c = '';
                    ord.Sales_ShipTo_State_Txt__c = '';
                    ord.Sales_ShipTo_Zip_Txt__c = '';
                    ord.Sales_Incoterms_Txt__c = '';
                    ord.Sales_Shipping_Instructions_Dsc__c = '';
                }
                //updating the End customer account on order with Direct end customer account details 
                if (ord.Sales_End_Customer_Account__c!=null && endAccMap.containsKey(ord.Sales_End_Customer_Account__c)){
                    ord.Sales_End_Cust_Acct_Id__c = endAccMap.get(ord.Sales_End_Customer_Account__c).Core_Direct_Account_Id__c;
                    ord.Sales_End_Customer_Account_2_Txt__c = endAccMap.get(ord.Sales_End_Customer_Account__c).Name;
                    ord.Sales_End_Customer_Street_Dsc__c =  endAccMap.get(ord.Sales_End_Customer_Account__c).BillingStreet;
                    ord.Sales_End_Customer_City_Txt__c = endAccMap.get(ord.Sales_End_Customer_Account__c).BillingCity;
                    ord.Sales_End_Customer_Province_Txt__c = endAccMap.get(ord.Sales_End_Customer_Account__c).BillingState; 
                    ord.Sales_End_Customer_Country_Txt__c = endAccMap.get(ord.Sales_End_Customer_Account__c).BillingCountryCode;
                    ord.Sales_End_Customer_State_Txt__c = endAccMap.get(ord.Sales_End_Customer_Account__c).BillingStateCode;
                    ord.Sales_End_Customer_Zip_Txt__c = endAccMap.get(ord.Sales_End_Customer_Account__c).BillingPostalCode;
                    //OOTB Account on the order is updated with the Direct End customer Parent Id
                    if(ord.Sales_Order_Reason__c == ORDER_REASON_NON_STOCKING_ORDER && ord.Type != ORDER_TYPE_NONCOMMERCIAL && endAccMap.get(ord.Sales_End_Customer_Account__c).ParentId!=null){
                        ord.AccountId = endAccMap.get(ord.Sales_End_Customer_Account__c).ParentId;
                    }
                    //Error if the Direct End customer Parent Id is null
                    else if(ord.Sales_Order_Reason__c == ORDER_REASON_NON_STOCKING_ORDER && ord.Type != ORDER_TYPE_NONCOMMERCIAL && (ord.Sales_End_Customer_Account__c==null || endAccMap.get(ord.Sales_End_Customer_Account__c).ParentId == null)){
                        ord.addError(System.label.Sales_End_Customer_Mandatory);
                    }
                    if((ord.Type == ORDER_TYPE_NONCOMMERCIAL) && (ord.Sales_Order_Sub_Type__c == ORDER_TYPE_FPGA_UNIVERSITY_PROGRAM || (ord.Sales_Order_Sub_Type__c == ORDER_SUBTYPE_CORPORATEORDER) || (ord.Sales_Order_Sub_Type__c == ORDER_TYPE_AMEND_NON_COMMERCIAL)) && endAccMap.get(ord.Sales_End_Customer_Account__c).ParentId!=null){
                        ord.AccountId = endAccMap.get(ord.Sales_End_Customer_Account__c).ParentId; 
                    }  
                }
                //updating the end customer account details and address on Order with blank if end customer account id is null
                else if(ord.Sales_End_Customer_Account__c==null){
                    ord.Sales_End_Cust_Acct_Id__c = '';
                    ord.Sales_End_Customer_Account_2_Txt__c = '';
                    ord.Sales_End_Customer_Street_Dsc__c = '';
                    ord.Sales_End_Customer_City_Txt__c = '';
                    ord.Sales_End_Customer_Province_Txt__c = ''; 
                    ord.Sales_End_Customer_Country_Txt__c = '';
                    ord.Sales_End_Customer_State_Txt__c = '';
                    ord.Sales_End_Customer_Zip_Txt__c = '';
                }
            }
        }
    }
    
    public static void updatePriceBook(List<Order> orderList,Map<Id, Order> oldOrderMap){ 
        String priceBookId = '';
        Boolean checkPriceBook = false;
        Boolean isTypeChanged = false;
        Boolean isChanged = false;
        Map<Id,String> soldToAccountDistyChannelMap = new Map<Id,String>();
        Set<Id> soldToAccountIds = new Set<Id>();
        List<Sales_Price_Book_Mapping__mdt> metadata_PBNames = new List<Sales_Price_Book_Mapping__mdt>();
        set<string> pbNames = new set<string>();
        Map<String, Id> pbNameId = new Map<String, Id>();
        Set<Id> soldToAccIdSet=new Set<Id>();
        Map<String,Order> orderMap=new Map<String,Order>();
        RecordType readonlyRecordType = [Select Id from RecordType where SobjectType='Order' and DeveloperName='Sales_Read_Only_Record' Limit 1];  // Select Id of 'Sales - Read Only' RecordType  ;
        
        for(Order ord : orderList)
        {
            if(ord.Status==ORDER_STATUS_DRAFT && (ord.SBQQ__Quote__c==null && ord.OrderItemCount__c==0)){
                if((oldOrderMap==null || (oldOrderMap!=null && (ord.Type!=oldOrderMap.get(ord.Id).Type || oldOrderMap.get(ord.Id).SBQQ__Quote__c!=null))) || 
                   (ord.Type==ORDER_TYPE_LICENSEDORDER && oldOrderMap==null || ((ord.Sales_Disty_Channel_Txt__c!=oldOrderMap.get(ord.Id).Sales_Disty_Channel_Txt__c)|| (ord.Sales_Sold_To_Account__c!=oldOrderMap.get(ord.Id).Sales_Sold_To_Account__c)))){
                       isTypeChanged = true;
                   }
            }
            
            if(ord.Status==ORDER_STATUS_DRAFT && (ord.Sales_Sold_To_Account__c!=null && ord.Type==ORDER_TYPE_LICENSEDORDER))
            {
                soldToAccountDistyChannelMap.put(ord.Id,ord.Sales_Disty_Channel_Txt__c);
            }
            if(System.Trigger.isInsert && ord.Pricebook2Id!=null){
                isChanged = true;
            }
            if(ord.Status==ORDER_STATUS_DRAFT && ord.Sales_Sold_To_Account__c!=null){
                soldToAccIdSet.add(ord.Sales_Sold_To_Account__c);
            }
            if((ord.Status==ORDER_STATUS_ACTIVATED) || ord.Sales_status__c==ORDER_CANCELLED && ord.RecordTypeId!=readonlyRecordType.Id){
                ord.RecordTypeId = readonlyRecordType.Id;       //Change RecordType to Sales_Read_Only_Record if  (1.Order Stage is Activated and status is Order Activated  or 2.Order is Cancelled) And Order's current recordtype isn't Sales_Read_Only_Record.
            }			
            If((ord.Sales_PO_Number_Txt__c!=null && ord.Sales_status__c!=ORDER_CANCELLED ) && (System.Trigger.isInsert || (ord.Sales_PO_Number_Txt__c!=oldOrderMap.get(ord.Id).Sales_PO_Number_Txt__c))){  //Checking if PO number is not null and order status is not order cancelled. 
                If(orderMap.containskey(ord.Sales_PO_Number_Txt__c)){
                    ord.Sales_PO_Number_Txt__c.addError(System.Label.Sales_PO_Number_Error);               //throwing error if an another order that already has the same po number
                }
                else{
                    orderMap.put(ord.Sales_PO_Number_Txt__c,ord);
                }
            }
        }
        if(soldToAccIdSet.size()>0){
            AccountshipTosoldTo(orderList,soldToAccIdSet);
        }
        
        
        for (Sales_Price_Book_Mapping__mdt mdtRecs : [Select id,Sales_PriceBook_name__c, Sales_Sold_To_Account_Region__c, Sales_isQuotePopulated__c, Sales_Type__c, Sales_Disti_Channel__c  
                                                      from Sales_Price_Book_Mapping__mdt ]){ //Getting all metdata records and storing in price book names in set pbNames.
                                                          metadata_PBNames.add(mdtRecs);
                                                          pbNames.add(mdtRecs.Sales_PriceBook_name__c);
                                                      }
        if(isTypeChanged==true){
            for(Pricebook2 pbRecord : [Select id,Name from Pricebook2 where Name = : pbNames and IsActive=true]){            //Fetching all price book id which are active 
                pbNameId.put(pbRecord.Name, pbRecord.Id);
            }
        }
        
        If(orderMap.size()>0){
            For(Order order:[Select Sales_PO_Number_Txt__c from Order where Sales_PO_Number_Txt__c!=null and Sales_status__c!=:ORDER_CANCELLED and Sales_PO_Number_Txt__c IN:orderMap.keySet()]){
                orderMap.get(order.Sales_PO_Number_Txt__c).Sales_PO_Number_Txt__c.addError(System.Label.Sales_PO_Number_Error);//Order newOrder=orderMap.get(order.Sales_PO_Number_Txt__c);
            }
        }
        
        If(pbNameId.size()>0){
            for(Order ord: orderList){
                for (Sales_Price_Book_Mapping__mdt mdtRec : metadata_PBNames){  //loop start here...
                    if ((ord.OrderItemCount__c==0 && ord.Type == ORDER_TYPE_LICENSEDORDER && mdtRec.Sales_Type__c == ord.Type 
                         && mdtRec.Sales_Sold_To_Account_Region__c== ord.Sales_Sold_To_Account_Region_Txt__c && ord.Sales_Disty_Channel_Txt__c==DISTI_ORDER_DISTI_CHANNEL && ord.Sales_Sold_To_Account_Region_Txt__c!=null)||
                        (ord.OrderItemCount__c==0 && ord.Type == ORDER_TYPE_LICENSEDORDER && mdtRec.Sales_Type__c == ord.Type 
                         && mdtRec.Sales_Disti_Channel__c==soldToAccountDistyChannelMap.get(ord.Id) && ord.Sales_Disty_Channel_Txt__c==DIRECT_ORDER_DISTI_CHANNEL)){      //if order type is licensed tools order then price book is based upon sold to account region                                                               
                             priceBookId = pbNameId.get(mdtRec.Sales_PriceBook_name__c);
                             break;
                         }
                    
                    else if(ord.OrderItemCount__c==0 && ord.Type != ORDER_TYPE_LICENSEDORDER && mdtRec.Sales_Type__c == ord.Type){ //for Sample order pricebook is OEM and for Non-Commercial order pricebook is standard price book.
                        priceBookId = pbNameId.get(mdtRec.Sales_PriceBook_name__c);
                        break;
                    }
                }
                
                if(ord.OrderItemCount__c==0 && ord.Type==ORDER_TYPE_LICENSEDORDER && ord.Sales_Disty_Channel_Txt__c == DISTI_ORDER_DISTI_CHANNEL && 
                   ord.Sales_Sold_To_Account_Region_Txt__c==null){
                       priceBookId=null;
                       checkPriceBook=true;
                   }
                
                if((String.isNotBlank(priceBookId) && ord.OrderItemCount__c==0 && ord.SBQQ__Quote__c==null)||(checkPriceBook==true && ord.OrderItemCount__c==0 && ord.SBQQ__Quote__c==null)){
                    if(isChanged!=true){
                        ord.Pricebook2Id = priceBookId; 
                    }
                }
            }
        }
        
    }
    
    public static void updateContractStatus(List<Order> ordList,Set<Id> quoteIds){
        Map<Id,Id> quoteToContractMap = new Map<Id,Id>();
        List<Contract> contractList = new List<Contract>();
        for(SBQQ__Quote__c qid :[Select Id, SBQQ__Type__c,SBQQ__MasterContract__c from SBQQ__Quote__c where Id IN :quoteIds AND SBQQ__Type__c =: QUOTE_TYPE_AMENDMENT]){            
            quoteToContractMap.put(qid.Id,qid.SBQQ__MasterContract__c);
        }
        //US1047228  - Added Sales_Is_Amendment_Completed__c in query
        for(Contract contList : [Select Id ,Status,SBQQ__Quote__c,Sales_Is_Amendment_Completed__c from Contract where Id IN: quoteToContractMap.values() And Status =: ORDER_STATUS_ACTIVATED]){
            contList.Status = CONTRACT_STATUS_AMENDMENT_COMPLETED;
            //US1047228  - to bypass validation rule
            contList.Sales_Is_Amendment_Completed__c = true;
            contractList.add(contList);
        }
        if(contractList.size()>0){
            update contractList;
        }
    }
    
    //Added as part of US1005271-Validation for selecting shipToAccount associated with the soldToAccount   
    public static void AccountshipTosoldTo(List<Order> ordersList, Set<Id> soldToOrderSet)
    {
        List<Id> soldToorderList = new List<Id>();
        Map<Id, Set<Id>> soldToshipToAccountMap= new Map<Id,Set<Id>>();
        
        //Storing the soldToAccounts and the associated shipToAccounts in a Map
        for(Core_Account_SoldTo_ShipTo_Rel__c acc:[select id,Core_Sold_To_Account__c,Core_Ship_To_Account__c,Core_Is_Deactivated_Ind__c from Core_Account_SoldTo_ShipTo_Rel__c where Core_Sold_To_Account__c IN : soldToOrderSet and Core_Is_Deactivated_Ind__c=false ])
        {
            
            if(soldToshipToAccountMap.containsKey(acc.Core_Sold_To_Account__c))
            {
                Set<Id> existingshipToIds = new Set<Id>();
                existingshipToIds = soldToshipToAccountMap.get(acc.Core_Sold_To_Account__c);
                existingshipToIds.add(acc.Core_Ship_To_Account__c); 
                soldToshipToAccountMap.put(acc.Core_Sold_To_Account__c,existingshipToIds);
            }
            else
            {
                soldToshipToAccountMap.put(acc.Core_Sold_To_Account__c,new Set<Id>{acc.Core_Ship_To_Account__c});
            }    
        }
        for(Order ord: ordersList)
        {
            String soldToId= ord.Sales_Sold_To_Account__c;
            String shipToId= ord.Sales_Ship_To_Account__c;
            if(soldToshipToAccountMap.get(soldToId)==null && !(soldToshipToAccountMap.containsKey(soldToId))){
                ord.addError(System.Label.Sales_SoldToShipToErrorMessage);
            }else{
                if(soldToId!=null && shipToId!=null){
                    if(soldToshipToAccountMap!=null && soldToshipToAccountMap.containsKey(soldToId) && soldToshipToAccountMap.get(soldToId)!=null && !((soldToshipToAccountMap.get(soldToId).contains(shipToId))))
                    {
                        ord.addError(System.Label.Sales_SoldToShipToErrorMessage);
                    } 
                }
            }
        }
    }
}