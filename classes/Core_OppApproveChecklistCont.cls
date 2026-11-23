/**************************************************************************************
Apex Class Name:  Core_OppApproveChecklistCont
Version     : 1.0 
Created Date: 16/6/2017
Description : To the display Indicator for  Design or Deal  Opportunity Approval Checklist.
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajesh infy Team            16/6/2017               Initial Revision
* Rajesh                      13/3/2017               US99003-Removed Descriptive features in the  Deal Opportunities and added new logic for Solution Type and Details
* Ashwin Dash                 20/8/2017               US128964 - OPPTY: Proof of Performance Updates on Approval Checklist
* Ashwin Dash                 11/10/2018              US176261 - OPPTY: Update Logic for Approval Checklist to check for POP or Proof of Performance
* Ashwin Dash                 12/19/2018              US185496 - Oppty: Update Proof of Performance Logic to Consider Activities
* Mahesh                      11/1/2019               US218684-SMG 2019: Update Pre-Submit Check Page
* Venu Karumuru               10/31/2021              Updated logic to show Green for MINDS when Compliance Status = N/A
* Pratik Padwal               21/2/2023               Added Production win POP check.
* Pratik Padwal               8/5/2023                added checck for Opportunity Solutions - TWC3123-4164
* Areefa banu                 26/05/2023             removed CoE_Status__c from query of line55
* Areefa banu                 25/07/2023             Stage Gate Validation for PCC-  TWC4767-845
*************************************************************************************/
public with sharing class Core_OppApproveChecklistCont {
    public Opportunity oppty {get;set;}
    public Boolean BUShortName{get;set;}
    public Boolean WriteInProducts{get;set;}
    public Boolean QuantityValidate{get;set;}
    public Boolean Note_Attachmentsize{get;set;}
    public Boolean Opptypartnersize{get;set;}
    Public Boolean Pageblocksectionredender{get;set;}
    public Boolean Vendorsize{get;set;}
    public Boolean DescriptiveFeature{get;set;}
    Public Boolean  MAGFlag{get;set;}
    Public Boolean ProductionDate{get;set;}  
    public boolean firstCustomerShipDate{get;set;}
    // 'Pre-Submit Check view //
    Public Boolean ListtoReview {get;set;}
    Public Boolean ARReviewtheList{get;set;}
    Public Boolean Completeflag{get;set;}
    Public Boolean Approvedflag{get;set;}
    Public Boolean noLinkflag{get;set;}
    Public Boolean ExludeKPIflag{get;set;}
    public Boolean InactiveOppAccount{get;set;} //TWC3123-1204
    public Boolean InactiveVendorAccount{get;set;} //TWC3123-1204
    public Boolean ToBeDeletedPrd{get;set;}//TWC3123-2055
    public Boolean DecisionDateCheck{get;set;} //TWC3123-2131
    public Boolean PW_Note_Attachmentsize{get;set;}//TWC3123-3676
    public Boolean isOppotySolutionAdded{get;set;}//TWC3123-4164
    public Boolean isDescriptionOfContribution{get;set;}//TWC3123-4822
    Public Boolean ExcludeVolume{get;set;}//TWC4767-845 
    /*
    public Boolean isDevelopOrDesignAndGrowth{get;set;}//TWC3123-6061
    public Boolean isDevelopOrDesignAndCore{get;set;}//TWC3123-6061
    public Boolean DesiredEndState{get;set;} //TWC3123-6061
    public Boolean TechnologyAndReadinessGaps{get;set;} //TWC3123-6061
    public Boolean BusinessNeed{get;set;}//TWC3123-6061
    public Boolean TechnicalNeed{get;set;}//TWC3123-6061
    public Boolean isTaskCompleted1{get;set;}//TWC3123-6061
    public Boolean isTaskCompleted2{get;set;}//TWC3123-6061
    public Boolean FADStartDate{get;set;}//TWC3123-6061
    public Boolean FADEndDate{get;set;}//TWC3123-6061
    public Boolean CompetitiveThreatMitigation{get;set;}//TWC3123-6061
    public Boolean isTaskCompleted3{get;set;}//TWC3123-6061
    public Boolean CompetitiveThreatMitigation1{get;set;}//TWC3123-6061
    public Boolean OpportunityDevelopPlus{get;set;}//TWC3123-6061
    public Boolean CoreOpportunityDevelopPlus{get;set;}//TWC3123-6061
    public Boolean OpportunityDesignWin{get;set;}//TWC3123-6061
    public Boolean CoreOpportunityDesignWin{get;set;}//TWC3123-6061
    public Boolean WinAnalysisTask{get;set;}//TWC3123-6309
    */
    // 'Pre-Submit Check view //
    Public String OppId;
    public Core_OppApproveChecklistCont(ApexPages.StandardController stdController){
        oppty= (Opportunity)stdController.getRecord();
        OppId=ApexPages.currentPage().getParameters().get('id');
        try{
            if(String.isNotBlank(oppty.Id)){
            // added field TWC3123-1204
            //TWC3123-6061
            list<Opportunity> opplist = [select id,Core_Decimal_Check__c,Core_Quantity_count__c,Opportunity_Focus__c,Account.RecordType.name, Core_Opportunity_Type__c,Core_Product_At_Risk__c,Core_Military_Aerospace_Govmt_End_Use__c,Core_Compliance_Status__c,Core_Production_End_Date__c,Core_First_Customer_Ship_Date__c,StageName,Core_Oppty_Check_BU_Short_Name__c,Core_Write_In_Product_Count__c,Core_Competitive_Architecture__c,Description, Core_MAG_Account__c, Core_Status_Update__c,Core_Manufacturing_Geo__c,Core_Volume__c,Core_Solution_Type__c,Core_Solution_Detail__c,Core_Combined_Solution_Detail__c,Core_Exclude_From_KPIs__c,CloseDate,Core_Solution_Area_Count__c,Core_Opportunity_Coverage_Nm__c,Desired_End_State__c,Technology_and_Readiness_Gaps__c,Business_Need__c,Technical_Need__c,FAD_Start_Date__c,FAD_End_Date__c,Competitor_Threat_Mitigation__c,RecordType.DeveloperName  from Opportunity where id =: oppty.Id]; //, CoE_Status__c
            //added field TWC3123-1204
            List<OpportunityLineItem> opptyLineItemsList= [SELECT id, Name, Core_Vendor__r.RecordType.name, Core_Status__c, Core_BU_Short_Name__c, Core_Write_In_Product_Flag__c, Core_Vendor__c FROM OpportunityLineItem WHERE OpportunityId = :oppty.Id];
                if(!opplist.isEmpty()){
                    
                
            //added query TWC3123-1204
            //List<Core_Opportunity_Partner__c> opptyPartnerList= [SELECT id, Name, Core_Partner__r.RecordType.name from Core_Opportunity_Partner__c where Core_Opportunity__c = :oppty.Id];
            // TWC3123-1204 end
            //Added by Kavyashree HR(Infosys Team) for the US822091, an extra condition with Design: Software-enable is added
            if(opplist != null && opplist.size() > 0 && (opplist[0].Core_Opportunity_Type__c == 'Design: Original' || opplist[0].Core_Opportunity_Type__c == 'Design: Secondary' || opplist[0].Core_Opportunity_Type__c == 'Design: Software-enable')){
                Pageblocksectionredender=true;
            }else{
                Pageblocksectionredender=false;
            }
            // end TWC3123-1204
            //Check for firstCustomerShipDate
            if(opplist[0].Core_First_Customer_Ship_Date__c != null && String.valueOf(opplist[0].Core_First_Customer_Ship_Date__c) != '' && opplist[0].Core_First_Customer_Ship_Date__c > System.Today()){
                firstCustomerShipDate = true;
            }else{
                firstCustomerShipDate = false;
            }
            //TWC3123-2131 Decision Date updates (Start)
            
            if(opplist[0].CloseDate < System.Today() || opplist[0].CloseDate > System.Today().addDays(365)){
                DecisionDateCheck=true;
            }
            else
            {
                DecisionDateCheck=false;
            }
           
            //TWC3123-2131 Decision Date updates (end)
            //START-US218684-SMG 2019: Update Pre-Submit Check Page
            
            ExludeKPIflag=false;
            if(opplist[0].Core_Exclude_From_KPIs__c){
                ExludeKPIflag=true;
            }else if(opplist[0].Core_Exclude_From_KPIs__c=false){
                ExludeKPIflag=false;
            }
           
            
            //Areefa:[TWC4767-845] ByPass/Stage Gate Validation for PCC
            ExcludeVolume = false;
            if(opplist[0].Core_Opportunity_Coverage_Nm__c==Core_CRM_Utility.getCRMLabel('Core_OpportunitySellerProgram')){
                ExcludeVolume = true;
            }else{
                ExcludeVolume = false;
            }
            
            //END-US218684-SMG 2019: Update Pre-Submit Check Page
            
            //START- US128964 - OPPTY: Proof of Performance Updates on Approval Checklist -- Ashwin
            //if(UserInfo.getUiThemeDisplayed() == 'Theme3'){
            // to check the attachment size of Opp//
            // START-US151865-Update Logic for Proof of Performance on Approval Checklist
            // START-US176261 - OPPTY: Update Logic for Approval Checklist to check for POP or Proof of Performance
            String POP = '%'+Label.Core_Performance_indicator+'%';
            String POP1 = '%'+Label.Core_Performance_indicator1+'%';
            List<Attachment> attachsize=[select id from Attachment where parentId=:oppty.Id AND (Name LIKE :POP OR Name LIKE :POP1)];
            List<Note> Notesize=[select id from Note where parentId=: oppty.Id AND (Title Like:POP OR Title Like:POP1)];
            List<ContentDocumentLink > contentdocSize=[SELECT ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId=:oppty.Id  AND (ContentDocument.Title Like:POP OR ContentDocument.Title Like:POP1)];
            // END-US176261 - OPPTY: Update Logic for Approval Checklist to check for POP or Proof of Performance
            //START-US185496 - Oppty: Update Proof of Performance Logic to Consider Activities 
            String POP2 = '%'+Label.Core_Performance_indicator2+'%';
            List<Task> taskList = [SELECT id FROM Task WHERE (Subject LIKE :POP OR Subject LIKE:POP1 OR Core_Task_Type__c LIKE:POP2) AND WhatId = :oppty.Id];
            //END-US185496-Oppty: Update Proof of Performance Logic to Consider Activities 
            // END-US151865-Update Logic for Proof of Performance on Approval Checklist
            
            if((attachsize != null && !attachsize.isEmpty()) || (Notesize != null && !Notesize.isEmpty()) || (contentdocSize != null && !contentdocSize.isEmpty()) || (taskList != null && !taskList.isEmpty())){  //Added check POP Logic to Consider Activities - US185496  -- Ashwin        
                Note_Attachmentsize=true;
                
            }else{
                Note_Attachmentsize=false;
             
                
            }
            //Start - TWC3123-3676- Added for PW approval
            //String POP3 = '%'+Label.Core_Performance_indicator3+'%';//TWC3123-3676- Added for check PW POP and in query filter as well. //Commented for TWC3123-3904  
            //Start - TWC3123-3904 Added some new fileName formats.
            List<String> POPFileNames = new List<String>();
            if(Label.Core_Performance_indicator3.contains(',')){
                POPFileNames = Label.Core_Performance_indicator3.split(',');
            }else{
                POPFileNames.add(Label.Core_Performance_indicator3); 
            }
            //End - TWC3123-3904
            //TWC3123-3904 changed like filter variable in query.
            List<Attachment> attachsize1=[select id from Attachment where parentId=:oppty.Id AND Name LIKE :POPFileNames];
            List<Note> Notesize1=[select id from Note where parentId=: oppty.Id AND Title Like:POPFileNames];
            List<ContentDocumentLink > contentdocSize1=[SELECT ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId=:oppty.Id  AND ContentDocument.Title Like:POPFileNames];
            List<Task> taskList1 = [SELECT id FROM Task WHERE (Subject LIKE:POPFileNames OR Core_Task_Type__c LIKE:POPFileNames) AND WhatId = :oppty.Id];
            
            if((attachsize1 != null && !attachsize1.isEmpty()) || (Notesize1 != null && !Notesize1.isEmpty()) || (contentdocSize1 != null && !contentdocSize1.isEmpty()) || (taskList1 != null && !taskList1.isEmpty())){         
                PW_Note_Attachmentsize=true;
               
            }else{
                PW_Note_Attachmentsize=false;   
            }
            //End - TWC3123-3676- Added for PW approval
            //}
            //END- US128964 - OPPTY: Proof of Performance Updates on Approval Checklist -- Ashwin
            //The opportunity does not include at least one opportunity partner//
            Integer Opptupartnersize=[select count() from Core_Opportunity_Partner__c where Core_Opportunity__c =:oppty.Id]; 
            if(Opptupartnersize > 0){ 
                Opptypartnersize=true;
            }else{
                Opptypartnersize=false;
            }
            
            //MAG//
           
            if(opplist[0].Core_Military_Aerospace_Govmt_End_Use__c != null && ((opplist[0].Core_Military_Aerospace_Govmt_End_Use__c == 'Yes' || opplist[0].Core_MAG_Account__c == true) && ((String.valueOf(opplist[0].Core_Compliance_Status__c) == '' || opplist[0].Core_Compliance_Status__c == null) || (opplist[0].Core_Compliance_Status__c != 'Approved' && opplist[0].Core_Compliance_Status__c != 'Approved with Guardrails' && opplist[0].Core_Compliance_Status__c != 'N/A')))){
                MAGFlag=false;
            }else{
                MAGFlag=true;
            }
            //The 'Opportunity Type' contains "Design" AND the 'Production End Date' = NULL or is prior to the current date (i.e. date is in the past) or is prior to the 'First Customer Ship Date' (i.e. Production End Date is before First Customer Ship Date).//
            if(opplist[0].Core_First_Customer_Ship_Date__c != null && String.valueOf(opplist[0].Core_First_Customer_Ship_Date__c) != ''){
                if(opplist[0].Core_Production_End_Date__c == null || opplist[0].Core_Production_End_Date__c < system.today() || opplist[0].Core_Production_End_Date__c < opplist[0].Core_First_Customer_Ship_Date__c){
                    ProductionDate=false;
                }else{
                    ProductionDate=true;
                }
            }else{
                ProductionDate = false;
            }
            //TWC3123-1204 start
            if(opplist[0].Account.RecordType.name=='Inactive Account'){
                InactiveOppAccount = true;
            }
            else{
                InactiveOppAccount = false;
            }
            
            if(opplist[0].Core_Decimal_Check__c==False){
                QuantityValidate = True;
            }
            else{
                QuantityValidate = false;
            }
            //TWC3123-1204 end
            
            // The  Opportunity Type contains "Deal" AND  each of the opportunity products don't include an entry for 'Vendor'//
            //Integer opplineitemvendorsize=[select count() from OpportunityLineItem  where OpportunityId =: oppty.Id AND Core_Vendor__c = null];
            Integer opplineitemvendorsize = 0;
            for(OpportunityLineItem opline : opptyLineItemsList){
                if(opline.Core_Vendor__c == null || String.valueOf(opline.Core_Vendor__c) == ''){
                    opplineitemvendorsize++;
                }
            }
            if(opplineitemvendorsize > 0){
                Vendorsize=false;
            }else{
                Vendorsize=true;
            }
            
            //Modified the logic for getting the BU ShortName and displaying green if no Oppty Line Items present -- Ashwin
            Integer BUShortNamesize = 0;
            if(!opptyLineItemsList.isEmpty()){
                for(OpportunityLineItem opline : opptyLineItemsList){
                    if(opline.Core_BU_Short_Name__c == null || opline.Core_BU_Short_Name__c == ''){
                        BUShortNamesize++;
                    }
                }
                //Integer BUShortNamesize=[select count()from OpportunityLineItem  where OpportunityId =: oppty.Id and Core_BU_Short_Name__c = null];
                if(BUShortNamesize == 0){
                    BUShortName=true;
                }else{
                    BUShortName=false;
                }
            }else{
                BUShortName = true;
            }
            
            //TWC3123-2055 start
            Integer ToBeDeletedsize = 0;
            if(!opptyLineItemsList.isEmpty()){
                for(OpportunityLineItem opline : opptyLineItemsList){
                    if(opline.core_status__c == 'To Be Deleted'){
                        ToBeDeletedsize++;
                    }
                }
                
                if(ToBeDeletedsize > 0){
                    ToBeDeletedPrd=true;
                }else{
                    ToBeDeletedPrd=false;
                }
            }else{
                ToBeDeletedPrd= false;
            }
            
            
            //TWC3123-2055 end
            
            //Modified the logic for getting the Write In Product and displaying green if no Oppty Line Items present -- Ashwin
            //Integer writeInProductSize=[select count()from OpportunityLineItem  where OpportunityId =: oppty.Id and Core_Write_In_Product_Flag__c=true and Core_Status__c != 'On Hold'];          
            Integer writeInProductSize = 0;
            if(!opptyLineItemsList.isEmpty()){
                for(OpportunityLineItem opline : opptyLineItemsList){
                    if(opline.Core_Write_In_Product_Flag__c){  //&& opline.Core_Status__c == 'On Hold'
                        writeInProductSize++;
                    }
                    //TWC3123-1204 start
                    if(opline.Core_Vendor__r.RecordType.name=='Inactive Account'){
                      
                        InactiveVendorAccount = true;
                        break;
                    }
                    else{
                        InactiveVendorAccount = false;
                    }
                    //TWC3123-1204 end
                }
                if(writeInProductSize == 0){
                    WriteInProducts=true;
                }else{
                    WriteInProducts=false;
                }
            }else{
                WriteInProducts=true;
            }
            
            //There is not at least one Descriptive Feature added//
            Integer DescriptiveFeaturesize=[select count() from Core_Opportunity_Features__c where Core_Opportunity__c =:oppty.Id];
            if(DescriptiveFeaturesize == 0){
                DescriptiveFeature=false;
            }else{
                DescriptiveFeature=true;
            }
            //Start TWC3123-4164 - Added Opportunity Solution Check.
            if(opplist[0].Core_Solution_Area_Count__c > 0){
                isOppotySolutionAdded= True;
            }else{
                isOppotySolutionAdded= False;
            }
            //End- TWC3123-4164
      //Start TWC3123-4822 - Added Description of Contribution Check.           
            Integer oppTMCount= [ SELECT count() from OpportunityTeamMember WHERE OpportunityId = :oppty.Id and Core_Description_of_Contribution__c = NULL];
            if(oppTMCount > 0){
                isDescriptionOfContribution = False;
            }else{
                isDescriptionOfContribution= True;                 
            }            
     //End- TWC3123-4822
        
     //Start TWC3123-6061 
     		/*
            String managerBonusTaskLabel = Core_CRM_Utility.getCRMLabel('Core_ManagerBonusTask');
            String stateAnalysisTaskLabel = Core_CRM_Utility.getCRMLabel('Core_StateAnalysisTask');
            String completeWinAnalysisTaskLabel = Core_CRM_Utility.getCRMLabel('Core_WinAnalysisTask'); //Part of TWC3123-6309
            //TWC4767-3003 - NP changes to check for Subject and NOT Task type

            List<Task> matchingTasks = [SELECT Id, Subject, Description FROM Task WHERE WhatId = :oppty.Id AND Status = 'Completed' AND (Subject = :managerBonusTaskLabel OR Subject = :stateAnalysisTaskLabel OR Subject = :completeWinAnalysisTaskLabel)];
            
            if(opplist[0].Core_Opportunity_Coverage_Nm__c=='Intel-Led Opportunity'){
                    
                    if (opplist[0].Opportunity_Focus__c =='Growth') {
                    isDevelopOrDesignAndGrowth = True;
                    isDevelopOrDesignAndCore = False;

                    OpportunityDevelopPlus = (opplist[0].StageName=='Develop' || opplist[0].StageName =='Design'||opplist[0].StageName=='Design Win')? True : False ;
                    DesiredEndState = (opplist[0].Desired_End_State__c == '' || opplist[0].Desired_End_State__c == null) ? False : True ;
                    TechnologyAndReadinessGaps = (opplist[0].Technology_and_Readiness_Gaps__c == '' || opplist[0].Technology_and_Readiness_Gaps__c == null) ? False : True ;
                    BusinessNeed = (opplist[0].Business_Need__c == '' || opplist[0].Business_Need__c == null) ? False : True ;
                    TechnicalNeed = (opplist[0].Technical_Need__c == '' || opplist[0].Technical_Need__c == null) ? False : True ;

                    for(Task taskRecord : matchingTasks){
                        if (taskRecord.Subject == managerBonusTaskLabel ){
                            isTaskCompleted2 = true;
                        }
                        if (taskRecord.Subject == stateAnalysisTaskLabel && taskRecord.Description != null){
                            isTaskCompleted1 = true;
                        }
                        if (taskRecord.Subject == completeWinAnalysisTaskLabel){ //Part of TWC3123-6309
                            WinAnalysisTask = true;
                        }
                    }   
                    OpportunityDesignWin = (opplist[0].StageName=='Design Win')? True : False ;
                    FADStartDate = (opplist[0].FAD_Start_Date__c == null) ? False : True ;
                    FADEndDate = (opplist[0].FAD_End_Date__c == null) ? False : True ;
                    CompetitiveThreatMitigation = (opplist[0].Competitor_Threat_Mitigation__c == '' || opplist[0].Competitor_Threat_Mitigation__c == null) ? False : True ;    
                    }

            	else if(opplist[0].RecordType.DeveloperName=='Core_Deal_Opportunity' && opplist[0].Opportunity_Focus__c == 'Core') {
                isDevelopOrDesignAndGrowth = False;
                isDevelopOrDesignAndCore = True;
                
                CoreOpportunityDevelopPlus = (opplist[0].StageName=='Develop' || opplist[0].StageName =='Design'||opplist[0].StageName =='Design Win')  ? True : False  ; 
                    for(Task taskRecord : matchingTasks) {                        
                        if (taskRecord.Subject == stateAnalysisTaskLabel && taskRecord.Description != null) {
                            isTaskCompleted3 = true;
                        }  
                    }
                    CoreOpportunityDesignWin = (opplist[0].StageName=='Design Win')? True : False ;
                    CompetitiveThreatMitigation1 = (opplist[0].Competitor_Threat_Mitigation__c == '' || opplist[0].Competitor_Threat_Mitigation__c == null) ? False : True ;    
            }
          } 
			*/
    //End- TWC3123-6061
    
            //List to Review Before Approval//
            if(opplist[0].StageName =='Qualify'){
                ListtoReview=true;
                Approvedflag=false;
                noLinkflag=false;
            }
            
            else if(opplist[0].StageName =='Design Win' || opplist[0].StageName =='Production Win' || opplist[0].StageName =='Production Lost' || opplist[0].StageName =='Production Cancelled'){ //Approved//
                ListtoReview = false;
                Approvedflag = true;
                noLinkflag = false;
            }
            else if(opplist[0].StageName == 'Cancelled' || opplist[0].StageName == 'Lost'){
                ListtoReview = false;
                Approvedflag = false;
                noLinkflag = true;
            }
            else if(opplist[0].StageName=='Define' || opplist[0].StageName=='Develop'|| opplist[0].StageName=='Design'){         
                //Here to check all the conditions apre submit process// 
                //Added by Kavyashree HR(Infosys Team) for the US822091, an extra condition with Design: Software-enable is added
                if(opplist[0].Core_Opportunity_Type__c == 'Design: Original' || opplist[0].Core_Opportunity_Type__c == 'Design: Secondary' || opplist[0].Core_Opportunity_Type__c == 'Design: Software-enable'){
                    if(BUShortName==true && MAGFlag == true && WriteInProducts == true && Note_Attachmentsize == true && opplist[0].Core_Competitive_Architecture__c != null && opplist[0].Description != null && opplist[0].Core_Status_Update__c !=null && !opplist[0].Core_Product_At_Risk__c && DescriptiveFeature == true && firstCustomerShipDate == true && ProductionDate==true && Opptypartnersize==true && opplist[0].Core_Manufacturing_Geo__c != null){ 
                        Completeflag = true; 
                        ARReviewtheList = false;
                    }else{
                        Completeflag = false; 
                        ARReviewtheList = true; 
                    }
                }else{
                    // US99003-Added logic for Solution Type and Details will not be blank --Rajesh//
                    if(BUShortName==true && MAGFlag==true && WriteInProducts==true && Note_Attachmentsize==true && opplist[0].Core_Competitive_Architecture__c !=null && opplist[0].Description !=null && opplist[0].Core_Status_Update__c !=null && !opplist[0].Core_Product_At_Risk__c && opplist[0].Core_Solution_Type__c !=null && opplist[0].Core_Combined_Solution_Detail__c !=null && Vendorsize==true && Opptypartnersize==true ){
                        Completeflag=true; 
                        ARReviewtheList=false;      
                    }else{
                        Completeflag=false;
                        ARReviewtheList=true; 
                    }
                }
            }
        }
        }
        }
        catch(Exception e){
            PMP_Utility.logError(e, 'Core_OppApproveChecklistCont.const');
        }
        
    }
   
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' +OppId);
        pageRef.setRedirect(true);
        return pageRef;            
    }
}