public class Core_IQR_UpdateProducts implements Database.Batchable<sObject> {
    
    Map<String, Core_IQR_Products_Staging__c> updateIQRProductMap = new Map<String, Core_IQR_Products_Staging__c>();
    Map<String, Core_IQR_Products_Staging__c> IQRProductStagingMap = new  Map<String, Core_IQR_Products_Staging__c>();
    Map<String, Core_IQR_Products_Staging__c> updateStagingStatusMap = new Map<String, Core_IQR_Products_Staging__c>();
    Map<Id, String> failedIQRProductMap = new Map<Id, String>();
    List<Product2> successIQRProductList = new List<Product2>();
    Set<Id> savedIqrSet = new Set<Id>();   
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('Inside start');
        String query = 'select id,Core_Product_Name__c,Core_Mem_Amt__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Family_EPM_ID__c,Core_Product_Family__c,Core_Product_Series_EPM_ID__c,Core_Product_Series__c,Core_Product_Group_EPM_ID__c,Core_Product_Group__c,Core_Code_Name_EPM_ID__c,Core_Code_Name__c,Core_Processor_Number_Nm__c,Core_Product_Status__c,Core_Item_Id__c,Core_Division_Code_Short_Name__c,Core_Division_Code__c,Core_Group_Code_Short_Name__c,Core_Group_Code__c,Core_Product_Name_EPM_ID__c,Core_BU_Operation_Code__c,Core_Is_Custom_Ind__c,Core_Is_IQR_Visible__c,Core_IsActive__c, Core_Unique_ID__c,Core_Family_Nm__c,Core_Forecast_Product_Name__c,Core_Business_Org_Nm__c from Core_IQR_Products_Staging__c where Core_Processing_Status__c=\'New\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Core_IQR_Products_Staging__c> scope){
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        if(scope != null){
            system.debug('Scope in update--'+scope);
            for(Core_IQR_Products_Staging__c IQRProductStaging:scope){
                if(IQRProductStaging.Core_Product_Name_EPM_ID__c != null){
                    IQRProductStagingMap.put(IQRProductStaging.Core_Product_Name_EPM_ID__c, IQRProductStaging);
                }
                
            }
            List<Product2> productToUpdateList =  new List<Product2>();
            List<Product2> productToInsertList = new List<Product2>();
            List<Product2> finalListToUpsert = new List<Product2>();
            List<Core_IQR_Products_Staging__c> iqrStagingWithoutEPM = new List<Core_IQR_Products_Staging__c>(); 
            
            List<String> epmIdInProductList = new List<String>();
            system.debug('Product2:1:'+IQRProductStagingMap.keySet());
            List<Product2> prodList = [Select id,name,Core_Product_Org__c,Core_Is_Custom_Ind__c, Core_Mem_Amt__c, Core_Hierarchy_ID__c, Core_Hierarchy_Name__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Family_EPM_ID__c,Core_Product_Family__c,Core_Product_Series_EPM_ID__c,Core_Product_Series__c,Core_Product_Group_EPM_ID__c,Core_Product_Group__c,Core_Code_Name_EPM_ID__c,Core_Code_Name__c,Core_Processor_Number_Ta_Nm__c, Core_Processor_Number_Nm__c,Core_Product_Status__c,Core_Item_Id__c,Core_Division_Code_Short_Name__c,Core_Division_Code__c,Core_Group_Code_Short_Name__c,Core_Group_Code__c,Core_Product_Name_EPM_ID__c,Core_BU_Operation_Code__c,Core_Unique_ID__c,Core_Family_Nm__c,Core_Forecast_Product_Name__c,Core_IQR_Visible__c,Core_Business_Org_Nm__c,IsActive from Product2 where Core_Product_Name_EPM_ID__c IN: IQRProductStagingMap.keySet()];
            
            
            Map<String, Product2> productEPMMap = new Map<String, Product2>();
            if(prodList.size() >0){
                for(Product2 prodRec:prodList){
                    if(prodRec.Core_Product_Org__c=='Sales' && prodRec.Core_IQR_Visible__c==true && prodRec.Core_Product_Type__c!=Label.PSG_Product_Type_Identifier){
                        productEPMMap.put(prodRec.Core_Product_Name_EPM_ID__c,prodRec);
                    }
                    system.debug('productEPMMap----'+productEPMMap);
                }
            }         
            for(String epmId: IQRProductStagingMap.keySet()){
                
                Core_IQR_Products_Staging__c stagingRecord = IQRProductStagingMap.get(epmId);
                //if(IQRProductStagingMap.containsKey(product.Core_Product_Name_EPM_ID__c )){
               
                if(productEPMMap.containsKey(epmId) && productEPMMap.get(epmId)!=null){
                    system.debug('#34--'+IQRProductStagingMap.containsKey(epmId)+'----'+productEPMMap.get(epmId).Core_Product_Org__c);
                    Product2 productToUpdate = new Product2();
                    system.debug('Map get epm key - Update'+stagingRecord);
                    system.debug('Product is updating with--'+productEPMMap.get(epmId).id);
                    
                    productToUpdate.id = productEPMMap.get(epmId).id;  
                    if(stagingRecord.Core_Product_Type_EPM_ID__c!= productEPMMap.get(epmId).Core_Product_Type_EPM_ID__c || stagingRecord.Core_Product_Type__c!=productEPMMap.get(epmId).Core_Product_Type__c ||
                      stagingRecord.Core_Product_Family_EPM_ID__c!=productEPMMap.get(epmId).Core_Product_Family_EPM_ID__c || stagingRecord.Core_Product_Family__c!= productEPMMap.get(epmId).Core_Product_Family__c ||
                      stagingRecord.Core_Product_Series_EPM_ID__c!= productEPMMap.get(epmId).Core_Product_Series_EPM_ID__c || stagingRecord.Core_Product_Series__c!=productEPMMap.get(epmId).Core_Product_Series__c ||
                      stagingRecord.Core_Product_Group_EPM_ID__c!= productEPMMap.get(epmId).Core_Product_Group_EPM_ID__c || stagingRecord.Core_Product_Group__c!=productEPMMap.get(epmId).Core_Product_Group__c || stagingRecord.Core_Code_Name_EPM_ID__c!=productEPMMap.get(epmId).Core_Code_Name_EPM_ID__c ||
                      stagingRecord.Core_Code_Name__c!=productEPMMap.get(epmId).Core_Code_Name__c || stagingRecord.Core_Processor_Number_Nm__c!= productEPMMap.get(epmId).Core_Processor_Number_Ta_Nm__c || 
                      stagingRecord.Core_Product_Status__c!=productEPMMap.get(epmId).Core_Product_Status__c || stagingRecord.Core_Item_Id__c!=productEPMMap.get(epmId).Core_Item_Id__c || stagingRecord.Core_Division_Code_Short_Name__c!=productEPMMap.get(epmId).Core_Division_Code_Short_Name__c || 
                      stagingRecord.Core_Division_Code__c!=productEPMMap.get(epmId).Core_Division_Code__c || stagingRecord.Core_Group_Code_Short_Name__c!=productEPMMap.get(epmId).Core_Group_Code_Short_Name__c ||
                      stagingRecord.Core_Group_Code__c!= productEPMMap.get(epmId).Core_Group_Code__c || stagingRecord.Core_Product_Name_EPM_ID__c!= productEPMMap.get(epmId).Core_Product_Name_EPM_ID__c || stagingRecord.Core_BU_Operation_Code__c!=productEPMMap.get(epmId).Core_BU_Operation_Code__c ||
                      stagingRecord.Core_Unique_ID__c!=productEPMMap.get(epmId).Core_Unique_ID__c || stagingRecord.Core_Is_Custom_Ind__c!=productEPMMap.get(epmId).Core_Is_Custom_Ind__c || stagingRecord.Core_Family_Nm__c!=productEPMMap.get(epmId).Core_Family_Nm__c ||
                      stagingRecord.Core_Forecast_Product_Name__c!=productEPMMap.get(epmId).Core_Forecast_Product_Name__c || stagingRecord.Core_Mem_Amt__c!=productEPMMap.get(epmId).Core_Mem_Amt__c || stagingRecord.Core_Product_Name__c!=productEPMMap.get(epmId).Name || stagingRecord.Core_Business_Org_Nm__c!= productEPMMap.get(epmId).Core_Business_Org_Nm__c || stagingRecord.Core_IsActive__c!=productEPMMap.get(epmId).IsActive || stagingRecord.Core_Is_IQR_Visible__c!=productEPMMap.get(epmId).Core_IQR_Visible__c){
                    productToUpdate.Core_Product_Type_EPM_ID__c = stagingRecord.Core_Product_Type_EPM_ID__c;
                    productToUpdate.Core_Product_Type__c = stagingRecord.Core_Product_Type__c;
                    productToUpdate.Core_Product_Family_EPM_ID__c = stagingRecord.Core_Product_Family_EPM_ID__c;
                    productToUpdate.Core_Product_Family__c = stagingRecord.Core_Product_Family__c;
                    productToUpdate.Core_Product_Series_EPM_ID__c = stagingRecord.Core_Product_Series_EPM_ID__c;
                    productToUpdate.Core_Product_Series__c = stagingRecord.Core_Product_Series__c;
                    productToUpdate.Core_Product_Group_EPM_ID__c = stagingRecord.Core_Product_Group_EPM_ID__c;
                    productToUpdate.Core_Product_Group__c = stagingRecord.Core_Product_Group__c;
                    productToUpdate.Core_Code_Name_EPM_ID__c = stagingRecord.Core_Code_Name_EPM_ID__c;
                    productToUpdate.Core_Code_Name__c = stagingRecord.Core_Code_Name__c;
                    productToUpdate.Core_Processor_Number_Ta_Nm__c = stagingRecord.Core_Processor_Number_Nm__c;
                    productToUpdate.Core_Product_Status__c = stagingRecord.Core_Product_Status__c;
                    productToUpdate.Core_Item_Id__c = stagingRecord.Core_Item_Id__c;
                    productToUpdate.Core_Division_Code_Short_Name__c = stagingRecord.Core_Division_Code_Short_Name__c;
                    productToUpdate.Core_Division_Code__c = stagingRecord.Core_Division_Code__c;
                    productToUpdate.Core_Group_Code_Short_Name__c = stagingRecord.Core_Group_Code_Short_Name__c;
                    productToUpdate.Core_Group_Code__c = stagingRecord.Core_Group_Code__c;
                   // productToUpdate.Core_Product_Name_EPM_ID__c = stagingRecord.Core_Product_Name_EPM_ID__c;
                    productToUpdate.Core_BU_Operation_Code__c = stagingRecord.Core_BU_Operation_Code__c;
                    productToUpdate.Core_Unique_ID__c = stagingRecord.Core_Unique_ID__c;
                    productToUpdate.Core_Is_Custom_Ind__c = stagingRecord.Core_Is_Custom_Ind__c;
                    productToUpdate.Core_Family_Nm__c = stagingRecord.Core_Family_Nm__c;
                    productToUpdate.Core_Forecast_Product_Name__c = stagingRecord.Core_Forecast_Product_Name__c;
                    productToUpdate.Core_Business_Org_Nm__c= stagingRecord.Core_Business_Org_Nm__c;
                    
                    productToUpdate.Core_Mem_Amt__c = stagingRecord.Core_Mem_Amt__c;
                    productToUpdate.Name = stagingRecord.Core_Product_Name__c;
                    productToUpdate.IsActive = stagingRecord.Core_IsActive__c;
                    productToUpdate.Core_IQR_Visible__c = stagingRecord.Core_Is_IQR_Visible__c;
                    productToUpdate.Core_Hierarchy_ID__c = '43';
                    productToUpdate.Core_Hierarchy_Name__c = 'Valid Product Hierarchy';
                    productToUpdateList.add(productToUpdate);     
                } 
                }else{
                    // for(Core_IQR_Products_Staging__c prodStagingRec : iqrStagingWithoutEPM){
                    
                    Product2 productToInsert = new Product2();
                    system.debug('Product is Inserted'); 
                    productToInsert.Name = stagingRecord.Core_Product_Name__c;
                    productToInsert.Core_Product_Type_EPM_ID__c = stagingRecord.Core_Product_Type_EPM_ID__c;
                    productToInsert.Core_Product_Type__c = stagingRecord.Core_Product_Type__c;
                    productToInsert.Core_Product_Family_EPM_ID__c = stagingRecord.Core_Product_Family_EPM_ID__c;
                    productToInsert.Core_Product_Family__c = stagingRecord.Core_Product_Family__c;
                    productToInsert.Core_Product_Series_EPM_ID__c = stagingRecord.Core_Product_Series_EPM_ID__c;
                    productToInsert.Core_Product_Series__c = stagingRecord.Core_Product_Series__c;
                    productToInsert.Core_Product_Group_EPM_ID__c = stagingRecord.Core_Product_Group_EPM_ID__c;
                    productToInsert.Core_Product_Group__c = stagingRecord.Core_Product_Group__c;
                    productToInsert.Core_Code_Name_EPM_ID__c = stagingRecord.Core_Code_Name_EPM_ID__c;
                    productToInsert.Core_Code_Name__c = stagingRecord.Core_Code_Name__c;
                    productToInsert.Core_Processor_Number_Ta_Nm__c = stagingRecord.Core_Processor_Number_Nm__c;
                    productToInsert.Core_Product_Status__c = stagingRecord.Core_Product_Status__c;
                    productToInsert.Core_Item_Id__c = stagingRecord.Core_Item_Id__c;
                    productToInsert.Core_Division_Code_Short_Name__c = stagingRecord.Core_Division_Code_Short_Name__c;
                    productToInsert.Core_Division_Code__c = stagingRecord.Core_Division_Code__c;
                    productToInsert.Core_Group_Code_Short_Name__c = stagingRecord.Core_Group_Code_Short_Name__c;
                    productToInsert.Core_Group_Code__c = stagingRecord.Core_Group_Code__c;
                    productToInsert.Core_Product_Name_EPM_ID__c = stagingRecord.Core_Product_Name_EPM_ID__c;
                    productToInsert.Core_BU_Operation_Code__c = stagingRecord.Core_BU_Operation_Code__c;
                    productToInsert.Core_Unique_ID__c = stagingRecord.Core_Unique_ID__c;
                    productToInsert.Core_Is_Custom_Ind__c = stagingRecord.Core_Is_Custom_Ind__c;
                    productToInsert.Core_Family_Nm__c = stagingRecord.Core_Family_Nm__c;
                    productToInsert.Core_Forecast_Product_Name__c = stagingRecord.Core_Forecast_Product_Name__c;
                    productToInsert.Core_Business_Org_Nm__c= stagingRecord.Core_Business_Org_Nm__c;
                    
                    productToInsert.Core_Mem_Amt__c = stagingRecord.Core_Mem_Amt__c;
                    productToInsert.IsActive = stagingRecord.Core_IsActive__c;
                    productToInsert.Core_Product_Org__c = 'Sales';                
                    productToInsert.Core_IQR_Visible__c = stagingRecord.Core_Is_IQR_Visible__c;
                    productToInsert.Core_Hierarchy_ID__c = '43';
                    productToInsert.Core_Hierarchy_Name__c = 'Valid Product Hierarchy';
                    productToInsertList.add(productToInsert);
                    //update staging records processing status to 'Completed' if equivalent product record is found using epmid
                    //  stagingRecord.Core_Processing_Status__c = 'Completed';
                     //  updateIQRProductMap.put(product.Id, stagingRecord);
                    
                    //epmIdInProductList.add(product.Core_Product_Name_EPM_ID__c); 
                    
                    system.debug('productToInsertList---'+productToInsertList);
                   
                }
                
             
            }
            
            finalListToUpsert.addAll(productToInsertList);
            finalListToUpsert.addAll(productToUpdateList);
                         
            if(!finalListToUpsert.isEmpty()){
                //Insert productToInsertList;
                
                Database.UpsertResult [] results = Database.upsert(finalListToUpsert, false);
                for (Integer i = 0; i < results.size(); i++) {
                    system.debug('results after insert--'+finalListToUpsert[i].Id);
                    Core_IQR_Products_Staging__c stagingRecordToUpdate1 = new Core_IQR_Products_Staging__c();
                    if(!results[i].isSuccess()){
                        String errorMsg = '';
                        errorMsg = errorMsg+results[i].getErrors();
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'IQR_Product insert Error', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_UpdateProducts', Core_When__c = System.now())); 
                        failedIQRProductMap.put(finalListToUpsert[i].Id,errorMsg);
                        system.debug('failedIQRProductMap--'+failedIQRProductMap);
                    }
                    if(results[i].isSuccess()){
                       // String successMsg = '';
                        //successMsg = successMsg+results[i].getErrors();
                        //captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = errorMsg, Core_Message__c = 'IQR_Product insert Error', Core_Severity__c = 'High',Core_Project__c='IQR', Core_Origin__c='Core_IQR_UpdateProducts', Core_When__c = System.now())); 
                        successIQRProductList.add(finalListToUpsert[i]);
                        system.debug('successIQRProductList--'+successIQRProductList);
                    }
                    
                }
                
            }
            List<Core_IQR_Products_Staging__c> iqrIntUpdateList = new List<Core_IQR_Products_Staging__c>();
            for(Core_IQR_Products_Staging__c iqrInt : scope){
                
                if(failedIQRProductMap.keySet().contains(iqrInt.Id)){
                    system.debug('failedIQRProductMap.keySet 173---'+iqrInt.Id);
                    iqrInt.Core_Processing_Status__c = 'Failure';
                    iqrIntUpdateList.add(iqrInt);
                }
                else if(successIQRProductList.size()>0){
                    system.debug('failedIQRProductMap.keySet 178---'+iqrInt.Id);
                    iqrInt.Core_Processing_Status__c = 'Success';
                    system.debug('Inserted successfully here');
                    iqrIntUpdateList.add(iqrInt);	
                }
                
            }
            if(!iqrIntUpdateList.isEmpty()){
                try{
                    update iqrIntUpdateList;
                }catch(Exception e){
                    System.debug('---Exception-- '+e.getMessage());
                }
            }
            /*if(updateIQRProductMap.size()>0){// epmid, stagingRec
//update updateIQRProductMap.values();
Database.SaveResult [] results = Database.update(updateIQRProductMap.values(), false);
Map<Id, String> failedIdMap = new Map<Id, String>();
for (Integer i = 0; i < results.size(); i++) { 


if (!results[i].isSuccess()) {
system.debug('error::'+results[i].getErrors()[0].getMessage());
}
}
}*/
            
        }
    }     
    
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new Core_IQR_CompareRecords(),50);
    }
    
}