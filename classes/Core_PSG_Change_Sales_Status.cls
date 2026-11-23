/**************************************************************************************
Apex Class Name:  Core_PSG_Change_Sales_Status
Version     : 1.0 
Created Date: 04 JAN 2021
Function    : Function to Update Sales Status Code - Quotable, Shippable and Orderable 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------------------------------------------------                 
* Gireesh K             04/01/2021              update_Sales_Status() Update Sales Status Code - Quotable, Shippable and Orderable
* 
to Signal Code and differentiate the products based on its Type
************************************************************************************************************************/
public  with sharing class Core_PSG_Change_Sales_Status {
    Public static void updateProductRecord(List<Core_Product_Ext_Attribute__c> updatedExtendedAttributeList){
        try{
            List<Product2> updateProductRecordList = new List<Product2>();
            for(Core_Product_Ext_Attribute__c updatedExtendedAttribute: updatedExtendedAttributeList){
                if(updatedExtendedAttribute.Core_Product_Id__c!=null){
                    Product2 updateProductRecord= new Product2();
                    updateProductRecord.Core_Product_Ext_Attribute_Id__c=updatedExtendedAttribute.id;
                    updateProductRecord.id=updatedExtendedAttribute.Core_Product_Id__c;
                    updateProductRecordList.add(updateProductRecord); 
                }                
            }            
            if(updateProductRecordList!=null && updateProductRecordList.size()>0 && Product2.SObjectType.getDescribe().isUpdateable()){
                update updateProductRecordList;
            }
        }
        Catch(Exception e){
        }        
    }
    Public static void updateSalesStatus(List<Product2> updatedProductList, Map<Id,Product2> oldMap){
        try{           
            final String TOOL = 'Tool';
            final String COMPONENT = 'Component';
            List<Product2> productsToUpdate = new List<Product2>();
            Map<String, Core_PSG_Product_Status_Code_Mapping__mdt> productSignalStatusCodeMetadataMap = new Map<String, Core_PSG_Product_Status_Code_Mapping__mdt>();
            List<Core_PSG_Product_Status_Code_Mapping__mdt> productSignalStatusCodeMetadataList = [SELECT Id,DeveloperName,QualifiedApiName,Status_Code__c,Quotable__c, Orderable__c, Shippable__c,Price_Auth__c FROM Core_PSG_Product_Status_Code_Mapping__mdt WITH SECURITY_ENFORCED];
            for(Core_PSG_Product_Status_Code_Mapping__mdt productSignalStatusCodeMetadata: productSignalStatusCodeMetadataList){
                productSignalStatusCodeMetadataMap.put(productSignalStatusCodeMetadata.Status_Code__c, productSignalStatusCodeMetadata);
            }
            Map<String, Product2> statusCodeProductMap = new Map<String, Product2>();
            for(Product2 updatedProduct: updatedProductList){ 
                if(oldMap==null){
                    if(updatedProduct.Core_Product_Type_Nm__c==TOOL){
                        statusCodeProductMap.put(updatedProduct.Core_Product_Status__c+updatedProduct.Id, updatedProduct);
                    }
                    else if(updatedProduct.Core_Product_Type_Nm__c==COMPONENT){
                        statusCodeProductMap.put(updatedProduct.Core_Item_Signal_Cd__c+updatedProduct.Id, updatedProduct);
                    }
                }
                else if(oldMap!=null && oldMap.size()>0 && oldMap.get(updatedProduct.Id).Core_Item_Signal_Cd__c !=updatedProduct.Core_Item_Signal_Cd__c || 
                        oldMap.get(updatedProduct.Id).Core_Product_Status__c !=updatedProduct.Core_Product_Status__c ||
                        oldMap.get(updatedProduct.Id).Core_Item_Class_Nm__c != updatedProduct.Core_Item_Class_Nm__c
                       ){  
                           if(updatedProduct.Core_Product_Type_Nm__c==TOOL){
                               statusCodeProductMap.put(updatedProduct.Core_Product_Status__c+updatedProduct.Id, updatedProduct);
                           }
                           else if(updatedProduct.Core_Product_Type_Nm__c==COMPONENT){
                               statusCodeProductMap.put(updatedProduct.Core_Item_Signal_Cd__c+updatedProduct.Id, updatedProduct);
                           }
                           else{
                               statusCodeProductMap.put(updatedProduct.Id, updatedProduct);
                           }
                       }
            }
            for(String statusCode : statusCodeProductMap.keySet()){
                Product2 product=null;
                String statusCodeSubString=statusCode.substring(0, 2);
                Core_PSG_Product_Status_Code_Mapping__mdt statusCodeDetails=null;
                if(statusCodeProductMap.containsKey(statusCode))
                {
                    product= statusCodeProductMap.get(statusCode); 
                }               
                if(productSignalStatusCodeMetadataMap.containsKey(statusCodeSubString)){
                    statusCodeDetails = productSignalStatusCodeMetadataMap.get(statusCodeSubString);
                }
                Product2 updateProductStatusCode = new Product2();
                if(statusCodeDetails!=null){                    
                    updateProductStatusCode.Core_Item_Orderable_Ind__c=statusCodeDetails.Orderable__c;
                    updateProductStatusCode.Core_Item_Shippable_Ind__c = statusCodeDetails.Shippable__c;
                    updateProductStatusCode.Core_Item_Quotable_Ind__c= statusCodeDetails.Quotable__c;
                    updateProductStatusCode.Core_Item_Price_Authorization_Ind__c = statusCodeDetails.Price_Auth__c;
                    updateProductStatusCode.Id = product.Id;
                    if(product.Core_Product_Type_Nm__c==TOOL){ 
                        updateProductStatusCode.Core_Item_Price_Authorization_Ind__c = False;
                    }
                    productsToUpdate.add(updateProductStatusCode);
                }else{
                    updateProductStatusCode.Core_Item_Orderable_Ind__c=False;
                    updateProductStatusCode.Core_Item_Shippable_Ind__c = False;
                    updateProductStatusCode.Core_Item_Quotable_Ind__c= False;
                    updateProductStatusCode.Core_Item_Price_Authorization_Ind__c = False;
                    updateProductStatusCode.Id = product.Id;
                    productsToUpdate.add(updateProductStatusCode);
                }         
            }
            if(productsToUpdate.size()>0 && Product2.SObjectType.getDescribe().isUpdateable()){
                update productsToUpdate;
            }
        }
        catch(Exception ex){
        }
    }
 	/*
    * Method name  : SendUpdatedProductstoOrders
    * Description  : Method to Call Order Related Methods on change of Subscription Pricing and Type fileds on Product
    * Return Type  : void
    * Parameter    : List<Product2> newProductList, Map<Id, Product2> oldProdMap
    */   
    public static void SendUpdatedProductstoOrders(List<Product2> newProductList, Map<Id, Product2> oldProdMap){
        List<Product2> ProdLst= new List<Product2>();
        for(Product2 prodRec : newProductList){
            if(prodRec.SBQQ__SubscriptionPricing__c != oldProdMap.get(prodRec.Id).SBQQ__SubscriptionPricing__c ||prodRec.SBQQ__SubscriptionType__c != oldProdMap.get(prodRec.Id).SBQQ__SubscriptionType__c){            
                ProdLst.add(prodRec);              
            }            
        } 
        if(ProdLst.size() >0){
            Sales_UpdateProductDetails.updateProductDetails_OrderproductSubscription(ProdLst);
        }
    }
}