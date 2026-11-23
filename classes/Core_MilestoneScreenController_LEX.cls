/***************************************************************************************************
Apex Class Name:  Core_MilestoneScreenController_LEX
US no          :  US943883
Version        :  1.0 
Created Date   :  23/03/2020 
Function       :  Controller to get All MileStones
Modification Log :
*Developer                 Date                    Description
* ----------------------------------------------------------------------------                 
* Farooq                 23/03/2020                 Created
****************************************************************************************************/
public with sharing class Core_MilestoneScreenController_LEX {
    /*-- This method is to get all MileStones--*/
    @AuraEnabled
    public static List<WrapMileStone> getMileStones(String recordId){
        List<Id> businesshoursIdList = new list<Id>();
        List<CaseMilestone> mileStoneQueryList = new List<CaseMilestone>(); 
        List<WrapMileStone> mileStoneDisplayList = new List<WrapMileStone>();
        List<BusinessHours> businessHoursQureryList = new List<BusinessHours>(); 
        try{
            if(CaseMilestone.SObjectType.getDescribe().isQueryable()){
                mileStoneQueryList = [SELECT BusinessHours.Name, Case.caseNumber, CompletionDate, IsViolated, IsCompleted, 
                                      Id, MilestoneType.Name, TargetDate, TimeRemainingInMins  
                                      FROM CaseMilestone  
                                      WHERE CaseId=:recordId
                                      ORDER BY CreatedDate DESC];   
            }
            
            for(CaseMileStone cMRec: MileStoneQueryList){
                WrapMileStone wCM = new WrapMileStone(); 
                
                if(Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]) != 0) {
                    WCM.TimeRemaininginHours = (Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0])/60).setscale(2);
                }
                else {
                    WCM.TimeRemaininginHours = Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]);
                }
                
                if(Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]) != 0) {
                    WCM.TimeRemaininginDays = (Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0])/1400).setscale(2);
                }
                else {
                    WCM.TimeRemaininginDays = Decimal.valueOf(CMRec.TimeRemainingInMins.split(':')[0]);
                }
                WCM.CsMs = CMRec;  
                WCM.BusinessHoursName = CMRec.BusinessHours.Name;   
                MileStoneDisplayList.add(WCM);
            }
        }catch(Exception e){
            throw new AuraHandledException('class=Core_MilestoneScreenController_LEX,  Method=getMileStones'+e.getMessage());
        }
        return MileStoneDisplayList;
    }
    public class WrapMileStone {
        @AuraEnabled
        public CaseMilestone csMs {get; set;}
        @AuraEnabled
        public Double timeRemaininginHours {get; set;}
        @AuraEnabled
        public Double timeRemaininginMinutesofHour {get; set;}
        @AuraEnabled
        public Double timeRemaininginDays {get; set;}
        @AuraEnabled
        public String businessHoursName {get;set;}
        
    }
    
}