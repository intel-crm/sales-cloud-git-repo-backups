/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_PSG_ProcessSignalCodeFromStaging
Version     : 1.0 
Created Date: 06 April 2021
Function    : This Batch class updates the Signal Code from Staging to Product Table. On successfull update it will change the Status to 'Successfull' in Staging Table
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya Dayananda            04/06/2021              Original Version

*************************************************************************************************************************************************************************************************/
public class Core_PSG_ProcessSignalCodeFromStaging implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext BC){
       
        String stagingRecordList = 'select id,Name, Core_Processing_Status__c,Core_Signal_code__c,Core_Part__c,Core_Component_Product_Class__c,LastModifiedDate from Core_PIR_Ext_Attributes__c where Core_Processing_Status__c=\'Pending\' ORDER BY CreatedDate DESC';
        return Database.getQueryLocator( stagingRecordList );
    }
    
    public void execute(Database.BatchableContext BC, List<Core_PIR_Ext_Attributes__c> stagingRecList){
     
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        Map<Id, Core_PIR_Ext_Attributes__c> updateStagingMap = new Map<Id, Core_PIR_Ext_Attributes__c>();
        Map<Id, Core_PIR_Ext_Attributes__c> productIdStagingMap = new Map<Id, Core_PIR_Ext_Attributes__c>();
        List<String> oPNFromProductList = new List<String>();
       // List<String> stageDescWithOPNList = new List<String>();
        try{
            List<Product2> prodListToBeUpdated = new List<Product2>();
            Map<String,Core_PIR_Ext_Attributes__c> PIRAttributeMap = new Map<String,Core_PIR_Ext_Attributes__c>();
            //As Part number is unique identifier for Product, this attribute is used as Unique update case
            if(stagingRecList != null){
                for(Core_PIR_Ext_Attributes__c PIRAttributeRecord : stagingRecList){
                    if(PIRAttributeRecord.Core_Processing_Status__c=='Pending') {
                        PIRAttributeMap.put(PIRAttributeRecord.Core_Part__c,PIRAttributeRecord);
                    }
                }
            }  
            
            Map<Id,Product2> productMap = new Map<Id,Product2>([select Id,Name,Core_Product_Ext_Attribute_Id__c,Core_OPN__c,Core_Item_Signal_Cd__c,Core_Item_Class_Nm__c from Product2 where Core_OPN__c IN:PIRAttributeMap.keySet() and Core_Product_Org__c ='Sales' and Core_Product_Type__c ='Intel® FPGAs']);
            for(Product2 productRec : productMap.values()){
               // stageDescWithOPNList.add(productRec.Core_OPN__c);
                if(PIRAttributeMap.containsKey(productRec.core_OPN__c)){
					Core_PIR_Ext_Attributes__c extAttribute = PIRAttributeMap.get(productRec.core_OPN__c);
                    if(extAttribute != null && String.isNotBlank(extAttribute.Core_Component_Product_Class__c)){
						productRec.Core_Item_Class_Nm__c = extAttribute.Core_Component_Product_Class__c;
						productRec.Core_Item_Signal_Cd__c= extAttribute.Core_Signal_code__c;
						prodListToBeUpdated.add(productRec);
						productIdStagingMap.put(productRec.Id, extAttribute);
						oPNFromProductList.add(productRec.Core_OPN__c);//list of OPNs available in Product
                    }
                }                
            }
           /* for(Core_PIR_Ext_Attributes__c StagingRec : stagingRecList){
                if(!stageDescWithOPNList.contains(StagingRec.Core_Part__c)){
                    Core_PIR_Ext_Attributes__c stageRec = new Core_PIR_Ext_Attributes__c();
                    stageRec.Id = StagingRec.Id;
                    stageRec.Core_Error_Description__c = 'Product in PENDING Status with Signal Code : '+StagingRec.Core_Signal_code__c+' and Last Modified Date : '+StagingRec.LastModifiedDate;
                   // stageDescWithoutOPN.add(stageRec);
                   stageDescWithoutOPN.put(stageRec.Id,stageRec);
                }
            }*/
            if(prodListToBeUpdated.size() > 0){
				Database.SaveResult[] srList = Database.update(prodListToBeUpdated, false);                    
                for(Integer i=0; i<srList.size(); i++){
					Core_PIR_Ext_Attributes__c updateStagingRec = new Core_PIR_Ext_Attributes__c();
                    if(srList[i].isSuccess()){
                    //onsuccess mark staging record as success
						if(productIdStagingMap.containsKey(srList[i].getId())){
							updateStagingRec.Id = productIdStagingMap.get(srList[i].getId()).Id;
                            updateStagingRec.Core_Processing_Status__c = 'Successful';
                            updateStagingRec.Core_Error_Description__c = 'Product Record '+srList[i].getId()+' UPDATED by Staging record : '+updateStagingRec.Id+' with Signal Code : '+' '+productIdStagingMap.get(srList[i].getId()).Core_Signal_code__c+' and Last Modified Date : '+System.now();
                            updateStagingMap.put(updateStagingRec.Id, updateStagingRec);
                            captureQueryErr.add(new Core_Log_Entry__c(Core_Details__c = 'Updated Product Record:'+srList[i].getId()+' by Staging Record:'+ updateStagingRec.Id, Core_Message__c = 'Success', Core_Severity__c = 'High',Core_Project__c='PIR', Core_Origin__c='Core_PSGProductIntegrationHandler', Core_When__c = System.now())); 
                        }
                    }
                        
                }
            }
                
            //update stagging records with status
            if(updateStagingMap!=null && updateStagingMap.size()>0){
                update updateStagingMap.values();
            }
          /*  if(stageDescWithoutOPN!=null && stageDescWithoutOPN.size()>0){
                system.debug('stageDescWithoutOPN Values------'+stageDescWithoutOPN.values());
            	update stageDescWithoutOPN.values();
            }*/	
            
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
    
    public void finish(Database.BatchableContext BC){
   }
}