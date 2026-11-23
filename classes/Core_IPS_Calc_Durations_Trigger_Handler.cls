/***********************************************************************************************
Version     : 1.0 
Created Date: 03 Jun 2019
Test Class  : Core_IPS_CalcDurationsHandler_Test
Function    : Methods for Escalation Reporting
Input Parameters: Case New List
Output Parameters: None
Transactions: After Update
Description: This method executes as follows:
After Update: Calls the methods in the STOWD managed package to create STOWD records.
"trackedFields" variable defines the fields that are tracked.
The managed package looks at the Case Field History table to determine field changes.
Because of the number of times the Case triggers are executed,
it can identify the same update multiple times.  To prevent inserting the same record,
the bulk of the code compares existing records to new records and prevents
inserting same record.  Otherwise, the managed package generates a duplicates error
which then gets propogated to VF pages to show the user.
This needs to run in After Update trigger because Case Field History has to be
updated before this code.
Number of Queries from Called methods:1
Number of times called: Once for trigger execution  
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sneha               06/03/2019              Created for US368211 STOWD Sub Status & Last Assigned Queue fields 
must capture transactional snapshot data in each record

* Sneha               07/25/2019              Updated for US404749 Add 'Escalated Level' to the STOWD data/process
*******************************************************************************************************************/  


public without sharing class Core_IPS_Calc_Durations_Trigger_Handler {
    public static void calcDurations(List<Case> lstTriggerNew) {
    /*    List<STOWD__Status_Ownership_Duration__c> lstCurrentSTOWD=new  List<STOWD__Status_Ownership_Duration__c>();
        try{
            if (!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('calcDurations'))
                return; 
            List<STOWD__Status_Ownership_Duration__c> durations = new List<STOWD__Status_Ownership_Duration__c>();
            // Added Escalated level field api to track  for US404749 
            Set<string> trackedFields = new Set<string> {'Core_IPS_Assigned_Queue__c', 'OwnerID', 'Status','Core_Sub_Status__c','Core_IPS_Escalated_Level__c'};
                
            STOWD.API.CalculateDurations(durations, trackedFields, 'caseHistory', 'CaseId');
            
            // List<User> userLists = [Select ID from User where id=:lstTriggerNew[0].ownerID]; // unused query commented by Chiru coderefactor
            //Query STOWD records that match the case record in the durations list.
            //Since blank or null is a valid value, it's difficult define a query to further
            //filter the query.
            if(durations != null && !durations.isEmpty()) {
                List<Id> lstParent = new List<Id>();                
                for (STOWD__Status_Ownership_Duration__c objSTOWD : durations) {
                    if(objSTOWD.STOWD__Parent__c != null) {
                        lstParent.Add(objSTOWD.STOWD__Parent__c);
                    }
                }
                
                //Added Escalated level field api in SOQL for US404749 
                //FLS check added-Venugopal
                if(STOWD__Status_Ownership_Duration__c.SObjectType.getDescribe().isQueryable()){
                    lstCurrentSTOWD =                                            [Select Id,
                                                                                  STOWD__Parent__c,
                                                                                  STOWD__Owner__c,
                                                                                  STOWD__Status__c,
                                                                                  STOWD__Until__c,
                                                                                  Core_IPS_Assigned_Queue__c,
                                                                                  Core_Sub_Status__c,
                                                                                  Core_IPS_Escalated_Level__c,
                                                                                  STOWD__From__c
                                                                                  From STOWD__Status_Ownership_Duration__c
                                                                                  Where STOWD__Parent__c =: lstParent];
                }
                
                //Compare durations list to existing records and remove any duplicates
                for (Integer i = (durations.size()-1) ; i >= 0; i--) {
                    STOWD__Status_Ownership_Duration__c objSTNew = durations[i];
                    if(lstCurrentSTOWD != null && !lstCurrentSTOWD.isEmpty()){
                        for(STOWD__Status_Ownership_Duration__c objSTCurrent : lstCurrentSTOWD) {
                            //Compare values.  STOWD__Until__c the only one not compared.
                            // Added Escalated level in the comparison for US404749 
                            if((objSTNew.STOWD__Parent__c == objSTCurrent.STOWD__Parent__c) && (objSTNew.STOWD__Owner__c == objSTCurrent.STOWD__Owner__c) &&
                               (objSTNew.STOWD__Status__c == objSTCurrent.STOWD__Status__c) && (objSTNew.Core_Sub_Status__c == objSTCurrent.Core_Sub_Status__c) &&
                               (objSTNew.STOWD__From__c == objSTCurrent.STOWD__From__c) &&  (objSTNew.Core_IPS_Assigned_Queue__c== objSTCurrent.Core_IPS_Assigned_Queue__c) &&
                               (objSTNew.Core_IPS_Escalated_Level__c == objSTCurrent.Core_IPS_Escalated_Level__c)) {
                                   durations.remove(i);
                               }
                        }
                    }                    
                }
            }
            
            // Add STOWD record
            if(durations.size() > 0) {
                Database.SaveResult[] srList = database.insert(durations, false);
            }            
        } 
        catch (exception e) {
        }
*/
    }
}