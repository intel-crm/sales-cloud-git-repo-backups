public without sharing class Core_MDF_Recovery_Batch implements Database.Batchable<sObject>, Database.Stateful,Core_MDF_BatchSchedulerInterface {
    public static set<String> programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    public static List<String> core_MDF_Program_Recovery_Preselection = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Program_Recovery_Preselection');
    public static List<String> Core_MDF_TechnicalbudgetTypeName = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_TechnicalbudgetTypeName');
    public static List<String> Core_MDF_TechnicalProgramName = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_TechnicalProgramName');
    //Core_MDF_TechnicalProgramName
    //Core_MDF_TechnicalbudgetTypeName	
    public static string jobFrequency = Core_MDF_CCP_ConstantClass.jobFrequency;
    public static string priority =Core_MDF_CCP_ConstantClass.priority;
    public static string programTxt = Core_MDF_CCP_ConstantClass.programTxt;
    public static string recoveryBatch = Core_MDF_CCP_ConstantClass.recoveryBatch;
    public static List<Integer> thirdMonthsList = Core_MDF_CustomLabelConfig.getIntegerList('Core_MDF_RecoveryRunMonthsCCF_DCF');
    public static String month_data = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Current_Month');
    public Set<String> excludeAccIdSet = new Set<String>(); // acc ids to be excluded for recovery

    public string program;
    public string budgetType;
    public string quarterYear;
    public string accountIds;
    public string regions;
    public string source;
    public boolean isRecReq_RecvryDone = false;
    public boolean isPreSelClaim_RecvryDone = false;
    public boolean isPSDataPeresent = false;
    
    public list<id> expliciteAccIdlst = new list<id>();
    public static Map<Id,decimal> eligibleClaims = new Map<Id,decimal>();
    public static List<Id> accountList = new List<Id>();
    public List<Id> accountIdListForWrapper = new List<Id>();
    public List<RecoveryRecoveryRequestWrap> finalRecoveryList = new List<RecoveryRecoveryRequestWrap>();
    public static Map<string,Core_MDF_Partnership_Score_Detail__c> pgmAccQtrBTGeoToPartnerScoreDetailMap = new Map<string,Core_MDF_Partnership_Score_Detail__c>();
    public Boolean isRecoveryAllowed = true;
    public Map<Id,List<Id>> Ultimate_Node_Account_Map = new Map<Id,List<Id>>();
    public static Integer recoveryBatchSize = Integer.ValueOf(Core_MDF_Configuration__c.getValues('Core_MDF_RecoveryClaimUpdateBatch_Size').Core_MDF_Value__c);
    public static object generateInstance(String jsonText, String classSignature){
        object des_Obj;
        map<String,object> parmValueMap = (Map<String, Object>)JSON.deserializeUntyped(jsonText);
            if(classSignature == 'Core_MDF_Recovery_Batch(string pgm, string bgtType, string qtrYr, string accounts)'){
                string pgm = string.valueOf(parmValueMap.get('pgm'));
                string bgtType = string.valueOf(parmValueMap.get('bgtType'));
                string qtrYr = string.valueOf(parmValueMap.get('qtrYr'));
                string accounts = string.valueOf(parmValueMap.get('accounts'));
                des_Obj = new Core_MDF_Recovery_Batch(pgm,bgtType,qtrYr,accounts);
            }
            else if(classSignature == 'Core_MDF_Recovery_Batch(string pgm, string bgtTypes, string qtrYr, string accounts,string regions,string source,boolean isRecReq_RecvryDone,boolean isPreSelClaim_RecvryDone)'){
                string pgm = string.valueOf(parmValueMap.get('pgm'));
                string bgtTypes = string.valueOf(parmValueMap.get('bgtTypes'));
                string qtrYr = string.valueOf(parmValueMap.get('qtrYr'));
                string accounts = string.valueOf(parmValueMap.get('accounts'));
                string regions = string.valueOf(parmValueMap.get('regions'));
                string source = string.valueOf(parmValueMap.get('source'));
                boolean isRecReq_RecvryDone = Boolean.valueOf(parmValueMap.get('isRecReq_RecvryDone'));
                boolean isPreSelClaim_RecvryDone = Boolean.valueOf(parmValueMap.get('isPreSelClaim_RecvryDone'));
                des_Obj = new Core_MDF_Recovery_Batch(pgm,bgtTypes,qtrYr,accounts,regions,source,isRecReq_RecvryDone,isPreSelClaim_RecvryDone);
            }
        	else if(classSignature == 'Core_MDF_Recovery_Batch(string pgm, string bgtType, string qtrYr)'){
                string pgm = string.valueOf(parmValueMap.get('pgm'));
                string bgtType = string.valueOf(parmValueMap.get('bgtType'));
                string qtrYr = string.valueOf(parmValueMap.get('qtrYr'));
                des_Obj = new Core_MDF_Recovery_Batch(pgm,bgtType,qtrYr);
            }
        return des_Obj;
    }
    public Core_MDF_Recovery_Batch()
    {
        this.finalRecoveryList = new List<RecoveryRecoveryRequestWrap>();
    }
    
    public Core_MDF_Recovery_Batch(string pgm, string bgtType, string qtrYr, string accounts)
    {
        this.program = pgm;
        this.budgetType = bgtType;
        this.quarterYear = qtrYr;
        this.accountIds = accounts;
        this.regions = '';
        this.source = 'Recover Run'; //'Payment Run' or 'Recover Run' or 'Adhoc'
        this.isRecReq_RecvryDone = false;
        this.isPreSelClaim_RecvryDone = false;
        this.finalRecoveryList = new List<RecoveryRecoveryRequestWrap>();
    }
    public Core_MDF_Recovery_Batch(string pgm, string bgtTypes, string qtrYr, string accounts,string regions,string source,boolean isRecReq_RecvryDone,boolean isPreSelClaim_RecvryDone)
    {
        this.program = pgm;
        this.budgetType = bgtTypes; 
        this.quarterYear = determinePreviousQuartYear(System.Today());
        this.accountIds = accounts;
        this.regions = regions; 
        this.source = source;
        this.isRecReq_RecvryDone = isRecReq_RecvryDone;
        this.isPreSelClaim_RecvryDone = isPreSelClaim_RecvryDone;
        this.finalRecoveryList = new List<RecoveryRecoveryRequestWrap>();
    }   
    
    //List<String> regionList = regions.split(',');
    //List<String> bdgtTypeList = budgetType.split(',');
    
    public Core_MDF_Recovery_Batch(string pgm, string bgtType, string qtrYr)
    {
        this.program = pgm;
        this.budgetType = bgtType;
        this.quarterYear = qtrYr;
        this.accountIds = '';
        this.regions = '';
        this.source = 'Adhoc'; //'Payment Run' or 'Recover Run' or 'Adhoc'
        this.isRecReq_RecvryDone = false;
        this.isPreSelClaim_RecvryDone = false;
        this.finalRecoveryList = new List<RecoveryRecoveryRequestWrap>();
    }
    
    public class recoveryDataWrapper {
        public String program ;
        public List<Id> accntListId;
        public List<String> regionList;
        public List<string> bdgtTypeList;
        public string qtrYr;
        public String source;
        public boolean isRecReq_RecvryDone ;
        public boolean isPreSelClaim_RecvryDone ;
        public string expliciteAccIds;
    }
    
    public static string determinePreviousQuartYear(date dateToBeconverted){
        string result;
        try{
            Integer quarter = dateToBeconverted.month();
            Integer year = dateToBeconverted.year();
            if(quarter == 1 || quarter == 2 ||quarter == 3 ){result = 'Q4 '+ (year-1);}
            
            else if(quarter == 4 || quarter == 5 ||quarter == 6){result = 'Q1 '+ year;}
            
            else if (quarter == 7 || quarter == 8 ||quarter == 9){result = 'Q2 '+ year;}
            
            else{result = 'Q3 '+ year;}
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
        return result;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String pgm = program;
        excludeAccIdSet = Core_MDF_Recovery_Utility.getExcludeAccounts(pgm);
        String bgtType = budgetType;
        String qrtYr = '';
        if(source == 'Payment Run'){
            quarterYear = determinePreviousQuartYear(System.Today());
            qrtYr = quarterYear;
        }else{
            qrtYr = quarterYear;
        }
        String accounts = accountIds;
        
        List<Id> accountIdList = accounts.split(',');
        Set<Id> Ultimate_Account_Ids = new Set<Id>();
        finalRecoveryList = new List<RecoveryRecoveryRequestWrap>();
        accountIdListForWrapper = new List<Id>();
        //Querying ultimate accounts if prog=IPA/RMF due to new change of node account dependency
        
         if(programs_For_Node_Account.contains(pgm) && !String.isBlank(accounts)){ //ATHR Fix - deeply nested if
        //if(programs_For_Node_Account.contains(pgm)){//ATHR Comment
           // if(!String.isBlank(accounts)) { //ATHR Comment

                //List<Id> accountIdList = accounts.split(',');
                for(Account acc:[Select id, Core_MDF_CoMarketing_Ultimate_Account__c  from Account where Id IN :accountIdList]){
                    if(this.Ultimate_Node_Account_Map.containsKey(acc.Core_MDF_CoMarketing_Ultimate_Account__c)){
                        this.Ultimate_Node_Account_Map.get(acc.Core_MDF_CoMarketing_Ultimate_Account__c).add(acc.Id);
                    }else{
                        this.Ultimate_Node_Account_Map.put(acc.Core_MDF_CoMarketing_Ultimate_Account__c, new List<Id>{acc.Id});
                    }
                }
                Ultimate_Account_Ids=this.Ultimate_Node_Account_Map.keySet();
            //} ATHR Comment
         //}//ATHR Comment
            
        }
        //Query to get the partnership score records for which the recoveries have to be done 
        String query1 = 'Select Id, Core_MDF_Account_Id__c,Core_MDF_Program_nm__c, Core_MDF_Quarter_Year_Nm__c, Core_MDF_Balance_Amount_Amt__c '+
            'From Core_MDF_Partnership_Score__c '+ 'Where Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = :pgm '+
            'and Core_MDF_Quarter_Year_Nm__c = :qrtYr and Core_MDF_Balance_Amount_Amt__c > 0 ';
        String query2 = '';
        if(!String.isBlank(accounts))
        {
            
            if(programs_For_Node_Account.contains(pgm)){
                query2 = 'and Core_MDF_Account_Id__c IN :Ultimate_Account_Ids ';
            }
            else{
                query2 = 'and Core_MDF_Account_Id__c IN :accountIdList ';
            }
        }
        else{
                query2 += ' and Core_MDF_Account_Id__c NOT IN :excludeAccIdSet ';
        }
        String query3 = 'order by Core_MDF_Account_Id__c';
        
        //check in the current month Recovery run allowed or not.
        isRecoveryAllowed = Core_MDF_Recovery_Utility.isRecoveryAllowedForCurrentMonth(Core_MDF_CustomLabelConfig.getTextList('Core_MDF_RecoveryRestrictedMonths'));
        
        return Database.getQueryLocator(String.escapeSingleQuotes(query1+query2+query3));  
    }
    
    // process each batch of records
    public void execute(Database.BatchableContext bc, List<Core_MDF_Partnership_Score__c> partnerScoreList) {
        isPSDataPeresent = true;
        if(!isRecoveryAllowed){
            return;
        }
        if(!Core_MDF_TechnicalProgramName.contains(program)){
            return;
        }
        Savepoint sp = Database.setSavepoint();
        List<RecoveryRecoveryRequestWrap> recoveries = new List<RecoveryRecoveryRequestWrap>();
        List<string> noBudgetTypePrograms = Label.Core_MDF_No_Budget_Types.split(';');
        boolean noBT = noBudgetTypePrograms.contains(program) ?true: false;
        Set<Id> partnershipScoreIds = new Set<Id>();
        try{
            if(partnerScoreList != null && partnerScoreList.size() > 0){
                //To create a map of PgmAcctBudgetTypeGeo and Partnership score detail record
                for(Core_MDF_Partnership_Score__c ps : partnerScoreList)
                {    
                    partnershipScoreIds.add(ps.Id);
                    if(!programs_For_Node_Account.contains(program)){
                        accountList.add(ps.Core_MDF_Account_Id__c);     
                    }
                    else{
                        if(Ultimate_Node_Account_Map != null && !Ultimate_Node_Account_Map.isEmpty() && Ultimate_Node_Account_Map.containsKey(ps.Core_MDF_Account_Id__c)){
                            accountList.addAll(Ultimate_Node_Account_Map.get(ps.Core_MDF_Account_Id__c));
                        }
                    }    
                } 
                if(this.accountIds=='' && programs_For_Node_Account.contains(program) && !partnershipScoreIds.isEmpty()){
                    for(Core_MDF_Partnership_Score_Detail__c psd: [select  Core_MDF_Partnership_Score_Id__c,Core_MDF_Node_Account_Id__c from Core_MDF_Partnership_Score_Detail__c where Core_MDF_Partnership_Score_Id__c in :partnershipScoreIds and Core_MDF_Node_Account_Id__c NOT IN :excludeAccIdSet and Core_MDF_Node_Account_Id__c!=null]){ //ATHR Fix added Core_MDF_Node_Account_Id__c!=null in query
                       // if(psd.Core_MDF_Node_Account_Id__c!=null){ //ATHR Comment
                            accountList.add(psd.Core_MDF_Node_Account_Id__c);
                       // }
                    }
                }
                string pgmBgtQtr = program+';'+budgetType+';'+quarterYear;

                if(accountIdListForWrapper == null || accountIdListForWrapper.size() == 0){
                    accountIdListForWrapper = new List<Id>();
                }

                If(accountList != null && !accountList.isEmpty()){
                    accountIdListForWrapper.addAll(accountList);
                }

                List<String> regionList = new list<string>();
                if(regions != null && regions != ''){
                    regionList = regions.split(',');
                }
                List<String> bdgtTypeList = new list<string>();
                if(budgetType != null && budgetType != ''){
                    bdgtTypeList = budgetType.split(',');
                }
                //proper budget type name check
                for(String bT : bdgtTypeList){
                    if(!Core_MDF_TechnicalbudgetTypeName.contains(bT)){
                        return;
                    }
                }


                recoveryDataWrapper wrapper = new recoveryDataWrapper();
                wrapper.program = program;
                wrapper.accntListId = accountList;
                wrapper.regionList = regionList;
                wrapper.bdgtTypeList = bdgtTypeList;
                wrapper.source = source ;//'Payment Run' or 'Recover Claims' or 'Adhoc'
                wrapper.qtrYr = quarterYear;
                wrapper.isRecReq_RecvryDone = isRecReq_RecvryDone;//false
                wrapper.isPreSelClaim_RecvryDone = isPreSelClaim_RecvryDone;//false
                
                //Calling utility method to perform recovery
                recoveries = Core_MDF_Recovery_Utility.runEligibilityLogicToGetRecoveryRecords(pgmBgtQtr,wrapper);
                
                if(finalRecoveryList == null || finalRecoveryList.size() == 0){
                    finalRecoveryList = new List<RecoveryRecoveryRequestWrap>();
                }

                if(recoveries!=null && !recoveries.isEmpty() && recoveries.size()>0){
                    finalRecoveryList.addAll(recoveries);
                }
      
            } 
        }catch(Exception e){ 
            Database.rollback(sp);
            Core_MDF_CCP_UtilityClass.logError(e); }  
    }   
    public static void runBatch(string program,string budgetType,string quarterYear,string accountIds,string regions,String Source,boolean isRecReq_RecvryDone,boolean isPreSelClaim_RecvryDone){
        List<Core_MDF_Batch_Scheduler__c> batchSchedulerList = new List<Core_MDF_Batch_Scheduler__c>();                        
        Core_MDF_Batch_Scheduler__c customSch = new Core_MDF_Batch_Scheduler__c();
        
        customSch.Core_MDF_Object_JSON_Txt__c = '{"program" : "' + program + '","budgetType" : "' + budgetType + '","quarterYear" : "' + quarterYear + '","accountIds" : "' + accountIds + '","regions" : "' + regions + '","source" : "' + source + '","isRecReq_RecvryDone" : ' + true + ',"isPreSelClaim_RecvryDone" : ' + false + '}';
        customSch.Core_MDF_Batch_Size_Nbr__c = recoveryBatchSize;
        Datetime now = Datetime.now();
        customSch.Scheduled_Time_Dt__c = now.addMinutes(10);
        
        customSch.Core_MDF_Batch_Class_Name_Txt__c = recoveryBatch;
        customSch.Core_MDF_Job_Frequency__c = jobFrequency;
        customSch.Core_MDF_Priority__c = priority;
        customSch.Core_MDF_Program_Txt__c = programTxt;
        batchSchedulerList.add(customSch);
        if(!batchSchedulerList.isEmpty()){
            Database.insert(batchSchedulerList);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        
        try{
            List<String> regionList = new list<string>();
            if(String.isNotBlank(regions)){
                regionList = regions.split(',');
            }
            List<String> bdgtTypeList = new list<string>();
            if(budgetType != null && budgetType != ''){
                bdgtTypeList = budgetType.split(',');
            }
            Integer currMonth = System.today().month();
            if(month_data!=null && month_data!=''){
                currMonth = Integer.valueOf(month_data);
            }
            else{
                currMonth = System.today().month(); 
            }
            
            if(source =='Payment Run'  && isRecReq_RecvryDone==false && isPreSelClaim_RecvryDone==false && (programs_For_Node_Account.contains(program) || (core_MDF_Program_Recovery_Preselection.contains(program) && thirdMonthsList.contains(currMonth)))
                && finalRecoveryList.size()==0 && isPSDataPeresent == true ){
                        try{
                            Core_MDF_Recovery_Batch recoveryBatchReRun = new Core_MDF_Recovery_Batch(program,  budgetType,  quarterYear,  accountIds, regions, source, true, false);
                            database.executeBatch(recoveryBatchReRun,recoveryBatchSize);
                        }
                        catch(Exception e){
                                
                                runBatch(program,  budgetType,  quarterYear,  accountIds, regions, source, true, false);   
                        }
            }
            else if(finalRecoveryList != null && finalRecoveryList.size() > 0){
                
                recoveryDataWrapper wrapperForRerunBatch = new recoveryDataWrapper();
                //in wrapper - we'll send string type parameters only which we have declared in the beginning
                accountList = accountIdListForWrapper;
                wrapperForRerunBatch.accntListId = accountList;
                wrapperForRerunBatch.expliciteAccIds = accountIds;
                wrapperForRerunBatch.program = program;
                wrapperForRerunBatch.regionList = regionList;
                wrapperForRerunBatch.source = source ;//'Payment Run' or 'Recover Claims' or 'Adhoc'
                wrapperForRerunBatch.qtrYr = quarterYear;
                wrapperForRerunBatch.bdgtTypeList = bdgtTypeList;
                wrapperForRerunBatch.isRecReq_RecvryDone = isRecReq_RecvryDone;//true
                wrapperForRerunBatch.isPreSelClaim_RecvryDone = isPreSelClaim_RecvryDone;//false
                Core_MDF_Batch_UpdateRecoveryClaims recoveryBatch = new Core_MDF_Batch_UpdateRecoveryClaims(finalRecoveryList,wrapperForRerunBatch);
                database.executeBatch(recoveryBatch,recoveryBatchSize);
                    
            }
            else if(isRecoveryAllowed && source =='Payment Run' && (isPSDataPeresent == false || finalRecoveryList.size() == 0)){
                if(!String.isBlank(accountIds)){
                    expliciteAccIdlst = accountIds.split(',');
                }
                Core_MDF_Batch_ClmRemoveRecoveryHold removeRecoveryHoldBatchRun = new Core_MDF_Batch_ClmRemoveRecoveryHold(expliciteAccIdlst,bdgtTypeList,regionList,program);
                database.executeBatch(removeRecoveryHoldBatchRun,recoveryBatchSize);
            }
        }   catch(Exception e){ 
            Core_MDF_CCP_UtilityClass.logError(e); } 
        
    }
}