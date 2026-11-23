public with sharing class mysearchcontroller {
    
@AuraEnabled(cacheable=true)
    public static List<sobject> searchRecords(String searchtext,String myobject,String myobject_fields,String mysearch_field) {
         
         try{

         if(searchtext!='' || String.isNotBlank(searchtext)){      
         String mysearch='%'+searchtext+'%';
         list<sobject> records;

         String query='select '+myobject_fields+' from '+myobject+' where '+mysearch_field+' like \'%'+String.escapeSingleQuotes(mysearch)+'%\''+' order by LastModifiedDate limit 100';
         records= Database.query(query);

        if(records.isEmpty()){
            return null;
        }
        else{
            return records;
        }

         }
         else{
           return null;
         }
         }catch(Exception e){
            system.debug('Error = '+e);
            return null;
         }
        }

}