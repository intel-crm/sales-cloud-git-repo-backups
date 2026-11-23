public class Test_FieldsAll_Version {
            
	public List<PartnerFundClaim> queryAllFieldsClaim(){
    Map<String,String> mapOfLabelToFieldAPI = new Map<String,String>();

	for(CCP_Activity_Type_dependent_fields__mdt metrics : [Select id,DeveloperName,Core_MDF_Module__c,Core_MDF_Object_API_Field_Name__c from CCP_Activity_Type_dependent_fields__mdt
														where Core_MDF_Module__c='PartnerFundClaim']){
		if(!mapOfLabelToFieldAPI.containsKey(metrics.Core_MDF_Object_API_Field_Name__c)){
			mapOfLabelToFieldAPI.put(metrics.Core_MDF_Object_API_Field_Name__c,metrics.DeveloperName);
		}
		if(metrics.Core_MDF_Object_API_Field_Name__c!=null)
		mapOfLabelToFieldAPI.put(metrics.Core_MDF_Object_API_Field_Name__c,metrics.DeveloperName);
}

System.debug('Total metadata' +mapOfLabelToFieldAPI.size());
System.debug('Total metadata -Fields' +mapOfLabelToFieldAPI.keySet());  
        //String 
        String query='SELECT id,title';
        query+=mapOfLabelToFieldAPI.keySet();
        query+='From PartnerFundClaim Limit 2';
        return Database.query(query);
	}
}