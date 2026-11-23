/***************************************************************************************************************************************
Apex Class Name     : PRM_BenefitUtility 
Version             : 1.0
Created Date        : Feb 2019
Function            : Handler for PRM_BenefitsUpdateBatch batch class to assign Benefits.
Modification Log    :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                   10-Feb-2019                   Added a new method 'assignBenefitsAndEntitlements' to Update or Insert the Benefits under
                                                          the Account Benefit Association object whenever the PRM_BenefitsUpdateBatch class executes.
* Bharath                    8-Sep-2020                   US773368 - Added new method to delete VX Data Record on ACM Inactivation
* Ruchi                      18 July 2025                 Removed reference for Partner role(PRM_Partner_Role_Nm__c) on VX Data Table(PRM_Value_Exchange_Data__c). Added comment "IPA Refresh 2.0 - Removed partner role as part of TWC729-8087"
*************************************************************************************************************************************/

public without sharing class PRM_BenefitUtility{
    public static Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    public static Final String ORIGIN  = 'PRM_BenefitUtility';
    public static Final String SEVERITY  = 'Info';
    public static Final String PROJECT  = 'IPA';
    public static Final String ERRORMESSAGE  = 'Too many DML rows';    
    public static final String LOG_ENTRY_SCOPE    = 'PRM_BenefitUtility';   
    public static final String LOG_ENTRY_ERROR    = 'error';
    public static final String LOG_ENTRY_SEVERITY = 'Error';    
    public static final String SYM_SEMICOL = ';';
    public static String logEntryMsgString='';
    public static String approvalType = System.label.PRM_ApprovalType;
    
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);
    
    public static boolean updateCheck = true;
    
    // Partner and Prestige tier
    // IPA 2.0 Refresh Changes : DINESH
    public static String partnerTier = PRM_accBenefitAssociationUtility.getApplicableBenefitTiers('Partner');
    public static String prestigeTier = PRM_accBenefitAssociationUtility.getApplicableBenefitTiers('Prestige');
    //----
    /* public static String TitaniumTier = PRM_accBenefitAssociationUtility.getApplicableBenefitTiers('Titanium');
    public static String GoldTier = PRM_accBenefitAssociationUtility.getApplicableBenefitTiers('Gold');
    public static String MemberTier = PRM_accBenefitAssociationUtility.getApplicableBenefitTiers('Member');*/
    public static Map<String,String> applicableTiersMap = new Map<String,String>();
    
    public static Id intelRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    public static void assignBenefitsAndEntitlements(List<Account>accounts,boolean sourceCheck, boolean assignOnlyEntitlement, boolean isAdminProcess){

        List<Id> beCon = new List<Id>();
        List<Id> beEnt = new List<Id>();

        logEntryMsgString+='\n\nassignBenefitsAndEntitlements method started';

        // IPA 2.0 Refresh Changes : DINESH
        /*if(ipaRefresh || Test.isRunningTest()){
            applicableTiersMap.put('Partner',partnerTier);
            applicableTiersMap.put('Prestige',prestigeTier);
        }
        if(!ipaRefresh || Test.isRunningTest()){
        applicableTiersMap.put('Titanium',TitaniumTier);
        applicableTiersMap.put('Gold',GoldTier);
        applicableTiersMap.put('Member',MemberTier);
        }*/ // IPA refresh - switch removal
        applicableTiersMap.put('Partner',partnerTier);
        applicableTiersMap.put('Prestige',prestigeTier);

        Core_CustomMetadataObjectController customMetadata = new Core_CustomMetadataObjectController('PRM_Tracker_steps__mdt');
        
        //TWC729-4717 - getting instance of metadata
        Map<String,Object> benefitUpdateMdt = customMetadata.getInstance('BF_UPD');
        List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
        //TWC729-4717 - initializing acm List for successful and unsuccessful upsert 
        map<Id, PRM_AccountBenefitAssociation__c> abaMapAfterUpsert = new  map <Id, PRM_AccountBenefitAssociation__c>();
        List<PRM_Value_Exchange_Recommendation__c> opidRecList = new List<PRM_Value_Exchange_Recommendation__c>(); //TWC729-6800 EOL activities
        set<Id> abaIdSet = new set<Id>();
        set<Id> opidAccIdSet = new set<Id>();
        //set<Id> opidRecIds = new set<Id>();
        
        //added as part of TWC729-5300
        Id opidRecommendationRecordType = Schema.SObjectType.PRM_Value_Exchange_Recommendation__c.getRecordTypeInfosByName().get(System.Label.PRM_RecordType_OPID).getRecordTypeId(); //OPID Recommendation //TWC729-6800 EOL activities
        Map<Id, PRM_Tracker__c> listOfAvailableMilestoneRecords = new Map<Id, PRM_Tracker__c>();
        List<PRM_Tracker__c> tList=new List<PRM_Tracker__c>();
        
        //DateTime lastSuccessfulRun;
        List<Id>accIdList = new List<Id>();
        List<PRM_VXBnftMatrix__c> vebm = new List<PRM_VXBnftMatrix__c>();
        List<PRM_VXEnttlmntMatrix__c> entitlementMatrixlist = new List< PRM_VXEnttlmntMatrix__c>();
        List<PRM_Account_Contact_Relationship__c> acrRecords = new List<PRM_Account_Contact_Relationship__c>();
        Set<PRM_AccountBenefitAssociation__c> abaId = new Set<PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> abaToUpsert = new List<PRM_AccountBenefitAssociation__c>();
        Map<Id,PRM_AccountBenefitAssociation__c> abaIdMap = new Map<Id,PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        Map<Id,List<String>> partnerBenefitMap  = new Map<Id,List<String>>();
        Map<String,Id> mapOfPB = new Map<String,Id>();
        Map<Id,String> mapAccToName = new Map<Id,String>();
        Map<Id,String> accToBenefitMap = new Map<Id,String>();
        Map<Id,String> mapAccToId = new Map<Id,Id>(); 
        Map<String,List<Id>> benefitMap = new Map<String,List<Id>>();
        List<String> cpl = new List<String>();
        PRM_BatchCustomSetting__c batchCustomSetting;
        List<String> partnerBenefitList;
        List<Id> partnerBenefitIdList = new List<Id>();
        List<Id> pbListOnBM = new List<Id>();
        List<Account> accountWithoutBenefits = new List<Account>();
        List<PRM_VXEnttlmntMatrix__c> entitlementWithoutBenefit = new List<PRM_VXEnttlmntMatrix__c>();
        Map<String,PRM_AccountChannelMembership__c> acmMap = new Map<String,PRM_AccountChannelMembership__c>();
        //Map<Id,Core_Contact_Entitlement__c> ceStatusMap = new Map<Id,Core_Contact_Entitlement__c>();
        
        
        Map<String,Set<String>> mapOfAccountIdAndSpeciality = new Map<String,Set<String>>();
        Set<string> setOfSpeciality = new Set<string>();
        Set<Id> finalAccList = new Set<Id>();
        Map<string,Set<string>> mapOfspecialityAndListOgBenifitGroup = new Map<string,Set<string>>();
        Set<string> benifitGroup = new Set<string>();
        Map<string,Set<String>> mapOfBenifitGroupToBenifit = new Map<string,Set<String>>(); 
        Map<string,Set<Id>> mapOfBenifitGroupToBenifitId = new Map<string,Set<Id>>(); 
        Map<string,Set<String>> mapOfSpeacailityIdAndBenifitId = new Map<string,Set<String>>();
        Map<string,Set<Id>> mapOfSpeacailityAndBenifit = new Map<string,Set<Id>>();
        Map<string,Set<String>> mapOfAccountAndBenifit = new Map<string,Set<String>>();
        Map<string,Set<Id>> mapOfAccountAndBenifitId = new Map<string,Set<Id>>();
        //Sheetal opid Changes Start
        Map<String,String> mapOfChildToParentAccount = new Map<String,String>();
        //Sheetal opid Changes end
        List<PRM_AccountChannelMembership__c> allACMsList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> inActiveACMsList = new List<PRM_AccountChannelMembership__c>();
        Map<Id,List<PRM_AccountChannelMembership__c>> accAcmMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
        List<Id> accWithNoActiveAcm = new List<Id>();
    
    //to hlod manual benefits
        Map<String, Set<String>> manualPartnerRolVxBftMat = new Map<String, Set<String>>();
    Map<String,List<PRM_AccountBenefitAssociation__c>> existingABAMap = new Map<String,List<PRM_AccountBenefitAssociation__c>>();
    
        
        
        Map<Id,Set<Id>> mapOfTierBenefits = new Map<Id,Set<Id>>();
        
        // capture all account ids
        // commented by dinesh : not required
        // ger the Partner Role from ACM
        Set<String> partnerRoles = new Set<String>();
        
        for(Account acc :accounts){
            accIdList.add(acc.Id);
            
        }
        
        //Query on AsyncApexJob to get the identical records which got modified in last 6 hrs.
        
        //Query on BatchCustomSetting to fetch batch size, Partner type, scheduling hour, channel program level        
        /*if(!ipaRefresh || Test.isRunningTest()){
        batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        cpl = batchCustomSetting.PRM_ChannelProgramLevel__c.split(';');
        }*/ // IPA refresh - switch removal
        
        Map<Id, Id> accountIdRecordTypeIdMap = new Map<Id,Id>();
        
        //Sheetal Changes for opid entltlment Start
        if(accounts != null && ! accounts.isEmpty()){
                finalAccList.addAll(accIdList);
                For(Core_Account_Group_Member__c Cagm: [Select id,name,Core_Inactive_Ind__c,Core_Partner_Account_Id__c,Core_Intel_Account_Id__c from Core_Account_Group_Member__c where (Core_Partner_Account_Id__c IN: accIdList OR Core_Intel_Account_Id__c IN: accIdList) AND Core_Inactive_Ind__c = false]){
                    mapOfChildToParentAccount.put(Cagm.Core_Intel_Account_Id__c,Cagm.Core_Partner_Account_Id__c);
                // IPA 2.0 Changes : Dinesh
                    finalAccList.add(Cagm.Core_Partner_Account_Id__c);
                    finalAccList.add(Cagm.Core_Intel_Account_Id__c);// ADDED BY DINESH
                }  
            }
        //Sheetal Changes for opid entltlment End
        //Query on Account channel membership which got modified in last 6 hrs, channel program as IPA , Channel program level as gold or platinum, status as approved.
        if(sourceCheck){
            //Bharath - US773368 - Changes start
            // IPA 2.0 Refresh : DINESH - pull only group account acms
            /*if(ipaRefresh){
                allACMsList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c,PRM_Account_Id__r.RecordType.DeveloperName From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Account_Id__c IN :finalAccList AND PRM_Partner_Role__c != null AND PRM_Channel_Program_Id__r.Name != null AND PRM_Channel_Program_Level_Id__r.Name !=null];
            }else{
            allACMsList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c,PRM_Account_Id__r.RecordType.DeveloperName From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Account_Id__c IN :accIdList AND PRM_Partner_Role__c != null AND PRM_Channel_Program_Id__r.Name != null AND PRM_Channel_Program_Level_Id__r.Name !=null];
            }*/ // IPA Refresh - switch removal
            allACMsList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c,PRM_Account_Id__r.RecordType.DeveloperName From PRM_AccountChannelMembership__c Where PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Account_Id__c IN :finalAccList AND PRM_Partner_Role__c != null AND PRM_Channel_Program_Id__r.Name != null AND PRM_Channel_Program_Level_Id__r.Name !=null];
            
            logEntryMsgString+='\n\nallACMsList returned if sourcecheck true:'+allACMsList;
            if(allACMsList != null && !allACMsList.isEmpty()){
                for(PRM_AccountChannelMembership__c acm:allACMsList){
                    partnerRoles.add(acm.PRM_Partner_Role__c);
                    /*if((!ipaRefresh || Test.isRunningTest())&& acm.PRM_Status_Nm__c == System.Label.PRM_Status && cpl.contains(acm.PRM_Channel_Program_Level_Id__r.Name)){
                        acmList.add(acm);
                    }*/ //IPA Refresh - switch removal
                    if(acm.PRM_Status_Nm__c == System.Label.PRM_Status /*&& (ipaRefresh || Test.isRunningTest())*/){
                        acmList.add(acm);
                    }
                    if(acm.PRM_Status_Nm__c == System.label.PRM_Status_Inactive){
                        inActiveACMsList.add(acm);
                    }
                    //get all acc and respective acm
                    if(accAcmMap.containsKey(acm.PRM_Account_Id__c)){
                        accAcmMap.get(acm.PRM_Account_Id__c).add(acm);
                    }else{
                        List<PRM_AccountChannelMembership__c> acmInactiveList = new List<PRM_AccountChannelMembership__c>();
                        acmInactiveList.add(acm);
                        accAcmMap.put(acm.PRM_Account_Id__c,acmInactiveList);
                    }
                }
            }
        
            if(inActiveACMsList != null && !inActiveACMsList.isEmpty()){
                removeVXDataRecords(inActiveACMsList);
            }
            //check if there is atleast one approved acm
            if(accAcmMap!=null && !accAcmMap.isEmpty()){
                Boolean hasActiveAcm = false;
                for(Id acc: accAcmMap.keySet()){
                    for(PRM_AccountChannelMembership__c  acm: accAcmMap.get(acc)){
                        if(acm.PRM_Status_Nm__c== System.Label.PRM_Status){
                            hasActiveAcm = true;
                            break;
                        }
                    }
                    if(!hasActiveAcm){
                        accWithNoActiveAcm.add(acc);
                    }
                }
            }
            if(accWithNoActiveAcm!=null && !accWithNoActiveAcm.isEmpty()){
                for(PRM_AccountbenefitAssociation__c aba:PRM_IPA_Utility.getAccountBenefitAssociationData(accWithNoActiveAcm)){
                    aba.PRM_Status_Nm__c = System.Label.PRM_Status_Inactive;
                    aba.PRM_Status_Reason_Txt__c = 'Inactivated as account has no active ACM';
                    abaId.add(aba);
                }
            }
            //Bharath - US773368 - Changes end
            
            /*US687673 - END*/
            // IPA 2.0 Refresh : Specialty Removed : DINESH
            
            /*if((!ipaRefresh || Test.isRunningTest())&& accIdList != null && !accIdList.isEmpty() ){
                for(PRM_Account_Specialty_Association__c asa :[Select Id,PRM_Account_Id__c,PRM_Account_Id__r.Name,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Specialty_Id__r.Name From PRM_Account_Specialty_Association__c Where PRM_InActive_Ind__c = false AND PRM_Account_Id__c IN :accIdList]){
                if(mapOfAccountIdAndSpeciality.containskey(asa.PRM_Account_Id__c)){
                        Set<String> setOfTempSpeciality = mapOfAccountIdAndSpeciality.get(asa.PRM_Account_Id__c);
                        setOfTempSpeciality.add(asa.PRM_Specialty_Id__r.Name);
                        mapOfAccountIdAndSpeciality.put(asa.PRM_Account_Id__c,setOfTempSpeciality);
                    } 
                    else{
                        mapOfAccountIdAndSpeciality.put(asa.PRM_Account_Id__c, new Set<string> {asa.PRM_Specialty_Id__r.Name});   
                    }
                   setOfSpeciality.add(asa.PRM_Specialty_Id__r.Name); 
                }  
            }*/ //IPA Refresh - switch removal

            // IPA 2.0 Refresh : Specialty Removed : DINESH
            /*if(!ipaRefresh || Test.isRunningTest())PRM_BenefitUtility.fetchingAndAssociatingBenefitsFromSpecialityAndBenefitGroup(setOfSpeciality, mapOfspecialityAndListOgBenifitGroup, benifitGroup, mapOfBenifitGroupToBenifit, mapOfBenifitGroupToBenifitId, mapOfSpeacailityIdAndBenifitId, mapOfSpeacailityAndBenifit, mapOfAccountIdAndSpeciality, mapOfAccountAndBenifit, mapOfAccountAndBenifitId);*/ // IPA refresh - switch removal
              //Fetching benefit group from speciality. 
        }
        else{
            /*if(ipaRefresh || Test.isRunningTest()){*/
                acmList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId, PRM_Account_Id__r.RecordType.DeveloperName From PRM_AccountChannelMembership__c Where PRM_Status_Nm__c =:System.Label.PRM_Status AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Channel_Program_Level_Id__r.Name = 'Partner' AND PRM_Account_Id__c IN :accIdList AND PRM_Partner_Role__c != null ]; //and PRM_Account_Id__r.RecordType.DeveloperName = 'Core_Partner_Account_Group'
                for( PRM_AccountChannelMembership__c acmRecord :acmList){
                    accountIdRecordTypeIdMap.put(acmRecord.PRM_Account_Id__c, acmRecord.PRM_Account_Id__r.RecordTypeId);
                }
            /*}
            if(!ipaRefresh || Test.isRunningTest()){
                acmList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c,PRM_Account_Id__r.RecordTypeId,PRM_Account_Id__r.RecordType.DeveloperName From PRM_AccountChannelMembership__c Where PRM_Status_Nm__c =:System.Label.PRM_Status AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Channel_Program_Level_Id__r.Name = 'Member' AND PRM_Account_Id__c IN :accIdList AND PRM_Partner_Role__c != null];
            }*/ // IPA Refresh - switch removal
            
          logEntryMsgString+='\n\nacmList returned if sourcecheck false:'+acmList;
        }
        if(acmList != null && !acmList.IsEmpty()){
            for(PRM_AccountChannelMembership__c acm :acmList){
                partnerRoles.add(acm.PRM_Partner_Role__c); // added by dinesh as Entitlment assignment was failing
                acmMap.put(acm.PRM_Account_Id__c + '-' + acm.PRM_Partner_Role__c, acm);
            }
        }
        
        // IPA Refresh: only Partner and Prestige Tier
        /*if(!ipaRefresh || Test.isRunningTest()){
            vebm = [Select id, PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Covered_Account_Ind__c, PRM_Approval_Type_Nm__c, PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c from PRM_VXBnftMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_IsActive_Ind__c = True];
        } // IPA Refresh - switch removal
        if(ipaRefresh || Test.isRunningTest()){*/
            vebm = [Select id, PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Covered_Account_Ind__c, PRM_Approval_Type_Nm__c, PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Role_Nm__c,PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c from PRM_VXBnftMatrix__c where /*PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND*/ PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance and PRM_Channel_Program_Level_Id__r.Name in ('Partner','Prestige') AND PRM_IsActive_Ind__c = True];
        //}
        //Start -TWC729-3959 
        List<string> pointsBenefits = System.Label.PRM_Points_benefits.split(';') ;
        Map<id,PRM_Profile_Responses__c> respnseListMap = new Map<id,PRM_Profile_Responses__c> ();
        Map<id,PRM_IPAMembership_Attributes__c> ipaMemAttMap = new Map<id,PRM_IPAMembership_Attributes__c> ();
         Map<id,Boolean> restrictBenefitUpdate = new Map<id,Boolean> ();
        if(!accIdList.isEmpty() && accIdList  != null ){
            //IPA 2.0 - TWC729-8021 : activate/inactivate points benefit based on ipa membership attribute's points not eligible field - START
            /*if(!ipaRefresh || Test.isRunningTest()){
                for(PRM_Profile_Responses__c respnseList : [Select PRM_Profile_Questions_Id__C, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c ,PRM_Profile_Answer_Id__r.PRM_Answer_Cd__c, PRM_Account_Id__c, PRM_View_History__c, PRM_Response_Txt__c,  PRM_InActive_Ind__c ,PRM_Question_Display_Text__c, PRM_Reason_Text__c, RecordTypeId from PRM_Profile_Responses__c where PRM_Account_Id__c in :accIdList and PRM_Profile_Questions_Id__r.PRM_Question_Cd__c = 'PRM_Point_Not_Eligible' ]){
                    respnseListMap.put(respnseList.PRM_Account_Id__c,respnseList);
                }
                for(Id accid : accIdList){
                    if(respnseListMap != null && respnseListMap.keyset().contains(accid) ){
                        if(respnseListMap.get(accid).PRM_Response_Txt__c != 'false'){
                            restrictBenefitUpdate.put(accid,true);
                        }else{
                            restrictBenefitUpdate.put(accid,false);
                        }
                    }else{
                        restrictBenefitUpdate.put(accid,false);
                    }
                }
            } // IPA Refresh - switch removal
            if(ipaRefresh || Test.isRunningTest()){*/
                for(PRM_IPAMembership_Attributes__c respnseList : [Select PRM_Points_Not_Eligible_Ind__c,PRM_Account_Id__c FROM PRM_IPAMembership_Attributes__c where PRM_Account_Id__c in :accIdList AND PRM_Inactive_ind__c = FALSE]){
                    ipaMemAttMap.put(respnseList.PRM_Account_Id__c,respnseList);
                }
                for(Id accid : accIdList){
                    if(ipaMemAttMap != null && ipaMemAttMap.keyset().contains(accid) ){
                        if(ipaMemAttMap.get(accid).PRM_Points_Not_Eligible_Ind__c){
                            restrictBenefitUpdate.put(accid,true);
                        }else{
                            restrictBenefitUpdate.put(accid,false);
                        }
                    }else{
                        restrictBenefitUpdate.put(accid,false);
                    }
                }
            //}
            //IPA 2.0 - TWC729-8021 : activate/inactivate points benefit based on ipa membership attribute's points not eligible field - END
        }
        //End -TWC729-3959  
        if(assignOnlyEntitlement){//for Benefit as well as ENtitlement
            if(acmList != null && !acmList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :acmList){
                    String applicableTiers = applicableTiersMap.get(acm.PRM_Channel_Program_Level_Id__r.Name);
                    partnerBenefitList = new List<String>();
                    List<Id> benefitListTemp =new List<Id>();
                    if(benefitMap.get(acm.PRM_Account_Id__c)!= null && !benefitMap.get(acm.PRM_Account_Id__c).isEmpty()){
                        benefitListTemp = benefitMap.get(acm.PRM_Account_Id__c);
                    }
                    if(partnerBenefitMap.get(acm.PRM_Account_Id__c)!= null && !partnerBenefitMap.get(acm.PRM_Account_Id__c).isEmpty()){
                        partnerBenefitList = partnerBenefitMap.get(acm.PRM_Account_Id__c);
                    }
                    if(vebm != null && !vebm.IsEmpty() && String.isNotBlank(applicableTiers)){
                        for(PRM_VXBnftMatrix__c bm : vebm){
                            //Fetching ABA applicable for the account.
                            Set<Id> tierBenefits = new Set<Id>();
                // Added as part of US TWC729-3583/3548 ,to add lower tier benefit.
                        //String applicableTiers = PRM_accBenefitAssociationUtility.getApplicableBenefitTiers(acm.PRM_Channel_Program_Level_Id__r.Name);
                            if(
                                ((acm.PRM_Account_Id__r.RecordTypeId != intelRecordTypeId /*&& ipaRefresh*/) && (applicableTiers.contains(bm.PRM_Channel_Program_Level_Id__r.Name)) && (bm.PRM_Approval_Type_Nm__c == 'Automatic') && (bm.PRM_IsActive_Ind__c = True) &&(acm.PRM_Partner_Role__c == bm.PRM_Partner_Role_Nm__c) && (acm.PRM_Account_Id__r.RecordType.DeveloperName == bm.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c)) ||
                            (applicableTiers.contains(bm.PRM_Channel_Program_Level_Id__r.Name) && (bm.PRM_Approval_Type_Nm__c == 'Automatic') && (bm.PRM_IsActive_Ind__c = True) &&(acm.PRM_Partner_Role__c == bm.PRM_Partner_Role_Nm__c) && (acm.PRM_Account_Id__r.RecordType.DeveloperName == bm.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c))){
                                if(acm.PRM_Account_Id__r.Core_Covered_Account__c == true){
                                    partnerBenefitList.add(bm.PRM_Partner_Benefit_Id__r.Name);                                  
                                    benefitListTemp.add(bm.PRM_Partner_Benefit_Id__c);
                                }
                                else{
                                    if(bm.PRM_Covered_Account_Ind__c == false){
                                        partnerBenefitList.add(bm.PRM_Partner_Benefit_Id__r.Name);
                                        benefitListTemp.add(bm.PRM_Partner_Benefit_Id__c);
                                    }
                                }
                                
                                if(mapOfTierBenefits.get(acm.PRM_Account_Id__c) != null && !mapOfTierBenefits.get(acm.PRM_Account_Id__c).IsEmpty()){
                                    tierBenefits = mapOfTierBenefits.get(acm.PRM_Account_Id__c);
                                }
                                tierBenefits.add(bm.PRM_Partner_Benefit_Id__c);
                                mapOfTierBenefits.put(acm.PRM_Account_Id__c,tierBenefits);
                                
                                partnerBenefitIdList.add(bm.PRM_Partner_Benefit_Id__c);
                                benefitMap.put(acm.PRM_Account_Id__c,benefitListTemp);
                            }
              if(/*ipaRefresh &&*/ applicableTiers.contains(bm.PRM_Channel_Program_Level_Id__r.Name) && bm.PRM_Approval_Type_Nm__c !='Automatic' && acm.PRM_Partner_Role__c == bm.PRM_Partner_Role_Nm__c && acm.PRM_Account_Id__r.RecordType.DeveloperName == bm.PRM_Partner_Benefit_Id__r.PRM_Account_Type_Nm__c){
                if(manualPartnerRolVxBftMat.containsKey(acm.PRM_Account_Id__c)){
                  manualPartnerRolVxBftMat.get(acm.PRM_Account_Id__c).add(bm.PRM_Partner_Benefit_Id__c);
                }else{
                  Set<String> tempSet = new Set<String>();
                  tempSet.add(bm.PRM_Partner_Benefit_Id__c);
                  manualPartnerRolVxBftMat.put(acm.PRM_Account_Id__c,tempSet);
                }
              }
                        }
                    }

                    if(partnerBenefitList != null && !partnerBenefitList.IsEmpty()){   
                        partnerBenefitMap.put(acm.PRM_Account_Id__c,partnerBenefitList);
                    }
                    if(benefitListTemp != null && !benefitListTemp.IsEmpty()){   
                        benefitMap.put(acm.PRM_Account_Id__c,benefitListTemp);
                    }
                }
            }
            logEntryMsgString+='\n\nbenefitMap returned:'+benefitMap;
            if(sourceCheck){  //US687673 - Assign benefits for the specialty as well as select benefit irrespective of partner tier.
                logEntryMsgString+='\n\nAssigning benefits';  
                PRM_BenefitUtility.assignBenefit(accIdList ,mapOfAccountAndBenifit, partnerBenefitMap,benefitMap,partnerBenefitIdList,mapOfAccountAndBenifitId);
                logEntryMsgString+='\n\nbenefitMap returned after assignment:'+benefitMap;
            }
            //US687673 - END
           
            if(accIdList != null && !accIdList.IsEmpty()){
                for(PRM_AccountBenefitAssociation__c aba :  PRM_IPA_Utility.getAccountBenefitAssociationData(accIdList)){
                    if(!accWithNoActiveAcm.contains(aba.PRM_Account_Id__c)){
                        if(/*(ipaRefresh|| Test.isRunningTest()) &&*/ aba.PRM_Status_Nm__c== System.Label.PRM_Status_Active){
                            if(existingABAMap.containsKey(aba.PRM_Account_Id__c)){
                                existingABAMap.get(aba.PRM_Account_Id__c).add(aba);
                            }else{
                                List<PRM_AccountBenefitAssociation__c> abaListTemp = new List<PRM_AccountBenefitAssociation__c>();
                                abaListTemp.add(aba);
                                existingABAMap.put(aba.PRM_Account_Id__c,abaListTemp);
                            }
                        }
                        
                        //When applicable ABA is already associated with parent account.
                        if(partnerBenefitMap!= null && !partnerBenefitMap.isEmpty()){
                            if(partnerBenefitMap.get(aba.PRM_Account_Id__c) !=null && !partnerBenefitMap.get(aba.PRM_Account_Id__c).isEmpty()){    
                                List<String> pbList = partnerBenefitMap.get(aba.PRM_Account_Id__c);
                                if(pbList!= null && !pbList.isEmpty() ){
                                    if(pbList.contains(aba.PRM_Partner_Benefit_Id__r.Name)){
                                        if(!pointsBenefits.contains(aba.PRM_Partner_Benefit_Id__r.Name) || (pointsBenefits.contains(aba.PRM_Partner_Benefit_Id__r.Name) && (!restrictBenefitUpdate.containsKey(aba.PRM_Account_Id__c) || restrictBenefitUpdate.get(aba.PRM_Account_Id__c) == false) ) ){ //TWC729-3959 
                                            if(aba.PRM_Status_Nm__c == System.Label.PRM_Status_Inactive && !accWithNoActiveAcm.contains(aba.PRM_Account_Id__c)){
                                                aba.PRM_Status_Nm__c = System.Label.PRM_Status_Active;
                                                aba.PRM_Status_Reason_Txt__c = 'Activated based on Profile Response';//TWC729-8089 : Adding reason text : NJ
                                            abaId.add(aba);
                                            }
                                        }                                                                                                                                                                                                 // TWC729-3959 
                                        if(pbList.indexOf(aba.PRM_Partner_Benefit_Id__r.Name) !=-1){
                                            Integer index = pbList.indexOf(aba.PRM_Partner_Benefit_Id__r.Name);
                                            pbList.remove(index);
                                        }
                                    }
                                }
                            }
                        }
                        mapAccToName.put(aba.Id,aba.PRM_Account_Id__r.Name);
                        mapAccToId.put(aba.Id,aba.PRM_Account_Id__c);
                    }
                }
            }
            
            for(PRM_PartnerBenefit__c pb : [Select Id, Name From PRM_PartnerBenefit__c]){
                mapOfPB.put(Pb.Name,pb.Id);
            }
           
        if(existingABAMap!=null && !existingABAMap.isEmpty()){
        for(String acc:existingABAMap.keyset()){
                    List<String> autoBenefits = new List<String>();
          Set<String> manualBenefits = new Set<String>();
          if(benefitMap.containsKey(acc) && benefitMap.get(acc)!=null){
                        autoBenefits = benefitMap.get(acc);
                    }
                    if(manualPartnerRolVxBftMat.containsKey(acc) && manualPartnerRolVxBftMat.get(acc)!=null){
            manualBenefits = manualPartnerRolVxBftMat.get(acc);
                    }
          List<PRM_AccountBenefitAssociation__c> existingABA = existingABAMap.get(acc);
          for(PRM_AccountBenefitAssociation__c aba: existingABA){
                        if(!accWithNoActiveAcm.contains(aba.PRM_Account_Id__c)){
                            if(autoBenefits!=null && !autoBenefits.contains(aba.PRM_Partner_Benefit_Id__c)){
                                if(!manualBenefits.isEmpty() && !manualBenefits.contains(aba.PRM_Partner_Benefit_Id__c)){
                                            aba.PRM_Status_Nm__c = 'Inactive';
                                            aba.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
                                        abaId.add(aba);
                                    }else if(manualBenefits.isEmpty()){
                                        aba.PRM_Status_Nm__c = 'Inactive';
                                        aba.PRM_Status_Reason_Txt__c =Label.PRM_ACM_ABA_Automation_Reason;
                                    abaId.add(aba);
                                }
                            }
                        }
                    }
          }
      }
      
      
            if(partnerBenefitMap!= null && !partnerBenefitMap.isEmpty()){
                for(Account acc :accounts){
                    //Assigning applicable ABA to the parent account.
                    List<String> pbList = partnerBenefitMap.get(acc.Id);
                    if(!accWithNoActiveAcm.contains(acc.Id)){
                        if(pbList!= null && !pbList.isEmpty() && (accountIdRecordTypeIdMap.get(acc.id) != intelRecordTypeId /*&& ipaRefresh*/) || pbList!= null && !pbList.isEmpty()){
                            for(integer i=0; i<pbList.size(); i++) {
                                PRM_AccountBenefitAssociation__c newAba = new PRM_AccountBenefitAssociation__c();
                                if(mapOfPB.get(pbList[i]) !=null  ){ 
                                    newAba.PRM_Status_Reason_Txt__c = 'Benefit as per benefit Matrix';//TWC729-8089 : Adding reason text : NJ
                                    newAba.PRM_Partner_Benefit_Id__c = mapOfPB.get(pbList[i]);
                                    newAba.PRM_Status_Nm__c = System.Label.PRM_Status_Active;
                                    newAba.PRM_Account_Id__c = acc.Id;
                                    if(mapOfTierBenefits.get(acc.Id) != null && !mapOfTierBenefits.get(acc.Id).IsEmpty() && mapOfAccountAndBenifitId.get(acc.Id) != null && !mapOfAccountAndBenifitId.get(acc.Id).IsEmpty() && mapOfTierBenefits.get(acc.Id).contains(mapOfPB.get(pbList[i])) && mapOfAccountAndBenifitId.get(acc.Id).contains(mapOfPB.get(pbList[i]))){ //Benefit is available from both the place, benefit matrix awa specialty. 
                                        newAba.PRM_Source__c = System.Label.PRM_Source_Matrix_Specialty;
                                    }
                                    else if(mapOfTierBenefits.get(acc.Id) != null && !mapOfTierBenefits.get(acc.Id).IsEmpty() && mapOfTierBenefits.get(acc.Id).contains(mapOfPB.get(pbList[i]))){//source of benefit is benefit matrix.
                                        newAba.PRM_Source__c = System.Label.PRM_Source_BenefitMatrix;
                                    }
                                    else if(mapOfAccountAndBenifitId.get(acc.Id) != null && !mapOfAccountAndBenifitId.get(acc.Id).IsEmpty() && mapOfAccountAndBenifitId.get(acc.Id).contains(mapOfPB.get(pbList[i]))){ //source of benefit is specialty.
                                        newAba.PRM_Source__c = System.Label.PRM_Source_Specialty;
                                    }
                                    
                                    /*Added below code to cover exception from test class - Start*/
                                    if(Test.isRunningTest() && i==0){
                                        newAba.PRM_Status_Reason_Txt__c = '*****************************************************************************************************************************************************************************************************************************************************************************';
                                    } 
                                    /*END*/
                                    abaId.add(newAba);
                                    accToBenefitMap.put(newAba.Id,pbList[i]);
                                }
                            }
                        }
                        else{
                            accountWithoutBenefits.add(acc);
                        }
                    }
                }
            }
            
            //Exception handling when any ABA record got errored out.
            if(abaId.size() < Limits.getLimitDMLRows()){
                if(!abaId.IsEmpty()){
                    Database.UpsertResult[] accBenList;
                    logEntryMsgString+='\n\nbenefits to upsert:'+abaId;
                    abaToUpsert.addAll(abaId);
                    accBenList = Database.upsert(abaToUpsert, false); 
                    integer index = 0;
                    for (Database.UpsertResult sr : accBenList){                    
                        if (!sr.isSuccess()){
                            Id sId;
                            String sObjectType = '';
                            String tags = '';
                            for(Database.Error err : sr.getErrors()){
                                sId =abaToUpsert[index].Id;
                                if(sId != null){sObjectType =  sId.getSObjectType().getDescribe().getName();
                                               }
                                String accName =  '';
                                accName =mapAccToName.get(abaToUpsert[index].Id) == null?'':mapAccToName.get(abaToUpsert[index].Id);
                                String benName =  '';
                                benName =accToBenefitMap.get(abaToUpsert[index].Id) == null?'':accToBenefitMap.get(abaToUpsert[index].Id);
                                String accId =  '';
                                accId = mapAccToId.get(abaToUpsert[index].Id) == null?'':mapAccToId.get(abaToUpsert[index].Id);
                                tags = accName + ';' + benName + ';' + accId;
                                Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, err.getMessage(), '', sId, sObjectType, tags);
                            }
                        } else {
                            abaIdSet.add(sr.getId());
                        } 
                    }
                    index ++;
                    //TWC729-4717 - updating map for sucessful upsert
                    for(PRM_AccountBenefitAssociation__c aba : abaToUpsert){
                        if(abaIdSet.contains(aba.Id)){
                            abaMapAfterUpsert.put(aba.PRM_Account_Id__c, aba);
                        }
                        opidAccIdSet.add(aba.PRM_Account_Id__c);
                    }
                    
                }
            }else{Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY,ERRORMESSAGE,'','' ,'','');
                 }
        }else{//Agate Team Logic(Assign only Entitlement)
            if(accIdList != null && !accIdList.IsEmpty()){
                for(PRM_AccountBenefitAssociation__c aba : PRM_IPA_Utility.getAccountBenefitAssociationData(accIdList))
                {
                    if(aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active){
                        pbListOnBM.add(aba.PRM_Partner_Benefit_Id__c);
                    }
                }
            }
           
            List<PRM_VXBnftMatrix__c> benefitMatrixList =[Select id, PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Partner_Type_Id__c,PRM_Partner_Type_Id__r.Name,PRM_Covered_Account_Ind__c, PRM_Approval_Type_Nm__c, PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Role_Nm__c from PRM_VXBnftMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_IsActive_Ind__c = True AND PRM_Partner_Benefit_Id__c IN :pbListOnBM];
            List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
            /*if(ipaRefresh){*/
                abaList = [Select Id, Name,PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Status_Nm__c,PRM_Account_Id__r.Name From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :mapOfChildToParentAccount.values() AND PRM_Status_Nm__c =:System.Label.PRM_Status_Active];
            /*}
            if(!ipaRefresh && accIdList!= null && !accIdList.isEmpty()){
                abaList = [Select Id, Name,PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Status_Nm__c,PRM_Account_Id__r.Name From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accIdList AND PRM_Status_Nm__c =:System.Label.PRM_Status_Active];
            }*/ // IPA refresh - switch removal
            
            //if(accIdList!= null && !accIdList.isEmpty()){
                for(PRM_AccountBenefitAssociation__c aba : abaList ){
                    {
                    for(PRM_VXBnftMatrix__c vmList :benefitMatrixList){
                        if(benefitMap.get(aba.PRM_Account_Id__c)!= null && !benefitMap.get(aba.PRM_Account_Id__c).isEmpty()){partnerBenefitIdList = benefitMap.get(aba.PRM_Account_Id__c);
                                                                                                                            }
                        partnerBenefitIdList.add(vmList.PRM_Partner_Benefit_Id__c);
                        benefitMap.put(aba.PRM_Account_Id__c,partnerBenefitIdList);
                    }
                }
            }
                
                
        }
        /*Code started for insertion of Batch entitlement records*/
        // Fetching entitlements when benefit get assigned to account.
        if(partnerBenefitIdList!= null && !partnerBenefitIdList.isEmpty()){
                String query = 'Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,RecordType.Name,PRM_IPA_Partner_Role_Nm__c,PRM_AGS_Role__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:approvalType AND PRM_Partner_Benefit_Id__c in :partnerBenefitIdList and PRM_IPA_Partner_Role_Nm__c in :partnerRoles AND PRM_IsActive_Ind__c = True AND PRM_IPA_Partner_Role_Nm__c != null';
                //String filter = ipaRefresh? 'and PRM_IPARefreshCheck__c = true': 'and PRM_IPARefreshCheck__c = false'; // IPA refresh - switch removal
                
                //entitlementMatrixlist = Database.Query(query+' '+filter);//[Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,RecordType.Name,PRM_IPA_Partner_Role_Nm__c,PRM_AGS_Role__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_Partner_Benefit_Id__c in :partnerBenefitIdList and PRM_IPA_Partner_Role_Nm__c in :partnerRoles AND PRM_IsActive_Ind__c = True AND PRM_IPA_Partner_Role_Nm__c != null];
                entitlementMatrixlist = Database.Query(query);
        }
        
        // Fetching entitlements when benefit doesn't assigned to account.
        /*if(ipaRefresh || Test.isRunningTest()){*/
                String query = 'Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__c,PRM_IPA_Partner_Role_Nm__c,RecordType.Name,PRM_AGS_Role__c,PRM_Channel_Program_Level_Id__r.Name from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:approvalType AND PRM_IPA_Partner_Role_Nm__c in :partnerRoles AND RecordType.Name = \'EntitlementWithoutBenefits\' AND PRM_IsActive_Ind__c = True AND PRM_IPA_Partner_Role_Nm__c != null and PRM_Channel_Program_Level_Id__r.Name in (\'Partner\',\'Prestige\')';
                //String filter = ipaRefresh? 'and PRM_IPARefreshCheck__c = true': 'and PRM_IPARefreshCheck__c = false'; //IPA refresh - switch removal

                //entitlementWithoutBenefit = Database.query(query+' '+filter);//[Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__c,PRM_IPA_Partner_Role_Nm__c,RecordType.Name,PRM_AGS_Role__c,PRM_Channel_Program_Level_Id__r.Name from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IPA_Partner_Role_Nm__c in :partnerRoles AND RecordType.Name = 'EntitlementWithoutBenefits' AND PRM_IsActive_Ind__c = True AND PRM_IPA_Partner_Role_Nm__c != null and PRM_Channel_Program_Level_Id__r.Name in ('Partner','Prestige')];
                entitlementWithoutBenefit = Database.query(query);
        /*}
        if(!ipaRefresh || Test.isRunningTest()){
                String query = 'Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__c,PRM_IPA_Partner_Role_Nm__c,RecordType.Name,PRM_AGS_Role__c,PRM_Channel_Program_Level_Id__r.Name from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:approvalType AND PRM_IPA_Partner_Role_Nm__c in :partnerRoles AND RecordType.Name = \'EntitlementWithoutBenefits\' AND PRM_IsActive_Ind__c = True AND PRM_IPA_Partner_Role_Nm__c != null and (NOT PRM_Channel_Program_Level_Id__r.Name in (\'Partner\',\'Prestige\'))';
                String filter = ipaRefresh? 'and PRM_IPARefreshCheck__c = true': 'and PRM_IPARefreshCheck__c = false';
                entitlementWithoutBenefit = Database.query(query+' '+filter);//[Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__c,PRM_IPA_Partner_Role_Nm__c,RecordType.Name,PRM_AGS_Role__c,PRM_Channel_Program_Level_Id__r.Name from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_IPA_Partner_Role_Nm__c in :partnerRoles AND RecordType.Name = 'EntitlementWithoutBenefits' AND PRM_IsActive_Ind__c = True AND PRM_IPA_Partner_Role_Nm__c != null and (NOT PRM_Channel_Program_Level_Id__r.Name in ('Partner','Prestige'))];
        }*/ // IPA Refresh - Switch removal
        
    Set<Id> entId = new Set<Id>();
    Map<String, List<PRM_VXEnttlmntMatrix__c>> entitlementWithoutBenefitmap = new Map<String, List<PRM_VXEnttlmntMatrix__c>>();
    List<PRM_VXEnttlmntMatrix__c> entWithoutBenListTemp;
    for(PRM_VXEnttlmntMatrix__c em: entitlementWithoutBenefit){
                String key = em.PRM_IPA_Partner_Role_Nm__c + '-' + em.PRM_Contact_Relationship_Id__c + '-' + em.PRM_Channel_Program_Level_Id__r.Name;      
      if(entitlementWithoutBenefitmap.containsKey(key)){
                    entWithoutBenListTemp = entitlementWithoutBenefitmap.get(key);
      }else
        entWithoutBenListTemp = new List<PRM_VXEnttlmntMatrix__c>();
      entId.add(em.PRM_Entitlement_Id__c);
      entWithoutBenListTemp.add(em);
      entitlementWithoutBenefitmap.put(key, entWithoutBenListTemp);
    }
        
        //If we have multiple Entitlements for single benefit.
        Map<Id,Map<String,List<PRM_VXEnttlmntMatrix__c>>> benefitEntitlementMap = new Map<Id,Map<String,List<PRM_VXEnttlmntMatrix__c>>>();
        if(entitlementMatrixlist!= null && !entitlementMatrixlist.isEmpty()){
            for(PRM_VXEnttlmntMatrix__c em1 :entitlementMatrixlist){
                Map<String,List<PRM_VXEnttlmntMatrix__c>> entitlements = new Map<String,List<PRM_VXEnttlmntMatrix__c>>();
                if(benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c)!= null && !benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c).isEmpty()){
                    entitlements = benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c);
                }else{
          entitlements = new Map<String,List<PRM_VXEnttlmntMatrix__c>>();
        }
                List<PRM_VXEnttlmntMatrix__c> entListTemp = entitlements.containsKey(em1.PRM_IPA_Partner_Role_Nm__c + '-' + em1.PRM_Contact_Relationship_Id__c)?
                                        entitlements.get(em1.PRM_IPA_Partner_Role_Nm__c + '-' + em1.PRM_Contact_Relationship_Id__c): new List<PRM_VXEnttlmntMatrix__c>();
               
                entListTemp.add(em1);
                entitlements.put(em1.PRM_IPA_Partner_Role_Nm__c + '-' + em1.PRM_Contact_Relationship_Id__c, entListTemp);
        entId.add(em1.PRM_Entitlement_Id__c);
                benefitEntitlementMap.put(em1.PRM_Partner_Benefit_Id__c,entitlements);
            }
        }
            
            
        Map<Id,Map<String,List<PRM_VXEnttlmntMatrix__c>>> accEntitlementsMap= new Map<Id,Map<String,List<PRM_VXEnttlmntMatrix__c>>>();
        Map<Id,List<id>> accEntilementNotUpdate = new Map<Id,List<id>>(); //TWC729-4156 -Start
            List<PRM_AccountBenefitAssociation__c> abaLst =  new List<PRM_AccountBenefitAssociation__c>();
            if(/*ipaRefresh &&*/ !finalAccList.isEmpty()) {
                abaLst = [Select Id, Name,PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Status_Nm__c,PRM_Account_Id__r.Name From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :mapOfChildToParentAccount.values() AND PRM_Partner_Benefit_Id__r.Name in: pointsBenefits];
            }else{
                abaLst = [Select Id, Name,PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Status_Nm__c,PRM_Account_Id__r.Name From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accounts AND PRM_Partner_Benefit_Id__r.Name in: pointsBenefits];
            }// IPA refresh - switch removal
            
            
            for(PRM_AccountBenefitAssociation__c aba : abaLst)
        {
            if(aba.PRM_Status_Nm__c == 'Inactive' ){
                List<id> benefits = new List<id>();
                if(accEntilementNotUpdate.get(aba.PRM_Account_Id__c)!= null && !accEntilementNotUpdate.get(aba.PRM_Account_Id__c).isEmpty()){
                    benefits = accEntilementNotUpdate.get(aba.PRM_Account_Id__c);
                }
                benefits.add(aba.PRM_Partner_Benefit_Id__c);
                accEntilementNotUpdate.put(aba.PRM_Account_Id__c,benefits);
            }
            
        } //TWC729-4156 - End
        for(Account acc :accounts){
            List<Id> accBenefits = new List<Id>();
                if(benefitMap.get(acc.Id) != null){
                    accBenefits = benefitMap.get(acc.Id); // get location account benefits
                }
                // get the opid benefits
                if(/*ipaRefresh &&*/ !benefitMap.isEmpty() && !mapOfChildToParentAccount.isEmpty() && mapOfChildToParentAccount.containsKey(acc.Id) && benefitMap.containsKey(mapOfChildToParentAccount.get(acc.Id))){
                    
                    for(String bnftId : benefitMap.get(mapOfChildToParentAccount.get(acc.Id))){
                        accBenefits.add(bnftId);
                    }
                    //accBenefits.addAll(benefitMap.get(mapOfChildToParentAccount.get(acc.Id))); // added by dinesh as part of iparefrsh 2.0
                }
                
            if(accBenefits != null && !accBenefits.IsEmpty()){
                Map<String,List<PRM_VXEnttlmntMatrix__c>> accEntitlements = new Map<String,List<PRM_VXEnttlmntMatrix__c>>();
                if(accEntitlementsMap.get(acc.Id)!= null && !accEntitlementsMap.get(acc.Id).isEmpty()){
                    accEntitlements = accEntitlementsMap.get(acc.Id);
                                                                                                      }
                 // updated old for loop to SOQL For Loop   -- DINESH
                for(id bnftId : accBenefits){
                    if(benefitEntitlementMap.containsKey(bnftId)){
                            if(benefitEntitlementMap.get(bnftId) != null && !benefitEntitlementMap.get(bnftId).IsEmpty() && (accEntilementNotUpdate.isEmpty() ||  (!accEntilementNotUpdate.containskey(acc.id) || !accEntilementNotUpdate.get(acc.id).contains(bnftId))) ){ // updated by Dinesh
                            for(String key: benefitEntitlementMap.get(bnftId).keyset()){
                                if(accEntitlements.containsKey(key)){
                                  accEntitlements.get(key).addAll(benefitEntitlementMap.get(bnftId).get(key));      
                                }else{
                  List<PRM_VXEnttlmntMatrix__c> entListTemp = new List<PRM_VXEnttlmntMatrix__c>();
                  entListTemp.addAll(benefitEntitlementMap.get(bnftId).get(key));
                                    accEntitlements.put(key, entListTemp);    
                                }
                                    
                            }
                                
                    }
                }
                        
                }
                accEntitlementsMap.put(acc.Id, accEntitlements);
            }
        }
        
            //Fetching ACR records of the att.accounts which is picked by the batch job to process.
            //acrRecords = [Select id,PRM_Account_Id__r.Name,PRM_Relationship_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__c, PRM_Contact_Id__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Partner_Role__c,PRM_Contact_Id__r.Name,PRM_Status_Nm__c,PRM_Contact_Id__r.Core_Login_Status__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :finalAccList AND  PRM_InActive_Ind__c!= true AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status AND (PRM_Contact_Id__r.Core_Login_Status__c =:System.Label.PRM_Status_Active OR (PRM_Contact_Id__r.Core_Login_Status__c =:System.Label.IPA_Downgrade_to_B2C AND PRM_Source_Agent__c!= 'Admin Invite')OR PRM_Contact_Id__r.Core_Login_Status__c = '')];
        //TWC729-7584 - ApexGuru
        acrRecords = [Select id,PRM_Account_Id__r.Name,PRM_Relationship_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__c, PRM_Contact_Id__c,PRM_Contact_Id__r.Core_IPA_PartnerRole__c,PRM_Partner_Role__c,PRM_Contact_Id__r.Name,PRM_Status_Nm__c,PRM_Contact_Id__r.Core_Login_Status__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :finalAccList AND LastmodifiedBy.name!='IPA Data Migration User'  AND  PRM_InActive_Ind__c=false AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status AND (PRM_Contact_Id__r.Core_Login_Status__c =:System.Label.PRM_Status_Active OR (PRM_Contact_Id__r.Core_Login_Status__c =:System.Label.IPA_Downgrade_to_B2C AND PRM_Source_Agent__c IN ('Partner Invite','Bulk Invite','Bulk Add','Self Registration','External Partner Invite','')) OR PRM_Contact_Id__r.Core_Login_Status__c = '')];
        logEntryMsgString+='\n\nacrRecords returned:'+acrRecords;
        List<PRM_Batch_Entitlement__c> beListTemp = new List<PRM_Batch_Entitlement__c>();
        
        List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
        Set<Id> conId = new Set<Id>();        
    
    for(PRM_Account_Contact_Relationship__c acr:acrRecords){
      conId.add(acr.PRM_Contact_Id__c);  
    }
    
    Map<String, Core_Contact_Entitlement__c> inactiveContEntMap = new Map<String, Core_Contact_Entitlement__c>();
    Map<Id, List<Id>> existingContEntMap = new Map<Id, List<Id>>();
    if((conId !=null && !conId.IsEmpty()) && (entId !=null && !entId.IsEmpty())){
            for(Core_Contact_Entitlement__c ce:  [Select Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Source__c,Core_From_Source__c From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :conId AND Core_Entitlement_Id__c IN :entId]){
        if(ce.Core_Selected__c == false){
          inactiveContEntMap.put(ce.Core_Contact_Id__c+'-'+ce.Core_Entitlement_Id__c, ce);
        }else{
          List<Id> entIdListTemp = existingContEntMap.containsKey(ce.Core_Contact_Id__c)? existingContEntMap.get(ce.Core_Contact_Id__c):new List<Id>() ;
          entIdListTemp.add(ce.Core_Entitlement_Id__c);
          existingContEntMap.put(ce.Core_Contact_Id__c, entIdListTemp);        
        }
      }
        }
    
    
        if(acrRecords != null && !acrRecords.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acr :acrRecords){
                Map<String, List<PRM_VXEnttlmntMatrix__c>> entitlementMap = new Map<String, List<PRM_VXEnttlmntMatrix__c>>();
        Set<PRM_VXEnttlmntMatrix__c> entitlements = new Set<PRM_VXEnttlmntMatrix__c>();
        List<PRM_VXEnttlmntMatrix__c> entitlementsList = new List<PRM_VXEnttlmntMatrix__c>();                
                //Sheetal opid Benefit Changes Start
                
                if(mapOfChildToParentAccount.containsKey(acr.PRM_Account_Id__c) && mapOfChildToParentAccount.get(acr.PRM_Account_Id__c) != null && accEntitlementsMap.containsKey(mapOfChildToParentAccount.get(acr.PRM_Account_Id__c)) && accEntitlementsMap.get(mapOfChildToParentAccount.get(acr.PRM_Account_Id__c)) != null && !accEntitlementsMap.get(mapOfChildToParentAccount.get(acr.PRM_Account_Id__c)).isEmpty()){
                    entitlementMap.putAll(accEntitlementsMap.get(mapOfChildToParentAccount.get(acr.PRM_Account_Id__c))); 
                }
                //Sheetal opid Benefit Changes End
                if(accEntitlementsMap.containsKey(acr.PRM_Account_Id__c))
                  entitlementMap.putAll(accEntitlementsMap.get(acr.PRM_Account_Id__c)); 
                
                //Sheetal opid Benefit Changes End
        PRM_AccountChannelMembership__c acm;
        if(acmMap !=null && !acmMap.IsEmpty() && acmMap.KeySet().contains(acr.PRM_Account_Id__c+'-'+acr.PRM_Partner_Role__c)){
          acm = acmMap.get(acr.PRM_Account_Id__c+'-'+acr.PRM_Partner_Role__c);
        }
            
        String keyForEnt = acr.PRM_Partner_Role__c + '-' + acr.PRM_Relationship_Id__c;
                
                if(entitlementMap.containsKey(keyForEnt)){
                  entitlements.addAll(entitlementMap.get(keyForEnt));
                }        
                //IPA 2.0 refresh : Dinesh [Partner and Prestige Tier Addition]
                if(acm != null && acm.PRM_Channel_Program_Level_Id__r.Name == 'Partner'){
                    if(entitlementWithoutBenefitmap.containsKey(keyForEnt + '-' + 'Partner')){
                        entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt + '-' + 'Partner'));
                    }
                }else if(acm != null && acm.PRM_Channel_Program_Level_Id__r.Name == 'Prestige'){
                    if(entitlementWithoutBenefitmap.containsKey(keyForEnt + '-' + 'Prestige')){
                        entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt + '-' + 'Prestige'));
                    }
                    if(entitlementWithoutBenefitmap.containsKey(keyForEnt + '-' + 'Partner')){
                        entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt + '-' + 'Partner'));
                    }
                    
                }/*else if(acm != null && acm.PRM_Channel_Program_Level_Id__r.Name == 'Titanium'){
            if(entitlementWithoutBenefitmap.containsKey(keyForEnt + '-' + 'Titanium')){
                                entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt + '-' + 'Titanium'));
                        }
                        if(entitlementWithoutBenefitmap.containsKey(keyForEnt  + '-' + 'Gold')){
                            entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt  + '-' + 'Gold'));
                        }
                        if(entitlementWithoutBenefitmap.containsKey(keyForEnt  + '-' + 'Member')){
                            entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt  + '-' + 'Member'));
                        }
            }else if(acm != null && acm.PRM_Channel_Program_Level_Id__r.Name == 'Gold'){
                        if(entitlementWithoutBenefitmap.containsKey(keyForEnt  + '-' + 'Gold')){
                entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt  + '-' + 'Gold'));
                        }
                        if(entitlementWithoutBenefitmap.containsKey(keyForEnt  + '-' + 'Member')){
                entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt  + '-' + 'Member'));
                        }
            }else if(acm != null && entitlementWithoutBenefitmap.containsKey(keyForEnt  + '-' + 'Member')){
            entitlements.addAll(entitlementWithoutBenefitmap.get(keyForEnt  + '-' + 'Member'));
        }  */                                      
                
                entitlementsList.addAll(entitlements);
                
                if(entitlementsList != null && !entitlementsList.IsEmpty()){ // Assigning entitlements based on the benefits get assigned.
                    for(integer i=0; i<entitlementsList.size(); i++){
                      
                        if(!existingContEntMap.containsKey(acr.PRM_Contact_Id__c) || !existingContEntMap.get(acr.PRM_Contact_Id__c).contains(entitlementsList[i].PRM_Entitlement_Id__c)){
                           // entId.add(entitlements[i].PRM_Entitlement_Id__c);                            
                            Core_Contact_Entitlement__c ce = inactiveContEntMap.containsKey(acr.PRM_Contact_Id__c+'-'+entitlementsList[i].PRM_Entitlement_Id__c)? inactiveContEntMap.get(acr.PRM_Contact_Id__c+'-'+entitlementsList[i].PRM_Entitlement_Id__c) : new Core_Contact_Entitlement__c();
                            if(ce.Core_Contact_Id__c == null){
                              ce.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                            }
                            ce.Core_Entitlement_Id__c = entitlementsList[i].PRM_Entitlement_Id__c;
                            ce.Core_Selected__c = true;
                            ce.Core_Data_Loaded__c = true;
                            ce.Core_DontNotify__c = true;
                            ce.Core_From_Source__c = false;
                            if(entitlementsList[i].PRM_AGS_Role__c == '' || entitlementsList[i].PRM_AGS_Role__c == null){
                                ce.Core_From_Source__c = true;
                            }
                            ce.Core_Status__c = 'Pending';
              
                            if(!finalCEList.contains(ce)){                          
                              finalCEList.add(ce);
                                beCon.add(ce.Core_Contact_Id__c);
                                beEnt.add(ce.Core_Entitlement_Id__c);
                            }
                            
                        }
                    }
                }               
            }
        }
    
                    
         logEntryMsgString+='\n\nfinalCEList identified:'+finalCEList;
        if(!isAdminProcess){
          
            if(finalCEList != null && !finalCEList.IsEmpty()){
                
                    Database.UpsertResult[] upsertfinalCEList = Database.upsert(finalCEList, false);
                    for (Database.UpsertResult sr : upsertfinalCEList ) {
                        if(!sr.isSuccess()){
                            Core_Log_Entry.logEntryWithDetails('PRM_BenefitUtility', 'IPA', 'Contact Entitlement record', 'exception', 'Exception occured while inserting Contact Entitlement', sr.getErrors()[0].getMessage(), sr.getId(), 'Core_Contact_Entitlement__c', 'Core_Contact_Entitlement__c');
                        }
                                 
                }
            }
        }
        Set<String> nonProccessedBERecord = new Set<String>();
       
        // UPDATED by DINESH - to AVOID Upserting existing BE Record to Success - TWC727-711
        if(isAdminProcess){ // Inserting/Updating Batch Entitlements records.
            if((beCon != null && !beCon.IsEmpty()) && (beEnt != null && !beEnt.IsEmpty())){ // Updating batch entitlement records.
                for(PRM_Batch_Entitlement__c batchEntitlements :[Select Id, Name, PRM_Contact_Id__c,PRM_Entitlement_Id__c,PRM_Status_Nm__c/*,PRM_IsRemove_Ind__c*/ From PRM_Batch_Entitlement__c Where (PRM_Status_Nm__c = 'New' OR PRM_Status_Nm__c = 'In Progress') AND PRM_Contact_Id__c IN:beCon AND PRM_Entitlement_Id__c IN :beEnt]){//ATHR Fix - TWC729-9556 - SJ
                    nonProccessedBERecord.add(batchEntitlements.PRM_Contact_Id__c+'_'+batchEntitlements.PRM_Entitlement_Id__c);
                }
            }
            if(finalCEList != null && !finalCEList.IsEmpty()){
                for(Core_Contact_Entitlement__c ce :finalCEList){ // Inserting batch entitlement records.
                String key = ce.Core_Contact_Id__c+'_'+ce.Core_Entitlement_Id__c;                  
                    PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                    be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                    be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                    be.PRM_Status_Nm__c = 'New';
                    be.PRM_Status_Reason_Txt__c ='PRM_BenefitUtility : Activation of Entitlement' ;//TWC729-8089 : Adding reason text : NJ
                  if(!nonProccessedBERecord.contains(key) && !beListTemp.Contains(be)){                    
                        beListTemp.add(be);
                    }
                }
            }
                
         
            If(beListTemp != null && !beListTemp.IsEmpty()){
                logEntryMsgString+='\n\nupserting batch entitlements'+beListTemp;
                upsert beListTemp;
            }
            
        }
        
        PRM_IPA_Utility.createLogEntry(logEntryMsgString, 'PRM_BenefitUtility', 'IPA', null, 'info', '');
    }
    //US773368 - Method to remove the vxData and vx Recommendation Records on ACM inactivation 
    public static void removeVXDataRecords(List<PRM_AccountChannelMembership__c> acmInactiveList){
        List<PRM_Value_Exchange_Data__c> toDelVXDataRecsList = new List<PRM_Value_Exchange_Data__c>();
        List<PRM_Value_Exchange_Recommendation__c> toDelVxRecomRecsList = new List<PRM_Value_Exchange_Recommendation__c>(); //TWC729-6800 EOL activities
        List<String> inActiveACMCombinationList = new List<String>();
        List<Id> accIdList = new List<Id>();
        List<String> partnerRoleList = new List<String>();
        List<Id> tierIdList = new List<Id>();
        List<Id> deletedRecOpidList = new List<Id>();
        List<String> deletedRecOpidCombination = new List<String>();
        List<PRM_Value_Exchange_Data__c> toUpdatevxDataRecsList = new List<PRM_Value_Exchange_Data__c>();
        List<Id> toUpdatevxDataAccsList = new List<Id>();
        List<String> toUpdateVXDataCombination = new List<String>();

        List<Id> accountWithAcmActiveList= new List<Id>();
        
        if(acmInactiveList != null && !acmInactiveList.isEmpty()){
            for(PRM_AccountChannelMembership__c acm:acmInactiveList){
                if(acm.PRM_Status_Nm__c == System.label.PRM_Status_Inactive){
                    String acmCombination = acm.PRM_Account_Id__c /*+ SYM_SEMICOL + acm.PRM_Partner_Role__c*/ + SYM_SEMICOL + acm.PRM_Channel_Program_Level_Id__c; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                    inActiveACMCombinationList.add(acmCombination);
                    if(!accIdList.contains(acm.PRM_Account_Id__c)){
                        accIdList.add(acm.PRM_Account_Id__c);
                    }
                    /*if(!partnerRoleList.contains(acm.PRM_Partner_Role__c)){
                        partnerRoleList.add(acm.PRM_Partner_Role__c);
                    }*/ // IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                    if(!tierIdList.contains(acm.PRM_Channel_Program_Level_Id__c)){
                        tierIdList.add(acm.PRM_Channel_Program_Level_Id__c);
                    }
                }
            }

             for(PRM_AccountChannelMembership__c acmactive : [Select PRM_Account_Id__c From PRM_AccountChannelMembership__c Where PRM_Status_Nm__c =:System.Label.PRM_Status AND PRM_Account_Id__c IN :accIdList AND PRM_Partner_Role__c != null ]){
                accountWithAcmActiveList.add(acmactive.PRM_Account_Id__c);
             }

            if(inActiveACMCombinationList != null &&  accIdList != null /*&& partnerRoleList != null*/ && tierIdList != null){
                for(PRM_Value_Exchange_Data__c vx:[Select Id,PRM_Account_Id__c,PRM_One_Partner_Id__c, /*PRM_Partner_Role_Nm__c,*/PRM_Tier_Id__c from PRM_Value_Exchange_Data__c where PRM_Account_Id__c in :accIdList and PRM_Tier_Id__c in :tierIdList /*and PRM_Partner_Role_Nm__c in :partnerRoleList*/]){ //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                    String vxAccCombination = vx.PRM_Account_Id__c /*+ SYM_SEMICOL + vx.PRM_Partner_Role_Nm__c*/ + SYM_SEMICOL + vx.PRM_Tier_Id__c; //IPA Refresh 2.0 - Removed partner role as part of TWC729-8087
                    if(inActiveACMCombinationList.contains(vxAccCombination) && (!(accountWithAcmActiveList.contains(vx.PRM_Account_Id__c)))){
                        toDelVXDataRecsList.add(vx);
                    }
                }
        
                if(toDelVXDataRecsList != null && !toDelVXDataRecsList.isEmpty()){
                    try {
                       
                        delete toDelVXDataRecsList;
                    } catch (Exception e) {
                      Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', e.getMessage() ,'' ,'PRM_BenefitUtility' ,'' ,e);    
                    }
                }
                
            }
        }
    }
    public static void assignBenefit(List<Id> accIdList,Map<string,Set<String>> mapOfAccountAndBenifit,  Map<Id,List<String>> partnerBenefitMap,Map<String,List<Id>> benefitMap,List<Id> partnerBenefitIdList , Map<string,Set<Id>> mapOfAccountAndBenifitId)
    {
        if(accIdList != null && !accIdList.IsEmpty()){
         for(Id accid :accIdList){
        List<Id> specBenefitListTemp =new List<Id>();
        List<String> specPartnerBenefitList =new List<String>();
        if(mapOfAccountAndBenifit.get(accid) != null && !mapOfAccountAndBenifit.get(accid).IsEmpty())
        {
            for(String benefit : mapOfAccountAndBenifit.get(accid)){
                if(partnerBenefitMap.get(accid) == null || partnerBenefitMap.get(accid).IsEmpty()){
                    specPartnerBenefitList.add(benefit);
                }
                else if(partnerBenefitMap.get(accid) != null){
                    specPartnerBenefitList = partnerBenefitMap.get(accid);
                    if(!specPartnerBenefitList.contains(benefit)){
                        specPartnerBenefitList.add(benefit);

                    }
                }
            }
        }
        if(mapOfAccountAndBenifitId.get(accid) != null && !mapOfAccountAndBenifitId.get(accid).IsEmpty())
        {
            for(Id benefit : mapOfAccountAndBenifitId.get(accid)){
                if(benefitMap.get(accid) == null || benefitMap.get(accid).IsEmpty()){
                    specBenefitListTemp.add(benefit);
                }
                else if(benefitMap.get(accid) != null){
                    specBenefitListTemp = benefitMap.get(accid);
                    if(!specBenefitListTemp.contains(benefit)){
                        specBenefitListTemp.add(benefit);
                    }
                }
                if(partnerBenefitIdList == null || partnerBenefitIdList.IsEmpty()){
                    partnerBenefitIdList.add(benefit);
                }
                else if(!partnerBenefitIdList.contains(benefit)){
                    partnerBenefitIdList.add(benefit);
                }
            }
        }
        if(specPartnerBenefitList != null && !specPartnerBenefitList.IsEmpty()){   
        partnerBenefitMap.put(accid,specPartnerBenefitList);
        }
        if(specBenefitListTemp != null && !specBenefitListTemp.IsEmpty()){   
            benefitMap.put(accid,specBenefitListTemp);
        }
    }
}
 }
