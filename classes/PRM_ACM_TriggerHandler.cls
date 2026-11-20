/*********************************************************************************************************************
Modification Log : 
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
*Manjula(Tanzanite)       07/08/2020                Added changes for update of Partner Role and Tier in Marketing Profile Information Records
*                                                    Line# :47,101
*********************************************************************************************************************/
public class PRM_ACM_TriggerHandler extends TriggerHandler{
    
    public static boolean firstRun = true;
    public static boolean iPAFirstRun = true;
    public static boolean mPFirstRun = true;
    @TestVisible static Boolean executeTrigger = true;
    
//     public override void beforeInsert() {
//         if(executeTrigger)
//         {
//             if(isActive('Account_Channel_Membership_Switch') && PRM_ACM_Utility.firstRunBeforeInsert){ //Retrieved from Custom labels  
//                 if(Trigger.isInsert){
//                     PRM_ACM_Utility.firstRunBeforeInsert = false;
//                     PRM_ACM_Utility.duplicateRecordCheck(Trigger.new, Trigger.old);
//                     PRM_ACM_Utility.UpsertOPIDACM(Trigger.new, (Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap);//US759862,US766682 - UTKARSH
                    
//                 }
//             }
//         }
//     }
//     public override void beforeUpdate() {
//         if(isActive('Account_Channel_Membership_Switch_Update') && PRM_ACM_Utility.firstRunBeforeUpdate){//Retrieved from Custom labels            
//             if(Trigger.isUpdate){
//                 PRM_ACM_Utility.firstRunBeforeUpdate = false; 
//                 PRM_ACM_Utility.suppressEmail(Trigger.new);
//                 //PRM_ACM_Utility.checkPendingMembership((Map<Id,PRM_AccountChannelMembership__c>)Trigger.newMap);
//                 PRM_ACM_Utility.duplicateRecordCheck(Trigger.new, Trigger.old);
//                 PRM_ACM_Utility.UpsertOPIDACM(Trigger.new, (Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap);//US759862,US766682 - UTKARSH
//                 PRM_ACM_Utility.updateSuppressEmail(Trigger.new, (Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap);
//                  PRM_ACM_Utility.updateACMStatusChangeDate(Trigger.new, (Map<Id,PRM_AccountChannelMembership__c>)Trigger.oldMap);
//                 // ACM_BU_DeleteDuplicateChnlMembership.deleteDupChnlMembership((Map<Id,PRM_AccountChannelMembership__c>)Trigger.oldMap, (Map<Id,PRM_AccountChannelMembership__c>)Trigger.newMap);
//                 }
//         }
//                        // PRM_ACM_Utility.suppressEmail(Trigger.new);

//     }
//     public override void afterInsert() {
//         if(executeTrigger)
//         {
//             //system.debug('firstRun '+firstRun);
//             if(isActive('ACM_Insert_ERPM_Integration_Trigger') && firstRun) {
//                 //ContactERPMIntegrationStatusHandler.parseInputList((List<PRM_AccountChannelMembership__c>)Trigger.new);
//                 //system.debug('ACM after insert');
//                 if(Trigger.isInsert){
//                     if(System.isBatch())
//                     {
//                         PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending((List<PRM_AccountChannelMembership__c>)Trigger.new);
//                     }
//                     else
//                     {
//                         System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_AccountChannelMembership__c>)Trigger.new,  Trigger.new.getSObjectType()));
//                     }
//                     firstRun = false;
//                 }
//             }
//             if(isActive('PMP_Company_Tier_Switch_Update')){
//                 if(Trigger.isInsert){
//                     PMP_AccountBenefitPartnerUtility.UpdatePartnerWhenTierIsUpdated((List<PRM_AccountChannelMembership__c>)Trigger.new);  
//                     mPFirstRun = false;
//                 }
//             }
            
//             if(isActive('ACM_After_Insert')){
//                 if(trigger.IsInsert && PRM_ACM_Utility.firstRunAfterInsert){
//                     //System.debug('enter after inert');
//                     PRM_ACM_Utility.firstRunAfterInsert = false;
//                     PRM_ACM_Utility.UpsertOPIDACM(Trigger.new, (Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap);//US759862,US766682 - UTKARSH
//                     //PRM_ACM_Utility.UpdateLocationAccACM(Trigger.new); //Utkarsh
//                     PRM_ACM_Utility.AfterOperationsOnACM(Trigger.new,(Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap); //UTKARSH                    
//                 }
//             } 
//             if(isActive('ACM_OPID_Recommendation') && PRM_ACM_Utility.isOpidrecommendationexecuted==true){
//                 if(Trigger.isInsert){
//                     PRM_ACM_Utility.isOpidrecommendationexecuted=false;
//                     PRM_ACM_Utility.CreateOPIDRecomndtn(Trigger.new,(Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap); //TWC729-1292-Javid   
//                 }
//             }            
//         }
//     }
    
//     public override void afterUpdate() {
//         //system.debug('firstRun '+firstRun);
//         if(isActive('ACM_Update_ERPM_Integration_Trigger') && firstRun) {
//             //ContactERPMIntegrationStatusHandler.parseInputList((List<PRM_AccountChannelMembership__c>)Trigger.new);
//             //system.debug('ACM after update');
//             if(Trigger.isUpdate){
//                 if(System.isBatch())
//                 {
//                     PRM_SalesCloudAccountIntStatus_Handler.setAccountIPAIntegrationStatusToPending((List<PRM_AccountChannelMembership__c>)Trigger.new);
//                 }
//                 else
//                 {
//                     System.enqueueJob(new ContactERPMIntegrationStatusHandler((List<PRM_AccountChannelMembership__c>)Trigger.new,  Trigger.new.getSObjectType()));
//                 }
//                 firstRun = false;
//             }
//         }
        
//         if(isActive('ACM_After_Update')){
//             if(trigger.Isupdate && (PRM_ACM_Utility.firstRun || PRM_ACM_Utility.secondRun)  ){
//                 if(Trigger.isUpdate){
//                     if(PRM_ACM_Utility.firstRun==false) 
//                         PRM_ACM_Utility.secondrun=false;
//                     PRM_ACM_Utility.firstRun = false;
//                     if(PRM_ACM_Utility.secondrun==true){                    
//                     PRM_ACM_Utility.CreateOPIDRecomndtn(Trigger.new,(Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap); //TWC729-1292-Javid
//                                         PRM_ACM_Utility.UpsertOPIDACM(Trigger.new, (Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap);//US759862,US766682 - UTKARSH               
// }
//                     PRM_ACM_Utility.UpdateLocationAccACM(Trigger.new,(Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap); //Utkarsh
//                     //PRM_ACM_Utility.profileResponseOnBenefitUpdate(Trigger.new, (Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap);
//                     PRM_ACM_Utility.AfterOperationsOnACM(Trigger.new,(Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap);//UTKARSH
//                 }
//             }
//         }
//         if(isActive('ACM_OPID_Recommendation') && PRM_ACM_Utility.isOpidrecommendationexecuted==true){
//             if(Trigger.isUpdate){
//                 PRM_ACM_Utility.isOpidrecommendationexecuted=false;
//                 PRM_ACM_Utility.CreateOPIDRecomndtn(Trigger.new,(Map<Id,PRM_AccountChannelMembership__c>) Trigger.oldMap); //TWC729-1292-Javid   
//             }
//         } 
//         if(isActive('PMP_Company_Tier_Switch_Update') && mPFirstRun){
//             if(Trigger.isUpdate){
//                 PMP_AccountBenefitPartnerUtility.UpdatePartnerWhenTierIsUpdated((List<PRM_AccountChannelMembership__c>)Trigger.new);  
//                 mPFirstRun =false;
//             }
//         }
    
//     PRM_ACM_Utility.createTrackerMilestonesForMembershipUpdate((List<PRM_AccountChannelMembership__c>)trigger.new,(Map<Id,PRM_AccountChannelMembership__c>) trigger.oldMap);
        
//     }
}