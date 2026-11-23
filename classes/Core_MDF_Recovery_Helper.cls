public without sharing class Core_MDF_Recovery_Helper {
    public static set<String> programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    public static List<String> core_MDF_Program_Recovery_Preselection = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Program_Recovery_Preselection');
    public static set<PartnerFundClaim> allClaims = new set<PartnerFundClaim>();
    public static Map<string,Map<id,decimal>> accountToEligibleClaims = new Map<string,Map<id,decimal>>();
    public static Map<string,decimal> budgetTypeGeoToAmountMap = new Map<string,decimal>();
    public static Map<string,Map<id,RecoveryRequestDetail>> accountEligibileClaimsBTGeo = new Map<string,Map<id,RecoveryRequestDetail>>();
    public static Map<id,string> rrBTGeo = new Map<id,string>();
    public static Map<id,RecoveryRequestDetail> claimIdToRequestDetail = new Map<id,RecoveryRequestDetail>();
    public static Map<id,id> claimToRR = new Map<id,id>();
    public static Map<string,Map<id,decimal>> readyTorecoveryRequestRecords = new Map<string,Map<id,decimal>>();
    public static Map<string,Map<id,decimal>> recoveredRecoveryRequestRecords = new Map<string,Map<id,decimal>>();
    // stores budgetType or Program to eligible cross recovery Budget Types
    public static Map<string,set<string>> crossBTorProgToBTMap = new Map<string,set<string>>();
    // stores claim id to budgetType or geo to recovery amount
    public static Map<id,Map<string,decimal>> clmToBtRecoveryAmt = new Map<id,Map<string,decimal>>();
    public static Map<Id, String> claimIdToClaimGeoMap = new Map<Id, String>();
    public static Map<Id, String> claimIdToClaimBudgetTypeMap = new Map<Id, String>();
    // stores DCF technical program name
    public static String progDCF = Label.Core_MDF_NonTranslateDCFRecordType;
    // stores CCF technical program name
    public static String progCCF = Label.Core_MDF_NonTranslateCCFRecordType;
    public static Set<id> pfcIdToSkip = new Set<Id>();
    public static Set<String> claimGeoSet = new Set<String>();
    public static Map<string,List<PartnerFundClaim>> accToClaimsMap = new Map<string,List<PartnerFundClaim>>();
	public static Map<Id,Decimal> clmIdToRecAmtMap = new Map<Id,Decimal>();    
    public static List<Integer> thirdMonthsList = Core_MDF_CustomLabelConfig.getIntegerList('Core_MDF_RecoveryRunMonthsCCF_DCF');
    public static String month_data = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Current_Month');
    public class ClaimAmtCompare implements Comparator<PartnerFundClaim> {
        public Integer compare(PartnerFundClaim e1, PartnerFundClaim e2) {
            // Guard against null operands for ‘<’ or ‘>’ operators because
            // they will always return false and produce inconsistent sorting
            Integer result;
            if (e1.Amount < e2.Amount) {
                  result = -1;
            } else if (e1.Amount > e2.Amount) {
                  result = 1;
            } else {
                  result = 0;  
            } 
        return result;
        }
    }
    //Method to return the Claims from the Recovery Request object or the Recommended Claims when called from Batch
    public static Map<string,List<RecoveryBatchParams>> getClaimsBasedOnConditionsForBatch(string programBudgetTypeQuarter, Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperForRecvryData){
        
        Map<string,Map<id,decimal>> recoveryRequestRecords = new Map<string,Map<id,decimal>>();
        Map<string,Map<string,decimal>> accountToBTGeoToAmountMap = new Map<string,Map<string,decimal>>();
        Map<string,Map<string,List<PartnerFundClaim>>> allClaimsList = new Map<string,Map<string,List<PartnerFundClaim>>>();
        Map<string,Map<id,decimal>> recommendedClaims = new Map<string,Map<id,decimal>>();
        Map<string,List<RecoveryBatchParams>> output = new Map<string,List<RecoveryBatchParams>>();
        List<id> accountsFiltered = new List<id>();
        Set<id> accountIds = new Set<id>(wrapperForRecvryData.accntListId);
        string programFromWraper = wrapperForRecvryData.program;
        
        //ThirdMonthsList = 3,6,9,12
        
        //String month_data = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Current_Month');
        
        Integer currMonth = System.today().month();
        if(month_data!=null && month_data!=''){
            currMonth = Integer.valueOf(month_data);
        }
        else{
            currMonth = System.today().month(); 
        }
        //List<string> regionList= wrapperForRecvryData.regionList;
        
        try{    
            List<string> keySplit = programBudgetTypeQuarter.split(';');
            List<string> programsForEligibilityRun = new List<string>();
            
            //First check if there are records in Recovery Request table
            
            recoveryRequestRecords = getDataFromRecoveryRequest(programBudgetTypeQuarter,wrapperForRecvryData, true);
            
            
            List<Core_MDF_Custom_Label_Configration__mdt> record = [select id, Core_MDF_Value_Txt__c, Core_MDF_Value2_Txt__c, Core_MDF_Value3_Txt__c,Core_MDF_Value4_Txt__c, Core_MDF_Value5_Txt__c  
                                                                    from Core_MDF_Custom_Label_Configration__mdt 
                                                                    where Label ='Core_MDF_Recovery_Batch_Eligibility_Pgms'];
            
            programsForEligibilityRun.add(record[0].Core_MDF_Value_Txt__c);   
            programsForEligibilityRun.add(record[0].Core_MDF_Value2_Txt__c); 
            programsForEligibilityRun.add(record[0].Core_MDF_Value3_Txt__c); 
            programsForEligibilityRun.add(record[0].Core_MDF_Value4_Txt__c); 
            programsForEligibilityRun.add(record[0].Core_MDF_Value5_Txt__c);   
           
            //Run eligibility for program included in the label (RMF)
            

            //ATHR Fix- Deeply nested if
            if(wrapperForRecvryData.source == 'Payment Run' && wrapperForRecvryData.isPreSelClaim_RecvryDone == false && (wrapperForRecvryData.isRecReq_RecvryDone==true) && ((recoveryRequestRecords.size() == 0 && programs_For_Node_Account.contains(programFromWraper)) || ((thirdMonthsList.contains(currMonth)) && core_MDF_Program_Recovery_Preselection.contains(programFromWraper)))){        
                    wrapperForRecvryData.isPreSelClaim_RecvryDone = true;
                    
                    //if(programsForEligibilityRun.contains(keySplit[0])){
                        //Filter out the Accounts that do not have RR so that they can be sent for Recovery Eligibility logic//[for ipa/rmf]
                        for(id inputIds: accountIds){
                            if((recoveredRecoveryRequestRecords.size()>0) && (!recoveredRecoveryRequestRecords.containsKey(inputIds)) && (core_MDF_Program_Recovery_Preselection.contains(programFromWraper))){
                                accountsFiltered.add(inputIds);
                            }
                            else if(!recoveryRequestRecords.containsKey(inputIds)){
                                accountsFiltered.add(inputIds);
                            }
                        }
                        
                        
                        //Check if the accounts have records in Partnership Score Detail to get the recovery amount
                        if(accountsFiltered.size() > 0 ){
                            Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperForFltedAccAndRgnLst = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
                            wrapperForFltedAccAndRgnLst.accntListId = accountsFiltered;
                            wrapperForFltedAccAndRgnLst.regionList = wrapperForRecvryData.regionList;
                            wrapperForFltedAccAndRgnLst.qtrYr = wrapperForRecvryData.qtrYr;
                            wrapperForFltedAccAndRgnLst.bdgtTypeList = wrapperForRecvryData.bdgtTypeList;
                            //if required add source and boolean indicators

                            accountToBTGeoToAmountMap = calculateRecoveryAmount(programBudgetTypeQuarter,wrapperForFltedAccAndRgnLst, true);
                        }
                        if(accountToBTGeoToAmountMap.size()> 0){
                            //Call method to get All Claims
                            allClaimsList = queryClaims(programBudgetTypeQuarter, accountsFiltered, true);
                            //ATHR Fix- Deeply nested if
                            //if(allClaimsList.size()>0){
                                //Call method to get Recommended Claims
                                recommendedClaims = allClaimsList.size()>0 ? processClaimsBasedOnBTGeo(accountToBTGeoToAmountMap,allClaimsList) : new Map<string,Map<id,decimal>>(); 
                            //}  
                        }
                    
            }
            
            
            if(recoveryRequestRecords.size() > 0){
                output = formatRecordsForBatch(recoveryRequestRecords, 'RR');
            }
            if(recommendedClaims.size()>0){
                output.putall(formatRecordsForBatch(recommendedClaims, 'Claims')) ;
            }
        }
        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}  
        return output;
    }
    
    //Method to display Eligibile Claims on the Claims Recovery Tab
    @AuraEnabled
    public static Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows getClaimsBasedOnConditionsForUI(string program, id account, string quarter){
        Map<string,Map<id,decimal>> recommendedRecoveries = new Map<string,Map<id,decimal>>();
        List<id> accountIdL = new List<id>();
        Map<string,Map<string,decimal>> accountToBTGeoToAmountMap = new Map<string,Map<string,decimal>>();
        Map<string,Map<string,List<PartnerFundClaim>>> allClaimsList = new Map<string,Map<string,List<PartnerFundClaim>>>();
        Map<string,Map<id,decimal>> recommendedClaims = new Map<string,Map<id,decimal>>();
        Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows rrRet = new Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows();
        string budgetTypeList = '';
        // Holds list of budgetType geo
        List<String> budgetGeoList = new List<String>();
        try{            
            //Hide Claim section if the quarter is not Current or Previous Quarter
            Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows rrResult = checkQuarterAndYear(quarter);
            if(rrResult.hideClaimInfo){
                return rrResult;
            }            
            accountIdL.add(account);
            
            //S&GP
            Core_MDF_RecoveryClaimReportViewCtrl.QuarterSurePayInfo info = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterInfoAndSurePayAmount(program,account);
            Decimal surePayRecAmount = Decimal.valueOf(info.surePayAmount);
            Set<String> surePayBTSet = info.surePayBTSet;
            clmIdToRecAmtMap = info.clmIdToRecAmtMap;
            
            Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperForRcvrData = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
                wrapperForRcvrData.accntListId = accountIdL;
            string programBudgetTypeQuarter= program + ';;'+ quarter;
            //Check if the accounts have records in Partnership Score Detail to get the recovery amount
            accountToBTGeoToAmountMap = calculateRecoveryAmount(programBudgetTypeQuarter,wrapperForRcvrData,false);
                        
            //If Partnership score detail exists:
            if(accountToBTGeoToAmountMap.size()>0 || surePayRecAmount >0){
                Set<String> combinedBTSet = new Set<String>();
                if(accountToBTGeoToAmountMap.size()>0){
                    //Create a list of all the Budget Types
                    Map<string,decimal> bTGeoMap = accountToBTGeoToAmountMap.get(account);
                    for(string bTGeo: bTGeoMap.keyset()){
                        List<string> bTGeoSplit = bTGeo.split(';');
                        if(!bTGeoSplit.isEmpty()){
                            combinedBTSet.add(bTGeoSplit[0]); // Budget Type
                        }
                        // Adding budgetType Geo (bTGeo) to the list
                        budgetGeoList.add(bTGeo);
                    }
                }
                if(surePayRecAmount >0 && surePayBTSet != null && !surePayBTSet.isEmpty()){
                    //system.debug('comingInsideSurePayIf::');
                    combinedBTSet.addAll(surePayBTSet);
                }
				if(!combinedBTSet.isEmpty()){
                    budgetTypeList = String.join(new List<String>(combinedBTSet), ',');
                    //system.debug('comingInsideCombinedIf::'+budgetTypeList);
                }
                programBudgetTypeQuarter = program + ';'+ budgetTypeList+ ';' + quarter;
                
                //Check for Recovery Requests
                recommendedRecoveries = getDataFromRecoveryRequest(programBudgetTypeQuarter,wrapperForRcvrData,false);
                
                //Call method to get All Claims
                allClaimsList = queryClaims(programBudgetTypeQuarter, accountIdL,false);
                
                //If there are no Recovery Requests, then send for calculating eligible claims
                if(recommendedRecoveries.size()==0 && allClaimsList.size()>0){
                    //Call method to get Recommended Claims
                    recommendedClaims = processClaimsBasedOnBTGeo(accountToBTGeoToAmountMap,allClaimsList);
                } 
            }
            //Show Recovery Requests if they exist or Eligible Claims if Recovery Requests don't exist
            if(recommendedRecoveries.size() > 0){
                rrRet = Core_MDF_RecoveryClaimReportViewCtrl.getOrganizedDataForClaimsToBeRecovered(allClaims,recommendedRecoveries.get(account),claimIdToRequestDetail,true,budgetGeoList,clmToBtRecoveryAmt,crossBTorProgToBTMap,clmIdToRecAmtMap);   
            }
            else if(recommendedClaims.size() > 0){
                rrRet = Core_MDF_RecoveryClaimReportViewCtrl.getOrganizedDataForClaimsToBeRecovered(allClaims,recommendedClaims.get(account),accountEligibileClaimsBTGeo.get(account),false,budgetGeoList,clmToBtRecoveryAmt,crossBTorProgToBTMap,clmIdToRecAmtMap);   
            }
            else if(surePayRecAmount >0 && recommendedRecoveries.size()==0 && recommendedClaims.size() == 0){
                system.debug('coming here::'+ allClaims);
                rrRet = Core_MDF_RecoveryClaimReportViewCtrl.getOrganizedDataForClaimsToBeRecovered(allClaims,null,null,false,null,null,crossBTorProgToBTMap,clmIdToRecAmtMap);   
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}  
        return rrRet;
    }
    
    //Check if the Quarter is Current or Previous Quarter.
    public static Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows checkQuarterAndYear(String quarter){
        
        Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows rrRet = new Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows();

        Date currDate = System.today();
        Integer currYear = currDate.year();
        Integer quarterNum = (currDate.month() - 1)/3;
        String currQuarter = quarterNum == 0 ? 'Q1' : quarterNum == 1 ? 'Q2' : quarterNum == 2 ? 'Q3' : quarterNum == 3 ? 'Q4' : '' ;
        String previousQuarterAndYear;
        if(quarterNum == 0){
            previousQuarterAndYear = 'Q4 ' +  (currYear - 1);
        }else{
            previousQuarterAndYear = 'Q' + quarterNum + ' ' + currYear;
        }
        
        //String currQuarterAndYear = currQuarter + ' ' + currYear; //TWC3117-16123
        
        //Allow specific users in the below list to see the claims if they select older quarters.
        String usersToBypass = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Bypass_Recovery_Selection');
        Boolean allowAllQuarters = String.isNotBlank(usersToBypass) ? usersToBypass.split(';').contains(UserInfo.getUserName()) : false;

        if(quarter != previousQuarterAndYear && !allowAllQuarters){
            rrRet.rows = null;
            rrRet.hideClaimInfo = true;
            rrRet.msgToShow = Label.Core_MDF_Recovery_PastQuarter_ErrorMsg1 + ' ' + previousQuarterAndYear + ' ' + Label.Core_MDF_Recovery_PastQuarter_ErrorMsg2;
        }else{
            rrRet.hideClaimInfo = false;
        }

        return rrRet;
    }
    
    //Method to get Recovery Request records for the Program, Account, Quarter if they exist
    public static Map<string,Map<id,decimal>> getDataFromRecoveryRequest(string programBudgetTypeQuarter, Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperForRecvryData, boolean isBatch) {
        Map<string,Map<id,decimal>> accountToRecoveryRequests = new Map<string,Map<id,decimal>>(); //what to do for budget types and quarter ...qtr should i update here as per source?like pre qtr?
        set<string> budgetTypeList = new set<string>();
        List<Core_MDF_Recovery_Request__c> rrList = new List<Core_MDF_Recovery_Request__c>();
        List<string> noBudgetTypePrograms = Label.Core_MDF_No_Budget_Types.split(';');
        boolean noBT;
        List<id> accountIds = wrapperForRecvryData.accntListId;
        List<string> regionList = wrapperForRecvryData.regionList;
        string source = wrapperForRecvryData.source;
        List<String> btListForBatch = wrapperForRecvryData.bdgtTypeList;
        // To indicate whether cross program is allowed or not
        boolean crossProgAllowed = false;
        boolean crossProgRecovery = false;
        try{
            
            List<string> keySplit = programBudgetTypeQuarter.split(';');
            string program = keySplit[0];
            string budTypeForBatch = keySplit[1];
            string crossProgram = program == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_Technical_program_name') ? progDCF : program == Label.Core_MDF_NonTranslateCCFBoostRecordType ? progCCF : null;

            // check if program is IPA
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
                // MDF:MDF+;MDF+:MDF;CCF 1.0:OEM CMP;DCF 1.0:OEM CMP,Service Provider CMP;Service Provider CoMarketing Fund:OEM CMP,Service Provider CMP
                List<String> crossBTorProgList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_CrossBTorProgRecoveries'); 
                // Looping over the list
                for(string tempString : crossBTorProgList){
                    List<String> btOrProg = tempString.split(':');
                    set<String> crossBT = new set<string>();
                    crossBT.addAll(btOrProg[1].split(','));
                    // setting key as BT or Program and value as eligible cross recovery Budget Types
                    crossBTorProgToBTMap.put(btOrProg[0],crossBT);
                }
            }
            if(noBudgetTypePrograms.contains(program) || program == progDCF || program == progCCF){
                crossProgRecovery = true;
            }
            // if program is SPCF/CCFB and crossBTorProgToBTMap contains this program and get is not null, then add the eligible budget types to budgetTypeList and crossProgAllowed to true
            if(noBudgetTypePrograms.contains(program) && crossBTorProgToBTMap.containsKey(program) && crossBTorProgToBTMap.get(program)!= NULL){
                budgetTypeList.add('');
                budgetTypeList.addAll(crossBTorProgToBTMap.get(program));
                crossProgAllowed = true;
            }else if(isBatch){
                budgetTypeList.addAll(btListForBatch);
            }else if(keySplit[1] != ''){
                // looping over the budget type values
                for(string bt : keySplit[1].split(',')){
                    // if crossBTorProgToBTMap contains bt, then add all the eligible cross recovery budget types to the list
                    if(crossBTorProgToBTMap.containsKey(bt) && crossBTorProgToBTMap.get(bt)!= NULL){
                        budgetTypeList.addAll(crossBTorProgToBTMap.get(bt)); 
                        budgetTypeList.add(bt);
                    }else{
                        budgetTypeList.addAll(keySplit[1].split(','));
                    }
                }                
            }
            
            string quarter = keySplit[2];
            noBT =noBudgetTypePrograms.contains(keySplit[0]) ?true: false;
            
            String strQuery = '';
            String vatValue = Label.Core_MDF_Service_Invoice_to_Intel;
            strQuery = 'select id,Core_MDF_Claim_Id__c,Core_MDF_Claim_Id__r.Core_MDF_Claim_Ref_Number__c,Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c,Core_MDF_Active_RO_Ind__c, Core_MDF_Ready_to_Recover_RO_Ind__c,';
            strQuery += 'Core_MDF_Claim_Id__r.Core_MDF_Region_Cd__c, Core_MDF_Claim_Id__r.Core_MDF_Status__c,Core_MDF_Claim_Id__r.Core_MDF_Activity_Category__c,';
            strQuery += 'Core_MDF_Claim_Id__r.Core_MDF_Activity_Types__c, Core_MDF_Claim_Id__r.Core_MDF_Requested_Reimbursement_Amt__c, Core_MDF_Claim_Id__r.Core_MDF_VAT_Opt_In_txt__c, Core_MDF_Recovery_Amount_Amt__c,Core_MDF_Recovery__c,';
            strQuery += 'Core_MDF_Program_Nm__c, Core_MDF_Account_Id__c, Core_MDF_Quarter_Year_Nm__c,Core_MDF_Recovered_Budget_Nm__c,Core_MDF_Comment_Txt__c,Core_MDF_Ready_to_Recover_Ind__c,Core_MDF_Active_Ind__c ';
            strQuery += 'from Core_MDF_Recovery_Request__c ';
            strQuery += 'where Core_MDF_Quarter_Year_Nm__c=:quarter and ';
            strQuery += 'Core_MDF_Account_Id__c in:accountIds and ';
            strQuery += 'Core_MDF_Claim_Id__r.Core_MDF_Status__c in (\'Payment Due\',\'Pending Available Fund\') and Core_MDF_Claim_Id__r.Amount>0 and ';
            if(crossProgAllowed && isBatch){
                strQuery += 'Core_MDF_Program_Nm__c =:program ';
            	if(source != 'Payment Run'){
                    strQuery += 'and Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c =:budTypeForBatch ';
                }else if(source == 'Payment Run' && btListForBatch != null && btListForBatch.size()>0){
                    strQuery += 'and Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c in:btListForBatch ';
                }
            }else if(crossProgRecovery){
                        strQuery += '(((Core_MDF_Program_Nm__c =:program and Core_MDF_Claim_Id__r.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c !=: program) OR (Core_MDF_Program_Nm__c !=: program and Core_MDF_Claim_Id__r.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =: program)) OR ';
                        if(crossProgAllowed && crossProgram != null){
                            strQuery += '(Core_MDF_Program_Nm__c =:program or ';
                            strQuery += '(Core_MDF_Program_Nm__c =:crossProgram  ';
                            //ATHR Fix- Deeply nested if
                            /*if(budgetTypeList != null && budgetTypeList.size() >0){
                                strQuery += 'and Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c in:budgetTypeList))) ';
                            }else{
                                strQuery += ' )))';
                            }*/
                            strQuery += (budgetTypeList != null && !budgetTypeList.isEmpty()) ? 'and Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c in:budgetTypeList))) ' : ' )))';
                        }else{
                            strQuery += '(Core_MDF_Program_Nm__c =:program  ';
                            //ATHR Fix- Deeply nested if
                            /*if(budgetTypeList != null && budgetTypeList.size() >0){
                                strQuery += 'and Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c in:budgetTypeList)) ';
                            }else{
                                strQuery += ' ))';
                            }*/
                            strQuery += (budgetTypeList != null && budgetTypeList.size() >0) ? 'and Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c in:budgetTypeList)) ' : ' ))';
                        }
            }else{
                strQuery += 'Core_MDF_Program_Nm__c =:program ';
                if(!noBT && budgetTypeList != null && budgetTypeList.size() >0 ){
                    strQuery += 'and Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c in:budgetTypeList '; 
                }
	        }
            if(regionList != null && regionList.size()>0 && !regionList.isEmpty()){
                strQuery += 'and Core_MDF_Claim_Id__r.Core_MDF_Region_Cd__c in: regionList ';
            }
            if(Core_MDF_Utility.byPassFeature('bypass_VATClaimsForRecovery')){
                strQuery += 'and Core_MDF_Claim_Id__r.Core_MDF_VAT_Opt_In_txt__c != :vatValue ';
            }
            Integer currMonth = System.today().month();
            if(month_data!=null && month_data!=''){
                 currMonth = Integer.valueOf(month_data);
            }
            else{
                currMonth = System.today().month(); 
            }
            if(isBatch && source == 'Payment Run' && (wrapperForRecvryData.isRecReq_RecvryDone==True) && (wrapperForRecvryData.isPreSelClaim_RecvryDone==False) && (core_MDF_Program_Recovery_Preselection.contains(program)) && thirdMonthsList.contains(currMonth)){
               
                strQuery += 'and ((Core_MDF_Active_RO_Ind__c = false and Core_MDF_Ready_to_Recover_RO_Ind__c = false and Core_MDF_Recovery__c!=null and CALENDAR_MONTH(LastModifiedDate)=:currMonth)';
            	strQuery += 'or (Core_MDF_Active_RO_Ind__c =true  and Core_MDF_Ready_to_Recover_RO_Ind__c =true))';
            }else{
            // claims can be recovered only if the ready to recover is selected
                if(isBatch) {
                    strQuery += 'and Core_MDF_Active_RO_Ind__c = true and Core_MDF_Ready_to_Recover_RO_Ind__c = true ';
                } else {
                    strQuery += 'and Core_MDF_Active_RO_Ind__c = true';
                }
            }
            
            rrList = Database.query(strQuery);
            //ATHR Fix- Deeply nested if
            if(rrList.isEmpty()){
                return accountToRecoveryRequests;
            }
            //if(rrList.size()>0){
                for(Core_MDF_Recovery_Request__c rr: rrList){
                    if(rr.Core_MDF_Program_Nm__c != program){
                        pfcIdToSkip.add(rr.Core_MDF_Claim_Id__c);
                    }else{
                    string key = rr.Core_MDF_Account_Id__c;
                    string value = rr.Core_MDF_Recovered_Budget_Nm__c;

                        if(rr.Core_MDF_Active_RO_Ind__c==false && rr.Core_MDF_Ready_to_Recover_RO_Ind__c==false && rr.Core_MDF_Recovery__c!=null){
                            if(recoveredRecoveryRequestRecords != null  && recoveredRecoveryRequestRecords.containsKey(key)){
                                
                                recoveredRecoveryRequestRecords.get(key).put(rr.Core_MDF_Claim_Id__c,rr.Core_MDF_Recovery_Amount_Amt__c);
                            }else{
                                Map<id,decimal> tempMap = new Map<id,decimal>();
                                tempMap.put(rr.Core_MDF_Claim_Id__c,rr.Core_MDF_Recovery_Amount_Amt__c);
                                    recoveredRecoveryRequestRecords.put(key,tempMap);
                            }
                        }
                        else{
                             if(rr.Core_MDF_Active_RO_Ind__c==true && rr.Core_MDF_Ready_to_Recover_RO_Ind__c==true){
                                if(readyTorecoveryRequestRecords != null  && readyTorecoveryRequestRecords.containsKey(key)){    
                                    readyTorecoveryRequestRecords.get(key).put(rr.Core_MDF_Claim_Id__c,rr.Core_MDF_Recovery_Amount_Amt__c);
                                }       
                                else{
                                    Map<id,decimal> tempMap = new Map<id,decimal>();
                                    tempMap.put(rr.Core_MDF_Claim_Id__c,rr.Core_MDF_Recovery_Amount_Amt__c);
                                    readyTorecoveryRequestRecords.put(key,tempMap);
                                }
                            }
					

                            if(accountToRecoveryRequests != null && accountToRecoveryRequests.containsKey(key)){
                                accountToRecoveryRequests.get(key).put(rr.Core_MDF_Claim_Id__c,rr.Core_MDF_Recovery_Amount_Amt__c);    
                            }
                            else{
                                Map<id,decimal> tempMap = new Map<id,decimal>();
                                tempMap.put(rr.Core_MDF_Claim_Id__c,rr.Core_MDF_Recovery_Amount_Amt__c);
                                accountToRecoveryRequests.put(key,tempMap);                            
                            }
                            Boolean rrrBool = rr.Core_MDF_Ready_to_Recover_RO_Ind__c;
                            //String rrrString = JSON.serialize(rrrBool);
                            rrBTGeo.put(rr.Core_MDF_Claim_Id__c,value);
                            
                            RecoveryRequestDetail rrd = new RecoveryRequestDetail();
                            rrd.comments = rr.Core_MDF_Comment_Txt__c;
                            rrd.budgetGeo = value;
                            rrd.readyToRecoverInd = rrrBool;
                            claimIdToRequestDetail.put(rr.Core_MDF_Claim_Id__c, rrd);
                            //claimIdToRequestDetail.put(rr.Core_MDF_Claim_Id__c,rr.Core_MDF_Comment_Txt__c + '!' + value);
                            claimToRR.put(rr.Core_MDF_Claim_Id__c,rr.Id);
                        }
                    }
                } 
            //}
             
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}  
        return accountToRecoveryRequests;
    }
    
    //Method to calculate the Recovery Amount per Budget Type and Region for a Program, Account, Quarter
    public static Map<string,Map<string,decimal>> calculateRecoveryAmount(string programBudgetTypeQuarter, Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperForRecvryData, boolean isBatch){
        
        Map<string,Map<string,decimal>> accountToRecoveryAmount = new Map<string,Map<string,decimal>>();
        List<Core_MDF_Partnership_Score_Detail__c> psdList = new List<Core_MDF_Partnership_Score_Detail__c>();
        //List<Core_MDF_Partnership_Score_Detail__c> psdList1 = new List<Core_MDF_Partnership_Score_Detail__c>(); //TWC3117-16123
        boolean noBT = false;
        List<id> accountIds = wrapperForRecvryData.accntListId;
        List<string> regionList = wrapperForRecvryData.regionList;
        try{
            //string recoveryPercentages = Label.Core_MDF_Recovery_Percentages;
            List<string> noBudgetTypePrograms = Label.Core_MDF_No_Budget_Types.split(';');
            List<string> keySplit = programBudgetTypeQuarter.split(';');
            string program = keySplit[0];
            string budgetType = keySplit[1];
            string quarter = keySplit[2];
            decimal balance;
            //Map<string,decimal> programToRecoveryPct = new Map<string,decimal>();
            
            /*for(string key: recoveryPercentages.split(';')){
                List<string> prgmSplit = key.split(':');
                decimal recoveryPct = (decimal.valueof(prgmSplit[1])/100).setScale(2);
                programToRecoveryPct.put(prgmSplit[0],recoveryPct);
            }*/           
            //noBT =noBudgetTypePrograms.contains(keySplit[0]) ?true: false;
            noBT = noBudgetTypePrograms.contains(keySplit[0]); //TWC3117-16123
            
            String strQuery = '';
            strQuery = 'select id,Core_MDF_Budget_Type_Nm__c,Core_MDF_Region_Cd__c,Core_MDF_Balance_Amount_Amt__c,Core_MDF_Node_Account_Id__c,';
            strQuery += 'Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c,';
            strQuery += 'Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c ';
            strQuery += 'from Core_MDF_Partnership_Score_Detail__c ';
            strQuery += 'where Core_MDF_Region_Cd__c != null AND Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c =:program and ';
            strQuery += 'Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c =:quarter and ';
            if(regionList != null && regionList.size() > 0){
                strQuery += 'Core_MDF_Region_Cd__c in:regionList and ';
            }
            if(programs_For_Node_Account.contains(program)){
                strQuery += 'Core_MDF_Node_Account_Id__c in:accountIds';
            }
            else{
            	strQuery += 'Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c in:accountIds';
            }
            if(isBatch && !noBT && budgetType != null && budgetType != ''){
                strQuery += ' and Core_MDF_Budget_Type_Nm__c =:budgetType';
            }
            
            psdList = Database.query(strQuery);
            if(psdList.size()>0){
                for(Core_MDF_Partnership_Score_Detail__c psd: psdList){
                    string key;
                    //Set<string> Programs_For_Node_Account = new Set<string>{'Retail Marketing Funds','Intel Partner Alliance'};
                    if(programs_For_Node_Account.contains(program)){
                        key = psd.Core_MDF_Node_Account_Id__c;    
                    }
                    else{
                        key = psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c;
                    }
                    string bTorPgm = noBT? program : psd.Core_MDF_Budget_Type_nm__c;
                    string key2 = bTorPgm + ';' + psd.Core_MDF_Region_Cd__c;
                    //string key3 = program + '-' + psd.Core_MDF_Budget_Type_nm__c;
                    //balance = programToRecoveryPct.containsKey(key3)? (psd.Core_MDF_Balance_Amount_Amt__c *programToRecoveryPct.get(key3)).setScale(2) : psd.Core_MDF_Balance_Amount_Amt__c;
                    balance = psd.Core_MDF_Balance_Amount_Amt__c;
                    if(accountToRecoveryAmount != null && accountToRecoveryAmount.containsKey(key)){   
                        accountToRecoveryAmount.get(key).put(key2,balance);
                    }
                    else{
                        Map<string,decimal> tempMap = new Map<string,decimal>();
                        tempMap.put(key2,balance);
                        accountToRecoveryAmount.put(key,tempMap); 
                    }
                } 
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return accountToRecoveryAmount;
    }
    
    //Query all Payment Due, Pending Availbale Funds claims for a Program, Account
    public static Map<string,Map<string,List<PartnerFundClaim>>> queryClaims(string programBudgetTypeQuarter, List<id> account, boolean isBatch){
        Map<string,Map<string,List<PartnerFundClaim>>> accountToClaims = new Map<string,Map<string,List<PartnerFundClaim>>>();
        set<string> budgetTypeList = new set<string>();
        List<PartnerFundClaim> claimList = new List<PartnerFundClaim>();
        boolean noBt;
        List<string> noBudgetTypePrograms = Label.Core_MDF_No_Budget_Types.split(';');
        List<string> keySplit = programBudgetTypeQuarter.split(';');
        boolean crossProgAllowed = false;        
        try{
            string program = keySplit[0];
            string crossProgram = program == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_Technical_program_name') ? progDCF : program == Label.Core_MDF_NonTranslateCCFBoostRecordType ? progCCF : null;
            // if program is SPCF/CCFB, add eligibile cross recovery BT's
            if(noBudgetTypePrograms.contains(program) && crossBTorProgToBTMap.containsKey(program) && crossBTorProgToBTMap.get(program)!= NULL){
                budgetTypeList.addAll(crossBTorProgToBTMap.get(program));
                crossProgAllowed = true;
            }else{
                if(keySplit[1] != ''){
                    for(string bt : keySplit[1].split(',')){
                        if(crossBTorProgToBTMap.containsKey(bt) && crossBTorProgToBTMap.get(bt)!= NULL){
                            budgetTypeList.addAll(crossBTorProgToBTMap.get(bt)); 
                            budgetTypeList.add(bt);
                        }else{
                            budgetTypeList.addAll(keySplit[1].split(','));
                        }
                    }
                }
            }
            noBT =noBudgetTypePrograms.contains(keySplit[0]) ?true: false;
            
            String strQuery = '';
            String vatValue = Label.Core_MDF_Service_Invoice_to_Intel;
            strQuery = 'select id,Core_MDF_Claim_Ref_Number__c,Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Region_Cd__c, Core_MDF_Status__c,Core_MDF_Activity_Category__c,Core_MDF_VAT_Opt_In_txt__c,Core_MDF_Processing_Preference_nm__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c,';
            strQuery += 'Core_MDF_Activity_Types__c, Amount, Core_MDF_Program__c, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Country_Location_nm__c,Core_MDF_Recovery_Hold_Ind__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c,Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c ';
            strQuery += 'from PartnerFundClaim ';
            strQuery += 'where Core_MDF_Status__c in (\'Payment Due\',\'Pending Available Fund\') and Amount>0 and ';            
            if(programs_For_Node_Account.contains(program)){
                strQuery += 'ChannelPartnerId in:account and ';
            }
            else{
            	strQuery += 'ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c in:account and ';
            }
            //strQuery += '(Core_MDF_Processing_Preference_nm__c != \'Settle, then get paid\' OR (Core_MDF_Processing_Preference_nm__c = \'Settle, then get paid\' AND (Core_MDF_Claim_Review_Case__c = null OR (Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c = \'Review Completed\' AND (Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c > 0 and Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c = 0))))) and ';
            strQuery += '(Core_MDF_Processing_Preference_nm__c != \'Settle, then get paid\' OR (Core_MDF_Processing_Preference_nm__c = \'Settle, then get paid\' AND (Core_MDF_Claim_Review_Case__c = null OR (Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c = \'Review Completed\' AND Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c >= 0)))) AND ';
            if(Core_MDF_Utility.byPassFeature('bypass_VATClaimsForRecovery')){
                strQuery += 'Core_MDF_VAT_Opt_In_txt__c != :vatValue and ';
            }
            strQuery += 'Core_MDF_Type_Txt__c = \'Claim\' and ';
            // Exclude Super Claims (having sub claims only) and its Sub Claims for all program
            strQuery += 'Core_MDF_Claim_Id__c = null and Core_MDF_Has_Sub_Claims_Ind__c = false and ';
            if(crossProgAllowed && crossProgram != null && budgetTypeList!= null && budgetTypeList.size()>0){
                strQuery += '(ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =:program or ';
            	strQuery += '(ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =:crossProgram and Core_MDF_Budget_Type_Options_Nm__c in:budgetTypeList))';
            }else{
                strQuery += 'ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =:program ';
                if(!noBT && budgetTypeList!= null && budgetTypeList.size()>0){
                    strQuery += 'and Core_MDF_Budget_Type_Options_Nm__c in:budgetTypeList '; 
                }
            }
            strQuery += 'order by Core_MDF_Recovery_Hold_Ind__c desc, Core_MDF_Status__c, Amount desc'; 
            claimList = Database.query(strQuery);
            //ATHR Fix - Deeply nested if
            //if(claimList.size()>0){
                for(PartnerFundClaim claim:((claimList != null && claimList.size() > 0) ? claimList : new List<PartnerFundClaim>())){
                    if(pfcIdToSkip != NULL && pfcIdToSkip.size() >0 && pfcIdToSkip.contains(claim.Id)){
                        continue;
                    }
                    string key1;
                    if(programs_For_Node_Account.contains(program)){
                        key1 = claim.ChannelPartnerId;
                    }
                    else{
                        key1 = claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
                    }      
                    //string bTorPgm = noBT ? program : claim.Core_MDF_Budget_Type_Options_Nm__c;
                    string bTorPgm = claim.Core_MDF_Budget_Type_Options_Nm__c != NULL ? claim.Core_MDF_Budget_Type_Options_Nm__c : program;
                    string key2 = bTorPgm +';'+ claim.Core_MDF_Region_Cd__c;
                    claimGeoSet.add(claim.Core_MDF_Region_Cd__c);
                    if(accToClaimsMap != null && accToClaimsMap.containsKey(key1)){
                        accToClaimsMap.get(key1).add(claim);
                    }else{
                        List<PartnerFundClaim> tempList = new List<PartnerFundClaim>();
                        tempList.add(claim);
                        accToClaimsMap.put(key1,tempList);
                    }
                    if(accountToClaims != null && accountToClaims.containsKey(key1)){
                        Map<string,List<PartnerFundClaim>> tempMap = accountToClaims.get(key1);
                        if(tempMap != null && tempMap.containsKey(key2)){
                            tempMap.get(key2).add(claim);
                        }
                        else{
                            List<PartnerFundClaim> tempList = new List<PartnerFundClaim>();
                            tempList.add(claim);
                            tempMap.put(key2,tempList);
                        }
                        accountToClaims.put(key1,tempMap);
                    }
                    else{
                        Map<string,List<PartnerFundClaim>> tempMap = new Map<string,List<PartnerFundClaim>>();
                        List<PartnerFundClaim> tempList = new List<PartnerFundClaim>();
                        tempList.add(claim);
                        tempMap.put(key2,tempList);
                        accountToClaims.put(key1,tempMap);
                    } 
                    allClaims.add(claim);
                    claimIdToClaimGeoMap.put(claim.Id, claim.Core_MDF_Region_Cd__c);
                    claimIdToClaimBudgetTypeMap.put(claim.Id, claim.Core_MDF_Budget_Type_Options_Nm__c);
                }
                
            //}
            
        }
        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return accountToClaims;
    }
    public static list<PartnerFundClaim> reverseSort(list<PartnerFundClaim> claimListTobeSorted){
        //list<PartnerFundClaim> sortedClaimList = new list<PartnerFundClaim>();
        list<PartnerFundClaim> finalSortedClaimList = new list<PartnerFundClaim>();
        List<PartnerFundClaim> paymentDueWithRecHold = new List<PartnerFundClaim>();
        List<PartnerFundClaim> PAFWithRecHold = new List<PartnerFundClaim>();
        List<PartnerFundClaim> paymentDueWithoutRecHold = new List<PartnerFundClaim>();
        List<PartnerFundClaim> PAFWithoutRecHold = new List<PartnerFundClaim>();
        for(integer i = claimListTobeSorted.size()-1; i >= 0;i--){
            if(claimListTobeSorted[i].Core_MDF_Recovery_Hold_Ind__c){
                if(claimListTobeSorted[i].Core_MDF_Status__c == 'Payment Due'){
                    paymentDueWithRecHold.add(claimListTobeSorted[i]);
                }else{
                    PAFWithRecHold.add(claimListTobeSorted[i]);
                }
            }else{
                if(claimListTobeSorted[i].Core_MDF_Status__c == 'Payment Due'){
                    paymentDueWithoutRecHold.add(claimListTobeSorted[i]);
                }else{
                    PAFWithoutRecHold.add(claimListTobeSorted[i]);
                }
                //sortedClaimList.add(claimListTobeSorted[i]);
            }
            
        }
        finalSortedClaimList.addAll(paymentDueWithRecHold);
        finalSortedClaimList.addAll(PAFWithRecHold);
        finalSortedClaimList.addAll(paymentDueWithoutRecHold);
        finalSortedClaimList.addAll(PAFWithoutRecHold);
        
        return finalSortedClaimList;
    }
    
    //Logic to get the recommended claims based on Budget Type, Region or Budget Type, cross Region 
    public static Map<string,Map<id,decimal>> processClaimsBasedOnBTGeo(Map<string,Map<string,decimal>> accountToBTGeoToAmountMap,Map<string,Map<string,List<PartnerFundClaim>>> allClaimsList) {
        Map<string,Map<id,decimal>> eligibleClaimRecords = new Map<string,Map<id,decimal>>();
        Set<string> crossbudTypeRecKey = new Set<string>();
        Set<string> crossbudTypeGeoRecKey = new Set<string>();
        try{
            //Loop through the Partnership Score Details
            for(string programAccountQ: accountToBTGeoToAmountMap.keyset()){
                Map<id,decimal> eligibleClaimsList= new  Map<id,decimal>();
                budgetTypeGeoToAmountMap = accountToBTGeoToAmountMap.get(programAccountQ);
                Map<String,List<PartnerFundClaim>> crossRecBudGeoMap = new Map<String,List<PartnerFundClaim>>();
                Map<String,List<PartnerFundClaim>> crossRecGeoMap = new Map<String,List<PartnerFundClaim>>();

                //Check if there are matching claims for Same Budget Type + Same Geo
                for(string budgetGeo: budgetTypeGeoToAmountMap.keyset()){ //Same Budget type & Same Geo
                    List<PartnerFundClaim> sameBTGeotoBeProcessed = new List<PartnerFundClaim>();
                    string sameBTGeokey = 'Budget+Geo'+':'+budgetGeo;
                    if(allClaimsList.containsKey(programAccountQ)){
                        //Get all claims that are of same Budget Type Geo of the recovery record
                        Map<string,List<PartnerFundClaim>> sameBTGeoclaimList = allClaimsList.get(programAccountQ);
                        if(sameBTGeoclaimList != null && sameBTGeoclaimList.containsKey(budgetGeo) && sameBTGeoclaimList.get(budgetGeo) != NULL){
                            sameBTGeotoBeProcessed.addAll(sameBTGeoclaimList.get(budgetGeo));                                                 
                        }
                    } 
                    // if toBeProcessed not null, then call the eligibility logic
                    if(sameBTGeotoBeProcessed != null && sameBTGeotoBeProcessed.size()>0){
                        eligibleClaimsList.putall(eligibilityLogic(sameBTGeokey,sameBTGeotoBeProcessed,'sameBudgetType'));
                    }
                }

                //Check if there are matching claims for Same Budget type and Cross Geo
                for(string budgetGeo: budgetTypeGeoToAmountMap.keyset()){//Same Budget type & Different Geo

                    // for same BT,crossgeo  or cross bt,cross geo
                    List<PartnerFundClaim> toBeProcessed1 = new List<PartnerFundClaim>();
                    List<PartnerFundClaim> toBeProcessedCrossRec = new List<PartnerFundClaim>();
                    Set<String> geoSet = new Set<String>();
                    //If there is dollar value still to be recovered for the Account/Program/Quarter
                    //ATHR Fix- Deeply nested if
                    if(budgetTypeGeoToAmountMap.get(budgetGeo)!=0 && allClaimsList.containsKey(programAccountQ)){
                        //if(allClaimsList.containsKey(programAccountQ)){
                            Map<string,List<PartnerFundClaim>> claimList = allClaimsList.get(programAccountQ);
                            string key = 'Budget+Geo'+':'+budgetGeo;
                            string key2 = 'Geo' + ':' + budgetGeo; 
                            List<String> budgetGeoList = budgetGeo.split(';');
                            if(claimList != null){                          
                                //Get all claims that are of same Budget Type of the recovery record
                                for(string bTGeo: claimList.keyset()){                                
                                    List<String> btGeoSplit = bTGeo.split(';');
                                    //ATHR Fix- Deeply nested if
                                    if(budgetGeoList[0] == btGeoSplit[0] && claimList.containsKey(bTGeo) && claimList.get(bTGeo) != NULL){
                                        //if(claimList != null && claimList.containsKey(bTGeo) && claimList.get(bTGeo) != NULL){
                                            toBeProcessed1.addAll(claimList.get(bTGeo));                                    
                                        //}
                                    }
                                }
                                
                                // if toBeProcessed1 not null, then call the eligibility logic
                                if(toBeProcessed1 !=null && toBeProcessed1.size()>0){
                                    ClaimAmtCompare clmAmtCompare = new ClaimAmtCompare();
                                    toBeProcessed1.sort(clmAmtCompare);
                                    toBeProcessed1 = reverseSort(toBeProcessed1);
                                    eligibleClaimsList.putall(eligibilityLogic(key2,toBeProcessed1,'sameBudgetType'));
                                }

                                //Get all claims that are of same Budget Type Geo of the recovery record
                                Map<string,List<PartnerFundClaim>> sameBTGeoclaimList = allClaimsList.get(programAccountQ);
                                //if(sameBTGeoclaimList != null && sameBTGeoclaimList.containsKey(budgetGeo) && sameBTGeoclaimList.get(budgetGeo) != NULL){
                                    list<string> sameBTGeosplitBudgetGeo = budgetGeo.split(';');
                                    // checking if budget type is available in crossBTorProgToBTMap
                                    if(crossBTorProgToBTMap.containsKey(sameBTGeosplitBudgetGeo[0]) && crossBTorProgToBTMap.get(sameBTGeosplitBudgetGeo[0]) != NULL){
                                        // looping over the cross budget type values
                                        for(String sameBTGeocrossBt : crossBTorProgToBTMap.get(sameBTGeosplitBudgetGeo[0])){
                                            // preparing a temperory key with budget type and geo
                                            String sameBTGeotempKey = sameBTGeocrossBt + ';' + sameBTGeosplitBudgetGeo[1];
                                            crossbudTypeRecKey.add(sameBTGeotempKey);                                
                                        }                                
                                    }                                                 
                                //}

                                // splitting budgetGeo with ;
                                list<string> splitBudgetGeo = budgetGeo.split(';');
                                // checking if budget type is available in crossBTorProgToBTMap
                                if(crossBTorProgToBTMap.containsKey(splitBudgetGeo[0]) && crossBTorProgToBTMap.get(splitBudgetGeo[0]) != NULL){
                                    // looping over the cross budget type values
                                    for(String crossBt : crossBTorProgToBTMap.get(splitBudgetGeo[0])){
                                        for(String geo : claimGeoSet){
                                            // preparing a temperory key with budget type and geo
                                            String tempKey = crossBt + ';' + geo;
                                            crossbudTypeGeoRecKey.add(tempKey);
                                        }                                                                     
                                    }
                                    if(accToClaimsMap != NULL && accToClaimsMap.containsKey(programAccountQ) && accToClaimsMap.get(programAccountQ) != NULL){
                                        for(PartnerFundClaim claim : accToClaimsMap.get(programAccountQ)){
                                            string bTorPgm = claim.Core_MDF_Budget_Type_Options_Nm__c != NULL ? claim.Core_MDF_Budget_Type_Options_Nm__c : claim.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
                                            string tempkey = bTorPgm +';'+ claim.Core_MDF_Region_Cd__c;
                                            if(crossbudTypeRecKey != null && crossbudTypeRecKey.size() > 0 && crossbudTypeRecKey.contains(tempkey)){
                                                toBeProcessedCrossRec.add(claim);
                                            }  
                                        }
                                    }
                                    if(toBeProcessedCrossRec != null && toBeProcessedCrossRec.size()>0){                                
                                        crossRecBudGeoMap.put(key,toBeProcessedCrossRec);
                                    }
                                }
                            }
                        //}
                    }
                }

                if(crossRecBudGeoMap.keyset() != NULL){
                    for(String key : crossRecBudGeoMap.keyset()){  
                        eligibleClaimsList.putall(eligibilityLogic(key,crossRecBudGeoMap.get(key),'crossBudgetType'));
                    }
                }

                //Check if there are matching claims for Cross Budget type and Same Geo
                for(string budgetGeo: budgetTypeGeoToAmountMap.keyset()){ //Cross Budget type & Same Geo
                    
                    // for same BT,crossgeo  or cross bt,cross geo
                    List<PartnerFundClaim> toBeProcessedCrossRec1 = new List<PartnerFundClaim>();
                    Set<String> geoSet = new Set<String>();
                    //If there is dollar value still to be recovered for the Account/Program/Quarter
                    //ATHR Fix- Deeply nested if
                    if(budgetTypeGeoToAmountMap.get(budgetGeo)!=0 && allClaimsList.containsKey(programAccountQ)){
                        //if(allClaimsList.containsKey(programAccountQ)){
                            Map<string,List<PartnerFundClaim>> claimList = allClaimsList.get(programAccountQ);
                            string key2 = 'Geo' + ':' + budgetGeo; 
                            //ATHR Fix- Deeply nested if
                            if(claimList == null){
                                continue;
                            }
                            //if(claimList != null){ 
                                // splitting budgetGeo with ;
                                list<string> splitBudgetGeo = budgetGeo.split(';');
                                // checking if budget type is available in crossBTorProgToBTMap
                                if(crossBTorProgToBTMap.containsKey(splitBudgetGeo[0]) && crossBTorProgToBTMap.get(splitBudgetGeo[0]) != NULL){
                                    // looping over the cross budget type values
                                    for(String crossBt : crossBTorProgToBTMap.get(splitBudgetGeo[0])){
                                        for(String geo : claimGeoSet){
                                            // preparing a temperory key with budget type and geo
                                            String tempKey = crossBt + ';' + geo;
                                            crossbudTypeGeoRecKey.add(tempKey);
                                        }                                                                     
                                    }
                                    if(accToClaimsMap != NULL && accToClaimsMap.containsKey(programAccountQ) && accToClaimsMap.get(programAccountQ) != NULL){
                                        for(PartnerFundClaim claim : accToClaimsMap.get(programAccountQ)){
                                            string bTorPgm = claim.Core_MDF_Budget_Type_Options_Nm__c != NULL ? claim.Core_MDF_Budget_Type_Options_Nm__c : claim.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
                                            string tempkey = bTorPgm +';'+ claim.Core_MDF_Region_Cd__c;
                                                                               
                                            if(crossbudTypeGeoRecKey != null && crossbudTypeGeoRecKey.size() > 0 && crossbudTypeGeoRecKey.contains(tempkey) && claim.Core_MDF_Region_Cd__c == splitBudgetGeo[1]){
                                                toBeProcessedCrossRec1.add(claim);
                                            }
                                        }
                                    }
                                    if(toBeProcessedCrossRec1 != null && toBeProcessedCrossRec1.size()>0){
                                        crossRecGeoMap.put(key2,toBeProcessedCrossRec1);
                                    }
                                }
                            //}
                        //}
                    }
                }   

                //Check if there are matching claims for Cross Budget type and Cross Geo
                for(string budgetGeo: budgetTypeGeoToAmountMap.keyset()){ //Cross Budget type & Cross Geo
                    
                    // for same BT,crossgeo  or cross bt,cross geo
                    List<PartnerFundClaim> toBeProcessedCrossRec1 = new List<PartnerFundClaim>();
                    Set<String> geoSet = new Set<String>();
                    //If there is dollar value still to be recovered for the Account/Program/Quarter
                    //ATHR Fix- Deeply nested if
                    if(budgetTypeGeoToAmountMap.get(budgetGeo)!=0 && allClaimsList.containsKey(programAccountQ)){
                        //if(allClaimsList.containsKey(programAccountQ)){
                            Map<string,List<PartnerFundClaim>> claimList = allClaimsList.get(programAccountQ);
                            string key2 = 'Geo' + ':' + budgetGeo; 
                            //ATHR Fix- Deeply nested if
                            if(claimList == null){
                                continue;
                            }
                            //if(claimList != null){ 
                                // splitting budgetGeo with ;
                                list<string> splitBudgetGeo = budgetGeo.split(';');
                                // checking if budget type is available in crossBTorProgToBTMap
                                if(crossBTorProgToBTMap.containsKey(splitBudgetGeo[0]) && crossBTorProgToBTMap.get(splitBudgetGeo[0]) != NULL){
                                    // looping over the cross budget type values
                                    for(String crossBt : crossBTorProgToBTMap.get(splitBudgetGeo[0])){
                                        for(String geo : claimGeoSet){
                                            // preparing a temperory key with budget type and geo
                                            String tempKey = crossBt + ';' + geo;
                                            crossbudTypeGeoRecKey.add(tempKey);
                                        }                                                                     
                                    }
                                    if(accToClaimsMap != NULL && accToClaimsMap.containsKey(programAccountQ) && accToClaimsMap.get(programAccountQ) != NULL){
                                        for(PartnerFundClaim claim : accToClaimsMap.get(programAccountQ)){
                                            string bTorPgm = claim.Core_MDF_Budget_Type_Options_Nm__c != NULL ? claim.Core_MDF_Budget_Type_Options_Nm__c : claim.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
                                            string tempkey = bTorPgm +';'+ claim.Core_MDF_Region_Cd__c;
                                                                               
                                            if(crossbudTypeGeoRecKey != null && crossbudTypeGeoRecKey.size() > 0 && crossbudTypeGeoRecKey.contains(tempkey)){
                                                toBeProcessedCrossRec1.add(claim);
                                            }
                                        }
                                    }
                                    if(toBeProcessedCrossRec1 != null && toBeProcessedCrossRec1.size()>0){
                                        crossRecGeoMap.put(key2,toBeProcessedCrossRec1);
                                    }
                                }
                            //}
                        //}
                    }
                }

                if(crossRecGeoMap.keyset() != NULL){
                    for(String key : crossRecGeoMap.keyset()){
                        eligibleClaimsList.putall(eligibilityLogic(key,crossRecGeoMap.get(key),'crossBudgetType'));
                    }
                } 
                if(eligibleClaimsList.size()>0){
                    eligibleClaimRecords.put(programAccountQ,eligibleClaimsList);
                }
            }
        }        
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return eligibleClaimRecords;
    }
    
    //Logic of selecting Claims and reducing from the total Recovery amount Budget, Region wise and Budget, cross Region wise
    public static Map<id,decimal> eligibilityLogic(string key, List<PartnerFundClaim> claimsMap, String context){
        
        string account;
        Map<id,decimal> eligibleClaims = new Map<id,decimal>();
        Map<String,set<String>> btToCrossBtMap = new Map<String,set<String>>();
        Map<id,decimal> crossRecClmIdToAmt = new Map<id,decimal>();
        List<string> noBudgetTypePrograms = Label.Core_MDF_No_Budget_Types.split(';');
        try{
            List<string> keySplit = key.split(':');
            // splitting keySplit[1] with ;
            List<string> btSplit = keySplit[1].split(';');            
            // checking if btSplit[0] is present in crossBTorProgToBTMap
            if(btSplit[0] != NULL && crossBTorProgToBTMap.containsKey(btSplit[0]) && crossBTorProgToBTMap.get(btSplit[0])!= NULL && !btToCrossBtMap.containsKey(btSplit[0])){
                btToCrossBtMap.put(btSplit[0],crossBTorProgToBTMap.get(btSplit[0]));
            }
            if(claimsMap !=null && claimsMap.size()>0){
                List<String> sameGeoRecoveryBudgetTypeList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_SameGeoRecoveryBudgetTypeList');
                if(context == 'sameBudgetType'){
                    //Iterate in the ClaimsMap
                    for(PartnerFundClaim claim: claimsMap){
                        //ATHR Fix- Deeply nested if
                        /*if(programs_For_Node_Account.contains(claim.Core_MDF_Program__c)){
                            account= claim.ChannelPartnerId;
                        }
                        else{
                            account= claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
                        }*/
                        account = programs_For_Node_Account.contains(claim.Core_MDF_Program__c)? claim.ChannelPartnerId : claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;
                        string bTorPgm = claim.Core_MDF_Budget_Type_Options_Nm__c == null ? claim.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c : claim.Core_MDF_Budget_Type_Options_Nm__c;
                        // preparing a string of Budget Type or Program to Geo // If incoming program is SPCF/CCFB, but claims Program is not SPCF/CCFB, then prepare a key as SPCF/CCFB;Claim's geo else Claim's Budget Type;claim's geo
                        //String claimKeyBtGeo = keySplit[1].split(';')[0] == 'Service Provider CoMarketing Fund' && bTorPgm != 'Service Provider CoMarketing Fund' ? 'Service Provider CoMarketing Fund' +';'+ claim.Core_MDF_Region_Cd__c : bTorPgm +';'+ claim.Core_MDF_Region_Cd__c;
                        String claimKeyBtGeo = noBudgetTypePrograms.contains(keySplit[1].split(';')[0]) && !noBudgetTypePrograms.contains(bTorPgm) ? keySplit[1].split(';')[0] +';'+ claim.Core_MDF_Region_Cd__c : bTorPgm +';'+ claim.Core_MDF_Region_Cd__c;
                        // preparing a string of Budget Type or Program // If incoming program is SPCF/CCFB, but claims Program is not SPCF/CCFB, then prepare a key as SPCF/CCFB else Claim's Budget Type
                        //String claimKeyBt = keySplit[1].split(';')[0] == 'Service Provider CoMarketing Fund' && bTorPgm != 'Service Provider CoMarketing Fund' ? 'Service Provider CoMarketing Fund' : bTorPgm;
                        String claimKeyBt = noBudgetTypePrograms.contains(keySplit[1].split(';')[0]) && !noBudgetTypePrograms.contains(bTorPgm) ? keySplit[1].split(';')[0] : bTorPgm;
                        
                        //If claims need to be checked against same Budget Type + Geo, then call eligibilityLogicCheck
                        //ATHR Fix- Deeply nested if
                        //if(keySplit[0] == 'Budget+Geo'){
                            eligibleClaims = (keySplit[0] == 'Budget+Geo') ? eligibilityLogicCheck(account, key, claimKeyBtGeo, claim) : eligibleClaims;
                        //}
                        //If claims need to be checked against same Budget Type and cross Geo, then call eligibilityLogicCheck
                        //if(keySplit[0] == 'Geo' && !sameGeoRecoveryBudgetTypeList.contains(claim.Core_MDF_Budget_Type_Options_Nm__c)){
                            eligibleClaims = (keySplit[0] == 'Geo' && !sameGeoRecoveryBudgetTypeList.contains(claim.Core_MDF_Budget_Type_Options_Nm__c)) ? eligibilityLogicCheck(account, key, claimKeyBt, claim) : eligibleClaims;  
                        //}
                    }
                }
                // check if btToCrossBtMap is not null
                //ATHR Fix- Deeply nested if
                if(context != 'crossBudgetType' || btToCrossBtMap == NULL || btToCrossBtMap.isEmpty()){
                    return eligibleClaims; 
                }
                //if(context == 'crossBudgetType' && btToCrossBtMap != NULL && btToCrossBtMap.size()>0){ 
                    // Looping over keyset of btToCrossBtMap
                    for(String bt : btToCrossBtMap.keySet()){
                        for(PartnerFundClaim claim: claimsMap){
                                account = programs_For_Node_Account.contains(claim.Core_MDF_Program__c)? claim.ChannelPartnerId : claim.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c;//ATHR Fix                            
                            string bTorPgm = claim.Core_MDF_Budget_Type_Options_Nm__c == null ? claim.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c : claim.Core_MDF_Budget_Type_Options_Nm__c;
                            // checking if btToCrossBtMap contains bt and get is not null and value contains claims budget type
                                if(btToCrossBtMap.containsKey(bt) && btToCrossBtMap.get(bt)!= NULL && (btToCrossBtMap.get(bt)).contains(bTorPgm)){
                                // preparing a string of Budget Type;geo
                                String claimKeyBtGeo = bt +';'+ claim.Core_MDF_Region_Cd__c;
                                // preparing a string of Budget Type
                                String claimKeyBt = bt;
                                //If claims need to be checked against same Budget Type + Geo, then call eligibilityLogicCheck
                                //ATHR Fix- Deeply nested if
                                //if(keySplit[0] == 'Budget+Geo'){ 
                                    eligibleClaims = (keySplit[0] == 'Budget+Geo') ? eligibilityLogicCheck(account, key, claimKeyBtGeo, claim) : eligibleClaims;                                                                       
                                //}
                                //If claims need to be checked against same Budget Type and cross Geo, then call eligibilityLogicCheck
                                //if(keySplit[0] == 'Geo' && !sameGeoRecoveryBudgetTypeList.contains(claim.Core_MDF_Budget_Type_Options_Nm__c)){
                                    eligibleClaims = (keySplit[0] == 'Geo' && !sameGeoRecoveryBudgetTypeList.contains(claim.Core_MDF_Budget_Type_Options_Nm__c)) ? eligibilityLogicCheck(account, key, claimKeyBt, claim) : eligibleClaims;                                    
                                //}
                            }
                        }
                    }
                //}
            }    
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return eligibleClaims;
    }
    
    public static Map<id,decimal> eligibilityLogicCheck(string account, String key, String claimBtOrGeoKey, PartnerFundClaim claim){
        Map<id,decimal> eligibleClaims = new Map<id,decimal>();
        Map<id,RecoveryRequestDetail> eligibileClaimsBTGeo = new Map<id,RecoveryRequestDetail>();
        Map<string,decimal> keyToRecoveryAmt = new Map<string,decimal>();
        try{
            // Splitting the key with :
            List<string> keySplit = key.split(':');
            // Splitting the keySplit[1] with ;
            list<string> keySplit2 = keySplit[1].split(';');
            // checking if keySplit[0] == 'Budget+Geo', then add Budget Type Geo value else add Budget Type value
            String btGeoOrbt = keySplit[0] == 'Budget+Geo' ? keySplit[1] : keySplit2[0];
            // setting recoveryMade to false
            boolean recoveryMade = false;
            // storing Amount to be recovered for the Budget Type and Geo combination in recoveryAmount
            decimal recoveryAmount = budgetTypeGeoToAmountMap.get(keySplit[1]);
            // setting claimRecovery to zero
            decimal claimRecovery = 0; 
            string consumedBudget;
            decimal balClmAmtAfterManualRec = (clmIdToRecAmtMap.containsKey(claim.Id) && clmIdToRecAmtMap.get(claim.Id) > 0) ? (claim.Amount - clmIdToRecAmtMap.get(claim.Id)) : claim.Amount;            
            // checking if accountToEligibleClaims contains account, then add the value to eligibleClaims
            if(accountToEligibleClaims.containsKey(account)){
                eligibleClaims = accountToEligibleClaims.get(account);
            }
            // checking if accountEligibileClaimsBTGeo contains account, then add the value to eligibileClaimsBTGeo
            if(accountEligibileClaimsBTGeo.containsKey(account)){
                eligibileClaimsBTGeo = accountEligibileClaimsBTGeo.get(account);
            }
            // checking if claimBtOrGeoKey matches with btGeoOrbt and recoveryAmount and claim amount greater than zero
            //ATHR Fix- Deeply nested if
            if(claimBtOrGeoKey != btGeoOrbt || recoveryAmount <= 0 || balClmAmtAfterManualRec <= 0){
                return eligibleClaims;
            }
            //if(claimBtOrGeoKey == btGeoOrbt && recoveryAmount >0 && balClmAmtAfterManualRec > 0){
                // checking if eligibleClaims not null and contains claim id
                if(eligibleClaims!=null && eligibleClaims.containsKey(claim.id)){
                    // add the get value to alreadyRecovered
                    decimal alreadyRecovered = eligibleClaims.get(claim.id);
                    // calculate remaining amount by substracting alreadyRecovered from claim's amount
                    decimal remaining = balClmAmtAfterManualRec - alreadyRecovered;
                    // if remaining amount is greater than zero
                    if(remaining>0){
                        // check if remaining amount is greater than recovery amount then add alreadyRecovered+recoveryAmount else add claim amount
                        claimRecovery = remaining > recoveryAmount ? alreadyRecovered + recoveryAmount : balClmAmtAfterManualRec;
                        // check if remaining amount is greater than recovery amount then set budgetBalance as recoveryAmount else remaining amt
                        decimal budgetBalance = remaining > recoveryAmount ? recoveryAmount : remaining;
                        // set consumedBudget as get of eligibileClaimsBTGeo , Bt;Geo = balance amount
                        consumedBudget = eligibileClaimsBTGeo.get(claim.id).consumedBudget +',' +keySplit[1] + '=' + budgetBalance;
                        // set recoveryMade to true
                        recoveryMade = true; 
                        // set budgetTypeGeoToAmountMap with key as bt;geo and value as recoveryAmount-budgetBalance
                        budgetTypeGeoToAmountMap.put(keySplit[1],recoveryAmount - budgetBalance);
                        // check if remaining amount is greater than recovery amount then add recovery amount else claim's amount 
                        decimal tempvar = remaining > recoveryAmount ? recoveryAmount : remaining;                            
                        // check if clmToBtRecoveryAmt containsKey claim id
                        //ATHR Fix- Deeply nested if
                        //if(clmToBtRecoveryAmt.containsKey(claim.id)){
                            // set keyToRecoveryAmt as get value of clmToBtRecoveryAmt
                            keyToRecoveryAmt = (clmToBtRecoveryAmt.containsKey(claim.id)) ? clmToBtRecoveryAmt.get(claim.id) : keyToRecoveryAmt;                            
                        //}
                        // set keyToRecoveryAmt with key as bt;geo and value as tempvar
                        keyToRecoveryAmt.put(keySplit[1],tempvar.setScale(2));
                        // set clmToBtRecoveryAmt with key as claim id and value as keyToRecoveryAmt
                        clmToBtRecoveryAmt.put(claim.id,keyToRecoveryAmt);                                                                               
                    }
                }
                // if eligibleClaims does not contains claim id
                else{
                    // check if claim amount is greater than or equal to recoveryAmount then add recoveryAmount to claimRecovery else add claim amount
                    claimRecovery = balClmAmtAfterManualRec >= recoveryAmount ? recoveryAmount : balClmAmtAfterManualRec;
                    // set consumedBudget as Bt;Geo = claimRecovery
                    consumedBudget = keySplit[1] + '=' + claimRecovery;
                    // set recoveryMade to true
                    recoveryMade = true;
                    // set budgetTypeGeoToAmountMap with key as bt;geo and value as recoveryAmount-claimRecovery
                    budgetTypeGeoToAmountMap.put(keySplit[1],recoveryAmount - claimRecovery);
                    // check if clmToBtRecoveryAmt containsKey claim id
                    //ATHR Fix- Deeply nested if
                    //if(clmToBtRecoveryAmt.containsKey(claim.id)){
                        // set keyToRecoveryAmt as get value of clmToBtRecoveryAmt
                        keyToRecoveryAmt = (clmToBtRecoveryAmt.containsKey(claim.id)) ? clmToBtRecoveryAmt.get(claim.id) : keyToRecoveryAmt;                        
                    //}
                    // set keyToRecoveryAmt with key as bt;geo and value as claimRecovery
                    keyToRecoveryAmt.put(keySplit[1],claimRecovery.setScale(2));
                    // set clmToBtRecoveryAmt with key as claim id and value as keyToRecoveryAmt
                    clmToBtRecoveryAmt.put(claim.id,keyToRecoveryAmt);
                                            
                }
                // check if recoveryMade is true
                if(recoveryMade){
                    // set key as claim id and value as claimRecovery
                    eligibleClaims.put(claim.id,claimRecovery.setScale(2));
                    // set key as account and value as eligibleClaims
                    accountToEligibleClaims.put(account,eligibleClaims);

                    RecoveryRequestDetail rrd = new RecoveryRequestDetail();
                    rrd.consumedBudget = consumedBudget;
                    // set key as claim id and value as consumedBudget
                    eligibileClaimsBTGeo.put(claim.id, rrd);  
                    // set key as account and value as eligibileClaimsBTGeo
                    accountEligibileClaimsBTGeo.put(account,eligibileClaimsBTGeo);                         
                }                            
            //}  
        }         
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return eligibleClaims;
    }
    
    //Save Recovery Requests
    @AuraEnabled
    public static Map<boolean,string> saveRecoveryRequests(List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows> rrr){
        Map<id,Core_MDF_Recovery_Request__c> existingRR = new Map<id,Core_MDF_Recovery_Request__c>();
        boolean issueUpdate = true;
        Map<boolean,string> output = new Map<boolean,string>();
        Map<boolean,string> result = new Map<boolean,string>();
        string message = '';
        Map<string,Map<string,decimal>> accountToBTGeoToAmountMap = new Map<string,Map<string,decimal>>();
        Map<string,decimal> btGeoToAmountMap = new Map<string,decimal>();
        List<id> accountIdL = new List<id>();
        List<Core_MDF_Recovery_Request__c> rrList = new List<Core_MDF_Recovery_Request__c>();
        // stores list of recoveryBudAmt
        List<String> recoveryBudAmtList = new List<string>();
        
        try{
            accountIdL.add(rrr[0].accountId);
            string programBudgetTypeQuarter= rrr[0].program + ';;'+ rrr[0].quarter;
            //Call method to populate accountToBTGeoToAmountMap
            Core_MDF_Recovery_Batch.recoveryDataWrapper wrapperRecData = new Core_MDF_Recovery_Batch.recoveryDataWrapper();
            wrapperRecData.accntListId = accountIdL;
            accountToBTGeoToAmountMap = Core_MDF_Recovery_Helper.calculateRecoveryAmount(programBudgetTypeQuarter,wrapperRecData,false);
            btGeoToAmountMap = accountToBTGeoToAmountMap.get(rrr[0].accountId);
            
            for(Core_MDF_Recovery_Request__c recovery: [SELECT id,Core_MDF_Claim_External_ID__c,Core_MDF_Program_Nm__c,Core_MDF_Account_Id__c,Core_MDF_Quarter_Year_Nm__c,
                                                        Core_MDF_Active_Ind__c, Core_MDF_Ready_to_Recover_Ind__c, Core_MDF_Claim_Id__c, Core_MDF_Recovery_Amount_Amt__c,
                                                        Core_MDF_Recovered_Budget_Nm__c 
                                                        FROM Core_MDF_Recovery_Request__c
                                                        WHERE Core_MDF_Active_Ind__c= true and Core_MDF_Program_Nm__c=:rrr[0].program AND Core_MDF_Quarter_Year_Nm__c=:rrr[0].quarter AND
                                                        Core_MDF_Account_Id__c =:rrr[0].accountId]){
                                                            recovery.Core_MDF_Active_Ind__c = false;
                                                            recovery.Core_MDF_Ready_to_Recover_Ind__c = false;
                                                            existingRR.put(recovery.Core_MDF_Claim_Id__c,recovery);   
                                                        }
            
            for(Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows record:rrr){
                if(String.isNotBlank(record.recoveryAmount)){
                    system.debug('record::'+record);
                    Core_MDF_Recovery_Request__c rr;
                    if(existingRR.containsKey(record.id)){
                        rr = new Core_MDF_Recovery_Request__c(id=existingRR.get(record.id).id);
                    }
                    else{
                        rr = new Core_MDF_Recovery_Request__c();
                        rr.Core_MDF_Recovered_Budget_Nm__c =record.budgetGeoConsumed;
                    }
                    String claimExternalId = record.budgetType != null ? record.quarter+'='+record.budgetType+'='+record.geo+'='+record.Id :  record.quarter+'='+record.geo+'='+record.Id;//quarterYear+budgetType+geo+claimId
                    rr.Core_MDF_Claim_Id__c = record.id;
                    rr.Core_MDF_Account_Id__c = record.accountId;
                    rr.Core_MDF_Recovery_Amount_Amt__c = decimal.valueof(record.recoveryAmount);
                    rr.Core_MDF_Program_Nm__c = record.program;
                    rr.Core_MDF_Quarter_Year_Nm__c = record.quarter;
                    rr.Core_MDF_Active_Ind__c = true;
                    rr.Core_MDF_Claim_External_ID__c = claimExternalId;
                    rr.Core_MDF_Comment_Txt__c = record.comments;
                    rr.Core_MDF_Ready_to_Recover_Ind__c = record.righttoRecover;
                    
                    existingRR.put(record.id,rr); 
                    // Adding recoveryBudAmt to list
                    recoveryBudAmtList.add(record.recoveryBudAmt);
                }
            }
            system.debug('recoveryBudAmtList::'+recoveryBudAmtList);
            system.debug('btGeoToAmountMap::'+btGeoToAmountMap);
            //Check if the recovered claims are within the recovery limit of the Account, Program, Quarter
            output = Core_MDF_Recovery_Save_Functionality.validateBudgetConsumed(btGeoToAmountMap,recoveryBudAmtList);
            for(boolean key:output.keyset()){
                issueUpdate = key;
                message = output.get(key);
            }
            
            //If there are records to be updated and the recovered claims are withing the recovery limit
            if(existingRR.size()>0 && issueUpdate){
                //Check if all recovery requests have budgetConsumedFrom field populated
                Map<id,string> validatedRR = Core_MDF_Recovery_Save_Functionality.checkBudgetConsumedFrom(btGeoToAmountMap,rrr);
                //Update the Budget Type Geo from where the recovery needs to be made
                for(id rrrRecords: validatedRR.keyset()){
                    Core_MDF_Recovery_Request__c updateBTConsumed = existingRR.get(rrrRecords);
                    updateBTConsumed.Core_MDF_Recovered_Budget_Nm__c = validatedRR.get(rrrRecords);
                    existingRR.put(rrrRecords,updateBTConsumed);
                }
                rrList = existingRR.values();
                upsert rrList Core_MDF_Claim_External_ID__c;
            } 
            
            result.put(issueUpdate,message);
            system.debug('result::'+result);
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);} 
        return result;
    }
    
    //Format output for Recovery Batch
    public static Map<string,List<RecoveryBatchParams>> formatRecordsForBatch (Map<string,Map<id,decimal>> claimOrRRRecords, string type){
        Map<string,List<RecoveryBatchParams>> result = new Map<string,List<RecoveryBatchParams>>(); 
        Map<id,string> claimsToBTGeo = new Map<id,string>();
        try{
            for(string pgmBTQ:claimOrRRRecords.keyset()){
                List<RecoveryBatchParams> recommendedClaimsList = new List<RecoveryBatchParams>();
                Map<id,decimal> claimOrRRList = claimOrRRRecords.get(pgmBTQ);
                for(id claimId:claimOrRRList.keyset()){
                    RecoveryBatchParams recoveryWRecord = new RecoveryBatchParams();
                    List<GeoRecoverySplit> geoRecoveryList = new List<GeoRecoverySplit>();
                    recoveryWRecord.claimId = claimId;
                    recoveryWRecord.rrID = claimToRR.get(claimId);

                    Map<Id,RecoveryRequestDetail> claimIdToRRDetail = accountEligibileClaimsBTGeo.get(pgmBTQ);
                    Map<Id,String> claimIdToConsumedBudget = new Map<Id, String>();
                    
                    if(claimIdToRRDetail != null){
                        for(Id partnerfundClaimId : claimIdToRRDetail.keySet()){
                            claimIdToConsumedBudget.put(partnerfundClaimId, claimIdToRRDetail.get(partnerfundClaimId).consumedBudget);
                        }
                    }

                    claimsToBTGeo = type =='RR'? rrBTGeo : claimIdToConsumedBudget;
                    if(claimsToBTGeo != null && claimsToBTGeo.containsKey(claimId) && claimsToBTGeo.get(claimId) != null && claimsToBTGeo.get(claimId).contains(',')){
                        for(string budgetGeoAmount: claimsToBTGeo.get(claimId).split(',')){
                            List<string> keySplit1 = budgetGeoAmount.split('=');
                            GeoRecoverySplit geoRecoveryRecord = new GeoRecoverySplit();
                            geoRecoveryRecord.geoRecoveryAmount = decimal.valueof(keySplit1[1]);
                            List<string> keySplit2 = keySplit1[0].split(';');
                            geoRecoveryRecord.budgetType = keySplit2[0];
                            geoRecoveryRecord.geo= keySplit2[1];
                            geoRecoveryList.add(geoRecoveryRecord);
                        }  
                    }
                    else{
                        GeoRecoverySplit geoRecoveryRecord = new GeoRecoverySplit();
                        List<string> keySplit1 = claimsToBTGeo.get(claimId).split('=');
                        geoRecoveryRecord.geoRecoveryAmount = decimal.valueof(keySplit1[1]);
                        List<string> keySplit2 = keySplit1[0].split(';');
                        geoRecoveryRecord.budgetType = keySplit2[0];
                        geoRecoveryRecord.geo= keySplit2[1];
                        geoRecoveryList.add(geoRecoveryRecord);
                    }
                    recoveryWRecord.recoveryAmount = claimOrRRList.get(claimId);
                    recoveryWRecord.geoRows = geoRecoveryList;
                    recoveryWRecord.budgetConsumed = claimsToBTGeo.get(claimId);
                    recoveryWRecord.claimGeo = claimIdToClaimGeoMap.get(claimId);
                    recoveryWRecord.claimBudgetType = claimIdToClaimBudgetTypeMap.get(claimId);
                    recommendedClaimsList.add(recoveryWRecord);
                }
                result.put(pgmBTQ,recommendedClaimsList);
            } 
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}  
        return result;
    }
    
    public static Boolean isZeroScorecardClaim(PartnerFundClaim claim) {
        return claim.Core_MDF_Processing_Preference_nm__c == 'Settle, then get paid' && claim.Core_MDF_Claim_Review_Case__r != null && claim.Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c == 'Review Completed' && (claim.Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c == 0 || (claim.Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c > 0 && claim.Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c > 0 && claim.Amount == claim.Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c));
    }
    public static Boolean isPartialScorecardClaim(PartnerFundClaim claim) {
        return claim.Core_MDF_Processing_Preference_nm__c == 'Settle, then get paid' && claim.Core_MDF_Claim_Review_Case__r != null && claim.Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c == 'Review Completed' && claim.Core_MDF_Claim_Review_Case__r.Core_MDF_Scorecard_Score_Nbr__c > 0 && claim.Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c > 0 && claim.Amount != claim.Core_MDF_Claim_Review_Case__r.Core_MDF_Manual_Recovery_Amount_USD_Amt__c;
    }
    
    //Wrapper Classes for sending output to Recovery Batch
    public class RecoveryBatchParams {
        public List<GeoRecoverySplit> geoRows {get; set;} 
        public id claimId { get; set; }
        public decimal recoveryAmount{ get; set; }
        public string budgetConsumed { get; set; }
        public id rrID {get; set;}
        public string claimGeo {get; set;}
        public String claimBudgetType {get; set;}
        
    } 
    public class GeoRecoverySplit {
        public String budgetType { get; set; }
        public String geo { get; set; }
        public decimal geoRecoveryAmount { get; set; } 
    }

    public class RecoveryRequestDetail {
        public String comments { get; set; }
        public String budgetGeo { get; set; } 
        public Boolean readyToRecoverInd { get; set; }
        public String consumedBudget { get; set; }

        public RecoveryRequestDetail() {
            // Assign default values
            comments = '';
            budgetGeo = '';
            readyToRecoverInd = false;
            consumedBudget = '';
        }
    }
}