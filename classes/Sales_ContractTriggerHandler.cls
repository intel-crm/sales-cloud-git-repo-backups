/*********************************************************************************************************************
Class Name    : Sales_ContractTriggerHandler
Version       : 1.0
Created Date  : Mar 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Saba Husain           8-Mar-2021              Contract Trigger Handler 
* Mitesh Dedhia        20-Apr-2021              US949934 | Delete Renewal Opportunity
***********************************************************************************************************/
/*public class Sales_ContractTriggerHandler extends TriggerHandler {
    public override void afterUpdate() {
        if(isActive('Sales_contract_After_Update_Trigger')) {  
            Map<Id, Contract> oldContMap = (Map<Id, Contract>)Trigger.oldMap; 
            Map<Id, Contract> activatedContNewMap = new Map<Id, Contract>(); 
            //Set<id> ordIds = new Set<Id>(); --unused variable 
            List<Contract> renewalOppContractList = new List<Contract>();
            for(Contract con: (List<Contract>)Trigger.new){
                if((con.Status == 'Activated' && oldContMap.get(con.id).Status != con.Status) || (con.SBQQ__Order__c != null && oldContMap.get(con.id).SBQQ__Order__c != con.SBQQ__Order__c) || (con.StartDate != null && oldContMap.get(con.id).StartDate != con.StartDate) || (con.EndDate != null && oldContMap.get(con.id).EndDate != con.EndDate) || (oldContMap.get(con.id).Sales_Order_Shipped_Count__c != con.Sales_Order_Shipped_Count__c)){
                    activatedContNewMap.put(con.Id, con); 
                }
                if(con.SBQQ__RenewalOpportunity__c != null && con.SBQQ__RenewalForecast__c && con.Sales_Program__c == 'PSG'){
                    renewalOppContractList.add(con);    
                }
            }
            if(!activatedContNewMap.isEmpty()){
                Sales_ContractTriggerUtility.updateStartDateOnLicenses(activatedContNewMap,oldContMap);
            }
            if(renewalOppContractList != null && !renewalOppContractList.isEmpty() ){
               Sales_ContractTriggerUtility.deleteRenewalOpportunity(renewalOppContractList);
            }
        }
    }
    public override void beforeUpdate(){
        Map<Id, Contract> oldContMap = (Map<Id, Contract>)Trigger.oldMap; 
        List<Contract> contList = new List<Contract>();
		String statusMsg ;
        if(isActive('Sales_contract_before_update')) {
            for(Contract con: (List<Contract>)Trigger.new){
                if(con.Sales_Amended_Quote_Id__c !=null && (oldContMap.get(con.Id).Sales_Amended_Quote_Id__c != con.Sales_Amended_Quote_Id__c) && con.Sales_Program__c == 'PSG' && (con.Status == 'Activated' || con.Status == 'Amendment Completed')){
					contList.add(con);
                }
            }
            if(contList.size() > 0){
				Sales_ContractTriggerUtility.updateContractStatusForAmend(contList);
			}
            Sales_ContractTriggerUtility.updateRecordTypeForContract((List<Contract>)Trigger.new ,(Map<Id, Contract>)Trigger.oldMap);
        }  
    } 
}*/
@isTest
public class Sales_ContractTriggerHandler{

}