/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Qualitative_Utility 
Version             : 1.0
Created Date        : Nov 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      29-Nov-2019                   Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events 

****************************************************************************************************************************/
public without sharing class PRM_Specialty_Qualitative_Utility {

    
    public static void specialtyDuplicateCheck(List<PRM_Specialty_Qualitative_Criteria__c> specialtyAssocNewList,Map<Id,PRM_Specialty_Qualitative_Criteria__c> oldMap)
    {
        Set<String> criteriaIdset = new Set<String>();// To store the Criteria field values from trigger.new
        Set<String> specialtyIdset = new Set<String>();
        Map<String,String> uniqueMap = new Map<String,String>();// To store the Criteria and speciality field values
        Set<String> duplicateSet = new Set<String>();
        for(PRM_Specialty_Qualitative_Criteria__c sqca: specialtyAssocNewList){
            PRM_Specialty_Qualitative_Criteria__c sqcaOld ; 
            if(oldMap!=null && oldMap.size()>0){ sqcaOld = (PRM_Specialty_Qualitative_Criteria__c) oldMap.get(sqca.id) ;}
            if((oldMap==null) || ((oldMap!=null && oldMap.size()>0) && sqcaOld.PRM_Criteria_Id__c != sqca.PRM_Criteria_Id__c))
            {
             criteriaIdset.add(sqca.PRM_Criteria_Id__c);
             specialtyIdset.add(sqca.PRM_Specialty_Id__c);
             uniqueMap.put(sqca.PRM_Criteria_Id__c+''+sqca.PRM_Specialty_Id__c,sqca.PRM_Specialty_Id__c);    
            }
        }
        //querying PRM_Specialty_Qualitative_Criteria__c records based on specialtyIdset and criteriaIdset values
        if(uniqueMap != null && uniqueMap.keySet().size()>0)
        {
        for(PRM_Specialty_Qualitative_Criteria__c sqca : [SELECT Id,PRM_Criteria_Id__c,PRM_Specialty_Id__c FROM PRM_Specialty_Qualitative_Criteria__c where PRM_Criteria_Id__c IN: criteriaIdset AND PRM_Specialty_Id__c IN: specialtyIdset]){
            if(sqca.PRM_Specialty_Id__c == uniqueMap.get(sqca.PRM_Criteria_Id__c+''+sqca.PRM_Specialty_Id__c))
            {
                duplicateSet.add(sqca.PRM_Criteria_Id__c+''+sqca.PRM_Specialty_Id__c);
            }
         }
       } 
        //iterating over the trigger context and throwing error if duplicate record already exists
        if(duplicateSet != null && duplicateSet.size()>0){
            for(PRM_Specialty_Qualitative_Criteria__c sqca: specialtyAssocNewList){
                System.debug('specialtyAssocNewList=======>'+sqca);
                if(duplicateSet.contains(sqca.PRM_Criteria_Id__c+''+sqca.PRM_Specialty_Id__c)){
                    sqca.addError(System.label.PRM_Specialty_Qualitative_Criteria_Duplicate_Error);
                }            
            } 
        }
    }
}