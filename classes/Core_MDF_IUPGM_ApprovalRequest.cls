/*****************************************************************************************************
Class        :   Core_MDF_IUPGM_ApprovalRequest
Test Class   :   Core_MDF_IUPGM_ApprovalRequest_Test
Developed By :   Weezer - Shiva
*****************************************************************************************************/
public without sharing class Core_MDF_IUPGM_ApprovalRequest {
    
    //Public Static string CHANNEL_MDF_PROG = Core_MDF_CCP_ConstantClass.CMDF_PROGRAM;
    Public Static string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
    Public Static string RMF_PROG = Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
    
    Public static set<string> allAccAllBTSet = new set<string>();
    Public static set<string> allAccSpecificBTSet = new set<string>();
    Public static set<string> singleAccAllBTSet = new set<string>();
    Public static set<string> singleAccSpecificBTSet = new set<string>();
    Public static Map<string,string> progToIdMap = new Map<string,string>(); 
    Public static Map<string,string> progTechNameToLabelMap = new Map<string,string>();
    Public static map<string,set<string>> roleToStageSetMap = new map<string,set<string>>();
    Public static Set<Id> queueIds = new Set<Id>();
    Public static Set<Id> inProgressPIWITrackingIds = new set<Id>();
    Public static Set<Id> inProgressTrackingRecordIds = new Set<Id>();
    Public static Map<string,string> piIdToObjIdMap = new Map<string,string>();
    Public static Map<Id,string> objIdToTitleMap = new Map<Id,string>();
    Public static Map<string,string> recordIdToPiwiIdMap = new Map<string,string>();
    Public static Set<Id> iupgmBasedApprovalIds = new set<Id>();
    Public static Set<string> iupgmBasedApprovalObj = new Set<string>();
    Public static Map<string,sObject> objNameToSObjectMap =  new Map<string,sObject>();
    Public static Map<string,set<string>> progToBudgetSetMap = new Map<string,set<string>>();
    Public static Map<String, ApprovalRequestWrapper> objApprovalRequestMap = new Map<String, ApprovalRequestWrapper>();
    Public static Map<string,Map<string,SObjectField>> objNameToApiNameToType = new Map<string,Map<string,SObjectField>>();
    Public static Map<string, Core_MDF_CCP_Custom_Metadata_Utility__c> approvalReqObjMdtPIMap = new Map<string, Core_MDF_CCP_Custom_Metadata_Utility__c>();
    static final string NON_BUDGETTYPE_ROLE = Core_MDF_CCP_ConstantClass.CCF_PRICE_REVIEWER;
    static final string PRICE_REVIEWER = Core_MDF_CCP_ConstantClass.PRICE_REVIEWER;
    static final string HOST_REGION_PROGRAM = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
    static final string STR_WW = 'WW';
    static final string STR_No = 'No';                              
    
    @AuraEnabled
    Public static string getRecordsToApprove() {
        set<string> programSet = new set<string>();
        Boolean isIUPGMBasedApprover = false;
        List<string> permissionSetList = new List<string>();
        set<string> programNameSet = new set<string>();
        set<string> rolesSet = new set<string>();
        set<string> iupgmProgram = new set<string>();
        set<string> iupgmRoles = new set<string>();
        set<string> progNameSet = new set<string>();
        List<PartnerFundRequest> pfrToApprove = new List<PartnerFundRequest>();
        List<ApprovalWrapper> approvalWrapList = new List<ApprovalWrapper>();
        List<Core_MDF_CCP_IUPGM_Approver_Mapping__c> iupgmApproverList = new List<Core_MDF_CCP_IUPGM_Approver_Mapping__c>();
        Map<string,Map<string,set<string>>> objectToApprovalStageMap = new Map<string,map<string,set<string>>>(); 
        Map<string,Map<string,set<string>>> psToProgToBTSetMap = new Map<string,map<string,set<string>>>();
        
        try{
            string userId = userinfo.getUserId();
            for(PermissionSetAssignment ps : [SELECT Id,AssigneeId, PermissionSet.Name 
                                              FROM PermissionSetAssignment 
                                              WHERE AssigneeId =: userId AND PermissionSet.Name Like: 'Core_MDF%']){
                                                  permissionSetList.add(ps.PermissionSet.Name);
                                              } 
            
            iupgmApproverList = [SELECT Id,Core_MDF_Program_txt__c,Core_MDF_Approval_Stage_txt__c,Core_MDF_Object_Name_txt__c,Core_MDF_Role_txt__c
                                 FROM Core_MDF_CCP_IUPGM_Approver_Mapping__c
                                 WHERE Core_MDF_Active_ind__c = true];
            
            //Query to retrieve records from the Custom Metadata Utility Object
            String query = 'SELECT ' +
            'Core_MDF_Field_9_txt__c, ' +
            'Core_MDF_Field_10_txt__c, ' +
            'Core_MDF_Program__c, ' +
            'Core_MDF_Field_12_txt__c, ' +
            'Core_MDF_Field_8_txt__c, ' +
            'Core_MDF_Field_11_txt__c, ' +
            'Core_MDF_Field_5_txt__c, ' +
            'Core_MDF_Field_6_txt__c, ' +
            'Core_MDF_Field_14_txt__c, ' +  //Added               
            'Core_MDF_Field_7_txt__c, ' + 
            'Core_MDF_Field_13_txt__c, ' + 
            'Core_MDF_Field_1_txt__c, ' + 
            'Core_MDF_Checkbox_Field_1_Ind__c ' + 
            'FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +
            'WHERE Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.APPROVAL_REQUEST_OBJECT_CATEGORY) + '\' ' +
            'AND Core_MDF_Is_Active_Ind__c = TRUE';
			/*([SELECT Core_MDF_Object_Label_Name__c, Core_MDF_Object_Name__c,Core_MDF_Program__c, 
                                                                    Core_MDF_Title_Field__c, Core_MDF_Icon_Name__c, Core_MDF_Table_View_Field_Properties__c,
                                                                    Core_MDF_Compact_Field_Properties__c, Core_MDF_Detail_Field_Properties__c,
                                                                    Core_MDF_Fields_API_Name__c,Core_MDF_Conditional_Field__c,Core_MDF_By_Pass_Bulk__c
                                                                    FROM Core_MDF_Approval_Req_Object_Config__mdt
                                                                    WHERE Core_MDF_Active__c = true])*/
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> customMetadataUtilityRecords = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);
            for(Core_MDF_CCP_Custom_Metadata_Utility__c appReq : customMetadataUtilityRecords){ 
                                                                        approvalReqObjMdtPIMap.put(appReq.Core_MDF_Field_10_txt__c, appReq);
                                                                    }
            
            for(Core_MDF_Record_Tracking__c track : [SELECT Id, Core_MDF_Object_Name_nm__c, Core_MDF_Scope_nm__c, Core_MDF_Target_Record_Id__c,
                                                     Core_MDF_Execution_InProgress_Ind__c
                                                     FROM Core_MDF_Record_Tracking__c 
                                                     WHERE Core_MDF_Execution_InProgress_Ind__c = true]){
                                                         inProgressPIWITrackingIds.add(track.Core_MDF_Target_Record_Id__c);
                                                     }
            
            if(!inProgressPIWITrackingIds.isEmpty()){
                for(ProcessInstanceWorkItem pIWI : [SELECT Id,ProcessInstance.TargetObjectId
                                                    FROM ProcessInstanceWorkItem 
                                                    WHERE ID IN: inProgressPIWITrackingIds]){inProgressTrackingRecordIds.add(pIWI.ProcessInstance.TargetObjectId);
                                                                                            } 
            }

            
            if(!iupgmApproverList.isEmpty() && !permissionSetList.isEmpty()){
                for(Core_MDF_ChannelProgram__mdt cpm : ([SELECT Core_MDF_Abbreviated_ProgramName_txt__c, MasterLabel,Core_MDF_Technical_Program_Name__c
                                                         FROM Core_MDF_ChannelProgram__mdt
                                                         WHERE Core_MDF_Abbreviated_ProgramName_txt__c != null])){ 
                                                             progNameSet.add(cpm.MasterLabel);
                                                             progTechNameToLabelMap.put(cpm.Core_MDF_Technical_Program_Name__c, cpm.MasterLabel);
                                                         }                               
                
                
                
                for(Core_MDF_Program_Budget_RecordType__mdt mdtConfiq: [select Id,Core_MDF_Program__c, Core_MDF_Account_Manager_PS_API_Name__c, Core_MDF_BudgetType__c 
                                                                        FROM Core_MDF_Program_Budget_RecordType__mdt 
                                                                        where Core_MDF_BudgetType__c != null AND Core_MDF_Account_Manager_PS_API_Name__c != null ]){
                                                                            if(permissionSetList.contains(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c)){
                                                                                if(psToProgToBTSetMap.containsKey(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c)){
                                                                                    if(psToProgToBTSetMap.get(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c).containsKey(mdtConfiq.Core_MDF_Program__c  )){
                                                                                        psToProgToBTSetMap.get(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c).get(mdtConfiq.Core_MDF_Program__c).add(mdtConfiq.Core_MDF_BudgetType__c);
                                                                                    }else{
                                                                                        psToProgToBTSetMap.get(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c).put(mdtConfiq.Core_MDF_Program__c,new set<string>{mdtConfiq.Core_MDF_BudgetType__c});
                                                                                    }
                                                                                }else{
                                                                                    map<String,set<string>> progToBTSetMap = new map<String,set<string>>();
                                                                                    progToBTSetMap.put(mdtConfiq.Core_MDF_Program__c,new set<string>{mdtConfiq.Core_MDF_BudgetType__c});
                                                                                    psToProgToBTSetMap.put(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c, progToBTSetMap);
                                                                                }
                                                                                
                                                                                
                                                                            }
                                                                        }
                
                for(Core_MDF_CCP_IUPGM_Approver_Mapping__c csObj: iupgmApproverList){
                    if(permissionSetList.contains(csObj.Core_MDF_Role_txt__c)){
                        iupgmBasedApprovalObj.add(csObj.Core_MDF_Object_Name_txt__c);
                        if(string.isNotBlank(csObj.Core_MDF_Role_txt__c ) && string.isNotBlank(csObj.Core_MDF_Approval_Stage_txt__c)){
                            if(objectToApprovalStageMap.containsKey(csObj.Core_MDF_Object_Name_txt__c)){
                                if(objectToApprovalStageMap.get(csObj.Core_MDF_Object_Name_txt__c).containsKey(csObj.Core_MDF_Role_txt__c   )){
                                    objectToApprovalStageMap.get(csObj.Core_MDF_Object_Name_txt__c).get(csObj.Core_MDF_Role_txt__c).add(csObj.Core_MDF_Approval_Stage_txt__c);
                                }else{
                                    objectToApprovalStageMap.get(csObj.Core_MDF_Object_Name_txt__c).put(csObj.Core_MDF_Role_txt__c,new set<string>{csObj.Core_MDF_Approval_Stage_txt__c});
                                }
                            }else{
                                map<String,set<string>> roleToApprovalStageSetMap = new map<String,set<string>>();
                                roleToApprovalStageSetMap.put(csObj.Core_MDF_Role_txt__c,new set<string>{csObj.Core_MDF_Approval_Stage_txt__c});
                                objectToApprovalStageMap.put(csObj.Core_MDF_Object_Name_txt__c, roleToApprovalStageSetMap);
                            }
                        }
                        
                        programSet.add(csObj.Core_MDF_Program_txt__c);  
                        rolesSet.add(csObj.Core_MDF_Role_txt__c	);
                    }
                }
            }
            
            if(!programSet.isEmpty() && !rolesSet.isEmpty()){
                
                //map<string,set<string>> roleToStageSetMap = new map<string,set<string>>();
                if(!objectToApprovalStageMap.isEmpty() && !objectToApprovalStageMap.values().isEmpty()){
                    for(map<string,set<string>> roleToStageMap : objectToApprovalStageMap.values()){
                        for(string role: roleToStageMap.keySet()){
                            if(roleToStageSetMap.containsKey(role)){
                                roleToStageSetMap.get(role).addAll(roleToStageMap.get(role));
                            }else{
                                roleToStageSetMap.put(role, roleToStageMap.get(role));
                            }
                        }
                    }
                }
                
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm: [SELECT Id, Core_MDF_All_Accounts_cd__c,Core_MDF_Program_nm__c,Core_MDF_Account_id__r.Name,Core_MDF_Channel_Program_id__r.Name,                               
                                                                      Core_MDF_Region_cd__c, Core_MDF_Account_id__c, Core_MDF_Channel_Program_id__c,Core_MDF_User_id__c,                               
                                                                      Core_MDF_Sub_Region_cd__c,Core_MDF_Region_Sub_Region_nm__c,Core_MDF_Role_nm__c,Core_MDF_Account_id__r.Core_MDF_Group_Id__c,
                                                                      Core_MDF_Budget_Type_nm__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c,Core_MDF_Activity_Classification_nm__c,
                                                                      /*Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c ,*/Core_MDF_All_Budget_Type_Access_Ind__c,Core_MDF_Approval_Region_nm__c                             
                                                                      FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c  
                                                                      WHERE Core_MDF_User_id__c =: userId 
                                                                      and Core_MDF_Is_Not_an_Approver_Ind__c = false
                                                                      and Core_MDF_Program_nm__c IN: programSet  
                                                                      and Core_MDF_Role_nm__c IN: rolesSet 
                                                                      and Core_MDF_Active_Ind__c = true]){
                                                                          
                                                                          KeySetWrapper keyWrap =  new KeySetWrapper();
                                                                          Set<string> approvalStageSet = new Set<string>();
                                                                          Set<string> iupgmClassifications = new Set<string>();
                                                                          
                                                                          iupgmProgram.add(iupgm.Core_MDF_Program_nm__c);
                                                                          iupgmRoles.add(iupgm.Core_MDF_Role_nm__c);
                                                                          
                                                                          if(!psToProgToBTSetMap.isEmpty() && !psToProgToBTSetMap.values().isEmpty()){
                                                                              if(psToProgToBTSetMap.containsKey(iupgm.Core_MDF_Role_nm__c) && psToProgToBTSetMap.get(iupgm.Core_MDF_Role_nm__c) != null){
                                                                                  
                                                                                  Map<string,set<string>> progToBTMap = psToProgToBTSetMap.get(iupgm.Core_MDF_Role_nm__c);
                                                                                  for(string prog: progToBTMap.keySet()){
                                                                                      string progLabel = progTechNameToLabelMap.containsKey(prog) ? progTechNameToLabelMap.get(prog) : '';
                                                                                      if(string.isNotBlank(progLabel)){
                                                                                          if(progToBudgetSetMap.containsKey(progLabel)){
                                                                                              progToBudgetSetMap.get(progLabel).addAll(progToBTMap.get(prog));
                                                                                          }else{
                                                                                              progToBudgetSetMap.put(progLabel, progToBTMap.get(prog));
                                                                                          }
                                                                                      }                               
                                                                                  }
                                                                                  
                                                                              }
                                                                          }
                                                                          
                                                                          if(string.isNotBlank(iupgm.Core_MDF_Activity_Classification_nm__c)){
                                                                              iupgmClassifications.addAll(iupgm.Core_MDF_Activity_Classification_nm__c.split(';'));
                                                                          }
                                                                          
                                                                          if(!roleToStageSetMap.isEmpty() && roleToStageSetMap.containsKey(iupgm.Core_MDF_Role_nm__c) && !roleToStageSetMap.get(iupgm.Core_MDF_Role_nm__c).isEmpty()){
                                                                              if(!iupgmClassifications.isEmpty()){
                                                                                  set<string> confiqApprovalStage = roleToStageSetMap.get(iupgm.Core_MDF_Role_nm__c);
                                                                                  for(string iupgmStage: iupgmClassifications){
                                                                                      for(string confiqStage: confiqApprovalStage){
                                                                                          if(confiqStage.contains(iupgmStage)){
                                                                                              approvalStageSet.add(confiqStage);
                                                                                          }
                                                                                      }
                                                                                  }
                                                                              }else{
                                                                                  approvalStageSet = roleToStageSetMap.get(iupgm.Core_MDF_Role_nm__c);
                                                                              }
                                                                          }                      
                                                                          
                                                                          if(!approvalStageSet.isEmpty()){
                                                                              keyWrap = getAllIUPGMKey(iupgm,approvalStageSet);
                                                                          }
                                                                          
                                                                          if(!keyWrap.allAccSpecificBTSet.isEmpty()){
                                                                              allAccSpecificBTSet.addAll(keyWrap.allAccSpecificBTSet);
                                                                          }
                                                                          if(!keyWrap.singleAccSpecificBTSet.isEmpty()){
                                                                              singleAccSpecificBTSet.addAll(keyWrap.singleAccSpecificBTSet);
                                                                          }
                                                                          if(!keyWrap.allAccAllBTSet.isEmpty()){
                                                                              allAccAllBTSet.addAll(keyWrap.allAccAllBTSet);
                                                                          }
                                                                          if(!keyWrap.singleAccAllBTSet.isEmpty()){
                                                                              singleAccAllBTSet.addAll(keyWrap.singleAccAllBTSet);
                                                                          }
                                                                      }
                
                
                if(!allAccSpecificBTSet.isEmpty() || !singleAccSpecificBTSet.isEmpty() || !allAccAllBTSet.isEmpty() || !singleAccAllBTSet.isEmpty()){
                    isIUPGMBasedApprover = true;
                }
                
                if(isIUPGMBasedApprover){
                    for (ChannelProgram cp : [SELECT Id, Name                               
                                              FROM ChannelProgram                               
                                              WHERE Name IN: progNameSet]){                               
                                                  progToIdMap.put(cp.Name,cp.Id);                             
                                              } 
                    
                    if(!progTechNameToLabelMap.isEmpty()){
                        for(string prog: iupgmProgram){
                            if(progTechNameToLabelMap.containsKey(prog)){
                                programNameSet.add(progTechNameToLabelMap.get(prog));
                            }
                        }
                    }
                }
                
            }
            
            if(!approvalReqObjMdtPIMap.isEmpty()){
                for(string objName: approvalReqObjMdtPIMap.keyset()){
                    Schema.SObjectType sObjType = ((SObject)(Type.forName('Schema.'+objName).newInstance())).getSObjectType();
                    DescribeSObjectResult sObjResult = sObjType.getDescribe();
                    Map<String,SObjectField> objectFieldMap = sObjResult.fields.getMap();
                    objNameToApiNameToType.put(objName, objectFieldMap);
                }
            }
            
            
        if(!iupgmBasedApprovalObj.isEmpty() && isIUPGMBasedApprover && !objectToApprovalStageMap.isEmpty()){
	            //Avoid Deeply Nested IF Statements
                if(objectToApprovalStageMap.containsKey('PartnerFundRequest') && !objectToApprovalStageMap.get('PartnerFundRequest').isEmpty()){
                    set<string> approvalStage = new set<string>();
                    approvalStage = getApprovalRoles(objectToApprovalStageMap,iupgmRoles,'PartnerFundRequest');
                    ApprovalWrapper appWrapObj = getPFRApprovers(programNameSet,approvalStage,'PartnerFundRequest');
                    if(appWrapObj != null){
                        approvalWrapList.add(appWrapObj);
                    }
                }
                if(objectToApprovalStageMap.containsKey('Campaign') && !objectToApprovalStageMap.get('Campaign').isEmpty()){
                    set<string> approvalStage = new set<string>();
                    approvalStage = getApprovalRoles(objectToApprovalStageMap,iupgmRoles,'Campaign');
                    ApprovalWrapper appWrapObj = getCampaignApprovers(programNameSet,approvalStage,'Campaign');
                    if(appWrapObj != null){
                        approvalWrapList.add(appWrapObj);
                    }
                }
                if(objectToApprovalStageMap.containsKey('PartnerMarketingBudget') && !objectToApprovalStageMap.get('PartnerMarketingBudget').isEmpty()){
                    set<string> approvalStage = new set<string>();
                    approvalStage = getApprovalRoles(objectToApprovalStageMap,iupgmRoles,'PartnerMarketingBudget');
                    ApprovalWrapper appWrapObj = getBudgetApprovers(programNameSet,approvalStage,'PartnerMarketingBudget');
                    if(appWrapObj != null){
                        approvalWrapList.add(appWrapObj);
                    }
                }
                if(objectToApprovalStageMap.containsKey('PartnerFundClaim') && !objectToApprovalStageMap.get('PartnerFundClaim').isEmpty()){
                    set<string> approvalStage = new set<string>();approvalStage = getApprovalRoles(objectToApprovalStageMap,iupgmRoles,'PartnerFundClaim');ApprovalWrapper appWrapObj = getPFCApprovers(programNameSet,approvalStage,'PartnerFundClaim');if(appWrapObj != null){approvalWrapList.add(appWrapObj);
                    }
                }
        }
        
        
        if(!approvalReqObjMdtPIMap.isEmpty()){
            //Get all the approval process for all objects
            Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
            
            if(groupIds != null && !groupIds.isEmpty()){
     
                for(GroupMember gm : [SELECT group.name,group.id,group.type 
                                      FROM GroupMember 
                                      WHERE (UserOrGroupId =: groupIds OR group.id =: groupIds) AND group.type = 'Queue' limit 10000]){
                                              queueIds.add(gm.group.id);    
                                          }
                }
                
                for(string objName: approvalReqObjMdtPIMap.keyset()){
                    ApprovalWrapper appWrapObj = getApproversBasedOnPI(objName);
                    if(appWrapObj != null){ Boolean isObjectAvailable = false;
                        if(!approvalWrapList.isEmpty()){for(ApprovalWrapper wrap: approvalWrapList){if(wrap.objectName == appWrapObj.objectName && wrap.icon == appWrapObj.icon){wrap.count += appWrapObj.count; isObjectAvailable = true;wrap.recordsToApprove.addAll(appWrapObj.recordsToApprove);
                                }
                            }
                        }
                        if(!isObjectAvailable){approvalWrapList.add(appWrapObj);}
                    } 
                }
            }
        }
        catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);
           
        }
        return JSON.serialize(approvalWrapList);
    }
    
    Public static set<string> getApprovalRoles(Map<string,Map<string,set<string>>> objectToApprovalStageMap,set<string> iupgmRoles, string objName){
        map<string,set<string>> roleToStageMap = new map<string,set<string>>();
        set<string> approvalStage = new set<string>();
        roleToStageMap = objectToApprovalStageMap.get(objName);
        
        if(!roleToStageMap.isEmpty()){
            for(string role: roleToStageMap.keySet()){
                if(iupgmRoles.contains(role)){
                    approvalStage.addAll(roleToStageMap.get(role));
                }
            }   
        }
        return approvalStage;
    }
    
    
    Public static KeySetWrapper getAllIUPGMKey(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm,set<string> approvalStageSet){
        
        KeySetWrapper keyWrap = new KeySetWrapper();
        List<string> geoSubGeoList = new List<string>();
        
        Map<string,List<string>> regionToBudgetTypeMap = new Map<string,List<string>>();
        List<string> regionToBudgetSet = new List<string>();
        
        set<string> allAccAllBTSet = new set<string>();//Key: Region_SubRegion_ProgramId_Stage 
        set<string> allAccSpecificBTSet = new set<string>();//Key: Region_SubRegion->ProgramId_Stage_BudgetType
        set<string> singleAccAllBTSet = new set<string>();//Key: Region_SubRegion->ProgramId_Stage_Account
        set<string> singleAccSpecificBTSet = new set<string>();//Key: Region_SubRegion->ProgramId_Stage_BudgetType_Account
     
        //Approval Region is populated for IPA Price Reviewer role.
        if(iupgm.Core_MDF_Program_nm__c=='CoGTM'){
           geoSubGeoList.add('EMEA;PRC;APJ;ASMO;INDIA');geoSubGeoList.add('WW');
           //geoSubGeoList.add(Core_MDF_CCP_ConstantClass.CAMPAIGN_ALL_REGION);
        }else{
        geoSubGeoList = iupgm.Core_MDF_Approval_Region_nm__c != null 
                        ? iupgm.Core_MDF_Approval_Region_nm__c.split(';') : iupgm.Core_MDF_Region_Sub_Region_nm__c != null 
                        ? iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';') : new List<string>();
        }
        
        if(iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c != null){
            regionToBudgetSet = iupgm.Core_MDF_GeoSubGeo_Budget_Type_nm__c.split(';');//APJ->DCA;APJ->CCA
        }
        
        
        if(!regionToBudgetSet.isEmpty()){
            for(string regionBT : regionToBudgetSet){
                if(regionBT.contains('->')){
                    List<string> regionToBT = regionBT.split('->');
                    string geo = regionToBT[0];
                    string budget = regionToBT[1];
                    if(regionToBudgetTypeMap.containsKey(geo)){
                        regionToBudgetTypeMap.get(geo).add(budget);
                    }else{
                        regionToBudgetTypeMap.put(geo,new List<string>{budget});
                    }
                }
            }
        }
        if(((/*CHANNEL_MDF_PROG.equals(iupgm.Core_MDF_Program_nm__c) ||*/ IPA_PROG.equals(iupgm.Core_MDF_Program_nm__c))
            && !iupgm.Core_MDF_All_Budget_Type_Access_Ind__c && !NON_BUDGETTYPE_ROLE.contains(iupgm.Core_MDF_Role_nm__c))){
                
                // Key for Specific Budget Type
                if(!geoSubGeoList.isEmpty()){
                    for(string geo: geoSubGeoList){
                        if(regionToBudgetTypeMap.containsKey(geo) && !regionToBudgetTypeMap.get(geo).isEmpty()){
                            for(string budgetType: regionToBudgetTypeMap.get(geo)){ 
                                budgetType = budgetType.replaceAll('\\s+', '');
                                for(string str: approvalStageSet){
                                    string approvalStage = str.replaceAll('\\s+', '');
                                    string allAccSpecificBTKey = geo + '->' + (string)iupgm.Core_MDF_Channel_Program_id__c + '_' + approvalStage + '_' + budgetType;
                                    allAccSpecificBTSet.add(allAccSpecificBTKey);
                                    
                                    //Add account
                                    if(iupgm.Core_MDF_All_Accounts_cd__c == STR_No){
                                        string singleAccSpecificBTKey = allAccSpecificBTKey + '_' + (string)iupgm.Core_MDF_Account_id__c;
                                        singleAccSpecificBTSet.add(singleAccSpecificBTKey);
                                    }
                                    
                                } 
                            }
                        }
                    }
                }
                
                if(!singleAccSpecificBTSet.isEmpty()){
                    keyWrap.singleAccSpecificBTSet = singleAccSpecificBTSet;
                }else if(!allAccSpecificBTSet.isEmpty()){
                    keyWrap.allAccSpecificBTSet = allAccSpecificBTSet;
                }
            }
            
        else{
            // Key for All Budget Type
            if(!geoSubGeoList.isEmpty()){
                for(string regionSub: geoSubGeoList){
                    for(string str: approvalStageSet){
                        string approvalStage = str.replaceAll('\\s+', '');
                        string allAccAllBTKey = regionSub + '->' + (string)iupgm.Core_MDF_Channel_Program_id__c + '_' + approvalStage;
                        allAccAllBTSet.add(allAccAllBTKey);
                        
                        //Add account
                        if(iupgm.Core_MDF_All_Accounts_cd__c == STR_No){
                            string singleAccAllBTKey = allAccAllBTKey +'_'+ (string)iupgm.Core_MDF_Account_id__c;
                            singleAccAllBTSet.add(singleAccAllBTKey);
                        }
                        
                    }
                    
                    
                }
            }
            if(!singleAccAllBTSet.isEmpty()){
                keyWrap.singleAccAllBTSet = singleAccAllBTSet;
            }else if(!allAccAllBTSet.isEmpty()){
                keyWrap.allAccAllBTSet = allAccAllBTSet;
            }
        } 
        return keyWrap;
    }
    
    Public static ApprovalWrapper getPFRApprovers(set<string> programNameSet, set<string> approvalStageSet, string objName){
        
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        
        set<Id> pfrIds = new set<Id>();
        List<PartnerFundRequest> pfrToApproveList = new List<PartnerFundRequest>();
        List<RecordsToApprove> recordWrapList = new List<RecordsToApprove>();
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        approvalWrap.icon = String.valueOf(mdtValues.Core_MDF_Field_8_txt__c);
        approvalWrap.objectName = String.valueOf(mdtValues.Core_MDF_Field_9_txt__c);
        
        ParamWrapper paramWrap = new ParamWrapper();
        paramWrap.fieldApiNames = String.valueOf(mdtValues.Core_MDF_Field_7_txt__c);
        paramWrap.inProgressTrackingRecordIds = inProgressTrackingRecordIds;
        paramWrap.programNameSet = programNameSet;
        paramWrap.approvalStageSet = approvalStageSet;
        pfrList = Core_MDF_IUPGM_ApprovalRequestData.getPfrRecordData(paramWrap);

        
        if(!pfrList.isEmpty()){
            for(PartnerFundRequest pfr: pfrList){
                string allAccAllBTSetKey,allAccSpecificBTSetKey,singleAccAllBTSetKey,singleAccSpecificBTSetKey;
                string budgetType = string.isNotBlank(pfr.Core_MDF_Budget_Type_nm__c) ? pfr.Core_MDF_Budget_Type_nm__c.replaceAll('\\s+', '') : '';
                string progId = progToIdMap.get(pfr.Core_MDF_Program__c);
                string approvalStage = string.isNotBlank(pfr.Core_MDF_Approval_Stage__c) ? pfr.Core_MDF_Approval_Stage__c.replaceAll('\\s+', '') : '';
                string region = pfr.Core_MDF_Host_Region_or_Region_txt__c;//For IPA & !PCT it stores Host Geo, else Transaction geo.   
                
                if(string.isNotBlank(region)){
                    if(progToBudgetSetMap.containsKey(pfr.Core_MDF_Program__c) && progToBudgetSetMap.get(pfr.Core_MDF_Program__c) != null){
                        //Updated the if/else to accomodate the Additional reviewer approval
                        if(pfr.Core_MDF_Approval_Stage__c != 'Additional Reviewer' && progToBudgetSetMap.get(pfr.Core_MDF_Program__c).contains(pfr.Core_MDF_Budget_Type_nm__c)){
                                allAccAllBTSetKey = pfr.Core_MDF_Sub_Region_nm__c != null ? region + '-' + pfr.Core_MDF_Sub_Region_nm__c +'->' + progId + '_' + approvalStage  : region +'->'+ progId + '_' + approvalStage;
                            }
                         else if(pfr.Core_MDF_Approval_Stage__c == 'Additional Reviewer' && hasAdditionalReviewAccess(pfr)){allAccAllBTSetKey = pfr.Core_MDF_Sub_Region_nm__c != null ? region + '-' + pfr.Core_MDF_Sub_Region_nm__c +'->' + progId + '_' + approvalStage  : region +'->'+ progId + '_' + approvalStage;
                        }
                        
                    }
                    else{
                        allAccAllBTSetKey = pfr.Core_MDF_Sub_Region_nm__c != null ? region + '-' + pfr.Core_MDF_Sub_Region_nm__c +'->' + progId + '_' + approvalStage  : region +'->'+ progId + '_' + approvalStage;
                    }
                }
                
                if(string.isNotBlank(allAccAllBTSetKey)){
                    allAccSpecificBTSetKey = budgetType != null ? allAccAllBTSetKey + '_' + budgetType : '';
                }
                
                if(string.isNotBlank(pfr.Core_MDF_Program__c)){
                    if(string.isNotBlank(allAccAllBTSetKey)){
                        if(pfr.Core_MDF_Program__c == RMF_PROG && pfr.Core_MDF_Approval_Stage__c != 'Price Reviewer'){
                            singleAccAllBTSetKey = allAccAllBTSetKey + '_' +pfr.ChannelPartnerId;
                            }else if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM 
                                     && (pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER 
                                    || pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL)
                                    && string.isNotBlank(pfr.Core_MDF_Campaign_Ultimate_Account_Id__c)){
                                        singleAccAllBTSetKey = allAccAllBTSetKey + '_' + pfr.Core_MDF_Campaign_Ultimate_Account_Id__c;
                        }else if(string.isNotBlank(pfr.Core_MDF_Ultimate_Account_Id__c)){
                            singleAccAllBTSetKey = allAccAllBTSetKey + '_' + pfr.Core_MDF_Ultimate_Account_Id__c;
                        }
                    }
                    if(string.isNotBlank(allAccSpecificBTSetKey)){
                        if(pfr.Core_MDF_Program__c == RMF_PROG && pfr.Core_MDF_Approval_Stage__c != 'Price Reviewer'){singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' +pfr.ChannelPartnerId;}else if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM && (pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER || pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL) && string.isNotBlank(pfr.Core_MDF_Campaign_Ultimate_Account_Id__c)){singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' + pfr.Core_MDF_Campaign_Ultimate_Account_Id__c;}else if(string.isNotBlank(pfr.Core_MDF_Ultimate_Account_Id__c)){singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' + pfr.Core_MDF_Ultimate_Account_Id__c; } }
                }
                
                string WW_allAccAllBTSetKey;
                string WW_allAccSpecificBTSetKey;
                string WW_singleAccAllBTSetKey;
                string WW_singleAccSpecificBTSetKey;
                
                if(string.isNotBlank(allAccAllBTSetKey) && allAccAllBTSetKey.contains('->')){
                    List<string> tempList = allAccAllBTSetKey.split('->');
                    WW_allAccAllBTSetKey = STR_WW + '->' + tempList[1];
                }
                
                if(string.isNotBlank(allAccSpecificBTSetKey) && allAccSpecificBTSetKey.contains('->')){List<string> tempList = allAccSpecificBTSetKey.split('->');WW_allAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                }
                if(string.isNotBlank(singleAccAllBTSetKey) && singleAccAllBTSetKey.contains('->')){
                    List<string> tempList = singleAccAllBTSetKey.split('->');
                    WW_singleAccAllBTSetKey = STR_WW + '->' + tempList[1];
                }
                if(string.isNotBlank(singleAccSpecificBTSetKey) && singleAccSpecificBTSetKey.contains('->')){
                    List<string> tempList = singleAccSpecificBTSetKey.split('->');
                    WW_singleAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                }
                
                if((!allAccAllBTSet.isEmpty() && string.isNotBlank(allAccAllBTSetKey) && string.isNotBlank(WW_allAccAllBTSetKey) && (allAccAllBTSet.contains(allAccAllBTSetKey) || allAccAllBTSet.contains(WW_allAccAllBTSetKey) )) ||
                   (!allAccSpecificBTSet.isEmpty() && string.isNotBlank(allAccSpecificBTSetKey) && string.isNotBlank(WW_allAccSpecificBTSetKey) && (allAccSpecificBTSet.contains(allAccSpecificBTSetKey) || allAccSpecificBTSet.contains(WW_allAccSpecificBTSetKey))) ||
                   (!singleAccAllBTSet.isEmpty() && string.isNotBlank(singleAccAllBTSetKey) && string.isNotBlank(WW_singleAccAllBTSetKey) && (singleAccAllBTSet.contains(singleAccAllBTSetKey) || singleAccAllBTSet.contains(WW_singleAccAllBTSetKey))) ||
                   (!singleAccSpecificBTSet.isEmpty() && string.isNotBlank(singleAccSpecificBTSetKey) && string.isNotBlank(WW_singleAccSpecificBTSetKey) && (singleAccSpecificBTSet.contains(singleAccSpecificBTSetKey) || singleAccSpecificBTSet.contains(WW_singleAccSpecificBTSetKey)))){
                       
                       pfrToApproveList.add(pfr);
                       pfrIds.add(pfr.Id);
                   }
            }
        }
        if(!pfrToApproveList.isEmpty()){
            
            //Check FLS
            if(!objNameToSObjectMap.containsKey(objName)){
                List<sObject> sObjList = new List<sObject>{pfrToApproveList[0]};
                objNameToSObjectMap = getFLSDetails(objName,sObjList);
            }
            
            if(objNameToSObjectMap != null && objNameToSObjectMap.containsKey(objName)){
                for(ProcessInstanceWorkItem piwi : [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Type,
                                                    ProcessInstance.TargetObject.Name,CreatedBy.name,CreatedDate FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN: pfrIds
                                                    AND ProcessInstance.Status =: Core_MDF_CCP_ConstantClass.PFR_PENDING_STATUS
                                                    AND ProcessInstance.TargetObject.Type =: objName]){
                                                        iupgmBasedApprovalIds.add(piwi.ProcessInstance.TargetObjectId);
                                                        recordIdToPiwiIdMap.put(piwi.ProcessInstance.TargetObjectId, piwi.Id); 
                                                    }
                
                for(PartnerFundRequest pfr: pfrToApproveList){
                    recordWrapList.add(getobjRecordDetails(pfr, objName));
                }
            }
           
        }
        approvalWrap.count = recordWrapList.size();
        approvalWrap.byPassBulk = mdtValues.Core_MDF_Checkbox_Field_1_Ind__c;
        approvalWrap.RecordsToApprove = recordWrapList;
        if(!recordWrapList.isEmpty()){
            return approvalWrap; 
        }else{
            return null; 
        }
        
    }
    
    /*****************************************************************************************************
Method Name :   getCampaignApprovers
Description :   to get the Campaign records for approvals
Added By    :   Saikat Manna                  
******************************************************************************************************/
    Public static ApprovalWrapper getCampaignApprovers(set<string> programNameSet, set<string> approvalStageSet, string objName){
        List<Campaign> campList = new List<Campaign>();
        List<Campaign> campToApproveList = new List<Campaign>();
        Set<Id> campaignIdSet = new Set<Id>();
        List<SObject> objList = new List<SObject>();
        List<RecordsToApprove> recordWrapList = new List<RecordsToApprove>();
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        userPermissionApproval userPermissionWrap= new userPermissionApproval();
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        approvalWrap.icon = String.valueOf(mdtValues.Core_MDF_Field_8_txt__c);
        approvalWrap.objectName = String.valueOf(mdtValues.Core_MDF_Field_9_txt__c);
        
       
        ParamWrapper paramWrap = new ParamWrapper();
        paramWrap.fieldApiNames = String.valueOf(mdtValues.Core_MDF_Field_7_txt__c);
        paramWrap.inProgressTrackingRecordIds = inProgressTrackingRecordIds;
        paramWrap.programNameSet = programNameSet;
        paramWrap.approvalStageSet = approvalStageSet;
        campList = Core_MDF_IUPGM_ApprovalRequestData.getCampaignRecordData(paramWrap);       

        if(FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Proposal_Activity_L2_Approver') && approvalStageSet.contains('L2 Regional Sales')){
            userPermissionWrap.isL2SalesApprover = true;
        }
        
        if(FeatureManagement.checkPermission('Core_MDF_CCP_Int_IPA_ProposalL1_Approver') && approvalStageSet.contains('L1 Approval')){
            userPermissionWrap.isL1Approver = true;
        }
        
        
        if(!campList.isEmpty()){
            for(Campaign obj: campList){
                string allAccAllBTSetKey,allAccSpecificBTSetKey,singleAccAllBTSetKey,singleAccSpecificBTSetKey;
                string WW_allAccAllBTSetKey, WW_allAccSpecificBTSetKey, WW_singleAccAllBTSetKey, WW_singleAccSpecificBTSetKey;
                //string progId = progToIdMap.get(obj.Core_MDF_Program__c);
                string progId = progToIdMap.get(obj.Core_MDF_Program__c) !=null ? progToIdMap.get(obj.Core_MDF_Program__c): progToIdMap.get(obj.Core_MDF_Channel_Program__r.Name);
                string budgetType = string.isNotBlank(obj.Core_MDF_Opal_Budget_Type_Txt__c) ? obj.Core_MDF_Opal_Budget_Type_Txt__c.replaceAll('\\s+', '') : '';
                string approvalStage = string.isNotBlank(obj.Core_MDF_Approval_Stage_nm__c) ? obj.Core_MDF_Approval_Stage_nm__c.replaceAll('\\s+', '') : '';
              
                String ultimateAccount = (String)obj.Core_MDF_Ultimate_Account_txt__c;
                Id ultAccount= ultimateAccount;
                string region = HOST_REGION_PROGRAM.contains(obj.Core_MDF_Program__c) ? obj.Core_MDF_Host_Region_cd__c : obj.Core_MDF_Region_cd__c;
                
                if(string.isNotBlank(region)){
                    allAccAllBTSetKey = obj.Core_MDF_Sub_Region_cd__c != null ? 
                        region + '-' + obj.Core_MDF_Sub_Region_cd__c +'->' + progId + '_' + approvalStage  
                        : region +'->'+ progId + '_' + approvalStage;
                }
                
                //EMEA;PRC;APJ;ASMO->0PkD30000009JRGKA2_L2 Approval
                if(string.isNotBlank(allAccAllBTSetKey)){allAccSpecificBTSetKey = budgetType != null ? allAccAllBTSetKey + '_' + budgetType : ''; }
                //EMEA;PRC;APJ;ASMO->0PkD30000009JRGKA2_L2 Approval_Co-Engineering
                //Avoid Deeply Nested IF Statements
                    if(string.isNotBlank(obj.Core_MDF_Program__c) && string.isNotBlank(allAccAllBTSetKey)){singleAccAllBTSetKey = allAccAllBTSetKey + '_' + ultAccount;
                    }
                    if(string.isNotBlank(obj.Core_MDF_Program__c) && string.isNotBlank(allAccSpecificBTSetKey)){singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' + ultAccount;}
                
                if(string.isNotBlank(allAccAllBTSetKey) && allAccAllBTSetKey.contains('->')){List<string> tempList = allAccAllBTSetKey.split('->');WW_allAccAllBTSetKey = STR_WW + '->' + tempList[1];
                }
                if(string.isNotBlank(allAccSpecificBTSetKey) && allAccSpecificBTSetKey.contains('->')){List<string> tempList = allAccSpecificBTSetKey.split('->');WW_allAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                }
                if(string.isNotBlank(singleAccAllBTSetKey) && singleAccAllBTSetKey.contains('->')){List<string> tempList = singleAccAllBTSetKey.split('->');WW_singleAccAllBTSetKey = STR_WW + '->' + tempList[1]; }
                if(string.isNotBlank(singleAccSpecificBTSetKey) && singleAccSpecificBTSetKey.contains('->')){
                    List<string> tempList = singleAccSpecificBTSetKey.split('->');
                    WW_singleAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                }
                
                if((!allAccAllBTSet.isEmpty() && string.isNotBlank(allAccAllBTSetKey) && string.isNotBlank(WW_allAccAllBTSetKey) && (allAccAllBTSet.contains(allAccAllBTSetKey) || allAccAllBTSet.contains(WW_allAccAllBTSetKey) )) ||
                   (!allAccSpecificBTSet.isEmpty() && string.isNotBlank(allAccSpecificBTSetKey) && string.isNotBlank(WW_allAccSpecificBTSetKey) && (allAccSpecificBTSet.contains(allAccSpecificBTSetKey) || allAccSpecificBTSet.contains(WW_allAccSpecificBTSetKey))) ||
                   (!singleAccAllBTSet.isEmpty() && string.isNotBlank(singleAccAllBTSetKey) && string.isNotBlank(WW_singleAccAllBTSetKey) && (singleAccAllBTSet.contains(singleAccAllBTSetKey) || singleAccAllBTSet.contains(WW_singleAccAllBTSetKey))) ||
                   (!singleAccSpecificBTSet.isEmpty() && string.isNotBlank(singleAccSpecificBTSetKey) && string.isNotBlank(WW_singleAccSpecificBTSetKey) && (singleAccSpecificBTSet.contains(singleAccSpecificBTSetKey) || singleAccSpecificBTSet.contains(WW_singleAccSpecificBTSetKey)))){campToApproveList.add(obj);
                       campaignIdSet.add(obj.Id);
                   }
            
            }
            if(!campToApproveList.isEmpty()){

                //Check FLS
                if(!objNameToSObjectMap.containsKey(objName)){
                    List<sObject> sObjList = new List<sObject>{campToApproveList[0]};
                    objNameToSObjectMap = getFLSDetails(objName,sObjList);}if(objNameToSObjectMap != null && objNameToSObjectMap.containsKey(objName)){
                    for(ProcessInstanceWorkItem piwi : [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Type,
                                                        ProcessInstance.TargetObject.Name,CreatedBy.name,CreatedDate FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN: campaignIdSet
                                                        AND ProcessInstance.TargetObject.Type =: objName
                                                        AND ProcessInstance.Status =: Core_MDF_CCP_ConstantClass.PFR_PENDING_STATUS]){iupgmBasedApprovalIds.add(piwi.ProcessInstance.TargetObjectId); recordIdToPiwiIdMap.put(piwi.ProcessInstance.TargetObjectId, piwi.Id); 
                                                        }
                    for(Campaign obj: campToApproveList){
                        recordWrapList.add(getobjRecordDetails(obj, objName)); }}}} approvalWrap.count = recordWrapList.size();
        approvalWrap.byPassBulk = mdtValues.Core_MDF_Checkbox_Field_1_Ind__c;
        approvalWrap.RecordsToApprove = recordWrapList;
        approvalWrap.userPermission = userPermissionWrap;
        if(!recordWrapList.isEmpty()){
            return approvalWrap;
        }else{
            return null;
        }
        
    }
   
  /*****************************************************************************************************
Method Name :   getBudgetApprovers
Description :   to get the Campaign records for approvals
Added By    :   Shiva                  
******************************************************************************************************/
    Public static ApprovalWrapper getBudgetApprovers(set<string> programNameSet, set<string> approvalStageSet, string objName){string MDFPLUS_BUDGET_TYPE = Core_MDF_CCP_ConstantClass.MDFPLUS_BUDGET_TYPE;
        string MDF_BUDGET_TYPE = Core_MDF_CCP_ConstantClass.MDF_BUDGET_TYPE;
        string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;string Co_GTM_PROG = Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM;
        
        List<PartnerMarketingBudget> budgetObjRecordList = new List<PartnerMarketingBudget>();
        List<PartnerMarketingBudget> budgetToApproveList = new List<PartnerMarketingBudget>();
        Set<Id> budgetIdSet = new Set<Id>();
        List<SObject> objList = new List<SObject>();
        List<RecordsToApprove> recordWrapList = new List<RecordsToApprove>();
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        approvalWrap.icon = String.valueOf(mdtValues.Core_MDF_Field_8_txt__c);
        approvalWrap.objectName = String.valueOf(mdtValues.Core_MDF_Field_9_txt__c);

       
        ParamWrapper paramWrap = new ParamWrapper();
        paramWrap.fieldApiNames = String.valueOf(mdtValues.Core_MDF_Field_7_txt__c);
        paramWrap.inProgressTrackingRecordIds = inProgressTrackingRecordIds;
        paramWrap.programNameSet = programNameSet;
        budgetObjRecordList = Core_MDF_IUPGM_ApprovalRequestData.getBudgetRecordData(paramWrap);

        
        if(!budgetObjRecordList.isEmpty()){
            for(PartnerMarketingBudget obj: budgetObjRecordList){
                string allAccAllBTSetKey,allAccSpecificBTSetKey,singleAccAllBTSetKey,singleAccSpecificBTSetKey;
                string WW_allAccAllBTSetKey, WW_allAccSpecificBTSetKey, WW_singleAccAllBTSetKey, WW_singleAccSpecificBTSetKey;
                string progId = progToIdMap.get(obj.Core_MDF_Program_Nm__c);
                string budgetType = string.isNotBlank(obj.Core_MDF_Budget_Type_Txt__c) ? obj.Core_MDF_Budget_Type_Txt__c.replaceAll('\\s+', '') : '';
                String ultimateAccount = (String)obj.Core_MDF_Ultimate_Account_Id__c;
                Id ultAccount= ultimateAccount;
                string approvalStage = 'None';
                
                if((obj.Core_MDF_Program_Nm__c == IPA_PROG) /*|| (obj.Core_MDF_Program_Nm__c == Co_GTM_PROG)*/){
                    string region = string.isNotBlank(obj.Core_MDF_Budget_Partner__r.Core_Geo__c) ? obj.Core_MDF_Budget_Partner__r.Core_Geo__c : '';
                    
                    if(string.isNotBlank(region)){
                        allAccAllBTSetKey = region +'->'+ progId + '_' + approvalStage;
                    }
                    
                    if(string.isNotBlank(allAccAllBTSetKey)){
                        allAccSpecificBTSetKey = budgetType != null ? allAccAllBTSetKey + '_' + budgetType : '';
                    }
                    
                    if(string.isNotBlank(obj.Core_MDF_Program__c)){
                        if(string.isNotBlank(allAccAllBTSetKey)){
                            singleAccAllBTSetKey = allAccAllBTSetKey + '_' + ultAccount;
                        }
                        if(string.isNotBlank(allAccSpecificBTSetKey)){
                            singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' + ultAccount;
                        }
                    }
                    
                    if(string.isNotBlank(allAccAllBTSetKey) && allAccAllBTSetKey.contains('->')){
                        List<string> tempList = allAccAllBTSetKey.split('->');
                        WW_allAccAllBTSetKey = STR_WW + '->' + tempList[1];
                    }
                    if(string.isNotBlank(allAccSpecificBTSetKey) && allAccSpecificBTSetKey.contains('->')){
                        List<string> tempList = allAccSpecificBTSetKey.split('->');
                        WW_allAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                    }
                    if(string.isNotBlank(singleAccAllBTSetKey) && singleAccAllBTSetKey.contains('->')){
                        List<string> tempList = singleAccAllBTSetKey.split('->');
                        WW_singleAccAllBTSetKey = STR_WW + '->' + tempList[1];
                    }
                    if(string.isNotBlank(singleAccSpecificBTSetKey) && singleAccSpecificBTSetKey.contains('->')){
                        List<string> tempList = singleAccSpecificBTSetKey.split('->');
                        WW_singleAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                    }
                    if((!allAccAllBTSet.isEmpty() && string.isNotBlank(allAccAllBTSetKey) && string.isNotBlank(WW_allAccAllBTSetKey) && (allAccAllBTSet.contains(allAccAllBTSetKey) || allAccAllBTSet.contains(WW_allAccAllBTSetKey) )) ||
                       (!allAccSpecificBTSet.isEmpty() && string.isNotBlank(allAccSpecificBTSetKey) && string.isNotBlank(WW_allAccSpecificBTSetKey) && (allAccSpecificBTSet.contains(allAccSpecificBTSetKey) || allAccSpecificBTSet.contains(WW_allAccSpecificBTSetKey))) ||
                       (!singleAccAllBTSet.isEmpty() && string.isNotBlank(singleAccAllBTSetKey) && string.isNotBlank(WW_singleAccAllBTSetKey) && (singleAccAllBTSet.contains(singleAccAllBTSetKey) || singleAccAllBTSet.contains(WW_singleAccAllBTSetKey))) || (!singleAccSpecificBTSet.isEmpty() && string.isNotBlank(singleAccSpecificBTSetKey) && string.isNotBlank(WW_singleAccSpecificBTSetKey) && (singleAccSpecificBTSet.contains(singleAccSpecificBTSetKey) || singleAccSpecificBTSet.contains(WW_singleAccSpecificBTSetKey)))){ budgetToApproveList.add(obj);
                           budgetIdSet.add(obj.Id);
                       }
                    
                } 
                else if(obj.Core_MDF_Budget_Type_Txt__c == MDF_BUDGET_TYPE || obj.Core_MDF_Budget_Type_Txt__c == MDFPLUS_BUDGET_TYPE 
                        || obj.Core_MDF_Program_Nm__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM || obj.Core_MDF_Program_Nm__c == Co_GTM_PROG){
                    string region = 'WW';
                    
                    if(string.isNotBlank(region)){
                        WW_allAccAllBTSetKey = region +'->'+ progId + '_' + approvalStage;
                    }
                    
                    if(string.isNotBlank(WW_allAccAllBTSetKey)){
                        WW_allAccSpecificBTSetKey = budgetType != null ? WW_allAccAllBTSetKey + '_' + budgetType : '';
                    }
                    
                    if(string.isNotBlank(WW_allAccAllBTSetKey)){
                        WW_singleAccAllBTSetKey = WW_allAccAllBTSetKey + '_' + ultAccount;
                    }
                    if(string.isNotBlank(WW_allAccSpecificBTSetKey)){WW_singleAccSpecificBTSetKey = WW_allAccSpecificBTSetKey + '_' + ultAccount;
                    }
                    
                    if((!allAccAllBTSet.isEmpty() && string.isNotBlank(WW_allAccAllBTSetKey) && allAccAllBTSet.contains(WW_allAccAllBTSetKey) ) || (!allAccSpecificBTSet.isEmpty() && string.isNotBlank(WW_allAccSpecificBTSetKey) && allAccSpecificBTSet.contains(WW_allAccSpecificBTSetKey)) || (!singleAccAllBTSet.isEmpty() && string.isNotBlank(WW_singleAccAllBTSetKey) && singleAccAllBTSet.contains(WW_singleAccAllBTSetKey)) || (!singleAccSpecificBTSet.isEmpty() && string.isNotBlank(WW_singleAccSpecificBTSetKey) && singleAccSpecificBTSet.contains(WW_singleAccSpecificBTSetKey))){budgetToApproveList.add(obj);
                           budgetIdSet.add(obj.Id);
                       }
                }
                
            }
        }
            if(!budgetToApproveList.isEmpty()){
                //Check FLS
                if(!objNameToSObjectMap.containsKey(objName)){
                    List<sObject> sObjList = new List<sObject>{budgetToApproveList[0]};
                    objNameToSObjectMap = getFLSDetails(objName,sObjList);
                }
                if(objNameToSObjectMap != null && objNameToSObjectMap.containsKey(objName)){
                    for(ProcessInstanceWorkItem piwi : [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Type,
                                                        ProcessInstance.TargetObject.Name,CreatedBy.name,CreatedDate 
                                                        FROM ProcessInstanceWorkItem
                                                        WHERE ProcessInstance.TargetObjectId IN: budgetIdSet
                                                        AND ProcessInstance.TargetObject.Type =: objName
                                                        AND ProcessInstance.Status =: Core_MDF_CCP_ConstantClass.PFR_PENDING_STATUS]){
                                                            iupgmBasedApprovalIds.add(piwi.ProcessInstance.TargetObjectId);
                                                            recordIdToPiwiIdMap.put(piwi.ProcessInstance.TargetObjectId, piwi.Id); 
                                                        }
                    for(PartnerMarketingBudget obj: budgetToApproveList){
                        recordWrapList.add(getobjRecordDetails(obj, objName));
                    }
                }
            }
        
        approvalWrap.count = recordWrapList.size();
        approvalWrap.byPassBulk = mdtValues.Core_MDF_Checkbox_Field_1_Ind__c;
        approvalWrap.RecordsToApprove = recordWrapList;
        if(!recordWrapList.isEmpty()){
            return approvalWrap;
        }else{
            return null;
        }  }
      /*****************************************************************************************************
Method Name :   getPFCApprovers
Description :   to get the Claim records for approvals
Added By    :   Akash                  
******************************************************************************************************/
    Public static ApprovalWrapper getPFCApprovers(set<string> programNameSet, set<string> approvalStageSet, string objName){ string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;string Co_GTM_PROG = Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM;
        
        List<PartnerFundClaim> claimObjRecordList = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimToApproveList = new List<PartnerFundClaim>();Set<Id> claimIdSet = new Set<Id>();
        List<SObject> objList = new List<SObject>();
        List<RecordsToApprove> recordWrapList = new List<RecordsToApprove>();
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        approvalWrap.icon = String.valueOf(mdtValues.Core_MDF_Field_8_txt__c);
        approvalWrap.objectName = String.valueOf(mdtValues.Core_MDF_Field_9_txt__c);

       
        ParamWrapper paramWrap = new ParamWrapper();
        paramWrap.fieldApiNames = String.valueOf(mdtValues.Core_MDF_Field_7_txt__c);
        paramWrap.inProgressTrackingRecordIds = inProgressTrackingRecordIds;
        paramWrap.programNameSet = programNameSet;
        claimObjRecordList = Core_MDF_IUPGM_ApprovalRequestData.getClaimRecordData(paramWrap);
        
        if(!claimObjRecordList.isEmpty()){
            for(PartnerFundClaim obj: claimObjRecordList){
                string allAccAllBTSetKey,allAccSpecificBTSetKey,singleAccAllBTSetKey,singleAccSpecificBTSetKey;
                string WW_allAccAllBTSetKey, WW_allAccSpecificBTSetKey, WW_singleAccAllBTSetKey, WW_singleAccSpecificBTSetKey;
                string progId = progToIdMap.get(obj.Core_MDF_Program__c);
                string budgetType = string.isNotBlank(obj.Core_MDF_Budget_Type_Options_Nm__c) ? obj.Core_MDF_Budget_Type_Options_Nm__c.replaceAll('\\s+', '') : '';
                String ultimateAccount = (String)obj.Core_MDF_Ultimate_Account_ID__c;
                Id ultAccount= ultimateAccount;
                string approvalStage = string.isNotBlank(obj.Core_MDF_Approval_Stage_nm__c) ? obj.Core_MDF_Approval_Stage_nm__c.replaceAll('\\s+', '') : '';
                
                if((obj.Core_MDF_Program__c == IPA_PROG) || (obj.Core_MDF_Program__c == Co_GTM_PROG)){
                    string region = (obj.Core_MDF_Program__c == IPA_PROG) ? (string.isNotBlank(obj.Core_MDF_Region_Cd__c) ? obj.Core_MDF_Region_Cd__c : '') : (obj.Core_MDF_Program__c == Co_GTM_PROG ? 'EMEA;PRC;APJ;ASMO;INDIA' : '');
                    if(string.isNotBlank(region)){
                        allAccAllBTSetKey = region +'->'+ progId + '_' + approvalStage;
                    }
                    
                    if(string.isNotBlank(allAccAllBTSetKey)){
                        allAccSpecificBTSetKey = budgetType != null ? allAccAllBTSetKey + '_' + budgetType : '';
                    }
                    
                    if(string.isNotBlank(obj.Core_MDF_Program__c)){
                        if(string.isNotBlank(allAccAllBTSetKey)){
                            singleAccAllBTSetKey = allAccAllBTSetKey + '_' + ultAccount;
                        }
                        if(string.isNotBlank(allAccSpecificBTSetKey)){
                            singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' + ultAccount;
                        }
                    }

                    if(string.isNotBlank(allAccAllBTSetKey) && allAccAllBTSetKey.contains('->')){List<string> tempList = allAccAllBTSetKey.split('->');WW_allAccAllBTSetKey = STR_WW + '->' + tempList[1]; } if(string.isNotBlank(allAccSpecificBTSetKey) && allAccSpecificBTSetKey.contains('->')){ List<string> tempList = allAccSpecificBTSetKey.split('->');WW_allAccSpecificBTSetKey = STR_WW + '->' + tempList[1];  }
                    if(string.isNotBlank(singleAccAllBTSetKey) && singleAccAllBTSetKey.contains('->')){List<string> tempList = singleAccAllBTSetKey.split('->');WW_singleAccAllBTSetKey = STR_WW + '->' + tempList[1];
                    }
                    if(string.isNotBlank(singleAccSpecificBTSetKey) && singleAccSpecificBTSetKey.contains('->')){
                        List<string> tempList = singleAccSpecificBTSetKey.split('->');
                        WW_singleAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                    }
                    if((!allAccAllBTSet.isEmpty() && string.isNotBlank(allAccAllBTSetKey) && string.isNotBlank(WW_allAccAllBTSetKey) && (allAccAllBTSet.contains(allAccAllBTSetKey) || allAccAllBTSet.contains(WW_allAccAllBTSetKey) )) ||
                       (!allAccSpecificBTSet.isEmpty() && string.isNotBlank(allAccSpecificBTSetKey) && string.isNotBlank(WW_allAccSpecificBTSetKey) && (allAccSpecificBTSet.contains(allAccSpecificBTSetKey) || allAccSpecificBTSet.contains(WW_allAccSpecificBTSetKey))) ||
                       (!singleAccAllBTSet.isEmpty() && string.isNotBlank(singleAccAllBTSetKey) && string.isNotBlank(WW_singleAccAllBTSetKey) && (singleAccAllBTSet.contains(singleAccAllBTSetKey) || singleAccAllBTSet.contains(WW_singleAccAllBTSetKey))) ||
                       (!singleAccSpecificBTSet.isEmpty() && string.isNotBlank(singleAccSpecificBTSetKey) && string.isNotBlank(WW_singleAccSpecificBTSetKey) && (singleAccSpecificBTSet.contains(singleAccSpecificBTSetKey) || singleAccSpecificBTSet.contains(WW_singleAccSpecificBTSetKey)))){
                           claimToApproveList.add(obj);
                           claimIdSet.add(obj.Id);
                       }
                    
                }  
            }
        }
            if(!claimToApproveList.isEmpty()){
                //Check FLS
                if(!objNameToSObjectMap.containsKey(objName)){
                    List<sObject> sObjList = new List<sObject>{claimToApproveList[0]};
                    objNameToSObjectMap = getFLSDetails(objName,sObjList);
                }
                if(objNameToSObjectMap != null && objNameToSObjectMap.containsKey(objName)){
                    for(ProcessInstanceWorkItem piwi : [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Type,
                                                        ProcessInstance.TargetObject.Name,CreatedBy.name,CreatedDate 
                                                        FROM ProcessInstanceWorkItem
                                                        WHERE ProcessInstance.TargetObjectId IN: claimIdSet
                                                        AND ProcessInstance.TargetObject.Type =: objName
                                                        AND ProcessInstance.Status =: Core_MDF_CCP_ConstantClass.PFR_PENDING_STATUS]){
                                                            iupgmBasedApprovalIds.add(piwi.ProcessInstance.TargetObjectId);
                                                            recordIdToPiwiIdMap.put(piwi.ProcessInstance.TargetObjectId, piwi.Id); 
                                                        }
                    for(PartnerFundClaim obj: claimToApproveList){
                        recordWrapList.add(getobjRecordDetails(obj, objName)); } } } approvalWrap.count = recordWrapList.size();approvalWrap.byPassBulk = mdtValues.Core_MDF_Checkbox_Field_1_Ind__c;approvalWrap.RecordsToApprove = recordWrapList;if(!recordWrapList.isEmpty()){return approvalWrap;    }else{return null; }
        
    }
      
    
    /*****************************************************************************************************
Method Name :   getApproversBasedOnPI
Description :   to get the approval process version
Added By    :   Saikat Manna                
******************************************************************************************************/
    Public static ApprovalWrapper getApproversBasedOnPI(String objName){
        List<RecordsToApprove> recordWrapList = new List<RecordsToApprove>();
        List<SObject> objList = new List<SObject>();
        ApprovalWrapper approvalWrap = new ApprovalWrapper(); Set<String> objRecIds = new Set<String>(); String icon = '';
        String objectName = '';
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        
        
        for(ProcessInstanceWorkItem piwi : [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Type,
                                            ProcessInstance.TargetObject.Name,CreatedBy.name,CreatedDate 
                                            FROM ProcessInstanceWorkItem WHERE ProcessInstance.Status =: Core_MDF_CCP_ConstantClass.PFR_PENDING_STATUS AND ProcessInstance.TargetObject.Type =: objName
                                            AND Id NOT IN: inProgressPIWITrackingIds
                                            AND ProcessInstance.TargetObjectId NOT IN: iupgmBasedApprovalIds
                                            AND (Actor.Id =: UserInfo.getUserId() OR Actor.Id IN: queueIds) ORDER BY CreatedDate DESC]){
                                                objRecIds.add(piwi.ProcessInstance.TargetObjectId); recordIdToPiwiIdMap.put(piwi.ProcessInstance.TargetObjectId, piwi.Id); 
                                            }
        if(!objRecIds.isEmpty()){
            ParamWrapper paramWrap = new ParamWrapper();paramWrap.fieldApiNames = String.valueOf(mdtValues.Core_MDF_Field_7_txt__c);paramWrap.objName = objName; paramWrap.objRecIds = objRecIds;objList = Core_MDF_IUPGM_ApprovalRequestData.getPIRecordData(paramWrap);
        }
        
        if(!objList.isEmpty()){
            //Check FLS
            if(!objNameToSObjectMap.containsKey(objName)){List<sObject> sObjList = new List<sObject>{objList[0]}; objNameToSObjectMap = getFLSDetails(objName,sObjList);
            }
            if(objNameToSObjectMap != null && objNameToSObjectMap.containsKey(objName)){for(SObject obj: objList){ recordWrapList.add(getobjRecordDetails(obj, objName));
                }
            }
            approvalWrap.icon = String.valueOf(mdtValues.Core_MDF_Field_8_txt__c);approvalWrap.objectName = String.valueOf(mdtValues.Core_MDF_Field_9_txt__c); 
        }  
        approvalWrap.RecordsToApprove = recordWrapList;
        approvalWrap.byPassBulk = mdtValues.Core_MDF_Checkbox_Field_1_Ind__c;
        approvalWrap.count = recordWrapList.size();
        if(!recordWrapList.isEmpty()){
            return approvalWrap;
        } else {
            return null;
        }
    } 
    
    /*****************************************************************************************************
Method Name :   getobjRecordDetails
Description :   Creates records wrapper
Added By    :   Saikat Manna                 
******************************************************************************************************/
    Public static RecordsToApprove getobjRecordDetails(SObject obj, String objName){
        List<string> detailFieldsList = new List<string>();
        List<string> compactFieldsList = new List<string>();
        List<string> tableViewFieldsList = new List<string>();
        String title = '';
        
        RecordsToApprove recordWrap = new RecordsToApprove();
        recordWrap.id = obj.Id;
        recordWrap.piwiId = recordIdToPiwiIdMap.containsKey(obj.Id) ? recordIdToPiwiIdMap.get(obj.Id) : null;
        
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        
        if (mdtValues != null){
            //String detailFieldsStr = mdtValues.Core_MDF_Field_6_txt__c;
            //Added  
            String detailFieldsStr = (
                objName == 'PartnerFundRequest' &&
                (String)obj.get('Core_MDF_Program__c') == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM  &&
                (Boolean)obj.get('Core_MDF_Is_Outcome_Based_Ind__c') == true
            ) 
                ? mdtValues.Core_MDF_Field_14_txt__c 
                : mdtValues.Core_MDF_Field_6_txt__c;

            //String compactFieldsStr = mdtValues.Core_MDF_Field_5_txt__c;
            String compactFieldsStr = (
                objName == 'PartnerFundRequest' &&
                (String)obj.get('Core_MDF_Program__c') == Core_MDF_CCP_ConstantClass.PFR_IPA_PROGRAM  &&
                (Boolean)obj.get('Core_MDF_Is_Outcome_Based_Ind__c') == true
            ) 
                ? mdtValues.Core_MDF_Field_13_txt__c 
                : mdtValues.Core_MDF_Field_5_txt__c;
            String tableViewFieldsStr = mdtValues.Core_MDF_Field_11_txt__c;
            
            title = String.valueOf(obj.get(mdtValues.Core_MDF_Field_12_txt__c));
            detailFieldsList = string.isNotBlank(detailFieldsStr) ? detailFieldsStr.split(',') : new List<string>();
            compactFieldsList = string.isNotBlank(compactFieldsStr) ? compactFieldsStr.split(',') : new List<string>();
            tableViewFieldsList = string.isNotBlank(tableViewFieldsStr) ? tableViewFieldsStr.split(',') : new List<string>();
        }
        
        recordWrap.title = title;
        if(!tableViewFieldsList.isEmpty()){
            recordWrap.tableViewDetails = getFieldDetails(obj, tableViewFieldsList);  
        }
        if(!compactFieldsList.isEmpty()){
            recordWrap.compactDetails = getFieldDetails(obj, compactFieldsList);     
        }
        if(!detailFieldsList.isEmpty()){
            recordWrap.recordDetails = getFieldDetails(obj, detailFieldsList);  
        }
        return recordWrap;
    }
    
    /*****************************************************************************************************
Method Name :   getFieldDetails
Description :   Method to update fields wrapper
Added By    :   Saikat Manna                   
******************************************************************************************************/
    Public static List<FieldsWrapper> getFieldDetails(SObject obj, List<string> fieldsList){
        String objectName = obj.id.getSObjectType().getDescribe().getName();
        List<FieldsWrapper> recordDetailWrapList = new List<FieldsWrapper>();
        for(string field : fieldsList){
            FieldsWrapper fieldsWrap = new FieldsWrapper();
            List<string> labelToApiName = field.split(':');
            if(!labelToApiName.isEmpty()){
                fieldsWrap.label = labelToApiName[0];
                if(obj.get(labelToApiName[1]) != null){
                    string fieldApiName = labelToApiName[1];
                if(objNameToSObjectMap.containsKey(objectName) && objNameToSObjectMap.get(objectName).isSet(fieldApiName)){
                    if(labelToApiName.size() > 2 && String.isNotBlank(labelToApiName[2])){
                        string lookUpApiName = labelToApiName[2];
                        fieldsWrap.value = String.valueOf(obj.getSObject(lookUpApiName.substringbefore('-')).get(lookUpApiName.substringafter('-')));
                        fieldsWrap.redirect = string.valueOf(obj.get(fieldApiName));
                    } else{

                        string fieldType = (!objNameToApiNameToType.isEmpty() && objNameToApiNameToType.containsKey(objectName)) ? 
                                            string.valueOf(objNameToApiNameToType.get(objectName).get(fieldApiName).getDescribe().getType()) : '';
                        
                        if(fieldType == 'CURRENCY'){
                            fieldsWrap.value =  '$' + string.valueOf(obj.get(fieldApiName));
                        }else if(fieldType == 'DATE' || fieldType == 'DATETIME'){
                            fieldsWrap.value = string.valueOf(obj.get(fieldApiName)).removeEnd('00:00:00');
                        }else{
                            fieldsWrap.value = string.valueOf(obj.get(fieldApiName));
                        }
                        
                    }
                    recordDetailWrapList.add(fieldsWrap); 
                }
                }
            }
        
        }
        return recordDetailWrapList;
    }
    
    /*****************************************************************************************************
Method Name :   submitForApproval
Description :   Method to hit approval  
Added By    :   Shiva          
******************************************************************************************************/
    @AuraEnabled
    Public static string submitForApproval(string approvalWrapperStr){
        
        ResultWrapper resultWrap = new ResultWrapper();
        resultWrap.isSuccess = true;
        if(string.isNotBlank(approvalWrapperStr)){
            List<ApprovalRequestWrapper> approvalWrapperList = (List<ApprovalRequestWrapper>) JSON.deserialize(approvalWrapperStr,List<ApprovalRequestWrapper>.class); 
            Map<String, ApprovalRequestWrapper> approvalRequestMap = new Map<String, ApprovalRequestWrapper>();
            Map<String, ApprovalRequestWrapper> piToApprovalRequestMap = new Map<String, ApprovalRequestWrapper>();
            Set<string> piwiRequestIds = new Set<string>();
            List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();
            List<ApprovalRequestWrapper> approvalWrapList = new List<ApprovalRequestWrapper>();
            set<string> piwiToApproveIds = new set<string>();
            Boolean anotherUserResponded = false;
            string buttonName;
            
            try{
                if(!approvalWrapperList.isEmpty()){
                    for(ApprovalRequestWrapper appReqitm : approvalWrapperList){
                        buttonName = appReqitm.actionStatus;
                        approvalRequestMap.put(appReqitm.requestId, appReqitm);
                        piToApprovalRequestMap.put(appReqitm.piwiId, appReqitm);
                        if(string.isNotBlank(appReqitm.piwiId)){
                            piwiRequestIds.add(appReqitm.piwiId);
                        }
                        if(string.isNotBlank(appReqitm.title)){
                            objIdToTitleMap.put(appReqitm.requestId, appReqitm.title);
                        }
                    }
                    
                    List<ProcessInstanceWorkItem> processInstanceList = new List<ProcessInstanceWorkItem>();
                    
                    if(!piwiRequestIds.isEmpty()){
                          processInstanceList = [SELECT ProcessInstance.TargetObjectId, Id 
                                                 FROM ProcessInstanceWorkItem
                                                 WHERE ProcessInstance.Status =: Core_MDF_CCP_ConstantClass.PFR_PENDING_STATUS
                                                 AND Id IN: piwiRequestIds];
                    }
                    
                    if(processInstanceList != null && !processInstanceList.isEmpty()){
                        for(ProcessInstanceWorkItem piwitm : processInstanceList){
                            piwiToApproveIds.add(piwitm.Id); 
                            piIdToObjIdMap.put(piwitm.Id, piwitm.ProcessInstance.TargetObjectId);
                        }
                        
                        List<Core_MDF_Record_Tracking__c> recTrackingList = [SELECT Id, Core_MDF_Object_Name_nm__c, Core_MDF_Scope_nm__c, Core_MDF_Target_Record_Id__c,
                                                                             Core_MDF_Execution_InProgress_Ind__c
                                                                             FROM Core_MDF_Record_Tracking__c 
                                                                             WHERE Core_MDF_Target_Record_Id__c =: piwiToApproveIds 
                                                                             AND Core_MDF_Execution_InProgress_Ind__c = true];
                        
                        if(!approvalRequestMap.isEmpty()){
                            if((approvalRequestMap.size() == processInstanceList.size()) && (recTrackingList == null || (recTrackingList != null && recTrackingList.isEmpty()))){
                                for(ProcessInstanceWorkItem piwitm : processInstanceList){
                                    String appComment = approvalRequestMap.get(piwitm.ProcessInstance.TargetObjectId).comments  != null 
                                        ? approvalRequestMap.get(piwitm.ProcessInstance.TargetObjectId).comments : '';                
                                    
                                    ApprovalRequestWrapper approvalWrap = new ApprovalRequestWrapper();
                                    approvalWrap.requestId = piwitm.Id;
                                    approvalWrap.actionStatus = approvalRequestMap.get(piwitm.ProcessInstance.TargetObjectId).actionStatus;
                                    approvalWrap.comments = appComment;
                                    approvalWrap.isDesktop = approvalRequestMap.get(piwitm.ProcessInstance.TargetObjectId).isDesktop;
                                    approvalWrap.targetObjectName = approvalRequestMap.get(piwitm.ProcessInstance.TargetObjectId).targetObjectName;
                                    approvalWrapList.add(approvalWrap);
                                    
                                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                                    req.setAction(approvalRequestMap.get(piwitm.ProcessInstance.TargetObjectId).actionStatus);
                                    req.setComments(appComment);
                                    req.setWorkitemId(piwitm.Id);
                                    pwrList.add(req);
                                }  
                                
                                ProcessResultWrapper processResWrapper = new ProcessResultWrapper();
                                addrecordTrackingRequests(approvalWrapList);
                                if(!pwrList.isEmpty()){
                                    
                                    fieldPopulateForApprovalComment(approvalWrapperList,buttonName);
                                    
                                    processResWrapper = processBulkApprovalRequests(pwrList);
                                    if(!processResWrapper.approvalSuccessResult.isEmpty() && processResWrapper.errorItemsList.isEmpty()){
                                        resultWrap.isSuccess = true;
                                        resultWrap.approvalSuccessResult = processResWrapper.approvalSuccessResult;
                                    }
                                    else if(!processResWrapper.errorItemsList.isEmpty()){
                                        resultWrap.showContent = processResWrapper.allItemsList.size() > 1 ? true : false;
                                        resultWrap.isSuccess = false; resultWrap.variant = 'error';
                                        resultWrap.approvalErrorResult = processResWrapper.approvalErrorResult;
                                        resultWrap.approvalSuccessResult = processResWrapper.approvalSuccessResult;
                                        if(processResWrapper.approvalSuccessResult != null && !processResWrapper.approvalSuccessResult.isEmpty()){
                                            resultWrap.approvalTotalResult.addAll(processResWrapper.approvalSuccessResult); } resultWrap.approvalTotalResult.addAll(processResWrapper.approvalErrorResult); }  PostApprovalCommentUpdate(approvalWrapperList,buttonName);}
                            }else{
                                anotherUserResponded = true;
                            }
                        }
                    }else{
                        anotherUserResponded = true;
                    }  
                    
                    if(anotherUserResponded){
                        string ANOTHER_USER_RESPONDED = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Another_User_Responded');
                        resultWrap.isSuccess = false;
                        resultWrap.message = ANOTHER_USER_RESPONDED;
                        resultWrap.variant = 'warning';
                        resultWrap.showContent = false;
                    }
                }else{
                    resultWrap.isSuccess = false;
                    resultWrap.message = 'Bad Request. Please take refreshed data!!';
                    resultWrap.variant = 'error'; resultWrap.showContent = false;
                }                                                                 
            }
            catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);resultWrap.isSuccess = false; resultWrap.variant = 'error';resultWrap.showContent = false; resultWrap.message = e.getMessage();
            }
        }
        return JSON.serialize(resultWrap);
    }
    
    
     @AuraEnabled
    public static Map<String,Boolean> checkClaimsAssociatedToCampaign(List<String> campaignId){
        
        Map<String, Boolean> campaignToClaimMap = new Map<String, Boolean>();
        try{
            for(AggregateResult result:[SELECT Core_MDF_Campaign_Id__c,Count(Id) ClaimCount FROM PartnerFundClaim WHERE Core_MDF_Campaign_Id__c in:campaignId AND Core_MDF_Program__c = 'Intel Partner Alliance' AND Core_MDF_Status__c != 'Cancelled'
                                        GROUP BY Core_MDF_Campaign_Id__c]){
                                            String campId= (String) result.get('Core_MDF_Campaign_Id__c');
                                            campaignToClaimMap.put(campId,true);
                                        }
        }catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);
          
        }
        
        return campaignToClaimMap;
        
    }
    
    
    public static void fieldPopulateForApprovalComment(List<ApprovalRequestWrapper> approvalWrapperList, string buttonName){
        
        List<sObject> objToUpdateList = new List<sObject>();
        string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;  string COGTM_PROG = Core_MDF_CCP_ConstantClass.Co_GTM_TECHNICAL_PROGRAM;  string PRICE_REVIEWER = Core_MDF_CCP_ConstantClass.PRICE_REVIEWER; try{
            ObjectWrapper objWrap = getRecordsToUpdate(approvalWrapperList);
            if(!objWrap.sObjectList.isEmpty()){
                List<sObject> objList = objWrap.sObjectList;
                String objName = objWrap.objName;
                if(objName == 'Co-Marketing Activity'){
                for(PartnerFundRequest pfr : (List<PartnerFundRequest>)objList){
                    String appComment = objApprovalRequestMap.get(pfr.Id).comments  != null ? 
                    objApprovalRequestMap.get(pfr.Id).comments : '';      
                    if(buttonName == 'Approve' && pfr.Core_MDF_Approval_Stage__c != PRICE_REVIEWER && 
                       pfr.Core_MDF_Program__c == IPA_PROG && pfr.Core_MDF_Proposal_Based_Ind__c == false){
                           PartnerFundRequest pfrObj = new PartnerFundRequest(Id = pfr.Id,Core_MDF_IPA_Int_Approver_Comment_txt__c = appComment);
                           objToUpdateList.add(pfrObj);  
                       }    
                }
                }else if(objName == 'Campaign'){
                    for(Campaign camp : (List<Campaign>)objList){
                    String appComment = objApprovalRequestMap.get(camp.Id).comments != null ? 
                    objApprovalRequestMap.get(camp.Id).comments : '';
                    Boolean terminalRejection = objApprovalRequestMap.get(camp.Id).permanentReject != null ? 
                    objApprovalRequestMap.get(camp.Id).permanentReject : false;
                    if((camp.Core_MDF_Program__c == IPA_PROG || camp.Core_MDF_Program__c == COGTM_PROG) && camp.Core_MDF_Proposal_Based_Ind__c == true){
                           Campaign campObj = new Campaign(Id = camp.Id,Core_MDF_Comments_Appvr_Only_txt__c = appComment,Core_MDF_Terminal_Rejection_Ind__c=terminalRejection);
                           objToUpdateList.add(campObj);  
                       }    
                    }
                } else if(objName == 'Claim'){for(PartnerFundClaim pfc : (List<PartnerFundClaim>)objList){String appComment = objApprovalRequestMap.get(pfc.Id).comments != null ?  objApprovalRequestMap.get(pfc.Id).comments : '';
                    String actionButtonName = objApprovalRequestMap.get(pfc.Id).actionStatus;
                    String claimStatus;
                    if(pfc.Core_MDF_Program__c == IPA_PROG &&  pfc.Core_MDF_OutcomeBased_Ind__c && (actionButtonName != null && actionButtonName == 'Reject')) {claimStatus = Core_MDF_CCP_ConstantClass.PENDING_CLARIFICATION; } PartnerFundClaim pfcObj;
                    if(pfc.Core_MDF_Program__c == IPA_PROG || pfc.Core_MDF_Program__c == COGTM_PROG){pfcObj = new PartnerFundClaim(Id = pfc.Id,Core_MDF_Comments_Appvr_Only_txt__c = appComment); if(pfc.Core_MDF_Program__c == IPA_PROG &&  pfc.Core_MDF_OutcomeBased_Ind__c) { pfcObj.Core_MDF_Status__c = claimStatus;
                           }
                           objToUpdateList.add(pfcObj);  
                       } } } }
            
            if(!objToUpdateList.isEmpty()){update objToUpdateList; }
        }catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);
           
        } }
    
    public static void PostApprovalCommentUpdate(List<ApprovalRequestWrapper> approvalWrapperList, string buttonName){ List<sObject> objToUpdateList = new List<sObject>();
        string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
        try{
          ObjectWrapper objWrap = getRecordsToUpdate(approvalWrapperList);
            if(!objWrap.sObjectList.isEmpty()){
                List<sObject> objList = objWrap.sObjectList;
                String objName = objWrap.objName;
                List<String> L2_APPROVAL_STAGES=Core_MDF_CCP_ConstantClass.L2_APPROVAL_STAGES;
                if(objName == 'Co-Marketing Activity'){
                for(PartnerFundRequest pfr : (List<PartnerFundRequest>)objList){
                    Boolean isUpdateRequired = false;
                    String appComment = objApprovalRequestMap.get(pfr.Id).comments  != null ? objApprovalRequestMap.get(pfr.Id).comments : '';   
                    PartnerFundRequest pfrObj = new PartnerFundRequest(); 
                    pfrObj.Id = pfr.Id;  
                    if(pfr.Core_MDF_Program__c == IPA_PROG && string.isNotBlank(pfr.Core_MDF_IPA_Int_Approver_Comment_txt__c)){
                        pfrObj.Core_MDF_IPA_Int_Approver_Comment_txt__c = ''; isUpdateRequired = true;
                    }
                    if(buttonName == 'Approve' && (pfr.Core_MDF_Approval_Step_Completed__c == 1 ||L2_APPROVAL_STAGES.contains( pfr.Core_MDF_Completed_Approval_Level_Name__c)
                       && string.isNotBlank(appComment))){
                        pfrObj.Core_MDF_Internal_Approval_Comment_txt__c = appComment;
                        isUpdateRequired = true;
                    }
                    if(buttonName == 'Reject' && pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM){
                        pfrObj.Status = 'Draft';
                        
                isUpdateRequired = true;                        
                    }
                    if(isUpdateRequired){
                        objToUpdateList.add(pfrObj);  
                    }
                }
               }
            }
            
        if(!objToUpdateList.isEmpty()){

            updatePFRFields(JSON.serialize(objToUpdateList));
        }
     }catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);
        
      }
    }
    
    
    @future                             
    public static void updatePFRFields(String appWrapStr){                              
        try{                                    
            List<PartnerFundRequest> pfrlist = (List<PartnerFundRequest>)JSON.deserialize(appWrapStr,List<PartnerFundRequest>.class); 
            Database.update(pfrlist,false);                              
        }                               
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}                              
    }


    public static ObjectWrapper getRecordsToUpdate(List<ApprovalRequestWrapper> approvalWrapperList){
        List<sObject> sObjectList = new List<sObject>();
        ObjectWrapper objWrap = new ObjectWrapper(); 
        String objectName = '' ;
            try{
            if(!approvalWrapperList.isEmpty()){
                for(ApprovalRequestWrapper appReqitm : approvalWrapperList){
                    objectName = appReqitm.targetObjectName ;
                    if(objectName == 'Co-Marketing Activity' || objectName == 'Campaign' || objectName == 'Claim'){
                        objApprovalRequestMap.put(appReqitm.requestId, appReqitm);
                    }
                } 
            }
            switch on objectName {
                    when 'Co-Marketing Activity'{
                      sObjectList = [Select Id,Core_MDF_IPA_Int_Approver_Comment_txt__c,Core_MDF_Internal_Approval_Comment_txt__c,Status,
                       Core_MDF_Approval_Step_Completed__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Approval_Stage__c,Core_MDF_Program__c,Core_MDF_Completed_Approval_Level_Name__c
                       FROM PartnerFundRequest 
                       WHERE Id IN : objApprovalRequestMap.keySet()];
                    }
                    when 'Campaign'{
                     sObjectList = [Select Id, Core_MDF_Comments_Appvr_Only_txt__c, Core_MDF_Program__c,Core_MDF_Proposal_Based_Ind__c,Core_MDF_Terminal_Rejection_Ind__c                     
                                FROM Campaign 
                                WHERE Id IN : objApprovalRequestMap.keySet()];
                            }
                    when 'Claim'{
                     sObjectList = [Select Id, Core_MDF_Comments_Appvr_Only_txt__c, Core_MDF_Program__c, Core_MDF_Status__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_OutcomeBased_Ind__c, Core_MDF_3rd_Party_POP_Doc_Required_Ind__c,
                                        Core_MDF_Ad_Run_Start_Date__c, Core_MDF_Ad_Run_End_Date__c, Core_MDF_Reimbursable_TransactionAmt_Loc__c, Core_MDF_Total_Invoice_Amount_Local__c, Core_MDF_Currency__c, Core_MDF_Activity_Types__c FROM PartnerFundClaim 
                                        WHERE Id IN : objApprovalRequestMap.keySet()];
                            }
          }
         if(!sObjectList.isEmpty()){
             objWrap.sObjectList = sObjectList;
             objWrap.objName = objectName;
         }
        }catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);
        }
        
        return objWrap; 
    }
    
    /*****************************************************************************************************
Method Name :   getGroupsForIds
Description :   
Added By    :   Saikat Manna                  
******************************************************************************************************/
    public static Set<Id> getGroupsForIds(Set<Id> userOrGroupIds){
        Set<Id> output = new Set<Id>();
        Set<Id> nestedGroupIds = new Set<Id>();
        // only query actual groups and not roles and queues
        list<GroupMember> records = [select id,GroupId,Group.Name,UserOrGroupId 
                                     from GroupMember where UserOrGroupId =: userOrGroupIds and UserOrGroupId != null];
        for (GroupMember record:records){
            if (!(record.UserOrGroupId + '').startsWith('005')){ nestedGroupIds.add(record.UserOrGroupId);   
                                                               } else {
                                                                   output.add(record.GroupId);
                                                               }
        }
        if (!nestedGroupIds.isEmpty()){ output.addAll(getGroupsForIds(nestedGroupIds)); }
        return output;
    }
    
    /************************************************************************************************* 
Method Name   :        addrecordTrackingRequests
Description   :        Creates Core_MDF_Record_Tracking__c records to store InProgress records
******************************************************************************************************/ 
    
    public static void addrecordTrackingRequests(List<ApprovalRequestWrapper> aprReqsList){
        List<Core_MDF_Record_Tracking__c> recTrackingList = new List<Core_MDF_Record_Tracking__c>();
        for(ApprovalRequestWrapper aprReqs : aprReqsList){
            Core_MDF_Record_Tracking__c recTracking = new Core_MDF_Record_Tracking__c();
            recTracking.Core_MDF_Object_Name_nm__c = aprReqs.targetObjectName;
            recTracking.Core_MDF_Scope_nm__c = (aprReqs.isDesktop == true) ? 'Bulk Approval Batch' : 'Activity Approval By Mobile';
            recTracking.Core_MDF_Target_Record_Id__c = aprReqs.requestId;
            recTracking.Core_MDF_Execution_InProgress_Ind__c = true;
            recTrackingList.add(recTracking);
        }
        Database.Insert(recTrackingList);
    }
    
    /***************************************************************************************************** 
Method Name   :        processBulkApprovalRequests
Description   :        Takes List<Approval.ProcessWorkitemRequest> for approval
******************************************************************************************************/ 
    
    public static ProcessResultWrapper processBulkApprovalRequests(List<Approval.ProcessWorkitemRequest> pwrList){
        ProcessResultWrapper processResWrapper = new ProcessResultWrapper();
        List<ApprovalResult> approvalResultErrorList = new List<ApprovalResult>();
        List<ApprovalResult> approvalResultSuccessList = new List<ApprovalResult>();
        Integer index = 0;
        List<Approval.ProcessWorkitemRequest> successProcessItemsList = new List<Approval.ProcessWorkitemRequest>();
        List<Approval.ProcessWorkitemRequest> errorProcessItemsList = new List<Approval.ProcessWorkitemRequest>();
        List<Approval.ProcessWorkitemRequest> allProcessItemsList = new List<Approval.ProcessWorkitemRequest>();
        List<Approval.ProcessResult> processResultList = new List<Approval.ProcessResult>();
        Boolean isBulkData = false;
        string ANOTHER_USER_RESPONDED = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Another_User_Responded');
        Integer maxCount = Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bulk_Approval_Max_Limit_Count'));
        if(!pwrList.isEmpty()){
            isBulkData = pwrList.size() > maxCount ? true : false;
            processResultList = Approval.process(pwrList, false);
        }
        
        for(Approval.ProcessResult result : processResultList){
            ApprovalResult approvalResult = new ApprovalResult();
            if(result.isSuccess()){
                successProcessItemsList.add(pwrList[index]);
                string objId = piIdToObjIdMap.containsKey(pwrList[index].getWorkitemId()) ? piIdToObjIdMap.get(pwrList[index].getWorkitemId()) : '';
                string objTitle = objIdToTitleMap.containsKey(objId) ? objIdToTitleMap.get(objId) : ''; 
                approvalResult.id = pwrList[index].getWorkitemId(); 
                approvalResult.title = objTitle;
                approvalResult.status = 'Success';
                approvalResult.redirect = objId;
                approvalResultSuccessList.add(approvalResult);
            }
            else if(result != null && !result.isSuccess()){
                for(Database.Error error : result.getErrors()){
                    string objId = piIdToObjIdMap.containsKey(pwrList[index].getWorkitemId()) ? piIdToObjIdMap.get(pwrList[index].getWorkitemId()) : '';
                    string objTitle = objIdToTitleMap.containsKey(objId) ? objIdToTitleMap.get(objId) : ''; 
                    approvalResult.id = pwrList[index].getWorkitemId(); string errMessage = error.getMessage();
                    if(errMessage.contains('invalid cross reference id') || errMessage.contains('access to this record')){
                        approvalResult.message = ANOTHER_USER_RESPONDED;
                    }else{
                        approvalResult.message = error.getMessage();
                    }
                    approvalResult.title = objTitle;approvalResult.status = 'Failed';
                    approvalResult.redirect = objId;
                    approvalResultErrorList.add(approvalResult);
                    break;
                }
                errorProcessItemsList.add(pwrList[index]);
            } allProcessItemsList.add(pwrList[index]); index++; } processResWrapper.successItemsList = successProcessItemsList; processResWrapper.allItemsList = allProcessItemsList;
        processResWrapper.errorItemsList = errorProcessItemsList;
        processResWrapper.approvalErrorResult = approvalResultErrorList;
        processResWrapper.approvalSuccessResult = approvalResultSuccessList;
        
        if(!isBulkData){ List<String> workItemsIds = new List<String>(); workItemsIds = getRecordIdsFromExecuteBatch(processResWrapper);
            deleteRecordTracingRecords(workItemsIds);
        }
        
        return processResWrapper;
    }
    
    public static void deleteRecordTracingRecords(List<String> workItemsIds){
        List<Core_MDF_Record_Tracking__c> recTrackingListToDelete = [SELECT Id, Core_MDF_Object_Name_nm__c, Core_MDF_Scope_nm__c, Core_MDF_Target_Record_Id__c,
                                                                     Core_MDF_Execution_InProgress_Ind__c
                                                                     FROM Core_MDF_Record_Tracking__c 
                                                                     WHERE Core_MDF_Target_Record_Id__c =:workItemsIds 
                                                                     AND Core_MDF_Execution_InProgress_Ind__c = true AND CreatedById =: UserInfo.getUserId()];  
        if(recTrackingListToDelete != null && !recTrackingListToDelete.isEmpty()){
            for(Core_MDF_Record_Tracking__c recordTrack : recTrackingListToDelete){
                recordTrack.Core_MDF_Execution_InProgress_Ind__c = false;
            }
            Database.update(recTrackingListToDelete);
        }          
    }
    
    public static List<String> getRecordIdsFromExecuteBatch(Core_MDF_IUPGM_ApprovalRequest.ProcessResultWrapper procResult){
        List<String> workItemsIds = new List<String>();
        if(procResult.allItemsList != null && procResult.allItemsList.size() > 0){
            String allItemsString = JSON.serialize(procResult.allItemsList);
            List<ProcessedResultWrapper> procResultList = (List<ProcessedResultWrapper>)JSON.deserialize(allItemsString, List<ProcessedResultWrapper>.class);
            if(procResultList != null && procResultList.size() > 0){
                for(ProcessedResultWrapper procRes : procResultList){
                    workItemsIds.add(procRes.workitemId);
                }
            }
        }
        return workItemsIds;
    }
    
    /***************************************************************************************************** 
    Method Name :   getRecordsToApproveForHomePage
    Description :   Method to get count of records on Co-marketing Home Page 
    ******************************************************************************************************/
    @AuraEnabled
    Public static string getRecordsToApproveForHomePage() {
        set<string> programSet = new set<string>();
        Boolean isIUPGMBasedApprover = false;
        List<string> permissionSetList = new List<string>();
        set<string> programNameSet = new set<string>();
        set<string> rolesSet = new set<string>();
        set<string> iupgmProgram = new set<string>();
        set<string> iupgmRoles = new set<string>();
        set<string> progNameSet = new set<string>();
        List<PartnerFundRequest> pfrToApprove = new List<PartnerFundRequest>();
        List<ApprovalWrapper> approvalWrapList = new List<ApprovalWrapper>();
        List<Core_MDF_CCP_IUPGM_Approver_Mapping__c> iupgmApproverList = new List<Core_MDF_CCP_IUPGM_Approver_Mapping__c>();
        Map<string,Map<string,set<string>>> objectToApprovalStageMap = new Map<string,map<string,set<string>>>(); 
        Map<string,Map<string,set<string>>> psToProgToBTSetMap = new Map<string,map<string,set<string>>>();
        
        try{
            string userId = userinfo.getUserId();
            for(PermissionSetAssignment ps : [SELECT Id,AssigneeId, PermissionSet.Name 
                                              FROM PermissionSetAssignment 
                                              WHERE AssigneeId =: userId AND PermissionSet.Name Like: 'Core_MDF%']){
                                                  permissionSetList.add(ps.PermissionSet.Name);
                                              } 
            
            iupgmApproverList = [SELECT Id,Core_MDF_Program_txt__c,Core_MDF_Approval_Stage_txt__c,Core_MDF_Object_Name_txt__c,Core_MDF_Role_txt__c
                                 FROM Core_MDF_CCP_IUPGM_Approver_Mapping__c
                                 WHERE Core_MDF_Active_ind__c = true];
            String query = 'SELECT ' +
                            'Core_MDF_Field_9_txt__c, ' +
                            'Core_MDF_Field_10_txt__c, ' +
                            'Core_MDF_Program__c, ' +
                            'Core_MDF_Field_12_txt__c, ' +
                            'Core_MDF_Field_8_txt__c, ' +
                            'Core_MDF_Field_11_txt__c, ' +
                            'Core_MDF_Field_5_txt__c, ' +
                            'Core_MDF_Field_6_txt__c, ' +
                			'Core_MDF_Field_14_txt__c, ' + //Added
                            'Core_MDF_Field_7_txt__c, ' + 
                            'Core_MDF_Field_13_txt__c, ' + 
                            'Core_MDF_Field_1_txt__c, ' + 
                            'Core_MDF_Checkbox_Field_1_Ind__c ' + 
                            'FROM Core_MDF_CCP_Custom_Metadata_Utility__c ' +
                            'WHERE Core_MDF_Category__c = \'' + String.escapeSingleQuotes(Core_MDF_CCP_ConstantClass.APPROVAL_REQUEST_OBJECT_CATEGORY) + '\' ' +
                            'AND Core_MDF_Is_Active_Ind__c = TRUE';
            List<Core_MDF_CCP_Custom_Metadata_Utility__c> customMetadataUtilityRecords = Core_MDF_Custom_Metadata_Utility.getCustomObjectRecordsUsingDynamicQuery(query);
			/*([SELECT Core_MDF_Object_Label_Name__c, Core_MDF_Object_Name__c,Core_MDF_Program__c, 
                                                                    Core_MDF_Title_Field__c, Core_MDF_Icon_Name__c, Core_MDF_Table_View_Field_Properties__c,
                                                                    Core_MDF_Compact_Field_Properties__c, Core_MDF_Detail_Field_Properties__c,
                                                                    Core_MDF_Fields_API_Name__c,Core_MDF_Conditional_Field__c,Core_MDF_By_Pass_Bulk__c
                                                                    FROM Core_MDF_Approval_Req_Object_Config__mdt
                                                                    WHERE Core_MDF_Active__c = true])*/
            for(Core_MDF_CCP_Custom_Metadata_Utility__c appReq : customMetadataUtilityRecords){ 
                                                                        //add a comment - refering to the custom setting what Field 10 means, example of the map
                                                                        /* Refer Custom Setting - Custom Metadata Utility mapping for the Mapping of fields
                                                                         Core_MDF_Field_10_txt__c(Field in the Metadata Utility Object) = Core_MDF_Object_Name__c(Field in the Approval Req Object Metadata) */
                                                                        approvalReqObjMdtPIMap.put(appReq.Core_MDF_Field_10_txt__c, appReq);
                                                                    }
            
     
            
            

            
            if(!iupgmApproverList.isEmpty() && !permissionSetList.isEmpty()){
                for(Core_MDF_ChannelProgram__mdt cpm : ([SELECT Core_MDF_Abbreviated_ProgramName_txt__c, MasterLabel,Core_MDF_Technical_Program_Name__c
                                                         FROM Core_MDF_ChannelProgram__mdt
                                                         WHERE Core_MDF_Abbreviated_ProgramName_txt__c != null])){ 
                                                             progNameSet.add(cpm.MasterLabel);
                                                             progTechNameToLabelMap.put(cpm.Core_MDF_Technical_Program_Name__c, cpm.MasterLabel);
                                                         }                               
                
                
                
                for(Core_MDF_Program_Budget_RecordType__mdt mdtConfiq: [select Id,Core_MDF_Program__c, Core_MDF_Account_Manager_PS_API_Name__c, Core_MDF_BudgetType__c 
                                                                        FROM Core_MDF_Program_Budget_RecordType__mdt 
                                                                        where Core_MDF_BudgetType__c != null AND Core_MDF_Account_Manager_PS_API_Name__c != null ]){
                                                                            if(permissionSetList.contains(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c)){
                                                                                if(psToProgToBTSetMap.containsKey(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c)){
                                                                                    if(psToProgToBTSetMap.get(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c).containsKey(mdtConfiq.Core_MDF_Program__c  )){
                                                                                        psToProgToBTSetMap.get(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c).get(mdtConfiq.Core_MDF_Program__c).add(mdtConfiq.Core_MDF_BudgetType__c);
                                                                                    }else{
                                                                                        psToProgToBTSetMap.get(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c).put(mdtConfiq.Core_MDF_Program__c,new set<string>{mdtConfiq.Core_MDF_BudgetType__c});
                                                                                    }
                                                                                }else{
                                                                                    map<String,set<string>> progToBTSetMap = new map<String,set<string>>();
                                                                                    progToBTSetMap.put(mdtConfiq.Core_MDF_Program__c,new set<string>{mdtConfiq.Core_MDF_BudgetType__c});
                                                                                    psToProgToBTSetMap.put(mdtConfiq.Core_MDF_Account_Manager_PS_API_Name__c, progToBTSetMap);
                                                                                }
                                                                                
                                                                                
                                                                            }
                                                                        }
                
                for(Core_MDF_CCP_IUPGM_Approver_Mapping__c csObj: iupgmApproverList){
                    if(permissionSetList.contains(csObj.Core_MDF_Role_txt__c)){
                        iupgmBasedApprovalObj.add(csObj.Core_MDF_Object_Name_txt__c);
                        if(string.isNotBlank(csObj.Core_MDF_Role_txt__c ) && string.isNotBlank(csObj.Core_MDF_Approval_Stage_txt__c)){
                            if(objectToApprovalStageMap.containsKey(csObj.Core_MDF_Object_Name_txt__c)){
                                if(objectToApprovalStageMap.get(csObj.Core_MDF_Object_Name_txt__c).containsKey(csObj.Core_MDF_Role_txt__c   )){
                                    objectToApprovalStageMap.get(csObj.Core_MDF_Object_Name_txt__c).get(csObj.Core_MDF_Role_txt__c).add(csObj.Core_MDF_Approval_Stage_txt__c);
                                }else{
                                    objectToApprovalStageMap.get(csObj.Core_MDF_Object_Name_txt__c).put(csObj.Core_MDF_Role_txt__c,new set<string>{csObj.Core_MDF_Approval_Stage_txt__c});
                                }
                            }else{
                                map<String,set<string>> roleToApprovalStageSetMap = new map<String,set<string>>();
                                roleToApprovalStageSetMap.put(csObj.Core_MDF_Role_txt__c,new set<string>{csObj.Core_MDF_Approval_Stage_txt__c});
                                objectToApprovalStageMap.put(csObj.Core_MDF_Object_Name_txt__c, roleToApprovalStageSetMap);
                            }
                        }
                        
                        programSet.add(csObj.Core_MDF_Program_txt__c);  
                        rolesSet.add(csObj.Core_MDF_Role_txt__c );
                    }
                }
            }
            
            if(!programSet.isEmpty() && !rolesSet.isEmpty()){
                
                //map<string,set<string>> roleToStageSetMap = new map<string,set<string>>();
                if(!objectToApprovalStageMap.isEmpty() && !objectToApprovalStageMap.values().isEmpty()){
                    for(map<string,set<string>> roleToStageMap : objectToApprovalStageMap.values()){
                        for(string role: roleToStageMap.keySet()){
                            if(roleToStageSetMap.containsKey(role)){
                                roleToStageSetMap.get(role).addAll(roleToStageMap.get(role));
                            }else{
                                roleToStageSetMap.put(role, roleToStageMap.get(role));
                            }
                        }
                    }
                }
                
                for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm: [SELECT Id, Core_MDF_All_Accounts_cd__c,Core_MDF_Program_nm__c,Core_MDF_Account_id__r.Name,Core_MDF_Channel_Program_id__r.Name,                               
                                                                      Core_MDF_Region_cd__c, Core_MDF_Account_id__c, Core_MDF_Channel_Program_id__c,Core_MDF_User_id__c,                               
                                                                      Core_MDF_Sub_Region_cd__c,Core_MDF_Region_Sub_Region_nm__c,Core_MDF_Role_nm__c,Core_MDF_Account_id__r.Core_MDF_Group_Id__c,
                                                                      Core_MDF_Budget_Type_nm__c,Core_MDF_GeoSubGeo_Budget_Type_nm__c,Core_MDF_Activity_Classification_nm__c,
                                                                      /*Core_MDF_CMDF_GeoSubGeo_BudgetType_nm__c ,*/Core_MDF_All_Budget_Type_Access_Ind__c,Core_MDF_Approval_Region_nm__c                             
                                                                      FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c  
                                                                      WHERE Core_MDF_User_id__c =: userId 
                                                                      and Core_MDF_Is_Not_an_Approver_Ind__c = false
                                                                      and Core_MDF_Program_nm__c IN: programSet  
                                                                      and Core_MDF_Role_nm__c IN: rolesSet 
                                                                      and Core_MDF_Active_Ind__c = true]){
                                                                          
                                                                          KeySetWrapper keyWrap =  new KeySetWrapper();
                                                                          Set<string> approvalStageSet = new Set<string>();
                                                                          Set<string> iupgmClassifications = new Set<string>();
                                                                          
                                                                          iupgmProgram.add(iupgm.Core_MDF_Program_nm__c);
                                                                          iupgmRoles.add(iupgm.Core_MDF_Role_nm__c);
                                                                          
                                                                          if(!psToProgToBTSetMap.isEmpty() && !psToProgToBTSetMap.values().isEmpty()){
                                                                              if(psToProgToBTSetMap.containsKey(iupgm.Core_MDF_Role_nm__c) && psToProgToBTSetMap.get(iupgm.Core_MDF_Role_nm__c) != null){
                                                                                  
                                                                                  Map<string,set<string>> progToBTMap = psToProgToBTSetMap.get(iupgm.Core_MDF_Role_nm__c);
                                                                                  for(string prog: progToBTMap.keySet()){
                                                                                      string progLabel = progTechNameToLabelMap.containsKey(prog) ? progTechNameToLabelMap.get(prog) : '';
                                                                                      if(string.isNotBlank(progLabel)){
                                                                                          if(progToBudgetSetMap.containsKey(progLabel)){
                                                                                              progToBudgetSetMap.get(progLabel).addAll(progToBTMap.get(prog));
                                                                                          }else{
                                                                                              progToBudgetSetMap.put(progLabel, progToBTMap.get(prog));
                                                                                          }
                                                                                      }                               
                                                                                  }
                                                                                  
                                                                              }
                                                                          }
                                                                          
                                                                          if(string.isNotBlank(iupgm.Core_MDF_Activity_Classification_nm__c)){
                                                                              iupgmClassifications.addAll(iupgm.Core_MDF_Activity_Classification_nm__c.split(';'));
                                                                          }
                                                                          
                                                                          if(!roleToStageSetMap.isEmpty() && roleToStageSetMap.containsKey(iupgm.Core_MDF_Role_nm__c) && !roleToStageSetMap.get(iupgm.Core_MDF_Role_nm__c).isEmpty()){
                                                                              if(!iupgmClassifications.isEmpty()){
                                                                                  set<string> confiqApprovalStage = roleToStageSetMap.get(iupgm.Core_MDF_Role_nm__c);
                                                                                  for(string iupgmStage: iupgmClassifications){
                                                                                      for(string confiqStage: confiqApprovalStage){
                                                                                          if(confiqStage.contains(iupgmStage)){
                                                                                              approvalStageSet.add(confiqStage);
                                                                                          }
                                                                                      }
                                                                                  }
                                                                              }else{
                                                                                  approvalStageSet = roleToStageSetMap.get(iupgm.Core_MDF_Role_nm__c);
                                                                              }
                                                                          }                      
                                                                          
                                                                          if(!approvalStageSet.isEmpty()){
                                                                              keyWrap = getAllIUPGMKey(iupgm,approvalStageSet);
                                                                          }
                                                                          
                                                                          if(!keyWrap.allAccSpecificBTSet.isEmpty()){
                                                                              allAccSpecificBTSet.addAll(keyWrap.allAccSpecificBTSet);
                                                                          }
                                                                          if(!keyWrap.singleAccSpecificBTSet.isEmpty()){
                                                                              singleAccSpecificBTSet.addAll(keyWrap.singleAccSpecificBTSet);
                                                                          }
                                                                          if(!keyWrap.allAccAllBTSet.isEmpty()){
                                                                              allAccAllBTSet.addAll(keyWrap.allAccAllBTSet);
                                                                          }
                                                                          if(!keyWrap.singleAccAllBTSet.isEmpty()){
                                                                              singleAccAllBTSet.addAll(keyWrap.singleAccAllBTSet);
                                                                          }
                                                                      }
                
                if(!allAccSpecificBTSet.isEmpty() || !singleAccSpecificBTSet.isEmpty() || !allAccAllBTSet.isEmpty() || !singleAccAllBTSet.isEmpty()){
                    isIUPGMBasedApprover = true;
                }
                
                if(isIUPGMBasedApprover){
                    for (ChannelProgram cp : [SELECT Id, Name                               
                                              FROM ChannelProgram                               
                                              WHERE Name IN: progNameSet]){                               
                                                  progToIdMap.put(cp.Name,cp.Id);                             
                                              } 
                    
                    if(!progTechNameToLabelMap.isEmpty()){
                        for(string prog: iupgmProgram){
                            if(progTechNameToLabelMap.containsKey(prog)){
                                programNameSet.add(progTechNameToLabelMap.get(prog));
                            }
                        }
                    }
                }
                
            }

        if(!iupgmBasedApprovalObj.isEmpty() && isIUPGMBasedApprover && !objectToApprovalStageMap.isEmpty() ){
            //Avoid Deeply Nested IF Statements
                if(objectToApprovalStageMap.containsKey('PartnerFundRequest') && !objectToApprovalStageMap.get('PartnerFundRequest').isEmpty()){
                    set<string> approvalStage = new set<string>();
                    approvalStage = getApprovalRoles(objectToApprovalStageMap,iupgmRoles,'PartnerFundRequest');
                    ApprovalWrapper appWrapObj = getPFRApproversForHomePage(programNameSet,approvalStage,'PartnerFundRequest');
                    if(appWrapObj != null){
                        approvalWrapList.add(appWrapObj);
                    }
                }
                if(objectToApprovalStageMap.containsKey('Campaign') && !objectToApprovalStageMap.get('Campaign').isEmpty()){
                    set<string> approvalStage = new set<string>();
                    approvalStage = getApprovalRoles(objectToApprovalStageMap,iupgmRoles,'Campaign');
                    ApprovalWrapper appWrapObj = getCampaignApproversForHomePage(programNameSet,approvalStage,'Campaign');
                    if(appWrapObj != null){
                        approvalWrapList.add(appWrapObj);
                    }
                }
                if(objectToApprovalStageMap.containsKey('PartnerMarketingBudget') && !objectToApprovalStageMap.get('PartnerMarketingBudget').isEmpty()){
                    set<string> approvalStage = new set<string>();
                    approvalStage = getApprovalRoles(objectToApprovalStageMap,iupgmRoles,'PartnerMarketingBudget');
                    ApprovalWrapper appWrapObj = getBudgetApproversForHomePage(programNameSet,approvalStage,'PartnerMarketingBudget');
                    if(appWrapObj != null){
                        approvalWrapList.add(appWrapObj);
                    }
                }
                if(objectToApprovalStageMap.containsKey('PartnerFundClaim') && !objectToApprovalStageMap.get('PartnerFundClaim').isEmpty()){
                    set<string> approvalStage = new set<string>();
                    approvalStage = getApprovalRoles(objectToApprovalStageMap,iupgmRoles,'PartnerFundClaim');
                    ApprovalWrapper appWrapObj = getPFCApproversForHomePage(programNameSet,approvalStage,'PartnerFundClaim');
                    if(appWrapObj != null){
                        approvalWrapList.add(appWrapObj);
                    }
                }
        }
        
        
        if(!approvalReqObjMdtPIMap.isEmpty()){
            //Get all the approval process for all objects
            Set<Id> groupIds = getGroupsForIds(new Set<Id>{userId});
            
            if(groupIds != null && !groupIds.isEmpty()){
                
                for(GroupMember gm : [SELECT group.name,group.id,group.type FROM GroupMember WHERE (UserOrGroupId =: groupIds OR group.id =: groupIds) AND group.type = 'Queue' limit 10000]){ queueIds.add(gm.group.id);  }
                }
                
                for(string objName: approvalReqObjMdtPIMap.keyset()){

                    ApprovalWrapper appWrapObj = getApproversBasedOnPIForHomePage(objName);
                    if(appWrapObj != null){Boolean isObjectAvailable = false;
                        if(!approvalWrapList.isEmpty()){
                            for(ApprovalWrapper wrap: approvalWrapList){
                                if(wrap.objectName == appWrapObj.objectName){ wrap.count += appWrapObj.count; isObjectAvailable = true;
                                }
                            }
                        }
                        if(!isObjectAvailable){ approvalWrapList.add(appWrapObj); }
                    } 
                }
            }
        }
        catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex);
           
        }
        return JSON.serialize(approvalWrapList);
    }
    /***************************************************************************************************** 
    Method Name :   getPFRApproversForHomePage
    Description :   Method to get count of records on Co-marketing Home Page 
    ******************************************************************************************************/
    
    Public static ApprovalWrapper getPFRApproversForHomePage(set<string> programNameSet, set<string> approvalStageSet, string objName){
        
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        List<PartnerFundRequest> pfrToApproveList = new List<PartnerFundRequest>();
        List<RecordsToApprove> recordWrapList = new List<RecordsToApprove>();
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        approvalWrap.icon = String.valueOf(mdtValues.Core_MDF_Field_8_txt__c);
        approvalWrap.objectName = String.valueOf(mdtValues.Core_MDF_Field_9_txt__c);
        
        ParamWrapper paramWrap = new ParamWrapper();
        paramWrap.fieldApiNames = String.valueOf(mdtValues.Core_MDF_Field_7_txt__c);
        paramWrap.inProgressTrackingRecordIds = inProgressTrackingRecordIds;
        paramWrap.programNameSet = programNameSet;
        paramWrap.approvalStageSet = approvalStageSet;
        pfrList = Core_MDF_IUPGM_ApprovalRequestData.getPfrRecordData(paramWrap);
       
        if(!pfrList.isEmpty()){
            for(PartnerFundRequest pfr: pfrList){
                string allAccAllBTSetKey,allAccSpecificBTSetKey,singleAccAllBTSetKey,singleAccSpecificBTSetKey;
                string budgetType = string.isNotBlank(pfr.Core_MDF_Budget_Type_nm__c) ? pfr.Core_MDF_Budget_Type_nm__c.replaceAll('\\s+', '') : '';
                string progId = progToIdMap.get(pfr.Core_MDF_Program__c);
                string approvalStage = string.isNotBlank(pfr.Core_MDF_Approval_Stage__c) ? pfr.Core_MDF_Approval_Stage__c.replaceAll('\\s+', '') : '';
                string region = pfr.Core_MDF_Host_Region_or_Region_txt__c;//For IPA & !PCT it stores Host Geo, else Transaction geo. 
                
                if(string.isNotBlank(region)){
                    if(progToBudgetSetMap.containsKey(pfr.Core_MDF_Program__c) && progToBudgetSetMap.get(pfr.Core_MDF_Program__c) != null){
                         if(pfr.Core_MDF_Approval_Stage__c != 'Additional Reviewer' && progToBudgetSetMap.get(pfr.Core_MDF_Program__c).contains(pfr.Core_MDF_Budget_Type_nm__c)){
                                allAccAllBTSetKey = pfr.Core_MDF_Sub_Region_nm__c != null ? region + '-' + pfr.Core_MDF_Sub_Region_nm__c +'->' + progId + '_' + approvalStage  : region +'->'+ progId + '_' + approvalStage;
                            }
                         else if(pfr.Core_MDF_Approval_Stage__c == 'Additional Reviewer' && hasAdditionalReviewAccess(pfr)){
                                allAccAllBTSetKey = pfr.Core_MDF_Sub_Region_nm__c != null ? region + '-' + pfr.Core_MDF_Sub_Region_nm__c +'->' + progId + '_' + approvalStage  : region +'->'+ progId + '_' + approvalStage;
                        }
                        
                    }else{
                        allAccAllBTSetKey = pfr.Core_MDF_Sub_Region_nm__c != null ? region + '-' + pfr.Core_MDF_Sub_Region_nm__c +'->' + progId + '_' + approvalStage  : region +'->'+ progId + '_' + approvalStage;
                    }
                }
                
                if(string.isNotBlank(allAccAllBTSetKey)){
                    allAccSpecificBTSetKey = budgetType != null ? allAccAllBTSetKey + '_' + budgetType : '';
                }
                
                if(string.isNotBlank(pfr.Core_MDF_Program__c)){
                    if(string.isNotBlank(allAccAllBTSetKey)){
                        if(pfr.Core_MDF_Program__c == RMF_PROG && pfr.Core_MDF_Approval_Stage__c != 'Price Reviewer'){
                            singleAccAllBTSetKey = allAccAllBTSetKey + '_' +pfr.ChannelPartnerId; } else if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM 
                                  && (pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER 
                                || pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL)
                                && string.isNotBlank(pfr.Core_MDF_Campaign_Ultimate_Account_Id__c)){
                            singleAccAllBTSetKey = allAccAllBTSetKey + '_' + pfr.Core_MDF_Campaign_Ultimate_Account_Id__c;
                            
                        }else if(string.isNotBlank(pfr.Core_MDF_Ultimate_Account_Id__c)){
                            singleAccAllBTSetKey = allAccAllBTSetKey + '_' + pfr.Core_MDF_Ultimate_Account_Id__c;
                        }
                    }
                    if(string.isNotBlank(allAccSpecificBTSetKey)){
                        if(pfr.Core_MDF_Program__c == RMF_PROG && pfr.Core_MDF_Approval_Stage__c != 'Price Reviewer'){
                            singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' +pfr.ChannelPartnerId;
                        } else if(pfr.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.EEF_PROGRAM 
                                  && (pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L1_APPROVAL_PRIMARY_PARTNER 
                                || pfr.Core_MDF_Approval_Stage__c == Core_MDF_CCP_ConstantClass.L2_PRIMARY_APPROVAL)
                                 && string.isNotBlank(pfr.Core_MDF_Campaign_Ultimate_Account_Id__c)){
                            singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' + pfr.Core_MDF_Campaign_Ultimate_Account_Id__c; }else if(string.isNotBlank(pfr.Core_MDF_Ultimate_Account_Id__c)){ singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' + pfr.Core_MDF_Ultimate_Account_Id__c;
                        }
                    }
                }
                
                string WW_allAccAllBTSetKey;
                string WW_allAccSpecificBTSetKey;
                string WW_singleAccAllBTSetKey;
                string WW_singleAccSpecificBTSetKey;
                
                if(string.isNotBlank(allAccAllBTSetKey) && allAccAllBTSetKey.contains('->')){List<string> tempList = allAccAllBTSetKey.split('->');WW_allAccAllBTSetKey = STR_WW + '->' + tempList[1]; }
                
                if(string.isNotBlank(allAccSpecificBTSetKey) && allAccSpecificBTSetKey.contains('->')){
                    List<string> tempList = allAccSpecificBTSetKey.split('->');
                    WW_allAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                }
                if(string.isNotBlank(singleAccAllBTSetKey) && singleAccAllBTSetKey.contains('->')){
                    List<string> tempList = singleAccAllBTSetKey.split('->');
                    WW_singleAccAllBTSetKey = STR_WW + '->' + tempList[1];
                }
                if(string.isNotBlank(singleAccSpecificBTSetKey) && singleAccSpecificBTSetKey.contains('->')){
                    List<string> tempList = singleAccSpecificBTSetKey.split('->');
                    WW_singleAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                }
                
                if((!allAccAllBTSet.isEmpty() && string.isNotBlank(allAccAllBTSetKey) && string.isNotBlank(WW_allAccAllBTSetKey) && (allAccAllBTSet.contains(allAccAllBTSetKey) || allAccAllBTSet.contains(WW_allAccAllBTSetKey) )) ||
                   (!allAccSpecificBTSet.isEmpty() && string.isNotBlank(allAccSpecificBTSetKey) && string.isNotBlank(WW_allAccSpecificBTSetKey) && (allAccSpecificBTSet.contains(allAccSpecificBTSetKey) || allAccSpecificBTSet.contains(WW_allAccSpecificBTSetKey))) ||
                   (!singleAccAllBTSet.isEmpty() && string.isNotBlank(singleAccAllBTSetKey) && string.isNotBlank(WW_singleAccAllBTSetKey) && (singleAccAllBTSet.contains(singleAccAllBTSetKey) || singleAccAllBTSet.contains(WW_singleAccAllBTSetKey))) ||
                   (!singleAccSpecificBTSet.isEmpty() && string.isNotBlank(singleAccSpecificBTSetKey) && string.isNotBlank(WW_singleAccSpecificBTSetKey) && (singleAccSpecificBTSet.contains(singleAccSpecificBTSetKey) || singleAccSpecificBTSet.contains(WW_singleAccSpecificBTSetKey)))){
                       iupgmBasedApprovalIds.add(pfr.Id);
                       pfrToApproveList.add(pfr);
                   }
            }
        }
        
        if(!pfrToApproveList.isEmpty()){
            if(!objNameToSObjectMap.containsKey(objName)){
                List<sObject> sObjList = new List<sObject>{pfrToApproveList[0]};
                    objNameToSObjectMap = getFLSDetails(objName,sObjList);
            }       
        }
        approvalWrap.count = pfrToApproveList.size();
        if(!pfrToApproveList.isEmpty() && objNameToSObjectMap.containsKey(objName)){return approvalWrap; }else{
            return null;
        }
         
    }
    
        /*****************************************************************************************************
Method Name :   getCampaignApproversForHomePage
Description :   to get the Campaign records for approvals
******************************************************************************************************/
    Public static ApprovalWrapper getCampaignApproversForHomePage(set<string> programNameSet, set<string> approvalStageSet, string objName){
        List<Campaign> campList = new List<Campaign>();
        List<Campaign> campToApproveList = new List<Campaign>();
        List<SObject> objList = new List<SObject>();
        List<RecordsToApprove> recordWrapList = new List<RecordsToApprove>();
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        approvalWrap.icon = String.valueOf(mdtValues.Core_MDF_Field_8_txt__c);
        approvalWrap.objectName = String.valueOf(mdtValues.Core_MDF_Field_9_txt__c);
       
        ParamWrapper paramWrap = new ParamWrapper();
        paramWrap.fieldApiNames = String.valueOf(mdtValues.Core_MDF_Field_7_txt__c);
        paramWrap.inProgressTrackingRecordIds = inProgressTrackingRecordIds;
        paramWrap.programNameSet = programNameSet;
        paramWrap.approvalStageSet = approvalStageSet;
        campList = Core_MDF_IUPGM_ApprovalRequestData.getCampaignRecordData(paramWrap);
        
        if(!campList.isEmpty()){
            for(Campaign obj: campList){
                string allAccAllBTSetKey,allAccSpecificBTSetKey,singleAccAllBTSetKey,singleAccSpecificBTSetKey;
                string WW_allAccAllBTSetKey, WW_allAccSpecificBTSetKey, WW_singleAccAllBTSetKey, WW_singleAccSpecificBTSetKey;
                //string progId = progToIdMap.get(obj.Core_MDF_Program__c);

                string progId = progToIdMap.get(obj.Core_MDF_Program__c)!=null ? progToIdMap.get(obj.Core_MDF_Program__c) : progToIdMap.get(obj.Core_MDF_Channel_Program__r.Name);

                string budgetType = string.isNotBlank(obj.Core_MDF_Opal_Budget_Type_Txt__c) ? obj.Core_MDF_Opal_Budget_Type_Txt__c.replaceAll('\\s+', '') : '';
                string approvalStage = string.isNotBlank(obj.Core_MDF_Approval_Stage_nm__c) ? obj.Core_MDF_Approval_Stage_nm__c.replaceAll('\\s+', '') : '';
                String ultimateAccount = (String)obj.Core_MDF_Ultimate_Account_txt__c;
                Id ultAccount= ultimateAccount;
                string region = HOST_REGION_PROGRAM.contains(obj.Core_MDF_Program__c) ? obj.Core_MDF_Host_Region_cd__c : obj.Core_MDF_Region_cd__c;
                
                if(string.isNotBlank(region)){
                    allAccAllBTSetKey = obj.Core_MDF_Sub_Region_cd__c != null ? 
                        region + '-' + obj.Core_MDF_Sub_Region_cd__c +'->' + progId + '_' + approvalStage  
                        : region +'->'+ progId + '_' + approvalStage; }
                
                if(string.isNotBlank(allAccAllBTSetKey)){
                    allAccSpecificBTSetKey = budgetType != null ? allAccAllBTSetKey + '_' + budgetType : '';
                }
                
                if(string.isNotBlank(obj.Core_MDF_Program__c)){ if(string.isNotBlank(allAccAllBTSetKey)){ singleAccAllBTSetKey = allAccAllBTSetKey + '_' + ultAccount; } if(string.isNotBlank(allAccSpecificBTSetKey)){
                        singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' + ultAccount;
                    } }
                
                if(string.isNotBlank(allAccAllBTSetKey) && allAccAllBTSetKey.contains('->')){
                    List<string> tempList = allAccAllBTSetKey.split('->');
                    WW_allAccAllBTSetKey = STR_WW + '->' + tempList[1];
                } if(string.isNotBlank(allAccSpecificBTSetKey) && allAccSpecificBTSetKey.contains('->')){
                    List<string> tempList = allAccSpecificBTSetKey.split('->');
                    WW_allAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                } if(string.isNotBlank(singleAccAllBTSetKey) && singleAccAllBTSetKey.contains('->')){ List<string> tempList = singleAccAllBTSetKey.split('->');
                    WW_singleAccAllBTSetKey = STR_WW + '->' + tempList[1];
                } if(string.isNotBlank(singleAccSpecificBTSetKey) && singleAccSpecificBTSetKey.contains('->')){
                    List<string> tempList = singleAccSpecificBTSetKey.split('->');
                    WW_singleAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                }
                
                if((!allAccAllBTSet.isEmpty() && string.isNotBlank(allAccAllBTSetKey) && string.isNotBlank(WW_allAccAllBTSetKey) && (allAccAllBTSet.contains(allAccAllBTSetKey) || allAccAllBTSet.contains(WW_allAccAllBTSetKey) )) || (!allAccSpecificBTSet.isEmpty() && string.isNotBlank(allAccSpecificBTSetKey) && string.isNotBlank(WW_allAccSpecificBTSetKey) && (allAccSpecificBTSet.contains(allAccSpecificBTSetKey) || allAccSpecificBTSet.contains(WW_allAccSpecificBTSetKey))) ||
                   (!singleAccAllBTSet.isEmpty() && string.isNotBlank(singleAccAllBTSetKey) && string.isNotBlank(WW_singleAccAllBTSetKey) && (singleAccAllBTSet.contains(singleAccAllBTSetKey) || singleAccAllBTSet.contains(WW_singleAccAllBTSetKey))) ||
                   (!singleAccSpecificBTSet.isEmpty() && string.isNotBlank(singleAccSpecificBTSetKey) && string.isNotBlank(WW_singleAccSpecificBTSetKey) && (singleAccSpecificBTSet.contains(singleAccSpecificBTSetKey) || singleAccSpecificBTSet.contains(WW_singleAccSpecificBTSetKey)))){ campToApproveList.add(obj); iupgmBasedApprovalIds.add(obj.Id);
                   }
            } }
        
                
        if(!campToApproveList.isEmpty()){ if(!objNameToSObjectMap.containsKey(objName)){ List<sObject> sObjList = new List<sObject>{campToApproveList[0]};
                    objNameToSObjectMap = getFLSDetails(objName,sObjList);
            }       
        } approvalWrap.count = campToApproveList.size(); if(!campToApproveList.isEmpty() && objNameToSObjectMap.containsKey(objName)){ return approvalWrap; }else{ return null;
        }
        
    }
 
 /*****************************************************************************************************
Method Name :   getBudgetApproversForHomePage
Description :   to get the Budget records for approvals
******************************************************************************************************/   
  Public static ApprovalWrapper getBudgetApproversForHomePage(set<string> programNameSet, set<string> approvalStageSet, string objName){
        string MDFPLUS_BUDGET_TYPE = Core_MDF_CCP_ConstantClass.MDFPLUS_BUDGET_TYPE;
        string MDF_BUDGET_TYPE = Core_MDF_CCP_ConstantClass.MDF_BUDGET_TYPE;
        string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
        string EEF_PROGRAM = Core_MDF_CCP_ConstantClass.EEF_PROGRAM;
        string Co_GTM_PROG = Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM;
        
      
        List<PartnerMarketingBudget> budgetObjRecordList = new List<PartnerMarketingBudget>();
        List<PartnerMarketingBudget> budgetToApproveList = new List<PartnerMarketingBudget>();
        Set<Id> budgetIdSet = new Set<Id>();
        List<SObject> objList = new List<SObject>();
        List<RecordsToApprove> recordWrapList = new List<RecordsToApprove>();
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        approvalWrap.icon = String.valueOf(mdtValues.Core_MDF_Field_8_txt__c);
        approvalWrap.objectName = String.valueOf(mdtValues.Core_MDF_Field_9_txt__c);

       
        ParamWrapper paramWrap = new ParamWrapper();
        paramWrap.fieldApiNames = String.valueOf(mdtValues.Core_MDF_Field_7_txt__c);
        paramWrap.inProgressTrackingRecordIds = inProgressTrackingRecordIds;
        paramWrap.programNameSet = programNameSet;
        budgetObjRecordList = Core_MDF_IUPGM_ApprovalRequestData.getBudgetRecordData(paramWrap);

      
      if(!budgetObjRecordList.isEmpty()){
          for(PartnerMarketingBudget obj: budgetObjRecordList){
              string allAccAllBTSetKey,allAccSpecificBTSetKey,singleAccAllBTSetKey,singleAccSpecificBTSetKey;
              string WW_allAccAllBTSetKey, WW_allAccSpecificBTSetKey, WW_singleAccAllBTSetKey, WW_singleAccSpecificBTSetKey;
              string progId = progToIdMap.get(obj.Core_MDF_Program_Nm__c);
              string budgetType = string.isNotBlank(obj.Core_MDF_Budget_Type_Txt__c) ? obj.Core_MDF_Budget_Type_Txt__c.replaceAll('\\s+', '') : '';
              String ultimateAccount = (String)obj.Core_MDF_Ultimate_Account_Id__c;
              Id ultAccount= ultimateAccount;
              string approvalStage = 'None';
              
              if((obj.Core_MDF_Program_Nm__c == IPA_PROG) /*|| (obj.Core_MDF_Program_Nm__c == Co_GTM_PROG)*/){
                  string region = string.isNotBlank(obj.Core_MDF_Budget_Partner__r.Core_Geo__c) ? obj.Core_MDF_Budget_Partner__r.Core_Geo__c : '';
                                                                                                   
                  
                  if(string.isNotBlank(region)){
                      allAccAllBTSetKey = region +'->'+ progId + '_' + approvalStage;
                  }
                  
                  if(string.isNotBlank(allAccAllBTSetKey)){
                      allAccSpecificBTSetKey = budgetType != null ? allAccAllBTSetKey + '_' + budgetType : '';
                  }
                  //Avoid Deeply Nested IF Statements
                      if(string.isNotBlank(obj.Core_MDF_Program__c) && string.isNotBlank(allAccAllBTSetKey)){
                          singleAccAllBTSetKey = allAccAllBTSetKey + '_' + ultAccount;
                      }
                      if(string.isNotBlank(obj.Core_MDF_Program__c) && string.isNotBlank(allAccSpecificBTSetKey)){
                          singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' + ultAccount;
                      }
                  
                  if(string.isNotBlank(allAccAllBTSetKey) && allAccAllBTSetKey.contains('->')){
                      List<string> tempList = allAccAllBTSetKey.split('->'); WW_allAccAllBTSetKey = STR_WW + '->' + tempList[1];
                  }
                  if(string.isNotBlank(allAccSpecificBTSetKey) && allAccSpecificBTSetKey.contains('->')){
                      List<string> tempList = allAccSpecificBTSetKey.split('->'); WW_allAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                  }
                  if(string.isNotBlank(singleAccAllBTSetKey) && singleAccAllBTSetKey.contains('->')){
                      List<string> tempList = singleAccAllBTSetKey.split('->'); WW_singleAccAllBTSetKey = STR_WW + '->' + tempList[1];
                  }
                  if(string.isNotBlank(singleAccSpecificBTSetKey) && singleAccSpecificBTSetKey.contains('->')){ List<string> tempList = singleAccSpecificBTSetKey.split('->');
                      WW_singleAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                  }
                 
                  if((!allAccAllBTSet.isEmpty() && string.isNotBlank(allAccAllBTSetKey) && string.isNotBlank(WW_allAccAllBTSetKey) && (allAccAllBTSet.contains(allAccAllBTSetKey) || allAccAllBTSet.contains(WW_allAccAllBTSetKey) )) || (!allAccSpecificBTSet.isEmpty() && string.isNotBlank(allAccSpecificBTSetKey) && string.isNotBlank(WW_allAccSpecificBTSetKey) && (allAccSpecificBTSet.contains(allAccSpecificBTSetKey) || allAccSpecificBTSet.contains(WW_allAccSpecificBTSetKey))) ||
                     (!singleAccAllBTSet.isEmpty() && string.isNotBlank(singleAccAllBTSetKey) && string.isNotBlank(WW_singleAccAllBTSetKey) && (singleAccAllBTSet.contains(singleAccAllBTSetKey) || singleAccAllBTSet.contains(WW_singleAccAllBTSetKey))) ||
                     (!singleAccSpecificBTSet.isEmpty() && string.isNotBlank(singleAccSpecificBTSetKey) && string.isNotBlank(WW_singleAccSpecificBTSetKey) && (singleAccSpecificBTSet.contains(singleAccSpecificBTSetKey) || singleAccSpecificBTSet.contains(WW_singleAccSpecificBTSetKey)))){ budgetToApproveList.add(obj);budgetIdSet.add(obj.Id);
                     }
                  
              }
              //Added EEF check to show record count for budget
              else if(obj.Core_MDF_Budget_Type_Txt__c == MDF_BUDGET_TYPE || obj.Core_MDF_Budget_Type_Txt__c == MDFPLUS_BUDGET_TYPE 
                      || obj.Core_MDF_Program_Nm__c == EEF_PROGRAM || obj.Core_MDF_Program_Nm__c == Co_GTM_PROG){ string region = 'WW';
                  
                  if(string.isNotBlank(region)){
                      WW_allAccAllBTSetKey = region +'->'+ progId + '_' + approvalStage;
                  } if(string.isNotBlank(WW_allAccAllBTSetKey)){ WW_allAccSpecificBTSetKey = budgetType != null ? WW_allAccAllBTSetKey + '_' + budgetType : '';  }
                  
                  if(string.isNotBlank(WW_allAccAllBTSetKey)){
                      WW_singleAccAllBTSetKey = WW_allAccAllBTSetKey + '_' + ultAccount;
                  }
                  if(string.isNotBlank(WW_allAccSpecificBTSetKey)){
                      WW_singleAccSpecificBTSetKey = WW_allAccSpecificBTSetKey + '_' + ultAccount;
                  }
                  
                  if((!allAccAllBTSet.isEmpty() && string.isNotBlank(WW_allAccAllBTSetKey) && allAccAllBTSet.contains(WW_allAccAllBTSetKey) ) ||
                     (!allAccSpecificBTSet.isEmpty() && string.isNotBlank(WW_allAccSpecificBTSetKey) && allAccSpecificBTSet.contains(WW_allAccSpecificBTSetKey)) ||
                     (!singleAccAllBTSet.isEmpty() && string.isNotBlank(WW_singleAccAllBTSetKey) && singleAccAllBTSet.contains(WW_singleAccAllBTSetKey)) ||
                     (!singleAccSpecificBTSet.isEmpty() && string.isNotBlank(WW_singleAccSpecificBTSetKey) && singleAccSpecificBTSet.contains(WW_singleAccSpecificBTSetKey))){
                         budgetToApproveList.add(obj);
                         budgetIdSet.add(obj.Id);
                     }
              }
              
          }
          
            if(!budgetToApproveList.isEmpty()){

                //Check FLS
                if(!objNameToSObjectMap.containsKey(objName)){
                    List<sObject> sObjList = new List<sObject>{budgetToApproveList[0]};
                    objNameToSObjectMap = getFLSDetails(objName,sObjList);
                }
                
            }
        }
        approvalWrap.count = budgetToApproveList.size();
        if(!budgetToApproveList.isEmpty() && objNameToSObjectMap.containsKey(objName)){
            return approvalWrap;
        }else{
            return null;
        }
    }

