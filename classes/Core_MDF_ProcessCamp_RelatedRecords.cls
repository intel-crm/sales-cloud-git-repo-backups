/********************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessCamp_RelatedRecords 
* Version     : 1.0 
* Created Date: 8-27-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Raj D        8/27/2018                    Create and campaign related object records once cmpaign is modified or inserted. 
*********************************************************************************************************************************************/
public without sharing class Core_MDF_ProcessCamp_RelatedRecords {    
    
    public static List<Id> regionWiseBudgetCampaignRecId= new List<Id>();   
    public static List<Id> categoryWiseBudgetCampaignRecId= new List<Id>();    
    static{
     
        List<String> recTypeDeveloperName = Label.Core_MDF_Campaign_RegionWise_Budget.split(';');
        for(String str: recTypeDeveloperName){
            regionWiseBudgetCampaignRecId.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());            
        }
        List<String> recTypeDeveloperName1 = Label.Core_MDF_Campaign_CategoryWise_Budget.split(';');
        for(String str: recTypeDeveloperName1){
            categoryWiseBudgetCampaignRecId.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());            
        } 
    System.debug('regionWiseBudgetCampaignRecId: '+regionWiseBudgetCampaignRecId);    
    System.debug('categoryWiseBudgetCampaignRecId: '+categoryWiseBudgetCampaignRecId);               
    }

    
       
        
/**************************************************************************************************************************************
Method Name:                                             insertUpdateCategoryOrRegionRecords
@return  :                                               Void
@parameters:                                             List of campaigns, campaigns oldMap                                 
Description:                                             
Added By:                                                Accenture – Raj D  -  27/8/2018
**************************************************************************************************************************************/    
    public static void insertUpdateCategoryOrRegionRecords(List<Campaign> newCmpList, Map<Id,Campaign> campOldMap, boolean isInsert, boolean isUpdate){ 
        
        Map<Id, List<String>> cmpWithRegions = new Map<Id, List<String>> ();
        Map<Id, List<String>> cmpWithCategories = new Map<Id, List<String>> ();
        Set<Id> cmpIds = new Set<Id>(); 
        
        // Condition on insert or update to get multi picklist values
        if (isInsert || isUpdate){
            for (Campaign cmp : newCmpList){
                
                String regionValues = cmp.Core_MDF_Market__c;
                String categoryValues = cmp.Core_MDF_Activity_Category__c;
                regionValues = regionValues +';';            
                categoryValues = categoryValues +';';
                cmpWithRegions.put(cmp.Id, regionValues.split(';'));
                cmpWithCategories.put(cmp.Id, categoryValues.split(';'));
                
                cmpIds.add(cmp.Id);           
            }    
        }
        
        //Block for Creation of related Regionwise and Categorywise records on insert
        if (isInsert){            
            newRegionOrCategoryRecords(newCmpList, cmpWithRegions, cmpWithCategories);  
            
        }
        //Block for Creation or deletion of related Regionwise and Categorywise records on update
        if (isUpdate){  
            
            Map<Id, List<Core_MDF_Regionwise_Campaign_Budget__c>> cmpWithRegionwise = new Map<Id, List<Core_MDF_Regionwise_Campaign_Budget__c>>();
            Map<Id, List<Core_MDF_Categorywise_Campaign_Budget__c>> cmpWithCategorywise = new Map<Id, List<Core_MDF_Categorywise_Campaign_Budget__c>>();
            List<Core_MDF_Regionwise_Campaign_Budget__c>  regionCmpToBeDeleted = new List<Core_MDF_Regionwise_Campaign_Budget__c> ();
            List<Core_MDF_Categorywise_Campaign_Budget__c>  categoryCmpToBeDeleted = new List<Core_MDF_Categorywise_Campaign_Budget__c> ();
            Map<Id, List<String>> cmpWithNewRegions = new Map<Id, List<String>>();
            Map<Id, List<String>> cmpWithNewCategories = new Map<Id, List<String>>();
            
            for (Campaign cmp : [SELECT Id, Name, (SELECT Id, Name, Core_MDF_Region__c, Core_MDF_Campaign__c FROM 
                                                   Regionwise_Campaign_Budgets__r) FROM Campaign WHERE Id IN:cmpIds LIMIT 50000]){
                                                       
                                                       cmpWithRegionwise.put(cmp.Id, cmp.Regionwise_Campaign_Budgets__r);
                                                   }
            
            for (Campaign cmp : [SELECT Id, Name, (SELECT Id, Name, Core_MDF_Activity_Category__c, Core_MDF_Campaign__c FROM 
                                                   Categorywise_Campaign_Budgets__r) FROM Campaign WHERE Id IN:cmpIds LIMIT 50000]){
                                                       
                                                       cmpWithCategorywise.put(cmp.Id, cmp.Categorywise_Campaign_Budgets__r);
                                                   }
            
            for (Campaign cmp : newCmpList){        
                
                // logic for CCF Record Type
                //CCFB record type check is added by Shridhar to enable Regionwise Grid to CCFB
                if(regionWiseBudgetCampaignRecId.contains(cmp.RecordTypeId) && cmp.Core_MDF_Market__c != campOldMap.get(cmp.Id).Core_MDF_Market__c){
                    
                    Set<String> newRegionVal = new Set<String>();            
                    Set<String> lstRegionVal = new Set<String>();
                    Map<String, String> lstRValues = new Map<String, String>();
                    
                    for(Core_MDF_Regionwise_Campaign_Budget__c rcmpVal: cmpWithRegionwise.get(cmp.Id)){
                        Boolean hasValue = false;
                        if(cmp.Id == rcmpVal.Core_MDF_Campaign__c){                         
                            for(String sval : cmpWithRegions.get(cmp.Id)){                  
                                if(rcmpVal.Core_MDF_Region__c == sval){ 
                                    lstRValues.put(rcmpVal.Core_MDF_Region__c, rcmpVal.Core_MDF_Region__c);
                                    hasValue = True;
                                    break;
                                }                          
                            }
                        }
                        if(!hasValue){
                            regionCmpToBeDeleted.add(rcmpVal);
                        }          
                    } 
                    
                    for(String sval : cmpWithRegions.get(cmp.Id)){                       
                        if(lstRValues.get(sval)==NULL){
                            newRegionVal.add(sVal);
                        }
                        
                    }                    
                    cmpWithNewRegions.put(cmp.Id,new List<String>(newRegionVal));
                }
                
                // logic for DCF Record Type
                if(categoryWiseBudgetCampaignRecId.contains(cmp.RecordTypeId) && cmp.Core_MDF_Activity_Category__c != campOldMap.get(cmp.Id).Core_MDF_Activity_Category__c){
                    
                    Set<String> newCategoryVal = new Set<String>();                    
                    Map<String, String> lstCValues = new Map<String, String>();
                    
                    for(Core_MDF_Categorywise_Campaign_Budget__c ccmpVal: cmpWithCategorywise.get(cmp.Id)){
                        Boolean hasValue = false;                        
                        for(String sval : cmpWithCategories.get(cmp.Id)){                  
                            if(ccmpVal.Core_MDF_Activity_Category__c == sval){ 
                                lstCValues.put(ccmpVal.Core_MDF_Activity_Category__c, ccmpVal.Core_MDF_Activity_Category__c);
                                hasValue = True;
                                break;
                            }                      
                            
                        }
                        if (!hasValue){
                            categoryCmpToBeDeleted.add(ccmpVal);
                        }          
                    }             
                    
                    for(String sval : cmpWithCategories.get(cmp.Id)){                        
                       if(lstCValues.get(sval)==NULL){
                            newCategoryVal.add(sVal);
                        }
                        
                    }                    
                    cmpWithNewCategories.put(cmp.Id,new List<String>(newCategoryVal));
                }
            }
            // records to be delete when selected value is removed from campaign
            if(regionCmpToBeDeleted.Size()>0){
                Database.delete(regionCmpToBeDeleted);                              
            }
            // records to be delete when selected value is removed from campaign
            if(categoryCmpToBeDeleted.Size()>0){       
                Database.delete(categoryCmpToBeDeleted);
            }
            
            // records to be shared when new selected value is added to campaign
            if(cmpWithNewRegions.Size()>0){
                newRegionOrCategoryRecords(newCmpList,cmpWithNewRegions, NULL);
            }
            
            // records to be shared when new selected value is added to campaign
            if(cmpWithNewCategories.Size()>0){
                newRegionOrCategoryRecords(newCmpList, NULL, cmpWithNewCategories);
            }
        }   
    }
    
