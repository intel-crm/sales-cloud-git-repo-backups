/****************************************************************************************************************************************
* Class Name  : Core_MDF_ExternalListViewExport 
* Version     : 
* Created Date: 
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Sneha R         9/9/2020                   Updated class to remove usage of audience list and added custom permission check
*****************************************************************************************************************************************/
public with sharing class Core_MDF_ExternalListViewExport {
    
    public static List<SingleColumn> lstColumn { get; set; }
    public static String strQuery;
    public static boolean isVaildSObject; 
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
        List<String> groupSet = new List<String>();        
        List<String> channelProg = new List<String>();
        Map<string,string> channelProgToCustomPermissionMap = new Map<string,string>();
        Map<string,string> channelPartnerToExtGrpMapping = new Map<string,string>();                
        List<Id> allCCPExternalGroupIds = new List<Id>();
        List<Id> contactIds = new List<Id>();                        
        Set<String> listViewSet = new Set<String>();
        list<ListViewWrapper> oListViewWrapper = new list<ListViewWrapper>();
        Id loggedUserId = UserInfo.getUserId();        
        
        try{
            //getting the channel prog to ccp external group map
            //Client Co-Marketing Fund:Core_MDF_CCP_CCF_EXTERNAL_ALL;
            
            for(string channelPartnetToExtGrpMap : Label.Core_MDF_Channel_Prog_To_Ext_Group_Map.split(';'))
            {
                List<string> record = channelPartnetToExtGrpMap.split(':');
                channelPartnerToExtGrpMapping.put(record[0],record[1]);         
            }
            //getting the channel prog to ccp audience map(ccf:ccf user)
            //Core_MDF_CCF_USER:Client Co-Marketing Fund
            for(string channelProToCP : Label.Core_MDF_CustomPermission_ChannelProgram_List.split(';'))
            {
                List<string> record = channelProToCP.split(':');
                if(FeatureManagement.checkPermission(record[0])){
                    String channelProgram = record[0].toUpperCase();                    
                    channelProgToCustomPermissionMap.put(channelProgram,record[1]);
                }  
            }
                       
            //geting the immediate group for the user.
            for(GroupMember gm : [SELECT Id, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE UserOrGroupId=: loggedUserId]){
                groupSet.add(gm.Group.DeveloperName);
            }  

            //getting all the ccp external groups
            Core_MDF_CCPExternalGroups ext = new Core_MDF_CCPExternalGroups();            
            allCCPExternalGroupIds = ext.getExternalGroups();
            
            //getting the group name for the external groups based on id.
            for(Group g : [SELECT DeveloperName FROM Group WHERE ID IN : allCCPExternalGroupIds]){                
                //if immediate group is part of any of the external group, add the parent group from channel prog to ccp external group map
                if(groupSet.contains(g.DeveloperName))
                {
                    //loop through the applicable Channel Program list and add the parent external group based on program.
                    if(channelProgToCustomPermissionMap != NULL && !channelProgToCustomPermissionMap.isEmpty()){
                        for(String program : channelProgToCustomPermissionMap.keySet()){
                            if(channelPartnerToExtGrpMapping != null && !channelPartnerToExtGrpMapping.isEmpty()){
                                groupSet.add(channelPartnerToExtGrpMapping.get(channelProgToCustomPermissionMap.get(program.toUpperCase())));                       
                            }
                        }
                    }  
                }
            }              
            
            // for(Core_MDF_List_View_Group_Mapping__c mdt : [SELECT Core_MDF_Active_ind__c, Core_MDF_Group_Name_txt__c, Core_MDF_SObject_txt__c,  Core_MDF_ListView_Name_txt__c,
            //                                                 Core_MDF_Visible_to_all_users_ind__c FROM Core_MDF_List_View_Group_Mapping__c WHERE Core_MDF_SObject_txt__c=:objectInfo AND Core_MDF_Active_ind__c = TRUE
            //                                                 AND Core_MDF_ListView_Name_txt__c != null and Core_MDF_Whitelisted_Object__c = false]){
                                                                
            //                                                     if(mdt.Core_MDF_Visible_to_all_users_ind__c == TRUE || (groupSet != null && groupSet.contains(mdt.Core_MDF_Group_Name_txt__c))){
            //                                                         listViewSet.add(mdt.Core_MDF_ListView_Name_txt__c); 
            //                                                     }                                   
            //                                                 }
            //updated the code for the change of Custom Metadata to Custom Settings - Akanksha                                                
            for(Core_MDF_List_View_Group_Mapping__c itrOnListViewMapping : Core_MDF_List_View_Group_Mapping__c.getall().values()){
                if(itrOnListViewMapping.Core_MDF_SObject_txt__c == objectInfo && itrOnListViewMapping.Core_MDF_Active_ind__c && itrOnListViewMapping.Core_MDF_ListView_Name_txt__c != null && !itrOnListViewMapping.Core_MDF_Whitelisted_Object__c && 
                    (itrOnListViewMapping.Core_MDF_Visible_to_all_users_ind__c || (groupSet != null && groupSet.contains(itrOnListViewMapping.Core_MDF_Group_Name_txt__c)))){
                        listViewSet.add(itrOnListViewMapping.Core_MDF_ListView_Name_txt__c); 
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
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);
        }        
        return oListViewWrapper; 
    }
    
    /*method: Apex method to call describe api for selected list view.
    *input: Object name and list view filter id
    *output: void */
    @AuraEnabled
    public static void listViewFilter(Id filterId, String sObjectName) {
        HttpRequest req = new HttpRequest();
        String endpointUrl = '';  
        String sanitizedSobjectName = string.escapeSingleQuotes(sObjectName);
        try{
            //check if the objname is a valid sobject.
            for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values() ) {
                 String sobjName = String.valueOf(sObjectType);
                 if (sobjName.contains(sanitizedSobjectName) ) {
                    isVaildSObject = true;
                    break;
                 }
                
            }
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');      
            req.setClientCertificateName(Label.Core_Self_Signed_Cert);  
            //calling describe list view api to get the details for the selected list view.
            
            //SF Fix-Ealisha:start
            List<String> whiteListedObjApiNameList = new List<String>();
            // for(Core_MDF_List_View_Group_Mapping__c mdt : [SELECT Core_MDF_Label_txt__c, Core_MDF_Active_ind__c, Core_MDF_SObject_txt__c,Core_MDF_Whitelisted_Object__c FROM Core_MDF_List_View_Group_Mapping__c WHERE Core_MDF_Whitelisted_Object__c=true and Core_MDF_Active_ind__c=true]){
            //     whiteListedObjApiNameList.add(mdt.Core_MDF_SObject_txt__c); 
            // }
            //updated the code for the change of Custom Metadata to Custom Settings - Akanksha (WW-32 2024)
            for(Core_MDF_List_View_Group_Mapping__c itrOnListViewMapping : Core_MDF_List_View_Group_Mapping__c.getall().values()){
                	
                if(itrOnListViewMapping.Core_MDF_Whitelisted_Object__c && itrOnListViewMapping.Core_MDF_Active_ind__c){
                    whiteListedObjApiNameList.add(itrOnListViewMapping.Core_MDF_SObject_txt__c); 
                }
            }
     
            Integer test = string.valueOf(filterId).length();
          
            if((isVaildSObject && whiteListedObjApiNameList.contains(sanitizedSobjectName)) && (string.valueOf(filterId).length() == 15 || string.valueOf(filterId).length() == 18)){
                endpointUrl = Label.Core_MDF_PFRCommunityLink+ Label.Core_MDF_Describe_API_URL4+sanitizedSobjectName +Label.Core_MDF_Describe_API_URL2 + filterId + Label.Core_MDF_Describe_API_URL3;
             
            }
            //SF Fix-Ealisha:end     
            System.debug('endpointUrl'+endpointUrl);
            //ATHR - Deeply Nested if 16209
            if(endpointUrl == ''){
                return;
            }
            //if(endpointUrl != ''){   
               
                req.setEndpoint(endpointUrl);
                req.setMethod('GET');      
                Http h = new Http();
                HttpResponse res = h.send(req);
                Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());     
                //get the query string from the response
                strQuery = (String)root.get('query') + string.escapeSingleQuotes(' LIMIT ') + (maxExportRows+ 1);  
                lstColumn = new List<SingleColumn>();
                
                //Parsing JSON string to get the column details    
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null){ 
                    if (parser.getCurrentToken() != JSONToken.START_ARRAY) continue; //ATHR - Deeply Nested if 16209
                    //if(parser.getCurrentToken() == JSONToken.START_ARRAY) {       
                        while (parser.nextToken() != null) {
                            if (parser.getCurrentToken() != JSONToken.START_OBJECT) continue; //ATHR - Deeply Nested if 16209
                            //if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                                
                                SingleColumn col = (SingleColumn)parser.readValueAs(SingleColumn.class);
                                if (col == null || col.hidden == null || col.hidden == true || col.label == null || col.fieldNameOrPath == null || col.fieldNameOrPath.contains('Clone')) continue; //ATHR - Deeply Nested if 16209
                                //if(col.hidden == false && col.fieldNameOrPath != NULL && !col.fieldNameOrPath.contains('Clone')) {            
                                    
                                    col.label = col.label.replace(',', '');                            
                                    lstColumn.add(col);   
                                   
                                //}    
                            //}
                        }
                    //}
                }
            //}
        }
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            //throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);
        }  
        
    }
    
    /*method: Apex method to fetch records for a selected list view.
     *input: Object name and list view filter id
     *output: List<sObject> */
    @AuraEnabled
    public static List<sObject> fetchRecords(Id filterId, String sObjectName){
        //fetching records based on the query.
        if(strQuery == null){
            listViewFilter(filterId,sObjectName);
        }
        List<sObject> lstRec = new List<sObject>();
        try{
            lstRec = Database.query(strQuery);

            /*for(Sobject obj : lstRec){
                for(SingleColumn col : lstColumn){
                    if(col.type == 'date'){
                        Date d = (Date) obj.get(col.selectListItem);
                        obj.put(col.selectListItem, d.format());
                    }else if(col.type == 'datetime'){
                        Datetime dt = (Datetime) obj.get(col.selectListItem);
                        obj.put(col.selectListItem, dt.format());
                    }
                }
            }*/
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);} 
        return lstRec;
        
    }
    
    /*method: Apex method to fetch columns for a selected list view.
     *input: Object name and list view filter id
     *output: Map<String,SingleColumn> */
    @AuraEnabled
    public static Map<String,SingleColumn> fetchKeys(Id filterId, String sObjectName){
        Map<String,SingleColumn> keysToLabelMap = new Map<String,SingleColumn>{};
            //try{
                listViewFilter(filterId, sObjectName);        
                for(SingleColumn fieldInfo: lstColumn){
                    keysToLabelMap.put(fieldInfo.selectListItem,fieldInfo);
                    
                }
            /*}
        catch(Exception e){
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);
        } */
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
                for(Core_MDF_Partner_Group_Mapping__c pgm : [select Core_MDF_Group_Id__c from Core_MDF_Partner_Group_Mapping__c where Core_MDF_Type_of_Access__c='External' and Core_MDF_Inactive_Ind__c = false])
                {
                    allCCPExternalGroupIds.add(pgm.Core_MDF_Group_Id__c);
                }
            }
            catch(Exception e){
                Core_MDF_CCP_UtilityClass.logError(e);
                throw new AuraHandledException(''+Label.Core_MDF_ApplicationErrorMessage);
            } 
            
            return allCCPExternalGroupIds;
        }        
    }  
}