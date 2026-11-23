/**************************************************************************************
Apex Class Name : PMP_PartnerAccGroupMemberTriggerHandler
Version     : 1.0
Created Date: 24th June, 2019
Description : Trigger handler for PMP_Account_Grp_MemberTrigger
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Sandip                  24/06/2019               Original Version
* Anupam Agarwal        12/08/2019         Added toggleIsPAGMember method call in the afterInsert and afterUpdate methods
to set the isPAGMember check on the Account
* Anupam Agarwal        12/08/2019         Added beforeUpdate and beforeInsert methods  to handle the MDA indicator and
duplicate records related validations.
* Anand TB                   09/04/2020                Added changes for setting Account.PRM_IPA_Integration_Status__c to
*                                                      pending on after insert and after update
Jambert          25-10-2021             Sending email for Admin Group If All the CAG records is Inactivated
********************************************************************************************************************************/
public class Core_Acct_Grp_Mbr_TriggerHandler extends TriggerHandler {
    
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static boolean iPAFirstRun = true;
    //public static String ipaRefresh = System.label.PRM_IPARefresh;//IPA 2.0 
    public override void afterInsert(){
        //Start of Changes - Accenture - IPA
        if(isActive('isPAGMTrigger')) {
            PMP_Acct_Grp_Mbr_TriggerHandler.toggleIsPAGMember(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
            //End of Changes - Accenture - IPA
        }
        Map<Id, Core_Account_Group_Member__c> newMap = (Map<Id, Core_Account_Group_Member__c>) Trigger.newMap;
        PMP_Acct_Grp_Mbr_TriggerHandler.afterMethod(Trigger.old, Trigger.new);
     // Commenting the below line since it is not used as part of WW06-2022
    PMP_Acct_Grp_Mbr_TriggerHandler.PopulateLegalAgreeOnOPID(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
  //  Added by Javid as part of TWC729-1172
        if(isActive('PRM_OPID_RollUpRollDown_Cag') && PMP_Acct_Grp_Mbr_TriggerHandler.isFirstRunRollUpDown ){
            PMP_Acct_Grp_Mbr_TriggerHandler.isFirstRunRollUpDown = false;
            //IPA 2.0 TWC729-7917 : profile response roll up/down START
            /*if(ipaRefresh!='TRUE'|| Test.isRunningTest()){
                PMP_Acct_Grp_Mbr_TriggerHandler.RollUpLocFlagToOPID(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
            }else{*/ // IPA Refresh - switch removal
                PMP_Acct_Grp_Mbr_TriggerHandler.PRM_IPAR_rollUpDownIPAMembership(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
            //}
            //IPA 2.0 TWC729-7917 : profile response roll up/down END
        }
        //Added by Hanuma Pantham - US1053946
  /*IPA2.0: US-TWC729-7976*/
        /*if(mapFunctionalityNameTriggerExecution.containsKey('OPID_Mem_Handler') && mapFunctionalityNameTriggerExecution.get('OPID_Mem_Handler').Core_Active__c){
               PSS_SolutionOPIDRollup.populateOPIDOnSolution(Trigger.new,null,'insert');
           }*/
        // Deactivated the switch as part of OPID Restructure - Sathish
       if(mapFunctionalityNameTriggerExecution.containsKey('PAG_mem_handler') &&
        mapFunctionalityNameTriggerExecution.get('PAG_mem_handler').Core_Active__c){
        PMP_PAG_mem_handler.onGroupMemAfterInsert(Trigger.new, newMap);
        //Added by Hanuma Pantham - US1053946
        //PSS_SolutionOPIDRollup.populateOPIDOnSolution(null,Trigger.new);
        } 
        //Set IPA integration status to pending - IPA integration
        //Added by Anand TB - US607581
        if(isActive('OPID_Insert_IPA_Integration_Trigger') && iPAFirstRun) {
            //system.enqueueJob(new PRM_SalesCloudAccountIntStatus_Handler((List<Core_Account_Group_Member__c>)Trigger.new, null, null));
            PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPendingOpId( (List<Core_Account_Group_Member__c>)Trigger.new, new Set<Id>());
            iPAFirstRun = false;
        }
        PMP_Acct_Grp_Mbr_TriggerHandler.populateOnePartnerIdOnIntelAccount(Trigger.new, null);
    PMP_Acct_Grp_Mbr_TriggerHandler.createTrackerMilestonesForOPIDUpdates(trigger.new, null);
    }
    public override void afterUpdate(){
       //TWC729-210  Alert on the 1PID record in SFDC when all accounts under it are inactivated and also send email to IPA and MP Admins
        PRM_EmailUtility.deactivationEmailofLastCAGRecords(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
        //Start of Changes - Accenture - IPA
        if(isActive('isPAGMTrigger')) {
            PMP_Acct_Grp_Mbr_TriggerHandler.toggleIsPAGMember(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
            //End of Changes - Accenture - IPA
      // Commenting the below line since it is not used as part of WW06-2022
            PMP_Acct_Grp_Mbr_TriggerHandler.PopulateLegalAgreeOnOPID(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
        }     
  // Added by Javid as part of TWC729-1172
        if(isActive('PRM_OPID_RollUpRollDown_Cag') && PMP_Acct_Grp_Mbr_TriggerHandler.isFirstUpdateRunRollUpDown ){
            PMP_Acct_Grp_Mbr_TriggerHandler.isFirstUpdateRunRollUpDown = false;
            //IPA 2.0 TWC729-7917 : profile response roll up/down START
            /*if(ipaRefresh!='TRUE'|| Test.isRunningTest()){
                PMP_Acct_Grp_Mbr_TriggerHandler.RollUpLocFlagToOPID(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
            }else{*/ // IPA Refresh - switch removal
                PMP_Acct_Grp_Mbr_TriggerHandler.PRM_IPAR_rollUpDownIPAMembership(Trigger.new,(Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
            //}
            //IPA 2.0 TWC729-7917 : profile response roll up/down END
        }
        Map<Id, Core_Account_Group_Member__c> oldMap = (Map<Id, Core_Account_Group_Member__c>) Trigger.oldMap;
        Map<Id, Core_Account_Group_Member__c> newMap = (Map<Id, Core_Account_Group_Member__c>) Trigger.newMap;
        
        PMP_Acct_Grp_Mbr_TriggerHandler.afterMethod(Trigger.old, Trigger.new);
        if(mapFunctionalityNameTriggerExecution.containsKey('PAG_mem_handler') &&
           mapFunctionalityNameTriggerExecution.get('PAG_mem_handler').Core_Active__c){
               PMP_PAG_mem_handler.onGroupMemAfterUpdate(Trigger.new, oldMap, newMap);
               //Added by Hanuma Pantham - US1053946
               //PSS_SolutionOPIDRollup.populateOPIDOnSolution(Trigger.old,Trigger.new);
           }
        //Added by Hanuma Pantham - US1053946
  /*IPA2.0: US-TWC729-7976*/
       /* if(mapFunctionalityNameTriggerExecution.containsKey('OPID_Mem_Handler') && mapFunctionalityNameTriggerExecution.get('OPID_Mem_Handler').Core_Active__c){
               PSS_SolutionOPIDRollup.populateOPIDOnSolution(Trigger.new,oldMap,'update');
               
           }*/
        //Set IPA integration status to pending - IPA integration
        //Added by Anand TB - US607581
        if(isActive('OPID_Update_IPA_Integration_Trigger') && iPAFirstRun) {
            boolean isUpdated = false;
            set<Id> oldAcctIds = new set<Id>();
            for(Core_Account_Group_Member__c newAgm : (List<Core_Account_Group_Member__c>)Trigger.new) {
                Core_Account_Group_Member__c oldAgm = (Core_Account_Group_Member__c)Trigger.oldMap.get(newAgm.Id);
                if(newAgm.Core_Inactive_Ind__c != oldAgm.Core_Inactive_Ind__c 
                   || newAgm.Core_Intel_Account_Id__c != oldAgm.Core_Intel_Account_Id__c) {
                       isUpdated = true;
                       oldAcctIds.add(oldAgm.Core_Intel_Account_Id__c);
                       break;
                   }
                
            }
            if(isUpdated) {
                PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPendingOpId( (List<Core_Account_Group_Member__c>)Trigger.new, oldAcctIds);
                iPAFirstRun = false;
            }
        }
  
        PMP_Acct_Grp_Mbr_TriggerHandler.populateOnePartnerIdOnIntelAccount(Trigger.new, (Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
    PMP_Acct_Grp_Mbr_TriggerHandler.createTrackerMilestonesForOPIDUpdates(Trigger.new, (Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
    }
    /*public override void beforeInsert(){
PMP_PartnerAccGroupMemHandler.beforeMethod(Trigger.old, Trigger.new);
}

public override void beforeUpdate(){
PMP_Acct_Grp_Mbr_TriggerHandler.beforeMethod(Trigger.old, Trigger.new);
}  */
    
    public override void beforeDelete(){
        //Map<Id, Core_Account_Group_Member__c> oldMap = (Map<Id, Core_Account_Group_Member__c>) Trigger.oldMap;
        //PMP_Acct_Grp_Mbr_TriggerHandler.beforeMethod(Trigger.old, Trigger.new);
        //
        //  if(mapFunctionalityNameTriggerExecution.containsKey('PAG_mem_handler') &&
        //    mapFunctionalityNameTriggerExecution.get('PAG_mem_handler').Core_Active__c){
        //      //PMP_PAG_mem_handler.onGroupMemBeforeDelete(Trigger.old, oldMap);
        //}
        PMP_Acct_Grp_Mbr_TriggerHandler.removeOnePartIdFromIntelAccOnDeletion(Trigger.old);
        //Added by Hanuma Pantham - US1053946
  /*IPA2.0: US-TWC729-7976*/
       /* if(mapFunctionalityNameTriggerExecution.containsKey('OPID_Mem_Handler') &&
           mapFunctionalityNameTriggerExecution.get('OPID_Mem_Handler').Core_Active__c){
               PSS_SolutionOPIDRollup.removeOPIDFromSolutionOnDeletion(Trigger.old);
           }*/
    }
    
    
    //Start of Changes - Accenture - IPA
    public override void beforeUpdate() {
        if(isActive('isPAGMTrigger')) { //Retrieved from Custom labels
            PMP_Acct_Grp_Mbr_TriggerHandler.checkMDAIndicator(Trigger.new, (Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
        }
        //Start of Changes by Ankit Thakur on 28th August in order to merge code for NPPDEV and DEVINT- Accenture - IPA
        PMP_Acct_Grp_Mbr_TriggerHandler.beforeMethod(Trigger.old, Trigger.new);
        //End of Changes by Ankit Thakur on 28th August in order to merge code for NPPDEV and DEVINT- Accenture - IPA
    }
    
    public override void beforeInsert() {
        if(isActive('isPAGMTrigger')) { //Retrieved from Custom labels
            PMP_Acct_Grp_Mbr_TriggerHandler.checkMDAIndicator(Trigger.new, (Map<Id, Core_Account_Group_Member__c>)Trigger.oldMap);
        }
        //PMP_Acct_Grp_Mbr_TriggerHandler.populateOnePartnerIdOnAccount(Trigger.new);
        //TWC729-3627 :Update Intel Record type field for Inactive_Account.      
        for(Core_Account_Group_Member__c coreAct:  (List<Core_Account_Group_Member__c>)Trigger.new){
            if(coreAct != null){
               coreAct.Intel_Record_Type_Text__c = coreAct.Core_Intel_Account_Id__r.RecordType.DeveloperName;
            } 
        } 
    }
    //End of Changes - Accenture - IPA
}