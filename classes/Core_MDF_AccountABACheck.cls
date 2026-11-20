/***************************************************************************************************** 
Class Name :    Core_MDF_AccountABACheck
Description:    Used to fetch ABA details for the selected Account from Activity Screen
Added By   :    Accenture - JB    Date:11/19/2025 Used to fetch ABA details for the selected Account from Activity Screen
******************************************************************************************************/
public without sharing class Core_MDF_AccountABACheck {
    //WW50-IPA outcome- Benefit association
    public static String objectApiName = 'Core_MDF_BudgetType_Benefit_Mappings__c';
    public static String Proposal_based_Indicator = Core_MDF_CCP_ConstantClass.Proposal_based_Indicator;
    public static String Account_based_Indicator = Core_MDF_CCP_ConstantClass.Account_based_Indicator;
    public static boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
    public static List<Core_MDF_BudgetType_Benefit_Mappings__c> budgetTypeBenefitMapping = new List<Core_MDF_BudgetType_Benefit_Mappings__c>();
    
    
    /***************************************************************************************************** 
    Method Name :   getBudgetType
    @return     :   Map<string,string>
    @parameters :   Id accId, string operation, string isProposalBased, string program
    Description :   Fetch ABA details for the selected Account
    Added By    :   Accenture - JB                                Copied from Core_MDF_CampaignCreatePage
    ******************************************************************************************************/
    /*******************WW50 -BudgetType Benefit Mapping**************************/
    public static Map<string,string> getBudgetType(Id accId, string operation, string isProposalBased, string program){
        List<String> budgetTypeValues = new List<String>();
        set<String> budgetFromMetaData = new set<String>();
        set<String> mdfBudgetType = new set<String>();
        List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();
        string budgetTypeString,recordType,AccountId;
        Set<String> budgetTypeFromPGM = new Set<String>();
        Map<string,set<string>> recordTypeBudgetMap = new Map<string,set<string>>();
        Map<string,string> budgetTypeValuesMap = new Map<string,string>();
        Map<string,string> budgetTypeMap = new Map<string,string>();
        
        try{
            
            Map<String,String> validBudgetTypeOptions = new Map<String,String>();
            Schema.DescribeFieldResult fieldResult = PartnerFundRequest.Core_MDF_Budget_Type_nm__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            for( Schema.PicklistEntry f : ple)
            {
                validBudgetTypeOptions.put(f.getValue(), f.getLabel());
            }       
            
            
            
            if(program == 'Intel Partner Alliance'){
                AdminOperations aoObj = new AdminOperations();
                AccountIdBudgetTypeWrapper abtw = new AccountIdBudgetTypeWrapper();
                abtw = aoObj.getAccSpecificBudgetTypes(accId,program);
                budgetTypeValuesMap = abtw.accIdBudgetTypeMap.get(accId);
                budgetTypeFromPGM = budgetTypeValuesMap.keySet();
            }
            //Existing flow for Channel MDF to get Budget types from PGM
            String budgetTypeForQuery = '(\''+String.join(new List<String>(budgetTypeFromPGM), '\', \'') + '\')';
            String whereClause = ' Core_MDF_RecordType__c != null AND Core_MDF_Budget_Type__c IN'+budgetTypeForQuery+' AND Core_MDF_Program_Nm__c =\''+program+'\' '+' AND Core_MDF_IsActive__c=true';
            budgetTypeBenefitMapping = Core_MDF_CampaignUtility.getBudgetTypeBenefitRec(objectApiName, whereClause);
            
            List<Core_MDF_BudgetType_Benefit_Mappings__c> budgetMappingsList = budgetTypeBenefitMapping;
            
            if(!budgetMappingsList.isEmpty()){
                
                for(Core_MDF_BudgetType_Benefit_Mappings__c budgetTypeMapping : budgetMappingsList){
                    budgetFromMetaData.add(budgetTypeMapping.Core_MDF_Budget_Type__c);
                    if(recordTypeBudgetMap.get(budgetTypeMapping.Core_MDF_RecordType__c) != null){
                        recordTypeBudgetMap.get(budgetTypeMapping.Core_MDF_RecordType__c).add(budgetTypeMapping.Core_MDF_Budget_Type__c);
                    }else{
                        recordTypeBudgetMap.put(budgetTypeMapping.Core_MDF_RecordType__c, new set<string>{budgetTypeMapping.Core_MDF_Budget_Type__c});
                    }
                }
            } 
            
            if(!budgetFromMetaData.isEmpty()){
                if(operation == 'edit'){
                    if(String.isNotBlank(isProposalBased)){
                        recordType = isProposalBased == 'true' ? Proposal_based_Indicator : Account_based_Indicator;
                    }
                    if(string.isNotBlank(recordType)){
                        if(recordTypeBudgetMap.get(recordType) != null){
                            mdfBudgetType = recordTypeBudgetMap.get(recordType);
                            for(String b:mdfBudgetType){
                                budgetTypeMap.put(b,validBudgetTypeOptions.get(b));
                            }
                            
                        }
                    }
                    
                    budgetTypeString = string.join((Iterable<String>)mdfBudgetType,';');
                    
                }else{
                    for(String b:budgetFromMetaData){
                        budgetTypeMap.put(b,validBudgetTypeOptions.get(b));
                    }
                    budgetTypeString = string.join((Iterable<String>)budgetFromMetaData,';');
                }    
            }
            
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}  
        return budgetTypeMap;
    }
    public without sharing class AdminOperations {
        public AccountIdBudgetTypeWrapper getAccSpecificBudgetTypes(String accountId, String program){
            //List<Id> accIdList = new List<Id>();
            Set<Id> accIdList = new Set<Id>();
            Map<Id,Map<String,String>> accIdBudgetTypeMap = new Map<Id,Map<String,String>>();
            Map<Id,Set<String>> benefitsApplicable = new Map<Id,Set<String>>();
            Set<String> unifiedIdSet =new Set<String>();//changed from primeIdSet to unifiedIdSet
            Set<Id> setOfAccIds=new Set<Id>();
            Map<Id,String> coMktAcctToUnifiedIdMap = new Map<Id,String>();//changed from coMktAcctToPrimeIdMap to coMktAcctToUnifiedIdMap
            //Map<Id,Id> intelAcctToCoMktAcctMap = new Map<Id,Id>();
            
            //Map<String,String> applicableBenefitsFromMdt = new Map<String,String>();
            Map<String, Set<String>> applicableBenefitsFromMdt = new Map<String, Set<String>>();  //Roshan
            Map<String,String> budgetTypeToRecTypeMap = new Map<String,String>();
            Map<String,Set<String>> unifiedIdToBenefitList = new Map<String,Set<String>>();//changed from primeIdToBenefitList to unifiedIdToBenefitList
            Map<Id,String> mapOfIntelAccountandUnifiedId = new Map<Id,String>();//changed from mapOfIntelAccountandPrimeId to mapOfIntelAccountandUnifiedId
            Map<String,String> validBudgetTypeOptions = new Map<String,String>();
            List<Id> MDFExcluded = new List<id>();
            Map<String, String> budgetTypesFromCampObj = new Map<String, String>();
            List<String> recTypeNameLst = new List<String>();
            //Roshan
            Boolean optAccountBenefitAssociation = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_OptAccountBenefitAssoc'); 
            Set<Id> setOfOnePartnerIds = new Set<Id>();
            Map<Id, Set<Id>> mapOfOPIDtoSetofAccountId = new Map<Id, Set<Id>>();  
            
            Schema.DescribeFieldResult fieldResult = PartnerFundRequest.Core_MDF_Budget_Type_nm__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            
            for( Schema.PicklistEntry f : ple) {
                budgetTypesFromCampObj.put(f.getValue(), f.getLabel());
            }
            
            recTypeNameLst.add('Core_MDF_Intel_Partner_Alliance_Proposal_Based');
            recTypeNameLst.add('Core_MDF_Intel_Partner_Alliance_Account_Based');
            List<String> ipaValidBudgetTypesList = getDependentPicklistValues('Core_MDF_Opal_Budget_Type_Txt__c',recTypeNameLst, program);//Core_MDF_Budget_Type_nm__c
            
            for(String budType: budgetTypesFromCampObj.keySet()) {
                if(ipaValidBudgetTypesList.contains(budType)) {
                    validBudgetTypeOptions.put(budType, budgetTypesFromCampObj.get(budType));
                }
            }
            accIdList.add(accountId);
            //added by jk for budget type benefit mapping
            String whereClauseForBudgetType = 'Core_MDF_Program_Nm__c =\''+program+'\' '+' AND Core_MDF_IsActive__c=true';
            //budgetTypeBenefitMapping = Core_MDF_GenericMetadata.getObjectRecords(objectApiName, whereClauseForBudgetType);
            budgetTypeBenefitMapping = Core_MDF_CampaignUtility.getBudgetTypeBenefitRec(objectApiName, whereClauseForBudgetType);
            
            for(Core_MDF_BudgetType_Benefit_Mappings__c budToBenMdt:budgetTypeBenefitMapping){
                //applicableBenefitsFromMdt.put(budToBenMdt.Core_MDF_Partner_Benefit__c, budToBenMdt.Core_MDF_Budget_Type__c);
                
                //Roshan
                if (!applicableBenefitsFromMdt.containsKey(budToBenMdt.Core_MDF_Partner_Benefit__c)) {
                    applicableBenefitsFromMdt.put(budToBenMdt.Core_MDF_Partner_Benefit__c, new Set<String>());
                }
                applicableBenefitsFromMdt.get(budToBenMdt.Core_MDF_Partner_Benefit__c).add(budToBenMdt.Core_MDF_Budget_Type__c);
                
                budgetTypeToRecTypeMap.put(budToBenMdt.Core_MDF_Budget_Type__c,budToBenMdt.Core_MDF_RecordType__c);
            }
            
            //for retriving accounts added by jk
            //String unifiedIdOrPrimeIdField = isUnifiedIdEnabled?' AND Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c!= null':' AND Core_MDF_CoMarketing_Ultimate_Account__r.Core_Prime_Id__c != null';
            String unifiedIdOrPrimeIdField = ' AND Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c!= null';
            String accIdListQuery = '(\''+String.join(new List<Id>(accIdList), '\', \'') + '\')';
            String whereClause = ' Id IN '+accIdListQuery+unifiedIdOrPrimeIdField;
            List<Account> accounts = Core_MDF_Account_Utility.fetchAccounts(whereClause);
            Set<Id> accountIds = new Set<Id>();
            for(Account acc : accounts){
                //String primeOrUnifiedField = isUnifiedIdEnabled?acc.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c:null;
                String primeOrUnifiedField = acc.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Unified_Global_Customer_BP_Id__c;    
                
                coMktAcctToUnifiedIdMap.put(acc.Id, primeOrUnifiedField/*acc.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Prime_Id__c*/);
                unifiedIdSet.add(primeOrUnifiedField/*acc.Core_MDF_CoMarketing_Ultimate_Account__r.Core_Prime_Id__c*/);  
                
                accountIds.add(acc.Id);           
            }
            
            if(!unifiedIdSet.isEmpty()) {
                
                List<PRM_IPA_Affiliation__c> prmIPAAff = Core_MDF_Account_Utility.fetchPRMIPAAffiliation(accountIds,null);
                for(PRM_IPA_Affiliation__c accIpaAff : prmIPAAff) {
                    MDFExcluded.add(accIpaAff.PRM_Account__c);
                }
                
                List<Account> unifiedAccounts = Core_MDF_Account_Utility.fetchUnifiedIdAccounts(unifiedIdSet);
                
                for(Account acc : unifiedAccounts) {
                    String primeIdOrUnifiedField = acc.Core_Unified_Global_Customer_BP_Id__c;
                    if(!MDFExcluded.contains(acc.Id)) {              
                        mapOfIntelAccountandUnifiedId.put(acc.Id,primeIdOrUnifiedField);
                        
                        //Roshan 
                        setOfAccIds.add(acc.Id);
                        if (acc.Core_IPA_One_Partner_Id__c != null) {
                            setOfOnePartnerIds.add(acc.Core_IPA_One_Partner_Id__c);
                            if (!mapOfOPIDtoSetofAccountId.containsKey(acc.Core_IPA_One_Partner_Id__c)) {
                                mapOfOPIDtoSetofAccountId.put(acc.Core_IPA_One_Partner_Id__c, new Set<Id>());
                            }
                            mapOfOPIDtoSetofAccountId.get(acc.Core_IPA_One_Partner_Id__c).add(acc.Id);
                        }
                        
                    }                          
                }
                
                String setOfGeneralizedAccountds = optAccountBenefitAssociation ? '(\'' + String.join(new List<Id>(setOfOnePartnerIds), '\', \'') + '\')' : '(\'' + String.join(new List<Id>(setOfAccIds), '\', \'') + '\')';
                
                Map<Id, Set<String>> accountIdToBenefitMap = Core_MDF_CampaignCreatePage.getAccountToBenefitsMap(optAccountBenefitAssociation, setOfGeneralizedAccountds);
                
                if (optAccountBenefitAssociation) {
                    for (Id opid : accountIdToBenefitMap.keySet()) {
                        if (mapOfOPIDtoSetofAccountId.containsKey(opid)) {
                            Set<String> benefits = accountIdToBenefitMap.get(opid);
                            for (Id intelAccId : mapOfOPIDtoSetofAccountId.get(opid)) {
                                accountIdToBenefitMap.put(intelAccId, new Set<String>(benefits));
                            }
                        }
                    }
                }
                
                for (Id accId : accountIdToBenefitMap.keySet()) {
                    String unifiedId = mapOfIntelAccountandUnifiedId.get(accId);
                    if (String.isNotBlank(unifiedId)) {
                        if (!unifiedIdToBenefitList.containsKey(unifiedId)) {
                            unifiedIdToBenefitList.put(unifiedId, new Set<String>());
                        }
                        unifiedIdToBenefitList.get(unifiedId).addAll(accountIdToBenefitMap.get(accId));
                    }
                }
                
            }                                        
            //ABA: {1141415jhayeqJK87={MDFPRPCCP}}
            //ASA: {1141415jhayeqJK87={Account Plan MDF, CCP-Pilot_IoT Premier System Provider, CCP-Pilot_ODM CCG Growth Plan - MDF, Client Specialties MDF, Data Centric Acceleration - MDF, Proposal I MDF, Proposal II MDF}}
            for(Id acctId:accIdList){
                Set<String> benList = new Set<String>();
                Map<String,String> budgetTypeMap = new Map<String,String>();
                String unifiedId ='';//changed from primeId to unifiedId
                
                if(coMktAcctToUnifiedIdMap.containsKey(acctId) && coMktAcctToUnifiedIdMap.get(acctId) !=Null){
                    unifiedId = coMktAcctToUnifiedIdMap.get(acctId);
                }
                
                if(String.isNotBlank(unifiedId) && unifiedIdToBenefitList.containsKey(unifiedId) && unifiedIdToBenefitList.get(unifiedId) !=Null){
                    benList.addAll(unifiedIdToBenefitList.get(unifiedId));
                }
                
                
                //Roshan
                for(String benifit : benList) {
                    if (applicableBenefitsFromMdt.containsKey(benifit)) {
                        for (String budgetType : applicableBenefitsFromMdt.get(benifit)) {
                            if (validBudgetTypeOptions.containsKey(budgetType)) {
                            	budgetTypeMap.put(budgetType, validBudgetTypeOptions.get(budgetType));
                            }
                        }
                    }
                }
                
                
                accIdBudgetTypeMap.put(acctId, budgetTypeMap);
                benefitsApplicable.put(acctId,benList);
            }  
            
            AccountIdBudgetTypeWrapper abtw = new AccountIdBudgetTypeWrapper();
            abtw.accIdBudgetTypeMap = accIdBudgetTypeMap;
            return abtw;
            
        }
    }
    public static List<String> getDependentPicklistValues(String fieldAPI, List<String> recTypeList, String program){
        Map<String, List<String>> fdvaluesmap=new Map<String, List<String>>();
        List<String> budgetTypesList = new List<String>();
        Set<Id> recordTypeIds = new Set<Id>();
        try{
            
            for(String recType : recTypeList) {
                if(!Test.isRunningTest()){
                    Map<String, Object> jsonResponse = Core_Intel_customPicklistController.customPicklistFetcher(recType);
                    Map<String, List<String>> returnData = Core_MDF_Smart_Picklist_Maintainence.parseDependentPicklistValues(jsonResponse, fieldAPI);
                    if(returnData != null && returnData.size() > 0) {
                        budgetTypesList.addAll(returnData.get(program));
                        
                    }
                }else{
                    budgetTypesList.addAll(new List<String>{'Account Plan', 'Proposal I MDF', 'Proposal II MDF'});
                }
            }
            
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(e.getMessage());
        }
        
        return budgetTypesList;
    }
    public class AccountIdBudgetTypeWrapper {
        @AuraEnabled public Map<Id,Map<String,String>> accIdBudgetTypeMap  { get; set; }
    }
}