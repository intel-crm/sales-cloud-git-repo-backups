public without sharing class CompetitorProdPriceStagingTriggerHandler extends TriggerHandler {
    public List<Pricing_Competitor_Product_Price_Staging__c> iqrTriggerNewList = new List<Pricing_Competitor_Product_Price_Staging__c>();
    public Set<String> compProdPriceStagingName = new Set<String>();
    Set<String> stageRegions = new Set<String>();
    public static String logMsg;
    public static String errorMsg;
    public static Boolean isInsert = false;
    
    public CompetitorProdPriceStagingTriggerHandler() {
        if(Trigger.new != null){
            for(Pricing_Competitor_Product_Price_Staging__c compProdPriceStaging : (List<Pricing_Competitor_Product_Price_Staging__c>)Trigger.new){
                if(compProdPriceStaging.Pricing_Competitor_Product_Name_Staging__c != null && compProdPriceStaging.Pricing_Region_Staging_Nm__c != null){
                    iqrTriggerNewList.add(compProdPriceStaging);
                    compProdPriceStagingName.add(compProdPriceStaging.Pricing_Competitor_Product_Name_Staging__c);
                    stageRegions.add(compProdPriceStaging.Pricing_Region_Staging_Nm__c);
                }
                else{
                    compProdPriceStaging.addError(Label.Pricing_Stage_Record_Insert_Error_Msg);
                }
            }
        }
    }
    public override void afterInsert() {
        if(!iqrTriggerNewList.isEmpty() && compProdPriceStagingName.size() >0){
            createCompProductPriceRecords(iqrTriggerNewList,compProdPriceStagingName,stageRegions);
        }
    }
    
    /**
* @description : Method to insert records in Pricing_Competitor_Product_Price__c obj from Pricing_Competitor_Product_Price_Staging__c obj
* @author Divya Gangasaram | 03-20-2023 
* @param List<Pricing_Competitor_Product_Price_Staging__c> ProductsPriceStagingList 
* @param Set<String> compProdPriceNameStagingTxt 
* @param Set<String> compProdPriceStageRegionList 
**/
    public static void createCompProductPriceRecords(List<Pricing_Competitor_Product_Price_Staging__c> productsPriceStagingList,Set<String> compProdPriceNameStagingTxt, Set<String> compProdPriceStageRegionList)
    {
        try{
            List<Pricing_Competitor_Product_Price__c> compProductsPriceList = new List<Pricing_Competitor_Product_Price__c>();
            List<Pricing_Competitor_Product_Price__c> compProdPriceListToUpdate = new List<Pricing_Competitor_Product_Price__c>();
            Map<String,Pricing_Competitor_Product_Price__c> compProdPriceNameRegToRecordMap = new Map<String,Pricing_Competitor_Product_Price__c>();
            Map<String,Pricing_Competitor_Product__c> compProdNameToRecordMap = new Map<String,Pricing_Competitor_Product__c>();
            Map<String,Pricing_Competitor_Product_Price__c> prodPriceNameRegToRecordMap = new Map<String,Pricing_Competitor_Product_Price__c>();
            Map<String,Pricing_Competitor_Product_Price__c> prodPriceNameRegToRecordMapInsert = new Map<String,Pricing_Competitor_Product_Price__c>();
            
            for(Pricing_Competitor_Product_Price__c compProdPrice : [SELECT id,Pricing_Competitor_Product__c,Pricing_Competitor_Product__r.Name,Pricing_Region_Nm__c,   Pricing_List_Price__c,
                                                                     Pricing_Median_Meet_Comp_Discount__c,Pricing_Final_Meet_Comp_Price__c,Pricing_Application_Nm__c FROM Pricing_Competitor_Product_Price__c WHERE Pricing_Competitor_Product__r.Name IN :compProdPriceNameStagingTxt and Pricing_Region_Nm__c IN : compProdPriceStageRegionList]){
                                                                         compProdPriceNameRegToRecordMap.put(compProdPrice.Pricing_Competitor_Product__r.Name +'-'+compProdPrice.Pricing_Region_Nm__c +'-'+compProdPrice.Pricing_Application_Nm__c, compProdPrice);     
                                                                     }
            
            for(Pricing_Competitor_Product__c compProduct : [SELECT id, Name, Pricing_Competitor_Product_Provider_Nm__c,RecordTypeId FROM Pricing_Competitor_Product__c WHERE Name IN : compProdPriceNameStagingTxt]){ 
                compProdNameToRecordMap.put(compProduct.Name,compProduct);                 
            }
            
            for(Pricing_Competitor_Product_Price_Staging__c productPriceStaging : productsPriceStagingList){
                if(compProdNameToRecordMap.containskey(productPriceStaging.Pricing_Competitor_Product_Name_Staging__c)){
                    if(!compProdPriceNameRegToRecordMap.keyset().contains(productPriceStaging.Pricing_Competitor_Product_Name_Staging__c + '-' +productPriceStaging.Pricing_Region_Staging_Nm__c + '-' +productPriceStaging.Pricing_Application_Staging_Nm__c))
                    {
                        if(!prodPriceNameRegToRecordMapInsert.keyset().contains(productPriceStaging.Pricing_Competitor_Product_Name_Staging__c + '-' +productPriceStaging.Pricing_Region_Staging_Nm__c)){ 
                            Pricing_Competitor_Product_Price__c compProdPrice = new Pricing_Competitor_Product_Price__c();
                            compProdPrice.Pricing_Region_Nm__c = productPriceStaging.Pricing_Region_Staging_Nm__c; 
                            compProdPrice.Pricing_List_Price__c = productPriceStaging.Pricing_List_Price_Staging__c; 
                            compProdPrice.Pricing_Median_Meet_Comp_Discount__c = productPriceStaging.Pricing_Median_Meet_Comp_Disty_Staging__c; 
                            compProdPrice.Pricing_Final_Meet_Comp_Price__c = productPriceStaging.Pricing_Final_Meet_Comp_Price_Staging__c;
                            compProdPrice.Pricing_Application_Nm__c = productPriceStaging.Pricing_Application_Staging_Nm__c;
                            //for(Pricing_Competitor_Product__c compprod :compProdNameToRecordMap.values()){
                            //if(compprod.Name == productPriceStaging.Pricing_Competitor_Product_Name_Staging__c){
                            compProdPrice.Pricing_Competitor_Product__c = compProdNameToRecordMap.get(productPriceStaging.Pricing_Competitor_Product_Name_Staging__c).id; 
                            //}  
                            //}
                            compProductsPriceList.add(compProdPrice);
                            prodPriceNameRegToRecordMapInsert.put(productPriceStaging.Pricing_Competitor_Product_Name_Staging__c + '-' +productPriceStaging.Pricing_Region_Staging_Nm__c ,compProdPrice);
                        }
                    }
                    else {
                        if(!prodPriceNameRegToRecordMap.keyset().contains(productPriceStaging.Pricing_Competitor_Product_Name_Staging__c + '-' +productPriceStaging.Pricing_Region_Staging_Nm__c)){ 
                            Pricing_Competitor_Product_Price__c cmpProdPrice = new Pricing_Competitor_Product_Price__c();
                            //cmpProdPrice.Pricing_Region_Nm__c = productPriceStaging.Pricing_Region_Staging_Nm__c; 
                            cmpProdPrice.Pricing_List_Price__c = productPriceStaging.Pricing_List_Price_Staging__c; 
                            cmpProdPrice.Pricing_Median_Meet_Comp_Discount__c = productPriceStaging.Pricing_Median_Meet_Comp_Disty_Staging__c; 
                            cmpProdPrice.Pricing_Final_Meet_Comp_Price__c = productPriceStaging.Pricing_Final_Meet_Comp_Price_Staging__c;
                            cmpProdPrice.Pricing_Application_Nm__c = productPriceStaging.Pricing_Application_Staging_Nm__c;
                            cmpProdPrice.id = compProdPriceNameRegToRecordMap.get(productPriceStaging.Pricing_Competitor_Product_Name_Staging__c + '-' +productPriceStaging.Pricing_Region_Staging_Nm__c + '-' +productPriceStaging.Pricing_Application_Staging_Nm__c).id;
                            compProdPriceListToUpdate.add(cmpProdPrice);
                            prodPriceNameRegToRecordMap.put(productPriceStaging.Pricing_Competitor_Product_Name_Staging__c + '-' +productPriceStaging.Pricing_Region_Staging_Nm__c ,cmpProdPrice);
                        }
                    }
                }
                
            }
            if(!compProdPriceListToUpdate.isEmpty()){                
                SBQQ.TriggerControl.disable();
                Database.SaveResult[] updateResult = Database.update(compProdPriceListToUpdate, false);
                SBQQ.TriggerControl.enable();
                partialSuccessError(updateResult,isInsert);
                
            }
            if(!compProductsPriceList.isEmpty()){
                Database.SaveResult[] result = Database.insert(compProductsPriceList, false);
                isInsert = true;
                partialSuccessError(result,isInsert);
            }
        }
        catch(Exception ex){
            Pricing_Tender_Utility.logError(ex);
        } 
    }
    
    public static void partialSuccessError(Database.SaveResult[] successErrorContent ,Boolean isInsert){
        Map<id,String> successMap = New Map<id,String>();
        Map<id,String> errorMap = New Map<id,String>();
        for (Database.SaveResult insertRes : successErrorContent){
            if (insertRes.isSuccess()) {
                logMsg = isInsert == true ?'Record has been inserted successfully.' : 'Record has been updated successfully.';
                successMap.put(insertRes.getId() ,logMsg);
            }
            else {               
                for(Database.Error err : insertRes.getErrors()) {
                    errorMsg = err.getMessage();
                }
                errorMap.put(insertRes.getId() ,errorMsg);
                
            }
        }
        if(successMap.size()>0){
            coreLogCreation(successMap);
        }
        if(errorMap.size()>0){
            coreLogCreation(errorMap);
        }
    }
    
    public static void coreLogCreation(Map<id,String> successErrorMap){
        List<core_log_entry__c> corelist = new List<core_log_entry__c>();
        for(Id keys :successErrorMap.keySet()){
            core_log_entry__c logEntry = new core_log_entry__c();
            logEntry.Core_sObjectId__c = keys;
            logEntry.Core_Details__c = successErrorMap.get(keys);
            logEntry.Core_Origin__c =  'Data Load';
            logEntry.Core_Project__c = Label.Pricing_IQR_Program_Name;
            logEntry.Core_Severity__c = (successErrorMap.get(keys) == 'Record has been inserted successfully.' || successErrorMap.get(keys) == 'Record has been updated successfully.') ? 'Low' :'Critical';
            logEntry.Core_Support_Email__c = Label.Pricing_IQR_Support_Email;
            logEntry.Core_Support_Link__c = Label.Pricing_IQR_Support_Link;
            logEntry.Core_Scope__c = 'Competitor Product Price Staging Data Load';
            logEntry.Core_When__c = system.now();
            corelist.add(logEntry); 
        }
        insert corelist;      
    }
}