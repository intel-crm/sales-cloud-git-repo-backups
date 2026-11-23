public class Account_Hierarchy_TreeGrid_1 {
	@AuraEnabled(cacheable=true)
    public static List<Account> findHierarchyData(){
        List<Account> accList = new List<Account>();
        string queryString = 'select id,name,industry,BillingCity,Owner.Alias,Core_MDF_Parent_Fund_Account__c,Core_Geo__c,Core_Sub_Geo__c from Account ';
        //Section to get all child account details from ultimate parent starts-------------------------
        List<String> currentParents      = new List<String>{};
        Integer level               = 0;
        Boolean endOfStructure      = false;
        //method to find ultimate parent of account
        currentParents = GetUltimateParentId();
        system.debug('@@*******topMostparent:'+currentParents);

         //Loop though all children
        string finalQueryString = '';
        List<Account>  queryOutput = new List<Account> ();
        while ( !endOfStructure ){  
            if( level == 0 ){
                finalQueryString = queryString + ' where id IN : currentParents ORDER BY name  Limit 1000';
            } 
            else {
                finalQueryString = queryString + ' where Core_MDF_Parent_Fund_Account__c IN : currentParents and recordtype.Id = \'0121J000000yaFXQAY\' ORDER  BY name Limit 1000';
            }
            system.debug('********finalQueryString:'+finalQueryString);
            if(finalQueryString != null && finalQueryString !=''){
                try{
                    if(Limits.getLimitQueries()-Limits.getQueries()>0){
                        System.debug('@@@@@Querying');
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
            system.debug('**queryOutput size:'+queryOutput);
            if( queryOutput.size() == 0 ){
                endOfStructure = true;
            }
            else{
                currentParents.clear();
                //iterating through query output
                for ( Integer i = 0 ; i < queryOutput.size(); i++ ){
                    currentParents.add(queryOutput[i].Id);
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
    public static List<String> GetUltimateParentId(){
        Boolean top = false;
        List<String> recIds = new List<String>();
        List<String> demoIds = System.Label.Core_Mdf_DemoAccountIds.split(';');
        string queryString = 'select id ,name, Core_MDF_Parent_Fund_Account__c ,Owner.Alias from Account where recordtype.Id =\'012o0000000GlzTAAS\' and Core_MDF_CoMarketingActive__c=true and id IN : demoIds ORDER BY Name ASC';
        List<Account> accts = database.query(queryString);
		for(Account acc:accts)
        {
            if(acc.Core_MDF_Parent_Fund_Account__c != Null)
                recIds.add(acc.Core_MDF_Parent_Fund_Account__c);
            else
                recIds.add(acc.Id);
        }
       System.debug('@@@accts-'+accts);
        return recIds ;
    }
    
}