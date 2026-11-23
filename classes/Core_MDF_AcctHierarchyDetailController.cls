public class Core_MDF_AcctHierarchyDetailController {
	@AuraEnabled(cacheable=true)
    public static List<Account> findHierarchyData(string recId){
        List<Account> accList = new List<Account>();
        string queryString = 'select id,name,type,industry,Core_MDF_Parent_Fund_Account__c from Account ';
        //Section to get all child account details from ultimate parent starts-------------------------
        List<String> currentParent      = new List<String>{};
        Integer level               = 0;
        Boolean endOfStructure      = false;
        //method to find ultimate parent of account
        string topMostparent = GetUltimateParentId(recId );
        system.debug('*******topMostparent:'+topMostparent);
        currentParent.add(topMostparent);
        system.debug('**********topMostparent:'+ currentParent);
        //Loop though all children
        string finalQueryString = '';
        List<Account>  queryOutput = new List<Account> ();
        while ( !endOfStructure ){  
            if( level == 0 ){
                finalQueryString = queryString + ' where id IN : CurrentParent ORDER BY Id Limit 1000';
            } 
            else {
                finalQueryString = queryString + ' where Core_MDF_Parent_Fund_Account__c IN : CurrentParent and recordtype.Id = \'0121J000000yaFXQAY\' ORDER BY id Limit 1000';
            }
            system.debug('********finalQueryString:'+finalQueryString);
            if(finalQueryString != null && finalQueryString !=''){
                try{
                    if(Limits.getLimitQueries()-Limits.getQueries()>0){
                        queryOutput = database.query(finalQueryString);
                        system.debug('***hierarchy level:'+level);
                    }else{
                        system.debug('****endOfStructure is true as SOQL limit reaches:');
                        endOfStructure = true;
                    }
                }catch(exception ex){ 
                    endOfStructure = true;
                }
            }
            system.debug('**queryOutput size:'+queryOutput.size());
            if( queryOutput.size() == 0 ){
                endOfStructure = true;
            }
            else{
                currentParent.clear();
                //iterating through query output
                for ( Integer i = 0 ; i < queryOutput.size(); i++ ){
                    currentParent.add(queryOutput[i].Id);
                    accList.add(queryOutput[i]);
                 }
            }
            level++;
        }
        system.debug('**********accList:'+accList);
        return accList;
    }
    
	// Find the tom most element in Heirarchy  
    // @return objId
    public static String GetUltimateParentId( string recId ){
        Boolean top = false;
        while ( !top ) {
            string queryString = 'select id ,name, Core_MDF_Parent_Fund_Account__c,Core_MDF_CoMarketing_Ultimate_Account__c from Account where Id =:recId LIMIT 100';
            Account acc = database.query(queryString);
            if ( acc.Core_MDF_Parent_Fund_Account__c != null ) {
                recId = acc.Core_MDF_Parent_Fund_Account__c;
            }else {
                top = true;
            }
        }
       // recId = acc.Core_MDF_CoMarketing_Ultimate_Account__c;
      //  System.debug('@@@Name-'+acc.name);
        return recId ;
    }
}