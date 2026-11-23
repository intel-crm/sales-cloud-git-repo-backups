/*********************************************************************************************************************
Trigger Name  : PRM_AccountBenefitAssociation_Trigger
Version       : 1.0
Created Date  : DEC 2018
Function      : It calls the triggerHandler of 'Account Benefit Association' object

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Utkarsh               12/14/2018              It calls the run method of TriggerHandler of 'Account Benefit Association' object

*********************************************************************************************************************/

trigger PRM_AccountBenefitAssociation_Trigger on PRM_AccountBenefitAssociation__c(before insert, before update, after insert, after update) {
    new PRM_aba_TriggerHandler().run();
    
   // system.debug('SOQL Limit Account ==>'+Limits.getQueries()+';;'+Limits.getLimitQueries());
    //system.debug('SOQL Limit DML Limit Account ==>'+Limits.getDMLStatements()+';;'+Limits.getLimitDMLStatements());
}