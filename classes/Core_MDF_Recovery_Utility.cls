public without sharing class Core_MDF_Recovery_Utility {
    public static set<String> programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    public static Map<Id,decimal> eligibleClaims = new Map<Id,decimal>();
    public static Map<Id,Id> claimToPartnerGradient = new Map<Id,Id>();
    public static Map<Id,Core_MDF_Recovery_Request__c> claimToRecoveryReqMap = new Map<Id,Core_MDF_Recovery_Request__c>();
    public static Map<Id,Core_MDF_Recovery__c> claimToRecoveryMap = new Map<Id,Core_MDF_Recovery__c>();

    public static Map<Id,String> claimToPgmAccMap = new Map<Id,String>();
    public static Map<Id,String> claimToConsumedBudget = new Map<Id,String>();
    public static Map<Id,String> claimToConsumedPSD = new Map<Id,String>();
    public static Map<Id,decimal> partnerScoreDetailtoAmtMap = new Map<Id,decimal>();
    public static Map<string,Core_MDF_Partnership_Score_Detail__c> pgmAccQtrBTGeoToPartnerScoreDetailMap = new Map<string,Core_MDF_Partnership_Score_Detail__c>();
    public static Map<Id, String> claimIdToClaimGeoMap = new Map<Id, String>();
    public static Map<Id, String> claimIdToClaimBudgetTypeMap = new Map<Id, String>();
    public static Map<String, String> programIdToProgramNameMap = new Map<String, String>();
    public static Map<String, String> accountIdToAccountNameMap = new Map<String, String>();
    //Method to create Recovery Records for the eligible claims
    public static List<Core_MDF_Recovery__c> createRecoveryRecords(Map<id,decimal> eligibleClaims)
    {
        
        List<Core_MDF_Recovery__c> recoveryObjList = new List<Core_MDF_Recovery__c>();
        for(Id claimid : eligibleClaims.keySet())
        {
            Core_MDF_Recovery__c recoveryObj = new Core_MDF_Recovery__c();
            recoveryObj.Core_MDF_Amount_Amt__c = eligibleClaims.get(claimid);
            recoveryObj.Core_MDF_Claim_Id__c = claimid;
            recoveryObj.Core_MDF_PartnershipGradeMaintenance_Nbr__c=claimToPartnerGradient.get(claimid);
            recoveryObj.Core_MDF_Recovered_Budget_Nm__c = claimToConsumedBudget.get(claimid);
            recoveryObjList.add(recoveryObj);
            claimToRecoveryMap.put(claimid,recoveryObj);
        }
        return recoveryObjList;
    }
    
    //Method to perform recovery and recovery request(create/update) and update partnership score detail
    public static void performRecoveryUpdates(Map<id,decimal> claimToAmtMap,String qtr)
    {
        
        List<Core_MDF_Recovery_Request__c> recoveryReqList = [Select Id, Core_MDF_Claim_Id__c,Core_MDF_Claim_External_ID__c, Core_MDF_Recovered_Budget_Nm__c, Core_MDF_Recovery__c,Core_MDF_Quarter_Year_Nm__c from Core_MDF_Recovery_Request__c
                                                              where Core_MDF_Claim_Id__c IN : claimToAmtMap.keySet() and Core_MDF_Active_RO_Ind__c = true and Core_MDF_Quarter_Year_Nm__c=:qtr];
        List<Core_MDF_Recovery_Request__c> recoveryReqListTobeUpserted = new List<Core_MDF_Recovery_Request__c>();
        
        if(recoveryReqList != null && recoveryReqList.size() >  0)
        {
            for(Core_MDF_Recovery_Request__c rr : recoveryReqList)
            {
                claimToRecoveryReqMap.put(rr.Core_MDF_Claim_Id__c, rr);
            }
        }   
        for(Id claimId : claimToAmtMap.keySet())
        {
            if(!claimToRecoveryReqMap.containsKey(claimId))
            {
                List<string> valueSplit = claimToPgmAccMap.get(claimId).split(';');
                string program = valueSplit[0];
                string acc = valueSplit[1];
                string quarter = valueSplit[2];
                String claimExternalId = quarter+'='+claimIdToClaimBudgetTypeMap.get(claimId)+'='+claimIdToClaimGeoMap.get(claimId)+'='+claimId;
                Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c();
                rr.Core_MDF_Account_Id__c = acc;
                rr.Core_MDF_Active_Ind__c = true;
                //rr.Core_MDF_Ready_to_Recover_Ind__c =true;
                rr.Core_MDF_Claim_Id__c = claimId;
                rr.Core_MDF_Partnership_Grade_Maint_Id__c = claimToPartnerGradient.get(claimId);
                rr.Core_MDF_Program_Nm__c = program;
                rr.Core_MDF_Quarter_Year_Nm__c = quarter;
                rr.Core_MDF_Recovery_Amount_Amt__c = claimToAmtMap.get(claimId);
                rr.Core_MDF_Recovered_Budget_Nm__c = claimToConsumedBudget.get(claimId);
                rr.Core_MDF_Claim_External_ID__c = claimExternalId;
                rr.Core_MDF_RecoveredPartnershipScoreDetail__c = claimToConsumedPSD.get(claimId);
                rr.Core_MDF_Is_System_Created_Ind__c = true;
                recoveryReqListTobeUpserted.add(rr);
                claimToRecoveryReqMap.put(claimId, rr);   
            } 
            else
            {
                Core_MDF_Recovery_Request__c rrRecord = claimToRecoveryReqMap.get(claimId);
                rrRecord.Core_MDF_Partnership_Grade_Maint_Id__c = claimToPartnerGradient.get(claimId);
                rrRecord.Core_MDF_RecoveredPartnershipScoreDetail__c = claimToConsumedPSD.get(claimId);
                recoveryReqListTobeUpserted.add(rrRecord);
                
            }
        }
        if(recoveryReqListTobeUpserted != null && recoveryReqListTobeUpserted.size() > 0)
        {
            upsert recoveryReqListTobeUpserted Core_MDF_Claim_External_ID__c;
        }
    }
    
    
    //method to update partnership score detail record with recovered amount
    public static void updatePartnershipScoreDetailMapping(List<Core_MDF_Recovery_Request__c> recoveryReqList)
    { 
        try{
            Set<String> quarterYear = new Set<String>();
            for(Core_MDF_Recovery_Request__c recoveryReq : recoveryReqList)
            {
                List<string> recoveredPartnershipScoreDetailLst = recoveryReq.Core_MDF_RecoveredPartnershipScoreDetail__c.split(';'); 
                for(string recoveredPartnershipScoreDetail : recoveredPartnershipScoreDetailLst)
                {
                    List<string> psdAmountSplit = recoveredPartnershipScoreDetail.split('-');
                    Id psdId = psdAmountSplit[0];
                    decimal amount = decimal.valueOf(psdAmountSplit[1]);
                    if(partnerScoreDetailtoAmtMap.containsKey(psdId)){
                        partnerScoreDetailtoAmtMap.put(psdId,partnerScoreDetailtoAmtMap.get(psdId)+amount);
                    }
                    else{
                        partnerScoreDetailtoAmtMap.put(psdId, amount);
                    }
                    
                }
                
            }
            Map<Id,Core_MDF_Partnership_Score_Detail__c> scoreDetailMap = new Map<Id,Core_MDF_Partnership_Score_Detail__c>([Select id, Core_MDF_Recovered_Amt__c
                                                                                                                            from Core_MDF_Partnership_Score_Detail__c
                                                                                                                            where id in :partnerScoreDetailtoAmtMap.keySet()]);
            List<Core_MDF_Partnership_Score_Detail__c> scoreDetailTobeUpdated = new List<Core_MDF_Partnership_Score_Detail__c>();
            
            for(Id psd : scoreDetailMap.keyset())
            {
                Core_MDF_Partnership_Score_Detail__c scoreDetailRec = scoreDetailMap.get(psd);
                scoreDetailRec.Core_MDF_Recovered_Amt__c = (scoreDetailRec.Core_MDF_Recovered_Amt__c == null? 0:scoreDetailRec.Core_MDF_Recovered_Amt__c) + partnerScoreDetailtoAmtMap.get(psd);
                scoreDetailTobeUpdated.add(scoreDetailRec);
            }
            if(scoreDetailTobeUpdated != null && scoreDetailTobeUpdated.size() > 0)
            {
                Database.update(scoreDetailTobeUpdated);            
            }
        }catch(Exception e){ 
            Core_MDF_CCP_UtilityClass.logError(e);
            throw e;} 
    }
    
    public static void populatePSDMap(string programBudgetTypeQuarter,Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperForRecvryData)
    {
        List<string> noBudgetTypePrograms = Label.Core_MDF_No_Budget_Types.split(';');
        List<string> programBudgetTypeQuarterSplit = programBudgetTypeQuarter.split(';');
        // To store the program values
        Set<String> programSet = new Set<String>();
        string program = programBudgetTypeQuarterSplit[0];
        string budgetType = programBudgetTypeQuarterSplit[1];
        string quarterYear = programBudgetTypeQuarterSplit[2];
        boolean noBT = noBudgetTypePrograms.contains(program) ?true: false;

        List<Id> accntListId = wrapperForRecvryData.accntListId;
        List<String> regionList = wrapperForRecvryData.regionList;
        List<String> budgetTypeList = wrapperForRecvryData.bdgtTypeList;
        
        // Holds BTorProg to eligible cross budget type values
        Map<string,set<string>> crossBTorProgToBTMap = new Map<string,set<string>>();
        // When program is IPA, prepare a map with eligible cross budget type values
        if(program == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name')){
            // ipaBTSet stores the IPA Budget type values
            Set<String> ipaBTSet = new set<string>();
            // Looping over budget type benefit mapping records and storing the budget type value in the ipaBTSet
            for(Core_MDF_BudgetType_Benefit_Mappings__c st : [Select Core_MDF_Budget_Type__c from Core_MDF_BudgetType_Benefit_Mappings__c where Core_MDF_Program_Nm__c =: program and Core_MDF_IsActive__c = true]) {
                ipaBTSet.add(st.Core_MDF_Budget_Type__c);
            } 
            // Iterating over the ipaBTSet
            for(string bt : ipaBTSet){
                set<String> tempList = new set<String>();
                // Adding all the IPA BT's
                tempList.addAll(ipaBTSet);
                // Removing the current BT
                tempList.remove(bt);
                // Setting key as BT and value as remaining IPA BT's
                crossBTorProgToBTMap.put(bt,tempList);
            }
        }else{
            // for other programs, looping over the crossBTorProgList and preparing a map of eligible cross budget type values
            List<String> crossBTorProgList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_CrossBTorProgRecoveries');  //MDF:MDF+;MDF+:MDF;CCF 1.0:OEM CMP;DCF 1.0:OEM CMP,Service Provider CMP;Service Provider CoMarketing Fund:OEM CMP,Service Provider CMP
            for(string tempString : crossBTorProgList){
                List<String> btOrProg = tempString.split(':');
                set<String> crossBT = new set<string>();
                crossBT.addAll(btOrProg[1].split(','));
                crossBTorProgToBTMap.put(btOrProg[0],crossBT);
            }
        }
        // Holds the set of Budget type values
        set<string> btList = new set<string>();
        // Looping over keyset values
        // Lets say if st=CCF 1.0, then bt = OEM CMP, then check if bt is equal to incoming budget type value, then add bt and st to the list
        if(budgetTypeList != null && budgetTypeList.size()>0){
            for(String st : crossBTorProgToBTMap.keySet()){
                for(string bt : crossBTorProgToBTMap.get(st)){
                    for(String budType : budgetTypeList){
                        if(bt == budType){
                            btList.add(st);
                            btList.add(bt);
                        }
                    }
                }
            }
        }
        // Adding incoming Budget Type value
        btList.addAll(budgetTypeList);
        
        // Adding incoming program value
        programSet.add(program);
        // If program is SPCF/CCFB, then add empty value in btList
        if(noBT){  
            btList.add('');          
        }


        if(programs_For_Node_Account.contains(program)){
            if(regionList != null && regionList.size() > 0 && btList != null && btList.size() > 0){
                for(Core_MDF_Partnership_Score_Detail__c psd :[Select Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, 
                                                        Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c, Core_MDF_Node_Account_Id__c
                                                        From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = :program 
                                                        and Core_MDF_Region_Cd__c in :regionList and Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c = :quarterYear and Core_MDF_Node_Account_Id__c in:accntListId 
                                                        and Core_MDF_Budget_Type_nm__c in:btList and Core_MDF_Balance_Amount_Amt__c > 0 order by Core_MDF_Node_Account_Id__c])
                {
                    string key1 = program+';'+psd.Core_MDF_Node_Account_Id__c+';'+quarterYear+';';
                    string key2 = noBT? psd.Core_MDF_Region_Cd__c : psd.Core_MDF_Budget_Type_nm__c+';'+psd.Core_MDF_Region_Cd__c;
                    pgmAccQtrBTGeoToPartnerScoreDetailMap.put(key1+key2,psd);
                }
            }else if(btList != null && btList.size() > 0){
                for(Core_MDF_Partnership_Score_Detail__c psd :[Select Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, 
                                                        Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c, Core_MDF_Node_Account_Id__c
                                                        From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = :program 
                                                        and Core_MDF_Budget_Type_nm__c in :btList and Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c = :quarterYear and Core_MDF_Node_Account_Id__c in:accntListId 
                                                        and Core_MDF_Balance_Amount_Amt__c > 0 order by Core_MDF_Node_Account_Id__c])
                {
                    string key1 = program+';'+psd.Core_MDF_Node_Account_Id__c+';'+quarterYear+';';
                    string key2 = noBT? psd.Core_MDF_Region_Cd__c : psd.Core_MDF_Budget_Type_nm__c+';'+psd.Core_MDF_Region_Cd__c;
                    pgmAccQtrBTGeoToPartnerScoreDetailMap.put(key1+key2,psd);
                }
            }else if(regionList != null && regionList.size() > 0){
                for(Core_MDF_Partnership_Score_Detail__c psd :[Select Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, 
                                                        Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c, Core_MDF_Node_Account_Id__c
                                                        From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = :program 
                                                        and Core_MDF_Region_Cd__c in :regionList and Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c = :quarterYear and Core_MDF_Node_Account_Id__c in:accntListId 
                                                        and Core_MDF_Balance_Amount_Amt__c > 0 order by Core_MDF_Node_Account_Id__c])
                {
                    string key1 = program+';'+psd.Core_MDF_Node_Account_Id__c+';'+quarterYear+';';
                    string key2 = noBT? psd.Core_MDF_Region_Cd__c : psd.Core_MDF_Budget_Type_nm__c+';'+psd.Core_MDF_Region_Cd__c;
                    pgmAccQtrBTGeoToPartnerScoreDetailMap.put(key1+key2,psd);
                }
            }
            else{
                for(Core_MDF_Partnership_Score_Detail__c psd :[Select Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, 
                                                        Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c, Core_MDF_Node_Account_Id__c
                                                        From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = :program 
                                                        and Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c = :quarterYear and Core_MDF_Node_Account_Id__c in:accntListId 
                                                        and Core_MDF_Balance_Amount_Amt__c > 0 order by Core_MDF_Node_Account_Id__c])
                {        
                    string key1 = program+';'+psd.Core_MDF_Node_Account_Id__c+';'+quarterYear+';';
                    string key2 = noBT? psd.Core_MDF_Region_Cd__c : psd.Core_MDF_Budget_Type_nm__c+';'+psd.Core_MDF_Region_Cd__c;
                    pgmAccQtrBTGeoToPartnerScoreDetailMap.put(key1+key2,psd);         
                }
            }
            
        }
        else{
            if(regionList != null && regionList.size() > 0 && btList != null && btList.size() > 0){
                for(Core_MDF_Partnership_Score_Detail__c psd :[Select Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, 
                                                        Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c
                                                        From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = :program 
                                                        and Core_MDF_Budget_Type_nm__c IN: btList and Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c = :quarterYear and Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c in:accntListId 
                                                        and Core_MDF_Region_Cd__c In:regionList and Core_MDF_Balance_Amount_Amt__c > 0 order by Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c])
                {        
                    string key1 = program+';'+psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c+';'+quarterYear+';';
                    string key2 = noBT? psd.Core_MDF_Region_Cd__c : psd.Core_MDF_Budget_Type_nm__c+';'+psd.Core_MDF_Region_Cd__c;
                    pgmAccQtrBTGeoToPartnerScoreDetailMap.put(key1+key2,psd);         
                }
            }else if(btList != null && btList.size() > 0){
                for(Core_MDF_Partnership_Score_Detail__c psd :[Select Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, 
                                                        Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c
                                                        From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = :program 
                                                        and Core_MDF_Budget_Type_nm__c IN: btList and Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c = :quarterYear and Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c in:accntListId 
                                                        and Core_MDF_Balance_Amount_Amt__c > 0 order by Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c])
                {        
                    string key1 = program+';'+psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c+';'+quarterYear+';';
                    string key2 = noBT? psd.Core_MDF_Region_Cd__c : psd.Core_MDF_Budget_Type_nm__c+';'+psd.Core_MDF_Region_Cd__c;
                    pgmAccQtrBTGeoToPartnerScoreDetailMap.put(key1+key2,psd);        
                }
            }else if(regionList != null && regionList.size() > 0){
                for(Core_MDF_Partnership_Score_Detail__c psd :[Select Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, 
                                                        Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c
                                                        From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = :program 
                                                        and Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c = :quarterYear and Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c in:accntListId 
                                                        and Core_MDF_Region_Cd__c In:regionList and Core_MDF_Balance_Amount_Amt__c > 0 order by Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c])
                {        
                    string key1 = program+';'+psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c+';'+quarterYear+';';
                    string key2 = noBT? psd.Core_MDF_Region_Cd__c : psd.Core_MDF_Budget_Type_nm__c+';'+psd.Core_MDF_Region_Cd__c;
                    pgmAccQtrBTGeoToPartnerScoreDetailMap.put(key1+key2,psd);         
                }
            }else{
                for(Core_MDF_Partnership_Score_Detail__c psd :[Select Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c, 
                                                        Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c
                                                        From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = :program 
                                                        and Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c = :quarterYear and Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c in:accntListId 
                                                        and Core_MDF_Balance_Amount_Amt__c > 0 order by Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c])
                {        
                    string key1 = program+';'+psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c+';'+quarterYear+';';
                    string key2 = noBT? psd.Core_MDF_Region_Cd__c : psd.Core_MDF_Budget_Type_nm__c+';'+psd.Core_MDF_Region_Cd__c;
                    pgmAccQtrBTGeoToPartnerScoreDetailMap.put(key1+key2,psd);         
                }
            }
        }
    }
    
    
    //method to run the recovery logic and update maps required for Recovery
    public static List<RecoveryRecoveryRequestWrap> runEligibilityLogicToGetRecoveryRecords(string programBudgetTypeQuarter, Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperForRecvryData)
    {
        List<RecoveryRecoveryRequestWrap> recoveries = new List<RecoveryRecoveryRequestWrap>();
        List<string> programBudgetTypeQuarterSplit = programBudgetTypeQuarter.split(';');
        string program = programBudgetTypeQuarterSplit[0];
        string quarter = programBudgetTypeQuarterSplit[2];
        List<string> noBudgetTypePrograms = Label.Core_MDF_No_Budget_Types.split(';');
        boolean noBT = noBudgetTypePrograms.contains(program) ?true: false;
        try{
            populatePSDMap(programBudgetTypeQuarter, wrapperForRecvryData);
            Map<string,List<Core_MDF_Recovery_Helper.recoveryBatchParams>> recoveryRequestRecords = Core_MDF_Recovery_Helper.getClaimsBasedOnConditionsForBatch(programBudgetTypeQuarter,wrapperForRecvryData);
            //to prepare partnerScoreDetailtoAmtMap- map of Partnership score detail record and the amount to be updated on it
            //to prepare claimToPartnerGradient- map of claim and the partnership score record to be updated on the recovery
            //to prepare eligibleClaims- map of claims and the amt to be recovered from it
            //to prepare claimToConsumedBudget - map of claim and its consumed budget to be updated on the recovery request
            Id rrIdNullCheck=null;
            for(string account : recoveryRequestRecords.keySet())
            {
                for(Core_MDF_Recovery_Helper.recoveryBatchParams recommendedRR1 : recoveryRequestRecords.get(account))
                {
                    List<Core_MDF_Recovery_Helper.geoRecoverySplit> geoRecoveryList = recommendedRR1.geoRows;
                    for(Core_MDF_Recovery_Helper.geoRecoverySplit geoRecoveryRecord : geoRecoveryList) 
                    {
                        string budgetType = geoRecoveryRecord.budgetType;
                        string geo = geoRecoveryRecord.geo;
                        decimal amount = geoRecoveryRecord.geoRecoveryAmount;
                        string key1 = program+';'+account+';'+quarter+';';
                        string key2 = noBT? geo : budgetType+';'+geo;
                        id psdId=null;
                        if(pgmAccQtrBTGeoToPartnerScoreDetailMap.containsKey(key1+key2) && pgmAccQtrBTGeoToPartnerScoreDetailMap.get(key1+key2).Core_MDF_Partnership_Score_Id__c != null){
                        claimToPartnerGradient.put(recommendedRR1.claimId,pgmAccQtrBTGeoToPartnerScoreDetailMap.get(key1+key2).Core_MDF_Partnership_Score_Id__c);
                            psdId = pgmAccQtrBTGeoToPartnerScoreDetailMap.get(key1+key2).Id;
                        }
                        
                        string psdAmtValue = psdId+'-'+string.valueOf(amount);
                        populateClaimToConsumedPSD(recommendedRR1.claimId,psdAmtValue);
                    }
                        Core_MDF_Recovery__c recoveryObj = new Core_MDF_Recovery__c();
                        recoveryObj.Core_MDF_Amount_Amt__c = recommendedRR1.recoveryAmount;
                        recoveryObj.Core_MDF_Claim_Id__c = recommendedRR1.claimId;
                        recoveryObj.Core_MDF_PartnershipGradeMaintenance_Nbr__c=claimToPartnerGradient.get(recommendedRR1.claimId);
                        recoveryObj.Core_MDF_Recovered_Budget_Nm__c = recommendedRR1.budgetConsumed;
                    RecoveryRecoveryRequestWrap rrrW = new RecoveryRecoveryRequestWrap();
                    Core_MDF_Recovery_Request__c rr = new Core_MDF_Recovery_Request__c(id = recommendedRR1.rrID);
                    rrIdNullCheck = recommendedRR1.rrID;
                    if(recommendedRR1.rrID!=null){     
                        rrrW.recovery = recoveryObj;
                        rrrW.recRequest = rr;
                        recoveries.add(rrrW);
                    }
                    eligibleClaims.put(recommendedRR1.claimId,recommendedRR1.recoveryAmount);
                    claimToConsumedBudget.put(recommendedRR1.claimId,recommendedRR1.budgetConsumed);
                    claimIdToClaimGeoMap.put(recommendedRR1.claimId, recommendedRR1.claimGeo);
                    claimIdToClaimBudgetTypeMap.put(recommendedRR1.claimId, recommendedRR1.claimBudgetType);
                    claimToPgmAccMap.put(recommendedRR1.claimId,program+';'+account+';'+quarter);
                }   
            }
            List<Core_MDF_Recovery__c> createdRecoveryRecords = new list<Core_MDF_Recovery__c>();
            if(eligibleClaims != null && eligibleClaims.size() > 0)
            {
                performRecoveryUpdates(eligibleClaims,quarter); 
	    	if (rrIdNullCheck==null){
                	createdRecoveryRecords = createRecoveryRecords(eligibleClaims);
                    for(id claimId :eligibleClaims.keySet()){
                        Core_MDF_Recovery_Request__c RRrec = claimToRecoveryReqMap.get(claimId);
                        Core_MDF_Recovery__c RecoveryRec = claimToRecoveryMap.get(claimId);
                        RecoveryRecoveryRequestWrap rrrW1 = new RecoveryRecoveryRequestWrap();
                        
                        rrrW1.recovery = RecoveryRec;
                        rrrW1.recRequest = RRrec;
                        recoveries.add(rrrW1);

                    }
		}
            }
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw e;
        }
        return recoveries;
    }
    
    public static void populateClaimToConsumedPSD(Id claimId, string psdAmtValue)
    {
        if(claimToConsumedPSD.containsKey(claimId)){
            claimToConsumedPSD.put(claimId,claimToConsumedPSD.get(claimId)+';'+psdAmtValue);
        }
        else{
            claimToConsumedPSD.put(claimId, psdAmtValue);
        }
        
    }

    public static Boolean isRecoveryAllowedForCurrentMonth(List<String> labelValue){
        Integer currMonth = System.today().month();
        String month_data = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Current_Month');

        if(month_data!=null && month_data!=''){
            currMonth = Integer.valueOf(month_data);
        }
        else{
            currMonth = System.today().month(); 
        }
        List<string> recoveryRestrictedMonths =  labelValue; // 1 => JAN, 4 => APR, 7 => JUL, 10 => OCT
        return recoveryRestrictedMonths.contains(String.valueOf(currMonth)) ? false : true ;
    }

   
    public Static list<RecoveryAdminProgramMapping> getRecoveryAdmins(List<String> psNameList, List<Core_MDF_Partnership_Score_Detail__c> psdRecList){
        //Roshan - Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
        List<PermissionSetAssignment> psaList = [select id,AssigneeId,Assignee.LanguageLocaleKey,Assignee.Contact.AccountId,Assignee.Email,PermissionSet.name from PermissionSetAssignment where PermissionSet.name in :psNameList and (Assignee.isActive = true OR Assignee.Partner_License_Reclaimed__c = true)];
        String psTProgramMapStr = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_Admin_Program_Mapping');
        string ipaProg = Core_MDF_CCP_ConstantClass.IPA_PROGRAM;
        string rmfProg = Core_MDF_CCP_ConstantClass.RMF_PROGRAM;
        Map<String,String> psTProgramMap = new Map<String,String>();
        for(string psToProgram : psTProgramMapStr.split(',')){
            List<string> record = psToProgram.split(':');
            psTProgramMap.put(record[0],record[1]);
        }
        Set<Id> ipaAndRmfUsers = new Set<Id> ();
        for(PermissionSetAssignment psa:psaList){
                if(psTProgramMap.get(psa.PermissionSet.name) == ipaProg || psTProgramMap.get(psa.PermissionSet.name) == rmfProg){
                    ipaAndRmfUsers.add(psa.AssigneeId);
                }
        }    
        Set<String> accProgwithRecoverySet = new Set<String>();
        Set<Id> nodesWithRecovery = new Set<Id>();
        for(Core_MDF_Partnership_Score_Detail__c psd : psdRecList){
            string key = psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c + psd.Core_MDF_Program_Nm__c;
            accProgwithRecoverySet.add(key);
            if(psd.Core_MDF_Node_Account_Id__c != null){
                nodesWithRecovery.add(psd.Core_MDF_Node_Account_Id__c);
            }
        }    
        Map<id,List<id>> userToAccountsListMap = new Map<id,List<id>>();
        //Roshan - Added Partner_License_Reclaimed__c in where clause for "Reclaiming SF Partner License"
        for(Core_MDF_Partner_Node_User_Mapping__c pnum : [select id, Core_MDF_User__c, Core_MDF_Account__c, Core_MDF_Active_Ind__c from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Active_Ind__c = true and Core_MDF_User__c in : ipaAndRmfUsers and (Core_MDF_User__r.IsActive = TRUE OR Core_MDF_User__r.Partner_License_Reclaimed__c = TRUE) and Core_MDF_Account__c in :nodesWithRecovery]){
                if(userToAccountsListMap.containsKey(pnum.Core_MDF_User__c) ){
                    userToAccountsListMap.get(pnum.Core_MDF_User__c).add(pnum.Core_MDF_Account__c);
                }
                else{
                    userToAccountsListMap.put(pnum.Core_MDF_User__c, new List<id> {pnum.Core_MDF_Account__c});
                }
            }
        Map<String,String> pgmNameToIdMap =  new Map<String,String>();
        List<ChannelProgram> pgmList = [Select id,Name from ChannelProgram where name in: psTProgramMap.values()];
        for(ChannelProgram cp : pgmList){
            pgmNameToIdMap.put(cp.name,cp.id);
        }
        List<RecoveryAdminProgramMapping> admPgmMapList = new List<RecoveryAdminProgramMapping>();
        for(PermissionSetAssignment psa:psaList){
            string key = psa.Assignee.Contact.AccountId + psTProgramMap.get(psa.PermissionSet.name); 
            boolean recoveryNodeAccess = false ;  
            if(userToAccountsListMap.get(psa.AssigneeId) != null && userToAccountsListMap.get(psa.AssigneeId).size()>0){
                recoveryNodeAccess = true;
            }
            if(accProgwithRecoverySet.contains(key) && 
            ((!(psTProgramMap.get(psa.PermissionSet.name) == ipaProg || psTProgramMap.get(psa.PermissionSet.name) == rmfProg)) 
             || ((psTProgramMap.get(psa.PermissionSet.name) == ipaProg || psTProgramMap.get(psa.PermissionSet.name) == rmfProg) && recoveryNodeAccess))){
            RecoveryAdminProgramMapping admPgmMap = new RecoveryAdminProgramMapping();
            user usr = new user();
            usr.id=psa.AssigneeId;
            usr.LanguageLocaleKey=psa.Assignee.LanguageLocaleKey;
            usr.email=psa.Assignee.Email;
            admPgmMap.user = usr;
            admPgmMap.program = psTProgramMap.get(psa.PermissionSet.name);
            admPgmMap.programId = pgmNameToIdMap.get(psTProgramMap.get(psa.PermissionSet.name));
            admPgmMapList.add(admPgmMap);
        }
        }
        return admPgmMapList;
    }

    
    public static Date reduceBusinessDays(Date startDate, Integer businessDaysToReduce){ 
        Date finalDate = startDate;
        Integer daysToReduce = 1;
        while(businessDaysToReduce != 0)
        {
            finalDate = finalDate - daysToReduce;
            // check finalDate is weekday or weekend
            if (!Core_MDF_PFC_VAT_ServiceHandler.isWeekendDay(finalDate))
            {
                businessDaysToReduce -= daysToReduce;
            }
        }
        return finalDate;
    }

    public static Core_MDF_Batch_Scheduler__c prepareBatchSchedulerInstance(String program, DateTime scheduleTime, String recoveryDate){
        Core_MDF_Batch_Scheduler__c customSch = new Core_MDF_Batch_Scheduler__c();
        customSch.Core_MDF_Object_JSON_Txt__c = '{"program" : "' + program + '","action" : "SendEmail","recoveryDate" : "' + recoveryDate + '"}';
        customSch.Core_MDF_Batch_Size_Nbr__c = 50;
        customSch.Scheduled_Time_Dt__c = scheduleTime;
        customSch.Core_MDF_Batch_Class_Name_Txt__c = 'Core_MDF_Batch_RecoveryAdminNotification';
        customSch.Core_MDF_Job_Frequency__c = 'Once';
        customSch.Core_MDF_Priority__c = 'High';
        customSch.Core_MDF_Program_Txt__c = 'CCP';
        
        return customSch;
    }

    public static void notifyRecoveryAdmin(List<String> psNameList,Map<String,String> programToRecoveryDateMap, List<Core_MDF_Partnership_Score_Detail__c> psdRecList){        
        List<Core_MDF_Recovery_Utility.RecoveryAdminProgramMapping> userProgramWrapList = Core_MDF_Recovery_Utility.getRecoveryAdmins(psNameList, psdRecList);
        if(userProgramWrapList != null){
            List<Messaging.SingleEmailMessage> emailMessageList = new List< Messaging.SingleEmailMessage>();
            for(Core_MDF_Recovery_Utility.RecoveryAdminProgramMapping userProgramWrap : userProgramWrapList){
                if(programToRecoveryDateMap.containsKey(userProgramWrap.Program)){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {userProgramWrap.user.email};
                String subject = '';
                String body = '';
                Date executionDate = Date.valueOf(programToRecoveryDateMap.get(userProgramWrap.Program));
                DateTime dt = (DateTime) executionDate;
                String executionDateStr = dt.format('MM/dd/yyyy');
                executionDateStr += ' 12:00 AM GMT';
                String userLocaleKey = userProgramWrap.user.LanguageLocaleKey;
                String recoveryURL = Label.Core_MDF_PFRCommunityLink+'s/claim-recovery';

                subject = System.Label.get('','Core_MDF_Recovery_Admin_Notification_Subject', userLocaleKey) + ' ' + executionDateStr;

                body += '<html><head><style>table,td,th{border: 1px solid black;border-collapse: collapse;padding: 3px 15px;}</style></head><body><div style="font-size:14px;font-family:Calibri">';
                body += System.Label.get('','Core_MDF_EmailTemp_StatusUpdate_DearMember', userLocaleKey) + '<br/><br/>';
                body += System.Label.get('','Core_MDF_Recovery_Admin_Notification_Body1', userLocaleKey) + ' ' + executionDateStr + '.<br/><br/>';               
                body += System.Label.get('','Core_MDF_EmailTemp_Program', userLocaleKey) + ' ' + userProgramWrap.Program + '<br/><br/>';
                body += System.Label.get('','Core_MDF_Recovery_Admin_Notification_Body2',userLocaleKey) + ' ' + '<a href="'+recoveryURL+'">' + recoveryURL + '<a>' + '<br/><br/>';
                body += System.Label.get('','Core_MDF_Recovery_Admin_Notification_Body3', userLocaleKey) + ' ' + executionDateStr + '.<br/><br/>';
                body += System.Label.get('','Core_MDF_Recovery_Admin_Notification_Body4', userLocaleKey) + '<br/><br/>';
                body += System.Label.get('','Core_MDF_EmailTemp_StatusUpdate_Body7', userLocaleKey) + '<br/><br/>';
                body += System.Label.get('','Core_MDF_Email_Signature', userLocaleKey) + '</div></body></html>';

                    
                mail.setToAddresses(toAddresses);
                mail.setSubject(subject);
                mail.setHtmlBody(body);
                mail.setTargetObjectId(userProgramWrap.user.Id);
                mail.setSaveAsActivity(false);
                mail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                emailMessageList.add(mail);
                }
            }
            if(emailMessageList != null && emailMessageList.size() > 0){
            Messaging.sendEmail(emailMessageList);
            }
        }

        
    }
    public static void sendRecoveryDashboardNotification(List<String> psNameList,String quarterAndYear, List<Core_MDF_Partnership_Score_Detail__c> psdRecList){
        
        List<Core_MDF_Recovery_Utility.RecoveryAdminProgramMapping> userProgramWrapList = Core_MDF_Recovery_Utility.getRecoveryAdmins(psNameList, psdRecList);
        if(userProgramWrapList != null){
            List<Messaging.SingleEmailMessage> emailMessageList = new List< Messaging.SingleEmailMessage>();
            for(Core_MDF_Recovery_Utility.RecoveryAdminProgramMapping userProgramWrap : userProgramWrapList){
                Messaging.SingleEmailMessage dashboardMail = new Messaging.SingleEmailMessage();
                String[] dashboardMailToAddresses = new String[] {userProgramWrap.user.email};
                String dashboardMailSubject = '';
                String dashboardMailBody = '';
                string quarterYearForLink = quarterAndYear.replace(' ','%20');
                string dashboardUrl = Label.Core_MDF_PFRCommunityLink + +'s/recovery-dashboard?c__programId='+ userProgramWrap.ProgramId +'&c__quarterYear='+ quarterYearForLink ; 
                String userLocaleKey = userProgramWrap.user.LanguageLocaleKey;
                dashboardMailSubject =  System.Label.get('','Core_MDF_RecoveryDashboardNotificationSubject1', userLocaleKey) +' ' + quarterAndYear;
                dashboardMailBody += System.Label.get('','Core_MDF_EmailTemp_StatusUpdate_DearMember', userLocaleKey) + '<br/><br/>';
                dashboardMailBody += System.Label.get('','Core_MDF_RecoveryDashboardNotificationBody1', userLocaleKey)+' ' + quarterAndYear +': ' +  '<html><a href="'+dashboardUrl+'">'+ System.Label.get('','Core_MDF_Click_here', userLocaleKey) +'</a></html>' + '<br/>';
                dashboardMailBody += System.Label.get('','Core_MDF_RecoveryDashboardNotificationBody2', userLocaleKey)+ '<br/><br/>';
                dashboardMailBody += System.Label.get('','Core_MDF_EmailTemp_StatusUpdate_Body7', userLocaleKey) + '<br/>';
                dashboardMailBody += System.Label.get('','Core_MDF_Email_Signature', userLocaleKey) + '</div></body></html>';
				dashboardMail.setToAddresses(dashboardMailToAddresses);
                dashboardMail.setSubject(dashboardMailSubject);
                dashboardMail.setHtmlBody(dashboardMailBody);
                dashboardMail.setTargetObjectId(userProgramWrap.user.Id);
                dashboardMail.setSaveAsActivity(false);
                dashboardMail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                emailMessageList.add(dashboardMail);
            }
            if(emailMessageList != null && emailMessageList.size() > 0){
            Messaging.sendEmail(emailMessageList);
            }
        }

        
    }
    
    /******************************************************************************************************
	Method Name:        notifyInternalActManagersOnRecoveryDataLoad
	@parameters:        permission name to include, permission sets to exclude, program to date of execution map, program names for processing, Partnership Score Detail records
	Description:        This method is used to send email to inform internal account managers on recovery data load
	Added By:           Accenture - Vikas Soni - 10/01/2025
	Modified By:        Date:       Changes:
    *******************************************************************************************************/

    public static void notifyInternalActManagersOnRecoveryDataLoad(List<String> psNameList, List<String> psNamesToExcludeForEmail, Map<String, String> programToRecoveryDateMap, Set<String> programNamesSet, List<Core_MDF_Partnership_Score_Detail__c> psdRecList, String notificationType, Boolean isPermissionSetAssignmentBased){
        try {
            Map<String, Map<String, Set<User>>> programToAccountToUsersMap = Core_MDF_Recovery_Utility.getProgramAndAccountSpecificAccountManagers(psNameList, psNamesToExcludeForEmail, programNamesSet, psdRecList, notificationType, isPermissionSetAssignmentBased);
            List<Messaging.SingleEmailMessage> emailMessageList = new List< Messaging.SingleEmailMessage>();
            String programName = '';
            String accountName = '';        
            String subject = '';
            String body = '';
            String recoveriesURL = Label.Core_MDF_PFRDetailLink + 'lightning/n/Recoveries';
            String powerBiDashboardURL = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_RecoveryPowerBIDashboardURL');
            String int_Acc_Manager_Email_Body1 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Int_Acc_Manager_Email_Body1');
            String int_Acc_Manager_Email_Body2 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Int_Acc_Manager_Email_Body2');
            String emailTemp_ViewInPartnerInvCentr = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailTemp_ViewInPartnerInvCentr');
            String emailTemp_ViewInDashboard = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EmailTemp_ViewInDashboard');
            String int_Acc_Manager_Email_Body3 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Int_Acc_Manager_Email_Body3');
            String int_Acc_Manager_Email_Body4 = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Int_Acc_Manager_Email_Body4');
            
            for(String programId : programToAccountToUsersMap.keySet()){
                programName = programIdToProgramNameMap.get(programId);
                if(programToRecoveryDateMap.containsKey(programName)){
                    Map<String, Set<User>> accountIdToUsersMap = programToAccountToUsersMap.get(programId);
                    for(String accountId : accountIdToUsersMap.keySet()){
                        body = '';
                        accountName = accountIdToAccountNameMap.get(accountId);
                        Date executionDate = Date.valueOf(programToRecoveryDateMap.get(programName));
                        Set<User> userList = accountIdToUsersMap.get(accountId);
                        DateTime dt = (DateTime) executionDate;
                        String executionDateStr = dt.format('MM/dd/yyyy');
                        executionDateStr += ' 12:00 AM GMT';
                        subject = System.Label.get('','Core_MDF_Recovery_Admin_Notification_Subject', 'en_US') + ' ' + executionDateStr + ' for ' + accountName + ' and ' + programName;
                        
                        body += '<html><head><style>table,td,th{border: 1px solid black;border-collapse: collapse;padding: 3px 15px;}</style></head><body><div style="font-size:14px;font-family:Calibri">';
                        body += System.Label.get('','Core_MDF_EmailTemp_DearIntelEmployee', 'en_US') + '<br/><br/>';
                        body += int_Acc_Manager_Email_Body1 + ' ' + executionDateStr + ' for ' + accountName + '.<br/><br/>';               
                        body += System.Label.get('','Core_MDF_EmailTemp_Program', 'en_US') + ' ' + programName + '<br/><br/>';
                        body += int_Acc_Manager_Email_Body2 + '<br/><br/>';
                        body += emailTemp_ViewInPartnerInvCentr + ': ' + '<a href="' + recoveriesURL+'">' + recoveriesURL + '<a>' + '<br/><br/>';
                        body += emailTemp_ViewInDashboard + ': ' + '<a href="' + powerBiDashboardURL + '">' + powerBiDashboardURL + '<a>' + '<br/><br/>';
                        body += int_Acc_Manager_Email_Body3 + ' ' + executionDateStr + '.<br/><br/>';
                        body += int_Acc_Manager_Email_Body4 + '<br/><br/>';
                        body += System.Label.get('','Core_MDF_EmailTemp_StatusUpdate_Body7', 'en_US') + '<br/><br/>';
                        body += System.Label.get('','Core_MDF_Email_Signature', 'en_US') + '</div></body></html>';
                        
                        for(User usr : userList){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            String [] toAddresses = (new String[] {usr.Email});                        
                            mail.setToAddresses(toAddresses);
                            mail.setSubject(subject);
                            mail.setHtmlBody(body);
                            mail.setTargetObjectId(usr.Id);
                            mail.setSaveAsActivity(false);
                            mail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
                            emailMessageList.add(mail);
                        }
                    }
                }
            }
            if(!emailMessageList.isEmpty()){
                Messaging.sendEmail(emailMessageList);
            }
        } catch(Exception e) { 
            Core_MDF_CCP_UtilityClass.logError(e);
        }
    }

    /******************************************************************************************************
	Method Name:        getProgramAndAccountSpecificAccountManagers
	@return:            map of programid-accountid-users
	@parameters:        permission name to include, permission sets to exclude, program names for processing, Partnership Score Detail records, notification type, is permission set assignment based user need to be queried
	Description:        This helper method is used to support 'notifyInternalActManagersOnRecoveryDataLoad'
	Added By:           Accenture - Vikas Soni - 10/01/2025
	Modified By:        Date:       Changes:
    *******************************************************************************************************/
    public static Map<String, Map<String, Set<User>>> getProgramAndAccountSpecificAccountManagers(List<String> psNameList, List<String> psNamesToExcludeForEmail, Set<String> programNamesSet, List<Core_MDF_Partnership_Score_Detail__c> psdRecList, String notificationType, Boolean isPermissionSetAssignmentBased){
        String key;
        Set<Id> accountIdsForIUPGMSet = new Set<Id>();
        Map<String, String> accIdWithPrgKeyToAccNameMap = new Map<String, String>();       
        Set<Id> channelProgramIdsForIUPGMQuery = new Set<Id>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmRecList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Set<String> programsForNodeAccountCheck = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
        Map<String, Map<String, Set<String>>> programIdToAccountIdtoNodeAccountIdSet = new Map<String, Map<String, Set<String>>>();
        List<Core_MDF_Int_Users_Partner_Geo_Mapping__c> iupgmRecordsList = new List<Core_MDF_Int_Users_Partner_Geo_Mapping__c>();
        Map<String, Map<String, Set<User>>> programToAccountToUsersMap = new Map<String, Map<String, Set<User>>>();
        
        //to prepare iaccId-Program to Account Name map
        for(Core_MDF_Partnership_Score_Detail__c psd : psdRecList){
            key = String.valueOf(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c) + String.valueOf(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c);
            if(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c != null){
                programIdToProgramNameMap.put(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c, psd.Core_MDF_Program_Nm__c);
                accountIdToAccountNameMap.put(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c, psd.Core_MDF_Account_Id__c);
                accountIdsForIUPGMSet.add(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c);
                accIdWithPrgKeyToAccNameMap.put(key, psd.Core_MDF_Account_Id__c);
                channelProgramIdsForIUPGMQuery.add(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c);
                
                //for IPA or RMF programs only: prepare intelAccountId-Program to Node Account Name map
                if(programsForNodeAccountCheck.contains(psd.Core_MDF_Program_Nm__c) && psd.Core_MDF_Node_Account_Id__c != null){
                    //for RMF only key will have nodeAccountId-Program as in IUPGM we have node account id stored for RMF
                    if(psd.Core_MDF_Program_Nm__c == Core_MDF_CCP_ConstantClass.RMF_PROGRAM){
                        key = String.valueOf(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c) + String.valueOf(psd.Core_MDF_Node_Account_Id__c);
                        accountIdsForIUPGMSet.add(psd.Core_MDF_Node_Account_Id__c);
                    }
                    accIdWithPrgKeyToAccNameMap.put(key, psd.Core_MDF_Node_Account_Id__r.Name);
                    accountIdToAccountNameMap.put(psd.Core_MDF_Node_Account_Id__c, psd.Core_MDF_Node_Account_Id__r.Name);
                }
                
                //prepare map for Core_MDF_All_Accounts_cd__c == 'Yes' in IUPGM
                Boolean isRMFProgram = psd.Core_MDF_Program_Nm__c == Core_MDF_CCP_ConstantClass.RMF_PROGRAM ? true : false;
                String accountKey = isRMFProgram ? psd.Core_MDF_Node_Account_Id__c : psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c;
                String accountValue = String.isNotBlank(psd.Core_MDF_Node_Account_Id__c) ? psd.Core_MDF_Node_Account_Id__c : psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c;
                if(programIdToAccountIdtoNodeAccountIdSet.containsKey(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c)){
                    if(programIdToAccountIdtoNodeAccountIdSet.get(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c).containsKey(accountKey)){
                        programIdToAccountIdtoNodeAccountIdSet.get(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c).get(accountKey).add(accountValue);
                    }else{
                        programIdToAccountIdtoNodeAccountIdSet.get(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c).put(accountKey, new Set<String>{accountValue});
                    }
                }else{
                    Map<String, Set<String>> intelAccountIdToAccountValue = new Map<String, Set<String>>{accountKey => new Set<String>{accountValue}};
                        programIdToAccountIdtoNodeAccountIdSet.put(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c, intelAccountIdToAccountValue);
                }
            }
        }
        Core_MDF_CCP_GenericUtility.QueryIUPGMRecordsWrapper queryIUPGMRecordsWrapperObj = new Core_MDF_CCP_GenericUtility.QueryIUPGMRecordsWrapper();
        queryIUPGMRecordsWrapperObj.psNameList = psNameList;
        queryIUPGMRecordsWrapperObj.psNamesToExcludeForEmail = psNamesToExcludeForEmail;
        queryIUPGMRecordsWrapperObj.channelProgramIds = channelProgramIdsForIUPGMQuery;
        queryIUPGMRecordsWrapperObj.accountIdsForIUPGMSet = accountIdsForIUPGMSet;
        queryIUPGMRecordsWrapperObj.isPermissionSetAssignmentBased = isPermissionSetAssignmentBased;
        queryIUPGMRecordsWrapperObj.queryAllAccounts = true;
        queryIUPGMRecordsWrapperObj.notificationType = notificationType;
        queryIUPGMRecordsWrapperObj.objectName = 'REC - Recovery';
        
        iupgmRecordsList = Core_MDF_CCP_GenericUtility.getIUPGMRecordsByWrapper(queryIUPGMRecordsWrapperObj);
        
        for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : iupgmRecordsList){
            key = String.valueOf(iupgm.Core_MDF_Channel_Program_id__c) + String.valueOf(iupgm.Core_MDF_Account_id__c);
            
            if(accIdWithPrgKeyToAccNameMap.containsKey(key) || iupgm.Core_MDF_All_Accounts_cd__c == 'Yes'){
                Map<String, Set<String>> accountIdToNodeAccountIdMap = programIdToAccountIdtoNodeAccountIdSet.get(iupgm.Core_MDF_Channel_Program_id__c);
                User userRecord = new User(Id = iupgm.Core_MDF_User_id__c, Email = iupgm.Core_MDF_User_id__r.Email);
                if(iupgm.Core_MDF_All_Accounts_cd__c == 'Yes'){
                    for(String intelAccountId : accountIdToNodeAccountIdMap.keySet()){
                        iupgm.Core_MDF_Account_id__c = intelAccountId;
                        programToAccountToUsersMap = prepareAccountManagerNotificationMap(iupgm, programToAccountToUsersMap, accountIdToNodeAccountIdMap, userRecord);
                    }
                }else{
                    programToAccountToUsersMap = prepareAccountManagerNotificationMap(iupgm, programToAccountToUsersMap, accountIdToNodeAccountIdMap, userRecord);
                }
            }
        }
        return programToAccountToUsersMap;
    }
    
    /******************************************************************************************************
	Method Name:        prepareAccountManagerNotificationMap
	@return:            map of programid-accountid-users
	@parameters:        iupgm record, existing map to update, account id to node account id map, user
	Description:        This helper method is used to support 'getProgramAndAccountSpecificAccountManagers'
	Added By:           Accenture - Vikas Soni - 10/01/2025
	Modified By:        Date:       Changes:
    *******************************************************************************************************/
    public static Map<String, Map<String, Set<User>>> prepareAccountManagerNotificationMap(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm, Map<String, Map<String, Set<User>>> programToAccountToUsersMap, Map<String, Set<String>> accountIdToNodeAccountIdMap, User userRecord){
        Set<String> intelOrNodeAccountIdList = new Set<String>();
        intelOrNodeAccountIdList = accountIdToNodeAccountIdMap.get(iupgm.Core_MDF_Account_id__c);
        
        if(intelOrNodeAccountIdList != null){
            for(String intelOrNodeAccountId : intelOrNodeAccountIdList){
                if(programToAccountToUsersMap.containsKey(iupgm.Core_MDF_Channel_Program_Id__c)){
                    if(programToAccountToUsersMap.get(iupgm.Core_MDF_Channel_Program_Id__c).containsKey(intelOrNodeAccountId)){
                        programToAccountToUsersMap.get(iupgm.Core_MDF_Channel_Program_Id__c).get(intelOrNodeAccountId).add(userRecord);
                    }else{
                        programToAccountToUsersMap.get(iupgm.Core_MDF_Channel_Program_Id__c).put(intelOrNodeAccountId, new Set<User>{userRecord});
                    }
                }else{
                    programToAccountToUsersMap.put(iupgm.Core_MDF_Channel_Program_Id__c, new Map<String, Set<User>>{intelOrNodeAccountId => new Set<User>{userRecord}});
                }
            }
        }
        
        return programToAccountToUsersMap;
    }

    public static Set<String> getExcludeAccounts(String program){
        Map<String,String> programExcludeAccountMdtMap = Core_MDF_CCP_ConstantClass.Program_ExcludeAccountMdtMap;
        Set<String> excludeAccIdSet = new Set<String>(); // acc ids to be excluded for recovery
        List<String> mdtDevNameList = new List<String>();
        String mdt = programExcludeAccountMdtMap.get(program);
        mdtDevNameList.add(mdt);
        Map<String,String> mtdAccoutIdMap = new Map<String,String>();
        mtdAccoutIdMap = Core_MDF_CustomLabelConfig.getBulkTextValues(mdtDevNameList);
        if(mtdAccoutIdMap!=null && !mtdAccoutIdMap.keySet().isEmpty()){
            String accIds = mtdAccoutIdMap.get(mdt);
            if(String.isNotBlank(accIds)){
                excludeAccIdSet = new Set<String>(accIds.split(';'));
            }
        }
        return excludeAccIdSet;
    }
    
    public class RecoveryNotificationMapping {        
        public String program = '';
        public String months = '';
        public String weekAndDay = '';
        public String reminderDays = '';
        public String budgettype = '';
        public String region = '';
        public String onlyReadyToRecoverMonths = '';
        public String surePayExeTime ='';
        public String recoveryExeTime ='';
    }

    public class RecoveryAdminProgramMapping {        
        public String Program = '';
        public User user;
        public String programId = '';
    }
}