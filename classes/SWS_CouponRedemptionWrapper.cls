public without sharing class SWS_CouponRedemptionWrapper{
    
    public List<String> coupons;
    public List<Redemptions> redemptions;
    public class Redemptions {
        public String code;
        public String cloudAccountId;
        public Datetime redeemed;
        public Boolean installed;
        public String creator;
    }
}