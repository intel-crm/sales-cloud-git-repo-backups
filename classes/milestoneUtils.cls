/***************************************************************************************************
* Apex Class Name: milestoneUtils
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rickey Flores               14/2/2016               Created
* Sumukh                      30/07/2019             Modified for US390495
* Ganapati                    28/08/2019              Modified for DE49777
* Sumukh                      12/09/2019              Modified for DE49968 
****************************************************************************************************/

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
        if(caseMilestone == null || caseMilestone !=cs){
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
        system.debug('=====activeMilestoneList==== '+activeMilestoneList );
        return activeMilestoneList;
    }
    public Static Map<Id,List<CaseMilestone>> getActiveMileStone(List<case> csList){
        Map<Id,List<CaseMilestone>> CaseMilestoneByCaseId =  new Map<Id,List<CaseMilestone>>();
        String query = 'select Id,caseId,completionDate, isCompleted,MileStoneTypeId,MileStoneType.Name from CaseMilestone where caseId in :csList and completionDate = null';
        system.debug('-query --------'+ query);
        for(CaseMilestone activeMilestone : Database.query(query))
        {
            system.debug('=====activeMilestone 69===='+activeMilestone );
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
    /***************************************************************************************************
Method Name:  getSetNextResponseDueDate
Method Type: Case milestone & next response due date calculating Method 
Version     : 1.0 
Created Date: 17 Nov 2015
Function    : This method is used to calculate the next response due date of the case(NRDD).
Input Parameters: Case
Output Parameters: Next response due date
Description:   This method takes the case and calculates the NRDD based on different scenarios of the business hours.
Number of Queries Within this Method: 0
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                       11/17/2015                 Created
* Sumukh                    30/06/2019               Added logic for US390495
****************************************************************************************************/   
    public static DateTime getSetNextResponseDueDate(case cs){       
        Id caseBusinessHoursId = NULL;        
        Integer businessHour;           // Added by sumukh for US390495
        Boolean isbusinessHour = false; // Added by sumukh for US390495      
      
        // Attempt to load the BusinessHours. Added by sumukh for US390495    
        businessHour = getBusinessHours(cs.Core_IPS_Product_Org_Number__c,cs.Priority);          
        if(businessHour !=null){                     
            isbusinessHour=true;
        }
        // end by sumukh for US390495      
        
        if ( cs.BusinessHoursId == null && isbusinessHour) { // Attempt to load the BusinessHoursId. modified by sumukh for US390495                   
            caseBusinessHoursId = getBusinessHoursId(cs.ownerId);          
        }
        else {  
            caseBusinessHoursId = cs.BusinessHoursId;            
        }
        
        // Added by sumukh for US390495
        if(businessHour !=null && isbusinessHour == true ){                  
            //cs.Core_Next_Response_Due_Date__c = System.Now().addHours(businessHour); //commented by Ganapati for DE49777                       
            cs.Core_Next_Response_Due_Date__c = BusinessHours.add(caseBusinessHoursId, System.now(), ((businessHour * 60) * (60*1000))); // Added by Ganapati for DE49777           
            return cs.Core_Next_Response_Due_Date__c;         
        }// End by sumukh for US390495
        
        // BusinessHoursId available, use it.
        if ( caseBusinessHoursId != null && isbusinessHour!= true ) {  // modified by sumukh for US390495           
            cs.Core_Next_Response_Due_Date__c = BusinessHours.add(caseBusinessHoursId, System.now(), Integer.valueof(System.Label.IPS_Next_Response_Due_Default_in_Minutes) * (60*1000));           
            return cs.Core_Next_Response_Due_Date__c;
        }            
        
        // BusinessHoursId NOT available - use VERY BASIC formula.
        if(isbusinessHour !=true && caseBusinessHoursId == null){ // modified by sumukh for US390495
            cs.Core_Next_Response_Due_Date__c = System.Now() + Integer.valueof(System.Label.IPS_Next_Response_Due_Default_in_Minutes) / (24*60);            
        }  
        return cs.Core_Next_Response_Due_Date__c;       
    }
    
    
    public static boolean isCaseMilestoneUpdateRequired(Case caseObj, DateTime completionDate){
        
        // consider an outbound email to the contact on the case a valid first response
        //if ((caseObj.Status == 'In Progress')&&(caseObj.EntitlementId != null)&&
        if ((caseObj.EntitlementId != null)&&
            (caseObj.SlaStartDate <= completionDate)&&(caseObj.SlaStartDate != null)&& (caseObj.SlaExitDate == null))
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
    
    /***************************************************************************************************
Method Name: getBusinessHours
Method Type: next response due date calculating Method cased on Case Supported Org Priority defined in the custom settings. 
Version     : 1.0 
Created Date: 30 July 2019
Function    : This method is used to calculate the next response due date of the case(NRDD).
Input Parameters: Case , Supported Org number of the case, Case Priority
Output Parameters: Business hours based on Supported Org priority
Description:   This method takes the case and calculates the NRDD based on different scenarios of the business hours.
Number of Queries Within this Method: 1
Number of Queries in Loop: 0
Number of Queries from Called methods:  0
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sumukh                    30/06/2019               Created logic for US390495
****************************************************************************************************/ 
    public static Integer getBusinessHours(String OrgNum,String Priority){          
        Integer Businesshours;         
        List<Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c> supOrgBizHourSetting = Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c.getall().values();           
        for(Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c supOrgId : supOrgBizHourSetting  ){                     
            if(OrgNum == supOrgId.Supported_Org_Number__c){                              
                if(Priority == supOrgId.Case_Priority_level__c && supOrgId.Active__c){   
                    Businesshours = Integer.valueof(supOrgId.Business_Hours__c);                              
                    Break;
                }
            }            
        }           
        return Businesshours;    
    }// end by sumukh for US390495
    
    public static Map<String,String> getBusinessHoursByOwner(Set<String> OwnerIds){
        Map<String, String> businessHoursByOwner = new Map<String, String>();
        List<Group> grpList = [SELECT Id,DeveloperName,Name FROM Group where id in :ownerIds];
        for(Group grp:grpList){
            String userOrGroupName = grp.developerName;
            String bizHrId;
            if(userOrGroupName!=null && userOrGroupName.length()>0){ 
                Core_IPS_Q_Biz_hours_mapping__c bizHourSetting = Core_IPS_Q_Biz_hours_mapping__c.getValues(userOrGroupName);
                System.debug('bizHourSetting-->' + bizHourSetting);
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
       
        /* Added by Ganapati - For DE49777*/
        Set<Id> casesWithOrgConfigSet = new Set<Id>();
        casesWithOrgConfigSet = milestoneUtils.getCasesWithOrgConfigSet(TrgNew);
        /* Added by Ganapati - end For DE49777*/
       
        for(Case CsNew:TrgNew){           
            String ownerId=CsNew.ownerId;            
            /*Fixed  for DE40804 Next Response Due Date is not getting populated when the case is created !casesWithOrgConfigSet.isEmpty() && */
            // added CsNew.Core_First_Response_Completed__c==false to below condition              
            if((trgOldMap == null || (trgOldMap.get(CsNew.Id).Priority != CsNew.Priority && casesWithOrgConfigSet.contains(CsNew.Id)) || (trgOldMap != null && trgOldMap.get(CsNew.id).ownerId!=CsNew.ownerId) || (trgOldMap.get(CsNew.id).Core_First_Response_Completed__c == false && (CsNew.Core_First_Response_Completed__c == true || CsNew.Core_First_Response_Completed__c==false)))){              
                CaseList.add(CsNew);
                ownerIdSet.add(csNew.ownerId);               
            }
        }
        
        Map<String, String> bizHoursByOwner = new Map<String, String>();
        bizHoursByOwner = getBusinessHoursByOwner(ownerIdSet);
        try{           
            for(Case cs:CaseList){               
                if(milestoneutils.getMilestone(cs) ==null ||  milestoneutils.getMilestone(cs).size()==0){                                                                                                                                                                                              
                    if(cs.Core_Next_Response_Due_Date__c == null){     // added by sumukh for US390495                             
                        cs.BusinessHoursId = Label.IPS_Business_Hours;                                                                                                             
                        cs.Core_Next_Response_Due_Date__c = BusinessHours.add(cs.BusinessHoursId, System.now(), Integer.valueof(System.Label.CORE_IPS_CASE_SLA_FIRST_RESPONSE_IN_MINUTES) * (60 * 1000));                                                                                                                                                                                           
                     }
                    else {                           
                          if(cs.Core_IPS_Minds__c ){                        //  Added by sumukh for DE49968                                               
                            //getSetNextResponseDueDate(cs); 
                            cs.Core_Next_Response_Due_Date__c = BusinessHours.add(cs.BusinessHoursId, System.now(), Integer.valueof(System.Label.CORE_IPS_CASE_SLA_FIRST_RESPONSE_IN_MINUTES) * (60 * 1000));
                          }  
                          else if(!cs.Core_IPS_GEC_Flag__c){                                                       
                              getSetNextResponseDueDate(cs); 
                          }                                                 // end by sumukh for DE49968                                                                                           
                    }// end by sumukh for US390495
                }
                else if(milestoneutils.getMilestone(cs).size() > 0 && milestoneutils.getMilestone(cs)[0].MileStoneType.Name== system.Label.Core_IPS_First_Response_MileStone_Label && bizHoursByOwner.get(cs.OwnerId)!=null ){                                          
                       cs.BusinessHoursId = bizHoursByOwner.get(cs.OwnerId);                          
                        if(cs.Core_Next_Response_Due_Date__c==null){        //  Added by sumukh for DE49968                                                      
                            getSetNextResponseDueDate(cs);  
                        }                                                   //  End for DE49968 
                }                    
                else { 
                      cs.BusinessHoursId = Core_IPS_Q_Biz_hours_mapping__c.getValues('Default').Business_Hours_ID__c;                                                              
                      getSetNextResponseDueDate(cs);                                      
                }
            }
        }
        catch(Exception e){
            //return Core_IPS_Q_Biz_hours_mapping__c.getValues('Default').Business_Hours_ID__c;
        }
    }
    
/***************************************************************************************************
Method Name: getCasesWithOrgConfigSet
Version     : 1.0 
Created Date: 27 August 2019
Description : This method takes the list of cases and returns set of Case Ids whose Support Org is 
configured in Custom Setting. 
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  27/08/2019           Created for DE49777
****************************************************************************************************/
    public static Set<Id> getCasesWithOrgConfigSet(List<Case> newList) {
        Set<Id> casesWithOrgConfigSet = new Set<Id>();
        String uniqueCode = '';
        Set<String> SupOrgPriUniqueCodeSet = new Set<String>();
        for (Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c supOrgMapObj : Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c.getall().values()) {
            uniqueCode = supOrgMapObj.Supported_Org_Number__c+'$'+supOrgMapObj.Case_Priority_level__c.toLowerCase();
            SupOrgPriUniqueCodeSet.add(uniqueCode);
        }
        
        for (Case cs:newList) {
            uniqueCode =cs.Core_IPS_Product_Org_Number__c +'$'+cs.Priority.toLowerCase();
            if(!SupOrgPriUniqueCodeSet.isEmpty() && SupOrgPriUniqueCodeSet.contains(uniqueCode)) {
                casesWithOrgConfigSet.add(cs.Id);
            }
        }
        return casesWithOrgConfigSet;
    }
} /*End*/