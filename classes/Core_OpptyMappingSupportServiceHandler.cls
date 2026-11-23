/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Core_OpptyMappingSupportServiceHandler {
    public static void determinecountofAprovers(List<Core_Opportunity_Support_Mapping__c> triggerNew)
    {
        List<Core_Opportunity_Support_Mapping__c> oppsuppid;
        Map<string,List<Core_Opportunity_Support_Mapping__c>> keyForOSM_CSA = new Map<String,List<Core_Opportunity_Support_Mapping__c>>();
        Map<string,List<Core_Opportunity_Support_Mapping__c>>  keyForOSM_TSS = new Map<string,List<Core_Opportunity_Support_Mapping__c>> ();
        Map<string,List<Core_Opportunity_Support_Mapping__c>>  keyForOSM_COE = new Map<string,List<Core_Opportunity_Support_Mapping__c>> ();
        Map<string,List<Core_Opportunity_Support_Mapping__c>> duplicate_rec =  new Map<string,List<Core_Opportunity_Support_Mapping__c>> ();
        List<Core_Opportunity_Support_Mapping__c > oppSupportMapping = [select id,Geo_Region__c,Core_BU__c,Core_OSM_Record_Type__c,Core_Opp_Center_of_Excellence__c, Core_Record_Type__c,User__r.id,User__r.Name from Core_Opportunity_Support_Mapping__c  where  Core_Opportunity_Support_Is_Active__c =true ];
        for(Core_Opportunity_Support_Mapping__c rec : oppSupportMapping)
        {
            
            if(rec.Core_OSM_Record_Type__c == 'COE')
            {
				
                if(keyForOSM_COE.containskey(rec.Core_OSM_Record_Type__c+'_'+rec.Core_Opp_Center_of_Excellence__c))
                {
                    keyForOSM_COE.get(rec.Core_OSM_Record_Type__c+'_'+rec.Core_Opp_Center_of_Excellence__c).add(rec);
                }
                else{
                    keyForOSM_COE.put (rec.Core_OSM_Record_Type__c+'_'+rec.Core_Opp_Center_of_Excellence__c,new List<Core_Opportunity_Support_Mapping__c>{rec});

                }
                if(duplicate_rec.containskey(rec.Core_OSM_Record_Type__c+'_'+rec.Core_Opp_Center_of_Excellence__c+'_'+rec.User__c))
                {
                    duplicate_rec.get(rec.Core_OSM_Record_Type__c+'_'+rec.Core_Opp_Center_of_Excellence__c+'_'+rec.User__c).add(rec);
                }
                else{
                    duplicate_rec.put(rec.Core_OSM_Record_Type__c+'_'+rec.Core_Opp_Center_of_Excellence__c+'_'+rec.User__c,new List<Core_Opportunity_Support_Mapping__c>{rec});
                }
            }
            else if(rec.Core_OSM_Record_Type__c == 'TSS')
            {
                if(keyForOSM_TSS.containskey(rec.Core_OSM_Record_Type__c +'_'+rec.Geo_Region__c+'_'+rec.Core_BU__c))
                {
                    keyForOSM_TSS.get(rec.Core_OSM_Record_Type__c +'_'+rec.Geo_Region__c+'_'+rec.Core_BU__c).add(rec);
                }
                else{
                    keyForOSM_TSS.put(rec.Core_OSM_Record_Type__c +'_'+rec.Geo_Region__c+'_'+rec.Core_BU__c,new List<Core_Opportunity_Support_Mapping__c>{rec});
                }
                       if(duplicate_rec.containskey(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c+'_'+rec.Core_BU__c+'_'+rec.User__c))
                {
                    duplicate_rec.get(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c+'_'+rec.Core_BU__c+'_'+rec.User__c).add(rec);
                }
                else{
                    duplicate_rec.put(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c+'_'+rec.Core_BU__c+'_'+rec.User__c,new List<Core_Opportunity_Support_Mapping__c>{rec});
                }
            }
            else if (rec.Core_OSM_Record_Type__c == 'CSA'){
                if(keyForOSM_CSA.containskey(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c))
                {
                    keyForOSM_CSA.get(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c).add(rec);
                }
                else{
                    keyForOSM_CSA.put(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c,new List<Core_Opportunity_Support_Mapping__c>{rec}); 
                }
               if(duplicate_rec.containskey(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c+'_'+rec.User__c))
                {
                    duplicate_rec.get(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c+'_'+rec.User__c).add(rec);
                }
                else{
                    duplicate_rec.put(rec.Core_OSM_Record_Type__c+'_'+rec.Geo_Region__c+'_'+rec.User__c,new List<Core_Opportunity_Support_Mapping__c>{rec});
                }
            }
        }
        
        for(Core_Opportunity_Support_Mapping__c oppsuppmapp : triggerNew)
        {
            if (oppsuppmapp.Core_OSM_Record_Type__c=='CSA')
            {
                if(keyForOSM_CSA.containskey(oppsuppmapp.Core_OSM_Record_Type__c+'_'+oppsuppmapp.Geo_Region__c) )
                {
                    
                    oppsuppid=keyForOSM_CSA.get(oppsuppmapp.Core_OSM_Record_Type__c+'_'+oppsuppmapp.Geo_Region__c);     
                    
                }
         	if (duplicate_rec.containskey(oppsuppmapp.Core_OSM_Record_Type__c+'_'+oppsuppmapp.Geo_Region__c+'_'+oppsuppmapp.User__c))
                {
                     oppsuppmapp.adderror('This approver is already added');
                }
                
            }
            if (oppsuppmapp.Core_OSM_Record_Type__c=='TSS')
            {
                if(keyForOSM_TSS.containskey(oppsuppmapp.Core_OSM_Record_Type__c +'_'+oppsuppmapp.Geo_Region__c+'_'+oppsuppmapp.Core_BU__c) )
                {
                    oppsuppid=keyForOSM_TSS.get(oppsuppmapp.Core_OSM_Record_Type__c +'_'+oppsuppmapp.Geo_Region__c+'_'+oppsuppmapp.Core_BU__c);                                                                                                                                                                                                                                                                                                  
                }
               if (duplicate_rec.containskey(oppsuppmapp.Core_OSM_Record_Type__c+'_'+oppsuppmapp.Geo_Region__c+'_'+oppsuppmapp.Core_BU__c+'_'+oppsuppmapp.User__c))
                {
                     oppsuppmapp.adderror('This approver is already added');
                }
            }
            if (oppsuppmapp.Core_OSM_Record_Type__c=='COE')
            {
                if(keyForOSM_COE.containskey(oppsuppmapp.Core_OSM_Record_Type__c+'_'+oppsuppmapp.Core_Opp_Center_of_Excellence__c) )
                {
                    oppsuppid=keyForOSM_COE.get(oppsuppmapp.Core_OSM_Record_Type__c+'_'+oppsuppmapp.Core_Opp_Center_of_Excellence__c);                                                                                                                                                                                                                                                                                                  
                }
                //system.debug('line 71'+duplicate_rec);
                //system.debug('line 72'+oppsuppmapp.Core_OSM_Record_Type__c+'_'+oppsuppmapp.Core_Opp_Center_of_Excellence__c+'_'+oppsuppmapp.User__c);
                if (duplicate_rec.containskey(oppsuppmapp.Core_OSM_Record_Type__c+'_'+oppsuppmapp.Core_Opp_Center_of_Excellence__c+'_'+oppsuppmapp.User__c))
                {
                     oppsuppmapp.adderror('This approver is already added');
                }
            }
            if (oppsuppid!=null && oppsuppid.size()>=10 && oppsuppmapp.Core_OSM_Record_Type__c != 'COE')
            {
                oppsuppmapp.adderror('No more than 10 approvers can be present');
            }
            else if (oppsuppid!=null && oppsuppid.size()>=5 && oppsuppmapp.Core_OSM_Record_Type__c == 'COE')
            {
                oppsuppmapp.adderror('No more than 5 approvers can be present');
            }
        }
        }

}