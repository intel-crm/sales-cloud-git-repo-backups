public with sharing class CustomSelectOptions {
   @AuraEnabled public  String label {get;set;}
	@AuraEnabled public  String value {get;set;}

	 public CustomSelectOptions() {
		
		this.label = '';
		this.value = '';
		
	}
    
	public CustomSelectOptions(String lab, String val) {
	
		this.label = lab;
		this.value = val;
		
	}
}