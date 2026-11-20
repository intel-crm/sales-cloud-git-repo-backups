/***********************************************************************************************************************************************
Apex Class Name:  PRM_PointsRedeemBenAssignUtility
Version     : 1.0 
Created Date: 12 July 2022
Function    : Utility Class for PRM_PointsRedeemBenAssignBatch

Modification Log :
* Developer                     Date                Description                                             TestClass
* -----------------------------------------------------------------------------------------------------------------------------------------------
* Tanya Rajesh                  12/07/2022           Utility Class for PRM_PointsRedeemBenAssignBatch       PRM_PointsRedeemBenAssignBatch_Test
*************************************************************************************************************************************************/
public with sharing class PRM_PointsRedeemBenAssignUtility {
    public static Final String ORIGIN  = 'PRM_PointsRedeemBenAssignUtility';
    public static Final String SEVERITY  = 'Critical';
    public static Final String PROJECT  = 'IPA';
    public static Final String ERRORMESSAGE  = 'Too many DML rows';
    public static set<id> eligibleAccountIds = new set<id>();
    public static set<id> ineligibleAccountIds = new set<id>();
    public static Set<Id> listAccId = new Set<Id>();
    public static String pointsRedeemBenefitName = LabelConfiguration__mdt.getInstance('Points_Redemption').MasterLabel;
    public static String partnerRoles = LabelConfiguration__mdt.getInstance('Points_Redemption').Value__c;
    public static List<String> eligiblePartnerRoles = partnerRoles.split(';');
    public static List<PRM_PartnerBenefit__c> pointsRedeembenefit = [
        SELECT 
        id, 
        name 
        FROM PRM_PartnerBenefit__c 
        WHERE name =:pointsRedeemBenefitName LIMIT 1];
    public static List<Core_Entitlement__c> pointsRedeemEntit = [
        SELECT id, 
        name 
        FROM Core_Entitlement__c 
        WHERE name =: System.Label.PRM_PointsRedeem LIMIT 1];
    
    //Assigning Benefits and Entitlements
    public static void pointsBenefitEligibility(List<PRM_AccountChannelMembership__c> listACMs){
        try{
            Map<id, String> mapAccIDToProfileResponse = new Map<id, String>();
            //List<PRM_Profile_Responses__c> listProfResponses = new List<PRM_Profile_Responses__c>();
            List<PRM_AccountBenefitAssociation__c> benefitListtoUpsert = new List<PRM_AccountBenefitAssociation__c>();
            Map<id, PRM_AccountBenefitAssociation__c> mapAccIDtoPointsBenefitDetail = new Map<id, PRM_AccountBenefitAssociation__c>();

            if(listACMs.size()>0 && !listACMs.isEmpty()){
                for(PRM_AccountChannelMembership__c acm : listACMs){
                    listAccId.add(acm.PRM_Account_Id__c);
                }
            }
            if(listAccId.size()>0 && !listAccId.isEmpty()){
                for(PRM_Profile_Responses__c profRes : [
                SELECT 
                id, 
                PRM_Account_Id__c, 
                PRM_Question_Display_Text__c,
                PRM_Response_Txt__c 
                FROM PRM_Profile_Responses__c 
                WHERE PRM_Account_Id__c in: listAccId 
                AND PRM_Profile_Questions_Id__r.PRM_Question_Cd__c = 'PRM_Point_Not_Eligible'
                ORDER BY createdDate desc]
                ){
                    //add latest profileresponse
                    if(!mapAccIDToProfileResponse.containsKey(profRes.PRM_Account_Id__c)){
                        mapAccIDToProfileResponse.put(profRes.PRM_Account_Id__c, profRes.PRM_Response_Txt__c);            
                    }
                }
            }
            for(PRM_AccountChannelMembership__c acm : listACMs){
                if(acm.PRM_Status_Nm__c == System.label.PRM_Status_Approved){
                    if(mapAccIDToProfileResponse.containsKey(acm.PRM_Account_Id__c)){
                        if(mapAccIDToProfileResponse.get(acm.PRM_Account_Id__c) == 'false'){
                            if(eligiblePartnerRoles.contains(acm.PRM_Partner_Role__c)){
                                eligibleAccountIds.add(acm.PRM_Account_Id__c);
                            }else{
                                ineligibleAccountIds.add(acm.PRM_Account_Id__c);
                            }
                        }
                        else{
                            ineligibleAccountIds.add(acm.PRM_Account_Id__c);
                        }  
                    }else{
                        if(eligiblePartnerRoles.contains(acm.PRM_Partner_Role__c)){
                            eligibleAccountIds.add(acm.PRM_Account_Id__c);
                        }else{
                            ineligibleAccountIds.add(acm.PRM_Account_Id__c);
                        }
                    }
                }else{
                    ineligibleAccountIds.add(acm.PRM_Account_Id__c);
                }
            }

            for(id accId : eligibleAccountIds){
                if(ineligibleAccountIds.contains(accId)){
                    ineligibleAccountIds.remove(accId);
                }
            }
            if(listAccId.size()>0 && !listAccId.isEmpty()){
                for(PRM_AccountBenefitAssociation__c benefit : [
                    SELECT 
                    Id, 
                    Name,
                    PRM_Partner_Benefit_Id__c,
                    PRM_Account_Id__c,
                    PRM_Partner_Benefit_Id__r.Name,
                    PRM_Status_Nm__c,
                    PRM_Account_Id__r.Name 
                    FROM PRM_AccountBenefitAssociation__c 
                    WHERE PRM_Account_Id__c IN :listAccId AND PRM_Partner_Benefit_Id__r.Name =: pointsRedeemBenefitName]
                ){
                    mapAccIDtoPointsBenefitDetail.put(benefit.PRM_Account_Id__c, benefit);
                }
            }
            //Benefit Assignment
            for(id accIds : listAccId){
                if(eligibleAccountIds.contains(accIds) && mapAccIDtoPointsBenefitDetail.containsKey(accIds) && mapAccIDtoPointsBenefitDetail.get(accIds).PRM_Status_Nm__c != System.Label.PRM_Status_Active){
                    mapAccIDtoPointsBenefitDetail.get(accIds).PRM_Status_Nm__c = System.Label.PRM_Status_Active;
                    mapAccIDtoPointsBenefitDetail.get(accIds).PRM_Status_Reason_Txt__c = 'Activated as account is eligible';//TWC729-8089 : Adding reason text : NJ
                    benefitListtoUpsert.add(mapAccIDtoPointsBenefitDetail.get(accIds));
                }
                else if(eligibleAccountIds.contains(accIds) && !mapAccIDtoPointsBenefitDetail.containsKey(accIds)){
                    PRM_AccountBenefitAssociation__c newAba = new PRM_AccountBenefitAssociation__c();
                    newAba.PRM_Partner_Benefit_Id__c = pointsRedeembenefit[0].id;
                    newAba.PRM_Status_Nm__c = System.Label.PRM_Status_Active;
                    newAba.PRM_Status_Reason_Txt__c='Activated as account is eligible';//TWC729-8089 : Adding reason text : NJ
                    newAba.PRM_Account_Id__c = accIds;
                    newAba.PRM_Source__c = System.Label.PRM_Source_BenefitMatrix;
                    benefitListtoUpsert.add(newAba);
                }
                else if(ineligibleAccountIds.contains(accIds) && mapAccIDtoPointsBenefitDetail.containsKey(accIds) && mapAccIDtoPointsBenefitDetail.get(accIds).PRM_Status_Nm__c == System.Label.PRM_Status_Active){
                    mapAccIDtoPointsBenefitDetail.get(accIds).PRM_Status_Nm__c = System.label.PRM_Status_Inactive;
                    mapAccIDtoPointsBenefitDetail.get(accIds).PRM_Status_Reason_Txt__c = 'Deactivated with PRM_PointsRedeemBenAssignBatch';
                    benefitListtoUpsert.add(mapAccIDtoPointsBenefitDetail.get(accIds));
                }
            }
            if(benefitListtoUpsert.size()>0 && !benefitListtoUpsert.isEmpty()){
                upsertData(benefitListtoUpsert);
            }
    
            //Batch Entitlement record Creation for related Eligible Contacts
            Set<id> allEligiblelocAccountIDAssociatedToOPID = new Set<id>();
            Set<id> allIneligiblelocAccountIDAssociatedToOPID = new Set<id>();
            map<id,id> accountAssociatedToOPIDList = new map<id,id>();             
            Set<id> eligibleContIds = new Set<id>();
            Set<id> ineligibleContIds = new Set<id>();
            Set<id> allContIds = new Set<id>();
            List<PRM_Batch_Entitlement__c> bacthentListToUpsert = new List<PRM_Batch_Entitlement__c>();

            if(listAccId.size()>0 && !listAccId.isEmpty()){
                for(Core_Account_Group_Member__c Cagm: [
                    SELECT 
                    id,
                    name,
                    Core_Inactive_Ind__c,
                    Core_Partner_Account_Id__c,
                    Core_Intel_Account_Id__c 
                    FROM Core_Account_Group_Member__c 
                    WHERE Core_Partner_Account_Id__c IN: listAccId AND Core_Inactive_Ind__c = false]
                ){
                    accountAssociatedToOPIDList.put(Cagm.Core_Intel_Account_Id__c,Cagm.Core_Partner_Account_Id__c);
                }
            }
            if(!accountAssociatedToOPIDList.isEmpty()){
                for(PRM_AccountChannelMembership__c acm : [
                    SELECT id, 
                    PRM_Account_Id__c,
                    PRM_Account_Id__r.Core_IPA_Partner_Role__c,
                    PRM_Account_Id__r.Core_Covered_Account__c, 
                    PRM_Channel_Program_Id__c, 
                    PRM_Channel_Program_Id__r.Name, 
                    PRM_Channel_Program_Level_Id__c,
                    PRM_Channel_Program_Level_Id__r.Name,
                    PRM_Status_Nm__c,PRM_Partner_Role__c 
                    FROM PRM_AccountChannelMembership__c 
                    WHERE PRM_Account_Id__c in: accountAssociatedToOPIDList.keySet() 
                    AND PRM_Status_Nm__c = 'Approved']
                ){
                    if(eligibleAccountIds.contains(accountAssociatedToOPIDList.get(acm.PRM_Account_Id__c))){
                        allEligiblelocAccountIDAssociatedToOPID.add(acm.PRM_Account_Id__c);
                    }
                    else if(ineligibleAccountIds.contains(accountAssociatedToOPIDList.get(acm.PRM_Account_Id__c))){
                        allIneligiblelocAccountIDAssociatedToOPID.add(acm.PRM_Account_Id__c);
                    }
                }
            }
      Set<Id> relationshipIds = new Set<Id>();
            List<PRM_VXEnttlmntMatrix__c> entitlementMatrixlist = new List<PRM_VXEnttlmntMatrix__c>([
                Select id, 
                PRM_Entitlement_Id__c,
                PRM_Entitlement_Id__r.Name, 
                PRM_Contact_Relationship_Id__c,
                PRM_Contact_Relationship_Id__r.Name, 
                PRM_IsActive_Ind__c, 
                PRM_Partner_Benefit_Id__c,
                PRM_Approval_Type_Nm__c,
                PRM_IPA_Partner_Role_Nm__c 
                from PRM_VXEnttlmntMatrix__c 
                where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType 
                    AND PRM_Partner_Benefit_Id__c =: pointsRedeembenefit[0].id 
                    AND PRM_IsActive_Ind__c = True]);
            for(PRM_VXEnttlmntMatrix__c vxMatrix : entitlementMatrixlist){
                relationshipIds.add(vxMatrix.PRM_Contact_Relationship_Id__c);
            }
            
            if(!accountAssociatedToOPIDList.isEmpty()){
                for(PRM_Account_Contact_Relationship__c acr : [
                    SELECT 
                    id,
                    PRM_Account_Id__r.Name,
                    PRM_Relationship_Id__c,
                    PRM_Account_Id__r.Core_IPA_Partner_Role__c,
                    PRM_Account_Id__c, 
                    PRM_Contact_Id__c,
                    PRM_Contact_Id__r.Core_IPA_PartnerRole__c,
                    PRM_Partner_Role__c,
                    PRM_Contact_Id__r.Name,
                    PRM_Status_Nm__c
                    FROM PRM_Account_Contact_Relationship__c 
                    WHERE PRM_Account_Id__c in :accountAssociatedToOPIDList.keySet() 
                    AND  PRM_InActive_Ind__c = false 
                    AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status
                    AND PRM_Relationship_Id__c in: relationshipIds]
                ){
                    allContIds.add(acr.PRM_Contact_Id__c);
                    if(eligiblePartnerRoles.contains(acr.PRM_Partner_Role__c) && allEligiblelocAccountIDAssociatedToOPID.contains(acr.PRM_Account_Id__c)){
                        eligibleContIds.add(acr.PRM_Contact_Id__c); 
                    }
                    if(allIneligiblelocAccountIDAssociatedToOPID.contains(acr.PRM_Account_Id__c)){
                        ineligibleContIds.add(acr.PRM_Contact_Id__c); 
                    }
                }
            }
            //List<PRM_Batch_Entitlement__c> existingBatchEntRecordsinNew = new List<PRM_Batch_Entitlement__c>();
            Map<id, Core_Contact_Entitlement__c> mapContIdToPointsRedeemEnt = new map<id, Core_Contact_Entitlement__c>();
            Map<id, PRM_Batch_Entitlement__c> mapContIdToBatchEntRec = new map<id, PRM_Batch_Entitlement__c>();
            if(allContIds.size()>0 && !allContIds.isEmpty()){
                for(Core_Contact_Entitlement__c ent : [SELECT 
                id, 
                name, 
                Core_Contact_Id__c, 
                Core_Entitlement_Id__c, 
                Core_Entitlement_Id__r.name,
                Core_SELECTed__c, 
                Core_Data_Loaded__c, 
                Core_DontNotify__c, 
                Core_FROM_Source__c 
                FROM Core_Contact_Entitlement__c 
                WHERE Core_Entitlement_Id__r.name =: System.Label.PRM_PointsRedeem
                AND Core_Contact_Id__c in: allContIds]
                ){
                    mapContIdToPointsRedeemEnt.put(ent.Core_Contact_Id__c, ent);
                }
            }
            if(allContIds.size()>0 && !allContIds.isEmpty()){
                for(PRM_Batch_Entitlement__c batchEnt : [
                SELECT id, 
                PRM_Contact_Id__c, 
                PRM_Entitlement_Id__r.name, 
                PRM_IsRemove_Ind__c,PRM_Status_Nm__c 
                FROM PRM_Batch_Entitlement__c 
                WHERE PRM_Entitlement_Id__r.name =: System.Label.PRM_PointsRedeem
                AND PRM_Status_Nm__c =: System.Label.PRM_Status_New
                AND PRM_Contact_Id__c in: allContIds]
                ){
                    mapContIdToBatchEntRec.put(batchEnt.PRM_Contact_Id__c, batchEnt);
                }
            }
            for(id conId : eligibleContIds){
                if(mapContIdToPointsRedeemEnt.containsKey(conId) && !mapContIdToPointsRedeemEnt.get(conId).Core_Selected__c && !mapContIdToBatchEntRec.containsKey(conId)){
                    PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                    be.PRM_Contact_Id__c = conId;
                    be.PRM_Entitlement_Id__c = pointsRedeemEntit[0].id;
                    be.PRM_Status_Nm__c = System.Label.PRM_Status_New;
                    be.PRM_Status_Reason_Txt__c ='PRM_PointsRedeemBenAssignUtility : Activation of Entitlement';//TWC729-8089 : Adding reason text : NJ
                    be.PRM_IsRemove_Ind__c = false;
                    bacthentListToUpsert.add(be);
                }
                else if(mapContIdToPointsRedeemEnt.containsKey(conId) && !mapContIdToPointsRedeemEnt.get(conId).Core_Selected__c && mapContIdToBatchEntRec.containsKey(conId) && mapContIdToBatchEntRec.get(conId).PRM_IsRemove_Ind__c){
                    mapContIdToBatchEntRec.get(conId).PRM_IsRemove_Ind__c = false;
                    bacthentListToUpsert.add(mapContIdToBatchEntRec.get(conId));
                }
                else if (!mapContIdToPointsRedeemEnt.containsKey(conId) && mapContIdToBatchEntRec.containsKey(conId) && mapContIdToBatchEntRec.get(conId).PRM_IsRemove_Ind__c) {
                    mapContIdToBatchEntRec.get(conId).PRM_IsRemove_Ind__c = false;
                    bacthentListToUpsert.add(mapContIdToBatchEntRec.get(conId));
                }
                else if (!mapContIdToPointsRedeemEnt.containsKey(conId) && !mapContIdToBatchEntRec.containsKey(conId)) {
                    PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                    be.PRM_Contact_Id__c = conId;
                    be.PRM_Entitlement_Id__c = pointsRedeemEntit[0].id;
                    be.PRM_Status_Nm__c = System.Label.PRM_Status_New;
                    be.PRM_Status_Reason_Txt__c= 'PRM_PointsRedeemBenAssignUtility : Activation of Entitlement';//TWC729-8089 : Adding reason text : NJ
                    be.PRM_IsRemove_Ind__c = false;
                    bacthentListToUpsert.add(be);
                }    
            }
            
            //Ineligible Contacts
            for(id conId : ineligibleContIds){
                if(mapContIdToPointsRedeemEnt.containsKey(conId) && mapContIdToPointsRedeemEnt.get(conId).Core_Selected__c && !mapContIdToBatchEntRec.containsKey(conId)){
                    PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                    be.PRM_Contact_Id__c = conId;
                    be.PRM_Entitlement_Id__c = pointsRedeemEntit[0].id;
                    be.PRM_Status_Nm__c = System.Label.PRM_Status_New;
                    be.PRM_Status_Reason_Txt__c ='PRM_PointsRedeemBenAssignUtility : Removal of Entitlement';//TWC729-8089 : Adding reason text : NJ
                    be.PRM_IsRemove_Ind__c = true;
                    bacthentListToUpsert.add(be);
                }
                else if(mapContIdToPointsRedeemEnt.containsKey(conId) && mapContIdToPointsRedeemEnt.get(conId).Core_Selected__c && mapContIdToBatchEntRec.containsKey(conId) && !mapContIdToBatchEntRec.get(conId).PRM_IsRemove_Ind__c){
                    mapContIdToBatchEntRec.get(conId).PRM_IsRemove_Ind__c = true;
                    bacthentListToUpsert.add(mapContIdToBatchEntRec.get(conId));
                }
                else if(mapContIdToPointsRedeemEnt.containsKey(conId) && !mapContIdToPointsRedeemEnt.get(conId).Core_Selected__c && mapContIdToBatchEntRec.containsKey(conId)){
                    mapContIdToBatchEntRec.get(conId).PRM_Status_Nm__c = 'Discarded';
                    mapContIdToBatchEntRec.get(conId).PRM_Status_Reason_Txt__c = 'Entitlement no longer required';
                    bacthentListToUpsert.add(mapContIdToBatchEntRec.get(conId));
                }
                else if(!mapContIdToPointsRedeemEnt.containsKey(conId) && mapContIdToBatchEntRec.containsKey(conId)) {
                    mapContIdToBatchEntRec.get(conId).PRM_Status_Nm__c = 'Discarded';
                    mapContIdToBatchEntRec.get(conId).PRM_Status_Reason_Txt__c = 'Entitlement no longer required';
                    bacthentListToUpsert.add(mapContIdToBatchEntRec.get(conId));
                }
            }
            
            if(bacthentListToUpsert.size()>0 && !bacthentListToUpsert.isEmpty()){
                upsertData(bacthentListToUpsert);
            } 
        }catch(Exception ex){
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, ex.getMessage(), '', '', '', '');
        }
    }
    //Exception handling when any record got errored out.
    public static void upsertData(List<sObject> upsertList){
        set<Id> abaIdSet = new set<Id>();
        String sObjectTypes;
        if(upsertList.size() < Limits.getLimitDMLRows()){
            if(upsertList != null && !upsertList.IsEmpty()){
                Database.UpsertResult[] accBenList;
                accBenList = Database.upsert(upsertList, false); 
                integer index = 0;
                for (Database.UpsertResult sr : accBenList){                    
                    if (!sr.isSuccess()){
                        Id sId;
                        String sObjectType = '';
                        String tags = '';
                        for(Database.Error err : sr.getErrors()){
                            sId =upsertList[index].Id;
                            if(sId != null){
                                sObjectType =  sId.getSObjectType().getDescribe().getName();
                            }
                            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, err.getMessage(), '', sId, sObjectType, tags);
                        }
                    }else{
                        abaIdSet.add(sr.getId()); 
      sObjectTypes = sr.getId().getSObjectType().getDescribe().getName();
                    }
                    index ++;
                }
        }else{
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY,ERRORMESSAGE,'','' ,'','');
        } 
    }
}
    }