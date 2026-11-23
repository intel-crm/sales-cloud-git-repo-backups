/******************************************************************************************************************
Class Name    : Sales_UpdateProductDetails
Version       : 1.0
Created Date  : Jan 2022
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Nilesh Mithapelli           12-Jan-2022           TWC3144-149 :Dev - Update Order Product and Subscription related fileds on update of Product
* *********************************************************************************************************************/
public without sharing class Sales_UpdateProductDetails {
    public static final string ORIGIN = 'Sales_UpdateProductDetails';
    public static final string CRITICALSEVERITY = 'Critical';
    public static final string INFOSEVERITY = 'Info';
    public static final string SUCCESSSEVERITY = 'Operation Completed Successfully!';
    public static final string FAILSEVERITY = 'Operation Failed!';
    public static final string ORDERPRODUCTOBJECTNAME = 'OrderItem';
    public static final string SUBSCRIPTIONOBJECTNAME = 'SBQQ__Subscription__c';
    public static final string PROJECT = 'PSG Sales';
    public static boolean BypassTriggerForProductUpdate=false;
    private static final string SUBSCRIPTION_TYPE = 'Renewable';
    private static final string SUBSCRIPTION_PRICING = 'Fixed Price';
    private static final string ORDER_STATUS = 'Draft';
    private static final string CONTRACT_PROGRAM = 'PSG';
    public static void updateProductDetails_OrderproductSubscription(List<Product2> productList){
        set<Id> productId= new Set<Id>();
        for(Product2 prod : productList){
            productId.add(prod.Id);
        }
        System.enqueueJob(new upadateProductDetailsOnOrderproductSubscription(productId));
    }
    public without sharing class upadateProductDetailsOnOrderproductSubscription implements System.Queueable{
        private set<Id> productId;
        public upadateProductDetailsOnOrderproductSubscription(set<Id> productId){
            this.productId=productId;
        }
        public void execute(System.QueueableContext ctx){
            BypassTriggerForProductUpdate = true;
            Boolean successOrderProduct=true; 
            Boolean successSubscription=true; 
            List<OrderItem> orderproductListUpdate = new List<OrderItem>();
            List<OrderItem> ordProdlist = [Select id,OrderItemNumber,SBQQ__QuoteLine__c,OrderId,Order.Status,Order.SBQQ__Quote__c, Product2Id, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionType__c, SBQQ__ProductSubscriptionType__c,Product2.SBQQ__SubscriptionPricing__c, Product2.SBQQ__SubscriptionType__c,Product2.IsActive from OrderItem where Product2Id IN:productId and Product2.IsActive=true and Order.Status =:ORDER_STATUS and Order.SBQQ__Quote__c!=null and SBQQ__QuoteLine__c!=null and ((Product2.SBQQ__SubscriptionPricing__c=:SUBSCRIPTION_PRICING and SBQQ__SubscriptionPricing__c = null) or ( Product2.SBQQ__SubscriptionType__c=:SUBSCRIPTION_TYPE and ( SBQQ__SubscriptionType__c = null or  SBQQ__ProductSubscriptionType__c = null))) limit 10000 FOR UPDATE];
            if(ordProdlist.size()>0){
                try{
                    for (OrderItem oi : ordProdlist) {
                        if(oi.SBQQ__SubscriptionPricing__c!=oi.Product2.SBQQ__SubscriptionPricing__c && oi.Product2.SBQQ__SubscriptionPricing__c==SUBSCRIPTION_PRICING){
                            oi.SBQQ__SubscriptionPricing__c = oi.Product2.SBQQ__SubscriptionPricing__c;
                        }
                        if(oi.SBQQ__SubscriptionType__c!=oi.Product2.SBQQ__SubscriptionType__c && oi.Product2.SBQQ__SubscriptionType__c==SUBSCRIPTION_TYPE){
                            oi.SBQQ__SubscriptionType__c = oi.Product2.SBQQ__SubscriptionType__c;
                        }
                        if(oi.SBQQ__ProductSubscriptionType__c!=SUBSCRIPTION_TYPE){
                            oi.SBQQ__ProductSubscriptionType__c=SUBSCRIPTION_TYPE;
                        }
                        orderproductListUpdate.add(oi);
                    }
                    if(orderproductListUpdate.size()>0){
                    	update orderproductListUpdate;
                    } 
                    System.enqueueJob(new upadateProductDetailsOnOrderproductSubscription(productId));
                }
                catch (Exception e){
                    Core_Log_Entry.logEntryWithDetails(Sales_UpdateProductDetails.ORIGIN, Sales_UpdateProductDetails.PROJECT,'',Sales_UpdateProductDetails.INFOSEVERITY,'','Error occurred while initializng the updation of product Details on Orderproduct  : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');   
                	successOrderProduct = false;
                }
            }
            else{
                List<SBQQ__Subscription__c> subListUpdate= new List<SBQQ__Subscription__c>();
                List<SBQQ__Subscription__c> subsList = [Select id,Name,SBQQ__Product__c,SBQQ__Contract__c,SBQQ__Contract__r.Sales_Program__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionType__c, SBQQ__ProductSubscriptionType__c,SBQQ__Product__r.SBQQ__SubscriptionPricing__c,SBQQ__Product__r.SBQQ__SubscriptionType__c,SBQQ__Product__r.IsActive from SBQQ__Subscription__c where SBQQ__Product__c IN:productId and SBQQ__Product__r.IsActive=true and SBQQ__Contract__c!=null and SBQQ__Contract__r.Sales_Program__c =:CONTRACT_PROGRAM and  ((SBQQ__Product__r.SBQQ__SubscriptionPricing__c=:SUBSCRIPTION_PRICING and SBQQ__SubscriptionPricing__c = null) or ( SBQQ__Product__r.SBQQ__SubscriptionType__c=:SUBSCRIPTION_TYPE and ( SBQQ__SubscriptionType__c = null or  SBQQ__ProductSubscriptionType__c = null))) limit 10000 FOR UPDATE] ;
                if(subsList.size()>0){
                    try{
                        for(SBQQ__Subscription__c sub : subsList){
                            if(sub.SBQQ__SubscriptionPricing__c!=sub.SBQQ__Product__r.SBQQ__SubscriptionPricing__c && sub.SBQQ__Product__r.SBQQ__SubscriptionPricing__c==SUBSCRIPTION_PRICING ){
                                sub.SBQQ__SubscriptionPricing__c = sub.SBQQ__Product__r.SBQQ__SubscriptionPricing__c;
                            }
                            if(sub.SBQQ__SubscriptionType__c!=sub.SBQQ__Product__r.SBQQ__SubscriptionType__c && sub.SBQQ__Product__r.SBQQ__SubscriptionType__c==SUBSCRIPTION_TYPE){
                                sub.SBQQ__SubscriptionType__c=sub.SBQQ__Product__r.SBQQ__SubscriptionType__c;
                            }
                            if(sub.SBQQ__ProductSubscriptionType__c!=SUBSCRIPTION_TYPE){
                                sub.SBQQ__ProductSubscriptionType__c=SUBSCRIPTION_TYPE;
                            } 
                            subListUpdate.add(sub);
                        }
                        if(subListUpdate.size()>0){
                        	update subListUpdate;
                        } 
                        System.enqueueJob(new upadateProductDetailsOnOrderproductSubscription(productId));
                    }
                    catch (Exception e){
                        Core_Log_Entry.logEntryWithDetails(Sales_UpdateProductDetails.ORIGIN, Sales_UpdateProductDetails.PROJECT,'',Sales_UpdateProductDetails.INFOSEVERITY,'','Error occurred while initializing the updation of product Details on subscription  : '+ e.getMessage()+' , Stack trace: '+e.getStackTraceString(),'', '', '');   
                    	successSubscription=false;
                    }
                }
            }
            if(successOrderProduct==true){  
                Core_Log_Entry.logEntryWithDetails(Sales_UpdateProductDetails.ORIGIN, Sales_UpdateProductDetails.PROJECT,'',Sales_UpdateProductDetails.INFOSEVERITY,'','Successfully Updated Product Details on OrderProduct','','', '');    
            }
            if(successSubscription==true){     
                Core_Log_Entry.logEntryWithDetails(Sales_UpdateProductDetails.ORIGIN, Sales_UpdateProductDetails.PROJECT,'',Sales_UpdateProductDetails.INFOSEVERITY,'','Successfully Updated Product Details on Subscription','','', '');   
            }  
        }    
    }      
}