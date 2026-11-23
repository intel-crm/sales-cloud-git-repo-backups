/*
Apex Class Name:  Core_IPS_BES_CasePromotion_Handler
Version     : 1.0 
Created Date: 23 07 2020
Function    : Handler Class for IPS case Backend Routing. This class defines all the methods
which are used for backend system determination, failed promotes re-processing logic etc.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Farooq Ahmed                         23/07/2020              Initial Version
*/
public with Sharing class Core_IPS_BES_CasePromotion_Handler {
    public static boolean initCheck = true;
    public static void executeBackendRoutingfromCaseTrigger(List<Case> oldList,List<Case> newList, Map<Id,Case> oldMap, Map<Id,Case> newMap){
        try{

            Map<String,String> mapOfBackSFId =  new Map<String,String>();
            
            List<Case> listCase = new List<Case>();
            List<Case> listUpdateCase = new List<Case>();
            Map<id,id> mapIdOfCaseMap = new Map<id,id>();

            // Continue if the user is not data migration or integration user and trigger is enabled.
            if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('enableIPSCaseBackendRouting')){
                for(Case cs : newList){
                    //System.debug('oldMap.get(cs.id).Core_IPS_New_Backend_System__c != null && cs.Core_IPS_New_Backend_System__c == null'+oldMap.get(cs.id).Core_IPS_New_Backend_System__c != null && cs.Core_IPS_New_Backend_System__c == null);
                    if(System.isFuture()){
                        continue;
                    }
                    if(!String.IsBlank(cs.Core_IPS_BackendID__c) && (cs.Core_IPS_BES_Promote_Status__c == null || (!(cs.core_IPS_BES_promote_status__c.equalsignorecase('Done'))))){
                        cs.core_IPS_BES_promote_status__c = 'Done';  
                        continue;
                    }
                   
               /*    else if((oldMap.get(cs.id).Core_IPS_New_Backend_System__c != null && newMap.get(cs.Id).Core_IPS_New_Backend_System__c == null) ||
                          (newMap.get(cs.id).Core_IPS_New_Backend_System__c == null && !String.IsBlank(cs.Core_IPS_BackendID__c)) ||
                          (oldMap.get(cs.id).Core_IPS_BackendID__c != null && newMap.get(cs.Id).Core_IPS_BackendID__c == null) ||  (newMap.get(cs.Id).Core_IPS_BackendID__c != null && oldMap.get(cs.id).Core_IPS_BackendID__c == null ) ||
                           (newMap.get(cs.Id).Core_IPS_New_Backend_System__c == null && (cs.Core_IPS_BES_Promote_Status__c == 'In Progress' || cs.Core_IPS_BES_Promote_Status__c == 'Promote')) ||
                            (newMap.get(cs.Id).Core_IPS_New_Backend_System__c != null && (cs.Core_IPS_BES_Promote_Status__c == 'In Progress' || cs.Core_IPS_BES_Promote_Status__c == 'Promote'))){
                        continue;
                    } */
                                 //System.debug('old version'+oldMap.get(cs.id).Core_Latest_Case_Comment__c);
                   // System.debug('new version'+newMap.get(cs.Id).Core_Latest_Case_Comment__c);
                 	 else if ((oldMap.get(cs.id).Core_IPS_New_Backend_System__c == null && newMap.get(cs.id).Core_IPS_New_Backend_System__c != null && ( cs.Core_IPS_BES_Promote_Status__c == 'Not Yet Promoted' || cs.Core_IPS_BES_Promote_Status__c == 'In Progress' || cs.Core_IPS_BES_Promote_Status__c == 'Promote')) ||
                             (oldMap.get(cs.id).Core_IPS_New_Backend_System__c == null && newMap.get(cs.id).Core_IPS_New_Backend_System__c != null && cs.Core_IPS_BES_Promote_Status__c == 'Done'	&& !String.IsBlank(cs.Core_IPS_BackendID__c)) ||
                             (oldMap.get(cs.id).Core_IPS_New_Backend_System__c != null && oldMap.get(cs.id).Core_IPS_BackendID__c == null  && newMap.get(cs.id).Core_IPS_New_Backend_System__c != null && cs.Core_IPS_BES_Promote_Status__c == 'Not Yet Promoted') ||
                             (oldMap.get(cs.id).Core_IPS_New_Backend_System__c != null && oldMap.get(cs.id).Core_IPS_BackendID__c != newMap.get(cs.id).Core_IPS_BackendID__c && newMap.get(cs.id).Core_IPS_New_Backend_System__c != null 	&& cs.Core_IPS_BES_Promote_Status__c == 'Done'	&& !String.IsBlank(cs.Core_IPS_BackendID__c))){
                        Continue;
                    }  
                    ListCase.add(cs);
                    
                   
                }
             if(initcheck && ListCase.size()>0) {  
                executeMainRouting(ListCase, oldMap, 'Case'); 
             }
            }}catch(Exception e){
                Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)newMap.keySet(),','));
            }
    }
    //************************************************************************************//
    // This method filters out cases which does not satisfy the below condition
    // The case should not be in closed status, it should not be GEC flagged and if GEC flagged, it should be approved.
    // Backend system and Backend ID should be blank, if backend system is assigned already, 
    // backend id should be blank and also the promote status should not "In progress" or "Failed". 
    // These cases should only be reprocesed using reprocessing mechanism.
    //************************************************************************************// 
    public static void executeMainRouting(List<case> caseList, Map<Id, Case> oldMap, String objectType)
    {
         Map<Id, Case> csMapUpdate = new Map<Id, Case>();
        List<case> listCase = new List<case>();
        /*Set<string> articleTypeSupportOrg = new Set<String>();        
        articleTypeSupportOrg.addAll(Label.Core_IPS_ArticleType_SupportOrg.split(','));*/
        try
        {
            for(Case cs : caseList){    
                System.debug('cs.Core_IPS_Assigned_Queue__c inside main routing:' + cs.Core_IPS_Assigned_Queue__c);
                if(cs.status == null || !(cs.status.equalsignorecase('Closed'))){
                    if(cs.Core_IPS_gec_flag__c == null || cs.Core_IPS_gec_flag__c == false || ( cs.Core_IPS_gec_flag__c ==  true && (cs.Core_IPS_gec_status__c != null  && cs.Core_IPS_gec_status__C.contains('Approved')))){
                        if((oldMap.get(cs.Id).Core_IPS_New_Backend_System__c == Null && (cs.core_IPS_BES_promote_status__c ==  Null || !(cs.core_IPS_BES_promote_status__c.equalsignorecase('Done') || cs.core_IPS_BES_promote_status__c.equalsignorecase('Sent Successfully'))))){
                            ListCase.add(cs);    
                        }  
                    }
                }
                if(cs.core_IPS_BES_promote_status__c !=null && (cs.core_IPS_BES_promote_status__c.equalsignorecase('Promote'))) {
                    cs.core_IPS_BES_promote_status__c = 'In Progress';
                    if(objectType != null && objectType != 'Case'){ 
                        csMapUpdate.put(cs.id, cs);   
                    } 
                }
                //Added by Pavani to populated the Core_IPS_HSD_Article_Type__c field value with Case Type value for org 006 cases in the update scenario - 20/05/2024
                /*if(cs.Core_CaseType__c!=null && oldMap.get(cs.Id).Core_IPS_Product_Org_Number__c != cs.Core_IPS_Product_Org_Number__c && articleTypeSupportOrg.contains(cs.Core_IPS_Product_Org_Number__c)){
                    cs.Core_IPS_HSD_Article_Type__c	 = cs.Core_CaseType__c;
                }*/
                System.debug('cs.OwnerId after setting to inProgrss and before update: '+ cs.OwnerId);
                //End - 20/05/2024
            }
             if(csMapUpdate!= null && csMapUpdate.size()>0){
                update csMapUpdate.values(); 
                
            }
            if(ListCase.size()>0){
                Core_IPS_BES_CasePromotion_Handler.getBackendID(ListCase, oldMap, objectType); 
              
            }  
            else{
               
            } 
        } catch(Exception e){  
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)oldMap.keySet(),','));
        }     
    }
    //************************************************************************************//
    // This is main method processes the main backend routing
    //************************************************************************************//
    public static void getBackendID(List<case> listCase, Map<Id, Case> oldMap, String objectType){
        Map<Id, Case> csMapUpdate = new Map<Id, Case>();
        Map<Id,List<Case>> spIDCaseListMap;
        List<Case> csList = new List<Case>();
        List<Case> caseList = new List<case>();
        Set<ID> backendSystemIDs = new Set<ID>();
        Set<ID> caseSubCatIds = new Set<ID>();
        List<Case> caseListWithReponseRecs = new List<case>();
        ID  supProdID;
        Map<Id, List<Core_IPS_Backend_Supported_Product_Map__c>> csBKSuppProdMap;
        List<Core_IPS_Backend_Routing__c> mapsupptBackend = new List<Core_IPS_Backend_Routing__c >();
        Map<String,List<Case>> queueCaseListMap;
        Map<Id,ID> caseIDSpIDMap = new MAP<Id, ID>();   
        try{      
            for(Case cs: ListCase){
                System.debug('cs.Core_IPS_Assigned_Queue__c inside getBackendId:' + cs.Core_IPS_Assigned_Queue__c);
                if(cs.id==null){
                    continue; 
                } 
                if(cs.Core_IPS_New_Backend_System__c != null && (cs.core_IPS_BES_promote_status__c.equalsignorecase('Failed') || cs.core_IPS_BES_promote_status__c.equalsignorecase('Not Yet Promoted') || cs.core_IPS_BES_promote_status__c.equalsignorecase('Done'))){
                   
                    if(objectType != null && objectType != 'Case'){ 
                        csMapUpdate.put(cs.id, cs);   
                    }
                    continue;
                }
                   csList.add(cs); 
            }
            if(csMapUpdate!= null && csMapUpdate.size()>0){
                update csMapUpdate.values(); 
                
            }
            if(csList <> null && csList.size() > 0){
                Map<String,Core_IPS_Backend_Routing__c> routingMap = new Map<String, Core_IPS_Backend_Routing__c>();
                String key =''; 
                Map<Id, List<Core_IPS_Response__c>> caseIdToResponsesMap = new Map<Id, List<Core_IPS_Response__c>>();
                
                if(case.SObjectType.getDescribe().isAccessible()){
		      //  Added by Chiru - 20-08-24 - APEX GURU - SOQL FIX
                    Map<Id, Case> csListMap = new Map<Id, Case>(csList);
                    caseListWithReponseRecs =  [SELECT Id,  
                                                       (SELECT Id,  Name,  Core_IPS_Case__c, Core_IPS_Answer_Master__c, Core_IPS_Answer__c,  Core_IPS_Question_Master__c, Core_IPS_Question_Master__r.Name,  Core_IPS_Question__c 
                                                        FROM Core_IPS_Responses__r) 
                                                       FROM Case
                                                       WHERE Id in :csListMap.keyset()];
                }
               
           
           
                           for (Case caseRecord : caseListWithReponseRecs) {
                    
            
            
            
                                caseIdToResponsesMap.put(caseRecord?.Id, caseRecord?.Core_IPS_Responses__r);
                }
                if(Core_IPS_Backend_Routing__c.SObjectType.getDescribe().isQueryable()){
                    mapsupptBackend = [Select Id, Core_IPS_Backend_Routing_Order__c, Core_IPS_Auto_Promote__c, Core_IPS_Deactivated__c, Core_IPS_New_Backend_System__c,Core_IPS_New_Backend_System__r.Name,Core_IPS_New_Backend_System__r.Support_Environment_Detail_Criteria__c, 
                                       Core_IPS_Support_Organization__c,Core_IPS_Supported_Product__r.Name, Core_IPS_Routing_Casetype__c, Core_IPS_Product__c,Environment_Detail_Question__c, Environment_Detail_Question__r.Name, Environment_Detail_Question__r.Core_IPS_Question__c, Environment_Question_Answer__c, Core_IPS_Queue__c, Core_IPS_Supported_Product__c 
                                       From Core_IPS_Backend_Routing__c Where Core_IPS_Deactivated__c=false AND Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c = false ORDER BY Core_IPS_Backend_Routing_Order__c Asc Limit 1000];
                    
                    Map<Id, List<Core_IPS_Backend_Routing__c>> suppProdToRoutMap = new Map<Id,List<Core_IPS_Backend_Routing__c>>();
                    for(Core_IPS_Backend_Routing__c route: mapsupptBackend){
                        if(route?.Core_IPS_New_Backend_System__r?.Support_Environment_Detail_Criteria__c  && route?.Core_IPS_Supported_Product__c != null && route?.Environment_Detail_Question__c != null && route?.Environment_Question_Answer__c != '' ){
                            if(suppProdToRoutMap.containsKey(route?.Core_IPS_Supported_Product__c)){
                                List<Core_IPS_Backend_Routing__c> routeRecs = suppProdToRoutMap.get(route?.Core_IPS_Supported_Product__c);
                                routeRecs.add(route);
                                suppProdToRoutMap.put(route?.Core_IPS_Supported_Product__c,routeRecs);
                            }else{
                               List<Core_IPS_Backend_Routing__c> routeRec = new List<Core_IPS_Backend_Routing__c>();
                                routeRec.add(route);
                               suppProdToRoutMap.put(route?.Core_IPS_Supported_Product__c,routeRec); 
                            }
                        }
                        
            
            
            
             key = '';
                        key = String.isNotBlank(route.Core_IPS_Queue__c) ? route.Core_IPS_Queue__c : '';
                        key = key+  ((route.Core_IPS_Supported_Product__c != null) ?  route.Core_IPS_Supported_Product__r.Name : '');
                        key = key+  ((route.Core_IPS_Support_Organization__c != null && route.Core_IPS_Support_Organization__c !='') ?  route.Core_IPS_Support_Organization__c : '');
                        key = key+  ((route.Core_IPS_Routing_Casetype__c != null) ?  route.Core_IPS_Routing_Casetype__c : '');
                        routingMap.put(key, route);
                    }
 
                    
                    List<String> keyArray = new List<String>();
                    String key1,key2,key3,key4;
                    List<String> allPosibleKeys = new List<String>();
                    for(Case cs : csList){
                     
             //          if(cs.Core_IPS_Assigned_Queue__c != null ){
             //          Modified key1 by chetan for CCG related issue.
             	            key1 = String.isNotBlank(cs.Core_IPS_Assigned_Queue__c) ? cs.Core_IPS_Assigned_Queue__c : (String.valueOf(cs.OwnerId).startsWith('OOG') ? cs.OwnerId : '');
                            //key1 = String.isNotBlank(cs.Core_IPS_Assigned_Queue__c) ? cs.Core_IPS_Assigned_Queue__c: '';
                            key2 = ((cs.Core_IPS_Ext_Supported_Product__c != null) ? cs.Core_IPS_Ext_Supported_Product__c : '');
                            key3 = ((cs.Core_Product_Organization__c != null) ? cs.Core_Product_Organization__c :'');
                            key4 = ((cs.Core_CaseType__c != null) ? cs.Core_CaseType__c : '');
                           
                            allPosibleKeys = getAllPosibleKeys(key1, key2, key3, key4);
            //            }
                        for(String routeKey: routingMap.keySet()){
                            if(allPosibleKeys.contains(routeKey)){
                                Core_IPS_Backend_Routing__c route = routingMap.get(allPosibleKeys.get(allPosibleKeys.indexOf(routeKey)));
                                //EDQ Criteria Logic - Start
                                if(route?.Core_IPS_New_Backend_System__r?.Support_Environment_Detail_Criteria__c && route?.Core_IPS_Supported_Product__c != null ){
                                                                      
                                      
                                      
                                      
                                      
                                      
                                    Boolean isEDQFilterMatchfound = checkEDQFilterCriteria(route,  caseIdToResponsesMap.get(cs.Id), suppProdToRoutMap);
                                    if(!isEDQFilterMatchfound)
                                        break;
                                } 
                                //EDQ Ceriteria logic Ends
                                /*System.debug('Chiru RePromote before Stamp calling current bk :'+ cs.Core_IPS_New_Backend_System__c);
                                System.debug('Chiru RePromote before Stamp calling old Map :'+ oldMap.get(cs.id).Core_IPS_New_Backend_System__c);
                                System.debug('Chiru RePromote before Stamp calling route ' +route.Core_IPS_New_Backend_System__c);
                                if(oldMap == null || ( oldMap != null && route.Core_IPS_New_Backend_System__c != oldMap.get(cs.Id).Core_IPS_New_Backend_System__c) )// added by chiru
                                    system.debug('Chiru Inside Block');*/
                                stampBackendID(route, cs);
                                break;
                            } 
                        }
                    }
                }
            }  
        }catch(Exception e) {  
          Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)oldMap.keySet(),','));
            
        }
    }
    public static List<String> getAllPosibleKeys(String key1, String key2, String key3, String key4){
        List<String> allPosibleKeys = new List<String>();
        allPosibleKeys.add(key1+key2+key3+key4);
        allPosibleKeys.add(key1+key2+key3);
        allPosibleKeys.add(key1+key3+key4);
        allPosibleKeys.add(key1+key2+key4);
        allPosibleKeys.add(key2+key3+key4); 
        allPosibleKeys.add(key1+key2);
        allPosibleKeys.add(key1+key3);
        allPosibleKeys.add(key1+key4);
        allPosibleKeys.add(key2+key3);
        allPosibleKeys.add(key2+key4);
        allPosibleKeys.add(key3+key4);
        allPosibleKeys.add(key1);
        allPosibleKeys.add(key2);
        allPosibleKeys.add(key3);
        allPosibleKeys.add(key4);
        return allPosibleKeys;
    }
    public static Map<Id, Case> stampBackendID(Core_IPS_Backend_Routing__c route, Case cs)
    {    
        System.debug('cs.Core_IPS_Assigned_Queue__c inside stampBackendId:' + cs.Core_IPS_Assigned_Queue__c);
        Map<ID, Case> csMap = new Map<ID, Case>();
        
        try {
            if(route.Core_IPS_New_Backend_System__c != null){
                cs.Core_IPS_New_Backend_System__c = route.Core_IPS_New_Backend_System__c;
                if(route.Core_IPS_Auto_Promote__c == true){
                    cs.core_IPS_BES_promote_status__c='In Progress';
                }else{
                    cs.core_IPS_BES_promote_status__c ='Not Yet Promoted';
                }
                csMap.put(cs.id, cs); 
            }
            else{  
              
            }
        } catch(Exception e) { 
              
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, (String) cs.Id);
            
        } 
        return csMap;
    }
   
    //EDQ Criteria logic processing
    public static Boolean checkEDQFilterCriteria(Core_IPS_Backend_Routing__c route, List<Core_IPS_Response__c> CaseEnvDetResponse, Map<Id, List<Core_IPS_Backend_Routing__c>> suppProdToRoutMap){
        
        Boolean isMatchFound = false;
        Map<String,String> questionToAnsMap = new Map<String,String>();
        for(Core_IPS_Response__c resRec: CaseEnvDetResponse){
            questionToAnsMap.put(resRec?.Core_IPS_Question_Master__r?.Name,resRec?.Core_IPS_Answer__c.toLowercase());     
        }
        
        for(Core_IPS_Backend_Routing__c bR: suppProdToRoutMap.get(route?.Core_IPS_Supported_Product__c)){
            
        
                    if(questionToAnsMap.containsKey(bR?.Environment_Detail_Question__r?.Name) && bR?.Environment_Question_Answer__c?.toLowercase().contains(questionToAnsMap.get(bR?.Environment_Detail_Question__r?.Name))) {
                
        isMatchFound = true;
            }  
            else{
                isMatchFound = false;
                break;
            }         
        }
        return isMatchFound;
    }
    
}