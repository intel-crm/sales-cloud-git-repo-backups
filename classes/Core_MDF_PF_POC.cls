public class Core_MDF_PF_POC {
   
    @AuraEnabled(cacheable=true)
    public static List<Wrapper> getTreeGridData(){
         Map<String, core_mdf_CCP_Object__mdt> mapEd = core_mdf_CCP_Object__mdt.getAll();
        system.debug('mapEd'+mapEd);
			for(String nameEmailDomain : mapEd.keySet()){
                System.debug('----->'+nameEmailDomain);}
          List<schema.sObjectType> allObjects = Schema.getGlobalDescribe().Values();
       //	  system.debug ('all objects'+allObjects);
        
        List<Wrapper> returnlist = new List<Wrapper>();
        for( Schema.SObjectType obj: allObjects)
        {
      	 if (obj.getDescribe().getName() == 'Campaign')
             //||obj.getDescribe().getName() == 'Case' ||obj.getDescribe().getName()=='PartnerFundRequest')
          //if (obj.getDescribe().getName() == 'Case')
        {
       	List<Schema.RecordTypeInfo> RT = obj.getDescribe().getRecordTypeInfos();
        
        Wrapper aWraper = new Wrapper() ; 
        Wrapper fWraper = new Wrapper() ;
   		aWraper.name = obj.getDescribe().getLabel(); //get api name "getname" //get the Name
        aWraper.ConCatname = obj.getDescribe().getLabel();
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
   
 
    public Static List<Items> GetRecordType (schema.sObjectType ObjName)
    {
        
		
       List<Items> rectyp = new List<Items>();
        
       for(Schema.RecordTypeInfo RTI : ObjName.getDescribe().getRecordTypeInfos())
        {
            if(RTI.getDeveloperName().contains('Core_MDF_'))
            {
             Items RecTypeWrapp = new Items();
			 RecTypeWrapp.name =  RTI.getName();
             RecTypeWrapp.ConCatname = ObjName+'+'+RTI.getName();
             RecTypeWrapp.items = GetFields(ObjName,RTI);
             rectyp.add(RecTypeWrapp);
             system.debug('Line 555'+RecTypeWrapp.ConCatname);
        }
         
    }
        return rectyp;
    }
    
    
    public Static List<Items> GetFields (Schema.SObjectType ObjName,Schema.RecordTypeInfo Rectype)
    {
         Map < String, Schema.SObjectField > fieldMap =  ObjName.getDescribe().fields.getMap();
         List<Items> fld = new List<Items>();
                	     for(Schema.SObjectField key:fieldMap.values()){
                             
           				 		Schema.DescribeFieldResult f = key.getDescribe();
           				
            			 		 if(String.valueOf(f.getType()).contains('PICKLIST') && f.getName().contains('Core_MDF_')){
                                     
             			 		 	 Items FieldTypeWrapp = new Items();
                                     List<Items> fldv = new List<Items>();
                          			 FieldTypeWrapp.name= f.getLabel();
                                     FieldTypeWrapp.ConCatname= ObjName+'+'+Rectype.getName()+'+'+f.getLabel();
                                     FieldTypeWrapp.items = GetFieldValues (ObjName,Rectype,f);
						  			 fld.add(FieldTypeWrapp);
                                     
                                   	/* List<Schema.PicklistEntry> ple = f.getPicklistValues();
                            			for( Schema.PicklistEntry pickListVal : ple){
                                            
                                            			Items FieldValueWrapp = new Items();
                                            			FieldValueWrapp.name = pickListVal.getLabel();
														fldv.add(FieldValueWrapp);
											}
                                     FieldTypeWrapp.items = fldv;*/
   }
                             
    }
       return fld;
    }
    
  
    public Static List<Items> GetFieldValues (Schema.SObjectType ObjName , Schema.RecordTypeInfo Rectype,Schema.DescribeFieldResult Field)
    {
       system.debug ('Inside line 86');
       system.debug ('OBJNAME'+ObjName+'RT'+Rectype.getName()+'Field'+Field.getlabel());
        List<Items> fldv = new List<Items>();
        List<Schema.PicklistEntry> ple = Field.getPicklistValues();
                            			for( Schema.PicklistEntry pickListVal : ple){
                                            
                                            			Items FieldValueWrapp = new Items();
                                            			FieldValueWrapp.name = pickListVal.getLabel();
                                            			FieldValueWrapp.ConCatname= ObjName+'+'+Rectype.getName()+'+'+Field.getLabel()+'+'+pickListVal.getLabel();
														fldv.add(FieldValueWrapp);
											}
                                     //ap<Object,List<String>> dependValuesByControlValue = getDependentPicklistValues(PartnerFundRequest.Core_MDF_Activity_Types__c);
   		 							system.debug('Line 168'+fldv);
        							 return fldv;
        
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
            if  (   controlValue == null ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
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