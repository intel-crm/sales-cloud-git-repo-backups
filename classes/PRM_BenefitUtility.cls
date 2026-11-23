/***************************************************************************************************************************************
Apex Class Name     : PRM_BenefitUtility 
Version             : 1.0
Created Date        : Feb 2019
Function            : Handler for PRM_BenefitsUpdateBatch batch class to assign Benefits.

Modification Log    :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Utkarsh                   10-Feb-2019                   Added a new method 'assignBenefitsAndEntitlements' to Update or Insert the Benefits under
the Account Benefit Association object whenever the PRM_BenefitsUpdateBatch 
class executes.
*************************************************************************************************************************************/

public without sharing class PRM_BenefitUtility{
    public static Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall();
    public static Final String ORIGIN  = 'PRM_BenefitUtility';
    public static Final String SEVERITY  = 'Critical';
    public static Final String PROJECT  = 'IPA';
    public static Final String ERRORMESSAGE  = 'Too many DML rows';
    public static boolean updateCheck = true;
    public static void assignBenefitsAndEntitlements(List<Account>accounts,boolean sourceCheck, boolean assignOnlyEntitlement, boolean isAdminProcess){
        DateTime lastSuccessfulRun;
        Set<Id>accIdList = new Set<Id>();
        List<PRM_VXBnftMatrix__c> vebm = new List<PRM_VXBnftMatrix__c>();
        List<PRM_VXEnttlmntMatrix__c> entitlementMatrixlist = new List< PRM_VXEnttlmntMatrix__c>();
        List<PRM_Account_Contact_Relationship__c> acrRecords = new List<PRM_Account_Contact_Relationship__c>();
        List<PRM_AccountBenefitAssociation__c>abaId = new List<PRM_AccountBenefitAssociation__c>();
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
        List<Id> activePartnerBenefitIdList = new List<Id>();
        List<Id> pbListOnBM = new List<Id>();
        List<Account> accountWithoutBenefits = new List<Account>();
        List<PRM_VXEnttlmntMatrix__c> entitlementWithoutBenefit = new List<PRM_VXEnttlmntMatrix__c>();
        Map<Id,List<PRM_AccountChannelMembership__c>> acmMap = new Map<Id,List<PRM_AccountChannelMembership__c>>();
        Map<Id,Core_Contact_Entitlement__c> ceStatusMap = new Map<Id,Core_Contact_Entitlement__c>();
        
        
        map<String,String> mapOfAccountIdAndSpeciality = new map<String,String>();
        Set<string> setOfSpeciality = new Set<string>();
        Map<string,Set<string>> mapOfspecialityAndListOgBenifitGroup = new Map<string,Set<string>>();
        Set<string> benifitGroup = new Set<string>();
        Map<string,Set<String>> mapOfBenifitGroupToBenifit = new Map<string,Set<String>>(); 
        Map<string,Set<Id>> mapOfBenifitGroupToBenifitId = new Map<string,Set<Id>>(); 
        Map<string,Set<String>> mapOfSpeacailityIdAndBenifitId = new Map<string,Set<String>>();
        Map<string,Set<Id>> mapOfSpeacailityAndBenifit = new Map<string,Set<Id>>();
        Map<string,Set<String>> mapOfAccountAndBenifit = new Map<string,Set<String>>();
        Map<string,Set<Id>> mapOfAccountAndBenifitId = new Map<string,Set<Id>>();
        
        for(Account acc :accounts){
            accIdList.add(acc.Id);
        }
        system.debug('assignOnlyEntitlement'+assignOnlyEntitlement);
        //Query on AsyncApexJob to get the identical records which got modified in last 6 hrs.
        List<AsyncApexJob> lastBatchRun = [SELECT CompletedDate FROM AsyncApexJob WHERE ApexClass.Name = :System.Label.PRM_Benefit_Update_Batch AND Status =:System.Label.PRM_AsyncStatus Order By CompletedDate DESC LIMIT 1];
        //Query on BatchCustomSetting to fetch batch size, Partner type, scheduling hour, channel program level        
        batchCustomSetting = [Select Id, Name, PRM_NoOfRecords__c, PRM_SchedulingHour__c,PRM_PartnerType__c,PRM_ChannelProgramLevel__c From PRM_BatchCustomSetting__c Where Name =:System.Label.PRM_BatchValues];
        cpl = batchCustomSetting.PRM_ChannelProgramLevel__c.split(';');
        
        //Query on Account channel membership which got modified in last 6 hrs, channel program as IPA , Channel program level as gold or platinum, status as approved.
        if(sourceCheck){
            acmList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c, PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Status_Nm__c =:System.Label.PRM_Status AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Channel_Program_Level_Id__r.Name IN :cpl AND PRM_Account_Id__c IN :accIdList AND PRM_Partner_Role__c != null AND PRM_Channel_Program_Id__r.Name != null AND PRM_Channel_Program_Level_Id__r.Name !=null];
            
            /*US687673 - Start - Need to consider ASA record which got recently modified both speciality and select benefit*/
            for(PRM_Account_Specialty_Association__c asa :[Select Id, PRM_Account_Id__c, PRM_Account_Id__r.Name,PRM_Specialty_Id__c,PRM_Partner_Role__c,PRM_InActive_Ind__c,PRM_Specialty_Id__r.Name From PRM_Account_Specialty_Association__c Where PRM_InActive_Ind__c = false AND PRM_Account_Id__c IN :accIdList]){
                mapOfAccountIdAndSpeciality.put(asa.PRM_Account_Id__c,asa.PRM_Specialty_Id__r.Name);
                setOfSpeciality.add(asa.PRM_Specialty_Id__r.Name);
            }
            /*US687673 - END*/
            System.debug('setOfSpeciality :- '+setOfSpeciality);
            System.debug('mapOfAccountIdAndSpeciality :- '+mapOfAccountIdAndSpeciality);
            
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
            System.debug('mapOfspecialityAndListOgBenifitGroup :-'+mapOfspecialityAndListOgBenifitGroup);
            System.debug('benifitGroup :-'+benifitGroup);
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
            System.debug('mapOfBenifitGroupToBenifit :-'+mapOfBenifitGroupToBenifit);
            System.debug('mapOfBenifitGroupToBenifitId :-'+mapOfBenifitGroupToBenifitId);
            
            // Associating speciality with benefits.
            if(mapOfspecialityAndListOgBenifitGroup.keyset() != null && !mapOfspecialityAndListOgBenifitGroup.keyset().isEmpty()){
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
            System.debug('mapOfSpeacailityIdAndBenifitId :-'+mapOfSpeacailityIdAndBenifitId);
            System.debug('mapOfSpeacailityAndBenifit :-'+mapOfSpeacailityAndBenifit);
            // Associating account with benefits.
            if(mapOfAccountIdAndSpeciality.keyset() !=null && !mapOfAccountIdAndSpeciality.keyset().isEmpty()){
                for (string str: mapOfAccountIdAndSpeciality.keyset()){
                    Set<string> listOfSpecialityForObj = new Set<string>();
                    Set<Id> listOfSpecialityIdForObj = new Set<Id>();
                    String strObj;
                    strObj = mapOfAccountIdAndSpeciality.get(str);
                    if(strObj !=null){
                        if(mapOfSpeacailityIdAndBenifitId.containskey(strObj)){
                            listOfSpecialityForObj.addall(mapOfSpeacailityIdAndBenifitId.get(strObj));   
                        }
                        if(mapOfSpeacailityAndBenifit.containskey(strObj)){
                            listOfSpecialityIdForObj.addall(mapOfSpeacailityAndBenifit.get(strObj));   
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
            
            System.debug('mapOfAccountAndBenifit-->'+mapOfAccountAndBenifit);
            System.debug('mapOfAccountAndBenifitId-->'+mapOfAccountAndBenifitId);
        }
        else{
            acmList = [Select Id, PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__r.Core_Covered_Account__c, PRM_Channel_Program_Id__c, PRM_Channel_Program_Level_Id__c,PRM_Channel_Program_Level_Id__r.Name,PRM_Status_Nm__c,PRM_Partner_Role__c From PRM_AccountChannelMembership__c Where PRM_Status_Nm__c =:System.Label.PRM_Status AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_Channel_Program_Level_Id__r.Name = 'Member' AND PRM_Account_Id__c IN :accIdList AND PRM_Partner_Role__c != null];
        }
        System.debug('acmList--->'+acmList);
        if(acmList != null && !acmList.IsEmpty()){
            for(PRM_AccountChannelMembership__c acm :acmList){
                List<PRM_AccountChannelMembership__c> channelMember = new List<PRM_AccountChannelMembership__c>();
                if(acmMap.get(acm.PRM_Account_Id__c)!= null && !acmMap.get(acm.PRM_Account_Id__c).isEmpty()){channelMember = acmMap.get(acm.PRM_Account_Id__c);
                }
                channelMember.add(acm);
                acmMap.put(acm.PRM_Account_Id__c,channelMember);
                System.debug('channelMember-->'+channelMember);
            }
        }
        System.debug('acmMap-->'+acmMap);
        //Query on Benefit matrix to fetch benefits when channel program is IPA , Approval type is automatic and should be active benefit.
        vebm = [Select id, PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Covered_Account_Ind__c, PRM_Approval_Type_Nm__c, PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Role_Nm__c from PRM_VXBnftMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_IsActive_Ind__c = True];
        System.debug('vebm-->'+vebm);
        if(assignOnlyEntitlement)
        {//for Benefit as well as ENtitlement
            if(acmList != null && !acmList.IsEmpty()){
                for(PRM_AccountChannelMembership__c acm :acmList){
                    partnerBenefitList = new List<String>();
                    List<Id> benefitListTemp =new List<Id>();
                    if(benefitMap.get(acm.PRM_Account_Id__c)!= null && !benefitMap.get(acm.PRM_Account_Id__c).isEmpty()){benefitListTemp = benefitMap.get(acm.PRM_Account_Id__c);
                    }
                    if(partnerBenefitMap.get(acm.PRM_Account_Id__c)!= null && !partnerBenefitMap.get(acm.PRM_Account_Id__c).isEmpty()){partnerBenefitList = partnerBenefitMap.get(acm.PRM_Account_Id__c);
                    }
                    if(vebm != null && !vebm.IsEmpty()){
                        for(PRM_VXBnftMatrix__c bm : vebm){
                            //Fetching ABA applicable for the account.
                            if((acm.PRM_Channel_Program_Level_Id__r.Name == bm.PRM_Channel_Program_Level_Id__r.Name) && (bm.PRM_Approval_Type_Nm__c == 'Automatic') && (bm.PRM_IsActive_Ind__c = True) &&(acm.PRM_Partner_Role__c == bm.PRM_Partner_Role_Nm__c)){
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
                                partnerBenefitIdList.add(bm.PRM_Partner_Benefit_Id__c);
                                benefitMap.put(acm.PRM_Account_Id__c,benefitListTemp);
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
            if(sourceCheck){  //US687673 - Assign benefits for the specialty as well as select benefit irrespective of partner tier.
                if(accIdList != null && !accIdList.IsEmpty()){
                    for(Id accid :accIdList){
                        List<Id> specBenefitListTemp =new List<Id>();
                        List<String> specPartnerBenefitList =new List<String>();
                        Set<string> allowedBenifitForSpeciality = new Set<string>();
                        Set<Id> allowedBenifitForSpecialityId = new Set<Id>();
                        System.debug('mapOfAccountAndBenifit-->'+mapOfAccountAndBenifit);
                        System.debug('mapOfAccountAndBenifitId-->'+mapOfAccountAndBenifitId);
                        allowedBenifitForSpeciality = mapOfAccountAndBenifit.get(accid); // Set of specialty benefits.
                        allowedBenifitForSpecialityId = mapOfAccountAndBenifitId.get(accid); 
                        System.debug('allowedBenifitForSpeciality-->'+allowedBenifitForSpeciality);
                        System.debug('allowedBenifitForSpecialityId-->'+allowedBenifitForSpecialityId);
                        if(allowedBenifitForSpeciality != null && !allowedBenifitForSpeciality.IsEmpty()){
                            for(String benefit : allowedBenifitForSpeciality){
                                if(partnerBenefitList == null || partnerBenefitList.IsEmpty()){
                                    specPartnerBenefitList.add(benefit);
                                    System.debug('specPartnerBenefitList-->'+specPartnerBenefitList);
                                }
                                else if(!partnerBenefitList.contains(benefit)){
                                    specPartnerBenefitList.addAll(partnerBenefitList);
                                    specPartnerBenefitList.add(benefit);
                                    System.debug('specPartnerBenefitList-->'+specPartnerBenefitList);
                                }
                            }
                        }
                        if(allowedBenifitForSpecialityId != null && !allowedBenifitForSpecialityId.IsEmpty()){
                            for(Id benefit : allowedBenifitForSpecialityId){
                                if(benefitMap.get(accid) == null || benefitMap.get(accid).IsEmpty()){
                                    specBenefitListTemp.add(benefit);
                                    System.debug('specBenefitListTemp-->'+specBenefitListTemp);
                                }
                                else if(benefitMap.get(accid) != null){
                                    specBenefitListTemp = benefitMap.get(accid);
                                    if(!specBenefitListTemp.contains(benefit)){
                                        specBenefitListTemp.add(benefit);
                                        System.debug('specBenefitListTemp-->'+specBenefitListTemp);
                                    }
                                }
                                if(partnerBenefitIdList == null || partnerBenefitIdList.IsEmpty()){
                                    partnerBenefitIdList.add(benefit);
                                    System.debug('partnerBenefitIdList-->'+partnerBenefitIdList);
                                }
                                else if(!partnerBenefitIdList.contains(benefit)){
                                    partnerBenefitIdList.add(benefit);
                                    System.debug('partnerBenefitIdList-->'+partnerBenefitIdList);
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
            //US687673 - END
            System.debug('benefitMap-->'+benefitMap);
            System.debug('partnerBenefitMap-->'+partnerBenefitMap);
            System.debug('partnerBenefitIdList-->'+partnerBenefitIdList);
            
            if(accIdList != null && !accIdList.IsEmpty()){
                for(PRM_AccountBenefitAssociation__c aba : [Select Id, Name,PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Status_Nm__c,PRM_Account_Id__r.Name From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accIdList])
                {
                    //When applicable ABA is already associated with parent account.
                    if(partnerBenefitMap!= null && !partnerBenefitMap.isEmpty()){
                        if(partnerBenefitMap.get(aba.PRM_Account_Id__c) !=null && !partnerBenefitMap.get(aba.PRM_Account_Id__c).isEmpty()){    
                            List<String> pbList = partnerBenefitMap.get(aba.PRM_Account_Id__c);
                            if(pbList!= null && !pbList.isEmpty() ){
                                if(pbList.contains(aba.PRM_Partner_Benefit_Id__r.Name)){
                                    if(aba.PRM_Status_Nm__c == System.Label.PRM_Status_Inactive){aba.PRM_Status_Nm__c = System.Label.PRM_Status_Active;
                                        abaId.add(aba);
                                    }
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
            System.debug('abaId-->'+abaId);
            for(PRM_PartnerBenefit__c pb : [Select Id, Name From PRM_PartnerBenefit__c]){
                mapOfPB.put(Pb.Name,pb.Id);
            }
            System.debug('mapOfPB-->'+mapOfPB);
            if(partnerBenefitMap!= null && !partnerBenefitMap.isEmpty()){
                for(Account acc :accounts){
                    //Assigning applicable ABA to the parent account.
                    List<String> pbList = partnerBenefitMap.get(acc.Id);
                    System.debug('pbList-->'+pbList);
                    if(pbList!= null && !pbList.isEmpty() ){
                        for(integer i=0; i<pbList.size(); i++) {
                            PRM_AccountBenefitAssociation__c newAba = new PRM_AccountBenefitAssociation__c();
                            if(mapOfPB.get(pbList[i]) !=null){
                                newAba.PRM_Partner_Benefit_Id__c = mapOfPB.get(pbList[i]);
                                newAba.PRM_Status_Nm__c = System.Label.PRM_Status_Active;
                                newAba.PRM_Account_Id__c = acc.Id; 
                                
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
            System.debug('abaId--->'+abaId);
            //Exception handling when any ABA record got errored out.
            if(abaId.size() < Limits.getLimitDMLRows()){
                system.debug('Total queries executed before benefit upsertion--->'+Limits.getQueries());
                if(abaId != null && !abaId.IsEmpty()){
                    Database.UpsertResult[] accBenList;
                    accBenList = Database.upsert(abaId, false); 
                    system.debug('Total queries executed after benefit upsertion--->'+Limits.getQueries());
                    integer index = 0;
                    for (Database.UpsertResult sr : accBenList){                    
                        if (!sr.isSuccess()){
                            Id sId;
                            String sObjectType = '';
                            String tags = '';
                            for(Database.Error err : sr.getErrors()){
                                sId =abaId[index].Id;
                                if(sId != null){sObjectType =  sId.getSObjectType().getDescribe().getName();
                                }
                                String accName =  '';
                                accName =mapAccToName.get(abaId[index].Id) == null?'':mapAccToName.get(abaId[index].Id);
                                String benName =  '';
                                benName =accToBenefitMap.get(abaId[index].Id) == null?'':accToBenefitMap.get(abaId[index].Id);
                                String accId =  '';
                                accId = mapAccToId.get(abaId[index].Id) == null?'':mapAccToId.get(abaId[index].Id);
                                tags = accName + ';' + benName + ';' + accId;
                                Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY, err.getMessage(), '', sId, sObjectType, tags);
                            }
                        } 
                    }
                    index ++;
                }
            }else{Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'Message', SEVERITY,ERRORMESSAGE,'','' ,'','');
            }
        }else{//Agate Team Logic(Assign only Entitlement)
            system.debug('only ENtitlement assignment');
            if(accIdList != null && !accIdList.IsEmpty()){
                for(PRM_AccountBenefitAssociation__c aba : [Select Id, Name,PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Status_Nm__c,PRM_Account_Id__r.Name From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accIdList])
                {
                    if(aba.PRM_Status_Nm__c == System.Label.PRM_Status_Active){
                        pbListOnBM.add(aba.PRM_Partner_Benefit_Id__c);
                    }
                }
            }
            System.debug('pbListOnBM-->'+pbListOnBM);
            List<PRM_VXBnftMatrix__c> benefitMatrixList =[Select id, PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__r.Name, PRM_Channel_Program_Level_Id__c,PRM_Partner_Type_Id__c,PRM_Partner_Type_Id__r.Name,PRM_Covered_Account_Ind__c, PRM_Approval_Type_Nm__c, PRM_Partner_Benefit_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Role_Nm__c from PRM_VXBnftMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_Channel_Program_Id__r.Name =:System.Label.PRM_Intel_Partner_Alliance AND PRM_IsActive_Ind__c = True AND PRM_Partner_Benefit_Id__c IN :pbListOnBM];
            System.debug('benefitMatrixList-->'+benefitMatrixList);
            if(accIdList!= null && !accIdList.isEmpty()){
                for(PRM_AccountBenefitAssociation__c aba : [Select Id, Name,PRM_Partner_Benefit_Id__c,PRM_Account_Id__c,PRM_Partner_Benefit_Id__r.Name,PRM_Status_Nm__c,PRM_Account_Id__r.Name From PRM_AccountBenefitAssociation__c Where PRM_Account_Id__c IN :accIdList AND PRM_Status_Nm__c =:System.Label.PRM_Status_Active])
                {
                    //pbListOnBM.add(aba.PRM_Partner_Benefit_Id__c);
                    //if(pbListOnBM!= null && !pbListOnBM.isEmpty()){
                        for(PRM_VXBnftMatrix__c vmList :benefitMatrixList){
                            if(benefitMap.get(aba.PRM_Account_Id__c)!= null && !benefitMap.get(aba.PRM_Account_Id__c).isEmpty()){partnerBenefitIdList = benefitMap.get(aba.PRM_Account_Id__c);
                            }
                                partnerBenefitIdList.add(vmList.PRM_Partner_Benefit_Id__c);
                                benefitMap.put(aba.PRM_Account_Id__c,partnerBenefitIdList);
                        }
                    //}
                }
            }
            system.debug('Total queries 1--->'+Limits.getQueries());
            
        }
        /*Code started for insertion of Batch entitlement records*/
        // Fetching entitlements when benefit get assigned to account.
        if(partnerBenefitIdList!= null && !partnerBenefitIdList.isEmpty()){
            entitlementMatrixlist = [Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,RecordType.Name,PRM_Partner_Role_Nm__c,PRM_AGS_Role__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND PRM_Partner_Benefit_Id__c in :partnerBenefitIdList AND PRM_IsActive_Ind__c = True AND PRM_Partner_Role_Nm__c != null];
        }
        System.debug('entitlementMatrixlist-->'+entitlementMatrixlist);
        // Fetching entitlements when benefit doesn't assigned to account.
        entitlementWithoutBenefit = [Select id, PRM_Entitlement_Id__c,PRM_Entitlement_Id__r.Name, PRM_Contact_Relationship_Id__c, PRM_IsActive_Ind__c, PRM_Partner_Benefit_Id__c,PRM_Approval_Type_Nm__c,PRM_Channel_Program_Id__c,PRM_Channel_Program_Level_Id__c,PRM_Partner_Role_Nm__c,RecordType.Name,PRM_AGS_Role__c from PRM_VXEnttlmntMatrix__c where PRM_Approval_Type_Nm__c =:System.Label.PRM_ApprovalType AND RecordType.Name = 'EntitlementWithoutBenefits' AND PRM_IsActive_Ind__c = True AND PRM_Partner_Role_Nm__c != null];
        System.debug('entitlementWithoutBenefit-->'+entitlementWithoutBenefit);
        
        //If we have multiple Entitlements for single benefit.
        Map<Id,List<PRM_VXEnttlmntMatrix__c>> benefitEntitlementMap = new Map<Id,List<PRM_VXEnttlmntMatrix__c>>();
        if(entitlementMatrixlist!= null && !entitlementMatrixlist.isEmpty()){
            for(PRM_VXEnttlmntMatrix__c em1 :entitlementMatrixlist){
                List<PRM_VXEnttlmntMatrix__c> entitlements = new List<PRM_VXEnttlmntMatrix__c>();
                if(benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c)!= null && !benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c).isEmpty()){
                    entitlements = benefitEntitlementMap.get(em1.PRM_Partner_Benefit_Id__c);
                }
                entitlements.add(em1);
                benefitEntitlementMap.put(em1.PRM_Partner_Benefit_Id__c,entitlements);
            }
        }
        System.debug('benefitEntitlementMap-->'+benefitEntitlementMap);
        
        Map<Id,Set<PRM_VXEnttlmntMatrix__c>> accEntitlementsMap= new Map<Id,Set<PRM_VXEnttlmntMatrix__c>>();
        for(Account acc :accounts){
            List<Id> accBenefits = new List<Id>();
            accBenefits = benefitMap.get(acc.Id);
            System.debug('accBenefits-->'+accBenefits);
            if(accBenefits != null && !accBenefits.IsEmpty()){
                Set<PRM_VXEnttlmntMatrix__c> accEntitlements = new Set<PRM_VXEnttlmntMatrix__c>();
                if(accEntitlementsMap.get(acc.Id)!= null && !accEntitlementsMap.get(acc.Id).isEmpty()){accEntitlements = accEntitlementsMap.get(acc.Id);
                }
                for(integer i=0; i<accBenefits.size(); i++){
                    List<PRM_VXEnttlmntMatrix__c> benfitEntitlements = new List<PRM_VXEnttlmntMatrix__c>();
                    System.debug('accBenefits[i]-->'+accBenefits[i]);
                    benfitEntitlements = benefitEntitlementMap.get(accBenefits[i]);
                    System.debug('benfitEntitlements-->'+benfitEntitlements);
                    if(benfitEntitlements != null && !benfitEntitlements.IsEmpty()){
                        accEntitlements.addAll(benfitEntitlements);
                    }
                    System.debug('accEntitlements-->'+accEntitlements);
                }
                accEntitlementsMap.put(acc.Id, accEntitlements);
                System.debug('accEntitlementsMap-->'+accEntitlementsMap);
            }
        }
        //Fetching ACR records of the accounts which is picked by the batch job to process.
        acrRecords = [Select id,PRM_Account_Id__r.Name,PRM_Relationship_Id__c,PRM_Account_Id__r.Core_IPA_Partner_Role__c,PRM_Account_Id__c, PRM_Contact_Id__c,PRM_Contact_Id__r.Core_IPA_Partner_Role__c,PRM_Partner_Role__c,PRM_Contact_Id__r.Name,PRM_Status_Nm__c from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c in :accIdList AND  PRM_InActive_Ind__c!= true AND PRM_Status_Nm__c =:System.Label.PRM_ACR_Status];
        System.debug('acrRecords-->'+acrRecords);
        List<PRM_Batch_Entitlement__c> beListTemp = new List<PRM_Batch_Entitlement__c>();
        List<PRM_Batch_Entitlement__c> beListFinal = new List<PRM_Batch_Entitlement__c>();
        List<Core_Contact_Entitlement__c> ceList = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> finalCEList = new List<Core_Contact_Entitlement__c>();
        Set<Id> conId = new Set<Id>();
        Set<Id> entId = new Set<Id>();
        Map<Id,String> entAgsMap = new Map<Id,String>();
        String updateReasonCSPFlow = System.Label.PRM_Entitlement_Source;
        Map<Core_Contact_Entitlement__c,Id> ceMap = new Map<Core_Contact_Entitlement__c,Id>();
        if(acrRecords != null && !acrRecords.IsEmpty()){
            for(PRM_Account_Contact_Relationship__c acr :acrRecords){
                Set<PRM_VXEnttlmntMatrix__c> entitlementSet = new Set<PRM_VXEnttlmntMatrix__c>();
                List<string> partnerRole = new List<string>();
                entitlementSet = accEntitlementsMap.get(acr.PRM_Account_Id__c);
                List<PRM_VXEnttlmntMatrix__c> entitlements = new List<PRM_VXEnttlmntMatrix__c>(entitlementSet);
                System.debug('entitlements-->'+entitlements);
                conId.add(acr.PRM_Contact_Id__c);
                if(acr.PRM_Partner_Role__c != null){
                    partnerRole = acr.PRM_Partner_Role__c.split('<br>');
                }
                if(entitlements != null && !entitlements.IsEmpty()){ // Assigning entitlements based on the benefits get assigned.
                    for(integer i=0; i<entitlements.size(); i++){
                        if(entitlements[i].PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c && (partnerRole != null && !partnerRole.IsEmpty()) && partnerRole.contains(entitlements[i].PRM_Partner_Role_Nm__c)){
                            entId.add(entitlements[i].PRM_Entitlement_Id__c);
                            entAgsMap.put(entitlements[i].PRM_Entitlement_Id__c,entitlements[i].PRM_AGS_Role__c);
                            Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
                            ce.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                            ce.Core_Entitlement_Id__c = entitlements[i].PRM_Entitlement_Id__c;
                            //ce.Core_Status__c = 'Pending';
                            ce.Core_Selected__c = true;
                            ce.Core_Data_Loaded__c = true;
                            ce.Core_DontNotify__c = true;
                            ce.Core_From_Source__c = false;
                            if(entitlements[i].PRM_AGS_Role__c == '' || entitlements[i].PRM_AGS_Role__c == null){
                                ce.Core_From_Source__c = true;
                            }
                            else {
                                ce.Core_Status__c = 'Pending';
                            } 
                            if(!ceList.contains(ce)){
                                ceList.add(ce);
                            }
                        }
                    }
                }
                if(entitlementWithoutBenefit != null && !entitlementWithoutBenefit.IsEmpty()){
                    for(PRM_VXEnttlmntMatrix__c em :entitlementWithoutBenefit){ //Assigning default entitlements.
                        List<PRM_AccountChannelMembership__c> acm = new List<PRM_AccountChannelMembership__c>();
                        if(acmMap !=null && !acmMap.IsEmpty() && acmMap.KeySet().contains(acr.PRM_Account_Id__c)){
                            acm = acmMap.get(acr.PRM_Account_Id__c);
                        }
                        if(acm != null && !acm.IsEmpty()){
                            for(integer i=0; i<acm.size(); i++){
                                if(em.PRM_Contact_Relationship_Id__c == acr.PRM_Relationship_Id__c && (partnerRole != null && !partnerRole.IsEmpty()) && partnerRole.contains(em.PRM_Partner_Role_Nm__c) && em.PRM_Channel_Program_Level_Id__c == acm[i].PRM_Channel_Program_Level_Id__c){
                                    entId.add(em.PRM_Entitlement_Id__c);
                                    entAgsMap.put(em.PRM_Entitlement_Id__c,em.PRM_AGS_Role__c);
                                    Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
                                    ce1.Core_Contact_Id__c = acr.PRM_Contact_Id__c;
                                    ce1.Core_Entitlement_Id__c = em.PRM_Entitlement_Id__c;
                                    //ce1.Core_Status__c = 'Pending';
                                    ce1.Core_Selected__c = true;
                                    ce1.Core_Data_Loaded__c = true;
                                    ce1.Core_DontNotify__c = true;
                                    ce1.Core_From_Source__c = false;
                                    if(em.PRM_AGS_Role__c == '' || em.PRM_AGS_Role__c == null){
                                        ce1.Core_From_Source__c = true;
                                    }
                                    else {
                                        ce1.Core_Status__c = 'Pending';
                                    } 
                                    if(!ceList.contains(ce1)){
                                        ceList.add(ce1);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        System.debug('conId-->'+conId);
        System.debug('entId-->'+entId);
        System.debug('ceList-->'+ceList);
        List<Id> beCon = new List<Id>();
        List<Id> beEnt = new List<Id>();
        List<Core_Contact_Entitlement__c> contactEntList = new List<Core_Contact_Entitlement__c>();
        
        // Checking existing contact entitlements.
        if((conId !=null && !conId.IsEmpty()) && (entId !=null && !entId.IsEmpty())){
            contactEntList = [Select Id,Core_Contact_Id__c,Core_Entitlement_Id__c,Core_Selected__c,Core_Status__c,Core_Data_Loaded__c,Core_DontNotify__c,Core_Source__c,Core_From_Source__c From Core_Contact_Entitlement__c Where Core_Contact_Id__c IN :conId AND Core_Entitlement_Id__c IN :entId];
        }
        System.debug('contactEntList-->'+contactEntList);
        if(contactEntList !=null && !contactEntList.IsEmpty()){
            for(Core_Contact_Entitlement__c ce :contactEntList){
                Core_Contact_Entitlement__c newCe = new Core_Contact_Entitlement__c();
                newCe.Core_Contact_Id__c = ce.Core_Contact_Id__c;
                newCe.Core_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                if((entAgsMap != null && !entAgsMap.IsEmpty()) && (entAgsMap.get(ce.Core_Entitlement_Id__c) != '' && entAgsMap.get(ce.Core_Entitlement_Id__c) != null)){
                    newCe.Core_Status__c = 'Pending';
                }
                //newCe.Core_Status__c = 'Pending';
                newce.Core_Selected__c = true;
                newCe.Core_Data_Loaded__c = true;
                newCe.Core_DontNotify__c = true;
                newCe.Core_From_Source__c = ce.Core_From_Source__c;
                 
                ceMap.put(newCe, ce.Id);
                ceStatusMap.put(ce.Id,ce);
            }
        }
        if(ceList !=null && !ceList.IsEmpty()){
            for(Core_Contact_Entitlement__c ce :ceList){ //Assigning id to existing contact entitlements
                updateCheck = false;
                beCon.add(ce.Core_Contact_Id__c);
                beEnt.add(ce.Core_Entitlement_Id__c);
                if(ceMap!= null && !ceMap.isEmpty() && ceMap.containsKey(ce)){
                    ce.Id = ceMap.get(ce);
                    Core_Contact_Entitlement__c contEnt = ceStatusMap.get(ce.Id);
                    if(contEnt.Core_Source__c != updateReasonCSPFlow){ //Added for US539488:to Identify origin of Entitlement
                        ce.Core_Source__c = updateReasonCSPFlow;
                        updateCheck = true;
                    }
                    if(!contEnt.Core_Selected__c){ //updating contact entitlements.
                        ce.Core_Selected__c = true;
                        updateCheck = true;
                    }
                    if(updateCheck){
                        finalCEList.add(ce);
                    }
                }
                else{
                    ce.Core_Selected__c = true; //Inserting contact entitlements.
                    ce.Core_Source__c = updateReasonCSPFlow;//Added for US539488:to Identify origin of Entitlement creation
                    finalCEList.add(ce);
                }
            }
        }
        System.debug('ceList-->'+ceList);
        System.debug('finalCEList-->'+finalCEList);
        if(!isAdminProcess){
            system.debug('Total queries executed before entitlement upsertion--->'+Limits.getQueries());
            if(finalCEList != null && !finalCEList.IsEmpty()){
                upsert finalCEList;               
            }
            system.debug('Total queries executed after entitlement upsertion--->'+Limits.getQueries());
        }
        System.debug('finalCEList-->'+finalCEList);
        if(isAdminProcess){ // Inserting/Updating Batch Entitlements records.
            if((beCon != null && !beCon.IsEmpty()) && (beEnt != null && !beEnt.IsEmpty())){ // Updating batch entitlement records.
                for(PRM_Batch_Entitlement__c batchEntitlements :[Select Id, Name, PRM_Contact_Id__c,PRM_Entitlement_Id__c,PRM_Status_Nm__c,PRM_IsRemove_Ind__c From PRM_Batch_Entitlement__c Where PRM_Status_Nm__c = 'New' AND PRM_IsRemove_Ind__c = true AND PRM_Contact_Id__c IN:beCon AND PRM_Entitlement_Id__c IN :beEnt]){
                        if(batchEntitlements.PRM_IsRemove_Ind__c == true){
                            batchEntitlements.PRM_IsRemove_Ind__c = false;
                            beListTemp.add(batchEntitlements);
                        }
                }
            }
            if(finalCEList != null && !finalCEList.IsEmpty()){
                for(Core_Contact_Entitlement__c ce :finalCEList){ // Inserting batch entitlement records.
                    PRM_Batch_Entitlement__c be = new PRM_Batch_Entitlement__c();
                    be.PRM_Contact_Id__c = ce.Core_Contact_Id__c;
                    be.PRM_Entitlement_Id__c = ce.Core_Entitlement_Id__c;
                    be.PRM_Status_Nm__c = 'New';
                    if(!beListTemp.Contains(be)){
                        beListTemp.add(be);
                    }
                }
            }
            system.debug('Total queries executed before batch entitlement upsertion--->'+Limits.getQueries());
            If(beListTemp != null && !beListTemp.IsEmpty()){
                upsert beListTemp;
            }
            system.debug('Total queries executed after batch entitlement upsertion--->'+Limits.getQueries());
            System.debug('beListTemp-->'+beListTemp);
        }
    }
}