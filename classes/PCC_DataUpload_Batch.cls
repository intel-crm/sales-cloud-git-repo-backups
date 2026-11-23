global class PCC_DataUpload_Batch implements Database.Batchable<sObject>, Database.Stateful {
    Map<id,id> resultMap = new Map<id,id>();
    public Database.QueryLocator start(Database.BatchableContext bc) {
        string query = 'select Core_Design_Registration_Nm__c,Core_End_Customer_Account_Id__c,id,';
           query+= 'Core_Product_Group_Nm__c,Core_Military_Aerospace_Gvrnmt_Use_Ind__c,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,';
           query+= 'Core_Vertical_Market_Nm__c,Core_Manufacturing_Region_Cd__c,Core_Production_End_Dt__c,Core_First_Customer_Ship_Dt__c,Core_Intel_Platform_Nm__c,Name,';
           query+= 'Core_Intel_Support_Status__c,Core_Design_Registration_Dsc__c,Core_FPGA_Quote_Comments_Txt__c,OwnerId,Core_Opportunity_Volume_Cnt__c,';
           query+= 'Core_Opportunity_Decision_Dt__c,Core_Accepted_By_Id__c,Core_Partner_Account_Id__r.OwnerID, Core_Partner_Account_Id__c'; 
        
        if(Test.isRunningTest()) {
            string name = 'PCC DataUpload Test DDR';
            query+= ' from Core_Design_Registration__c where Core_Design_Registration_Nm__c = : name';
        }
        else {
            query+= ' ' + System.Label.PCCDDRQuery;
        }

        return Database.getQueryLocator(query);    
    }
    
    public void execute(Database.BatchableContext BC, list<Core_Design_Registration__c> DDRList) {
        map <String, Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
        List<Opportunity> oppList = new List<Opportunity>();

        //Create Opps
        oppList = PCC_DataUpload_BatchHelper.createOppRecords(DDRList);
        
        //Opportunity Share - TO, TO roles + DDR Partner Account's Owner
        PCC_DataUpload_BatchHelper.oppSharing(oppList);
        
        //Add Opp Products even if inactive + make them Prod Win
        PCC_DataUpload_BatchHelper.createOLI(oppList,DDRList);
        
        //Create Opportunity Partner
        PCC_DataUpload_BatchHelper.createOppPartner(oppList);
        
        //Update the Opp to Prod Win
        resultMap = PCC_DataUpload_BatchHelper.updateOppStatus(oppList);
    }
    
    public void finish(Database.BatchableContext BC){
    }

}