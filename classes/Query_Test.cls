public with sharing class Query_Test {
    public Query_Test(){}
    public void query1(){
        List<List <sObject>> searchList;
        String HandledQueryParam;
        String query='Intel® Server System';
        String queryString='';
        String soslQuery='';
        List<Asset> prodList;
        String publicProductRecTypeName = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Global_Asset_RT');
    if(query==''){
        system.debug('empty text');
            queryString = 'SELECT ';
            List<Schema.FieldSetMember> fieldSetMemberList =  Core_Utility.readFieldSet('AssetFieldSet','asset');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                queryString += fieldSetMemberObj.getFieldPath() + ', ';
            }            
            queryString += 'Id FROM asset where status!=\'Inactive\'';
            
                Contact con= [Select id, accountId from contact where id='0033F0000084PNn' limit 1];
                String contactId = con.Id;
                String accountId = con.accountId;
                if(contactId!=null && contactId.length()>0){
                    queryString += ' and (RecordType.DeveloperName=:publicProductRecTypeName or ((contactId =: contactId';
                    if(accountId !=null && accountId !=''){
                        queryString +=' or accountId =: accountId)';
                    }
                     else{
                        queryString +=')';
                    }                    
                    queryString +='))'; 
                }                                        
           
         
            queryString = queryString + ' ORDER BY Core_IPS_Support_License__c, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC';
            queryString +=' LIMIT 3000'; 
            
            
            prodList = database.query(queryString);
           system.debug('prodList=='+prodList);
        }else if(query.trim().length() > 1){
            system.debug('text');
            HandledQueryParam = Core_Utility.SOSLQueryStringValidator(query);
            soslQuery = 'find {*'+String.valueOf(HandledQueryParam)+'*} IN ALL FIELDS RETURNING asset (';
            List<Schema.FieldSetMember> fieldSetMemberList = Core_Utility.readFieldSet('AssetFieldSet','Asset');
            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
                soslQuery += fieldSetMemberObj.getFieldPath() + ', ';
            }
             soslQuery += 'id where status!=\'Inactive\''; 
                Contact con= [Select id, accountId from contact where id='0033F0000084PNn' limit 1];
                String contactId = con.Id;
                String accountId = con.accountId;
                if(contactId!=null && contactId.length()>0) {
                    soslQuery += ' AND (RecordType.DeveloperName=\'IPS Asset\' OR contactId =: contactId';
                    if(accountId !=null && accountId !=''){
                        soslQuery= soslQuery+ ' OR accountId =: accountId'; 
                    }
                    soslQuery += ')';
                    soslQuery= soslQuery+ ' ORDER BY Core_IPS_Support_License__c, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC)';
                }                                        
            }
            else{
                system.debug('defaullt');
                soslQuery= soslQuery+ ' ORDER BY Core_IPS_Support_License__c, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last,Name ASC)';
            }
            system.debug('soslquery==='+soslQuery);
            searchList = search.query(soslQuery);
            system.debug('searchList==='+searchList);
            prodList = ((List<asset>)searchList[0]);
            system.debug('prodList=='+prodList.size());
        }
             
}