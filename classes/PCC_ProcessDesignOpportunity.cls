/****************************************************************************************************************************************
* Class Name  : PCC_ProcessDesignOpportunity 
* Version     : 1.0 
* Created Date:  18-11-2024
* Modification Log :
* Developer                  Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Aravind                        18-11-2024         This contains InvocableMethod called from platform event to create design opportunity
                                                  in asyn mode.
*****************************************************************************************************************************************/
public with sharing class PCC_ProcessDesignOpportunity {
    /**
     * This method is used to reate design opportunity and related records.
     */
    @InvocableMethod(label='Process design reg opportunity' description='Process design opportunity')
    public static void processDesignOpportunity(List<Id> ddrIds) {
        List<Core_Design_Registration__c> lstApprovedDRs = [
            SELECT
                Id,
                Name,
                Core_Design_Registration_Nm__c,
                Core_End_Customer_Account_Id__c,
                Core_Product_Group_Nm__c,
                Core_Military_Aerospace_Gvrnmt_Use_Ind__c,
                Core_Product_Segment_Nm__c,
                Core_Product_Application_Nm__c,
                PCC_Design_Type__c,
                PCC_ODM_Board_Partner_Account__c,
                Core_Vertical_Market_Nm__c,
                Core_Manufacturing_Region_Cd__c,
                Core_Production_End_Dt__c,
                Core_First_Customer_Ship_Dt__c,
                Core_Intel_Platform_Nm__c,
                Core_Intel_Support_Status__c,
                Core_FPGA_Quote_Comments_Txt__c,
                Core_Design_Registration_Dsc__c,
                OwnerId,
                Core_Opportunity_Volume_Cnt__c,
                Core_Opportunity_Decision_Dt__c,
                Core_Opportunity_Id__c
            FROM Core_Design_Registration__c
            WHERE ID IN :ddrIds with USER_MODE
        ];
        String message = Core_DDR_Design_Handler_Utility.processDesignOpportunity(lstApprovedDRs, ddrIds);

        PCC_Deal_Approval_Process_Communication__e evt = new PCC_Deal_Approval_Process_Communication__e();
        evt.PCC_Record_ID__c = lstApprovedDRs[0].Id;
        evt.Design__c = true;
        evt.PCC_Error_Message__c =String.isNotBlank(message)? message : '';
        if (LabelConfiguration__mdt.getInstance('DDR_OLI_ASYNC').value__c == 'No') {
            evt.PCC_Object__c = 'Opportunity';
            evt.PCC_Type__c = (String.isNotBlank(message) && message != 'null') ? 'Failure' : 'Success';            
        }
        else {
            evt.PCC_Object__c = (String.isNotBlank(message) && message != 'null')? 'Opportunity' : 'OLI';
            evt.PCC_Type__c = (String.isNotBlank(message) && message != 'null')? 'Failure' : 'Design';    
        }
        Database.SaveResult result = EventBus.publish(evt);
    }
}