public class milestoneUtils {
    //SALESFORCE TESTING Complete: RCA found. Do not make any change til discussed
    /*public static boolean completeMilestone(Case cs, String milestoneName, DateTime complDate) {
        
        boolean triggerMilestone = true;
        
        if(triggerMilestone && milestoneName != null && complDate != null && cs !=null){
            System.debug('milestoneName:'+milestoneName);
            System.debug('complDate:'+complDate);
            System.debug('Case Id:'+cs.id);
            String query = 'select Id, completionDate, isCompleted from CaseMilestone where caseId =\''+cs.Id+'\' and MilestoneType.Name=\''+milestoneName+'\' and completionDate = null limit 1';
            //List<CaseMilestone> cmsToUpdate = new List<CaseMileStone>();
            //cmsToUpdate = [select Id, completionDate, isCompleted
             //              from CaseMilestone cm
             //              where caseId =:cs.Id
             //              and cm.MilestoneType.Name=:milestoneName
             //              and completionDate = null limit 1];
             system.debug([select Core_Trigger_Next_Response__c, Id from case where id=:cs.Id]);
            CaseMilestone cmsToUpdate = Database.query(query);
                        System.debug('Milestone NAME : ' + query);
                        
            if(cmsToUpdate!=null &&  !cmsToUpdate.isCompleted){
                cmsToUpdate.completionDate = complDate;
                System.debug('Complete DATE : ' + complDate);
                update cmsToUpdate;
                return false;
            }
            triggerMilestone=false;
            return true;
        }
        return false;
    }*/
    
    /*
     This Will Bring all the Milesstone of the case
    */
    static case caseMilestone;
    static List<CaseMilestone> caseMilestoneList;
    public Static List<CaseMilestone> getMileStone(case cs){
    system.debug('cs=================' + cs);
    system.debug('caseMilestoneList=================' + caseMilestoneList);
     if(caseMilestone == null || caseMilestone !=cs)
     {
        caseMilestone = cs;
        String query = 'select Id, completionDate, isCompleted,MileStoneTypeId,MileStoneType.Name from CaseMilestone where caseId =\''+cs.Id+'\' Order By CreatedDate Desc' ;
        caseMilestoneList =  new List<CaseMilestone>();
        caseMilestoneList = Database.query(query);
            
            return caseMilestoneList;
     }
     else
     {
        return caseMilestoneList;
     }
    }
    
    public Static List<CaseMilestone> getActiveMileStone(case cs){
        String query = 'select Id, completionDate, isCompleted,MileStoneTypeId,MileStoneType.Name from CaseMilestone where caseId =\''+cs.Id+'\' and completionDate = null';
            List<CaseMilestone> activeMilestoneList = Database.query(query);
            return activeMilestoneList;
    }
    public Static Map<Id,List<CaseMilestone>> getActiveMileStone(List<case> csList){
     Map<Id,List<CaseMilestone>> CaseMilestoneByCaseId =  new Map<Id,List<CaseMilestone>>();
        String query = 'select Id,caseId,completionDate, isCompleted,MileStoneTypeId,MileStoneType.Name from CaseMilestone where caseId in :csList and completionDate = null';
            for(CaseMilestone activeMilestone : Database.query(query))
            {
              if(activeMilestone !=null)
              {
              List<CaseMilestone> LstCaseMilestone  ;
             if(CaseMilestoneByCaseId.containsKey(activeMilestone.caseID))
             {
               LstCaseMilestone =  CaseMilestoneByCaseId.get(activeMilestone.caseID);
               LstCaseMilestone.add(activeMilestone);
               CaseMilestoneByCaseId.Put(activeMilestone.caseID,LstCaseMilestone);
             }
             else
             {
               LstCaseMilestone =  new List<CaseMilestone>();
               LstCaseMilestone.add(activeMilestone);
               CaseMilestoneByCaseId.Put(activeMilestone.caseID,LstCaseMilestone);
             }
             }
            }
            return CaseMilestoneByCaseId;
    }
    
