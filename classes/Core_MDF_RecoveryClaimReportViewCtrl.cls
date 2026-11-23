public without sharing class Core_MDF_RecoveryClaimReportViewCtrl {
    public static set<String> Programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    public static Map<String,String> toBeRecoveredClaimsHeaders = new Map<String,String>();
    public static Map<String,String> claimsEligibleForRecoveryHeaders = new Map<String,String>();
    public static Map<string,decimal> budgetTypeGeoToAmountMap = new Map<string,decimal>();
    public static List<PartnerFundClaim> allClaims = new List<PartnerFundClaim>();
    public static List<String> headers = new List<String>();
    public static Boolean isL3UserWithItAdminProfile = false;
    static{
        Core_MDF_RecoveryClaimReportViewCtrl.toBeRecoveredClaimsHeaders.put('Row Label','groupName');
        Core_MDF_RecoveryClaimReportViewCtrl.toBeRecoveredClaimsHeaders.put('Total Recovery','totalRecoveryAmt');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Claim #','claimID');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Budget Type','budgetType');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Geo','geo');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Country','country');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Claim Status','clmStatus');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Activity Category','actCategory');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Activity Type','actType');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Claim Amount','claimAmt');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Recovery Amount','recoveryAmount');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Balance Amount','balanceAmt');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Comments','comments');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Recovery Budget Amount','recoveryBudAmt');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Recovery Hold','recoveryHold');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Processing Preference','processingPref');
        Core_MDF_RecoveryClaimReportViewCtrl.claimsEligibleForRecoveryHeaders.put('Settle, then get paid recovery amount','surePayRecAmt');
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getQuarterOptionsMap (){
        List<String> finalQuarter = new List<String>();
        
        Set<String> quarter = new Set<String>();
        Schema.DescribeFieldResult objFieldDescribe = Core_MDF_Partnership_Score__c.Core_MDF_Quarter_Year_Nm__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        Date dat = System.today();
        Integer yr = dat.year();
        Integer month = Date.Today().Month();
        
        Map<String,List<String>> quarterToMonthMap = new Map<String,List<String>>();
        quarterToMonthMap.put('Q1',new List<String>{'1','2','3'});
        quarterToMonthMap.put('Q2',new List<String>{'4','5','6'});
        quarterToMonthMap.put('Q3',new List<String>{'7','8','9'});
        quarterToMonthMap.put('Q4',new List<String>{'10','11','12'});
        
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            String q = objPickList.getValue();
            if(Integer.valueOf(q.split(' ')[1]) < yr){
                quarter.add(q);
            } 
            else if (Integer.valueOf(q.split(' ')[1]) == yr){
                
                if(quarterToMonthMap.get(q.split(' ')[0]).contains(String.valueOf(month))){
                    quarter.add(q);
                }
                if(q.split(' ')[0] == 'Q1' && (Integer.valueOf(quarterToMonthMap.get('Q1')[0]) < month || 
                                               Integer.valueOf(quarterToMonthMap.get('Q1')[1]) < month ||
                                               Integer.valueOf(quarterToMonthMap.get('Q1')[2]) < month)){
                                                   quarter.add(q);    
                                               }
                if(q.split(' ')[0] == 'Q2' && (Integer.valueOf(quarterToMonthMap.get('Q2')[0]) < month ||
                                               Integer.valueOf(quarterToMonthMap.get('Q2')[1]) < month ||
                                               Integer.valueOf(quarterToMonthMap.get('Q2')[2]) < month
                                              )){
                                                  quarter.add(q);    
                                              }
                
                if(q.split(' ')[0] == 'Q3' && (Integer.valueOf(quarterToMonthMap.get('Q3')[0]) < month ||
                                               Integer.valueOf(quarterToMonthMap.get('Q3')[1]) < month ||
                                               Integer.valueOf(quarterToMonthMap.get('Q3')[2]) < month)){
                                                   quarter.add(q);    
                                               }
                
                if(q.split(' ')[0] == 'Q4' && (Integer.valueOf(quarterToMonthMap.get('Q4')[0]) < month ||
                                               Integer.valueOf(quarterToMonthMap.get('Q4')[1]) < month ||
                                               Integer.valueOf(quarterToMonthMap.get('Q4')[2]) < month)){
                                                   quarter.add(q);    
                                               }
            }
        }
        finalQuarter.addAll(quarter);
        
        return finalQuarter;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getQuarterOptionsWithoutCurrentQuarter(){
        List<String> finalQuarterList = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
        
        Set<String> finalQuarterSet = new Set<String>(finalQuarterList);
        
        //this method call gets up the current quarter based on today's date
        String currentQuarter = Core_MDF_ReverseAuditDecision.determineQuartYear(System.today());
        finalQuarterSet.remove(currentQuarter);
        
        return new List<String>(finalQuarterSet);
    }
    
    @AuraEnabled
    public static List<LeftReportRows> getFilteredDataForClaimsToBeRecovered(String program,Id account,String quarter) {        
        QuarterSurePayInfo info = getQuarterInfoAndSurePayAmount(program, account);        
        Map<String,List<Core_MDF_Partnership_Score_Detail__c>> budgetTypeWisePGD = new Map<String,List<Core_MDF_Partnership_Score_Detail__c>>();
        Map<String, Decimal> readyToRecoverSavedAmtMap = new Map<String, Decimal>();
        String query = 'SELECT Id,Core_MDF_Balance_Amount_Amt__c, Core_MDF_Program_Nm__c, Core_MDF_Recovered_Amt__c, Core_MDF_Recovery_Offset_Amt__c, Core_MDF_Recovery_Offset_Comments_txt__c, Core_MDF_Offset_Comment_Details_txt__c, Core_MDF_Budget_Type_Nm__c, Core_MDF_Partnership_Score_Id__c, Core_MDF_Region_Cd__c, Core_MDF_Node_Account_Id__c FROM Core_MDF_Partnership_Score_Detail__c WHERE Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c =: program AND Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c =: quarter AND Core_MDF_Region_Cd__c != null';
        if(Programs_For_Node_Account.contains(program)){
            query += ' AND Core_MDF_Node_Account_Id__c =: account';
        }else{
            //updated
            query += ' AND Core_MDF_Partnership_Score_Id__r.Core_MDF_AccountID_id__c =: account';
        }
        
        query += ' ORDER BY Core_MDF_Budget_Type_Nm__c,Core_MDF_Region_Cd__c ASC';
        
        List<Core_MDF_Recovery_Request__c> recoveryReqRecords = [SELECT Core_MDF_Recovered_Budget_Nm__c FROM Core_MDF_Recovery_Request__c WHERE Core_MDF_Program_Nm__c = :program AND Core_MDF_Account_Id__c = :account AND Core_MDF_Quarter_Year_Nm__c = :quarter AND Core_MDF_Ready_to_Recover_Ind__c = true AND Core_MDF_Active_Ind__c = true];
        
        for (Core_MDF_Recovery_Request__c rec : recoveryReqRecords) {
            String recBud = rec.Core_MDF_Recovered_Budget_Nm__c;
            if (String.isBlank(recBud)) continue;
            
            for (String entry : recBud.split(',')) { // 1) split entries
                entry = entry.trim();
                if (entry == '') continue;
                
                Integer p = entry.lastIndexOf('='); // 2) split key vs amount
                if (p <= 0) continue;
                
                String key = entry.substring(0, p).trim(); // "BudgetType;Region"
                key = key.replace(';', '-'); 
                Decimal amt;
                try { amt = Decimal.valueOf(entry.substring(p+1).trim()); }
                catch (Exception e) { continue; }
                // roll up
                Decimal cur = readyToRecoverSavedAmtMap.get(key);
                readyToRecoverSavedAmtMap.put(key, (cur == null ? 0 : cur) + amt);
            }
        }
        
        for(Core_MDF_Partnership_Score_Detail__c pgd : Database.query(query)){
            if(budgetTypeWisePGD != null && budgetTypeWisePGD.containsKey(pgd.Core_MDF_Budget_Type_Nm__c)){
                List<Core_MDF_Partnership_Score_Detail__c> pgdgeowiseDataPerBudgetType = new List<Core_MDF_Partnership_Score_Detail__c>();
                pgdgeowiseDataPerBudgetType = budgetTypeWisePGD.get(pgd.Core_MDF_Budget_Type_Nm__c);
                pgdgeowiseDataPerBudgetType.add(pgd);
                budgetTypeWisePGD.put(pgd.Core_MDF_Budget_Type_Nm__c,pgdgeowiseDataPerBudgetType);
            }
            else{
                List<Core_MDF_Partnership_Score_Detail__c> pgdgeowiseDataPerBudgetType = new List<Core_MDF_Partnership_Score_Detail__c>();
                pgdgeowiseDataPerBudgetType.add(pgd);
                budgetTypeWisePGD.put(pgd.Core_MDF_Budget_Type_Nm__c,pgdgeowiseDataPerBudgetType);
            }                                               
        }
        
        List<LeftReportRows> lrList = new List<LeftReportRows>();
        List<OffsetDetails> offsetDetailsList = new List<OffsetDetails>();
        Decimal overAllTotalRecoveryAmt = 0.0;
        for(String budgetType:budgetTypeWisePGD.keySet()){
            LeftReportRows lrBudgetType = new LeftReportRows();
            lrBudgetType.groupName = budgetType;
            lrBudgetType.cssProperty = 'budgettype Rec';
            Decimal budgetTypeTotalRecAmt=0.0;
            
            List<LeftReportRows> lrGeoRows = new List<LeftReportRows>();
            
            List<Core_MDF_Partnership_Score_Detail__c> geoRows = budgetTypeWisePGD.get(budgetType);
            List<String> offSetEligiblePgmsForAllBT = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Paid_Claims_Notifications').split(',');
            for(Core_MDF_Partnership_Score_Detail__c geoRec:geoRows){                
                LeftReportRows lrGeo = new LeftReportRows();
                lrGeo.groupName=geoRec.Core_MDF_Region_Cd__c;
                lrGeo.totalRecoveryAmt= String.valueOf(geoRec.Core_MDF_Balance_Amount_Amt__c);
                budgetTypeTotalRecAmt = budgetTypeTotalRecAmt + Decimal.valueOf(lrGeo.totalRecoveryAmt == '' || lrGeo.totalRecoveryAmt == null ? '0' : lrGeo.totalRecoveryAmt) ;
                lrGeo.cssProperty = 'geo Rec';
                lrGeoRows.add(lrGeo);
                decimal total = Decimal.valueof(lrGeo.totalRecoveryAmt == ''||lrGeo.totalRecoveryAmt==null?'0':lrGeo.totalRecoveryAmt);
                budgetTypeGeoToAmountMap.put(budgetType+';'+ geoRec.Core_MDF_Region_Cd__c,total);
                if(hasAccessToOffset(quarter) && offSetEligiblePgmsForAllBT.contains(geoRec.Core_MDF_Program_Nm__c)
                   && geoRec.Core_MDF_Recovered_Amt__c <=0 && (geoRec.Core_MDF_Balance_Amount_Amt__c > 0 || geoRec.Core_MDF_Recovery_Offset_Amt__c > 0)
                   && ((FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager') || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Claim_Case_Reviewer'))
                       ||(FeatureManagement.checkPermission('Core_MDF_CCP_Internal_RMF_Payment_Admin') && FeatureManagement.checkPermission('Core_MDF_CCP_Internal_PRC_User')
                          && (geoRec.Core_MDF_Budget_Type_Nm__c == 'RSA MD' && geoRec.Core_MDF_Region_Cd__c == 'PRC')))){
                              OffsetDetails offset = new OffsetDetails();
                              String key = geoRec.Core_MDF_Budget_Type_Nm__c + '-' + geoRec.Core_MDF_Region_Cd__c;
                              offset.showOffsetButton = true;
                              offset.disableOffsetButton = false;
                              offset.recordId = geoRec.Id;
                              offset.recoveryOffsetAmount = geoRec.Core_MDF_Recovery_Offset_Amt__c != null ? geoRec.Core_MDF_Recovery_Offset_Amt__c : 0.0;
                              offset.readyToRecoverSavedAmount = readyToRecoverSavedAmtMap.containsKey(key) ? readyToRecoverSavedAmtMap.get(key) : 0.00;
                              offset.maxOffsetAmount = (geoRec.Core_MDF_Balance_Amount_Amt__c != null ? geoRec.Core_MDF_Balance_Amount_Amt__c : 0.0) + (geoRec.Core_MDF_Recovery_Offset_Amt__c != null ? geoRec.Core_MDF_Recovery_Offset_Amt__c : 0.0);
                              offset.offsetComments = String.isNotBlank(geoRec.Core_MDF_Recovery_Offset_Comments_txt__c) ? geoRec.Core_MDF_Recovery_Offset_Comments_txt__c : '';
                              offset.offsetCommentDetails = String.isNotBlank(geoRec.Core_MDF_Offset_Comment_Details_txt__c) ? geoRec.Core_MDF_Offset_Comment_Details_txt__c : '';
                              offset.budgetType = geoRec.Core_MDF_Budget_Type_Nm__c;
                              offset.region = geoRec.Core_MDF_Region_Cd__c;
                              offsetDetailsList.add(offset);
                          }
            }
            
            
            lrBudgetType.totalRecoveryAmt = String.valueOf(budgetTypeTotalRecAmt) ;
            overAllTotalRecoveryAmt = overAllTotalRecoveryAmt + budgetTypeTotalRecAmt;
            if(lrBudgetType.groupName != null){
                lrList.add(lrBudgetType);
            }
            
            lrList.addAll(lrGeoRows);
        }
        
        Decimal total = overAllTotalRecoveryAmt;
        LeftReportRows lrgrandtotal = new LeftReportRows();
        lrgrandtotal.groupName = 'Total';
        lrgrandtotal.totalRecoveryAmt = String.valueOf(overAllTotalRecoveryAmt);
        
        lrgrandtotal.cssProperty = 'total';
        lrList.add(lrgrandtotal);
        
        //RSA MD PRC Offset process
        LeftReportRows lrrOffsetDetatil = new LeftReportRows();
        lrrOffsetDetatil.groupName = 'Offset';
        lrrOffsetDetatil.offsetDetailsList = offsetDetailsList;
        lrList.add(lrrOffsetDetatil);
        
        //Quarter info
        LeftReportRows quarterRow = new LeftReportRows();
        quarterRow.groupName = 'QuarterInfo';
        quarterRow.currentQuarterYear = info.currentQuarter;
        quarterRow.previousQuarterYear = info.previousQuarter;
        quarterRow.surePayRecoveryAmount = '$' + info.surePayAmount;
        quarterRow.clmIdToRecAmtMap = info.clmIdToRecAmtMap;
        lrList.add(quarterRow);
        
        return lrList;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ReportColumns> getcolumnsForToBeRecoveredClaims() {
        
        List<ReportColumns> rcList = new List<ReportColumns>();
        for(String key:toBeRecoveredClaimsHeaders.keySet()){
            ReportColumns rc = new ReportColumns();
            rc.fieldName = toBeRecoveredClaimsHeaders.get(key);
            rc.label=key;
            rc.type = 'text';
            rcList.add(rc);
        }
        return rcList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ReportColumns> getcolumnsForClaimsEligibleForRecovery() {
        
        List<ReportColumns> rcList = new List<ReportColumns>();
        for(String key:claimsEligibleForRecoveryHeaders.keySet()){
            ReportColumns rc = new ReportColumns();
            rc.fieldName = claimsEligibleForRecoveryHeaders.get(key);
            rc.label=key;
            rc.type = 'text';
            rcList.add(rc);
        }
        return rcList;
    }
    
    
    
    @AuraEnabled(cacheable=true)
    public static String checkMode(String program , Id account){
        String mode = 'read';
        Boolean isL3MaintenanceUser = FeatureManagement.checkPermission('CCP_L3_Maintenance');
        //Allow to edit if the user having L3 Permission and the flag switched ON
        if(isL3MaintenanceUser && Core_MDF_Utility.byPassFeature('Core_MDF_Allow_L3_to_EditClaimSection')){
            mode = 'edit';
            return mode;
        }else if(isL3MaintenanceUser){
            Profile iTAdminProfile = [SELECT Id FROM Profile WHERE Name = 'IT Admin' LIMIT 1];
            isL3UserWithItAdminProfile = UserInfo.getProfileId() == iTAdminProfile.Id ? true : false;
        }
        
        if(UserInfo.getUserType() == 'PowerPartner'){
            if(FeatureManagement.checkPermission('Core_MDF_CCF_Recovery_Administrator') || FeatureManagement.checkPermission('Core_MDF_DCF_Recovery_Administrator') || FeatureManagement.checkPermission('Core_MDF_RMF_Recovery_Administrator') || FeatureManagement.checkPermission('Core_MDF_IPA_Recovery_Administrator')){
                mode = 'edit';
            }
        }else {
            if(FeatureManagement.checkPermission('Core_MDF_CCP_Account_Recovery_Manager')){
                mode = 'edit';
            }
            
        }
        
        Boolean isbatchScheduled = isRecoveryBatchScheduled(program);
        
        if(isbatchScheduled){
            mode = 'read';
        }else if(isL3UserWithItAdminProfile){
            mode = 'edit';
        }
        return mode;
    }
    
    @AuraEnabled(cacheable=true)
    public static boolean checkRecoveryMode(String program){
        boolean result;
        try{
            Boolean isbatchScheduled = isRecoveryBatchScheduled(program);
            result = (FeatureManagement.checkPermission('Core_MDF_Recovery_Run') && !isbatchScheduled) ? true:false;
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}  
        return result; 
    }
    
    public static Boolean isRecoveryBatchScheduled(String program){
        Boolean isbatchScheduled = false;
        Datetime currDateTime = System.now();
        Datetime futureDateTime = isL3UserWithItAdminProfile ? currDateTime.addHours(12) : currDateTime + 1; // enable recovery for l3 user till 12 hours before recovery. Allow L3 User to select claims for recovery in Claim Recovery UI till 5PM IST, GMT 16:30
        List<String> validStatuses = new List<String>{'Pending','Scheduled'};
            for(Core_MDF_Batch_Scheduler__c bs : [SELECT Id, Scheduled_Time_Dt__c, Core_MDF_Object_JSON_Txt__c FROM Core_MDF_Batch_Scheduler__c WHERE Core_MDF_Batch_Class_Name_Txt__c =: 'Core_MDF_Recovery_Batch' AND Core_MDF_Scheduler_Status_Txt__c IN: validStatuses ORDER BY Scheduled_Time_Dt__c ASC]){ //HP:ATHR Fix
                if(String.isNotBlank(bs.Core_MDF_Object_JSON_Txt__c)){
                    bs.Scheduled_Time_Dt__c = isL3UserWithItAdminProfile ? bs.Scheduled_Time_Dt__c : bs.Scheduled_Time_Dt__c.addHours(1);
                    Core_MDF_Recovery_Batch.recoveryDataWrapper wrapResult = (Core_MDF_Recovery_Batch.recoveryDataWrapper) JSON.deserialize(bs.Core_MDF_Object_JSON_Txt__c, Core_MDF_Recovery_Batch.recoveryDataWrapper.class);
                    if(String.isNotBlank(wrapResult.program) && String.isNotBlank(program) && program.replace('-', '').toLowerCase() == wrapResult.program.replace('-', '').toLowerCase()
                       && bs.Scheduled_Time_Dt__c >= currDateTime && bs.Scheduled_Time_Dt__c <= futureDateTime){
                           isbatchScheduled = true;
                           break;
                       }
                }
            }
        
        return isbatchScheduled;
    }
    
    //Logic to organize the Claims to show up in the UI
    public static FinalRightRows getOrganizedDataForClaimsToBeRecovered( set<PartnerFundClaim> data, Map<id,decimal> eligibleClaims, Map<Id,Core_MDF_Recovery_Helper.RecoveryRequestDetail> infoFromBE, boolean isRR, List<string> budgetTypeList, Map<id,Map<string,decimal>> clmToBtRecoveryAmt, Map<string,set<string>> crossBTorProgToBTMap, Map<Id,Decimal>clmIdToRecAmtMap) {
        List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows> surePayClaims = new List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows>();
        List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows> recommendedClaims = new List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows>();
        List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows> nonRecommendedClaims = new List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows>();
        List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows> recommendedRTRClaims = new List<Core_MDF_RecoveryClaimReportViewCtrl.RightReportRows>();
        FinalRightRows frr = new FinalRightRows();
        List<RightReportRows> rrList = new List<RightReportRows>();
        Set<Id> selectedClaimIdSet = new Set<Id>(); 
        Integer rowSize=0;
        
        for(PartnerFundClaim sc : data){
            RightReportRows rr = new RightReportRows();
            rowSize++;
            for(String header: claimsEligibleForRecoveryHeaders.keySet()){
                rr.Id = sc.Id;
                if(claimsEligibleForRecoveryHeaders.get(header)=='actCategory'){
                    rr.actCategory = String.valueOf(sc.Core_MDF_Activity_Category__c);
                }
                if(claimsEligibleForRecoveryHeaders.get(header)=='actType'){
                    rr.actType = String.valueOf(sc.Core_MDF_Activity_Types__c);
                }
                if(claimsEligibleForRecoveryHeaders.get(header)=='budgetType'){
                    rr.budgetType = String.valueOf(sc.Core_MDF_Budget_Type_Options_Nm__c);
                }
                if(claimsEligibleForRecoveryHeaders.get(header)=='claimAmt'){
                    rr.claimAmt = String.valueOf(sc.Amount);
                }
                if(claimsEligibleForRecoveryHeaders.get(header)=='claimID'){
                    rr.claimID = String.valueOf(sc.Core_MDF_Claim_Ref_Number__c);
                }
                if(claimsEligibleForRecoveryHeaders.get(header)=='geo'){
                    rr.geo = String.valueOf(sc.Core_MDF_Region_Cd__c);
                }    
                if(claimsEligibleForRecoveryHeaders.get(header)=='country'){
                    rr.country = String.valueOf(sc.Core_MDF_Country_Location_nm__c);
                } 
                if(claimsEligibleForRecoveryHeaders.get(header)=='clmStatus'){
                    rr.clmStatus = String.valueOf(sc.Core_MDF_Status__c);
                }
                if(claimsEligibleForRecoveryHeaders.get(header)=='balanceAmt'){
                    rr.balanceAmt = '';
                }
                if(claimsEligibleForRecoveryHeaders.get(header)=='recoveryAmount'){
                    rr.recoveryAmount = '';
                }
                if(claimsEligibleForRecoveryHeaders.get(header)=='recoveryBudAmt'){
                    rr.recoveryBudAmt = '';
                }
                if(claimsEligibleForRecoveryHeaders.get(header)=='recoveryHold'){
                    rr.recoveryHold = sc.Core_MDF_Recovery_Hold_Ind__c;
                }
                if(claimsEligibleForRecoveryHeaders.get(header)=='processingPref'){
                    rr.processingPref = sc.Core_MDF_Processing_Preference_nm__c == 'Settle, then get paid' ? 'S, GP' : 'GP, S';
                }
                // Checking if budgetTypeList is not null                
                //if(budgetTypeList != NULL && budgetTypeList.size()>0){
                if (budgetTypeList == null || budgetTypeList.isEmpty()) {//ATHR Fix WW19
                    continue; 
                }
                                                
                    // sorting the values
                    budgetTypeList.sort();
                    // Map to store BudgetType Geo to Amount
                    Map<string,decimal> btGeoRecAmtMap = new Map<string,decimal>();
                    // Programs which doesnt contains Budget Type
                    List<string> noBudgetTypePrograms = Label.Core_MDF_No_Budget_Types.split(';');
                    // Defaulting the boolean value to false
                    boolean noBT = false;
                    // stores the claim's program
                    string program = sc.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
                    // checking if claim's program is in noBudgetTypePrograms list
                    noBT =noBudgetTypePrograms.contains(program) ?true: false;
                    // if claim doesnt have BudgetType then use program else use Budget Type
                    string bTorPgm = noBT? program : rr.budgetType;
                    // Looping over budgetTypeList
                    for(string btGeo : budgetTypeList){ // ccf1.0;apj
                        // Splitting the value with ;
                        List<string> splitLst = btGeo.split(';');                        
                        // checking if the the value is same as bTorPgm
                        if(splitLst[0] == bTorPgm){
                            // setting the key as btGeo and value as 0
                            btGeoRecAmtMap.put(btGeo,0);
                        }
                        // checking if crossBTorProgToBTMap contains bt and map.get contains bTorPgm 
                        if(crossBTorProgToBTMap.get(splitLst[0]) != NULL && crossBTorProgToBTMap.get(splitLst[0]).contains(bTorPgm)) {
                            // setting the key as btGeo and value as 0
                            btGeoRecAmtMap.put(btGeo,0);
                        }                         
                    }
                    // if clmToBtRecoveryAmt contains claims id and get is not null
                    if(clmToBtRecoveryAmt.containsKey(sc.id) && clmToBtRecoveryAmt.get(sc.id) != NULL){
                        // adding the get value to tempmap
                        map<string,decimal> tempmap = clmToBtRecoveryAmt.get(sc.id);
                        // looping over the keyset of tempmap
                        for(string st : tempmap.keySet()){
                            // if tempmap.get(st) is not null
                            if(tempmap.get(st) != NULL){
                                // setting the key as st and value as tempmap.get(st)
                                btGeoRecAmtMap.put(st,tempmap.get(st));
                            }                            
                        }                            
                    }
                    // if btGeoRecAmtMap is not null, then set rr.recoveryBudAmtMap as btGeoRecAmtMap
                    if(btGeoRecAmtMap != NULL){
                        rr.recoveryBudAmtMap = btGeoRecAmtMap;
                    }                        				
                //}
                
                rr.selected = false;
                rr.righttoRecover = false;
                if(clmIdToRecAmtMap != NULL && clmIdToRecAmtMap.size()>0 && clmIdToRecAmtMap.containsKey(sc.id) && clmIdToRecAmtMap.get(sc.id) >0 && claimsEligibleForRecoveryHeaders.get(header)=='surePayRecAmt'){
                    rr.surePayRecAmt = String.valueof(clmIdToRecAmtMap.get(sc.id));
                    Boolean isZeroScore = Core_MDF_Recovery_Helper.isZeroScorecardClaim(sc);
                    rr.disableRow = isZeroScore;
                    Boolean isPartialScore = Core_MDF_Recovery_Helper.isPartialScorecardClaim(sc);
                    rr.disableSelected = isPartialScore;
                    rr.selected = (isZeroScore || isPartialScore) ? true : false;                    
                }                
                //if(eligibleClaims != null && eligibleClaims.size() > 0 && eligibleClaims.containsKey(sc.id)){
                if (eligibleClaims == null || eligibleClaims.isEmpty() || !eligibleClaims.containsKey(sc.Id)) { //ATHR Fix WW19
                    continue;
                }

                    
                    rr.selected = true;
                    
                    if(claimsEligibleForRecoveryHeaders.get(header)=='recoveryAmount'){
                        rr.recoveryAmount = String.valueOf(eligibleClaims.get(sc.id));
                    }
                    if(claimsEligibleForRecoveryHeaders.get(header)=='balanceAmt'){
                        decimal balClmAmtAfterManualRec = (clmIdToRecAmtMap.containsKey(sc.Id) && clmIdToRecAmtMap.get(sc.Id) > 0) ? (sc.Amount - clmIdToRecAmtMap.get(sc.Id)) : sc.Amount;
                        decimal balance = balClmAmtAfterManualRec - eligibleClaims.get(sc.id);
                        rr.balanceAmt = String.valueof(balance);
                        
                    }
                    // if header is recoveryBudAmt and clmToBtRecoveryAmt map contains claim id and get is not null
                    if(claimsEligibleForRecoveryHeaders.get(header)=='recoveryBudAmt' && clmToBtRecoveryAmt.containsKey(sc.id) && clmToBtRecoveryAmt.get(sc.id) != NULL){
                        // setting btRecAmt 
                        Map<string,decimal> btRecAmt = clmToBtRecoveryAmt.get(sc.id);
                        // stores budget type list
                        List<string> btList = new List<string>();
                        // adding all the keysets of btRecAmt
                        btList.addAll(btRecAmt.keySet());
                        // sorting the btList
                        btList.sort();
                        string st = '';
                        // looping over the btList
                        for(string btAmt : btList){                                
                            st = st != '' ? st +','+ btAmt+'='+btRecAmt.get(btAmt) : btAmt+'='+btRecAmt.get(btAmt);//CCF 1.0;ASMO=5,CCF 1.0;EMEA=2                                 
                            rr.recoveryBudAmt = String.valueOf(st);	                               
                        }                        
                    }                    
                    if(isRR){
                        Core_MDF_Recovery_Helper.RecoveryRequestDetail rrd = infoFromBE.get(sc.id);
                        rr.comments = String.isNotBlank(rrd.comments) ? rrd.comments : '';
                        rr.budgetGeoConsumed = rrd.budgetGeo;
                        rr.righttoRecover = rrd.readyToRecoverInd;
                        
                        // checking if rr.budgetGeoConsumed not null
                        if(rr.budgetGeoConsumed != NULL){
                            // splitting rr.budgetGeoConsumed with ,
                            List<string> recList = rr.budgetGeoConsumed.split(',');
                            map<string,decimal> tempmap = new map<string,decimal>();
                            // looping over recList
                            for(string bt : recList){
                                // splitting with =
                                list<string> btGeoAmt = bt.split('=');
                                // setting key as btGeoAmt[0] and value as btGeoAmt[1]
                                tempmap.put(btGeoAmt[0],Decimal.valueof(btGeoAmt[1]));                                                                                                 
                            }
                            // if tempmap not null, then set below values
                            if(tempmap != NULL){
                                rr.recoveryBudAmtMap = tempmap;
                                rr.recoveryBudAmt = rr.budgetGeoConsumed;
                            }                           
                        }                        
                    }
                    else{
                        rr.budgetGeoConsumed = infoFromBE.get(sc.id).consumedBudget;
                    }
                    selectedClaimIdSet.add(sc.Id);
                //}             
            }
            
            //Only for RSA MD budget type
            String budgetGeo = '';
            if(String.isNotBlank(sc.Core_MDF_Budget_Type_Options_Nm__c) && String.isNotBlank(sc.Core_MDF_Region_Cd__c)) {
                budgetGeo = sc.Core_MDF_Budget_Type_Options_Nm__c + ';' + sc.Core_MDF_Region_Cd__c;
            }
            
            if(clmIdToRecAmtMap.containsKey(sc.Id) && clmIdToRecAmtMap.get(sc.Id) > 0){
                surePayClaims.add(rr);
            }else if(eligibleClaims != null && eligibleClaims.size() > 0 && eligibleClaims.containsKey(sc.id) && rr.righttoRecover){
                recommendedRTRClaims.add(rr);
            }else if(eligibleClaims != null && eligibleClaims.size() > 0 && eligibleClaims.containsKey(sc.id)){
                recommendedClaims.add(rr);
            }else if(sc.Core_MDF_Budget_Type_Options_Nm__c != 'RSA MD' || (sc.Core_MDF_Budget_Type_Options_Nm__c == 'RSA MD' && String.isNotBlank(budgetGeo) && (rr.recoveryBudAmtMap != null && rr.recoveryBudAmtMap.keySet().contains(budgetGeo)))){
                nonRecommendedClaims.add(rr);
            }
        }
		if(surePayClaims != NULL && surePayClaims.size() > 0){
            rrList.addAll(surePayClaims);
        }        
        if(recommendedRTRClaims != NULL && recommendedRTRClaims.size() > 0){
            rrList.addAll(recommendedRTRClaims);
        }
        rrList.addAll(recommendedClaims);
        rrList.addAll(nonRecommendedClaims);
        frr.rows = rrList;
        frr.selectedIdSet = selectedClaimIdSet;
        frr.isSaved = isRR ? true: false;
        return frr;   
    }
    
    
    @AuraEnabled
    public static string resetRecovery(string program, id account, string quarter){
        List<Core_MDF_Recovery_Request__c> recoveryList = new List<Core_MDF_Recovery_Request__c>();
        string status = '';
        try{
            if(string.isNotBlank(program) && account != null && string.isNotBlank(quarter)){
                recoveryList = [SELECT id,Core_MDF_Program_Nm__c,Core_MDF_Account_Id__c,Core_MDF_Quarter_Year_Nm__c,Core_MDF_Active_Ind__c,Core_MDF_Ready_to_Recover_Ind__c  
                                FROM Core_MDF_Recovery_Request__c
                                WHERE Core_MDF_Active_Ind__c= true AND Core_MDF_Program_Nm__c=:program AND Core_MDF_Quarter_Year_Nm__c=:quarter AND
                                Core_MDF_Account_Id__c =:account]; 
            }
            
            
            if(!recoveryList.isEmpty()){
                for(Core_MDF_Recovery_Request__c recovery: recoveryList){
                    recovery.Core_MDF_Active_Ind__c = false;
                    recovery.Core_MDF_Comment_Txt__c = '';
                    recovery.Core_MDF_Recovered_Budget_Nm__c = '';
                    recovery.Core_MDF_Ready_to_Recover_Ind__c = false;
                } 
                Database.update(recoveryList);
                status = 'success';
            }
            else{
                status = 'success';
            }
            
        }catch(Exception ex){Core_MDF_CCP_UtilityClass.logError(ex); 
                             throw new AuraHandledException(ex.getMessage());
                            }
        return status;
        
    }
    
    public static List<Core_MDF_RecoveryFilters.AccountOptions> getAccountIdToNameMapForExternal (String program){
        List<Core_MDF_RecoveryFilters.AccountOptions> accOpt = new List<Core_MDF_RecoveryFilters.AccountOptions>();
        User u = [select Id, AccountId from user where id=:UserInfo.getUserId() limit 1];
        
        String groupName='';
        //Claim Recovery
        //If program=RMF/IPA, query for pnum instead of pgm
        if(Programs_For_Node_Account.contains(program)){
            for(Core_MDF_Partner_Node_User_Mapping__c pnum : [select id, Core_MDF_Account__c, Core_MDF_Account__r.Name,Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name 
                                                              from Core_MDF_Partner_Node_User_Mapping__c where Core_MDF_Account__r.Core_MDF_Channel_Program__r.Name=:program and
                                                              Core_MDF_Account__r.Core_MDF_Active_Ind__c = true and Core_MDF_User__c=: u.Id and Core_MDF_Active_Ind__c=true order by Core_MDF_Account__r.Name]) {
                                                                  Core_MDF_RecoveryFilters.AccountOptions accOptions = new Core_MDF_RecoveryFilters.AccountOptions();
                                                                  accOptions.accountName = pnum.Core_MDF_Account__r.Name;
                                                                  accOptions.accountId = pnum.Core_MDF_Account__c;
                                                                  accOptions.isExternal = true;
                                                                  accOpt.add(accOptions);
                                                              }
        }
        else{
            
            accOpt = Core_MDF_RecoveryDashboardFilters.getAccountIdToNameMapForExternal(program);
            
        }
        
        
        return accOpt;
        
    }
    //Intel Navneet: To calculate the Breakdown Summary on left hand side table
    @AuraEnabled
    public static List<BreakdownSummary> Get_SummaryBreakdown(String program,Id account,String quarter) {
        List<BreakdownSummary> bdSummaryList = new List<BreakdownSummary> ();
        List<Core_MDF_Partnership_Score_Detail__c> psd = new List<Core_MDF_Partnership_Score_Detail__c>();
        if(Programs_For_Node_Account.contains(program)){
            psd = [SELECT Id, Core_MDF_Budget_Type_Nm__c, Core_MDF_Region_Cd__c,Core_MDF_Total_Recovery_Amt__c, Core_MDF_Carry_Over_Amt__c,Core_MDF_Recovered_Amt__c, Core_MDF_Node_Account_Id__c, Core_MDF_Recovery_Offset_Amt__c, Core_MDF_Recovery_Offset_Comments_txt__c 
                   FROM Core_MDF_Partnership_Score_Detail__c where Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c=:Program and Core_MDF_Node_Account_Id__c=:account  and Core_MDF_Quarter_Year_Nm__c =:quarter  AND Core_MDF_Region_Cd__c != null order by Core_MDF_Budget_Type_Nm__c,Core_MDF_Region_Cd__c ];
        }
        else{
            //updated - acc_id
            psd = [SELECT Id, Core_MDF_Budget_Type_Nm__c, Core_MDF_Region_Cd__c,Core_MDF_Total_Recovery_Amt__c, Core_MDF_Carry_Over_Amt__c,Core_MDF_Recovered_Amt__c, Core_MDF_Recovery_Offset_Amt__c, Core_MDF_Recovery_Offset_Comments_txt__c 
                   FROM Core_MDF_Partnership_Score_Detail__c where Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c=:Program and Core_MDF_Partnership_Score_Id__r.Core_MDF_AccountID_id__c=:account  and Core_MDF_Quarter_Year_Nm__c =:quarter AND Core_MDF_Region_Cd__c != null order by Core_MDF_Budget_Type_Nm__c,Core_MDF_Region_Cd__c ];
        }
        for (Core_MDF_Partnership_Score_Detail__c psdrec : psd)
        {
            BreakdownSummary bdsumm = new BreakdownSummary();
            bdsumm.id = psdrec.Id;
            if (String.isBlank(psdrec.Core_MDF_Budget_Type_Nm__c))
            {bdsumm.budgetType = 'N/A';}
            else{bdsumm.budgetType = psdrec.Core_MDF_Budget_Type_Nm__c;
                }
            bdsumm.region = psdrec.Core_MDF_Region_Cd__c;
            if(psdrec.Core_MDF_Total_Recovery_Amt__c !=null)
            {
                bdsumm.totalAmt = '$' + String.valueOf((psdrec.Core_MDF_Total_Recovery_Amt__c).setScale(2));
            }
            if(psdrec.Core_MDF_Carry_Over_Amt__c !=null){
                bdsumm.carryOverAmt = '$' + String.valueOf((psdrec.Core_MDF_Carry_Over_Amt__c).setScale(2));}
            if(psdrec.Core_MDF_Recovered_Amt__c !=null){
                bdsumm.recoveredAmt = '$' + String.valueOf((psdrec.Core_MDF_Recovered_Amt__c).setScale(2));}
            if(psdrec.Core_MDF_Recovery_Offset_Amt__c != null/* && psdrec.Core_MDF_Budget_Type_Nm__c == 'RSA MD' && psdrec.Core_MDF_Region_Cd__c == 'PRC'*/){
                bdsumm.recoveryOffsetAmt = '$' + String.valueOf((psdrec.Core_MDF_Recovery_Offset_Amt__c).setScale(2));
            }else{
                bdsumm.recoveryOffsetAmt = 'N/A';
            }
            Boolean isCommentsPresent = String.isNotBlank(psdrec.Core_MDF_Recovery_Offset_Comments_txt__c) ? true : false;
            bdsumm.recoveryOffsetComments = isCommentsPresent ? psdrec.Core_MDF_Recovery_Offset_Comments_txt__c : '';
            bdsumm.showrecoveryOffsetDetails = isCommentsPresent;
            bdSummaryList.add(bdsumm);
        }
        return bdSummaryList;
    }
    
    @AuraEnabled
    public static List<string> getRecoveryBT(String program,Id account,String quarter) {
        Map<string, decimal> bTToAmount = new Map<string,decimal>();
        List<string> bTResult = new List<string>();
        set<string> budgetTypeSet = new set<string>();
        List<string> noBudgetTypePrograms = Label.Core_MDF_No_Budget_Types.split(';');
        try{            
            for(Core_MDF_Recovery_Request__c rr : [SELECT Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c FROM Core_MDF_Recovery_Request__c
                                                   WHERE Core_MDF_Program_Nm__c =: Program AND Core_MDF_Account_Id__c =: account AND
                                                   Core_MDF_Quarter_Year_Nm__c =: quarter AND Core_MDF_Active_RO_Ind__c = TRUE AND Core_MDF_Ready_to_Recover_RO_Ind__c = TRUE
                                                   ORDER BY Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c])
            {
                if(noBudgetTypePrograms.contains(program) && rr.Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c == NULL){
                    budgetTypeSet.add(program);
                }
                if(rr.Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c != NULL){
                    budgetTypeSet.add(rr.Core_MDF_Claim_Id__r.Core_MDF_Budget_Type_Options_Nm__c);
                }
            }
            if(budgetTypeSet != NULL && budgetTypeSet.size() > 0){
                bTResult.addAll(budgetTypeSet);
            }else{
                bTResult.add('None');
            }
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}  
        return bTResult;
    }
    
    @AuraEnabled
    public static Boolean hasAccessToOffset(String quarter){
        
        Boolean showOffsetButton = false;
        
        Core_MDF_RecoveryClaimReportViewCtrl.FinalRightRows result = Core_MDF_Recovery_Helper.checkQuarterAndYear(quarter);
        if((FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager') 
            || FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Claim_Case_Reviewer') || (FeatureManagement.checkPermission('Core_MDF_CCP_Internal_RMF_Payment_Admin') && FeatureManagement.checkPermission('Core_MDF_CCP_Internal_PRC_User')) 
            || FeatureManagement.checkPermission('CCP_L3_Maintenance')) && !result.hideClaimInfo){
                showOffsetButton = true;
            }
        return showOffsetButton;
    }
    
    @AuraEnabled
    public static void updatePsdRecords(List<Core_MDF_Partnership_Score_Detail__c> recordList) {
        try {
            if (recordList != null && !recordList.isEmpty()) {
                update recordList;
            }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
            throw new AuraHandledException('Error updating records: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateSobjectList(List<Sobject> sobjectToUpdateList){
        try{
            if(!sobjectToUpdateList.isEmpty()){
                update sobjectToUpdateList;
            }
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    
    public static QuarterSurePayInfo getQuarterInfoAndSurePayAmount(String program, Id accountId) {
        QuarterSurePayInfo info = new QuarterSurePayInfo();
        Set<String> BTSet = new Set<String>();
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
        String currQuarterAndYear = currQuarter + ' ' + currYear;
        info.currentQuarter = currQuarterAndYear;
        info.previousQuarter = previousQuarterAndYear;
        Map<Id, Decimal> claimToSurePay = new Map<Id, Decimal>();
        String query = 'SELECT Core_MDF_Score_Nbr__c, Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__c, Core_MDF_Claim_Amt__c, Core_MDF_Manual_Recovery_Amount_USD_Amt__c, Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c ' +
            'FROM Core_MDF_Scorecard__c WHERE Core_MDF_Quarter__c = :currQuarterAndYear AND Core_MDF_Case_Id__r.Account.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = :program ' +
            'AND Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Processing_Preference_nm__c = \'Settle, then get paid\' AND (Core_MDF_Score_Nbr__c = 0 OR (Core_MDF_Score_Nbr__c > 0 AND Core_MDF_Manual_Recovery_Amount_USD_Amt__c > 0)) ' +
            'AND Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__r.Core_MDF_Status__c in (\'Payment Due\',\'Pending Available Fund\')';
        if (Programs_For_Node_Account.contains(program)) {
            query += ' AND Core_MDF_Case_Id__r.AccountId = :accountId';
        } else {
            query += ' AND Core_MDF_Case_Id__r.Account.Core_MDF_CoMarketing_Ultimate_Account__c = :accountId';
        }        
        Decimal amt = 0;        
        for (Core_MDF_Scorecard__c sc : Database.query(query)) {            
            if (sc.Core_MDF_Score_Nbr__c == 0) {
                amt = sc.Core_MDF_Claim_Amt__c == null ? 0 : sc.Core_MDF_Claim_Amt__c;
            }else if (sc.Core_MDF_Score_Nbr__c > 0 && sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c != null && sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c > 0){                         
                amt = sc.Core_MDF_Manual_Recovery_Amount_USD_Amt__c;
            }
            claimToSurePay.put(sc.Core_MDF_Case_Id__r.Core_MDF_Claim_Lookup_Id__c, amt);
            BTSet.add(sc.Core_MDF_Case_Id__r.Core_MDF_Budget_Type_nm__c);
        }
        
        String recQuery = 'SELECT Core_MDF_Amount_Amt__c,Core_MDF_Claim_Id__c FROM Core_MDF_Recovery__c WHERE Core_MDF_Claim_Id__r.Core_MDF_Processing_Preference_nm__c = \'Settle, then get paid\' AND Core_MDF_Sure_Pay_Ind__c = true ' +
			'AND Core_MDF_Claim_Id__r.Core_MDF_Claim_Review_Case__r.ClosedDate = THIS_QUARTER AND Core_MDF_Claim_Id__r.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c = :program ';
        if (Programs_For_Node_Account.contains(program)) {
            recQuery += ' AND Core_MDF_Claim_Id__r.ChannelPartnerId = :accountId';
        } else {
            recQuery += ' AND Core_MDF_Claim_Id__r.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c = :accountId';
        }
        system.debug('recQuery::'+recQuery);
        List<Core_MDF_Recovery__c> recoveries = Database.query(recQuery);            
        
        for (Core_MDF_Recovery__c rec : recoveries) {
            Id claimId = rec.Core_MDF_Claim_Id__c;
            if (claimToSurePay.containsKey(claimId)) {
                Decimal current = claimToSurePay.get(claimId);
                Decimal recAmt = rec.Core_MDF_Amount_Amt__c == null ? 0 : rec.Core_MDF_Amount_Amt__c;                
                Decimal updated = current - recAmt;
                claimToSurePay.put(claimId, updated < 0 ? 0 : updated);
            }
        }
        system.debug('claimToSurePay::'+claimToSurePay);
        Decimal total = 0;
        for (Decimal val : claimToSurePay.values()) {
            total += val;
        }        
        info.surePayAmount = String.valueOf(total.setScale(2));
        info.surePayBTSet = BTSet;
        info.clmIdToRecAmtMap = claimToSurePay;
        return info;
    }
    
    public class OffsetDetails {
        @AuraEnabled public Boolean showOffsetButton { get; set; }
        @AuraEnabled public Boolean disableOffsetButton { get; set; }
        @AuraEnabled public String recordId { get; set; }
        @AuraEnabled public String offsetComments { get; set; }
        @AuraEnabled public String offsetCommentDetails { get; set; }
        @AuraEnabled public Decimal maxOffsetAmount { get; set; }
        @AuraEnabled public Decimal recoveryOffsetAmount { get; set; }
        @AuraEnabled public Decimal readyToRecoverSavedAmount { get; set; }
        @AuraEnabled public String budgetType { get; set; }
        @AuraEnabled public String region { get; set; }
    }
    
    public class BreakdownSummary {
        @AuraEnabled public String budgetType { get; set; }
        @AuraEnabled public String region { get; set; }
        @AuraEnabled public String totalAmt { get; set; }
        @AuraEnabled public String carryOverAmt { get; set; }
        @AuraEnabled public String recoveredAmt { get; set; }
        @AuraEnabled public String recoveryOffsetAmt { get; set; }
        @AuraEnabled public String recoveryOffsetComments { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public Boolean showrecoveryOffsetDetails { get; set; }
        
    }
    
    //Wrapper Class
    public class ReportColumns {
        //@AuraEnabled public Boolean columnVisible { get; set; }
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public Boolean editable { get; set; }
    }
    
    public class RightReportRows {
        //@AuraEnabled public Boolean columnVisible { get; set; }
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String claimID { get; set; }
        @AuraEnabled public String budgetType { get; set; }
        @AuraEnabled public String geo { get; set; }
        @AuraEnabled public string country { get; set; }
        @AuraEnabled public String clmStatus { get; set; }
        @AuraEnabled public String actCategory { get; set; }
        @AuraEnabled public String actType { get; set; }
        @AuraEnabled public String claimAmt { get; set; }
        @AuraEnabled public String recoveryAmount { get; set; }
        @AuraEnabled public String balanceAmt { get; set; }
        @AuraEnabled public String recoveryBudAmt { get; set; }
        @AuraEnabled public Map<String,decimal> recoveryBudAmtMap { get; set; }
        @AuraEnabled public String comments { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        @AuraEnabled public String mode { get; set; }
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public string program { get; set; }
        @AuraEnabled public string quarter { get; set; }
        @AuraEnabled public string budgetGeoConsumed { get; set; }
        @AuraEnabled public Boolean righttoRecover { get; set; }
        @AuraEnabled public string onSelect { get; set; }
        @AuraEnabled public Boolean recoveryHold { get; set; }
        @AuraEnabled public Boolean disableRow { get; set; }
        @AuraEnabled public Boolean disableSelected { get; set; }
        @AuraEnabled public String surePayRecAmt { get; set; }
        @AuraEnabled public string processingPref { get; set; }
    }
    
    public class FinalRightRows{
        @AuraEnabled public List<RightReportRows> rows {get; set;} 
        @AuraEnabled public set<Id> selectedIdSet {get; set;} 
        @AuraEnabled public boolean isSaved {get; set;} 
        @AuraEnabled public Boolean hideClaimInfo {get; set;} 
        @AuraEnabled public String msgToShow {get; set;} 
        
    }
    
    public class LeftReportRows {
        //@AuraEnabled public Boolean columnVisible { get; set; }
        @AuraEnabled public String groupName { get; set; }
        @AuraEnabled public String totalRecoveryAmt { get; set; }
        @AuraEnabled public String cssProperty{ get; set; }
        @AuraEnabled public List<Core_MDF_RecoveryClaimReportViewCtrl.OffsetDetails> offsetDetailsList{ get; set; } //Only for Offset process
        @AuraEnabled public String currentQuarterYear { get; set; }
        @AuraEnabled public String previousQuarterYear { get; set; }
        @AuraEnabled public String surePayRecoveryAmount { get; set; }
        @AuraEnabled public Set<String> surePayBTSet { get; set; }
        @AuraEnabled public Map<Id,Decimal> clmIdToRecAmtMap { get; set; }
    }
    
    public class QuarterSurePayInfo {
        public String currentQuarter;
        public String previousQuarter;
        public String surePayAmount;
        public Set<String> surePayBTSet = new Set<String>();
        public Map<Id,Decimal> clmIdToRecAmtMap = new Map<Id,Decimal>();
    }
}