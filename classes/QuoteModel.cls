public class QuoteModel {
    public SBQQ__Quote__c record {get;set;}
    public QuoteLineModel[] lineItems {get;set;}
    public QuoteLineGroupModel[] lineItemGroups {get;set;}
    public Integer nextKey {get;set;}
    public Boolean applyAdditionalDiscountLast {get;set;}
    public Boolean applyPartnerDiscountFirst {get;set;}
    public Boolean channelDiscountsOffList {get;set;}
    public Decimal customerTotal {get;set;}
    public Decimal netTotal {get;set;}
    public Decimal netNonSegmentTotal {get;set;}
}