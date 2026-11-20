public with sharing class Core_IPS_MilestoneScreen_Controller {
    public Core_IPS_MilestoneScreen_Controller() {

    }
  
    public static List<CaseMilestone> MileStoneQueryList = new List<CaseMilestone>(); 
    public static List<WrapMileStone> MileStoneDisplayList = new List<WrapMileStone>();
    public static List<BusinessHours> BusinessHoursQureryList = new List<BusinessHours>(); 
    
    @AuraEnabled (cacheable = true)
    public static List<WrapMileStone> getcaseMilestones(Id caseId){
            List<Id> BusinesshoursIdList = new list<Id>();
            Map<Id,String> BusinessHoursNameMap = new Map<Id,String>();
            MileStoneQueryList = [SELECT BusinessHoursId, Case.caseNumber, CompletionDate, IsViolated, IsCompleted, 
                                         Id, MilestoneType.Name, TargetDate, TimeRemainingInMins  
                                  FROM CaseMilestone  
                                  WHERE CaseId=: caseId
                                  ORDER BY CreatedDate DESC];     
            
            
            for(CaseMileStone CMRecforBHoursId: MileStoneQueryList){
                BusinesshoursIdList.add(CMRecforBHoursId.BusinessHoursId);
            }
            	BusinessHoursQureryList = [Select Id,Name from BusinessHours where id IN: BusinesshoursIdList ];
            
            for(CaseMileStone CMRecforMapCreation: MileStoneQueryList){
                for(BusinessHours BHRecforMapCreation: BusinessHoursQureryList){
                    BusinessHoursNameMap.put(CMRecforMapCreation.id,BHRecforMapCreation.Name);
                }
            }
            
            
            for(CaseMileStone CMRec: MileStoneQueryList){
                WrapMileStone WCM = new WrapMileStone(); 
                

                if(Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]) != 0) {
                    WCM.TimeRemaininginHours = (Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0])/60).setscale(2);
                    
                }else {
                    WCM.TimeRemaininginHours = Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]);
                    
                }
                    
                if(Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]) != 0) {
                    WCM.TimeRemaininginDays = (Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0])/1400).setscale(2);
                    
                }else {
                    WCM.TimeRemaininginDays = Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]);
                    
                }
                
                WCM.caseNumber =  CMRec.Case.caseNumber;
                WCM.completionDate = CMRec.CompletionDate;
                WCM.isCompleted = CMRec.IsCompleted;
                WCM.isViolated = CMRec.IsViolated;
                WCM.milestoneTypeName = CMRec.MilestoneType.Name;
                WCM.targetDate = CMRec.TargetDate;
                WCM.BusinessHoursName = BusinessHoursNameMap.get(CMRec.id);   
                
                MileStoneDisplayList.add(WCM);
            }
            return MileStoneDisplayList;
    }
    
    public class WrapMileStone {
        @AuraEnabled public String milestoneTypeName {get; set;}
        @AuraEnabled public Boolean isViolated {get; set;}
        @AuraEnabled public Boolean isCompleted {get; set;}
        @AuraEnabled public Datetime completionDate {get; set;}
        @AuraEnabled public DateTime targetDate {get; set;}
        @AuraEnabled public String caseNumber {get; set;}
        @AuraEnabled public Double TimeRemaininginHours {get; set;}
        @AuraEnabled public Double TimeRemaininginMinutesofHour {get; set;}
        @AuraEnabled public Double TimeRemaininginDays {get; set;}
        @AuraEnabled public String BusinessHoursName {get;set;}
            
    }
}