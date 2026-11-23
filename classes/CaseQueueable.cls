global class CaseQueueable implements Queueable {
    public List<Case> newCases;
    public Map<Id, Case> oldCaseMap;
    public List<Id> caseIds;
    public CaseQueueable(String newCaseIds){
        this.caseIds = (List<Id>) JSON.deserialize(newCaseIds,List<Id>.class);
     this.newCases = [Select Id,Core_IPS_Assigned_Queue__c,status,Core_IPS_gec_flag__c,Core_IPS_gec_status__c,Core_IPS_New_Backend_System__c,core_IPS_BES_promote_status__c,Core_IPS_HSD_Article_Type__c,Core_CaseType__c,Core_IPS_Product_Org_Number__c,Core_IPS_Ext_Supported_Product__c,Core_Product_Organization__c,CaseNumber, ContactId, AccountId, AssetId, ProductId,Type, RecordTypeId, Reason, Origin
                      FROM Case Where Id In: this.caseIds ];
       
    }
    
  public void execute(QueueableContext context) {
   try {
       for(Case cs : newCases){
           cs.Core_IPS_New_Backend_System__c = null;
       }
    // Core_IPS_BES_CasePromotion_Handler.executeMainRouting(newCases,oldCaseMap,'Case');
    }catch (Exception e){
     }
    }
    /*
    public void execute(QueueableContext context){
        
        Core_CaseTrigger_Dispatcher.rePromotecase = false;
        List<Core_IPS_Backend_Routing__c> backendRoutingMap = new List<Core_IPS_Backend_Routing__c >();
            Map<String,Core_IPS_Backend_Routing__c> routingMap = new Map<String, Core_IPS_Backend_Routing__c>();
            
            backendRoutingMap = [Select Id, Core_IPS_Backend_Routing_Order__c, Core_IPS_Auto_Promote__c, Core_IPS_Deactivated__c, Core_IPS_New_Backend_System__c,Core_IPS_New_Backend_System__r.Name,Core_IPS_New_Backend_System__r.Support_Environment_Detail_Criteria__c, 
                                 Core_IPS_Support_Organization__c,Core_IPS_Supported_Product__r.Name, Core_IPS_Routing_Casetype__c, Core_IPS_Product__c,Environment_Detail_Question__c, Environment_Detail_Question__r.Name, Environment_Detail_Question__r.Core_IPS_Question__c, Environment_Question_Answer__c, Core_IPS_Queue__c, Core_IPS_Supported_Product__c 
                                 From Core_IPS_Backend_Routing__c Where Core_IPS_Deactivated__c=false AND Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c = false ORDER BY Core_IPS_Backend_Routing_Order__c Asc Limit 1000];
            
            Map<Id, List<Core_IPS_Backend_Routing__c>> productToRouteMap = new Map<Id,List<Core_IPS_Backend_Routing__c>>();
            for(Core_IPS_Backend_Routing__c route: backendRoutingMap){
                if(route?.Core_IPS_New_Backend_System__r?.Support_Environment_Detail_Criteria__c  && route?.Core_IPS_Supported_Product__c != null && route?.Environment_Detail_Question__c != null && route?.Environment_Question_Answer__c != '' ){
                    if(productToRouteMap.containsKey(route?.Core_IPS_Supported_Product__c)){
                        List<Core_IPS_Backend_Routing__c> routeRecs = productToRouteMap.get(route?.Core_IPS_Supported_Product__c);
                        routeRecs.add(route);
                        productToRouteMap.put(route?.Core_IPS_Supported_Product__c,routeRecs);
                    }else{
                        List<Core_IPS_Backend_Routing__c> routeRec = new List<Core_IPS_Backend_Routing__c>();
                        routeRec.add(route);
                        productToRouteMap.put(route?.Core_IPS_Supported_Product__c,routeRec); 
                    }
                }
                String key = '';
                key = String.isNotBlank(route.Core_IPS_Queue__c) ? route.Core_IPS_Queue__c : '';
                key = key+  ((route.Core_IPS_Supported_Product__c != null) ?  route.Core_IPS_Supported_Product__r.Name : '');
                key = key+  ((route.Core_IPS_Support_Organization__c != null && route.Core_IPS_Support_Organization__c !='') ?  route.Core_IPS_Support_Organization__c : '');
                key = key+  ((route.Core_IPS_Routing_Casetype__c != null) ?  route.Core_IPS_Routing_Casetype__c : '');
                routingMap.put(key, route);
            }
            
            List<String> keyArray = new List<String>();
            String key1,key2,key3,key4;
            List<String> allPosibleKeys = new List<String>();
            Map<Id,Case> casesMap = new Map<Id,Case>();
            for(Case cs: newCases){
                cs.core_IPS_BES_promote_status__c = '';
                cs.Core_IPS_New_Backend_System__c = null;
                cs.Core_IPS_Backend_ID__c = '';
                cs.Core_IPS_Backend_Rev__c = '';
                key1 = String.isNotBlank(cs.Core_IPS_Assigned_Queue__c) ? cs.Core_IPS_Assigned_Queue__c: '';
                key2 = ((cs.Core_IPS_Ext_Supported_Product__c != null) ? cs.Core_IPS_Ext_Supported_Product__c : '');
                key3 = ((cs.Core_Product_Organization__c != null) ? cs.Core_Product_Organization__c :'');
                key4 = ((cs.Core_CaseType__c != null) ? cs.Core_CaseType__c : '');
                allPosibleKeys = Core_IPS_BES_CasePromotion_Handler.getAllPosibleKeys(key1, key2, key3, key4);
                
                for(String routeKey: routingMap.keySet()){
                    if(allPosibleKeys.contains(routeKey)){
                        Core_IPS_Backend_Routing__c route = routingMap.get(allPosibleKeys.get(allPosibleKeys.indexOf(routeKey)));
                        casesMap.put(cs.Id,  (Core_IPS_BES_CasePromotion_Handler.stampBackendID(route, cs).get(cs.Id)  ));
                        break;
                    } 
                }
                
            }
            update casesMap.values();
    }
        
 public CaseQueueable(String newCasesJson,String oldCaseMapJson) {
System.debug('New Cases: constructor 1');
this.newCases = (List<Case>) JSON.deserialize(newCasesJson, List<Case>.class);
this.oldCaseMap = (Map<Id, Case>) JSON.deserialize(oldCaseMapJson, Map<Id, Case>.class);
System.debug('New Cases: constructor 2');
}*/
        
        public void execute1(QueueableContext context) {
            try {
                for(Case item : newCases){
                    item.Core_IPS_New_Backend_System__c = null;
                    item.Core_IPS_BES_Promote_Status__c = null;
                    item.Core_IPS_Backend_Rev__c = null;
                    item.Core_IPS_BackendID__c = null; 
                }
                Core_IPS_BES_CasePromotion_Handler.executeMainRouting(newCases,oldCaseMap,'Case');
            } 
            catch (Exception e){
                
            }
        }
    }