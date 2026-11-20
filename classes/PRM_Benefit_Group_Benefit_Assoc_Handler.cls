/****************************************************************************************************************************
    Apex Class Name     : PRM_Benefit_Group_Benefit_Assoc_Handler 
    Version             : 1.0
    Created Date        : Nov 2019

    Modification Log    :
    * Developer                 Date                    Description
    * --------------------------------------------------------------------------------------------------------------------------
    * Teja Munagala      27-Nov-2019                   Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events 
    * Tejasree Tadi      12-Mar-2020                   As part of US5670004 added a new method 'sendBenefitsEmailNotification' which is being called from PRM_EmailUtility Class to send Emails in insert and update events
    ****************************************************************************************************************************/
    public class PRM_Benefit_Group_Benefit_Assoc_Handler extends TriggerHandler{
        
        public override void beforeInsert() {
            if(isActive('PRM_Benefit_Group_Benefit_Assoc')) {     //Retrieved from Custom Metadata  
               PRM_Benefit_Group_Benefit_Assoc_Utility.benefitDuplicateCheck(Trigger.new,null);
               
            }   
        }
        
        public override void beforeUpdate() {
            if(isActive('PRM_Benefit_Group_Benefit_Assoc')) {     //Retrieved from Custom Metadata    
               PRM_Benefit_Group_Benefit_Assoc_Utility.benefitDuplicateCheck(Trigger.new,(Map<Id,PRM_Benefit_Group_Benefit_Association__c>) Trigger.oldMap);
            }
        }
        
         public override void afterInsert() {
            if(isActive('PRM_Benefit_Group_Benefit_Assoc')) {     //Retrieved from Custom Metadata    
               PRM_Benefit_Group_Benefit_Assoc_Utility.updateBenefitOnAccount(Trigger.new,(Map<Id,PRM_Benefit_Group_Benefit_Association__c>) Trigger.oldMap);
             //  PRM_EmailUtility.sendBenefitsEmailNotification(Trigger.new,(Map<Id,PRM_Benefit_Group_Benefit_Association__c>) Trigger.oldMap);
            }
        }
        
         public override void afterUpdate() {
             if(isActive('PRM_Benefit_Group_Benefit_Assoc')) {     //Retrieved from Custom Metadata 
                 PRM_Benefit_Group_Benefit_Assoc_Utility.updateBenefitOnAccount(Trigger.new,(Map<Id,PRM_Benefit_Group_Benefit_Association__c>) Trigger.oldMap);
                 PRM_Benefit_Group_Benefit_Assoc_Utility.benefitRemovalFromAccount(Trigger.new,(Map<Id,PRM_Benefit_Group_Benefit_Association__c>) Trigger.oldMap);
               //  PRM_EmailUtility.sendBenefitsEmailNotification(Trigger.new,(Map<Id,PRM_Benefit_Group_Benefit_Association__c>) Trigger.oldMap);
             }
        }

    }