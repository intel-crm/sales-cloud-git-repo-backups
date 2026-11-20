/********************************************************************************************************************************************************************
Apex Class Name:  Core_OppProductConcatenatedFieldUpdBatch
Version     : 1.0 
Created Date: 10/12/2020
Function    : When the product name changes, this batch gets all the products and update all the opportunities by reconstructing the concatenated Product field

Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kavyashree HR              10/12/2020               Original Version developed
*******************************************************************************************************************************************************************/
global class Core_OppProductConcatenatedFieldUpdBatch implements Database.Batchable<sObject>,Database.Stateful {
    global Core_Batch_Processing__c batchProcessing;
    global Integer count = 0;
    global Integer batchSize = 0;
    global Set<Id> noUpdateProductIdSet = new Set<Id>(); 
    /*
     * Method name  : start()
     * Description  : Method to query all the products whose name was changed( Core_IsName_Changed__c = true).
     * Return Type  : Void
     * Parameter    : Database.BatchableContext bc
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        batchProcessing = new Core_Batch_Processing__c();
        Core_Batch_header__c header = [Select id,Email_Distribution_List__c from Core_Batch_Header__c where name = 'Core_OppProductConcatenatedFieldUpdBatch' limit 1];
        try{
            String query = 'SELECT Id,Name,Core_Is_Name_Changed_Chk__c FROM Product2 WHERE Core_Is_Name_Changed_Chk__c = true';
            batchProcessing.Batch_Header__C = header.id;
            batchProcessing.Core_Email_Distribution_List__c = header.Email_Distribution_List__c;
            batchProcessing.Core_Salesforce_Job_Id__c = BC.getJobId();
            batchProcessing.Core_Batch_Query__c = query;            
            batchProcessing.Core_Object_Name__c = 'Product2';
            batchProcessing.Core_Start_Date_Time__c = System.Now();
            insert batchProcessing;
            return Database.getQueryLocator(query);
        }
        catch(Exception e){
            batchProcessing.Core_Exception_Log__c = e.getMessage();
            insert batchProcessing;
            return null;
        }
    }
    
    /*
     * Method name  : execute()
     * Description  : For all where the name is changing, gets all Opportunity & Opportunity Product records with those Products, for all of those Opportunities, reconstructs the concatenated Product field
     * Return Type  : Void
     * Parameter    : Database.BatchableContext bc, List<Product2>
     */
    global void execute(Database.BatchableContext bc, List<Product2> productList){
        Integer batchRecCount=0;
        Integer failedRecordCount= 0;
        String errorString='';
        Set<Id>successfulOppIds = new set<Id>();
        Batch_Processing_Line_Item__c batchline = new Batch_Processing_Line_Item__c();
        if(productList.size() > batchSize)
            batchSize = productList.size();
        // We only want to operate on Products whose names are changing, so build a set of those
        List<Product2> updateProductList = new List<Product2>();
        Set<Id> productIdsChanging = new Set<Id>();
        for(Product2 prod : productList){
            productIdsChanging.add(prod.Id);
        }        
        try{
            // Do we have any where the name changed?
            List<OpportunityLineItem> oppProdsChanging = new List<OpportunityLineItem>();
            if (productIdsChanging.size() > 0){
                oppProdsChanging = [SELECT OpportunityId, Product2.Name FROM OpportunityLineItem WHERE Product2Id in :productIdsChanging];
            }
            Set<Id> oppIdsToBeUpdated = new Set<Id>();                
            for (OpportunityLineItem oppProd : oppProdsChanging) {
                oppIdsToBeUpdated.add(oppProd.OpportunityId);
            }
            List<OpportunityLineItem> fullSetOppProds = new List<OpportunityLineItem>();
            if(!oppIdsToBeUpdated.isEmpty() && oppIdsToBeUpdated.size()!=0){
                fullSetOppProds = [SELECT OpportunityId, Product2.Name FROM OpportunityLineItem WHERE OpportunityId in :oppIdsToBeUpdated];
            }
            // Build a map of Opportunity IDs to the string of Product name for each, so we can use it for later lookups 
            Map<Id, Set<String>> mapOfOppIdAndSetProdName = new Map<Id, Set<String>>();
            Map<Id, String> mapOfOppIdAndStrProdName = new Map<Id, String>();
            Map<Id, Set<Id>> mapOfOppIdToProducts = new Map<Id, Set<Id>>();
            for(OpportunityLineItem oppLineItem : fullSetOppProds){         
                if(mapOfOppIdAndSetProdName.containsKey(oppLineItem.OpportunityId)){
                    if(mapOfOppIdAndStrProdName.containsKey(oppLineItem.OpportunityId)){               
                        Set<String> setProdName = mapOfOppIdAndSetProdName.get(oppLineItem.OpportunityId);
                        String prodName = mapOfOppIdAndStrProdName.get(oppLineItem.OpportunityId); 
                        Set<Id> setProd = mapOfOppIdToProducts.get(oppLineItem.OpportunityId);
                        setProd.add(oppLineItem.Product2.Id);
                        if(!setProdName.contains(oppLineItem.Product2.Name)){
                            setProdName.add(oppLineItem.Product2.Name);
                            prodName = prodName + oppLineItem.Product2.Name +', ';
                        } 
                        mapOfOppIdAndSetProdName.put(oppLineItem.OpportunityId, setProdName);
                        mapOfOppIdAndStrProdName.put(oppLineItem.OpportunityId, prodName);
                        mapOfOppIdToProducts.put(oppLineItem.OpportunityId, setProd);
                    }
                }
                else{
                    Set<String> setProdName = new Set<String>();
                    String prodName = '';
                    setProdName.add(oppLineItem.Product2.Name);
                    prodName = prodName + oppLineItem.Product2.Name +', ';  
                    mapOfOppIdAndSetProdName.put(oppLineItem.OpportunityId, setProdName);
                    mapOfOppIdAndStrProdName.put(oppLineItem.OpportunityId, prodName);
                    mapOfOppIdToProducts.put(oppLineItem.OpportunityId, new Set<Id>{oppLineItem.Product2.Id});
                }
            }
            //Populate the Core_Opportunity_Products__c field of Opportunity with the child OppLineItem's Product Name field
            List<Opportunity> oppList = new List<Opportunity>();   
            if(!mapOfOppIdAndStrProdName.isEmpty() && mapOfOppIdAndStrProdName != null){
                Opportunity oppUpdate;
                for(String oppId : mapOfOppIdAndStrProdName.keySet()){                
                    oppUpdate = new Opportunity();
                    oppUpdate.Id = oppId;
                    String productName = mapOfOppIdAndStrProdName.get(oppId);
                    if(productName.length() > 2)
                        productName = productName.left(productName.length()-2);
                    oppUpdate.Core_Opportunity_Products__c = productName; 
                    oppList.add(oppUpdate);                
                }            
            }
            //Update the Opportunity list            
            if(!oppList.isEmpty() && oppList.size()!=0){
                Database.SaveResult[] oppsr = Database.update(oppList, false);
                for(Database.SaveResult sr:oppsr){
                    if(sr.isSuccess()){
                        batchRecCount=batchRecCount+1;
                        successfulOppIds.add(sr.getId());                       
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) { 
                            errorString=errorString +err.getStatusCode() + ': ' + err.getMessage()+' | ';                            
                        }
                    }
                }
                for(Opportunity opp : oppList)
                {
                    if(!successfulOppIds.contains(opp.Id) ){
                        noUpdateProductIdSet.addAll(mapOfOppIdToProducts.get(opp.Id));
                        errorString=errorString + '  Failed Id: '+ String.valueOf(opp.Id)+';';
                        failedRecordCount=failedRecordCount+1;                          
                    }
                }                  
            }
            //insert the batch process line details.    
            count=count+batchRecCount ;
            batchline.Batch_Processing__c = batchProcessing.id;           
            batchline.Object_Type__c = 'Opportunity';            
            batchline.Core_Number_of_Updates__c = batchRecCount; 
            batchline.Exception_Log__c='Total failed records: '+failedRecordCount;
            batchline.Core_Change_Log__c=errorString.length() > 100000? errorString.substring(0, 99999): errorString;    // added as part of TWC4767-4319
            insert batchline;
            
            //Not resetting the product checkbox, if the opportunity is not updated
            for(Product2 prod : productList){
                if(!noUpdateProductIdSet.contains(prod.Id)){
                    prod.Core_Is_Name_Changed_Chk__c = False;
                    updateProductList.add(prod);
                }
            }
            //Update the Product Core_IsName_Changed__c field to false once processed
            if(!updateProductList.isEmpty() && updateProductList.size()!=0){
                Database.update(updateProductList);        
            }  
        }
        catch(Exception e){
            batchProcessing.Core_Exception_Log__c = e.getMessage();
            update batchProcessing;
        }                    
    }
            
    /*
     * Method name  : finish()
     * Description  : Send mail on batch process
     * Return Type  : Void
     * Parameter    : Database.BatchableContext bc
     */   
    global void finish(Database.BatchableContext bc){
        batchProcessing.Core_Total_Number_of_Records__c = count;
        batchProcessing.Core_End_Date_Time__c = System.Now();
        batchProcessing.Core_Batch_Size__c = batchSize;        
        batchProcessing.Core_Send_Email__c = true;                
        update batchProcessing;    
    }    
}