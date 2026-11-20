/**
 * @description       : Wrapper class for claims data payload.
 * @author            : Accenture
 * @group             : Gravity
 * @last modified on  : 04-28-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Pricing_ClaimsDataWrapper {

	public Header Header;
	public List<ClaimsData> claims;

	public class Header {
		public String xid {set;get;}
		public String target_system {set;get;}
		public String source_system {set;get;}
		public String action {set;get;}
	}

	public class ClaimsData {
		public Decimal creditVolume {set;get;}
		public Decimal creditDollars {set;get;}
		public Decimal debitVolume {set;get;}
		public Decimal debitDollars {set;get;}
		public String lastCreditOrDebitDate {set;get;}
		public String dealId {set;get;}
		public String quoteLineNumber {set;get;}
	}
}