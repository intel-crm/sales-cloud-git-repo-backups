public class Core_MDF_POC_1 {

 
        @AuraEnabled(cacheable=true)
    public static List<Wrapper> getTreeGridData(){
        
          List<string> allObjects = new list<string>();
        
         for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values())
    	{
        Schema.DescribeSObjectResult describeSObjectResultObj = objTyp.getDescribe();
      //  if(!describeSObjectResultObj.isCustom())
      //  {
            String name = objTyp.getDescribe().getName();
            // Exclude all the unwanted Sobjects e.g. History, Share etc.
            if(!name.containsignorecase('history') && !name.containsignorecase('tag')&&
             !name.containsignorecase('share') && !name.containsignorecase('feed'))
            {
                allObjects.add(name);
            }
       // }
    }
    system.debug('SObjectList****' + allObjects);
        List<Wrapper> returnlist = new List<Wrapper>();
        for( String obj: allObjects)
        {
         system.debug('line 31'+obj);
         if (obj=='Case'||obj == 'Campaign'||obj=='PartnerFundRequest'||obj=='PartnerFundClaim'||obj == 'Core_MDF_Escalation__c'||obj=='PartnerMarketingBudget'||obj == 'Core_MDF_PFRCustomPicklist__c')
           
         
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
   
    @AuraEnabled(cacheable=true)
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
    public Static List<Items> GetFields (String ObjName,String Rectype)
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
    
  /* @AuraEnabled(cacheable=true)
   public Static List<Items> GetFieldValues (String ObjName,String Rectype,String Field)
    {
                  system.debug ('Inside line 86');
     //  system.debug ('OBJNAME'+ObjName+'RT'+Rectype.getName()+'Field'+Field.getLabel());
        List<Items> fldv = new List<Items>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(ObjName) ;
		Schema.DescribeSObjectResult r = s.getDescribe() ;
		Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
		Schema.DescribeFieldResult fieldResult = fields.get(Field).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                            			for( Schema.PicklistEntry pickListVal : ple){
                                            
                                            			Items FieldValueWrapp = new Items();
                                            			FieldValueWrapp.name = pickListVal.getLabel();
                                            			FieldValueWrapp.ConCatname= ObjName+'+'+Rectype+'+'+Field+'+'+pickListVal.getLabel();
														fldv.add(FieldValueWrapp);
											}
                                     //ap<Object,List<String>> dependValuesByControlValue = getDependentPicklistValues(PartnerFundRequest.Core_MDF_Activity_Types__c);
   		 							system.debug('Line 168'+fldv);
        							 return fldv;
        
    }*/
    //String ObjName,String Rectype,String Field List<Wrapper>
    
   @AuraEnabled(cacheable=true)
   public Static List<Wrapper> getFieldValues ()
    {
        String ObjName='Case';
        String Rectype='0121J000000uIJ8QAM';
        String Field='Core_MDF_Brand__c';
        system.debug('objnm'+ObjName);
        system.debug('objnm1'+Rectype);
        system.debug('objnm2-9'+Field);
        List<Wrapper> returnlist1 = new List<Wrapper>();
        Httprequest req = new HttpRequest();
		req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() +
					    '/services/data/v52.0/ui-api/object-info/' +
						ObjName +
						'/picklist-values/' +
						Rectype +
						'/' +
						Field
						);
		req.setMethod('GET');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
		Http http = new Http();
		HttpResponse res = http.send(req);
		system.debug('respBodyMap'+res.getBody());
		//Map<String, Object> respBodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
		
		//List<object> valuesObjList = (List<object>) respBodyMap.get('values');
		//List<string> pickValues = new List<string>();
		/*List<Map<String, Object>> values = new List<Map<String, Object>>();
        List<Items> fldv = new List<Items>();
        Wrapper aWraper1 = new Wrapper() ;
		for (object obj : (List<Object>)respBodyMap.get('values')) {
		Map<string, object> valuesMap = (map<string, object>) obj;
		//pickValues.add((string) valuesMap.get('value'));
        Wrapper FieldValueWrapp = new Wrapper();
        FieldValueWrapp.name = (string) valuesMap.get('value');
        FieldValueWrapp.ConCatname= ObjName+'+'+Rectype+'+'+Field+'+'+(string)valuesMap.get('value');
		//fldv.add(FieldValueWrapp);
        
        FieldValueWrapp.items = null;
       	returnlist1.add(FieldValueWrapp);
           // system.debug('line 168'+FieldValueWrapp);
		}*/
        Wrapper FieldValueWrapp = new Wrapper();
        FieldValueWrapp.name ='Case';
        FieldValueWrapp.ConCatname= 'Case+id';
		system.debug('pvalues ' + returnlist1);
		return returnlist1;
    }
    
    public static Map<Object,List<String>> getDependentPicklistValues( Schema.sObjectField dependToken )
{
    Schema.DescribeFieldResult depend = dependToken.getDescribe();
    Schema.sObjectField controlToken = depend.getController();
    if ( controlToken == null ) return null;
    Schema.DescribeFieldResult control = controlToken.getDescribe();
    List<Schema.PicklistEntry> controlEntries =
    (   control.getType() == Schema.DisplayType.Boolean
    ?   null
    :   control.getPicklistValues()
    );
 
    String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
    for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
    {
        List<String> base64chars =
            String.valueOf
            (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
            ).split( '' );
        for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
        {
            Object controlValue =
            (   controlEntries == null
            ?   (Object) (index == 1)
            :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
            );
            Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
            if  (   controlValue == null
                ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                ) continue;
            if ( !dependentPicklistValues.containsKey( controlValue ) )
            {
                dependentPicklistValues.put( controlValue, new List<String>() );
            }
            dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
        }
    }
    return dependentPicklistValues;
}
	@AuraEnabled(cacheable=true)
    public static Map<Object,List<String>> getDependentPicklistValues( String sObjectName, String fieldName )
	{
        system.debug('line 181'+getDependentPicklistValues
    (   Schema.getGlobalDescribe().get( sObjectName ).getDescribe().fields.getMap().get( fieldName )
    ));
    return getDependentPicklistValues
    (   Schema.getGlobalDescribe().get( sObjectName ).getDescribe().fields.getMap().get( fieldName )
    );
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
    }
   



}