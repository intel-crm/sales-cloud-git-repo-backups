public with sharing class Core_MDF_ExternalListViewExport {
    
    public static List<SingleColumn> lstColumn { get; set; }
    public static String strQuery;
    @TestVisible private static integer maxExportRows= Integer.valueOf(Label.Core_MDF_Max_export_limit);   
    /*method: Apex method to fetch wrapper of list views for an object
*input: Object name
*output: List of ListViewWrapper including name, developer name and id of the list views.*/
    
    @AuraEnabled
    public static list<ListViewWrapper> listValues(string objectInfo){
        
        Map<String,List<String>> listViewGroupMap = new Map<String,List<String>>();
        Set<String> allVisisbleListView = new Set<String>();        
        String aud;
        List<String> audList=new List<String>();
        List<String> filteredAudList=new List<String>();        
        List<String> groupSet = new List<String>();        
        List<String> channelProg = new List<String>();
        Map<string,string> channelPartnerToAudienceMapping = new Map<string,string>();
        Map<string,string> channelPartnerToExtGrpMapping = new Map<string,string>();                
        List<Id> allCCPExternalGroupIds = new List<Id>();
        List<Id> contactIds = new List<Id>();                        
        Set<String> listViewSet = new Set<String>();
        list<ListViewWrapper> oListViewWrapper = new list<ListViewWrapper>();
        Id loggedUserId = UserInfo.getUserId();        
        
        try{  
            
            //getting the contact id based on user
            for(User u : [select contactid from User where id =: loggedUserId limit 1]){
                contactIds.add(u.contactid);
            }  
            
            //getting the audience list for contact.
            for(Contact c : [select Core_Audience_List__c from Contact where id =: contactIds[0]]){
                if(c.Core_Audience_List__c != null){
                    aud = c.Core_Audience_List__c.toUpperCase(); }                  
            } 
            if(aud != null){
                audList = aud.split(';');}
            
            //getting the channel prog to ccp external group map
            for(string channelPartnetToExtGrpMap : Label.Core_MDF_Channel_Prog_To_Ext_Group_Map.split(';'))
            {
                List<string> record = channelPartnetToExtGrpMap.split(':');
                channelPartnerToExtGrpMapping.put(record[0],record[1]);         
            }
            
            //getting the channel prog to ccp audience map(ccf:ccf user)
            for(string audienceToChannelProgram : Label.Core_MDF_User_Group_Mapping_Automation_Audience_List.split(';'))
            {
                List<string> record = audienceToChannelProgram.split(':');
                channelPartnerToAudienceMapping.put(record[0],record[1]); 
                if(audList.contains(record[0])){
                    filteredAudList.add(record[0]);
                }                
            }
            system.debug('filteredAudList:'+filteredAudList); 
            
            //geting the immediate group for the user.
            for(GroupMember gm : [SELECT Id, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE UserOrGroupId=: loggedUserId]){
                groupSet.add(gm.Group.DeveloperName);
            }  
            system.debug('groupSet:'+groupSet); 
            
            //getting all the ccp external groups
            Core_MDF_CCPExternalGroups ext = new Core_MDF_CCPExternalGroups();            
            allCCPExternalGroupIds = ext.getExternalGroups();
            
            //getting the group name for the external groups based on id.
            for(Group g : [SELECT DeveloperName FROM Group WHERE ID IN : allCCPExternalGroupIds]){                
                //if immediate group is part of any of the external group, add the parent group from channel prog to ccp external group map
                if(groupSet.contains(g.DeveloperName))
                {  
                    //loop through the audience list and add the parent external group based on program.
                    for(string a :filteredAudList)
                    {
                        system.debug('a outside loop:'+a);
                        if(channelPartnerToAudienceMapping.containsKey(a.toUpperCase()))
                        {
                            system.debug('a:'+a);
                            groupSet.add(channelPartnerToExtGrpMapping.get(channelPartnerToAudienceMapping.get(a.toUpperCase())));                       
                        }
                    }  
                    
                    system.debug('groupSet:'+groupSet); 
                }
                                       
            }              
           
            for(Core_MDF_ListView_Group_Mapping__mdt mdt : [SELECT Core_MDF_Active_ind__c, Core_MDF_Group_Name_txt__c, Core_MDF_SObject_txt__c, Core_MDF_ListView_Name_txt__c,
                                                            Core_MDF_Visible_to_all_users_ind__c FROM Core_MDF_ListView_Group_Mapping__mdt WHERE Core_MDF_SObject_txt__c=:objectInfo AND Core_MDF_Active_ind__c = TRUE
                                                            AND Core_MDF_ListView_Name_txt__c != null and Core_MDF_Whitelisted_Object__c = false]){
                                                                
                                                                if(mdt.Core_MDF_Visible_to_all_users_ind__c == TRUE || (groupSet != null && groupSet.contains(mdt.Core_MDF_Group_Name_txt__c))){
                                                                    listViewSet.add(mdt.Core_MDF_ListView_Name_txt__c); 
                                                                }                                   
                                                            }
            
            for(ListView lv : [SELECT Id, Name, DeveloperName,CreatedById FROM ListView
                               WHERE sObjectType = : objectInfo ORDER By Name ASC]){                              
                                   
                                   if(lv.CreatedById == loggedUserId || listViewSet.contains(lv.DeveloperName)){
                                       ListViewWrapper oWrapper = new ListViewWrapper();
                                       oWrapper.label = lv.Name;
                                       oWrapper.developerName = lv.DeveloperName;
                                       oWrapper.listViewId = lv.Id;
                                       oListViewWrapper.add(oWrapper);                                    
                                   }                                                        
                               }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);}        
        system.debug('ListViewsReturned:'+oListViewWrapper);
        return oListViewWrapper; 
    }
    
    /*method: Apex method to call describe api for selected list view.
*input: Object name and list view filter id
*output: void */
    @AuraEnabled
    public static void listViewFilter(Id filterId, String sObjectName) {
        HttpRequest req = new HttpRequest();
        String endpointUrl = '';  
         try{
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');      
        req.setClientCertificateName(Label.Core_Self_Signed_Cert);  
        //calling describe list view api to get the details for the selected list view.
        
            //SF Fix-Ealisha:start
            List<String> whiteListedObjApiNameList = new List<String>();
            for(Core_MDF_ListView_Group_Mapping__mdt mdt : [SELECT Label, Core_MDF_Active_ind__c, Core_MDF_SObject_txt__c,Core_MDF_Whitelisted_Object__c FROM Core_MDF_ListView_Group_Mapping__mdt WHERE Core_MDF_Whitelisted_Object__c=true and Core_MDF_Active_ind__c=true]){
                                                            whiteListedObjApiNameList.add(mdt.Core_MDF_SObject_txt__c); 
                                                            }
            system.debug('whiteListedObjApiNameList:'+whiteListedObjApiNameList);
            if(whiteListedObjApiNameList.contains(sObjectName) && (string.valueOf(filterId).length() == 15 || string.valueOf(filterId).length() == 18)){
               endpointUrl = Label.Core_MDF_PFRCommunityLink+ Label.Core_MDF_Describe_API_URL4+sObjectName +Label.Core_MDF_Describe_API_URL2 + filterId + Label.Core_MDF_Describe_API_URL3;
            }
            //SF Fix-Ealisha:end     
             
             
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
        
    }
    
    /*method: Apex method to fetch records for a selected list view.
*input: Object name and list view filter id
*output: List<sObject> */
    @AuraEnabled
    public static List<sObject> fetchRecords(Id filterId, String sObjectName){
        //fetching records based on the query.
        System.debug('strQuery before fetch: ' + strQuery);
        if(strQuery == null){
            listViewFilter(filterId,sObjectName);
            System.debug('strQuery after fetch from inside if: ' + strQuery);
        }
        List<sObject> lstRec = new List<sObject>();
        try{
            lstRec = Database.query(strQuery);
            System.debug('Queried Records ' + lstRec);
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);} 
        return lstRec;
        
    }
    
    /*method: Apex method to fetch columns for a selected list view.
*input: Object name and list view filter id
*output: Map<String,String> */
    @AuraEnabled
    public static Map<String,String> fetchKeys(Id filterId, String sObjectName){
        Map<String,String> keysToLabelMap = new Map<String,String>{};
            try{
                listViewFilter(filterId, sObjectName);        
                for(SingleColumn l: lstColumn){
                    keysToLabelMap.put(l.selectListItem,l.label);
                    
                }
                
                system.debug('keys:'+keysToLabelMap);
            }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);} 
        return keysToLabelMap;
    }
    
    /*wrapper class to store listView details*/ 
    public class ListViewWrapper{
        @AuraEnabled public string label{get;set;} 
        @AuraEnabled public string developerName{get;set;}
        @AuraEnabled public string listViewId{get;set;}
        
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
    
    
    public without sharing class Core_MDF_CCPExternalGroups{
        
        public List<Id> getExternalGroups(){
            List<Id> allCCPExternalGroupIds = new List<Id>();
            try{
                for(Core_MDF_Partner_Group_Mapping__c pgm : [select Core_MDF_Group_Id__c from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Type_of_Access__c='External'])
                {
                    allCCPExternalGroupIds.add(pgm.Core_MDF_Group_Id__c);
                }
            }
            catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);} 
            
            return allCCPExternalGroupIds;
        }
        
    }
    
}