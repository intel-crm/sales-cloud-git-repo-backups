/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Utility 
Version             : 1.0
Created Date        : 09 Jan 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      09-Jan-2020                   Added a new method inactiveASACheck to restrict Name change and Inative Specialty check

****************************************************************************************************************************/
public without sharing class PRM_Specialty_Utility {
    //public static boolean ipaRefresh = Boolean.valueOf(label.PRM_IPARefresh);  //IPA2.0-TWC727-2861
    public static void inactiveASACheck(List<PRM_Specialty__c> specialtyNewList,Map<Id,PRM_Specialty__c> oldMap){
        
        Set<String> specialtyIdSet = new Set<String>();// to add list of spcialties to set
        Set<String> activespecSet = new Set<String>(); //final set to comapre trigger context
        for(PRM_Specialty__c spec: specialtyNewList){
            PRM_Specialty__c specOld ; 
            if(oldMap!=null && oldMap.size()>0){ specOld = (PRM_Specialty__c) oldMap.get(spec.id) ;}
            if(((oldMap!=null && oldMap.size()>0)&&(specOld.PRM_Inactive_Ind__c!=spec.PRM_Inactive_Ind__c)&&(specOld.PRM_Inactive_Ind__c==False)||(specOld.Name!=spec.Name)))
            {
                specialtyIdSet.add(spec.id); //adding specalities to set if they are getting inactivated or Name changing 
            }
        }
        //IPA2.0-TWC727-2861
        /*if(!ipaRefresh || test.isrunningtest()){
        for(PRM_Account_Specialty_Association__c asa : [select id,PRM_Specialty_id__c,PRM_Inactive_Ind__c from PRM_Account_Specialty_Association__c 
                                                        where PRM_Specialty_id__c IN:specialtyIdSet AND PRM_Inactive_Ind__c = False]){
                                                            activespecSet.add(asa.PRM_Specialty_Id__c);  //adding specalities to final set if any active Account specialty Associations are identified to throw an error                                                             
                                                        }
                                                    }*/ // IPA Refresh - switch removal
        if(activespecSet != null && activespecSet.size()>0){
            for(PRM_Specialty__c spec: specialtyNewList){
                //System.debug('specialtyNewList=======>'+spec);
                PRM_Specialty__c specOld ;
                if(oldMap!=null && oldMap.size()>0){ specOld = (PRM_Specialty__c) oldMap.get(spec.id) ;}
                if(activespecSet.contains(spec.id)&&(specOld.Name!=spec.Name)){
                    spec.Name.addError(System.label.PRM_Specialty_Name);  
                }
                else if(activespecSet.contains(spec.id)&&(specOld.PRM_Inactive_Ind__c!=spec.PRM_Inactive_Ind__c)&&(specOld.PRM_Inactive_Ind__c==False)){   
                    spec.PRM_Inactive_Ind__c.addError(System.label.PRM_Specialty_Inactive);
                }
            } 
        }
        
    }
    
}