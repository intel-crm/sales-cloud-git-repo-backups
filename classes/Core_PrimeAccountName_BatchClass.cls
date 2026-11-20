/**************************************************************************************
Apex Class Name:  Core_PrimeAccountName_BatchClass
Version     : 1.0 
Created Date: 09 Feb 2018
Function    : Class to populate Prime Account Name on Opportunity
Modification Log :
* Developer           Date                    Description
* ---------------------------------------------------------------------------- 
* Ragamalika Mohanraj  09/02/2018       US93865-Reporting: Add New Measures to Track Open and Won Products       
*/

global class Core_PrimeAccountName_BatchClass implements Database.Batchable<sObject>,Database.Stateful{
    global Core_Batch_Processing__c batchProcessing;  
    global DateTime jobRunTime;
    global String batchClassName;
    global Integer batchSize = 0;
    global integer count=0; 
    
    /*
    * Method name  : Start()- Batch class
    * Description  : Queries the values from Opportunity to update the Prime Account Name
    * Return Type  : List of records.
    * Parameter    : Batch context
    */ 
    global Core_PrimeAccountName_BatchClass(){
        jobRunTime= System.Now(); 
        batchClassName='Core_PrimeAccountName_BatchClass';     
        batchProcessing = new Core_Batch_Processing__c();  
    }  
    global Database.QueryLocator start(Database.BatchableContext BC){       
        Core_Batch_header__c batchHeader = [Select id,Last_Run_Date_Time__c,Email_Distribution_List__c from Core_Batch_Header__c where name = :batchClassName limit 1];
        String query = 'SELECT id,Core_Opp_Prime_Account_Name__c,Accountid,Account.Core_Prime_Account_Name__c FROM Opportunity';                                    
        batchProcessing.Batch_Header__C = batchHeader.id;
        batchProcessing.Core_Email_Distribution_List__c = batchHeader.Email_Distribution_List__c;
        batchProcessing.Core_Salesforce_Job_Id__c = BC.getJobId();
        batchProcessing.Core_Batch_Query__c = query;            
        batchProcessing.Core_Object_Name__c = 'Opportunity';            
        batchProcessing.Core_Start_Date_Time__c = jobRunTime; 
        insert batchProcessing;
        return Database.getQueryLocator(query);
    }
    
    /*
    * Method name  : execute()- Batch class
    * Description  : Process the records to update the Prime Account Name
    * Return Type  : VOID
    * Parameter    : Batch context and Scope
    */  
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        List<id> accIdList = new List<Id>();
        map<Opportunity,id> oppAccMap = new map<Opportunity,id>();        
        List<Account> accList = new List<Account>();
        map<Id,Account> accprimeMap = new map<Id,Account>();
        Set<Id>successfulOppIds=new set<Id>();
        Batch_Processing_Line_Item__c batchline = new Batch_Processing_Line_Item__c();
        Integer failedRecordCount=0;
        String errorString='';
        Integer batchRecCount=0;
        if(scope.size() > batchSize){            
            batchSize = scope.size();
        }      
        for(Opportunity oppObj: scope){    
            system.debug('inside 1st for');                                                         
            accIdList.add(oppObj.AccountId);
            oppAccMap.put(oppObj,oppObj.AccountId);
        }
        accList = [select Id,  Core_Prime_Account_Name__c from Account where id in:accIdList];
        for(Account a: accList){
            accPrimeMap.put(a.Id,a);
            system.debug('accPrimeMap-->'+accPrimeMap);
        }                    

        for(Opportunity opp: oppAccMap.KeySet()){
            if(opp.Core_Opp_Prime_Account_Name__c!=accPrimeMap.get(opp.AccountId).Core_Prime_Account_Name__c){
                system.debug('condition satisfied');
                system.debug('prime acc name-->'+accPrimeMap.get(opp.AccountId));
                opp.Core_Opp_Prime_Account_Name__c=accPrimeMap.get(opp.AccountId).Core_Prime_Account_Name__c;
                oppToUpdateList.add(opp);
            }
        }  
        //update scope;          
        try{
            // Database.update(oppToUpdateList);
            system.debug('OPPLIST IS:'+oppToUpdateList.size());
            Database.SaveResult[] lsr = Database.update(oppToUpdateList, false);
            // Iterate through the Save Results 
            for(Database.SaveResult sr:lsr){
                // fetch all success DML id's in this set
                if(sr.isSuccess()){
                    batchRecCount=batchRecCount+1;
                    successfulOppIds.add(sr.getId());
                }else{
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()){ 
                        errorString=errorString +err.getStatusCode() + ': ' + err.getMessage();
                    }                        
                }
            }
            // Get all the failed Ids by iterating through all the Account Ids and check with success IDs.
            for(Opportunity o: oppToUpdateList){
                if(!successfulOppIds.contains(o.Id)){
                    errorString=errorString + String.valueOf(o.Id)+';';
                    failedRecordCount=failedRecordCount+1;                      
                }
            }
            //insert the batch process line details.    
            count=count+batchRecCount;
            batchline.Batch_Processing__c = batchProcessing.id;           
            batchline.Object_Type__c = 'Opportunity';            
            batchline.Core_Number_of_Updates__c = batchRecCount; 
            batchline.Exception_Log__c='Total failed records: '+failedRecordCount;
            batchline.Core_Change_Log__c=errorString;                      
            insert batchline;
        }catch(Exception e){      
            System.debug('****BatchProcessing - '+batchProcessing);
            String exMessage= e.getMessage();
            if(exMessage.length()>255){
                exMessage.substring(0,255);
            }
            batchProcessing.Core_Exception_Log__c = exMessage;
            Update batchProcessing;
            system.debug('batchProcessing-->'+batchProcessing);
        }    
    }
    
    /*
    * Method name  : Finish()- Batch class
    * Description  : 
    * Return Type  : VOID
    * Parameter    : BatchableContext 
    */  
    global void finish(Database.BatchableContext BC){
        //update the batch processing with batch size, batch end date and other details.
        batchProcessing.Core_Total_Number_of_Records__c = count;
        batchProcessing.Core_End_Date_Time__c = System.Now();
        batchProcessing.Core_Batch_Size__c = batchSize;        
        batchProcessing.Core_Send_Email__c = true;                
        update batchProcessing;    
    }
}