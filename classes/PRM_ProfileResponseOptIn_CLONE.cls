/**********************************************************************************************************************
Class Name    : PRM_ProfileResponseOptIn
Version       : 1.0
Created Date  : June 2020
Function      : Inserting Profile Response record for 'PRM_Opt_In' question code and CSP/OEM/Solution Provider Partner Roles

Modification Log :
* Developer                          Date                    Description
* ---------------------------------------------------------------------------------------------------------------------
* Pratik Sanganeria              25 June,2020            Gets called from PRM_CreateAccountAndRelatedRecords 
and PRM_CreateAccountAndRelatedRecordsAdmin classes
* Srishty Sharma                 23 Dec,2020             US856784: Set the point not eligible flag for Partner 
roles that are not eligible for Points opt in.
***********************************************************************************************************************/

public without sharing class PRM_ProfileResponseOptIn_CLONE {
    
    /* public static void createResponse(List<Account> accList,List<Contact> contList){
         Map<String,PRM_Profile_Questions__c> profQuesMap = new Map<String,PRM_Profile_Questions__c>();
         Map<String,PRM_Profile_Answer__c> profAnsMap = new Map<String,PRM_Profile_Answer__c>();
         Map<String,PRM_Profile_Answer__c> profAnsMapForNotEligible = new Map<String,PRM_Profile_Answer__c>();
         List<String> partnerRoleArray = new List<String>();
         Boolean shouldInsert = true;
         Id profQuesId;
         Id profAnsId;
         final String APPROVED_VALUE = 'Approved';
         partnerRoleArray = accList[0].Core_IPA_Partner_Role__c.split(';');
         System.debug(' Partner roles array :'+partnerRoleArray);
         List<String> existingPRListOfQuesIds = new List<String>();
         List<PRM_Profile_Responses__c> proResToUpdateNotEligible= new List<PRM_Profile_Responses__c>();
         for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.id,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c where PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_True OR  PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_False ]){
             profAnsMapForNotEligible.put(profAns.PRM_Answer_Cd__c,profAns);
         }
         
         if(partnerRoleArray.contains(System.Label.PRM_Service_Provider) || partnerRoleArray.contains(System.Label.PRM_Seller) || partnerRoleArray.contains(System.Label.PRM_OEM) || partnerRoleArray.contains(System.Label.PRM_Independent_Software_Vendor) || partnerRoleArray.contains(System.Label.PRM_Solution_Integrator) )
         {
             System.debug('@@ Partner Roles in the account : '+partnerRoleArray);
             System.debug('Required Partner Role found !!');
             
             if(accList != null && accList.size()>0)
             {
                 for(PRM_Profile_Responses__c profResp : [Select Id,PRM_Account_Id__c,PRM_Profile_Questions_Id__c from PRM_Profile_Responses__c where PRM_Account_Id__c =: accList[0].Id])
                {
                     if(profResp.PRM_Profile_Questions_Id__c==profAnsMapForNotEligible.get(Label.PRM_Points_Not_Eligible_True).PRM_Profile_Questions_Id__r.id){
                         profResp.PRM_Response_Txt__c = 'false';
                         profResp.PRM_Profile_Answer_Id__c = profAnsMapForNotEligible.get(Label.PRM_Points_Not_Eligible_False).id;
                         proResToUpdateNotEligible.add(profResp);
                     }
                     existingPRListOfQuesIds.add(String.valueOf(profResp.PRM_Profile_Questions_Id__c));
                 }
             }
             System.debug('@@ Profile Response Question Ids : '+existingPRListOfQuesIds);
             System.debug('@@ List of Accounts received : '+accList);
             System.debug('@@ List of Contacts received : '+contList);
             //US856784: Updating existing point eligble flag to false if OPT In eligible Partner role comes through registration approval for account.
             if(proResToUpdateNotEligible.size()>0){
                 update proResToUpdateNotEligible;
             }
             
             
             for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.id,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c where PRM_Answer_Cd__c=:System.Label.PRM_Answer_Code_OptInTrue  ]){
                 profAnsMap.put(profAns.PRM_Answer_Cd__c,profAns);
             }
             System.debug('@@@'+profAnsMap);
             
             for(String str : profAnsMap.keyset())
             {
                 profQuesId = profAnsMap.get(str).PRM_Profile_Questions_Id__r.id;
                 profAnsId = profAnsMap.get(str).id;
                 system.debug('Question id'+profQuesId);
                 system.debug('Answer id'+profAnsId);
             }
             for(String str1 : existingPRListOfQuesIds)
             {
                 System.debug('@@ Existing Question Id : '+str1);
                 if(str1 == profQuesId)
                 {
                     shouldInsert = false;
                     System.debug('Code Terminated !!');
                     return;
                 }
             }
             System.debug('@@ Profile Answer Id : '+profAnsId);
             PRM_Profile_Responses__c profResponse = new PRM_Profile_Responses__c();
             if(profQuesId != null){
                 profResponse.PRM_Profile_Questions_Id__c = profQuesId;
             }
             if(profAnsId != null){
                 profResponse.PRM_Profile_Answer_Id__c = profAnsId;
             }
             if(contList.size() > 0){
                 profResponse.PRM_Contact_Id__c = contList[0].Id;
             }
             if(accList.size() > 0){
                 profResponse.PRM_Account_Id__c = accList[0].Id;
             }
             profResponse.PRM_Response_Txt__c = System.Label.PRM_Response_Text_True;
             profResponse.PRM_InActive_Ind__c = false;
             System.debug('@@ Profile response record to be inserted : '+profResponse);
             
             if(profResponse != null && shouldInsert == true){
                 insert profResponse;
                 System.debug('Profile Response successfully inserted !!');
             }
         }
         //US856784: Set the point not eligible flag for Partner roles that are not eligible for Points opt in.
         else if(partnerRoleArray.contains(Label.PRM_Distributor_Partner_Role) || partnerRoleArray.contains(Label.PRM_FPGA_Designer_Partner_role) || partnerRoleArray.contains(Label.PRM_Manufacturer_Partner_Role)|| partnerRoleArray.contains(Label.PRM_Guest_Partner_Role)|| partnerRoleArray.contains(Label.PRM_Sponsor_Partner_Role)){
             System.debug('@@ Partner Roles in the account : '+partnerRoleArray);
             System.debug('Required Partner Role found !!');
             if(accList != null && accList.size()>0)
             {
                 for(PRM_Profile_Responses__c profResp : [Select Id,PRM_Account_Id__c,PRM_Profile_Questions_Id__c from PRM_Profile_Responses__c where PRM_Account_Id__c =: accList[0].Id])
                 {
                     if(profResp.PRM_Profile_Questions_Id__c==profAnsMapForNotEligible.get(Label.PRM_Points_Not_Eligible_False).PRM_Profile_Questions_Id__r.id){
                         profResp.PRM_Response_Txt__c = System.Label.PRM_Response_Text_True;
                         profResp.PRM_Profile_Answer_Id__c = profAnsMapForNotEligible.get(Label.PRM_Points_Not_Eligible_True).id;
                         proResToUpdateNotEligible.add(profResp);
                     }
                     existingPRListOfQuesIds.add(String.valueOf(profResp.PRM_Profile_Questions_Id__c));
                 }
             }
             System.debug('@@ Profile Response Question Ids : '+existingPRListOfQuesIds);
             System.debug('@@ List of Accounts received : '+accList);
             System.debug('@@ List of Contacts received : '+contList);
             
             if(proResToUpdateNotEligible.size()>0){
                 update proResToUpdateNotEligible;
             }
             
             for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.id,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c where PRM_Answer_Cd__c=:Label.PRM_Points_Not_Eligible_True ]){
                 profAnsMap.put(profAns.PRM_Answer_Cd__c,profAns);
             }  
             
             System.debug('@@@'+profAnsMap);
             for(String str : profAnsMap.keyset())
             {
                 profQuesId = profAnsMap.get(str).PRM_Profile_Questions_Id__r.id;
                 profAnsId = profAnsMap.get(str).id;
                 system.debug('Question id'+profQuesId);
                 system.debug('Answer id'+profAnsId);
             }
             
             
             //if the existing record have points not eligible then it will not insert new record for the same
             for(String str1 : existingPRListOfQuesIds){
                System.debug('@@ Existing Question Id : '+str1);
                 if(str1 == profQuesId){   
                     shouldInsert = false;
                     System.debug('Code Terminated !!');
                     return;
                 }
             }
             System.debug('@@ Profile Answer Id : '+profAnsId);
             PRM_Profile_Responses__c profResponse = new PRM_Profile_Responses__c();
             if(profQuesId != null){
                 profResponse.PRM_Profile_Questions_Id__c = profQuesId;
             }
             if(profAnsId != null){
                 profResponse.PRM_Profile_Answer_Id__c = profAnsId;
             }
             if(contList.size() > 0){
                 profResponse.PRM_Contact_Id__c = contList[0].Id;
             }
             if(accList.size() > 0){
                 profResponse.PRM_Account_Id__c = accList[0].Id;
             }
             profResponse.PRM_Response_Txt__c = System.Label.PRM_Response_Text_True;
             profResponse.PRM_InActive_Ind__c = false;
             System.debug('@@ Profile response record to be inserted : '+profResponse);
             
             if(profResponse != null && shouldInsert == true){
                 insert profResponse;//inserting profile response with Profile Question as Points Not Eligible as true for account.
                 System.debug('Profile Response successfully inserted !!');
             }
         }
     } */
     
     //Bulkified Code
     /* public static void createResponse(List<Account> accList,List<Contact> contList){
         
         List<String> existingPRListOfQuesIds = new List<String>();
         List<PRM_Profile_Responses__c> proResToUpdateNotEligibleTrue= new List<PRM_Profile_Responses__c>();
         List<PRM_Profile_Responses__c> proResToUpdateNotEligibleFalse= new List<PRM_Profile_Responses__c>();
         List<PRM_Profile_Responses__c> proResListInsert = new List<PRM_Profile_Responses__c>();
         Set<Id>acctContainsPartRoleSet1 = new Set<Id>();
         Set<Id>acctContainsPartRoleSet2 = new Set<Id>();
         List<String>existingPRListOfQuesIdsSet1 = new List<String>();
         List<String>existingPRListOfQuesIdsSet2 = new List<String>();
         PRM_Profile_Answer__c profAnsPointsNotEligibleTrue;
         PRM_Profile_Answer__c profAnsPointsNotEligibleFalse;
         PRM_Profile_Answer__c profAnsPointsOptInTrue;
         Date dToday = Date.today();
         DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
         String currentDate = dt.format('yyyy-MM-dd');
         
          for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.id,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c where 
                                              PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_True 
                                              OR  PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_False 
                                              OR PRM_Answer_Cd__c=:System.Label.PRM_Answer_Code_OptInTrue
                                              OR PRM_Answer_Cd__c=:Label.PRM_Points_Not_Eligible_True
                                              ]){
                                                  if(profAns.PRM_Answer_Cd__c == Label.PRM_Points_Not_Eligible_True){
                                                      profAnsPointsNotEligibleTrue = profAns;
                                                  } else If(profAns.PRM_Answer_Cd__c == Label.PRM_Points_Not_Eligible_False ){
                                                      profAnsPointsNotEligibleFalse = profAns;
                                                  }else If(profAns.PRM_Answer_Cd__c == System.Label.PRM_Answer_Code_OptInTrue){
                                                      profAnsPointsOptInTrue = profAns;
                                                  }
                                              }
         
         Map<Id,List<Id>> accountConListMap = new Map<Id,List<Id>>();
         for(Contact eachCon : contList){
             if(accountConListMap.containsKey(eachCon.AccountID)){
                 accountConListMap.get(eachCon.AccountID).add(eachCon.id);
             }else{
                 accountConListMap.put(eachCon.AccountID, new List<Id>{eachCon.id});
             }
         }
         
         
         if(accList.size() >  0){
             for(PRM_Profile_Responses__c profResp : [Select Id,PRM_Account_Id__c,PRM_Profile_Questions_Id__c from PRM_Profile_Responses__c where PRM_Account_Id__c =:accList]){
                 if(profResp.PRM_Profile_Questions_Id__c==profAnsPointsNotEligibleTrue.PRM_Profile_Questions_Id__r.id || profResp.PRM_Profile_Questions_Id__c==profAnsPointsNotEligibleFalse.PRM_Profile_Questions_Id__r.id){
                     profResp.PRM_Response_Txt__c = 'false';
                     profResp.PRM_Profile_Answer_Id__c = profAnsPointsNotEligibleFalse.id;
                     proResToUpdateNotEligibleTrue.add(profResp);
                 }else{
                     existingPRListOfQuesIdsSet1.add(String.valueOf(profResp.PRM_Profile_Questions_Id__c));
                 }
                  if(profResp.PRM_Profile_Questions_Id__c==profAnsPointsNotEligibleFalse.PRM_Profile_Questions_Id__r.id){
                     profResp.PRM_Response_Txt__c = currentDate;
                     profResp.PRM_Profile_Answer_Id__c = profAnsPointsNotEligibleTrue.id;
                     proResToUpdateNotEligibleFalse.add(profResp);
                    
                 }else{
                     existingPRListOfQuesIdsSet2.add(String.valueOf(profResp.PRM_Profile_Questions_Id__c));
                 }
                 
             }    
     }
         if(proResToUpdateNotEligibleTrue.size()>0){
             update proResToUpdateNotEligibleTrue;
         }
          if(proResToUpdateNotEligibleFalse.size()>0){
             update proResToUpdateNotEligibleFalse;
         }
                 
         for(Account eachAcc : accList){
             Boolean shouldInsert = true;
             Id profQuesId;
             Id profAnsId;
                 List<String> partnerRoleArray  = (eachAcc.Core_IPA_Partner_Role__c.split(';'));
                 System.debug('Each Acc --'+eachAcc);
                 if(partnerRoleArray.contains(System.Label.PRM_Service_Provider) || partnerRoleArray.contains(System.Label.PRM_Seller) || partnerRoleArray.contains(System.Label.PRM_OEM) || partnerRoleArray.contains(System.Label.PRM_Independent_Software_Vendor) || partnerRoleArray.contains(System.Label.PRM_Solution_Integrator)){
                     profQuesId = profAnsPointsOptInTrue.PRM_Profile_Questions_Id__r.id;
                     profAnsId = profAnsPointsOptInTrue.id;
                 }else if(partnerRoleArray.contains(Label.PRM_Distributor_Partner_Role) || partnerRoleArray.contains(Label.PRM_FPGA_Designer_Partner_role) || partnerRoleArray.contains(Label.PRM_Manufacturer_Partner_Role)|| partnerRoleArray.contains(Label.PRM_Guest_Partner_Role)|| partnerRoleArray.contains(Label.PRM_Sponsor_Partner_Role)){
                     profQuesId = profAnsPointsNotEligibleTrue.PRM_Profile_Questions_Id__r.id;
                     profAnsId = profAnsPointsNotEligibleTrue.id;        
                 }
            
             if(existingPRListOfQuesIdsSet1.contains(profQuesId) || existingPRListOfQuesIdsSet2.contains(profQuesId)){
                 shouldInsert = false;
                     return;
             }
             PRM_Profile_Responses__c profResponse = new PRM_Profile_Responses__c();
             if(profQuesId != null){
                 profResponse.PRM_Profile_Questions_Id__c = profQuesId;
             }
             if(profAnsId != null){
                 profResponse.PRM_Profile_Answer_Id__c = profAnsId;
             }
             if(contList.size() > 0){
                 List<Id> contactList = accountConListMap.get(eachAcc.id);
                 if(contactList.size() > 0){
                     profResponse.PRM_Contact_Id__c = contactList[0];    
                 }
             }
             System.debug('Account List--->'+accList);
             if(accList.size() > 0){
                 System.debug('Each Acc Id--->'+eachAcc.Id);
                 profResponse.PRM_Account_Id__c = eachAcc.Id;
             }
             //profResponse.PRM_Response_Txt__c = System.Label.PRM_Response_Text_True;
             profResponse.PRM_Response_Txt__c = currentDate;
             profResponse.PRM_InActive_Ind__c = false;
             
             if(profResponse != null && shouldInsert == true){
                 proResListInsert.add(profResponse);
             }  
         }
         System.debug('ProREsList--->'+proResListInsert);
         if(proResListInsert.size() > 0){
             Insert proResListInsert;
             
         }
         
     }*/
     	 	
     public static final String LOG_ENTRY_ORIGIN = 'Profile Response utility';
     public static final String LOG_ENTRY_PROJECT = 'IPA';
     public static final String LOG_ENTRY_SCOPE = 'PRM_ProfileResponseOptIn';
     public static final String LOG_ENTRY_SEVERITY = 'Medium'; 
     public static boolean OpidFirstRun= true;
     
    public static Map<String,PRM_Profile_Answer__c>  profileAnsCodeMapMethod(){
        Map<String,PRM_Profile_Answer__c> profileAnsCodeMap = new Map<String,PRM_Profile_Answer__c>();
        for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.id,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c where 
                PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_True // value = PRM_Points_Not_Eligible_True
                OR  PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_False // PRM_Points_Not_Eligible_False
                OR PRM_Answer_Cd__c=:System.Label.PRM_Answer_Code_OptInTrue // PRM_Opt_In_True
        ]){
                    profileAnsCodeMap.put(profAns.PRM_Answer_Cd__c,profAns);
        }
        return profileAnsCodeMap; 
    }

    
    
    public static void checkExtProfRespOnOPIDAndCreateResp_IPARefresh(List<Account> accList,List<Contact> contList, List<Core_Account_Group_Member__c> cagList, List<PRM_Registration_Request__c> listRegReq){
        if(accList != null && !accList.isEmpty() && contList != null){
            Map<Id, Account> accountMap = new Map<Id, Account>(accList); 
            Map<Id, Id> opidaccIdLocAccIdMap = new Map<Id, Id>();
            Map<Id, String> opidAccIdWithApprovedPartnerRole = new Map<Id,String>();
            Set<PRM_IPAMembership_Attributes__c> opidProfRespSet = new Set<PRM_IPAMembership_Attributes__c>();
            for(Core_Account_Group_Member__c cag: cagList){
            	opidaccIdLocAccIdMap.put(cag.Core_Partner_Account_Id__c, cag.Core_Intel_Account_Id__c);     
            }  
            
            for(PRM_AccountChannelMembership__c acm: [Select id, PRM_Partner_Role__c, PRM_Status_Nm__c, PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN: opidaccIdLocAccIdMap.keyset() and PRM_Status_Nm__c = 'Approved']){
            	system.debug('acm---'+acm);
                if(opidAccIdWithApprovedPartnerRole.containsKey(acm.PRM_Account_Id__c) && 
                ((opidAccIdWithApprovedPartnerRole.get(acm.PRM_Account_Id__c) == 'Eligible' && !System.label.PointsOptInEligiblePartners.split(',').contains(acm.PRM_Partner_Role__c)) || 
                (opidAccIdWithApprovedPartnerRole.get(acm.PRM_Account_Id__c) == 'Not Eligible' && System.label.PointsOptInEligiblePartners.split(',').contains(acm.PRM_Partner_Role__c)))){
                    opidAccIdWithApprovedPartnerRole.put(acm.PRM_Account_Id__c, 'Both');
                }else if (System.label.PointsOptInEligiblePartners.split(',').contains(acm.PRM_Partner_Role__c)){
                    opidAccIdWithApprovedPartnerRole.put(acm.PRM_Account_Id__c, 'Eligible');    
                }else{
                    opidAccIdWithApprovedPartnerRole.put(acm.PRM_Account_Id__c, 'Not Eligible');      
                }
                
            }
            system.debug('opidAccIdWithApprovedPartnerRole---'+opidAccIdWithApprovedPartnerRole);
            if(!opidAccIdWithApprovedPartnerRole.isEmpty()){   
                system.debug('opidAccIdWithApprovedPartnerRole inside if---'+opidAccIdWithApprovedPartnerRole);             
                List<PRM_IPAMembership_Attributes__c> profResList = [Select Id,PRM_Account_Id__c from PRM_IPAMembership_Attributes__c where PRM_Account_Id__c IN :opidAccIdWithApprovedPartnerRole.keyset()  order by PRM_Account_Id__c];
                Map<Id, List<PRM_IPAMembership_Attributes__c>> opidAccIdProdRespMap = new Map<Id, List<PRM_IPAMembership_Attributes__c>>();//check if its list or single record
				Map<String, String> fieldLabelsMap = PRM_ProfileResponse_Utility.getProfResFieldNames();
                system.debug('fieldLabelsMap---'+fieldLabelsMap);
                for(PRM_IPAMembership_Attributes__c  prodRes: profResList){
                    if(opidAccIdProdRespMap.containsKey(prodRes.PRM_Account_Id__c)){
                        opidAccIdProdRespMap.get(prodRes.PRM_Account_Id__c).add(prodRes);
                    }else{
                        opidAccIdProdRespMap.put(prodRes.PRM_Account_Id__c, new List<PRM_IPAMembership_Attributes__c>{prodRes});    
                    }                    
		            for(String fieldName : fieldLabelsMap.keySet()){
                        String fieldLabel = fieldLabelsMap.get(fieldName);
                        if(fieldLabel == PRM_ProfileResponse_Utility.POINTS_NOT_ELIGIBLE && opidAccIdWithApprovedPartnerRole.get(prodRes.PRM_Account_Id__c) != 'Eligible' && opidAccIdProdRespMap.containsKey(prodRes.PRM_Account_Id__c)) {
                        system.debug('points not eleigible');
                        opidProfRespSet.addAll(opidAccIdProdRespMap.get(prodRes.PRM_Account_Id__c));
                        accountMap.remove(opidaccIdLocAccIdMap.get(prodRes.PRM_Account_Id__c));
                        system.debug('accountMap 1--'+accountMap);
                        }
                        if(fieldLabel == PRM_ProfileResponse_Utility.POINTS_OPT_IN && opidAccIdWithApprovedPartnerRole.get(prodRes.PRM_Account_Id__c) != 'Not Eligible' && opidAccIdProdRespMap.containsKey(prodRes.PRM_Account_Id__c)){
                            system.debug('points Opt in');
                            opidProfRespSet.addAll(opidAccIdProdRespMap.get(prodRes.PRM_Account_Id__c));
                            accountMap.remove(opidaccIdLocAccIdMap.get(prodRes.PRM_Account_Id__c));
                            system.debug('accountMap 2--'+accountMap);
                        }
                    }
                }
                
                if(!opidProfRespSet.isEmpty()){
                    List<PRM_IPAMembership_Attributes__c> profRespListToRollDown = new List<PRM_IPAMembership_Attributes__c>();
                    profRespListToRollDown.addAll(opidProfRespSet);
                    //PRM_ProfileResponse_CLONE.OPIDToLoctionRollDown_IPARefresh(profRespListToRollDown, null);
                }    
                  
            }
        
            if(!accountMap.isEmpty()){
                //createResponse(accountMap.values(), contList, null, null);   
                //createResponseForOpid(accountMap.values(),contList, listRegReq, cagList); 
            }

        }
    }
    
    
    /*public static void createResponseForOpid(List<Account> accList,List<Contact> contList, List<PRM_Registration_Request__c> listRegReq, List<Core_Account_Group_Member__c> CAGforIPA){ 
        boolean OpidHasProfResp=false;
        boolean AnyotherLocIsactive=false;
        Set<Id> regAccountIdSet = new set<id>();
        set<id> accListIds=new set<id>();
        Map<String, String> mapOfRegAccountQstnIdResTxt = new Map<String, String>();
        Map<Id, Id> mapOfOPIDAccIdLocAccId = new Map<Id, Id>();
        for(account a:accList){
            accListIds.add(a.id);
        }
        for(PRM_Registration_Request__c regReq: listRegReq){
            if(String.isNotBlank(regReq.PRM_Salesforce_ID__c)){
            	regAccountIdSet.add(regReq.PRM_Salesforce_ID__c);    
            }    
        }
        Map<String,PRM_Profile_Answer__c> profileAnsCodeMap = profileAnsCodeMapMethod();
        if(!accList.isEmpty()){
            //List<Core_Account_Group_Member__c> CAGforIPA = [SELECT Id, Name, Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Core_Account_Type__c,  Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c,Core_Intel_Partner_Alliance_PartnerGroup__c from Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c in :accList  AND Core_Inactive_Ind__c != true];            
            List<Id> Opidset= new List<Id>();
            Map<Id,boolean> locAccAssociated=new Map<Id,boolean>();
            for (Core_Account_Group_Member__c c:CAGforIPA){
                mapOfOPIDAccIdLocAccId.put(c.Core_Partner_Account_Id__c, c.Core_Intel_Account_Id__c);
                Opidset.add(c.Core_Partner_Account_Id__c);
                //locAccAssociatedList.add(c.Core_Intel_Account_Id__c);
                locAccAssociated.put(c.Core_Intel_Account_Id__c,c.Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c);
            }
             for(id locid:locAccAssociated.keyset()){
                 for(id accid:accListIds){
                   if(locid!=accid){
                        if(locAccAssociated.get(locid))
                            AnyotherLocIsactive=true;
                        //anyotherlocareinactive=true;
                    }   
                 }  
                           
                }            
            
            //for(PRM_Profile_Responses__c profResp : [Select Id,PRM_Account_Id__c,PRM_Profile_Questions_Id__c, PRM_Response_Txt__c from PRM_Profile_Responses__c where PRM_Account_Id__c =:Opidset or PRM_Account_Id__c =:regAccountIdSet]){
            for(PRM_IPAMembership_Attributes__c profResp : [Select Id,PRM_Account_Id__c from PRM_IPAMembership_Attributes__c where PRM_Account_Id__c =:Opidset or PRM_Account_Id__c =:regAccountIdSet]){
                if(Opidset.contains(profResp.PRM_Account_Id__c)){
                    if(profResp.PRM_Profile_Questions_Id__c == profileAnsCodeMap.get(Label.PRM_Points_Not_Eligible_True).PRM_Profile_Questions_Id__c
                         || profResp.PRM_Profile_Questions_Id__c== profileAnsCodeMap.get(Label.PRM_Points_Not_Eligible_False).PRM_Profile_Questions_Id__c){
                             OpidHasProfResp= True;                     
                         }
                }else{
                    mapOfRegAccountQstnIdResTxt.put(profResp.PRM_Profile_Questions_Id__c + '-' + profResp.PRM_Account_Id__c,profResp.PRM_Response_Txt__c);
                }
            }
            if (!OpidHasProfResp || (OpidHasProfResp && !AnyotherLocIsactive)){    
                    list<account> OpidAccount=[SELECT
                    Id,
                    Core_IPA_Partner_Segment__c,
                    Name,
                    AccountNumber,
                    Core_Intel_Partner_Alliance_PartnerGroup__c,
                    Core_Account_Type__c,
                    Core_IPS_Active__c,
                    Core_IPA_Partner_Role__c,
                    Core_User_Defined_Phone_Number__c,
                    Core_User_Defined_Website__c from Account where id=:Opidset];
                	PRM_ProfileResponses_TriggerHandler.firstRun = true;                	
                    createResponse(OpidAccount,contList, mapOfRegAccountQstnIdResTxt, mapOfOPIDAccIdLocAccId); 
                	OpidFirstRun= false;
            }                                     
        }
    }*/

     public static void createResponse(List<Account> accList){//,List<Contact> contList, Map<String, String> mapOfRegAccountQstnIdResTxt, Map<Id, Id> mapOfOPIDAccIdLocAccId){
        map<Id,list<string>> accIdACMRecMap=new map<Id,list<string>>();
        map<Id,list<string>> accIdApprovedACMRecMap=new map<Id,list<string>>();
         //Map<String,PRM_Profile_Answer__c> profileAnsCodeMap = new Map<String,PRM_Profile_Answer__c>();
        // Map<String,PRM_Profile_Answer__c> profileAnsCodeMap = profileAnsCodeMapMethod();
         List<PRM_IPAMembership_Attributes__c> profileResponsesToUpsert = new List<PRM_IPAMembership_Attributes__c>();
         Map<Id,PRM_IPAMembership_Attributes__c> exisitngPRMap = new Map<Id,PRM_IPAMembership_Attributes__c>();

         Date dToday = Date.today();
         DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
         String currentDate = dt.format('yyyy-MM-dd');
         Map<Id,List<Id>> accountConListMap = new Map<Id,List<Id>>();
         
        //  for(Contact eachCon : contList){
        //      if(accountConListMap.containsKey(eachCon.AccountID)){
        //          accountConListMap.get(eachCon.AccountID).add(eachCon.id);
        //      }else{
        //          accountConListMap.put(eachCon.AccountID, new List<Id>{eachCon.id});
        //      }
        //  }
         if(accList.size() >  0){
            for(PRM_IPAMembership_Attributes__c pr : [select id,PRM_Account_Id__c,PRM_Points_Not_Eligible_Ind__c,PRM_Points_Not_Eligible_Dt__c,PRM_Points_Opt_in_Ind__c,PRM_Points_Opt_in_Dt__c from PRM_IPAMembership_Attributes__c where PRM_Account_Id__c IN:accList]) {
                
                exisitngPRMap.put(pr.PRM_Account_Id__c , pr);
            }
            for(PRM_AccountChannelMembership__c acm:[select id, PRM_Status_Nm__c, PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Account_Id__c, PRM_Channel_Program_Level_Id__c, PRM_Partner_Role__c,PRM_Account_Id__r.RecordType.DeveloperName 
                                                    from PRM_AccountChannelMembership__c where PRM_Account_Id__c in: accList]){
                if(acm.PRM_Status_Nm__c=='Inactive' ){
                    if (!accIdACMRecMap.containsKey(acm.PRM_Account_Id__c)) {
                        accIdACMRecMap.put(acm.PRM_Account_Id__c , new list<string>{acm.PRM_Partner_Role__c});
                    }
                    else {
                        accIdACMRecMap.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);
                    }

                }
                if(acm.PRM_Status_Nm__c=='Approved' ){
                    if (!accIdApprovedACMRecMap.containsKey(acm.PRM_Account_Id__c)) {
                        accIdApprovedACMRecMap.put(acm.PRM_Account_Id__c , new list<string>{acm.PRM_Partner_Role__c});
                    }
                    else {
                        accIdApprovedACMRecMap.get(acm.PRM_Account_Id__c).add(acm.PRM_Partner_Role__c);
                    }
                }
            }
      
        }
        set<Id> accIdSet=new set<Id>();
        list<Id> optInApprovedIdSet=new list<Id>();
        list<Id> noElgbleApprovedSet=new list<Id>();
        list<Id> optInIdSet=new list<Id>();
        list<Id> noElgbleSet=new list<Id>();
        list<Id> optInIdtrueSet=new list<Id>();
        list<Id> noElgbletrueSet=new list<Id>();
        
        Boolean isOptIn = false;
        Boolean isNotEligible = false;
        for(Account accRec : accList){
            List<String> partnerRoleArray  = new List<String>();
            if(String.isNotBlank(accRec.Core_IPA_Partner_Role__c))
                partnerRoleArray = accRec.Core_IPA_Partner_Role__c.split(';');

            if(partnerRoleArray.isEmpty() && accIdApprovedACMRecMap.containsKey(accRec.id)){
                partnerRoleArray = accIdApprovedACMRecMap.get(accRec.id);
            }

        
        isNotEligible = PRM_ProfileResponse_Utility.checkExistingPartnerRoles(partnerRoleArray,'Not Eligible Role');
        isOptIn =PRM_ProfileResponse_Utility.checkExistingPartnerRoles(partnerRoleArray,'Opt In Role');
            
            /*---One condition---*/
            if(exisitngPRMap.isEmpty()|| !exisitngPRMap.containsKey(accRec.Id))
            {
                PRM_IPAMembership_Attributes__c ipaMember = new PRM_IPAMembership_Attributes__c();
                ipaMember.PRM_Account_Id__c = accRec.Id;
                if(isOptIn){
                    ipaMember.PRM_Points_Opt_in_Ind__c = TRUE;
                    ipaMember.PRM_Points_Opt_in_Dt__c = Date.valueOf(currentDate);	
                }
                if(isNotEligible){
                    ipaMember.PRM_Points_Not_Eligible_Ind__c = TRUE;
                    ipaMember.PRM_Points_Not_Eligible_Dt__c = Date.valueOf(currentDate);
                }
                profileResponsesToUpsert.add(ipaMember);
            }else if(exisitngPRMap.containsKey(accRec.Id)){
                    PRM_IPAMembership_Attributes__c ipaMember = new PRM_IPAMembership_Attributes__c();
                        ipaMember.Id = exisitngPRMap.get(accRec.Id).Id;
                        if(exisitngPRMap.get(accRec.Id).PRM_Points_Opt_in_Ind__c==FALSE && isOptIn){
                                ipaMember.PRM_Points_Opt_in_Ind__c = TRUE;
                                ipaMember.PRM_Points_Opt_in_Dt__c = Date.valueOf(currentDate);
                                
                        }if(isNotEligible){
                                ipaMember.PRM_Points_Not_Eligible_Ind__c = TRUE;
                                ipaMember.PRM_Points_Not_Eligible_Dt__c = Date.valueOf(currentDate);
                            }
                            
                            profileResponsesToUpsert.add(ipaMember);
            }
/*----ONE Condition */
/*---- Second Condition */
            /* if((!exisitngQuestionIds.isEmpty() 
             && exisitngQuestionIds.containsKey(accRec.Id)
             && (exisitngQuestionIds.get(accRec.Id)).contains(profileAnsCodeMap.get(Label.PRM_Points_Not_Eligible_True).PRM_Profile_Questions_Id__c))
       && (accIdACMRecMap.containskey(accRec.Id) && (accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Distributor_Partner_Role)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_FPGA_Designer_Partner_role)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Manufacturer_Partner_Role)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Guest_Partner_Role)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Sponsor_Partner_Role)))
             ){
                accIdSet.add(accRec.Id);
                if(accIdApprovedACMRecMap.containsKey(accRec.Id)  && (accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Distributor_Partner_Role)
                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_FPGA_Designer_Partner_role)
                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Manufacturer_Partner_Role)
                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Guest_Partner_Role)
                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Sponsor_Partner_Role)) ){
                    noElgbleApprovedSet.add(accRec.Id);
                   
                }
                else{
                    if(!noElgbleSet.contains(accRec.Id)){
                        noElgbleSet.add(accRec.Id);
                    }
                }
              }
            
                              
             
             else if((!exisitngQuestionIds.isEmpty() 
             && exisitngQuestionIds.containsKey(accRec.Id)
             && (exisitngQuestionIds.get(accRec.Id)).contains(profileAnsCodeMap.get(Label.PRM_Answer_Code_OptInTrue).PRM_Profile_Questions_Id__c))
       && (accIdACMRecMap.containskey(accRec.Id) && (accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Seller)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Service_Provider)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_OEM)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Independent_Software_Vendor)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Solution_Integrator)))){
                                accIdSet.add(accRec.Id);
                                if(accIdApprovedACMRecMap.containsKey(accRec.Id)  && (accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Seller)
                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Service_Provider)
                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_OEM)
                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Independent_Software_Vendor)
                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Solution_Integrator)) ){
                                    optInApprovedIdSet.add(accRec.Id);
                                    
                                }
                                else{
                                    if(!optInIdSet.contains(accRec.Id)){
                                            optInIdSet.add(accRec.Id);
                                         }
                                }
                              }*/
/*--- Second Condition Ends ---*/

                          /*   if((!exisitngQuestionIds.isEmpty() 
             && exisitngQuestionIds.containsKey(accRec.Id)
             && (exisitngQuestionIds.get(accRec.Id)).contains(profileAnsCodeMap.get(Label.PRM_Points_Not_Eligible_True).PRM_Profile_Questions_Id__c))
       && (accIdACMRecMap.containskey(accRec.Id) && (accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Seller)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Service_Provider)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_OEM)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Independent_Software_Vendor)
                              ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Solution_Integrator)))){
                                accIdSet.add(accRec.Id);
                                if(accIdApprovedACMRecMap.containsKey(accRec.Id)  && (accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Distributor_Partner_Role)
                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_FPGA_Designer_Partner_role)
                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Manufacturer_Partner_Role)
                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Guest_Partner_Role)
                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Sponsor_Partner_Role)) ){
                                    if(!noElgbletrueSet.contains(accRec.Id)){
                                        noElgbletrueSet.add(accRec.Id);
                                         }
                                    
                                }

                              }
                            if((!exisitngQuestionIds.isEmpty() 
                              && exisitngQuestionIds.containsKey(accRec.Id)
                              && (exisitngQuestionIds.get(accRec.Id)).contains(profileAnsCodeMap.get(Label.PRM_Answer_Code_OptInTrue).PRM_Profile_Questions_Id__c))
                        && (accIdACMRecMap.containskey(accRec.Id) && (accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Distributor_Partner_Role)
                                               ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_FPGA_Designer_Partner_role)
                                               ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Manufacturer_Partner_Role)
                                               ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Guest_Partner_Role)
                                               ||accIdACMRecMap.get(accRec.Id).contains(System.Label.PRM_Sponsor_Partner_Role)))
                              ){
                                 accIdSet.add(accRec.Id);
                                 if(accIdApprovedACMRecMap.containsKey(accRec.Id)  && (accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Seller)
                                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Service_Provider)
                                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_OEM)
                                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Independent_Software_Vendor)
                                                ||accIdApprovedACMRecMap.get(accRec.Id).contains(System.Label.PRM_Solution_Integrator)) ){
                                   
                                                    if(!optInIdtrueSet.contains(accRec.Id)){
                                                        optInIdtrueSet.add(accRec.Id);
                                                     }
                                 }
                                 
                               }
                
                      }*/
                        //list<PRM_Profile_Responses__c> prListToUpdate=new list<PRM_Profile_Responses__c>();
                /* for (PRM_Profile_Responses__c pr : [select id,PRM_Response_Txt__c, PRM_Account_Id__c, PRM_Account_Id__r.Name, PRM_InActive_Ind__c,  PRM_Question_Display_Text__c,PRM_Profile_Questions_Id__c  from PRM_Profile_Responses__c where PRM_Account_Id__c IN:accIdSet]){
                     if((optInIdSet.contains(pr.PRM_Account_Id__c) && pr.PRM_Question_Display_Text__c == 'Points Opt-in' && !optInApprovedIdSet.contains(pr.PRM_Account_Id__c)) ||
                     (noElgbleSet.contains(pr.PRM_Account_Id__c) && pr.PRM_Question_Display_Text__c == 'Points Not eligible') && !noElgbleApprovedSet.contains(pr.PRM_Account_Id__c)){
                         pr.PRM_Response_Txt__c = 'false';
                         profileResponsesToUpsert.add(pr);
                     }
                     if((noElgbletrueSet.contains(pr.PRM_Account_Id__c) && pr.PRM_Question_Display_Text__c == 'Points Not eligible') || (optInIdtrueSet.contains(pr.PRM_Account_Id__c) && pr.PRM_Question_Display_Text__c == 'Points Opt-in')){
                        String key = mapOfOPIDAccIdLocAccId != null? pr.PRM_Profile_Questions_Id__c + '-' + mapOfOPIDAccIdLocAccId.get(pr.PRM_Account_Id__c):'';
                        pr.PRM_Response_Txt__c = (mapOfRegAccountQstnIdResTxt != null && mapOfRegAccountQstnIdResTxt.get(key) != null)?mapOfRegAccountQstnIdResTxt.get(key): currentDate;
                        profileResponsesToUpsert.add(pr);
                     }*/
                 }
                
                 string logEntry; 
                 if(!profileResponsesToUpsert.isEmpty()){
                    list<Database.UpsertResult> savePrResLst = Database.Upsert(profileResponsesToUpsert,false);
                    for (Database.UpsertResult sr : savePrResLst) {
                        if(!sr.isSuccess()){
                            logEntry=Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '');
                        }
                    }

                 }

       }
    
    public static List<Core_Account_Group_Member__c> getCAGList(Set<Id> accIdSet){
        system.debug('accIdSet--'+accIdSet);
        List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_Member__c>();
        if(accIdSet!= null && !accIdSet.isEmpty()){
        	cagList = [SELECT Id, Name, Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Core_Account_Type__c,  Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c,Core_Intel_Partner_Alliance_PartnerGroup__c from Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c in :accIdSet  AND Core_Inactive_Ind__c != true];    
            system.debug('cagList--'+cagList);
        }
        return cagList;
    }
     
 }