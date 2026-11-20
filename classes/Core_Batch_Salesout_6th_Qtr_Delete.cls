/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_Salesout_6th_Qtr_Delete
Version     : 1.0 
Created Date: 1/05/16
Function    : Salesout should carry the current quarter and 4 prior quarters.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Brian Matthews              1/05/16                Development Start
*****************************************************************************************************************************************************************************************************/
global class Core_Batch_Salesout_6th_Qtr_Delete implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        try{
            Decimal numPeriod = NULL;

            Date currentDate = Date.today();
            
            // MUST use a Double in the Ceiling function
            Double doubleMonth     = currentDate.month();                                            
            Integer currentQuarter = Integer.valueOf(Math.Ceil(doubleMonth/3));  // MUST USE DOUBLE           
                                 
            Date quarterEnd  = Date.newInstance(currentDate.year(), currentQuarter * 3, 1);
            quarterEnd       = quarterEnd.addMonths(-14);
            quarterEnd       = quarterEnd.addDays(-1);
            
            String strPeriod = quarterEnd.year() + '0' + (quarterEnd.Month() / 3);
            numPeriod        = Decimal.valueOf(strPeriod);
            
            System.debug('#00 currentQuarter: ' + currentQuarter);
            System.debug('#01 quarterEnd: '     + quarterEnd);
            System.debug('#02 strPeriod: '      + strPeriod);
            System.debug('#03 numPeriod: '      + numPeriod);            

            return Database.getQueryLocator([SELECT Id 
                                             FROM Core_Channel_Salesout__c
                                             WHERE Core_Invoice_Quarter__c <= :numPeriod]);
        } catch(Exception ex){
            system.debug('#05 Error in Salesout Query: ' + ex.getMessage());
            return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if (scope == NULL)
            return;    
    
        List<Core_Channel_Salesout__c> lstCS = (List<Core_Channel_Salesout__c>) scope;

        // Database.delete parameter "AllOrNone" set to false to perform deletes even if some of deletes  
        // throw an exception.
        // 
        if(lstCS.size() > 0) { 
           Database.delete(lstCS, false);
           Database.emptyRecycleBin(lstCS);
        }   

    }   
    
    global void finish(Database.BatchableContext BC){
    }
}