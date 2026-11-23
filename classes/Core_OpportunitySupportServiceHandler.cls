/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Core_OpportunitySupportServiceHandler{
	public static void determineApprovers(List<Core_Opportunity_Support__c> triggerNew) {        
        string recordtypeTSS='Core_TSS_Request' , recordtypeCSA = 'Core_CSA_RecordType';
        string recordtypeCOE='Core_Center_of_Excellence_Request';
        // new record type CoE
        string recordtypeTSSId = '' , recordtypeCSAId ='',recordtypeCOEId=''; // need to declare
        Map<String,List<id>> geoUserMap = new Map<String,List<id>>();
        List<Id> OpportunityId = new List<Id>();
        List<Id> userListOppShare =new List<Id>();
        Map<String,OpportunityShare> OppUserMap = new Map<String,OpportunityShare>();
        
        Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.Core_Opportunity_Support__c.getRecordTypeInfosByDeveloperName();
        recordtypeCSAId = recordTypeMap.get(recordtypeCSA).getRecordTypeId();
        recordtypeTSSId = recordTypeMap.get(recordtypeTSS).getRecordTypeId();
        recordtypeCOEId = recordTypeMap.get(recordtypeCOE).getRecordTypeId();
       // Coe record type
         List<Core_Opportunity_Support_Mapping__c > oppSupportMapping = [select id,Geo_Region__c,Core_BU__c,Core_OSM_Record_Type__c,Core_Opp_Center_of_Excellence__c, Core_Record_Type__c,User__r.id,User__r.Name from Core_Opportunity_Support_Mapping__c  where  Core_Opportunity_Support_Is_Active__c =true
																		   and User__r.IsActive =true 
																		  ];
			for(Core_Opportunity_Support_Mapping__c rec : oppSupportMapping) {
			   string keyForRegionRectype;
			   if(rec.Core_OSM_Record_Type__c == 'COE')
			   {
				   keyForRegionRectype = rec.Core_Opp_Center_of_Excellence__c+'_'+recordtypeCOEId;
			   }
			   else if(rec.Core_OSM_Record_Type__c == 'TSS')
			   {
				   keyForRegionRectype = rec.Geo_Region__c+'_'+rec.Core_BU__c+'_'+recordtypeTSSId;
			   }
			   else if (rec.Core_OSM_Record_Type__c == 'CSA'){
				keyForRegionRectype = rec.Geo_Region__c+'_'+recordtypeCSAId;
			   }
			   if(geoUserMap.containsKey(keyForRegionRectype)) {
					geoUserMap.get(keyForRegionRectype).add(rec.User__c);
				} else {
					geoUserMap.put(keyForRegionRectype,new List<id>{rec.User__c});
				}
			   
			}
        
      
            for(Core_Opportunity_Support__c oppsupp :triggerNew)
            {
                string keyformOppSuport = oppsupp.Core_Region__c+'_'+oppsupp.RecordTypeId;
                string keyformOppSuport_TSS = oppsupp.Core_Region__c+'_'+oppsupp.Core_TSS_Support_Type__c+'_'+oppsupp.RecordTypeId;
                string keyfromOppSupport_COE = oppsupp.Center_of_Excellence__c+'_'+oppsupp.RecordTypeId;
                List<id> approvers  = new List<id>();
                
                if(geoUserMap.containskey(keyformOppSuport))
                    approvers = geoUserMap.get(keyformOppSuport);
                if(geoUserMap.containskey(keyfromOppSupport_COE))
                    approvers = geoUserMap.get(keyfromOppSupport_COE);
                if(geoUserMap.containskey(keyformOppSuport_TSS))
                    approvers = geoUserMap.get(keyformOppSuport_TSS);
                //if(geoUserMap.containskey(keyformOppSuport))
                
                if(approvers.size() > 0)
                {
                    //List<id> approvers = geoUserMap.get(keyformOppSuport); 
                    OpportunityId.add(oppsupp.Opportunity__c);
                    for(id OppsupportUserID : approvers){   
                        userListOppShare.add(OppsupportUserID);
                        OpportunityShare temApprover = new OpportunityShare();
                        temApprover.OpportunityId = oppsupp.Opportunity__c;
                        temApprover.OpportunityAccessLevel = 'Edit';
                        temApprover.RowCause = 'Manual';
                        temApprover.UserOrGroupId = OppsupportUserID;  
                        OppUserMap.put(oppsupp.Opportunity__c +'_'+ OppsupportUserID,temApprover);
                    }
                    /*As part of TWC4767-3919 CRM: CSA/TSS Support Mapping Increase
                    Increased the approvers limit to 10*/
                    Integer count=1;
                    for(Integer i = 0; i < approvers.size(); i++ )
                    {
                        if(i==0)
                            oppsupp.Core_Approver_1__c = approvers[0];
                        else if(i==1)
                            oppsupp.Core_Approver_2__c = approvers[1];
                        else if(i==2)
                            oppsupp.Core_Approver_3__c = approvers[2];
                        else if(i==3)
                            oppsupp.Core_Approver_4__c = approvers[3];
                        else if(i==4)
                            oppsupp.Core_Approver_5__c = approvers[4];
                        else if(i==5)
                            oppsupp.Core_Approver_6__c = approvers[5];
                        else if(i==6)
                            oppsupp.Core_Approver_7__c = approvers[6];    
                        else if(i==7)
                            oppsupp.Core_Approver_8__c = approvers[7];
                        else if(i==8)
                            oppsupp.Core_Approver_9__c = approvers[8];
                        else if(i==9)
                            oppsupp.Core_Approver_10__c = approvers[9];
                        count++;
                    }
                    for(Integer i = count; i<=10; i++ ){
                        if(i == 2)
                            oppsupp.Core_Approver_2__c = approvers[0];
                        else if(i == 3)
                            oppsupp.Core_Approver_3__c = approvers[0];
                        else if(i == 4)
                            oppsupp.Core_Approver_4__c = approvers[0];
                        else if(i == 5)
                            oppsupp.Core_Approver_5__c = approvers[0];
                        else if(i == 6)
                            oppsupp.Core_Approver_6__c = approvers[0];
                        else if(i == 7)
                            oppsupp.Core_Approver_7__c = approvers[0];
                        else if(i == 8)
                            oppsupp.Core_Approver_8__c = approvers[0];
                        else if(i == 9)
                            oppsupp.Core_Approver_9__c = approvers[0];
                        else if(i == 10)
                            oppsupp.Core_Approver_10__c = approvers[0];
                    }
                    /*if(approvers.size() == 1)
                    {
                        oppsupp.Core_Approver_1__c = approvers[0];
                        oppsupp.Core_Approver_2__c = approvers[0];
                        oppsupp.Core_Approver_3__c = approvers[0];
                        oppsupp.Core_Approver_4__c = approvers[0];
                        oppsupp.Core_Approver_5__c = approvers[0];
                    }
                    else if (approvers.size() == 2){
                        oppsupp.Core_Approver_1__c = approvers[0];
                        oppsupp.Core_Approver_2__c = approvers[1];
                        oppsupp.Core_Approver_3__c = approvers[0];
                        oppsupp.Core_Approver_4__c = approvers[0];
                        oppsupp.Core_Approver_5__c = approvers[0];
                    }
                    else if (approvers.size() == 3){
                        oppsupp.Core_Approver_1__c = approvers[0];
                        oppsupp.Core_Approver_2__c = approvers[1];
                        oppsupp.Core_Approver_3__c = approvers[2];
                        oppsupp.Core_Approver_4__c = approvers[0];
                        oppsupp.Core_Approver_5__c = approvers[0];
                    }
                    else if (approvers.size() == 4){
                        oppsupp.Core_Approver_1__c = approvers[0];
                        oppsupp.Core_Approver_2__c = approvers[1];
                        oppsupp.Core_Approver_3__c = approvers[2];
                        oppsupp.Core_Approver_4__c = approvers[3];
                        oppsupp.Core_Approver_5__c = approvers[0];
                    }
                    else if (approvers.size() == 5){
                        oppsupp.Core_Approver_1__c = approvers[0];
                        oppsupp.Core_Approver_2__c = approvers[1];
                        oppsupp.Core_Approver_3__c = approvers[2];
                        oppsupp.Core_Approver_4__c = approvers[3];
                        oppsupp.Core_Approver_5__c = approvers[4];
                    }*/
                }
            } 
       
			for(OpportunityShare userInOppsgare : [select id ,OpportunityId,OpportunityAccessLevel,RowCause,UserOrGroupId from OpportunityShare where OpportunityId IN: OpportunityId and UserOrGroupId IN: userListOppShare])
			{
				if(OppUserMap.containsKey(userInOppsgare.OpportunityId+'_'+userInOppsgare.UserOrGroupId) && userInOppsgare.RowCause == 'Owner')
					OppUserMap.remove(userInOppsgare.OpportunityId+'_'+userInOppsgare.UserOrGroupId);
				
			} 
			if(OppUserMap.size() > 0)
				insert OppUserMap.values();
        
    }
   
    public static void addSupportToOpprotunityTeam(Map<Id,Core_Opportunity_Support__c> triggerOldMap, List<Core_Opportunity_Support__c> triggerNew){
        List<Core_Opportunity_Support__c> opportunitiesSuportApprovered = new List<Core_Opportunity_Support__c>();
        List<Core_Opportunity_Support__c> opportunitySuportCancelled = new List<Core_Opportunity_Support__c>();
         List<Id> OppSuppReqId = new List<Id>();
        //check for Approved record
        //string recordtypeMS='CRM_Marketing_Support';
        string recordtypeMSId=  Schema.SObjectType.Core_Opportunity_Support__c.getRecordTypeInfosByDeveloperName().get('CRM_Marketing_Support').getRecordTypeId();
        
        for (Core_Opportunity_Support__c opp_supp : triggerNew) {
            OppSuppReqId.add(opp_supp.id);
            if(opp_supp.Core_Status__c == 'Approved' && opp_supp.Core_Status__c != triggerOldMap.get(opp_supp.id).Core_Status__c && triggerOldMap.get(opp_supp.id).Core_Status__c !='Rejected' && opp_supp.RecordTypeId != recordtypeMSId)
                opportunitiesSuportApprovered.add(opp_supp);
          
             if(opp_supp.Core_Status__c == 'Cancelled' && opp_supp.Core_Status__c != triggerOldMap.get(opp_supp.id).Core_Status__c)
                opportunitySuportCancelled.add(opp_supp);
            
            
        }
        if(opportunitiesSuportApprovered.size() > 0){
            //List<OpportunityTeamMember> oppToShare = new List<OpportunityTeamMember>();           
            
            //List of user details tag to Opp support
            try {                
                Map<id,Core_Opportunity_Support__c> mapOppsup = new Map<Id, Core_Opportunity_Support__c>(opportunitiesSuportApprovered);
               
                Core_EmailNotification job = new Core_EmailNotification(mapOppsup.keySet(), 'Core_Oppty_Support_Approve_Reject',true);
                System.enqueueJob(job, 2);
                
                //Core_EmailNotification.sendNotificationApprover(mapOppsup.keySet(),'Core_Oppty_Support_Approve_Reject');
                List<Core_Opportunity_Support_Team__c> updateSupportTeam = [select id, Core_Status__c from Core_Opportunity_Support_Team__c where Core_Opportunity_Support__c IN : mapOppsup.keySet() AND Core_Status__c='New'];// AND Core_Status__c Not IN ('Denied','Accepted')
                for(Core_Opportunity_Support_Team__c temTeam : updateSupportTeam){
                     temTeam.Core_Status__c  = 'Accepted';
                   	 temTeam.Core_Approval_Comment__c = 'Auto Approved';
                }
				if(updateSupportTeam.size() > 0)
                    update updateSupportTeam;
               
                
            } catch (Exception e) {
                Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='Core_OpportunitySupportShare',Core_Method_Name__c ='Adding user to Opp team',Core_IPS_Object_Name__c = 'OpportunityTeamMember');
                insert excep;
            } 
        }
         if(opportunitySuportCancelled.size() > 0){
             try{
         Map<id,Core_Opportunity_Support__c> OppSuppMap = new Map<Id, Core_Opportunity_Support__c>(opportunitySuportCancelled);
                               
		 List<Core_Opportunity_Support_Team__c> updateSupportTeam1 = [select id, Core_Status__c from Core_Opportunity_Support_Team__c where Core_Opportunity_Support__c IN : OppSuppMap.keySet()];
                 for(Core_Opportunity_Support_Team__c temTeam1 : updateSupportTeam1){
                     temTeam1.Core_Status__c  = 'Cancelled';
                     temTeam1.Core_Approval_Comment__c  = 'Recalled by Approver';//confirm once
                }
				if(updateSupportTeam1.size() > 0)
                {
                    update updateSupportTeam1;
                }
                 
                 
                
            } catch (Exception e) {
                Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='Core_OpportunitySupportShare',Core_Method_Name__c ='Adding user to Opp team',Core_IPS_Object_Name__c = 'OpportunityTeamMember');
                insert excep;
            } 
         }
        
        
    }
    
    
    

    public static void checkOppSupportTeam(List<Core_Opportunity_Support__c> triggerNew ,Map<Id,Core_Opportunity_Support__c> triggerNewMap,Map<Id,Core_Opportunity_Support__c> triggerOldMap)
    {
        
        //string recordtypeMS='CRM_Marketing_Support';
        string recordtypeMSId=  Schema.SObjectType.Core_Opportunity_Support__c.getRecordTypeInfosByDeveloperName().get('CRM_Marketing_Support').getRecordTypeId();
        try{
            List<Id> OppSuppReqId = new List<Id>();
            //Map<Id,String> oppSuppReqMapIdStatus = new Map<Id,String>();
            //List<Id> toTrackLastedOppId = new List<Id>();
            for(Core_Opportunity_Support__c opp: triggerNew){
                if((opp.Core_Status__c == 'Approved' || opp.Core_Status__c == 'Rejected' ) && opp.Core_Status__c != triggerOldMap.get(opp.id).Core_Status__c  )// add status check only for approved record                  
                    OppSuppReqId.add(opp.Id);
                if(opp.Core_Status__c == 'Approved' && opp.Core_Opportunity_Support_Team_Count__c == 0 && opp.RecordTypeId != recordtypeMSId){
                    opp.addError(Core_CRM_Utility.getCRMLabel('CRM_OpportunitySuppTeamMember'));
                }
                if(opp.Core_Status__c == 'Rejected' && opp.Core_Opportunity_Support_Team_Count__c != 0 && triggerOldMap.get(opp.id).Core_Status__c == 'Submitted' ){
                    opp.addError(Core_CRM_Utility.getCRMLabel('CRM_RemoveTeamMemBeforeReject'));
                }
            } 
        }
        catch (Exception e) {
            Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='Core_OpportunitySupportServiceHandler',Core_Method_Name__c ='checkOppSupportTeam',Core_IPS_Object_Name__c = 'Core_Opportunity_Support__c');
            insert excep;
        }
    }
    
    public static void updateApproveOrRejectComents(List<Core_Opportunity_Support__c> triggerNew ,Map<Id,Core_Opportunity_Support__c> triggerOldMap){
        Set<Id> OppSuppReqId = new Set<Id>();
        //List<Id> toTrackLastedOppId = new List<Id>();
        Set<Id> OppSuppReqIdRejected = new Set<Id>();
        //string recordtypeMS='CRM_Marketing_Support';
        string recordtypeMSId=  Schema.SObjectType.Core_Opportunity_Support__c.getRecordTypeInfosByDeveloperName().get('CRM_Marketing_Support').getRecordTypeId();
        for(Core_Opportunity_Support__c opp: triggerNew){
            if((opp.Core_Status__c == 'Approved' || opp.Core_Status__c == 'Rejected' ) && opp.Core_Status__c != triggerOldMap.get(opp.id).Core_Status__c && opp.RecordTypeId != recordtypeMSId)// add status check only for approved record
                OppSuppReqId.add(opp.Id);   
            if(opp.Core_Status__c == 'Rejected' && triggerOldMap.get(opp.id).Core_Status__c == 'Submitted')
                OppSuppReqIdRejected.add(opp.Id);
        }
        
        if(OppSuppReqId.size() > 0 ){
            //Queue Job to update Approval Comments reusing same Queueable
            Core_EmailNotification job = new Core_EmailNotification(OppSuppReqId, '',false);
            System.enqueueJob(job, 1);
        }
        if(OppSuppReqIdRejected.size() > 0){
            Core_EmailNotification job2 = new Core_EmailNotification(OppSuppReqId, 'Core_Oppty_Support_Approve_Reject',true);
            System.enqueueJob(job2, 2);
        }
        
    }
    

 
}