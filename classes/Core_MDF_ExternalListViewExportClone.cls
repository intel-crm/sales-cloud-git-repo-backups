public class Core_MDF_ExternalListViewExportClone {
  public static List<SingleColumn> lstColumn { get; set; }
 @AuraEnabled
    public static void listViewFilter(Id filterId, String sObjectName) {
        Boolean isVaildSObject;
        String strQuery;
       
        HttpRequest req = new HttpRequest();
        String endpointUrl = '';  
        integer maxExportRows= Integer.valueOf(Label.Core_MDF_Max_export_limit);  
        //try{
            //check if the objname is a valid sobject.
            for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
                 String sobjName = String.valueOf(sObjectType);
                 if (sobjName.contains(sObjectName) ) {
                    isVaildSObject = true;
                    break;
                 }
                
            }
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');      
            req.setClientCertificateName(Label.Core_Self_Signed_Cert);  
            //calling describe list view api to get the details for the selected list view.
            
  
            List<String> whiteListedObjApiNameList = new List<String>();
            // for(Core_MDF_List_View_Group_Mapping__c mdt : [SELECT Core_MDF_Label_txt__c, Core_MDF_Active_ind__c, Core_MDF_SObject_txt__c,Core_MDF_Whitelisted_Object__c FROM Core_MDF_List_View_Group_Mapping__c WHERE Core_MDF_Whitelisted_Object__c=true and Core_MDF_Active_ind__c=true]){
            //     whiteListedObjApiNameList.add(mdt.Core_MDF_SObject_txt__c); 
            // }
            //updated the code for the change of Custom Metadata to Custom Settings - Akanksha
            for(Core_MDF_List_View_Group_Mapping__c itrOnListViewMapping : Core_MDF_List_View_Group_Mapping__c.getall().values()){
                if(itrOnListViewMapping.Core_MDF_Whitelisted_Object__c && itrOnListViewMapping.Core_MDF_Active_ind__c){
                    whiteListedObjApiNameList.add(itrOnListViewMapping.Core_MDF_SObject_txt__c); 
                }
            }
            system.debug('whiteListedObjApiNameList:'+whiteListedObjApiNameList);
            if((isVaildSObject && whiteListedObjApiNameList.contains(sObjectName)) && (string.valueOf(filterId).length() == 15 || string.valueOf(filterId).length() == 18)){
                endpointUrl = Label.Core_MDF_PFRCommunityLink+ Label.Core_MDF_Describe_API_URL4+sObjectName +Label.Core_MDF_Describe_API_URL2 + filterId + Label.Core_MDF_Describe_API_URL3;
            }
       
            
            
            system.debug('endpoint:'+endpointUrl);
            if(endpointUrl != ''){     
                req.setEndpoint(endpointUrl);
                req.setMethod('GET');      
                Http h = new Http();
                HttpResponse res = h.send(req);
                system.debug('res body:'+res.getBody());
                Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());     
                //get the query string from the response
                strQuery = (String)root.get('query') + string.escapeSingleQuotes(' LIMIT ') + (maxExportRows+ 1);  
                System.debug('#10 strQuery: ' + strQuery);
                    lstColumn = new List<SingleColumn>();
                
                //Parsing JSON string to get the column details    
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null){ 
                    if(parser.getCurrentToken() == JSONToken.START_ARRAY) {       
                        while (parser.nextToken() != null) {
                            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                
                                SingleColumn col = (SingleColumn)parser.readValueAs(SingleColumn.class);
                                if(col.hidden == false && col.fieldNameOrPath != NULL && !col.fieldNameOrPath.contains('Clone')) {            
                                    
                                    col.label = col.label.replace(',', '');                            
                                    lstColumn.add(col);                    
                                }    
                            }
                        }
                    }
                }
            }
        //}
        //catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);}  
        
    }
    
      public static void listViewFilterWithRunningUser(Id filterId, String sObjectName, String userId) {
        Boolean isVaildSObject;
        String strQuery;
        User usr = [SELECT Id from User where Id=: userId];
        if(usr !=null){
           System.runAs(usr){
            HttpRequest req = new HttpRequest();
            String endpointUrl = '';  
            integer maxExportRows= Integer.valueOf(Label.Core_MDF_Max_export_limit);  
            try{
                //check if the objname is a valid sobject.
                for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
                     String sobjName = String.valueOf(sObjectType);
                     if (sobjName.contains(sObjectName) ) {
                        isVaildSObject = true;
                        break;
                     }
                    
                }
                req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
                req.setHeader('Content-Type', 'application/json');      
                req.setClientCertificateName(Label.Core_Self_Signed_Cert);  
                //calling describe list view api to get the details for the selected list view.
                
      
                List<String> whiteListedObjApiNameList = new List<String>();
                // for(Core_MDF_List_View_Group_Mapping__c mdt : [SELECT Core_MDF_Label_txt__c, Core_MDF_Active_ind__c, Core_MDF_SObject_txt__c,Core_MDF_Whitelisted_Object__c FROM Core_MDF_List_View_Group_Mapping__c WHERE Core_MDF_Whitelisted_Object__c=true and Core_MDF_Active_ind__c=true]){
                //     whiteListedObjApiNameList.add(mdt.Core_MDF_SObject_txt__c); 
                // }
                //updated the code for the change of Custom Metadata to Custom Settings - Akanksha
                for(Core_MDF_List_View_Group_Mapping__c itrOnListViewMapping : Core_MDF_List_View_Group_Mapping__c.getall().values()){
                    if(itrOnListViewMapping.Core_MDF_Whitelisted_Object__c && itrOnListViewMapping.Core_MDF_Active_ind__c){
                        whiteListedObjApiNameList.add(itrOnListViewMapping.Core_MDF_SObject_txt__c); 
                    }
                }
                system.debug('whiteListedObjApiNameList:'+whiteListedObjApiNameList);
                if((isVaildSObject && whiteListedObjApiNameList.contains(sObjectName)) && (string.valueOf(filterId).length() == 15 || string.valueOf(filterId).length() == 18)){
                    endpointUrl = Label.Core_MDF_PFRCommunityLink+ Label.Core_MDF_Describe_API_URL4+sObjectName +Label.Core_MDF_Describe_API_URL2 + filterId + Label.Core_MDF_Describe_API_URL3;
                }
           
                
                
                system.debug('endpoint:'+endpointUrl);
                if(endpointUrl != ''){     
                    req.setEndpoint(endpointUrl);
                    req.setMethod('GET');      
                    Http h = new Http();
                    HttpResponse res = h.send(req);
                    system.debug('res body:'+res.getBody());
                    Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());     
                    //get the query string from the response
                    strQuery = (String)root.get('query') + string.escapeSingleQuotes(' LIMIT ') + (maxExportRows+ 1);  
                    System.debug('#10 strQuery: ' + strQuery);
                        lstColumn = new List<SingleColumn>();
                    
                    //Parsing JSON string to get the column details    
                    JSONParser parser = JSON.createParser(res.getBody());
                    while (parser.nextToken() != null){ 
                        if(parser.getCurrentToken() == JSONToken.START_ARRAY) {       
                            while (parser.nextToken() != null) {
                                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                    
                                    SingleColumn col = (SingleColumn)parser.readValueAs(SingleColumn.class);
                                    if(col.hidden == false && col.fieldNameOrPath != NULL && !col.fieldNameOrPath.contains('Clone')) {            
                                        
                                        col.label = col.label.replace(',', '');                            
                                        lstColumn.add(col);                    
                                    }    
                                }
                            }
                        }
                    }
                }
            }
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);}  
            }   }
    }
    
     public class SingleColumn {    
        @AuraEnabled public String  ascendingLabel  { get; set; }
        @AuraEnabled public String  descendingLabel { get; set; }
        @AuraEnabled public String  fieldNameOrPath { get; set; }
        @AuraEnabled public Boolean hidden          { get; set; }
        @AuraEnabled public String  label           { get; set; }
        @AuraEnabled public String  selectListItem  { get; set; }
        @AuraEnabled public String  sortDirection   { get; set; }
        @AuraEnabled public Integer sortIndex       { get; set; }
        @AuraEnabled public Boolean sortable        { get; set; }
        @AuraEnabled public String  type            { get; set; }
        @AuraEnabled public Boolean isDateType {
            get {
                return (type != NULL && type.contains('date'));     
            }
        }    
    }    
}