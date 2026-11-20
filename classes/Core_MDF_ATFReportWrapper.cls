public class Core_MDF_ATFReportWrapper {
    
    public Id activityId;
    public string program;
    public string ATFFlag;
    public String ActivityName;
    public string ultimateAccountName;
    public string activityNumber;
    public string budgetType;
    public string activityStatus;
    public Decimal activitySpendingLimitLocal;
    public Decimal activitySpendingLimit;
    //activityspending
    public Decimal intelContribution;
    public String reimburesementRate;
    public Decimal mdfReimburesementRate;
    public Decimal exchangeRate;
    public String currencyValue;
    public String reimburesementRateOld;
    public String reimburesementRateNew;
    public String activitySpendingOld;
    public Decimal activitySpendingNew;
    public Decimal intelContributionOld;
    public Decimal intelContributionNew;
    public Decimal intelContributionDifference;
    public Datetime createdDate;
    public Id createdById; 
    
    public Core_MDF_ATFReportWrapper(Id activityId,String program,string ATFFlag,String ActivityName,string ultimateAccountName,
                                     string activityNumber,string budgetType, string activityStatus,                                                                       
                                     Decimal activitySpendingLimitLocal,Decimal activitySpendingLimit,Decimal intelContribution,
                                     String reimburesementRate,Decimal mdfReimburesementRate,Decimal exchangeRate,String currencyValue,
                                     String reimburesementRateOld,String reimburesementRateNew,String activitySpendingOld,Decimal activitySpendingNew,
                                     Decimal intelContributionOld, Decimal intelContributionNew,Decimal intelContributionDifference,Datetime createdDate,Id createdById){
                                         this.activityId = activityId;
                                         this.program = program;
                                         this.ATFFlag = ATFFlag;
                                         this.ActivityName = ActivityName;
                                         this.ultimateAccountName = ultimateAccountName;
                                         this.activityNumber = activityNumber;
                                         this.budgetType = budgetType;
                                         this.activityStatus = activityStatus;
                                         this.activitySpendingLimitLocal = activitySpendingLimitLocal;
                                         this.activitySpendingLimit = activitySpendingLimit;
                                         this.intelContribution = intelContribution;
                                         this.reimburesementRate = reimburesementRate;
                                         this.mdfReimburesementRate = mdfReimburesementRate;
                                         this.exchangeRate = exchangeRate;
                                         this.currencyValue = currencyValue;
                                         this.reimburesementRateNew = reimburesementRateNew;
                                         this.reimburesementRateOld = reimburesementRateOld;
                                         this.activitySpendingOld = activitySpendingOld;
                                         this.activitySpendingNew = activitySpendingNew;
                                          this.intelContributionOld = intelContributionOld;
                                         this.intelContributionNew = intelContributionNew;
                                         this.intelContributionDifference = intelContributionDifference;
                                         this.createdDate = createdDate;
                                         this.createdById = createdById; 
                                     } 
}