/****************************************************************************************************
Apex Class Name : PSG_DPA_ALNBusinessLogic
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is Helper class for DPA/ALN Object Trigger Operations.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari                    08/13/2021                Created
*****************************************************************************************************/
public without sharing class PSG_DPA_ALNBusinessLogic{
    public static Map<String, String> mtdtBOQueueMap = new Map <String, String>();
    static{
        for(PSG_BO_Queue_Owner_Mapping__mdt boQueueRec : [SELECT Id, DeveloperName, PSG_BO_Queue_Name__c, PSG_Disti_Geo__c FROM PSG_BO_Queue_Owner_Mapping__mdt WHERE PSG_Active__c = true]){                                                          
            for(String localGeoStr: (boQueueRec.PSG_Disti_Geo__c).split(',')){
                mtdtBOQueueMap.put(localGeoStr, boQueueRec.PSG_BO_Queue_Name__c);
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : beforeInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Method performs are the operations in before context.
    ************************************************************************************************************/
    public static void beforeInsertUpdateOperations(List<core_cpq_dpa_aln__c> dpa_alnList,Map<Id,core_cpq_dpa_aln__c> oldMap,Boolean isInsert){
        Boolean isUpdate = !isInsert;
        /*Map<Id,String> userIdToRoleMap = new Map<Id,String>();
        for(PermissionSetAssignment psa : [SELECT Id,AssigneeId,PermissionSet.Name,PermissionSet.Profile.Name,Assignee.Contact.AccountId FROM PermissionSetAssignment WHERE 
                                           (PermissionSet.Name =: Label.PSG_Quote_SOS_PermissionSet OR 
                                            PermissionSet.Name =: Label.PSG_Quote_BO_PermissionSet OR 
                                            PermissionSet.Name =: Label.PSG_Quote_BM_PermissionSet OR 
                                            PermissionSet.Name =: Label.PSG_PermissionSets_PSG_Distributor OR
                                            PermissionSet.ProfileId =: Userinfo.getProfileId())]){
                                                
                                                
                                                if(psa.PermissionSet.Name == Label.PSG_PermissionSets_PSG_Distributor){
                                                    userIdToRoleMap.put(psa.AssigneeId,'Disty');
                                                }                                                               
                                                if(psa.PermissionSet.Name == Label.PSG_Quote_SOS_PermissionSet){
                                                    userIdToRoleMap.put(psa.AssigneeId,'SOS');
                                                }else if(psa.PermissionSet.Name == Label.PSG_Quote_BM_PermissionSet){
                                                    userIdToRoleMap.put(psa.AssigneeId,'BM');
                                                }else if(psa.PermissionSet.Name == Label.PSG_Quote_BO_PermissionSet){
                                                    userIdToRoleMap.put(psa.AssigneeId,'BO');
                                                }
                                            }*/
        
        Map<String, Id> bizOpsQueueMap = new Map<String, Id>();   
        for(Group boQueue: [SELECT Id, name, DeveloperName FROM Group WHERE type = 'Queue' AND DeveloperName like '%busops%' ]){
            bizOpsQueueMap.put(boQueue.name,boQueue.Id);
        }
        
        Set<Id> assignedToSet = new Set<Id>();
        Set<Id> boAssignedToSet = new Set<Id>();
        
        if(isInsert){
            
            Set<Id> quoteSet = new Set<Id>();
            
            Map <Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
            
            for(core_cpq_dpa_aln__c dpa_aln : dpa_alnList){          
                if(dpa_aln.core_cpq_active_quote__c != null){
                    quoteSet.add(dpa_aln.core_cpq_active_quote__c);
                }
                if(dpa_aln.core_cpq_ship_start_date_dt__c == null && dpa_aln.core_cpq_ship_end_date_dt__c==null&&dpa_aln.core_cpq_duration_nbr__c==null){   
                    dpa_aln.core_cpq_ship_start_date_dt__c=Date.today();//autopopulate
                    dpa_aln.core_cpq_ship_end_date_dt__c=  (dpa_aln.core_cpq_ship_start_date_dt__c).addMonths(12);
                    dpa_aln.core_cpq_duration_nbr__c = 12;
                }
                else if(dpa_aln.core_cpq_ship_start_date_dt__c != null && dpa_aln.core_cpq_ship_end_date_dt__c != null && dpa_aln.core_cpq_duration_nbr__c==null){
                    dpa_aln.core_cpq_duration_nbr__c = dpa_aln.core_cpq_ship_start_date_dt__c.monthsBetween(dpa_aln.core_cpq_ship_end_date_dt__c);
                }
                else if(dpa_aln.core_cpq_ship_start_date_dt__c != null && dpa_aln.core_cpq_duration_nbr__c!=null){
                    dpa_aln.core_cpq_ship_end_date_dt__c= dpa_aln.core_cpq_ship_start_date_dt__c.addMonths((integer)dpa_aln.core_cpq_duration_nbr__c);                  
                }
                
                /*if(dpa_aln.core_cpq_active_quote__r.core_cpq_pricing_parent_active_cb__c == false || dpa_aln.core_cpq_active_quote__r.core_cpq_end_customer_nm__r.Core_Direct_Legal_Parent_Id__c != dpa_aln.core_cpq_active_quote__r.core_cpq_cmf_pricing_parent__c){
                    dpa_aln.addError('Testing Purpose!! HAHAHHAHAHAHah');
                }*/
            }
            
            if(!quoteSet.isEmpty()){
                quoteMap = new Map<Id, SBQQ__Quote__c>([SELECT id, SBQQ__Distributor__c,SBQQ__Distributor__r.Core_Direct_Pricing_Parent_Id__c, SBQQ__Distributor__r.Core_Geo__c,SBQQ__Distributor__r.Name,core_cpq_revision_nbr__c,core_cpq_cm_name_nm__c,core_cpq_cm_name_nm__r.Core_Direct_Pricing_Parent_Id__c,core_cpq_end_customer_nm__c,core_cpq_end_customer_nm__r.Core_Direct_Pricing_Parent_Id__c,tolabel(core_cpq_cm_name_nm__r.Core_Direct_Pricing_Parent_Id__r.BillingStateCode),tolabel(core_cpq_cm_name_nm__r.Core_Direct_Pricing_Parent_Id__r.BillingCountryCode),core_cpq_cm_country__c,Name,core_cpq_account_program__c,core_cpq_Latest_Account_Program__c,core_cpq_ec_region_txt__c,core_cpq_disty_group_name__c FROM SBQQ__Quote__c WHERE Id IN: quoteSet]);
            }
            
            for(core_cpq_dpa_aln__c dpa_aln : dpa_alnList){
                //TWC3133-5964 Geo Change
                String distiGeo = '';
                if(quoteMap.containsKey(dpa_aln.core_cpq_active_quote__c)){
                    distiGeo = (quoteMap.get(dpa_aln.core_cpq_active_quote__c).SBQQ__Distributor__r.Core_Geo__c == 'INDIA') ? 'APJ' : quoteMap.get(dpa_aln.core_cpq_active_quote__c).SBQQ__Distributor__r.Core_Geo__c;
                }
                else{
                    distiGeo = '';
                }
                
                if(mtdtBOQueueMap.containskey(distiGeo) && /*userIdToRoleMap.get(userInfo.getUserId()) == 'Disty'*/ UserInfo.getUserType()=='PowerPartner'){
                    if(bizOpsQueueMap.containsKey(mtdtBOQueueMap.get(distiGeo))){
                        dpa_aln.OwnerId = bizOpsQueueMap.get(mtdtBOQueueMap.get(distiGeo));
                    }
                }
                if(quoteMap.containsKey(dpa_aln.core_cpq_active_quote__c)){
                    if(dpa_aln.core_cpq_sap_end_customer_nm__c == null){
                        dpa_aln.core_cpq_sap_end_customer_nm__c  = quoteMap.get(dpa_aln.core_cpq_active_quote__c).core_cpq_end_customer_nm__r.Core_Direct_Pricing_Parent_Id__c;
                        
                    }
                    if(dpa_aln.core_cpq_cm_name_nm__c == null){
                        dpa_aln.core_cpq_cm_name_nm__c = quoteMap.get(dpa_aln.core_cpq_active_quote__c).core_cpq_cm_name_nm__r.Core_Direct_Pricing_Parent_Id__c;
                        dpa_aln.core_cpq_cm_country_txt__c=quoteMap.get(dpa_aln.core_cpq_active_quote__c).core_cpq_cm_name_nm__r.Core_Direct_Pricing_Parent_Id__r.BillingCountryCode;
                        dpa_aln.core_cpq_sap_state_txt__c = quoteMap.get(dpa_aln.core_cpq_active_quote__c).core_cpq_cm_name_nm__r.Core_Direct_Pricing_Parent_Id__r.BillingStateCode;
                    }
                    if( dpa_aln.core_cpq_quote_distributor__c == null){
                        dpa_aln.core_cpq_quote_distributor__c = quoteMap.get(dpa_aln.core_cpq_active_quote__c).SBQQ__Distributor__c;
                    }
                    if( dpa_aln.core_cpq_account_program__c == null){
                        dpa_aln.core_cpq_account_program__c = quoteMap.get(dpa_aln.core_cpq_active_quote__c).core_cpq_Latest_Account_Program__c;
                    }
						dpa_aln.core_cpq_disty_group_name__c = quoteMap.get(dpa_aln.core_cpq_active_quote__c).core_cpq_disty_group_name__c;	
                        dpa_aln.core_cpq_ec_region_txt__c = quoteMap.get(dpa_aln.core_cpq_active_quote__c).core_cpq_ec_region_txt__c;
                }
            }
            
        }
        
        if(isUpdate){
            Map<Id,Account> accountMap = new Map<Id,Account>();
            Map <Id, core_cpq_dpa_aln__c> dpaIdtoDpaShipDateChangeMap = new Map<Id, core_cpq_dpa_aln__c>();
            List<core_cpq_dpa_aln_line__c> dpaLinesList = new List<core_cpq_dpa_aln_line__c>();
            Set<String> replaceAlnList=new Set<String>();
            set<Id> cmAccountId=new set<Id>();
            Map<String,core_cpq_dpa_aln__c> rplaceALNMap=new Map<String,core_cpq_dpa_aln__c>();
            for(core_cpq_dpa_aln__c dpa_aln : dpa_alnList){   
                if(oldMap.get(dpa_aln.Id).core_cpq_replace_aln_txt__c != dpa_aln.core_cpq_replace_aln_txt__c && dpa_aln.core_cpq_replace_aln_txt__c != null){
                    replaceAlnList.add(dpa_aln.core_cpq_replace_aln_txt__c);
                }
                if(oldMap.get(dpa_aln.Id).core_cpq_cm_name_nm__c != dpa_aln.core_cpq_cm_name_nm__c && dpa_aln.core_cpq_cm_name_nm__c!= null){
                    cmAccountId.add(dpa_aln.core_cpq_cm_name_nm__c);
                } 
                else if(oldMap.get(dpa_aln.Id).core_cpq_final_ship_to_customer_nm__c != dpa_aln.core_cpq_final_ship_to_customer_nm__c && dpa_aln.core_cpq_final_ship_to_customer_nm__c!= null){
                    cmAccountId.add(dpa_aln.core_cpq_final_ship_to_customer_nm__c);
                }
                
                if(oldMap.get(dpa_aln.Id).core_cpq_sap_end_customer_nm__c != dpa_aln.core_cpq_sap_end_customer_nm__c && dpa_aln.core_cpq_sap_end_customer_nm__c != null){
                    cmAccountId.add(dpa_aln.core_cpq_sap_end_customer_nm__c);
                }
                
                if(dpa_aln.core_cpq_assigned_to_nm__c != null && (oldMap.get(dpa_aln.Id).core_cpq_assigned_to_nm__c != dpa_aln.core_cpq_assigned_to_nm__c)){
                    assignedToSet.add(dpa_aln.core_cpq_assigned_to_nm__c);
                }
                if (dpa_aln.core_cpq_change_flag__c == 'E' && oldMap.get(dpa_aln.Id).core_cpq_ship_end_date_dt__c != dpa_aln.core_cpq_ship_end_date_dt__c){
                    if(dpa_aln.core_cpq_ship_end_date_dt__c <= System.today()){
                    	dpa_aln.core_cpq_extend_expire__c = 'Expire';
                    }else{
                        dpa_aln.core_cpq_extend_expire__c = 'Extend';
                    }
				}
            }
            
            if(!cmAccountId.isEmpty()){
                accountMap =  new Map<Id,Account>([SELECT Id,Core_Partner_Alliance_Program__c,
                                                   Core_Account_Tier__c,Name,Core_Geo__c,Core_Sub_Geo__c,
                                                   Core_Direct_Pricing_Parent_Id__c,Core_Direct_Pricing_Parent_Id__r.Core_Direct_Parent_Account_Tier_Nm__c,
                                                   Core_Direct_Pricing_Parent_Id__r.Core_Sub_Geo__c,Core_Direct_Pricing_Parent_Id__r.Core_Geo__c, tolabel(BillingCountryCode),tolabel(BillingStateCode)
                                                   from Account where Id=:cmAccountId]);                
            }
            if(!assignedToSet.isEmpty()){
                for(PermissionSetAssignment psa : [SELECT PermissionSet.Name,AssigneeId FROM PermissionSetAssignment  WHERE AssigneeId IN :assignedToSet AND PermissionSet.Name =:Label.PSG_Quote_BO_PermissionSet]){ 
                    boAssignedToSet.add(psa.AssigneeId);
                }
            }
            
            if(!replaceAlnList.isEmpty()){
                for(core_cpq_dpa_aln__c dpa_aln : [Select Id,Name,core_cpq_dpa_aln_no_nbr__c,core_cpq_status_txt__c from core_cpq_dpa_aln__c where core_cpq_status_txt__c='Hold' and core_cpq_dpa_aln_no_nbr__c in :replaceAlnList and core_cpq_record_type_identifier__c = 'ALN']){
                    if(dpa_aln.core_cpq_dpa_aln_no_nbr__c != null)
                        rplaceALNMap.put(dpa_aln.core_cpq_dpa_aln_no_nbr__c, dpa_aln);
                    else
                        rplaceALNMap.put(dpa_aln.Name, dpa_aln);
                }
            }
            
            String convertToUpper;
            for(core_cpq_dpa_aln__c  dpa_aln : dpa_alnList){          
                if(dpa_aln.core_cpq_cm_name_nm__c != null && accountMap.containsKey(dpa_aln.core_cpq_cm_name_nm__c)){
                    convertToUpper = accountMap.get(dpa_aln.core_cpq_cm_name_nm__c).BillingCountrycode;
                    dpa_aln.core_cpq_cm_country_txt__c = convertToUpper?.toUpperCase();
                    dpa_aln.core_cpq_sap_state_txt__c = accountMap.get(dpa_aln.core_cpq_cm_name_nm__c).BillingStatecode;
                    
                }else if(dpa_aln.core_cpq_cm_name_nm__c == null){
                    dpa_aln.core_cpq_cm_country_txt__c =null;
                    dpa_aln.core_cpq_sap_state_txt__c  = null;
                }
                if(accountMap.containsKey(dpa_aln.core_cpq_final_ship_to_customer_nm__c )){
                    convertToUpper=  accountMap.get(dpa_aln.core_cpq_final_ship_to_customer_nm__c).BillingCountryCode; 
                    dpa_aln.core_cpq_final_ship_to_country_txt__c = convertToUpper?.toUpperCase();
                }else if(dpa_aln.core_cpq_final_ship_to_customer_nm__c == null){
                    dpa_aln.core_cpq_final_ship_to_country_txt__c = null;
                }
                
                if(oldMap.get(dpa_aln.Id).core_cpq_replace_aln_txt__c != dpa_aln.core_cpq_replace_aln_txt__c && dpa_aln.core_cpq_replace_aln_txt__c != null && Label.PSG_System_User != UserInfo.getUserId() && dpa_aln.core_cpq_ship_end_date_dt__c>System.TODAY()){
                    if(rplaceALNMap.containsKey(dpa_aln.core_cpq_replace_aln_txt__c)){
                        //if(rplaceALNMap.get(dpa_aln.core_cpq_replace_aln_txt__c).core_cpq_status_txt__c == 'Hold'){
                            dpa_aln.core_cpq_change_flag__c='R';
                        /*}else{
                            dpa_aln.core_cpq_replace_aln_txt__c.addError('Selected ALN #'+dpa_aln.core_cpq_replace_aln_txt__c+' should be in Hold state');
                        }*/
                    }else{
                        //dpa_aln.core_cpq_replace_aln_txt__c.addError('Unable to find ALN #'+dpa_aln.core_cpq_replace_aln_txt__c);
                        dpa_aln.core_cpq_replace_aln_txt__c.addError('Selected ALN #'+dpa_aln.core_cpq_replace_aln_txt__c+' is not in Hold state or does not exist.'); 
                    }
                }
                if((oldMap.get(dpa_aln.Id).core_cpq_ship_end_date_dt__c != dpa_aln.core_cpq_ship_end_date_dt__c) || (oldMap.get(dpa_aln.Id).core_cpq_ship_start_date_dt__c != dpa_aln.core_cpq_ship_start_date_dt__c ) ){
                    dpa_aln.core_cpq_duration_nbr__c = dpa_aln.core_cpq_ship_start_date_dt__c.monthsBetween(dpa_aln.core_cpq_ship_end_date_dt__c);
                }else if((oldMap.get(dpa_aln.Id).core_cpq_ship_end_date_dt__c == dpa_aln.core_cpq_ship_end_date_dt__c) && (oldMap.get(dpa_aln.Id).core_cpq_ship_start_date_dt__c == dpa_aln.core_cpq_ship_start_date_dt__c ) && (oldMap.get(dpa_aln.Id).core_cpq_duration_nbr__c != dpa_aln.core_cpq_duration_nbr__c) ){
                    dpa_aln.core_cpq_ship_end_date_dt__c= dpa_aln.core_cpq_ship_start_date_dt__c.addMonths((integer)dpa_aln.core_cpq_duration_nbr__c);
                }
                if(dpa_aln.core_cpq_assigned_to_nm__c!= null && (oldMap.get(dpa_aln.Id).core_cpq_assigned_to_nm__c != dpa_aln.core_cpq_assigned_to_nm__c) && !(boAssignedToSet.contains(dpa_aln.core_cpq_assigned_to_nm__c)) && Label.PSG_System_User != UserInfo.getUserId() &&  dpa_aln.core_cpq_ship_end_date_dt__c>System.TODAY()){
                    dpa_aln.addError('Only Business Operations can be assigned as DPA/ALN owner');
                }
                if((oldMap.get(dpa_aln.Id).core_cpq_ship_end_date_dt__c != dpa_aln.core_cpq_ship_end_date_dt__c) || (oldMap.get(dpa_aln.Id).core_cpq_ship_start_date_dt__c != dpa_aln.core_cpq_ship_start_date_dt__c ) ){
                    dpaIdtoDpaShipDateChangeMap.put(dpa_aln.Id, dpa_aln);   
                }
                if((oldMap.get(dpa_aln.Id).core_cpq_ship_end_date_dt__c != dpa_aln.core_cpq_ship_end_date_dt__c)){
                    dpa_aln.core_cpq_previous_ship_end_date__c=oldMap.get(dpa_aln.Id).core_cpq_ship_end_date_dt__c;
                }
            }
            if(!dpaIdtoDpaShipDateChangeMap.isEmpty()){
                for(core_cpq_dpa_aln_line__c dpaLines : [SELECT id, core_cpq_ship_start_date_dt__c, core_cpq_ship_exp_date_dt__c,core_cpq_duration_nbr__c,Name,core_cpq_cis_no_nbr__c FROM core_cpq_dpa_aln_line__c WHERE core_cpq_cis_no_nbr__c IN :dpaIdtoDpaShipDateChangeMap.keySet()]){
                    dpaLines.core_cpq_ship_start_date_dt__c = dpaIdtoDpaShipDateChangeMap.get(dpaLines.core_cpq_cis_no_nbr__c).core_cpq_ship_start_date_dt__c;
                    dpaLines.core_cpq_ship_exp_date_dt__c=dpaIdtoDpaShipDateChangeMap.get(dpaLines.core_cpq_cis_no_nbr__c).core_cpq_ship_end_date_dt__c;
                    dpaLines.core_cpq_duration_nbr__c=dpaIdtoDpaShipDateChangeMap.get(dpaLines.core_cpq_cis_no_nbr__c).core_cpq_duration_nbr__c;
                    dpaLinesList.add(dpaLines);
                    
                }
            }
            if(!dpaLinesList.isEmpty()){
                try{
                    update as system dpaLinesList;
                }catch(Exception e){
                    PSG_Utility.logError(e);
                }                
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : afterInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Method performs are the operations in after context.
    ************************************************************************************************************/
    public static void afterInsertUpdateOperations(List<core_cpq_dpa_aln__c> dpa_alnList,Map<Id,core_cpq_dpa_aln__c> oldMap,Boolean isInsert){
        if(isInsert && !dpa_alnList.isEmpty()){
            set<Id>accountIdSet = new set<Id>();
            Map<String,Set<Id>> quoteIdToDistyAccountIdToShareMap = new Map<String,Set<Id>>();
            set<Id>quoteIdSet = new set<Id>();
            Map<String,String> idToNewGroupMap = new Map<String,String>();
            for(core_cpq_dpa_aln__c dpaObj : dpa_alnList){
                if(dpaObj.core_cpq_quote_distributor__c != null){
                    //accountIdSet.add(dpaObj.core_cpq_quote_distributor__c);
                    quoteIdSet.add(dpaObj.core_cpq_active_quote__c);
                    if(dpaObj.core_cpq_disty_group_name__c != null){
                       idToNewGroupMap.put(dpaObj.Id,dpaObj.core_cpq_disty_group_name__c); 
                    }
                }
            }
            if(!quoteIdSet.isEmpty()){
                for(core_cpq_disty_visibility__c distyVisibility : [SELECT Id,core_cpq_distributor__c,core_cpq_quote__c FROM core_cpq_disty_visibility__c WHERE core_cpq_quote__c IN: quoteIdSet]){
                    if(quoteIdToDistyAccountIdToShareMap.containsKey(distyVisibility.core_cpq_quote__c)) {
                        quoteIdToDistyAccountIdToShareMap.get(distyVisibility.core_cpq_quote__c).add(distyVisibility.core_cpq_distributor__c);
                    } else {
                        quoteIdToDistyAccountIdToShareMap.put(distyVisibility.core_cpq_quote__c, new Set<Id>{distyVisibility.core_cpq_distributor__c});
                    }
                    accountIdSet.add(distyVisibility.core_cpq_distributor__c);
                }
            }
            if(!accountIdSet.isEmpty()){
                shareWithDistyUser(dpa_alnList,accountIdSet,quoteIdToDistyAccountIdToShareMap);
            }
            if(!idToNewGroupMap.isEmpty()){
            	PSG_QuoteBusinessLogic.shareUnshareWithDisty(null,idToNewGroupMap,'DPA/ALN');
            }
        }
    }
    
    /************************************************************************************************************
    *Method Name : shareWithDistyUser
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Method gives DPA/ALN record access for the disty users.
    ************************************************************************************************************/
    public static void shareWithDistyUser(List<core_cpq_dpa_aln__c> dpa_alnList, set<Id> accountIdSet, Map<String,Set<Id>> quoteIdToDistyAccountIdToShareMap){
        if(dpa_alnList != null && !dpa_alnList.isEmpty()){
            try{
                Map<String,Set<Id>> distyAccountToUserIdMap = new Map<String,Set<Id>>();
                List<core_cpq_dpa_aln__share> dpaAlnShareList = new List<core_cpq_dpa_aln__share>();
                
                if(!accountIdSet.isEmpty()){
                    for(user distyUser : [SELECT Id,accountId,Contact.accountId FROM User WHERE accountId IN: accountIdSet and IsActive = true]){
                        if(distyAccountToUserIdMap.containsKey(distyUser.accountId)) {
                            distyAccountToUserIdMap.get(distyUser.accountId).add(distyUser.Id);
                        } else {
                            distyAccountToUserIdMap.put(distyUser.accountId, new Set<Id>{distyUser.Id});
                        }
                    }
                    
                    /*for(core_cpq_dpa_aln__c dpaObj : dpa_alnList){
                        if(distyAccountToUserIdMap.containsKey(dpaObj.core_cpq_quote_distributor__c)){
                            for(Id userId :distyAccountToUserIdMap.get(dpaObj.core_cpq_quote_distributor__c)){
                                if(dpaObj.ownerId != userId){
                                    dpaAlnShareList.add(new core_cpq_dpa_aln__share(ParentId = dpaObj.id,
                                                                                    UserOrGroupId = userId ,
                                                                                    AccessLevel = 'Read',
                                                                                    RowCause = Schema.core_cpq_dpa_aln__share.RowCause.Manual));
                                }                                          
                            }
                        }
                    }*/
                    
                    for(core_cpq_dpa_aln__c dpaObj : dpa_alnList){
                        if(quoteIdToDistyAccountIdToShareMap.containsKey(dpaObj.core_cpq_active_quote__c)){
                            for(Id distyAccToShare :quoteIdToDistyAccountIdToShareMap.get(dpaObj.core_cpq_active_quote__c)){
                                if(distyAccountToUserIdMap.containsKey(distyAccToShare)){
                                    for(Id userId :distyAccountToUserIdMap.get(distyAccToShare)){
                                        if(dpaObj.ownerId != userId){
                                            dpaAlnShareList.add(new core_cpq_dpa_aln__share(ParentId = dpaObj.id,
                                                                                            UserOrGroupId = userId ,
                                                                                            AccessLevel = 'Read',
                                                                                            RowCause = Schema.core_cpq_dpa_aln__share.RowCause.Manual));
                                        }                                          
                                    }
                                }
                            }
                        }
                    }
                    if(!dpaAlnShareList.isEmpty()){
                        Insert as system dpaAlnShareList;  
                    }
                }
            }catch(Exception ex){
                PSG_Utility.logError(ex);
            }
        }
    }
}