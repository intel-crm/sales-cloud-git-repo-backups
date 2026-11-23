public inherited sharing class DPALine_selector extends fflib_SObjectSelector implements ISelector {
    
     public DPALine_selector() {
          super(false,true,true,false);
    }
    
    public static ISelector newInstance(){
        return (ISelector)Application.Selector.newInstance(core_cpq_dpa_aln_line__c.SObjectType);
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public Schema.SObjectType getSObjectType() {
        return core_cpq_dpa_aln_line__c.sObjectType;
    }   
    
    public List<core_cpq_dpa_aln_line__c> selectDPAById(Id recordId){
		 
        String query = 'SELECT Id,Name FROM core_cpq_dpa_aln_line__c WHERE core_cpq_cis_no_nbr__c = :recordId';
        return Database.query(query);
	}
    
    
}