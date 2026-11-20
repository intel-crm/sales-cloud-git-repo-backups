public class Core_AccountCoverageExportTriggerHandler{
 
 // This method logs insert audits
    /*public static void updateInsertOperation(list<Core_AccountCoverage_Export__c> listTriggerNewACE){
        for(Core_AccountCoverage_Export__c ACE:listTriggerNewACE){
            if(ACE.Core_Status__c==''||ACE.Core_Status__c==null||ACE.Core_Status__c=='New') {
                    ACE.Core_Status__c='New';
                    ACE.Core_Operation__c='ADD';
            }   
        }
    }*/

  // This method logs Update audits
   /* public static void updateOperation(list<Core_AccountCoverage_Export__c> listTriggerNewACE, Map<Id,Core_AccountCoverage_Export__c> mapTriggerOldACE){
            Boolean isUpdate = false;
            for(Core_AccountCoverage_Export__c ACE:listTriggerNewACE){
                isUpdate = false;
                Core_AccountCoverage_Export__c oldACE = mapTriggerOldACE.get(ACE.ID);
                
                if(oldACE.Core_Status__c!=ACE.Core_Status__c){
                    // Checking for change in data
                    if ((ACE.Name != oldACE.Name)||(ACE.Core_User_Email__c != oldACE.Core_User_Email__c)||(ACE.Core_User_WWID__c != oldACE.Core_User_WWID__c) ||(ACE.Core_Login_Id__c != oldACE.Core_Login_Id__c) ||(ACE.Core_User_City__c  != oldACE.Core_User_City__c) ||(ACE.Core_User_Country_Code__c != oldACE.Core_User_Country_Code__c)  ||(ACE.Core_User_First_Name__c != oldACE.Core_User_First_Name__c)  ||(ACE.Core_User_IsActive__c != oldACE.Core_User_IsActive__c)  ||(ACE.Core_User_Language_Locale_Key__c != oldACE.Core_User_Language_Locale_Key__c)  ||(ACE.Core_User_Last_Name__c != oldACE.Core_User_Last_Name__c)  ||(ACE.Core_User_Title__c != oldACE.Core_User_Title__c)) {
                        isUpdate=true;
                        
                    }
                     
                        Not required  
                       if((oldACE.Core_Status__c==''||oldACE.Core_Status__c==null) && (ACE.Core_Status__c=='New')){
                            ACE.Core_Operation__c='ADD';
                        }
                        
                        // Core_Operation__c = Load is updating from "Core_Batch_AccountCoverage_Summary"  
                        
                       if((oldACE.Core_Status__c=='New') && (ACE.Core_Status__c=='Processed')){
                        ACE.Core_Operation__c='NC';
                       }
                   
                    if((oldACE.Core_Status__c=='Processed') && (ACE.Core_Status__c=='New')){
                        if(isUpdate){
                            ACE.Core_Operation__c='UPDT';
                        }else{
                            ACE.Core_Operation__c='NC';
                        }    
                    }
                    
                    /*      Moved To Batch Process
                    
                        if((oldACE.Core_Status__c=='Processed') && (ACE.Core_Status__c=='Delete')){
                                ACE.Core_Operation__c='DEL';
                        }
                        if((oldACE.Core_Status__c=='New') && (ACE.Core_Status__c=='Load')){
                            ACE.Core_Operation__c='LOAD';
                        }
                    
                    
                   
              }
            }
       } */
         public static String dummyMethod1() {
        return null;
    }
}