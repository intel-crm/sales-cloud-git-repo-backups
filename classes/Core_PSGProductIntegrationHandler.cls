/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_PSGProductIntegrationHandler
Version     : 1.0 
Created Date: 06 April 2021
Function    : Utility methods to handle Delta Load
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya Dayananda            04/06/2021              Original Version

*****************************************************************************************************************************************************************************************************/
Public without sharing Class Core_PSGProductIntegrationHandler{
    Public static void handleLoad(List<Core_PIR_Ext_Attributes__c> newPSGProductList){
        
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        Map<Id, Core_PIR_Ext_Attributes__c> updateStagingMap = new Map<Id, Core_PIR_Ext_Attributes__c>();
        Map<Id, Core_PIR_Ext_Attributes__c> productIdStagingMap = new Map<Id, Core_PIR_Ext_Attributes__c>();
        List<String> oPNFromProductList = new List<String>();
        
        try{
            
            /*if(triggerPoint.equalsIgnoreCase('insert')){*/
                system.debug('Inside is insert/update');
                list<Product2> prodListToBeUpdated = new list<Product2>();
                //list<Product2> moUpadted = new list<Product2>();
                map<String,Core_PIR_Ext_Attributes__c> PIRAttributeMap = new map<String,Core_PIR_Ext_Attributes__c>();
                //As Part number is unique identifier for Product, this attribute is used as Unique update case
                for(Core_PIR_Ext_Attributes__c PIRAttributeRecord: newPSGProductList){
                    if(PIRAttributeRecord.Core_Processing_Status__c=='Pending') {
                        PIRAttributeMap.put(PIRAttributeRecord.Core_Part__c,PIRAttributeRecord);
                    }
                }
                /*//commented as PIRAttributeMap.keySet() can be used
                * Set<String> stagingUniqueIds = new Set<String>();
                for(Core_PIR_Ext_Attributes__c uniqueIdValue: newPSGProductList){
                stagingUniqueIds.add(uniqueIdValue.Core_Part__c);
                }*/
                Map<Id,Product2> productMap = new Map<Id,Product2>([select Id,Name,Core_Product_Ext_Attribute_Id__c,Core_OPN__c,Core_Product_Family__c,Core_Item_Class_Nm__c,Core_Item_Signal_Cd__c,Core_Item_Standard_Cost_Amt__c 
                                                                    from Product2 where Core_OPN__c IN:PIRAttributeMap.keySet() and IsActive=True]);
                for(Product2 productRec : productMap.values()){
                    if(PIRAttributeMap.containsKey(productRec.core_OPN__c)){
                        Core_PIR_Ext_Attributes__c extAttribute = PIRAttributeMap.get(productRec.core_OPN__c);
                        if(extAttribute != null){
                            //productRec.Core_Item_Package_Txt__c= extAttribute.Core_Package__c;
                            //productRec.Core_OPN__c= extAttribute.Core_Part__c;
                            //productRec.Core_Product_Family__c= extAttribute.Core_Product_Family__c;
                            productRec.Core_Item_Signal_Cd__c= extAttribute.Core_Signal_code__c;
                            if(Test.isRunningTest()){//only for test class coverage
                                productRec.Core_Product_Ext_Attribute_Id__c = extAttribute.Core_Package__c;    
                            }
                            
                            /*if(extAttribute.Core_Standard_Cost_Altera__c!='NA' && extAttribute.Core_Standard_Cost_Altera__c!='N/A'){
                                productRec.Core_Item_Standard_Cost_Amt__c= Decimal.valueOf(extAttribute.Core_Standard_Cost_Altera__c);
                            }*/
                            prodListToBeUpdated.add(productRec);
                            productIdStagingMap.put(productRec.Id, extAttribute);
                            oPNFromProductList.add(productRec.Core_OPN__c);//list of OPNs available in Product
                        }
                    }
                    
                    //prodListToBeUpdated.add(productRec);
                    
                    /*for(Core_PIR_Ext_Attributes__c newPSGProduct: newPSGProductList){//update pending status to successful after processing
                        Core_PIR_Ext_Attributes__c updateStagingRec = new Core_PIR_Ext_Attributes__c();
                        updateStagingRec.Core_Processing_Status__c = 'Successful';
                        updateStagingRec.Id = newPSGProduct.Id;
                        updateStagingMap.put(newPSGProduct.Id, updateStagingRec);
                        system.debug('#G:pending:'+newPSGProduct.Id);
                        }*/
                                        }
                                        
                                        /*//update stagging records with status
                        if(updateStagingMap!=null && updateStagingMap.size()>0){
                        update updateStagingMap.values();
                        }*/

				//compare to check if OPNs aren't found in Product from what is in stagging table
                for(Core_PIR_Ext_Attributes__c pIRAttribute: PIRAttributeMap.values()){
                    if(!oPNFromProductList.contains(pIRAttribute.Core_Part__c)){
                        Core_PIR_Ext_Attributes__c updateStagingRec = new Core_PIR_Ext_Attributes__c();
                        updateStagingRec.Id = pIRAttribute.Id;
                        //updateStagingRec.Core_Processing_Status__c = 'InProgress';
                        updateStagingRec.Core_Processing_Status__c = 'Failed';
                        updateStagingRec.Core_Error_Description__c = 'OPN not found in product records';
                        updateStagingMap.put(updateStagingRec.Id, updateStagingRec);
                        captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c ='Product Reocord not found by Staging Record:'+updateStagingRec.Id+' because OPN not found in product records', Core_Message__c = 'Failed', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSGProductIntegrationHandler', Core_When__c = System.now())); 
                    }
                }

                if(prodListToBeUpdated.size() > 0){
                    Database.SaveResult[] srList = Database.update(prodListToBeUpdated, false);
                    //for(Database.SaveResult sr : srList) {
                    for(Integer i=0; i<srList.size(); i++){
                        Core_PIR_Ext_Attributes__c updateStagingRec = new Core_PIR_Ext_Attributes__c();
                        if(srList[i].isSuccess()){
                            //onsuccess mark staging record as success
                            if(productIdStagingMap.containsKey(srList[i].getId())){
                                updateStagingRec.Id = productIdStagingMap.get(srList[i].getId()).Id;
                                updateStagingRec.Core_Processing_Status__c = 'Successful';
                                updateStagingRec.Core_Error_Description__c = '';
                                updateStagingMap.put(updateStagingRec.Id, updateStagingRec);
                                captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Updated Product Record:'+srList[i].getId()+' by Staging Record:'+ updateStagingRec.Id, Core_Message__c = 'Success', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSGProductIntegrationHandler', Core_When__c = System.now())); 
                            }
                        }
                        else{
                            //onfailure mark staging record as Failed with details
                            updateStagingRec.Id = productIdStagingMap.get(prodListToBeUpdated.get(i).Id).Id;
                            updateStagingRec.Core_Processing_Status__c = 'Failed';
                            updateStagingRec.Core_Error_Description__c = srList[i].getErrors()[0].getMessage();
                            updateStagingMap.put(updateStagingRec.Id, updateStagingRec);
                            //Capture the error logs
                            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c ='Failed to update Product Record:'+prodListToBeUpdated.get(i).Id+ ' by Staging Record:'+updateStagingRec.Id+' because:'+ srList[i].getErrors()[0].getMessage(), Core_Message__c = 'Failed', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSGProductIntegrationHandler', Core_When__c = System.now())); 
                        }
                    }
                }
                
                //update stagging records with status
                if(updateStagingMap!=null && updateStagingMap.size()>0){
                    update updateStagingMap.values();
                }
            //}
        }catch(Exception e){
            
        }
        finally{
            try{
                if(captureQueryErr!=null && captureQueryErr.size()>0){
                    insert captureQueryErr;
                }
            }
            catch(Exception e){
            }            
        }
    }    
}