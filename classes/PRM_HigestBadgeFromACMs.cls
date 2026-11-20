/**************************************************************************************************************
Apex Class Name:  PRM_HigestBadgeFromACMs
Version     : 1.0 
Created Date: 28 May 2020
Function    : This class used for sorting based on badge. 1st reord of the list always contain the topest badge details. 
Modification Log :
* Developer             Date              Description
* ----------------------------------------------------------------------------                 
* Prasant Sahu         05/31/2020        Initial version
***************************************************************************************************************/
global without sharing class PRM_HigestBadgeFromACMs implements Comparable{
    private static Map<String,Integer> ipaBadgeMap = getIPABadgeMap();
    public PRM_AccountChannelMembership__c acm{
        get;
        private set;
    }
    
    
    public PRM_HigestBadgeFromACMs(PRM_AccountChannelMembership__c acm){
        this.acm = acm;
    }
    
	public Integer compareTo(Object obj) {
        if(!ipaBadgeMap.isEmpty()){
            PRM_HigestBadgeFromACMs prmHighBadge = (PRM_HigestBadgeFromACMs)obj;
            PRM_AccountChannelMembership__c acmObj = prmHighBadge.acm;
            
            String acmTierName = acm.PRM_Channel_Program_Level_Id__r.name;
            Integer acmTierValue = ipaBadgeMap.get(acmTierName);
            System.debug('Badge One : '+acmTierName);
            
            String acmObjTierName = acmObj.PRM_Channel_Program_Level_Id__r.name;
            Integer acmObjTierValue = ipaBadgeMap.get(acmObjTierName);
            System.debug('Badge Two : '+acmObjTierName);
            
            return acmTierValue < acmObjTierValue ? -1 : (acmTierValue > acmObjTierValue ? 1 : 0);            
        }    
        return null;        
    }
    
    //Return map of badge with rank from custom metdata
    public static Map<String,Integer> getIPABadgeMap(){
        Map<String, Integer> mapOfIPABadge = new Map<String, Integer>();
        for(String bageMapping :LabelConfiguration__mdt.getInstance('ChannelProgramLevelRanking').Value__c.split(';')){ 
            List<String> progTier = bageMapping.split(':');
            if(!mapOfIPABadge.containsKey(progTier[0])){   
                mapOfIPABadge.put(progTier[0],Integer.valueOf(progTier[1])); 
            }
        }
        System.debug('mapOfIPABadge called from static variable '+mapOfIPABadge);
        return mapOfIPABadge;
    } 

}