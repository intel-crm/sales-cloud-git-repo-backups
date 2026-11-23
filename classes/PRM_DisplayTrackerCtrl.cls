public with sharing class PRM_DisplayTrackerCtrl {
	
	public static Final String ORIGIN  = 'PRM_DisplayTrackerCtrl';
    public static Final String SEVERITY  = 'Info';
    public static Final String PROJECT  = 'IPA';
	public static Final String SCOPE  = 'Exception Handling analysis';
	
    @AuraEnabled(cacheable=true)
    public static List<List<TrackerWrapper>> getTrackerSteps(String recId, String type, String lookupApiName){
        try {
            List<List<TrackerWrapper>> finalSteps = new List<List<TrackerWrapper>>();
            Map<String, Core_CustomMetadata_Object__c> trackerStepMap = new Map<String, Core_CustomMetadata_Object__c>();
            String strEsc = String.escapeSingleQuotes(lookupApiName);
            Id trackRecId;
            Map<String,Map<String,PRM_Tracker__c>> trackerGroupMap = new  Map<String,Map<String,PRM_Tracker__c>>();
           /* List<PRM_Tracker_steps__mdt> stepsMdt = [SELECT Id,DeveloperName,PRM_Failed_Step__c,PRM_Active__c,PRM_Conditional_Display__c,PRM_Milestone_Display_Name__c,PRM_Order__c,PRM_Skippable_step__c FROM PRM_Tracker_steps__mdt WHERE PRM_Type__c=:type AND PRM_Active__c = TRUE ORDER BY PRM_Order__c];*/
            List<Core_CustomMetadata_Object__c> stepsMdt = [SELECT id,DeveloperName__c,Field_3__c,Field_1__c,Field_2__c,Field_4__c,Field_5__c,Field_6__c,Field_7__c from Core_CustomMetadata_Object__c WHERE Metadata_Name__c='PRM_Tracker_steps__mdt' AND Header_row__c!=null AND Field_7__c=:type AND Field_1__c='TRUE' ORDER BY Field_5__c];
            
            
            for(Core_CustomMetadata_Object__c step: stepsMdt){
                trackerStepMap.put(step.DeveloperName__c, step);
            }
            
            //String query = 'SELECT Id,PRM_Completed__c,PRM_OPID__c,PRM_OPID_account_name__c,PRM_LOC_account_name__c,PRM_Location_Account__c,PRM_Milestone__c,PRM_Merge_field_1__c,PRM_Merge_field_2__c,PRM_Groupby_Id__c,PRM_Milestone_Display_Name__c FROM PRM_Tracker__c WHERE '+strEsc+' =:recId AND PRM_Type__c=:type ORDER BY CreatedDate ASC';
            recId = String.escapeSingleQuotes(recId);
            type = String.escapeSingleQuotes(type);
            String query = 'SELECT '+String.join(PRM_DisplayTrackerCtrl.getTrackerFields(),',')+' FROM PRM_Tracker__c WHERE '+strEsc+' =:recId AND PRM_Type__c=:type ORDER BY CreatedDate ASC';
            
            List<TrackerWrapper> stepso = new List<TrackerWrapper>();
            DateTime opidCreatedDate;
            List<PRM_Tracker__c> trackerList = new List<PRM_Tracker__c>();
            trackerList = Database.query(query);
            for(PRM_Tracker__c step: trackerList){
                if(type == 'OPID Updates 1PID'){
                    Boolean displayLink = false;
                    String url;
                    String linkLabel;
                    if (step.PRM_Milestone_Display_Name__c.contains('Link')) {                           
                        Integer startIndex = step.PRM_Milestone_Display_Name__c.indexOf('Link(');
                        Integer endIndex = step.PRM_Milestone_Display_Name__c.indexOf(')');
                        List<String> values = step.PRM_Milestone_Display_Name__c.subString(startIndex+5,endIndex).split(',');
                        if (values != null && !values.isEmpty() &&
                            values.size() == 2 &&
                            ( !values[0].contains('__c') || step.get(values[0]) != null) &&
                            step.get(values[1]) != null){
                            url = '/'+String.valueOf(step.get(values[1]));
                            linkLabel = values[0].contains('__c') ? String.valueOf(step.get(values[0])) : values[0];
                            displayLink = true;
                        }
                       
            
                        step.PRM_Milestone_Display_Name__c = step.PRM_Milestone_Display_Name__c.replace(step.PRM_Milestone_Display_Name__c.subString(startIndex,endIndex+1),'');
                    }
                    for(Integer i=1;i<3;i++){
                        String field = 'PRM_Merge_field_'+i+'__c';
                        step.PRM_Milestone_Display_Name__c = step.PRM_Milestone_Display_Name__c.replace(field ,step.get(field) != null ?
                            String.valueOf(step.get(field)) :
                            '');
                    }
                    if(step.PRM_Milestone__c == 'OPID_CRTD'){
                        opidCreatedDate = step.CreatedDate;
                    }
                    if(step.PRM_Milestone__c == 'OPID_REQ' && opidCreatedDate != null &&
                    (step.CreatedDate.getTime() - opidCreatedDate.getTime()) / 60000 < 2){              
                        stepso.add(0,createWrapper(step.PRM_Milestone__c , step.PRM_Milestone_Display_Name__c, step.PRM_Completed__c,!step.PRM_Completed__c,false,displayLink,url,linkLabel,false));
                    }
                    else{
                        stepso.add(createWrapper(step.PRM_Milestone__c , step.PRM_Milestone_Display_Name__c, step.PRM_Completed__c,!step.PRM_Completed__c,false,displayLink,url,linkLabel,false));
                    }
                }
                String groupKey = String.isNotBlank(step.PRM_Groupby_Id__c) ? step.PRM_Groupby_Id__c : 'default';
                if (!trackerGroupMap.containsKey(groupKey)) {
                    trackerGroupMap.put(groupKey, new Map<String,PRM_Tracker__c>{step.PRM_Milestone__c=>step});
                }
                else{
                    trackerGroupMap.get(groupKey).put(step.PRM_Milestone__c,step);
                }
            }

            if(type == 'OPID Updates 1PID'){
                finalSteps.add(stepso);
                return finalSteps;
            }
      if(type == 'OPID Updates'){
        // for (String groupbyId : trackerGroupMap.keySet()) {//remove this for
                List<TrackerWrapper> steps = new List<TrackerWrapper>();
                //Map<String,PRM_Tracker__c> trackerMap = trackerGroupMap.get(groupbyId);//take metadata
                for(PRM_Tracker__c tracker: trackerList){ // tracker step
                    Boolean displayLink = false;
                    String url;
                    String linkLabel; 
                    if(trackerStepMap.containsKey(tracker.PRM_Milestone__c)){
                        Core_CustomMetadata_Object__c trackerstep = trackerStepMap.get(tracker.PRM_Milestone__c);
                    
                        if(trackerStep!=null){
                        if(trackerstep.DeveloperName__c == 'OPID_REMOVED'){
                            trackerstep.Field_4__c ='OPID Removed Link(PRM_OPID_account_name__c,PRM_OPID__c)';
                            
                        }
                        if(trackerstep.DeveloperName__c == 'OPID_ASSOCIATED'){
                            trackerstep.Field_4__c ='OPID AssociatedLink(PRM_OPID_account_name__c,PRM_OPID__c)';
                            
                        }

                    if(trackerstep != null){
                        
                            if (trackerstep.Field_4__c!=null && trackerstep.Field_4__c.contains('Link')) {
                                Integer startIndex = trackerstep.Field_4__c.indexOf('Link(');
                                Integer endIndex = trackerstep.Field_4__c.indexOf(')');
                                List<String> values = trackerstep.Field_4__c.subString(startIndex+5,endIndex).split(',');
                            if (values != null && !values.isEmpty() &&
                                values.size() == 2 &&
                                (!values[0].contains('__c') || tracker.get(values[0]) != null) &&
                                tracker.get(values[1]) != null){
                                url = '/'+String.valueOf(tracker.get(values[1]));
                                linkLabel =  values[0].contains('__c') ? String.valueOf(tracker.get(values[0])) : values[0];
                                displayLink = true;
                            }
                           

                                trackerstep.Field_4__c = trackerstep.Field_4__c.replace(trackerstep.Field_4__c.subString(startIndex,endIndex+1),'');
                            
                        }
                        for(Integer i=1;i<3;i++){
                            String field = 'PRM_Merge_field_'+i+'__c';
                                trackerstep.Field_4__c = trackerstep.Field_4__c.replace(field ,tracker.get(field) != null ?
                                String.valueOf(tracker.get(field)) :
                                '');
                        }
                            steps.add(createWrapper(trackerstep.DeveloperName__c , trackerstep.Field_4__c, Boolean.valueOf(trackerstep.Field_3__c )? false: tracker.PRM_Completed__c,Boolean.valueOf(trackerstep.Field_3__c) ? true: !tracker.PRM_Completed__c,false,displayLink,url,linkLabel,false));
                    }
                        else if(!Boolean.valueOf(trackerstep.Field_2__c)){
                        for(Integer i=1;i<3;i++){
                            String field = 'PRM_Merge_field_'+i+'__c';
                                trackerstep.Field_4__c = trackerstep.Field_4__c.replace(field ,'');
                            }
                            steps.add(createWrapper(trackerstep.DeveloperName__c , trackerstep.Field_4__c, false,false,!Boolean.valueOf(trackerstep.Field_3__c),displayLink,url,linkLabel,Boolean.valueOf(trackerstep.Field_6__c)));
                        }
                        }
                    }
                }

                finalSteps.add(steps);
           // }
      }
      if(type=='OPID Recommendation'){
          
                    for (String groupbyId : trackerGroupMap.keySet()) {
                List<TrackerWrapper> steps = new List<TrackerWrapper>();
                Map<String,PRM_Tracker__c> trackerMap = trackerGroupMap.get(groupbyId);
                for(Core_CustomMetadata_Object__c step: stepsMdt){
                    Boolean displayLink = false;
                    String url;
                    String linkLabel;

                        if(trackerMap.containsKey(step.DeveloperName__c)){
                            
                        if (step.Field_4__c.contains('Link')) {
                            
                            Integer startIndex = step.Field_4__c.indexOf('Link(');
                            Integer endIndex = step.Field_4__c.indexOf(')');
                            List<String> values = step.Field_4__c.subString(startIndex+5,endIndex).split(',');
                            if (values != null && !values.isEmpty() &&
                                values.size() == 2 &&
                                (!values[0].contains('__c') || trackerMap.get(step.DeveloperName__c).get(values[0]) != null) &&
                                trackerMap.get(step.DeveloperName__c).get(values[1]) != null){
                                url = '/'+String.valueOf(trackerMap.get(step.DeveloperName__c).get(values[1]));
                                linkLabel =  values[0].contains('__c') ? String.valueOf(trackerMap.get(step.DeveloperName__c).get(values[0])) : values[0];
                                displayLink = true;
                            }
                           

                            step.Field_4__c = step.Field_4__c.replace(step.Field_4__c.subString(startIndex,endIndex+1),'');
                        }

                        for(Integer i=1;i<3;i++){
                            String field = 'PRM_Merge_field_'+i+'__c';
                            step.Field_4__c = step.Field_4__c.replace(field ,trackerMap.get(step.DeveloperName__c).get(field) != null ?
                                String.valueOf(trackerMap.get(step.DeveloperName__c).get(field)) :
                                '');
                        }
                        steps.add(createWrapper(step.DeveloperName__c , step.Field_4__c, Boolean.valueOf(step.Field_3__c )? false: trackerMap.get(step.DeveloperName__c).PRM_Completed__c,Boolean.valueOf(step.Field_3__c) ? true: !trackerMap.get(step.DeveloperName__c).PRM_Completed__c,false,displayLink,url,linkLabel,false));
                    }
                    else if(!Boolean.valueOf(step.Field_2__c)){
                        for(Integer i=1;i<3;i++){
                            String field = 'PRM_Merge_field_'+i+'__c';
                            step.Field_4__c = step.Field_4__c.replace(field ,'');
                        }
                        steps.add(createWrapper(step.DeveloperName__c , step.Field_4__c, false,false,!Boolean.valueOf(step.Field_6__c),displayLink,url,linkLabel,Boolean.valueOf(step.Field_6__c)));
                    }
                }

                finalSteps.add(steps);
            }
    }
       return finalSteps;
        } catch (Exception e) {
			Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, SCOPE, SEVERITY, e.getMessage(), e.getStackTraceString(), '', '', '');
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<String> getTrackerFields(){
        List<String> fields = new List<String>();
    /*SObjectType trackerType = Schema.getGlobalDescribe().get('PRM_Tracker__c');
    Map<String,Schema.SObjectField> mfields = trackerType.getDescribe().fields.getMap();  */
        //JB
        Map<String,Schema.SObjectField>mfields=PRM_Tracker__c.SObjectType.getDescribe().fields.getMap();
        for (Schema.SObjectField d: mfields.values()) {
        fields.add(String.valueOf(d));
    }
        return fields;
        
    }

    private static TrackerWrapper createWrapper(String milestone, String milestoneDisplay,Boolean completed, Boolean error, Boolean inProgress, Boolean displayLink , String url, String linkLabel, Boolean skippable){
        TrackerWrapper wrp = new TrackerWrapper();
        wrp.completed = completed;
        wrp.milestone = milestone;
        wrp.milestoneDisplay = milestoneDisplay;
        wrp.error = error;
        wrp.inProgress = inProgress;
        wrp.displayLink = displayLink;
        wrp.url = url;
        wrp.linkLabel = linkLabel;
        wrp.skippable = skippable;
        return wrp;
    }
    public class TrackerWrapper{
        @AuraEnabled
        public String milestone{get; set;}

        @AuraEnabled
        public String milestoneDisplay{get; set;}

        @AuraEnabled
        public Boolean inProgress{get; set;}

        @AuraEnabled
        public Boolean completed{get; set;}

        @AuraEnabled
        public Boolean error{get; set;}

        @AuraEnabled
        public Boolean displayLink{get; set;}

        @AuraEnabled
        public String url{get; set;}

        @AuraEnabled
        public String linkLabel{get; set;}

        @AuraEnabled
        public Boolean skippable{get; set;}
    }
}