    public static DateTime getSetNextResponseDueDate(case cs){

        Id caseBusinessHoursId = NULL;        

        // Attempt to load the BusinessHoursId.
        if ( cs.BusinessHoursId == null ) {
            caseBusinessHoursId = getBusinessHoursId(cs.ownerId);
            System.debug('#31 caseBusinessHoursId: ' + caseBusinessHoursId + '   cs.Id: ' + cs.Id + '   cs.BusinessHoursId IS NULL');            
        }
        else {        
            caseBusinessHoursId = cs.BusinessHoursId;
            System.debug('#32 caseBusinessHoursId: ' + caseBusinessHoursId + '   cs.Id: ' + cs.Id + '   cs.BusinessHoursId: ' + cs.BusinessHoursId);            
        }

        // BusinessHoursId available, use it.
        if ( caseBusinessHoursId != null ) {
            cs.Core_Next_Response_Due_Date__c = BusinessHours.add(caseBusinessHoursId, System.now(), Integer.valueof(System.Label.IPS_Next_Response_Due_Default_in_Minutes) * (60*1000));
            System.debug('#33 cs.Core_Next_Response_Due_Date__c: ' + cs.Core_Next_Response_Due_Date__c);            
            return cs.Core_Next_Response_Due_Date__c;
        }            

        // BusinessHoursId NOT available - use VERY BASIC formula.
        cs.Core_Next_Response_Due_Date__c = System.Now() + Integer.valueof(System.Label.IPS_Next_Response_Due_Default_in_Minutes) / (24*60);
        System.debug('#34 cs.Core_Next_Response_Due_Date__c: ' + cs.Core_Next_Response_Due_Date__c);            
        return cs.Core_Next_Response_Due_Date__c;
    }
    
    
    public static boolean isCaseMilestoneUpdateRequired(Case caseObj, DateTime completionDate){
        
            // consider an outbound email to the contact on the case a valid first response
            //if ((caseObj.Status == 'In Progress')&&(caseObj.EntitlementId != null)&&
        if ((caseObj.EntitlementId != null)&&
            (caseObj.SlaStartDate <= completionDate)&&(caseObj.SlaStartDate != null)&&
            (caseObj.SlaExitDate == null))
            return true;                    
        return false;
    }
    
     /*public static void resetCaseNextResponseDueDateToDefault(Case caseObj, String milestoneName){
         CaseMilestone cmsToUpdate = [select Id, completionDate, isCompleted
                           from CaseMilestone cm
                           where caseId =:caseObj.Id
                           and cm.MilestoneType.Name=:milestoneName
                           and completionDate = null limit 1];
                        
                        
         long bhdiff = 0;
         
         if (caseObj.EntitlementId != null && cmsToUpdate!=null && cmsToUpdate.isCompleted) {
      
             if ( caseObj.BusinessHoursId != null )
                             
                 caseObj.Core_Next_Response_Due_Date__c=BusinessHours.add(caseObj.BusinessHoursId,caseObj.Core_Next_Response_Due_Date__c,Integer.valueof(System.Label.Core_IPS_Next_Response_Due_Default_in_Minutes)* (60*1000));
        
             else  
                 caseObj.Core_Next_Response_Due_Date__c=System.Now()+Integer.valueof(System.Label.Core_IPS_Next_Response_Due_Default_in_Minutes)/(24*60);

             update caseObj;

         }
        
            
    }

    public static void resetCaseNextResponseDueDateToDefault2(Case caseObj, String milestoneName){
         CaseMilestone cmsToUpdate = [select Id, completionDate, isCompleted
                           from CaseMilestone cm
                           where caseId =:caseObj.Id
                           and cm.MilestoneType.Name=:milestoneName
                           and completionDate = null limit 1];
                if (caseObj.EntitlementId != null && cmsToUpdate!=null && cmsToUpdate.isCompleted)
                      caseObj.Core_Next_Response_Due_Date__c=System.Now()+Integer.valueof(System.Label.Core_IPS_Next_Response_Due_Default_in_Minutes)/24;
             update caseObj;
    }*/
        
    public static void stopMilestoneClockWhenAwaitingCustomerResponse(Case caseObj){
        if(caseObj.Core_Sub_Status__c!=null && caseObj.Core_Sub_Status__c.startsWith('Waiting')){
            caseObj.IsStopped=true;
            //caseObj.Core_Next_Response_Due_Date__c=null;
        }
        
    }
    
