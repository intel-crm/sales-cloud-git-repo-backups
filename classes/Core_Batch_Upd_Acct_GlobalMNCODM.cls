/********************************************************************************************************************
Apex Class Name:  Core_Batch_Upd_Acct_GlobalMNCODM
Version     : 1.0 
Created Date: 17 MAR 2016
Function    : Batch class to populate Global MNC/ODM field on all Accounts if an Account is assigned to Global 
			Territory Type and if that territory has Gloabl MNC/ODM flag  checked on the Territory object
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
*Shailaja Gandam            3/17/16                 Initial Creation
*********************************************************************************************************************/
global class Core_Batch_Upd_Acct_GlobalMNCODM implements Database.Batchable<sObject> {
    
    public void updateAccounts(List<Account> updateAcctList)  {
     // Database.Update parameter "AllOrNone" set to false to perform updates even if some of Accounts  
        // throw a field validation exception.
        if(updateAcctList.size() > 0)
           Database.update(updateAcctList, false);                                  
     }   
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        try{
            // Query to get all the GLOBAL territories 
            // Global MNC/ODM field on territory will be maintained manually for this purpose
               return Database.getQueryLocator([select Id, Name, Core_Global_MNC_ODM__c from Territory2 
             					  				where LastModifiedDate >= YESTERDAY
                                                and Territory2Type.MasterLabel = 'Named / Strategic Accounts']);
          }Catch(Exception ex){
            system.debug('Error in Querying data' + ex.getMessage());
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC,List<sObject> scope){
        map<Id,List<ObjectTerritory2Association>> accountIdTerritorymap = new map<Id,List<ObjectTerritory2Association>>();
        map<Id,List<ObjectTerritory2Association>> acctIdDelTerrmap      = new map<Id,List<ObjectTerritory2Association>>();
        map<Id,List<ObjectTerritory2Association>> terrIdTerritorymap    = new map<Id,List<ObjectTerritory2Association>>();
        //Set<Id> accountIDSet = new Set<Id>();
        Set<Id> terrIdSet    = new Set<Id>();
        Set<Id> setDupeCheck = new Set<Id>();
        List<Account> updateAcctList = new List<Account>();
        List<ObjectTerritory2Association> terrAccountID = new List<ObjectTerritory2Association>();
        
         //get all the territory IDs from the territory structure
          	for(Territory2 Terr : (List<Territory2>) scope){
                if (!setDupeCheck.contains(terr.Id))
                   {
                      terrIdSet.add(terr.Id);		                       
                      setDupeCheck.add(terr.Id);          	
                   }
        	}

/*** this logic checks for the modified territories for the global MNC/ODM flag on the territory model * */        
        //clear variable
        setDupeCheck.clear();
        
        //get all account Objects associated to the modified territory ids
        for(ObjectTerritory2Association terrObjAssoc : [SELECT Territory2Id,Territory2.Name,ObjectId, Object.RecordType.developerName,
                                                		Territory2.Territory2Type.MasterLabel, Territory2.Core_Global_MNC_ODM__C
                                                		FROM ObjectTerritory2Association 
                                                		where Territory2Id In : terrIdSet ORDER BY Territory2.Name ASC] ){
            if(terrObjAssoc.Object.RecordType.developerName == 'Mastered_Account'){
                if(!accountIdTerritorymap.keySet().contains(terrObjAssoc.ObjectId)){
                    accountIdTerritorymap.put(terrObjAssoc.ObjectId,new List<ObjectTerritory2Association>());
                    accountIdTerritorymap.get(terrObjAssoc.ObjectId).add(terrObjAssoc); 
                }
            }   
        }  
 /*** this logic checks for the Account's modified territory assignments (ONLY addition no deletes)* */         
        //check if any account's territory assignment is changed   (not deleted) 
        for(ObjectTerritory2Association acctTerrAssc : [select Territory2Id, Territory2.Name, ObjectId, Territory2.Territory2Type.MasterLabel, 
                                                        Object.RecordType.developerName, Territory2.Core_Global_MNC_ODM__C
                                             			from ObjectTerritory2Association
                                             			where LastModifiedDate >= YESTERDAY]){
           if(acctTerrAssc.Object.RecordType.developerName == 'Mastered_Account'){
                if(!accountIdTerritorymap.keySet().contains(acctTerrAssc.ObjectId)){
                    accountIdTerritorymap.put(acctTerrAssc.ObjectId,new List<ObjectTerritory2Association>());
                    accountIdTerritorymap.get(acctTerrAssc.ObjectId).add(acctTerrAssc); 
                }
            }   
      	}    
        
 /** this logic unstamps the flag on account for removed territory associations ***/          
         List<Account> accountIDSet = [Select Id, Core_Global_MNC_ODM_Account__c
                                 		from Account
                                 		where Core_Global_MNC_ODM_Account__c != Null];
	     if(accountIDSet.size() > 0) {
         	for(ObjectTerritory2Association acctTerrAssc : [select Territory2Id, Territory2.Name, ObjectId, Territory2.Territory2Type.MasterLabel, 
                                                            Object.RecordType.developerName, Territory2.Core_Global_MNC_ODM__C
                                             			 	 from ObjectTerritory2Association
                                                             where ObjectId in : accountIDSet
                                                             and Territory2.Territory2Type.MasterLabel = 'Named / Strategic Accounts']){
        		if(!acctIdDelTerrmap.keySet().contains(acctTerrAssc.ObjectId)){
                    acctIdDelTerrmap.put(acctTerrAssc.ObjectId,new List<ObjectTerritory2Association>());              
                	acctIdDelTerrmap.get(acctTerrAssc.ObjectId).add(acctTerrAssc);
                }
        	}         
        
        	//check if the assoication doesnt exist and unstamp the flag
       	 	for(Account acct : accountIDSet) {
                if(!accountIdTerritorymap.containsKey(acct.ID)){
            		if(!acctIdDelTerrmap.containsKey(acct.ID)){                		
                		acct.Core_Global_MNC_ODM_Account__c = null;
                		if (!setDupeCheck.contains(acct.Id)){	
		                   	updateAcctList.add(acct);
    	                  	setDupeCheck.add(acct.Id);
        	            } 
            		}
                }
        	}
		}

        //set Core_Global_MNCODM__c field on an account        
       if(accountIdTerritorymap.size()>0){
         for(Account acct : [select Id, Core_Global_MNC_ODM_Account__c
                             from Account
                             where Id in : accountIdTerritorymap.keySet()]){
         	if(accountIdTerritorymap.get(acct.Id).size()>0){
            	for(ObjectTerritory2Association territ : accountIdTerritorymap.get(acct.Id)){
                    if(territ.Territory2.Territory2Type.MasterLabel == 'Named / Strategic Accounts') {
                       if (territ.Territory2.Core_Global_MNC_ODM__C == True ){
                  			acct.Core_Global_MNC_ODM_Account__c = territ.Territory2.Name;
                        }   
                        else {
                             acct.Core_Global_MNC_ODM_Account__c = null;
                        }
                     	if (!setDupeCheck.contains(acct.Id))
                        {
                          	updateAcctList.add(acct);
                           	setDupeCheck.add(acct.Id);
                        }
                	}  
             	}
         	}
          }
 		}  
                    
       //update accounts to stamp/unstamp global MNC/ODM account field
        if(updateAcctList.size() > 0) {
        	updateAccounts(updateAcctList);
        }
    }                
                               
    global void finish(Database.BatchableContext BC){
    }
}