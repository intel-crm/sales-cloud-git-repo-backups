public class PSG_EmailMessageLogWrapper {

	public class Recipients {
		public String field;
		public String recipient;
		public String type_z;
	}

	public class Attributes {
		public String type_z;
		public String url;
	}

	public class Metadata {
		public List<String> ccEmails;
		public String description;
		public Boolean protected_z;
		public List<Recipients> recipients;
		public String senderAddress;
		public String senderType;
		public String template;
		public List<String> urls;
	}

	public Attributes attributes;
	public String Id;
	public String TemplateId;
	public String CcEmails;
	public String Description;
	public String DeveloperName;
	public String SenderType;
	public String ManageableState;
	public List<String> NamespacePrefix;
	public String CreatedDate;
	public String CreatedById;
	public String LastModifiedDate;
	public String LastModifiedById;
	public String EntityDefinitionId;
	public Metadata Metadata;
	public String FullName;

	
	public static PSG_EmailMessageLogWrapper parse(String json) {
		return (PSG_EmailMessageLogWrapper) System.JSON.deserialize(json, PSG_EmailMessageLogWrapper.class);
	}
}