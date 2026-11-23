global class Sales_Future_LicenseGeneration {
    @future(Callout = true)
    public static void LicenseGenFileCorporateRenewal(){
    Map<Id,Id> licensehostmap = new Map<id, Id>();
    Set<id> orderid = new Set<id>();
    Set<id> licenseid = new Set<id>();
    List<Order> ordelist = new list<Order>();  
    List<Sales_License__c>licensesList = new List<Sales_License__c>();
        for(Sales_License__c lic : [Select Id, Sales_License_Quantity__c ,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Temporary_Lic_Allowed_Ind__c,Sales_License_Host_Node_Id__c,
                                    Sales_License_Avbl_Qty_Nbr__c ,Sales_License_Status__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Max_Rehost_Cnt__c,
                                    Sales_License_Order_Product__r.Order.Sales_Order_Sub_Type__c,Sales_License_Avbl_Rehost_Nbr__c, Sales_License_Maintenance_Exp_Dt__c,Sales_License_Expiration_Date_Dt__c,
                                    Sales_License_Available_Temp_Licenses__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                    Sales_License_Order__c, Sales_License_Order_Product__c,Sales_License_Order__r.Sales_Order_Sub_Type__c,
                                    Sales_License_Order__r.Type, Sales_License_Order__r.Status, Sales_License_Order__r.Sales_status__c
                                    from Sales_License__c  where 
                                    Sales_License_Status__c = 'Licensed' AND Sales_License_Host_Node_Id__c != null  ]){
                                        
            licensehostmap.put(lic.id,lic.Sales_License_Host_Node_Id__c);
            licensesList.add(lic);
        }
        if(licensehostmap.size()>0){
        for(Sales_License__c lc :licensesList){
            orderid.add(lc.Sales_License_Order__c);//total order ids
        } 
            
        }
        
        for(order o : [select id ,Sales_Order_Sub_Type__c, Type,  SBQQ__Quote__r.SBQQ__Type__c,  name from Order where id IN :orderid
                       AND Sales_Order_Sub_Type__c ='Corporate Order' AND  SBQQ__Quote__r.SBQQ__Type__c ='Renewal' ]){
                           
            ordelist.add(o);
        }
        
        for(Sales_License__c lc :[select id, Sales_License_Order__c,Sales_License_Order__r.Type,Sales_License_Order__r.Status, Sales_License_Order__r.Sales_status__c,Sales_License_Host_Node_Id__c
                                  from Sales_License__c where Sales_License_Order__c in :ordelist]   ){
            
            licenseid.add(lc.id);
            
            if(lc.Sales_License_Order__r.Status == 'Activated' && lc.Sales_License_Order__r.Sales_status__c == 'SAP Order Shipped' 
               && lc.Sales_License_Order__r.Type == 'Licensed Tool Order' || lc.Sales_License_Order__r.Type == 'Sample Order' ){
                   Sales_LicenseGenIntegration_Utility.returnHostIdDetail(lc.Sales_License_Host_Node_Id__c, 'HostId','');
                   
               }
            if(lc.Sales_License_Order__r.Status == 'Activated' && lc.Sales_License_Order__r.Sales_status__c == 'Order created successfully' 
               && lc.Sales_License_Order__r.Type == 'Non Commercial Order'){
             Sales_LicenseGenIntegration_Utility.returnHostIdDetail(lc.Sales_License_Host_Node_Id__c, 'HostId','');
             System.debug('lc.Sales_License_Host_Node_Id__c'+lc.Sales_License_Host_Node_Id__c); 
               } 
        }
    }

}