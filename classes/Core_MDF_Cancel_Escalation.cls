/***************************************************************************************************** 
Class Name   :    Core_MDF_Cancel_Escalation
Description  :    To release blocked amount of Escalation cancelled from Cancel Button
Added By     :    Ramapriya - Weezer
Created Date :    02/12/2024
******************************************************************************************************/
public class Core_MDF_Cancel_Escalation {

    /*Method to update Activity amount when Escalation is cancelled from Cancel Button*/
    @InvocableMethod
    public static void cancelEscalation(List<EscalationWrapper> escalationWrapper){
        set<Id> pfrIdset = new set<Id>();
        //'Core_MDF_BudgetReversal_BudgetTypes' contains MDF,MDF+,Retail MDF, Account Plan, Proposal I MDF And Proposal II MDF Budget Types
		List<String> MDFBudgetTypes = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_BudgetReversal_BudgetTypes').split(';');        
        if(EscalationWrapper!= null && EscalationWrapper.size() > 0){
        	string EscBudgetType = EscalationWrapper[0].BudgetType;
        	pfrIdset.addall(EscalationWrapper[0].pfrId);
        
            //Update Amount only when Budget Type is MDF,MDF+,Retail MDF, Account Plan, Proposal I MDF, Proposal II MDF
            if(MDFBudgetTypes.contains(EscBudgetType) ){
                Core_MDF_PFR_PlatformEventHandler.updateActivityAmount(pfrIdset);
            }
        }
    }
    
    /*Method to give required parameters to EscalationWrapper from Core_MDF_CancelEscalation flow*/
    public class EscalationWrapper{
        @InvocableVariable (Label='PFR Ids' Required=True) public List<Id> pfrId;//Activity ID of the corresponding Escalation
        @InvocableVariable (Label='Budget Types' Required=True) public string BudgetType;
    }
}