    public static void reStartMilestoneClockWhenCustomerresponded(Case caseObj){
        long bhdiff = 0;
                
        if(caseObj.Core_Sub_Status__c!=null && caseObj.Core_Sub_Status__c.equalsIgnoreCase(Core_IPS_Helper_utility.getIPSLabel('IPS_Case_Status_Investigating')) && caseObj.IsStopped){
            caseObj.IsStopped=false;
            if(caseObj.Core_First_Response_Completed__c){
                if ( caseobj.StopStartDate!=null && caseObj.BusinessHoursId != null){
                      bhdiff = BusinessHours.diff(caseObj.BusinessHoursId,caseobj.StopStartDate, System.now()) ;
                      if ( bhdiff > 0 ){ 
                         caseObj.Core_Next_Response_Due_Date__c=BusinessHours.add(caseObj.BusinessHoursId,caseObj.Core_Next_Response_Due_Date__c, bhdiff);
                         return;
                      }
                  }
                if(caseobj.StopStartDate!=null)
                    caseObj.Core_Next_Response_Due_Date__c=caseObj.Core_Next_Response_Due_Date__c+((timeUtils.diffMinutes(System.Now(),caseobj.StopStartDate))/(24*60));
              
            }
        }
        
    }
    
    public static void AddCaseBizHoursOnOwnerUpdate(Case oldCase, case newCase){
        //Hardcoded value used for Queue recognition - Warning
        String ownerId=newCase.ownerId;
        if((oldCase==null || (oldCase!=null && oldCase.ownerId!=newCase.ownerId))){
            System.debug('#51 BusinesssHoursId Update BEFORE: ' + newCase.Id + '  newCase.OwnerId: ' + newCase.OwnerId + '   newCase.BusinessHoursId: ' + newCase.BusinessHoursId);   
            newCase.BusinessHoursId = getBusinessHoursId(newCase.ownerId);
            System.debug('#52 BusinesssHoursId Update AFTER: ' + newCase.Id + '  newCase.OwnerId: ' + newCase.OwnerId + '   newCase.BusinessHoursId: ' + newCase.BusinessHoursId);   
        }
    }
    
    public static Id getBusinessHoursId(String ownerId){
        try{   
            System.debug('#80 Starting getBusinessHoursId');
            
            String userOrGroupName;
            if(ownerId.startsWith('00G')){
                list<Group> lstGroup = [SELECT DeveloperName FROM Group where id=:ownerId limit 1];                
                if (lstGroup != null && lstGroup.size() > 0)
                    userOrGroupName = lstGroup[0].developerName;
            } else {  
                User u = [SELECT id,name from User where id=:ownerId limit 1]; 
                if(u!=null) 
                    userOrGroupName = u.name;
            }

            if(userOrGroupName!=null && userOrGroupName.length()>0){
                Core_IPS_Q_Biz_hours_mapping__c bizHourSetting = Core_IPS_Q_Biz_hours_mapping__c.getValues(userOrGroupName);
                if(bizHourSetting!=null){
                    return bizHourSetting.Business_Hours_ID__c;
                } else {
	                System.debug('#84 Core_IPS_Q_Biz_hours_mapping__c.getValues(Default): ' + Core_IPS_Q_Biz_hours_mapping__c.getValues('Default'));
                    return Core_IPS_Q_Biz_hours_mapping__c.getValues('Default').Business_Hours_ID__c;
                }
            } else {
                return Core_IPS_Q_Biz_hours_mapping__c.getValues('Default').Business_Hours_ID__c;
            }
            
        } catch(Exception e){
            System.debug('#88 Exception e.getMessage(): ' + e.getMessage());
            if (Core_IPS_Q_Biz_hours_mapping__c.getValues('Default') != NULL)
                return Core_IPS_Q_Biz_hours_mapping__c.getValues('Default').Business_Hours_ID__c;
        }
        
        return null;
    }
 
