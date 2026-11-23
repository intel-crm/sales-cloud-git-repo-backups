/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Benefit_Group_Asso_Utility 
Version             : 1.0
Created Date        : Dec 2019

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      02-Dec-2019                   Added a new method specialtyDuplicateCheck to restrict duplicate  in insert and update events
* Teja Munagala      10-Feb-2020                   Added a new method newBGSpecialtyCheck to restrict Benefit Group Assignment to specialty if any active accounts are associated to the specialty both insert and update events

****************************************************************************************************************************/
public without sharing class PRM_Specialty_Benefit_Group_Asso_Utility {

    public static Set<String> duplicateSet = new Set<String>();
    public static Map<String,String> uniqueMap = new Map<String,String>();// To store the Criteria and speciality field values
    //public static boolean ipaRefresh =  Boolean.valueOf(label.PRM_IPARefresh); //IPA2.0-TWC727-2861
    public static void specialtyDuplicateCheck(List<PRM_Specialty_Benefit_Group_Association__c> specialtyAssocNewList,Map<Id,PRM_Specialty_Benefit_Group_Association__c> oldMap)
    {
        Set<String> benefitGroupIdSet = new Set<String>();// To store the Criteria field values from trigger.new
        Set<String> specialtyIdset = new Set<String>();
       
        
        for(PRM_Specialty_Benefit_Group_Association__c sbga: specialtyAssocNewList){
            PRM_Specialty_Benefit_Group_Association__c sbgaOld ; 
            if(oldMap!=null && oldMap.size()>0){ sbgaOld = (PRM_Specialty_Benefit_Group_Association__c) oldMap.get(sbga.id) ;}
            if((oldMap==null) || ((oldMap!=null && oldMap.size()>0) && sbgaOld.PRM_Benefit_Group_Id__c != sbga.PRM_Benefit_Group_Id__c))
            {
             benefitGroupIdSet.add(sbga.PRM_Benefit_Group_Id__c);
             specialtyIdset.add(sbga.PRM_Specialty_Id__c);
             uniqueMap.put(sbga.PRM_Benefit_Group_Id__c+''+sbga.PRM_Specialty_Id__c,sbga.PRM_Specialty_Id__c);    
            }
        }
        //querying PRM_Specialty_Benefit_Group_Association__c records based on specialtyIdset and benefitGroupIdSet values
        if(uniqueMap != null && uniqueMap.keySet().size()>0)
        {
        for(PRM_Specialty_Benefit_Group_Association__c sbga : [SELECT Id,PRM_Benefit_Group_Id__c,PRM_Specialty_Id__c FROM PRM_Specialty_Benefit_Group_Association__c where PRM_Benefit_Group_Id__c IN: benefitGroupIdSet AND PRM_Specialty_Id__c IN: specialtyIdset]){adddtoduplicateset(sbga);}
       } 
        //iterating over the trigger context and throwing error if duplicate record already exists
        if(duplicateSet != null && duplicateSet.size()>0){
                functionadderror(specialtyAssocNewList);              
        }
    }
  
  public static void adddtoduplicateset(PRM_Specialty_Benefit_Group_Association__c sbga){
    if(sbga.PRM_Specialty_Id__c == uniqueMap.get(sbga.PRM_Benefit_Group_Id__c+''+sbga.PRM_Specialty_Id__c)){duplicateSet.add(sbga.PRM_Benefit_Group_Id__c+''+sbga.PRM_Specialty_Id__c);}
  }
  
  public static void functionadderror(List<PRM_Specialty_Benefit_Group_Association__c>  specialtyAssocNewList){
        for(PRM_Specialty_Benefit_Group_Association__c sbga: specialtyAssocNewList){
      if(duplicateSet.contains(sbga.PRM_Benefit_Group_Id__c+''+sbga.PRM_Specialty_Id__c)){
              sbga.addError(System.label.PRM_Specialty_Benefit_Group_Asso_Error);
      }
        }
  }
   /* --------------------------------------------------------------------------------------------------------------------------

* Teja Munagala      10-Feb-2020                   Added a new method newBGSpecialtyCheck to restrict Benefit Group Assignment to specialty if any active accounts are associated to the specialty both insert and update events

****************************************************************************************************************************/ 
public static Map<id,id> asaMap = new Map<id,id>(); // to store specialty id and asa id    
public static void newBGSpecialtyCheck(List<PRM_Specialty_Benefit_Group_Association__c> specialtyAssocNewList,Map<Id,PRM_Specialty_Benefit_Group_Association__c> oldMap){
        Set<String> specialtyIdset = new Set<String>();// to store Speciality ids in to a set
        for(PRM_Specialty_Benefit_Group_Association__c sbga: specialtyAssocNewList){
            PRM_Specialty_Benefit_Group_Association__c sbgaOld ; //getting old values from map
            if(oldMap!=null && oldMap.size()>0)
            {sbgaOld = (PRM_Specialty_Benefit_Group_Association__c) oldMap.get(sbga.id) ;}
            if((oldMap==null) || ((oldMap!=null && oldMap.size()>0) &&((sbgaOld.PRM_Benefit_Group_Id__c != sbga.PRM_Benefit_Group_Id__c)|| (sbgaOld.PRM_InActive_Ind__c != sbga.PRM_InActive_Ind__c))))
            {
        specialtyIdset.add(sbga.PRM_Specialty_Id__c);  // adding specialties to a set
            }
        }
        /*if(!ipaRefresh || test.isrunningtest()){ //IPA2.0-TWC727-2861
        for(PRM_Account_Specialty_Association__c asa :[select id,PRM_Specialty_Id__c, PRM_InActive_Ind__c from PRM_Account_Specialty_Association__c where PRM_Specialty_Id__c IN:specialtyIdset AND PRM_InActive_Ind__c=False]){
            asaMap.put(asa.PRM_Specialty_Id__c,asa.id);
        }
    }*/ // IPA Refresh - switch removal
        if(asaMap!=null || !asaMap.isEmpty()){
         for(PRM_Specialty_Benefit_Group_Association__c sbga: specialtyAssocNewList){
        assigntosbaold(oldMap,sbga);
            }
    }
    }
  
    public static void assigntosbaold(Map<Id,PRM_Specialty_Benefit_Group_Association__c> oldMap,PRM_Specialty_Benefit_Group_Association__c sbga){
      PRM_Specialty_Benefit_Group_Association__c sbgaOld ; //getting old values from map
             if(oldMap!=null && oldMap.size()>0)
             {sbgaOld = (PRM_Specialty_Benefit_Group_Association__c) oldMap.get(sbga.id) ;}
            if(asaMap.containskey(sbga.PRM_Specialty_Id__c)){
                if((oldMap==null) ||(oldMap!=null && oldMap.size()>0) &&(sbgaOld.PRM_Benefit_Group_Id__c != sbga.PRM_Benefit_Group_Id__c)){
                    sbga.addError(System.label.PRM_Specialty_Benefit_Group_Asso_Error1);
      }
        else if((oldMap!=null && oldMap.size()>0) &&(sbgaOld.PRM_InActive_Ind__c != sbga.PRM_InActive_Ind__c)){
          sbga.addError(System.label.PRM_Specialty_Benefit_Group_Asso_Error2);
        }  
      }
    }
  }