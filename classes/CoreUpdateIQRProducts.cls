public with sharing class CoreUpdateIQRProducts {

    public static void updateProductRecords(){
        //pull all the IQR staging records whose Processing Status='new'
        Map<String, Core_IQR_Products_Staging__c> updateIQRProductMap = new Map<String, Core_IQR_Products_Staging__c>();
        Map<String, Core_IQR_Products_Staging__c> IQRProductStagingMap = new  Map<String, Core_IQR_Products_Staging__c>();
        for(Core_IQR_Products_Staging__c IQRProductStaging: [select id,Core_Mem_Amt__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Family_EPM_ID__c,Core_Product_Family__c,Core_Product_Series_EPM_ID__c,Core_Product_Series__c,Core_Product_Group_EPM_ID__c,Core_Product_Group__c,Core_Code_Name_EPM_ID__c,Core_Code_Name__c,Core_Processor_Number_Nm__c,Core_Product_Status__c,Core_Item_Id__c,Core_Division_Code_Short_Name__c,Core_Division_Code__c,Core_Group_Code_Short_Name__c,Core_Group_Code__c,Core_Product_Name_EPM_ID__c,Core_BU_Operation_Code__c,Core_Is_Custom_Ind__c,Core_Unique_ID__c from Core_IQR_Products_Staging__c where Core_Processing_Status__c='new']){
           IQRProductStagingMap.put(IQRProductStaging.Core_Product_Name_EPM_ID__c, IQRProductStaging);
        }
        
        List<Product2> productToUpdateList =  new List<Product2>();
        List<String> epmIdInProductList = new List<String>();
         system.debug('Product2:1:'+IQRProductStagingMap.keySet());
        for(Product2 product: [Select id,Core_Product_Org__c,Core_Is_Custom_Ind__c, Core_Mem_Amt__c, Core_Hierarchy_ID__c, Core_Hierarchy_Name__c, Core_Product_Type_EPM_ID__c,Core_Product_Type__c,Core_Product_Family_EPM_ID__c,Core_Product_Family__c,Core_Product_Series_EPM_ID__c,Core_Product_Series__c,Core_Product_Group_EPM_ID__c,Core_Product_Group__c,Core_Code_Name_EPM_ID__c,Core_Code_Name__c,Core_Processor_Number_Ta_Nm__c, Core_Processor_Number_Nm__c,Core_Product_Status__c,Core_Item_Id__c,Core_Division_Code_Short_Name__c,Core_Division_Code__c,Core_Group_Code_Short_Name__c,Core_Group_Code__c,Core_Product_Name_EPM_ID__c,Core_BU_Operation_Code__c,Core_Unique_ID__c from Product2 where Core_Product_Name_EPM_ID__c IN: IQRProductStagingMap.keySet()]){
            system.debug('Product2:'+product.Core_Product_Name_EPM_ID__c);
            if(IQRProductStagingMap.containsKey(product.Core_Product_Name_EPM_ID__c)){
                Core_IQR_Products_Staging__c stagingRecord = IQRProductStagingMap.get(product.Core_Product_Name_EPM_ID__c);
                if(product.Core_Product_Org__c=='Sales'){//Process only Sales Product Records
                    Product2 productToUpdate = new Product2();
                    productToUpdate.id = product.id;                    
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
                    productToUpdate.Core_Product_Name_EPM_ID__c = stagingRecord.Core_Product_Name_EPM_ID__c;
                    productToUpdate.Core_BU_Operation_Code__c = stagingRecord.Core_BU_Operation_Code__c;
                    productToUpdate.Core_Unique_ID__c = stagingRecord.Core_Unique_ID__c;
                    productToUpdate.Core_Is_Custom_Ind__c = stagingRecord.Core_Is_Custom_Ind__c;
                    productToUpdate.Core_Mem_Amt__c = stagingRecord.Core_Mem_Amt__c;
                    productToUpdate.IsActive = True;
                    productToUpdate.Core_Hierarchy_ID__c = '43';
                    productToUpdate.Core_Hierarchy_Name__c = 'Valid Product Hierarchy';
                    productToUpdateList.add(productToUpdate);     
                    
                    //update staging records processing status to 'old' if equivalent product record is found using epmid
                    stagingRecord.Core_Processing_Status__c = 'old';
                    updateIQRProductMap.put(product.Core_Product_Name_EPM_ID__c, stagingRecord);
                    
                    epmIdInProductList.add(product.Core_Product_Name_EPM_ID__c); 
                }
                else{//IPS Product Record
                    stagingRecord.Core_Processing_Status__c = 'IPS';
                    updateIQRProductMap.put(product.Core_Product_Name_EPM_ID__c, stagingRecord);
                    
                    epmIdInProductList.add(product.Core_Product_Name_EPM_ID__c); 
                    
                }
                
            }
        }
        
        //update staging record processing status to 'not found' if equivalent product record is not found using epmid 
        for(String epmid: IQRProductStagingMap.keySet()){
            if(epmIdInProductList.indexOf(epmid)==-1){
                Core_IQR_Products_Staging__c stagingRecord = IQRProductStagingMap.get(epmid);
                stagingRecord.Core_Processing_Status__c = 'not found';
                updateIQRProductMap.put(epmid, stagingRecord);
            }
        }
        
        if(productToUpdateList.size()>0){
            //update productToUpdateList;
            Database.SaveResult [] results = Database.update(productToUpdateList, false);
			Map<Id, String> failedIdMap = new Map<Id, String>();
            for (Integer i = 0; i < results.size(); i++) { 
                if (!results[i].isSuccess()) {
                    system.debug('error::'+results[i].getErrors()[0].getMessage());
                }
            }
            
        }
        if(updateIQRProductMap.size()>0){
            //update updateIQRProductMap.values();
            Database.SaveResult [] results = Database.update(updateIQRProductMap.values(), false);
			Map<Id, String> failedIdMap = new Map<Id, String>();
            for (Integer i = 0; i < results.size(); i++) { 
                if (!results[i].isSuccess()) {
                    system.debug('error::'+results[i].getErrors()[0].getMessage());
                }
            }
        }
		        
    }
}