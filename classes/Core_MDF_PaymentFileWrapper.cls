public class Core_MDF_PaymentFileWrapper {
    public List<PartnerFundClaim> claimsToBeProcessed = new List<PartnerFundClaim>();
    public Core_MDF_Payment__c paymentForClaims = new Core_MDF_Payment__c();
    public Decimal sumOfClaimsAmount = 0;  
    public Decimal sumOfConvertedAmount = 0;
    public String geoLocation = '';
    public String subGeoLocation = '';
    public Decimal currencyExchangeRate = 0;
    public String productCategory = '';
    public String quarterNum = '';
    public String fiscalYear = '';
    public String fyQuarterAndYear = '';
    public String paymentWrapperUniqueKey = '';
    public Decimal totalVatAmt = 0;
    public Boolean isVatEligible = false;
    public Decimal totalConvertedVatAmt = 0;
    public Boolean isCTypeInd=false;
    public String businessUnit = '';
    public String profitcenter = '';
    public String materialCode = '';
    public String shipToNumber ='';
    public String soldToNumber ='';
    //WW42 added to hold costCenter
     public String costCenter ='';
    //WW05 to hold gl Account
    public String glAccount = '';
    //Only for IPA and RMF(Retail MDF)
    public Boolean isRecoveryIncluded = false;
    public Boolean includeOnlyClaimAmountForPayment = false;
    public Decimal sumOfClaimsAmountExcludesRecovery = 0;
    public Decimal sumOfConvertedAmountExcludesRecovery = 0;
    public String salesOrg ='';
    public String distributionChannel ='';
   
}