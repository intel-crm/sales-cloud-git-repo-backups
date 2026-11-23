/****************************************************************************************************
Apex Class Name:  
Version     : 1.0 
Created Date: 01 Jan 2024
Function    : Utility Class for PCC Deal Reg

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Shijas KM             01/31/2024              Original Version

*****************************************************************************************************/

public class Core_OpportunityDealRegUtility {
    
    public static boolean IsPCC_DealRegOpty(Id recordId)
    {
        Boolean isPCC_DealRegOpty= false;
        try {
            List<Opportunity> oppId = [Select Id from Opportunity where Core_Opportunity_Coverage_Nm__c= 'Partner-Led Opportunity' and Core_Coverage_Type_Nm__c= 'Deal Registration' and Id =: recordId ];
            if(oppId.IsEmpty()){
                isPCC_DealRegOpty= false;                 
            }
            else{
                isPCC_DealRegOpty= true;
            }
        }
        catch(Exception e) {
            Core_Log_Entry__c er_Entry= new Core_Log_Entry__c(Core_Details__c= e.getStackTraceString() ,Core_Message__c='isPCC_DealRegOpty' + 'line number'+e.getLineNumber(),Core_Project__c = 'Sales CRM'  );
            insert er_Entry;
        }
        return isPCC_DealRegOpty;
    }
    
    /*Areefa : Method to ByPass the PCC Deal Reg Opportunities  
    public static List<String> byPassOpptfromKPI(List<String> records){
        List<String> rid = new List<String>();
        try{
            List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Core_Opportunity_Coverage_Nm__c != 'Partner-Led Opportunity' AND Core_Coverage_Type_Nm__c != 'Deal Registration' AND Id IN :records];
            
            for (Opportunity opp : oppList) {
                rid.add(opp.Id);
            } 
        }catch(Exception e) {
            Core_Log_Entry__c er_Entry= new Core_Log_Entry__c(Core_Details__c= e.getStackTraceString() ,Core_Message__c='Error in class of Core_OpportunityDealRegUtilit Method Name byPassOpptfromKPI ' + 'line number'+e.getLineNumber(),Core_Project__c = 'Sales CRM'  );
            insert er_Entry;
        }
        
        return rid;
    }*/
    
}