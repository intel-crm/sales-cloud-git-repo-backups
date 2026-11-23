public without sharing class Core_MDF_AccountServiceHandler {
    public static Id coMarketingRecordtypeId = Core_MDF_CCP_ConstantClass.coMarketing_RecordType_Id; //Added by Accenture - VD -> Check if the record type is not Co-Marketing
    public static Id masterRecrodtypeId = Core_MDF_CCP_ConstantClass.master_RecordType_Id;
    public static Map<Id,set<Id>> accIdToExtGrpIdMap = new Map<Id,set<Id>>();
    public static Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
    public static Map<Id,Account> parentAccIdToParentAccMap = new Map<Id,Account>();
    public static Map<Id,Account> virtualCorpToUltimateAccountMap = new Map<Id,Account>();
    public static Map<String,Account> virtualCorpIdToVirtualCorpAccMap  = new Map<String,Account>();
    public static Map<Id,Id> parentAccountToUltimateAccountmap = new Map<Id,Id>();
    public static Set<Id> ultimateAccountIds = new Set<Id>();
   

    public static void processCCPTriggerUpdates(List<Account> newAccountList, Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap, String triggerContext) {
     List<Account> comarkAct = new List<Account>();
     Set<Id> parentFundAcctIds = new Set<Id>();
     Set<Id> programIds  = new Set<Id>();

        //By-pass when recursive call
        if(Core_MDF_RecursiveTrigger.isRecursive){
            return;
        }

        for(Account acc : newAccountList)
        {
           if(acc.RecordTypeId == coMarketingRecordTypeId)
           {
             comarkAct.add(acc);
             programIds.add(acc.Core_MDF_Channel_Program__c);
             parentFundAcctIds.add(acc.Core_MDF_Parent_Fund_Account__c);

           }
        }
        if(!parentFundAcctIds.isEmpty() && !programIds.isEmpty())
        {
            getParentFundAccounts(parentFundAcctIds,programIds);
        }
     

        if(triggerContext == 'before insert') {


            if(mapFunctionalityNameTriggerExecution.containskey('Core_MDF_VirtualCorpInsertionLogic') &&
            mapFunctionalityNameTriggerExecution.get('Core_MDF_VirtualCorpInsertionLogic').Core_Active__c)
            {
                virtualCorpInsertionLogic(comarkAct,programIds);
            }

            if(mapFunctionalityNameTriggerExecution.containskey('Core_MDF_UpdateHostRegionOnNodeAcc') &&
               mapFunctionalityNameTriggerExecution.get('Core_MDF_UpdateHostRegionOnNodeAcc').Core_Active__c)
            {
                updateHostRegionOnNodeAccounts(comarkAct);
            }
        } 
        
        if(triggerContext == 'before update') {
 
            //To validate the co-marketing Account's Parent Fund Account changes
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ValidatePFAChange') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_ValidatePFAChange').Core_Active__c) 
            {
                validateMDFParentFundAccChanges(newAccountList, oldAccountMap);
            }
            if(mapFunctionalityNameTriggerExecution.containskey('Core_MDF_IPA_Account_Region_Check') &&
               mapFunctionalityNameTriggerExecution.get('Core_MDF_IPA_Account_Region_Check').Core_Active__c)
            {
                restrictHostRegionUpdateOnNodeAccounts(newAccountMap, oldAccountMap);
            }
                    }
        
        if(triggerContext == 'after insert') {
            
            List<Account> accountToBeSharedList = new List<Account>();
            //To create Group on Co-Marketing Accounts for Node Based Sharing
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_createGroupForAccountNode') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_createGroupForAccountNode').Core_Active__c) 
            {
                accountToBeSharedList = createGroupForComarketingAccount(comarkAct);
            }
            //To call Batch process for Account and Budget Sharing
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ShareAccountsWithGroups') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_ShareAccountsWithGroups').Core_Active__c)
            {
                sharingWithNewAcctGrps(accountToBeSharedList);
            }
           /* if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_Account_node_share') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_Account_node_share').Core_Active__c)
            {
                if(!Core_MDF_Utility.byPassFeature('Bypass_External_Group_Creation')){
                    createNodeShrngGrpAndUpdAccNodeAttr(newAccountMap);
                }
                
            }*/
            //ATHR Fix - For deeply nested if - combined byPassFeature
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_Account_node_share') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_Account_node_share').Core_Active__c && !Core_MDF_Utility.byPassFeature('Bypass_External_Group_Creation'))
            {
                    createNodeShrngGrpAndUpdAccNodeAttr(newAccountMap);
                
            }//ATHR End
            
            //Aswin- Account Node attribute changes
                //createAccountNodeAttr(newAccountList,newAccountMap);
        }
        
        if(triggerContext == 'after update') {
            //To validate the co-marketing Account's Parent Fund Account changes
            if(mapFunctionalityNameTriggerExecution.containsKey('Core_MDF_ValidatePFAChangeOnAftrUpdt') && 
               mapFunctionalityNameTriggerExecution.get('Core_MDF_ValidatePFAChangeOnAftrUpdt').Core_Active__c) 
            {
                validateAccountHierarchy(newAccountList, oldAccountMap);
            }
            // This method will be called when a host region/payment type is changed on the virtual corp  and the same should be stamped on its child accounts
            if(mapFunctionalityNameTriggerExecution.containskey('Core_MDF_UpdateHostRegionAfterVCUpdate') &&
               mapFunctionalityNameTriggerExecution.get('Core_MDF_UpdateHostRegionAfterVCUpdate').Core_Active__c)
            {
                updateHostRegionAfterVirtualCorpUpdate(newAccountList, oldAccountMap); 
            }

            if(!Core_MDF_Utility.byPassFeature('Bypass_AccountPgmSync_Account')){
                processPGMCreation(newAccountMap, oldAccountMap); 
            }

            //Core_MDF_RecursiveTrigger.isRecursive = true;
        }                
    }

    /***************************************************************************************************** 
    Method name  : createAccountNodeAttr
    Description  : This method is used to create Account Node Attribute records for the VC and Node Accounts and Return the Mapping
    Return Type  : Map<Id, Id>
    Parameter    : Map<Id, Account> newAccountMap
    Created By   : JB               
    Date         : 04/25/2025      This method is used to create Account Node Attribute records for the VC and Node Accounts and Return the Mapping
    ******************************************************************************************************/
    public static Map<Id, Id> createAccountNodeAttr(Map<Id, Account> newAccountMap){

        //check the locking- account flow to stamp/update the group & account node attr after insert flow
        Map<Id, Id> accIdToNodeAttrIdMap = new Map<Id,Id>();
        List<Core_MDF_Account_Node_Attributes__c> accNodeAttrList =new List<Core_MDF_Account_Node_Attributes__c>();

        /*Map<String, String> programIdToProgramNameMap = new Map<String, String>();
        for(Core_MDF_ChannelProgram__mdt program : [SELECT Id, DeveloperName, Core_MDF_Program_ID__c, Label FROM Core_MDF_ChannelProgram__mdt WHERE Core_MDF_Program_ID__c != null]){
            String programId15Digit = (program.Core_MDF_Program_ID__c.length() >= 15 ? (String.valueOf(program.Core_MDF_Program_ID__c).substring(0, 15)) : program.Core_MDF_Program_ID__c);
            programIdToProgramNameMap.put(programId15Digit, program.Label);
        }

        Map<String, Core_MDF_CCP_Payment_File_Particulars__mdt> programNameToFileParticularsMap = new Map<String, Core_MDF_CCP_Payment_File_Particulars__mdt>();
        for(Core_MDF_CCP_Payment_File_Particulars__mdt fileParticulars : [SELECT Core_MDF_GL_Account__c, Core_MDF_GL_Account_CSAR__c, Core_MDF_Program__c FROM Core_MDF_CCP_Payment_File_Particulars__mdt LIMIT 1000]){
            programNameToFileParticularsMap.put(fileParticulars.Core_MDF_Program__c, fileParticulars);
        }*/

        for(Account acc : newAccountMap.values()){
            if(acc.RecordTypeId == coMarketingRecordTypeId){
                //String progamId15Digit = String.isNotBlank(acc.Core_MDF_Channel_Program__c) ? (String.valueOf(acc.Core_MDF_Channel_Program__c).length() >= 15 ? String.valueOf(acc.Core_MDF_Channel_Program__c).substring(0, 15) : String.valueOf(acc.Core_MDF_Channel_Program__c)) : String.valueOf(acc.Core_MDF_Channel_Program__c);
                //Core_MDF_CCP_Payment_File_Particulars__mdt fileParticular = programIdToProgramNameMap.containsKey(progamId15Digit) && programNameToFileParticularsMap.containsKey(programIdToProgramNameMap.get(progamId15Digit)) ? programNameToFileParticularsMap.get(programIdToProgramNameMap.get(progamId15Digit)) : new Core_MDF_CCP_Payment_File_Particulars__mdt();
                
                Core_MDF_Account_Node_Attributes__c accNodeAttr = new Core_MDF_Account_Node_Attributes__c();
                accNodeAttr.Core_MDF_Account_id__c= acc.Id;
                
                //When the File PArticulars is 'null' then populate default field values for Core_MDF_CSAR_GL_Account_nbr__c and Core_MDF_NonPO_GL_Account_nbr__c
                /*if(fileParticular != null){
                    if(String.isNotBlank(fileParticular.Core_MDF_GL_Account_CSAR__c)){
                        accNodeAttr.Core_MDF_CSAR_GL_Account_nbr__c = Decimal.valueOf(fileParticular.Core_MDF_GL_Account_CSAR__c);
                    }
                    if(String.isNotBlank(fileParticular.Core_MDF_GL_Account__c)){
                        accNodeAttr.Core_MDF_NonPO_GL_Account_nbr__c = Decimal.valueOf(fileParticular.Core_MDF_GL_Account__c);
                    }
                }*/

                accNodeAttr.Core_MDF_Program_id__c = acc.Core_MDF_Channel_Program__c;
                accNodeAttrList.add(accNodeAttr);
            }
        }

        if(!accNodeAttrList.isEmpty()){
            insert accNodeAttrList;

            for(Core_MDF_Account_Node_Attributes__c nodeAttribute: accNodeAttrList){
                accIdToNodeAttrIdMap.put(nodeAttribute.Core_MDF_Account_id__c, nodeAttribute.Id);
            }
        }           

        return accIdToNodeAttrIdMap;

    }
 /***************************************************************************************************** 
    Method name  : getParentFundAccounts
    Description  : Method to query parent fund/Virtual Corp accounts
    Return Type  : Map<Id,Account>
    Parameter    : List<Id>   
    Created By   : Mayuri Dhanjani              
    Date         : 25 Aug, 2023    
    ******************************************************************************************************/

    public static void getParentFundAccounts(Set<Id> parentFundAcctIds, Set<Id> programIds)
    {
       
    
        for(Account acc : [Select id,Name,RecordTypeId,RecordType.DeveloperName,Core_Geo__c,Core_MDF_Payment_Type_nm__c,Core_MDF_Virtual_Corp_Account_Id__c,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName,Core_MDF_Active_Ind__c from Account where Id IN : parentFundAcctIds])
        {
            parentAccIdToParentAccMap.put(acc.Id,acc);
          
            if(acc.RecordTypeId == masterRecrodtypeId)
            {
                ultimateAccountIds.add(acc.Id);
                parentAccountToUltimateAccountmap.put(acc.Id,acc.Id);
            }
            else
            {
                ultimateAccountIds.add(acc.Core_MDF_CoMarketing_Ultimate_Account__c);
                parentAccountToUltimateAccountmap.put(acc.Id,acc.Core_MDF_CoMarketing_Ultimate_Account__c);

            }
        }
    System.debug('ultimateAccountIds ---'+ultimateAccountIds);
        for(Account acc : [Select id,Name,Core_Geo__c,RecordType.DeveloperName,Core_MDF_Virtual_Corp_Account_Id__c,Core_MDF_CoMarketing_Ultimate_Account__c,Core_MDF_Channel_Program__c,Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName from Account where Core_MDF_Parent_Fund_Account__c IN : ultimateAccountIds and Core_MDF_Channel_Program__c IN: programIds and RecordTypeId =: coMarketingRecordtypeId and Core_MDF_Parent_Fund_Account__r.RecordTypeId =: masterRecrodtypeId and Core_MDF_Active_Ind__c = TRUE])
        {
            String key = String.valueOf(acc.Core_MDF_CoMarketing_Ultimate_Account__c) + String.valueOf(acc.Core_MDF_Channel_Program__c);
            virtualCorpIdToVirtualCorpAccMap.put(key,acc);
            //added by Jahnavi K - payment type and region field mandatory for IPA and cogtm program on VC
            virtualCorpToUltimateAccountMap.put(acc.id,acc);
        }
        System.debug('virtualCorpToUltimateAccountMap--'+virtualCorpToUltimateAccountMap);
    
    }

    /***************************************************************************************************** 
    Method name  : processPGMCreation
    Description  : This method is used to create or Inactivate PGM records when Unified Id or IPA Active flag changed
    Return Type  : Void
    Parameter    : Map<Id,Account> Trigger.newMap, Map<Id,Account> Trigger.OldMap 
    Created By   : JB               
    Date         : 02/16/2022      This method is used to create or Inactivate PGM records when Unified Id or IPA Active flag changed
    ******************************************************************************************************/
    public static void processPGMCreation(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap) {

        try{
            boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
            List<Core_MDF_Account_PGM_Sync__e> accountPgmSyncPE = new List<Core_MDF_Account_PGM_Sync__e>();            
            for(Account newAccount : newAccountMap.values()){
                if(newAccount.RecordTypeId == masterRecrodtypeId && oldAccountMap != null && oldAccountMap.containsKey(newAccount.Id) &&
                    (newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c != oldAccountMap.get(newAccount.Id).Core_Intel_Partner_Alliance_PartnerGroup__c ||
                    (newAccount.Core_Unified_Global_Customer_BP_Id__c != oldAccountMap.get(newAccount.Id).Core_Unified_Global_Customer_BP_Id__c) ||
                    (newAccount.Core_IPA_One_Partner_Id__c != oldAccountMap.get(newAccount.Id).Core_IPA_One_Partner_Id__c))){

                    Account oldAccount = oldAccountMap.get(newAccount.Id);
                    Account accountWithOldValues = new Account(Id = oldAccount.Id, Core_MDF_CoMarketingActive__c = oldAccount.Core_MDF_CoMarketingActive__c , Core_Intel_Partner_Alliance_PartnerGroup__c = oldAccount.Core_Intel_Partner_Alliance_PartnerGroup__c, Core_IPA_One_Partner_Id__c = oldAccount.Core_IPA_One_Partner_Id__c);
                    //if(isUnifiedIdEnabled){
                        accountWithOldValues.Core_Unified_Global_Customer_BP_Id__c = oldAccount.Core_Unified_Global_Customer_BP_Id__c;
                        //SObject accountWithOldValues = new Account(Id = oldAccount.Id, Core_MDF_CoMarketingActive__c = oldAccount.Core_MDF_CoMarketingActive__c , Core_Intel_Partner_Alliance_PartnerGroup__c = oldAccount.Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Unified_Global_Customer_BP_Id__c = oldAccount.Core_Unified_Global_Customer_BP_Id__c);
                       // accountPgmSyncPE.add(new Core_MDF_Account_PGM_Sync__e(Core_MDF_DML_Operation_Type_txt__c = 'Update', Core_MDF_Object_API_Name__c = 'Account', Core_MDF_JSON_Data__c = JSON.serialize(accountWithOldValues)));
                    //}
                        
                    /*else{
                    //Prepare data for Platform Event
                    accountWithOldValues.Core_Prime_Id__c = oldAccount.Core_Prime_Id__c;
                    //SObject accountWithOldValues = new Account(Id = oldAccount.Id, Core_MDF_CoMarketingActive__c = oldAccount.Core_MDF_CoMarketingActive__c , Core_Intel_Partner_Alliance_PartnerGroup__c = oldAccount.Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Prime_Id__c = oldAccount.Core_Prime_Id__c);
                    //accountPgmSyncPE.add(new Core_MDF_Account_PGM_Sync__e(Core_MDF_DML_Operation_Type_txt__c = 'Update', Core_MDF_Object_API_Name__c = 'Account', Core_MDF_JSON_Data__c = JSON.serialize(accountWithOldValues)));
                    }*/
                    accountPgmSyncPE.add(new Core_MDF_Account_PGM_Sync__e(Core_MDF_DML_Operation_Type_txt__c = 'Update', Core_MDF_Object_API_Name__c = 'Account', Core_MDF_JSON_Data__c = JSON.serialize(((SObject)accountWithOldValues))));
                }
            }           

            if(!accountPgmSyncPE.isEmpty()){
                //Publish Platform event(Core_MDF_Account_PGM_Sync__e)
                List<Database.SaveResult> results = EventBus.publish(accountPgmSyncPE);
                // Inspect publishing result for each event
            }
        }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}

    }
    
