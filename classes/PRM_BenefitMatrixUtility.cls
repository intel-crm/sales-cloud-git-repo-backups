/***************************************************************************************************************************************************
Apex Class Name  : PRM_BenefitMatrixUtility
Version       : 1.0
Created Date  : FEB 2019
Function      : Check Benefit matrix duplicate records

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      15-Feb-2019          
***************************************************************************************************************************************************/
public without sharing class PRM_BenefitMatrixUtility{

 /**
*  @description      : Check Benefit matrix duplicate records
*  @name             : duplicateBMXCheck
*  @param            : List<PRM_Account_Contact_Relationship__c>
*  @throws exception : if the AGS message is not generated//
**/

public static void duplicateBMXCheck(List<PRM_VXBnftMatrix__c> bmxNewList)
    {
        System.debug('bmxNewList :-'+bmxNewList);
        List<String> uniqstr = new List<String>(); 
      Map<String,Id> uniqmap = new Map<String,Id>();
        for(PRM_VXBnftMatrix__c bmx: bmxNewList){
           
            uniqstr.add(bmx.PRM_BenfitMatrix_Combination__c);
        }
        System.debug('uniqstr :-'+uniqstr);
        List<PRM_VXBnftMatrix__c> bmxList = [SELECT Id, PRM_BenfitMatrix_Combination__c FROM PRM_VXBnftMatrix__c where PRM_BenfitMatrix_Combination__c IN: uniqstr];
        System.debug('bmxList :-'+bmxList);
        for(PRM_VXBnftMatrix__c beneMax: bmxList){
           
            uniqmap.put(beneMax.PRM_BenfitMatrix_Combination__c, beneMax.Id);
            
        }
        System.debug('uniqmap :-'+uniqmap);
        for(PRM_VXBnftMatrix__c benMax: bmxNewList){
           
            if(uniqmap.containsKey(benMax.PRM_BenfitMatrix_Combination__c)){
                benMax.addError(System.label.PRM_BenfitMatrix_Error1);
            }            
        }
        
    }
    
    public static void duplicateUpdateBMXCheck(List<PRM_VXBnftMatrix__c> bmxNewList)
    {
        List<String> uniqstr = new List<String>();
        List<Id> idslist = new List<Id>();
      Map<String,Id> uniqmap = new Map<String,Id>();
        for(PRM_VXBnftMatrix__c bmx: bmxNewList){
           
            uniqstr.add(bmx.PRM_BenfitMatrix_Combination__c);
            idslist.add(bmx.Id);
        }
        List<PRM_VXBnftMatrix__c > bmxList = [SELECT Id, PRM_BenfitMatrix_Combination__c FROM PRM_VXBnftMatrix__c where PRM_BenfitMatrix_Combination__c IN: uniqstr and Id Not IN: idslist];
        for(PRM_VXBnftMatrix__c bmx: bmxList){
           
            uniqmap.put(bmx.PRM_BenfitMatrix_Combination__c, bmx.Id);
            
        }
        for(PRM_VXBnftMatrix__c bmx: bmxNewList){
            
            if(uniqmap.containsKey(bmx.PRM_BenfitMatrix_Combination__c)){
                bmx.addError(System.label.PRM_BenfitMatrix_Error1);
            }            
        
      }  
    }
    //End of Changes by Teja Munagala on 15-FEB-2018 for Duplicate Rule check

}