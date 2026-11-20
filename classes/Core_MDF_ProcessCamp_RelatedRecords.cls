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
        //WW49 - TWC742-1384: [DCF] - Replace "CMP Spend by Activity Category and Year" with "CMP Spend by Year (similar to CCF)"
        if(Label.Core_MDF_Campaign_RegionWise_Budget.contains(';')){
            List<String> recTypeDeveloperName = Label.Core_MDF_Campaign_RegionWise_Budget.split(';');
            for(String str: recTypeDeveloperName){
                regionWiseBudgetCampaignRecId.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());            
            }
        }
        if(Label.Core_MDF_Campaign_CategoryWise_Budget.contains(';')){
            List<String> recTypeDeveloperName1 = Label.Core_MDF_Campaign_CategoryWise_Budget.split(';');
            for(String str: recTypeDeveloperName1){categoryWiseBudgetCampaignRecId.add(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(str).getRecordTypeId());} 
        }      
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
        Set<String> newCategoryVal = new Set<String>();                    
        Map<String, String> lstCValues = new Map<String, String>();
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
                                    lstRValues.put(rcmpVal.Core_MDF_Region__c, rcmpVal.Core_MDF_Region__c);hasValue = True;break;
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
                    for(Core_MDF_Categorywise_Campaign_Budget__c ccmpVal: cmpWithCategorywise.get(cmp.Id)){
                        Boolean hasValue = false;                        
                        for(String sval : cmpWithCategories.get(cmp.Id)){                  
                            if(ccmpVal.Core_MDF_Activity_Category__c == sval){ 
                                lstCValues.put(ccmpVal.Core_MDF_Activity_Category__c, ccmpVal.Core_MDF_Activity_Category__c);hasValue = True;break;
                            }                    
                        }
                        if (!hasValue){categoryCmpToBeDeleted.add(ccmpVal);}          
                    }
                    for(String sval : cmpWithCategories.get(cmp.Id)){                        
                       if(lstCValues.get(sval)==NULL){newCategoryVal.add(sVal);}  
                    }                    
                    cmpWithNewCategories.put(cmp.Id,new List<String>(newCategoryVal));
                }
            }
            // records to be delete when selected value is removed from campaign
            //US930209 - Added extra condition to fix checkmarx related issues
            if(regionCmpToBeDeleted.Size()>0 && Schema.sObjectType.Core_MDF_Regionwise_Campaign_Budget__c.isAccessible() && Schema.sObjectType.Core_MDF_Regionwise_Campaign_Budget__c.isDeletable()){
                Database.delete(regionCmpToBeDeleted);                              
            }
            // records to be delete when selected value is removed from campaign
            //US930209 - Added extra condition to fix checkmarx related issues
            if(categoryCmpToBeDeleted.Size()>0 && Schema.sObjectType.Core_MDF_Categorywise_Campaign_Budget__c.isAccessible() && Schema.sObjectType.Core_MDF_Categorywise_Campaign_Budget__c.isDeletable()){       
                Database.delete(categoryCmpToBeDeleted);
            }
            
            // records to be shared when new selected value is added to campaign
            if(cmpWithNewRegions.Size()>0){
                newRegionOrCategoryRecords(newCmpList,cmpWithNewRegions, NULL);
            }
            
            // records to be shared when new selected value is added to campaign
            if(cmpWithNewCategories.Size()>0){newRegionOrCategoryRecords(newCmpList, NULL, cmpWithNewCategories);}
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
        //US930209 - Added extra condition to fix checkmarx related issues
        if(regionCmp.Size()>0 && Schema.sObjectType.Core_MDF_Regionwise_Campaign_Budget__c.isCreateable()){
            
            Database.insert(regionCmp); 
        }
        
        // Insert DCF related records
        //US930209 - Added extra condition to fix checkmarx related issues
        if(categoryCmp.Size()>0 && Schema.sObjectType.Core_MDF_Categorywise_Campaign_Budget__c.isCreateable()){        
            Database.insert(categoryCmp);
        }
    }
  
//prepare list of activating accounts    
public static List<Id> getPartnerAccList(String partAcc){
    List<Id> partAccList = new List<Id>();
    if( String.isNotBlank(partAcc)){
        if(partAcc.contains(';')){
            partAccList = (List<Id>)partAcc.split(';');
        }
        else{
            Id pId = (Id)partAcc;
            partAccList.add(pId);
        }
    }
    return partAccList;
}

/**************************************************************************************************************************************
Method Name:                                             insertUpdateActivatingPartnerMap
@return  :                                               Void
@parameters:                                             List of campaigns, campaigns oldMap                                 
Description:                                             Insert/Update Camp_to_ActPartner_Map 
Added By:                                                Accenture – Namratha  -  20/3/2024
**************************************************************************************************************************************/   