/*****************************************************************************************************
Method Name :   getPFCApproversForHomePage
Description :   to get the claim records for approvals
******************************************************************************************************/   
  Public static ApprovalWrapper getPFCApproversForHomePage(set<string> programNameSet, set<string> approvalStageSet, string objName){
        string IPA_PROG = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
        string Co_GTM_PROG = Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM;
        
      
        List<PartnerFundClaim> claimObjRecordList = new List<PartnerFundClaim>();
        List<PartnerFundClaim> claimToApproveList = new List<PartnerFundClaim>();
        Set<Id> claimIdSet = new Set<Id>();
        List<SObject> objList = new List<SObject>();
        List<RecordsToApprove> recordWrapList = new List<RecordsToApprove>();
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        approvalWrap.icon = String.valueOf(mdtValues.Core_MDF_Field_8_txt__c);
        approvalWrap.objectName = String.valueOf(mdtValues.Core_MDF_Field_9_txt__c);

       
        ParamWrapper paramWrap = new ParamWrapper();
        paramWrap.fieldApiNames = String.valueOf(mdtValues.Core_MDF_Field_7_txt__c);
        paramWrap.inProgressTrackingRecordIds = inProgressTrackingRecordIds;
        paramWrap.programNameSet = programNameSet;
        claimObjRecordList = Core_MDF_IUPGM_ApprovalRequestData.getClaimRecordData(paramWrap);

      
      if(!claimObjRecordList.isEmpty()){
          for(PartnerFundClaim obj: claimObjRecordList){ string allAccAllBTSetKey,allAccSpecificBTSetKey,singleAccAllBTSetKey,singleAccSpecificBTSetKey;string WW_allAccAllBTSetKey, WW_allAccSpecificBTSetKey, WW_singleAccAllBTSetKey, WW_singleAccSpecificBTSetKey; string progId = progToIdMap.get(obj.Core_MDF_Program__c);string budgetType = string.isNotBlank(obj.Core_MDF_Budget_Type_Options_Nm__c) ? obj.Core_MDF_Budget_Type_Options_Nm__c.replaceAll('\\s+', '') : ''; String ultimateAccount = (String)obj.Core_MDF_Ultimate_Account_ID__c;Id ultAccount= ultimateAccount; string approvalStage = string.isNotBlank(obj.Core_MDF_Approval_Stage_nm__c) ? obj.Core_MDF_Approval_Stage_nm__c.replaceAll('\\s+', '') : '';if((obj.Core_MDF_Program__c == IPA_PROG) || (obj.Core_MDF_Program__c == Co_GTM_PROG)){
                    string region = (obj.Core_MDF_Program__c == IPA_PROG) ? (string.isNotBlank(obj.Core_MDF_Region_Cd__c) ? obj.Core_MDF_Region_Cd__c : '') : (obj.Core_MDF_Program__c == Co_GTM_PROG ? 'EMEA;PRC;APJ;ASMO;INDIA' : ''); if(string.isNotBlank(region)){ allAccAllBTSetKey = region +'->'+ progId + '_' + approvalStage;
                  }
                  
                  if(string.isNotBlank(allAccAllBTSetKey)){ allAccSpecificBTSetKey = budgetType != null ? allAccAllBTSetKey + '_' + budgetType : '';
                  }
                  
                  if(string.isNotBlank(obj.Core_MDF_Program__c)){ if(string.isNotBlank(allAccAllBTSetKey)){ singleAccAllBTSetKey = allAccAllBTSetKey + '_' + ultAccount;
                      }
                      if(string.isNotBlank(allAccSpecificBTSetKey)){ singleAccSpecificBTSetKey = allAccSpecificBTSetKey + '_' + ultAccount;
                      }
                  }
                    if(string.isNotBlank(allAccAllBTSetKey) && allAccAllBTSetKey.contains('->')){ List<string> tempList = allAccAllBTSetKey.split('->'); WW_allAccAllBTSetKey = STR_WW + '->' + tempList[1];
                    }
                    if(string.isNotBlank(allAccSpecificBTSetKey) && allAccSpecificBTSetKey.contains('->')){ List<string> tempList = allAccSpecificBTSetKey.split('->');WW_allAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                    }
                    if(string.isNotBlank(singleAccAllBTSetKey) && singleAccAllBTSetKey.contains('->')){ List<string> tempList = singleAccAllBTSetKey.split('->'); WW_singleAccAllBTSetKey = STR_WW + '->' + tempList[1];
                    }
                    if(string.isNotBlank(singleAccSpecificBTSetKey) && singleAccSpecificBTSetKey.contains('->')){ List<string> tempList = singleAccSpecificBTSetKey.split('->'); WW_singleAccSpecificBTSetKey = STR_WW + '->' + tempList[1];
                    }
                    if((!allAccAllBTSet.isEmpty() && string.isNotBlank(allAccAllBTSetKey) && string.isNotBlank(WW_allAccAllBTSetKey) && (allAccAllBTSet.contains(allAccAllBTSetKey) || allAccAllBTSet.contains(WW_allAccAllBTSetKey) )) || (!allAccSpecificBTSet.isEmpty() && string.isNotBlank(allAccSpecificBTSetKey) && string.isNotBlank(WW_allAccSpecificBTSetKey) && (allAccSpecificBTSet.contains(allAccSpecificBTSetKey) || allAccSpecificBTSet.contains(WW_allAccSpecificBTSetKey))) ||(!singleAccAllBTSet.isEmpty() && string.isNotBlank(singleAccAllBTSetKey) && string.isNotBlank(WW_singleAccAllBTSetKey) && (singleAccAllBTSet.contains(singleAccAllBTSetKey) || singleAccAllBTSet.contains(WW_singleAccAllBTSetKey))) || (!singleAccSpecificBTSet.isEmpty() && string.isNotBlank(singleAccSpecificBTSetKey) && string.isNotBlank(WW_singleAccSpecificBTSetKey) && (singleAccSpecificBTSet.contains(singleAccSpecificBTSetKey) || singleAccSpecificBTSet.contains(WW_singleAccSpecificBTSetKey)))){ claimToApproveList.add(obj); claimIdSet.add(obj.Id);
                       }
                  
              }       
          }
          
            if(!claimToApproveList.isEmpty()){

                //Check FLS
                if(!objNameToSObjectMap.containsKey(objName)){ List<sObject> sObjList = new List<sObject>{claimToApproveList[0]}; objNameToSObjectMap = getFLSDetails(objName,sObjList);
                }
                
            }
        }
        approvalWrap.count = claimToApproveList.size();
        if(!claimToApproveList.isEmpty() && objNameToSObjectMap.containsKey(objName)){
            return approvalWrap;
        }else{
            return null;
        }
    }
 
    
