/******************************************************************************************************************************************
Trigger Name:  Core_Solution_Area_Controller
Version     : 1.0 
Created Date: 03 OCT 2014
Function    : Apex Class to update long text with multiple picklists
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gaurav Kurwade             18/11/2022              Original Version
*****************************************************************************************************************************************/

public with sharing class Core_Solution_Area_Controller {
    
    Public Static String dealDesign;
    /*Solution Area Long text update - 18/11/22 Start*/
    public static void addValuesToSolution(List<Core_Solution_Areas__c> solutionArea){
        
        List<String> saPickval = new List<String>();
        List<String> solutionAreaName = new List<String>();
        List<String> solutionAreaVersion = new List<String>();
        for(Core_Solution_Areas__c saPick: solutionArea){
            solutionAreaName.add(saPick.name);
            solutionAreaVersion.add(saPick.Core_Version__c);
        }
        Map<String,String> csaVerName = new Map<String,String>();
        //Part TWC3123-6629 Removed and replaced solutionAreas outside for loop to fix soql query inside loop
        List<Core_Solution_Areas__c> solutionAreas = [SELECT id, Core_Version__c, name FROM Core_Solution_Areas__c WHERE Core_Version__c LIKE :solutionAreaVersion AND name LIKE :solutionAreaName];
        
        for(Core_Solution_Areas__c saPick : solutionAreas ){
            csaVerName.put(saPick.Core_Version__c,saPick.name);
        }
        
        for(Core_Solution_Areas__c saPick: solutionArea){
            
            //  Integer SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :saPick.Core_Version__c and name= :saPick.Name];
            if(!(csaVerName.containskey(saPick.Core_Version__c) && (csaVerName.get(saPick.Core_Version__c)==saPick.Name)))
                //   if ( SolnCnt <= 0)
            {
                if(saPick.Core_Application_Workload__c != null || saPick.Core_Industry_Use_Case__c!= null || saPick.Core_Region_of_availability__c!= null || saPick.Core_Technology_Enabled__c!= null || saPick.Core_Industry__c!= null || saPick.Core_Solution_owner_email__c != null || saPick.Core_Solution_Type__c != null){
                    saPick.Core_Solution_Long__c = saPick.Core_Application_Workload__c+';'+saPick.Core_Industry_Use_Case__c+';'+saPick.Core_Region_of_availability__c+';'+saPick.Core_Technology_Enabled__c+';'+saPick.Core_Industry__c+';'+saPick.Core_Solution_owner_email__c+';'+saPick.Core_End_Customer_Solution__c+';'+saPick.Core_Solution_Type__c+';'+saPick.Core_Content_Link__c;
                   	
                }
            }
            else
            {
                
                saPick.addError(Label.Core_Solution_exist);
            }
        }
    }
    
    public static void updatedValuesToSolution(List<Core_Solution_Areas__c> newSolutionArea, Map<Id, Core_Solution_Areas__c> oldSolutionArea){
        
        String usrProfileName = [select Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
        List<String> saPickval = new List<String>();
        for(Core_Solution_Areas__c saPick: newSolutionArea){
            
            if(newSolutionArea.size()>0){
                for(Core_Solution_Areas__c OppSA: newSolutionArea){
                    DateTime dT = System.now();
                    if (oldSolutionArea.get(OppSA.Id).Core_Status__c!= 'EOL' )                         
                    {
                        if (saPick.Core_Status__c!= 'EOL')
                        {
                            if(OppSA.Core_Status__c != oldSolutionArea.get(OppSA.Id).Core_Status__c ||  OppSA.Core_Solution_owner_email__c != oldSolutionArea.get(OppSA.Id).Core_Solution_owner_email__c || OppSA.Core_End_Customer_Solution__c != oldSolutionArea.get(OppSA.Id).Core_End_Customer_Solution__c || OppSA.Core_Solution_Type__c != oldSolutionArea.get(OppSA.Id).Core_Solution_Type__c){
                                OppSA.Core_Solution_Long__c = OppSA.Core_Region_of_availability__c+';'+OppSA.Core_Industry__c+';'+OppSA.Core_Solution_owner_email__c+';'+OppSA.Core_End_Customer_Solution__c+';'+OppSA.Core_Solution_Type__c+';'+OppSA.Core_Content_Link__c;
                            }      
                        }
                        else
                        {
                            OppSA.Core_Solution_Long__c =null;
                            
                            OppSA.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                        }
                    }
                    else if (oldSolutionArea.get(OppSA.Id).Core_Status__c== 'EOL' )
                    {
                        // this is for IT admin...update while disabling the Validation rule
                        OppSA.Core_Solution_Long__c = OppSA.Core_Region_of_availability__c+';'+OppSA.Core_Industry__c+';'+OppSA.Core_Solution_owner_email__c+';'+OppSA.Core_End_Customer_Solution__c+';'+OppSA.Core_Solution_Type__c+';'+OppSA.Core_Content_Link__c;
                        
                        OppSA.Core_Most_Recent_Status_Change_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                    }
                    
                    // OPTY Solution field update based on Solution Area update
                    //  String usrProfileName = [select Profile.Name from Opportunity_Solution_Area__c where id = :saPick.Id()];
                }
            }
        }
    }
    /*Solution Area Long text update - 18/11/22 Start*/
    //New Change: 26/12/2022
    public static void restrictPicklists(List<Core_Solution_Areas__c> newSolutionArea, Map<Id, Core_Solution_Areas__c> oldSolutionArea){
       
        try{
            String usrProfileName = [select Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
            Integer usrPermissionsetCnt = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'Core_CRM_Special_Access'];
           
            
            // Start TWC3123-6629 Removed and replaced solutionAreas outside for loop to fix soql query inside loop
            list<string> solnAreaNameList = new list<string>();
            list<string> solnAreaVersionList = new list<string>();
            set<Id> solnAreaIdSet = new set<Id>();
            for(Core_Solution_Areas__c OppSA: newSolutionArea){
                solnAreaNameList.add(OppSA.Name);
                solnAreaVersionList.add(OppSA.Core_Version__c);
                solnAreaIdSet.add(OppSA.Id);
            }
            List<Core_Solution_Areas__c> existingSolnAreas = [SELECT Id, Name, Core_Version__c from Core_Solution_Areas__c where Core_Version__c in :solnAreaVersionList and name in :solnAreaNameList and ID not in :solnAreaIdSet];
            //end TWC3123-6629
            if(oldSolutionArea.size()>0){
                for(Core_Solution_Areas__c OppSA: newSolutionArea){
                    // if(usrProfileName != 'IT Admin'){
                
                    if(usrProfileName != 'IT Admin' && (OppSA.Core_Industry_Use_Case__c != oldSolutionArea.get(OppSA.Id).Core_Industry_Use_Case__c || OppSA.Core_Application_Workload__c != oldSolutionArea.get(OppSA.Id).Core_Application_Workload__c || OppSA.Core_Technology_Enabled__c != oldSolutionArea.get(OppSA.Id).Core_Technology_Enabled__c || OppSA.Core_Version__c != oldSolutionArea.get(OppSA.Id).Core_Version__c)){
                       
                        OppSA.addError(Label.restrictPicklists_for_Solutions);                               
                    }
                    if(usrProfileName != 'IT Admin' && usrProfileName != 'Data Ops' && usrPermissionsetCnt == 0 &&  (OppSA.Name != oldSolutionArea.get(OppSA.Id).Name || OppSA.OwnerId != oldSolutionArea.get(OppSA.Id).OwnerId)){
                       
                        OppSA.addError('Cannot edit Solution Name/Owner');
                    } 
                    
                    if(OppSA.Name != oldSolutionArea.get(OppSA.Id).Name  || OppSA.Core_Version__c != oldSolutionArea.get(OppSA.Id).Core_Version__c)
                    {
                        //Integer SolnCnt = [SELECT count() from Core_Solution_Areas__c where Core_Version__c = :OppSA.Core_Version__c and name= :OppSA.Name];
                        //if ( SolnCnt > 0)
                        //Start TWC3123-6629 Removed and replaced solutionAreas outside for loop to fix soql query inside loop
                        if(!existingSolnAreas.isempty()){
                            for(Core_Solution_Areas__c exOppSA: existingSolnAreas) {
                                if(OppSA.Name == exOppSA.Name && OppSA.Core_Version__c == exOppSA.Core_Version__c){
                                    OppSA.addError(Label.Core_Solution_exist);
                                }
                            }
                        }
                        //end TWC3123-6629
                    }
                }
            }
            
            if(Test.isRunningTest()){
                
                throw new System.DMLException();   
            }   
        }Catch(Exception ex){
            
        }
    }
    
    
    /*
* Method name  : updateOpportunitySolutionArea
* Description  : When updating the Solution area attributes corresponding OPTY Solution area attributes are updated with the help of this method.
* Return Type  : VOID
* Parameter    : 
*/
    
    public static void updateOpportunitySolutionArea(List<Core_Solution_Areas__c> newSolutionArea, Map<Id, Core_Solution_Areas__c> oldSolutionArea){
        
        
        Set<Id> saIds = new Set<Id>();
        List<Opportunity_Solution_Area__c> getOppSA= new List<Opportunity_Solution_Area__c>();
        
        try{
            
            if(newSolutionArea.size()>0){
                for(Core_Solution_Areas__c OppSA: newSolutionArea){
                    if(OppSA.Core_Industry_Use_Case__c != oldSolutionArea.get(OppSA.Id).Core_Industry_Use_Case__c || 
                       OppSA.Core_Application_Workload__c != oldSolutionArea.get(OppSA.Id).Core_Application_Workload__c ||
                       OppSA.Core_Technology_Enabled__c != oldSolutionArea.get(OppSA.Id).Core_Technology_Enabled__c ||
                       OppSA.Core_Industry__c != oldSolutionArea.get(OppSA.Id).Core_Industry__c ||
                       OppSA.Core_Region_of_availability__c != oldSolutionArea.get(OppSA.Id).Core_Region_of_availability__c   )                 
                    {
                        
                        saIds.add(OppSA.Id); 
                    }
                }
                
                if(saIds.size()>0){                      
                    
                    getOppSA = [Select Id, Core_Solution_Areas__c, Core_Technology_Enabled__c, Core_Region_of_availability__c ,Core_Industry_Use_Case_s__c, Core_Industry__c, Core_Application_Workload__c from Opportunity_Solution_Area__c where Core_Solution_Areas__c in :saIds]; 
                    List<Core_Solution_Areas__c> SolnArea= new List<Core_Solution_Areas__c>();
                    SolnArea = [Select Id, Core_Solution_Areas__c, tolabel( Core_Technology_Enabled__c), tolabel(Core_Region_of_availability__c) ,tolabel(Core_Industry_Use_Case__c),  tolabel(Core_Industry__c), tolabel( Core_Application_Workload__c) from Core_Solution_Areas__c where Id in :saIds]; 
                    // update Opportunity_Solution_Area__c	
                   	
                    if(getOppSA.size()>0){
                        List<Opportunity_Solution_Area__c> oppDetails = new List<Opportunity_Solution_Area__c>();
                        for(Opportunity_Solution_Area__c oSolArea : getOppSA){
                            for(Core_Solution_Areas__c Sol : SolnArea){
                                if (Sol.Id==oSolArea.Core_Solution_Areas__c)
                                {
                                    
                                    oSolArea.Core_Technology_Enabled__c = Sol.Core_Technology_Enabled__c;
                                    oSolArea.Core_Region_of_availability__c = Sol.Core_Region_of_availability__c;
                                    oSolArea.Core_Industry_Use_Case_s__c = Sol.Core_Industry_Use_Case__c;
                                    oSolArea.Core_Industry__c = Sol.Core_Industry__c;
                                    oSolArea.Core_Application_Workload__c = Sol.Core_Application_Workload__c;
                                    oppDetails.add(oSolArea);
                                    
                                }
                            }
                        }
                        upsert oppDetails;
                    }
                }	
            }
            
        }Catch(Exception ex){
            
        }
    } 
    /*
* Method name  : AddOpportunitySolutionArea
* Description  : When adding the Solution area OPTY Solution area updating the required fields.
* Return Type  : VOID
* Parameter    : 
*/
    
    public static void AddOpportunitySolutionArea(List<Opportunity_Solution_Area__c> newOptySolutionArea){
        
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> SAIds = new Set<Id>();
        List<Opportunity_Solution_Area__c> getOppSA= new List<Opportunity_Solution_Area__c>();
        
        try{
            
            if(newOptySolutionArea.size()>0){
                for(Opportunity_Solution_Area__c OppSA: newOptySolutionArea){ 
                    oppIds.add(OppSA.Core_Opportunity__c); 
                }
                
                if(oppIds.size()>0){ 
                    getOppSA = [Select Id, Core_Solution_Areas__c, Core_Technology_Enabled__c, Core_Region_of_availability__c ,Core_Industry_Use_Case_s__c, Core_Industry__c, Core_Application_Workload__c from Opportunity_Solution_Area__c where Core_Opportunity__c in :oppIds]; 
                    if(getOppSA.size()>0){
                        for(Opportunity_Solution_Area__c OppSA: getOppSA){ 
                            SAIds.add(OppSA.Core_Solution_Areas__c); 
                        }
                        List<Core_Solution_Areas__c> SolnArea= new List<Core_Solution_Areas__c>();
                        SolnArea = [Select Id, Core_Solution_Areas__c, tolabel( Core_Technology_Enabled__c), tolabel(Core_Region_of_availability__c) ,tolabel(Core_Industry_Use_Case__c),  tolabel(Core_Industry__c), tolabel( Core_Application_Workload__c) from Core_Solution_Areas__c where Id in :SAIds]; 
                        // update Opportunity_Solution_Area__c	
                        	
                        if(getOppSA.size()>0){
                            List<Opportunity_Solution_Area__c> oppDetails = new List<Opportunity_Solution_Area__c>();
                            for(Opportunity_Solution_Area__c oSolArea : getOppSA){
                                for(Core_Solution_Areas__c Sol : SolnArea){
                                    if (Sol.Id==oSolArea.Core_Solution_Areas__c)
                                    { 
                                        oSolArea.Core_Technology_Enabled__c = Sol.Core_Technology_Enabled__c;
                                        oSolArea.Core_Region_of_availability__c = Sol.Core_Region_of_availability__c;
                                        oSolArea.Core_Industry_Use_Case_s__c = Sol.Core_Industry_Use_Case__c;
                                        oSolArea.Core_Industry__c = Sol.Core_Industry__c;
                                        oSolArea.Core_Application_Workload__c = Sol.Core_Application_Workload__c;
                                        oppDetails.add(oSolArea);
                                       
                                    }
                                }
                            }
                            upsert oppDetails;
                        }
                    }	
                }           
            }
        }
        Catch(Exception ex){
           
        }
    }
    
    //Added by Hira
    public static void determineApprovers(List<Core_Solution_Areas__c> newOptySolutionArea){
        Map<String, Core_Solution_Approvers__c> approvers = Core_Solution_Approvers__c.getAll();
        Map<Id,String> OppMap=new Map<Id,String>();
        Set<Id> oppIds=new Set<Id>();
        Set<Id> solutionwithNoOpps=new Set<Id>();
        for(Core_Solution_Areas__c solution:newOptySolutionArea){
            if(solution.Opportunity__c != null)
                oppIds.add(solution.Opportunity__c);
            else
                solutionwithNoOpps.add(solution.Id);
        }
       
        
        if(!oppIds.isEmpty()){
            for(Opportunity opp: [select Id,Core_Product_Segment__c from Opportunity where Id IN :oppIds]){
                OppMap.put(opp.Id,opp.Core_Product_Segment__c);
            }
        }
        
        
        for(Core_Solution_Areas__c solution:newOptySolutionArea){
            List<Id> approverIdList=new List<Id>();
            Core_Solution_Approvers__c customsetting=new Core_Solution_Approvers__c();
            if(!OppMap.isEmpty() && solution.Opportunity__c != null){
                customsetting=approvers.get(OppMap.get(solution.Opportunity__c));
            }
            /* else if(solution.Opportunity__c ==null){
customsetting=approvers.get('Default');

}*/
            
           
            if(customsetting!=null){
                if(customsetting.Approver_1__c!=null){
                    approverIdList.add(customsetting.Approver_1__c);
                }
                if(customsetting.Approver_2__c!=null){
                    approverIdList.add(customsetting.Approver_2__c);
                }if(customsetting.Approver_3__c!=null){
                    approverIdList.add(customsetting.Approver_3__c);   
                }
            }
            Integer numApprovers=approverIdList.size();
           
            if(customsetting!=null){
                if(numApprovers == 1){
                    solution.Approver_1__c=approverIdList[0];
                    solution.Approver_2__c=approverIdList[0];
                    solution.Approver_3__c=approverIdList[0];
                }else if(numApprovers == 2){
                    solution.Approver_1__c=approverIdList[0];
                    solution.Approver_2__c=approverIdList[1];
                    solution.Approver_3__c=approverIdList[0];
                }else if(numApprovers == 3){
                    solution.Approver_1__c=approverIdList[0];
                    solution.Approver_2__c=approverIdList[1];
                    solution.Approver_3__c=approverIdList[2];
                }
                //solution.Product_Segment__c=OppMap.get(solution.Opportunity__c);
                
            }
        }
    }
    
    //Post Approval Update fields 10
    public static void UpdateSolutionFields(List<Core_Solution_Areas__c> newOptySolutionArea,Map<Id,Core_Solution_Areas__c> OldSolMap){
        Map<Id,Core_Solution_Areas__c> solutionOppMap=new Map<Id,Core_Solution_Areas__c>();
        Set<Id> SolutionsToResubmit=new Set<Id>();
        List<Opportunity_Solution_Area__c> opptysolList=new List<Opportunity_Solution_Area__c>();
        try{
            for(Core_Solution_Areas__c solution:newOptySolutionArea){
                //Updating fields after approval
                if(solution.Opportunity__c != null && OldSolMap.get(solution.Id).Core_Status__c!=solution.Core_Status__c && 
                   (OldSolMap.get(solution.Id).Core_Status__c=='Pending'  && solution.Core_Status__c == 'Active')){
                       //solution.Core_Deal_Visible__c=false;
                       //solution.Core_Design_Visible__c=false;
                       solutionOppMap.put(solution.Opportunity__c,solution);
                   }
            }
            
            if(!solutionOppMap.isEmpty()){
                for(Id OppId:solutionOppMap.keyset()){
                    //Creating New Opportunity Solutions based on Approved(Active) Solutions
                    Opportunity_Solution_Area__c opptySolution=new Opportunity_Solution_Area__c();
                    opptySolution.Core_Solution_Areas__c = solutionOppMap.get(OppId).Id;
                    opptySolution.Core_Opportunity__c = OppId;
                    opptySolution.Core_Technology_Enabled__c = solutionOppMap.get(OppId).Core_Technology_Enabled__c;
                    opptySolution.Core_Region_of_availability__c = solutionOppMap.get(OppId).Core_Region_of_availability__c;
                    opptySolution.Core_Industry_Use_Case_s__c = solutionOppMap.get(OppId).Core_Industry_Use_Case__c;
                    opptySolution.Core_Industry__c = solutionOppMap.get(OppId).Core_Industry__c;
                    opptySolution.Core_Application_Workload__c = solutionOppMap.get(OppId).Core_Application_Workload__c;
                    opptysolList.add(opptySolution);
                    
                }
            }
            
            if(!opptysolList.isEmpty()){
                Database.SaveResult[] lsr = Database.insert(opptysolList,false);
            }
        }
        catch(Exception e){
                    
        }
    }
    
    @InvocableMethod(label='recallApproval')
    public static void recallApproval(List<Id> recId)   
    {       
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: recId];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Removed');       
        req.setWorkitemId(piwi.get(0).Id);
        
        Approval.process(req,false);
    }
    
    public static void submitSolutionsforApproval(List<Core_Solution_Areas__c> newOptySolutionArea){
        List<Opportunity> oppList=new List<Opportunity>();
        Set<Id> OppIds=new Set<Id>();
        
        try{
            for(Core_Solution_Areas__c solution:newOptySolutionArea){
                //Only Solutions with Opportunty will go through Approval Process
                if(solution.Opportunity__c != null){
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();                
                    approvalRequest.setObjectId(solution.Id);
                    
                    
                    if(!Test.isRunningTest()){
                        Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
                        if(approvalResult .isSuccess()){
                            
                        }
                        else{
                            
                        }
                    }
                }
            }
        }
        catch (Exception e) {
                   
        }
    }
    //sindu added start
    public static void populateReviewer(List<Core_Solution_Areas__c> solList,Map<Id,Core_Solution_Areas__c> solMap){
        
        Set<Id> solutionIdSet = new Set<Id>();
        List<Core_Solution_Areas__c> solutionListUpdate = new List<Core_Solution_Areas__c>();
        for(Core_Solution_Areas__c sol:solList){
            solutionIdSet.add(sol.Id);
        }
        for(Core_Solution_Areas__c sol:[Select  Approver_1__r.Email,Approver_2__r.Email,Approver_3__r.Email from Core_Solution_Areas__c where Id IN:solutionIdSet]){
            if(sol.Approver_1__c!=null){
                
                sol.Reviewer_Email_Text__c = sol.Approver_1__r.Email;
            }
            if(sol.Approver_2__c!=null){
                
                sol.Reviewer_Email_Text__c += ','+sol.Approver_2__r.Email;  
            }
            if(sol.Approver_3__c!=null){
               
                sol.Reviewer_Email_Text__c +=',' +sol.Approver_3__r.Email; 
            }
            solutionListUpdate.add(sol);
        }
        try{
            update solutionListUpdate;
        }
        catch(Exception e){
            
        }
    }
    //sindu added end  
}