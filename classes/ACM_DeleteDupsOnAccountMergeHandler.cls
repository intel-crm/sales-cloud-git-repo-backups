public without sharing class ACM_DeleteDupsOnAccountMergeHandler {
    public static void  deleteDuplicates(Set<String> accountIds) {
        deleteDupsOnAccLegalMem(accountIds);
        deleteDupsOnAccBenefitAsstn(accountIds);
        deleteDupsOnAccChannelMem(accountIds);
        deleteDupsOnAcctSplAsstn(accountIds);
        deleteDupsOnOPIDGrpMem(accountIds);
        deleteDupsOnAccConRltnship(accountIds);
        deleteDupsOnProfileResponse(accountIds);
        deleteAccountComplainceWatchList(accountIds);
        deleteDuplicateCpe(accountIds);
    }
    //To delete the AccountLegalAgreemntAssociation duplicate records during account merge 
    private static void deleteDupsOnAccLegalMem(Set<String> accountIds) {
        List<PRM_AccountLegalAgreemntAssociation__c> deletionAccountLegalAggmtList = new List<PRM_AccountLegalAgreemntAssociation__c>();
        List<PRM_AccountLegalAgreemntAssociation__c> legalAggmtList = new List<PRM_AccountLegalAgreemntAssociation__c> ();  
        List<string> accountLegalAggmtList = new List<string>();
            
        legalAggmtList = [select id,PRM_InActive_Ind__c,PRM_Account_Id__c,
                                                        PRM_Partner_Agreement_Id__r.name, CreatedDate,PRM_Partner_Agreement_Id__c
                                                        from PRM_AccountLegalAgreemntAssociation__c where PRM_Account_Id__c =: accountIds
                                                        order by PRM_InActive_Ind__c, CreatedDate];
                    
        
        try {
            if(!legalAggmtList.isEmpty()) {
                for(PRM_AccountLegalAgreemntAssociation__c legalAggmt:legalAggmtList) {
                    string Key = String.valueOf(legalAggmt.PRM_Account_Id__c)+'_'+(legalAggmt.PRM_Partner_Agreement_Id__c!=null ? String.valueOf(legalAggmt.PRM_Partner_Agreement_Id__r.name) : '');
                    if (accountLegalAggmtList.contains(Key)) {
                        deletionAccountLegalAggmtList.add(legalAggmt);
                        
                    } else {
                        accountLegalAggmtList.add(Key);
                    }
                }
                if(!deletionAccountLegalAggmtList.isEmpty()) {
                    delete deletionAccountLegalAggmtList;
                    
                }
            }
            
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnAccountMergeHandler','deleteDupsOnAccLegalMem','AccountIds: ' +String.join(new List<String>(accountIds), ', ') + ' legalAggmtList: ' + legalAggmtList + '  Message: ' + ex.getStackTraceString(),null);
    
        }
    
    }
    //To delete the AccountBenefitAssociation duplicate records during account merge 
    private static void deleteDupsOnAccBenefitAsstn(Set<String> accountIds) {
        List<PRM_AccountBenefitAssociation__c> deletionAccountBnftAsstnList = new List<PRM_AccountBenefitAssociation__c>();
        Map<String, List<PRM_AccountBenefitAssociation__c>> accountBnftAsstnMap = new Map<string, List<PRM_AccountBenefitAssociation__c>>();
        List<PRM_AccountBenefitAssociation__c> bnftAsstnList = new List<PRM_AccountBenefitAssociation__c> ();  
        List<string> accountBnftAsstnList = new List<string>();
            
        bnftAsstnList = [select id,PRM_Status_Nm__c,PRM_Account_Id__c,
                                                        CreatedDate,PRM_Partner_Benefit_Id__c, PRM_Partner_Benefit_Id__r.Name
                                                        from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c =: accountIds
                                                        order by PRM_Status_Nm__c, CreatedDate];
            
        
        try {
            if(!bnftAsstnList.isEmpty()) {
                for(PRM_AccountBenefitAssociation__c bnftAsstn:bnftAsstnList) {
                    string Key = String.valueOf(bnftAsstn.PRM_Account_Id__c)+'_'+(bnftAsstn.PRM_Partner_Benefit_Id__c!=null ? String.valueOf(bnftAsstn.PRM_Partner_Benefit_Id__r.Name) : '');
                    if (accountBnftAsstnList.contains(Key)){
                        deletionAccountBnftAsstnList.add(bnftAsstn);
                    } else {
                        accountBnftAsstnList.add(Key);
                    }
                }
                if(!deletionAccountBnftAsstnList.isEmpty()) {
                        delete deletionAccountBnftAsstnList;
                    
                    
                }
            }
            
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnAccountMergeHandler','deleteDupsOnAccBenefitAsstn','AccountIds: ' +String.join(new List<String>(accountIds), ', ') + ' bnftAsstnList: ' + bnftAsstnList+ '  Message: ' + ex.getStackTraceString(),null);
        }
    }
    
    //To delete the AccountSpecialityAssociation duplicate records during account merge 
    private static void deleteDupsOnAcctSplAsstn(Set<String> accountIds) {
        List<PRM_Account_Specialty_Association__c> deletionAccountSplAsstnList = new List<PRM_Account_Specialty_Association__c>();
        Map<String, List<PRM_Account_Specialty_Association__c>> accountSplAsstnMap = new Map<string, List<PRM_Account_Specialty_Association__c>>();
        List<PRM_Account_Specialty_Association__c> splAsstnList = new List<PRM_Account_Specialty_Association__c> ();  
        List<string> accountSplAsstnList = new List<string>();
            
        splAsstnList = [select id,PRM_InActive_Ind__c,PRM_Account_Id__c,
                                                        CreatedDate,PRM_Specialty_Id__c, PRM_Specialty_Id__r.Name
                                                        from PRM_Account_Specialty_Association__c where PRM_Account_Id__c =: accountIds
                                                        order by PRM_InActive_Ind__c, CreatedDate];
            
                
    
        
        try {
            if(!splAsstnList.isEmpty()) {
                for(PRM_Account_Specialty_Association__c splAsstn:splAsstnList) {
                    string Key = String.valueOf(splAsstn.PRM_Account_Id__c)+'_'+(splAsstn.PRM_Specialty_Id__c!=null ? String.valueOf(splAsstn.PRM_Specialty_Id__r.Name) : '');//--use ternary operator
                    if (accountSplAsstnList.contains(Key)) {
                        deletionAccountSplAsstnList.add(splAsstn);
                    } else {
                        accountSplAsstnList.add(Key);
                    }
                }
                if(!deletionAccountSplAsstnList.isEmpty()) {
                        delete deletionAccountSplAsstnList;
                    
                    
                }
            }
            
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnAccountMergeHandler','deleteDupsOnAcctSplAsstn','AccountIds: ' +String.join(new List<String>(accountIds), ', ') + ' splAsstnList: ' + splAsstnList + '  Message: ' + ex.getStackTraceString(),null);
        }
    }
    
    //To delete the OPIDGroupMembers duplicate records during account merge 
    private static void deleteDupsOnOPIDGrpMem(Set<String> accountIds) {
        List<Core_Account_Group_Member__c> deletionOpidGrpMemList = new List<Core_Account_Group_Member__c>();
        Map<String, List<Core_Account_Group_Member__c>> opidGrpMemMap = new Map<string, List<Core_Account_Group_Member__c>>();
        List<Core_Account_Group_Member__c> opidGrpMemList = new List<Core_Account_Group_Member__c> ();  
        List<string> opidGroupMemList = new List<string>();
            
        opidGrpMemList = [select id,Core_Inactive_Ind__c,Core_Intel_Account_Id__c,
                                                        CreatedDate,Core_Partner_Account_Id__c, Core_Partner_Account_Id__r.name
                                                        from Core_Account_Group_Member__c where Core_Intel_Account_Id__c =: accountIds
                                                        order by Core_Inactive_Ind__c, CreatedDate];
            
            
        
        try {
            if(!opidGrpMemList.isEmpty()) {
                for(Core_Account_Group_Member__c opidGrpMem:opidGrpMemList) {
                    string Key = String.valueOf(opidGrpMem.Core_Intel_Account_Id__c)+'_'+String.valueOf(opidGrpMem.Core_Partner_Account_Id__c);//--use ternary operator
                    if (opidGroupMemList.contains(Key)) {
                        deletionOpidGrpMemList.add(opidGrpMem);
                    } else {
                        opidGroupMemList.add(Key);
                    }
                }
                if(!deletionOpidGrpMemList.isEmpty()) {
                        delete deletionOpidGrpMemList;
                    
                }
            }
            
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnAccountMergeHandler','deleteDupsOnOPIDGrpMem','AccountIds: ' +String.join(new List<String>(accountIds), ', ') + '  OPIDGrpMemberList: ' +opidGrpMemList + '  Message: ' + ex.getMessage() + '. StackTrace: ' + ex.getStackTraceString(),null);
        }
    }
    
    //To delete the AccountContactRelationship duplicate records during account merge 
    private static void deleteDupsOnAccConRltnship(Set<String> accountIds) {
        List<PRM_Account_Contact_Relationship__c> deletionAccConRltnshipList = new List<PRM_Account_Contact_Relationship__c>();
        Map<String, List<PRM_Account_Contact_Relationship__c>> accConRltnshipMap = new Map<string, List<PRM_Account_Contact_Relationship__c>>();
        List<PRM_Account_Contact_Relationship__c> accContactRltnshipList = new List<PRM_Account_Contact_Relationship__c> ();  
        List<string> accConRltnshipList = new List<string>();
                
        accContactRltnshipList = [select id,PRM_InActive_Ind__c,PRM_Account_Id__c,PRM_Contact_Id__c,
                                                        PRM_Relationship_Id__r.Name, CreatedDate,PRM_Relationship_Id__c
                                                        from PRM_Account_Contact_Relationship__c where PRM_Account_Id__c =: accountIds
                                                        order by PRM_InActive_Ind__c, CreatedDate];
            
            
        
        try {
            if(!accContactRltnshipList.isEmpty()) {
                for(PRM_Account_Contact_Relationship__c accConRltnship:accContactRltnshipList) {
                    string Key = String.valueOf(accConRltnship.PRM_Account_Id__c)+'_'+String.valueOf(accConRltnship.PRM_Contact_Id__c)+'_'+(accConRltnship.PRM_Relationship_Id__c!=null ? String.valueOf(accConRltnship.PRM_Relationship_Id__r.Name) : '');//--use ternary operator
                    if (accConRltnshipList.contains(Key)) {
                        deletionAccConRltnshipList.add(accConRltnship);
                    } else {
                        accConRltnshipList.add(Key);
                    }
                }
                if(!deletionAccConRltnshipList.isEmpty()) {
                        delete deletionAccConRltnshipList;
                    
                }
            }
            
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnAccountMergeHandler','deleteDupsOnAccConRltnship','AccountIds: ' +String.join(new List<String>(accountIds), ', ') + ' accContactRltnshipList: ' + accContactRltnshipList + '  Message: ' + ex.getStackTraceString(),null);
        }
    }
    
    //To delete the ProfileResponse duplicate records during account merge 
    private static void deleteDupsOnProfileResponse(Set<String> accountIds) {
        List<PRM_Profile_Responses__c> deletionProfRespList = new List<PRM_Profile_Responses__c>();
        Map<String, List<PRM_Profile_Responses__c>> ProfRespMap = new Map<string, List<PRM_Profile_Responses__c>>();
        List<PRM_Profile_Responses__c> profRespList = new List<PRM_Profile_Responses__c> ();  
        List<string> profileResponseList = new List<string>();
        
        profRespList = [select id,PRM_InActive_Ind__c,PRM_Account_Id__c,
                                                        PRM_Profile_Questions_Id__r.name, CreatedDate,PRM_Profile_Questions_Id__c
                                                        from PRM_Profile_Responses__c where PRM_Account_Id__c =: accountIds
                                                        order by CreatedDate desc];
        
        try {
            if(!profRespList.isEmpty()) {
                for(PRM_Profile_Responses__c profResp:profRespList) {
                    string Key = String.valueOf(profResp.PRM_Account_Id__c)+'_'+(profResp.PRM_Profile_Questions_Id__c!=null ? String.valueOf(profResp.PRM_Profile_Questions_Id__r.name) : '');//--use ternary operator
                    if (profileResponseList.contains(Key)) {
                        deletionProfRespList.add(profResp);
                    } else {
                        profileResponseList.add(Key);
                    }
                }
                if(!deletionProfRespList.isEmpty()) {
                        delete deletionProfRespList;
                    
                }
            }
            
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnAccountMergeHandler','deleteDupsOnProfileResponse','AccountIds: ' +String.join(new List<String>(accountIds), ', ') + ' profRespList: ' + profRespList+ '  Message: ' + ex.getStackTraceString(),null);
        }
    }
    
    //To delete the AccountChannelMembership duplicate records during account merge 
    private static void deleteDupsOnAccChannelMem(Set<String> accountIds) { 
        String APRV = 'Approved';
        String PNDG = 'Pending';
        String INACT = 'Inactive';
        List<PRM_AccountChannelMembership__c> deletionAccountChnlMemList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> approvedList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> pendingList  =  new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> inactiveList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> finalSortedChnlMemList = new List<PRM_AccountChannelMembership__c>();
        List<PRM_AccountChannelMembership__c> acmList = new List<PRM_AccountChannelMembership__c>();
        List<String> accChnlMemList = new List<String>();
            
        acmList = [select id, PRM_Account_Id__c, PRM_Partner_Role__c, PRM_Tier_Name_txt__c,PRM_Status_Nm__c 
                                                            from PRM_AccountChannelMembership__c where PRM_Account_Id__c =:accountIds
                                                            order by PRM_Status_Nm__c,CreatedDate
                                                            ];
        
        try{
            if(!acmList.isEmpty()) {
                for(PRM_AccountChannelMembership__c acm : acmList) {
                    if(acm.PRM_Status_Nm__c == APRV) {
                        approvedList.add(acm); 
                    } else if(acm.PRM_Status_Nm__c == PNDG) {
                        pendingList.add(acm);
                    } else if(acm.PRM_Status_Nm__c == INACT) {
                        inactiveList.add(acm);
                    }
                }
                finalSortedChnlMemList.addAll(approvedList);
                finalSortedChnlMemList.addAll(pendingList);
                finalSortedChnlMemList.addAll(inactiveList);
                for(PRM_AccountChannelMembership__c acm : finalSortedChnlMemList) {
                    string Key = String.valueOf(acm.PRM_Account_Id__c)+'_'+acm.PRM_Partner_Role__c+'_'+(String.isNotBlank(acm.PRM_Tier_Name_txt__c)?acm.PRM_Tier_Name_txt__c:'');
                    if(!accChnlMemList.contains(Key)) {
                        accChnlMemList.add(Key);
                    } else {
                        deletionAccountChnlMemList.add(acm);
                    }
                }
                if(!deletionAccountChnlMemList.isEmpty()) {
                        delete deletionAccountChnlMemList;
                    
                }
            }
        }catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnAccountMergeHandler','deleteDupsOnAccChannelMem','AccountIds: ' +String.join(new List<String>(accountIds), ', ') + 'acmList: ' + acmList + '  Message: ' + ex.getStackTraceString(),null);
    
        }                                      
        
    }
     
    public static void deleteDuplicateCpe(Set<String> accountIds){
        List<Account_Business_Types__c> cpeRecs = new List<Account_Business_Types__c>();
        Map<Id,Set<String>> BusinessTypeName = new Map<Id,Set<String>>();
        List<Account_Business_Types__c> duplAccCpeList = new List<Account_Business_Types__c>();
         if (Schema.sObjectType.Account_Business_Types__c.fields.Account__c.isAccessible())
         {
            if(accountIds.size()>0){
                cpeRecs = [SELECT Id,Account__c,Business_Types__r.Name	 FROM Account_Business_Types__c WHERE Account__c IN:accountIds ORDER BY LastModifiedDate ASC];
                if(cpeRecs.size() > 0){
                    for(Account_Business_Types__c accBuss:cpeRecs){    
                        if(BusinessTypeName.get(accBuss.Account__c) == null || !BusinessTypeName.get(accBuss.Account__c).contains(accBuss.Business_Types__r.Name)){
                            if(BusinessTypeName.get(accBuss.Account__c) == null){
                                BusinessTypeName.put(accBuss.Account__c,new Set<String>{accBuss.Business_Types__r.Name});
                            }else{
                                BusinessTypeName.get(accBuss.Account__c).add(accBuss.Business_Types__r.Name);
                            }
                        }else{
                            duplAccCpeList.add(accBuss);
                        }    
                    }
                }
                if(duplAccCpeList.size() >0){
                    delete duplAccCpeList;
                }
            }
            

    
        }

    }
    public static void deleteAccountComplainceWatchList(Set<String> accountIds) {
        List<Core_Account_Compliance_Watch_List__c> deletionAccountCompWatchLst = new List<Core_Account_Compliance_Watch_List__c>();
       List<Core_Account_Compliance_Watch_List__c> deletionAccList = new List<Core_Account_Compliance_Watch_List__c> ();  
        List<string> complaianceWatchListKey = new List<string>();
        if (Schema.sObjectType.Core_Account_Compliance_Watch_List__c.fields.Core_Account_Id__c.isAccessible() &&
            Schema.sObjectType.Core_Account_Compliance_Watch_List__c.fields.Core_Type__c .isAccessible()){
            deletionAccList = [select id,Core_Account_Id__c,Core_Type__c,
                                                        CreatedDate,Core_Account_Id__r.Core_Business_Party_Id__c
                                                        from Core_Account_Compliance_Watch_List__c where Core_Account_Id__c =: accountIds
                                                        order by LastModifiedDate ASC];
        }
        try {
            Map<Id,Set<String>> acctCWLMap = new Map<Id,Set<String>>();
            for(Core_Account_Compliance_Watch_List__c cwl : deletionAccList){
                if(acctCWLMap.get(cwl.Core_Account_Id__c) == null || !acctCWLMap.get(cwl.Core_Account_Id__c).contains(cwl.Core_Type__c)){
                    if(acctCWLMap.get(cwl.Core_Account_Id__c) == null){
                        acctCWLMap.put(cwl.Core_Account_Id__c,new Set<String>{cwl.Core_Type__c});
                    }else{
                        acctCWLMap.get(cwl.Core_Account_Id__c).add(cwl.Core_Type__c);
                    }
                }else{
                    deletionAccountCompWatchLst.add(cwl);
                }
            }
            // for(Core_Account_Compliance_Watch_List__c cwl : deletionAccountCompWatchLst){
            //     UCD_ACM_AccountDeactivationService.setCWLDeleteDate(cwl.Id, cwl.Core_Account_Id__r.Core_Business_Party_Id__c);
            // }
            if(deletionAccountCompWatchLst.size()>0){
                delete deletionAccountCompWatchLst;
            }
        } catch (Exception ex) {
            UCD_ACM_Logger.error('ACM_DeleteDupsOnAccountMergeHandler','deleteAccountComplainceWatchList','Message: ' + ex.getStackTraceString(),NULL);
        }
    }
    }