/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessClaimSubmissionClosure 
Core_MDF_ProcessClaimSubmissionClosure
* Version     : 1.0 
* Created Date: 05-20-2020
* Modification Log :
* Developer                          Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Bikram Bebarta         05/20/2020               process claim submission and closure dates
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ProcessClaimSubmissionClosure {
	//new approach
    public static map<string,List<date>> getQuarterStartAndEndDate(map<string,date> dueDateMap){
        map<string,List<date>> qtrDueDateMap = new map<string,List<date>>{};
        map<string,date> qtrStartMap = getDueDate(dueDateMap,'QtrStrtDate');
        map<string,date> qtrEndMap = getDueDate(dueDateMap,'Quarter');
        for(string key:dueDateMap.keySet()){
            List<date> startEndDate = new List<date>();
            if(qtrStartMap.containsKey(key)){
                startEndDate.add(qtrStartMap.get(key));
            }
            if(qtrEndMap.containsKey(key)){
                startEndDate.add(qtrEndMap.get(key));
            }
            qtrDueDateMap.put(key,startEndDate);
        }
        return qtrDueDateMap;
    }
    
    //new approach
    public static map<string,date> getQuarterEndDate(map<string,date> dueDateMap){
        map<string,date> qtrDueDateMap = getDueDate(dueDateMap,'Quarter');
        return qtrDueDateMap;
    }
    
    public static map<string,date> getQuarterStartDate(map<string,date> dueDateMap){
        map<string,date> qtrDueDateMap = getDueDate(dueDateMap,'QtrStrtDate');
        return qtrDueDateMap;
    }
	//new approach
    public static map<string,date> getSubmissionDueDate(map<string,date> dueDateMap){
        map<string,date> submissionDueDateMap = getDueDate(dueDateMap,'Submission');
        return submissionDueDateMap;
    }
	
    public static map<string,date> getDocSubDueDate(map<string,date> dueDateMap){
        map<string,date> closureDueDateMap = getDueDate(dueDateMap,'DocSubDueDate');
        return closureDueDateMap;
    }
    public static map<string,date> getEscSubDate(map<string,date> dueDateMap){
        map<string,date> closureDueDateMap = getDueDate(dueDateMap,'EscDate');
        return closureDueDateMap;
    }
    //new approach
    public static map<string,date> getActSubDueDate(map<string,date> dueDateMap){
        map<string,date> actSubDueDateMap = getDueDate(dueDateMap,'ActSubDueDate');
        return actSubDueDateMap;
    }
    private static Map<string,Core_MDF_CCP_Submission_Window__mdt> getMetadataValuesForKeyApplied(Set<string> keySet){
       map<string,Core_MDF_CCP_Submission_Window__mdt> keyToAppliedMetadataMap = new map<string,Core_MDF_CCP_Submission_Window__mdt>{};  
       map<string,Core_MDF_CCP_Submission_Window__mdt> ncClosureMap = createSubmissionAndClosureMap();       
       for(string key : keySet){
           Core_MDF_CCP_Submission_Window__mdt mtd;
               if(ncClosureMap != null && !ncClosureMap.isEmpty()){
                        string keyApplied;
                        // get the metadata as per the key pgm:budgettype:geo:subgeo:country
                        if(ncClosureMap.containsKey(key)){
                            keyApplied=key;
                            mtd = ncClosureMap.get(key);
                        }else{
                            // if no metadata as per above, then keep checking the metdatda by subgeo, geo, budgettype, programme
                            list<string> keyList = key.split(':');
                            string programme = keyList[0];
                            string budgetType = keyList[1];
                            string geo = keyList[2];
                            string subGeo = keyList[3];
                            
                            string keySubGeo = programme +':'+ budgetType +':'+ geo +':'+ subGeo +':'+ 'null';
                            string keyGeo = programme +':'+ budgetType +':'+ geo +':'+ 'null' +':'+ 'null';
                            string keyPgmBudget = programme +':'+ budgetType +':'+ 'null' +':'+ 'null' +':'+ 'null';
                            string keyPgm = programme +':'+ 'null' +':'+ 'null' +':'+ 'null' +':'+ 'null';
                            
                            
                            if(ncClosureMap.containsKey(keySubGeo)){
                                keyApplied = keySubGeo;
                            }else if(ncClosureMap.containsKey(keyGeo)){
                                keyApplied = keyGeo;
                            }else if(ncClosureMap.containsKey(keyPgmBudget)){
                                keyApplied = keyPgmBudget;
                            }else if(ncClosureMap.containsKey(keyPgm)){
                                keyApplied = keyPgm;
                            }
                            
                            
                            if(string.isNotBlank(keyApplied)){
                                mtd = ncClosureMap.get(keyApplied);
                            }
                        }
                    }
             keyToAppliedMetadataMap.put(key,mtd);
                }
        return keyToAppliedMetadataMap;
    }
	//new approach
    private static map<string,date> getDueDate(map<string,date> submissionDueDateMap,string window){
        map<string,date> dueDateMap = new map<string,date>();
        Map<String,List<InternalMetdata>> ruleToMtdMap = new Map<String,List<InternalMetdata>>{};
                                
        // the key will be-> pgm:budgettype:geo:subgeo:country:date
        // date will be input and parsed as per user locale. input date = date.format()(may need to change after discussion)
        
        Set<string> keySet = new Set<string>{};
        try{
        for(string strKey : submissionDueDateMap.keySet()){
            string key = strKey.substringbeforelast(':');
            keySet.add(key);
        }
        map<string,Core_MDF_CCP_Submission_Window__mdt> inputKeyToMtdMap = getMetadataValuesForKeyApplied(keySet);

        if(submissionDueDateMap != null && !submissionDueDateMap.isEmpty()){
        	for(string strKey : submissionDueDateMap.keySet()){
                if(dueDateMap.containsKey(strKey)){continue;}
            	string key = strKey.substringbeforelast(':');
                string dtStr = strKey.substringafterlast(':');
                date dt;
                try{
                    //dt = date.valueOf(dtStr);
                    dt = date.parse(dtStr);
                }catch(Exception ex){
                    system.debug('exception in date format--- '+dtStr+' --  '+ex.getMessage());
                    continue;
            	}
                if(dt != null){
                    Core_MDF_CCP_Submission_Window__mdt mtd = inputKeyToMtdMap.get(key);
                    // get quarter value from metadata
                        if(mtd != null && mtd.Core_MDF_Quarter__c != null){
                            integer qtrVal = integer.valueOf(mtd.Core_MDF_Quarter__c);
                            date qtrEndDate = getQuarterEndDate(dt,qtrVal);
                            if(window.equalsIgnoreCase('QtrStrtDate')){
                                date qtrStartDate = getQuarterStartDate(dt,qtrVal);
                                if(qtrStartDate != null){
                                    dueDateMap.put(strKey,qtrStartDate);
                                }
                            }
                            else if(window.equalsIgnoreCase('Quarter')){
                                if(qtrEndDate != null){
                                    dueDateMap.put(strKey,qtrEndDate);
                                }
                            }
                            
                            if(window.equalsIgnoreCase('Submission')){
                                // rename getQuarterEndDate
                                if(qtrEndDate != null){
                                    date submissionDueDate = getSubmissionDueDate(qtrEndDate,mtd);
                                    if(submissionDueDate != null){
                                        dueDateMap.put(strKey,submissionDueDate);
                                	}
                                }
                            }
                            else if(window.equalsIgnoreCase('DocSubDueDate')){
                                InternalMetdata intMtd = new InternalMetdata();
                                //String rule;Core_MDF_CCP_Submission_Window__mdt mtd;Date dt;String key;
                                //intMtd.key=strKey;
                                intMtd.rule=mtd.Core_MDF_Doc_Submission_Rule__c;
                                intMtd.mtd=mtd;
                                intMtd.dt=qtrEndDate;//quarter end date 
                                
                                dueDateMap.put(strKey,getDate(intMtd));
                            }
                            else if(window.equalsIgnoreCase('EscDate')){
                                InternalMetdata intMtd = new InternalMetdata();
                                //String rule;Core_MDF_CCP_Submission_Window__mdt mtd;Date dt;String key;
                                //intMtd.key=strKey;
                                intMtd.rule=mtd.Core_MDF_Escalation_Submission_Rule__c;
                                intMtd.mtd=mtd;
                                intMtd.dt=qtrEndDate;//quarter end date
                                dueDateMap.put(strKey,getDate(intMtd));
                            }
                            else if(window.equalsIgnoreCase('ActSubDueDate')){
                                InternalMetdata intMtd = new InternalMetdata();
                                //String rule;Core_MDF_CCP_Submission_Window__mdt mtd;Date dt;String key;
                                //intMtd.key=strKey;
                                intMtd.rule=mtd.Core_MDF_Activity_Auto_Closure_Rule__c;
                                intMtd.mtd=mtd;
                                intMtd.dt=qtrEndDate;//quarter end date
                                dueDateMap.put(strKey,getDate(intMtd));                                
                            }
                            
                        }
                    }
                }
        	} 
    }
    catch(exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
        return dueDateMap;
    }
    
    private static Date getDate(InternalMetdata intMtd){
        List<String> rulesplit=new List<String>();
        Date returnDate = intMtd.dt;
        if(intMtd.rule.contains('+')){
           rulesplit = intMtd.rule.split('\\+');
        }
        else{
           rulesplit.add(intMtd.rule);
        }
        if(rulesplit!=null){
        for(string rule:rulesplit){//max 2 times
            if(rule=='Core_MDF_Claim_Submission_Window_mnth__c'){                
                returnDate = getSubmissionDueDate(returnDate,intMtd.mtd);
            }
            if(rule=='Core_MDF_Doc_Submission_Window__c'){
                returnDate = getClosureDueDate(returnDate,intMtd.mtd);
            }
            if(rule=='Core_MDF_Claim_Submission_Window_days__c'){
                returnDate = getSubmissionDueDate(returnDate,intMtd.mtd);
            }
            if(rule=='Core_MDF_Escalation_Submission_Window__c'){
                returnDate = getEscalationDate(returnDate,intMtd.mtd);
            }
            if(rule=='Core_MDF_Activity_Auto_Closure_SLA__c'){
                returnDate = getActSubDueDate(returnDate,intMtd.mtd);
            }
            if(rule=='Core_MDF_Activity_Auto_Closure_SLA_Month__c'){
                returnDate = getActSubDueDate(returnDate,intMtd.mtd);
            }
            
        }
        }
        return returnDate;
    }
    
    private static date getEscalationDate(date dt, Core_MDF_CCP_Submission_Window__mdt mtd){
        date escSubDate;
        if(dt != null && mtd != null && mtd.Core_MDF_Escalation_Submission_Window__c != null){
            integer EscSubDays = integer.valueOf(mtd.Core_MDF_Escalation_Submission_Window__c);
        	escSubDate = dt.addDays(EscSubDays);	
        }
        return escSubDate;
    }
    private static date getActSubDueDate(date dt, Core_MDF_CCP_Submission_Window__mdt mtd){
        date actSubDueDate;
        
        if(dt != null && mtd != null){
         if(mtd.Core_MDF_Activity_Auto_Closure_SLA_Month__c != null && mtd.Core_MDF_Activity_Auto_Closure_SLA_Month__c > 0 ){
                integer actSubClosureWindowAddMnths = integer.valueOf(mtd.Core_MDF_Activity_Auto_Closure_SLA_Month__c);
                actSubDueDate = dt.addMonths(actSubClosureWindowAddMnths);
                //submissionDueDate = submissionDueDate.addMonths(submissionAddMonths).toStartofMonth().addDays(-1);
                if(mtd.Core_MDF_Quarter__c > 0){
                    integer numberOfDays = Date.daysInMonth(actSubDueDate.year(), actSubDueDate.month());
                	actSubDueDate = Date.newInstance(actSubDueDate.year(), actSubDueDate.month(), numberOfDays);
                }
            }else if(mtd.Core_MDF_Activity_Auto_Closure_SLA__c != null && mtd.Core_MDF_Activity_Auto_Closure_SLA__c > 0 ){
                integer actSubClosureWindowAddDays = integer.valueOf(mtd.Core_MDF_Activity_Auto_Closure_SLA__c);
                actSubDueDate = dt.addDays(actSubClosureWindowAddDays);
            }
        }
        
        /*if(dt != null && mtd != null && mtd.Core_MDF_Activity_Auto_Closure_SLA__c != null){
            integer actSubClosureWindow = integer.valueOf(mtd.Core_MDF_Activity_Auto_Closure_SLA__c);
        	actSubDueDate = dt.addDays(actSubClosureWindow);	
        }*/
        return actSubDueDate;
    }
    
    //new approach
    private static map<string,Core_MDF_CCP_Submission_Window__mdt> createSubmissionAndClosureMap(){
		map<string,Core_MDF_CCP_Submission_Window__mdt> submissionAndClosureMap = new map<string,Core_MDF_CCP_Submission_Window__mdt>();
        list<Core_MDF_CCP_Submission_Window__mdt> ncClosureMtdList = [SELECT Core_MDF_Program__c, Core_MDF_Budget_Type__c, 
                                                                  Core_MDF_Geo__c, Core_MDF_Sub_Geo__c, Core_MDF_Country__c,
                                                                  Core_MDF_Quarter__c,Core_MDF_Case_SLA__c, Core_MDF_Claim_Submission_Window_mnth__c, Core_MDF_Claim_Submission_Window_days__c,
                                                                  Core_MDF_Doc_Submission_Window__c,Core_MDF_Doc_Submission_Rule__c,
                                                                  Core_MDF_Escalation_Submission_Window__c,Core_MDF_Escalation_Submission_Rule__c,
                                                                  Core_MDF_Activity_Auto_Closure_SLA__c,Core_MDF_Activity_Auto_Closure_SLA_Month__c,
                                                                  Core_MDF_Activity_Auto_Closure_Rule__c    
                                                                  FROM Core_MDF_CCP_Submission_Window__mdt
                                                                  WHERE Core_MDF_Active__c = TRUE
                                                                  AND Core_MDF_Program__c != NULL
                                                                  //AND Core_MDF_Budget_Type__c != NULL
                                                                 ];
        for(Core_MDF_CCP_Submission_Window__mdt mtd : ncClosureMtdList){
            //string key = mtd.Core_MDF_Program__c +':'+mtd.Core_MDF_Budget_Type__c +':'+mtd.Core_MDF_Geo__c +':'+mtd.Core_MDF_Sub_Geo__c +':'+mtd.Core_MDF_Country__c +':'+mtd.Core_MDF_Quarter__c;
            string key = mtd.Core_MDF_Program__c +':'+mtd.Core_MDF_Budget_Type__c+':'+mtd.Core_MDF_Geo__c +':'+mtd.Core_MDF_Sub_Geo__c +':'+mtd.Core_MDF_Country__c; 
            key = key.deleteWhitespace();
            //key = key.replaceAll('null','');
            submissionAndClosureMap.put(key,mtd);
        }
        return submissionAndClosureMap;
    }
    //new approach
    private static date getQuarterEndDate(date dt, integer qtrVal){
        date qtrEndDate;
        if(qtrVal == 0){
            qtrEndDate = dt;
        }
        else{
            integer noOfMonthsPerQtr = 12/qtrVal;
            date firstDayCurrentYear = date.newinstance(dt.year(),1,1);
            date claimSubmissionDueDt;
            for(integer i=noOfMonthsPerQtr;i<=12;i+=noOfMonthsPerQtr){
               qtrEndDate = firstDayCurrentYear.addmonths(i);
               qtrEndDate = qtrEndDate.addDays(-1);
               if(dt <= qtrEndDate){
                    break;
               }
            }
        }
        return qtrEndDate;
    }
    
    //quarter start date
    private static date getQuarterStartDate(date dt, integer qtrVal){
        date qtrStartDate;date qtrEndDate;
        integer noOfMonthsPerQtr = 12/(qtrVal==0?4:qtrVal);
            date firstDayCurrentYear = date.newinstance(dt.year(),1,1);
            for(integer i=0;i<=12;i+=noOfMonthsPerQtr){
               qtrStartDate = firstDayCurrentYear.addmonths(i);
               qtrEndDate = firstDayCurrentYear.addmonths(i+noOfMonthsPerQtr);
               qtrEndDate = qtrEndDate.addDays(-1);
               if(dt >= qtrStartDate && dt <= qtrEndDate){
                    break;
               }
            }
        
        return qtrStartDate;
    }
    private static date getSubmissionDueDate(date dt, Core_MDF_CCP_Submission_Window__mdt mtd){
        date submissionDueDate;
        if(dt != null && mtd != null){
            if(mtd.Core_MDF_Claim_Submission_Window_mnth__c != null && mtd.Core_MDF_Claim_Submission_Window_mnth__c > 0 ){
                integer submissionAddMonths = integer.valueOf(mtd.Core_MDF_Claim_Submission_Window_mnth__c);
                submissionDueDate = dt.addMonths(submissionAddMonths);
                //submissionDueDate = submissionDueDate.addMonths(submissionAddMonths).toStartofMonth().addDays(-1);
                if(mtd.Core_MDF_Quarter__c > 0){
                    integer numberOfDays = Date.daysInMonth(submissionDueDate.year(), submissionDueDate.month());
                	submissionDueDate = Date.newInstance(submissionDueDate.year(), submissionDueDate.month(), numberOfDays);
                }
            }else if(mtd.Core_MDF_Claim_Submission_Window_days__c != null && mtd.Core_MDF_Claim_Submission_Window_days__c > 0 ){
                integer submissionAddDays = integer.valueOf(mtd.Core_MDF_Claim_Submission_Window_days__c);
                submissionDueDate = dt.addDays(submissionAddDays);
            }
        }
        return submissionDueDate;
    }
    private static date getClosureDueDate(date dt, Core_MDF_CCP_Submission_Window__mdt mtd){
        date closureDate;
        if(dt != null && mtd != null && mtd.Core_MDF_Doc_Submission_Window__c != null){
            integer closureDays = integer.valueOf(mtd.Core_MDF_Doc_Submission_Window__c);
        	closureDate = dt.addDays(closureDays);	
        }
        return closureDate;
    }
    //Added by Ealisha:need for Days SLA Calculation
     public static Map<string,integer> getDaysSLA(Map<string,integer> keyToDaysSLA){
         Map<string,integer> keyToDaysSLAOutputMap = new Map<string,integer>{};
         Map<string,Core_MDF_CCP_Submission_Window__mdt> ncClosureMap = getMetadataValuesForKeyApplied(keyToDaysSLA.keySet());
         try{
         for(string key:keyToDaysSLA.keySet()){
             Core_MDF_CCP_Submission_Window__mdt mtd = ncClosureMap.get(key);
             if(mtd != null && mtd.Core_MDF_Case_SLA__c != null){
                keyToDaysSLAOutputMap.put(key,Integer.valueOf(mtd.Core_MDF_Case_SLA__c));                  
             }
         }
         }
         catch(exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
         return keyToDaysSLAOutputMap; 
    }
    
    private class InternalMetdata {
        //String key;
        String rule;
        Core_MDF_CCP_Submission_Window__mdt mtd;
        Date dt;
    }
}