/***************************************************************************************************** 
    Method name  : virtualCorpInsertionLogic
    Description  : Validation on virtual corp Insertion
    Return Type  : void
    Parameter    : List<Id> AccountIds, Set<Id> ProgramsIds, Map<Id,Account> parentToRecordType   
    Created By   : Mayuri Dhanjani              
    Date         : 25 Aug, 2023    
    ******************************************************************************************************/
public static void virtualCorpInsertionLogic(List<Account> newList, Set<Id> programIds){

        Set<Id> parentFundAcctIds  = new Set<Id>();
        //List to store Account
        List<Account> accList = New List<Account>();
        Set<Id> parentAccIds = new Set<Id>();
        //Map to store UniqueKey and Account Name
        Map<String,String> uniqueKeyToAccName = new Map<String,String>();
        Map<String,Core_MDF_Account_Onboarding__c> uniqueKeyToOnboarding = new  Map<String,Core_MDF_Account_Onboarding__c>();
        try{
           
            //check if input parameters are not null
            if(!newList.isEmpty() && !programIds.isEmpty() && !parentAccIdToParentAccMap.isEmpty()) { 
                //Querying Account Onboarding record
                for(Core_MDF_Account_Onboarding__c accOnboard : [Select Id, Core_MDF_Account__c,Core_MDF_Channel_Program__c from Core_MDF_Account_Onboarding__c where Core_MDF_Account__c IN : parentAccIdToParentAccMap.keySet() and Core_MDF_Account__r.RecordTypeId =: masterRecrodtypeId and Core_MDF_Channel_Program__c IN: programIds and Core_MDF_Type__c =: Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IntelAccount')])
                {
                       String key = String.valueOf(accOnboard.Core_MDF_Account__c) + String.valueOf(accOnboard.Core_MDF_Channel_Program__c);
                       uniqueKeyToOnboarding.put(key,accOnboard);
                }

                for(Account acc : newList){
                    
                  /*  if(parentAccIdToParentAccMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && (parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).RecordTypeId == masterRecrodtypeId))
                    {
                        String ultimateAccToProgKey = String.valueOf(acc.Core_MDF_Parent_Fund_Account__c) + String.valueOf(acc.Core_MDF_Channel_Program__c);
                      //Restrict direct Virtual Corp Creation 
                        if(!uniqueKeyToOnboarding.containsKey(ultimateAccToProgKey)){
                            acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DirectVCInsertionError'));
                        } 
                      //Restrict duplicate virtual Corp Creation
                      if(virtualCorpIdToVirtualCorpAccMap.containsKey(ultimateAccToProgKey) && virtualCorpIdToVirtualCorpAccMap.get(ultimateAccToProgKey) != null){
                            acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram1')+' '+virtualCorpIdToVirtualCorpAccMap.get(ultimateAccToProgKey).Name+' '+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram2'));
                        }
                    }*/  
                    //ATHR FIX 
                    if (!(parentAccIdToParentAccMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).RecordTypeId == masterRecrodtypeId)) {
                        continue;  
                    }
                    String ultimateAccToProgKey = String.valueOf(acc.Core_MDF_Parent_Fund_Account__c) + String.valueOf(acc.Core_MDF_Channel_Program__c);
                    //Restrict direct Virtual Corp Creation 
                    if(!uniqueKeyToOnboarding.containsKey(ultimateAccToProgKey)){
                        acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_DirectVCInsertionError'));
                    } 
                    //Restrict duplicate virtual Corp Creation
                    if(virtualCorpIdToVirtualCorpAccMap.containsKey(ultimateAccToProgKey) && virtualCorpIdToVirtualCorpAccMap.get(ultimateAccToProgKey) != null){
                        acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram1')+' '+virtualCorpIdToVirtualCorpAccMap.get(ultimateAccToProgKey).Name+' '+Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MultipleVCForSameProgram2'));
                    }//ATHR End
                }  
                
            }
                
            }catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }  
    
    /***************************************************************************************************** 
    Method name  : updateHostRegionOnNodeAccounts
    Description  : To stamp the host region on Node/Sub node accounts from their parent fund account(before insert)
    Return Type  : VOID
    Parameter    : List Trigger.new    
    Created By   : VB                 
    Date         : 29 Nov, 2022     
    ******************************************************************************************************/
    public static void updateHostRegionOnNodeAccounts(List<Account> listNewAccount) {
        //Set to Store the parent fund account Id's of a coMarketing Account
        Set<Id> parentFundAccountIdsSet = new Set<Id>();
        List<Account> accountsWithoutSubGeo = new List<Account>();
        //Map to Store the parent fund account Id as key as Parent fund account record as value of any node account
        Map<Id,Account> coMarkAccIdToCoMarkAccMap = new Map<Id,Account>();
        try {
            //Get the channel Program id of IPA program
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
            // Get the parent fund account Id of node accounts
                for(Account acc : listNewAccount){

                        if(acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfIPA.Core_MDF_Program_ID__c && acc.Core_Sub_Geo__c != null ) {
                            acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubRegion_Inapplicable_Message'));
                        } else {
                            accountsWithoutSubGeo.add(acc);
                        }
                    
                }

        //stamp the host region/Payment Type from its parent account for the parent fund account matching records
        //ATHR - Deeply Nested if 16209
        if(parentAccIdToParentAccMap.isEmpty()) return;
        //if(!parentAccIdToParentAccMap.isEmpty()) {
            for(Account acc: accountsWithoutSubGeo) {
                //ATHR - Deeply Nested if 16209
                if(!parentAccIdToParentAccMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) || parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).RecordTypeId != coMarketingRecordTypeId || parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Id != acc.Core_MDF_Parent_Fund_Account__c) continue;

                 //if(parentAccIdToParentAccMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && (parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).RecordTypeId == coMarketingRecordTypeId) && (parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Id == acc.Core_MDF_Parent_Fund_Account__c)) {    
                    
                    if(acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfIPA.Core_MDF_Program_ID__c){
                        //ATHR - Deeply Nested if 16209
                        if(acc.Core_Geo__c != null && parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c != acc.Core_Geo__c) {
                            //if(parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c != acc.Core_Geo__c) {
                                acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RegionMismatch_Error'));
                            /*} else {
                                acc.Core_Geo__c = parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c;
                            }*/
                        } else {
                            acc.Core_Geo__c = parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c;
                        }
                        
                    }
                    //ATHR - Deeply Nested if 16209
                    if(acc.Core_MDF_Payment_Type_nm__c != null && parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c != acc.Core_MDF_Payment_Type_nm__c && !Core_MDF_Utility.byPassFeature('bypassPaymentTypeErrorOnAccount')){
                        //if(parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c != acc.Core_MDF_Payment_Type_nm__c && !Core_MDF_Utility.byPassFeature('bypassPaymentTypeErrorOnAccount'))
                        //{
                            acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PaymentTypeMismatch_Error'));                          
                        /*}else{
                            acc.Core_MDF_Payment_Type_nm__c =  parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c;
                        }*/
                    }else{
                        acc.Core_MDF_Payment_Type_nm__c =  parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c;
                    }                   

                    String key = String.valueOf(parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_MDF_CoMarketing_Ultimate_Account__c) + String.valueOf(acc.Core_MDF_Channel_Program__c);
                    
                    if(virtualCorpIdToVirtualCorpAccMap.containsKey(key) && virtualCorpIdToVirtualCorpAccMap.get(key) != null){
                        acc.Core_MDF_Virtual_Corp_Account_Id__c = virtualCorpIdToVirtualCorpAccMap.get(key).Id;
                    }
                     //ATHR Fix
                     //acc.Core_MDF_Virtual_Corp_Account_Id__c = (virtualCorpIdToVirtualCorpAccMap.containsKey(key) && virtualCorpIdToVirtualCorpAccMap.get(key) != null)  ? virtualCorpIdToVirtualCorpAccMap.get(key).Id : acc.Core_MDF_Virtual_Corp_Account_Id__c;//if the key exists and is not null then virtualCorpIdToVirtualCorpAccMap.get(key).Id else no change                    
                //}
                
            }
        //} 
    }catch(Exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    /***************************************************************************************************** 
    Method Name: validateMDFParentFundAccChanges
    @return  :  Void
    Created By: SH                  
    Date: 09 MAR, 2022     
    ******************************************************************************************************/
    public static void validateMDFParentFundAccChanges(List<Account> newList, Map<Id,Account> oldMap){
        //To By-pass the method execution
        if(Core_MDF_Utility.byPassFeature('byPassMDFPFAChangesMethod')){
            return;
        }
        //List to store Parent Fund Accounts Ids
        List <Id> accountIds = new List<Id>();
        if(newList.size()>0 && UserInfo.getUserType() != System.Label.Core_MDF_Partner_User_Type){
            for(Account acc : newList) {
                //Check if Parent fund Account value get change
                if(oldMap != null && oldMap.size() > 0  && acc.RecordTypeId == coMarketingRecordtypeId && oldMap.get(acc.Id).Core_MDF_Parent_Fund_Account__c != acc.Core_MDF_Parent_Fund_Account__c){
                    accountIds.add(acc.Id);
                }
            }
        }
        //ATHR - Deeply Nested if 16209
        if (accountIds.isEmpty()) return;
        //if(accountIds != NULL && accountIds.size()>0){
            //List to store all child accounts
            List <Account> hierarchyList = [SELECT Id,RecordType.DeveloperName,Name,Core_MDF_Enabled_Auto_Transfer__c, Core_MDF_Auto_Transfer_Account__c,Core_MDF_Parent_Fund_Account__c , Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                                        Core_MDF_External_Group_Id__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c ,Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c,
                                        Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c
                                        FROM Account WHERE RecordTypeId =: coMarketingRecordtypeId  AND (Id IN : accountIds 
                                                                                                                 OR Core_MDF_Parent_Fund_Account__c IN : accountIds 
                                                                                                                 OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN : accountIds  
                                                                                                                 OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN : accountIds 
                                                                                                                 OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN : accountIds)];
            
            //Check if child node list is not empty
            //ATHR - Deeply Nested if 16209
            if (hierarchyList.isEmpty()) return;
            //if(hierarchyList != NULL && hierarchyList.size()>0){
                for(Account acctObj : newList){
                    //List to store Auto Transfer Enable Nodes
                    List<String> errorNode = new List<String>();  
                    for(Account acc : hierarchyList){
                        //Retail sharing
                        //ATHR - Deeply Nested if 16209
                        if(!Core_MDF_Utility.byPassFeature('byPassRetailCampSharingOnPFAChange') && acc.Id == acctObj.Id && acc.Core_MDF_External_Group_Id__c != NULL && acc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c == 'Retail Marketing Funds'){
                            //if(acc.Id == acctObj.Id && acc.Core_MDF_External_Group_Id__c != NULL && acc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c == 'Retail Marketing Funds'){
                                accIdToExtGrpIdMap.put(acc.Id, new set<Id>{acc.Core_MDF_External_Group_Id__c});
                                if(acc.Core_MDF_Parent_Fund_Account__c != null && acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c != null){
                                    if(accIdToExtGrpIdMap.containsKey(acc.id)){
                                        accIdToExtGrpIdMap.get(acc.id).add(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c);
                                    }else{
                                        accIdToExtGrpIdMap.put(acc.id, new set<Id>{acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c});
                                    }
                                }
                                if(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c != null 
                                && acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c != null)
                                {
                                    if(accIdToExtGrpIdMap.containsKey(acc.id)){
                                        accIdToExtGrpIdMap.get(acc.id).add(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c);
                                    }else{
                                        accIdToExtGrpIdMap.put(acc.id, new set<Id>{acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_External_Group_Id__c});
                                    }
                                }
                            //}
                        }
                        //check if child nodes parent match with editing node  
                        if(acc.Core_MDF_Parent_Fund_Account__c == acctObj.Id || acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == acctObj.Id 
                           || acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == acctObj.Id 
                           || acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == acctObj.Id
                          )
                        {
                            //check if Enable Auto Transfer is true and Auto Trandfer Account is not empty 
                            if(acc.Core_MDF_Enabled_Auto_Transfer__c == True && acc.Core_MDF_Auto_Transfer_Account__c != NULL){
                                
                                if(acc.Core_MDF_Auto_Transfer_Account__c == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c && acctObj.id == acc.Core_MDF_Parent_Fund_Account__c){           
                                    //acctObj.Core_MDF_Parent_Fund_Account__c.addError('Parent Fund Account cannot be changed if Enable Auto Transfer/ Auto-Transfer Account is populated.1');
                                    errorNode.add(acc.Name);
                                }
                                else if(acc.Core_MDF_Auto_Transfer_Account__c == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c && 
                                        (acctObj.id == acc.Core_MDF_Parent_Fund_Account__c || acctObj.id == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c)){
                                            //acctObj.addError('Parent Fund Account cannot be changed if Enable Auto Transfer/ Auto-Transfer Account is populated.2'+acc.Name);
                                            errorNode.add(acc.Name);
                                        }
                                else if(acc.Core_MDF_Auto_Transfer_Account__c == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c 
                                        && (acctObj.id == acc.Core_MDF_Parent_Fund_Account__c || acctObj.id == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c || acctObj.id == acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c)){  
                                            //acctObj.Core_MDF_Parent_Fund_Account__c.addError('Parent Fund Account cannot be changed if Enable Auto Transfer/ Auto-Transfer Account is populated.3');
                                            errorNode.add(acc.Name);
                                        }
                            }
                            // check if Parent Fund Account is child account
                            if(acctObj.Core_MDF_Parent_Fund_Account__c == acc.id){
                                acctObj.Core_MDF_Parent_Fund_Account__c.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Child_ParenFundAccount'));
                            }
                            
                        }
                    }
                    //check if atleast one Auto Transfer Enable node available
                    if(errorNode != NULL && errorNode.size()>0){ 
                        String errorString = String.join(errorNode, ', ');
                        acctObj.Core_MDF_Parent_Fund_Account__c.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EnableAutoTransfer_error')+' '+errorString);
                    }
                }
            //}
        //}
    }
    
    /***************************************************************************************************** 
    Method name  : restrictHostRegionUpdateOnNodeAccounts
    Description  : To restrict the host region update on Node/Sub node accounts if its not same as its parent(before update)
    Return Type  : VOID
    Parameter    : Map<Id,Account> Trigger.NewMap, Map<Id,Account> Trigger.OldMap   
    Created By   : VB                 
    Date         : 12 Dec, 2022     
    ******************************************************************************************************/    
    public static void restrictHostRegionUpdateOnNodeAccounts(Map<Id,Account> newAccountMap, Map<Id,Account> accRecsOldMap) {
        try {
            System.debug('NewAccountMap---'+newAccountMap);
            Set<Id> parentFundAccountIdsSet = new Set<Id>();
            List<Account> geoUpdatedAccountsList = new List<Account>();
            List<Account> updatePaymentTypeAccountList = new List<Account>();
            List<Account> paymentTypeupdateAccList = new List<Account>();
            List<String> paymentTypeSupportedProgramIds = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_PaymentTypeSupportedProgramIds');
            //Get the channel Program id of IPA program
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
            Core_MDF_ChannelProgram__mdt channeProgramDetailsOFCogtm = Core_MDF_ChannelProgram__mdt.getInstance('Co_GTM');
            Boolean hasAccessToUpdateGeo = FeatureManagement.checkPermission('Core_MDF_CCP_users_with_Region_Field_Edit_Access_on_CoMarketing_Account');
            // Loop through the Accounts
            for(Account acc : newAccountMap.values()){

                //if (acc.RecordTypeId == coMarketingRecordTypeId && !acc.Core_MDF_CoMarketingActive__c && !acc.Core_MDF_CoMarketingAgency__c) { ATHR Comment
                //ATHR Fix
                if (!(acc.RecordTypeId == coMarketingRecordTypeId && !acc.Core_MDF_CoMarketingActive__c && !acc.Core_MDF_CoMarketingAgency__c)) {
                    continue;
                }
                    
                  if(acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfIPA.Core_MDF_Program_ID__c ){
                    // sub-geo is updated/selected, throw error. Core_MDF_SubRegion_Inapplicable_Message - Sub-Region is not applicable for Intel Partner Alliance Program.
                    if(accRecsOldMap != null && accRecsOldMap.get(acc.Id).Core_Sub_Geo__c != acc.Core_Sub_Geo__c) {
                        acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SubRegion_Inapplicable_Message'));
                    } 
                    //geo is updated without valid user access. Core_MDF_UserPermissionToInactivate - This user does not have permissions to perform this action.
                    else if(accRecsOldMap != null && accRecsOldMap.get(acc.Id).Core_Geo__c != acc.Core_Geo__c && !hasAccessToUpdateGeo) {
                        acc.addError(Label.Core_MDF_UserPermissionToInactivate);
                    }
                    //geo is updated with valid user access - store the accounts and accounts parent Id
                    else if(accRecsOldMap != null && accRecsOldMap.get(acc.Id).Core_Geo__c != acc.Core_Geo__c && hasAccessToUpdateGeo) {
                        geoUpdatedAccountsList.add(acc);
                    }
                  }
                  //added by Jahnavi K -- payment type and region should be mandatory for IPA Program on virtual corp
                  //Payment Type field mandatory for co-gtm program on virtual corp
                  if(ultimateAccountIds.contains(acc.Core_MDF_Parent_Fund_Account__c)){
                    if(acc.Core_Geo__c == null && acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfIPA.Core_MDF_Program_ID__c){
                        acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MandateRegionOnVirtualCorp'));
                    }else if(acc.Core_MDF_Payment_Type_nm__c == null && paymentTypeSupportedProgramIds.contains(acc.Core_MDF_Channel_Program__c)){
                        acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_MandatePaymentTypeOnVirtualCorp'));
                    }
                }
                  if(accRecsOldMap != null || acc.Core_MDF_Channel_Program__c == channeProgramDetailsOFCogtm.Core_MDF_Program_ID__c) 
                  {
                    if((accRecsOldMap != null || acc.Core_MDF_Channel_Program__c == channeProgramDetailsOFCogtm.Core_MDF_Program_ID__c )&& accRecsOldMap.get(acc.Id).Core_MDF_Payment_Type_nm__c != acc.Core_MDF_Payment_Type_nm__c){
                        paymentTypeupdateAccList.add(acc);
                    }
                    updatePaymentTypeAccountList.add(acc);
                  }
               //}  ATHR comment
            }

            
            //Throw an error 'Region Should be Same as its Parent Account', if the region on node/sub-node accounts is not same as its Parent Account's region
            //ATHR - Deeply Nested if 16209
            if(parentAccIdToParentAccMap.isEmpty()) return;
            //if(!parentAccIdToParentAccMap.isEmpty()) {
                    for(Account acc : updatePaymentTypeAccountList){
                        
                        if(parentAccIdToParentAccMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && (parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).RecordTypeId == coMarketingRecordTypeId) && (parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Id == acc.Core_MDF_Parent_Fund_Account__c)) {
                           //ATHR - Deeply Nested if 16209
                           if(geoUpdatedAccountsList.contains(acc) && ((newAccountMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && newAccountMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c != acc.Core_Geo__c) || (!newAccountMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c != acc.Core_Geo__c))) 
                           {
                               /*if((newAccountMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && 
                                newAccountMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c != acc.Core_Geo__c)  || 
                               (!newAccountMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && 
                               parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c != acc.Core_Geo__c)) {*/
                                    acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RegionMismatch_Error')); //Core_MDF_RegionMismatch_Error - Region Should be Same as its Parent Account
                                //} 
                           }
                           if(paymentTypeupdateAccList.contains(acc) && !Core_MDF_Utility.byPassFeature('bypassPaymentTypeErrorOnAccount') && ((newAccountMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && newAccountMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c != acc.Core_MDF_Payment_Type_nm__c)  || (!newAccountMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c != acc.Core_MDF_Payment_Type_nm__c)))
                           {
                               /*if((newAccountMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && 
                                newAccountMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c != acc.Core_MDF_Payment_Type_nm__c)  || 
                               (!newAccountMap.containsKey(acc.Core_MDF_Parent_Fund_Account__c) && 
                               parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c != acc.Core_MDF_Payment_Type_nm__c)) {*/
                                    acc.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PaymentTypeMismatch_Error')); 
                                //} 
                           }
                           
                        }
                    }
                
                //}
        } catch(Exception ex) {Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    /*************************************************************************************************************
   * Method Name:                                            createGroupForComarketingAccount
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – AS                          19/08/2020       This method is used Create Group on Co-Marketing Account
************************************************************************************************************/
    public static List<Account> createGroupForComarketingAccount(List<Account> accountList){
        //To Store Co-Marketing Accounts
        List<Account> coMarkAccountToBeProcessed= new List<Account>();
              
        if(accountList!=null && accountList.size()>0){
            //Method to Create Groups for Co-Marketing Accounts
            Core_MDF_Account_Utility.createGroupForAccountNode(accountList);
        }
        return accountList;
    }
    
    /*************************************************************************************************************
   * Method Name:                                            sharingWithNewAcctGrps
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – AS                          19/08/2020       This method is used Call Batch Class for Node Sharing
************************************************************************************************************/
    public static void sharingWithNewAcctGrps(List<Account> accountList){        
       
        if(accountList!=null && accountList.size()>0){
           Id batchInstanceId = Database.executeBatch(new Core_MDF_Batch_SharingWithNewAcctGrp(accountList)); 
        }
    }
    
    /*************************************************************************************************************
   * Method Name:                                            createNodeShrngGrpAndUpdAccNodeAttr
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – NK                          22/02/2022       This method is used Create PNUM based External sharing group and
                                                             Share account to  that group.
                                            29/04/2025       Included the logic to create the Account node attribute creation
************************************************************************************************************/
    Public static void createNodeShrngGrpAndUpdAccNodeAttr(Map<Id,Account> newMap){
        try{
            Id coMarketingRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId();
            Map<Id,Group> accIdGrpNameMap = new Map<Id,Group>();
            //used to store Node Account Ext PNUM Group name and All Access Group Name
            Map<String,String> nodeGrpToAllAccessGrpNameMap = new Map<String,String>();
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfCCF = Core_MDF_ChannelProgram__mdt.getInstance('Client_Co_Marketing_Fund');
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfDCF = Core_MDF_ChannelProgram__mdt.getInstance('Data_Center_Co_Marketing_Fund');
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfEEF = Core_MDF_ChannelProgram__mdt.getInstance('Ecosystem_Extension_Fund');

            List<Group> allAccessGroupList = new List<Group>();
            Map<String,Id> ultimateAccProgamAllAccessGrpIdMap = new Map<String,Id>();
            //query PGM records with ultimate acc Ids
            System.debug('ultimateAccountIds---'+ultimateAccountIds);
            for(Core_MDF_Partner_Group_Mapping__c pgm : [select Core_MDF_Account__c,Core_MDF_Channel_Program__c,Core_MDF_All_Access_Group_Id__c
                                                        from Core_MDF_Partner_Group_Mapping__c 
                                                        where Core_MDF_Account__c in : ultimateAccountIds 
                                                        and Core_MDF_Inactive_Ind__c = false 
                                                        and Core_MDF_Type_of_Access__c='External'
                                                        and Core_MDF_All_Access_Group_Id__c != null]){
                                                            System.debug('pgm--'+pgm);
                
                String key = String.valueOf(pgm.Core_MDF_Account__c)+String.valueOf(pgm.Core_MDF_Channel_Program__c);
                System.debug('Key--'+key);
                ultimateAccProgamAllAccessGrpIdMap.put(key,pgm.Core_MDF_All_Access_Group_Id__c);
            }
            for(Account acc : newMap.values()){
                if(acc.RecordTypeId == coMarketingRecordtypeId){
                    Group newNodeGroup = new Group();
                    newNodeGroup.name = 'CCP_'+acc.Id+'_EXT_GRP';
                    newNodeGroup.DeveloperName = 'Core_MDF_CCP_'+acc.Id+'_EXT_GRP'; 
                    newNodeGroup.DoesIncludeBosses = false;
                    accIdGrpNameMap.put(acc.Id,newNodeGroup);
                    
                    if(acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfCCF.Core_MDF_Program_ID__c || acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfDCF.Core_MDF_Program_ID__c || acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfEEF.Core_MDF_Program_ID__c){
                        String ultimateAccIdProgram = String.valueOf(parentAccountToUltimateAccountmap.get(acc.Core_MDF_Parent_Fund_Account__c))+String.valueOf(acc.Core_MDF_Channel_Program__c);
                        System.debug('ultimateAccIdProgram---'+ultimateAccIdProgram);
                        nodeGrpToAllAccessGrpNameMap.put(newNodeGroup.DeveloperName,ultimateAccProgamAllAccessGrpIdMap.get(ultimateAccIdProgram));
                        System.debug('nodeGrpToAllAccessGrpNameMap---'+nodeGrpToAllAccessGrpNameMap);
                    }

                }
            }
            
            if(!accIdGrpNameMap.isEmpty()){
                Database.insert(accIdGrpNameMap.values());
            }
            
            Map<Id, List<Id>> accIdGrpIdListMap = new Map<Id, List<Id>>();
            for(Id accId : accIdGrpNameMap.keyset()){
                accIdGrpIdListMap.put(accId,new List<Id>{accIdGrpNameMap.get(accId).Id});
                System.debug('accIdGrpIdListMap --- '+accIdGrpIdListMap);
            }
            
            //Adding All Access Group as a group member to Node External Group
            List<GroupMember> gmemList = new List<GroupMember>();
            List<String> serializedGroupMembers = new List<String>();
            List<Core_MDF_Bulk_Transaction__e> RecordList = new List<Core_MDF_Bulk_Transaction__e>();
            for(Group g:accIdGrpNameMap.values()){
                System.debug('g----'+g);
                if(nodeGrpToAllAccessGrpNameMap.get(g.developerName)!= null){
                    System.debug('in line 594--');
                    GroupMember gm = new GroupMember();
                    gm.UserOrGroupId = nodeGrpToAllAccessGrpNameMap.get(g.developerName);
                    gm.GroupId = g.Id;
                    gmemList.add(gm); 
                    System.debug('gm---'+gm);
                    Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e(); 
                    evtObj.Core_MDF_JSON_Data__c = JSON.serialize(gm); 
                    evtObj.Core_MDF_Object_Name__c = 'GroupMember';
                    RecordList.add(evtObj);
                    String serializedGm = JSON.serialize(gm);
                    serializedGroupMembers.add(serializedGm);
                }
            } 
            if(!RecordList.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(RecordList);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } 
                else { 
                    for(Database.Error err : sr.getErrors()) { 
                        System.debug('Error returned: ' + err.getStatusCode() ); 
                    }
                }
            }
         }
             /*if(!serializedGroupMembers.isEmpty()){
                //insertGrpMem(serializedGroupMembers);
            }*/
            
            //Account node attribute creation- WW24'2025
            Map<Id, Id> accIdToNodeAttrIdMap = new Map<Id, Id>();
            if(!Core_MDF_Utility.byPassFeature('Bypass_AccNodeAttr_Creation')){
                accIdToNodeAttrIdMap = createAccountNodeAttr(newMap);
            }

            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Account',accIdGrpIdListMap, 'Edit','Manual','Read');
            List<AccountShare> accountShareList = Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst); 
            List<Account> accToUpdate = new List<Account>();
            for(account acc : [select id,Core_MDF_External_Group_Id__c,Core_MDF_Account_Node_Attribute_Id__c from Account where Id in:accIdGrpNameMap.keyset()]){
                acc.Core_MDF_External_Group_Id__c = accIdGrpNameMap.get(acc.Id).Id;
                if(accIdToNodeAttrIdMap != null && accIdToNodeAttrIdMap.containsKey(acc.Id) && accIdToNodeAttrIdMap.get(acc.Id)!=null){
                    acc.Core_MDF_Account_Node_Attribute_Id__c = accIdToNodeAttrIdMap.get(acc.Id);
                }
                accToUpdate.add(acc);
            }
            Database.update(accToUpdate); 

        }catch (Exception e) {Core_MDF_CCP_UtilityClass.logError(e);
       }
    }
    /***************************************************************************************************
    Method Name: insertGrpMem
    @return : void
    Created By: AN
    Date: 12 Dec, 23
    ****************************************************************************************************/
    /*@future
    public static void insertGrpMem(List<String> serializedGroupMembers){
        List<GroupMember> groupMembers = new List<GroupMember>();
        if(!serializedGroupMembers.isEmpty()){ 
        for (String serializedGm : serializedGroupMembers) {
            GroupMember groupMember = (GroupMember)JSON.deserialize(serializedGm, GroupMember.class);
            groupMembers.add(groupMember);
        }
        insert groupMembers;r
        }
    }*/
    /****************************************************************************************************
    Method Name: validateAccountHierarchy
    @return  :  Void
    Created By: SH                  
    Date: 09 MAR, 2022     
    ******************************************************************************************************/
    public static void validateAccountHierarchy(List<Account> newList,Map<Id,Account> oldMap){ 
        //To By-pass the method execution
        if(Core_MDF_Utility.byPassFeature('byPassValidateAccountHierarchy')){
            return;
        }
        //List to store Parent Fund Account
        List<Account> accList = new List<Account>();
        if(newList.size()>0 && UserInfo.getUserType() != System.Label.Core_MDF_Partner_User_Type){
            for(Account acc : newList){
                //Check if Parent fund Account value get change
                if(oldMap != null && oldMap.size() > 0 && acc.RecordTypeId == coMarketingRecordtypeId && oldMap.get(acc.Id).Core_MDF_Parent_Fund_Account__c != acc.Core_MDF_Parent_Fund_Account__c){
                    accList.add(acc);
                }
            }
        }
        //ATHR - Deeply Nested if 16209
        if(accList == NULL || accList.isEmpty()) return;
        //if(accList != NULL && accList.size() > 0){
            if(!Core_MDF_Utility.byPassFeature('byPassRetailCampSharingOnPFAChange')){
                checkRetailCampaignShare(accList);
            }
            
            List <Account> hierarchyList = [Select id,RecordType.DeveloperName,Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c, Core_MDF_Parent_Fund_Account__c, 
                                    Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, 
                                    Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                                    Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                                    Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                                    Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c                           
                                    from Account 
                                    where  RecordTypeId =: coMarketingRecordtypeId  AND (Core_MDF_Parent_Fund_Account__c IN: accList 
                                                                                         OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: accList 
                                                                                         OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: accList 
                                                                                         OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: accList 
                                                                                         OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: accList 
                                                                                         OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: accList)];
            
            //ATHR - Deeply Nested if 16209
            if(hierarchyList == NULL || hierarchyList.isEmpty()) return;
            //if(hierarchyList != NULL && hierarchyList.size()>0){
                for(Account accInst : accList){
                    for(Account childAcc : hierarchyList){
                        if(childAcc.Core_MDF_Parent_Fund_Account__c == accInst.Id || childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Id ||
                           childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c ==  accInst.Id || childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Id ||
                           childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Id ||
                           childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Id)
                        {
                            //Check if account is not retail and Hierarchy level exceeds five
                            if(childAcc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c != 'Retail Marketing Funds' && 
                               childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Core_MDF_CoMarketing_Ultimate_Account__c)
                            {
                                accInst.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Five_levels_hierarchy'));
                                break;
                                
                                //Check if account is retail and Hierarchy level exceeds three
                            }else if(childAcc.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c == 'Retail Marketing Funds' && 
                                     childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c == accInst.Core_MDF_CoMarketing_Ultimate_Account__c)
                            {
                                accInst.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Retail_Three_level_hierarchy'));
                                break;
                            }
                        }
                    }
                }
            //}
        //}
    }
    
    /***************************************************************************************************** 
    Method name  : updateHostRegionAfterVirtualCorpUpdate
    Description  : when a virtual corp account' host region/payment type is changed, update the same to its child accounts
    Return Type  : VOID
    Parameter    : List Trigger.new, Map<Id,Account> Trigger.OldMap    
    Created By   : VB                 
    Date         : 29 Nov, 2022     
    ******************************************************************************************************/
    public static void updateHostRegionAfterVirtualCorpUpdate(List<Account> listNewAccount, Map<Id,Account> accRecsOldMap) {
        //Set to Store the coMarketing Account Ids
        Set<Id> coMarketingAccountIds = new Set<Id>();
        //Map to store the virtual corp account id as key and its details as value
        Map<Id, Account> virtualCorpIdsToVirtualCorpMap = new Map<Id, Account>();
        //List to store the accounts to update
        List<Account> childAccountsToBeUpdatedList = new List<Account>();
        Map<Id, Account> childAccIdsToChildAccMap = new Map<Id, Account>();
        List<Account> hostGeoUpdatedAccList = new List<Account>();
        List<Account> newAccList = new List<Account>();
        try {
            //Get the channel Program id of IPA program
            Core_MDF_ChannelProgram__mdt channelProgramDetailsOfIPA = Core_MDF_ChannelProgram__mdt.getInstance('Intel_Partner_Alliance');
            Core_MDF_ChannelProgram__mdt channeProgramDetailsOFCogtm = Core_MDF_ChannelProgram__mdt.getInstance('Co_GTM');
            // Get the account Ids of the virtual corp accounts on update of host region field
            for(Account acc : listNewAccount){
                if (acc.RecordTypeId == coMarketingRecordTypeId && (acc.Core_MDF_Channel_Program__c == channelProgramDetailsOfIPA.Core_MDF_Program_ID__c  || acc.Core_MDF_Channel_Program__c == channeProgramDetailsOFCogtm.Core_MDF_Program_ID__c)  && !acc.Core_MDF_CoMarketingActive__c && !acc.Core_MDF_CoMarketingAgency__c
                    && (acc.Core_Geo__c != accRecsOldMap.get(acc.Id).Core_Geo__c || acc.Core_MDF_Payment_Type_nm__c != accRecsOldMap.get(acc.Id).Core_MDF_Payment_Type_nm__c)) {
                        coMarketingAccountIds.add(acc.Id);
                        if(acc.Core_Geo__c != accRecsOldMap.get(acc.Id).Core_Geo__c && parentAccIdToParentAccMap.get(acc.Core_MDF_Parent_Fund_Account__c).RecordTypeId == masterRecrodtypeId)
                        {
                            newAccList.add(acc);
                            hostGeoUpdatedAccList.add(accRecsOldMap.get(acc.Id));
                        }
                        
                    }
            }
            
            //query virtual corp and all the child accounts of virtual corp
            if(!coMarketingAccountIds.isEmpty()) {
                for(Account acc : [select Id, Name, Core_MDF_Parent_Fund_Account__c, Core_MDF_Parent_Fund_Account__r.RecordTypeId, Core_MDF_Parent_Fund_Account__r.Core_MDF_Payment_Type_nm__c, Core_MDF_Payment_Type_nm__c,
                                        Core_MDF_Parent_Fund_Account__r.Core_Geo__c, Core_Geo__c, Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c,
                                        Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c, Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c 
                                        from Account where ((Core_MDF_Parent_Fund_Account__c IN: coMarketingAccountIds 
                                                             OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: coMarketingAccountIds 
                                                             OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: coMarketingAccountIds 
                                                             OR Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c IN: coMarketingAccountIds)
                                                            OR Id IN: coMarketingAccountIds)]) {
                                                                 if(acc.Core_MDF_Parent_Fund_Account__r.RecordTypeId == masterRecrodtypeId) {
                                                                     virtualCorpIdsToVirtualCorpMap.put(acc.Id, acc);
                                                                 } else {
                                                                     childAccIdsToChildAccMap.put(acc.Id, acc);
                                                                 }
                                                             }
            }
            
            //stamp the host region value from virtual corp to its child accounts
            if(!virtualCorpIdsToVirtualCorpMap.isEmpty() && !childAccIdsToChildAccMap.isEmpty()) {
                for(Account childAcc : childAccIdsToChildAccMap.values()) {
                    if(virtualCorpIdsToVirtualCorpMap.containsKey(childAcc.Core_MDF_Parent_Fund_Account__c) && 
                       virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__c).Id == childAcc.Core_MDF_Parent_Fund_Account__c) {
                           childAcc.Core_Geo__c = virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__c).Core_Geo__c;
                           childAcc.Core_MDF_Payment_Type_nm__c = virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c;
                       }else if (virtualCorpIdsToVirtualCorpMap.containsKey(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) && 
                                 virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Id == childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) {
                                     childAcc.Core_Geo__c = virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Core_Geo__c; 
                                     childAcc.Core_MDF_Payment_Type_nm__c = virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c;
                                 } else if (virtualCorpIdsToVirtualCorpMap.containsKey(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) && 
                                            virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Id == childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) {
                                                childAcc.Core_Geo__c = virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Core_Geo__c;
                                                childAcc.Core_MDF_Payment_Type_nm__c = virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c;
                                            }else if(virtualCorpIdsToVirtualCorpMap.containsKey(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) && 
                                                     virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Id == childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c) {
                                                         childAcc.Core_Geo__c =virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Core_Geo__c;
                                                         childAcc.Core_MDF_Payment_Type_nm__c =virtualCorpIdsToVirtualCorpMap.get(childAcc.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__r.Core_MDF_Parent_Fund_Account__c).Core_MDF_Payment_Type_nm__c;
                                                     }
                    childAccountsToBeUpdatedList.add(childAcc);
                }
            }

             
            
            if(!childAccountsToBeUpdatedList.isEmpty()) {
                update childAccountsToBeUpdatedList;
            }
            if(!hostGeoUpdatedAccList.isEmpty()) {
                Core_MDF_HostRegion_Sharing.createObjectShareRecords(hostGeoUpdatedAccList,newAccList);

            }
        } catch(Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }   
    }
    
    /***************************************************************************************************** 
    Method Name: checkRetailCampaignShare
    @return  :  Void
    Created By: SH                  
    Date: 09 MAR, 2022     
    ******************************************************************************************************/
    public static void checkRetailCampaignShare(List<Account> accList){
        Map<Id, Campaign> campMap = new Map<Id, Campaign>();
        Map<Id,Set<Id>> cmpIdToGrpdsIdSetToBeDltd = new Map<Id,Set<Id>>();
        for(Campaign cmp : [SELECT Id,Core_MDF_Program__c,Core_MDF_Account__c from Campaign where Core_MDF_Program__c =: 'Retail Marketing Funds' AND Core_MDF_Account__c IN: accList]){
            campMap.put(cmp.Id,cmp);
            if(accIdToExtGrpIdMap != NULL && accIdToExtGrpIdMap.containsKey(cmp.Core_MDF_Account__c) && accIdToExtGrpIdMap.get(cmp.Core_MDF_Account__c) != NULL){
               cmpIdToGrpdsIdSetToBeDltd.put(cmp.Id, accIdToExtGrpIdMap.get(cmp.Core_MDF_Account__c)); 
            }            
        }
        if(campMap != NULL && cmpIdToGrpdsIdSetToBeDltd != NULL && campMap.size()>0 && cmpIdToGrpdsIdSetToBeDltd.size() > 0){
            Core_MDF_ProcessCCP_Campaign.shareUnshareCampaignGenericMethod(campMap,cmpIdToGrpdsIdSetToBeDltd);
        }
    }
}