global with sharing class Product_upsertProduct2Records  implements Database.Batchable<sObject> {
    public String ipaasId;  
    public static List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>();   
    public Heap_Analysis__c hp = new Heap_Analysis__c(); 
    public Integer recordCount = 0;
    //Upsert Filter Logic variables
    public static Set<String> retainOldValues = new Set<String>(Product_Staging_StaticConstants.retainOldValues);
    public static List<String> statusCodeFilter = Product_Staging_StaticConstants.Product_StatusFilter;
    public static List<string> vplchIpsFilter = Product_Staging_StaticConstants.vplchIpsFilter;
    //fetch ipaasloadId
    public Product_upsertProduct2Records(String ipaasLoadId){
        this.ipaasId=ipaasLoadId;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        // for analysis
        hp.Class_Name__c ='Product_upsertProduct2Records';
        hp.iPaaS_Load_ID__c = ipaasId;
        hp.Start_Time__c = system.now();
        //fetch Core_Products_Staging__c records
        String query = 'SELECT '+String.join(Product_Utility.getObjectFields('Core_Products_Staging__c'),',')+' FROM Core_Products_Staging__c WHERE iPaaS_Load_ID__c =: ipaasId';
        return Database.getQueryLocator(query);
    } 
    
    public void execute(Database.BatchableContext BC, List<Core_Products_Staging__c> stgRecords){
        try{
            recordCount += stgRecords.size();
            Map<String,String> stgToFph_fieldMappingTable = new Map<String,String>();
            Map<String,String> stgToProd_fieldMappingTableL4Only = new Map<String,String>();
            Map<String,String> stgToProd_fieldMappingTable = new Map<String,String>();
            Map<String,String> stgToProd_fieldMappingTableMMID = new Map<String,String>();
            Map<String,String> stgToProd_fieldMappingTableVplch = new Map<String,String>();
            
            // metadata mapping from staging to product3 and fph using -- Product_fields_mapping__mdt
            for (Product_fields_mapping__mdt  mappingRec : Product_fields_mapping__mdt.getall().Values()) {
                if(mappingRec.Product_staging_field__c != null && mappingRec.Product2_field__c != null && (mappingRec.Type__c == 'Mapping' || mappingRec.Type__c == 'Rollup'  ) && (mappingRec.Product_Org__c == 'Sales' || mappingRec.Product_Org__c == 'IPS' ) && mappingRec.Hierarchy_ID__c == '43' ){
                    stgToProd_fieldMappingTable.put(mappingRec.Product2_field__c,mappingRec.Product_staging_field__c);
                    if(!mappingRec.Is_MMID_Blank__c){
                        stgToProd_fieldMappingTableMMID.put(mappingRec.Product2_field__c,mappingRec.Product_staging_field__c);
                    }  
                    //Handling Status Code -- Separate Map 
                    if(mappingRec.Is_L4_Mapping_Field__c){ //L4 attribute feilds -  7 records
                        stgToProd_fieldMappingTableL4Only.put(mappingRec.Product2_field__c,mappingRec.Product_staging_field__c);
                    }                
                } 
                else if(mappingRec.Product_staging_field__c != null && mappingRec.Product2_field__c != null && (mappingRec.Type__c == 'Mapping' || mappingRec.Type__c == 'Rollup'  ) && (mappingRec.Product_Org__c == 'Sales' || mappingRec.Product_Org__c == 'IPS' ) && mappingRec.Hierarchy_ID__c == '59' ){
                    stgToProd_fieldMappingTableVplch.put(mappingRec.Product2_field__c,mappingRec.Product_staging_field__c);
                } 
                else if(mappingRec.Product_staging_field__c != null && mappingRec.FPH_Field__c != null && mappingRec.Type__c == 'Mapping' && mappingRec.Product_Org__c == 'FPH') {
                    stgToFph_fieldMappingTable.put(mappingRec.FPH_Field__c,mappingRec.Product_staging_field__c);
                }           
            } 
            
            processProduct2FPHRecords(stgRecords,stgToProd_fieldMappingTable,stgToProd_fieldMappingTableL4Only,stgToProd_fieldMappingTableMMID,stgToProd_fieldMappingTableVplch,stgToFph_fieldMappingTable);
        }catch(Exception ex){
            Product_Utility.createLogEntryAndNotifyUser(ex.getMessage(),ipaasId,'Product_upsertProduct2Records',null,null);
        }
    } 
    
    public void processProduct2FPHRecords(List<Core_Products_Staging__c> stgRecords,Map<String,String> stgToProd_fieldMappingTable, Map<String,String> stgToProd_fieldMappingTableL4Only,  Map<String,String> stgToProd_fieldMappingTableMMID,Map<String,String> stgToProd_fieldMappingTableVplch,Map<String,String> stgToFph_fieldMappingTable){
        List<Product2> productsToUpsertList = new List<Product2>();
        Product2 prdVPHRec = new Product2();
        List<Core_Flat_Product_Hierarchy__c> fphToUpsertList = new List<Core_Flat_Product_Hierarchy__c>();
        // auto insert/update product2 records using external id -- Core_Unique_ID__c
        if(!stgRecords.isEmpty() && stgRecords.size()>0){
            for (Core_Products_Staging__c stgRec :stgRecords){
                // for Sales and IPS - VPH
                Product2 productToUpsert = new Product2();  
                if (isVPHRecord(stgRec)) { 
                    prdVPHRec=mappingVPHFields(stgRec, stgToProd_fieldMappingTable,stgToProd_fieldMappingTableL4Only,stgToProd_fieldMappingTableMMID);
                    productsToUpsertList.add(prdVPHRec);
                }
                // for Sales and IPS - VPLCH
                else if(isVPLCHRecord(stgRec)){
                    // fields mapping
                    for(String field: stgToProd_fieldMappingTableVplch.keySet()) {                
                        productToUpsert.put(field, stgRec.get(stgToProd_fieldMappingTableVplch.get(field)));                   
                    } 
                    productToUpsert.IsActive              = stgRec.Core_IsActive__c ;
                    productToUpsert.Core_OPN__c           = stgRec.Core_OPN__c ;
                    productToUpsert.Core_Product_Org__c   = stgRec.Core_Product_Org__c;
                    productToUpsert.Core_Unique_ID__c     = stgRec.Core_Unique_ID__c;
                    productToUpsert.Core_Sales_Visible_Flag__c = stgRec.Core_Sales_Visible_Flag__c;
                    productToUpsert.Core_IQR_Visible__c =  stgRec.Core_Is_IQR_Visible__c ;
                    productToUpsert.Core_External_Source_Name__c = Product_Staging_StaticConstants.SourceName;
                    productToUpsert.Core_Item_Standard_Cost_Amt__c = Product_Staging_StaticConstants.StandardCost;
                  	//Ganesh Start
                    if (Product_Utility.isProductDeprecationDateEnabled() && stgRec.Level__c == '5'&& stgRec.Deactivation_Date__c != null) {
                        productToUpsert.Deactivation_Date__c = stgRec.Deactivation_Date__c;
                    }
                    //Ganesh End
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
        upsertProduct2FPHRecords(productsToUpsertList,fphToUpsertList); 
    }
    
    public boolean isVPHRecord(Core_Products_Staging__c stgRec) {
        Boolean VPHCondition=false;
        if(stgRec.Core_Unique_ID__c != null && (stgRec.Core_Product_Org__c == Product_Staging_StaticConstants.sales || stgRec.Core_Product_Org__c == Product_Staging_StaticConstants.ips) && stgRec.Core_Hierarchy_ID__c == '43' ){
            VPHCondition=true;
        }
        return VPHCondition;
    }
    
public Product2 mappingVPHFields(
    Core_Products_Staging__c stgRec,
    Map<String, String> fieldMappingTable,
    Map<String, String> stgToProd_fieldMappingTableL4Only,
    Map<String, String> stgToProd_fieldMappingTableMMID
) {
    Product2 productToUpsert = new Product2();

    for (String field : fieldMappingTable.keySet()) {
        if (
            (
                stgToProd_fieldMappingTableL4Only
                    .keySet()
                    .contains(field)
                && !statusCodeFilter.contains(
                    String.valueOf(
                        stgRec.get('Status_Code__c')
                    )
                )
            )
            || (
                stgToProd_fieldMappingTableMMID
                    .keySet()
                    .contains(field)
                && stgRec.Is_MMID_Blank__c == true
            )
            || (
                retainOldValues.contains(field)
                && String.isBlank(
                    String.valueOf(
                        stgRec.get(
                            fieldMappingTable.get(field)
                        )
                    )
                )
            )
        ) {
            continue;
        } else {
            productToUpsert.put(
                field,
                stgRec.get(
                    fieldMappingTable.get(field)
                )
            );
        }
    }
    //Ganesh Start
    if (Product_Utility.isProductDeprecationDateEnabled() && stgRec.Level__c == '5' && stgRec.Deactivation_Date__c != null) {
        productToUpsert.Deactivation_Date__c = stgRec.Deactivation_Date__c;
    }
    //Ganesh End
    productToUpsert.Core_External_Source_Name__c =
        Product_Staging_StaticConstants.SourceName;

    productToUpsert.Core_Item_Standard_Cost_Amt__c =
        Product_Staging_StaticConstants.StandardCost;

    return productToUpsert;
}
    public boolean isVPLCHRecord(Core_Products_Staging__c stgRec) {
        Boolean VPLCHCondition=false;
        if(stgRec.Core_Unique_ID__c != null && (stgRec.Core_Product_Org__c == Product_Staging_StaticConstants.sales || (stgRec.Core_Product_Org__c == Product_Staging_StaticConstants.ips && !vplchIpsFilter.contains(stgRec.Core_Unique_ID__c) ) ) && stgRec.Core_Hierarchy_ID__c == '59'){
            VPLCHCondition= true;
            
        }
        return VPLCHCondition;
    }
    
    public void upsertProduct2FPHRecords(List<Product2> productsToUpsertList,List<Core_Flat_Product_Hierarchy__c> fphToUpsertList) {
        //upserting the final list of product2
        if(!productsToUpsertList.isEmpty()){
            Database.UpsertResult [] results = Database.upsert(productsToUpsertList, Product2.Core_Unique_ID__c, false);
            //upsert productsToUpsertList Core_Unique_ID__c;            
            for(Database.UpsertResult sr : results ) {
                if(!sr.isSuccess()){
                    logEntries.add(new Core_Log_Entry__c(Core_Details__c = sr.getErrors()[0].getMessage(),Core_XID__c = ipaasId,Core_Message__c = 'Product2 upsert '+sr.getErrors()[0].getMessage(),Core_Severity__c = 'High',Core_Project__c='Product',Core_Origin__c='Product_upsertProduct2Records',Core_When__c = System.now(),Core_sObjectId__c = sr.getId()));                    
                }
            }
        }
        //upserting the final list of fph
        if(!fphToUpsertList.isEmpty()){
            Database.UpsertResult [] results = Database.upsert(fphToUpsertList, Core_Flat_Product_Hierarchy__c.Core_Unique_ID__c , false);
            //upsert fphToUpsertList Core_Unique_ID__c;            
            for(Database.UpsertResult sr : results ) {
                if(!sr.isSuccess()){
                    logEntries.add(new Core_Log_Entry__c(Core_Details__c = sr.getErrors()[0].getMessage(),Core_XID__c = ipaasId,Core_Message__c = 'Core_Flat_Product_Hierarchy__c upsert '+sr.getErrors()[0].getMessage(),Core_Severity__c = 'High',Core_Project__c='Product',Core_Origin__c='Product_upsertProduct2Records',Core_When__c = System.now(),Core_sObjectId__c = sr.getId())); 
                }
            }
        }
        if(!logEntries.isEmpty()){
            Database.insert(logEntries,false);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        //for analysis
        hp.End_Time__c = system.now();
        hp.Record_Count__c = recordCount; 
        insert hp;
        //notify user on records failed for upsertion
        Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        Integer logEntryListSize ;
        String className = 'Product_upsertProduct2Records';
        List<AggregateResult> agrList = [select count(Id)cnt,Core_XID__c from Core_Log_Entry__c where Core_XID__c =: ipaasId and Core_Origin__c =: className group by Core_XID__c];
        if(!agrList.isEmpty()){
            logEntryListSize = (Integer)agrList[0].get('cnt');
        }
        if(mapFunctionalityNameTriggerExecution.containsKey('AllowProductErrorNotification') && mapFunctionalityNameTriggerExecution.get('AllowProductErrorNotification').Core_Active__c) {
            if (logEntryListSize > 0){            
                Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();            
                String[] toAddresses  = Label.ProductSupportEmail.split(';');             
                mail.setToAddresses(toAddresses);
                mail.setSubject('Product Integration: '+logEntryListSize+' Records Failed For Upsertion - '+className);
                String body = 'Hi,<br><br>';
                body += 'This is to notify on records failure for upsertion. <br>';
                body += '<b> Failed Records Count - ' + logEntryListSize + '</b>, <br>';  
                body += 'For IpaasLoadId - ' + ipaasId+'.';                                       
                mail.setHtmlBody(body);
                mail.setOrgWideEmailAddressId(Label.Core_Ownership_Orgwide_Email_Id);
                Messaging.sendEmail(new Messaging.SingleEmailMessage []{mail},false);
            }
        }
        
        //call Product_DeleteFPHRecords Batch
        Database.executeBatch(new Product_DeleteFPHRecords(ipaasId),2000);
    }    
}