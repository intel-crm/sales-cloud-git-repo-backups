public class Core_MDF_CloseCaseAfterClmSbmWindow {
    /*
    public void getCases(){
        Map<Id,Date> caseWithQuarterMap = new Map<Id,Date>{};
        Map<Id,Date> caseWithClosureDateMap = new Map<Id,Date>{};
        List<Case> casesList = [SELECT ID,Core_MDF_Activity_End_Date__c 
                                FROM CASE 
                                where 
                                RecordType.Name in ('Audit') 
                                and Core_MDF_Channel_Program_txt__c ='Retail Marketing Funds'
                                and Core_MDF_Status__c ='Pending Documents' 
                                limit 5];
        for(Case c: casesList){
            Date clmSubDate = getClmSubDate(c.Core_MDF_Activity_End_Date__c);
            caseWithQuarterMap.put(c.id,clmSubDate);
            system.debug('clmSubDate for case id:'+c.Id+' is:'+clmSubDate);
            Date closureDate = getClosureDate(clmSubDate);            
            caseWithClosureDateMap.put(c.Id,closureDate);
            system.debug('closure date for case id:'+c.Id+' is:'+closureDate);
        }
    }
    public Date getClmSubDate(Date actDate){
        Integer month = actDate.month();
        Integer setMonth;
        if(month>=1 && month<=3){setMonth=1;}
        else if(month>=4 && month<=6){setMonth=4;}
        else if(month>=7 && month<=9){setMonth=7;}
        else if(month>=10 && month<=12){setMonth=10;}  
        Date newActDate = Date.newInstance(actDate.year(), setMonth, actDate.day());
        Date clmSubDate = newActDate.addMonths(1).toStartofMonth().addDays(-1);
        return clmSubDate;
   }
   public Date getClosureDate(Date clmSubDate){
        Date closureDate = clmSubDate.addDays(14);
        return closureDate;
   }
    
    public map<id,DateTime> setClaimNcClosureDate(list<Case> csList){
        // Core_MDF_Document_Submission_DueDate_dtm__c
        // pgm n budgettype
        // read claim window metadata to get Country, Quarter, Claim Submission window days , NC Closure window days, Geo, SubGeo
        // Core_MDF_Document_Submission_DueDate_dtm__c == get end date of quarter(cs.Core_MDF_Activity_End_Date__c) + days(Claim Submission window days) + days (NC Closure window days)
        // after the day pass this date Core_MDF_Document_Submission_DueDate_dtm__c then case ll be noncompliant
        
        map<id,datetime> claimNcClosureDateMap = new map<id,datetime>();
        map<string,Core_MDF_CCP_Claim_Window__mdt> claimWindowMtdMap = new map<string,Core_MDF_CCP_Claim_Window__mdt>();
        //list<Core_MDF_CCP_Claim_Window__mdt> claimWindowMtdList = [SELECT id, Core_MDF_Budget_Type_Txt__c FROM Core_MDF_CCP_Claim_Window__mdt];
        for(Core_MDF_CCP_Claim_Window__mdt mtd : [SELECT id, Core_MDF_Budget_Type_Txt__c FROM Core_MDF_CCP_Claim_Window__mdt]){
            claimWindowMtdMap.put(mtd.Core_MDF_Program__c+mtd.Core_MDF_Budget_Type_Txt__c,mtd);
        }
        for(Case cs : csList){
            string country = cs.Core_MDF_Country_Region__c;
            string programme = cs.Core_MDF_Channel_Program_txt__c;
            Core_MDF_CCP_Claim_Window__mdt mtd = claimWindowMtdMap.get(programme);
            list<integer> claimSubmissionConfigList =  calculateClaimSubmissionAndClosureDays(country,mtd);
            Integer quarter = 4;// claimSubmissionConfigList[0]
            Integer claimSubmissionAddMonths = 1;// claimSubmissionConfigList[1]
            Integer ncClosureDays = 14;// claimSubmissionConfigList[2]
            
            date qtrEndDate = getActivityQuarterEndDate(cs.Core_MDF_Activity_End_Date__c,quarter);
            date claimSubmissionDueDate = qtrEndDate.addMonths(claimSubmissionAddMonths);
            date claimNcClosureDate = claimSubmissionDueDate.addDays(ncClosureDays);
            
            datetime claimNcClosureDateTime = datetime.newInstance(claimNcClosureDate.year(), claimNcClosureDate.month(),claimNcClosureDate.day());
            claimNcClosureDateMap.put(cs.id,claimNcClosureDateTime);
        }
        return claimNcClosureDateMap;
    }
    
    public static date getActivityQuarterEndDate(date activityDt, integer qtrVal){
        date qtrEndDate;
        integer noOfMonthsPerQtr = 12/qtrVal;
        date firstDayCurrentYear = date.newinstance(activityDt.year(),1,1);
        date claimSubmissionDueDt;
        for(integer i=noOfMonthsPerQtr;i<=12;i+=noOfMonthsPerQtr){
           system.debug('new date---- '+firstDayCurrentYear.addmonths(i));
           qtrEndDate = firstDayCurrentYear.addmonths(i);
           qtrEndDate = qtrEndDate.addDays(-1);
           if(activityDt <= qtrEndDate){
                break;
           }
        }
        return qtrEndDate;
    }
    
    public date getClaimSubmissionDueDate(date activityDt, integer claimSubmissionWindowDays){
        date claimSubmissionDate;
        claimSubmissionDate = activityDt.addDays(claimSubmissionWindowDays);
        return claimSubmissionDate;
    }
    
    public date getNcClosureDate(date activityDt, integer ncClosureWindowDays){
        date ncClosureDate;
        ncClosureDate = activityDt.addDays(ncClosureWindowDays);
        return ncClosureDate;
    }
    
    public list<integer> calculateClaimSubmissionAndClosureDays(string country, Core_MDF_CCP_Claim_Window__mdt mtd){
        // pgm, budgettype, country, geo, subgeo, quarter, submissiondays, closuredays
        string countryMtd = 'japan,china:india';//mtd.country
        string quarterMtd = '3:4';//mtd.quarter
        string submissionDaysMtd = '30:40';//mtd.submissiondays
        string closureDaysMtd = '14:20';//mtd.closuredays
        list<string> countryList = countryMtd.split(':');
        list<string> quarterList = quarterMtd.split(':');
        list<string> submissionDaysList = submissionDaysMtd.split(':');
        if(countryMtd.contains(country)){
            
        }else{
            
        }
        return null;
    }
    */
}