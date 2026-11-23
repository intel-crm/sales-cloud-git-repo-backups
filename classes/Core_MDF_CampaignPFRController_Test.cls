@isTest
public class Core_MDF_CampaignPFRController_Test {
	@isTest(SeeAllData=true)
    static void approveRejectProposalRejectTes2(){
          List<Campaign> cmpList = [select Id,Name from Campaign 
                                                where Id In (Select TargetObjectId from ProcessInstance where Status = 'Pending') AND 
                                                Core_MDF_Approval_Stage_nm__c = 'L1 Approval' limit 4];
        System.debug('cmpList-> '+cmpList);
        
        ProcessInstanceWorkitem piwitem1 = [select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: cmpList[0].Id limit 1];
        
        Core_MDF_CampaignPFR_Controller.loadCampRecord(cmpList[0].Id);
        Core_MDF_CampaignPFR_Controller.approveRejectProposal('Reject',cmpList[0].Id,'Rejected',piwitem1.Id);
        
         ProcessInstanceWorkitem piwitem2 = [select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: cmpList[1].Id limit 1];
        
        Core_MDF_CampaignPFR_Controller.loadCampRecord(cmpList[1].Id);
        Core_MDF_CampaignPFR_Controller.approveRejectProposal('Recall',cmpList[1].Id,'Recall',piwitem2.Id);
        
         ProcessInstanceWorkitem piwitem3 = [select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: cmpList[2].Id limit 1];
        
        Core_MDF_CampaignPFR_Controller.loadCampRecord(cmpList[2].Id);
        Core_MDF_CampaignPFR_Controller.approveRejectProposal('Recall',cmpList[2].Id,' ',piwitem3.Id);
        
         ProcessInstanceWorkitem piwitem4 = [select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: cmpList[3].Id limit 1];
        
        Core_MDF_CampaignPFR_Controller.loadCampRecord(cmpList[3].Id);
        Core_MDF_CampaignPFR_Controller.approveRejectProposal('Approve',cmpList[3].Id,'Approve',piwitem4.Id);
   }
}