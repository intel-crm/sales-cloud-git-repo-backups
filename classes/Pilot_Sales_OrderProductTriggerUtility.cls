/*********************************************************************************************************************
Class Name    : Pilot_Sales_OrderProductTriggerUtility
Version       : 1.0
Created Date  : Sep 2021
Function      :  

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Shalini Kumari            16/09/2021              Pilot Project for testing framework.
* ************************************************************************************************************************************************/
public class Pilot_Sales_OrderProductTriggerUtility {
	private static final String TOOL_LICENSE_TYPE_FIXED = 'FIXED';
    private static final String TOOL_LICENSE_TYPE_FLOAT = 'FLOAT';
    private static final String TOOL_LICENSE_TYPE_NEUTRAL = 'NEUTRAL';
    private static final String TOOL_LICENSE_TYPE_INTEGRATE_BUNDLE = 'INTEGRATE BUNDLE';
    private static final String TOOL_LICENSE_TYPE_COMPOSITE_BUNDLE = 'COMPOSITE BUNDLE';

    private static final String TOOL_LICENSE_TYPE_CORPORATE_BUNDLE = 'CORPORATE';
    private static final String TOOL_LICENSE_TYPE_OPTIONAL = 'Optional';
    private static final String CORE_PSG_TOOL_RENEWAL_TYPE = 'RENEWAL';
    private static final String CORE_PSG_TOOL_ADD_SEAT_TYPE = 'ADD SEAT';
    private static final String ACCOUNT_TYPE_DISTI='Distributor';
    private static final String ACCOUNT_TYPE_DIRECT='End User';
    private static final String DIRECT_ORDER_DISTI_CHANNEL='01';
    private static final String DISTI_ORDER_DISTI_CHANNEL='02';
    private static final String ORDER_TYPE_SAMPLEORDER='Sample Order';
    private static final String ORDER_TYPE_CORPORATEORDER='Corporate order'; 
    private static final String ORDER_TYPE_NONCOMMERCIALORDER = 'Non Commercial Order';
    private static final String DEVKIT_PRODUCT_CLASS='BD';
    private static final String ORDER_STATUS_DRAFT='Draft';
    private static final String PRODUCT_OPTION_TYPE_COMPONENT='Component';
    private static final String PRODUCT_OPTION_TYPE_ACCESSORY='Accessory';
    private static final String TOOL_LICENSE_TYPE_NA='N-A';
    private static Map<Id, Product2> productMap = new Map<Id, Product2>();
    private static Map<Id, Order> orderMap = new Map<Id,Order>();
    private static List<Sales_License_Order_Product__c> licOrdProdToDelete = new List<Sales_License_Order_Product__c>();
    private static List<Sales_License__c> licToUpdate = new List<Sales_License__c>();
    private static List<Sales_License_Order_Product__c> licOrdProdToUpdate = new List<Sales_License_Order_Product__c>();
    
    public static void beforeUpdateOrderProductUtility(List<OrderItem> orderProductList,Map<Id, OrderItem> oldMap, Map<Id, Order> ordMap){
        Set<Id> productIdSet = new Set<Id>();
        //   Set<Id> orderSetId = new Set<Id>();
        Map<Id,Id> orderToQuoteMap = new Map<Id,Id>();
        Map<Id,Id> orderToAccountMap = new Map<Id,Id>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        Map<Id,SBQQ__QuoteLine__c> productQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Core_Product_Ext_Attribute__c> psgToProductMap = new Map<Id,Core_Product_Ext_Attribute__c>();
        for(OrderItem orderProduct: orderProductList){
            productIdSet.add(orderProduct.Product2Id);
            //  orderSetId.add(orderProduct.OrderId);
        }
        updateUnitPriceForQuotedOrder(orderProductList,productIdSet,ordMap.values());
    }
    
    public static void beforeInsertOrderProductUtility(List<OrderItem> orderProductList, Map<Id, Order> ordMap){
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        for(OrderItem orderProduct: orderProductList){
            productIdSet.add(orderProduct.Product2Id);
            //  orderIdSet.add(orderProduct.OrderId);
        }
        updateUnitPriceForQuotedOrder(orderProductList,productIdSet,ordMap.values());
    }
    //added by Srishty -US909519:This method will create License record for Order when Order Product is inserted
    public static void createSalesLicense(List<OrderItem> orderProductList, Map<Id, Order> ordMap, Set<Id> productIdSet,Boolean createOriginal, Boolean isOptionLicense, Sales_License__c parentLicense,Id renewalLicId){
        Integer expiryDatefromProduct=0;        
        Map<String,Sales_License__c> existingLicMap =new Map<String,Sales_License__c>();
        List<Sales_License__c> newLicenseList = new List<Sales_License__c>();
        Map<Id,Set<String>> prodTypeMap = new Map<Id,Set<String>>();
        Map<Id,SBQQ__ProductOption__c> productOptionMap = new Map<Id,SBQQ__ProductOption__c>();
        Map<Id,String> orderWithQuoteTypeMap = new Map<Id,String>();
        List<Id> renewalAmendOppIdsList = new List<Id>();
        Map<Id, Integer> mapOfProdIdLicCount = new Map<Id, Integer>();
        Map<Id, List<Sales_License__c>> mapOfProdIdLicenses = new Map<Id, List<Sales_License__c>>();
        Map<OrderItem, List<Sales_License__c>> mapOfOrdProdLicListForLinking = new Map<OrderItem, List<Sales_License__c>>();
        List<Sales_License__c> newLicenseListToInsert = new List<Sales_License__c>();
        Set<Id> contractIdsSet = new Set<Id>();
        String licenseType;
        Double qty; 
        
        //Get the contract id in case of renewal/amendment order
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
        
        //Get the existing License records for the contract
        //for(Sales_License__c existingLic: [Select Id,Sales_License_Type__c, Sales_License_Order__c, Sales_License_Status__c,Sales_License_Order_Product__c,Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Contract__c,
        //                                   Sales_License_Product__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,Sales_License_Avbl_Qty_Nbr__c, Sales_License_Quantity__c 
        //                                   from Sales_License__c where Sales_License_Order_Product__r.SBQQ__Contract__c IN: contractIdsSet and Sales_License_Type__c = 'Original' and Sales_License_Status__c != 'Cancelled']){
        for(Sales_License__c existingLic: SEL_Sales_License.newInstance().selectByContractIds(contractIdsSet)){
                                               
                                               Integer count = 0; 
                                               //For fixed product the number of licenses are equal to the quantity, so the count is 1 for each license
                                               if(existingLic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c==TOOL_LICENSE_TYPE_FIXED){
                                                   count = 1;
                                               }else{
                                                   //For float product, the count is equal to the quantity
                                                   // count = (Integer)existingLic.Sales_License_Avbl_Qty_Nbr__c;
                                                   count = (Integer)existingLic.Sales_License_Quantity__c;
                                               }
                                               //Populate the map with product id as the key and count as value
                                               if(mapOfProdIdLicCount.containsKey(existingLic.Sales_License_Product__c)){
                                                   mapOfProdIdLicCount.put(existingLic.Sales_License_Product__c, mapOfProdIdLicCount.get(existingLic.Sales_License_Product__c) + count);
                                               }else{
                                                   mapOfProdIdLicCount.put(existingLic.Sales_License_Product__c, count);
                                               }   
                                               
                                               //Populate map with Product id as key and list of related licenses as value
                                               if(mapOfProdIdLicenses.containsKey(existingLic.Sales_License_Product__c)){
                                                   mapOfProdIdLicenses.get(existingLic.Sales_License_Product__c).add(existingLic);
                                               }else{
                                                   List<Sales_License__c> licList = new List<Sales_License__c>();
                                                   licList.add(existingLic);
                                                   mapOfProdIdLicenses.put(existingLic.Sales_License_Product__c, licList);
                                               }   
                                           }
        
        //Map of Product with Option Product with base product as non corporate.
        //productMap = new Map<Id,Product2>([Select Id,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c ,Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
        //                                   (Select Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,SBQQ__Type__c,SBQQ__Bundled__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c from SBQQ__Options__r where SBQQ__Type__c IN(:PRODUCT_OPTION_TYPE_COMPONENT,:PRODUCT_OPTION_TYPE_ACCESSORY))
        //                                   from Product2 where Id IN:productIdSet 
        //                                   AND Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!=:TOOL_LICENSE_TYPE_CORPORATE_BUNDLE]);
        productMap = new Map<Id,Product2>(SEL_Product.newInstance().selectByProductIdAndType(productIdSet, TOOL_LICENSE_TYPE_CORPORATE_BUNDLE, PRODUCT_OPTION_TYPE_COMPONENT, PRODUCT_OPTION_TYPE_ACCESSORY));
        
        //Map of option product with type of bundle
       // for(SBQQ__ProductOption__c productOption : [Select Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,SBQQ__Type__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c IN:productMap.keySet() And SBQQ__Type__c IN(:PRODUCT_OPTION_TYPE_COMPONENT,:PRODUCT_OPTION_TYPE_ACCESSORY)]){
        for(SBQQ__ProductOption__c productOption : SEL_ProductOption.newInstance().selectByProductIdAndType(productMap.keySet(), PRODUCT_OPTION_TYPE_COMPONENT, PRODUCT_OPTION_TYPE_ACCESSORY)){
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
        
        //Normal scenario -- procuctIdSet contains all the products from orderProducts
        //In component scenario -- productIdSet contains the child option products
        //creating license record based on different criteria
        for(OrderItem orderProduct: orderProductList){ // this will run only once when called from component
            List<Sales_License__c> newLicenseListForBundle = new List<Sales_License__c>();
            newLicenseList = new List<Sales_License__c>();
            if(!isOptionLicense){
                productIdSet.clear();//clearing the productId set in case when called from trigger
                productIdSet.add(orderProduct.Product2Id);// populating with current loop iteration order product's product
            }
            for(Id productId : productIdSet){ //this loop will run only once in the case when called from trigger as productIdSet will contain only one product
                if(createOriginal){
                    productId=orderProduct.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c;
                }
                if(productMap.containsKey(productId)){
                    qty = orderProduct.Quantity;
                    licenseType = 'Original';
                    
                    if(!createOriginal){
                        
                        //For Add Seat product or Amendment Order with decrease in qty
                        if(productMap.get(productId).Core_Product_Ext_Attribute_Id__r != null && productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == CORE_PSG_TOOL_ADD_SEAT_TYPE)
                        {
                            licenseType=System.Label.Sales_Licencse_Add_Seat_record_type;
                        }
                        else if(ordMap.containsKey(orderProduct.OrderId) && ordMap.get(orderProduct.OrderId).SBQQ__Quote__r.SBQQ__Type__c == 'Amendment' && mapOfProdIdLicCount.containsKey(productId) && orderProduct.Quantity < 0){
                            licenseType = System.Label.Sales_Amend_Contract_Qty_Decrease;    
                            //In case the product is removed in amendment order, the addition of new order product qty (-ve value) and number of exiting licenses would be 0
                            //Set the qty as 0 and populate the map for linking existing licenses with new order product with -ve qty
                            if(orderProduct.Quantity < 0  && (orderProduct.Quantity + mapOfProdIdLicCount.get(productId) == 0)){
                                qty = 0;
                                mapOfOrdProdLicListForLinking.put(orderProduct, mapOfProdIdLicenses.get(productId));                              
                            }
                            //For Renewal Product, set the license type as Renewal                               
                        }else if(productMap.get(productId).Core_Product_Ext_Attribute_Id__r != null && productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == CORE_PSG_TOOL_RENEWAL_TYPE){
                            licenseType = CORE_PSG_TOOL_RENEWAL_TYPE;          
                            //For Corporate Renewal Order
                        }else if(ordMap.containsKey(orderProduct.OrderId) && ordMap.get(orderProduct.OrderId).SBQQ__Quote__r.SBQQ__Type__c == 'Renewal' && mapOfProdIdLicCount.containsKey(productId)){
                            qty = (orderProduct.Quantity - mapOfProdIdLicCount.get(productId));
                            //If qty is greater than or equal to 0, that means the quantity on Renewal order is increased or same
                            //Link the existing licenses with new order product
                            if(qty >= 0){
                                mapOfOrdProdLicListForLinking.put(orderProduct, mapOfProdIdLicenses.get(productId));
                                //Else qty is decreased, create a Renewal License record
                            }else{
                                licenseType = System.Label.Sales_Renew_Contract_Qty_Decrease;
                                qty = (orderProduct.Quantity); 
                            }                      
                        }
                    }                   
                    
                    Set<String> typeSet = prodTypeMap.containsKey(productId)?prodTypeMap.get(productId):null;
                    if(qty != 0){
                        //For non-bundle products
                        if(productMap.get(productId).SBQQ__Options__r.size()==0 || (typeSet!=null && typeSet.contains(PRODUCT_OPTION_TYPE_COMPONENT))){
                            System.debug('Inside this if');
                            expiryDatefromProduct=(Integer)productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c;                                                           
                            //for FIXED type , based on number of qty in Order Product, License record will be created. 
                            if(productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c==TOOL_LICENSE_TYPE_FIXED){
                                newLicenseList = processLicense(ordMap,orderProduct,qty,qty,false,expiryDatefromProduct,productId,licenseType);   
                            }
                            //for FLOAT,Neutral and Bundle, there will be one License record for each Order Product.
                            else if(productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c==TOOL_LICENSE_TYPE_FLOAT || 
                                    productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c==TOOL_LICENSE_TYPE_NEUTRAL|| 
                                    productMap.get(productId).Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c==TOOL_LICENSE_TYPE_NA){
                                        newLicenseList = processLicense(ordMap,orderProduct, 1,qty, false,expiryDatefromProduct,productId,licenseType); 
                                    }
                        }
                        //creating license record for bundle option product with accessory type
                        else{
                            System.debug('Inside this else');
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
                                    if(toolLicenseType==TOOL_LICENSE_TYPE_FIXED){//for FIXED type , based on number of qty in Order Product, Subscription record will be created. 
                                        newLicenseListForBundle.addAll(processLicense(ordMap,orderProduct,qty,qty,false,expiryDatefromProduct,productOption.SBQQ__OptionalSKU__c,licenseType));
                                    }
                                    else if(toolLicenseType==TOOL_LICENSE_TYPE_FLOAT || toolLicenseType==TOOL_LICENSE_TYPE_NEUTRAL || toolLicenseType==TOOL_LICENSE_TYPE_NA){//for FLOAT,Neutral and Bundle, there will be one subscription record for each Order Product.
                                        newLicenseListForBundle.addAll(processLicense(ordMap,orderProduct, 1,qty, false,expiryDatefromProduct,productOption.SBQQ__OptionalSKU__c,licenseType));
                                    }
                                }
                            }
                        }
                    }
                }            
                
            }
            //Adding to a single list, all individual and bundle products licenses
            newLicenseListToInsert.addAll(newLicenseList);
            newLicenseListToInsert.addAll(newLicenseListForBundle);
            //Populating map for linking order product and new licenses created
            if(mapOfOrdProdLicListForLinking.containsKey(orderProduct)){
                mapOfOrdProdLicListForLinking.get(orderProduct).addAll(newLicenseList);
                mapOfOrdProdLicListForLinking.get(orderProduct).addAll(newLicenseListForBundle);
            }else{
                mapOfOrdProdLicListForLinking.put(orderProduct, newLicenseList);
                mapOfOrdProdLicListForLinking.get(orderProduct).addAll(newLicenseListForBundle);
            }
        }//loop ends here...
        
