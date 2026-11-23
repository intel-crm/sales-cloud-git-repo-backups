public with sharing class Core_MilestoneScreenController{

    public Case newcase{get;set;}
 
    List<CaseMilestone> MileStoneQueryList = new List<CaseMilestone>(); 
    List<WrapMileStone> MileStoneDisplayList = new List<WrapMileStone>();
    List<BusinessHours> BusinessHoursQureryList = new List<BusinessHours>(); 
    
    public Core_MilestoneScreenController(ApexPages.StandardController controller) {
        newCase=(Case)controller.getRecord();
    }
    
    public List<WrapMileStone> getcaseMilestones(){
            List<Id> BusinesshoursIdList = new list<Id>();
            Map<Id,String> BusinessHoursNameMap = new Map<Id,String>();
            MileStoneQueryList = [SELECT BusinessHoursId, Case.caseNumber, CompletionDate, IsViolated, IsCompleted, 
                                         Id, MilestoneType.Name, TargetDate, TimeRemainingInMins  
                                  FROM CaseMilestone  
                                  WHERE CaseId=:newCase.id
                                  ORDER BY CreatedDate DESC];     
            
            for(CaseMileStone CMRecforBHoursId: MileStoneQueryList){
                BusinesshoursIdList.add(CMRecforBHoursId.BusinessHoursId);
                system.debug('244444444444444444 ' + BusinesshoursIdList);
                  system.debug(' 255555555555555555555 ' + MileStoneQueryList );
            }
            
            BusinessHoursQureryList = [Select Id,Name from BusinessHours where id IN: BusinesshoursIdList ];
            
            for(CaseMileStone CMRecforMapCreation: MileStoneQueryList){
                for(BusinessHours BHRecforMapCreation: BusinessHoursQureryList){
                    BusinessHoursNameMap.put(CMRecforMapCreation.id,BHRecforMapCreation.Name);
                }
            }
            
            
            for(CaseMileStone CMRec: MileStoneQueryList){
                WrapMileStone WCM = new WrapMileStone(); 
                system.debug('Time remianing in Hours if not zero***'+CMRec);

                if(Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]) != 0) {
                    WCM.TimeRemaininginHours = (Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0])/60).setscale(2);
                    system.debug('Time remianing in Hours if not zero***'+WCM.TimeRemaininginHours);}
                else {
                    WCM.TimeRemaininginHours = Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]);
                    system.debug('Time remianing in Hours if zero zero***'+WCM.TimeRemaininginHours);
                }
                    
                if(Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]) != 0) {
                    WCM.TimeRemaininginDays = (Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0])/1400).setscale(2);
                    system.debug('Time remianing in Hours if not zero***'+WCM.TimeRemaininginDays);}
                else {
                    WCM.TimeRemaininginDays = Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]);
                    system.debug('Time remianing in Hours if zero zero***'+WCM.TimeRemaininginDays);
                }
                    
                WCM.CsMs = CMRec;  
                WCM.BusinessHoursName = BusinessHoursNameMap.get(CMRec.id);   
                
                /*WCM.CaseNumber = CMRec.Case.CaseNumber;
                WCM.CompletionDate = CMRec.CompletionDate;
                WCM.IsViolated = CMRec.IsViolated;
                WCM.IsCompleted = CMRec.IsCompleted;
                WCM.TargetDate = CMRec.TargetDate;
                WCM.MilestoneTypeName = CMRec.MilestoneType.Name;*/
                
                MileStoneDisplayList.add(WCM);
            }
            return MileStoneDisplayList;
    }
    
    public class WrapMileStone {
        public CaseMilestone CsMs {get; set;}
        public Double TimeRemaininginHours {get; set;}
        public Double TimeRemaininginMinutesofHour {get; set;}
        public Double TimeRemaininginDays {get; set;}
        public String BusinessHoursName {get;set;}
        
        /*public String CaseNumber {get;set;} 
        public DateTime CompletionDate {get;set;}
        public boolean IsViolated {get;set;}
        public boolean IsCompleted {get;set;}
        public string MilestoneTypeName {get;set;}
        public DateTime TargetDate {get;set;}*/
            
    }
}