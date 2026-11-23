public class Core_MDF_Picklist_Finder_POC {
    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getTreeGridData(){
        List<schema.sObjectType> allObjects = Schema.getGlobalDescribe().Values();
        system.debug ('all objects'+allObjects);
        
        List<AccountWrapper> aooo = new List<AccountWrapper>();
        for( Schema.SObjectType o: allObjects)
        {
      	 if (o.getDescribe().getName() == 'Campaign' ||o.getDescribe().getName() == 'Case' ||o.getDescribe().getName()=='PartnerFundRequest')
          //if (o.getDescribe().getName() == 'Case')
        {
       	List<Schema.RecordTypeInfo> RT = o.getDescribe().getRecordTypeInfos();
        
        AccountWrapper aWraper = new AccountWrapper() ; 
        AccountWrapper fWraper = new AccountWrapper() ;
   		aWraper.name = o.getDescribe().getLabel(); //get api name "getname" //get the Name
        List<Items> co = new List<Items>();
        //List<Items> fld = new List<Items>();
        //List<Items> fldv = new List<Items>(); 
         
         //system.debug('line of 24'+RTI.getDeveloperName());
          			
        for(Schema.RecordTypeInfo RTI : o.getDescribe().getRecordTypeInfos() )
        {
            system.debug('line 23'+o.getDescribe().getRecordTypeInfos());
            if(RTI.getDeveloperName().contains('Core_MDF_'))
            {
             Items RecTypeWrapp = new Items();
        	 List<Items> fld = new List<Items>();
			RecTypeWrapp.name =  RTI.getName();
            co.add(RecTypeWrapp);
          //  system.debug ('DEF'+co);
           // system.debug(RTI.getDeveloperName()+'line 30 RecTypeWrapp'+RecTypeWrapp.name);
         	//system.debug('line of 27'+RTI.getDeveloperName());
          			
          				 Map < String, Schema.SObjectField > fieldMap =  o.getDescribe().fields.getMap();
                	     for(Schema.SObjectField key:fieldMap.values()){
                             
           				 		Schema.DescribeFieldResult f = key.getDescribe();
           				
            			 		 if(String.valueOf(f.getType()).contains('PICKLIST') && f.getName().contains('Core_MDF_')){
                                     
                       			   //  system.debug('RecTypeWrapp Enter Here'+RecTypeWrapp.name+f.getLabel());
                                   //  system.debug('RecTypeWrapp Enter Here2'+RTI.getName());
             			 		 	 Items FieldTypeWrapp = new Items();
                                     List<Items> fldv = new List<Items>();
                          			 FieldTypeWrapp.name= f.getLabel();
						  			 fld.add(FieldTypeWrapp);
                                     
                                       List<Schema.PicklistEntry> ple = f.getPicklistValues();
                            			for( Schema.PicklistEntry pickListVal : ple){
                                            
                                            			Items FieldValueWrapp = new Items();
                                            			FieldValueWrapp.name = pickListVal.getLabel();
														fldv.add(FieldValueWrapp);
											}
                                     FieldTypeWrapp.items = fldv;
                      	}
                            
            		}
                            
                        
                 RecTypeWrapp.items = fld;
				// co.add(RecTypeWrapp);
                        
                     
                	
                	// fWraper.items =fld;
                    // aooo.add(fWraper);
              
                
                

            }
        }
         
      
        aWraper.items = co; 
    
        aooo.add(aWraper);
        
        }
        }
        system.debug('Line 51'+aooo);
		return aooo ;
        }
       
     
	
       public Class AccountWrapper{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }

     public Class Items{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }
   

}