    public static Map<String,String> getBusinessHoursByOwner(Set<String> OwnerIds){
        Map<String, String> businessHoursByOwner = new Map<String, String>();
        List<Group> grpList = [SELECT Id,DeveloperName,Name FROM Group where id in :ownerIds];
        for(Group grp:grpList){
            String userOrGroupName = grp.DeveloperName;
            String bizHrId;
            if(userOrGroupName!=null && userOrGroupName.length()>0){
                Core_IPS_Q_Biz_hours_mapping__c bizHourSetting = Core_IPS_Q_Biz_hours_mapping__c.getValues(userOrGroupName);
                if(bizHourSetting!=null){
                    bizHrId= bizHourSetting.Business_Hours_ID__c;
                }else{
                    bizHrId= Core_IPS_Q_Biz_hours_mapping__c.getValues('Default').Business_Hours_ID__c;
                }
            }else{
                bizHrId= Core_IPS_Q_Biz_hours_mapping__c.getValues('Default').Business_Hours_ID__c;
            }
            businessHoursByOwner.put(grp.Id,bizHrId);
        }
        return businessHoursByOwner;
    }
 
    
    /*Start*/
     //Code added by Roshan-10/9/2015. This is to bulkify the code.
    public static void AddCaseBizHoursOnOwnerUpdate(map<ID, Case> trgOldMap, List<Case> TrgNew){
        //Hardcoded value used for Queue recognition - Warning
        Map<Case,Id> MapBusinessHoursIdToCase = new Map<Case,Id>();
        List<Case> CaseList = new List<Case>();
        Map<Id,Group> MapGrouptoId = new Map<Id,Group>();
        Map<Case,String> MapBizHourstoCase = new Map<Case,String>();
        Map<Case,String> MapDefaultBizHourstoCase = new Map<Case,String>();
        Set<String> ownerIdSet = new Set<String>();
        for(Case CsNew:TrgNew){
            String ownerId=CsNew.ownerId;
            system.debug('>>>>>>>>>>>>>>>>>>>>>' + CsNew.Core_First_Response_Completed__c);
            if((trgOldMap == null || (trgOldMap != null && trgOldMap.get(CsNew.id).ownerId!=CsNew.ownerId) || (trgOldMap.get(CsNew.id).Core_First_Response_Completed__c == false && CsNew.Core_First_Response_Completed__c == true))){
                system.debug('>>>>>>>>>>>>>>>>>>>>>' + CsNew.Core_First_Response_Completed__c);
                CaseList.add(CsNew);
                ownerIdSet.add(csNew.ownerId);
            }
        }
        Map<String, String> bizHoursByOwner = new Map<String, String>();
        bizHoursByOwner = getBusinessHoursByOwner(ownerIdSet);
        try{    
            for(Case cs:CaseList){
                    system.debug(milestoneutils.getMilestone(cs));
                    system.debug(system.Label.Core_IPS_First_Response_MileStone_Label);
                    if(milestoneutils.getMilestone(cs) ==null ||  milestoneutils.getMilestone(cs).size()==0)
                    {
                        cs.BusinessHoursId = Label.IPS_Business_Hours;      
                        
                        // BM [5/21] - Resync NextResponseDueDate after Bus Hours change.                   
                        // Need to use the First Response Label Value.
                        cs.Core_Next_Response_Due_Date__c = BusinessHours.add(cs.BusinessHoursId, System.now(), Integer.valueof(System.Label.CORE_IPS_CASE_SLA_FIRST_RESPONSE_IN_MINUTES) * (60 * 1000));
                        
                        System.debug('#53 BusinesssHoursId Update: ' + cs.Id + '  cs.OwnerId: ' + cs.OwnerId + '   cs.BusinessHoursId: ' + cs.BusinessHoursId);   
                    }
                    else if(milestoneutils.getMilestone(cs).size() > 0 && milestoneutils.getMilestone(cs)[0].MileStoneType.Name== system.Label.Core_IPS_First_Response_MileStone_Label && bizHoursByOwner.get(cs.OwnerId)!=null){
                        cs.BusinessHoursId = bizHoursByOwner.get(cs.OwnerId);
                        
                        // BM [5/20] - Resync NextResponseDueDate after Bus Hours change.                   
                        getSetNextResponseDueDate(cs);
                        System.debug('#54 BusinesssHoursId Update: ' + cs.Id + '  cs.OwnerId: ' + cs.OwnerId + '   cs.BusinessHoursId: ' + cs.BusinessHoursId);   
                    }                    
                    else
                    {
                        cs.BusinessHoursId = Core_IPS_Q_Biz_hours_mapping__c.getValues('Default').Business_Hours_ID__c;
                        
                        // BM [5/20] - Resync NextResponseDueDate after Bus Hours change.                   
                        getSetNextResponseDueDate(cs);
                        System.debug('#55 BusinesssHoursId Update: ' + cs.Id + '  cs.OwnerId: ' + cs.OwnerId + '   cs.BusinessHoursId: ' + cs.BusinessHoursId);   
                    }
                }
        }
        catch(Exception e){
            //return Core_IPS_Q_Biz_hours_mapping__c.getValues('Default').Business_Hours_ID__c;
        }
    }
    /*End*/
    }