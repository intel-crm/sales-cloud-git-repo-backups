public class PRD_ProductDeactivation implements Database.Batchable<sObject>{
   public final List<Core_Products_Staging__c> stagingLst;
   public final String iPaaSID;
   public static boolean batchSuccess = true;
   
    public PRD_ProductDeactivation(List<Core_Products_Staging__c> dataset, String loadId){
             stagingLst = dataset; 
        	 iPaaSID = loadId;
   }

    public Database.QueryLocator start(Database.BatchableContext bc) {
       String query = 'Select Id,Core_Is_Custom_Ind__c, Core_Mem_Amt__c, Core_Hierarchy_ID__c, Core_Hierarchy_Name__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Family_EPM_ID__c,Core_Product_Family__c,Core_Product_Series_EPM_ID__c,Core_Product_Series__c,Core_Product_Group_EPM_ID__c,Core_Product_Group__c,Core_Code_Name_EPM_ID__c,Core_Code_Name__c,Core_Processor_Number_Ta_Nm__c, Core_Processor_Number_Nm__c,Core_Product_Status__c,Core_Item_Id__c,Core_Product_Name_EPM_ID__c,IsActive__c from Product3__c where isActive=True and Core_Product_Org__c=\'Sales\' FOR UPDATE';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Product3__c> products){
      Map<String, Product3__c> productsMap = new Map<String, Product3__c>();
      Map<String, Core_Products_Staging__c> stagingRecordMap = new Map<String, Core_Products_Staging__c>();
      List<Core_Products_Staging__c> stagingRecords = new List<Core_Products_Staging__c>();
      List<Core_Products_Staging__c> resetLatestStaging = new List<Core_Products_Staging__c>();
      List<Product3__c> deactivationLst = new List<Product3__c>();
        
      List<Core_Log_Entry__c> logEntry = new List<Core_Log_Entry__c>();
        
        for(Product3__c product:products){ 
           if(product.Core_Unique_ID__c !=null){
                productsMap.put(product.Core_Unique_ID__c, product);
             } 
        }
        
        
        stagingRecords= [SELECT Id, Core_IsActive__c,Core_Code_Name_EPM_ID__c, Core_Item_Id__c, Core_Product_Family_EPM_ID__c, Core_Product_Group_EPM_ID__c, Core_Product_Name_EPM_ID__c, Core_Product_Series_EPM_ID__c, 
                         Core_Product_Type_EPM_ID__c, Core_Unique_ID__c, Core_Platform_Config_EPM_ID__c, Core_Platform_EPM_ID__c, Core_Hierarchy_ID__c, iPaaS_Load_ID__c, 
                         Core_L1_EPM_ID__c, Core_L2_EPM_ID__c, Core_L3_EPM_ID__c, Core_L4_EPM_ID__c, Core_L5_EPM_ID__c,Core_IsLatest__c 
                         FROM Core_Products_Staging__c 
                         WHERE iPaaS_Load_ID__c =:iPaaSID and Core_IsLatest__c = true];
        
        for(Core_Products_Staging__c stagingRecord:stagingRecords){
        	if(stagingRecord.Core_Unique_ID__c!=null){
                stagingRecordMap.put(stagingRecord.Core_Unique_ID__c, stagingRecord);
                stagingRecord.Core_IsLatest__c = false;
                resetLatestStaging.add(stagingRecord);
            }//END--IF
        }//END--FOR
        
        /*Compare Product3__c Map with Staging Map, if corresponding record is not found in Staging then deactivate the record in Product3__c Table */
        for(Product3__c productEPMID: productsMap.values()){
            if(!stagingRecordMap.isEmpty() && !stagingRecordMap.containsKey(productEPMID.Core_Unique_ID__c)){
                
                Product3__c deactivateProduct = productsMap.get(productEPMID.Core_Unique_ID__c);
                deactivateProduct.IsActive__c = false;
                
                deactivationLst.add(deactivateProduct);
             }            
        }
        
        try{
          //update Product Staging Records with Core_IsLatest__c = false
          Database.SaveResult [] stagingResults = Database.update(resetLatestStaging, false); 
          for (Integer i = 0; i < stagingResults.size(); i++) { 
             if (!stagingResults[i].isSuccess()) {
                  logEntry.add(new Core_Log_Entry__c(Core_Details__c = stagingResults[i].getErrors()[0].getMessage(), Core_Message__c = 'Product Staging IsLatest=false '+stagingResults[i].getErrors()[0].getMessage(), Core_Severity__c = 'High',Core_Project__c='Product', Core_Origin__c='PRD_ProductDeactivation', Core_When__c = System.now())); 
             	  batchSuccess = false; 
             }
           }
            
          //update Product2 with IsActive__c = false
          Database.SaveResult [] results = Database.update(deactivationLst, false); 
          for (Integer i = 0; i < results.size(); i++) { 
             if (!results[i].isSuccess()) {
                  logEntry.add(new Core_Log_Entry__c(Core_Details__c = results[i].getErrors()[0].getMessage(), Core_Message__c = 'Product2 Deactivation '+results[i].getErrors()[0].getMessage(), Core_Severity__c = 'High',Core_Project__c='Product', Core_Origin__c='PRD_ProductDeactivation', Core_When__c = System.now())); 
                  batchSuccess = false; 
              }
           }
           
        }
        catch(Exception e){
          logEntry.add(new Core_Log_Entry__c(Core_Details__c = e.getCause()+'------'+e.getLineNumber(), Core_Message__c = 'Product2 Deactivation :'+e.getMessage(), Core_Severity__c = 'High',Core_Project__c='Product', Core_Origin__c='PRD_ProductDeactivation', Core_When__c = System.now()));
          batchSuccess = false; 
        }
        
        /*All Products Deactivation ---- Code to migrate to existing BATCH APEX*/
		List<Product3__c> deactivationPrdLst = [SELECT Id, Core_Hierarchy_ID__c, Core_Hierarchy_Name__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Status__c,Core_Product_Name_EPM_ID__c,IsActive__c 
                                                FROM Product3__c WHERE Core_iPaaS_Load_ID__c != :iPaaSID  AND Core_Product_Org__c='Sales' FOR UPDATE];
        List<Product3__c> lstProduct = new List<Product3__c>();
        for(Product3__c prd : deactivationPrdLst){
            prd.IsActive__c = false;
            lstProduct.add(prd);
        }
        try{
			//update Product2 with IsActive__c = false
          Database.SaveResult [] results = Database.update(lstProduct, false); 
          for (Integer i = 0; i < results.size(); i++) { 
             if (!results[i].isSuccess()) {
                  logEntry.add(new Core_Log_Entry__c(Core_Details__c = results[i].getErrors()[0].getMessage(), Core_Message__c = 'Product2 Deactivation '+results[i].getErrors()[0].getMessage(), Core_Severity__c = 'High',Core_Project__c='Product', Core_Origin__c='PRD_ProductDeactivation', Core_When__c = System.now())); 
                  batchSuccess = false; 
              }
           }
                     
        }//endTRY
        catch(Exception e){
          logEntry.add(new Core_Log_Entry__c(Core_Details__c = e.getCause()+'------'+e.getLineNumber(), Core_Message__c = 'Product2 Deactivation :'+e.getMessage(), Core_Severity__c = 'High',Core_Project__c='Product', Core_Origin__c='PRD_ProductDeactivation', Core_When__c = System.now()));
          batchSuccess = false;   
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
        if(!batchSuccess){
            AsyncApexJob job =[SELECT id,Status from AsyncApexJob WHERE Id =:BC.getJobId()];
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            string[] toadd=new string []{'divya.sundararaj@intel.com'};
            msg.setToAddresses(toAdd);
            msg.setSubject('Product Deactivation Batch Job - '+job.Id);
            msg.setPlainTextBody('Batch Operation Status :'+job.status +'\n Batch Processed'+job.JobItemsProcessed);
            
            Messaging.Email[] emails = new Messaging.Email[]{msg};
            Messaging.sendEmail(emails);  

         }
        
    }

}