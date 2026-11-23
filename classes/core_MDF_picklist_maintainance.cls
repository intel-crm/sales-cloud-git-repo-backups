public class core_MDF_picklist_maintainance {

 
    /*@AuraEnabled(cacheable=true)
    public static List<Wrapper> getTreeGridData(){
        
        List<string > result = new List<string >();
 
        
        for(core_MDF_Picklist_Maintainance__mdt obj : [select Core_MDF_Picklist_Maintanance__c from core_MDF_Picklist_Maintainance__mdt order by Core_MDF_Picklist_Maintanance__c ]){
		result.add(obj.Core_MDF_Picklist_Maintanance__c);
	    }
    
        List<Wrapper> returnlist = new List<Wrapper>();
        for( String obj: result )
        {
        system.debug('line 31'+obj);
        // if (obj=='Case'||obj == 'Campaign'||obj=='PartnerFundRequest'||obj=='PartnerFundClaim'||obj == 'Core_MDF_Escalation__c'||obj=='PartnerMarketingBudget'||obj == 'Core_MDF_PFRCustomPicklist__c')
           
         
        {
       	List<Schema.RecordTypeInfo> RT = Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfos();
        system.debug('line 36'+obj);
        Wrapper aWraper = new Wrapper() ; 
        Wrapper fWraper = new Wrapper() ;
   		aWraper.name = Schema.getGlobalDescribe().get(obj).getDescribe().getLabel(); //get api name "getname" //get the Name
        aWraper.ConCatname = Schema.getGlobalDescribe().get(obj).getDescribe().getLabel();
        List<Items> rectype = new List<Items>();
     //   system.debug('ABC'+aWraper.name);
        
		rectype = GetRecordType(obj); 
        aWraper.items = rectype;
       	returnlist.add(aWraper);
        system.debug ('Line 26'+obj);
        }
        }
        system.debug('Line 51'+returnlist);
		return returnlist ;
  	
    }
   
    @AuraEnabled(cacheable=true)//fetching the Core_MDF record types based on object
    public Static List<Items> GetRecordType (string ObjName)
    {
        
		
       List<Items> rectyp = new List<Items>();		
        
       for(Schema.RecordTypeInfo RTI : Schema.getGlobalDescribe().get(ObjName).getDescribe().getRecordTypeInfosByName().values())
        {
            if(RTI.getDeveloperName().contains('Core_MDF_'))
            {
             Items RecTypeWrapp = new Items();
			 RecTypeWrapp.name =  RTI.getName();
             RecTypeWrapp.ConCatname = ObjName+'+'+RTI.getName()+'+'+RTI.getRecordTypeId();
             RecTypeWrapp.items = GetFields(ObjName,RTI.getRecordTypeId());
             rectyp.add(RecTypeWrapp);
             system.debug('Line 555'+RecTypeWrapp.ConCatname);
        }
         
    }
        return rectyp;
    }
    
    @AuraEnabled(cacheable=true)
    public Static List<Items> GetFields (String ObjName,String Rectype) //Fetchning the picklist fields based on Record type
    {
         Map < String, Schema.SObjectField > fieldMap =  Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        system.debug ('FM'+fieldMap);
         List<Items> fld = new List<Items>();
        List<Items> fldv = new List<Items>();
                	     for(Schema.SObjectField key:fieldMap.values()){
                             
           				 		Schema.DescribeFieldResult f = key.getDescribe();
           				
            			 		 if(String.valueOf(f.getType()).contains('PICKLIST')){
                                     
             			 		 	 Items FieldTypeWrapp = new Items();
                          			 FieldTypeWrapp.name= f.getLabel();
                                     FieldTypeWrapp.ConCatname= ObjName+'+'+Rectype+'+'+f.getName();
                                    // FieldTypeWrapp.items = GetFieldValues (ObjName,Rectype,f.getName());
                                    // FieldTypeWrapp.items = GetFieldValues ('Case','0121J000000uIJ8QAM','Core_MDF_Brand__c');
						  			 fld.add(FieldTypeWrapp);
                                     system.debug ('line 96'+fld);
                                   
                                     
   }
                             
    }
       return fld;
    }
    
  
       public Class Wrapper{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String ConCatname {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }

     public Class Items{ 
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String ConCatname {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }*/
   



}