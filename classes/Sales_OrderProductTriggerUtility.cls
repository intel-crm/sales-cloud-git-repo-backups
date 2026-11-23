/*********************************************************************************************************************
Class Name    : Sales_OrderProductTriggerUtility
Version       : 1.0
Created Date  : Dec 2020
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Srishty Sharma           30-Dec-2020              US862561:Order Product Trigger Utility 
* Srishty Sharma           22-Jan-2020              US862469:Price & Quantity Logic of a Order Product for different types of orders
* Srishty Sharma           01-Feb-2020              US862284:Validation rule to prevent  Products that involve license generator from Mentor graphics from being bought by Mentor graphics' competitors.
* Shivam Vishwakarma       13-Feb-2021              US919632: Renaming Field API
* *********************************************************************************************************************/
@isTest
public without sharing class Sales_OrderProductTriggerUtility {
    /*private static final String TOOL_LICENSE_TYPE_FIXED = 'FIXED';
    private static final String TOOL_LICENSE_TYPE_FLOAT = 'FLOAT';
    private static final String TOOL_LICENSE_TYPE_NEUTRAL = 'NEUTRAL';
    private static final String TOOL_LICENSE_TYPE_CORPORATE_BUNDLE = 'CORPORATE';
    private static final String TOOL_LICENSE_TYPE_OPTIONAL = 'Optional';
    private static final String CORE_PSG_TOOL_RENEWAL_TYPE = 'RENEWAL';
    private static final String CORE_PSG_TOOL_ADD_SEAT_TYPE = 'ADD SEAT';
    private static final String DISTI_ORDER_DISTI_CHANNEL='02';
    private static final String ORDER_TYPE_NONCOMMERCIALORDER = 'Non Commercial Order';
    private static final String ORDER_STATUS_DRAFT='Draft';
    private static final String PRODUCT_OPTION_TYPE_COMPONENT='Component';
    private static final String PRODUCT_OPTION_TYPE_ACCESSORY='Accessory';
    private static final String TOOL_LICENSE_TYPE_NA='N-A';
    private static final String LICENSE_STATUS_LICENSED='Licensed';
    private static Map<Id, Product2> productMap = new Map<Id, Product2>();
    private static Map<Id, Order> orderMap = new Map<Id,Order>();
    private static List<Sales_License_Order_Product__c> licOrdProdToDelete = new List<Sales_License_Order_Product__c>();
    private static List<Sales_License__c> licToUpdate = new List<Sales_License__c>();
    private static List<Sales_License_Order_Product__c> licOrdProdToUpdate = new List<Sales_License_Order_Product__c>();
    public static void beforeUpdateOrderProductUtility(List<OrderItem> orderProductList,Map<Id, OrderItem> oldMap, Map<Id, Order> ordMap){
        Set<Id> productIdSet = new Set<Id>();
        Map<Id,Id> orderToQuoteMap = new Map<Id,Id>();
        Map<Id,Id> orderToAccountMap = new Map<Id,Id>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        Map<Id,Core_Product_Ext_Attribute__c> psgToProductMap = new Map<Id,Core_Product_Ext_Attribute__c>();
        for(OrderItem orderProduct: orderProductList){
            productIdSet.add(orderProduct.Product2Id);
        }
        updateUnitPriceForQuotedOrder(orderProductList,productIdSet,ordMap.values());
    }
    public static void beforeInsertOrderProductUtility(List<OrderItem> orderProductList, Map<Id, Order> ordMap){
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        for(OrderItem orderProduct: orderProductList){
            productIdSet.add(orderProduct.Product2Id);
        }
        updateUnitPriceForQuotedOrder(orderProductList,productIdSet,ordMap.values());
    }
    public static void createSalesLicense(List<OrderItem> orderProductList, Map<Id, Order> ordMap, Set<Id> productIdSet,Boolean createOriginal, Boolean isOptionLicense, Sales_License__c parentLicense,Id renewalLicId){
        Integer expiryDatefromProduct=0;        
        List<Sales_License__c> newLicenseList = new List<Sales_License__c>();
        Map<Id,Set<String>> prodTypeMap = new Map<Id,Set<String>>();
        Map<Id,SBQQ__ProductOption__c> productOptionMap = new Map<Id,SBQQ__ProductOption__c>();
        Map<Id, Integer> mapOfProdIdLicCount = new Map<Id, Integer>();
        Map<Id, List<Sales_License__c>> mapOfProdIdLicenses = new Map<Id, List<Sales_License__c>>();
        Map<OrderItem, List<Sales_License__c>> mapOfOrdProdLicListForLinking = new Map<OrderItem, List<Sales_License__c>>();
        List<Sales_License__c> newLicenseListToInsert = new List<Sales_License__c>();
        Set<Id> contractIdsSet = new Set<Id>();
        String licenseType;
        Double qty; 
        for(Order ord: ordMap.values()){
            if(ord.SBQQ__Quote__r != null && ord.SBQQ__Quote__r.SBQQ__Type__c == 'Renewal' ||  ord.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){                
                if(ord.SBQQ__Quote__r.Sales_Renewed_from_Contract_Id__c != null){
                    contractIdsSet.add(ord.SBQQ__Quote__r.Sales_Renewed_from_Contract_Id__c);   
                }
                if(ord.SBQQ__Quote__r?.SBQQ__MasterContract__c != null){
                    contractIdsSet.add(ord.SBQQ__Quote__r.SBQQ__MasterContract__c);
                }
            }
        }
        for(Sales_License__c existingLic: [Select Id,Sales_License_Type__c, Sales_License_Order__c, Sales_License_Status__c,Sales_License_Lic_User_Contact_ID__c,Sales_License_Order_Product__c,Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Contract__c,
                                           Sales_License_Product__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,Sales_License_Avbl_Qty_Nbr__c, Sales_License_Quantity__c 
                                           from Sales_License__c where Sales_License_Contract__c IN: contractIdsSet and Sales_License_Type__c = 'Original' and Sales_License_Status__c != 'Cancelled' and Sales_License_Quantity__c>0]){
                                               Integer count = 0; 
                                               count = (Integer)existingLic.Sales_License_Quantity__c;
                                               if(mapOfProdIdLicCount.containsKey(existingLic.Sales_License_Product__c)){
                                                   mapOfProdIdLicCount.put(existingLic.Sales_License_Product__c, mapOfProdIdLicCount.get(existingLic.Sales_License_Product__c) + count);
                                               }else{
                                                   mapOfProdIdLicCount.put(existingLic.Sales_License_Product__c, count);
                                               }
                                               if(mapOfProdIdLicenses.containsKey(existingLic.Sales_License_Product__c)){
                                                   mapOfProdIdLicenses.get(existingLic.Sales_License_Product__c).add(existingLic);
                                               }else{
                                                   List<Sales_License__c> licList = new List<Sales_License__c>();
                                                   licList.add(existingLic);
                                                   mapOfProdIdLicenses.put(existingLic.Sales_License_Product__c, licList);
                                               }   
                                           }
        productMap = new Map<Id,Product2>([Select Id,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c ,Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
                                           (Select Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,SBQQ__Type__c,SBQQ__Bundled__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c from SBQQ__Options__r where SBQQ__Type__c IN(:PRODUCT_OPTION_TYPE_COMPONENT,:PRODUCT_OPTION_TYPE_ACCESSORY))
                                           from Product2 where Id IN:productIdSet 
                                           AND Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!=:TOOL_LICENSE_TYPE_CORPORATE_BUNDLE]);
        for(SBQQ__ProductOption__c productOption : [Select Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,SBQQ__Type__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c IN:productMap.keySet() And SBQQ__Type__c IN(:PRODUCT_OPTION_TYPE_COMPONENT,:PRODUCT_OPTION_TYPE_ACCESSORY)]){
            productOptionMap.put(productOption.Id,productOption);
            if(prodTypeMap.containsKey(productOption.SBQQ__ConfiguredSKU__c)){
                Set<String> typeSet = prodTypeMap.get(productOption.SBQQ__ConfiguredSKU__c);
                typeSet.add(productOption.SBQQ__Type__c);
                prodTypeMap.put(productOption.SBQQ__ConfiguredSKU__c,typeSet);
            }
            else{
                Set<String> typeSet = new Set<String>();
                typeSet.add(productOption.SBQQ__Type__c);
                prodTypeMap.put(productOption.SBQQ__ConfiguredSKU__c,typeSet);
            }
        }
        for(OrderItem orderProduct: orderProductList){ 
            List<Sales_License__c> newLicenseListForBundle = new List<Sales_License__c>();
            newLicenseList = new List<Sales_License__c>();
            if(!isOptionLicense){
                productIdSet.clear();
                productIdSet.add(orderProduct.Product2Id);
            }
            for(Id productId : productIdSet){ 
                if(createOriginal){
                    productId=orderProduct.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c;
                }
                if(productMap.containsKey(productId)){
                    qty = orderProduct.Quantity;
                    licenseType = 'Original';
                    if(!createOriginal){
                        if(productMap.get(productId).Core_Product_Ext_Attribute_Id__r != null && productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == CORE_PSG_TOOL_ADD_SEAT_TYPE)
                        {
                            licenseType=System.Label.Sales_Licencse_Add_Seat_record_type;
                        }
                        else if(ordMap.containsKey(orderProduct.OrderId) && ordMap.get(orderProduct.OrderId).SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' && mapOfProdIdLicCount.containsKey(productId) && orderProduct.Quantity < 0){
                            licenseType = System.Label.Sales_Amend_Contract_Qty_Decrease;    
                            if(orderProduct.Quantity < 0  && (orderProduct.Quantity + mapOfProdIdLicCount.get(productId) == 0)){
                                qty = 0;
                                mapOfOrdProdLicListForLinking.put(orderProduct, mapOfProdIdLicenses.get(productId));                              
                            }
                        }else if(productMap.get(productId).Core_Product_Ext_Attribute_Id__r != null && productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == CORE_PSG_TOOL_RENEWAL_TYPE){
                            licenseType = CORE_PSG_TOOL_RENEWAL_TYPE;          
                        }else if(ordMap.containsKey(orderProduct.OrderId) && ordMap.get(orderProduct.OrderId).SBQQ__Quote__r.SBQQ__Type__c == 'Renewal' && mapOfProdIdLicCount.containsKey(productId)){
                            qty = (orderProduct.Quantity - mapOfProdIdLicCount.get(productId));
                            if(qty >= 0){
                                mapOfOrdProdLicListForLinking.put(orderProduct, mapOfProdIdLicenses.get(productId));
                            }else{
                                licenseType = System.Label.Sales_Renew_Contract_Qty_Decrease;
                                qty = (orderProduct.Quantity); 
                            }                      
                        }
                    }                   
                    Set<String> typeSet = prodTypeMap.containsKey(productId)?prodTypeMap.get(productId):null;
                    if(qty != 0){
                        if(productMap.get(productId).SBQQ__Options__r.size()==0 || (typeSet!=null && typeSet.contains(PRODUCT_OPTION_TYPE_COMPONENT))){
                            expiryDatefromProduct=(Integer)productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c;                                                           
                            if(productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c==TOOL_LICENSE_TYPE_FIXED){
                                newLicenseList.addAll(processLicense(ordMap,orderProduct,qty,qty,false,expiryDatefromProduct,productId,licenseType));   
                            }
                            else if(productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c==TOOL_LICENSE_TYPE_FLOAT || 
                                    productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c==TOOL_LICENSE_TYPE_NEUTRAL|| 
                                    productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c==TOOL_LICENSE_TYPE_NA){
                                        newLicenseList.addAll(processLicense(ordMap,orderProduct, 1,qty, false,expiryDatefromProduct,productId,licenseType)); 
                                    }
                        }
                        else{
                            for(SBQQ__ProductOption__c productOption:productMap.get(productId).SBQQ__Options__r){
                                if(productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r != null && productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == CORE_PSG_TOOL_ADD_SEAT_TYPE)
                                {
                                    licenseType=System.Label.Sales_Licencse_Add_Seat_record_type;
                                }
                                else if(ordMap.containsKey(orderProduct.OrderId) && ordMap.get(orderProduct.OrderId).SBQQ__Quote__r?.SBQQ__Type__c == 'Amendment' && mapOfProdIdLicCount.containsKey(productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__c) && orderProduct.Quantity < 0){
                                    licenseType = System.Label.Sales_Amend_Contract_Qty_Decrease;    
                                    if(orderProduct.Quantity < 0  && (orderProduct.Quantity + mapOfProdIdLicCount.get(productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__c) == 0)){
                                        qty = 0;
                                        if(!mapOfOrdProdLicListForLinking.containsKey(orderProduct)){
                                            mapOfOrdProdLicListForLinking.put(orderProduct, mapOfProdIdLicenses.get(productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__c));                              
                                        }else{
                                            mapOfOrdProdLicListForLinking.get(orderProduct).addAll(mapOfProdIdLicenses.get(productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__c));                                   
                                        }
                                    }  
                                }else if(productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r != null && productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == CORE_PSG_TOOL_RENEWAL_TYPE){
                                    licenseType = CORE_PSG_TOOL_RENEWAL_TYPE;                                          
                                }else if(ordMap.containsKey(orderProduct.OrderId) && ordMap.get(orderProduct.OrderId).SBQQ__Quote__r.SBQQ__Type__c == 'Renewal' && mapOfProdIdLicCount.containsKey(productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__c)){
                                    qty = (orderProduct.Quantity - mapOfProdIdLicCount.get(productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__c));
                                    if(qty >= 0){
                                        if(!mapOfOrdProdLicListForLinking.containsKey(orderProduct)){
                                            mapOfOrdProdLicListForLinking.put(orderProduct, mapOfProdIdLicenses.get(productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__c));                              
                                        }else{
                                            mapOfOrdProdLicListForLinking.get(orderProduct).addAll(mapOfProdIdLicenses.get(productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__c));                                   
                                        }
                                    }else{
                                        licenseType =  System.Label.Sales_Renew_Contract_Qty_Decrease;
                                        qty = (orderProduct.Quantity); 
                                    }
                                }
                                else{
                                    licenseType = 'Original';
                                    qty = orderProduct.Quantity;
                                }
                                if(qty != 0){
                                    String toolLicenseType = productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c;
                                    expiryDatefromProduct=(Integer)productOptionMap.get(productOption.Id).SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c;
                                    if(toolLicenseType==TOOL_LICENSE_TYPE_FIXED){
                                        newLicenseListForBundle.addAll(processLicense(ordMap,orderProduct,qty,qty,false,expiryDatefromProduct,productOption.SBQQ__OptionalSKU__c,licenseType));
                                    }
                                    else if(toolLicenseType==TOOL_LICENSE_TYPE_FLOAT || toolLicenseType==TOOL_LICENSE_TYPE_NEUTRAL || toolLicenseType==TOOL_LICENSE_TYPE_NA){
                                        newLicenseListForBundle.addAll(processLicense(ordMap,orderProduct, 1,qty, false,expiryDatefromProduct,productOption.SBQQ__OptionalSKU__c,licenseType));
                                    }
                                }
                            }
                        }
                    }
                }            
            }
            newLicenseListToInsert.addAll(newLicenseList);
            newLicenseListToInsert.addAll(newLicenseListForBundle);
            if(mapOfOrdProdLicListForLinking.containsKey(orderProduct)){
                mapOfOrdProdLicListForLinking.get(orderProduct).addAll(newLicenseList);
                mapOfOrdProdLicListForLinking.get(orderProduct).addAll(newLicenseListForBundle);
            }else{
                mapOfOrdProdLicListForLinking.put(orderProduct, newLicenseList);
                mapOfOrdProdLicListForLinking.get(orderProduct).addAll(newLicenseListForBundle);
            }
        }
        if(isOptionLicense && parentLicense!=null){
            List<Sales_License__c> tempListList = new List<Sales_License__c>();
            for(Sales_License__c licRecord : newLicenseListToInsert){
                licRecord.Sales_License_Status__c=parentLicense.Sales_License_Status__c;
                licRecord.Sales_License_Expiration_Date_Dt__c=parentLicense.Sales_License_Expiration_Date_Dt__c;
                licRecord.Sales_License_Maintenance_Exp_Dt__c=parentLicense.Sales_License_Maintenance_Exp_Dt__c;
                licRecord.Sales_License_Primary_Admin_Contact__c = parentLicense.Sales_License_Primary_Admin_Contact__c;
                licRecord.Sales_License_Lic_User_Contact_ID__c=parentLicense.Sales_License_Lic_User_Contact_ID__c;
                licRecord.Sales_Parent_License__c = parentLicense.Id;
                licRecord.Sales_License_Internal_Comments_Txt__c=parentLicense.Sales_License_Internal_Comments_Txt__c;
                licRecord.Sales_License_Comments_Txt__c=parentLicense.Sales_License_Internal_Comments_Txt__c;
                if(parentLicense.Sales_License_Status__c == LICENSE_STATUS_LICENSED){
                    licRecord.Sales_License_Avbl_Qty_Nbr__c = 0;
                }                
                licRecord.Sales_License_Web_Display_Flag__c = false;
                licRecord.Sales_License_Avbl_Rehost_Nbr__c=parentLicense.Sales_License_Avbl_Rehost_Nbr__c;
                licRecord.Sales_License_Activation_Code__c=parentLicense.Sales_License_Activation_Code__c;
                licRecord.Sales_License_Type__c=TOOL_LICENSE_TYPE_OPTIONAL;
                licRecord.Sales_License_SAPLine_Nbr__c=parentLicense.Sales_License_SAPLine_Nbr__c;
                licRecord.Sales_License_Contract__c=parentLicense.Sales_License_Contract__c;
                licRecord.Sales_License_Host_Node_Id__c = parentLicense.Sales_License_Host_Node_Id__c;
                licRecord.Sales_License_Start_Date_Dt__c = parentLicense.Sales_License_Start_Date_Dt__c;
                if(parentLicense.Sales_License_Account__c!=null){
                    licRecord.Sales_License_Account__c=parentLicense.Sales_License_Account__c;
                }
                tempListList.add(licRecord); 
            }
            newLicenseListToInsert.clear();
            newLicenseListToInsert.addAll(tempListList);
        }
        if(!newLicenseListToInsert.isEmpty()){
            insert newLicenseListToInsert;
        }
        createLicenseOrderProducts(null,mapOfOrdProdLicListForLinking,null);
    }
    private static List<Sales_License__c> processLicense(Map<Id, Order> ordMap, OrderItem orderProduct, Decimal numberOfLic, Double qty, Boolean isBundle,Integer expiryDatefromProduct, Id productId, String licenseType){
        List<Sales_License__c> licenceReturnList = new List<Sales_License__c>();
        if(licenseType == 'Renewal'|| licenseType==System.Label.Sales_Amend_Contract_Qty_Decrease
           ||licenseType== System.Label.Sales_Renew_Contract_Qty_Decrease || licenseType==System.Label.Sales_Licencse_Add_Seat_record_type ){
               numberOfLic = 1;
           }                
        for (Integer i = 0; i < (Integer)numberOfLic; i++) {
            Sales_License__c newLic = new Sales_License__c();
            newLic.Sales_License_Avbl_Qty_Nbr__c = numberOfLic>1 ? 1 :qty;
            newLic.Sales_License_Quantity__c = numberOfLic>1 ? 1 :qty;
            newLic.Sales_License_Product__c = productId;
            newLic.Sales_License_Order_Product__c=orderProduct.Id;
            newLic.Sales_License_Order__c =orderProduct.OrderId;
            newLic.Sales_License_Type__c = licenseType;
            newLic.Sales_License_Status__c = 'Unlicensed';
            Order ord = ordMap.get(orderProduct.OrderId);
            if(ord.Sales_Order_Reason__c != 'Stocking Order' && ord.Type != null){
                newLic.Sales_License_Account__c = ord.AccountId;
            }
            String key=String.valueOf(newLic.Sales_License_Product__c)+String.valueOf(newLic.Sales_License_Order_Product__c)+String.valueOf(newLic.Sales_License_Product__c);
            licenceReturnList.add(newLic);
        }
        return licenceReturnList;
    }          
    public static void createLicenseProductInstance(Map<OrderItem, List<Sales_License__c>> mapofordprod,Map<Id,Id> childLicIdToRenwlLicIdMap,Map<Id, OrderItem> licToOrdItemMap,Id renewlicid,List<Sales_License_Order_Product__c> licOrderProdListToInsert){
        for(OrderItem ordItm: mapofordprod.keyset()){
            List<Sales_License__c> licList = mapofordprod.get(ordItm);                 
            if(!licList.isEmpty()){
                for(Sales_License__c lic: licList){
                    licToOrdItemMap.put(lic.id, ordItm);
                    if(renewlicid!=null)
                        childLicIdToRenwlLicIdMap.put(lic.id,renewlicid);
                    Sales_License_Order_Product__c licOrdPrd = new Sales_License_Order_Product__c();
                    licOrdPrd.Sales_License__c = lic.id;
                    licOrdPrd.Sales_Order_Product__c = ordItm.Id;
                    if(lic.Sales_License_Status__c=='Licensed'){
                        licOrdPrd.Sales_License_ContractId__c = lic.Sales_License_Contract__c;
                        licOrdPrd.Sales_License_Expiration_Date_Dt__c=lic.Sales_License_Expiration_Date_Dt__c;
                        licOrdPrd.Sales_Renewable_license__c=renewlicid;
                    }
                    licOrdPrd.Sales_Quantity__c = lic.Sales_License_Quantity__c; 
                    licOrderProdListToInsert.add(licOrdPrd);    
                }
            } 
        }
    }
    public static List<Sales_License_Order_Product__c> createLicenseOrderProducts(Map<Id,Map<OrderItem, List<Sales_License__c>>> mapOfOrdProdLicListForLinking,Map<OrderItem, List<Sales_License__c>> mapofOrdPrdtoLicList,Set<Id> setofrenewalId){
        List<Sales_License_Order_Product__c> licOrderProdListToInsert = new List<Sales_License_Order_Product__c>();
        Map<Id,Id> childLicIdToRenwlLicIdMap= new Map<Id,Id>();
        if((mapOfOrdProdLicListForLinking != null && !mapOfOrdProdLicListForLinking.isEmpty()) || (mapofOrdPrdtoLicList!=null && !mapofOrdPrdtoLicList.isEmpty())){            
            Map<Id, OrderItem> licToOrdItemMap = new Map<Id, OrderItem>();
            if(setofrenewalId!=null && !setofrenewalId.isEmpty()){
                for(Id renewlicid:setofrenewalId){
                    Map<OrderItem, List<Sales_License__c>> mapofordprod=mapOfOrdProdLicListForLinking.get(renewlicid);
                    createLicenseProductInstance(mapofordprod,childLicIdToRenwlLicIdMap,licToOrdItemMap,renewlicid,licOrderProdListToInsert);
                }
            }else{
                createLicenseProductInstance(mapofOrdPrdtoLicList,childLicIdToRenwlLicIdMap,licToOrdItemMap,null,licOrderProdListToInsert);
            }
            if(!licToOrdItemMap.isEmpty()){
                for(Sales_License__c childLic: [Select Id,Sales_License_Maintenance_Exp_Dt__c, Sales_License_Quantity__c,Sales_Parent_License__r.Sales_License_Maintenance_Exp_Dt__c, Sales_Parent_License__c,Sales_Parent_License__r.Sales_License_Status__c,Sales_Parent_License__r.Sales_License_Expiration_Date_Dt__c,Sales_Parent_License__r.Sales_License_Contract__c from Sales_License__c where Sales_Parent_License__c IN: licToOrdItemMap.keySet() and Sales_Parent_License__c!=null ]){
                    Sales_License_Order_Product__c licOrdPrd = new Sales_License_Order_Product__c();
                    OrderItem ordProd = licToOrdItemMap.get(childLic.Sales_Parent_License__c);
                    if(childLic.Sales_Parent_License__r.Sales_License_Status__c=='Licensed'){
                        licOrdPrd.Sales_License_ContractId__c = childLic.Sales_Parent_License__r.Sales_License_Contract__c;
                        licOrdPrd.Sales_License_Expiration_Date_Dt__c=childLic.Sales_Parent_License__r.Sales_License_Expiration_Date_Dt__c;
                        licOrdPrd.Sales_License_Order_Prod_Maint_Exp_Dt__c=childLic.Sales_Parent_License__r.Sales_License_Maintenance_Exp_Dt__c;
                        licOrdPrd.Sales_Renewable_license__c=childLicIdToRenwlLicIdMap.containsKey(childLic.Sales_Parent_License__c)?childLicIdToRenwlLicIdMap.get(childLic.Sales_Parent_License__c):null;
                    }
                    licOrdPrd.Sales_Quantity__c=childLic.Sales_License_Quantity__c;
                    licOrdPrd.Sales_License__c = childLic.id;
                    licOrdPrd.Sales_Order_Product__c = ordProd.Id;      
                    licOrderProdListToInsert.add(licOrdPrd);                                            
                }
            }
            insert licOrderProdListToInsert;
        }   
        return licOrderProdListToInsert;
    }
    public static void updateUnitPriceForQuotedOrder(List<OrderItem> orderProductList, Set<Id>productIdSet, List<Order>orderList ){
        Map<Id,Id> orderToQuoteMap = new Map<Id,Id>();
        Map<Id,Id> orderToAccountMap = new Map<Id,Id>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        Map<Id,SBQQ__QuoteLine__c> qlineMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Id> quotelineToQuoteMap = new Map<Id,Id>();
        Map<Id,Core_Product_Ext_Attribute__c> psgToProductMap = new Map<Id,Core_Product_Ext_Attribute__c>();
        for(Order ord: orderList){
            if(ord.SBQQ__Quote__c != null){
                orderToQuoteMap.put(ord.Id,ord.SBQQ__Quote__c);
                orderToAccountMap.put(ord.Id,ord.Sales_Sold_To_Account__c);
                orderMap.put(ord.Id,ord);
            }
        }
        Map<Id,Account> accountMap = new Map<Id,Account>([Select id,Type,Core_Account_Type__c,Core_Direct_Distributor_Channel_Nm__c from Account where Id IN:orderToAccountMap.values()]);
        for(Core_Product_Ext_Attribute__c psg : [Select Id ,Core_Prod_Tool_Type_Nm__c,Core_Product_Id__c from Core_Product_Ext_Attribute__c where Core_Product_Id__c IN: productIdSet AND Core_Prod_Tool_Type_Nm__c='CORPORATE']){
            psgToProductMap.put(psg.Core_Product_Id__c,psg); 
        }
        for(SBQQ__QuoteLine__c quoteLine:[Select Id,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__PriceBook__r.Name,SBQQ__Product__c,price_brokencost_amt__c,price_requested_resale_amt__c,price_suggested_resale_amt__c,price_disty_cost_nbr__c,SBQQ__ListPrice__c
                                          from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:orderToQuoteMap.values() order by SBQQ__Quote__c]){
                                              qlineMap.put(quoteLine.Id,quoteLine);
                                              quotelineToQuoteMap.put(quoteLine.Id,quoteLine.SBQQ__Quote__c);
                                          }
        for(OrderItem item:orderProductList){
            if(orderToQuoteMap.containsKey(item.OrderId)){
                Id quoteId = orderToQuoteMap.get(item.OrderId);
                if(qlineMap.size()>0 && quotelineToQuoteMap.size()>0 && item.UnitPriceForceOverride__c==null){
                    Id accountId = orderToAccountMap.get(item.OrderId);
                    Account accountRecord = accountMap.get(accountId);
                    if((item.SBQQ__QuoteLine__c!= null && qlineMap.get(item.SBQQ__QuoteLine__c) != null && item.SBQQ__QuoteLine__c == qlineMap.get(item.SBQQ__QuoteLine__c).id) && (item.Product2Id == qlineMap.get(item.SBQQ__QuoteLine__c).SBQQ__Product__c ) && (orderMap.get(item.OrderId).type!=ORDER_TYPE_NONCOMMERCIALORDER) && (orderMap.get(item.OrderId).Status=='Draft') && (orderMap.get(item.OrderId).Sales_Sold_To_Account__c!=null) && (accountRecord.Core_Direct_Distributor_Channel_Nm__c==DISTI_ORDER_DISTI_CHANNEL)){
                        item.UnitPrice = qlineMap.get(item.SBQQ__QuoteLine__c).price_brokencost_amt__c!=null?qlineMap.get(item.SBQQ__QuoteLine__c).price_brokencost_amt__c:0;  
                        item.Sales_Broken_Price_Amt__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_brokencost_amt__c;   
                        item.Sales_Suggested_Resale_Price__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_suggested_resale_amt__c;  
                    }
                    else if((item.SBQQ__QuoteLine__c!= null && qlineMap.get(item.SBQQ__QuoteLine__c) != null && item.SBQQ__QuoteLine__c==qlineMap.get(item.SBQQ__QuoteLine__c).id) && (item.Product2Id == qlineMap.get(item.SBQQ__QuoteLine__c).SBQQ__Product__c ) && (orderMap.get(item.OrderId).type!=ORDER_TYPE_NONCOMMERCIALORDER)  && (orderMap.get(item.OrderId).Status=='Draft') && (orderMap.get(item.OrderId).Sales_Sold_To_Account__c!=null) && ((accountRecord.Core_Direct_Distributor_Channel_Nm__c=='01')||(accountRecord.Core_Direct_Distributor_Channel_Nm__c=='04'))){
                        item.UnitPrice = qlineMap.get(item.SBQQ__QuoteLine__c).price_suggested_resale_amt__c!=null?qlineMap.get(item.SBQQ__QuoteLine__c).price_suggested_resale_amt__c:0;
                        item.Sales_Broken_Price_Amt__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_brokencost_amt__c;  
                        item.Sales_Suggested_Resale_Price__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_suggested_resale_amt__c;   
                    }
                    else if((item.SBQQ__QuoteLine__c!= null && qlineMap.get(item.SBQQ__QuoteLine__c) != null && item.SBQQ__QuoteLine__c==qlineMap.get(item.SBQQ__QuoteLine__c).id) && (item.Product2Id == qlineMap.get(item.SBQQ__QuoteLine__c).SBQQ__Product__c ) && (orderMap.get(item.OrderId).type==ORDER_TYPE_NONCOMMERCIALORDER)  && (orderMap.get(item.OrderId).Status=='Draft')){
                        item.UnitPrice = 0;
                        item.Sales_Broken_Price_Amt__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_brokencost_amt__c; 
                        item.Sales_Suggested_Resale_Price__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_suggested_resale_amt__c;   
                    }
                }
            }
        }
    }
    public static void checkCompetitorAccountVsProduct(List<OrderItem> orderItemList){
        Sales_LicenseValidationCheckUtilty.addErrorOnOrderItem(orderItemList);
    }
    public static void checkOrderProductsFromQuoteLines(List<OrderItem> orderItemList){
        Sales_OrderCreationValidationUtility.validateOrderProducts(orderItemList); 
    }
    public static void restrictOrderProductCreation(List<OrderItem> orderItemList, Map<id, order> ordMap){
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderIdsWithQuote = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        Map<Id,Id> orderQuoteMap = new Map<Id,Id>();
        Map<Id,Map<Id,Integer>> orderToProductLineMapOnOrderItem = new Map<Id,Map<Id,Integer>>();
        Map<Id,Map<Id,Integer>> quoteToProductQuanityMapOnQuoteLine = new Map<Id,Map<Id,Integer>>();
        for(OrderItem orderProduct : orderItemList){
            if(ordMap.containsKey(orderProduct.OrderId) && ordMap.get(orderProduct.OrderId).SBQQ__Quote__c != null){
                quoteIds.add(ordMap.get(orderProduct.OrderId).SBQQ__Quote__c);
                orderIdsWithQuote.add(orderProduct.OrderId);
                orderQuoteMap.put(orderProduct.OrderId,ordMap.get(orderProduct.OrderId).SBQQ__Quote__c);
            }
        }
        for(OrderItem orderLine:[Select OrderId,Product2Id from OrderItem where OrderId IN:orderIdsWithQuote order by OrderId]){
            Map<Id,Integer> productLineMap = new Map<Id,Integer>();
            if(orderToProductLineMapOnOrderItem.containsKey(orderLine.OrderId)){
                productLineMap = orderToProductLineMapOnOrderItem.get(orderLine.OrderId);
                if(productLineMap.containsKey(orderLine.Product2Id)){
                    Integer productLineCount = productLineMap.get(orderLine.Product2Id);
                    productLineCount+=1;
                    productLineMap.put(orderLine.Product2Id,productLineCount);
                }
                else{
                    productLineMap.put(orderLine.Product2Id,1);
                }
                orderToProductLineMapOnOrderItem.put(orderLine.OrderId,productLineMap);
            }
            else{
                productLineMap.put(orderLine.Product2Id,1);
                orderToProductLineMapOnOrderItem.put(orderLine.OrderId,productLineMap); 
            }
        }
        for(SBQQ__QuoteLine__c quoteLine:[Select SBQQ__Quote__c,SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:quoteIds order by SBQQ__Quote__c]){
            Map<Id,Integer> productQuantityMap = new Map<Id,Integer>();
            if(quoteToProductQuanityMapOnQuoteLine.containsKey(quoteLine.SBQQ__Quote__c)){
                productQuantityMap = quoteToProductQuanityMapOnQuoteLine.get(quoteLine.SBQQ__Quote__c);
                if(productQuantityMap.containsKey(quoteLine.SBQQ__Product__c)){
                    Integer productQuantity = productQuantityMap.get(quoteLine.SBQQ__Product__c);
                    productQuantity+=1;
                    productQuantityMap.put(quoteLine.SBQQ__Product__c,productQuantity);
                }
                else{
                    productQuantityMap.put(quoteLine.SBQQ__Product__c,1);
                }
                quoteToProductQuanityMapOnQuoteLine.put(quoteLine.SBQQ__Quote__c,productQuantityMap);
            }
            else{
                productQuantityMap.put(quoteLine.SBQQ__Product__c,1);
                quoteToProductQuanityMapOnQuoteLine.put(quoteLine.SBQQ__Quote__c,productQuantityMap); 
            }
        }
        for(OrderItem orderProduct : orderItemList){
            if(orderIdsWithQuote.contains(orderProduct.OrderId)){
                Map<Id,Integer> productQuantityOnOrderMap = new Map<Id,Integer>();
                Map<Id,Integer> productQuantityOnQuoteMap = new Map<Id,Integer>();
                Id productId = orderProduct.Product2Id;
                productQuantityOnOrderMap = orderToProductLineMapOnOrderItem.get(orderProduct.OrderId);
                Integer existingProductCount = productQuantityOnOrderMap!=null && productQuantityOnOrderMap.containsKey(productId) ? productQuantityOnOrderMap.get(productId):0;
                Integer totalProductLineCount = existingProductCount+1;
                Id quoteId = orderQuoteMap.get(orderProduct.OrderId);
                productQuantityOnQuoteMap = quoteToProductQuanityMapOnQuoteLine.get(quoteId);
                Integer productCountOnLineItem = productQuantityOnQuoteMap!=null && productQuantityOnQuoteMap.containsKey(productId)? productQuantityOnQuoteMap.get(productId):0;
                if(totalProductLineCount>productCountOnLineItem){
                    orderProduct.addError(System.Label.Sales_RestrictOderProductCreation_Error);
                }
            }
        }
    }
    public static void populateListPriceBasedonQty(List<OrderItem> orderItemList, Map<Id, Order> ordMap){
        Set<String> pricebookEntryIds = new Set<String>();
        Set<Id> ordIds = new Set<Id>();
        Set<Id> pricebookIds = new Set<Id>();
        List<Order> orderList;
        Boolean isBlankPricebook = false;
        Set<Id> productIds = new Set<Id>();
        Map<String,String> orderItemIdsMap = new Map<String,String>();
        for(OrderItem pi : orderItemList){
            if(String.isBlank(pi.PricebookEntryId)){
                isBlankPricebook = true;
            }else{
                pricebookEntryIds.add(String.valueOf(pi.PricebookEntryId)); 
            }
            ordIds.add(pi.OrderId);  
            productIds.add(pi.Product2Id);
        }
        if(isBlankPricebook){
            if(ordIds.size() > 0){
                orderList = new List<Order>([SELECT Id, Pricebook2Id from Order WHERE id IN :ordIds]);
            }
            for(Order ord : orderList){
                pricebookIds.add(ord.Pricebook2Id);
            }
            if(pricebookIds.size()>0 && productIds.size()>0){
                for(PricebookEntry pbentryId : [select id,Product2Id from PriceBookEntry where Pricebook2Id IN:pricebookIds and Product2Id IN:productIds]){         
                    orderItemIdsMap.put(pbentryId.Product2Id, pbentryId.Id);
                }
            } 
            for(OrderItem pi : orderItemList){
                if(String.isBlank(pi.PricebookEntryId) && String.isNotBlank(pi.Product2Id)){
                    if(orderItemIdsMap.size() > 0){
                        pi.PricebookEntryId = orderItemIdsMap.get(pi.Product2Id);
                    }
                }
                pricebookEntryIds.add(String.valueOf(pi.PricebookEntryId)); 
            }
        }
        Map<Id,PricebookEntry> pbEntryMap = new Map<Id,PricebookEntry>();
        Map<id, List<core_cpq_list_price__c>> pbeIdVsListPriceMap = new Map<id, List<core_cpq_list_price__c>>();
        List<core_cpq_list_price__c> listPriceLst = new List<core_cpq_list_price__c>();
        if(pricebookEntryIds.size()>0){
            for(PricebookEntry pbEntry : [Select Id,UnitPrice,price_disty_cost__c,Product2Id from PricebookEntry where Id IN:pricebookEntryIds And Product2Id IN:productIds]){
                pbEntryMap.put(pbEntry.Id,pbEntry);
            }
        }
        if(pricebookEntryIds.size()>0){
            listPriceLst = [select id, core_cpq_list_price_amt__c, core_cpq_lowerbound_qty__c, core_cpq_upperbound_qty__c, core_cpq_product_name__c, Pricebookentry__c from core_cpq_list_price__c where Pricebookentry__c in: pricebookEntryIds And core_cpq_product_name__c in: productIds]; 
        }
        if(listPriceLst.size()>0){
            for(core_cpq_list_price__c listPriceRec: listPriceLst){
                if(pbeIdVsListPriceMap.containsKey(listPriceRec.Pricebookentry__c)){
                    List<core_cpq_list_price__c> listPriceRecLst = pbeIdVsListPriceMap.get(listPriceRec.Pricebookentry__c);
                    listPriceRecLst.add(listPriceRec);
                    pbeIdVsListPriceMap.put(listPriceRec.Pricebookentry__c, listPriceRecLst);
                }else{
                    pbeIdVsListPriceMap.put(listPriceRec.Pricebookentry__c, new List<core_cpq_list_price__c> { listPriceRec });
                }
            }
        }
        for(OrderItem orderProduct : orderItemList){
            orderProduct.Sales_Disti_cost__c = pbEntryMap.get(orderProduct.PricebookEntryId)?.price_disty_cost__c;
            if((pbeIdVsListPriceMap.size()>0) && (pbeIdVsListPriceMap.containsKey(orderProduct.PricebookEntryId)) && (pbeIdVsListPriceMap.get(orderProduct.PricebookEntryId)!=null)  && (ordMap.get(orderProduct.OrderId).Status==ORDER_STATUS_DRAFT)){
                for(core_cpq_list_price__c listPriceRec: pbeIdVsListPriceMap.get(orderProduct.PricebookEntryId)){
                    if(orderProduct.Quantity>=listPriceRec.core_cpq_lowerbound_qty__c && (orderProduct.Quantity<=listPriceRec.core_cpq_upperbound_qty__c || listPriceRec.core_cpq_upperbound_qty__c==null)){
                        if((orderProduct.SBQQ__QuoteLine__c==null)  && (ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__c!=null) && (((ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='01') || (ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='04')) && (orderProduct.UnitPriceForceOverride__c==null) && (ordMap.get(orderProduct.OrderId).type!=ORDER_TYPE_NONCOMMERCIALORDER))){
                            orderProduct.UnitPrice=listPriceRec.core_cpq_list_price_amt__c;
                        }
                        orderProduct.Sales_Column_resale_price__c=listPriceRec.core_cpq_list_price_amt__c;
                    }
                }
            }
            else if((ordMap.get(orderProduct.OrderId).Status==ORDER_STATUS_DRAFT)){
                if((orderProduct.UnitPriceForceOverride__c==null) && (orderProduct.SBQQ__QuoteLine__c==null) && (ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__c!=null) && (((ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='01')|| (ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='04')) && (ordMap.get(orderProduct.OrderId).type!=ORDER_TYPE_NONCOMMERCIALORDER))){
                    orderProduct.UnitPrice = pbEntryMap.get(orderProduct.PricebookEntryId)?.UnitPrice;
                }
                orderProduct.Sales_Column_resale_price__c = pbEntryMap.get(orderProduct.PricebookEntryId)?.UnitPrice;
            }
        }
    }
    public static void populateSAPLACRule(List<OrderItem> orderItemList){
        Map<String,String> sapLACMapping=new Map<String,String>();
        Map<Id,Product2> prodMap;
        Map<Id,Order> orderMap;
        Set<Id> prodIdSet =new Set<Id>();
        Set<Id> orderIdSet =new Set<Id>();
        for(Sales_Order_SAP_LAC_Rule__mdt lacMap:[Select Sales_Order_Reason_Type__c,Sales_SAP_LAC_Rule_Value__c,Sales_Tool_License_Type__c,Sales_Tool_Type__c from Sales_Order_SAP_LAC_Rule__mdt]){
            String key=lacMap.Sales_Order_Reason_Type__c+lacMap.Sales_Tool_License_Type__c+lacMap.Sales_Tool_Type__c;
            sapLACMapping.put(key, lacMap.Sales_SAP_LAC_Rule_Value__c);
        }
        for(OrderItem item:orderItemList){
            orderIdSet.add(item.OrderId);
            prodIdSet.add(item.Product2Id);
        }
        orderMap=new Map<Id,Order>([Select Id,Sales_Order_Reason__c from Order where Id IN:orderIdSet]);
        prodMap= new Map<Id,Product2>([Select Id,Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from Product2 where Id IN:prodIdSet]);
        for(OrderItem item:orderItemList){
            String toolTypeOfOrderItem=prodMap.get(item.Product2Id).Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c;
            String toolLicenceOfOderItem=prodMap.get(item.Product2Id)?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Type_Nm__c;
            String orderReason=orderMap.get(item.OrderId)?.Sales_Order_Reason__c;
            String key =orderReason+toolLicenceOfOderItem+toolTypeOfOrderItem;
            if(sapLACMapping!=null ){
                if(sapLACMapping.containsKey(key)){
                    item.Sales_SAP_LAC_Rule_Txt__c= sapLACMapping.get(key);
                }
                else{
                    key=orderReason+toolLicenceOfOderItem+null;
                    if(sapLACMapping.containsKey(key)){
                        item.Sales_SAP_LAC_Rule_Txt__c= sapLACMapping.get(key);
                    }
                }
            }
        }
    }
    public static void updateLicenseRecordsOnUpdatingQty(Map<Id, OrderItem> newOrdProdMap, Map<Id, OrderItem> oldOrderProdMap, Map<Id, Order> ordMap){  
        Set<id> productIdSet = new Set<Id>();
        Map<OrderItem, List<Sales_License__c>> licOrdProdMap = new  Map<OrderItem, List<Sales_License__c>>();
        List<Sales_License__c> licensesToDeleteList = new List<Sales_License__c>();
        List<Sales_License__c> licensesToUpsertList = new List<Sales_License__c>();
        Map<Id, OrderItem> originalOrdProdMap = new Map<Id, OrderItem>();
        Map<Id, List<Sales_License_Order_Product__c>> ordProdIdlicOrdProdListMap = new Map<Id, List<Sales_License_Order_Product__c>>(); 
        Map<Id, Sales_License_Order_Product__c> ordProdRenewalAmendLicenseMap = new Map<Id, Sales_License_Order_Product__c>();
        Set<Id> contractIdSet = new Set<Id>();
        for(Sales_License_Order_Product__c licOrdProd : [Select Id,Sales_Quantity__c,Sales_order_Product__r.Order.SBQQ__Quote__r.Sales_Renewed_from_Contract_Id__c, Sales_License__c,Sales_License__r.Sales_License_Type__c,Sales_License__r.Sales_License_Order_Product__c, Sales_Order_Product__c, Sales_Order_Product__r.Product2Id,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c from Sales_License_Order_Product__c where Sales_Order_Product__c IN: newOrdProdMap.keyset() order by Sales_License__r.CreatedDate desc]){      
            productIdSet.add(licOrdProd.Sales_Order_Product__r.Product2Id);
            if(licOrdProd.Sales_order_Product__r.Order.SBQQ__Quote__r?.Sales_Renewed_from_Contract_Id__c != null){
                contractIdSet.add(licOrdProd.Sales_order_Product__r.Order.SBQQ__Quote__r?.Sales_Renewed_from_Contract_Id__c);
            }
            if(ordProdIdlicOrdProdListMap.containskey(licOrdProd.Sales_Order_Product__c)){
                ordProdIdlicOrdProdListMap.get(licOrdProd.Sales_Order_Product__c).add(licOrdProd);
            }else{
                List<Sales_License_Order_Product__c> licOrdProdList = new List<Sales_License_Order_Product__c>();
                licOrdProdList.add(licOrdProd);
                ordProdIdlicOrdProdListMap.put(licOrdProd.Sales_Order_Product__c, licOrdProdList);
            }
            if(licOrdProd.Sales_License__r.Sales_License_Type__c != 'Original'){
                ordProdRenewalAmendLicenseMap.put(licOrdProd.Sales_Order_Product__c, licOrdProd);
            }
        }
        for(OrderItem originalOrdProd: [Select id, Product2Id, Quantity from OrderItem where Product2Id IN :productIdSet and SBQQ__Contract__c IN: contractIdSet]){
            originalOrdProdMap.put(originalOrdProd.Product2Id, originalOrdProd);    
        }
        productMap = new Map<Id,Product2>([Select Id,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c ,Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
                                           (Select Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,SBQQ__Type__c,SBQQ__Bundled__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c from SBQQ__Options__r where SBQQ__Type__c IN(:PRODUCT_OPTION_TYPE_COMPONENT,:PRODUCT_OPTION_TYPE_ACCESSORY))
                                           from Product2 where Id IN:productIdSet 
                                           AND Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!=:TOOL_LICENSE_TYPE_CORPORATE_BUNDLE]);
        for(OrderItem newOrdProd: newOrdProdMap.values()){          
            OrderItem oldOrdProd = oldOrderProdMap.get(newOrdProd.id);
            Order ord = ordMap.get(newOrdProd.OrderId);
            if(ord != null && (!productMap.isEmpty())){
                if((ord.SBQQ__Quote__c == null || ord.SBQQ__Quote__c != null && ord.SBQQ__Quote__r.SBQQ__Type__c == 'Quote') && productMap?.get(newOrdProd.Product2Id)?.Core_Product_Ext_Attribute_Id__r?.Core_Prod_Tool_Type_Nm__c != 'Renewal' && productMap.get(newOrdProd?.Product2Id)?.Core_Product_Ext_Attribute_Id__r?.Core_Prod_Tool_Type_Nm__c != 'Add Seat'){         
                    if(newOrdProd.Quantity > oldOrdProd.Quantity){  
                        if(productMap.get(newOrdProd.Product2Id)?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Type_Nm__c == 'FIXED'){
                            licensesToUpsertList.addAll(createLicenseRecords(newOrdProd, productMap.get(newOrdProd.Product2Id), productMap.get(newOrdProd.Product2Id).SBQQ__Options__r, (newOrdProd.Quantity - oldOrdProd.Quantity).intValue(), ordMap));                       
                        }else{
                            deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd, (newOrdProd.Quantity).intValue(), false, false);
                        }
                    }else{
                        licensesToDeleteList.addAll(deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd, (oldOrdProd.Quantity - newOrdProd.Quantity).intValue(), false, true));
                    }
                }else if(productMap.get(newOrdProd.Product2Id).Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'Add Seat' ){          
                    licensesToUpsertList.add(updateDummyLicenseRecord(newOrdProd, ordProdRenewalAmendLicenseMap.get(newOrdProd.id),  (newOrdProd.Quantity).intValue(), 'Add Seat'));            
                }
                else if(productMap.get(newOrdProd.Product2Id).Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'Renewal'){
                    licensesToUpsertList.add(updateDummyLicenseRecord(newOrdProd, ordProdRenewalAmendLicenseMap.get(newOrdProd.id),  (newOrdProd.Quantity).intValue(), 'Renewal'));
                }else if(ord.SBQQ__Quote__c != null && ord.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){    
                    if(oldOrdProd.Quantity < 0 && newOrdProd.Quantity < 0){
                        licensesToDeleteList.addAll(deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd,  ordProdIdlicOrdProdListMap.get(newOrdProd.id).size(), false, true));               
                        licensesToUpsertList.add(updateDummyLicenseRecord(newOrdProd, ordProdRenewalAmendLicenseMap.get(newOrdProd.id), (newOrdProd.Quantity).intvalue(), System.Label.Sales_Amend_Contract_Qty_Decrease));                            
                    }else if(oldOrdProd.Quantity < 0 && newOrdProd.Quantity > 0){
                        licensesToDeleteList.addAll(deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd,  ordProdIdlicOrdProdListMap.get(newOrdProd.id).size(), true, true));                
                        licensesToUpsertList.addAll(createLicenseRecords(newOrdProd, productMap.get(newOrdProd.Product2Id), productMap.get(newOrdProd.Product2Id).SBQQ__Options__r,  (newOrdProd.Quantity).intValue(), ordMap));                    
                    }else if(oldOrdProd.Quantity > 0 && newOrdProd.Quantity > 0 && newOrdProd.Quantity > oldOrdProd.Quantity){
                        if(productMap.get(newOrdProd.Product2Id)?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Type_Nm__c == 'FIXED'){
                            licensesToUpsertList.addAll(createLicenseRecords(newOrdProd, productMap.get(newOrdProd.Product2Id), productMap.get(newOrdProd.Product2Id).SBQQ__Options__r, (newOrdProd.Quantity - oldOrdProd.Quantity).intValue(), ordMap));                   
                        }else{
                            deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd, (newOrdProd.Quantity).intValue(), false, false);    
                        }
                    }else if(oldOrdProd.Quantity > 0 && newOrdProd.Quantity > 0 && newOrdProd.Quantity < oldOrdProd.Quantity){
                        licensesToDeleteList.addAll(deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd, (oldOrdProd.Quantity - newOrdProd.Quantity).intValue(), false, true));  
                    }else if(oldOrdProd.Quantity > 0 && newOrdProd.Quantity < 0){
                        licensesToDeleteList.addAll(deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd, (oldOrdProd.Quantity).intValue(), false, true));    
                        licensesToUpsertList.add(updateDummyLicenseRecord(newOrdProd, ordProdRenewalAmendLicenseMap.get(newOrdProd.id),  (newOrdProd.Quantity).intValue(), System.Label.Sales_Amend_Contract_Qty_Decrease));
                    }
                }else if(ord.SBQQ__Quote__c != null && ord.SBQQ__Quote__r.SBQQ__Type__c == 'Renewal' && originalOrdProdMap.containskey(newOrdProd.Product2Id)){
                    if(originalOrdProdMap.get(newOrdProd.Product2Id).Quantity < oldOrdProd.Quantity){
                        if(oldOrdProd.Quantity > newOrdProd.Quantity){
                            if(newOrdProd.Quantity < originalOrdProdMap.get(newOrdProd.Product2Id).Quantity){
                                licensesToDeleteList.addAll(deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd, ordProdIdlicOrdProdListMap.get(newOrdProd.id).size(), true, true)); 
                                licensesToUpsertList.add(updateDummyLicenseRecord(newOrdProd, ordProdRenewalAmendLicenseMap.get(newOrdProd.id),  (newOrdProd.Quantity).intValue(), System.Label.Sales_Renew_Contract_Qty_Decrease));
                            }else{
                                licensesToDeleteList.addAll(deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd,(oldOrdProd.Quantity - newOrdProd.Quantity).intValue()  , true, true));                                  
                            }
                        }else{
                            licensesToUpsertList.addAll(createLicenseRecords(newOrdProd, productMap.get(newOrdProd.Product2Id), productMap.get(newOrdProd.Product2Id).SBQQ__Options__r,  (newOrdProd.Quantity - oldOrdProd.Quantity).intValue(), ordMap));                      
                        }
                    }else{
                        licensesToDeleteList.addAll(deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd, (newOrdProd.Quantity).intValue(), false, true));    
                        licensesToUpsertList.add(updateDummyLicenseRecord(newOrdProd, ordProdRenewalAmendLicenseMap.get(newOrdProd.id), (newOrdProd.Quantity).intValue(),System.Label.Sales_Renew_Contract_Qty_Decrease ));        
                    }
                }   
            }   
        }
        for(Sales_license__c lic: licensesToUpsertList){
            if(lic.id == null){
                OrderItem ordItm = newOrdProdMap.get(lic.Sales_License_Order_Product__c);
                if(licOrdProdMap.containskey(ordItm)){
                    licOrdProdMap.get(ordItm).add(lic);     
                }else{
                    List<Sales_license__c> newLicListToAdd = new List<Sales_License__c>();
                    newLicListToAdd.add(lic);
                    licOrdProdMap.put(ordItm,newLicListToAdd);     
                }
            }
        }
        if(!licOrdProdToDelete.isEmpty()){
            delete licOrdProdToDelete;            
        }
        delete licensesToDeleteList;
        if(!licToUpdate.isEmpty()){
            licensesToUpsertList.addAll(licToUpdate);
        }
        upsert licensesToUpsertList;
        update licOrdProdToUpdate;
        createLicenseOrderProducts(null,licOrdProdMap,null);
    }
    private static List<Sales_License__c> createLicenseRecords(OrderItem newOrdProd, Product2 prod, List<SBQQ__ProductOption__c> prodOptnList, Integer qty, Map<Id, Order> ordMap){
        List<Sales_License__c> newLicenseList = new List<Sales_License__c>();
        String toolLicenseType;
        Integer expiryDatefromProduct;
        if( prodOptnList != null && !prodOptnList.IsEmpty() && prod.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'BUNDLE'){
            for(SBQQ__ProductOption__c prodOtn: prodOptnList){
                expiryDatefromProduct=(Integer)prodOtn.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c;   
                toolLicenseType = prodOtn.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c;         
                if(toolLicenseType==TOOL_LICENSE_TYPE_FIXED){
                    newLicenseList.addAll(processLicense(ordMap,newOrdProd,(Decimal)qty,1,false,expiryDatefromProduct,prodOtn.SBQQ__OptionalSKU__c,'Original'));
                }
                else if(toolLicenseType==TOOL_LICENSE_TYPE_FLOAT || toolLicenseType==TOOL_LICENSE_TYPE_NEUTRAL || toolLicenseType==TOOL_LICENSE_TYPE_NA){
                    newLicenseList.addAll(processLicense(ordMap,newOrdProd, (Decimal)1,Qty, false,expiryDatefromProduct,prodOtn.SBQQ__OptionalSKU__c,'Original'));
                }
            }
        }else{
            toolLicenseType = prod.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c; 
            expiryDatefromProduct=(Integer)prod.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c;   
            if(toolLicenseType==TOOL_LICENSE_TYPE_FIXED){
                newLicenseList.addAll(processLicense(ordMap,newOrdProd,(Decimal)qty,1,false,expiryDatefromProduct,prod.id,'Original'));
            }
            else if(toolLicenseType==TOOL_LICENSE_TYPE_FLOAT || toolLicenseType==TOOL_LICENSE_TYPE_NEUTRAL || toolLicenseType==TOOL_LICENSE_TYPE_NA){
                newLicenseList.addAll(processLicense(ordMap,newOrdProd, (Decimal)1,Qty, false,expiryDatefromProduct,prod.id,'Original'));
            }
        }
        return newLicenseList;
    }
    private static List<Sales_License__c> deleteLicenseRecords(List<Sales_License_Order_Product__c> licOrdProdList, OrderItem ordProd, Integer qtyToDelete, Boolean deleteDummyLicense, Boolean deleteLicOrdProdRecords){
        Integer count = 0;
        List<Sales_License__c> licListToDelete = new List<Sales_License__c>();
        for(Sales_License_Order_Product__c licOrdProd: licOrdProdList){            
            if(count < qtyToDelete){                
                if(licOrdProd.Sales_License__r.Sales_License_Order_Product__c ==  licOrdProd.Sales_Order_Product__c && qtyToDelete > 0 && (licOrdProd.Sales_License__r.Sales_License_Type__c == 'Original' || (licOrdProd.Sales_License__r.Sales_License_Type__c != 'Original' && deleteDummyLicense))){
                    if(licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c != TOOL_LICENSE_TYPE_FIXED || licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c == TOOL_LICENSE_TYPE_FIXED){
                        count = count + 1;    
                    }
                    Sales_License__c lic = new Sales_License__c();
                    lic.id = licOrdProd.Sales_License__c;
                    if(licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c == TOOL_LICENSE_TYPE_FLOAT ||
                       licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c == TOOL_LICENSE_TYPE_NEUTRAL ||
                       licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c == TOOL_LICENSE_TYPE_NA){
                           lic.Sales_License_Avbl_Qty_Nbr__c = ordProd.Quantity; 
                           lic.Sales_License_Quantity__c = ordProd.Quantity; 
                           licOrdProd.Sales_Quantity__c = ordProd.Quantity; 
                           licToUpdate.add(lic);
                           licOrdProdToUpdate.add(licOrdProd);
                       }else{                    
                           licListToDelete.add(lic);
                           licOrdProdToDelete.add(licOrdProd);
                       }
                }else if(licOrdProd.Sales_License__r.Sales_License_Order_Product__c !=  licOrdProd.Sales_Order_Product__c && deleteLicOrdProdRecords && (licOrdProd.Sales_License__r.Sales_License_Type__c == 'Original' || (licOrdProd.Sales_License__r.Sales_License_Type__c != 'Original' && deleteDummyLicense)) ){
                    licOrdProdToDelete.add(licOrdProd);
                    if(licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c == TOOL_LICENSE_TYPE_FIXED){
                        count = count + 1;    
                    }
                }
            }
        }
        return licListToDelete;
    }
    private static Sales_License__c updateDummyLicenseRecord(OrderItem ordProd, Sales_License_Order_Product__c dummyLicOrdProd, Integer qty, String type){
        Sales_License__c dummyLic = new Sales_License__c();
        if(dummyLicOrdProd == null){                            
            dummyLic.Sales_License_Type__c = type;
            dummyLic.Sales_License_Order_Product__c = ordProd.id;
        }else{            
            dummyLic.id = dummyLicOrdProd.Sales_License__c;
            dummyLicOrdProd.Sales_Quantity__c = qty;
            licOrdProdToUpdate.add(dummyLicOrdProd);
        }
        dummyLic.Sales_License_Product__c = ordProd.Product2Id;
        dummyLic.Sales_License_Avbl_Qty_Nbr__c = qty;      
        dummyLic.Sales_License_Quantity__c = qty;             
        return dummyLic;
    }
    public static void updatePriceChangedOnOrder(List<OrderItem> ordProdList, Map<Id,OrderItem> oldOrderProdMap, List<Order> orderList){
        Map<Id,Id> orderToQuote = new Map<Id,Id>();
        Map<Id,SBQQ__QuoteLine__c> qlineMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Id> quotelineToQuoteMap = new Map<Id,Id>();
        Map<Id,Id> orderToAccountMap = new Map<Id,Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        List<String> orderItemList = new List<String>();
        List<String> orderItemMismatchList = new List<String>();
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        List<Id> orderIds = new List<Id>();
        List<Order> ordList = new List<Order>();
        for(OrderItem orderProduct: ordProdList){
            productIdSet.add(orderProduct.Product2Id);
            orderIdSet.add(orderProduct.OrderId);
        }
        if(productIdSet!=null && orderIdSet!=null){
            for(Order order: orderList){
                if(order.SBQQ__Quote__c!=null && order.Status=='Draft' && order.Sales_Is_Verified__c==false){
                    orderToQuote.put(order.Id,order.SBQQ__Quote__c);
                    orderToAccountMap.put(order.Id,order.Sales_Sold_To_Account__c);
                    orderMap.put(order.Id,order);
                }   
            } 
            if(orderToAccountMap.size() > 0){
                for(Account acc : [Select Id,type,Core_Direct_Distributor_Channel_Nm__c from Account where Id IN:orderToAccountMap.values()]){ accMap.put(acc.Id,acc);
                                                                                                                                             }
            }
            if(orderToQuote.size() > 0){
                for(SBQQ__QuoteLine__c qline : [Select Id , SBQQ__Quote__c,price_brokencost_amt__c,price_suggested_resale_amt__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:orderToQuote.values() ]){
                    qlineMap.put(qline.Id,qline);
                    quotelineToQuoteMap.put(qline.Id,qline.SBQQ__Quote__c);
                }
            }
            for(OrderItem oi : [Select Id ,OrderItemNumber,Sales_Broken_Price_Amt__c,Sales_Suggested_Resale_Price__c,UnitPrice,SBQQ__QuoteLine__c,OrderId from OrderItem where SBQQ__QuoteLine__c IN:quotelineToQuoteMap.keySet() and OrderId IN:orderToQuote.keySet()]){
                Id accountId =  orderToAccountMap.get(oi.OrderId);
                Account accRecord = accMap.get(accountId); 
                orderItemList.add(oi.OrderItemNumber);
                orderIds.add(oi.OrderId);
                if(orderMap.get(oi.OrderId).Sales_Sold_To_Account__c!=null && accRecord.Core_Direct_Distributor_Channel_Nm__c=='02' && (oi.UnitPrice != qlineMap.get(oi.SBQQ__QuoteLine__c).price_brokencost_amt__c) && qlineMap.get(oi.SBQQ__QuoteLine__c).price_brokencost_amt__c!=null){ 
                    orderItemMismatchList.add(oi.OrderItemNumber);
                }
                else if(orderMap.get(oi.OrderId).Sales_Sold_To_Account__c!=null && accRecord.Core_Direct_Distributor_Channel_Nm__c=='01' && (oi.UnitPrice!=qlineMap.get(oi.SBQQ__QuoteLine__c).price_suggested_resale_amt__c) && qlineMap.get(oi.SBQQ__QuoteLine__c).price_suggested_resale_amt__c!=null){ 
                    orderItemMismatchList.add(oi.OrderItemNumber);
                }
            }
            if(orderItemList.size()>0 && orderItemMismatchList.size()==0) {
                for(Order ord :[Select Id,Sales_IsPriceChanged__c,Sales_Req_Ship_Date_Dt__c from Order where Id IN:orderIds and Status='Draft']){
                    if(ord.Sales_Req_Ship_Date_Dt__c < Date.today()){ ord.Sales_Req_Ship_Date_Dt__c = Date.today(); 
                                                                    }
                    ord.Sales_IsPriceChanged__c = false;
                    ordList.add(ord);
                }
            }    
            if(ordList.size()>0){
                update ordList;
            }
        }
    }    
    public static void validateOrderProductForDeletion(Map<Id, OrderItem> orderItmMap){
        for(Sales_License__c lic: [Select id, Sales_License_Order_Product__c, Sales_License_Order__r.Status, Sales_License_Type__c, Sales_Distributed_Quantity__c from Sales_License__c where Sales_License_Order_Product__c IN: orderItmMap.values()]){
            if(lic.Sales_License_Order__r.Status == 'Activated'){
                orderItmMap.get(lic.Sales_License_Order_Product__c)?.addError(System.label.Sales_ActivatedOrder_Error); 
            }
            if((lic.Sales_License_Type__c == 'Renewal' || lic.Sales_License_Type__c ==  System.Label.Sales_Amend_Contract_Qty_Decrease||
                lic.Sales_License_Type__c == System.Label.Sales_Renew_Contract_Qty_Decrease || lic.Sales_License_Type__c == System.Label.Sales_Licencse_Add_Seat_record_type  ) && lic.Sales_Distributed_Quantity__c > 0 && !orderItmMap.get(lic.Sales_License_Order_Product__c)?.hasErrors()){
                    orderItmMap.get(lic.Sales_License_Order_Product__c)?.addError(System.label.Sales_DummyLicDistributed_Error);     
                }
        }
    }
    public static void deleteLicensesOnOrderProductDeletion(Map<Id, OrderItem> orderItmMap){
        List<Sales_License__c> licensesToDeleteList = new List<Sales_License__c>();
        List<Sales_License_Order_Product__c> licOrdProdToDeleteList = new List<Sales_License_Order_Product__c>();
        for(Sales_License_Order_Product__c licOrdProd: [Select id, Sales_License__c,Sales_Order_Product__c, Sales_License__r.Sales_License_Order_Product__c from Sales_License_Order_Product__c where Sales_Order_Product__c IN: orderItmMap.values()]){
            OrderItem ordItm = orderItmMap.get(licOrdProd.Sales_Order_Product__c);
            Sales_License__c lic = new Sales_License__c();
            lic.id = licOrdProd.Sales_License__c;
            if(ordItm != null && licOrdProd.Sales_License__r.Sales_License_Order_Product__c == ordItm.id && !licensesToDeleteList.contains(lic)){                
                licensesToDeleteList.add(lic);
            }    
            licOrdProdToDeleteList.add(licOrdProd);
        }           
        if(!licOrdProdToDeleteList.isEmpty()){
            delete licOrdProdToDeleteList;
        }
        if(!licensesToDeleteList.isEmpty()){
            delete licensesToDeleteList;
        }
    }
    public static void renewalProductValidation(List<OrderItem> orderItmList){
        String LICENSE_TYPE_ORIGINAL = 'Original';
        Boolean isBundled=false;
        Set<id> contactId = new Set<id>();
        Set<id> prodId = new Set<id>();
        List<String> qty = new List<String>();
        Set<Id> foundProdIdSet=new Set<Id>();
        Map<Id, Integer> prodIdLicCountMap = new Map<Id, Integer>();
        Map<Id, Integer> renewalprodcountMap = new Map<Id, Integer>();
        Map<Id,Id> foundationProdRenewalProdMap = new Map<id, Id>();
        Map<Id, Decimal> orderItemQuantityMap = new Map<Id, Decimal>();
        Map<Id, Decimal> licenseQuantityMap = new Map<Id, Decimal>();
        List<Sales_License__c> licenseQuantityList = new List<Sales_License__c>();
        List<Id>orderitemRenewalList = new List<id>();
        List<String>orderitemRenewalListName = new List<String>();
        Map<Id,Set<Id>> delPrimaryContactMap = new Map<Id,Set<Id>>();
        Map<Id,Id> OptionalBaseMap = new Map<Id,Id>();
        List<OrderItem> renewalorderitemlist =  new List<OrderItem>(); 
        Set<id> renewalOrderitemIds =new Set<id>();
        Set<id> conIdSet = new Set<Id>();
        Map<Id,OrderItem> ProdId_toBeInsertedOPMap = new Map<Id,OrderItem>();
        Set<Id> toBeInsertedOP_ProdIDs = new Set<Id>();
        Set<Id> prod_ExtAttributeMapIDS = new Set<Id>();
        for(OrderItem oItem : orderItmList){
            ProdId_toBeInsertedOPMap.put(oItem.Product2Id, oItem);
        }
        toBeInsertedOP_ProdIDs = ProdId_toBeInsertedOPMap.keySet();
        Map<Id,Core_Product_Ext_Attribute__c> prod_ExtAttributeMap = new Map<Id,Core_Product_Ext_Attribute__c>();
        for(Core_Product_Ext_Attribute__c at : [SELECT Id, Core_Product_Id__c, Core_Foundation_Product_Id__c, Core_SW_Lic_Type_Nm__c, Core_Prod_Tool_Type_Nm__c FROM Core_Product_Ext_Attribute__c WHERE Core_Product_Id__c In: toBeInsertedOP_ProdIDs and Core_Prod_Tool_Type_Nm__c= 'RENEWAL' and Core_Foundation_Product_Id__c != null  ]){
            prod_ExtAttributeMap.put(at.Core_Product_Id__c, at);
            prod_ExtAttributeMapIDS = prod_ExtAttributeMap.keySet();            
        }
        if(orderItmList.size() > 0 && prod_ExtAttributeMap.size() >0 ){  
            for(OrderItem oi :[select id , Quantity , Sales_Contact__c, Product2Id , Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c from orderitem where id in: orderItmList AND  Product2Id In: prod_ExtAttributeMapIDS ] ){    
                orderItemQuantityMap.put(oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,oi.Quantity);
                renewalorderitemlist.add(oi);
                renewalOrderitemIds.add(oi.Id);
                foundationProdRenewalProdMap.put(prod_ExtAttributeMap.get(oi.Product2Id)?.Core_Foundation_Product_Id__c,oi.Product2Id);              
                if(oi.Sales_Contact__c != null){
                    contactId.add(oi.Sales_Contact__c);
                }
                prodId.add(oi.Product2Id);
                foundProdIdSet.add(prod_ExtAttributeMap.get(oi.Product2Id).Core_Foundation_Product_Id__c);
            }
        }
        List<SBQQ__ProductOption__c> compositeBundleChildList=[Select Id,SBQQ__Type__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c 
                                                               from SBQQ__ProductOption__c 
                                                               where SBQQ__Type__c ='Accessory'  AND SBQQ__ConfiguredSKU__c IN:foundProdIdSet AND SBQQ__Bundled__c=true];
        if(compositeBundleChildList.size()>0){ 
            isBundled=true;
            for(SBQQ__ProductOption__c childProd:compositeBundleChildList){
                OptionalBaseMap.put(childProd.SBQQ__OptionalSKU__c,childProd.SBQQ__ConfiguredSKU__c);
                foundProdIdSet.add(childProd.SBQQ__OptionalSKU__c);
            }
        }
        if(contactId.size()>0){
            delPrimaryContactMap = Sales_LicenseGenerationGenericFunctions.validateDelegateUsers(contactId);
            for(Id conId1 : delPrimaryContactMap.keySet()) {
                conIdSet.addAll(delPrimaryContactMap.get(conId1));
            }
            List<Sales_License__c> lcList = [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
                                             Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c,
                                             Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c 
                                             FROM Sales_License__c where
                                             Sales_License_Product__c IN:foundProdIdSet 
                                             AND (Sales_License_Primary_Admin_Contact__c IN:contactId OR Sales_License_Lic_User_Contact_ID__c IN:contactId
                                                  OR(Sales_License_Primary_Admin_Contact__c IN : conIdSet))
                                             AND (Sales_License_Type__c =: LICENSE_TYPE_ORIGINAL) AND (Sales_License_Status__c != 'Cancelled')];
            Set<Sales_License__c> lcListSet = new Set<Sales_License__c>(lcList);
            PRM_Execution_Controls__c skipValidations= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());
            if(lcList.isEmpty()){   
                for(OrderItem oi : orderItmList){
                    if(renewalOrderitemIds.contains(oi.Id) && (!skipValidations.Skip_ValidationRule_Order_Status__c) ){
                        oi.addError(System.label.Sales_NoBaseForRenewal_ErrMsg);
                    }
                }
            }
            Integer count =0 ;
            for(Sales_License__c lic: lcList){
                if(prodIdLicCountMap.containsKey(lic.Sales_License_Product__c)){
                    count = prodIdLicCountMap.get(lic.Sales_License_Product__c);
                    if(lic.Sales_License_Quantity__c != null){
                        count = count + (Integer)lic?.Sales_License_Quantity__c;
                    }
                }else{
                    count = (Integer)lic?.Sales_License_Quantity__c;
                }
                prodIdLicCountMap.put(lic.Sales_License_Product__c, count);
            }
            Decimal licenseRollupQuantity=0;
            for(Sales_License__c lc : lcList){
                if(prod_ExtAttributeMap.size()>0){
                    Decimal orderProductQuantity=0;
                    Id originalRenewalProdID;       
                    if(foundationProdRenewalProdMap.containsKey(lc.Sales_License_Product__c) ||
                       (OptionalBaseMap.containsKey(lc.Sales_License_Product__c))){
                           Set<Id> foundationprodSet=new Set<Id>();
                           foundationprodSet = foundationProdRenewalProdMap.keyset(); 
                           Set<Id> orderitemprodSet=new Set<Id>();
                           orderitemprodSet = orderItemQuantityMap.keyset();  
                           if(orderItemQuantityMap.containsKey(lc.Sales_License_Product__c) ||
                              orderItemQuantityMap.containsKey((OptionalBaseMap.get(lc.Sales_License_Product__c)))){ 
                                  if(isBundled){
                                      orderProductQuantity=orderItemQuantityMap.get(foundationProdRenewalProdMap.get(OptionalBaseMap.get(lc.Sales_License_Product__c)));
                                      originalRenewalProdID = foundationProdRenewalProdMap.get(OptionalBaseMap.get(lc.Sales_License_Product__c));
                                  }
                                  else{
                                      orderProductQuantity=orderItemQuantityMap.get(lc.Sales_License_Product__c); 
                                      originalRenewalProdID = foundationProdRenewalProdMap.get(lc.Sales_License_Product__c);
                                  }
                                  if(prodIdLicCountMap.containsKey(lc.Sales_License_Product__c)){
                                      licenseRollupQuantity = prodIdLicCountMap.get(lc.Sales_License_Product__c);
                                  }
                                  PRM_Execution_Controls__c skipValidation= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());
                                  if(orderProductQuantity>licenseRollupQuantity){  
                                      if(!skipValidation.Skip_ValidationRule_Order_Status__c){
                                          ProdId_toBeInsertedOPMap.get(originalRenewalProdID).addError(System.label.Sales_BaseLicErrMsg);
                                      }
                                  }
                              }
                       }
                }
            }
            for(Sales_License__c lic : [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
                                        Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c, Sales_License_Avbl_Qty_Nbr__c,
                                        Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c,Sales_License_Product__r.Name  
                                        from Sales_License__c 
                                        where  Sales_License_Product__c IN:prodId  
                                        AND (Sales_License_Primary_Admin_Contact__c IN:contactId OR Sales_License_Lic_User_Contact_ID__c IN:contactId
                                             OR(Sales_License_Primary_Admin_Contact__c IN : conIdSet))
                                        AND(Sales_License_Type__c ='Renewal') AND (Sales_License_Status__c != 'Cancelled')
                                        AND Sales_License_Avbl_Qty_Nbr__c > 0 AND (Sales_License_Maintenance_Exp_Dt__c = null OR (Sales_License_Maintenance_Exp_Dt__c > :Date.Today()))  ]){
                                            licenseQuantityMap.put(lic.Sales_License_Product__c,lic.Sales_License_Avbl_Qty_Nbr__c );
                                            licenseQuantityList.add(lic);
                                            orderitemRenewalList.add(lic.Sales_License_Order_Product__c);
                                            if(!orderitemRenewalListName.contains(lic.Sales_License_Product__r.Name)){
                                                orderitemRenewalListName.add(lic.Sales_License_Product__r.Name);
                                            }
                                        }
            Integer renewalcount =0 ;
            Decimal licenseRenewalQuantity=0;
            if(!licenseQuantityList.isEmpty()){
                for(Sales_License__c lic : licenseQuantityList){
                    if(renewalprodcountMap.containsKey(lic.Sales_License_Product__c)){
                        renewalcount = renewalprodcountMap.get(lic.Sales_License_Product__c);
                        if(lic.Sales_License_Quantity__c != null){
                            renewalcount = renewalcount + (Integer)lic?.Sales_License_Quantity__c;
                        }
                    }else{
                        renewalcount = (Integer)lic?.Sales_License_Quantity__c;
                    }
                    renewalprodcountMap.put(lic.Sales_License_Product__c, renewalcount);
                }
            } 
            List<OrderItem> orderitemlist = new List<OrderItem>();
            Map<Id,OrderItem> ordItmIdToOrderitem = new Map<Id,OrderItem>();                     
            if(licenseQuantityMap!= null && !licenseQuantityMap.isEmpty()){
                for(OrderItem oi : [select id ,Product2Id,  Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c, Quantity  from OrderItem where Id IN : orderItmList]){
                    if(licenseQuantityMap.containsKey(oi.Product2Id)){
                        licenseRollupQuantity = prodIdLicCountMap.get(oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
                        licenseRenewalQuantity = (Decimal)renewalprodcountMap.get(oi.Product2Id);
                        if(!orderitemRenewalList.contains(oi.id)){
                            if( licenseRenewalQuantity == licenseRollupQuantity && (oi.Quantity != null&& oi.Quantity >= 1) ){
                                ordItmIdToOrderitem.put(oi.Id, oi);
                            }  
                            if( (oi.Quantity != null) && licenseRollupQuantity < (licenseRenewalQuantity + oi.Quantity )  ){
                                ordItmIdToOrderitem.put(oi.Id, oi);  
                            }
                        }
                        else if(orderitemRenewalList.contains(oi.id ) && oi.Quantity > licenseRollupQuantity){
                            ordItmIdToOrderitem.put(oi.Id, oi);
                        }
                    }
                }
                List<Object> parameters = new List<Object> {orderitemRenewalListName}; 
                    String errorText = System.Label.Sales_NotEnoughBaseToRenew_CloneErrMsg; 
                String formattedErrorText = String.format(errorText, parameters);  
                for(orderItem o : orderItmList){ 
                    if(ordItmIdToOrderitem.containsKey(o.Id) ){
                        PRM_Execution_Controls__c skipValidation= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());
                        if(o.isclone()){
                            o.addError(formattedErrorText); 
                        }
                        else{
                            if(!skipValidation.Skip_ValidationRule_Order_Status__c){
                                o.addError(System.label.Sales_BaseLicErrMsg);
                            }
                        }
                    }
                }
            }
        }    
    }*/
}