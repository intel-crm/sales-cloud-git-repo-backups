public without sharing class Core_MDF_IAH_Partnership_Score {
    public static String logEntryMsg = '';
    public static Boolean isError = false; 
    public static Boolean retryIndicator = true;
    public static integer retryCount = 0;
    public static exception ex;
    public static List<String> accountIdsList;
    
    public static string callHttp(string program, String quarter,string accounts)
    {
        integer valuesUpdated;
        List<Core_MDF_Partnership_Score__c> PscoreListtobeUpdated =new List<Core_MDF_Partnership_Score__c>();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(120000);
		Map<string, List<Core_MDF_Partnership_Score__c>> pscarryfwdMap = new Map<string, List<Core_MDF_Partnership_Score__c>>();
        String href;
        String hrefpagination;        
        String prevQtr;
        List<String> qysplit = quarter.split(' ');
        List<String> qsplit = qysplit[0].split('');
        Integer quarterInteger = integer.valueof(qsplit[1]);
        Integer yearInteger = integer.valueof(qysplit[1]);
        yearInteger = (quarterInteger==1)?yearInteger:yearInteger;
        
        quarterInteger = (quarterInteger==1)?quarterInteger:quarterInteger;
        prevQtr = 'Q'+quarterInteger+' '+yearInteger;
   
        
        try
        {

            //string qttr = 'Q4 2021'.replace(' ', '+');
            href= '?$start_index=0&$count=1000';
            if(!String.isBlank(prevQtr)){
                String prevQtr1 = prevQtr.replace(' ' , '+');
                    String currQtr= quarter.replace(' ' , '+');
                href += '&quarter_nm='+currQtr;
            }
            if(!String.isBlank(program)){
                String programId = [select id from ChannelProgram WHERE Name =: program LIMIT 1]?.Id;
                href += '&program_id='+programId;
            }
            if(!String.isBlank(accounts)){
                accountIdsList = accounts.split(',');
            }else{
                accountIdsList =new List<string>();
            }
            
             integer pag=0;
             do{
           
            HTTPResponse res = new HTTPResponse();    
            req.setEndpoint('callout:APIJEE_Recovery_IAH_URL'+((pag==0)?href:hrefpagination));//cur_qtr needs to be changed to prev_qtr
           //APIJEE_Recovery_IAH_URL
           req.setMethod('GET');
            res = http.send(req);
            
            List<Links> getnextlink = new List<Links>();
            if(res!=null){hrefpagination = track_resp (res);pag++;}
            if( res.getBody() != NULL){ 
            List<Core_MDF_Partnership_Score__c> PscoreListtobeUpdated2 =new List<Core_MDF_Partnership_Score__c>();
            pscarryfwdMap =getValuesforforCarryFwd(quarter);
            Map<Id,Map<Id,Id>> intelAccountIdToProgramToVirtualCorpAccountId = getVirtualCorpAccount(program, accounts);

            PscoreListtobeUpdated2 = parseJSONoutput(res,pscarryfwdMap, intelAccountIdToProgramToVirtualCorpAccountId);          
            if(PscoreListtobeUpdated2!=null)
            {
                    PscoreListtobeUpdated.addAll(PscoreListtobeUpdated2);
            }
            }
                
           }while(hrefpagination!=null);
           
            if(!PscoreListtobeUpdated.isEmpty()){
                Schema.SObjectField externalID = Core_MDF_Partnership_Score__c.Core_MDF_External_Id__c;
                Database.UpsertResult[] saveResult = Database.upsert(PscoreListtobeUpdated, externalID, false);
            }

		
        }
        catch(exception ex){
            logEntryMsg += Core_MDF_CCP_UtilityClass.getErrorDetails(ex);
            
            if(retryIndicator && retryCount < 3 & !Test.isRunningTest()){
                Core_MDF_Scheduler_IAH_Partnership_Score_Retry();// callHttp(); next 1 hr 
                retryCount += 1;
            }
            Core_MDF_CCP_UtilityClass.logError(ex);
        }      
        if(logEntryMsg == ''){
            string successMessage = string.valueOf(valuesUpdated) + ' records have been inserted/updated successfully for the current quarter from Core_MDF_IAH_Partnership_Score method.';
            return successMessage;
        }
        else{
            string errorMessage = 'Error from IAH method:' + logEntryMsg; 
            return errorMessage; 
        }
    }
    
    public static List<Core_MDF_Partnership_Score__c> parseJSONoutput(HTTPResponse input,Map<string, List<Core_MDF_Partnership_Score__c>> pscarryfwdMap, Map<Id,Map<Id,Id>> intelAccountIdToProgramToVirtualCorpAccountId){
        integer updatedValues; 
        List<Elements> partnershipScoreList = new List<Elements>();
        List<Core_MDF_Partnership_Score__c> partnershipScoreInsertObjs = new List<Core_MDF_Partnership_Score__c>();
        Decimal CarryfwdAmt;
        
        try{
            wrapperPartnershipScoreObj wpsc = (wrapperPartnershipScoreObj)JSON.deserialize(input.getBody(),wrapperPartnershipScoreObj.class);
            partnershipScoreList = wpsc.elements;
            Map<Id,string> programIdToLabelMap = new Map<Id,string>();
			for(Core_MDF_ChannelProgram__mdt channelProgram : [Select Id, Core_MDF_Technical_Program_Name__c,Core_MDF_Program_ID__c FROM Core_MDF_ChannelProgram__mdt LIMIT 1000]){
                programIdToLabelMap.put(channelProgram.Core_MDF_Program_ID__c, channelProgram.Core_MDF_Technical_Program_Name__c);
            }
            for(Elements rec:partnershipScoreList)
            {
                if(rec!=Null)
                {
                    Id virtualCorpAccountId = (intelAccountIdToProgramToVirtualCorpAccountId.containsKey(rec.account_id) && intelAccountIdToProgramToVirtualCorpAccountId.get(rec.account_id).containsKey(rec.program_id)) ? intelAccountIdToProgramToVirtualCorpAccountId.get(rec.account_id).get(rec.program_id) : null;
                    if((accountIdsList.isEmpty() || accountIdsList.contains(rec.account_id)) && String.isNotBlank(virtualCorpAccountId)){
                        Core_MDF_Partnership_Score__c newobj = new Core_MDF_Partnership_Score__c();
                        newobj.Core_MDF_Account_Id__c = rec.account_id;
                        newobj.Core_MDF_Channel_Program_Id__c = rec.program_id;
                        newObj.Core_MDF_Virtual_Corp_Account_Id__c = virtualCorpAccountId;
                        if((rec.program_id)!=null){
                            newobj.Core_MDF_Program_nm__c = programIdToLabelMap.get(String.valueOf(rec.program_id).substring(0, 15));
                        }
                        newobj.Core_MDF_Quarter_Year_Nm__c = rec.quarter_nm;
                        newobj.Core_MDF_Zone_nm__c = rec.zone_nm;
                        newobj.Core_MDF_Aggregate_Claim_Score_Nbr__c=rec.aggregate_claim_score_nbr;
                        newobj.Core_MDF_Partial_Value_Score_Nbr__c=rec.partial_value_score_nbr;
                        //newobj.Core_MDF_Partnership_Grade_Nbr__c=rec.partnership_grade_nbr;//commentit out
                        newobj.Core_MDF_Partnership_Score_Nbr__c=rec.partnership_score_nbr;
                        newobj.Core_MDF_Recovery_Amt__c=rec.recovery_amt;
                        newobj.Core_MDF_Manual_Recovery_Amt__c=rec.manual_recovery_amt;
                        newobj.Core_MDF_Trend_Value_Nm__c=rec.trend_nm;//trend_nm from IAH B4//take the first string
                        newobj.Core_MDF_External_Id__c = rec.program_id + virtualCorpAccountId + rec.quarter_nm;
                        newobj.Core_MDF_Trend_Difference_Score_Nbr__c =String.valueOf(rec.trend_difference_score_nbr);
                        List<Core_MDF_Partnership_Score__c> cFAmtToBeInserted = pscarryfwdMap.containsKey(rec.program_id + virtualCorpAccountId + rec.quarter_nm) ? pscarryfwdMap.get(rec.program_id + virtualCorpAccountId + rec.quarter_nm) : new List<Core_MDF_Partnership_Score__c>();
                        if(cFAmtToBeInserted != null && !cFAmtToBeInserted.isEmpty()){
                            newobj.Core_MDF_Partnership_Score_Id__c = cFAmtToBeInserted[0].Id;
                        }
                    partnershipScoreInsertObjs.add(newobj);
                    }
                }
            }
            
            
            updatedValues = partnershipScoreInsertObjs.size();  
          
        }
        
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        return partnershipScoreInsertObjs;
    }
    
    public static void insertCurrQuarterData(String quarter){
        List<Core_MDF_Bulk_Transaction__e> toBeUpdated = new List<Core_MDF_Bulk_Transaction__e>();
        Map <String,Core_MDF_Partnership_Score__c> uniquekey =new Map <String,Core_MDF_Partnership_Score__c>();
        //String prevQYear = String.escapeSingleQuotes(prevQuarterYear);
        if (String.isBlank(quarter)) {
        quarter = CurrentQuarter();
        }
        String prevQuarterYear = PreviousQuarter(quarter);
        Map<String,Id> progAcctAndPSIDmap = new Map<String,Id>();
		List<Core_MDF_Partnership_Score__c> partScoreList = [SELECT Id, Core_MDF_External_Id__c,Core_MDF_Account_Id__c,Core_MDF_Quarter_Year_Nm__c, Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Channel_Program_Id__c 
                                                             FROM Core_MDF_Partnership_Score__c 
                                                             WHERE Core_MDF_Quarter_Year_Nm__c IN (:quarter, :prevQuarterYear)];
        for(Core_MDF_Partnership_Score__c psRec : partScoreList){
            String progAcctId = String.valueOf(psRec.Core_MDF_Channel_Program_Id__c) + String.valueOf(psRec.Core_MDF_Virtual_Corp_Account_Id__c) + String.valueOf(psRec.Core_MDF_Quarter_Year_Nm__c);
            progAcctAndPSIDmap.put(progAcctId,psRec.Id);
        }
       // List<Core_MDF_Partnership_Score__c> psList = new List<Core_MDF_Partnership_Score__c>();
        for(Account a : [SELECT Id, Core_MDF_Channel_Program__c, Core_MDF_CoMarketing_Ultimate_Account__c
                         FROM Account
                         WHERE RecordType.Name = 'CoMarketing' AND Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketingActive__c = true ]){
       		
        String newprogAcctId = String.valueOf(a.Core_MDF_Channel_Program__c) + String.valueOf(a.Id);
        String key = newprogAcctId+quarter;
        String key2 = newprogAcctId+prevQuarterYear;
        if(!progAcctAndPSIDmap.containsKey(key)){
            Core_MDF_Partnership_Score__c ps = new Core_MDF_Partnership_Score__c();
            ps.Core_MDF_Account_Id__c = a.Core_MDF_CoMarketing_Ultimate_Account__c;
            ps.Core_MDF_Virtual_Corp_Account_Id__c = a.Id;
            ps.Core_MDF_Channel_Program_Id__c = a.Core_MDF_Channel_Program__c;
            ps.Core_MDF_Quarter_Year_Nm__c = quarter;
            ps.Core_MDF_Partnership_Score_Id__c = progAcctAndPSIDmap.get(key2);
            ps.Core_MDF_External_Id__c = '' + a.Core_MDF_Channel_Program__c + a.Id + quarter;
            uniquekey.put(key,ps);
            }
        }
        if (!uniquekey.isEmpty()) {
        	Database.insert(uniquekey.values(), false);
        	}
        Map<String, Core_MDF_Partnership_Score_Detail__c> psKeyTopsdRecordList = new Map<String, Core_MDF_Partnership_Score_Detail__c>();
        for (Core_MDF_Partnership_Score__c ps : uniquekey.values()) {
        Core_MDF_Partnership_Score_Detail__c psd = new Core_MDF_Partnership_Score_Detail__c();
        psd.Core_MDF_External_ID__c = ps.Core_MDF_External_Id__c;
        psd.Core_MDF_Partnership_Score_Id__c = ps.Id;
        psKeyTopsdRecordList.put(ps.Core_MDF_External_Id__c, psd);
        }
    	if (!psKeyTopsdRecordList.isEmpty()) {
        	createPSDandRecoveryDashboardRecords(psKeyTopsdRecordList);
    		}
    }
    
    private static String CurrentQuarter() {
        Date today = Datetime.now().dateGmt();
        Integer month = today.month();
        Integer year = today.year();
        Integer quarter = (month - 1) / 3 + 1;
        return 'Q' + quarter + ' ' + year;
    }

	private static String PreviousQuarter(String currentQuarter) {
        List<String> qysplit = currentQuarter.split(' ');
        List<String> qsplit = qysplit[0].split('');
        Integer quarterInteger = Integer.valueOf(qsplit[1]);
        Integer yearInteger = Integer.valueOf(qysplit[1]);
        yearInteger = (quarterInteger == 1) ? yearInteger - 1 : yearInteger;
        quarterInteger = (quarterInteger == 1) ? 4 : quarterInteger - 1;
        return 'Q' + quarterInteger + ' ' + yearInteger;
    }

    public static void createPSDandRecoveryDashboardRecords(Map<String, Core_MDF_Partnership_Score_Detail__c> psKeyTopsdRecordList){
        //Insert Partnership Score Detail records with PS external Key for Current Quarter
        
        Schema.SObjectField externalID = Core_MDF_Partnership_Score_Detail__c.Core_MDF_External_Id__c;
        Database.UpsertResult[] results = Database.upsert(psKeyTopsdRecordList.values(), externalID, false);

        List<Core_MDF_Recovery_Dashboard__c> recoveryDashboardListToInsert = new List<Core_MDF_Recovery_Dashboard__c>();
        for(Core_MDF_Partnership_Score_Detail__c psd : psKeyTopsdRecordList.values()){
            if(String.isNotBlank(psd.Id)){
                Core_MDF_Recovery_Dashboard__c recoveryDashboard = new Core_MDF_Recovery_Dashboard__c();
                recoveryDashboard.Core_MDF_Is_Active_Ind__c = true;
                recoveryDashboard.Core_MDF_Partnership_Score_Id__c = psd.Core_MDF_Partnership_Score_Id__c;
                recoveryDashboard.Core_MDF_Partnership_Score_Detail_Id__c = psd.Id;
                recoveryDashboardListToInsert.add(recoveryDashboard);
            }
        }

        if(!recoveryDashboardListToInsert.isEmpty()){
            Database.insert(recoveryDashboardListToInsert, false);
        }
    }
    
    //Schedules a Multicurreny Retry Batch after an hour
    public static void Core_MDF_Scheduler_IAH_Partnership_Score_Retry(){
        
        try{            
            Core_MDF_Batch_Scheduler__c customSch = new Core_MDF_Batch_Scheduler__c();
            customSch.Core_MDF_Batch_Size_Nbr__c = 200;
            customSch.Scheduled_Time_Dt__c = system.now().addHours( Core_MDF_CustomLabelConfig.getIntegerValues('Core_MDF_IAH_pull_Batch_retry_delay'));
            customSch.Core_MDF_Batch_Class_Name_Txt__c = 'Core_MDF_Batch_IAH_Pull';
            customSch.Core_MDF_Job_Frequency__c = 'Once';
            customSch.Core_MDF_Priority__c = 'High';
            customSch.Core_MDF_Program_Txt__c = 'CCP'; 
            insert customSch;
        }
        
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
        
    }
   public static string track_resp(HttpResponse resp1)
   {
     boolean goahead = false;
     Http http = new Http();
     HttpRequest req = new HttpRequest();
     HTTPResponse res;
     String href; 
       
    	List<Links> getnextlink = new List<Links>();
          
            wrapperPartnershipScoreObj nextlinks = (wrapperPartnershipScoreObj)JSON.deserialize(resp1.getBody(),wrapperPartnershipScoreObj.class);
            getnextlink =nextlinks.links;
           
            for(Links rec:getnextlink)
            {
            if (rec.rel =='next' )
            {
                
                href = rec.href;
                
            }
               
            }
       return href;
   }
    public static Map<string, List<Core_MDF_Partnership_Score__c>> getValuesforforCarryFwd(string quarter){
        Map<String, List<Core_MDF_Partnership_Score__c >> pScoretodetail = new Map<String, List<Core_MDF_Partnership_Score__c >> ();
        List<Core_MDF_Partnership_Score__c> pgdList;
        String qtrforCarryfwdAmt;
        String qtrforprevQtr;
        if(String.isNotBlank(quarter)){   
            qtrforprevQtr = quarter;    
            List<String> qysplit = quarter.split(' ');
            List<String> qsplit = qysplit[0].split('');
            Integer quarterInteger = integer.valueof(qsplit[1]);
            Integer yearInteger = integer.valueof(qysplit[1]);
            yearInteger = (quarterInteger==1)?yearInteger-1:yearInteger;
            quarterInteger = (quarterInteger==1)?4:quarterInteger-1;
            qtrforCarryfwdAmt = 'Q'+quarterInteger+' '+yearInteger;
            
            
        }
        else{
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            if(qtr[2]!=null)
            {
                qtrforCarryfwdAmt = qtr[2];
            }
                qtrforprevQtr = qtr[1];
            
            
        }
        try{
        for(Core_MDF_Partnership_Score__c psdrec:[Select Id,Core_MDF_Program_Nm__c,Core_MDF_Account_Id__c,Core_MDF_External_Id__c,Core_MDF_Balance_Amount_Amt__c FROM Core_MDF_Partnership_Score__c Where Core_MDF_Quarter_Year_Nm__c =: qtrforCarryfwdAmt ]) {
			   string ExtIdKey = psdrec.Core_MDF_External_Id__c;
                              pgdList = pScoretodetail.get(ExtIdKey) == null? new List<Core_MDF_Partnership_Score__c>() : pScoretodetail.get(ExtIdKey);
			   pgdList.add(psdrec);
               ExtIdKey = psdrec.Core_MDF_External_Id__c.replace(qtrforCarryfwdAmt,qtrforprevQtr);//qtrforCarryfwdAmt,qtrforprevQtr
               pScoretodetail.put(ExtIdKey,pgdList);
               
           }
             
         }
         catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
         return pScoretodetail;
        
     }

     public static Map<Id,Map<Id,Id>> getVirtualCorpAccount(String program, String accountIds){

        String query = 'SELECT Id, Core_MDF_Channel_Program__c, Core_MDF_CoMarketing_Ultimate_Account__c  FROM Account WHERE RecordType.DeveloperName = \'Core_MDF_Co_Marketing\' AND Core_MDF_CoMarketing_Ultimate_Account__c != null AND Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketingActive__c = true';
        if(String.isNotBlank(program)){
            query += ' AND Core_MDF_Channel_Program__r.Name =: program';
        }
        if(String.isNotBlank(accountIds)){
            List<String> accountIdList = accountIds.split(',');
            query += ' AND Core_MDF_CoMarketing_Ultimate_Account__c IN: accountIdList';
        }

        Map<Id,Map<Id,Id>> intelAccountIdToProgramToVirtualCorpAccountId = new Map<Id,Map<Id,Id>>();
        for(Account acc : Database.query(query)){
            if(intelAccountIdToProgramToVirtualCorpAccountId.containsKey(acc.Core_MDF_CoMarketing_Ultimate_Account__c)){
                intelAccountIdToProgramToVirtualCorpAccountId.get(acc.Core_MDF_CoMarketing_Ultimate_Account__c).put(acc.Core_MDF_Channel_Program__c, acc.Id);
            }else{
                intelAccountIdToProgramToVirtualCorpAccountId.put(acc.Core_MDF_CoMarketing_Ultimate_Account__c, new Map<Id,Id>{acc.Core_MDF_Channel_Program__c => acc.Id});
            }
        }
         return intelAccountIdToProgramToVirtualCorpAccountId;
     }
    
    public class errorHandling{
        public string errorCode {get;set;}
        public string errorMessage {get;set;}
    }
    public class wrapperPartnershipScoreObj{
        public String name{get;set;}
        public List<Elements> elements{get;set;}
        public List<Links> links{get;set;}
    }
    public class Links {
        public String rel{get;set;}
        public String href{get;set;}
        public String title{get;set;}
    }
    public class Elements {
        public String account_id{get;set;}
        public decimal manual_recovery_amt{get;set;}
        public String program_id{get;set;}
        public String mview_ts{get;set;}
        public decimal recovery_amt{get;set;}
        public String quarter_nm{get;set;}
        public String zone_nm{get;set;}
        public decimal aggregate_claim_score_nbr{get;set;}
        public decimal trend_difference_score_nbr{get;set;}
        public decimal partial_value_score_nbr{get;set;}
        public decimal partnership_grade_nbr{get;set;}
        public decimal partnership_score_nbr{get;set;}
        public String trend_nm{get;set;}
        public decimal total_recovery_amt{get;set;}
    }

    
}