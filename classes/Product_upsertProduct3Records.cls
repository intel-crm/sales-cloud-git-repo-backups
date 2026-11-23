global class Product_upsertProduct3Records  implements Database.Batchable<sObject>,Database.stateful {
    public String ipaasId;  
    public List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();   
    //List<Core_Deactivation_Log_Entry__c> deactivationLogEntries = new List<Core_Deactivation_Log_Entry__c>();
    public Heap_Analysis__c hp = new Heap_Analysis__c(); 
    public Integer recordCount = 0;
    //fetch ipaasloadId
    public Product_upsertProduct3Records(String ipaasLoadId){
        this.ipaasId=ipaasLoadId;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        system.debug('--------------------- inside start method --------------------- '+ipaasId);
        // for analysis
        hp.Class_Name__c ='Product_upsertProduct3Records';
        hp.iPaaS_Load_ID__c = ipaasId;
        hp.Start_Time__c = system.now();
        //fetch Core_Products_Staging__c records
        String query = 'SELECT '+String.join(Product_Utility.getObjectFields('Core_Products_Staging__c'),',')+' FROM Core_Products_Staging__c WHERE iPaaS_Load_ID__c =: ipaasId';
        return Database.getQueryLocator(query);  
    }    
    public void execute(Database.BatchableContext BC, List<Core_Products_Staging__c> stgRecords){
        /*
        system.debug('--------------------- inside execute method ---------------------');
        system.debug('The start time of Upsert product batch >>>  -----'+ System.now());          
        System.debug('stgRecords size -- '+stgRecords.size());        
        recordCount += stgRecords.size();
        List<Product2> productsToUpsertList = new List<Product2>();
        Map<String,String> stgToFph_fieldMappingTable = new Map<String,String>();
        Map<String,String> stgToProd_fieldMappingTable = new Map<String,String>();
        List<Core_Flat_Product_Hierarchy__c> fphToUpsertList = new List<Core_Flat_Product_Hierarchy__c>();
        // metadata mapping from staging to product3 and fph using -- Product_fields_mapping__mdt  
        for (Product_fields_mapping__mdt  mappingRec : Product_fields_mapping__mdt.getall().Values()) {
            if(mappingRec.Product_staging_field__c != null && mappingRec.Product2_field__c != null && (mappingRec.Type__c == 'Mapping' || mappingRec.Type__c == 'Rollup'  ) && (mappingRec.Product_Org__c == 'Sales' || mappingRec.Product_Org__c == 'IPS' ) ){
                stgToProd_fieldMappingTable.put(mappingRec.Product2_field__c,mappingRec.Product_staging_field__c);
            } 
            else if(mappingRec.Product_staging_field__c != null && mappingRec.FPH_Field__c != null && mappingRec.Type__c == 'Mapping' && mappingRec.Product_Org__c == 'FPH') {
                stgToFph_fieldMappingTable.put(mappingRec.FPH_Field__c,mappingRec.Product_staging_field__c);
            }           
        } 
        // auto insert/update product3 records using external id -- Core_Unique_ID__c
        if(!stgRecords.isEmpty() && stgRecords.size()>0){
            for (Core_Products_Staging__c stgRec :stgRecords){
                // if(stgRec.Log_Comments__c!=null){   
                //	deactivationLogEntries.add(new Core_Deactivation_Log_Entry__c(Core_Details__c='',Core_Message__c=stgRec.Log_Comments__c,Method_Name__c='Product_upsertProduct3Records',Class_Name__c='',When__c=System.now()));
                // }
                // for Sales and IPS
                if(stgRec.Core_Unique_ID__c != null && (stgRec.Core_Product_Org__c == Product_Staging_StaticConstants.sales || stgRec.Core_Product_Org__c == Product_Staging_StaticConstants.ips)){
                    Product2 productToUpsert = new Product2();                            
                    // fields mapping
                    for(String field: stgToProd_fieldMappingTable.keySet()) {                
                        productToUpsert.put(field, stgRec.get(stgToProd_fieldMappingTable.get(field)));                   
                    }                                
                    productsToUpsertList.add(productToUpsert);                   
                }
                // for FPH
                else{
                    Core_Flat_Product_Hierarchy__c fphRecordToUpsert = new Core_Flat_Product_Hierarchy__c();            
                    //fields mapping
                    for(String field: stgToFph_fieldMappingTable.keySet()) {
                        fphRecordToUpsert.put(field, stgRec.get(stgToFph_fieldMappingTable.get(field)));  
                    }
                    fphToUpsertList.add(fphRecordToUpsert);
                }              
            } 
        }   
        System.debug('log size -- '+logEntries.size());     
        //insert logEntries;// change to stateful
        //upserting the final list of product3
        if(!productsToUpsertList.isEmpty()){
            Database.UpsertResult [] results = Database.upsert(productsToUpsertList, Product2.Core_Unique_ID__c, false);
            //upsert productsToUpsertList Core_Unique_ID__c;            
            for(Database.UpsertResult sr : results ) {
                if(!sr.isSuccess()){
                    logEntries.add(new Core_Log_Entry__c(Core_Details__c = sr.getErrors()[0].getMessage(),Core_Message__c = 'Product2 upsert '+sr.getErrors()[0].getMessage(),Core_Severity__c = 'High',Core_Project__c='Product',Core_Origin__c='Product_upsertProduct3Records',Core_When__c = System.now()));                    
                    //Product_Utility.logEntryWithDetails('Product_upsertProduct3Records', 'Products', 'upsert product3 Record', 'exception', 'Exception occured while upserting Product2', sr.getErrors()[0].getMessage(), sr.getId(), 'Product2', 'Product2');
                }
            }
        }
        //upserting the final list of fph
        if(!fphToUpsertList.isEmpty()){
            Database.UpsertResult [] results = Database.upsert(fphToUpsertList, Core_Flat_Product_Hierarchy__c.Core_Unique_ID__c , false);
            //upsert fphToUpsertList Core_Unique_ID__c;            
            for(Database.UpsertResult sr : results ) {
                if(!sr.isSuccess()){
                    logEntries.add(new Core_Log_Entry__c(Core_Details__c = sr.getErrors()[0].getMessage(),Core_Message__c = 'Core_Flat_Product_Hierarchy__c upsert '+sr.getErrors()[0].getMessage(),Core_Severity__c = 'High',Core_Project__c='Product',Core_Origin__c='Product_upsertProduct3Records',Core_When__c = System.now())); 
                    //Product_Utility.logEntryWithDetails('Product_upsertProduct3Records', 'Products', 'upsert Core_Flat_Product_Hierarchy__c Record', 'exception', 'Exception occured while upserting Core_Flat_Product_Hierarchy__c', sr.getErrors()[0].getMessage(), sr.getId(), 'Core_Flat_Product_Hierarchy__c', 'Core_Flat_Product_Hierarchy__c');
                }
            }
        } */
    }    
    public void finish(Database.BatchableContext BC) {
       /* System.debug('--------------------- inside finish method ---------------------');
        system.debug('Log size---'+logEntries.size());
        
        List<Core_Flat_Product_Hierarchy__c> fphRecordsToDelete = [SELECT Id FROM Core_Flat_Product_Hierarchy__c WHERE Core_iPaaS_Load_ID__c != :ipaasId limit 999];
        System.debug('fphRecordsToDelete size ------' + fphRecordsToDelete.size());
        if (!fphRecordsToDelete.isEmpty()) {
            Database.delete(fphRecordsToDelete,false);
        } 
        //Product Deactivation ---- Based on iPaaS ID 
        List<Product2> deactivationPrdLst = [SELECT Id, Core_Hierarchy_ID__c, Core_Hierarchy_Name__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Status__c,Core_Product_Name_EPM_ID__c,IsActive 
                                             FROM Product2 WHERE Core_iPaaS_Load_ID__c != :ipaasId  AND Core_Product_Org__c =: Product_Staging_StaticConstants.sales limit 9000 FOR UPDATE ];
        List<Product2> lstProduct = new List<Product2>();
        for(Product2 prd : deactivationPrdLst){
            prd.IsActive = false;
            lstProduct.add(prd);
        }
        try{
            //update Product2 with IsActive__c = false
            Database.SaveResult [] results = Database.update(lstProduct, false); 
            for (Integer i = 0; i < results.size(); i++) { 
                if (!results[i].isSuccess()) {
                    logEntries.add(new Core_Log_Entry__c(Core_Details__c = results[i].getErrors()[0].getMessage(), Core_Message__c = 'Product2 Deactivation '+results[i].getErrors()[0].getMessage(), Core_Severity__c = 'High',Core_Project__c='Product', Core_Origin__c='Product_upsertProduct3Records', Core_When__c = System.now()));                     
                }
            }
        }//endTRY
        catch(Exception e){
            logEntries.add(new Core_Log_Entry__c(Core_Details__c = e.getCause()+'------'+e.getLineNumber(), Core_Message__c = 'Product2 Deactivation :'+e.getMessage(), Core_Severity__c = 'High',Core_Project__c='Product', Core_Origin__c='Product_upsertProduct3Records', Core_When__c = System.now()));            
        }
        if(!logEntries.isEmpty()){
            insert logEntries;
        }
        System.debug('The end time is ---- '+system.now());
        // for analysis
        hp.End_Time__c = system.now();
        hp.Record_Count__c = recordCount; 
        insert hp;  */
    }      
}