public static void insertUpdateActivatingPartnerMap(List<Campaign> newCmpList, Map<Id,Campaign> campOldMap, boolean isInsert, boolean isUpdate){ 
        ChannelProgram prog = [select id , Core_MDF_Technical_Program_Name__c from ChannelProgram where Core_MDF_Technical_Program_Name__c='Ecosystem Extension Fund' limit 1];
        List<Core_MDF_Camp_to_ActPartner__c> actPartnerList = new List<Core_MDF_Camp_to_ActPartner__c>();
        //ATHR 
        Set<Id> campaignIds = new Set<Id>();
        for (Campaign cmp : newCmpList) {
            campaignIds.add(cmp.Id);
        }
        Map<Id, List<Core_MDF_Camp_to_ActPartner__c>> campaignToActPartnerMap = new Map<Id, List<Core_MDF_Camp_to_ActPartner__c>>();
        List<Core_MDF_Camp_to_ActPartner__c> accParList = [select id,Core_MDF_Activating_Partner_Account_id__c, Core_MDF_Campaign_Id__c from Core_MDF_Camp_to_ActPartner__c where Core_MDF_Campaign_Id__c IN :campaignIds];
        
        for (Core_MDF_Camp_to_ActPartner__c aObj : accParList) {
            if (!campaignToActPartnerMap.containsKey(aObj.Core_MDF_Campaign_Id__c)) {
                campaignToActPartnerMap.put(aObj.Core_MDF_Campaign_Id__c, new List<Core_MDF_Camp_to_ActPartner__c>());
            }
            campaignToActPartnerMap.get(aObj.Core_MDF_Campaign_Id__c).add(aObj);
        }//ATHR
        for (Campaign cmp : newCmpList){
            Map<Id,Core_MDF_Camp_to_ActPartner__c> accPartMap = new Map<Id,Core_MDF_Camp_to_ActPartner__c>();
            List<Id> actPartAccounts = new List<Id>();
            if (campaignToActPartnerMap.containsKey(cmp.Id)) {//ATHR
                for(Core_MDF_Camp_to_ActPartner__c aObj : campaignToActPartnerMap.get(cmp.Id)){// accParList is replaced with campaignToActPartnerMap.get(cmp.Id)
                    accPartMap.put(aObj.Core_MDF_Activating_Partner_Account_id__c,aObj);
                    actPartAccounts.add(aObj.Core_MDF_Activating_Partner_Account_id__c);
                }
            }
            List<Id> oldActAccounts = new List<Id>();
            List<Id> accList = new List<Id>();
            if(isUpdate){
                oldActAccounts = getPartnerAccList(campOldMap.get(cmp.Id).Core_MDF_Partner_Mapping_Txt__c);
            }
            if(cmp.Core_MDF_Program__c == 'Ecosystem Extension Fund'){
                accList = getPartnerAccList(cmp.Core_MDF_Partner_Mapping_Txt__c);
                if(isInsert || isUpdate){
                    for(Id acc:accList){
                        if(isInsert || (oldActAccounts!=null && !oldActAccounts.contains(acc))){
                            Core_MDF_Camp_to_ActPartner__c actPartRec = new Core_MDF_Camp_to_ActPartner__c();
                            actPartRec.Core_MDF_Campaign_Id__c = cmp.Id;
                            actPartRec.Core_MDF_Activating_Partner_Account_id__c = acc;
                            actPartRec.Core_MDF_Reimbursement_Rate_pct__c = '100%';
                            actPartRec.Core_MDF_Channel_Program__c = prog.Id;
                            actPartRec.Core_MDF_Active_Ind__c = true;
                            actPartRec.Core_MDF_External_ID__c = (String)cmp.Id + (String)acc;
                            actPartnerList.add(actPartRec);
                        }
                    }
                }
                else if(isUpdate){
                    for(Id acc:oldActAccounts){
                        if(!accList.contains(acc)){
                            Id aPId = accPartMap.get(acc).Id;
                            Core_MDF_Camp_to_ActPartner__c actPartRec = new Core_MDF_Camp_to_ActPartner__c();
                            actPartRec.Id = aPId;
                            actPartRec.Core_MDF_Campaign_Id__c = cmp.Id;
                            actPartRec.Core_MDF_Activating_Partner_Account_id__c = acc;
                            actPartRec.Core_MDF_Active_Ind__c = false;
                            actPartRec.Core_MDF_External_ID__c = (String)cmp.Id + (String)acc;
                            actPartnerList.add(actPartRec);
                        }
                    }
                }
                
            }
        }
        
        try{
            if(actPartnerList.Size()>0 && Schema.sObjectType.Core_MDF_Camp_to_ActPartner__c.isCreateable()){               
                Database.upsert(actPartnerList); 
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }
}