        if(isOptionLicense && parentLicense!=null){
            //Sales_License__c parentLicense = [Select id,Sales_License_Expiration_Date_Dt__c,Sales_License_SAPLine_Nbr__c,Sales_License_Avbl_Rehost_Nbr__c,Sales_License_Web_Display_Flag__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Status__c,Sales_License_Primary_Admin_Contact__c,Sales_License_Contract__c,Sales_License_Activation_Code__c from Sales_License__c where Id=:licenseId];
            List<Sales_License__c> tempListList = new List<Sales_License__c>();
            for(Sales_License__c licRecord : newLicenseListToInsert){
                licRecord.Sales_License_Status__c=parentLicense.Sales_License_Status__c;
                licRecord.Sales_License_Expiration_Date_Dt__c=parentLicense.Sales_License_Expiration_Date_Dt__c;
                licRecord.Sales_License_Maintenance_Exp_Dt__c=parentLicense.Sales_License_Maintenance_Exp_Dt__c;
                licRecord.Sales_License_Primary_Admin_Contact__c = parentLicense.Sales_License_Primary_Admin_Contact__c;
                licRecord.Sales_Parent_License__c = parentLicense.Id;
                //licRecord.Sales_License_Quantity__c=parentLicense.Sales_License_Quantity__c;
                //licRecord.Sales_License_Avbl_Qty_Nbr__c=parentLicense.Sales_License_Avbl_Qty_Nbr__c;
                licRecord.Sales_License_Web_Display_Flag__c = false;
                licRecord.Sales_License_Avbl_Rehost_Nbr__c=parentLicense.Sales_License_Avbl_Rehost_Nbr__c;
                licRecord.Sales_License_Activation_Code__c=parentLicense.Sales_License_Activation_Code__c;//populating activation code.
                licRecord.Sales_License_Type__c=TOOL_LICENSE_TYPE_OPTIONAL;//optional license will be creted as Optional type.
                licRecord.Sales_License_SAPLine_Nbr__c=parentLicense.Sales_License_SAPLine_Nbr__c;//populating same sap line number to update activation code from parent post shipment from sap.
                licRecord.Sales_License_Contract__c=parentLicense.Sales_License_Contract__c;
                licRecord.Sales_License_Host_Node_Id__c = parentLicense.Sales_License_Host_Node_Id__c;
                licRecord.Sales_License_Start_Date_Dt__c = parentLicense.Sales_License_Start_Date_Dt__c;
                tempListList.add(licRecord); 
            }
            newLicenseListToInsert.clear();
            newLicenseListToInsert.addAll(tempListList);
        }
        if(!newLicenseListToInsert.isEmpty()){
            insert newLicenseListToInsert;//inserting license record
        }
        //Create license order product linking records for all existing and new licenses
        createLicenseOrderProducts(mapOfOrdProdLicListForLinking,false,null);
    }
    
    //Added by :Srishty -US862561:This method is helper method of createSubscriptions for creating Subscription record based on certain criteria(remove this method to common utility class)
    private static List<Sales_License__c> processLicense(Map<Id, Order> ordMap, OrderItem orderProduct, Decimal numberOfLic, Double qty, Boolean isBundle,Integer expiryDatefromProduct, Id productId, String licenseType){
        List<Sales_License__c> licenceReturnList = new List<Sales_License__c>();
        Date mainresult, lastDayOfMonth;
        Integer numberOfDays;
        //If license type is Amend/Renewal, create only one license record
        if(licenseType == 'Renewal'|| licenseType==System.Label.Sales_Amend_Contract_Qty_Decrease
           ||licenseType== System.Label.Sales_Renew_Contract_Qty_Decrease || licenseType==System.Label.Sales_Licencse_Add_Seat_record_type ){//custom label
               numberOfLic = 1;
           }                
        for (Integer i = 0; i < (Integer)numberOfLic; i++) {//loop start here...
            Sales_License__c newLic = new Sales_License__c();
            newLic.Sales_License_Avbl_Qty_Nbr__c = numberOfLic>1 ? 1 :qty;
            newLic.Sales_License_Quantity__c = numberOfLic>1 ? 1 :qty;
            //newLic.Sales_License_Product__c = isBundle ? productMap.get(orderProduct.Product2Id).SBQQ__Options__r[0].SBQQ__OptionalSKU__c : orderProduct.Product2Id;
            newLic.Sales_License_Product__c = productId;
            //newLic.Sales_License_Primary_Admin_Contact__c=orderProduct.Sales_Contact__c;
            newLic.Sales_License_Order_Product__c=orderProduct.Id;
            newLic.Sales_License_Order__c =orderProduct.OrderId;
            newLic.Sales_License_Type__c = licenseType;
            newLic.Sales_License_Status__c = 'Unlicensed';
            
            Order ord = ordMap.get(orderProduct.OrderId);
            //For corporate Order, set the License start date as Quote start date
            //Expiry date as last day of month of (quote Start date + Product expiry) or quote end date, whichever is greater
            //Maintenance expiry date as quote end date
            //Commeting below expiry date logic as part of US1047247, this is to make the expiry date logic consistent for all order types
            /*
if(ord.Sales_Order_Sub_Type__c == 'Corporate Order' || (ord.SBQQ__Quote__r != null && ord.Sales_Order_Sub_Type__c == null) ){
newLic.Sales_License_Start_Date_Dt__c =  ord.SBQQ__Quote__r.SBQQ__StartDate__c;
Date endDate;

if(ord.SBQQ__Quote__r?.SBQQ__EndDate__c != null){
endDate = ord.SBQQ__Quote__r?.SBQQ__EndDate__c;
}else if(ord.SBQQ__Quote__r?.SBQQ__StartDate__c !=null && ord.SBQQ__Quote__r?.SBQQ__SubscriptionTerm__c != null){
endDate = (ord.SBQQ__Quote__r?.SBQQ__StartDate__c).addMonths((ord.SBQQ__Quote__r?.SBQQ__SubscriptionTerm__c).intvalue())-1;
}  
// endDate = Sales_LicenseTriggerUtility.getLastDateOfMonth(endDate);
if(expiryDatefromProduct != null && newLic.Sales_License_Start_Date_Dt__c != null && endDate < Sales_LicenseTriggerUtility.getLastDateOfMonth(newLic.Sales_License_Start_Date_Dt__c.addDays(expiryDatefromProduct))){
newLic.Sales_License_Expiration_Date_Dt__c = Sales_LicenseTriggerUtility.getLastDateOfMonth(newLic.Sales_License_Start_Date_Dt__c.addDays(expiryDatefromProduct));
}else if(expiryDatefromProduct != null){
newLic.Sales_License_Expiration_Date_Dt__c = endDate;    
}                            
//   newLic.Sales_License_Maintenance_Exp_Dt__c = Sales_LicenseTriggerUtility.getLastDateOfMonth(endDate);
newLic.Sales_License_Maintenance_Exp_Dt__c = endDate;
}
*/ 
            if(ord.Sales_Order_Reason__c != 'Stocking Order' && ord.Type != null){
                newLic.Sales_License_Account__c = ord.AccountId;
            }
            String key=String.valueOf(newLic.Sales_License_Product__c)+String.valueOf(newLic.Sales_License_Order_Product__c)+String.valueOf(newLic.Sales_License_Product__c);
            licenceReturnList.add(newLic);
            
        }//loop ends here...
        //returning list of subscription for insertion.
        return licenceReturnList;
    }          
    
    //This method creates License Order Product records
    public static void createLicenseOrderProducts(Map<OrderItem, List<Sales_License__c>> mapOfOrdProdLicListForLinking, Boolean fromComponent,Id renewalId){
        System.debug('@@keySet'+mapOfOrdProdLicListForLinking.keyset());
        if(mapOfOrdProdLicListForLinking != null && !mapOfOrdProdLicListForLinking.isEmpty()){
            List<Sales_License_Order_Product__c> licOrderProdListToInsert = new List<Sales_License_Order_Product__c>();
            Map<Id, OrderItem> allLicMap = new Map<Id, OrderItem>();
            for(OrderItem ordItm: mapOfOrdProdLicListForLinking.keyset()){
                List<Sales_License__c> licList = mapOfOrdProdLicListForLinking.get(ordItm);                 
                if(licList!=null){//Added the null check
                    for(Sales_License__c lic: licList){
                        allLicMap.put(lic.id, ordItm);
                        Sales_License_Order_Product__c licOrdPrd = new Sales_License_Order_Product__c();
                        licOrdPrd.Sales_License__c = lic.id;
                        licOrdPrd.Sales_Order_Product__c = ordItm.Id;
                        if(lic.Sales_License_Status__c=='Licensed'){
                            licOrdPrd.Sales_License_ContractId__c = lic.Sales_License_Contract__c;
                            licOrdPrd.Sales_License_Expiration_Date_Dt__c=lic.Sales_License_Expiration_Date_Dt__c;
                            // licOrdPrd.Sales_Renewable_license__c=renewalId;
                            //System.debug('licOrdPrd.Sales_Renewable_license__c'+licOrdPrd.Sales_Renewable_license__c);
                        }
                        licOrdPrd.Sales_Renewable_license__c=renewalId;
                        System.debug('licOrdPrd.Sales_Renewable_license__c'+licOrdPrd.Sales_Renewable_license__c);
                        //  licOrdPrd.Sales_Quantity__c = lic.Sales_License_Avbl_Qty_Nbr__c; 
                        licOrdPrd.Sales_Quantity__c = lic.Sales_License_Quantity__c; 
                        //if(licOrdPrd.Sales_Quantity__c < 0 && lic.Sales_License_Type__c == 'Original'){
                        //      licOrdPrd.Sales_Quantity__c = Math.abs(licOrdPrd.Sales_Quantity__c);
                        //  }
                        licOrderProdListToInsert.add(licOrdPrd);                    
                    } 
                }
            }
            
            //If existing parent licenses are linked, also link the child licenses
            //for(Sales_License__c childLic: [Select Id,Sales_License_Maintenance_Exp_Dt__c, Sales_Parent_License__r.Sales_License_Maintenance_Exp_Dt__c, Sales_Parent_License__c,Sales_Parent_License__r.Sales_License_Status__c,Sales_Parent_License__r.Sales_License_Expiration_Date_Dt__c,Sales_Parent_License__r.Sales_License_Contract__c from Sales_License__c where Sales_Parent_License__c IN: allLicMap.keySet()]){
            for(Sales_License__c childLic: SEL_Sales_License.newInstance().selectByParentLicense(allLicMap.keySet())){
                Sales_License_Order_Product__c licOrdPrd = new Sales_License_Order_Product__c();
                OrderItem ordProd = allLicMap.get(childLic.Sales_Parent_License__c);
                if(childLic.Sales_Parent_License__r.Sales_License_Status__c=='Licensed'){
                    licOrdPrd.Sales_License_ContractId__c = childLic.Sales_Parent_License__r.Sales_License_Contract__c;
                    licOrdPrd.Sales_License_Expiration_Date_Dt__c=childLic.Sales_Parent_License__r.Sales_License_Expiration_Date_Dt__c;
                    licOrdPrd.Sales_License_Order_Prod_Maint_Exp_Dt__c=childLic.Sales_Parent_License__r.Sales_License_Maintenance_Exp_Dt__c;
                    licOrdPrd.Sales_Renewable_license__c=renewalId;
                }
                licOrdPrd.Sales_License__c = childLic.id;
                licOrdPrd.Sales_Order_Product__c = ordProd.Id;                  
                licOrderProdListToInsert.add(licOrdPrd);                                            
            }
            
            insert licOrderProdListToInsert;
            System.debug('licOrderProdListToInsert'+licOrderProdListToInsert);
        }   
    }
    
    
    //Added by Srishty-US862469:Price & Quantity Logic of a Order Product for different types of orders,updating unit price for order having quote for disti/direct and Sample Order.
    //Updated by Nilesh - US923425 :Quote to Order price field mappings
    
    //Method to calculate unit price when quote is associated based on the sold to account disti channel.
    public static void updateUnitPriceForQuotedOrder(List<OrderItem> orderProductList, Set<Id>productIdSet, List<Order>orderList ){
        Map<Id,Map<Id,SBQQ__QuoteLine__c>> quoteToProductWithQuoteLineMap = new Map<Id,Map<Id,SBQQ__QuoteLine__c>>();
        Map<Id,Id> orderToQuoteMap = new Map<Id,Id>();
        Map<Id,Id> orderToAccountMap = new Map<Id,Id>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        Map<Id,SBQQ__QuoteLine__c> qlineMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Id> quotelineToQuoteMap = new Map<Id,Id>();
        // Set<Id> productIdSet = new Set<Id>();
        Map<Id,Core_Product_Ext_Attribute__c> psgToProductMap = new Map<Id,Core_Product_Ext_Attribute__c>();
        // String subOrderType ;
        //Boolean isCorp=false;
        
        //loop start here to create map of OrderId with related quote and OrderId with related Account
        // for(Order order : [Select id,SBQQ__Quote__c,Sales_Sold_To_Account__c,Status,type,Sales_Order_Sub_Type__c from Order where Id In:orderSetId And SBQQ__Quote__c!=null]){
        for(Order ord: orderList){
            if(ord.SBQQ__Quote__c != null){
                orderToQuoteMap.put(ord.Id,ord.SBQQ__Quote__c);//Map of Order and related quote
                orderToAccountMap.put(ord.Id,ord.Sales_Sold_To_Account__c);//Map of Order and related account
                orderMap.put(ord.Id,ord);
            }
        }//loop ends here...   
        //query on account to get account details 
        //Map<Id,Account> accountMap = new Map<Id,Account>([Select id,Type,Core_Account_Type__c,Core_Direct_Distributor_Channel_Nm__c from Account where Id IN:orderToAccountMap.values()]);
        Map<Id,Account> accountMap = new Map<Id,Account>(SEL_Account.newInstance().selectBySoldIds(orderToAccountMap.values()));
        //Query on product extended attribute to check tool type
        //for(Core_Product_Ext_Attribute__c psg : [Select Id ,Core_Prod_Tool_Type_Nm__c,Core_Product_Id__c from Core_Product_Ext_Attribute__c where Core_Product_Id__c IN: productIdSet AND Core_Prod_Tool_Type_Nm__c='CORPORATE']){
        for(Core_Product_Ext_Attribute__c psg : SEL_Core_Product_Ext_Attribute.newInstance().selectByProductIds(productIdSet)){
            psgToProductMap.put(psg.Core_Product_Id__c,psg); // map of product and psg license
        }
        //loop start here to create the Map of Quote with all the  Product from quote line.
        //for(SBQQ__QuoteLine__c quoteLine:[Select Id,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__PriceBook__r.Name,SBQQ__Product__c,price_brokencost_amt__c,price_requested_resale_amt__c,price_suggested_resale_amt__c,price_disty_cost_nbr__c,SBQQ__ListPrice__c
        //                                  from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:orderToQuoteMap.values() order by SBQQ__Quote__c]){
        for(SBQQ__QuoteLine__c quoteLine:SEL_QuoteLines.newInstance().selectAndOrderByQuoteIds(orderToQuoteMap.values())){
                                              qlineMap.put(quoteLine.Id,quoteLine);
                                              quotelineToQuoteMap.put(quoteLine.Id,quoteLine.SBQQ__Quote__c);
                                              /*  Map<Id,SBQQ__QuoteLine__c> productQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
if(quoteToProductWithQuoteLineMap.containsKey(quoteLine.SBQQ__Quote__c)){
productQuoteLineMap = quoteToProductWithQuoteLineMap.get(quoteLine.SBQQ__Quote__c);//retreiving value of productquotelineMap corresponding to Quote
productQuoteLineMap.put(quoteLine.SBQQ__Product__c,quoteLine);
quoteToProductWithQuoteLineMap.put(quoteLine.SBQQ__Quote__c,productQuoteLineMap);//map of Quote with map of quoteline product
}
else{
productQuoteLineMap.put(quoteLine.SBQQ__Product__c,quoteLine);
quoteToProductWithQuoteLineMap.put(quoteLine.SBQQ__Quote__c,productQuoteLineMap); //map of Quote with map of quoteline product for first time
}*/
                                          }//loop ends here...
        
        for(OrderItem item:orderProductList){//loop start here...
            
            if(orderToQuoteMap.containsKey(item.OrderId)){
                Id quoteId = orderToQuoteMap.get(item.OrderId);
                // Map<Id,SBQQ__QuoteLine__c> productQuoteLineMap = quoteToProductWithQuoteLineMap.get(quoteId);//getting value of quote line
                // if(productQuoteLineMap != null && productQuoteLineMap.containsKey(item.Product2Id) && item.UnitPriceForceOverride__c==null){
                if(qlineMap.size()>0 && quotelineToQuoteMap.size()>0 && item.UnitPriceForceOverride__c==null){
                    
                    // SBQQ__QuoteLine__c quoteLineItem = productQuoteLineMap.get(item.Product2Id);
                    Id accountId = orderToAccountMap.get(item.OrderId);
                    Account accountRecord = accountMap.get(accountId);
                    
                    //Disti order(02) with quote scenario where unit price is set as the broken cost from the quote line
                    if((item.SBQQ__QuoteLine__c!= null && qlineMap.get(item.SBQQ__QuoteLine__c) != null && item.SBQQ__QuoteLine__c == qlineMap.get(item.SBQQ__QuoteLine__c).id) && (item.Product2Id == qlineMap.get(item.SBQQ__QuoteLine__c).SBQQ__Product__c ) && (orderMap.get(item.OrderId).type!=ORDER_TYPE_NONCOMMERCIALORDER) && (orderMap.get(item.OrderId).Status=='Draft') && (orderMap.get(item.OrderId).Sales_Sold_To_Account__c!=null) && (accountRecord.Core_Direct_Distributor_Channel_Nm__c==DISTI_ORDER_DISTI_CHANNEL)){// unit price updating for Disti order
                        System.debug('Inside disti order');
                        System.debug('Disti channel>>'+accountRecord.Core_Direct_Distributor_Channel_Nm__c);
                        item.UnitPrice = qlineMap.get(item.SBQQ__QuoteLine__c).price_brokencost_amt__c!=null?qlineMap.get(item.SBQQ__QuoteLine__c).price_brokencost_amt__c:0;  //updating with 0 value if the broken price on quote line is blank   
                        item.Sales_Broken_Price_Amt__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_brokencost_amt__c;   //broken cost on orderproduct populated with broken cost on quoteline
                        item.Sales_Suggested_Resale_Price__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_suggested_resale_amt__c;  //suggested resale on orderproduct populated with suggested resale on quoteline                  
                    }
                    //For Direct Orders
                    //Direct Order (01) and internal (04) with quote scenario where unit price is set as the suggested resale price from the quote line 
                    else if((item.SBQQ__QuoteLine__c!= null && qlineMap.get(item.SBQQ__QuoteLine__c) != null && item.SBQQ__QuoteLine__c==qlineMap.get(item.SBQQ__QuoteLine__c).id) && (item.Product2Id == qlineMap.get(item.SBQQ__QuoteLine__c).SBQQ__Product__c ) && (orderMap.get(item.OrderId).type!=ORDER_TYPE_NONCOMMERCIALORDER)  && (orderMap.get(item.OrderId).Status=='Draft') && (orderMap.get(item.OrderId).Sales_Sold_To_Account__c!=null) && ((accountRecord.Core_Direct_Distributor_Channel_Nm__c=='01')||(accountRecord.Core_Direct_Distributor_Channel_Nm__c=='04'))){//updating unit price for direct order or sample order
                        System.debug('Inside direct order');
                        System.debug('Disti channel>>'+accountRecord.Core_Direct_Distributor_Channel_Nm__c);
                        item.UnitPrice = qlineMap.get(item.SBQQ__QuoteLine__c).price_suggested_resale_amt__c!=null?qlineMap.get(item.SBQQ__QuoteLine__c).price_suggested_resale_amt__c:0;//updating with 0 value if the resale price on quote line is blank
                        item.Sales_Broken_Price_Amt__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_brokencost_amt__c;  //broken cost on orderproduct populated with broken cost on quoteline
                        item.Sales_Suggested_Resale_Price__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_suggested_resale_amt__c;   //suggested resale on orderproduct populated with suggested resale on quoteline 
                    }
                    //Non-commercial order with quote scenario where unit price set to zero
                    else if((item.SBQQ__QuoteLine__c!= null && qlineMap.get(item.SBQQ__QuoteLine__c) != null && item.SBQQ__QuoteLine__c==qlineMap.get(item.SBQQ__QuoteLine__c).id) && (item.Product2Id == qlineMap.get(item.SBQQ__QuoteLine__c).SBQQ__Product__c ) && (orderMap.get(item.OrderId).type==ORDER_TYPE_NONCOMMERCIALORDER)  && (orderMap.get(item.OrderId).Status=='Draft')){
                        item.UnitPrice = 0;//updating with 0 value
                        item.Sales_Broken_Price_Amt__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_brokencost_amt__c; //broken cost on orderproduct populated with broken cost on quoteline
                        item.Sales_Suggested_Resale_Price__c = qlineMap.get(item.SBQQ__QuoteLine__c).price_suggested_resale_amt__c;   //suggested resale on orderproduct populated with suggested resale on quoteline
                    }
                }
            }
        }//loop ends here..
    }
    
    //US862284: Validation rule to prevent  Products that involve license generator from Mentor graphics from being bought by Mentor graphics' competitors.
    //US970579:Mentor Graphics design change
    public static void checkCompetitorAccountVsProduct(List<OrderItem> orderItemList){
        //Map<Id,Id> orderToEndCustomerMap =new Map<Id,Id>();//map of Order Id and endcutomer account Id 
        /*Set<Id> orderIdSet = new Set<Id>();//order Id set
List<String> opnList = new List<String>();
for(OrderItem item:orderItemList){
orderIdSet.add(item.OrderId);
opnList.add(item.Sales_OPN__c);
}
for(Order order:[Select Id, Sales_End_Customer_Account__c from Order where Id IN:orderIdSet]){
if(order.Sales_End_Customer_Account__c !=null){
orderToEndCustomerMap.put(order.Id,order.Sales_End_Customer_Account__c);  
}
}*/
        Pilot_Sales_LicenseValidationCheckUtilty.addErrorOnOrderItem(orderItemList);//calling validation check
    }
    
    
    //Added by Jasmine as a part of US909064: Order Creation from Quote & Quote Line Groups
    public static void checkOrderProductsFromQuoteLines(List<OrderItem> orderItemList){
        Pilot_Sales_OrderCreationValidUtility.validateOrderProducts(orderItemList); 
        System.debug('## in 679 Queries Used'+Limits.getQueries());
        System.debug('## in 679 Total Allowed Queries'+Limits.getLimitQueries());
    }
    
    //Added by Srishty:US909064: Order Creation from Quote & Quote Line Groups, to restrict the creation of new order product which is not in quote line.
    public static void restrictOrderProductCreation(List<OrderItem> orderItemList, Map<id, order> ordMap){
        Set<Id> orderIds = new Set<Id>();
        Set<Id> orderIdsWithQuote = new Set<Id>();//set of order ID which is asscoiated with quote
        Set<Id> quoteIds = new Set<Id>();
        Map<Id,Id> orderQuoteMap = new Map<Id,Id>();
        Map<Id,Map<Id,Integer>> orderToProductLineMapOnOrderItem = new Map<Id,Map<Id,Integer>>();//map of order Id with corresponding map of product with number of order item.
        Map<Id,Map<Id,Integer>> quoteToProductQuanityMapOnQuoteLine = new Map<Id,Map<Id,Integer>>();//map of quote Id with corresponding map of product with number of quote line item.
        
        for(OrderItem orderProduct : orderItemList){
            //  orderIds.add(orderProduct.OrderId);//adding order ID of order item. 
            if(ordMap.containsKey(orderProduct.OrderId) && ordMap.get(orderProduct.OrderId).SBQQ__Quote__c != null){
                quoteIds.add(ordMap.get(orderProduct.OrderId).SBQQ__Quote__c);//adding quote Id for correspoding order.
                orderIdsWithQuote.add(orderProduct.OrderId);
                orderQuoteMap.put(orderProduct.OrderId,ordMap.get(orderProduct.OrderId).SBQQ__Quote__c);//adding order Id and correspoding quote Id.    
            }
        }
        
        /*   for(Order order:[Select Id,SBQQ__Quote__c from Order where Id In:orderIds AND SBQQ__Quote__c!='']){
quoteIds.add(order.SBQQ__Quote__c);//adding quote Id for correspoding order.
orderIdsWithQuote.add(order.Id);
orderQuoteMap.put(order.Id,order.SBQQ__Quote__c);//adding order Id and correspoding quote Id.
} */
        
        //for(OrderItem orderLine:[Select OrderId,Product2Id from OrderItem where OrderId IN:orderIdsWithQuote order by OrderId]){//loop start here..
        for(OrderItem orderLine:SEL_OrderItem.newInstance().selectAndOrderByOrderIds(orderIdsWithQuote)){//loop start here..
            Map<Id,Integer> productLineMap = new Map<Id,Integer>();
            if(orderToProductLineMapOnOrderItem.containsKey(orderLine.OrderId)){
                productLineMap = orderToProductLineMapOnOrderItem.get(orderLine.OrderId);
                if(productLineMap.containsKey(orderLine.Product2Id)){
                    Integer productLineCount = productLineMap.get(orderLine.Product2Id);
                    productLineCount+=1;
                    productLineMap.put(orderLine.Product2Id,productLineCount);//Adding product and its line in orderItem,
                }
                else{
                    productLineMap.put(orderLine.Product2Id,1);
                }
                orderToProductLineMapOnOrderItem.put(orderLine.OrderId,productLineMap);//map of order with map of product line numbers.
            }
            else{
                productLineMap.put(orderLine.Product2Id,1);
                orderToProductLineMapOnOrderItem.put(orderLine.OrderId,productLineMap); //map of order with map of product and quanity added for first time.
            }
        }//loop ends here...
        
        //for(SBQQ__QuoteLine__c quoteLine:[Select SBQQ__Quote__c,SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:quoteIds order by SBQQ__Quote__c]){
        List<Id> quoteIdsList = new List<Id>(quoteIds);
        for(SBQQ__QuoteLine__c quoteLine:SEL_QuoteLines.newInstance().selectAndOrderByQuoteIds(quoteIdsList)){
            Map<Id,Integer> productQuantityMap = new Map<Id,Integer>();
            if(quoteToProductQuanityMapOnQuoteLine.containsKey(quoteLine.SBQQ__Quote__c)){
                productQuantityMap = quoteToProductQuanityMapOnQuoteLine.get(quoteLine.SBQQ__Quote__c);
                if(productQuantityMap.containsKey(quoteLine.SBQQ__Product__c)){
                    Integer productQuantity = productQuantityMap.get(quoteLine.SBQQ__Product__c);
                    productQuantity+=1;
                    productQuantityMap.put(quoteLine.SBQQ__Product__c,productQuantity);//Map of Quoteline and its quantity
                }
                else{
                    productQuantityMap.put(quoteLine.SBQQ__Product__c,1);
                }
                quoteToProductQuanityMapOnQuoteLine.put(quoteLine.SBQQ__Quote__c,productQuantityMap);//Map of Qoute and correponding map of Quoteline and its quantity
            }
            else{
                productQuantityMap.put(quoteLine.SBQQ__Product__c,1);
                quoteToProductQuanityMapOnQuoteLine.put(quoteLine.SBQQ__Quote__c,productQuantityMap); //Map of Qoute and correponding map of Quoteline and its quantity for first time
            }
        }//loop ends here...
        
        for(OrderItem orderProduct : orderItemList){//comparing the count of quote line and order product for new product getting added through order product on order.
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
        }//loop ends here...
    }
    //US925272 to populate list price based on quantity from CORE CPQ LIST PRICE
    //Method to calculate unit price when quote is not associated and sold to disti channel is 01 or 04
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
                pricebookEntryIds.add(String.valueOf(pi.PricebookEntryId)); //fill set of pricebookentry ids
            }
            ordIds.add(pi.OrderId);  
            productIds.add(pi.Product2Id);
        }
        
        List<Id> ordIdsList = new List<Id>(ordIds);
        if(isBlankPricebook){
            if(ordIds.size() > 0){
                //orderList = new List<Order>([SELECT Id, Pricebook2Id from Order WHERE id IN :ordIds]);//Map of Order for fetching PricebookId
                orderList = new List<Order>(SEL_Order.newInstance().selectByOrderId(ordIdsList));//Map of Order for fetching PricebookId
            }
            
            for(Order ord : orderList){
                pricebookIds.add(ord.Pricebook2Id);
            }
            
            //PricebookEntry pbentryId = [select id,Product2Id from PriceBookEntry where Pricebook2Id IN:pricebookIds and Product2Id IN : productIds];            
            PricebookEntry pbentryId = SEL_PricebookEntry.newInstance().selectByPricebook2IdAndProductIds(pricebookIds, productIds)[0];            
            orderItemIdsMap.put(pbentryId.Product2Id, pbentryId.Id);
            
            for(OrderItem pi : orderItemList){
                if(String.isBlank(pi.PricebookEntryId)){//populating pricebookEntryId if it is blank
                    if(String.isNotBlank(pi.Product2Id)){
                        if(orderItemIdsMap.size() > 0){
                            pi.PricebookEntryId = orderItemIdsMap.get(pi.Product2Id);
                        }
                    }
                }
                pricebookEntryIds.add(String.valueOf(pi.PricebookEntryId)); //fill set of pricebookentry ids
            }
        }
        System.debug('pricebookEntryIds-->'+pricebookEntryIds);
        // Map<Id,Order> ordMap = new Map<Id,Order>();
        Map<Id,PricebookEntry> pbEntryMap = new Map<Id,PricebookEntry>();
        Map<id, List<core_cpq_list_price__c>> pbeIdVsListPriceMap = new Map<id, List<core_cpq_list_price__c>>();
        List<core_cpq_list_price__c> listPriceLst = new List<core_cpq_list_price__c>();
        /*for(OrderItem orderProduct : orderItemList){
// if(orderProduct.SBQQ__QuoteLine__c==null && pricebookEntryIds.size() >= 0 && ordIds.size() >=0){
//if(pricebookEntryIds.size() >= 0 && ordIds.size() >=0){commented by Jasmine
pricebookEntryIds.add(String.valueOf(orderProduct.PricebookEntryId)); //fill set of pricebookentry ids
//}
}*/
        //querying pricebookentry based on the product in order product record
        if(pricebookEntryIds.size()>0){
            for(PricebookEntry pbEntry : [Select Id,UnitPrice,price_disty_cost__c,Product2Id from PricebookEntry where Id IN:pricebookEntryIds And Product2Id IN:productIds]){
                pbEntryMap.put(pbEntry.Id,pbEntry);
                System.debug('PricebookentryMap'+pbEntryMap);
            }
        }
        System.debug('PricebookentryMap'+pbEntryMap);
        //creating a list of the cpq list price records
        if(pricebookEntryIds.size()>0){
            //listPriceLst = [select id, core_cpq_list_price_amt__c, core_cpq_lowerbound_qty__c, core_cpq_upperbound_qty__c, core_cpq_product_name__c, Pricebookentry__c from core_cpq_list_price__c where Pricebookentry__c in: pricebookEntryIds And core_cpq_product_name__c in: productIds]; //fetch all core cpq list price records for product
            listPriceLst = SEL_core_cpq_list_price.newInstance().selectByPriceBookEntryAndProductIds(pricebookEntryIds, productIds); //fetch all core cpq list price records for product
        }
        //fill map of pricebookentry id vs list of core cpq list price records of that product
        //creating a map of the pricebookentry and list of the record of the cpq list price object
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
        //compare quantity for each order product and populate the list price
        //  if(pbeIdVsListPriceMap.size()>0){
        for(OrderItem orderProduct : orderItemList){
            orderProduct.Sales_Disti_cost__c = pbEntryMap.get(orderProduct.PricebookEntryId)?.price_disty_cost__c;
            if((pbeIdVsListPriceMap.size()>0) && (pbeIdVsListPriceMap.containsKey(orderProduct.PricebookEntryId)) && (pbeIdVsListPriceMap.get(orderProduct.PricebookEntryId)!=null)  && (ordMap.get(orderProduct.OrderId).Status==ORDER_STATUS_DRAFT)){
                for(core_cpq_list_price__c listPriceRec: pbeIdVsListPriceMap.get(orderProduct.PricebookEntryId)){
                    
                    //comparing quantity and populating the price where sold to disti channel is 01 or 04 
                    if(orderProduct.Quantity>=listPriceRec.core_cpq_lowerbound_qty__c && (orderProduct.Quantity<=listPriceRec.core_cpq_upperbound_qty__c || listPriceRec.core_cpq_upperbound_qty__c==null)){
                        if((orderProduct.SBQQ__QuoteLine__c==null)  && (ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__c!=null) && (((ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='01') || (ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='04')) && (orderProduct.UnitPriceForceOverride__c==null) && (ordMap.get(orderProduct.OrderId).type!=ORDER_TYPE_NONCOMMERCIALORDER))){
                            orderProduct.UnitPrice=listPriceRec.core_cpq_list_price_amt__c;
                        }
                        //added as part of US1005687 to view Column resale price on order product
                        //populating the list price from cpq list price object into column resale price field in orderproduct
                        orderProduct.Sales_Column_resale_price__c=listPriceRec.core_cpq_list_price_amt__c;
                    }
                }
            }
            //if no entry found in the cpq list price then list price from default pricebookentry is set as unit price 
            else if((ordMap.get(orderProduct.OrderId).Status==ORDER_STATUS_DRAFT)){
                if((orderProduct.UnitPriceForceOverride__c==null) && (orderProduct.SBQQ__QuoteLine__c==null) && (ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__c!=null) && (((ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='01')|| (ordMap.get(orderProduct.OrderId).Sales_Sold_To_Account__r.Core_Direct_Distributor_Channel_Nm__c=='04')) && (ordMap.get(orderProduct.OrderId).type!=ORDER_TYPE_NONCOMMERCIALORDER))){
                    orderProduct.UnitPrice = pbEntryMap.get(orderProduct.PricebookEntryId)?.UnitPrice;
                }
                System.debug('Inside direct no cpq entry');
                //populating list price from pricebook entry into column resale on order product
                orderProduct.Sales_Column_resale_price__c = pbEntryMap.get(orderProduct.PricebookEntryId)?.UnitPrice;
            }
        }
    }
    
    //This method will populate SAPLACRule based on mapping
    public static void populateSAPLACRule(List<OrderItem> orderItemList){
        Map<String,String> sapLACMapping=new Map<String,String>();
        //Map<Id,Id> orItemToProdIdMap =new Map<Id,Id>();
        Map<Id,Product2> prodMap;
        Map<Id,Order> orderMap;
        Set<Id> prodIdSet =new Set<Id>();
        Set<Id> orderIdSet =new Set<Id>();
        
        
        for(Sales_Order_SAP_LAC_Rule__mdt lacMap:[Select Sales_Order_Reason_Type__c,Sales_SAP_LAC_Rule_Value__c,Sales_Tool_License_Type__c,Sales_Tool_Type__c from Sales_Order_SAP_LAC_Rule__mdt]){
            String key=lacMap.Sales_Order_Reason_Type__c+lacMap.Sales_Tool_License_Type__c+lacMap.Sales_Tool_Type__c;
            sapLACMapping.put(key, lacMap.Sales_SAP_LAC_Rule_Value__c);
        }
        System.debug('@@SAPMetadata'+sapLACMapping);
        
        for(OrderItem item:orderItemList){
            orderIdSet.add(item.OrderId);//order Id
            prodIdSet.add(item.Product2Id);//Product ID 
        }
        
        //orderMap=new Map<Id,Order>([Select Id,Sales_Order_Reason__c from Order where Id IN:orderIdSet]);
        //prodMap= new Map<Id,Product2>([Select Id,Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from Product2 where Id IN:prodIdSet]);
        List<Id> orderIdList = new List<Id>(orderIdSet);
        orderMap=new Map<Id,Order>(SEL_Order.newInstance().selectByOrderId(orderIdList));
        prodMap= new Map<Id,Product2>(SEL_Product.newInstance().selectByProductIds(prodIdSet));
        
        for(OrderItem item:orderItemList){//populating filed value based on rule
            
            String toolTypeOfOrderItem=prodMap.get(item.Product2Id).Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c;
            /*if(toolTypeOfOrderItem !='BUNDLE' && toolTypeOfOrderItem !='RENEWAL' && toolTypeOfOrderItem !='SOC'){
toolTypeOfOrderItem=null; 
}*/
            String toolLicenceOfOderItem=prodMap.get(item.Product2Id)?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Type_Nm__c;
            String orderReason=orderMap.get(item.OrderId)?.Sales_Order_Reason__c;
            String key =orderReason+toolLicenceOfOderItem+toolTypeOfOrderItem;
            System.debug('@@SAPKey'+key);
            if(sapLACMapping!=null ){
                if(sapLACMapping.containsKey(key)){
                    item.Sales_SAP_LAC_Rule_Txt__c= sapLACMapping.get(key);
                    System.debug('@@SAP'+sapLACMapping.get(key));
                    System.debug('@@ValueSAPLAC'+item.Sales_SAP_LAC_Rule_Txt__c);  
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
    /*
public static void populateContactOnLicenseForCorporateOrder(List<OrderItem> orderItemList,Map<Id,OrderItem> ordProdOldMap){

List<Id> itemList = new List<Id>();
Map<Id, List<Id>> ordOrderProdIdsMap = new Map<Id, List<Id>>();
List<Sales_License__c> licListToUpdate = new List<Sales_License__c>();
Map<Id, OrderItem> corporateOrdIdMap = new Map<Id, OrderItem>();
// String subOrderType ;
for(OrderItem ordProd : orderItemList){
if(ordOrderProdIdsMap.containsKey(ordProd.OrderId)){
ordOrderProdIdsMap.get(ordProd.OrderId).add(ordProd.id);    
}   
else{
List<Id> orditemList = new List<Id>();
orditemList.add(ordProd.id);
ordOrderProdIdsMap.put(ordProd.OrderId,orditemList);
}

}

for(OrderItem oi : [Select Id,OrderId,Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c , Sales_Contact__c from OrderItem where OrderId IN:ordOrderProdIdsMap.keySet()]){

if(ordOrderProdIdsMap.containsKey(oi.OrderId) && ordOrderProdIdsMap.get(oi.OrderId).contains(oi.id) && oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='CORPORATE'){
corporateOrdIdMap.put(oi.OrderId, oi);
}
itemList.add(oi.id);
}
for(Sales_License__c lic : [Select Id ,Sales_License_Primary_Admin_Contact__c,Sales_License_Order__c,Sales_License_Order_Product__c from Sales_License__c where Sales_License_Order_Product__c IN:itemList]){
if(corporateOrdIdMap.keyset().contains(lic.Sales_License_Order__c)){
lic.Sales_License_Primary_Admin_Contact__c = corporateOrdIdMap.get(lic.Sales_License_Order__c).Sales_Contact__c;
licListToUpdate.add(lic);
}            
}
-
if(licListToUpdate.size() > 0){
update licListToUpdate;
}

} */
    
    
    public static void updateLicenseRecordsOnUpdatingQty(Map<Id, OrderItem> newOrdProdMap, Map<Id, OrderItem> oldOrderProdMap, Map<Id, Order> ordMap){  
        Set<id> productIdSet = new Set<Id>();
        Map<OrderItem, List<Sales_License__c>> licOrdProdMap = new  Map<OrderItem, List<Sales_License__c>>();
        List<Sales_License__c> licensesToDeleteList = new List<Sales_License__c>();
        List<Sales_License__c> licensesToUpsertList = new List<Sales_License__c>();
        //  Set<Sales_License__c> licenseOrdProdToUpsertSet = new Set<Sales_License__c>();
        Map<Id, OrderItem> originalOrdProdMap = new Map<Id, OrderItem>();
        Map<Id, List<Sales_License_Order_Product__c>> ordProdIdlicOrdProdListMap = new Map<Id, List<Sales_License_Order_Product__c>>(); 
        Map<Id, Sales_License_Order_Product__c> ordProdRenewalAmendLicenseMap = new Map<Id, Sales_License_Order_Product__c>();
        Set<Id> contractIdSet = new Set<Id>();
        System.debug('order item keyset:'+newOrdProdMap.keyset());
        //for(Sales_License_Order_Product__c licOrdProd : [Select Id,Sales_Quantity__c,Sales_order_Product__r.Order.SBQQ__Quote__r.Sales_Renewed_from_Contract_Id__c, Sales_License__c,Sales_License__r.Sales_License_Type__c,Sales_License__r.Sales_License_Order_Product__c, Sales_Order_Product__c, Sales_Order_Product__r.Product2Id,Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c from Sales_License_Order_Product__c where Sales_Order_Product__c IN: newOrdProdMap.keyset() order by Sales_License__r.CreatedDate desc]){      
        for(Sales_License_Order_Product__c licOrdProd :SEL_Sales_License_Order_Product.newInstance().selectByOrderItemIdOrderByDate(newOrdProdMap.keyset())){      
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
        
        //for(OrderItem originalOrdProd: [Select id, Product2Id, Quantity from OrderItem where Product2Id IN :productIdSet and SBQQ__Contract__c IN: contractIdSet]){
        for(OrderItem originalOrdProd: SEL_OrderItem.newInstance().selectByProductAndContractIds(productIdSet, contractIdSet)){
            originalOrdProdMap.put(originalOrdProd.Product2Id, originalOrdProd);    
        }
        
        //productMap = new Map<Id,Product2>([Select Id,Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c ,Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c,
        //                                   (Select Id,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c,SBQQ__Type__c,SBQQ__Bundled__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c from SBQQ__Options__r where SBQQ__Type__c IN(:PRODUCT_OPTION_TYPE_COMPONENT,:PRODUCT_OPTION_TYPE_ACCESSORY))
        //                                   from Product2 where Id IN:productIdSet 
        //                                   AND Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c!=:TOOL_LICENSE_TYPE_CORPORATE_BUNDLE]);
        productMap = new Map<Id,Product2>(SEL_Product.newInstance().selectByProductIdAndType(productIdSet, TOOL_LICENSE_TYPE_CORPORATE_BUNDLE, PRODUCT_OPTION_TYPE_COMPONENT, PRODUCT_OPTION_TYPE_ACCESSORY));
        
        
        for(OrderItem newOrdProd: newOrdProdMap.values()){          
            OrderItem oldOrdProd = oldOrderProdMap.get(newOrdProd.id);
            Order ord = ordMap.get(newOrdProd.OrderId);
            system.debug('##0'+ord); // Getting Ord as Null, hence added below if condition.
            if(ord != null && (!productMap.isEmpty())){
                //ord.SBQQ__Quote__r.SBQQ__Type__c == 'Original' in below line was mentioned this before, but we don't have Picklist value original.
                if((ord.SBQQ__Quote__c == null || ord.SBQQ__Quote__c != null && ord.SBQQ__Quote__r.SBQQ__Type__c == 'Quote') && productMap?.get(newOrdProd.Product2Id)?.Core_Product_Ext_Attribute_Id__r?.Core_Prod_Tool_Type_Nm__c != 'Renewal' && productMap.get(newOrdProd?.Product2Id)?.Core_Product_Ext_Attribute_Id__r?.Core_Prod_Tool_Type_Nm__c != 'Add Seat'){         
                    if(newOrdProd.Quantity > oldOrdProd.Quantity){  
                        System.debug('productMap.get(newOrdProd.id):'+productMap.get(newOrdProd.id));
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
                        //  licensesToDeleteList.addAll(deleteLicenseRecords(ordProdIdlicOrdProdListMap.get(newOrdProd.id), newOrdProd, (oldOrdProd.Quantity).intValue(), false, true));                    
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
                        licensesToUpsertList.add(updateDummyLicenseRecord(newOrdProd, ordProdRenewalAmendLicenseMap.get(newOrdProd.id), (newOrdProd.Quantity).intValue(),System.Label.Sales_Renew_Contract_Qty_Decrease ));        //add label      
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
        
        createLicenseOrderProducts(licOrdProdMap,false,null);
        
        
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
                    //for FIXED type , based on number of qty in Order Product, Subscription record will be created.
                    
                    newLicenseList.addAll(processLicense(ordMap,newOrdProd,(Decimal)qty,1,false,expiryDatefromProduct,prodOtn.SBQQ__OptionalSKU__c,'Original'));
                    
                }
                else if(toolLicenseType==TOOL_LICENSE_TYPE_FLOAT || toolLicenseType==TOOL_LICENSE_TYPE_NEUTRAL || toolLicenseType==TOOL_LICENSE_TYPE_NA){
                    //for FLOAT,Neutral and Bundle, there will be one subscription record for each Order Product.
                    newLicenseList.addAll(processLicense(ordMap,newOrdProd, (Decimal)1,Qty, false,expiryDatefromProduct,prodOtn.SBQQ__OptionalSKU__c,'Original'));
                }
            }
        }else{
            toolLicenseType = prod.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c; 
            expiryDatefromProduct=(Integer)prod.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Expiration_Duration_Nbr__c;   
            if(toolLicenseType==TOOL_LICENSE_TYPE_FIXED){
                //for FIXED type , based on number of qty in Order Product, Subscription record will be created.
                
                newLicenseList.addAll(processLicense(ordMap,newOrdProd,(Decimal)qty,1,false,expiryDatefromProduct,prod.id,'Original'));
                
            }
            else if(toolLicenseType==TOOL_LICENSE_TYPE_FLOAT || toolLicenseType==TOOL_LICENSE_TYPE_NEUTRAL || toolLicenseType==TOOL_LICENSE_TYPE_NA){
                //for FLOAT,Neutral and Bundle, there will be one subscription record for each Order Product.
                newLicenseList.addAll(processLicense(ordMap,newOrdProd, (Decimal)1,Qty, false,expiryDatefromProduct,prod.id,'Original'));
            }
            
        }
        
        return newLicenseList;
        
    }
    
    
    private static List<Sales_License__c> deleteLicenseRecords(List<Sales_License_Order_Product__c> licOrdProdList, OrderItem ordProd, Integer qtyToDelete, Boolean deleteDummyLicense, Boolean deleteLicOrdProdRecords){
        Integer count = 0;
        List<Sales_License__c> licListToDelete = new List<Sales_License__c>();
        //List<Sales_License_Order_Product__c> licOrdProdListToDelete = new List<Sales_License_Order_Product__c>();
        
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
                    
                }else if(licOrdProd.Sales_License__r.Sales_License_Order_Product__c !=  licOrdProd.Sales_Order_Product__c && deleteLicOrdProdRecords){
                    if(licOrdProd.Sales_License__r.Sales_License_Type__c == 'Original' || (licOrdProd.Sales_License__r.Sales_License_Type__c != 'Original' && deleteDummyLicense)){
                        licOrdProdToDelete.add(licOrdProd);
                        if(licOrdProd.Sales_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c == TOOL_LICENSE_TYPE_FIXED){
                            count = count + 1;    
                        }
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
    /*
public static void createCorporateOPNForAmendment(List<OrderItem> ordItmList, Map<Id, Order> ordMap){        
Map<Id, Boolean> hasCorporateOPNMap = new Map<Id, Boolean>();
Map<Id, Id> productIdOrdIdMap = new Map<Id, Id>();
for(OrderItem ordProd: ordItmList){
Order ord = ordMap.get(ordProd.OrderId);
if(ord != null & ord.SBQQ__Quote__c != null && ord.SBQQ__Quote__r.SBQQ__Type__c == 'Amendment'){
productIdOrdIdMap.put(ordProd.Product2Id, ord.id);              
hasCorporateOPNMap.put(ord.Id, false);    
}
}

for(Product2 prod: [Select Id, Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c from Product2 where id IN:productIdOrdIdMap.keyset()]){
if(prod.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == TOOL_LICENSE_TYPE_CORPORATE_BUNDLE){
hasCorporateOPNMap.put(productIdOrdIdMap.get(prod.id), true);
}
}
Map<Id, Id> contractIDMap = new Map<Id, Id>();        
for(Id ordID: hasCorporateOPNMap.keyset()){
if(hasCorporateOPNMap.get(ordID) == false){                
contractIDMap.put(ordMap.get(ordID).SBQQ__Quote__r.SBQQ__MasterContract__c, ordID);
}
}
List<OrderItem> ordItmListToInsert = new List<OrderItem>();
for(OrderItem ordItm:[Select id, Product2Id, SBQQ__Contract__c, SBQQ__QuoteLine__c from OrderItem where OrderItem.SBQQ__Contract__c IN:contractIDMap.keyset() and Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c = 'CORPORATE']){
if(contractIDMap.containsKey(ordItm.SBQQ__Contract__c)){
OrderItem newOrdItem = new OrderItem();
newOrdItem.Quantity = 1;
newOrdItem.OrderId = contractIDMap.get(ordItm.SBQQ__Contract__c);
newOrdItem.Product2Id = ordItm.Product2Id;
newOrdItem.SBQQ__QuoteLine__c = ordItm.SBQQ__QuoteLine__c;
ordItmListToInsert.add(newOrdItem);                

}               
}

insert ordItmListToInsert;

} */
    
    public static void updatePriceChangedOnOrder(List<OrderItem> ordProdList, Map<Id,OrderItem> oldOrderProdMap, List<Order> orderList){
        Map<Id,Id> orderToQuote = new Map<Id,Id>();
        Map<Id,SBQQ__QuoteLine__c> qlineMap = new Map<Id,SBQQ__QuoteLine__c>();
        Map<Id,Id> quotelineToQuoteMap = new Map<Id,Id>();
        Map<Id,Id> orderToAccountMap = new Map<Id,Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,Id> quoteToAccountMap = new Map<Id,Id>();
        Map<Id,Order> orderMap = new Map<Id,Order>();
        List<String> orderItemList = new List<String>();
        List<String> orderItemMismatchList = new List<String>();
        Set<Id> productIdSet = new Set<Id>();
        Set<Id> orderIdSet = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        List<Order> ordList = new List<Order>();
        for(OrderItem orderProduct: ordProdList){
            productIdSet.add(orderProduct.Product2Id);
            orderIdSet.add(orderProduct.OrderId);
        }
        if(productIdSet!=null && orderIdSet!=null){
            //  for(Order order:[Select Id,SBQQ__Quote__c,AccountId,Sales_Sold_To_Account__c, Status from Order where Id IN :orderIdSet and Status='Draft' and Sales_Is_Verified__c=false]){
            //orderIdSet.add(order.Id);
            for(Order order: orderList){
                if(order.SBQQ__Quote__c!=null && order.Status=='Draft' && order.Sales_Is_Verified__c==false){
                    orderToQuote.put(order.Id,order.SBQQ__Quote__c);
                    orderToAccountMap.put(order.Id,order.Sales_Sold_To_Account__c);
                    orderMap.put(order.Id,order);
                    System.debug('orderToQuote>>'+orderToQuote);
                    System.debug('orderToAccountMap>>'+orderToAccountMap);
                }   
            } 
            /* for (SBQQ__Quote__c quote : [Select Id , SBQQ__Account__c from SBQQ__Quote__c where Id IN: orderToQuote.values()]){
quoteToAccountMap.put(quote.Id,quote.SBQQ__Account__c);
System.debug('quoteToAccountMap>>'+quoteToAccountMap);
}*/
            if(orderToAccountMap.size() > 0){
                //for(Account acc : [Select Id,type,Core_Direct_Distributor_Channel_Nm__c from Account where Id IN:orderToAccountMap.values()]){
                for(Account acc : SEL_Account.newInstance().selectBySoldIds(orderToAccountMap.values())){
                    accMap.put(acc.Id,acc);
                    System.debug('accMap>>'+accMap);
                 }
            }
            Set<Id> orderToQuoteValuesSet = new Set<Id>(orderToQuote.values());
            if(orderToQuote.size() > 0){
                //for(SBQQ__QuoteLine__c qline : [Select Id , SBQQ__Quote__c,price_brokencost_amt__c,price_suggested_resale_amt__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:orderToQuote.values() ]){
                for(SBQQ__QuoteLine__c qline :SEL_QuoteLines.newInstance().selectByQuoteIds(orderToQuoteValuesSet)){
                    qlineMap.put(qline.Id,qline);
                    quotelineToQuoteMap.put(qline.Id,qline.SBQQ__Quote__c);
                    System.debug('qlineMap>>'+qlineMap);
                    System.debug('quotelineToQuoteMap>>'+quotelineToQuoteMap);
                }
            }
            
            //for(OrderItem oi : [Select Id ,OrderItemNumber,Sales_Broken_Price_Amt__c,Sales_Suggested_Resale_Price__c,UnitPrice,SBQQ__QuoteLine__c,OrderId from OrderItem where SBQQ__QuoteLine__c IN:quotelineToQuoteMap.keySet() and OrderId IN:orderToQuote.keySet()]){
            for(OrderItem oi : SEL_OrderItem.newInstance().selectByOrderIdAndQuoteLineIds(quotelineToQuoteMap.keySet(),orderToQuote.keySet())){
                Id accountId =  orderToAccountMap.get(oi.OrderId);
                Account accRecord = accMap.get(accountId); 
                System.debug('account id>>'+orderToAccountMap.get(oi.OrderId));
                System.debug('Order product>>');
                System.debug('Broken cost>>'+qlineMap.get(oi.SBQQ__QuoteLine__c).price_brokencost_amt__c);
                System.debug('Unit price'+oi.UnitPrice);
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
                //for(Order ord :[Select Id,Sales_IsPriceChanged__c,Sales_Req_Ship_Date_Dt__c from Order where Id IN:orderIds and Status='Draft']){
                for(Order ord :SEL_Order.newInstance().selectByIdsAndDraftStatus(orderIds)){
                    System.debug('Inside order field set');
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
    //This method validates if order product can be deleted and returns error in case its invalid
    public static void validateOrderProductForDeletion(Map<Id, OrderItem> orderItmMap){
        //Get all license order product associated to order product
        //for(Sales_License__c lic: [Select id, Sales_License_Order_Product__c, Sales_License_Order__r.Status, Sales_License_Type__c, Sales_Distributed_Quantity__c from Sales_License__c where Sales_License_Order_Product__c IN: orderItmMap.values()]){
        for(Sales_License__c lic: SEL_Sales_License.newInstance().selectByOrderItem(orderItmMap.values())){
            //Order Product cannot be deleted if order is already activated          
            if(lic.Sales_License_Order__r.Status == 'Activated'){
                orderItmMap.get(lic.Sales_License_Order_Product__c)?.addError(System.label.Sales_ActivatedOrder_Error); 
            }
            //Order Product cannot be deleted if Order is a renewal or Amend order and the distribution action on renewal/amend licenses are already taken
            if((lic.Sales_License_Type__c == 'Renewal' || lic.Sales_License_Type__c ==  System.Label.Sales_Amend_Contract_Qty_Decrease||
                lic.Sales_License_Type__c == System.Label.Sales_Renew_Contract_Qty_Decrease || lic.Sales_License_Type__c == System.Label.Sales_Licencse_Add_Seat_record_type  ) && lic.Sales_Distributed_Quantity__c > 0 && !orderItmMap.get(lic.Sales_License_Order_Product__c)?.hasErrors()){
                    orderItmMap.get(lic.Sales_License_Order_Product__c)?.addError(System.label.Sales_DummyLicDistributed_Error);     
                }
        }
        
    }
    //This method deletes all licenses & license order products associated to order product when order product is deleted 
    public static void deleteLicensesOnOrderProductDeletion(Map<Id, OrderItem> orderItmMap){
        List<Sales_License__c> licensesToDeleteList = new List<Sales_License__c>();
        List<Sales_License_Order_Product__c> licOrdProdToDeleteList = new List<Sales_License_Order_Product__c>();
        //Get all license order product associated to order product
        //for(Sales_License_Order_Product__c licOrdProd: [Select id, Sales_License__c,Sales_Order_Product__c, Sales_License__r.Sales_License_Order_Product__c from Sales_License_Order_Product__c where Sales_Order_Product__c IN: orderItmMap.values()]){
        for(Sales_License_Order_Product__c licOrdProd: SEL_Sales_License_Order_Product.newInstance().selectByOrderItemProductIds(orderItmMap.values())){
            OrderItem ordItm = orderItmMap.get(licOrdProd.Sales_Order_Product__c);
            //If license record is also assocaited to the same order product getting deleted, delete the license record as well
            Sales_License__c lic = new Sales_License__c();
            lic.id = licOrdProd.Sales_License__c;
            if(ordItm != null && licOrdProd.Sales_License__r.Sales_License_Order_Product__c == ordItm.id && !licensesToDeleteList.contains(lic)){                
                licensesToDeleteList.add(lic);
            }    
            //delete license order product
            licOrdProdToDeleteList.add(licOrdProd);
        }           
        
        if(!licOrdProdToDeleteList.isEmpty()){
            delete licOrdProdToDeleteList;
        }
        
        if(!licensesToDeleteList.isEmpty()){
            delete licensesToDeleteList;
        }
        
    }
    
    //This method will display the warning messages if the orderproduct has no base license or not enough license records.
    //This method will display the warning messages if the orderproduct has no base license or not enough license records.
    public static void renewalProductValidation(List<OrderItem> orderItmList){
        String LICSTATUS_LICENSED ='Licensed';
        String LICENSE_TYPE_ORIGINAL = 'Original';
        OrderItem renewal_order_item ;
        Boolean isRenewal=false;
        Boolean isBundled=false;
        Set<id> contactId = new Set<id>();
        Set<id> prodId = new Set<id>();
        List<String> qty = new List<String>();
        Set<Id> foundProdIdSet=new Set<Id>();
        Map<Id, Integer> prodIdLicCountMap = new Map<Id, Integer>();//count of Original #of seats license
        Map<Id, Integer> renewalprodcountMap = new Map<Id, Integer>();//count of Renewal #of seats license
        
        Map<Id,Id> foundationProdRenewalProdMap = new Map<id, Id>();//map of foundation product and renewal product
        Map<Id, Decimal> orderItemQuantityMap = new Map<Id, Decimal>();//map of renewal order Item and its quantity
        Map<Id, Decimal> licenseQuantityMap = new Map<Id, Decimal>();//Map of Base License Product and its Quantity
        List<Sales_License__c> licenseQuantityList = new List<Sales_License__c>();//Map of Base License Product and its Quantity
        List<Id>orderitemRenewalList = new List<id>();
        List<String>orderitemRenewalListName = new List<String>();
        Map<Id,Id> delPrimaryContactMap = new Map<Id,Id>();
        Map<Id,Id> OptionalBaseMap = new Map<Id,Id>();//Map of optional Sku product and its foundation product
        List<OrderItem> renewalorderitemlist =  new List<OrderItem>(); //list of renewal order item
        Set<id> renewalOrderitemIds =new Set<id>();
        List<Sales_License_Admin_Delegate__c> delegateList = new List<Sales_License_Admin_Delegate__c>(); //List of license admin delegate
        // List of renewal orderItems with tool type as renewal associated with Non Corporate Orders
        
        List<OrderItem> orderItemRec = New List<OrderItem>();
        Map<Id,OrderItem> ProdId_toBeInsertedOPMap = new Map<Id,OrderItem>();
        Set<Id> toBeInsertedOP_ProdIDs = new Set<Id>();
        Set<Id> prod_ExtAttributeMapIDS = new Set<Id>();
        for(OrderItem oItem : orderItmList){
            //toBeInsertedOP_ProdIDs.add(oItem.Product2Id);
            ProdId_toBeInsertedOPMap.put(oItem.Product2Id, oItem);
            
        }
        
        toBeInsertedOP_ProdIDs = ProdId_toBeInsertedOPMap.keySet();
        
        //Prod Id - Extended Attribute
        Map<Id,Core_Product_Ext_Attribute__c> prod_ExtAttributeMap = new Map<Id,Core_Product_Ext_Attribute__c>();
        //Prod Ext Attribute Id - Prod Ext Attribute Object
        //for(Core_Product_Ext_Attribute__c at : [SELECT Id, Core_Product_Id__c, Core_Foundation_Product_Id__c, Core_SW_Lic_Type_Nm__c, Core_Prod_Tool_Type_Nm__c FROM Core_Product_Ext_Attribute__c WHERE Core_Product_Id__c In: toBeInsertedOP_ProdIDs and Core_Prod_Tool_Type_Nm__c= 'RENEWAL' and Core_Foundation_Product_Id__c != null  ]){
        for(Core_Product_Ext_Attribute__c at : SEL_Core_Product_Ext_Attribute.newInstance().selectByRenewalToolType(toBeInsertedOP_ProdIDs)){
            prod_ExtAttributeMap.put(at.Core_Product_Id__c, at);
            prod_ExtAttributeMapIDS = prod_ExtAttributeMap.keySet();            
        }
        System.debug('@@prod_ExtAttributeMap'+prod_ExtAttributeMap);     
        
        
        if(orderItmList.size() > 0 && prod_ExtAttributeMap.size() >0 ){  
            //iterating each filtered OrderItem and storing its Quantity, Contact, tooltype and foundation product
            //for(OrderItem oi :[select id , Quantity , Sales_Contact__c, Product2Id , Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c from orderitem where id in: orderItmList AND  Product2Id In: prod_ExtAttributeMapIDS ] ){    //orderItemRec //orderItmList //select id ,  Product2Id , Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c from orderitem where id in: orderItmList
            for(OrderItem oi :SEL_OrderItem.newInstance().selectByOrderItemAndProductId(orderItmList ,prod_ExtAttributeMapIDS)){    //orderItemRec //orderItmList //select id ,  Product2Id , Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c from orderitem where id in: orderItmList
                orderItemQuantityMap.put(oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,oi.Quantity);
                System.debug('orderItemQuantityMap'+orderItemQuantityMap);
                renewalorderitemlist.add(oi);
                renewalOrderitemIds.add(oi.Id);
                System.debug('order '+oi);
                System.debug('prod_ExtAttributeMap'+prod_ExtAttributeMap);
                System.debug('oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c'+oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
                //adding foundation product and renewal product in the Map
                foundationProdRenewalProdMap.put(prod_ExtAttributeMap.get(oi.Product2Id)?.Core_Foundation_Product_Id__c,oi.Product2Id);              
                contactId.add(oi.Sales_Contact__c);//adding renewal Contact in the set
                prodId.add(oi.Product2Id);//adding renewal product in the set
                
                //adding foundation product in the Set
                foundProdIdSet.add(prod_ExtAttributeMap.get(oi.Product2Id).Core_Foundation_Product_Id__c);
                
            }
        }
        
        
        // list of options of foundation product of renewal product having type as Accessory and IsBundled true
        //List<SBQQ__ProductOption__c> compositeBundleChildList=[Select Id,SBQQ__Type__c, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c 
        //                                                       from SBQQ__ProductOption__c 
        //                                                       where SBQQ__Type__c ='Accessory'  AND SBQQ__ConfiguredSKU__c IN:foundProdIdSet AND SBQQ__Bundled__c=true];
        List<SBQQ__ProductOption__c> compositeBundleChildList=SEL_ProductOption.newInstance().selectByConfiguredSKU(foundProdIdSet);
        
        if(compositeBundleChildList.size()>0){ //checking if foundation product has options
            isBundled=true;
            //iterating the options and adding the foundation product in the set incase of bundles
            for(SBQQ__ProductOption__c childProd:compositeBundleChildList){
                OptionalBaseMap.put(childProd.SBQQ__OptionalSKU__c,childProd.SBQQ__ConfiguredSKU__c);
                foundProdIdSet.add(childProd.SBQQ__OptionalSKU__c);
            }
        }
        
        //delPrimaryContactMap will contain Delegate Admin and Primary Admin of Delegate Object
        if(contactId.size()>0){
            delPrimaryContactMap = Pilot_Sales_LicenseGenGenericFunctions.validateDelegateUsers(contactId);
        }
        
        // to get the license record of the original order
        //List<Sales_License__c> lcList = [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
        //                                 Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c,
        //                                 Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c 
        //                                 FROM Sales_License__c where
        //                                 Sales_License_Product__c IN:foundProdIdSet 
        //                                 AND (Sales_License_Primary_Admin_Contact__c IN:contactId OR Sales_License_Lic_User_Contact_ID__c IN:contactId
        //                                      OR(Sales_License_Primary_Admin_Contact__c IN : delPrimaryContactMap.values()))
        //                                 AND (Sales_License_Type__c =: LICENSE_TYPE_ORIGINAL) AND (Sales_License_Status__c != 'Cancelled')];// OR Sales_License_Type__c =: LICENSE_TYPE_EVALUATION) ]; 
        List<Sales_License__c> lcList = SEL_Sales_License.newInstance().selectByContactIdForOriginalLicense(foundProdIdSet, contactId, delPrimaryContactMap.values(), LICENSE_TYPE_ORIGINAL);// OR Sales_License_Type__c =: LICENSE_TYPE_EVALUATION) ]; 
        System.debug('lcList-->'+lcList);
        Set<Sales_License__c> lcListSet = new Set<Sales_License__c>(lcList);
        PRM_Execution_Controls__c skipValidations= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());

        if(lcList.isEmpty()){   
            for(OrderItem oi : orderItmList){
                if(renewalOrderitemIds.contains(oi.Id)){
                    if(!skipValidations.Skip_ValidationRule_Order_Status__c){
                    oi.addError(System.label.Sales_NoBaseForRenewal_ErrMsg);
                    }
                }
            }
        }
        Integer count =0 ;
        for(Sales_License__c lic: lcList){
            if(prodIdLicCountMap.containsKey(lic.Sales_License_Product__c)){
                System.debug('map entered'+prodIdLicCountMap);
                count = prodIdLicCountMap.get(lic.Sales_License_Product__c);//prodIdLicCountMap
                System.debug('Sales_License_Quantity__c'+lic.Sales_License_Quantity__c);
                if(lic.Sales_License_Quantity__c != null){
                    count = count + (Integer)lic?.Sales_License_Quantity__c;
                }
                System.debug('count-->'+count);
            }else{
                count = (Integer)lic?.Sales_License_Quantity__c;
                System.debug('else count'+count);
            }
            
            prodIdLicCountMap.put(lic.Sales_License_Product__c, count);
        }
        
        Decimal licenseRollupQuantity=0;
        //iterating list of base license records
        for(Sales_License__c lc : lcList){
            if(prod_ExtAttributeMap.size()>0){
                
                Decimal orderProductQuantity=0;
                Id originalRenewalProdID;       //To store Original Renewal Product Id for the Order product that the User is trying to Insert
                //checking if foundation product is same as Product in Base license
                if(foundationProdRenewalProdMap.containsKey(lc.Sales_License_Product__c) ||
                   (OptionalBaseMap.containsKey(lc.Sales_License_Product__c))){
                       System.debug('foundationProdRenewalProdMap>>>'+foundationProdRenewalProdMap);
                       Set<Id> foundationprodSet=new Set<Id>();
                       foundationprodSet = foundationProdRenewalProdMap.keyset(); 
                       Set<Id> orderitemprodSet=new Set<Id>();
                       orderitemprodSet = orderItemQuantityMap.keyset();  
                       //checking if orderItemQuantityMap map contains Renewal Product
                       if(orderItemQuantityMap.containsKey(lc.Sales_License_Product__c) ||
                          orderItemQuantityMap.containsKey((OptionalBaseMap.get(lc.Sales_License_Product__c)))){ 
                              if(isBundled){
                                  //getting quantity of renewal orderItem incase of Bundles
                                  orderProductQuantity=orderItemQuantityMap.get(foundationProdRenewalProdMap.get(OptionalBaseMap.get(lc.Sales_License_Product__c)));
                                  originalRenewalProdID = foundationProdRenewalProdMap.get(OptionalBaseMap.get(lc.Sales_License_Product__c));
                              }
                              else{
                                  //getting quantity of renewal orderItem incase of non bundled scenarios
                                  orderProductQuantity=orderItemQuantityMap.get(lc.Sales_License_Product__c); 
                                  originalRenewalProdID = foundationProdRenewalProdMap.get(lc.Sales_License_Product__c);
                              }
                              
                              //checking prodIdLicCountMap contains product in Base license and adding the license quantities 
                              if(prodIdLicCountMap.containsKey(lc.Sales_License_Product__c)){
                                  licenseRollupQuantity = prodIdLicCountMap.get(lc.Sales_License_Product__c);
                              }
                              
                              System.debug('orderProductQuantity**' +orderProductQuantity );
                              System.debug('licenseRollupQuantity ' +licenseRollupQuantity);
                            PRM_Execution_Controls__c skipValidation= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());

                              // checking if base records are less than Renewal OrderItem quantity
                              if(orderProductQuantity>licenseRollupQuantity){  
                                  System.debug('orderProductQuantity**' +orderProductQuantity );
                                  System.debug('licenseRollupQuantity ' +licenseRollupQuantity);
                                  if(!skipValidation.Skip_ValidationRule_Order_Status__c){
                                  ProdId_toBeInsertedOPMap.get(originalRenewalProdID).addError(System.label.Sales_BaseLicErrMsg);
                                  }
                              }
                              
                              
                          }
                   }
            }
            
        }
        //added by monika for
        //query for the renewal license records
        //for(Sales_License__c lic : [SELECT Id, Name, Sales_License_Account__c,Sales_License_Status__c, Sales_License_Expiration_Date_Dt__c,Sales_License_Maintenance_Exp_Dt__c,
        //                            Sales_License_Primary_Admin_Contact__c,Sales_License_Type__c,Sales_License_Lic_User_Contact_ID__c, Sales_License_Avbl_Qty_Nbr__c,
        //                            Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Order_Product__r.OrderItemNumber,Sales_License_Order_Product__c, Sales_Tool_License_Type__c,Sales_License_Product__r.Name  
        //                          from Sales_License__c 
        //                          where  Sales_License_Product__c IN:prodId  
        //                          AND (Sales_License_Primary_Admin_Contact__c IN:contactId OR Sales_License_Lic_User_Contact_ID__c IN:contactId
        //                               OR(Sales_License_Primary_Admin_Contact__c IN : delPrimaryContactMap.values()))
        //                          AND(Sales_License_Type__c ='Renewal') AND (Sales_License_Status__c != 'Cancelled')
        //                          AND Sales_License_Avbl_Qty_Nbr__c > 0 AND (Sales_License_Maintenance_Exp_Dt__c = null OR (Sales_License_Maintenance_Exp_Dt__c > :Date.Today()))  ]){
        for(Sales_License__c lic : SEL_Sales_License.newInstance().selectByContactIdForRenewal(contactId, prodId,delPrimaryContactMap.values())){
                                        //map of license product and available quantity
                                        licenseQuantityMap.put(lic.Sales_License_Product__c,lic.Sales_License_Avbl_Qty_Nbr__c );
                                        System.debug('licenseQuantityMap'+ licenseQuantityMap);
                                        System.debug('lic maint exp date '+lic.Sales_License_Maintenance_Exp_Dt__c);
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
                    System.debug('map entered'+renewalprodcountMap);
                    
                    renewalcount = renewalprodcountMap.get(lic.Sales_License_Product__c);
                    System.debug('Sales_License_Quantity__c'+lic.Sales_License_Quantity__c);
                    if(lic.Sales_License_Quantity__c != null){
                        renewalcount = renewalcount + (Integer)lic?.Sales_License_Quantity__c;
                    }
                    System.debug('renewalcount-->'+renewalcount);
                }else{
                    renewalcount = (Integer)lic?.Sales_License_Quantity__c;
                    System.debug('else count'+renewalcount);
                }
                renewalprodcountMap.put(lic.Sales_License_Product__c, renewalcount);
            }
        } 
        List<OrderItem> orderitemlist = new List<OrderItem>();
        Map<Id,OrderItem> ordItmIdToOrderitem = new Map<Id,OrderItem>();                     
        if(licenseQuantityMap!= null && !licenseQuantityMap.isEmpty()){
            //for(OrderItem oi : [select id ,Product2Id,  Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c, Quantity  from OrderItem where Id IN : orderItmList]){
            for(OrderItem oi : SEL_OrderItem.newInstance().selectByOrderItemIds(orderitemlist)){
                if(licenseQuantityMap.containsKey(oi.Product2Id)){
                    licenseRollupQuantity = prodIdLicCountMap.get(oi.Product2.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c);
                    licenseRenewalQuantity = (Decimal)renewalprodcountMap.get(oi.Product2Id);
                    //add quantity of foundation product of renewal product in licenseRollupQuantity
                    //if the qty of original license is  equal to the no of renewal license and the qty to be entered on new order of renewal is greater than 0
                    //licenseQuantityMap.get(oi.Product2Id)
                    if(!orderitemRenewalList.contains(oi.id)){
                        if( licenseRenewalQuantity == licenseRollupQuantity && (oi.Quantity != null&& oi.Quantity >= 1) ){
                            ordItmIdToOrderitem.put(oi.Id, oi);
                            System.debug('orderitemRenewalList'+ orderitemRenewalList);
                            System.debug('oi id'+ oi.id);
                            
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

            List<Object> parameters = new List<Object> {orderitemRenewalListName}; //  Order Product Name of Renewal type
            String errorText = System.Label.Sales_NotEnoughBaseToRenew_CloneErrMsg; // custom Label of error text
            String formattedErrorText = String.format(errorText, parameters);  // formatting the Product Names with error text.

            for(orderItem o : orderItmList){ // if order is in order item list
                if(ordItmIdToOrderitem.containsKey(o.Id) ){
                   //  System.debug('Inside Normal Error -->');
                    //if map contains orderproduct id then add error on orderproduct 
                    PRM_Execution_Controls__c skipValidation= PRM_Execution_Controls__c.getInstance(UserInfo.getUserId());

                    if(o.isclone()){
                        //System.debug('Inside Clone Error -->');
                        o.addError(formattedErrorText); // displaying the formatting error message
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
}