/**************************************************************************************************************************************
Method Name:                                             newRegionOrCategoryRecords
@return  :                                               Void
@parameters:                                             List of campaigns, campaignswithRegio oldMap                                 
Description:                                             
Added By:                                                Accenture – Raj D  -  27/8/2018

**************************************************************************************************************************************/    
    public Static void newRegionOrCategoryRecords(List<Campaign> newCampList, Map<Id, List<String>> cmpWithRegions, Map<Id, List<String>> cmpWithCategories){
        List<Core_MDF_Regionwise_Campaign_Budget__c>  regionCmp = new List<Core_MDF_Regionwise_Campaign_Budget__c> ();
        List<Core_MDF_Categorywise_Campaign_Budget__c>  categoryCmp = new List<Core_MDF_Categorywise_Campaign_Budget__c> ();
        for (Campaign cmp : newCampList){
         
            if(regionWiseBudgetCampaignRecId.contains(cmp.RecordTypeId)){
                for(String cmpValues : cmpWithRegions.get(cmp.Id)){
                    Core_MDF_Regionwise_Campaign_Budget__c rCBudget = new Core_MDF_Regionwise_Campaign_Budget__c();             
                    rCBudget.Core_MDF_Region__c = cmpValues;
                    rCBudget.Core_MDF_Campaign__c = cmp.Id;                    
                    regionCmp.add(rCBudget);                                    
                }
            }
            
            if(categoryWiseBudgetCampaignRecId.contains(cmp.RecordTypeId)){
                for(String cmpValues : cmpWithCategories.get(cmp.Id)){                    
                    Core_MDF_Categorywise_Campaign_Budget__c rCBudget = new Core_MDF_Categorywise_Campaign_Budget__c();             
                    rCBudget.Core_MDF_Activity_Category__c = cmpValues;
                    rCBudget.Core_MDF_Campaign__c = cmp.Id;                    
                    categoryCmp.add(rCBudget);      
                }
            }
        } 
        
        // Insert CCF related records
        if(regionCmp.Size()>0){
            Database.insert(regionCmp); 
        }
        
        // Insert DCF related records
        if(categoryCmp.Size()>0){        
            Database.insert(categoryCmp);
        }
    }       
}