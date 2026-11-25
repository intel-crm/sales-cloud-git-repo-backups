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

public without sharing class PRM_ProfileResponseOptIn {

    public static Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();  
    public static Id opidIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('1PID Account Attributes').getRecordTypeId();
    public static Id inteIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('Intel Account Attributes').getRecordTypeId();
    
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
         //system.debug(' Partner roles array :'+partnerRoleArray);
         List<String> existingPRListOfQuesIds = new List<String>();
         List<PRM_Profile_Responses__c> proResToUpdateNotEligible= new List<PRM_Profile_Responses__c>();
         for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.id,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c where PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_True OR  PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_False ]){
             profAnsMapForNotEligible.put(profAns.PRM_Answer_Cd__c,profAns);
         }
         
         if(partnerRoleArray.contains(System.Label.PRM_Service_Provider) || partnerRoleArray.contains(System.Label.PRM_Seller) || partnerRoleArray.contains(System.Label.PRM_OEM) || partnerRoleArray.contains(System.Label.PRM_Independent_Software_Vendor) || partnerRoleArray.contains(System.Label.PRM_Solution_Integrator) )
         {
             //system.debug('@@ Partner Roles in the account : '+partnerRoleArray);
             //system.debug('Required Partner Role found !!');
             
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
             //system.debug('@@ Profile Response Question Ids : '+existingPRListOfQuesIds);
             //system.debug('@@ List of Accounts received : '+accList);
             //system.debug('@@ List of Contacts received : '+contList);
             //US856784: Updating existing point eligble flag to false if OPT In eligible Partner role comes through registration approval for account.
             if(proResToUpdateNotEligible.size()>0){
                 update proResToUpdateNotEligible;
             }
             
             
             for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.id,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c where PRM_Answer_Cd__c=:System.Label.PRM_Answer_Code_OptInTrue  ]){
                 profAnsMap.put(profAns.PRM_Answer_Cd__c,profAns);
             }
             //system.debug('@@@'+profAnsMap);
             
             for(String str : profAnsMap.keyset())
             {
                 profQuesId = profAnsMap.get(str).PRM_Profile_Questions_Id__r.id;
                 profAnsId = profAnsMap.get(str).id;
                 //system.debug('Question id'+profQuesId);
                 //system.debug('Answer id'+profAnsId);
             }
             for(String str1 : existingPRListOfQuesIds)
             {
                 //system.debug('@@ Existing Question Id : '+str1);
                 if(str1 == profQuesId)
                 {
                     shouldInsert = false;
                     //system.debug('Code Terminated !!');
                     return;
                 }
             }
             //system.debug('@@ Profile Answer Id : '+profAnsId);
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
             //system.debug('@@ Profile response record to be inserted : '+profResponse);
             
             if(profResponse != null && shouldInsert == true){
                 insert profResponse;
                 //system.debug('Profile Response successfully inserted !!');
             }
         }
         //US856784: Set the point not eligible flag for Partner roles that are not eligible for Points opt in.
         else if(partnerRoleArray.contains(Label.PRM_Distributor_Partner_Role) || partnerRoleArray.contains(Label.PRM_FPGA_Designer_Partner_role) || partnerRoleArray.contains(Label.PRM_Manufacturer_Partner_Role)|| partnerRoleArray.contains(Label.PRM_Guest_Partner_Role)|| partnerRoleArray.contains(Label.PRM_Sponsor_Partner_Role)){
             //system.debug('@@ Partner Roles in the account : '+partnerRoleArray);
             //system.debug('Required Partner Role found !!');
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
             //system.debug('@@ Profile Response Question Ids : '+existingPRListOfQuesIds);
             //system.debug('@@ List of Accounts received : '+accList);
             //system.debug('@@ List of Contacts received : '+contList);
             
             if(proResToUpdateNotEligible.size()>0){
                 update proResToUpdateNotEligible;
             }
             
             for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.id,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c where PRM_Answer_Cd__c=:Label.PRM_Points_Not_Eligible_True ]){
                 profAnsMap.put(profAns.PRM_Answer_Cd__c,profAns);
             }  
             
             //system.debug('@@@'+profAnsMap);
             for(String str : profAnsMap.keyset())
             {
                 profQuesId = profAnsMap.get(str).PRM_Profile_Questions_Id__r.id;
                 profAnsId = profAnsMap.get(str).id;
                 //system.debug('Question id'+profQuesId);
                 //system.debug('Answer id'+profAnsId);
             }
             
             
             //if the existing record have points not eligible then it will not insert new record for the same
             for(String str1 : existingPRListOfQuesIds){
                //system.debug('@@ Existing Question Id : '+str1);
                 if(str1 == profQuesId){   
                     shouldInsert = false;
                     //system.debug('Code Terminated !!');
                     return;
                 }
             }
             //system.debug('@@ Profile Answer Id : '+profAnsId);
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
             //system.debug('@@ Profile response record to be inserted : '+profResponse);
             
             if(profResponse != null && shouldInsert == true){
                 insert profResponse;//inserting profile response with Profile Question as Points Not Eligible as true for account.
                 //system.debug('Profile Response successfully inserted !!');
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
                 //system.debug('Each Acc --'+eachAcc);
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
             //system.debug('Account List--->'+accList);
             if(accList.size() > 0){
                 //system.debug('Each Acc Id--->'+eachAcc.Id);
                 profResponse.PRM_Account_Id__c = eachAcc.Id;
             }
             //profResponse.PRM_Response_Txt__c = System.Label.PRM_Response_Text_True;
             profResponse.PRM_Response_Txt__c = currentDate;
             profResponse.PRM_InActive_Ind__c = false;
             
             if(profResponse != null && shouldInsert == true){
                 proResListInsert.add(profResponse);
             }  
         }
         //system.debug('ProREsList--->'+proResListInsert);
         if(proResListInsert.size() > 0){
             Insert proResListInsert;
             
         }
         
     }*/
          
     public static final String LOG_ENTRY_ORIGIN = 'IPA Membership Attributes Logic';
     public static final String LOG_ENTRY_PROJECT = 'IPA';
     public static final String LOG_ENTRY_SCOPE = 'PRM_ProfileResponseOptIn';
     public static final String LOG_ENTRY_SEVERITY = 'Medium'; 
     public static boolean OpidFirstRun= true;
     
    public static Map<String,PRM_Profile_Answer__c>  profileAnsCodeMapMethod(){
        Map<String,PRM_Profile_Answer__c> profileAnsCodeMap = new Map<String,PRM_Profile_Answer__c>();
        for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.id,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c where 
                PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_True 
                OR  PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_False 
                OR PRM_Answer_Cd__c=:System.Label.PRM_Answer_Code_OptInTrue
        ]){
                    profileAnsCodeMap.put(profAns.PRM_Answer_Cd__c,profAns);
        }
        return profileAnsCodeMap; 
    }
    
    public static void checkExtProfRespOnOPIDAndCreateResp(List<Account> accList,List<Contact> contList, List<Core_Account_Group_Member__c> cagList, List<PRM_Registration_Request__c> listRegReq){
        if(accList != null && !accList.isEmpty() && contList != null){
            Map<Id, Account> accountMap = new Map<Id, Account>(accList); 
            Map<Id, Id> opidaccIdLocAccIdMap = new Map<Id, Id>();
            Map<Id, String> opidAccIdWithApprovedPartnerRole = new Map<Id,String>();
            Set<PRM_Profile_Responses__c> opidProfRespSet = new Set<PRM_Profile_Responses__c>();
            for(Core_Account_Group_Member__c cag: cagList){
              opidaccIdLocAccIdMap.put(cag.Core_Partner_Account_Id__c, cag.Core_Intel_Account_Id__c);     
            }  
            
            for(PRM_AccountChannelMembership__c acm: [Select id, PRM_Partner_Role__c, PRM_Status_Nm__c, PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN: opidaccIdLocAccIdMap.keyset() and PRM_Status_Nm__c = 'Approved']){
              
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
            
            if(!opidAccIdWithApprovedPartnerRole.isEmpty()){                
                List<PRM_Profile_Responses__c> tempProfResList = new List<PRM_Profile_Responses__c>();
                string tempAccId = null;
                boolean addProfResponses, skipProfResp = false;
                List<PRM_Profile_Responses__c> profResList = [Select Id,PRM_Account_Id__c,PRM_Profile_Questions_Id__c, PRM_Response_Txt__c, PRM_Reason_Text__c, PRM_Question_Display_Text__c from PRM_Profile_Responses__c where PRM_Account_Id__c IN :opidAccIdWithApprovedPartnerRole.keyset()  order by PRM_Account_Id__c];
                Map<Id, List<PRM_Profile_Responses__c>> opidAccIdProdRespMap = new Map<Id, List<PRM_Profile_Responses__c>>();
                for(PRM_Profile_Responses__c prodRes: profResList){
                    if(opidAccIdProdRespMap.containsKey(prodRes.PRM_Account_Id__c)){
                        opidAccIdProdRespMap.get(prodRes.PRM_Account_Id__c).add(prodRes);
                    }else{
                        opidAccIdProdRespMap.put(prodRes.PRM_Account_Id__c, new List<PRM_Profile_Responses__c>{prodRes});    
                    }
                }
                
                for(PRM_Profile_Responses__c profRes: profResList){  
                                            
                    if(profRes.PRM_Question_Display_Text__c == 'Points Not eligible' && opidAccIdWithApprovedPartnerRole.get(profRes.PRM_Account_Id__c) != 'Eligible' && opidAccIdProdRespMap.containsKey(profRes.PRM_Account_Id__c)){
                       opidProfRespSet.addAll(opidAccIdProdRespMap.get(profRes.PRM_Account_Id__c));
                       accountMap.remove(opidaccIdLocAccIdMap.get(profRes.PRM_Account_Id__c));
                       
                    }

                    if(profRes.PRM_Question_Display_Text__c == 'Points Opt-in' && opidAccIdWithApprovedPartnerRole.get(profRes.PRM_Account_Id__c) != 'Not Eligible' && opidAccIdProdRespMap.containsKey(profRes.PRM_Account_Id__c)){
                        opidProfRespSet.addAll(opidAccIdProdRespMap.get(profRes.PRM_Account_Id__c));
                        accountMap.remove(opidaccIdLocAccIdMap.get(profRes.PRM_Account_Id__c));
                    }
                    
                }
                if(!opidProfRespSet.isEmpty()){
                    List<PRM_Profile_Responses__c> profRespListToRollDown = new List<PRM_Profile_Responses__c>();
                    profRespListToRollDown.addAll(opidProfRespSet);
                    PRM_ProfileResponse.OPIDToLoctionRollDown(profRespListToRollDown, null);
                }    
                  
            }
       
            if(!accountMap.isEmpty()){
                createResponse(accountMap.values(), contList, null, null);   
                createResponseForOpid(accountMap.values(),contList, listRegReq, cagList); 
            }

        }
                    
    }    
    
    
    public static void createResponseForOpid(List<Account> accList,List<Contact> contList, List<PRM_Registration_Request__c> listRegReq, List<Core_Account_Group_Member__c> CAGforIPA){ 
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
            
            for(PRM_Profile_Responses__c profResp : [Select Id,PRM_Account_Id__c,PRM_Profile_Questions_Id__c, PRM_Response_Txt__c from PRM_Profile_Responses__c where PRM_Account_Id__c =:Opidset or PRM_Account_Id__c =:regAccountIdSet]){
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
    }

     public static void createResponse(List<Account> accList,List<Contact> contList, Map<String, String> mapOfRegAccountQstnIdResTxt, Map<Id, Id> mapOfOPIDAccIdLocAccId){
        map<Id,list<string>> accIdACMRecMap=new map<Id,list<string>>();
        map<Id,list<string>> accIdApprovedACMRecMap=new map<Id,list<string>>();
         //Map<String,PRM_Profile_Answer__c> profileAnsCodeMap = new Map<String,PRM_Profile_Answer__c>();
         Map<String,PRM_Profile_Answer__c> profileAnsCodeMap = profileAnsCodeMapMethod();
         List<PRM_Profile_Responses__c> profileResponsesToUpsert = new List<PRM_Profile_Responses__c>();
         Map<Id,Set<Id>> exisitngQuestionIds = new Map<Id,Set<Id>>();

         Date dToday = Date.today();
         DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
         String currentDate = dt.format('yyyy-MM-dd');

        /* for(PRM_Profile_Answer__c profAns : [Select Id,PRM_Answer_Cd__c,PRM_Profile_Questions_Id__r.id,PRM_Answer_Display_Txt__c from PRM_Profile_Answer__c where 
         PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_True 
         OR  PRM_Answer_Cd__c=: Label.PRM_Points_Not_Eligible_False 
         OR PRM_Answer_Cd__c=:System.Label.PRM_Answer_Code_OptInTrue
         ]){
             profileAnsCodeMap.put(profAns.PRM_Answer_Cd__c,profAns);
         }*/

         Map<Id,List<Id>> accountConListMap = new Map<Id,List<Id>>();
         
         for(Contact eachCon : contList){
             if(accountConListMap.containsKey(eachCon.AccountID)){
                 accountConListMap.get(eachCon.AccountID).add(eachCon.id);
             }else{
                 accountConListMap.put(eachCon.AccountID, new List<Id>{eachCon.id});
             }
         }
         if(accList.size() >  0){
             for(PRM_Profile_Responses__c profResp : [Select Id,PRM_Account_Id__c,PRM_Profile_Questions_Id__c from PRM_Profile_Responses__c where PRM_Account_Id__c =:accList /* || PRM_Account_Id__c=:Opidset*/]){
                 /*if(profResp.PRM_Profile_Questions_Id__c == profileAnsCodeMap.get(Label.PRM_Points_Not_Eligible_True).PRM_Profile_Questions_Id__c
                 || profResp.PRM_Profile_Questions_Id__c== profileAnsCodeMap.get(Label.PRM_Points_Not_Eligible_False).PRM_Profile_Questions_Id__c){
                     profResp.PRM_Response_Txt__c = currentDate;
                     profResp.PRM_Profile_Answer_Id__c = profAnsPointsNotEligibleTrue.id;
                     profileResponsesToUpsert.add(profResp);
                 }*/
                 if (!exisitngQuestionIds.containsKey(profResp.PRM_Account_Id__c)) {
                     exisitngQuestionIds.put(profResp.PRM_Account_Id__c , new Set<Id>{profResp.PRM_Profile_Questions_Id__c});
                 }
                 else {
                     exisitngQuestionIds.get(profResp.PRM_Account_Id__c).add(profResp.PRM_Profile_Questions_Id__c);
                 }
             }  
       //list<string> acmPartnerRole=new list<string>();
       
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
         for(Account accRec : accList){
             List<String> partnerRoleArray  = new List<String>();
             if(String.isNotBlank(accRec.Core_IPA_Partner_Role__c))
                 partnerRoleArray = accRec.Core_IPA_Partner_Role__c.split(';');
             if(partnerRoleArray.isEmpty() && accIdApprovedACMRecMap.containsKey(accRec.id)){
                 partnerRoleArray = accIdApprovedACMRecMap.get(accRec.id);
             }
             if((exisitngQuestionIds.isEmpty() 
             || !exisitngQuestionIds.containsKey(accRec.Id)
             || !(exisitngQuestionIds.get(accRec.Id)).contains(profileAnsCodeMap.get(Label.PRM_Answer_Code_OptInTrue).PRM_Profile_Questions_Id__c))

             && 
             
                 (partnerRoleArray.contains(System.Label.PRM_Service_Provider) 
             || partnerRoleArray.contains(System.Label.PRM_Seller) 
             || partnerRoleArray.contains(System.Label.PRM_OEM) 
             || partnerRoleArray.contains(System.Label.PRM_Independent_Software_Vendor) 
             || partnerRoleArray.contains(System.Label.PRM_Solution_Integrator))){
                 PRM_Profile_Responses__c profResponse = new PRM_Profile_Responses__c();
                 profResponse.PRM_Profile_Questions_Id__c = profileAnsCodeMap.get(Label.PRM_Answer_Code_OptInTrue).PRM_Profile_Questions_Id__c;
                 profResponse.PRM_Profile_Answer_Id__c = profileAnsCodeMap.get(Label.PRM_Answer_Code_OptInTrue).Id;
                 if (accountConListMap.containsKey(accRec.Id)) {
                     profResponse.PRM_Contact_Id__c = accountConListMap.get(accRec.Id)[0]; 
                 }
                 profResponse.PRM_Account_Id__c = accRec.Id;
                 String key = mapOfOPIDAccIdLocAccId != null? profResponse.PRM_Profile_Questions_Id__c + '-' + mapOfOPIDAccIdLocAccId.get(profResponse.PRM_Account_Id__c):'';
                 profResponse.PRM_Response_Txt__c = (mapOfOPIDAccIdLocAccId != null && mapOfRegAccountQstnIdResTxt != null && mapOfRegAccountQstnIdResTxt.get(key) != null)?mapOfRegAccountQstnIdResTxt.get(key): currentDate;
                 profileResponsesToUpsert.add(profResponse);
             }
             else if((exisitngQuestionIds.isEmpty() 
             || !exisitngQuestionIds.containsKey(accRec.Id)
             || !(exisitngQuestionIds.get(accRec.Id)).contains(profileAnsCodeMap.get(Label.PRM_Points_Not_Eligible_True).PRM_Profile_Questions_Id__c))

             && 
             
             (partnerRoleArray.contains(System.Label.PRM_Distributor_Partner_Role) 
             || partnerRoleArray.contains(System.Label.PRM_FPGA_Designer_Partner_role) 
             || partnerRoleArray.contains(System.Label.PRM_Manufacturer_Partner_Role) 
             || partnerRoleArray.contains(System.Label.PRM_Guest_Partner_Role) 
             || partnerRoleArray.contains(System.Label.PRM_Sponsor_Partner_Role))){
                 PRM_Profile_Responses__c profResponsePE = new PRM_Profile_Responses__c();
                profResponsePE.PRM_Profile_Questions_Id__c = profileAnsCodeMap.get(Label.PRM_Points_Not_Eligible_True).PRM_Profile_Questions_Id__c;
                 profResponsePE.PRM_Profile_Answer_Id__c = profileAnsCodeMap.get(Label.PRM_Points_Not_Eligible_True).Id;
                 if (accountConListMap.containsKey(accRec.Id)) {
                     profResponsePE.PRM_Contact_Id__c = accountConListMap.get(accRec.Id)[0]; 
                 }
                 profResponsePE.PRM_Account_Id__c = accRec.Id;
                 String key = mapOfOPIDAccIdLocAccId != null? profResponsePE.PRM_Profile_Questions_Id__c + '-' + mapOfOPIDAccIdLocAccId.get(profResponsePE.PRM_Account_Id__c):'';
                 profResponsePE.PRM_Response_Txt__c = (mapOfRegAccountQstnIdResTxt != null && mapOfRegAccountQstnIdResTxt.get(key) != null)?mapOfRegAccountQstnIdResTxt.get(key): currentDate;
                 profileResponsesToUpsert.add(profResponsePE);
             }

             if((!exisitngQuestionIds.isEmpty() 
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
                              }

                             if((!exisitngQuestionIds.isEmpty() 
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
                
                      }
                        //list<PRM_Profile_Responses__c> prListToUpdate=new list<PRM_Profile_Responses__c>();
                 for (PRM_Profile_Responses__c pr : [select id,PRM_Response_Txt__c, PRM_Account_Id__c, PRM_Account_Id__r.Name, PRM_InActive_Ind__c,  PRM_Question_Display_Text__c,PRM_Profile_Questions_Id__c  from PRM_Profile_Responses__c where PRM_Account_Id__c IN:accIdSet]){
                     if((optInIdSet.contains(pr.PRM_Account_Id__c) && pr.PRM_Question_Display_Text__c == 'Points Opt-in' && !optInApprovedIdSet.contains(pr.PRM_Account_Id__c)) ||
                     (noElgbleSet.contains(pr.PRM_Account_Id__c) && pr.PRM_Question_Display_Text__c == 'Points Not eligible') && !noElgbleApprovedSet.contains(pr.PRM_Account_Id__c)){
                         pr.PRM_Response_Txt__c = 'false';
                         profileResponsesToUpsert.add(pr);
                     }
                     if((noElgbletrueSet.contains(pr.PRM_Account_Id__c) && pr.PRM_Question_Display_Text__c == 'Points Not eligible') || (optInIdtrueSet.contains(pr.PRM_Account_Id__c) && pr.PRM_Question_Display_Text__c == 'Points Opt-in')){
                        String key = mapOfOPIDAccIdLocAccId != null? pr.PRM_Profile_Questions_Id__c + '-' + mapOfOPIDAccIdLocAccId.get(pr.PRM_Account_Id__c):'';
                        pr.PRM_Response_Txt__c = (mapOfRegAccountQstnIdResTxt != null && mapOfRegAccountQstnIdResTxt.get(key) != null)?mapOfRegAccountQstnIdResTxt.get(key): currentDate;
                        profileResponsesToUpsert.add(pr);
                     }
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
        List<Core_Account_Group_Member__c> cagList = new List<Core_Account_Group_Member__c>();
        if(accIdSet!= null && !accIdSet.isEmpty()){
            //ATHR Fix - TWC729-9556
          cagList = [SELECT Id, Name, Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.Core_Account_Type__c,  Core_Partner_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__r.Core_IPA_Partner_Segment__c, Core_Intel_Account_Id__c,Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c,Core_Partner_Account_Id__r.Core_OnePartnerID__c,Core_Inactive_Ind__c,Core_Intel_Partner_Alliance_PartnerGroup__c from Core_Account_Group_Member__c WHERE Core_Intel_Account_Id__c in :accIdSet  AND  /* Core_Inactive_Ind__c != true*/ Core_Inactive_Ind__c=false];    
        }
        return cagList;
    }

    /* IPA 2.0 Refresh Changes */
    public static void checkExtProfRespOnOPIDAndCreateResp_IPAR(List<Account> accList,List<Contact> contList, List<Core_Account_Group_Member__c> cagList, List<PRM_Registration_Request__c> listRegReq){
        String logEntryMsg='';
        logEntryMsg+='Inside checkExtProfRespOnOPIDAndCreateResp_IPAR, listRegReq:'+listRegReq;
        logEntryMsg+='\naccList:'+accList;
        logEntryMsg+='\ncagList:'+cagList;
        logEntryMsg+='\ncontList:'+contList;
        
        if(accList != null && !accList.isEmpty() && contList != null){
            Map<Id, Account> accountMap = new Map<Id, Account>(accList); 
            Map<Id, Id> opidaccIdLocAccIdMap = new Map<Id, Id>();
            Map<Id, String> opidAccIdWithApprovedPartnerRole = new Map<Id,String>();
            Set<PRM_IPAMembership_Attributes__c> opidProfRespSet = new Set<PRM_IPAMembership_Attributes__c>();
            for(Core_Account_Group_Member__c cag: cagList){
              opidaccIdLocAccIdMap.put(cag.Core_Partner_Account_Id__c, cag.Core_Intel_Account_Id__c); 
                    
            }  
             logEntryMsg+='\nopidaccIdLocAccIdMap:'+opidaccIdLocAccIdMap;
            for(PRM_AccountChannelMembership__c acm: [Select id, PRM_Partner_Role__c, PRM_Status_Nm__c, PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c IN: opidaccIdLocAccIdMap.keyset() and PRM_Status_Nm__c = 'Approved']){
              
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
            logEntryMsg+='\nopidAccIdWithApprovedPartnerRole:'+opidAccIdWithApprovedPartnerRole;
            
            if(!opidAccIdWithApprovedPartnerRole.isEmpty()){   
                
                List<PRM_IPAMembership_Attributes__c> profResList = [SELECT Id,RecordTypeId, PRM_Points_Not_Eligible_Reason_Txt__c, PRM_Points_Not_Eligible_Ind__c, PRM_Points_Not_Eligible_Dt__c, PRM_Component_Point_earning_excl_Ind__c, PRM_Component_Point_earning_excl_Dt__c, PRM_Branded_Point_earning_excl_Ind__c, PRM_Branded_Point_earning_excl_Dt__c, PRM_ODM_whiteboxPointEarning_excl_Ind__c, PRM_ODM_whiteboxPointEarning_excl_Dt__c,PRM_Activity_earning_excluded__c,PRM_Activity_earning_excluded_Start_Date__c,PRM_Client_Business_earning_excluded__c,PRM_ClientBusinessexcluded_StartDate__c,PRM_Ethernet_Business_earning_excluded__c,PRM_Ethernet_BusinessexcludedStartDt__c,PRM_Server_Business_earning_excluded__c,PRM_Server_Business_excluded_Start_Date__c, PRM_Registration_Source_Txt__c, PRM_Points_Opt_in_Ind__c, PRM_Points_Opt_in_Dt__c, PRM_Point_Status_Txt__c, PRM_Point_Status_Dt__c, PRM_Point_Status_Reason_Txt__c, PRM_Account_Id__c,lastmodifieddate, PRM_Inactive_ind__c from PRM_IPAMembership_Attributes__c where PRM_Account_Id__c IN :opidAccIdWithApprovedPartnerRole.keyset()  order by PRM_Account_Id__c];
                logEntryMsg+='\nprofResList:'+profResList;
                Map<Id, List<PRM_IPAMembership_Attributes__c>> opidAccIdProdRespMap = new Map<Id, List<PRM_IPAMembership_Attributes__c>>();//check if its list or single record
        Map<String, String> fieldLabelsMap = PRM_IPAR_ProfileResponse_Utility.getProfResFieldNames();
                                
                for(PRM_IPAMembership_Attributes__c  prodRes: profResList){
                                        
                    //BYPASS any IPA record flagged as inactive
                    if(prodRes.PRM_Inactive_ind__c== false){
                        opidProfRespSet.add(prodRes);
                        accountMap.remove(opidaccIdLocAccIdMap.get(prodRes.PRM_Account_Id__c));
                        continue;
                    }
                    if(prodRes.PRM_Points_Not_Eligible_Ind__c && opidAccIdWithApprovedPartnerRole.get(prodRes.PRM_Account_Id__c) != 'Eligible' ) {
                        system.debug('points not eleigible');
                        opidProfRespSet.add(prodRes);
                        accountMap.remove(opidaccIdLocAccIdMap.get(prodRes.PRM_Account_Id__c));
                    }
                    if(prodRes.PRM_Points_Opt_in_Ind__c && opidAccIdWithApprovedPartnerRole.get(prodRes.PRM_Account_Id__c) != 'Not Eligible' ){
                        system.debug('points Opt in');
                        opidProfRespSet.add(prodRes);
                        accountMap.remove(opidaccIdLocAccIdMap.get(prodRes.PRM_Account_Id__c));
                    }
                }
                if(!opidProfRespSet.isEmpty()){
                    List<PRM_IPAMembership_Attributes__c> profRespListToRollDown = new List<PRM_IPAMembership_Attributes__c>();
                    profRespListToRollDown.addAll(opidProfRespSet);
                    logEntryMsg+='\nprofRespListToRollDown:'+profRespListToRollDown;
                    PRM_ProfileResponse.OPIDToLoctionRollDown_IPAR(profRespListToRollDown, null);
                }    
                  
            }
            logEntryMsg+='\naccountMap:'+accountMap;
            if(!accountMap.isEmpty()){
                createResponse_IPAR(accountMap.values());//, contList, null, null);   
                createResponseForOpid_IPAR(accList, listRegReq, cagList);//Nj
            }

        }
        createLogEntry(logEntryMsg, LOG_ENTRY_SCOPE);
    }
    /**
        *  @description      : IPA 2.0 - create response for opid  
        *  @name             : createResponseForOpid_IPAR
        *  @param            : List<Account> accList, List<PRM_Registration_Request__c> listRegReq, List<Core_Account_Group_Member__c> CAGforIPA
        *  @throws exception : NONE
        * @userstory         : TWC729-7967
    **/
    public static void createResponseForOpid_IPAR(List<Account> accList, List<PRM_Registration_Request__c> listRegReq, List<Core_Account_Group_Member__c> CAGforIPA){ 
        String logEntryMsg='';
        logEntryMsg+='inside createResponseForOpid_IPAR, listRegReq:'+listRegReq;
        boolean OpidHasProfResp=false;
        boolean AnyotherLocIsactive=false;
        Set<Id> regAccountIdSet = new set<id>();
        set<id> accListIds=new set<id>();
        Map<String, String> mapOfRegAccountQstnIdResTxt = new Map<String, String>();
        Map<Id, Id> mapOfOPIDAccIdLocAccId = new Map<Id, Id>();
        for(PRM_Registration_Request__c regReq: listRegReq){
            if(String.isNotBlank(regReq.PRM_Salesforce_ID__c)){
              regAccountIdSet.add(regReq.PRM_Salesforce_ID__c);    
            }    
        }
        logEntryMsg+='\nregAccountIdSet:'+regAccountIdSet;
        if(!accList.isEmpty()){
            for(Account acc: accList){
                accListIds.add(acc.Id);
            }
            List<Id> Opidset= new List<Id>();
            Map<Id,boolean> locAccAssociated=new Map<Id,boolean>();
            for (Core_Account_Group_Member__c c:CAGforIPA){
                mapOfOPIDAccIdLocAccId.put(c.Core_Partner_Account_Id__c, c.Core_Intel_Account_Id__c);
                Opidset.add(c.Core_Partner_Account_Id__c);
                //locAccAssociatedList.add(c.Core_Intel_Account_Id__c);
                locAccAssociated.put(c.Core_Intel_Account_Id__c,c.Core_Intel_Account_Id__r.Core_Intel_Partner_Alliance_PartnerGroup__c);
            }
            for(id locid:locAccAssociated.keyset()){
                if(!accListIds.contains(locid) && locAccAssociated.get(locid)){
                    AnyotherLocIsactive=true;
                }             
            }            
            for(PRM_IPAMembership_Attributes__c ipaMemAtt : [Select Id,PRM_Account_Id__c from PRM_IPAMembership_Attributes__c where PRM_Account_Id__c =:Opidset or PRM_Account_Id__c =:regAccountIdSet]){
                if(Opidset.contains(ipaMemAtt.PRM_Account_Id__c)){
                    OpidHasProfResp= True;                     
                }
            }
            logEntryMsg+='\nOpidHasProfResp:'+OpidHasProfResp;
            logEntryMsg+='\nOpidset:'+Opidset;
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
                    RecordTypeId,
                    Core_User_Defined_Website__c from Account where id=:Opidset];
                    logEntryMsg+='\nOpidAccount:'+OpidAccount;
                  PRM_ProfileResponses_TriggerHandler.firstRun = true;                  
                    createResponse_IPAR(OpidAccount); 
                  OpidFirstRun= false;
            }                                     
        }
        createLogEntry(logEntryMsg, LOG_ENTRY_SCOPE);
    } 

    public static void createResponse_IPAR(List<Account> accList){//,List<Contact> contList, Map<String, String> mapOfRegAccountQstnIdResTxt, Map<Id, Id> mapOfOPIDAccIdLocAccId){
        String logEntryMsg='';
        logEntryMsg+='inside createResponse_IPAR, accList:'+accList;
        map<Id,list<string>> accIdACMRecMap=new map<Id,list<string>>();
        map<Id,list<string>> accIdApprovedACMRecMap=new map<Id,list<string>>();
        List<PRM_IPAMembership_Attributes__c> profileResponsesToUpsert = new List<PRM_IPAMembership_Attributes__c>();
        Map<Id,PRM_IPAMembership_Attributes__c> exisitngPRMap = new Map<Id,PRM_IPAMembership_Attributes__c>();
        Date dToday = Date.today();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        String currentDate = dt.format('yyyy-MM-dd');
        Map<Id,List<Id>> accountConListMap = new Map<Id,List<Id>>(); 
        logEntryMsg+='\naccList:'+accList;
         if(accList.size() >  0){
            for(PRM_IPAMembership_Attributes__c pr : [select id,PRM_Account_Id__c,PRM_Points_Not_Eligible_Ind__c,PRM_Points_Not_Eligible_Dt__c,PRM_Points_Opt_in_Ind__c,PRM_Points_Opt_in_Dt__c, PRM_Inactive_ind__c from PRM_IPAMembership_Attributes__c where PRM_Account_Id__c IN:accList]) { 
                exisitngPRMap.put(pr.PRM_Account_Id__c , pr);
            }
            for(PRM_AccountChannelMembership__c acm:[select id, PRM_Status_Nm__c,PRM_Account_Id__c,PRM_Partner_Role__c /*PRM_Account_Id__r.Core_IPA_One_Partner_Id__c, PRM_Channel_Program_Level_Id__c, ,PRM_Account_Id__r.RecordType.DeveloperName */ //ATHR Fix - TWC729-9556
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
        logEntryMsg+='\nexisitngPRMap:'+exisitngPRMap;
        logEntryMsg+='\naccIdACMRecMap:'+accIdACMRecMap;
        logEntryMsg+='\naccIdApprovedACMRecMap:'+accIdApprovedACMRecMap;
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
            logEntryMsg+='\npartnerRoleArray:'+partnerRoleArray;
            isNotEligible = PRM_IPAR_ProfileResponse_Utility.checkExistingPartnerRoles(partnerRoleArray,'Not Eligible Role');
            isOptIn =PRM_IPAR_ProfileResponse_Utility.checkExistingPartnerRoles(partnerRoleArray,'Opt In Role');
            logEntryMsg+='\nisNotEligible:'+isNotEligible;
            logEntryMsg+='\nisOptIn:'+isOptIn;
            if(exisitngPRMap.isEmpty()|| !exisitngPRMap.containsKey(accRec.Id))
            {
                PRM_IPAMembership_Attributes__c ipaMember = new PRM_IPAMembership_Attributes__c();
                ipaMember.PRM_Account_Id__c = accRec.Id;
                ipaMember.RecordTypeId = (accRec.RecordTypeId==OpidAccRecordTypeId)?opidIpaMemAttrRecordId:inteIpaMemAttrRecordId;
                if(isOptIn){
                    ipaMember.PRM_Points_Opt_in_Ind__c = TRUE;
                    ipaMember.PRM_Points_Opt_in_Dt__c = Date.valueOf(currentDate);  
                }
                if(isNotEligible){
                    
                    ipaMember.PRM_Points_Not_Eligible_Ind__c = TRUE;
                    ipaMember.PRM_Points_Not_Eligible_Dt__c = Date.valueOf(currentDate);
                    ipaMember.PRM_Points_Not_Eligible_Reason_Txt__c ='Role is not Eligible';//TWC729-8194: point not eligible reason mandatory
                }
                profileResponsesToUpsert.add(ipaMember);
               
            }else if(exisitngPRMap.containsKey(accRec.Id)){
                
                PRM_IPAMembership_Attributes__c ipaMember = new PRM_IPAMembership_Attributes__c();
                ipaMember.Id = exisitngPRMap.get(accRec.Id).Id;
                if(exisitngPRMap.get(accRec.Id).PRM_Inactive_ind__c == true){
                    ipaMember.PRM_Inactive_ind__c = false; //reset the inactive indicator to false
                }
                
                if(exisitngPRMap.get(accRec.Id).PRM_Points_Opt_in_Ind__c==FALSE && isOptIn){
                    ipaMember.PRM_Points_Opt_in_Ind__c = TRUE;
                    ipaMember.PRM_Points_Opt_in_Dt__c = Date.valueOf(currentDate);
                            
                }if(isNotEligible){
                    ipaMember.PRM_Points_Not_Eligible_Ind__c = TRUE;
                    ipaMember.PRM_Points_Not_Eligible_Dt__c = Date.valueOf(currentDate);
                    ipaMember.PRM_Points_Not_Eligible_Reason_Txt__c ='Role is not Eligible';//TWC729-8194: point not eligible reason mandatory
                        
                }    
                profileResponsesToUpsert.add(ipaMember);
                
            }
            logEntryMsg+='\nprofileResponsesToUpsert:'+profileResponsesToUpsert;
        }  
         /* Set Points Status and Points Status Date based on Opt-In and Points Not Eligible*/                        
        List<PRM_IPAMembership_Attributes__c> pointsStatusList = pointStatusCalc_IPAR(profileResponsesToUpsert,null);
        string logEntry; 
        if(!profileResponsesToUpsert.isEmpty()){
            list<Database.UpsertResult> savePrResLst = Database.Upsert(profileResponsesToUpsert,false);
            for (Database.UpsertResult sr : savePrResLst) {
                if(!sr.isSuccess()){
                    for (Database.Error err : sr.getErrors()) {
                                logEntryMsg+= '\nMessage: ' + err.getMessage() + '\n'
                                                + 'Fields: ' + err.Fields.toString() + '\n'
                                                + 'StatusCode: ' + err.getStatusCode() + '\n';
                    }
                }
            }
        }
        createLogEntry(logEntryMsg,LOG_ENTRY_SCOPE);
    }

    public static List<PRM_IPAMembership_Attributes__c> pointStatusCalc_IPAR(List<PRM_IPAMembership_Attributes__c> prPointsList,Map<Id,PRM_IPAMembership_Attributes__c> oldMap){
        String logEntryMsg='';
        logEntryMsg+='Inside pointStatusCalc_IPAR, prPointsList: '+prPointsList;
        List<PRM_IPAMembership_Attributes__c> listProfileResponse = new List<PRM_IPAMembership_Attributes__c>();
        Map<id,Boolean> tncSigned = new  Map<id,Boolean>();
        Map<id,Boolean> tncLocSigned = new  Map<id,Boolean>();
        boolean updateToday = false;
        boolean tochange = true;
        Set<Id> prIdSet = new Set<Id>();
        //check if indicators change, add it to map
        Boolean isPtsIndChanged = false;
        if(prPointsList!=null && !prPointsList.isEmpty()){
            for(PRM_IPAMembership_Attributes__c obj:prPointsList){
                if(!PRM_ProfileResponse.opidtoLocRDMap.contains(obj.PRM_Account_Id__c)){
                    prIdSet.add(obj.PRM_Account_Id__c);
                    if(oldMap!=null){
                        if((obj.PRM_Points_Opt_in_Ind__c != oldMap.get(obj.Id).PRM_Points_Opt_in_Ind__c) || (obj.PRM_Points_Not_Eligible_Ind__c != oldMap.get(obj.Id).PRM_Points_Not_Eligible_Ind__c)){
                            isPtsIndChanged = true;
                            break;
                        }
                    }
                }
            }
        }
        if(oldmap!=null && !isPtsIndChanged){
            return null;
        }

        /*To check the T&C signed for location accounts*/    
        if(prIdSet!=null && !prIdSet.isEmpty()){
            for(PRM_AccountLegalAgreemntAssociation__c legal:[Select id,PRM_Account_Id__c,PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,PRM_Account_Id__r.RecordTypeId from PRM_AccountLegalAgreemntAssociation__c where (PRM_Account_Id__c in :prIdSet or (PRM_Account_Id__r.Core_IPA_One_Partner_Id__c<>null and PRM_Account_Id__r.Core_IPA_One_Partner_Id__c in :prIdSet)) and PRM_InActive_Ind__c=FALSE and PRM_Partner_Agreement_Id__r.PRM_Channel_Program_Id__r.Name ='Intel Partner Alliance']){   
                
                if(legal.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c != null && legal.PRM_Account_Id__r.RecordTypeId != OpidAccRecordTypeId) {     
                    tncLocSigned.put(legal.PRM_Account_Id__r.Core_IPA_One_Partner_Id__c,true); 
                
                }
                tncSigned.put(legal.PRM_Account_Id__c,true);
                
            } 
        }
        logEntryMsg+='\ntncSigned:'+tncSigned;
        logEntryMsg+='\ntncLocSigned:'+tncLocSigned;
        if(prPointsList!=null && !prPointsList.isEmpty()){
            for(PRM_IPAMembership_Attributes__c prRec :prPointsList){
                Boolean isChanged = false;
                if(!PRM_ProfileResponse.opidtoLocRDMap.contains(prRec.PRM_Account_Id__c)){    
                    Date optInDate,NEDate;
                    Boolean isSigned = false;
                    if(prRec.PRM_Points_Not_Eligible_Ind__c){
                        prRec.PRM_Points_Opt_in_Ind__c = FALSE;
                        prRec.PRM_Points_Opt_in_Dt__c=null;
                        prRec.PRM_Point_Status_Txt__c='Not Eligible';
                        prRec.PRM_Points_Not_Eligible_Dt__c = prRec.PRM_Points_Not_Eligible_Dt__c!=null?prRec.PRM_Points_Not_Eligible_Dt__c:System.today();
                        prRec.PRM_Point_Status_Dt__c = prRec.PRM_Points_Not_Eligible_Dt__c;
                        NEDate = prRec.PRM_Points_Not_Eligible_Dt__c;
                        listProfileResponse.add(prRec); 
                    }else{
                        if(prRec.PRM_Points_Opt_in_Ind__c){
                            prRec.PRM_Points_Not_Eligible_Ind__c = FALSE;
                            prRec.PRM_Points_Not_Eligible_Dt__c = null;
                            prRec.PRM_Points_Not_Eligible_Reason_Txt__c ='';//TWC729-8194: point not eligible reason blanked out as points not eligible indicator is not checked
                                
                                optInDate = prRec.PRM_Points_Opt_in_Dt__c!=null?prRec.PRM_Points_Opt_in_Dt__c:System.today();
                                prRec.PRM_Points_Opt_in_Dt__c = optInDate;
                                if(tncLocSigned.get(prRec.PRM_Account_Id__c)!=null){
                                    isSigned = tncLocSigned.get(prRec.PRM_Account_Id__c);
                                    
                                }
                                
                                else if(tncSigned.get(prRec.PRM_Account_Id__c)!=null){
                                    isSigned = tncSigned.get(prRec.PRM_Account_Id__c);
                                    
                                }
                                if(isSigned){  
                                    if(prRec.PRM_Point_Status_Txt__c == 'Active'){ 
                                    if(prRec.PRM_Point_Status_Dt__c != optInDate){ 
                                            prRec.PRM_Point_Status_Dt__c = optInDate;
                                            listProfileResponse.add(prRec);  
                                    }   
                                    }
                                    if(prRec.PRM_Point_Status_Txt__c == 'Eligible' || prRec.PRM_Point_Status_Txt__c == 'Not Eligible'){ 
                                        prRec.PRM_Point_Status_Txt__c='Active'; 
                                        if(prRec.PRM_Point_Status_Dt__c != System.today()){
                                            prRec.PRM_Point_Status_Dt__c = System.today(); 
                                        }                
                                        listProfileResponse.add(prRec);  
                                    } 
                                    if(String.isBlank(prRec.PRM_Point_Status_Txt__c)){
                                        prRec.PRM_Point_Status_Txt__c='Active'; 
                                        prRec.PRM_Point_Status_Dt__c = optInDate;
                                        listProfileResponse.add(prRec);
                                    }
                                }else{
                                if(prRec.PRM_Point_Status_Txt__c == 'Not Eligible'){ 
                                        if(prRec.PRM_Point_Status_Dt__c != optInDate){ 
                                            prRec.PRM_Point_Status_Dt__c = optInDate;
                                            listProfileResponse.add(prRec);  
                                        }
                                    }
                                if(prRec.PRM_Point_Status_Txt__c == 'Eligible' || prRec.PRM_Point_Status_Txt__c == 'Active'){
                                        if(prRec.PRM_Point_Status_Dt__c != System.today()){
                                            prRec.PRM_Point_Status_Dt__c = System.today();  
                                            //listProfileResponse.add(prRec);  
                                            isChanged = true;
                                        }
                                    }  
                                if(prRec.PRM_Point_Status_Txt__c !='Not Eligible'){
                                    prRec.PRM_Point_Status_Txt__c='Not Eligible'; 
                                        if(prRec.PRM_Point_Status_Dt__c != System.today()){
                                            prRec.PRM_Point_Status_Dt__c = System.today();   //Status date update   
                                            //listProfileResponse.add(prRec);  
                                            isChanged = true;
                                        }                   
                                        //listProfileResponse.add(prRec);
                                        isChanged = true;
                                    }  
                                    if(String.isBlank(prRec.PRM_Point_Status_Txt__c)){
                                    prRec.PRM_Point_Status_Txt__c='Not Eligible'; 
                                        prRec.PRM_Point_Status_Dt__c = System.today(); ////Status date update 
                                        listProfileResponse.add(prRec); 
                                    }                  
                                }
                        }//points opt in = false
                        else{
                    
                            //if(OPIDList.contains(acntId)){
                            prRec.PRM_Points_Opt_in_Dt__c=null;
                            prRec.PRM_Points_Not_Eligible_Dt__c = null;
                            prRec.PRM_Points_Not_Eligible_Reason_Txt__c ='';
                                if(tncLocSigned.get(prRec.PRM_Account_Id__c)!=null) 
                                    isSigned = tncLocSigned.get(prRec.PRM_Account_Id__c);
                            //}
                            else if(tncSigned.get(prRec.PRM_Account_Id__c)!=null){
                                isSigned = tncSigned.get(prRec.PRM_Account_Id__c);
                            }
                            if(isSigned){                                                  
                                if(prRec.PRM_Point_Status_Txt__c !='Eligible'){
                                prRec.PRM_Point_Status_Txt__c='Eligible'; 
                                prRec.PRM_Point_Status_Dt__c = System.today();   //Status date update                 
                                    listProfileResponse.add(prRec);
                                }                    
                                if(prRec.PRM_Point_Status_Dt__c != System.today()){
                                    prRec.PRM_Point_Status_Dt__c = System.today();  
                                    listProfileResponse.add(prRec); 
                                }         
                            }
                            else{                           
                                if(prRec.PRM_Point_Status_Txt__c !='Not Eligible'){
                                    prRec.PRM_Point_Status_Txt__c='Not Eligible';
                                    prRec.PRM_Point_Status_Dt__c = System.today(); //Status date update                    
                                    listProfileResponse.add(prRec); 
                                }              
                                if(prRec.PRM_Point_Status_Dt__c != NEDate){
                                    prRec.PRM_Point_Status_Dt__c = NEDate != null? NEDate: System.Today();
                                    listProfileResponse.add(prRec);
                                } 
                            }
                        }
                    }    
                }
                if(isChanged){
                    listProfileResponse.add(prRec);
                }
            }
        }
        logEntryMsg+='\nlistProfileResponse:'+listProfileResponse;
        createLogEntry(logEntryMsg, LOG_ENTRY_SCOPE);
        return listProfileResponse;
    }

    public static void createLogEntry(String logEntryMsgString,String scope){
        string jobInitiatedDateTime = System.Now().format('MM/dd/YYYY HH:MM:SS','PST');
        if(logEntryMsgString!=''){// this block will create Log Entry records on the basis of length of logEntryMsg and Field limit.
            PRM_ProcessInboundOPIDLogEntriesUtility logEntryUtility=new PRM_ProcessInboundOPIDLogEntriesUtility();
            Integer fieldLength=Schema.SObjectType.Core_Log_Entry__c.fields.Core_Details__c.getLength();
            logEntryUtility.addLogEntry(logEntryMsgString,fieldLength);
            for(Integer i=0; i<logEntryUtility.logEntryList.size();i++){
               Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, scope, LOG_ENTRY_SEVERITY,'Job started at: '+ jobInitiatedDateTime +' PST' ,logEntryUtility.logEntryList[i] , '', '', '');
            }//loop ends here..
        }
    }
}