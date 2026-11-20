/**************************************************************************************
Apex Class Name:  Core_OppSupTeamAccOrRej
Version     : 1.0 
Created Date: 18 MAR 2023
Function    : 
Test Class Name: Core_OpptySupportServiceHandlerTest
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Vijay					  18/04/2023			  To show Accept or Deined Opp Support Requets
*************************************************************************************/

//Class is without sharing to show data to Opportunity Support team member.
public  without sharing class Core_OppSupTeamAccOrRej {
    
     @AuraEnabled(cacheable=true)
    public static List<Core_Opportunity_Support_Team__c> checkUserformOppteam(Id userID){
        List<Core_Opportunity_Support_Team__c> checkUser = new List<Core_Opportunity_Support_Team__c>();
        //system.debug('user id'+userID);
        try{
            checkUser =  [select id ,name ,Core_Opportunity_Support__r.Core_CoE_Request_Detail__c,Core_Opportunity_Support__r.Center_of_Excellence__c,Core_Opportunity_Support__r.Opportunity__r.Account.name ,Core_Opportunity_Support__r.RecordType.Name,Core_Opportunity_Support__r.RecordType.DeveloperName,Core_Opportunity_Support__r.Core_Sales_Stages__c, Core_Opportunity_Support__r.Core_Opportunity_Name__c,Core_Opportunity_Support__r.Core_Account_Name__c,Core_Opportunity_Support_Team_Member__c,Core_Opportunity_Support__c ,Core_Opportunity_Support__r.Core_Amount__c,Core_Opportunity_Support__r.Core_Additional_Support_Needed__c,Core_Opportunity_Support__r.Core_Approved_By_c__c , 
                                                             Core_Opportunity_Support__r.Core_background_info_on_architecture__c,Core_Opportunity_Support__r.Core_Decision_Date__c,Core_Opportunity_Support__r.Core_Opportunity_Description__c,Core_Opportunity_Support__r.Core_Opportunity_Support_Team_Count__c,Core_Opportunity_Support__r.Core_PrimaryBlockers__c ,Core_Opportunity_Support__r.Core_Product_Application__c , Core_Opportunity_Support__r.Core_Product_Segment__c ,Core_Opportunity_Support__r.Core_Region__c ,
                                                             Core_Opportunity_Support__r.Sales_Group__c,Core_Opportunity_Support__r.Core_Technical_Owner__c,Core_Opportunity_Support__r.Core_TSS_Support_Type__c,Core_Opportunity_Support__r.Core_Vertical_Market__c from Core_Opportunity_Support_Team__c where Core_Opportunity_Support_Team_Member__c =:userID and core_Status__c = 'Pending' WITH SECURITY_ENFORCED order by createddate desc];//TWC3123-5299 Added WITH SECURITY_ENFORCED
        }
        catch(Exception e){
            Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'An exception has been thrown for:Class.Core_OppSupTeamAccOrRej.checkUserformOppteam',Core_Details__c = e.getMessage(), Core_Origin__c='Core_OppSupTeamAccOrRej', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Unicorn');
            //Database.insert(logEntry, false);
        
        }
        
       //system.debug('checkUser' + checkUser);        
        return checkUser;
        
    }
    
    @AuraEnabled
    public static  boolean updateStatusOppRequestTeam(string status,Id recordID, string comments,Core_Opportunity_Support_Team__c OppSupTeam){
        /*system.debug('--id @@@-'+status);
        system.debug('--recordID @@@-'+recordID);
        system.debug('@@ --'+ OppSupTeam);*/
        integer acceptCount = 0;
        integer deniedCount = 0;
        integer pendingCount = 0;
        
		Core_Opportunity_Support_Team__c updateUserstatus = [select id,Core_Approval_Comment_History__c,Core_Status__c,Core_Approval_Comment__c,Core_Opportunity_Support_Team_Member__r.id, Core_Opportunity_Support__r.id,LastModifiedBy.Email,Core_Opportunity_Support_Team_Member__r.Email  from Core_Opportunity_Support_Team__c  where id =: recordID WITH SECURITY_ENFORCED];//TWC3123-5299 Added WITH SECURITY_ENFORCED
        Core_Opportunity_Support__c oppSuppReq = new Core_Opportunity_Support__c();
        //updateUserstatus.id = recordID;
        string prevoiuscomments = updateUserstatus.Core_Approval_Comment_History__c != null ? updateUserstatus.Core_Approval_Comment_History__c : ' ';
        set<id> supId =  new set<id>();
        updateUserstatus.Core_Status__c = status;
        updateUserstatus.Core_Approval_Comment__c =   comments;
        updateUserstatus.Core_Approval_Comment_History__c = Datetime.now() +' '+ UserInfo.getName() +' :' +comments+' \n '+prevoiuscomments;
        //system.debug('comments --' +updateUserstatus);
        
        try{
            //TWC3123-5299 Added isUpdateable check
			if(Schema.sObjectType.Core_Opportunity_Support_Team__c.isUpdateable()){
            	update updateUserstatus;
            }
            if(status == 'Denied'){
                //Core_Opportunity_Support_Team__c getSuppRequest = [select id,Core_Opportunity_Support_Team_Member__r.id, Core_Opportunity_Support__r.id,LastModifiedBy.Email,Core_Opportunity_Support_Team_Member__r.Email  from Core_Opportunity_Support_Team__c  where id =: recordID];
                supId.add(updateUserstatus.Core_Opportunity_Support__r.id);
                Core_EmailNotification.denyRequestEmail(supId,'Opportunity_Support_Team_Member_Approve',updateUserstatus.Core_Opportunity_Support_Team_Member__r.id,updateUserstatus);//Opportunity_Support_Team_Member_Denies
                
            }
            //Areefa
            //Core_Opportunity_Support_Team__c oppSuppTeam = [select id,Core_Status__c, Core_Opportunity_Support__c from Core_Opportunity_Support_Team__c where id=:recordID];
            
            
            For(Core_Opportunity_Support_Team__c checkOtherUserStatus : [select id,Core_Status__c, Core_Opportunity_Support__c from Core_Opportunity_Support_Team__c where Core_Opportunity_Support__c =: OppSupTeam.Core_Opportunity_Support__c WITH SECURITY_ENFORCED]) {//TWC3123-5299 Added WITH SECURITY_ENFORCED
                switch on checkOtherUserStatus.Core_Status__c {
                    when 'Pending'{
                        pendingCount =+ 1;}
                    when 'Accepted'{
                        acceptCount =+ 1;}
                    when 'Denied'{
                        deniedCount =+ 1;}                    
                }                
            }
            oppSuppReq.id = OppSupTeam.Core_Opportunity_Support__c;
            if( pendingCount == 0 && acceptCount > 0){
                oppSuppReq.Core_Status__c = 'Approved'; 
                //TWC3123-5299 Added isUpdateable
                if(Schema.sObjectType.Core_Opportunity_Support__c.isUpdateable()){
                    update oppSuppReq;
                }  
            }  
            if( pendingCount == 0 && deniedCount > 0 && acceptCount == 0){
                oppSuppReq.Core_Status__c = 'Rejected'; 
                //TWC3123-5299 Added isUpdateable check
                 if(Schema.sObjectType.Core_Opportunity_Support__c.isUpdateable()){
                 	update oppSuppReq;  
                }
            }
                
           
        }catch (Exception e) {
            //system.debug('--error--'+e.getMessage());
            Core_Exceptions__c excep = new Core_Exceptions__c(Core_Exception__c = 'Failure : ########### - '+e.getStackTraceString()+' Cause'+e.getMessage(),Core_Class_Name__c ='Core_OpportunitySupport',Core_Method_Name__c ='updateStatusOppRequestTeam');
            //TWC3123-5299 Added isCreateable check
            if(Schema.sObjectType.Core_Exceptions__c.isCreateable()){
               insert excep; 
            }
            throw new AuraHandledException(e.getMessage());
        }        
        return true;
        
    }

}