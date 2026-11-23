/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 12-19-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Core_AccountPlanRecordPrintController {
    public AccountPlan accountPlan {get;set;}
    public String formattedStartDate { get; set; }
    public String formattedEndDate{ get; set; }
    
    public Core_AccountPlanRecordPrintController(ApexPages.StandardController controller){
       Id recordID = controller.getID();
      accountPlan = [SELECT Id,name,Account.Name, Owner.Name,AccountVision,
                    Status,Notes,RelationshipStrengths,RelationshipOpportunities,
                    RelationshipWeaknesses,RelationshipThreats,AccountStrategicPriorities,
                    AccountChallenges,AccountPrfmIndicators,AccountIndustryTrends,AccountCompetitiveStrengths,
                    AccountCmptvWeaknesses,AccountCompetitors from AccountPlan where id =:recordID];
      /*if(true) 
            formattedStartDate = accountPlan.StartDate.format();
        if(accountPlan.EndDate != null)
            formattedEndDate = accountPlan.EndDate.format(); */
            
    }   
     
}