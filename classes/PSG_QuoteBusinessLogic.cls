/****************************************************************************************************
Apex Class Name : PSG_QuoteBusinessLogic
Version         : 1.0 
Created Date    : 11/27/2020
Function        : This class is used used as part of Quote trigger for all the PSG functionalities
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Avani                     11/27/2020               Created
*****************************************************************************************************/
public without sharing class PSG_QuoteBusinessLogic{
    public static Map<String, String> mtdtQueueMap = new Map <String, String>(); 
    public static Map<String, String> mtdtECkeyToNameMap = new Map <String, String>();  
    public static Map<String, String> mtdtdistykeyToNameMap = new Map <String, String>();  
    public static Map<String, List<String>> mtdtGeoToOwnerpriorFieldMap = new Map <String, List<String>>();
    public static Map<String, Boolean> sendEmailToQueueMap = new Map<String,Boolean>();
    public static Map<String, core_cpq_bm_assignment_config__c> bmApproverMap = new Map<String, core_cpq_bm_assignment_config__c>();
    public static Map<String,Set<String>> revisionTriggerQLFieldMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> updationFieldQLMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> revisionFieldsQLMap = new Map<String,Set<String>>();
    Public static Set<String> permissionSetsNameSet = new Set<String>{Label.PSG_Quote_SOS_PermissionSet,Label.PSG_Quote_BO_PermissionSet,Label.PSG_Quote_BM_PermissionSet,Label.PSG_PermissionSets_PSG_Distributor};
    public static Map<String,Set<String>> revisionTriggerPridFieldMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> updationFieldPridMap = new Map<String,Set<String>>();
    public static Map<String,Set<String>> revisionFieldsPridMap = new Map<String,Set<String>>();
    //Hari Optimization
    public static Map<String, Id> sosQueueMap = new Map<String, Id>();  
    public static Map<String,String> distyToGroupMap=new Map<String,String>();
    public static Map<String, Id> quotePricebookMap = new Map<String, Id>(); 
    public static OrgWideEmailAddress orgWideEmailAdd;
    public static Map<Id,Set<Id>> delegateUserMap1 = new Map<Id,Set<Id>>();
    Public static List<string> AccountTierList = Label.PSG_Account_Tier_label.split(';');
    static{ 
    	//Hari Optimization
        orgWideEmailAdd = [SELECT Id, Address, DisplayName from OrgWideEmailAddress where Address='wsm-postmaster@intel.com' LIMIT 1];
        for(core_user_delegation__c delegate:[SELECT id,core_cpq_delegated_For__c, core_cpq_delegated_to__c,core_cpq_IsActive__c from core_user_delegation__c WHERE core_cpq_IsActive__c=true LIMIT :Limits.getLimitDmlRows()]){
            if(delegateUserMap1.containsKey(delegate.core_cpq_delegated_For__c)){
                delegateUserMap1.get(delegate.core_cpq_delegated_For__c).add(delegate.core_cpq_delegated_to__c);
            }else{
                delegateUserMap1.put(delegate.core_cpq_delegated_For__c,new set<Id>{delegate.core_cpq_delegated_to__c});
            }
        } 
        for(PSG_Queue_Owner_Mapping__mdt queueRec: [SELECT Id, DeveloperName, PSG_Disti_GEO__c, PSG_Account_Country__c, PSG_Account_Name__c, PSG_Quote_Type__c, PSG_send_email__c,
                                                    PSG_Account_State__c, PSG_SOS_Queue_Name__c, PSG_EC_keyword__c,PSG_Disty_Name__c,PSG_Disty_Keyword__c FROM PSG_Queue_Owner_Mapping__mdt WHERE PSG_Active__c = true LIMIT :Limits.getLimitDmlRows()] ){
                                                        
            String geoStr =  queueRec.PSG_Disti_GEO__c;
            if(geoStr == null){geoStr ='';} 
           // List<String> geoList = geoStr.split(',');
            
            String countryStr =  queueRec.PSG_Account_Country__c;
            if(countryStr == null){countryStr ='';} 
            List<String> countryList = countryStr.split(',');
            
            String stateStr =  queueRec.PSG_Account_State__c;
            if(stateStr == null){stateStr ='';}                                            
            List<String> stateList = stateStr.split(',');
            
            String accStr =  queueRec.PSG_Account_Name__c;                 
            if(accStr == null){accStr ='';}                                          
            List<String> accList = accStr.split(',');
                                                       
            String disStr =  queueRec.PSG_Disty_Name__c;                 
            if(disStr == null){disStr ='';}                                          
            List<String> distyList = disStr.split(',');
            
            String quoteType = queueRec.PSG_Quote_Type__c;
            quoteType = String.isBlank(quoteType)?'':queueRec.PSG_Quote_Type__c;
                                                        
            String ecKeyword= queueRec.PSG_EC_keyword__c;
            if(ecKeyword != null){
                List<String> ecKeyWordList = ecKeyword.split(',');
                for(String kw:ecKeyWordList){
                    mtdtECkeyToNameMap.put(kw.replace('__',' '),accList[0]);
                }
            } 
            
            String distyKeyword= queueRec.PSG_Disty_Keyword__c;
            if(distyKeyword != null){
                List<String> distyKeyWordList = distyKeyword.split(',');
                for(String kw:distyKeyWordList){
                    mtdtdistykeyToNameMap.put(kw.replace('__',' '),distyList[0]);
                }
            } 
            
            
            for(String country: countryList){
                for(String state: stateList){
                    for(String acc: accList){
                        for(String disty: distyList){
                            String uniqueStr = geoStr.trim()  +country.trim()  +state.trim() + acc.trim()+disty.trim() +quoteType.trim();  
                            uniqueStr = uniqueStr.trim();                            
                            mtdtQueueMap.put(uniqueStr, queueRec.PSG_SOS_Queue_Name__c);
                        }
                    }
                }
            } 
            
            if(queueRec.PSG_send_email__c == true){
                sendEmailToQueueMap.put(queueRec.PSG_SOS_Queue_Name__c, queueRec.PSG_send_email__c);
            }                                         
        }           

        for(PSG_Geo_Based_Owner_Mapping_Priority__mdt priorRec : [Select Id,PSG_Geo__c,PSG_Fields_to_check__c,PSG_Priority__c from PSG_Geo_Based_Owner_Mapping_Priority__mdt where PSG_Active__c= true order by PSG_Priority__c asc]){
            if(mtdtGeoToOwnerpriorFieldMap.containsKey(priorRec.PSG_Geo__c)){
                mtdtGeoToOwnerpriorFieldMap.get(priorRec.PSG_Geo__c).add(priorRec.PSG_Fields_to_check__c);
            }else{
                mtdtGeoToOwnerpriorFieldMap.put(priorRec.PSG_Geo__c,new List<String>{priorRec.PSG_Fields_to_check__c});
            }
        }
        for(PSG_PRID_Mapping__mdt pridRec :[SELECT Id,PSG_PRID_Type__c,psg_revision_trigger_field_prid__c,psg_cpq_revision_trigger_field_ql__c,
                                            core_cpq_updation_trigger_field_prid__c,psg_updation_trigger_field_ql__c,psg_revision_fields_QL__c,
                                            psg_revision_fields_prid__c from PSG_PRID_Mapping__mdt where PSG_Active__c = true LIMIT :Limits.getLimitDmlRows()]){
            if(String.isNotBlank(pridRec.psg_cpq_revision_trigger_field_ql__c)){
                revisionTriggerQLFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_cpq_revision_trigger_field_ql__c).split(':')));   
            }else{
                revisionTriggerQLFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>());
            }
            if(String.isNotBlank(pridRec.psg_updation_trigger_field_ql__c)){
                updationFieldQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_updation_trigger_field_ql__c).split(':')));
            }else{
                updationFieldQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>());
            } 
            if(String.isNotBlank(pridRec.psg_revision_fields_QL__c)){
                revisionFieldsQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_revision_fields_QL__c).split(':')));
            }else{
                revisionFieldsQLMap.put(pridRec.PSG_PRID_Type__c,new Set<String>());
            } 
            if(String.isNotBlank(pridRec.psg_revision_trigger_field_prid__c)){
                revisionTriggerPridFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_revision_trigger_field_prid__c).split(':'))); 
            }else{
                revisionTriggerPridFieldMap.put(pridRec.PSG_PRID_Type__c,new Set<String>()); 
            }  
            if(String.isNotBlank(pridRec.core_cpq_updation_trigger_field_prid__c)){
                updationFieldPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.core_cpq_updation_trigger_field_prid__c).split(':'))); 
            }else{
                updationFieldPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>()); 
            }  
            if(String.isNotBlank(pridRec.psg_revision_fields_prid__c)){
                revisionFieldsPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>((pridRec.psg_revision_fields_prid__c).split(':'))); 
            }else{
                revisionFieldsPridMap.put(pridRec.PSG_PRID_Type__c,new Set<String>()); 
            } 
        }
	//Hari Optimization
        for(Group sosQueue: [SELECT Id, name, DeveloperName FROM Group WHERE type = 'Queue' AND DeveloperName like 'psg__%' LIMIT :Limits.getLimitDmlRows()]){
            sosQueueMap.put(sosQueue.name,sosQueue.Id);
        }
        for(Core_MDF_Partner_Group_Mapping__c grpMapRec: [SELECT Id, Core_MDF_Account__c, Core_MDF_Group_Name__c FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Channel_Program__r.Name='PSG Distributor']){
            distyToGroupMap.put(grpMapRec.Core_MDF_Account__c,grpMapRec.Core_MDF_Group_Name__c);
        }
        for(core_cpq_bm_assignment_config__c approverRec: [SELECT id, name, core_cpq_end_customer_parent__c , core_cpq_business_unit_nm__c, core_cpq_account_tier_nm__c, core_cpq_end_customer_parent__r.Parent.Core_Geo__c,
                                                           core_cpq_end_customer_parent__r.Parent.Core_Sub_Geo__c, core_cpq_asmo_txt__c, core_cpq_emea_txt__c, core_cpq_apj_prc_txt__c, core_cpq_japan_txt__c 
                                                           FROM core_cpq_bm_assignment_config__c LIMIT :Limits.getLimitDmlRows()] ){
            
            String ecp = approverRec.core_cpq_end_customer_parent__c; 
            String bUnit = approverRec.core_cpq_business_unit_nm__c;
            String accTier = approverRec.core_cpq_account_tier_nm__c;
            
            String uniqueApprStr = '';
            uniqueApprStr = (String.isBlank(ecp)?'':ecp.trim()) +(String.isBlank(bUnit)?'':bUnit.trim()) +(String.isBlank(accTier)?'':accTier.trim());
            
            if(ecp != null){
                uniqueApprStr = ecp;
                bmApproverMap.put(uniqueApprStr,approverRec);
            }else{
                uniqueApprStr = (String.isBlank(bUnit)?'':bUnit.trim()) + (String.isBlank(accTier)?'':accTier.trim());
                uniqueApprStr = uniqueApprStr.trim();
                bmApproverMap.put(uniqueApprStr,approverRec);
            }
        }
        for(Pricebook2 pbRec: [SELECT Id, Name FROM Pricebook2]){
            quotePricebookMap.put(pbRec.Name, pbRec.Id);
        }
    }
    
    /************************************************************************************************************
    *Method Name : beforeInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Vijay
    *Description : Performs operations on before context of trigger.
    ************************************************************************************************************/
    public static void beforeInsertUpdateOperations(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap,Boolean isInsert){
        if(quoteList != null && !quoteList.isEmpty()){   
	//Hari Optimization
                Boolean isUpdate = !isInsert;
                Id inActiveRecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c','PSG_Quote_Inactive_Quotes');
                Id submittedRecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c','PSG_Quote_Submitted');
                Id readOnlyRecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c','PSG_Quote_ReadOnly');
                Id inApprovedRecordTypeId = PSG_Utility.getRecordTypeId('SBQQ__Quote__c','PSG_Quote_Approved');
                Set<Id> assignedToSet = new Set<Id>();
                Set<Id> accSet = new Set<Id>();
                Map<Id,Account> accountMap = new Map<Id,Account>();
                Set<String> internalUsersSet = new Set<String>{'SOS','BM','BO'};
                Map<Id,String> userIdToRoleMap = new Map<Id,String>();
                Map<Id,Id> userIdToAccountIdMap = new Map<Id,Id>();       
                Map<Id,Id> userIdToPriceBookIdMap = new Map<Id,Id>();
		//Hari Optimization
                Set<Id> distyAccountIdSet = new Set<Id>();
                Set<Id> shareIdSet = new Set<Id>();
                //Set<Id> quoteEditCheckIdSet = new Set<Id>();
		//Hari Optimization
                if(isInsert){
                    Set<Id> opptyIdSetOnInsert = new Set<Id>();
                    Map<Id,Opportunity> oppIdToOppRecordMapOnInsert = new Map<Id,Opportunity>();
                    Set<Id> quoteOwnerIdSet = new Set<Id>();
                    for(SBQQ__Quote__c quote : quoteList){                        
                        if(quote.core_cpq_end_customer_nm__c != null){
                            quote.SBQQ__Account__c = quote.core_cpq_end_customer_nm__c;
                        }
			//Hari Optimization
                        if(quote.SBQQ__Type__c=='Renewal' || quote.SBQQ__Type__c=='Amendment'){
                            quote.core_cpq_end_customer_nm__c=quote.SBQQ__Account__c;
                            quote.RecordTypeId=submittedRecordTypeId;
                            quote.SBQQ__Status__c='In Progress';
                            quote.core_cpq_status_txt__c='In Progress';
                            quote.core_cpq_quote_type_nm__c='Tools';
                            quote.core_cpq_price_book_nm__c = quote.SBQQ__PricebookId__c;
                        }
			//Hari Optimization
                        quote.core_cpq_quote_expiry_dt__c = Date.today().addYears(3);
                        if(quote.SBQQ__Status__c != null){
                            quote.core_cpq_status_txt__c = quote.SBQQ__Status__c;
                        }else if(quote.core_cpq_status_txt__c != null){
                            quote.SBQQ__Status__c = quote.core_cpq_status_txt__c;
                        }
                        if(quote.SBQQ__Distributor__c != null){
                            accSet.add(quote.SBQQ__Distributor__c);
                        }

                        if(quote.core_cpq_sap_ecp_nm__c != null){
                            accSet.add(quote.core_cpq_sap_ecp_nm__c);
                        }
                        /* Not Needed - Hari
                        if(quote.core_cpq_end_customer_nm__r.Core_Direct_Pricing_Parent_Id__c != null){
                            accSet.add(quote.core_cpq_end_customer_nm__r.Core_Direct_Pricing_Parent_Id__c);
                        }*/
                        
                        if(quote.core_cpq_cm_name_nm__c!= null){
                            accSet.add(quote.core_cpq_cm_name_nm__c);
                        }     
			//Hari Optimization                  
                        if(!quote.core_cpq_active_cb__c){
                            quote.RecordTypeId = inActiveRecordTypeId;
                        }
                        /* Not Needed - Hari
                        if(quote.core_cpq_assigned_to_nm__c != null){
                            assignedToSet.add(quote.core_cpq_assigned_to_nm__c);
                        }*/
                        if(quote.SBQQ__Opportunity2__c != null){
                            opptyIdSetOnInsert.add(quote.SBQQ__Opportunity2__c);
                        } 
                        if(quote.core_cpq_end_customer_nm__c !=null){
                            accSet.add(quote.core_cpq_end_customer_nm__c);
                        }  
                        if(quote.ownerId != null){
                            quoteOwnerIdSet.add(quote.ownerId);
                        }
			//Hari Optimization
                    }
                    assignedToSet.add(userInfo.getUserId());
                    if(!assignedToSet.isEmpty()){
                        for(PermissionSetAssignment psa : [SELECT Id,AssigneeId,PermissionSet.Name,PermissionSet.Profile.Name,Assignee.Contact.AccountId,Assignee.Contact.Account.Core_Geo__c
                                                           FROM PermissionSetAssignment WHERE AssigneeId IN: assignedToSet AND 
                                                           (PermissionSet.Name =: Label.PSG_Quote_SOS_PermissionSet OR 
                                                            PermissionSet.Name =: Label.PSG_Quote_BO_PermissionSet OR 
                                                            PermissionSet.Name =: Label.PSG_Quote_BM_PermissionSet OR 
                                                            PermissionSet.Name =: Label.PSG_PermissionSets_PSG_Distributor OR
                                                            PermissionSet.ProfileId =: Userinfo.getProfileId()) LIMIT :Limits.getLimitDmlRows()]){
                                                                
                                                                
                            if(psa.PermissionSet.Name == Label.PSG_PermissionSets_PSG_Distributor){
                                userIdToRoleMap.put(psa.AssigneeId,'Disty');
                                userIdToAccountIdMap.put(psa.AssigneeId,psa.Assignee.Contact.AccountId);
                                if(psa?.Assignee?.Contact?.AccountId != null){
                                    accSet.add(psa.Assignee.Contact.AccountId);
                                }
                                /*if(psa.Assignee.Contact.Account.Core_Geo__c != null && quotePricebookMap.containsKey(psa.Assignee.Contact.Account.Core_Geo__c)){
                                    userIdToPriceBookIdMap.put(psa.AssigneeId,quotePricebookMap.get(psa.Assignee.Contact.Account.Core_Geo__c));  
                                }*/
                            }                                                               
                            if(psa.PermissionSet.Name == Label.PSG_Quote_SOS_PermissionSet){
                                userIdToRoleMap.put(psa.AssigneeId,'SOS');
                            }else if(psa.PermissionSet.Name == Label.PSG_Quote_BM_PermissionSet){
                                userIdToRoleMap.put(psa.AssigneeId,'BM');
                            }else if(psa.PermissionSet.Name == Label.PSG_Quote_BO_PermissionSet){
                                userIdToRoleMap.put(psa.AssigneeId,'BO');
                            }
                        }
                    }
                    if(!accSet.isEmpty()){ 
                        accountMap =  new Map<Id,Account>([SELECT Id,Core_Direct_Pricing_Parent_Id__r.Core_Sub_Geo__c,Core_Direct_Pricing_Parent_Id__r.Core_Direct_Parent_Account_Tier_Nm__c,
                                                           Core_Direct_Pricing_Parent_Id__r.Core_Geo__c,Core_Partner_Alliance_Program__c,
                                                           Core_Direct_Pricing_Parent_Id__c,Core_Account_Tier__c,Name,Core_Geo__c,
                                                           Core_Sub_Geo__c, tolabel(BillingCountryCode) from Account where Id IN : accSet]);  
                    }
                    if(!opptyIdSetOnInsert.isEmpty()){
                        oppIdToOppRecordMapOnInsert = new Map<Id,Opportunity>([SELECT Core_Product_Application__c, Core_Product_Segment__c, 
                                                                               Core_Volume__c,CloseDate, Core_First_Customer_Ship_Date__c, 
                                                                               Core_Production_End_Date__c ,Core_Opportunity_Owner_Geo__c FROM Opportunity WHERE Id IN: 
                                                                               opptyIdSetOnInsert]);
                    }   
                    Map<Id,String> ownerIdToNameMap = new Map<Id,String>();
                    if(!quoteOwnerIdSet.isEmpty()){
                        for(User userRec : [SELECT Id,name from User where Id IN: quoteOwnerIdSet]){
                            ownerIdToNameMap.put(userRec.Id,userRec.name);
                        }
                    }
			//Hari Optimization
                    for(SBQQ__Quote__c quote : quoteList){
                        String EndCustomerGeo = '';
                        String EndCustomerSubGeo = '';
                        String ecpId = ''; 
                        if(accountMap.containsKey(quote.core_cpq_end_customer_nm__c)){
                            quote.core_cpq_sap_ecp_nm__c = AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Direct_Pricing_Parent_Id__c;
                            quote.core_cpq_end_customer_list_view__c=accountMap.get(quote.core_cpq_end_customer_nm__c).name;
                            String tierValue = accountMap.get(quote.core_cpq_end_customer_nm__c).Core_Account_Tier__c;
                            quote.core_cpq_account_tier__c =null;
                                if(String.isNotBlank(tierValue)){ 
                                    for(String tierval:AccountTierList){
                                        if(tierValue.containsIgnoreCase(tierval)){
                                            quote.core_cpq_account_tier__c = tierval;
                                            break;
                                        }
                                    }
                                    
                                }
                            quote.core_cpq_account_program__c = accountMap.get(quote.core_cpq_end_customer_nm__c).Core_Partner_Alliance_Program__c;
                            
                             if(quote.core_cpq_cm_name_nm__c != null && accountMap.containsKey(quote.core_cpq_cm_name_nm__c)){
                                quote.core_cpq_cm_country__c = accountMap.get(quote.core_cpq_cm_name_nm__c).BillingCountrycode;
                            }
                            
                            if(quote.core_cpq_end_customer_nm__c != null && accountMap.containsKey(quote.core_cpq_end_customer_nm__c)){
                                quote.core_cpq_ec_country__c = accountMap.get(quote.core_cpq_end_customer_nm__c).BillingCountrycode;
                                //TWC3133-5964 Geo Change
                                quote.core_cpq_ec_region_txt__c = (AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c == 'INDIA') ? 'APJ' : accountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c; //Sayed
                            }
                            EndCustomerSubGeo = (AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Sub_Geo__c != null) ?AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Sub_Geo__c : '';
                            if(AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c != null){
                                EndCustomerGeo = (AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c == 'INDIA') ? 'APJ' :AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c;
                            
                            }
                            else{
                                EndCustomerGeo = '';
                            }
                            ecpId = (quote.core_cpq_sap_ecp_nm__c != null) ? ''+quote.core_cpq_sap_ecp_nm__c : '';
                        }
                        
                        if(userIdToRoleMap.containsKey(userInfo.getUserId()) && userIdToRoleMap.get(userInfo.getUserId()) == 'Disty'){
                            if(userIdToAccountIdMap.containsKey(userInfo.getUserId())){
                                quote.SBQQ__Distributor__c = userIdToAccountIdMap.get(userInfo.getUserId());
                                if(userIdToPriceBookIdMap.containsKey(userInfo.getUserId())){
                                    quote.SBQQ__PricebookId__c = userIdToPriceBookIdMap.get(userInfo.getUserId());
                                    quote.SBQQ__PriceBook__c = userIdToPriceBookIdMap.get(userInfo.getUserId());
                                    quote.core_cpq_price_book_nm__c = userIdToPriceBookIdMap.get(userInfo.getUserId());
                                }
                            }
                        }else if(userIdToRoleMap.containsKey(userInfo.getUserId()) 
                              && internalUsersSet.contains(userIdToRoleMap.get(userInfo.getUserId()))){
                            quote.SBQQ__Status__c = Label.PSG_Quote_Status_In_Progress;
                            quote.core_cpq_status_txt__c = Label.PSG_Quote_Status_In_Progress;
                            quote.RecordTypeId = submittedRecordTypeId;
                        }else{
                            quote.SBQQ__Status__c = Label.PSG_Quote_Status_In_Progress;
                            quote.core_cpq_status_txt__c = Label.PSG_Quote_Status_In_Progress;
                            quote.RecordTypeId = submittedRecordTypeId;                        
                        }
			//Hari Optimization
                        if((quote.SBQQ__Status__c == 'In Progress' || quote.SBQQ__Status__c == 'New') 
                            && quote.SBQQ__Distributor__c != null && ownerIdToNameMap.containsKey(quote.ownerId)){
                            quote.core_cpq_quote_owner_disty_txt__c = ownerIdToNameMap.get(quote.ownerId);
                        }
                        
                        if(quote.SBQQ__Distributor__c != null && distyToGroupMap.containsKey(quote.SBQQ__Distributor__c)){
                            quote.core_cpq_disty_group_name__c=distyToGroupMap.get(quote.SBQQ__Distributor__c);
                        }
                        if(quote.SBQQ__Opportunity2__c != null && oppIdToOppRecordMapOnInsert.containsKey(quote.SBQQ__Opportunity2__c)){
                            quote.core_cpq_product_segment_nm__c = oppIdToOppRecordMapOnInsert.get(quote.SBQQ__Opportunity2__c).Core_Product_Segment__c;
                            quote.core_cpq_product_application_nm__c = oppIdToOppRecordMapOnInsert.get(quote.SBQQ__Opportunity2__c).Core_Product_Application__c;
                            quote.core_cpq_volume_nbr__c = oppIdToOppRecordMapOnInsert.get(quote.SBQQ__Opportunity2__c).Core_Volume__c;
                            quote.core_cpq_decision_date_dt__c = oppIdToOppRecordMapOnInsert.get(quote.SBQQ__Opportunity2__c).CloseDate;
                            quote.core_cpq_first_ship_date_dt__c = oppIdToOppRecordMapOnInsert.get(quote.SBQQ__Opportunity2__c).Core_First_Customer_Ship_Date__c;
                            quote.core_cpq_production_end_date_dt__c = oppIdToOppRecordMapOnInsert.get(quote.SBQQ__Opportunity2__c).Core_Production_End_Date__c;
                            quote.core_cpq_opportunity_region__c = oppIdToOppRecordMapOnInsert.get(quote.SBQQ__Opportunity2__c).Core_Opportunity_Owner_Geo__c;
                        }
                        
			//Hari Optimization
                        //TWC3133-5964 Geo Change
                        String geo = '';
                        if(accountMap.containsKey(quote.SBQQ__Distributor__c) && accountMap.get(quote.SBQQ__Distributor__c).Core_Geo__c != null){
                            geo = (AccountMap.get(quote.SBQQ__Distributor__c).Core_Geo__c == 'INDIA')? 'APJ' : accountMap.get(quote.SBQQ__Distributor__c).Core_Geo__c;
                        }
                        else{
                            geo = '';
                        }                      
                        System.debug('dsdkds geo'+ geo);
                        String subGeo = accountMap.containsKey(quote.SBQQ__Distributor__c) ? accountMap.get(quote.SBQQ__Distributor__c).Core_Sub_Geo__c : '';
                        String distributorName = accountMap.containsKey(quote.SBQQ__Distributor__c) ? accountMap.get(quote.SBQQ__Distributor__c).name : '';                     
                        String state = (quote.core_cpq_end_customer_state_disty_txt__c != null) ? quote.core_cpq_end_customer_state_disty_txt__c : '';
                        String country = (quote.core_cpq_end_customer_country_disty_nm__c != null) ? quote.core_cpq_end_customer_country_disty_nm__c : '';
                        String endCustomerFromDisty = (quote.core_cpq_end_customer_disty_nm__c != null) ? quote.core_cpq_end_customer_disty_nm__c : '';
                        String endCustomer = endCustomerFromDisty.toLowerCase();
                        String uniqueString = '';
                        quote.core_cpq_disty_region__c = geo;
                        String name = distributorName.toLowerCase();
                        String ECName=''; 
                        String DistyName = '';
                        List<String> ecNameList=endCustomer.split(' ');
                        List<String> distyNameList=name.split(' ');
                        for(String kw : mtdtECkeyToNameMap.keySet()){
                            if(ecNameList.contains(kw)){
                            	ECName = mtdtECkeyToNameMap.get(kw);
                                break;
                            }
                        }
                        for(String kw : mtdtdistykeyToNameMap.keySet()){
                            if(distyNameList.contains(kw)){
                            	DistyName = mtdtdistykeyToNameMap.get(kw);
                                break;
                            }
                        }
                        Map<String,String> fieldTovalueMap=new Map<String,String>{ 'endcustomer' =>  ECName, 'distributor' => DistyName, 'country' => country, 'state' => state, 'geo' => geo, 'quotetype' => quote.core_cpq_quote_type_nm__c};
                        
                        if(String.isNotBlank(geo) && quotePricebookMap.containsKey(geo)){
                            String pbName=(geo=='APJ' && subGeo=='IJKK') ? 'JAPAN' : geo;
                            if(quotePricebookMap.containskey(pbName)){
                                quote.SBQQ__PricebookId__c       =   quotePricebookMap.get(pbName);
                                quote.SBQQ__PriceBook__c         =   quotePricebookMap.get(pbName);
                                quote.core_cpq_price_book_nm__c  =   quotePricebookMap.get(pbName);                                    
                            }
                        }
                        if(quote.SBQQ__Status__c != 'Draft' && userIdToRoleMap.containsKey(userInfo.getUserId()) && userIdToRoleMap.get(userInfo.getUserId()) == 'Disty'){
                            if(mtdtGeoToOwnerpriorFieldMap.containsKey(geo)){
                                for(String fieldString : mtdtGeoToOwnerpriorFieldMap.get(geo)){
                                    Boolean isOneFieldBlank=false;
                                	String UniqueString1='';
                                    for(String field : fieldString.split(';')){
                                        if(fieldTovalueMap.containsKey(field) && !String.isBlank(fieldTovalueMap.get(field))){
                                            UniqueString1=UniqueString1+fieldTovalueMap.get(field);
                                        }else{
                                            isOneFieldBlank=true;
                                            break;
                                        }                                        
                                    }
                                    if(!isOneFieldBlank && mtdtQueueMap.containsKey(UniqueString1)){
                                        if(sosQueueMap.containsKey(mtdtQueueMap.get(UniqueString1))){
                                            quote.ownerId = sosQueueMap.get(mtdtQueueMap.get(UniqueString1));
                                        }
                                        quote.core_cpq_quote_owner_disty_txt__c = mtdtQueueMap.get(UniqueString1);
                                        break;
                                    }
                            	}
                            }                          
                        }                       
                        
                        if(quote.core_cpq_quote_owner_disty_txt__c != null){
                            if(sendEmailToQueueMap.get(quote.core_cpq_quote_owner_disty_txt__c) == true){
                                quote.core_cpq_send_email__c = true;
                            }else{
                                quote.core_cpq_send_email__c = false;
                            }
                        }
                                
                        String businessUnit = (quote.core_cpq_business_unit_nm__c != null) ? (quote.core_cpq_business_unit_nm__c) : '';
                        String accountTier = (quote.core_cpq_account_tier__c != null) ? (quote.core_cpq_account_tier__c) : '';
                        String myStr = '';
                        String uniqueApproverString = '';
                        uniqueApproverString = (String.isBlank(ecpId)?'':ecpId.trim()) +(String.isBlank(businessUnit)?'':businessUnit.trim()) +(String.isBlank(accountTier)?'':accountTier.trim()); 
                                                
                        if(bmApproverMap.containsKey(ecpId)){
                            myStr = ecpId;
                        }
                        else{
                            myStr = (businessUnit + accountTier).trim();
                        }
                       
                        if(bmApproverMap.containsKey(myStr)){
                            switch on EndCustomerGeo{
                                when 'ASMO'{
                                    quote.core_cpq_first_bm_approver__c = bmApproverMap.get(myStr).core_cpq_asmo_txt__c;
                                }
                                
                                when 'EMEA'{
                                    quote.core_cpq_first_bm_approver__c = bmApproverMap.get(myStr).core_cpq_emea_txt__c;
                                }
                                when 'APJ', 'PRC'{
                                    quote.core_cpq_first_bm_approver__c = bmApproverMap.get(myStr).core_cpq_apj_prc_txt__c;
                                }
                            }
                            
                            if((EndCustomerGeo == 'PRC' || EndCustomerGeo == 'APJ') && EndCustomerSubGeo == 'IJKK'){
                                quote.core_cpq_first_bm_approver__c = bmApproverMap.get(myStr).core_cpq_japan_txt__c;
                            }
                        }

                        
                        if(quote.SBQQ__Status__c == Label.PSG_Quote_Status_In_Progress){
                            quote.RecordTypeId = submittedRecordTypeId;
                        }
                    }
                }
                
                if(isUpdate){          
                    Set<Id> opptyIdSet = new Set<Id>();
                    Map<Id,Opportunity> oppIdToOppRecordMap = new Map<Id,Opportunity>();
                    Map<String,core_cpq_product_details__c> uniqueProductDetailsMap = new Map<String,core_cpq_product_details__c>();
                    Set<String> prodSegmentSet = new Set<String>();
                    Set<String> prodApplicationSet = new Set<String>();
                    Set<Id> ultimateParentIdSet = new Set<Id>();
                    map<Id,String> quoteIdToOwnerIdMap = new map<id,String>();
                    List<SBQQ__Quote__c> activeQuoteList = new List<SBQQ__Quote__c>();
                    List<SBQQ__Quote__c> quoteListToUpdateAppLevel = new List<SBQQ__Quote__c>();
                    Set<Id> approvedQuoteIds=new Set<Id>();
		    //Hari Optimization
                    Set<Id> amendmentQuoteIdSet=new Set<Id>();
                    Map<Id,List<sbaa__Approval__c>> quoteIdToApprovalMap=new Map<Id,List<sbaa__Approval__c>>();
		    //Hari Optimization
                    Map<ID,SBQQ__Quote__c> mapOfQuoteIdAndDetails = new Map<ID,SBQQ__Quote__c>();
		    //Hari Optimization
                    /*for(SBQQ__Quote__c quoteRecord:[Select Id,SBQQ__Type__c, 
                                        SBQQ__MasterContract__r.SBQQ__Quote__r.SBQQ__Distributor__c ,
                                        core_cpq_original_quote__r.core_cpq_business_unit_nm__c,SBQQ__Distributor__c,
                                        SBQQ__MasterContract__r.SBQQ__Quote__r.core_cpq_business_unit_nm__c ,
                                        core_cpq_distributor_disty_view_nm__c,core_cpq_business_unit_nm__c,
                                        Sales_Renewed_from_Contract_Id__r.SBQQ__Quote__r.core_cpq_business_unit_nm__c,
                                        Sales_Renewed_from_Contract_Id__r.SBQQ__Quote__r.SBQQ__Distributor__c
                                        FROM SBQQ__Quote__c where id IN: quoteList and (SBQQ__Type__c ='Renewal' OR SBQQ__Type__c ='Amendment') LIMIT :Limits.getLimitDmlRows()]){
                                            mapOfQuoteIdAndDetails.put(quoteRecord.Id,quoteRecord);
                    }*/
                    
                    for(SBQQ__Quote__c quote : quoteList){ 
                    	if(oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && quote.ApprovalStatus__c == 'Approved'){
                            approvedQuoteIds.add(quote.Id);
                        }
                    }
                    
                    if(!approvedQuoteIds.isEmpty()){
                        for(sbaa__Approval__c approval : [Select Quote__c,sbaa__Status__c from sbaa__Approval__c where sbaa__Status__c = 'Requested' and Quote__c in : approvedQuoteIds]){
                            if(quoteIdToApprovalMap.containsKey(approval.Quote__c))
                                quoteIdToApprovalMap.get(approval.Quote__c).add(approval);
                            else
                                quoteIdToApprovalMap.put(approval.Quote__c,new List<sbaa__Approval__c> {approval} );
                        }
                    }
                    for(SBQQ__Quote__c quote : quoteList){  
		    //Hari Optimization
                        if(quote.SBQQ__Type__c == 'Amendment'){
                            amendmentQuoteIdSet.add(quote.Id);
                        }
                        
                        if(oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c){
                            quote.core_cpq_status_txt__c = quote.SBQQ__Status__c;
                        }
                        if(oldMap.get(quote.Id).core_cpq_end_customer_nm__c != quote.core_cpq_end_customer_nm__c || quote.core_cpq_end_customer_nm__c != null){
                            quote.SBQQ__Account__c = quote.core_cpq_end_customer_nm__c;
                            accSet.add(quote.core_cpq_end_customer_nm__c);
                        }
                         if(oldMap.get(quote.Id).core_cpq_cm_name_nm__c != quote.core_cpq_cm_name_nm__c || quote.core_cpq_cm_name_nm__c!= null){
                            
                            accSet.add(quote.core_cpq_cm_name_nm__c);
                        }
			//Hari Optimization
                        if(oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && quote.ApprovalStatus__c == 'Pending'){
                            quote.SBQQ__Status__c = 'In Review';
                            quote.core_cpq_status_txt__c = 'In Review';
                            quoteListToUpdateAppLevel.add(quote);
						}else if(oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && quote.ApprovalStatus__c == 'Approved'){
                            if(!quoteIdToApprovalMap.containsKey(quote.Id)){
                                quote.SBQQ__Status__c = 'Approved';
                            	quote.core_cpq_status_txt__c = 'Approved';
                            }else{
                                quote.ApprovalStatus__c=oldMap.get(quote.Id).ApprovalStatus__c;
                            }                            
                        }else if(oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && quote.ApprovalStatus__c == 'Rejected'){
                            quote.SBQQ__Status__c = 'Rejected';
                            quote.core_cpq_status_txt__c = 'Rejected';
                        }
                        
                        if(oldMap.get(quote.Id).ApprovalStatus__c != quote.ApprovalStatus__c && quote.ApprovalStatus__c == 'Recalled'){
                            quote.SBQQ__Status__c        = 'In Progress';
                            quote.core_cpq_status_txt__c = 'In Progress';
                            quote.core_cpq_Approval_Level_txt__c = '';
                        }
                        
                        if(oldMap.get(quote.Id).core_cpq_status_txt__c!= quote.core_cpq_status_txt__c && quote.core_cpq_status_txt__c =='In Review' && !quote.core_cpq_ready_for_submission__c){
                            quote.addError('Please click Edit Lines and check \'Ready for Submission\' in-order to submit the Quote for Approval');
                        }
                                                
                        if(quote.SBQQ__Distributor__c != null){
                            accSet.add(quote.SBQQ__Distributor__c);
                        }
                        
                        if(quote.core_cpq_sap_ecp_nm__c != null){
                            accSet.add(quote.core_cpq_sap_ecp_nm__c);
                        }
                        
                        if(oldMap.get(quote.Id).core_cpq_price_book_nm__c != quote.core_cpq_price_book_nm__c){
                            quote.SBQQ__PricebookId__c = quote.core_cpq_price_book_nm__c;
                            quote.SBQQ__PriceBook__c = quote.core_cpq_price_book_nm__c;
                        }
                        if(oldMap.get(quote.Id).core_cpq_assigned_to_nm__c != quote.core_cpq_assigned_to_nm__c && quote.core_cpq_assigned_to_nm__c != null){
                            assignedToSet.add(quote.core_cpq_assigned_to_nm__c);
                        }

                        if(oldMap.get(quote.Id).SBQQ__Opportunity2__c != quote.SBQQ__Opportunity2__c){
                            if(quote.SBQQ__Opportunity2__c != null){
                                opptyIdSet.add(quote.SBQQ__Opportunity2__c);
                            }else{
                                quote.core_cpq_product_segment_nm__c = null;     
                                quote.core_cpq_product_application_nm__c = null;
                                quote.core_cpq_volume_nbr__c = null;
                                quote.core_cpq_decision_date_dt__c = null;
                                quote.core_cpq_first_ship_date_dt__c = null;
                                quote.core_cpq_production_end_date_dt__c = null;
                                quote.core_cpq_segment_nm__c = null;
                                quote.core_cpq_opportunity_region__c=null;
                            }
                        }
                       
                        if((quote.core_cpq_status_txt__c != oldMap.get(quote.Id).core_cpq_status_txt__c 
                            && (quote.core_cpq_status_txt__c == 'New' || quote.core_cpq_status_txt__c == 'In Progress' )
                            && quote.SBQQ__Distributor__c != null) || (quote.core_cpq_end_customer_country_disty_nm__c 
                                                                       != oldMap.get(quote.Id).core_cpq_end_customer_country_disty_nm__c) ||
                            (quote.core_cpq_end_customer_state_disty_txt__c  != oldMap.get(quote.Id).core_cpq_end_customer_state_disty_txt__c)|| 
                            (quote.SBQQ__Distributor__c != oldMap.get(quote.Id).SBQQ__Distributor__c)||
                            (quote.core_cpq_end_customer_disty_nm__c  != oldMap.get(quote.Id).core_cpq_end_customer_disty_nm__c)){
                                distyAccountIdSet.add(quote.SBQQ__Distributor__c);
                        }

                        if((oldMap.get(quote.Id).core_cpq_active_cb__c != quote.core_cpq_active_cb__c) && quote.core_cpq_active_cb__c){
                            if(quote.core_cpq_ultimate_parent_quote__c != null){
                                ultimateParentIdSet.add(quote.core_cpq_ultimate_parent_quote__c);                           
                            }else{
                                ultimateParentIdSet.add(quote.id);
                            }                 
                        }
			//Hari Optimization
                        if((oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c) && quote.SBQQ__Status__c == Label.PSG_Quote_Status_Approved){
                            quote.RecordTypeId = inApprovedRecordTypeId;
                            quote.core_cpq_quote_approved_date_dt__c = System.today();
                            quote.core_cpq_approved_by_nm__c = userInfo.getUserId();
                        }
                        
                        //Added by Bishal Singh - TWC3133-4238
                        if((oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c) && quote.SBQQ__Status__c == 'Rejected'){
                            quote.core_cpq_quote_rejected_date__c = System.today();
                        }
                        //Added by Bishal Singh - TWC3133-4238
                        if((oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c) && oldMap.get(quote.Id).SBQQ__Status__c == 'Rejected' && oldMap.get(quote.Id).core_cpq_quote_rejected_date__c != null){
                            quote.core_cpq_quote_rejected_date__c = null;
                        }
						
                        if((oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c) && quote.SBQQ__Status__c == Label.PSG_Quote_Status_Cancelled){
                            quote.RecordTypeId = readOnlyRecordTypeId;
                            quote.core_cpq_active_cb__c = false;
                        }
                        if((oldMap.get(quote.Id).core_cpq_active_cb__c != quote.core_cpq_active_cb__c) && !quote.core_cpq_active_cb__c){
                            quote.RecordTypeId = inActiveRecordTypeId;
                        }
                    }

                    if(!accSet.isEmpty()){ 
                        accountMap =  new Map<Id,Account>([SELECT Id,Core_Partner_Alliance_Program__c,
                                                           Core_Account_Tier__c,Name,Core_Geo__c,Core_Sub_Geo__c,
                                                           Core_Direct_Pricing_Parent_Id__c,Core_Direct_Pricing_Parent_Id__r.Core_Direct_Parent_Account_Tier_Nm__c,
                                                           Core_Direct_Pricing_Parent_Id__r.Core_Sub_Geo__c,Core_Direct_Pricing_Parent_Id__r.Core_Geo__c, tolabel(BillingCountryCode)
                                                           from Account where Id IN : accSet]);  
                    }
                    assignedToSet.add(userInfo.getUserId());
                    if(!assignedToSet.isEmpty()){
                        for(PermissionSetAssignment psa : [SELECT Id,AssigneeId,PermissionSet.Name FROM PermissionSetAssignment
                                                           WHERE AssigneeId IN: assignedToSet AND 
                                                           PermissionSet.Name IN: permissionSetsNameSet LIMIT :Limits.getLimitDmlRows()]){
                                                                
                                                                
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
                        }
                    }
                    Set<Id> activeQuoteSet = new Set<Id>();
			//Hari Optimization
                    if(!ultimateParentIdSet.isEmpty() || !amendmentQuoteIdSet.isEmpty()){  
                        for(SBQQ__Quote__c quote : [SELECT Id,core_cpq_active_cb__c,Name,core_cpq_ultimate_parent_quote__c,
                                                    SBQQ__MasterContract__r.SBQQ__Quote__r.SBQQ__Distributor__c ,
                                                    SBQQ__MasterContract__r.SBQQ__Quote__r.core_cpq_business_unit_nm__c 
                                                    FROM SBQQ__Quote__c 
                                                    WHERE ((core_cpq_ultimate_parent_quote__c IN: ultimateParentIdSet) AND 
                                                    core_cpq_active_cb__c = true) OR Id IN :amendmentQuoteIdSet LIMIT :Limits.getLimitDmlRows()]){
                            if(amendmentQuoteIdSet.contains(quote.Id)){
                                 mapOfQuoteIdAndDetails.put(quote.Id,quote);
                            }
                            if(ultimateParentIdSet.contains(quote.core_cpq_ultimate_parent_quote__c) && quote.core_cpq_active_cb__c){
                            	activeQuoteSet.add(quote.core_cpq_ultimate_parent_quote__c);                   
                            }                         
                        }
                    }
                    if(!opptyIdSet.isEmpty()){
                        oppIdToOppRecordMap = new Map<Id,Opportunity>([SELECT Core_Product_Application__c, Core_Product_Segment__c, Core_Volume__c,CloseDate, Core_First_Customer_Ship_Date__c, Core_Production_End_Date__c,Core_Opportunity_Owner_Geo__c FROM Opportunity WHERE id IN: OpptyIdSet]);
                        for(Id oppId : oppIdToOppRecordMap.keySet()){
                            prodSegmentSet.add(oppIdToOppRecordMap.get(oppId).Core_Product_Segment__c);
                            prodApplicationSet.add(oppIdToOppRecordMap.get(oppId).Core_Product_Application__c);
                        }
                        
                    }
		    //Hari Optimization
                    
                    if(!prodSegmentSet.isEmpty() && !prodApplicationSet.isEmpty()){
                        for(core_cpq_product_details__c prodDetails : [SELECT core_cpq_segment_nm__c, core_cpq_business_unit_nm__c,core_cpq_product_segment_nm__c,
                                                                       core_cpq_product_application_nm__c from core_cpq_product_details__c WHERE (core_cpq_product_segment_nm__c 
                                                                                                                                                  IN: prodSegmentSet AND core_cpq_product_application_nm__c IN:prodApplicationSet) LIMIT :Limits.getLimitDmlRows()]){
                                                                                                                                                      uniqueProductDetailsMap.put(''+prodDetails.core_cpq_product_segment_nm__c + prodDetails.core_cpq_product_application_nm__c,prodDetails);
                                                                                                                                                  }
                    }
                   // Map<String,Id> approvertoUserMap = new Map<String,Id>();
                    for(SBQQ__Quote__c quote : quoteList) {
                        String EndCustomerGeo = '';
                        String EndCustomerSubGeo = '';
                        String ecpId = '';
			//Hari Optimization
                        if(mapOfQuoteIdAndDetails != null && quote.SBQQ__Type__c == 'Amendment' && mapOfQuoteIdAndDetails.containsKey(quote.Id) && mapOfQuoteIdAndDetails.get(quote.id).SBQQ__MasterContract__c != null){
                            quote.SBQQ__Distributor__c = mapOfQuoteIdAndDetails.get(quote.id).SBQQ__MasterContract__r?.SBQQ__Quote__r?.SBQQ__Distributor__c;
                            quote.core_cpq_business_unit_nm__c = mapOfQuoteIdAndDetails.get(quote.id).SBQQ__MasterContract__r?.SBQQ__Quote__r?.core_cpq_business_unit_nm__c;
                        }
                        if(oldMap.get(quote.Id).SBQQ__Distributor__c != quote.SBQQ__Distributor__c){
                            if(quote.SBQQ__Distributor__c != null && distyToGroupMap.containsKey(quote.SBQQ__Distributor__c))
                                quote.core_cpq_disty_group_name__c=distyToGroupMap.get(quote.SBQQ__Distributor__c);
                            else
                                quote.core_cpq_disty_group_name__c=null;
                        }
                        if(AccountMap.containsKey(quote.core_cpq_end_customer_nm__c)){
                            String tierValue = accountMap.get(quote.core_cpq_end_customer_nm__c).Core_Account_Tier__c;
                            quote.core_cpq_account_tier__c =null;
                            if(String.isNotBlank(tierValue)){
                                for(String tierval:AccountTierList){
                                    if(tierValue.containsIgnoreCase(tierval)){
                                        quote.core_cpq_account_tier__c = tierval;
                                        break;
                                    }
                                }
                            }
                            if(quote.SBQQ__Status__c!='Approved'){
                               quote.core_cpq_account_program__c = accountMap.get(quote.core_cpq_end_customer_nm__c).Core_Partner_Alliance_Program__c; 
                            }
                            
                            quote.core_cpq_end_customer_list_view__c=accountMap.get(quote.core_cpq_end_customer_nm__c).name;
                            if(quote.core_cpq_cm_name_nm__c != null && accountMap.containsKey(quote.core_cpq_cm_name_nm__c)){
                                quote.core_cpq_cm_country__c = accountMap.get(quote.core_cpq_cm_name_nm__c).BillingCountrycode;
                            }else if(quote.core_cpq_cm_name_nm__c == null){
                                quote.core_cpq_cm_country__c = '';
                            }
                          
                           if(quote.core_cpq_end_customer_nm__c != null && accountMap.containsKey(quote.core_cpq_end_customer_nm__c)){
                                quote.core_cpq_ec_country__c = accountMap.get(quote.core_cpq_end_customer_nm__c).BillingCountrycode;
                                //TWC3133-5964 Geo Change
                                quote.core_cpq_ec_region_txt__c = (AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c == 'INDIA') ? 'APJ' : accountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c;
                            }else if(quote.core_cpq_end_customer_nm__c == null){
                                quote.core_cpq_ec_country__c = '';
                                quote.core_cpq_ec_region_txt__c ='';
                            } 
                            if(quote.SBQQ__Status__c != 'Approved'){
                            	quote.core_cpq_sap_ecp_nm__c = AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Direct_Pricing_Parent_Id__c;
                                //TWC3133-5964 Geo Change
                                if(AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c != null){
                                EndCustomerGeo = (AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c == 'INDIA') ? 'APJ' :AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Geo__c;
                            
                            }
                            else{
                                EndCustomerGeo = '';
                            }
                            	EndCustomerSubGeo = (AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Sub_Geo__c != null) ?AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Sub_Geo__c : '';
                            	ecpId = (AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Direct_Pricing_Parent_Id__c != null) ? ''+(AccountMap.get(quote.core_cpq_end_customer_nm__c).Core_Direct_Pricing_Parent_Id__c) : '';
                            }
                        }
                        
                        //String ecpName = AccountMap.containsKey(quote.core_cpq_sap_ecp_nm__c) ? AccountMap.get(quote.core_cpq_sap_ecp_nm__c).Name : '';
                        String businessUnit = (quote.core_cpq_business_unit_nm__c != null) ? (quote.core_cpq_business_unit_nm__c) : '';                
                        String accountTier = (quote.core_cpq_account_tier__c != null) ? (quote.core_cpq_account_tier__c) : '';              
                        String uniqueApproverString = '';
                             
                        if(quote.core_cpq_sap_ecp_nm__c != oldmap.get(quote.Id).core_cpq_sap_ecp_nm__c ||
                            quote.core_cpq_account_tier__c != oldmap.get(quote.Id).core_cpq_account_tier__c ||
                            quote.core_cpq_business_unit_nm__c != oldmap.get(quote.Id).core_cpq_business_unit_nm__c ||
                            quote.core_cpq_end_customer_nm__c != oldmap.get(quote.Id).core_cpq_end_customer_nm__c){
                        
                            String myStr = '';
                            uniqueApproverString = (String.isBlank(ecpId)?'':ecpId.trim()) +(String.isBlank(businessUnit)?'':businessUnit.trim()) +(String.isBlank(accountTier)?'':accountTier.trim()); 
                                                    
                            if(bmApproverMap.containsKey(ecpId)){
                                myStr = ecpId;
                            }
                            else{
                                myStr = (businessUnit + accountTier).trim();
                            }
                                                     
                            if(bmApproverMap.containsKey(myStr)){
                                switch on EndCustomerGeo{
                                    when 'ASMO'{
                                        quote.core_cpq_first_bm_approver__c = bmApproverMap.get(myStr).core_cpq_asmo_txt__c;
                                    }
                                    
                                    when 'EMEA'{
                                        quote.core_cpq_first_bm_approver__c = bmApproverMap.get(myStr).core_cpq_emea_txt__c;
                                    }
                                    when 'APJ', 'PRC'{
                                        quote.core_cpq_first_bm_approver__c = bmApproverMap.get(myStr).core_cpq_apj_prc_txt__c;
                                    }
                                }
                                
                                if((EndCustomerGeo == 'PRC' || EndCustomerGeo == 'APJ') && EndCustomerSubGeo == 'IJKK'){
                                    quote.core_cpq_first_bm_approver__c = bmApproverMap.get(myStr).core_cpq_japan_txt__c;
                                }
                            }
                        }
                        //TWC3133-5964 Geo Change
                        String geo = '';
                        if(accountMap.containsKey(quote.SBQQ__Distributor__c) && accountMap.get(quote.SBQQ__Distributor__c).Core_Geo__c != null){
                            geo = (AccountMap.get(quote.SBQQ__Distributor__c).Core_Geo__c == 'INDIA')? 'APJ' : accountMap.get(quote.SBQQ__Distributor__c).Core_Geo__c;
                        }
                        else{
                            geo = '';
                        }                      
                        System.debug('dsdkds geo'+ geo);
                        String distributorName = accountMap.containsKey(quote.SBQQ__Distributor__c) ? accountMap.get(quote.SBQQ__Distributor__c).name : '';                     
                        String state = (quote.core_cpq_end_customer_state_disty_txt__c != null) ? quote.core_cpq_end_customer_state_disty_txt__c : '';
                        String country = (quote.core_cpq_end_customer_country_disty_nm__c != null) ? quote.core_cpq_end_customer_country_disty_nm__c : '';
                        String endCustomerFromDisti = (quote.core_cpq_end_customer_disty_nm__c != null) ? quote.core_cpq_end_customer_disty_nm__c : '';
                        String endCustomer = endCustomerFromDisti.toLowerCase();
                        String uniqueString = '';
                        quote.core_cpq_disty_region__c = geo;
                        String ArwMac = '';
                        String name = distributorName.toLowerCase();
                        String ECName='';
                        String DistyName = '';
                        List<String> ecNameList=endCustomer.split(' ');
                        List<String> distyNameList=name.split(' ');
                        for(String kw : mtdtECkeyToNameMap.keySet()){
                            if(ecNameList.contains(kw)){
                            	ECName = mtdtECkeyToNameMap.get(kw);
                                break;
                            }
                        }
                        for(String kw : mtdtdistykeyToNameMap.keySet()){
                            if(distyNameList.contains(kw)){
                            	DistyName = mtdtdistykeyToNameMap.get(kw);
                                break;
                            }
                        }
                        Map<String,String> fieldTovalueMap=new Map<String,String>{ 'endcustomer' =>  ECName, 'distributor' => DistyName, 'country' => country, 'state' => state, 'geo' => geo, 'quotetype' => quote.core_cpq_quote_type_nm__c};  
                        if(userIdToRoleMap.containsKey(userInfo.getUserId()) && userIdToRoleMap.get(userInfo.getUserId()) == 'Disty' 
                        && ((((quote.core_cpq_status_txt__c == 'New')) &&  quote.SBQQ__Distributor__c != null ) 
                        || quote.SBQQ__Distributor__c != oldMap.get(quote.Id).SBQQ__Distributor__c
                        || (quote.core_cpq_end_customer_country_disty_nm__c != oldMap.get(quote.Id).core_cpq_end_customer_country_disty_nm__c)
                        || (quote.core_cpq_end_customer_state_disty_txt__c  != oldMap.get(quote.Id).core_cpq_end_customer_state_disty_txt__c)
                        || (quote.core_cpq_end_customer_disty_nm__c  != oldMap.get(quote.Id).core_cpq_end_customer_disty_nm__c)
                        || (quote.core_cpq_quote_type_nm__c != oldMap.get(quote.Id).core_cpq_quote_type_nm__c)) && oldMap.get(quote.Id).SBQQ__Status__c!='Pending' ){
                            if(mtdtGeoToOwnerpriorFieldMap.containsKey(geo)){
                                for(String fieldString : mtdtGeoToOwnerpriorFieldMap.get(geo)){
                                	Boolean isOneFieldBlank=false;
                                	String UniqueString1='';
                                    for(String field : fieldString.split(';')){
                                        if(fieldTovalueMap.containsKey(field) && !String.isBlank(fieldTovalueMap.get(field))){
                                            UniqueString1=UniqueString1+fieldTovalueMap.get(field);
                                        }else{
                                            isOneFieldBlank=true;
                                            break;
                                        }                                        
                                    }
                                    if(!isOneFieldBlank && mtdtQueueMap.containsKey(UniqueString1)){
                                        if(sosQueueMap.containsKey(mtdtQueueMap.get(UniqueString1))){
                                            quote.ownerId = sosQueueMap.get(mtdtQueueMap.get(UniqueString1));
                                        }
                                        quote.core_cpq_quote_owner_disty_txt__c = mtdtQueueMap.get(UniqueString1);
                                        break;
                                    }
                            	}
                            }
                        
                            if(quote.core_cpq_quote_owner_disty_txt__c != null ){
                                if(sendEmailToQueueMap.get(quote.core_cpq_quote_owner_disty_txt__c) == true){
                                    quote.core_cpq_send_email__c = true;
                                }
                                else quote.core_cpq_send_email__c = false;
                            }    
                        } 
                        if(oldMap.get(quote.Id).SBQQ__Opportunity2__c != quote.SBQQ__Opportunity2__c && quote.SBQQ__Opportunity2__c != null && oppIdToOppRecordMap.containsKey(quote.SBQQ__Opportunity2__c)){
                            quote.core_cpq_product_segment_nm__c = oppIdToOppRecordMap.get(quote.SBQQ__Opportunity2__c).Core_Product_Segment__c;
                            quote.core_cpq_product_application_nm__c = oppIdToOppRecordMap.get(quote.SBQQ__Opportunity2__c).Core_Product_Application__c;
                            quote.core_cpq_volume_nbr__c = oppIdToOppRecordMap.get(quote.SBQQ__Opportunity2__c).Core_Volume__c;
                            quote.core_cpq_decision_date_dt__c = oppIdToOppRecordMap.get(quote.SBQQ__Opportunity2__c).CloseDate;
                            quote.core_cpq_first_ship_date_dt__c = oppIdToOppRecordMap.get(quote.SBQQ__Opportunity2__c).Core_First_Customer_Ship_Date__c;
                            quote.core_cpq_production_end_date_dt__c = oppIdToOppRecordMap.get(quote.SBQQ__Opportunity2__c).Core_Production_End_Date__c;
                            quote.core_cpq_opportunity_region__c = oppIdToOppRecordMap.get(quote.SBQQ__Opportunity2__c).Core_Opportunity_Owner_Geo__c;	
                            if(uniqueProductDetailsMap.containsKey(''+quote.core_cpq_product_segment_nm__c + quote.core_cpq_product_application_nm__c)){
                                quote.core_cpq_segment_nm__c = uniqueProductDetailsMap.get(''+quote.core_cpq_product_segment_nm__c + quote.core_cpq_product_application_nm__c).core_cpq_segment_nm__c;     
                                quote.core_cpq_business_unit_nm__c = uniqueProductDetailsMap.get(''+quote.core_cpq_product_segment_nm__c + quote.core_cpq_product_application_nm__c).core_cpq_business_unit_nm__c;
                            }
                        }
                        if(!Test.isRunningTest()){
                            if (Label.PSG_System_User != UserInfo.getUserId() && oldMap.get(quote.Id).core_cpq_status_txt__c != quote.core_cpq_status_txt__c && oldMap.get(quote.Id).core_cpq_status_txt__c!=null){
                                Map<String,String> statusCondMap = (Map<String,String>)JSON.deserialize(Label.PSG_QuoteStatusValidation, Map<String,String>.class);
                                if(statusCondMap.containsKey(oldMap.get(quote.Id).core_cpq_status_txt__c) && !statusCondMap.get(oldMap.get(quote.Id).core_cpq_status_txt__c).contains(quote.core_cpq_status_txt__c)){
                                    quote.addError('Quote Status cannot be changed to ' +quote.core_cpq_status_txt__c + ' from ' + oldMap.get(quote.Id).core_cpq_status_txt__c +'. Please reload the page');
                                }
                        	}
                        }
                        if(oldMap.get(quote.Id).core_cpq_assigned_to_nm__c != quote.core_cpq_assigned_to_nm__c && quote.core_cpq_assigned_to_nm__c != null){
                            quote.core_cpq_assigned_by_nm__c     = userInfo.getUserId();
                            quote.core_cpq_assigned_on__c =  System.now();
                            if(userIdToRoleMap.containsKey(quote.core_cpq_assigned_to_nm__c) && userIdToRoleMap.get(quote.core_cpq_assigned_to_nm__c) == 'SOS' ){
                                if(oldMap.get(quote.Id).SBQQ__Status__c ==Label.PSG_Quote_Status_Approved || oldMap.get(quote.Id).SBQQ__Status__c ==Label.PSG_Quote_Status_Rejected ){                           
                                    quote.SBQQ__Status__c = oldMap.get(quote.Id).SBQQ__Status__c;                           
                                }else{
                                    quote.SBQQ__Status__c = Label.PSG_Quote_Status_In_Progress;   
                                    quote.core_cpq_quote_owner_name__c = quote.core_cpq_assigned_to_nm__c;
                                }
                                quote.RecordTypeId = submittedRecordTypeId;
                            }else if(userIdToRoleMap.containsKey(quote.core_cpq_assigned_to_nm__c) && (userIdToRoleMap.get(quote.core_cpq_assigned_to_nm__c) == 'BO' || userIdToRoleMap.get(quote.core_cpq_assigned_to_nm__c) == 'BM')){
                                quote.SBQQ__Status__c = Label.PSG_Quote_Status_In_Review; 
                                quote.RecordTypeId = submittedRecordTypeId;
                            }
                        }
                        if((quote.SBQQ__Status__c == Label.PSG_Quote_Status_New) && userIdToRoleMap.containsKey(userInfo.getUserId()) && internalUsersSet.contains(userIdToRoleMap.get(userInfo.getUserId()))){
                            quote.SBQQ__Status__c = Label.PSG_Quote_Status_In_Progress;
                            quote.core_cpq_status_txt__c = Label.PSG_Quote_Status_In_Progress;
                            quote.core_cpq_quote_owner_name__c = UserInfo.getUserId();
                            quote.core_cpq_quote_owner_disty_txt__c = userInfo.getName();
                            quote.OwnerId = userInfo.getUserId();
                        }
                        if((oldMap.get(quote.Id).core_cpq_active_cb__c != quote.core_cpq_active_cb__c) && quote.core_cpq_active_cb__c){
                            if(quote.core_cpq_ultimate_parent_quote__c != null && activeQuoteSet.contains(quote.core_cpq_ultimate_parent_quote__c)){
                                quote.addError('Quote has already been revised and is active. Previous revisions of quote should not be reactivated in this case. Only latest revision should remain active');
                            }else if(activeQuoteSet.contains(quote.id)){
                                quote.addError('Quote has already been revised and is active. Previous revisions of quote should not be reactivated in this case. Only latest revision should remain active');
                            }
                            if(!activeQuoteSet.isEmpty() && activeQuoteSet.size() >0 ){
                                 quote.addError('Quote has already been revised and is active. Previous revisions of quote should not be reactivated in this case. Only latest revision should remain active');
                            }else{
                                quote.RecordTypeId = submittedRecordTypeId;
                            }                
                        }
                         if(quote.SBQQ__Status__c == Label.PSG_Quote_Status_In_Progress && quote.core_cpq_active_cb__c==true){
                            quote.RecordTypeId = submittedRecordTypeId;
                        }
                        
                    }
                   
                    if(!quoteListToUpdateAppLevel.isEmpty()){
                        calculateApprovalLevel(quoteListToUpdateAppLevel);
                    }
                }
        }
    }    
    
      /************************************************************************************************************
    *Method Name : afterInsertUpdateOperations
    *Created Date: 08/13/2021
    *Author: Vijay
    *Description : Performs operations on after context of trigger.
    ************************************************************************************************************/
    public static void afterInsertUpdateOperations(List<SBQQ__Quote__c> quoteList,Map<Id,SBQQ__Quote__c> oldMap,Boolean isInsert){
        if(quoteList != null && !quoteList.isEmpty()){
            try{
                if(isInsert){
                    Set<Id> opportunityIdSet = new Set<Id>();
                    Set<Id> quoteIdToDeleteSet = new Set<Id>();
                    Map<String,Set<Id>> optyIdToQuoteIdMap = new Map<String,Set<Id>>();
                    Map<String,String>idToNewGroupMap = new Map<String,String>();
                    for(SBQQ__Quote__c quote : quoteList){
                        if(quote.SBQQ__Opportunity2__c != null && quote.SBQQ__Type__c == 'Quote'){
                            opportunityIdSet.add(quote.SBQQ__Opportunity2__c);
                        
                        }
                        if(quote.core_cpq_disty_group_name__c != null){
                            idToNewGroupMap.put(quote.Id,quote.core_cpq_disty_group_name__c);
                        }
                    }
                    if(!opportunityIdSet.isEmpty()){
                        for(SBQQ__Quote__c quoteRec : [Select Id,SBQQ__Opportunity2__c FROM SBQQ__Quote__c where SBQQ__Type__c = 'Quote' AND SBQQ__Opportunity2__c IN :opportunityIdSet LIMIT :Limits.getLimitDmlRows()]){
                            if(optyIdToQuoteIdMap.containsKey(quoteRec.SBQQ__Opportunity2__c)){
                                optyIdToQuoteIdMap.get(quoteRec.SBQQ__Opportunity2__c).add(quoteRec.Id);
                            }else{
                                optyIdToQuoteIdMap.put(quoteRec.SBQQ__Opportunity2__c, new Set<Id>{quoteRec.Id});
                            }       
                        }
                    }
                    for(Id opptyId : opportunityIdSet){
                        if(optyIdToQuoteIdMap.containsKey(opptyId)){
                            Set<Id> quoteIdToIterate=optyIdToQuoteIdMap.get(opptyId);
                            if (quoteIdToIterate.size() == 1){
                                for(Id quoteId:quoteIdToIterate){
                                    quoteIdToDeleteSet.add(quoteId);
                                }   
                            }
                        }   
                    }   
                    if(!quoteIdToDeleteSet.isEmpty()){
                        List<SBQQ__QuoteLine__c> quoteLinesToDelete = [SELECT Id FROM SBQQ__QuoteLine__c
                                                                           WHERE SBQQ__Quote__c IN :quoteIdToDeleteSet ];
                        if(!quoteLinesToDelete.isEmpty()){
                            delete quoteLinesToDelete;
                        }
                    }
                    if(!idToNewGroupMap.isEmpty()){
                        shareUnshareWithDisty(null,idToNewGroupMap,'Quote');
                    }
                }else{
                    Set<Id> designWinDeactivatedQuoteSet = new Set<Id>();
                    List<SBQQ__Quote__c> quoteListToShare = new List<SBQQ__Quote__c>();
                    List<SBQQ__Quote__c> quoteListToShareOppty = new List<SBQQ__Quote__c>();
                    List<SBQQ__Quote__c> quoteListForPendingStatus = new List<SBQQ__Quote__c>();
                    List<SBQQ__Quote__c> quoteListForPendingToInProgressStatus = new List<SBQQ__Quote__c>();
                    List<SBQQ__Quote__c> quoteListForInReviewToInProgressStatus = new List<SBQQ__Quote__c>();
                    List<SBQQ__Quote__c> RejectedQuoteList = new List<SBQQ__Quote__c>();
                    Set<Id> previousOwnerIdSet = new Set<Id>();
                    Map<Id,Id> quotetoownerid=new Map<Id,Id>();
                    map<id,SBQQ__Quote__c> quoteMap = new map<id,SBQQ__Quote__c>();
                    set<Id> priceBookIdSet = new set<Id>();
                    List<SBQQ__Quote__c> approvedQuoteList = new List<SBQQ__Quote__c>();
                    Set<Id> quoteIdSetToUpdateDistiMargin = new Set<Id>();
                    Set<Id> cmfModQuoteIdSet=new Set<Id>();
                    Map<Id,SBQQ__Quote__c> newMap=new Map<Id,SBQQ__Quote__c>(quoteList);
                    List<SBQQ__QuoteLine__c> cmfModQlToUpdateList=new List<SBQQ__QuoteLine__c>();
                    Set<id> quoteIdSet = new Set<id>();
                    Set<id> quoteToUpdateDPAALNSet = new Set<Id>();
                    Set<Id> dwCPquoteIdSet = new Set<Id>();
                    Set<Id> quotewithOppIdSet = new set<Id>();
                	Map<String,String> quoteIdToNewStatusMap = new Map<String,String>();
                    Map<String,String> quoteIdToOldStatusMap = new Map<String,String>();
                    Map<String,String> newDWTOOldDWMap=new Map<String,String>();
                    Map<String,String>idToOldGroupMap = new Map<String,String>();
                    Map<String,String>idToNewGroupMap = new Map<String,String>();
                    for(SBQQ__Quote__c quote : quoteList){
                        quoteIdSet.add(quote.id);
                       if((oldMap.get(quote.Id).SBQQ__Distributor__c != quote.SBQQ__Distributor__c) 
                        || (oldMap.get(quote.Id).SBQQ__PriceBook__c != quote.SBQQ__PriceBook__c)
                        || (oldMap.get(quote.Id).core_cpq_end_customer_nm__c != quote.core_cpq_end_customer_nm__c)
                        || (oldMap.get(quote.Id).core_cpq_margin_geo_txt__c != quote.core_cpq_margin_geo_txt__c)){
                            quoteIdSetToUpdateDistiMargin.add(quote.Id);
                        }
                        if(oldMap.get(quote.Id).core_cpq_disty_group_name__c != quote.core_cpq_disty_group_name__c){
                            if(oldMap.get(quote.Id)?.core_cpq_disty_group_name__c != null)
                            	idToOldGroupMap.put(quote.Id,oldMap.get(quote.Id)?.core_cpq_disty_group_name__c);
                            if(quote.core_cpq_disty_group_name__c != null)
                            	idToNewGroupMap.put(quote.Id,quote.core_cpq_disty_group_name__c);
                        }
                        if(quote.core_cpq_active_cb__c != oldMap.get(quote.Id).core_cpq_active_cb__c && !quote.core_cpq_active_cb__c && quote.core_cpq_quote_type_nm__c != 'Contract Pricing'){
                            quoteToUpdateDPAALNSet.add(quote.Id);
                        }
                        if(quote.core_cpq_active_cb__c != oldMap.get(quote.Id).core_cpq_active_cb__c && !quote.core_cpq_active_cb__c && (quote.core_cpq_quote_type_nm__c == 'Contract Pricing' || quote.core_cpq_quote_type_nm__c == 'Design Win') ){
                            dwCPquoteIdSet.add(quote.Id);
                        }
                        if(quote.ownerId != oldMap.get(quote.Id).ownerId){
                            previousOwnerIdSet.add(oldMap.get(quote.Id).ownerId);
                            quotetoownerid.put(quote.id,oldMap.get(quote.Id).ownerId);
                        }                        
                        if((oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c) && quote.SBQQ__Status__c  == 'Pending'){
                            quoteListForPendingStatus.add(quote);
                        }
                        
                        if((oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c) && quote.SBQQ__Status__c  == 'In Progress' && oldMap.get(quote.Id).SBQQ__Status__c == 'Pending'){
                            quoteListForPendingToInProgressStatus.add(quote);
                        } 
                        if((oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c) && quote.SBQQ__Status__c  == 'In Progress' && oldMap.get(quote.Id).SBQQ__Status__c == 'In Review'){
                            quoteListForInReviewToInProgressStatus.add(quote);
                        }
                        
                        
                        if(oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c){
                            quoteIdToNewStatusMap.put(quote.Id,quote.SBQQ__Status__c);
                            quoteIdToOldStatusMap.put(quote.Id,oldMap.get(quote.Id).SBQQ__Status__c);
                        }
                        
                        if((oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c) && quote.SBQQ__Status__c  == 'Rejected'){
                            RejectedQuoteList.add(quote);
                        }
                        
                        if(oldMap.get(quote.Id).core_cpq_price_book_nm__c != quote.core_cpq_price_book_nm__c){
                            priceBookIdSet.add(quote.core_cpq_price_book_nm__c);
                            quoteMap.put(quote.id,quote);
                        }
                        if(oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c 
                        && quote.SBQQ__Status__c == 'Approved' && quote.core_cpq_quote_type_nm__c == 'Design Win'){
                            approvedQuoteList.add(quote);
                        }
                        if(oldMap.get(quote.Id).core_cpq_active_cb__c != quote.core_cpq_active_cb__c 
                        && !quote.core_cpq_active_cb__c && quote.core_cpq_quote_type_nm__c == 'Design Win'){
                            designWinDeactivatedQuoteSet.add(quote.Id);
                        }
                        if(oldMap.get(quote.Id).core_cpq_sap_ecp_nm__c != quote.core_cpq_sap_ecp_nm__c){
                            cmfModQuoteIdSet.add(quote.Id);
                        }
                                                
                        if(oldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c && quote.SBQQ__Status__c=='Approved'){
                            if(quote.SBQQ__Opportunity2__c!=null){
                                quotewithOppIdSet.add(quote.Id);
                            }
                            if(quote.core_cpq_revision_nbr__c>1 && quote.core_cpq_quote_type_nm__c == 'Design Win' && quote.core_cpq_active_cb__c==true ){
                                newDWTOOldDWMap.put(quote.core_cpq_original_quote__c,quote.id);
                            }                            
                        }
                    }
                    
                    
                    if(!quoteIdToNewStatusMap.isEmpty() || !quoteIdToOldStatusMap.isEmpty()){
                        PSG_QuoteHistoryTracking.createHistory(quoteIdToNewStatusMap,quoteIdToOldStatusMap);
                    }
                    
                    if(!dwCPquoteIdSet.isEmpty()){
                        for(SBQQ__QuoteLine__c ql : [Select Id,SBQQ__Quote__c,core_cpq_parent_quote__c,core_cpq_parent_quote__r.Name from SBQQ__QuoteLine__c where SBQQ__Quote__r.core_cpq_active_cb__c = true and SBQQ__Quote__r.core_cpq_quote_type_nm__c='Transfer Pricing' and core_cpq_parent_quote__c in :dwCPquoteIdSet]){
                            quoteToUpdateDPAALNSet.add(ql.core_cpq_parent_quote__c);
                        }                        
                    }
                    if(!cmfModQuoteIdSet.isEmpty()){
                        for(SBQQ__QuoteLine__c ql : [Select Id,core_cpq_sap_ecp_nm__c,core_cpq_PRID__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in :cmfModQuoteIdSet LIMIT :Limits.getLimitDmlRows()]){
                            if(ql.core_cpq_sap_ecp_nm__c != newMap.get(ql.SBQQ__Quote__c).core_cpq_sap_ecp_nm__c){
                                ql.core_cpq_sap_ecp_nm__c=newMap.get(ql.SBQQ__Quote__c).core_cpq_sap_ecp_nm__c;
                                ql.core_cpq_PRID__c=null;
                                ql.core_cpq_previous_PRID__c=null;
                                cmfModQlToUpdateList.add(ql);
                            }
                        }                         
                        if(!cmfModQlToUpdateList.isEmpty()){
                            PSG_Constants.isQuoteLineTriggerActive=false;
                            List<Database.SaveResult> updateResults = Database.update(cmfModQlToUpdateList,false);
                            processDMLResult('PSG_QuoteBusinessLogic', 'afterInsertUpdateOperations','Error while updating ECP on QLs on EC update on Quote','SBQQ__QuoteLine__c','High',updateResults,cmfModQlToUpdateList);
                            PSG_Constants.isQuoteLineTriggerActive=true;
                        }
                    }
                    if(!quoteIdSetToUpdateDistiMargin.isEmpty()){
                        PSG_QuoteLineBusinessLogic.updateDistiMarginValue = true;
                        List<SBQQ__Quoteline__c> quoteLineList = [SELECT Id,SBQQ__Quote__c,core_cpq_account_nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN : quoteIdSetToUpdateDistiMargin];
                        if(!quoteLineList.isEmpty()){
							for(SBQQ__Quoteline__c ql : quoteLineList){
								ql.core_cpq_account_nm__c=newMap.get(ql.SBQQ__Quote__c).core_cpq_end_customer_nm__c;
							}
							List<Database.SaveResult> updateResults = Database.update(quoteLineList,false);
                            processDMLResult('PSG_QuoteBusinessLogic', 'afterInsertUpdateOperations','Error while refreshing DM% on QLs','SBQQ__QuoteLine__c','Medium',updateResults,quoteLineList);
                        }
                    }
                    if(!quoteListForInReviewToInProgressStatus.isEmpty()){
                        List<SBQQ__Quoteline__c> quoteLineList = [SELECT Id, core_cpq_resale_guidance__c, core_cpq_design_win_convertible__c, core_cpq_disregarding_price_guidance__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN : quoteListForInReviewToInProgressStatus];
                        if(!quoteLineList.isEmpty()){
							for(SBQQ__Quoteline__c ql : quoteLineList){
								ql.core_cpq_resale_guidance__c = null;
                                ql.core_cpq_design_win_convertible__c = '';
                                ql.core_cpq_disregarding_price_guidance__c = '';
							}
							List<Database.SaveResult> updateResults = Database.update(quoteLineList,false);
                            processDMLResult('PSG_QuoteBusinessLogic', 'afterInsertUpdateOperations','Error while blanking AI Price Guidance attributes on QLs','SBQQ__QuoteLine__c','Medium',updateResults,quoteLineList);
                        }
                    }
                 
                    if(!approvedQuoteList.isEmpty()){
                        System.enqueueJob(new PSG_CreatePRIDQueueable(approvedQuoteList[0].Id));
                    }
                    if(quoteListForPendingStatus.Size() > 0){
                    	sendEmailNotification(quoteListForPendingStatus,'PSG_Pending_Status_Email_Template');
                    }
                    
                    //Change made for TWC3133-3982 - Bishal Singh
                    if(quoteListForPendingToInProgressStatus.Size() > 0){
                    	sendEmailNotification(quoteListForPendingToInProgressStatus,'PSG_Pending_to_In_Progress_Status_Notify');
                    }
                    Map<Id, SBQQ__Quote__c> RejectedQuoteListMap = new Map<Id, SBQQ__Quote__c>(RejectedQuoteList);
                    List<sbaa__Approval__c> approvalstatus = [Select Id, Name, sbaa__Status__c from sbaa__Approval__c where Quote__c in :RejectedQuoteListMap.keyset()];                   
                    if(approvalstatus.isEmpty() && RejectedQuoteList.Size() > 0){
                        sendEmailNotification(RejectedQuoteList,Label.PSG_Quote_Rejected_Notification);
                    }       
                    if(!quoteMap.isEmpty() && !priceBookIdSet.isEmpty()){
                        updateRelatedQuoteLines(quoteMap,priceBookIdSet);
                    }
                    
                    if(!quoteToUpdateDPAALNSet.isEmpty()){
                        PRIDBusinessLogic.updateUnderlyingDPAALN(quoteToUpdateDPAALNSet,false);
                    }
                    
                    if(!quotewithOppIdSet.isEmpty()){
                        Core_UpdateOptyRiskStatusFromQuote.updateAtRiskForPSGQuotes(quotewithOppIdSet);
                    }
                    
                  if(!newDWTOOldDWMap.isEmpty()){
                     PSG_CPQuoteBusinessLogic.ReplaceParentQuoteInTP(newDWTOOldDWMap); 
                  }
                    if(!idToOldGroupMap.isEmpty() || !idToNewGroupMap.isEmpty()){
                        shareUnshareWithDisty(idToOldGroupMap,idToNewGroupMap,'Quote');
                    }
                }
            }catch(Exception e){
                PSG_Utility.logError(e);
            } 
        }
    }
    
    /************************************************************************************************************
    *Method Name : processDMLResult
    *Created Date: 14/APR/2023
    *Author: Hari
    *Description : Process the DML result and logs the failures
    ************************************************************************************************************/
    public static void processDMLResult(String className,String methodName,String message,String objectName,String priority,List<Database.SaveResult> results,List<SObject> listToUpdate){
        List<SObject> failedList=new List<SObject>();
        for(Integer i=0;i<results.size();i++){
            if(!results[i].isSuccess()){
                failedList.add(listToUpdate[i]);
            }
        }
        String result='Records Failed => '+failedList+'\n\n DML Result : '+results;
        if(result.length() > 32768){
            result=result.subString(0,32768);
        }
        if(!failedList.isEmpty()){
            PSG_Utility.createCoreLogEntry(className,methodName,message, result,objectName,priority,'');
        }
    }
    
    /************************************************************************************************************
    *Method Name : sendEmailNotification
    *Created Date: 08/13/2021
    *Author: Vijay
    *Description : Sends email notification.
    ************************************************************************************************************/
    public static void sendEmailNotification(List<SBQQ__Quote__c> quoteList, String templateName){
        if(quoteList != null && !quoteList.isEmpty()){
            List<String> emails = new List<String>();
            Map<Id,Id> toUserId = new Map<Id,Id>();
            Set<id> ccUserIdSet = new Set<Id>();
            //Changes made for TWC3133- -Bishal Singh
			Map<String,List<String>> relatedValues = new Map<String,List<String>>();
            List<String> relatedToId = new List<String>();
            List<String> toId = new List<String>();
            List<String> subject = new List<String>(); 
			List<String> htmlBody = new List<String>();
            for(SBQQ__Quote__c qc0 : quoteList){
                if(qc0.core_cpq_requestor_nm__c != null){
                    toUserId.put(qc0.Id,qc0.core_cpq_requestor_nm__c);
                }
                relatedToId.add(qc0.Id);
                if(delegateUserMap1.containsKey(qc0.core_cpq_quote_owner_name__c)){
                    for(Id delegateId:delegateUserMap1.get(qc0.core_cpq_quote_owner_name__c)){
                        ccUserIdSet.add(delegateId);
                    }
                    ccUserIdSet.add(qc0.core_cpq_quote_owner_name__c);
                }else{
                    ccUserIdSet.add(qc0.core_cpq_quote_owner_name__c);
                }
            } 
            ccUserIdSet.add(UserInfo.getUserId());
            for(User us: [select id, name, Email from User where id =: ccUserIdSet]){
                emails.add(us.Email);
            }
            
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {};
            List<EmailTemplate> emailTemplateList = new List<EmailTemplate>([SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: templateName LIMIT 1]);
            
            if(!emailTemplateList.isEmpty() && !toUserId.isEmpty()){
                for(Id objId : toUserId.keySet()){       
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(toUserId.get(objId));
                    message.setWhatId(objId);
                    message.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
                    message.setUseSignature(false); 
                    message.setBccSender(false);  
                    message.setCcAddresses(emails);
                    message.setSaveAsActivity(false); 
                    message.setTemplateID(emailTemplateList[0].Id); 
                    messages.add(message);
                    //Changes made for TWC3133-4138 -Bishal Singh
                    toId.add(toUserId.get(objId));
                }
                if(!messages.isEmpty()){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    //Changes made for TWC3133-4138 -Bishal Singh
                    
                    for(String recordId : relatedToId){
                        Messaging.SingleEmailMessage getEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].Id, null, recordId);
                        subject.add(getEmail.getSubject());
                        htmlBody.add(getEmail.getHtmlBody());
                    }
                    //Changes made for TWC3133-4138 -Bishal Singh
                    relatedValues.put('relatedToId',relatedToId);
                    relatedValues.put('subject', subject);
                    relatedValues.put('htmlBody', htmlBody);
                    PSG_EmailMessageLog.createEmailMessageRecord(relatedValues,orgWideEmailAdd.Address,orgWideEmailAdd.DisplayName,toId,
                                                                 null,emails,null);
                    
                }
            }
        }
    }
    
    /*************************************************************************************************************************
    *Method Name : updateRelatedQuoteLines
    *Created Date: 26/03/2021
    *Author: usha
    *Description : Updates related quotelines.
    **************************************************************************************************************************/ 
    public static void updateRelatedQuoteLines(Map<Id,SBQQ__Quote__c> quoteMap, set<Id> priceBookIdSet){
        set<Id> priceBookentryIdSet = new set<Id>();
        Map<Id,list<core_cpq_list_price__c>> uniqueIdToListPriceMap = new map<Id,list<core_cpq_list_price__c>>();
        Map<String,PricebookEntry> uniqueIdToPriceBookEntryMap = new Map<String,PricebookEntry>();
        set<Id> productIdSet = new set<Id>();
        set<Id> quoteIdSet = new set<Id>();
        list<SBQQ__QuoteLine__c> quoteLineListToUpdate = new list<SBQQ__QuoteLine__c>();
        Map<String,PricebookEntry> priceBookKeyWithPriceBookEntriesMap = new Map<String,PricebookEntry>();  
        Boolean isUpdate = false;
        for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,SBQQ__Product__c,SBQQ__PricebookEntryId__c,core_cpq_multiple_qty_nbr__c,
            core_cpq_minimum_qty__c,SBQQ__Quote__c,price_disty_cost_nbr__c,SBQQ__ListPrice__c,SBQQ__Quantity__c FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c =: quoteMap.keySet() LIMIT :Limits.getLimitDmlRows()]){ 
                
            productIdSet.add(quoteLine.SBQQ__Product__c);
            quoteLineListToUpdate.add(quoteLine);               
        }
        if(!priceBookIdSet.isEmpty() && !productIdSet.isEmpty()){
            for(PricebookEntry pbe : [SELECT Id,UnitPrice,price_disty_cost__c ,core_cpq_minimum_order_qty__c,core_cpq_multiple_order_quantity__c,
                Product2Id ,Pricebook2Id FROM PricebookEntry WHERE IsActive = true and Product2Id IN: productIdSet and Pricebook2Id IN: 
                priceBookIdSet LIMIT :Limits.getLimitDmlRows()]){
                uniqueIdToPriceBookEntryMap.put(''+pbe.Pricebook2Id+pbe.Product2Id , pbe);
                priceBookentryIdSet.add(pbe.Id);
            }
        
            for(core_cpq_list_price__c lp : [select Id,Pricebookentry__c, core_cpq_lowerbound_qty__c, core_cpq_upperbound_qty__c, core_cpq_list_price_amt__c from       core_cpq_list_price__c  WHERE Pricebookentry__c =: priceBookentryIdSet LIMIT :Limits.getLimitDmlRows()]){
                if(uniqueIdToListPriceMap.containsKey(lp.Pricebookentry__c)){
                    uniqueIdToListPriceMap.get(lp.Pricebookentry__c).add(lp);
                }else{                                      
                    uniqueIdToListPriceMap.put(lp.Pricebookentry__c, new  List <core_cpq_list_price__c> { lp });
                }
            }
            
            for(SBQQ__QuoteLine__c quoteLine : quoteLineListToUpdate){
                if(uniqueIdToPriceBookEntryMap.containsKey(''+quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c  + quoteLine.SBQQ__Product__c)){
                    quoteLine.price_disty_cost_nbr__c = uniqueIdToPriceBookEntryMap.get(''+quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).price_disty_cost__c;
                    quoteLine.SBQQ__PricebookEntryId__c = uniqueIdToPriceBookEntryMap.get(''+quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).Id;                           
                    quoteLine.core_cpq_multiple_qty_nbr__c = uniqueIdToPriceBookEntryMap.get(''+quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).core_cpq_multiple_order_quantity__c;
                    quoteLine.core_cpq_minimum_qty__c = uniqueIdToPriceBookEntryMap.get(''+quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).core_cpq_minimum_order_qty__c;
                    
                    string key = uniqueIdToPriceBookEntryMap.get(''+quoteMap.get(quoteLine.SBQQ__Quote__c).core_cpq_price_book_nm__c + quoteLine.SBQQ__Product__c).Id;
                    if(!uniqueIdToListPriceMap.isEmpty() && uniqueIdToListPriceMap.containsKey(key)){
                        for(core_cpq_list_price__c lp : uniqueIdToListPriceMap.get(key)){
                            if(quoteLine.SBQQ__Quantity__c >= lp.core_cpq_lowerbound_qty__c && quoteLine.SBQQ__Quantity__c <= lp.core_cpq_upperbound_qty__c){
                                quoteLine.SBQQ__ListPrice__c = lp.core_cpq_list_price_amt__c;
                            }
                        }
                    }
                }else{
                    quoteLine.price_disty_cost_nbr__c = 0;
                    quoteLine.SBQQ__ListPrice__c = 0; 
                }
            }           
        }
        if(isUpdate){
            PSG_Constants.isQuoteLineTriggerActive=false;
            Database.update(quoteLineListToUpdate,false);
            PSG_Constants.isQuoteLineTriggerActive=true;
        }
    }
    
    /*************************************************************************************************************************
    *Method Name : createPRIDRecords
    *Created Date: 26/03/2021
    *Author: Vijay
    *Description : Creates PRID or revise PRID on approval of DW Quote or processing of CP Quote.
    **************************************************************************************************************************/
    public static void createPRIDRecords(Id quoteId){
        SBQQ__Quote__c quote=[Select Id,core_cpq_quote_type_nm__c,core_cpq_end_customer_nm__r.Core_Geo__c from SBQQ__Quote__c where Id = : quoteId LIMIT 1];
        Map<Id,price_prid__c> quoteLineIdToPRIDMap = new Map<Id,price_prid__c>();
        List<price_prid__c> pridListToDeactivate = new List<price_prid__c>();
        List<SBQQ__QuoteLine__c> changedQuoteLineList = new List<SBQQ__QuoteLine__c>();
        Set<Id> existingPRIDSet = new Set<Id>();
        Set<Id> oldActivePRIDSet = new Set<Id>();
        Set<String> existingPRIDUniqueValueSet = new Set<String>();
        Map<Id,SBQQ__QuoteLine__c> quoteLineIdToQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineWithNewPRIDCreationList = new List<SBQQ__QuoteLine__c>();
        Map<Id,SBQQ__QuoteLine__c> quoteLineWithOldPRIDMap = new Map<Id,SBQQ__QuoteLine__c>(); 
        Map<String,String> qlToUniqueIdMap=new Map<String,String>();
        List<SBQQ__QuoteLine__c> quoteLinesToBeUpdated = new List<SBQQ__QuoteLine__c>();
        Map<String,price_prid__c> uniqueIdToPridMap=new Map<String,price_prid__c>();
        List<SBQQ__QuoteLine__c> cpQlToBeUpdated = new List<SBQQ__QuoteLine__c>();
        List<price_PRID__c> deleteOPNPRIDToUpdateList=new List<price_PRID__c>();
        Set<String> cmfIds=new Set<String>();
        Set<String> opnIds=new Set<String>();
        
        Map<String,String> quoteLineApiToPridApiMap = new Map<String,String>{
            'price_suggested_resale_amt__c' => 'price_amt__c',
            'SBQQ__Quantity__c' => 'core_cpq_quantity_eau_nbr__c',
            'core_cpq_upper_bound_qty_nbr__c' => 'core_cpq_upper_bound_qty_nbr__c',
            'core_cpq_lower_bound_qty_qty__c' => 'core_cpq_lower_bound_qty_nbr__c',
            'core_cpq_pricing_start_date_dt__c' => 'core_cpq_price_start_date_dt__c',
            'core_cpq_pricing_end_date_dt__c' => 'core_cpq_price_end_date_dt__c',
            'core_cpq_price_eligibility_date_dt__c' => 'core_cpq_prid_eligiblity_date_dt__c',
            'core_cpq_review_date_dt__c' => 'core_cpq_prid_review_date_dt__c',
            'core_cpq_reviewer__c' => 'core_cpq_prid_reviewer__c',
            'core_cpq_active_Pricing__c' => 'core_cpq_active_pricing_cb__c',
            'core_cpq_comments_txt__c' => 'core_cpq_comments_txt__c'
        };
        Map<String,String> quoteLineApiToLabelMap = new Map<String,String>{
            'price_suggested_resale_amt__c' => 'Suggested Resale Price',
            'SBQQ__Quantity__c' => 'Quantity(EAU)',
            'core_cpq_upper_bound_qty_nbr__c' => 'Upper Bound Qty',
            'core_cpq_lower_bound_qty_qty__c' => 'Lower Bound Qty',
            'core_cpq_pricing_start_date_dt__c' => 'Price Start Date',
            'core_cpq_pricing_end_date_dt__c' => 'Price End Date',
            'core_cpq_price_eligibility_date_dt__c' => 'PED',
            'core_cpq_review_date_dt__c' => 'Review Date',
            'core_cpq_reviewer__c' => 'Reviewer',
            'core_cpq_active_Pricing__c' => 'Active Pricing' ,
            'core_cpq_comments_txt__c' => 'PRID COMMENTS'
        };
        Map<String,String> quoteLineApiToTypeMap = new Map<String,String>{
            'SBQQ__Quantity__c' => 'integer',
            'core_cpq_upper_bound_qty_nbr__c' => 'integer',
            'core_cpq_lower_bound_qty_qty__c' => 'integer',
            'core_cpq_pricing_start_date_dt__c' => 'date',
            'core_cpq_pricing_end_date_dt__c' => 'date',
            'core_cpq_price_eligibility_date_dt__c' => 'date',
            'core_cpq_review_date_dt__c' => 'date'
        };
        Map<String,String> quoteLineApiToDefaultValueMap = new Map<String,String>{
            'price_suggested_resale_amt__c' => '0',
            'SBQQ__Quantity__c' => '0',
            'core_cpq_upper_bound_qty_nbr__c' => '0',
            'core_cpq_lower_bound_qty_qty__c' => '0',
            'core_cpq_pricing_start_date_dt__c' => null,
            'core_cpq_pricing_end_date_dt__c' => null,
            'core_cpq_price_eligibility_date_dt__c' => null,
            'core_cpq_review_date_dt__c' => null,
            'core_cpq_reviewer__c' => null
        };
        Map<String,String> pridApiToDefaultValueMap = new Map<String,String>{
            'price_amt__c' => '0',
            'core_cpq_quantity_eau_nbr__c' => '0',
            'core_cpq_upper_bound_qty_nbr__c' => '0',
            'core_cpq_lower_bound_qty_nbr__c' => '0',
            'core_cpq_pricing_start_date_dt__c' => null,
            'core_cpq_price_start_date_dt__c' => null,
            'core_cpq_prid_eligiblity_date_dt__c' => null,
            'core_cpq_prid_review_date_dt__c' => null,
            'core_cpq_prid_reviewer__c' => null
        };          
        try{
            if(quoteId != null){
                for(SBQQ__QuoteLine__c quoteLine : [SELECT Id,Name,SBQQ__Quote__c,Delete_OPN__c,core_cpq_active_Pricing__c,SBQQ__Quote__r.core_cpq_end_customer_nm__c,core_cpq_PRID__c,SBQQ__Quote__r.Name,
                                                    SBQQ__Quote__r.core_cpq_sap_ecp_nm__c,SBQQ__Product__c,
                                                    core_cpq_quote_line_type_txt__c,SBQQ__Quantity__c,core_cpq_sap_ecp_nm__c,core_cpq_lower_bound_qty_qty__c,core_cpq_price_eligibility_date_dt__c,
                                                    core_cpq_upper_bound_qty_nbr__c,core_cpq_quantity_nm__c,core_cpq_product_nm__c,SBQQ__Quote__r.core_cpq_end_customer_nm__r.Core_Direct_Pricing_Parent_Id__r.id,
                                                    SBQQ__Quote__r.core_cpq_cmf_pricing_parent_id__c, price_suggested_resale_amt__c,core_cpq_pricing_start_date_dt__c,core_cpq_pricing_end_date_dt__c,
                                                    core_cpq_review_date_dt__c,core_cpq_reviewer__c ,core_cpq_comments_txt__c,SBQQ__Quote__r.core_cpq_quote_type_nm__c 
                                                    from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteId and ((SBQQ__Quote__r.core_cpq_quote_type_nm__c = 'Contract Pricing' and core_cpq_dollar_change_flag_cb__c = false) or (SBQQ__Quote__r.core_cpq_quote_type_nm__c <> 'Contract Pricing')) LIMIT :Limits.getLimitDmlRows()]){
                    if(quote.core_cpq_quote_type_nm__c == 'Design Win'){
                        if(quoteLine.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c != null)
                            cmfIds.add(quoteLine.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c);
                        if(quoteLine.SBQQ__Product__c != null)
                            opnIds.add(quoteLine.SBQQ__Product__c);
                    }
                    quoteLineIdToQuoteLineMap.put(quoteLine.Id,quoteLine);
                    if(quoteLine.core_cpq_PRID__c != null){
                        existingPRIDSet.add(quoteLine.core_cpq_PRID__c);
                        quoteLineWithOldPRIDMap.put(quoteLine.Id,quoteLine);
                    }else{
                        String ecp = '';
                        String pro = '';
                        String upperBound = '';
                        String lowerBound = '';
                        if(quoteLine.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c != null){
                            ecp = String.valueOf(quoteLine.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c).substring(0, 15);
                        }
                        if(quoteLine.SBQQ__Product__c != null){
                            pro = String.valueOf(quoteLine.SBQQ__Product__c).substring(0, 15);
                        }
                        
                        if(quoteLine.core_cpq_quote_line_type_txt__c == 'Step'|| quoteLine.core_cpq_quote_line_type_txt__c == 'AVP'){
                            upperBound = String.valueOf(quoteLine.core_cpq_upper_bound_qty_nbr__c);
                            lowerBound = String.valueOf(quoteLine.core_cpq_lower_bound_qty_qty__c);
                            existingPRIDUniqueValueSet.add(''+ecp + pro + lowerBound + upperBound);
                            qlToUniqueIdMap.put(quoteLine.Id,''+ecp + pro + lowerBound + upperBound);
                        }else{
                            existingPRIDUniqueValueSet.add(''+ecp + pro);
                            qlToUniqueIdMap.put(quoteLine.Id,''+ecp + pro);
                        }
                        if(quote.core_cpq_quote_type_nm__c != 'Contract Pricing'){
                            quoteLineWithNewPRIDCreationList.add(quoteLine);
                        }                   
                    }
                }
                Map<Id,price_prid__c> pridMap = new Map<Id,price_prid__c>();
                if(!existingPRIDUniqueValueSet.isEmpty() || !existingPRIDSet.isEmpty()){
                    String query = 'SELECT Id,core_cpq_unique_combination_nm__c,core_cpq_type__c,core_cpq_cps_cb__c';
                    if(!quoteLineApiToPridApiMap.isEmpty()){
                        query = query +','+ String.join(new List<String>(quoteLineApiToPridApiMap.Values()),',');
                    }
                    query = query + ' FROM price_prid__c WHERE (core_cpq_unique_combination_nm__c IN : existingPRIDUniqueValueSet OR Id IN : existingPRIDSet) AND core_cpq_active_cb__c = true';
                    if(String.isNotBlank(query)){
                        for(price_prid__c pridRec  : DataBase.query(query)){
                            pridMap.put(pridRec.Id,pridRec);
                            uniqueIdToPridMap.put(pridRec.core_cpq_unique_combination_nm__c,pridRec);
                        } 
                    } 
                }
                
                if(quote.core_cpq_quote_type_nm__c == 'Contract Pricing'){
                    for(SBQQ__QuoteLine__c quoteLine : quoteLineIdToQuoteLineMap.values()){
                        String uniqueId=qlToUniqueIdMap.get(quoteLine.Id);
                        if(quoteLine.Delete_OPN__c){
                            if(quoteLine.core_cpq_PRID__c != null || uniqueIdToPridMap.containsKey(uniqueId)){
                                price_prid__c prid=quoteLine.core_cpq_PRID__c != null ? pridMap.get(quoteLine.core_cpq_PRID__c) : uniqueIdToPridMap.get(uniqueId);
                                if(prid.core_cpq_type__c == quoteLine.core_cpq_quote_line_type_txt__c  && prid.core_cpq_cps_cb__c==true){
                                    prid.core_cpq_active_cb__c = false;
                                    prid.core_cpq_cps_cb__c=false;
                                    prid.core_cpq_update_underlying_quotelines_cb__c = true;
                                    prid.Inactivation_Reason__c='Delete OPN flag set on '+quoteLine.Name;
                                    deleteOPNPRIDToUpdateList.add(prid);
                                }                                                                    
                            }
                        }else if(quoteLine.core_cpq_PRID__c == null){
                            if(uniqueIdToPridMap.containsKey(uniqueId)){
                                price_prid__c prid=uniqueIdToPridMap.get(uniqueId);
                                if(prid.core_cpq_type__c == quoteLine.core_cpq_quote_line_type_txt__c  && prid.core_cpq_cps_cb__c==true){
                                    quoteLine.core_cpq_PRID__c=prid.Id;
                                    cpQlToBeUpdated.add(quoteLine);
                                    quoteLineWithOldPRIDMap.put(quoteLine.Id,quoteLine);                                
                                }else{
                                    quoteLineWithNewPRIDCreationList.add(quoteLine);
                                }
                            }else{
                                quoteLineWithNewPRIDCreationList.add(quoteLine);
                            }
                        }
                    }
                        
                    if(!cpQlToBeUpdated.isEmpty()){
                        quoteLinesToBeUpdated.addAll(cpQlToBeUpdated);
                    }
                    
                    if(!deleteOPNPRIDToUpdateList.isEmpty()){
                        update deleteOPNPRIDToUpdateList;
                    }
                }
                
                if(!cmfIds.isEmpty() || !opnIds.isEmpty()){
                    Map<String,Set<SBQQ__QuoteLine__c>> ecpOpnToQLMap=new Map<String,Set<SBQQ__QuoteLine__c>>();
                    for(SBQQ__QuoteLine__c ql : [SELECT Id,Name,SBQQ__Quote__c,SBQQ__Product__c,SBQQ__Quote__r.core_cpq_sap_ecp_nm__c from SBQQ__QuoteLine__c 
                                                 where SBQQ__Quote__c <> :quoteId and SBQQ__Quote__r.core_cpq_quote_type_nm__c = 'Contract Pricing' and core_cpq_dollar_change_flag_cb__c = false and
                                                 SBQQ__Quote__r.SBQQ__Status__c = 'Approved' and SBQQ__Quote__r.core_cpq_active_cb__c = false and SBQQ__Quote__r.core_cpq_Process_flag__c = false and
                                                 (SBQQ__Product__c in :opnIds or SBQQ__Quote__r.core_cpq_sap_ecp_nm__c in : cmfIds) LIMIT :Limits.getLimitDmlRows()]){
                        if(ecpOpnToQLMap.containsKey(''+ql.SBQQ__Product__c+ql.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c)){
                            Set<SBQQ__QuoteLine__c> qlSet=ecpOpnToQLMap.get(''+ql.SBQQ__Product__c+ql.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c);
                            qlSet.add(ql);
                            ecpOpnToQLMap.put(''+ql.SBQQ__Product__c+ql.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c,qlSet);
                        }else{
                            ecpOpnToQLMap.put(''+ql.SBQQ__Product__c+ql.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c,new Set<SBQQ__QuoteLine__c>{ql});
                        }
                    }
                    
                    Set<SBQQ__QuoteLine__c> qlToUpdate=new Set<SBQQ__QuoteLine__c>();
                    for(SBQQ__QuoteLine__c ql : quoteLineIdToQuoteLineMap.values()){
                        if(ecpOpnToQLMap.containsKey(''+ql.SBQQ__Product__c+ql.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c)){
                            qlToUpdate.addAll(ecpOpnToQLMap.get(''+ql.SBQQ__Product__c+ql.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c));
                        }
                    }
                    if(!qlToUpdate.isEmpty()){
                        List<SBQQ__QuoteLine__c> qlListToUpdate=new List<SBQQ__QuoteLine__c>();
                        for(SBQQ__QuoteLine__c ql : qlToUpdate){
                            ql.core_cpq_dollar_change_flag_cb__c=true;
                            qlListToUpdate.add(ql);
                        }
                        if(!qlListToUpdate.isEmpty()){
                            quoteLinesToBeUpdated.addAll(qlListToUpdate);
                        }
                    }                    
                }
                
                if(!quoteLinesToBeUpdated.isEmpty()){
                    List<SBQQ__QuoteLine__c> failedQls=new List<SBQQ__QuoteLine__c>();
                    PSG_Constants.isQuoteLineTriggerActive=false;
                    List<Database.SaveResult> results=Database.update(quoteLinesToBeUpdated,false);
                    PSG_Constants.isQuoteLineTriggerActive=true;
                    for(Integer i=0;i<results.size();i++){
                        if(!results[i].isSuccess()){
                            failedQls.add(quoteLinesToBeUpdated[i]);
                        }
                    }
                    if(!failedQls.isEmpty()){
                        PSG_Utility.createCoreLogEntry('PSG_QuoteBusinessLogic', 'createPRIDRecords', 'Error while updating Quotelines CP Quote lines(Line ==> 1459)', 'Failed QuoteLines : \\n'+failedQls+'\\n \\nDatabase Update Result  : \\n\\n'+results, 'SBQQ__Quote__c', 'High', '');
                    }
                }
                Set<Id> avpqlIds=new Set<Id>();
                for(SBQQ__QuoteLine__c quoteLine : quoteLineWithNewPRIDCreationList){ 
                    quoteLineIdToPRIDMap.put(quoteLine.Id,new price_prid__c(core_cpq_active_cb__c = true,
                                                                            core_cpq_active_pricing_cb__c = true,
                                                                            core_cpq_device__c = quoteLine.SBQQ__Product__c,
                                                                            core_cpq_type__c = quoteLine.core_cpq_quote_line_type_txt__c,
                                                                            core_cpq_sap_ecp_nm__c = quoteLine.SBQQ__Quote__r.core_cpq_sap_ecp_nm__c,
                                                                            core_cpq_cps_cb__c = (quoteLine.SBQQ__Quote__r.core_cpq_quote_type_nm__c == 'Contract Pricing' ? true : false),
                                                                            core_cpq_sap_ec_code__c = quoteLine.SBQQ__Quote__r.core_cpq_cmf_pricing_parent_id__c,
                                                                            core_cpq_lower_bound_qty_nbr__c = quoteLine.core_cpq_lower_bound_qty_qty__c,
                                                                            core_cpq_upper_bound_qty_nbr__c = quoteLine.core_cpq_upper_bound_qty_nbr__c,
                                                                            core_cpq_quantity_eau_nbr__c = quoteLine.SBQQ__Quantity__c,
                                                                            price_amt__c = quoteLine.price_suggested_resale_amt__c,
                                                                            //core_cpq_price_start_date_dt__c = quoteLine.core_cpq_pricing_start_date_dt__c,
                                                                            core_cpq_price_start_date_dt__c = ((quoteLine.core_cpq_quote_line_type_txt__c == 'AVP' && quoteLine.core_cpq_pricing_start_date_dt__c == null) ? quoteLine.core_cpq_price_eligibility_date_dt__c :quoteLine.core_cpq_pricing_start_date_dt__c ),
                                                                            core_cpq_price_end_date_dt__c = quoteLine.core_cpq_pricing_end_date_dt__c,
                                                                            core_cpq_prid_eligiblity_date_dt__c=quoteLine.core_cpq_quote_line_type_txt__c == 'AVP' ? quoteLine.core_cpq_price_eligibility_date_dt__c : null,
                                                                            core_cpq_quote__c = quoteLine.SBQQ__Quote__c,
                                                                            core_cpq_quoteline__c = quoteLine.Id,
                                                                            core_cpq_prid_review_date_dt__c = quoteLine.core_cpq_review_date_dt__c,
                                                                            core_cpq_prid_reviewer__c = quoteLine.core_cpq_reviewer__c,
                                                                            core_cpq_comments_txt__c = quoteLine.core_cpq_comments_txt__c
                                                                            )); 
                    if(quoteLine.core_cpq_quote_line_type_txt__c == 'AVP'){
                        avpqlIds.add(quoteLine.Id);
                    }
                }           
                                
                Map<Id,SBQQ__QuoteLine__c> quoteLineUpdateMap = new Map<Id,SBQQ__QuoteLine__c>();

                for(SBQQ__QuoteLine__c quoteLine : quoteLineWithOldPRIDMap.values()){
                    if(!quoteLine.Delete_OPN__c){
                        Boolean isPridRevision = false;
                        Boolean isPridUpdation = false;
                        
                        if(revisionTriggerQLFieldMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                            for(String qlField : revisionTriggerQLFieldMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                String pridField = quoteLineApiToPridApiMap.get(qlField);
                                if(pridMap.containsKey(quoteLine.core_cpq_PRID__c) 
                                   && quoteLine.get(qlField) != (pridMap.get(quoteLine.core_cpq_PRID__c)).get(pridField)){
                                       isPridRevision = true;
                                   }
                            }
                        }
                        if(isPridRevision && revisionFieldsQLMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                            for(String qlField : revisionFieldsQLMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                String pridField = quoteLineApiToPridApiMap.get(qlField);
                                if(pridMap.containsKey(quoteLine.core_cpq_PRID__c) 
                                   && quoteLine.get(qlField) != (pridMap.get(quoteLine.core_cpq_PRID__c)).get(pridField)){
                                       pridMap.get(quoteLine.core_cpq_PRID__c).put('core_cpq_update_underlying_quotelines_cb__c',true);
                                       pridMap.get(quoteLine.core_cpq_PRID__c).put(pridField,quoteLine.get(qlField));
                                   }
                            }
                        }
                        if(updationFieldQLMap.containsKey(quoteLine.core_cpq_quote_line_type_txt__c)){
                            for(String qlField : updationFieldQLMap.get(quoteLine.core_cpq_quote_line_type_txt__c)){
                                String pridField = quoteLineApiToPridApiMap.get(qlField);
                                if(pridMap.containsKey(quoteLine.core_cpq_PRID__c) 
                                   && quoteLine.get(qlField) != (pridMap.get(quoteLine.core_cpq_PRID__c)).get(pridField)){
                                       isPridUpdation = true;
                                       pridMap.get(quoteLine.core_cpq_PRID__c).put(pridField,quoteLine.get(qlField));
                                   }
                            }
                        }
                        if(isPridRevision || isPridUpdation){
                            if(isPridRevision ){
                                pridMap.get(quoteLine.core_cpq_PRID__c).put('core_cpq_last_revised_dt__c',System.today());
                            }
                            if(isPridUpdation){
                                pridMap.get(quoteLine.core_cpq_PRID__c).put('core_cpq_last_updated_dt__c',System.today());
                            }
                            pridMap.get(quoteLine.core_cpq_PRID__c).put('core_cpq_quoteline__c',quoteLine.Id);
                            pridMap.get(quoteLine.core_cpq_PRID__c).put('core_cpq_quote__c',quoteLine.SBQQ__Quote__c);
                            quoteLineIdToPRIDMap.put(quoteLine.Id,pridMap.get(quoteLine.core_cpq_PRID__c));
                        }
                    }                    
                }
                
                if(!quoteLineIdToPRIDMap.isEmpty()){
                    PRIDBusinessLogic.triggeredOnQuoteApproval=true;
                    upsert quoteLineIdToPRIDMap.values();
                    PRIDBusinessLogic.triggeredOnQuoteApproval=false;
                }
                
                for(Id quoteLineId : quoteLineIdToPRIDMap.keySet()){
                    SBQQ__QuoteLine__c quoteLine = quoteLineIdToQuoteLineMap.get(quoteLineId);
                    quoteLine.core_cpq_PRID__c = quoteLineIdToPRIDMap.get(quoteLine.Id).Id;
                    if( quoteLine.core_cpq_pricing_start_date_dt__c == null){
                        if(quoteLine.core_cpq_quote_line_type_txt__c == 'AVP'){
                            quoteLine.core_cpq_pricing_start_date_dt__c = quoteLine.core_cpq_price_eligibility_date_dt__c;
                        }else{
                            quoteLine.core_cpq_pricing_start_date_dt__c = System.today();
                        }
                    }else if(quoteLine.core_cpq_pricing_start_date_dt__c != null && quoteLine.core_cpq_pricing_start_date_dt__c < System.today()){
                        quoteLine.core_cpq_pricing_start_date_dt__c = System.today();
                    }
                    if( quoteLine.core_cpq_pricing_end_date_dt__c == null){
                        quoteLine.core_cpq_pricing_end_date_dt__c = Date.valueOf(Label.PSG_PRID_PriceEndDate);
                    }
                    quoteLineUpdateMap.put(quoteLine.Id,quoteLine);
                }
               
                for(Id quoteLineId : quoteLineIdToQuoteLineMap.keySet()){
                    if(quoteLineUpdateMap.containsKey(quoteLineId)){
                        quoteLineUpdateMap.get(quoteLineId).core_cpq_prid_alert__c = '';
                    }else{
                        quoteLineIdToQuoteLineMap.get(quoteLineId).core_cpq_prid_alert__c = '';
                        quoteLineUpdateMap.put(quoteLineId,quoteLineIdToQuoteLineMap.get(quoteLineId));
                    }
                }
                if(!quoteLineUpdateMap.isEmpty()){
                    SBQQ.TriggerControl.disable();
                    List<SBQQ__QuoteLine__c> failedList=new List<SBQQ__QuoteLine__c>();
                    PSG_QuoteLineBusinessLogic.triggeredOnQuoteApproval = true;
                    List<Database.SaveResult> updateResults = Database.update (quoteLineUpdateMap.values(),false);
                    PSG_QuoteLineBusinessLogic.triggeredOnQuoteApproval = false;
                    for(Integer i=0;i<updateResults.size();i++){
                        if(!updateResults[i].isSuccess()){
                            failedList.add(quoteLineUpdateMap.values()[i]);
                        }
                    }
                    if(!failedList.isEmpty()){
                        PSG_Utility.createCoreLogEntry('PSG_QuoteBusinessLogic', 'createPRIDRecords', 'Error while Stamping PRID back to QL on Quote Approval', 'QLs Failed to Update => '+failedList+'\n\n Update Result : '+updateResults, 'SBQQ__QuoteLine__c', 'High', '');
                    }
                    SBQQ.TriggerControl.enable();
                }
                
                if(!avpqlIds.isEmpty() && quote.core_cpq_end_customer_nm__r?.Core_Geo__c!= null){
                    sendAVPPRIDEmailAlert(avpqlIds,quote.core_cpq_end_customer_nm__r.Core_Geo__c);
                }
            }   
        }catch(Exception e){
            PSG_Utility.logError(e);
        }finally{
            PSG_Constants.isQuoteLineTriggerActive=true;
            PSG_QuoteLineBusinessLogic.triggeredOnQuoteApproval =false;
        }
    }
    
    public static void sendAVPPRIDEmailAlert(Set<Id> qlIds,String ECGeo){
        if(ECGeo != null && ECGeo != ''){
            Set<Id> userIds=new Set<Id>();
            List<String> userEmails=new List<String>();
            //TWC3133-5964 Geo Change
            Map<String,String> geoToGroupMap=new Map<String,String>{
                    'APJ' => 'ags_busops_ap',
                    'ASMO' => 'ags_busops_asmo',
                    'EMEA' => 'ags_busops_eu',
                    'PRC' => 'ags_busops_prc',
                    'INDIA' => 'ags_busops_ap'
                    };
                        for(GroupMember gm : [Select Id,UserOrGroupId from GroupMember where Group.DeveloperName=:geoToGroupMap.get(ECGeo) LIMIT :Limits.getLimitDmlRows()]){
                            userIds.add(gm.UserOrGroupId);
                        }
            for(User u :[Select Id,Email from User where Id in :userIds]){
                userEmails.add(u.Email);
            }
            List<SBQQ__QuoteLine__c> qls=[Select Id,Name,SBQQ__Quote__c, SBQQ__Quote__r.Name,core_cpq_PRID__c,core_cpq_PRID__r.Name from SBQQ__QuoteLine__c where Id in:qlIds];
            String pridTableBody='<table class="t">';
            pridTableBody+='<tr><th class="t2">PRID #</th><th class="t2">Quote Line #</th></tr>';
            for(SBQQ__QuoteLine__c ql:qls){
                pridTableBody+='<tr><td class="t1"><a href="'+formRecUrl(ql.core_cpq_PRID__c)+'">'+ql.core_cpq_PRID__r?.Name+'</a></td><td class="t1">'+ql.Name+'</td></tr>';
            }
            pridTableBody+='</table>';
            EmailTemplate tempId = [SELECT Id, HTMLValue,Subject, Body, Name FROM EmailTemplate WHERE DeveloperName = 'PSG_consol_AVP_PRID_Notification_busops'];
            Savepoint sp = Database.setSavepoint();
            Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
            mail1.setTemplateId(tempId.Id);
            mail1.setTargetObjectId(Userinfo.getUserId());
            mail1.setToAddresses(new List<String>{Userinfo.getUserEmail()});
            mail1.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail1});
            Database.rollback(sp);
            String emailBody=mail1.getHtmlBody();
            emailBody=emailBody.replace('PRID_Table',pridTableBody );
            emailBody=emailBody.replace('QUOTE_NUMBER','<a href="'+formRecUrl(qls[0].SBQQ__Quote__c)+'">'+qls[0].SBQQ__Quote__r?.Name+'</a>' );        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(orgWideEmailAdd.Id);
            mail.setToAddresses(userEmails);
            mail.setHtmlBody(emailBody);
            mail.setSubject(tempId.Subject);
            Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }        
    }
    
    public static String formRecUrl(Id recId){
        String baseUrl=URL.getSalesforceBaseUrl().toExternalForm();
        if(baseUrl.contains('my.salesforce')){
            baseUrl=baseUrl.replace('my.salesforce','lightning.force');
        }
        if(recId != null)
            return baseUrl+'/lightning/r/'+recId.getSObjectType().getDescribe().getName()+'/'+recId+'/view';
        else
            return '';
    }
    /********************************************************************************************
     * Method Name : calculateApprovalLevel
     * Description : Method to predict Approval Level required for Quote to be approved.
     * Author : Adarsh
     * Created Date : 11/11/2021
    ********************************************************************************************/
    public static void calculateApprovalLevel(List<SBQQ__Quote__c> quoteList){
        Map<Id, SBQQ__Quote__c> QuoteListMap = new Map<Id, SBQQ__Quote__c>(quoteList);
        SBAA__Approval__c approvalRec = [SELECT Id , SBAA__Rule__r.Name, Quote__r.core_cpq_negative_margin_quote_Value__c from SBAA__Approval__c WHERE Quote__c IN : QuoteListMap.keyset() LIMIT 1];
        if(approvalRec.SBAA__Rule__r.Name == 'BM Approval Rule'){
            Map<String,core_cpq_bm_approval_threshold__c> uniqueValueToThresholdsMap = new Map<String,core_cpq_bm_approval_threshold__c>();
            for(core_cpq_bm_approval_threshold__c approvalThresholdRec : [SELECT Id,core_cpq_bm_level_txt__c,core_cpq_business_unit_nm__c,
                                                                          core_cpq_intel_margin_pct__c,price_peak_annual_amt__c from 
                                                                          core_cpq_bm_approval_threshold__c]){
                                                                              uniqueValueToThresholdsMap.put(''+approvalThresholdRec.core_cpq_business_unit_nm__c + approvalThresholdRec.price_peak_annual_amt__c + approvalThresholdRec.core_cpq_intel_margin_pct__c,approvalThresholdRec);
                                                                          }
            Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(quoteList);
            Map<Id,List<SBQQ__QuoteLine__c>> qlMap = new Map<Id,List<SBQQ__QuoteLine__c>>();
            List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
            if(!quoteList.isEmpty()){
                for(SBQQ__QuoteLine__c quoteLine : [Select Id, price_peak_annual_resale_amt__c, core_cpq_intel_margin_pct__c, SBQQ__Quote__r.core_cpq_business_unit_nm__c from SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : quoteList]){
                    quoteLineList.add(quoteLine);
                    qlMap.put(quoteLine.SBQQ__Quote__r.Id, quoteLineList);
                }
                Map<Id,Decimal> quoteMaxPeakAnnualResaleMap = new Map<Id,Decimal>();
                Map<Id,Decimal> quoteMinIntelMarginMap = new Map<Id,Decimal>();
                Map<Id,String> quoteToBusinessUnitMap = new Map<Id,String>();
                for(Id key : qlMap.keySet()){
                    if(quoteMap.get(key).core_cpq_negative_margin_quote_Value__c == 0){
                        for(SBQQ__QuoteLine__c quoteLine : qlMap.get(key)){
                            if(!quoteMaxPeakAnnualResaleMap.containsKey(quoteLine.SBQQ__Quote__c)){                                 
                                quoteMaxPeakAnnualResaleMap.put(quoteLine.SBQQ__Quote__c,quoteLine.price_peak_annual_resale_amt__c);
                            }else if(quoteLine.price_peak_annual_resale_amt__c > quoteMaxPeakAnnualResaleMap.get(quoteLine.SBQQ__Quote__c)){
                                quoteMaxPeakAnnualResaleMap.put(quoteLine.SBQQ__Quote__c,quoteLine.price_peak_annual_resale_amt__c);
                            }
                            if(!quoteMinIntelMarginMap.containsKey(quoteLine.SBQQ__Quote__c)){                                  
                                quoteMinIntelMarginMap.put(quoteLine.SBQQ__Quote__c,quoteLine.core_cpq_intel_margin_pct__c);
                            }else if(quoteLine.core_cpq_intel_margin_pct__c < quoteMinIntelMarginMap.get(quoteLine.SBQQ__Quote__c)){
                                quoteMinIntelMarginMap.put(quoteLine.SBQQ__Quote__c,quoteLine.core_cpq_intel_margin_pct__c);
                            }
                            if(!quoteToBusinessUnitMap.containsKey(quoteLine.SBQQ__Quote__c) && quoteLine.SBQQ__Quote__r.core_cpq_business_unit_nm__c != null){
                                quoteToBusinessUnitMap.put(quoteLine.SBQQ__Quote__c,quoteLine.SBQQ__Quote__r.core_cpq_business_unit_nm__c);
                            }
                        }
                        Decimal diffPeakAnnual = 2147483647;
                        Decimal diffIntMargin = -2147483647;
                        Decimal diffPeakAnnualIns, diffIntMarginIns;
                        Integer checkBu = 0;
                        core_cpq_bm_approval_threshold__c peakAnnualrec = new core_cpq_bm_approval_threshold__c();
                        core_cpq_bm_approval_threshold__c intMarginrec = new core_cpq_bm_approval_threshold__c();
                        List<String> levelMargin = new List<String>();
                        List<String> levelPeakAnnual = new List<String>();
                        for(String thresholdTable : uniqueValueToThresholdsMap.keySet()){
                            core_cpq_bm_approval_threshold__c threshold = uniqueValueToThresholdsMap.get(thresholdTable);
                            if(threshold.core_cpq_business_unit_nm__c == quoteToBusinessUnitMap.get(key)){
                                checkBu++;
                                if(quoteMaxPeakAnnualResaleMap.get(key) <= threshold.price_peak_annual_amt__c)
                                    diffPeakAnnualIns = threshold.price_peak_annual_amt__c - quoteMaxPeakAnnualResaleMap.get(key);
                                if(quoteMinIntelMarginMap.get(key) >= threshold.core_cpq_intel_margin_pct__c)
                                    diffIntMarginIns = quoteMinIntelMarginMap.get(key) - threshold.core_cpq_intel_margin_pct__c;
                                if(diffPeakAnnualIns < diffPeakAnnual && quoteMaxPeakAnnualResaleMap.get(key) != null){
                                    peakAnnualrec = threshold;
                                    diffPeakAnnual = diffPeakAnnualIns;
                                }
                                if(diffIntMarginIns < diffIntMargin && quoteMinIntelMarginMap.get(key) != null){
                                    intMarginrec = threshold;
                                    diffIntMargin = diffIntMarginIns;
                                }
                            }
                        }
                        String value = '';
                        if(checkBu > 0){
                            levelPeakAnnual = (peakAnnualrec.core_cpq_bm_level_txt__c).split(' ');
                            if(intMarginrec != null && intMarginrec.core_cpq_bm_level_txt__c != null){
                                levelMargin = (intMarginrec.core_cpq_bm_level_txt__c).split(' ');
                            }
                            else{
                                levelMargin.add('Level');
                                levelMargin.add('1');
                            }
                            
                            
                            if(Integer.valueOf(levelPeakAnnual[1]) > Integer.valueOf(levelMargin[1])){
                                
                                for(integer i=1; i<= Integer.valueOf(levelPeakAnnual[1]); i++){
                                    value += 'BM Level ' +  i ;
                                    if(i < Integer.valueOf(levelPeakAnnual[1])){
                                        value += ' -> ';
                                    }
                                }
                            }
                            else{
                                
                                for(integer i=1; i<= Integer.valueOf(levelMargin[1]); i++){
                                    value += 'BM Level ' +  i ;
                                    if(i < Integer.valueOf(levelMargin[1])){
                                        value += ' -> ';
                                    }
                                }
                            }
                        }
                        quoteMap.get(key).core_cpq_Approval_Level_txt__c = value;
                    }
                    else{
                        quoteMap.get(key).core_cpq_Approval_Level_txt__c = 'BM Level 1 -> BM Level 2 -> BM Level 3 -> BM Level 4 -> BM Level 5';
                    }
                }
            }
        }
    }
    
    public Static void  generateQuoteDocument(PSG_QuoteBusinessLogic.QuoteProposalModel context) {
        SBQQ.ServiceRouter.save('SBQQ.QuoteDocumentAPI.Save', JSON.serialize(context));
    }
    
    class QuoteProposalModel {
        public String name {get;set;}
        public Id quoteId {get;set;}
        public Id templateId {get;set;}
        public String language {get;set;}
        public String outputFormat {get;set;}
        public String paperSize {get;set;}
    }
    /********************************************************************************************
     * Method Name : shareUnshareWithDisty
     * Description : Method to share/unshare Quotes & DPA/ALN with Disty based on Distributor Group Name.
     * Author : Adarsh Parashar
     * Created Date : 06/20/2023
    ********************************************************************************************/
    public static void shareUnshareWithDisty(Map<String,String> idToOldGroupMap,Map<String,String> idToNewGroupMap,String objType){
        List<String> pgNames=new List<String>();
        Map<String,String> pgNameToIdMap=new Map<String,String>();
        if(idToOldGroupMap!=null && !idToOldGroupMap?.isEmpty()){
            pgNames.addAll(idToOldGroupMap.values());
        }
        if(idToNewGroupMap!=null && !idToNewGroupMap?.isEmpty()){
            pgNames.addAll(idToNewGroupMap.values());
        }
        for(Group g: [Select Id,DeveloperName from Group where Type <> 'Queue' and DeveloperName in : pgNames]){
            pgNameToIdMap.put(g.DeveloperName,g.Id);
        }
        if(idToOldGroupMap!=null && !idToOldGroupMap?.isEmpty()){
            List<Sobject> shareRecToDelete=new List<SObject>();
            List<Sobject> recList= new List<SObject>();
            if(objType=='Quote'){
                recList=[Select id,ParentId,UserOrGroupId from SBQQ__Quote__Share where parent.Id in :idToOldGroupMap.keyset() and RowCause='Manual' and UserOrGroupId in:pgNameToIdMap.values()];
            }else{
                recList=[Select id,ParentId,UserOrGroupId from core_cpq_dpa_aln__share where parent.Id in :idToOldGroupMap.keyset() and RowCause='Manual' and UserOrGroupId in:pgNameToIdMap.values()];
            }		
            for(SObject shareRec: recList){
                if(pgNameToIdMap.containsKey(idToOldGroupMap.get((String)shareRec.get('ParentId'))) && shareRec.get('UserOrGroupId') == pgNameToIdMap.get(idToOldGroupMap.get((String)shareRec.get('ParentId')))){
                    shareRecToDelete.add(shareRec);
                }
            }
            if(!shareRecToDelete.isEmpty()){
                delete shareRecToDelete;
            }	
        }
        
        if(idToNewGroupMap!=null && !idToNewGroupMap?.isEmpty()){
            List<SObject> shareRecToInsert=new List<Sobject>();
            for(String parentId:idToNewGroupMap.keyset()){
                String groupName=idToNewGroupMap.get(parentId);
                SObject shareRec;
                if(pgNameToIdMap.containsKey(groupName)){
                    if(objType=='Quote'){
                        shareRec= new SBQQ__Quote__Share(ParentId = parentId,UserOrGroupId = pgNameToIdMap.get(groupName),AccessLevel = 'Edit',RowCause = Schema.SBQQ__Quote__Share.RowCause.PSG_PGM_Mapping__c);
                    }else{
                        shareRec= new core_cpq_dpa_aln__share(ParentId = parentId,UserOrGroupId = pgNameToIdMap.get(groupName),AccessLevel = 'Read',RowCause = Schema.core_cpq_dpa_aln__share.RowCause.PSG_PGM_Mapping__c);
                    }
                    shareRecToInsert.add(shareRec);
                }                
            }
            if(!shareRecToInsert.isEmpty()){
                List<Database.SaveResult> result=Database.insert(shareRecToInsert,false);
            }
        }
    }
}