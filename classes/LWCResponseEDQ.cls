public  with sharing class LWCResponseEDQ {
    	
	//@AuraEnabled public String qquestion{get;set;}
	//@AuraEnabled  public String llabel{get;set;}
//	@AuraEnabled public String vvalue{get;set;}
//	@AuraEnabled  public Boolean rrequired{get;set;}
@AuraEnabled public List<Edq> edq;
public class Edq {
	public String qquestion;
	public String llabel;
	public String vvalue;
	public Boolean rrequired;
	public String ttype;
	public Boolean val;
}

public class Edq_Z {
public String qquestion;
	public String llabel;
	public List<String> vvalue;
	public Boolean rrequired;
	public String ttype;
	public Boolean val;
}


public static List<LWCResponseEDQ> parse(String json) {
	System.debug('Hassan Khan ----> '+ json);
	if(string.isblank(json)){
		return ( new List<LWCResponseEDQ>()); 
	}else{
		return (List<LWCResponseEDQ>) System.JSON.deserialize(json, List<LWCResponseEDQ>.class);
	}           
}
}