/*****************************************************************************************************
Method Name :   getApproversBasedOnPIForHomePage
Description :   to get the approval process version
******************************************************************************************************/
    Public static ApprovalWrapper getApproversBasedOnPIForHomePage(String objName){
        ApprovalWrapper approvalWrap = new ApprovalWrapper();
        Set<String> objRecIds = new Set<String>();
        List<SObject> objList = new List<SObject>();
        String objectName = '';
        Core_MDF_CCP_Custom_Metadata_Utility__c mdtValues = approvalReqObjMdtPIMap.get(objName);
        try{
            
        
        
        for(ProcessInstanceWorkItem piwi : [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.TargetObject.Type,
                                            ProcessInstance.TargetObject.Name,CreatedBy.name,CreatedDate 
                                            FROM ProcessInstanceWorkItem
                                            WHERE ProcessInstance.Status =: Core_MDF_CCP_ConstantClass.PFR_PENDING_STATUS
                                            AND ProcessInstance.TargetObject.Type =: objName
                                            AND ProcessInstance.TargetObjectId NOT IN: iupgmBasedApprovalIds
                                            AND (Actor.Id =: UserInfo.getUserId() OR Actor.Id IN: queueIds) ORDER BY CreatedDate DESC]){
                                                objRecIds.add(piwi.ProcessInstance.TargetObjectId); 
                                            }

        if(!objRecIds.isEmpty()){
            ParamWrapper paramWrap = new ParamWrapper();paramWrap.fieldApiNames = String.valueOf(mdtValues.Core_MDF_Field_7_txt__c);paramWrap.objName = objName; paramWrap.objRecIds = objRecIds;objList = Core_MDF_IUPGM_ApprovalRequestData.getPIRecordData(paramWrap);            
        }
            if(!objList.isEmpty()){
                if(!objNameToSObjectMap.containsKey(objName)){ List<sObject> sObjList = new List<sObject>{objList[0]}; objNameToSObjectMap = getFLSDetails(objName,sObjList);
                }       
            }

        approvalWrap.count = objList.size();
        approvalWrap.objectName = String.valueOf(mdtValues.Core_MDF_Field_9_txt__c); 
        if(!objList.isEmpty() && objNameToSObjectMap.containsKey(objName)){ return approvalWrap;
        } else {
            return null;
        }
        }
        catch(Exception ex){ 
	    //Avoid empty catch blocks
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return approvalWrap;
    } 
    /*****************************************************************************************************
Method Name :   hasAdditionalReviewAccess
Description :   return boolean based on the Field review/marketing review for Addtiional reviewer
Added By    :   Aswin Selvaraj / Accenture / 30/Oct/2024                 
******************************************************************************************************/	
    public static boolean hasAdditionalReviewAccess (PartnerfundRequest pfr){
        Boolean isAdditionalReviwer = false;
        if((pfr.Core_MDF_Additional_Review_Type_txt__c=='Field Review' && (roleToStageSetMap.containskey('Core_MDF_CCP_Internal_CCF_Field_Acct_Mgr') || roleToStageSetMap.containskey('Core_MDF_CCP_Internal_DCF_Field_Acct_Mgr'))) ||
           (pfr.Core_MDF_Additional_Review_Type_txt__c=='Marketing Review' && (roleToStageSetMap.containskey('Core_MDF_CCP_Internal_CCF_Acct_Mgr') || roleToStageSetMap.containskey('Core_MDF_CCP_Internal_DCF_Acct_Mgr')))){
               isAdditionalReviwer = true;
           }
        return isAdditionalReviwer;
    }
    Public static Map<String,SObject> getFLSDetails(string objName,List<sObject> sObjList){
        Boolean noAccess = false;
        List<sObject> objFieldAccess = new List<sObject>();
        try{
            SObjectAccessDecision objectAccess = Security.stripInaccessible(AccessType.READABLE, sObjList);
            objFieldAccess.add((sObject)objectAccess.getRecords()[0]);
        }catch(NoAccessException ex){ Core_MDF_CCP_UtilityClass.logError(ex); noAccess = true;
        }
        if(!objFieldAccess.isEmpty() && !noAccess){
            objNameToSObjectMap.put(objName, objFieldAccess[0]);
        }
        return objNameToSObjectMap;
    }
        
    
    @AuraEnabled
    Public static string getValidationMessage(){
        ValidationMsgWrapper validationWrap = new ValidationMsgWrapper();
        validationWrap.Core_MDF_Select_Same_Object_Type = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Select_Same_Object_Type');
        validationWrap.Core_MDF_Bulk_Approval_Max_Limit = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bulk_Approval_Max_Limit');
        validationWrap.Core_MDF_Bulk_Approval_Max_Limit_Count = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bulk_Approval_Max_Limit_Count');
        validationWrap.Core_MDF_Home_Page_Dashboard_Col_Header1 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Home_Page_Dashboard_Col_Header1');
        validationWrap.Core_MDF_Home_Page_Dashboard_Col_Header2 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Home_Page_Dashboard_Col_Header2');
        validationWrap.Core_MDF_Home_Page_Dashboard_NoRecMsg = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Home_Page_Dashboard_NoRecMsg');
        validationWrap.Core_MDF_PermanentRejectionClaimError = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PermanentRejectionClaimError');
        validationWrap.Core_MDF_PermanentRejectionCheckboxMsg = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PermanentRejectionCheckboxMsg');
        validationWrap.Core_MDF_PermanentRejectionWarning = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PermanentRejectionWarning');
        return JSON.serialize(validationWrap);
    }

    public class ProcessedResultWrapper {
        @AuraEnabled public String workitemId {get; set;}
    }
    
    Public class KeySetWrapper {
        public set<string> allAccAllBTSet;
        public set<string> allAccSpecificBTSet;
        public set<string> singleAccAllBTSet;
        public set<string> singleAccSpecificBTSet;
        Public KeySetWrapper() {
            allAccAllBTSet = new set<string>();
            allAccSpecificBTSet = new set<string>();
            singleAccAllBTSet = new set<string>();
            singleAccSpecificBTSet = new set<string>();
        }
    }
    
    Public class ApprovalWrapper {
        public string icon;
        public string objectName;
        public Integer count;
        public boolean byPassBulk = false;
        public userPermissionApproval userPermission;
        public List<RecordsToApprove> recordsToApprove;
    }
    
    Public class userPermissionApproval{
        public Boolean isL2SalesApprover = false;
        public Boolean isL1Approver = false;
    }
    
    Public class RecordsToApprove {
        public string id;
        public string piwiId;
        public string title;
        public boolean isSelected = false;
        public string comments;
        public List<FieldsWrapper> compactDetails;
        public List<FieldsWrapper> tableViewDetails;
        public List<FieldsWrapper> recordDetails;
    }
    
    Public class FieldsWrapper {
        public string label;
        public string value;
        public string redirect;
        Public FieldsWrapper() {
            label = '';
            value = '';
            redirect = '';
        }
    }
    
    Public class ApprovalRequestWrapper {
        public string requestId;
        public string actionStatus;
        public string comments;
        public string piwiId;
        public string title;
        public string targetObjectName;
        public Boolean isDesktop;
        public boolean permanentReject;
    }
    
    Public class ResultWrapper {
        public boolean isSuccess;
        public boolean isBatchExecuted = false;
        public string message;
        public string variant;
        public boolean showContent = false;
        public List<ApprovalResult> approvalErrorResult = new List<ApprovalResult>();
        public List<ApprovalResult> approvalSuccessResult = new List<ApprovalResult>();
        public List<ApprovalResult> approvalTotalResult = new List<ApprovalResult>();
    }
    
    Public class ApprovalResult{
        public string id;        
        public boolean isChecked = true;
        public string title;
        public string message;
        public string redirect;
        public string status;
        
    }
    
    Public class ParamWrapper{
        public string fieldApiNames;        
        public Set<Id> inProgressTrackingRecordIds = new Set<Id>();
        public Set<string> programNameSet = new Set<string>();
        public set<string> approvalStageSet = new Set<string>();
        public Set<string> objRecIds = new Set<string>();
        public string objName;
        
    }
    
    Public class ProcessResultWrapper {
        public List<Approval.ProcessWorkitemRequest> successItemsList {get; set;}
        public List<Approval.ProcessWorkitemRequest> errorItemsList {get; set;}
        public List<Approval.ProcessWorkitemRequest> allItemsList {get; set;}
        public List<ApprovalResult> approvalErrorResult {get; set;}
        public List<ApprovalResult> approvalSuccessResult {get; set;}
    }
    Public class ObjectWrapper {
        public List<sObject> sObjectList = new List<sObject>();
        public string objName;
    }
    
    Public class ValidationMsgWrapper {
        public string Core_MDF_Select_Same_Object_Type;
        public string Core_MDF_Bulk_Approval_Max_Limit;
        public string Core_MDF_Bulk_Approval_Max_Limit_Count;
        public string Core_MDF_Home_Page_Dashboard_Col_Header1;
        public string Core_MDF_Home_Page_Dashboard_Col_Header2;
        public string Core_MDF_Home_Page_Dashboard_NoRecMsg;
        public string Core_MDF_PermanentRejectionClaimError;
        public string Core_MDF_PermanentRejectionCheckboxMsg;
        public string Core_MDF_PermanentRejectionWarning;

    }
    
    
}