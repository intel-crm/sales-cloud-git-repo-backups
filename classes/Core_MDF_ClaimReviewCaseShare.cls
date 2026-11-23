/****************************************************************************************************************************************
* Class Name  : Core_MDF_ClaimReviewCaseShare 
* Version     : 1.0 
* Created Date: 11-21-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Harika P         11/23/2018                   Created Core_MDF_ClaimReviewCaseShare for sharing case records
* Accenture – Shridhar K       01/08/2019                   Updated claimReviewCaseShare method 
* Accenture – Shridhar K       02/18/2019                   Case is shared with account manager based on PGM records
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ClaimReviewCaseShare {
    public static List<Case> listOfCases = new List<Case>();
    /****************************************************************************************************************************************
    Method Name:                                             claimReviewCaseShare
    @return  :                                               Void
    @parameters:                                             caseList - List of cases                                
    Description:                                             This method will be invoked by a Process Builder in order to create the Share records for Cases 
    Added By:                                                Accenture – Harika P  -  11/23/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P        11/21/2018                   Created. 
    Accenture – Shridhar K      01/08/2019                   Updated claimReviewCaseShare method to share Case records only with claim submitter.
    Accenture – Shridhar K      02/18/2019                   Case is shared with account manager based on PGM records
    Accenture - Varun           07/13/2020                   Modified method to share Internal groups as Read only access
    *****************************************************************************************************************************************/    
    @InvocableMethod
    public static void claimReviewCaseShare(List<Case> caseList){
        try{ 
            Map<Id,List<Id>> claimIdUserIdListMapToShare = new Map<Id,List<Id>>();        
            Map<Id,List<Id>> caseIdWithUserOrGroupId = new Map<Id,List<Id>>();  
            Map<Id,Id> caseWithVirtualAccount = new Map<Id,Id>();
            Map<Id,Id> caseWithIntelAccount = new Map<Id,Id>();
            Map<Id,Id> virtualAccWithIntelAcc = new Map<Id,Id>();
            Map<Id,List<Core_MDF_Partner_Group_Mapping__c>> intelAccIdWithGroup = new Map<Id,List<Core_MDF_Partner_Group_Mapping__c>>();
            Map<Id,Account> virtualAccMap = new Map<Id,Account>();
            
            //VK
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> programIdSet = new Set<Id>();
            Set<String> geoSet = new Set<String>();            
            Map<String,Id> geoInternalMap = new Map<String,Id>();
            String accIdProgramIdGeoSubGeo;
            String accIdProgramIdGeo;
            String accIdProgramId;
            String geoMapKey;
            String subGeoMapKey;
            String geoBudgetTypeMapKey;
            String subGeoBudgetTypeMapKey;
            Map<Id,List<Id>> caseIdWithReadOnlyGroup = new Map<Id,List<Id>>();

            //EEF - Primary Partner Account Sharing
            String geoBudgetTypeMapKeyForPrimary ;
            String geoMapKeyForPrimary;
            String WWMapKeyForPrimary;
            Set<Id> primaryPartnerAccountIds = new Set<Id>();
            //Case Ids set
            Set<Id> caseIdSet = new set<Id>();
            //Splitting Custom Label to share with Retail/ IPA claim submitters as well - Added by Sugathri
            List<String> claimSubmitterPSList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_External_Claim_Submitter').split(';');
            List<id> caseId = new List<Id>();

            for(Case c :caseList){
                if(c.Core_MDF_Channel_Program_txt__c == 'Ecosystem Extension Fund'){
                    caseId.add(c.id);
                }
            }
            if(caseId != null){
                caseList = [select id,Core_MDF_Claim_Lookup_Id__r.Request.Campaign.Core_MDF_Account__c,Core_MDF_Channel_Program_txt__c,AccountId,Core_Account_Geo__c,Core_IPS_Account_Sub_Geo__c,Core_MDF_Budget_Type_nm__c from Case where Id in :caseId];
            }
            
            // Identifying accounts from cases
            for (Case c : caseList){
                if(c.AccountId != null){
                    caseWithVirtualAccount.put(c.Id, c.AccountId); 
                    String geo = c.Core_Account_Geo__c.trim();
                    geoSet.add(geo);
                    //EEF - Primary Partner Account Sharing
                    if(c.Core_MDF_Channel_Program_txt__c == 'Ecosystem Extension Fund'){
                        primaryPartnerAccountIds.add(c.Core_MDF_Claim_Lookup_Id__r.Request.Campaign.Core_MDF_Account__c);
                    }
                }
            }
            
            //isUser active check in below query added by Shridhar 04/02/2019
            //Mapping with virtual corp accounts
            /*List<Core_MDF_Partner_Node_User_Mapping__c> pnumList = [SELECT Id, Name, Core_MDF_Account__c, Core_MDF_User__c, 
                                                                    Core_MDF_AccountIdUserId__c 
                                                                    FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                                    WHERE Core_MDF_Account__c IN: caseWithVirtualAccount.values() AND 
                                                                    Core_MDF_User__r.IsActive = true and Core_MDF_Active_Ind__c = true LIMIT 50000];
            
            //Claim Submitter check logic begins
            list<Id> allUsersId = new list<Id>();
            for(Core_MDF_Partner_Node_User_Mapping__c pnumRec : pnumList){
                allUsersId.add(pnumRec.Core_MDF_User__c);
            }       
            
            Set<Id> allClaimSubmitter = new Set<Id>();
            for(PermissionSetAssignment usrPer : [SELECT Id, AssigneeId, PermissionSet.Name 
                                                  FROM PermissionSetAssignment
                                                  WHERE AssigneeId IN :allUsersId AND 
                                                  (PermissionSet.Name IN: claimSubmitterPSList OR PermissionSet.Name =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Extrnl_Prposl_Mgr_Prmsn_Set'))]){
                allClaimSubmitter.add(usrPer.AssigneeId);
            }*/
            
            //Claim Submitter check logic ends
            
            Map<String,String> cpNameToTechnicalProgramNameMap = new Map<String,String>();
            Map<Id, String> mapOfAccToHostGeo = new Map<Id, String>();
            Set<String> setOfAccHostGeo = new Set<String>();
            //Case sharing with Account Manager begins
            //Case is shared with Account Manager based on PGM records       
            for(Account acc: [SELECT Id, Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c, 
                              Core_MDF_Group_Id__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,
                              Core_MDF_Channel_Program__r.Name, Core_Geo__c
                              FROM Account 
                              WHERE Id IN: caseWithVirtualAccount.values() OR 
                              Id IN : primaryPartnerAccountIds]){
                if(acc.Core_MDF_CoMarketing_Ultimate_Account__c!= null){
                    virtualAccWithIntelAcc.put(acc.Id, acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                    virtualAccMap.put(acc.Id,acc);
                    cpNameToTechnicalProgramNameMap.put(acc.Core_MDF_Channel_Program__r.Name, acc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
                    //Populate accIdSet and programIdSet if sharing with Acc Mgr is based on PGM
                    Boolean isNodeBasedSharingReqd = Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(acc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);
                    if(!isNodeBasedSharingReqd){
                        accIdSet.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                        programIdSet.add(acc.Core_MDF_Channel_Program__c);
                    }                    
                }
                mapOfAccToHostGeo.put(acc.Id, acc.Core_Geo__c);
                setOfAccHostGeo.add(acc.Core_Geo__c);
            }

            //Fetching PGM records and storing them in map with Account
            if(accIdSet != NULL && accIdSet.Size() > 0 && programIdSet != NULL && programIdSet.Size() > 0){
                
                for(Core_MDF_Partner_Group_Mapping__c pgm:[SELECT Id, Core_MDF_Group_Id__c, Core_MDF_Account__c,Core_MDF_Sub_Region_cd__c, 
                                                           Core_MDF_Channel_Program__c,Core_MDF_Region_cd__c,
                                                           Core_MDF_BudgetType_nm__c
                                                           FROM Core_MDF_Partner_Group_Mapping__c 
                                                           WHERE Core_MDF_Type_of_Access__c='Internal' 
                                                           AND Core_MDF_Account__c IN : accIdSet AND 
                                                           Core_MDF_Inactive_Ind__c = false AND 
                                                           Core_MDF_Channel_Program__c IN : programIdSet AND
                                                           (Core_MDF_Region_cd__c IN : geoSet OR Core_MDF_Region_cd__c = 'WW' OR Core_MDF_Region_cd__c IN: setOfAccHostGeo)])
                {                      
                    If(pgm.Core_MDF_Sub_Region_cd__c != NULL){
                        
                        //Prepare acc + Cp + Geo + SubGeo key
                        accIdProgramIdGeoSubGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c+pgm.Core_MDF_Sub_Region_cd__c;
                        
                        //If budget type on pgm is null else add budget type to the key
                        if(pgm.Core_MDF_BudgetType_nm__c == NULL){
                            geoInternalMap.put(accIdProgramIdGeoSubGeo, pgm.Core_MDF_Group_Id__c);
                        }
                        else{
                            accIdProgramIdGeoSubGeo = accIdProgramIdGeoSubGeo + pgm.Core_MDF_BudgetType_nm__c;
                            geoInternalMap.put(accIdProgramIdGeoSubGeo, pgm.Core_MDF_Group_Id__c);
                        }
                    }else if(pgm.Core_MDF_Region_cd__c != 'WW'){
                        //Prepare acc + Cp + Geo key
                        accIdProgramIdGeo = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                        
                        //If budget type on pgm is null else add budget type to the key
                        if(pgm.Core_MDF_BudgetType_nm__c == NULL){
                            geoInternalMap.put(accIdProgramIdGeo, pgm.Core_MDF_Group_Id__c);
                        }else{
                            accIdProgramIdGeo = accIdProgramIdGeo + pgm.Core_MDF_BudgetType_nm__c;
                            geoInternalMap.put(accIdProgramIdGeo, pgm.Core_MDF_Group_Id__c);
                        }
                    }
                    
                    if(pgm.Core_MDF_Region_cd__c == 'WW'){
                        accIdProgramId = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c;
                        if(pgm.Core_MDF_BudgetType_nm__c == NULL){
                            geoInternalMap.put(accIdProgramId,pgm.Core_MDF_Group_Id__c);
                        } else{
                            accIdProgramId = accIdProgramId + pgm.Core_MDF_BudgetType_nm__c;
                            geoInternalMap.put(accIdProgramId, pgm.Core_MDF_Group_Id__c);
                        }
                    }
                }
            }
            
            Map<String,List<Id>> programGeoGroupMap = new Map<String,List<Id>>();
            programGeoGroupMap = loadMetadata();
            
            for (Case c : caseList){
               
                //Initilatizing set again
                Set<Id> userOrGroupIdSet = new Set<Id>();
                Set<Id> readOnlyGroupSet = new Set<Id>();

                // To share case record only with external claim submitter 
                /*for(Core_MDF_Partner_Node_User_Mapping__c pnumShare : pnumList){
                    if(c.AccountId != NULL && c.AccountId == pnumShare.Core_MDF_Account__c && allClaimSubmitter.contains(pnumShare.Core_MDF_User__c)){                            
                        userOrGroupIdSet.add(pnumShare.Core_MDF_User__c);                    
                    }            
                }*/               
                
                String techProgName = cpNameToTechnicalProgramNameMap.get(c.Core_MDF_Channel_Program_txt__c);
                Boolean isNodeBasedSharingReqd = Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(techProgName);
                String accRegion;

                if(c.Core_MDF_Channel_Program_txt__c == 'Intel Partner Alliance'){
                    if(mapOfAccToHostGeo.containsKey(c.AccountId) && mapOfAccToHostGeo.get(c.AccountId) != null){
                        accRegion = mapOfAccToHostGeo.get(c.AccountId).trim();
                    }else{
                        accRegion = '';
                    }
                }else{
                    accRegion = c.Core_Account_Geo__c.trim();
                }

                //Share case with Acc Mgr based on Group present on Account for Retail Program else follow PGM sharing
                if(isNodeBasedSharingReqd && virtualAccMap.containsKey(c.AccountId) && 
                   virtualAccMap.get(c.AccountId) != NULL && virtualAccMap.get(c.AccountId).Core_MDF_Group_Id__c != NULL){
                    readOnlyGroupSet.add(virtualAccMap.get(c.AccountId).Core_MDF_Group_Id__c);   
                }else{
                    if(c.Core_IPS_Account_Sub_Geo__c != NULL){           
                        subGeoMapKey = (String)virtualAccWithIntelAcc.get(c.AccountId) + virtualAccMap.get(c.AccountId).Core_MDF_Channel_Program__c + accRegion +c.Core_IPS_Account_Sub_Geo__c.trim();  
                        
                        if(c.Core_MDF_Budget_Type_nm__c != NULL){
                            subGeoBudgetTypeMapKey = (String)virtualAccWithIntelAcc.get(c.AccountId) + virtualAccMap.get(c.AccountId).Core_MDF_Channel_Program__c + accRegion + c.Core_IPS_Account_Sub_Geo__c.trim() + c.Core_MDF_Budget_Type_nm__c;                  
                        }
                        
                    }
                    
                    geoMapKey = (String)virtualAccWithIntelAcc.get(c.AccountId) + virtualAccMap.get(c.AccountId).Core_MDF_Channel_Program__c + accRegion;
                    
                    geoBudgetTypeMapKey = (String)virtualAccWithIntelAcc.get(c.AccountId) + virtualAccMap.get(c.AccountId).Core_MDF_Channel_Program__c + accRegion + c.Core_MDF_Budget_Type_nm__c;    

                    //for EEF - Primary Partner Account Sharing
                    if(c.Core_MDF_Channel_Program_txt__c == 'Ecosystem Extension Fund'){
                        
                        geoMapKeyForPrimary = (String)virtualAccWithIntelAcc.get(c.Core_MDF_Claim_Lookup_Id__r.Request.Campaign.Core_MDF_Account__c) + virtualAccMap.get(c.Core_MDF_Claim_Lookup_Id__r.Request.Campaign.Core_MDF_Account__c).Core_MDF_Channel_Program__c + accRegion;
                        WWMapKeyForPrimary = (String)virtualAccWithIntelAcc.get(c.Core_MDF_Claim_Lookup_Id__r.Request.Campaign.Core_MDF_Account__c) + virtualAccMap.get(c.Core_MDF_Claim_Lookup_Id__r.Request.Campaign.Core_MDF_Account__c).Core_MDF_Channel_Program__c;
                        if(geoInternalMap.containsKey(geoMapKeyForPrimary)){
                            readOnlyGroupSet.add(geoInternalMap.get(geoMapKeyForPrimary));
                        }
                        if(geoInternalMap.containsKey(WWMapKeyForPrimary)){
                            readOnlyGroupSet.add(geoInternalMap.get(WWMapKeyForPrimary));
                        }
                        
                    }
                    
                    if(subGeoMapKey != NULL && geoInternalMap.containsKey(subGeoMapKey)){
                        readOnlyGroupSet.add(geoInternalMap.get(subGeoMapKey));
                    }
                    
                    if(subGeoBudgetTypeMapKey != NULL && geoInternalMap.containsKey(subGeoBudgetTypeMapKey)){
                        readOnlyGroupSet.add(geoInternalMap.get(subGeoBudgetTypeMapKey));
                    }
                    
                    if(geoInternalMap.containsKey(geoMapKey)){
                        readOnlyGroupSet.add(geoInternalMap.get(geoMapKey));
                    }
                    
                    if(geoInternalMap.containsKey(geoBudgetTypeMapKey)){
                        readOnlyGroupSet.add(geoInternalMap.get(geoBudgetTypeMapKey));
                    }
                    
                    geoMapKey = geoMapKey.left(36);
                    
                    if(geoInternalMap.containsKey(geoMapKey)){
                        readOnlyGroupSet.add(geoInternalMap.get(geoMapKey));
                    }
                    
                    geoMapKey = geoMapKey + c.Core_MDF_Budget_Type_nm__c;
                    if(geoInternalMap.containsKey(geoMapKey)){
                        readOnlyGroupSet.add(geoInternalMap.get(geoMapKey));
                    }
                }
                
                //Below conditions are for sharing case with program based group from metadata
                if(programGeoGroupMap.containsKey(c.Core_MDF_Channel_Program_txt__c) && programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c) != NULL){
                    readOnlyGroupSet.addAll(programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c));
                }
                if(programGeoGroupMap.containsKey(c.Core_MDF_Channel_Program_txt__c + accRegion) && 
                   programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c + accRegion) != NULL){
                    readOnlyGroupSet.addAll(programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c + accRegion));
                }
                if(programGeoGroupMap.containsKey(c.Core_MDF_Channel_Program_txt__c + accRegion +c.Core_IPS_Account_Sub_Geo__c.trim()) &&
                   programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c + accRegion +c.Core_IPS_Account_Sub_Geo__c.trim()) != NULL){
                    readOnlyGroupSet.addAll(programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c + accRegion +c.Core_IPS_Account_Sub_Geo__c.trim()));
                }
                //For Budget Type based sharing
                if(programGeoGroupMap.containsKey(c.Core_MDF_Channel_Program_txt__c + accRegion + c.Core_MDF_Budget_Type_nm__c) &&
                   programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c + accRegion + c.Core_MDF_Budget_Type_nm__c) != NULL){
                    readOnlyGroupSet.addAll(programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c + accRegion + c.Core_MDF_Budget_Type_nm__c));
                }
                if(programGeoGroupMap.containsKey(c.Core_MDF_Channel_Program_txt__c + accRegion + c.Core_IPS_Account_Sub_Geo__c.trim() + c.Core_MDF_Budget_Type_nm__c) &&
                   programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c + accRegion + c.Core_IPS_Account_Sub_Geo__c.trim() + c.Core_MDF_Budget_Type_nm__c) != NULL){
                    readOnlyGroupSet.addAll(programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c + accRegion + c.Core_IPS_Account_Sub_Geo__c.trim() + c.Core_MDF_Budget_Type_nm__c));
                }
                //For WW region
                if(programGeoGroupMap.containsKey(c.Core_MDF_Channel_Program_txt__c + 'WW' + c.Core_MDF_Budget_Type_nm__c) &&
                programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c + 'WW' + c.Core_MDF_Budget_Type_nm__c) != NULL){
                readOnlyGroupSet.addAll(programGeoGroupMap.get(c.Core_MDF_Channel_Program_txt__c + 'WW' + c.Core_MDF_Budget_Type_nm__c));
                }
                
                // Preparing map of case Id and List of user Id's to be shared 
                /*if (userOrGroupIdSet.Size()>0){                
                    caseIdWithUserOrGroupId.Put(c.Id, new List<Id>(userOrGroupIdSet));                    
                */
                if (readOnlyGroupSet.Size()>0){                
                    caseIdWithReadOnlyGroup.Put(c.Id, new List<Id>(readOnlyGroupSet));                    
                }                
            }        
            // Call Generic share method class using MapcaseIdWithUserOrGroupId for sharing Case records with 
            // External Users from Partner Node User Mapping
            
            if(!caseIdWithUserOrGroupId.isEmpty()){
                //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Case', caseIdWithUserOrGroupId); 
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Case', caseIdWithUserOrGroupId, 'Edit');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
            }
            if(!caseIdWithReadOnlyGroup.isEmpty()){
                //Core_MDF_GenericShareRecordActionClass.createShareRecordList('Case', caseIdWithUserOrGroupId); 
                Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsReadInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Case', caseIdWithReadOnlyGroup, 'Read');
                Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsReadInst);
            }
        }
        catch(Exception e){
            String errorDetails = Core_MDF_CCP_UtilityClass.getErrorDetails(e); Core_MDF_CCP_UtilityClass.logErrorinLogObject(errorDetails,'Exception occured in CCP claimReviewCaseShare method');
        }
    }
    
    /****************************************************************************************************************************************
    Method Name:                                             loadMetadata
    @return  :                                               Map<String,List<Id>>
    @parameters:                                             
    Description:                                             This method will be return the groups based on Program+Region
    Added By:                                                Accenture – Varun -  07/13/2020
    Modified By:                  Date:                      Changes: 
    *****************************************************************************************************************************************/   
    public static Map<String,List<Id>> loadMetadata(){
        
        Map<String, String> programRWGroupMap = new Map<String, String>();
        Map<String, String> programROGroupMap = new Map<String, String>();
        List<String> groupNameList = new List<String>();
        Map<String, Id> groupNameGroupIdMap = new Map<String,Id>();
        Map<String,List<Id>> programGeoGroupIdListMap = new Map<String,List<Id>>();
        
        try{
            for(Core_MDF_ProgramGeoGroupMap__mdt mdt :[SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,
                                                       Core_MDF_Sub_Region__c,Core_MDF_Check_SubGeo__c, Core_MDF_Budget_Type_txt__c
                                                       From Core_MDF_ProgramGeoGroupMap__mdt LIMIT 10000]){
                 //For RO Sharing for all Programs                                         
                 if(mdt.Core_MDF_Budget_Type_txt__c == NULL){
                     if(mdt.Core_MDF_Region__c == NULL){
                         programRWGroupMap.put(mdt.Core_MDF_Program__c, mdt.Core_MDF_Group_Name__c);
                      
                         programROGroupMap.put(mdt.Core_MDF_Program__c, mdt.Core_MDF_Group_Name_RO__c);
                     }else if(mdt.Core_MDF_Region__c != NULL && mdt.Core_MDF_Sub_Region__c != NULL){
                         programRWGroupMap.put(mdt.Core_MDF_Program__c+mdt.Core_MDF_Region__c+mdt.Core_MDF_Sub_Region__c, mdt.Core_MDF_Group_Name__c);
                         programROGroupMap.put(mdt.Core_MDF_Program__c+mdt.Core_MDF_Region__c+mdt.Core_MDF_Sub_Region__c, mdt.Core_MDF_Group_Name_RO__c);
                     }else if(mdt.Core_MDF_Region__c != NULL && mdt.Core_MDF_Sub_Region__c == NULL){
                         programRWGroupMap.put(mdt.Core_MDF_Program__c+mdt.Core_MDF_Region__c, mdt.Core_MDF_Group_Name__c);
                         programROGroupMap.put(mdt.Core_MDF_Program__c+mdt.Core_MDF_Region__c, mdt.Core_MDF_Group_Name_RO__c);
                     }
                 }
                 //For Budget Type based Sharing for IPA Only                                          
                 if(mdt.Core_MDF_Program__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') && mdt.Core_MDF_Budget_Type_txt__c != NULL){
                     //For ASMO LAR-NAR
                     if(mdt.Core_MDF_Region__c != NULL && mdt.Core_MDF_Sub_Region__c != NULL){
                        programRWGroupMap.put(mdt.Core_MDF_Program__c+mdt.Core_MDF_Region__c+mdt.Core_MDF_Sub_Region__c+mdt.Core_MDF_Budget_Type_txt__c, mdt.Core_MDF_Group_Name__c);
                        programROGroupMap.put(mdt.Core_MDF_Program__c+mdt.Core_MDF_Region__c+mdt.Core_MDF_Sub_Region__c+mdt.Core_MDF_Budget_Type_txt__c, mdt.Core_MDF_Group_Name_RO__c);
                     //For APJ, EMEA, PRC   
                     }else if(mdt.Core_MDF_Region__c != NULL && mdt.Core_MDF_Sub_Region__c == NULL){
                        programRWGroupMap.put(mdt.Core_MDF_Program__c+mdt.Core_MDF_Region__c+mdt.Core_MDF_Budget_Type_txt__c, mdt.Core_MDF_Group_Name__c);
                        programROGroupMap.put(mdt.Core_MDF_Program__c+mdt.Core_MDF_Region__c+mdt.Core_MDF_Budget_Type_txt__c, mdt.Core_MDF_Group_Name_RO__c);
                     }
                 }  
                                                          
                 groupNameList.add(mdt.Core_MDF_Group_Name__c);
                 groupNameList.add(mdt.Core_MDF_Group_Name_RO__c);                                     
            }

            for(Group grp : [SELECT Id, Name, DeveloperName FROM Group WHERE (DeveloperName like 'Core_MDF%' or DeveloperName like 'MDF%') and type='Regular' and DeveloperName IN: groupNameList]){
                groupNameGroupIdMap.put(grp.DeveloperName, grp.Id);
            }
            
            for(String key : programRWGroupMap.keySet()){
                if(groupNameGroupIdMap.containsKey(programRWGroupMap.get(key)) && groupNameGroupIdMap.get(programRWGroupMap.get(key)) != NULL){
                    programGeoGroupIdListMap.put(key, new List<Id>{groupNameGroupIdMap.get(programRWGroupMap.get(key))});
                }
            }
            
            for(String key : programROGroupMap.keySet()){
                if(groupNameGroupIdMap.containsKey(programROGroupMap.get(key)) && groupNameGroupIdMap.get(programROGroupMap.get(key)) != NULL){
                    if(programGeoGroupIdListMap.containsKey(key)){
                       programGeoGroupIdListMap.get(key).add(groupNameGroupIdMap.get(programROGroupMap.get(key))); 
                    }else{
                       programGeoGroupIdListMap.put(key, new List<Id>{groupNameGroupIdMap.get(programROGroupMap.get(key))}); 
                    }
                }
                
            }
            
            return programGeoGroupIdListMap;
        }catch(Exception e){Core_MDF_CCP_UtilityClass.getErrorDetails(e); return NULL;}
    }
}