//ATHR Fix - TWC729-9556 - SJ
 /*public static void fetchingAndAssociatingBenefitsFromSpecialityAndBenefitGroup(Set<string> setOfSpeciality,Map<string,Set<string>> mapOfspecialityAndListOgBenifitGroup,Set<string> benifitGroup, Map<string,Set<String>> mapOfBenifitGroupToBenifit, Map<string,Set<Id>> mapOfBenifitGroupToBenifitId,Map<string,Set<String>> mapOfSpeacailityIdAndBenifitId,Map<string,Set<Id>> mapOfSpeacailityAndBenifit,Map<String,Set<String>> mapOfAccountIdAndSpeciality, Map<string,Set<String>> mapOfAccountAndBenifit, Map<string,Set<Id>> mapOfAccountAndBenifitId)
 {
    //Fetching benefit group from speciality. 
    if(setOfSpeciality !=null && !setOfSpeciality.isEmpty()){
       for(PRM_Specialty_Benefit_Group_Association__c sbgRecord: [select id,name,PRM_Specialty_Id__c,PRM_Benefit_Group_Id__c,PRM_Specialty_Id__r.name from PRM_Specialty_Benefit_Group_Association__c where PRM_Specialty_Id__r.name IN: setOfSpeciality AND PRM_InActive_Ind__c = false AND PRM_Benefit_Group_Id__c != null]){
           if(mapOfspecialityAndListOgBenifitGroup.containskey(sbgRecord.PRM_Specialty_Id__r.name)){
               Set<string> setOfbenifitGroup = mapOfspecialityAndListOgBenifitGroup.get(sbgRecord.PRM_Specialty_Id__r.name);
               setOfbenifitGroup.add(sbgRecord.PRM_Benefit_Group_Id__c);
               mapOfspecialityAndListOgBenifitGroup.put(sbgRecord.PRM_Specialty_Id__r.name,setOfbenifitGroup);
       
           }
           else{
               mapOfspecialityAndListOgBenifitGroup.put(sbgRecord.PRM_Specialty_Id__r.name, new Set<string> {sbgRecord.PRM_Benefit_Group_Id__c} );  
           }
           benifitGroup.add(sbgRecord.PRM_Benefit_Group_Id__c); 
       }     
   }
  
   //Fetching benefits from benefit group.
   //Added Check of PRM_Status_Nm__c in BGBA Query as part of US : US594299 I4
   if(benifitGroup !=null && !benifitGroup.isEmpty()){
       for(PRM_Benefit_Group_Benefit_Association__c bgbRecord: [select id,name,PRM_Benefit_Id__c,PRM_Benefit_Id__r.Name,PRM_Benefit_Group_Id__c from PRM_Benefit_Group_Benefit_Association__c where PRM_Benefit_Group_Id__c In:benifitGroup AND PRM_InActive_Ind__c = false AND PRM_Benefit_Id__c != null AND PRM_Status_Nm__c ='Live']){
           if(mapOfBenifitGroupToBenifit.containskey(bgbRecord.PRM_Benefit_Group_Id__c)){
               
               Set<String> setOfBenifitofBG = mapOfBenifitGroupToBenifit.get(bgbRecord.PRM_Benefit_Group_Id__c);
               Set<Id> setOfBenifitofBGId = mapOfBenifitGroupToBenifitId.get(bgbRecord.PRM_Benefit_Group_Id__c);
               setOfBenifitofBG.add(bgbRecord.PRM_Benefit_Id__r.Name);
               setOfBenifitofBGId.add(bgbRecord.PRM_Benefit_Id__c);
               mapOfBenifitGroupToBenifit.put(bgbRecord.PRM_Benefit_Group_Id__c,setOfBenifitofBG);
               mapOfBenifitGroupToBenifitId.put(bgbRecord.PRM_Benefit_Group_Id__c,setOfBenifitofBGId);
           } 
           else{
               mapOfBenifitGroupToBenifit.put(bgbRecord.PRM_Benefit_Group_Id__c, new Set<string> {bgbRecord.PRM_Benefit_Id__r.Name});
               mapOfBenifitGroupToBenifitId.put(bgbRecord.PRM_Benefit_Group_Id__c, new Set<Id> {bgbRecord.PRM_Benefit_Id__c});                     
           }
       }   
   }
  
   // Associating speciality with benefits.
   if(mapOfspecialityAndListOgBenifitGroup.keyset() != null && !mapOfspecialityAndListOgBenifitGroup.keyset().isEmpty())
   {
       for(string str: mapOfspecialityAndListOgBenifitGroup.keyset()){
           Set<string> listOfBenifit = new Set<string>();
           Set<Id> listOfBenifitId = new Set<Id>();
           for(string lstOfBG: mapOfspecialityAndListOgBenifitGroup.get(str)){
               if(lstOfBG != null){
                   if(mapOfBenifitGroupToBenifit.containskey(lstOfBG)){
                       listOfBenifit.addall(mapOfBenifitGroupToBenifit.get(lstOfBG));  
                   }
                   if(mapOfBenifitGroupToBenifitId.containskey(lstOfBG)){
                       listOfBenifitId.addall(mapOfBenifitGroupToBenifitId.get(lstOfBG));  
                   }                           
               }
           }
           if(listOfBenifit != null && !listOfBenifit.IsEmpty()){
               mapOfSpeacailityIdAndBenifitId.put(str,listOfBenifit);
           }
           if(listOfBenifitId != null && !listOfBenifitId.IsEmpty()){
               mapOfSpeacailityAndBenifit.put(str,listOfBenifitId);
           }
       }  
   }

  //Associating account with benefits.

   if(mapOfAccountIdAndSpeciality.keyset() !=null && !mapOfAccountIdAndSpeciality.keyset().isEmpty())
         {
             for (string str: mapOfAccountIdAndSpeciality.keyset()){
                 Set<string> listOfSpecialityForObj = new Set<string>();
                 Set<Id> listOfSpecialityIdForObj = new Set<Id>();
                 for(string strObj: mapOfAccountIdAndSpeciality.get(str)){
                 if(strObj !=null){
                     if(mapOfSpeacailityIdAndBenifitId.containskey(strObj)){
                         listOfSpecialityForObj.addall(mapOfSpeacailityIdAndBenifitId.get(strObj));   
                     }
                     if(mapOfSpeacailityAndBenifit.containskey(strObj)){
                         listOfSpecialityIdForObj.addall(mapOfSpeacailityAndBenifit.get(strObj));   
                     }                           
                 } 
                 }                   
                 if(listOfSpecialityForObj != null && !listOfSpecialityForObj.IsEmpty()){
                     mapOfAccountAndBenifit.put(str,listOfSpecialityForObj);
                 }
                 if(listOfSpecialityIdForObj != null && !listOfSpecialityIdForObj.IsEmpty()){
                     mapOfAccountAndBenifitId.put(str,listOfSpecialityIdForObj);
                 }
             }    
         }

 }*/
}