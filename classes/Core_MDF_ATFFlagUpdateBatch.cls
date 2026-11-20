/****************************************************************************************************************************************
* Class Name        : Core_MDF_ATFFlagUpdateBatch
* Test Class Name   :
* Created Date      : 4/21/2022
* Modification Log
* Created By        : Hemapriyadharshini.k
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture- Weezer         4/22/2022         Batch class to update ATF Flag for past dated activities in pending review/pending approval status
*****************************************************************************************************************************************/
global class Core_MDF_ATFFlagUpdateBatch implements Database.Batchable<sObject>,Database.stateful{
    public String pfrActivityClosureAuto;
    Public string pfrAutoClosureType;
    public String pfrActivityClose;
    public String pfrPendingApproval;
    public String pfrPendingReview;
    public Date pfrCurrentDate;
    Public List<Database.SaveResult> srList = new List<Database.SaveResult>();
    
    public List<String> pfrListIDs = new List<String>();
    
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        pfrCurrentDate = system.today();
        pfrPendingApproval = System.Label.Core_MDF_Status_Pending_Approval_Nm;
        pfrPendingReview = System.Label.Core_MDF_PFR_Status_PendingReview;
        String createdDate = System.Label.Core_MDF_PFRCreatedDate;
        Datetime createdDatePFR = datetime.valueOf(createdDate);
        String GTMProgram = System.Label.Core_MDF_Co_GTM_program_name;
        
        String pfrList = 'SELECT Id,Core_MDF_Budget_Type_nm__c,Core_MDF_Start_Date__c,Core_MDF_ATF_Flag_nm__c,Core_MDF_Fund_Request_Status__c'+
            ' FROM PartnerFundRequest'+
            ' WHERE ((Core_MDF_Fund_Request_Status__c=:pfrPendingReview AND Core_MDF_Start_Date__c<:pfrCurrentDate AND Core_MDF_ATF_Flag_nm__c excludes (\'Missed Internal Approval ATF\'))'+
            ' OR (Core_MDF_Fund_Request_Status__c=:pfrPendingApproval AND Core_MDF_Start_Date__c <:pfrCurrentDate AND Core_MDF_ATF_Flag_nm__c excludes (\'Missed External Approval ATF\')))'+
            ' AND CreatedDate>= :createdDatePFR AND Core_MDF_Program__c != :GTMProgram';
        
        
        return Database.getQueryLocator(pfrList);
    }
    
    global void execute(Database.BatchableContext bc, List<PartnerFundRequest> pfrList){
        String missedInternalApproval = System.Label.Core_MDF_Missed_Internal_Approval;
        String missedExternalApproval = System.Label.Core_MDF_Missed_External_Approval;
        List<PartnerFundRequest> pfrATFList = new List<PartnerFundRequest>();
        try {
            if(pfrList != null && !pfrList.isEmpty()){
                for(PartnerFundRequest pfrActivity : pfrList){
                    PartnerFundRequest pfrToBeUpdated = new PartnerFundRequest();
                    pfrToBeUpdated.Id = pfrActivity.Id;
                    //Avoid Deeply Nested IF Statements
                    if(pfrActivity.Core_MDF_Start_Date__c < System.today() && pfrActivity.Core_MDF_Fund_Request_Status__c == pfrPendingReview){
                        pfrToBeUpdated.Core_MDF_ATF_Flag_nm__c = String.isBlank(pfrActivity.Core_MDF_ATF_Flag_nm__c) 
                            ? missedInternalApproval 
                            : pfrActivity.Core_MDF_ATF_Flag_nm__c + ';' + missedInternalApproval;
                        pfrATFList.add(pfrToBeUpdated);
                    }
                    else if(pfrActivity.Core_MDF_Start_Date__c < System.today() && pfrActivity.Core_MDF_Fund_Request_Status__c == pfrPendingApproval){
                        pfrToBeUpdated.Core_MDF_ATF_Flag_nm__c = String.isBlank(pfrActivity.Core_MDF_ATF_Flag_nm__c) 
                            ? missedExternalApproval 
                            : pfrActivity.Core_MDF_ATF_Flag_nm__c + ';' + missedExternalApproval;
                        pfrATFList.add(pfrToBeUpdated);
                    }
                }
                //Avoid Deeply Nested IF Statements
                if(!pfrATFList.isEmpty()){
                    Database.SaveResult[] srList = Database.update(pfrATFList,false);
                    // Iterate through each returned result
                    for (Database.SaveResult sr : srList) {
                    // Only process failed operations
                        if (!sr.isSuccess()) {
                            List<String> errorMessages = new List<String>();
                            for(Database.Error err : sr.getErrors()) {
                                errorMessages.add(err.getStatusCode() + ': ' + err.getMessage());
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e); throw e;
        }
    }
    
    global void finish(Database.BatchableContext bc){
    }
}