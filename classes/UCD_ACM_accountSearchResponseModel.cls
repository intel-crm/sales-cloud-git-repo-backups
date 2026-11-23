public class UCD_ACM_accountSearchResponseModel {
    public class BusinessNameTypeCd {
		public String type;
		public Boolean ov;
		public String value;
		public String lookupCode;
		public String lookupValue;
		public String uri;
	}

	public String uri;
	public String type;
	public String createdBy;
	public Long createdTime;
	public String updatedBy;
	public Long updatedTime;
	public Attributes attributes;
	public Boolean isFavorite;
	public List<Crosswalks> crosswalks;
	public String label;
	public String secondaryLabel;

	public class IntelRequesterNm {
		public String type;
		public Boolean ov;
		public String value;
		public String uri;
	}

	public class BusinessOrganizationName {
		public String label;
		public Value value;
		public Boolean ov;
		public String uri;
	}
    public class AggregateParent{
        public String label;
        public String relationshipLabel;
        public AggregateParentValue value;
    }
    public class AggregateParentValue{
        public List<IntelRequesterNm> BusinessPartyId;
		public List<BusinessNameTypeCd> CustomerAggregationTypeCd;
    }


	public class Attributes {
		public List<BusinessOrganizationName> BusinessOrganizationName;
		public List<BusinessNameTypeCd> CustomerAggregationTypeCd;
		public List<Addresses> Addresses;
		public List<BusinessOrganizationComplianceWatchList> BusinessOrganizationComplianceWatchList;
		public List<CustomerProcessEngagement> CustomerProcessEngagement;
		public List<BusinessOrganizationNm> ReadyToPublish;
		public List<BusinessNameTypeCd> RPLStatus;
		public List<BusinessNameTypeCd> DataStewardValidationStatus;
		public List<BusinessNameTypeCd> RejectionReason;
		public List<IntelRequesterNm> IntelRequesterNm;
		public List<IntelRequesterNm> IntelRequesterWWID;
		public List<IntelRequesterNm> IntelRequesterEmail;
		public List<IntelRequesterNm> BusinessPartyId;
        public List<AggregateParent> AggregateParent;
	}

	public class Value_Z {
		public List<BusinessNameTypeCd> Country;
	}

	public class Value_X {
		public List<BusinessNameTypeCd> CustomerProcessEngagementCd;
		public List<BusinessOrganizationNm> EffectiveStartDtm;
	}

	public class Value_Y {
		public List<BusinessNameTypeCd> ComplianceWatchListType;
		public List<BusinessOrganizationNm> EffectiveStartDtm;
	}

	public class Addresses {
		public String label;
		public Value_Z value;
		public Boolean ov;
		public String uri;
	}

	public class CustomerProcessEngagement {
		public String label;
		public Value_X value;
		public Boolean ov;
		public String uri;
	}

	public class Crosswalks {
		public String uri;
		public String type;
		public String value;
		public String reltioLoadDate;
		public String createDate;
		public String updateDate;
		public List<String> attributes;
		public String sourceTable;
	}

	public class BusinessOrganizationComplianceWatchList {
		public String label;
		public Value_Y value;
		public Boolean ov;
		public String uri;
	}

	public class Value {
		public List<BusinessOrganizationNm> BusinessOrganizationNm;
		public List<BusinessNameTypeCd> BusinessNameTypeCd;
		public List<BusinessNameTypeCd> LanguageCode;
	}

	public class BusinessOrganizationNm {
		public String type;
		public Boolean ov;
		public String value;
		public String uri;
		public Boolean ignored;
	}
    
    public static List<UCD_ACM_accountSearchResponseModel> parse(String json) {
        return (List<UCD_ACM_accountSearchResponseModel>) System.JSON.deserialize(json, List<UCD_ACM_accountSearchResponseModel>.class);
    }
}