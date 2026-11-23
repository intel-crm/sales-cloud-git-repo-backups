//NP - 2023
//Class the dynamically embed Power BI reports in Lightning Record Pages
//Maintain URL details in Custom Metatdata - PBI_Embed_Configuration__mdt
public class pBI_Embed_Cloud {
    @AuraEnabled(cacheable=true)
    public static Map<boolean,string> getURL(string configName, string recordId) {
        Map<boolean,string> result=new Map<boolean,string>();
        Map<string,string> filterToField = new Map<string,string>();
        Map<string,string> filterToValue = new Map<string,string>();
        List<string> fieldsToBeQueriedL = new List<string>();
        string filterConditions = '';
        boolean hasAccess = true;
        string url = '';
        
        try {
            //Query to get the URL Configs
            PBI_Embed_Configuration__mdt urlConfig = [select id,Dynamic_filter__c, Filter__c, Filter_and_Value__c, Object__c, Static_Filter__c, URL__c,Security_enforced__c,Security_Query__c, No_Access_Error__c
                                                      from PBI_Embed_Configuration__mdt where DeveloperName = :configName];
            
            url += urlConfig.URL__c;
            
            //If URL has Dynamic Filters
            if(urlConfig.Dynamic_filter__c) {
                system.debug('filter and value : '+ urlConfig.Filter_and_Value__c);
                List<string> filterVal = urlConfig.Filter_and_Value__c.split(';');
                for(string filter:filterVal) {
                    list<string> innerList = filter.split(':');
                    string apiNames = innerList[1].replaceAll('\'','');
                    fieldsToBeQueriedL.add(apiNames);
                    filterToField.put(innerList[0],apiNames);
                    filterToValue.put(innerList[0],innerList[1]);
                }
                system.debug('fieldsToBeQueried: '+fieldsToBeQueriedL);
                string fieldsToBeQueried = String.join(new List <String> (fieldsToBeQueriedL), ',');
                string dynamicQuery = 'Select '+ String.escapeSingleQuotes(fieldsToBeQueried) + ' from '+ urlConfig.Object__c + ' where id=:recordId';
                sObject sO=Database.query(dynamicQuery);
                
                system.debug('sO: '+sO);
                
                url += '&filter=';
                
                for(string fV: filterToField.keyset()) {
                    string value = filterToValue.get(fV).replace(filterToField.get(fV),String.valueOf(sO.get(filterToField.get(fV))));
                    system.debug('value'+value);
                    filterConditions += fV + ' '+ value;
                    if(filterToField.size()>1) {
                        filterConditions += ' and '; 
                    }
                }
                
                url = url+filterConditions;
                url = url.removeend(' and ');
            }
            
            //If URL has static filters
            if(urlConfig.Filter__c) {
                if(urlConfig.Dynamic_filter__c) {
                    url+=' and ' + urlConfig.Static_Filter__c;
                }
                else {
                    url+='&filter=' + urlConfig.Static_Filter__c;
                }
            }
            system.debug('Final url: '+ url);
            system.debug('Final url: '+ urlConfig.Security_enforced__c);
            
            if(urlConfig.Security_enforced__c){
                string query = urlConfig.Security_Query__c + ' WITH SECURITY_ENFORCED';
                sObject[] securitySo =Database.query(query);
                hasAccess = securitySo.size()>0 ? true:false;  
                system.debug('hasAccess: '+ hasAccess);
                if(!hasAccess){
                    url = '';
                    url = urlConfig.No_Access_Error__c;
                }
            }
            
            result.put(hasAccess,url);
            system.debug('result: '+result);
        }
        catch(exception ex) {
            hasAccess = false;
            string error = 'Error :'+ ex.getMessage();
            result.put(hasAccess,error);
            system.debug('result2: '+result);
        }
        
        return result;  
    }
}