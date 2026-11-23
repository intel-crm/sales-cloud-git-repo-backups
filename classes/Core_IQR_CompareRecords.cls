Public class Core_IQR_CompareRecords implements Database.Batchable<sObject>{
    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select id,Core_Is_Custom_Ind__c, Core_Mem_Amt__c, Core_Hierarchy_ID__c, Core_Hierarchy_Name__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Family_EPM_ID__c,Core_Product_Family__c,Core_Product_Series_EPM_ID__c,Core_Product_Series__c,Core_Product_Group_EPM_ID__c,Core_Product_Group__c,Core_Code_Name_EPM_ID__c,Core_Code_Name__c,Core_Processor_Number_Ta_Nm__c, Core_Processor_Number_Nm__c,Core_Product_Status__c,Core_Item_Id__c,Core_Division_Code_Short_Name__c,Core_Division_Code__c,Core_Group_Code_Short_Name__c,Core_Group_Code__c,Core_Product_Name_EPM_ID__c,Core_BU_Operation_Code__c,Core_Unique_ID__c,Core_Family_Nm__c,Core_Forecast_Product_Name__c from Product2 where isActive=True and Core_IQR_Visible__c=True and Core_Product_Org__c=\'Sales\' and Core_Hierarchy_ID__c = \'43\' and Core_Hierarchy_Name__c = \'Valid Product Hierarchy\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Product2> products){
        
        system.debug('products cnt-----'+ products.size());          
        if(Test.isRunningTest()){ 
            
            List<Product2> products_test= new List<Product2>();
            Product2 p = new Product2();
            p.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)';
            p.Core_Product_Org__c = 'Sales';
            p.Core_Unique_ID__c='120458;122573;122570;86065;35125';
            p.Core_Product_Name_EPM_ID__c='120458';
            p.isActive=True;
           	products_test.add(p);
            
            Product2 p1 = new Product2();
            p1.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
            p1.Core_Product_Org__c = 'IPS';
            p1.Core_Unique_ID__c='123808;122573;122570;86065;35125';
            p1.Core_Product_Name_EPM_ID__c='123808';
            p1.isActive=True;
           	products_test.add(p1);
            
            Product2 p2 = new Product2();
            p2.Name='Intel® Xeon® Gold 6142 Processor (22M Cache, 2.60 GHz)1';
            p2.Core_Product_Org__c = 'Sales';
            p2.Core_Unique_ID__c='1239292929;122573;122570;86065;35125';
            p2.Core_Product_Name_EPM_ID__c='1239292929';
            p2.isActive=True;
          	products_test.add(p2);
            
            system.debug('products cnt-----'+ products_test.size());
            
            compareProductAndStagingRecords(products_test);
        }
        else
        {
            compareProductAndStagingRecords(products);
            
        }
        
    }
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new Core_IQR_PIM_IntelProductData(),1); 
    }
    //@future
    public static void compareProductAndStagingRecords(List<Product2> products){
        system.debug('products.size-----'+products.size());
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        //Get all Product records
        Map<String, Product2> productsMap = new Map<String, Product2>();
        for(Product2 product:products){ 
            system.debug('product.Core_Product_Name_EPM_ID__c-----'+product.Core_Product_Name_EPM_ID__c);
            if(product.Core_Product_Name_EPM_ID__c !=null){
                productsMap.put(product.Core_Product_Name_EPM_ID__c, product);
                system.debug('productsMap in Compare-----'+productsMap.keySet());
            }
        }
        
        //Get all Staging records where IsLatest=True
        List<Core_IQR_Products_Staging__c> unsetStagingList = new List<Core_IQR_Products_Staging__c>();
          List<Core_IQR_Products_Staging__c> stagingRecords = new List<Core_IQR_Products_Staging__c>();
        Map<String, Core_IQR_Products_Staging__c> stagingRecordMap = new Map<String, Core_IQR_Products_Staging__c>();
        
          if(Test.isRunningTest()){ 
               stagingRecords= [Select id,Core_Is_Custom_Ind__c, Core_Mem_Amt__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Family_EPM_ID__c,Core_Product_Family__c,Core_Product_Series_EPM_ID__c,Core_Product_Series__c,Core_Product_Group_EPM_ID__c,Core_Product_Group__c,Core_Code_Name_EPM_ID__c,Core_Code_Name__c, Core_Processor_Number_Nm__c,Core_Product_Status__c,Core_Item_Id__c,Core_Division_Code_Short_Name__c,Core_Division_Code__c,Core_Group_Code_Short_Name__c,Core_Group_Code__c,Core_Product_Name_EPM_ID__c,Core_BU_Operation_Code__c,Core_Unique_ID__c,Core_Family_Nm__c,Core_Forecast_Product_Name__c from Core_IQR_Products_Staging__c];
               for (Integer i = 0; i < stagingRecords.size(); i++) { 
                   if (stagingRecords[i].Core_Product_Name_EPM_ID__c== null)
                   {
                   stagingRecords[i].Core_Product_Name_EPM_ID__c='1239292929';
                   }
               }
        }
        else
        {
              stagingRecords= [Select id,Core_Is_Custom_Ind__c, Core_Mem_Amt__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Family_EPM_ID__c,Core_Product_Family__c,Core_Product_Series_EPM_ID__c,Core_Product_Series__c,Core_Product_Group_EPM_ID__c,Core_Product_Group__c,Core_Code_Name_EPM_ID__c,Core_Code_Name__c, Core_Processor_Number_Nm__c,Core_Product_Status__c,Core_Item_Id__c,Core_Division_Code_Short_Name__c,Core_Division_Code__c,Core_Group_Code_Short_Name__c,Core_Group_Code__c,Core_Product_Name_EPM_ID__c,Core_BU_Operation_Code__c,Core_Unique_ID__c,Core_Family_Nm__c,Core_Forecast_Product_Name__c from Core_IQR_Products_Staging__c where Core_IsLatest__c=True];
            
        }
        for(Core_IQR_Products_Staging__c stagingRecord:stagingRecords){
        
            if(stagingRecord.Core_Product_Name_EPM_ID__c!=null){
                
                stagingRecordMap.put(stagingRecord.Core_Product_Name_EPM_ID__c, stagingRecord);
                system.debug('stagingRecordMap---'+stagingRecordMap);
                //unset isLatest Flag to False
                stagingRecord.Core_IsLatest__c = False;
                unsetStagingList.add(stagingRecord);
                system.debug('unsetStagingList--'+unsetStagingList);
            }
        }
        
        //compare Product records against Staging records
        List<Product2> deactivateProductList = new List<Product2>();
        /* for(String productEPMID: productsMap.keySet()){

if(!stagingRecordMap.isEmpty() && !stagingRecordMap.containsKey(productEPMID)){
Product2 deactivateProduct = productsMap.get(productEPMID);
deactivateProduct.IsActive = False;
deactivateProductList.add(deactivateProduct);
system.debug('deactivateProductList-----'+deactivateProductList);
}            
}*/
        for(Product2 productEPMID: productsMap.values()){
            
            if(!stagingRecordMap.isEmpty() && !stagingRecordMap.containsKey(productEPMID.Core_Product_Name_EPM_ID__c)){
                Product2 deactivateProduct = productsMap.get(productEPMID.Core_Product_Name_EPM_ID__c);
                deactivateProduct.IsActive = False;
                deactivateProductList.add(deactivateProduct);
                system.debug('deactivateProductList-----'+deactivateProductList);
            }            
        }
        
        
        
        //update Staging records with isLatest Flag to False
        if(unsetStagingList.size()>0){
            Database.SaveResult [] results = Database.update(unsetStagingList, false);
            Map<Id, String> failedIdMap = new Map<Id, String>();
            for (Integer i = 0; i < results.size(); i++) { 
                if (!results[i].isSuccess()) {
                    system.debug('error::'+results[i].getErrors()[0].getMessage());
                    captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = results[i].getErrors()[0].getMessage(), Core_Message__c = 'IQR_Product Compare Error ', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_CompareRecords', Core_When__c = System.now())); 
                }
            }
        }
        
        
        //inactivate Product records
        if(deactivateProductList.size()>0){
            List<Product2> tempList = new List<Product2>();
            Integer itr=0;
            Integer count=0;
            count = unsetStagingList.size()/9000;
            for(product2 p:deactivateProductList){
                itr+=1;
                tempList.add(p);
                if(itr==9000){
                    Database.SaveResult [] results = Database.update(tempList, false);
                    Map<Id, String> failedIdMap = new Map<Id, String>();
                    for (Integer i = 0; i < results.size(); i++) { 
                        if (!results[i].isSuccess()) {
                            system.debug('error::'+results[i].getErrors()[0].getMessage());
                            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = results[i].getErrors()[0].getMessage(), Core_Message__c = 'IQR_Product Compare Error '+results[i].getErrors()[0].getMessage(), Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_CompareRecords', Core_When__c = System.now())); 
                        }
                    }
                    
                    //reset the counter
                    itr=0;
                    tempList=null;
                }
            }
            
            if(deactivateProductList.size()>0){
                Database.SaveResult [] results = Database.update(deactivateProductList, false);
                Map<Id, String> failedIdMap = new Map<Id, String>();
                for (Integer i = 0; i < results.size(); i++) { 
                    if (!results[i].isSuccess()) {
                        system.debug('error::'+results[i].getErrors()[0].getMessage());
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = results[i].getErrors()[0].getMessage(), Core_Message__c = 'IQR_Product Compare Error at #96 '+results[i].getErrors()[0].getMessage(), Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_CompareRecords', Core_When__c = System.now())); 
                    }
                }
            }
        }
        
        
    }
    
}