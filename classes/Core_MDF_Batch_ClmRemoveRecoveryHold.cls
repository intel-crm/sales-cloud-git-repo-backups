public without sharing class Core_MDF_Batch_ClmRemoveRecoveryHold implements Database.Batchable<SObject>, Database.Stateful {
    
    public list<id> accountIdList = new list<id>();
    public list<string> budTypeList = new list<string>();
    public list<string> regionList = new list<string>();
    public string program;
    public set<string> keySet = new set<string>();
    public Boolean ccfDcfSpcfCcfbSecondM = false;

    public static Map<string,set<string>> crossBTorProgToBTMap = new Map<string,set<string>>();
    public static String progDCF = Label.Core_MDF_NonTranslateDCFRecordType;
    public static String progCCF = Label.Core_MDF_NonTranslateCCFRecordType;
    public static set<String> programs_For_Node_Account = Core_MDF_CCP_ConstantClass.Programs_For_Node_Account;
    public static String month_data = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Current_Month');
    public static List<String> core_MDF_Program_Recovery_Preselection = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Program_Recovery_Preselection');
    public static List<Integer> thirdMonthsList = Core_MDF_CustomLabelConfig.getIntegerList('Core_MDF_RecoveryRunMonthsCCF_DCF');
    public static List<string> noBudgetTypePrograms = Label.Core_MDF_No_Budget_Types.split(';');
    
    public string quarterYear = Core_MDF_Recovery_Batch.determinePreviousQuartYear(System.Today());

    // Constructor
    //accountIdList this we need to have accList if we have ran the batch - accSpecific or not
    //accountIdListforPSD this we need to check PSD only if balance amt > 0
    public Core_MDF_Batch_ClmRemoveRecoveryHold(list<id> accountIdList, list<string> budTypeList,list<string> regionList,string program) {
        this.accountIdList = accountIdList;
        this.budTypeList = budTypeList;
        this.program = program;
        this.regionList=regionList;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> excludeAccIdSet = new Set<String>();
        excludeAccIdSet = Core_MDF_Recovery_Utility.getExcludeAccounts(program);
        String strQuery = '';
        strQuery = 'select id,Core_MDF_Budget_Type_Options_Nm__c, Core_MDF_Region_Cd__c,';
        strQuery += ' Core_MDF_Program__c, ChannelPartnerId, ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c,ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Recovery_Hold_Ind__c ';
        strQuery += 'from PartnerFundClaim ';
        strQuery += 'where Core_MDF_Recovery_Hold_Ind__c =true and ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c =:program ';
        if(accountIdList!= null && accountIdList.size()>0){
            if(programs_For_Node_Account.contains(program)){
                strQuery += 'and ChannelPartnerId in:accountIdList ';
            }
            else{
                strQuery += 'and ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c in:accountIdList ';
            }
        }
        else{
            strQuery += ' and ChannelPartnerId NOT IN :excludeAccIdSet and ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c NOT IN :excludeAccIdSet';
        }
        if(budTypeList!= null && budTypeList.size()>0){
            strQuery += ' and Core_MDF_Budget_Type_Options_Nm__c in:budTypeList '; 
        }
        if(regionList!= null && regionList.size()>0){
            strQuery += ' and Core_MDF_Region_Cd__c in:regionList '; 
        }
        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext BC, List<PartnerFundClaim> scopeRecords) {
        
        list<PartnerFundClaim> clmlstToBUpdated = new list<PartnerFundClaim>();
        Integer currMonth = getCurrMonth(month_data);

        try{    
            if(!programs_For_Node_Account.contains(program) && thirdMonthsList.contains(currMonth+1) && keySet.size() == 0){
                populateKeySet(program,quarterYear);
                ccfDcfSpcfCcfbSecondM = true;
            }
            clmlstToBUpdated = populateClaimList(scopeRecords,quarterYear,program);
            if(clmlstToBUpdated.size()>0){
                database.update(clmlstToBUpdated);
            }
        }catch(Exception e){ 
            Core_MDF_CCP_UtilityClass.logError(e); } 
        
    }

    public void finish(Database.BatchableContext BC) {

    }
    public list<partnerfundclaim> populateClaimList(List<PartnerFundClaim> scopeRecords,string qtrYr,string prgm){
        list<PartnerFundClaim> clmlstToBUpdated = new list<PartnerFundClaim>();
        
        for(PartnerFundClaim clm : scopeRecords){
            
            if(ccfDcfSpcfCcfbSecondM){
                boolean noBT = noBudgetTypePrograms.contains(prgm) ?true: false;
                string key1 = clm.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c+';'+clm.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+';'+qtrYr;
                string key2 = noBT? '' : ';'+clm.Core_MDF_Budget_Type_Options_Nm__c ;
                if(keySet.contains(key1+key2)){
                    continue;
                }else{
                    clm.Core_MDF_Recovery_Hold_Ind__c = false;
                }
            }else{
                clm.Core_MDF_Recovery_Hold_Ind__c = false;
            }
            clmlstToBUpdated.add(clm);
        }
        return clmlstToBUpdated;
    }

    public Integer getCurrMonth(string month_data){
        Integer currMonth;
        if(month_data!=null && month_data!=''){
            currMonth = Integer.valueOf(month_data);
        }
        else{
            currMonth = System.today().month(); 
        }
        return currMonth;
    }
    public void populateKeySet(string prog, string qtrYr){
        string crossProgram = prog == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_SPCF_Technical_program_name') ? progDCF : prog == Label.Core_MDF_NonTranslateCCFBoostRecordType ? progCCF : null;
        List<String> crossBTorProgList = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_CrossBTorProgRecoveries'); 
                // Looping over the list
        for(string tempString : crossBTorProgList){
            List<String> btOrProg = tempString.split(':');
            set<String> crossBT = new set<string>();
            crossBT.addAll(btOrProg[1].split(','));
            // setting key as BT or Program and value as eligible cross recovery Budget Types
            crossBTorProgToBTMap.put(btOrProg[0],crossBT);
        }

            String psdQuery = 'Select Id, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Program_nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c, ';
            psdQuery +=' Core_MDF_Region_Cd__c,Core_MDF_Budget_Type_nm__c,Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c, Core_MDF_Node_Account_Id__c ';
            psdQuery += 'From Core_MDF_Partnership_Score_Detail__c Where Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c = :prog and Core_MDF_Partnership_Score_Id__r.Core_MDF_Quarter_Year_Nm__c = :qtrYr ';
            
            psdQuery += 'and Core_MDF_Balance_Amount_Amt__c > 0 order by Core_MDF_Account_Id__c';   
            list<Core_MDF_Partnership_Score_Detail__c> psdList = Database.query(psdQuery);
            
            String key;
            for(Core_MDF_Partnership_Score_Detail__c psd : psdList){
                
                if(crossProgram != null){//ccfb/spcf
                    key = program +';'+psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c+';'+qtrYr;
                    keySet.add(key);
                    for(String crossProgBT : crossBTorProgToBTMap.get(psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c)){
                        string tempKey= crossProgram +';'+psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c+';'+qtrYr+';'+crossProgBT;
                        keySet.add(tempKey);
                    }
                }else{//for mdf/mdf+/ccf1.0/dcf1.0
                    key = program +';'+psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c+';'+qtrYr+';'+psd.Core_MDF_Budget_Type_nm__c;
                    keySet.add(key);
                    if(crossBTorProgToBTMap.containsKey(psd.Core_MDF_Budget_Type_nm__c)){
                       for(String crossBt : crossBTorProgToBTMap.get(psd.Core_MDF_Budget_Type_nm__c)){//dcf check once
                        String tempKey = prog +';'+psd.Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c+';'+qtrYr+';'+crossBt;
                        keySet.add(tempKey);                                                               
                    	} 
                    }
                }
            }
    }
}