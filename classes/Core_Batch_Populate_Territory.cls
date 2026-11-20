/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_Populate_Territory 
Version     : 1.0 
Created Date: 03 SEP 2015
Function    : Batch Class used to populate Territory info on Opportunity based on associated Account
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kalpana Choudhary         09/03/2015              Batch Class used to populate Territory info on Opportunity based on associated Account.
* Dave Hood                 12/09/2015              Added "AllOrNone" = false using Database.Update; also changed Map to List and added code to update the List
* Aran Wongsaprome          03/02/2017              US20045 Add stages "Production Lost" and "Production Cancelled"
*****************************************************************************************************************************************************************************************************/
global class Core_Batch_Populate_Territory implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        try{
            // Note: the following statement won't handle deletes, since they get hard-deleted from the table.
            // Plan is to run the initial load once a week to handle deletes.
            return Database.getQueryLocator([select Territory2Id, Territory2.Name, ObjectId, Object.RecordType.DeveloperName,
                                             Territory2.DeveloperName, Territory2.Territory2Type.MasterLabel
                                             from ObjectTerritory2Association
                                             where LastModifiedDate >= YESTERDAY]);
        }Catch(Exception ex){
            system.debug('Error in Querying data' + ex.getMessage());
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        map<Id,List<ObjectTerritory2Association>> accountIdTerritorymap = new map<Id,List<ObjectTerritory2Association>>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        Set<Id> accountIDSet = new Set<Id>();
        map<Id,ObjectTerritory2Association> BusinessTerriMap = new map<Id,ObjectTerritory2Association>();
        map<Id,ObjectTerritory2Association> GeographicTerriMap = new map<Id,ObjectTerritory2Association>();
        map<Id,ObjectTerritory2Association> NamedTerriMap = new map<Id,ObjectTerritory2Association>();
        String BusinessTerriType = null,GeographicTerriType = null,NamedTerriType = null;
        for(ObjectTerritory2Association Terr : (List<ObjectTerritory2Association>) scope){
            accountIDSet.add(terr.ObjectId);
        }
        
        for(ObjectTerritory2Association Terr : [SELECT Territory2Id,Territory2.Name,ObjectId,Object.RecordType.developerName, Territory2.DeveloperName, Territory2.Territory2Type.MasterLabel FROM ObjectTerritory2Association where ObjectId In : accountIDSet ORDER BY Territory2.Name ASC] ){
            if(terr.Object.RecordType.developerName == 'Mastered_Account'){
                if(!accountIdTerritorymap.keySet().contains(terr.ObjectId)){
                    accountIdTerritorymap.put(terr.ObjectId,new List<ObjectTerritory2Association>());
                }
                accountIdTerritorymap.get(terr.ObjectId).add(terr); 
            }   
        }  
        
        Set<Id> setOppDupeCheck = new Set<Id>();
        
        if(accountIdTerritorymap.size()>0){
            for(Opportunity opp : [Select Id,Core_Business_Unit_Territory__c ,StageName,Core_Business_Unit_Territory_Name__c,AccountId,Core_Named_Strategic__c,Core_Named_Strategic_Territory_Name__c,Core_Geographical_Territory__c,Core_Geographical_Territory_Name__c from opportunity where accountId In : accountIdTerritorymap.keySet() and (recordtypeId =: label.Core_Opp_New_Opp_Record_Type_Id OR recordtypeId =: label.Core_Opportunity_Record_Type_Id) ]){
                // Status check added for closed opportunties
                if(!(opp.StageName == 'Lost' || opp.StageName == 'Cancelled' || opp.StageName == 'Design Win' || opp.StageName == 'Production Win'
                    || opp.StageName == 'Production Lost' || opp.StageName == 'Production Cancelled'))
                {
                    // As only first territory of corresponding account is required for processing.
                    if(accountIdTerritorymap.get(opp.AccountId).size()>0){
                        for(ObjectTerritory2Association territ : accountIdTerritorymap.get(opp.AccountId)){
                            if(territ.Territory2.Territory2Type.MasterLabel == 'Business Units and Specialists'){
                                BusinessTerriType = BusinessTerriType + ' ;' + territ.Territory2.Name;
                                BusinessTerriMap.put(territ.ObjectId,territ);
                            }   
                            else if(territ.Territory2.Territory2Type.MasterLabel == 'Geographic World Wide'){    
                                GeographicTerriType = GeographicTerriType + ' ;' + territ.Territory2.Name;
                                GeographicTerriMap.put(territ.ObjectId,territ);
                            }
                            else if(territ.Territory2.Territory2Type.MasterLabel == 'Named / Strategic Accounts'){   
                                NamedTerriType = NamedTerriType + ' ;' + territ.Territory2.Name;
                                NamedTerriMap.put(territ.ObjectId,territ);
                            }   
                        }
                        for(ObjectTerritory2Association territ : accountIdTerritorymap.get(opp.AccountId)){
                            if(BusinessTerriMap.size() >0 && territ.Territory2.Territory2Type.MasterLabel == 'Business Units and Specialists'){
                                if(opp.Core_Business_Unit_Territory__c == Null || !(BusinessTerriType.Contains(opp.Core_Business_Unit_Territory__c)) ){
                                    opp.Core_Business_Unit_Territory__c = BusinessTerriMap.get(opp.AccountId).Territory2.Name;
                                    opp.Core_Business_Unit_Territory_Name__c = BusinessTerriMap.get(opp.AccountId).Territory2.DeveloperName;
                                    
                                    if (!setOppDupeCheck.contains(opp.Id))
                                    {
                                        updateOppList.add(opp);
                                        setOppDupeCheck.add(opp.Id);
                                    }
                                }
                            }
                            else if(GeographicTerriMap.size() >0 && territ.Territory2.Territory2Type.MasterLabel == 'Geographic World Wide'){
                                if(opp.Core_Geographical_Territory__c == null || !(GeographicTerriType.Contains(opp.Core_Geographical_Territory__c))){
                                    opp.Core_Geographical_Territory__c = GeographicTerriMap.get(opp.AccountId).Territory2.Name;
                                    opp.Core_Geographical_Territory_Name__c = GeographicTerriMap.get(opp.AccountId).Territory2.DeveloperName;
                                    
                                    if (!setOppDupeCheck.contains(opp.Id))
                                    {
                                        updateOppList.add(opp);
                                        setOppDupeCheck.add(opp.Id);
                                    }
                                }   
                            }else if(NamedTerriMap.size() >0 && territ.Territory2.Territory2Type.MasterLabel == 'Named / Strategic Accounts'){
                                if(opp.Core_Named_Strategic__c == null || !(NamedTerriType.Contains(opp.Core_Named_Strategic__c))){
                                    opp.Core_Named_Strategic__c  = NamedTerriMap.get(opp.AccountId).Territory2.Name;
                                    opp.Core_Named_Strategic_Territory_Name__c = NamedTerriMap.get(opp.AccountId).Territory2.DeveloperName;
                                    
                                    if (!setOppDupeCheck.contains(opp.Id))
                                    {
                                        updateOppList.add(opp);
                                        setOppDupeCheck.add(opp.Id);
                                    }
                                }   
                            } 
                        }
                    }
                }
            }
        }
        // Database.Update parameter "AllOrNone" set to false to perform updates even if some of opportunities  
        // throw a field validation exception.
        // 
        if(updateOppList.size() > 0)
           Database.update(updateOppList, false);

    }   
    
    global void finish(Database.BatchableContext BC){
    }
}