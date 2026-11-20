/**
 * @description       : Wrapper class for Consumption Attributes payload.
 * @author            : Sandeep Chamate
 * @group             : Accenture
 * @last modified on  : 10-18-2023
 * @last modified by  : Sandeep Chamate
**/
public class Pricing_ConsumptionAttributesWrapper {
    public Header Header;
	public RecordDetails RecordDetails;

	public class Header {
		public String xid {set;get;}
		public String target_system {set;get;}
		public String source_system {set;get;}
		public String action {set;get;}
	}
    
    public class RecordDetails {
        public List<ConsumptionData> ConsumptionData;
    }

	public class ConsumptionData {
		public String cimId {set;get;}
		public String consumptionType {set;get;}
		public String value {set;get;}
		public String mode {set;get;}
		public String isActive {set;get;}
	}

}