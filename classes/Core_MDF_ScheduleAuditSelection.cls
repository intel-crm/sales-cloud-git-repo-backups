/******************************************************************************************************
* Class Name  : Core_MDF_Schedule_PaymentRun  
* Version     : 1.0 
* Created Date: 01-22-2019
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - AD      01/22/2019          It is a schedulable class to run batch                                      
*******************************************************************************************************/
public without sharing class Core_MDF_ScheduleAuditSelection implements Schedulable {
    
    //To hold payment run object
    public List<PartnerFundClaim> claims;
    
    //Constructor  - To assign payment run instance
    public Core_MDF_ScheduleAuditSelection(List<PartnerFundClaim> claimLst){
        this.claims = claimLst;
    }
    
    public void execute(SchedulableContext sc) {
        //Call the batch class to be scheduled
        /* commented as a part of Core_MDF_CCP_Claim_Window__mdt Optimization
        Core_MDF_AuditSelectionHelper_BatchTest auditbatch = new Core_MDF_AuditSelectionHelper_BatchTest(claims);
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(auditbatch,500);
        */
    }
}