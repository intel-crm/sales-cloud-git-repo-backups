/**************************************************************************************
Apex Class Name:  Core_OppApproveChecklistCont
Version     : 1.0 
Created Date: 16/6/2017
Description : To the display Indicator for  Design or Deal  Opportunity Approval Checklist .
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rajesh infy Team            16/6/2017               Initial Revision
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
     // 'Pre-Submit Check view //
    Public String OppId;
    public Core_OppApproveChecklistCont(ApexPages.StandardController stdController){
        oppty= (Opportunity)stdController.getRecord();
        OppId=ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(oppty.Id)){
            list<Opportunity> opplist = [select id,Core_Opportunity_Type__c,Core_Military_Aerospace_Govmt_End_Use__c,Core_Compliance_Status__c,Core_Production_End_Date__c,Core_First_Customer_Ship_Date__c,StageName,Core_Oppty_Check_BU_Short_Name__c,Core_Write_In_Product_Count__c,Core_Competitive_Architecture__c,Description, Core_MAG_Account__c, Core_Status_Update__c,Core_Manufacturing_Geo__c,Core_Volume__c  from Opportunity where id =: oppty.Id];
            
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

            
            // to check the attachment size of Opp//
            List<Attachment> attachsize=[select id from Attachment where parentId=:oppty.Id];
            List<Note> Notesize=[select id from Note where parentId=: oppty.Id];   
            if((attachsize != null &&  attachsize.size() > 0) || (Notesize != null &&  Notesize.size() > 0)){
                Note_Attachmentsize=true;
            }else{
                Note_Attachmentsize=false;
            }
            
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
            }else if(opplist[0].StageName =='Design Win' || opplist[0].StageName =='Production Win' || opplist[0].StageName =='Production Lost' || opplist[0].StageName =='Production Cancelled'){ //Approved//
                ListtoReview = false;
                Approvedflag = true;
                noLinkflag = false;
            }else if(opplist[0].StageName == 'Cancelled' || opplist[0].StageName == 'Lost'){
                ListtoReview = false;
                Approvedflag = false;
                noLinkflag = true;
            }else if(opplist[0].StageName=='Define' || opplist[0].StageName=='Develop'|| opplist[0].StageName=='Design'){         
                //Here to check all the conditions pre submit process// 
                if(opplist[0].Core_Opportunity_Type__c == 'Design: Original' || opplist[0].Core_Opportunity_Type__c == 'Design: Secondary'){
                    if(BUShortName==true && MAGFlag == true && WriteInProducts == true && Note_Attachmentsize == true && opplist[0].Core_Competitive_Architecture__c != null && opplist[0].Description != null && opplist[0].Core_Status_Update__c !=null && DescriptiveFeature == true && firstCustomerShipDate == true && ProductionDate==true && Opptypartnersize==true && opplist[0].Core_Manufacturing_Geo__c != null && opplist[0].Core_Volume__c != null){
                        Completeflag = true; 
                        ARReviewtheList = false;
                    }else{
                        Completeflag = false; 
                        ARReviewtheList = true; 
                    }
                }else{
                    if(BUShortName==true && MAGFlag==true && WriteInProducts==true && Note_Attachmentsize==true && opplist[0].Core_Competitive_Architecture__c !=null && opplist[0].Description !=null && opplist[0].Core_Status_Update__c !=null && DescriptiveFeature == true && Vendorsize==true && Opptypartnersize==true ){
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
        return new PageReference('/' +oppty.Id);
    }
 }