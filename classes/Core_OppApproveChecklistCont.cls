/**************************************************************************************
Apex Class Name:  Core_OppApproveChecklistCont
Version     : 1.0 
Created Date: 16/6/2017
Description : To the display Indicator for  Design or Deal  Opportunity Approval Checklist .
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajesh infy Team            16/6/2017               Initial Revision
* Rajesh                      13/3/2017               US99003-Removed Descriptive features in the  Deal Opportunities and added new logic for Solution Type and Details
* Ashwin Dash                 20/8/2017               US128964 - OPPTY: Proof of Performance Updates on Approval Checklist
* Ashwin Dash                 11/10/2018              US176261 - OPPTY: Update Logic for Approval Checklist to check for POP or Proof of Performance
* Ashwin Dash                 12/19/2018              US185496 - Oppty: Update Proof of Performance Logic to Consider Activities
* Mahesh                      11/1/2019               US218684-SMG 2019: Update Pre-Submit Check Page
*************************************************************************************/
public with sharing class Core_OppApproveChecklistCont {
    public Opportunity oppty {get;set;}
    public Boolean BUShortName{get;set;}
    public Boolean WriteInProducts{get;set;}
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
    // 'Pre-Submit Check view //
    Public String OppId;
    public Core_OppApproveChecklistCont(ApexPages.StandardController stdController){
        oppty= (Opportunity)stdController.getRecord();
        OppId=ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(oppty.Id)){
            list<Opportunity> opplist = [select id,Core_Opportunity_Type__c,Core_Military_Aerospace_Govmt_End_Use__c,Core_Compliance_Status__c,Core_Production_End_Date__c,Core_First_Customer_Ship_Date__c,StageName,Core_Oppty_Check_BU_Short_Name__c,Core_Write_In_Product_Count__c,Core_Competitive_Architecture__c,Description, Core_MAG_Account__c, Core_Status_Update__c,Core_Manufacturing_Geo__c,Core_Volume__c,Core_Solution_Type__c,Core_Solution_Detail__c,Core_Combined_Solution_Detail__c,Core_Exclude_From_KPIs__c  from Opportunity where id =: oppty.Id];
            
            List<OpportunityLineItem> opptyLineItemsList= [SELECT id, Name, Core_Status__c, Core_BU_Short_Name__c, Core_Write_In_Product_Flag__c, Core_Vendor__c FROM OpportunityLineItem WHERE OpportunityId = :oppty.Id];
            
            if(opplist != null && opplist.size() > 0 && (opplist[0].Core_Opportunity_Type__c == 'Design: Original' || opplist[0].Core_Opportunity_Type__c == 'Design: Secondary')){
                Pageblocksectionredender=true;
            }else{
                Pageblocksectionredender=false;
            }
            /*
//Check for firstCustomerShipDate
if(opplist[0].Core_First_Customer_Ship_Date__c != null && String.valueOf(opplist[0].Core_First_Customer_Ship_Date__c) != '' && opplist[0].Core_First_Customer_Ship_Date__c < System.Today()){
firstCustomerShipDate = false;
}else{
firstCustomerShipDate = true;
}
*/
            //Check for firstCustomerShipDate
            if(opplist[0].Core_First_Customer_Ship_Date__c != null && String.valueOf(opplist[0].Core_First_Customer_Ship_Date__c) != '' && opplist[0].Core_First_Customer_Ship_Date__c > System.Today()){
                firstCustomerShipDate = true;
            }else{
                firstCustomerShipDate = false;
            }
            //START-US218684-SMG 2019: Update Pre-Submit Check Page
           
            ExludeKPIflag=false;
            if(opplist[0].Core_Exclude_From_KPIs__c){
                ExludeKPIflag=true;
            }else if(opplist[0].Core_Exclude_From_KPIs__c=false){
                 ExludeKPIflag=false;
            }
            system.debug('ExludeKPIflag'+ExludeKPIflag);
            //END-US218684-SMG 2019: Update Pre-Submit Check Page
            
            //START- US128964 - OPPTY: Proof of Performance Updates on Approval Checklist -- Ashwin
            //if(UserInfo.getUiThemeDisplayed() == 'Theme3'){
            // to check the attachment size of Opp//
            // START-US151865-Update Logic for Proof of Performance on Approval Checklist
            // START-US176261 - OPPTY: Update Logic for Approval Checklist to check for POP or Proof of Performance
            String POP = '%'+Label.Core_Performance_indicator+'%';
            String POP1 = '%'+Label.Core_Performance_indicator1+'%';            
            List<Attachment> attachsize=[select id,Name from Attachment where parentId=:oppty.Id AND (Name LIKE :POP OR Name LIKE :POP1)];
            List<Note> Notesize=[select id,Title from Note where parentId=: oppty.Id AND (Title Like:POP OR Title Like:POP1)]; 
            List<ContentDocumentLink > contentdocSize=[SELECT ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId=:oppty.Id  AND (ContentDocument.Title Like:POP OR ContentDocument.Title Like:POP1)];
            // END-US176261 - OPPTY: Update Logic for Approval Checklist to check for POP or Proof of Performance
            //START-US185496 - Oppty: Update Proof of Performance Logic to Consider Activities 
            String POP2 = '%'+Label.Core_Performance_indicator2+'%';
            List<Task> taskList = [SELECT id, Subject, Core_Task_Type__c FROM Task WHERE (Subject LIKE :POP OR Subject LIKE:POP1 OR Core_Task_Type__c LIKE:POP2) AND WhatId = :oppty.Id];
            //END-US185496-Oppty: Update Proof of Performance Logic to Consider Activities 
            // END-US151865-Update Logic for Proof of Performance on Approval Checklist
            
            if((attachsize != null && !attachsize.isEmpty()) || (Notesize != null && !Notesize.isEmpty()) || (contentdocSize != null && !contentdocSize.isEmpty()) || (taskList != null && !taskList.isEmpty())){  //Added check POP Logic to Consider Activities - US185496  -- Ashwin        
                Note_Attachmentsize=true;
                system.debug('Note_Attachmentsize1'+Note_Attachmentsize);
                
            }else{
                Note_Attachmentsize=false;
                system.debug('Note_Attachmentsize2'+Note_Attachmentsize);
                
            }
            //}
            /*else {
List<ContentDocumentLink > contentdocSize=[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:oppty.Id];
if(contentdocSize.size() > 0)
Note_Attachmentsize=true;
else
Note_Attachmentsize=false;
}  */
            //END- US128964 - OPPTY: Proof of Performance Updates on Approval Checklist -- Ashwin
            //The opportunity does not include at least one opportunity partner//
            Integer Opptupartnersize=[select count() from Core_Opportunity_Partner__c where Core_Opportunity__c =:oppty.Id]; 
            if(Opptupartnersize > 0){ 
                Opptypartnersize=true;
            }else{
                Opptypartnersize=false;
            }
            
            //MAG//
            System.debug('**MAG - '+opplist[0].Core_Military_Aerospace_Govmt_End_Use__c+' MAG Account - '+opplist[0].Core_MAG_Account__c+' Compliance - '+opplist[0].Core_Compliance_Status__c);
            if(opplist[0].Core_Military_Aerospace_Govmt_End_Use__c != null && ((opplist[0].Core_Military_Aerospace_Govmt_End_Use__c == 'Yes' || opplist[0].Core_MAG_Account__c == true) && ((String.valueOf(opplist[0].Core_Compliance_Status__c) == '' || opplist[0].Core_Compliance_Status__c == null) || (opplist[0].Core_Compliance_Status__c != 'Approved' && opplist[0].Core_Compliance_Status__c != 'Approved with Guardrails')))){
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
            
            //Modified the logic for getting the Write In Product and displaying green if no Oppty Line Items present -- Ashwin
            //Integer writeInProductSize=[select count()from OpportunityLineItem  where OpportunityId =: oppty.Id and Core_Write_In_Product_Flag__c=true and Core_Status__c != 'On Hold'];          
            Integer writeInProductSize = 0;
            if(!opptyLineItemsList.isEmpty()){
                for(OpportunityLineItem opline : opptyLineItemsList){
                    if(opline.Core_Write_In_Product_Flag__c){  //&& opline.Core_Status__c == 'On Hold'
                        writeInProductSize++;
                    }
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
                if(opplist[0].Core_Opportunity_Type__c == 'Design: Original' || opplist[0].Core_Opportunity_Type__c == 'Design: Secondary'){
                    if(BUShortName==true && MAGFlag == true && WriteInProducts == true && Note_Attachmentsize == true && opplist[0].Core_Competitive_Architecture__c != null && opplist[0].Description != null && opplist[0].Core_Status_Update__c !=null && DescriptiveFeature == true && firstCustomerShipDate == true && ProductionDate==true && Opptypartnersize==true && opplist[0].Core_Manufacturing_Geo__c != null && opplist[0].Core_Volume__c != null){
                        Completeflag = true; 
                        ARReviewtheList = false;
                    }else{
                        Completeflag = false; 
                        ARReviewtheList = true; 
                    }
                }else{
                    // US99003-Added logic for Solution Type and Details will not be blank --Rajesh//
                    if(BUShortName==true && MAGFlag==true && WriteInProducts==true && Note_Attachmentsize==true && opplist[0].Core_Competitive_Architecture__c !=null && opplist[0].Description !=null && opplist[0].Core_Status_Update__c !=null && opplist[0].Core_Solution_Type__c !=null && opplist[0].Core_Combined_Solution_Detail__c !=null && Vendorsize==true && Opptypartnersize==true ){
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
    
    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' +OppId);
        pageRef.setRedirect(true);
        return pageRef;            
    }
}