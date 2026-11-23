public class Core_MDF_BUSplitClaimsFileWapper {
	public List<PartnerFundClaim> claimsToBeProcessed = new List<PartnerFundClaim>();
    public Core_MDF_Payment__c paymentForClaims = new Core_MDF_Payment__c();
    public Decimal sumOfClaimsAmount = 0;  
    public String geoLocation = '';
    public String subGeoLocation = '';
    public String productCategory = '';
    public String quarterNum = '';
    public String fiscalYear = '';
    public String fyQuarterAndYear = '';
    public String paymentWrapperUniqueKey = '';
    public Decimal totalVatAmt = 0;
    public Boolean isVatEligible = false;
    public Boolean isCTypeInd=false;
    public Decimal buAmount =0;
    public String bu = '';
    public String profitCenter = '';
    public String materialCode = '';
}