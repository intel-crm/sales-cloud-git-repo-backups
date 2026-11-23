public with sharing class Core_IPS_BES_UpdateCase_AJ {
    public class CustomException extends Exception {}
    // 1.6MB --> 6.6MB
    public static void updateCase(List<String> caseString, Map<String, String> userDetailsMap) {  // 1 case : list, 1 case 
        Map<String,String> fieldMap = new Map<String, String>();
        Boolean isBatchExecute = false;
        System.debug('Heap Size chiru Entry '+ Limits.getHeapSize()); // 1.6MB
        Map<String, List<IssueInformationWrapper>> IssueInfoDetails = new Map<String, List<IssueInformationWrapper>>();
        Map<String,String> revisionMap = new Map<String,String>();
        Map<String,String> sourceDetailsMap = new Map<String,String>();
        
        Set<String> fldsToQuery = new Set<String>();
        Set<String> caseNumbers = new Set<String>();
        String sObjectFields = '';
        
        try {
            if(IPS_Case_Fields__c.SObjectType.getDescribe().isQueryable()){
                //  List<IPS_Case_Fields__c> allCustomSettings =[Select id, Object_Name__c, API_Name__c, JSON_Field_Name__c,Order__c,Additional_Info__c from IPS_Case_Fields__c order by Order__c DESC ];
                for(IPS_Case_Fields__c  cc : [Select id, Object_Name__c, API_Name__c, JSON_Field_Name__c,Order__c,Additional_Info__c from IPS_Case_Fields__c order by Order__c DESC ]) {
                    if(cc.Object_Name__c == 'Case') {
                        fieldMap.put(cc.JSON_Field_Name__c, cc.API_Name__c);
                    }
                }
            }
            
            System.debug('heap size Core_IPS_BES_UpdateCase 26 : '+Limits.getHeapSize()); // *** V2_7.39MB
            Map<String,String> APIJSONKeyMap = new  Map<String,String>();
            
            
            for (String jsonString : caseString) {
                Map<String, Object> inboundDetailsMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);    
                Map<String, Object> issueInformationMap = (Map<String, Object>)inboundDetailsMap.get('issue_information');
                caseNumbers.add((String)((Map<String, Object>)inboundDetailsMap.get('system_details')).get('target_id'));
                for(String caseField : issueInformationMap.keySet()){ 
                    if(fieldMap.get(caseField) !=null &&   ( issueInformationMap.get(caseField)!='' ||  caseField.equalsIgnoreCase('hsd_mirror_reason') || caseField.equalsIgnoreCase('case_closure')) ){
                        APIJSONKeyMap.put(fieldMap.get(caseField),caseField);
                        fldsToQuery.add(fieldMap.get(caseField));
                    }
                }
            }
            
            sObjectFields = String.join(new List<String>(fldsToQuery),',');
            List<Case> caseObjList = new List<case>();
            list<Case> casesToUpdate = new list<Case>();
            
            if(!String.isBlank(sObjectFields)){
                String soqlQueryEnv = 'SELECT '+ sObjectFields +',Core_IPS_Date_Time_Close_Pending__c,Core_IPS_New_Backend_System__c,Core_IPS_New_Backend_System__r.Name,Core_IPS_BackendID__c,Core_IPS_BES_Promote_Status__c,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,CaseNumber FROM case WHERE CaseNumber IN:caseNumbers';
                caseObjList = Database.Query(soqlQueryEnv);
            }
            System.debug('heap size Core_IPS_BES_UpdateCase 43 : '+Limits.getHeapSize());
            Schema.DescribeSObjectResult objectDescribe = caseObjList.getSObjectType().getDescribe();
            Map<String, Schema.SObjectField> fields = objectDescribe.fields.getMap();
            String status, reason ;
            Boolean isSameValue = false;
            
            
            for(Integer i=0;i<caseString.Size();i++){ // 3 times
                Map<String, Object> inboundDetailsMap = (Map<String, Object>)JSON.deserializeUntyped(caseString[i]);
                Map<String, Object> issueInformationMap = (Map<String, Object>)inboundDetailsMap.get('issue_information');
                Map<String, Object> systemDetailsMap = (Map<String, Object>)inboundDetailsMap.get('system_details');
                Case caseObj = new Case();
                status = null; reason = null;
                isSameValue = false; 
                /********* New Change as Part of Heapsize Optimization **********/
                IssueInformationWrapper issueInfoWrapper = new IssueInformationWrapper();
                issueInfoWrapper.owner_info = (String)issueInformationMap.get('owner_info');
                issueInfoWrapper.hsd_mirror_status = (String)issueInformationMap.get('hsd_mirror_status');
                issueInfoWrapper.hsd_mirror_reason = (String)issueInformationMap.get('hsd_mirror_reason');
                issueInfoWrapper.comment_text = (String)issueInformationMap.get('comment_text');
                issueInfoWrapper.comment_author = (String)issueInformationMap.get('comment_author');
                
                if (!IssueInfoDetails.containsKey((String)systemDetailsMap.get('target_id' ))) {
                    // isBatchExecute = false; // Executing
                    IssueInfoDetails.put((String)systemDetailsMap.get('target_id' ), new List<IssueInformationWrapper>{issueInfoWrapper});
                } else {
                    IssueInfoDetails.get((String)systemDetailsMap.get('target_id' )).add(issueInfoWrapper);
                    isBatchExecute = true; // Executing
                    system.debug('Debugg17 -- '+isBatchExecute);
                }
                if(systemDetailsMap != null && systemDetailsMap.get('target_id' )!= null && systemDetailsMap.get('backend_rev' )!= null){
                    String targetId = (String)systemDetailsMap.get('target_id' );
                    String backendRev = (String)systemDetailsMap.get('backend_rev' );
                    
                    String revisionValue = revisionMap != null ? revisionMap.get(targetId) : null;
                    
                    if (revisionValue != null && Integer.valueOf(revisionValue) < Integer.valueOf(backendRev)) {
                        revisionMap.put(targetId, backendRev);
                    } else if (revisionValue == null) {
                        revisionMap.put(targetId, backendRev);
                    }
                }
                sourceDetailsMap.put((String)systemDetailsMap.get('target_id' ),(String)systemDetailsMap.get('source_id' ));
                
                /********* New Change as Part of Heapsize Optimization **********/
                System.debug('heap size Core_IPS_BES_UpdateCase 78 : '+Limits.getHeapSize());
                for(Integer j=0;j<caseObjList.size();j++){
                    if(caseObjList[j].caseNumber == systemDetailsMap.get('target_id')){
                        caseObj.Id = caseObjList[j].id;
                        
                        for(String JSONfield: fldsToQuery){
                            String fieldAPI = APIJSONKeyMap.get(JSONfield);
                            if(!issueInformationMap.containsKey(fieldAPI)){
                                Continue;
                            }
                            if(String.ValueOf(caseObjList[j].get('HSD_Mirror_Status__c')) != String.valueOf(issueInformationMap.get('HSD_Mirror_Status__c')) || String.ValueOf(caseObjList[j].get('HSD_Mirror_Reason__c')) != String.valueOf(issueInformationMap.get('HSD_Mirror_Reason__c'))){
                                isSameValue = false;  
                            } else {
                                isSameValue = true;     
                            }
                            
                            Schema.SObjectField field = fields.get(JSONfield);
                            String fieldType = schemaDisplayTypeMapping(field);
                            
                            switch on fieldType{
                                when 'String'{ 
                                    if(fieldAPI == 'Core_Issue_Description__c'){
                                        caseObj.put(JSONfield,  String.valueOf(issueInformationMap.get(fieldAPI)).replaceAll('jpg','jpeg'));
                                    }
                                    else{
                                        if(String.isNotBlank(String.valueOf(issueInformationMap.get(fieldAPI))))
                                            caseObj.put(JSONfield,  String.valueOf(issueInformationMap.get(fieldAPI)));
                                    }
                                    if(JSONfield == 'HSD_Mirror_Status__c'){
                                        status = String.valueOf(issueInformationMap.get(fieldAPI));
                                    }
                                    if(JSONfield == 'HSD_Mirror_Reason__c'){
                                        reason = String.valueOf(issueInformationMap.get(fieldAPI));
                                        caseObj.put(JSONfield,  reason);
                                    }
                                }
                                when 'Boolean'{
                                    caseObj.put(JSONfield,  Boolean.valueOf(issueInformationMap.get(fieldAPI)));
                                }
                                when 'Integer'{
                                    caseObj.put(JSONfield,  Integer.valueOf(issueInformationMap.get(fieldAPI)));
                                }
                                when 'Double'{
                                    caseObj.put(JSONfield,  Double.valueOf(issueInformationMap.get(fieldAPI)));
                                }
                            }
                        }
                        
                        if((String.isNotBlank(status) || String.isNotBlank(reason)) && isSameValue == false ){
                            Map<String,String> statusSubStatusValue = Core_IPS_BES_CCG_CustomLogic.processStatusReasonLogic(status,reason,String.ValueOf(caseObjList[j].getsObject('Core_IPS_New_Backend_System__r').get('Name')),String.ValueOf(caseObjList[j].get('Id')));
                            if(statusSubStatusValue.containsKey('Status') && statusSubStatusValue.get('Status')!=''){
                                caseObj.put('Status',statusSubStatusValue.get('Status'));
                            }
                            if(statusSubStatusValue.containsKey('Core_Sub_Status__c')  && statusSubStatusValue.get('Core_Sub_Status__c')!=''){
                                caseObj.put('Core_Sub_Status__c',statusSubStatusValue.get('Core_Sub_Status__c'));
                                if((caseObjList[j].get('Core_IPS_Date_Time_Close_Pending__c')== null || caseObjList[j].get('Core_IPS_Date_Time_Close_Pending__c')== '') && statusSubStatusValue.get('Core_Sub_Status__c')==System.Label.Core_IPS_Case_Close_Pending && statusSubStatusValue.get('Status') == 'Open'){
                                    caseObj.put('Core_IPS_Date_Time_Close_Pending__c',DateTime.Now());
                                }
                            }
                        }
                        
                        System.debug('heap size Core_IPS_BES_UpdateCase 139 : '+Limits.getHeapSize());
                        String newOwner = (String)issueInformationMap.get('owner_info');
                        if(newOwner != null && newOwner!= '' && userDetailsMap != null){
                            List<String> authDetails = userDetailsMap.get(newOwner)?.split(';');
                            if(authdetails != null ){
                                String agentEmail = (authDetails.size() >= 1 &&authDetails[0] !='null') ? authDetails[0] : NULL;
                                caseObj.put('Core_IPS_Backend_System_Agent_Email__c', agentEmail);        
                                String agentName = (authDetails.size() > 2 && authDetails[2] !='null') ? authDetails[2] : NULL;
                                caseObj.put('Core_IPS_Backend_System_Agent_Name__c', agentName);
                            }                       
                        } 
                        System.debug('heap size Core_IPS_BES_UpdateCase 150 : '+Limits.getHeapSize());
                        if(casesToUpdate.contains(caseObj) == false){
                            //Ajith added this logic to restrict the Case Update, when Backend system is deactivated
                            //if(caseObj.Core_IPS_New_Backend_System__c != null && caseObj.Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c ==false && caseObj.Core_IPS_BES_Promote_Status__c =='Done' && caseObj.Core_IPS_BackendID__c!= null && sourceDetailsMap.get(caseObj.CaseNumber)==caseObj.Core_IPS_BackendID__c){
                            if(caseObjList[j].getsObject('Core_IPS_New_Backend_System__r') != null && caseObjList[j].getsObject('Core_IPS_New_Backend_System__r').get('Core_IPS_Deactivated__c') ==false && String.ValueOf(caseObjList[j].get('Core_IPS_BES_Promote_Status__c')) =='Done' && caseObjList[j].get('Core_IPS_BackendID__c')!= null && systemDetailsMap.get('source_id')==String.ValueOf(caseObjList[j].get('Core_IPS_BackendID__c'))){
                                casesToUpdate.add(caseObj);
                            }
                        }
                        //  system.debug('Debugg23 -- '+casesToUpdate+'-----'+isBatchExecute);
                    }
                }
            }
            System.debug('PB Debug 11 : '+isBatchExecute);
            System.debug('PB Debug 12 : '+casesToUpdate);
            //added by AJ need to check notnull conditon
            List<Case> accessClassList = Core_IPS_BES_UpdateBackendID_AJ.caseList;
            if(!accessClassList.isEmpty()){
                casesToUpdate.addAll(accessClassList);    
            }
            Set<String> lstchckduplicate = new Set<String>();
            for(case ca:casesToUpdate){
                if(lstchckduplicate.contains(ca.CaseNumber)){
                    isBatchExecute = true;
                    break;
                }
                lstchckduplicate.add(ca.CaseNumber);
            }
            if (casesToUpdate.size()<=0){
                Core_IPS_BES_InboundMessage_AJ.setjsoncasedml();
                
            }
            
            if(casesToUpdate.size()>0 && isBatchExecute == false){
                if(Case.SObjectType.getDescribe().isUpdateable()){
                    List<Database.SaveResult> results = Database.update(casesToUpdate,false);
                    
                    for (Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            for (Database.Error err : result.getErrors()){  
                                try{
                                    throw new CustomException(err.getMessage());
                                }
                                catch(Exception e){
                                    Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, '400', String.join(new List<String>(caseNumbers),','));
                                }  
                            }
                        }
                    }
                }
                System.debug('heap size Core_IPS_BES_UpdateCase 179 : '+Limits.getHeapSize());
            }
            else if(casesToUpdate.size()>1 && isBatchExecute == true){
                //system.debug('Debugg23 -- '+casesToUpdate);
                Core_IPS_BES_UpdateCaseBatch batch = new Core_IPS_BES_UpdateCaseBatch(casesToUpdate);
                Database.executeBatch(batch,1);
            }
            if(revisionMap != null){
                //system.debug('Debugg24 -- '+revisionMap);
                Core_IPS_BES_InboundMessage.updateRevision(revisionMap,sourceDetailsMap); 
            }
        }
        catch(Exception e) {
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join((Iterable<String>)caseNumbers,','));     
        }
        System.debug('Heap Size chiru EXit '+ Limits.getHeapSize()); // 6.6MB
    }
    
    
    
    public class SystemDetailsWrapper {
        public String message_id;
        public String message_type;
        public String source_system;
        public String hsdes;
        public String target_system;
        public String source_id;
        public String target_id;
        public String backend_rev;
    }
    
    public class IssueInformationWrapper {
        public String owner_info;
        public String hsd_mirror_status;
        public String hsd_mirror_reason;
        public String comment_text;
        public String comment_author;
    }
    
    public class InboundWrapper {
        public IssueInformationWrapper IssueInfoDetails;
        public SystemDetailsWrapper SystemDetails;
    }
    
    
    public static String schemaDisplayTypeMapping(Schema.SObjectField field){
        DescribeFieldResult fielddesc = field.getDescribe();
        DisplayType fieldType = fielddesc.getType();    
        if(fieldType == Schema.DisplayType.String || 
           fieldType == Schema.DisplayType.TextArea ||
           fieldType == Schema.DisplayType.Id ||
           fieldType == Schema.DisplayType.Picklist)
            return 'String';
        if(fieldType == Schema.DisplayType.Integer)
            return 'Integer';
        if(fieldType == Schema.DisplayType.Boolean)
            return 'Boolean';            
        
        return 'UNKNOWN';    
    }
}