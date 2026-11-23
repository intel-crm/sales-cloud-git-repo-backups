public without sharing class Pricing_QuoteTeam_QuoteSharing_Batch implements Database.Batchable<sObject> {
    public Set<Id> finalQuoteIds = new Set<Id>();
    /**
    * @description : Return Quote Team Members where Grant Access is True and Quote is not null or Quote Team Member is inactive
    * @author   |  
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator([SELECT id,Pricing_Role_Nm__c,Pricing_Quote_Team_Member_Id__c,Pricing_Quote_Team_Member_Id__r.Email,Pricing_Quote_Id__c,Pricing_Quote_Id__r.Pricing_Intel_Account_Exec_Email_Txt__c,Pricing_Grant_Access_Ind__c,Pricing_Quote_Team_Member_Id__r.IsActive 
                                         FROM Pricing_Quote_Team__c WHERE (Pricing_Grant_Access_Ind__c=false AND Pricing_Quote_Id__c!=null) OR Pricing_Quote_Team_Member_Id__r.IsActive =false]);      
    }
    
    /**
    * @description : Create Quote Shares for Quote Team Members
    * @author   | 
    * @param bc 
    * @param quoteTeamMembersBatch 
    **/
    public void execute(Database.BatchableContext bc, List<Pricing_Quote_Team__c> quoteTeamMembers){
        try{
            Map<Id,Pricing_Quote_Team__c> quoteTeamMap = new Map<Id,Pricing_Quote_Team__c>();
            List<Pricing_Quote_Team__c> qtmToBeUpdated = new List<Pricing_quote_team__c>();
            for(Pricing_Quote_Team__c qtm : quoteTeamMembers){
                if(qtm.Pricing_Quote_Team_Member_Id__r.IsActive){
                    quoteTeamMap.put(qtm.Id, qtm);
                }else if(qtm.Pricing_Grant_Access_Ind__c){
                    qtm.Pricing_Grant_Access_Ind__c=false;
                    qtmToBeUpdated.add(qtm);
                }
                finalQuoteIds.add(qtm.Pricing_Quote_Id__c);
            }
            if(quoteTeamMap.size() > 0){
            Pricing_QuoteTeam_Trigger_Handler.createQuoteSharesForQTM(quoteTeamMap); 
            }
            if(qtmToBeUpdated.size()>0){
                update qtmToBeUpdated;
            }
        }catch(exception ex){
            Pricing_Tender_Utility.logError(ex);
        }       
    }

    /**
    * @description create core log entry
    * @author Karthik  | 28-01-2025 
    * @param bc 
    **/
    public void finish(database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        List<Core_Log_Entry__c> lstLogEntryRecords = createLogEntryRecords();
        List<Database.SaveResult> resultsCreateLogRecords = Database.insert(lstLogEntryRecords, false);
    }

    /**
    * @description : create core log entry record 
    * @author Karthik  | 28-01-2025 
    * @return List<Core_Log_Entry__c> 
    **/
    private List<Core_Log_Entry__c> createLogEntryRecords(){
    List<Core_Log_Entry__c> lstLogEntry = new List<Core_Log_Entry__c>();
    DateTime dtnow = System.now();
    decimal duration = ((dtnow.getTime())/1000) - ((System.now().getTime())/1000);        
    // Create Assign log Entry
    Core_Log_Entry__c addLogEntry = new Core_Log_Entry__c ();
    addLogEntry.Core_Origin__c = 'Quote Shares for Quote Team Members';
    addLogEntry.Core_Project__c = 'Intel Quote Request (IQR)';
    addLogEntry.Core_Scope__c = 'IQR Quote Shares for Quote Team Members Logic';
    addLogEntry.Core_Severity__c = 'Information';
    addLogEntry.Core_Message__c = 'Batch for creating Quote Shares for Quote Team Members';
    addLogEntry.Core_When__c = System.now();
    addLogEntry.Core_Details__c = 'Duration: ' + duration+' for processing batch for following Quotes:' +finalQuoteIds;
    lstLogEntry.add(addLogEntry);        
    return(lstLogEntry);
    }
}