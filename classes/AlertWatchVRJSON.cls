public class AlertWatchVRJSON{
	public Integer size;	
	public Integer totalSize;	
	public boolean done;
	public cls_queryLocator queryLocator;
	public String entityTypeName;	//ValidationRule
	public cls_records[] records;
	class cls_queryLocator {
	}
	public class cls_records {
		public cls_attributes attributes;
		public String Id;	
		public String ValidationName;	
		public cls_EntityDefinition EntityDefinition;
	}
	public class cls_attributes {
		public String type;	//EntityDefinition
		public String url;	///services/data/v57.0/tooling/sobjects/EntityDefinition/01IDf000002qoRn
	}
	public class cls_EntityDefinition {
		public cls_attributes attributes;
		public String DeveloperName;	
	}
	
	
	public static AlertWatchVRJSON parse(String json){
		return (AlertWatchVRJSON) System.JSON.deserialize(json, AlertWatchVRJSON.class);
	}
}