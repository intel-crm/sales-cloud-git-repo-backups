public class Core_DDR_OppRetry {
    
    public static string DR_STATUS_APPROVED = 'Approved';
    public static string DR_STATUS_RESUBMITTED = 'Re-Submitted';
    public static string DR_STATUS_SUBMITTED = 'Submitted';
    public static string DR_STATUS_REJECTED = 'Rejected';
    
    public static string PRICEBOOK_NAME = 'Partner Price Book';
    public static string Project = 'DDR';
    public static string Severity = 'High';
    public static string Log_Severity = 'Info';
    public static string InsertSuccess = 'Successfully Inserted';
    Public static string failedRecordId;
      
/***************Retry Logic for Oppo Start******************/
    
@InvocableMethod(label='DDR Opp Retry' description='Reprocess the failed DDR records' category='LogEntry')
public static void RetryFailedOppRecords(List<ID> ids) 
{
		System.debug('*****Opp Retry Logic Start***');
        Map<Id,Core_Design_Registration__c> lstApprovedDDR = new Map<Id,Core_Design_Registration__c>();
        List<Core_Design_Registration__c> listApprovedDDReg = new List<Core_Design_Registration__c>();
        List<ID> FailedDdr= new List<ID>(); //1
        
        //////////////////////Vars 
        
        List<Core_Design_Registration__c> lstApprovedDRs = new List<Core_Design_Registration__c>();
        List<Opportunity> lstInsertOpportunities = new List<Opportunity>();   
        List<Core_Design_Registration__c> lstRejectedDesigns = new List<Core_Design_Registration__c>();        
        List<Core_Design_Registration__c> lstDesignsForGroupName = new List<Core_Design_Registration__c>();        
        
        List<Id> DDRids = new list<Id>();
        Id userId = Userinfo.getUserId();
        
        Pricebook2 priceBook;
        
        //Check for export compliance
        List<Core_Design_Registration__c> lstDesignRegForExportCompl = new List<Core_Design_Registration__c>();
        List<Core_Design_Registration__c> lstDesignRegForSharing = new List<Core_Design_Registration__c>();
        
    	/////////////////////Vars
 
        Map<String, Core_LogEntry_Switch__c> logSwitch = Core_LogEntry_Switch__c.getall(); //1
        List<Core_Log_Entry__c> logEntries = new List<Core_Log_Entry__c>(); //1
        
        List<Core_Log_Entry__c> logEList=[Select id, Name, Core_Retry_Counter__c, Core_Message__c, Core_Origin__c, Core_sObjectId__c, Core_Next_Scheduled_Run__c from Core_Log_Entry__c where id IN :ids AND Core_sObjectId__c != null AND Core_Origin__c = 'Opportunity Creation' AND Core_Message__c != 'Successfully Inserted'];
        System.debug('***logEList::'+logEList);
        for(Core_Log_Entry__c logE : logEList)
        {
            FailedDdr.add(logE.Core_sObjectId__c); 
        }
        System.debug('***FailedDdr:::'+FailedDdr);
        
		listApprovedDDReg = [SELECT id, Name, Core_Product_Group_Nm__c,Core_Partner_Account_Region_Cd__c, Core_Design_Registration_Nm__c, Core_Vertical_Market_Nm__c, Core_Military_Aerospace_Gvrnmt_Use_Ind__c, Core_Product_Application_Nm__c,Core_Product_Segment_Nm__c, Core_Opportunity_Id__c, Core_End_Customer_Account_Id__c, OwnerId, Core_Partner_Account_Id__c, Core_Approver_Grp_Nm__c, Core_Design_Registration_Status_Nm__c, Core_Manufacturing_Region_Cd__c, Core_Production_End_Dt__c, Core_First_Customer_Ship_Dt__c, Core_Intel_Platform_Nm__c, Core_FPGA_Quote_Comments_Txt__c, Core_Design_Registration_Dsc__c, Core_Intel_Technical_Owner_Id__c, Core_Opportunity_Volume_Cnt__c, Core_Opportunity_Decision_Dt__c from Core_Design_Registration__c where Id =:FailedDdr AND Core_Opportunity_Id__c=null];
        System.debug('Retry record for opp:::'+listApprovedDDReg);
    	for(Core_Design_Registration__c oppDDR : listApprovedDDReg)
        {
            lstApprovedDDR.put(oppDDR.Id, oppDDR);
            System.debug('***lstApprovedDDR:: '+lstApprovedDDR);
        }
        
        If(listApprovedDDReg.size()>0)
        {
            
            //////////////////////////////start 
            try
            {           
                
                for(Core_Design_Registration__c iDR : listApprovedDDReg)
                {
                    if(iDR.Core_End_Customer_Account_Id__c != null)
                    {
                        lstDesignRegForExportCompl.add(iDR);    
                    }
                    
                    if(iDR.OwnerId != null)
                    {
                        system.debug(iDR.Id);
                        lstDesignRegForSharing.add(iDR);
                    }
                }            
                
                //To populate the partner account and share the design based on owner field
                if(lstDesignRegForSharing.size() > 0)
                {
                    system.debug(lstDesignRegForSharing);
                    Core_DDR_Design_Handler.populatePartnerAccount(lstDesignRegForSharing);
                    Core_DDR_Design_Handler.designRegShare(lstDesignRegForSharing);
                }            
                
                if(lstDesignRegForExportCompl.size() > 0)
                {
                    Core_DDR_Design_Handler.checkForExportCompliance(lstDesignRegForExportCompl);
                }
                
                for(Core_Design_Registration__c iDR : listApprovedDDReg)
                {
                    
                    if(iDR.Core_Partner_Account_Id__c != NULL && iDR.Core_Approver_Grp_Nm__c == NULL)
                    {
                        lstDesignsForGroupName.add(iDR);    
                    }
                    
                    //if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && !(oldMap.get(iDR.Id).Core_Opportunity_Id__c != newMap.get(iDR.Id).Core_Opportunity_Id__c) && !(oldMap.get(iDR.Id).Core_Approver_Grp_Notification_Sent_Ind__c != newMap.get(iDR.Id).Core_Approver_Grp_Notification_Sent_Ind__c))
                    if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED && iDR.Core_Opportunity_Id__c == null)//Added by Suresh Palvadi
                    {
                        lstApprovedDRs.add(iDR);
                    }    
                    
                    if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_APPROVED)
                    {
                        DDRids.add(iDR.id);
                    }
                    
                    //Lock the rejected line items after header is locked
                    if(iDR.Core_Design_Registration_Status_Nm__c == DR_STATUS_REJECTED)
                    {
                        lstRejectedDesigns.add(iDR);
                    }
                }   
                
                if(lstDesignsForGroupName.size() > 0)
                {
                    Core_DDR_Design_Handler.updateGroupName(lstDesignsForGroupName);
                }
                
                if(lstRejectedDesigns.size() > 0)
                {
                    Core_DDR_Design_Handler.lockRejectedProducts(lstRejectedDesigns);
                }
                
                if(lstApprovedDRs.size() > 0)
                { 
                    //lock the approved DRs
                    //Approval.lock(lstApprovedDRs, true);
                    
                    priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name =: PRICEBOOK_NAME];
                    
                    //prepare list of Opp to create new Opps
                    for(Core_Design_Registration__c iDR : lstApprovedDRs)
                    {
                        Opportunity createOpp = new Opportunity(Name = iDR.Core_Design_Registration_Nm__c, AccountID = iDR.Core_End_Customer_Account_Id__c, StageName = 'Define');
                        
                        createOpp.Core_Design_Registration_Id__c = iDR.id;
                        createOpp.Core_Sales_Group__c = (iDR.Core_Product_Group_Nm__c == 'FPGA/Power' ? 'PSG Sales': 'Regional Sales');
                        createOpp.Core_Military_Aerospace_Govmt_End_Use__c = iDR.Core_Military_Aerospace_Gvrnmt_Use_Ind__c;
                        createOpp.Core_Commissionable__c = 'Yes';
                        createOpp.Core_Opportunity_Type__c = 'Design: Original';
                        createOpp.Core_Product_Segment__c = iDR.Core_Product_Segment_Nm__c;
                        createOpp.Core_Product_Application__c = iDR.Core_Product_Application_Nm__c;
                        createOpp.Core_Consumption_Market__c = iDR.Core_Vertical_Market_Nm__c;
                        createOpp.Core_Manufacturing_Geo__c = iDR.Core_Manufacturing_Region_Cd__c;
                        createOpp.Core_Production_End_Date__c = iDR.Core_Production_End_Dt__c;
                        createOpp.Core_First_Customer_Ship_Date__c = iDR.Core_First_Customer_Ship_Dt__c;
                        createOpp.Core_Intel_Platform__c = iDR.Core_Intel_Platform_Nm__c;
                        if (iDR.Core_FPGA_Quote_Comments_Txt__c == null)
                            createOpp.Description = iDR.Core_Design_Registration_Dsc__c;
                        else
                            createOpp.Description = 'Description:\n---------------\n' + iDR.Core_Design_Registration_Dsc__c + '\n\nFPGA Quote Comments:\n--------------------------------\n' + iDR.Core_FPGA_Quote_Comments_Txt__c;
                        createOpp.OwnerID = iDR.OwnerID;
                        createOpp.Core_Technical_Owner__c = iDR.Core_Intel_Technical_Owner_Id__c!=NULL?iDR.Core_Intel_Technical_Owner_Id__c:UserInfo.getUserId();
                        createOpp.Core_Volume__c = iDR.Core_Opportunity_Volume_Cnt__c; 
                        createOpp.Pricebook2id = priceBook.id;
                        createOpp.Core_Channel_Opportunity_Ind__c = true;
                        createOpp.CloseDate = (iDR.Core_Opportunity_Decision_Dt__c < system.today() ? system.today() : iDR.Core_Opportunity_Decision_Dt__c);
                        
                        createOpp.Core_Compliance_Status__c = 'N/A';
                        createOpp.Core_Compliance_Sub_Status__c = 'Completed';
                        
                        if(iDR.Core_Opportunity_Id__c == NULL)
                        {
                            lstInsertOpportunities.add(createOpp); 
                        }
                    }
                    
                    List<id> insertOppIds = new List<id>();
                    if(lstInsertOpportunities.size() > 0)
                    {         
                        //////////////////////////////////insert Opp
                        
                        Database.SaveResult[] lstOppLineItemsInsertResults = Database.insert(lstInsertOpportunities, false);         
                        
                        for (Database.SaveResult sr : lstOppLineItemsInsertResults)
                        {      
                            System.debug('###lstInsertOpportunities size :::'+lstInsertOpportunities.size());
                            if (!sr.isSuccess())
                            {
                                for(Core_Log_Entry__c logE : logEList)
                                {
                                    Core_Log_Entry__c log = new Core_Log_Entry__c();
                                    log.Id = logE.Id;
                                    log.Core_Retry_Counter__c = logE.Core_Retry_Counter__c +1;
                                    if(log.Core_Retry_Counter__c<4){
                                        log.Core_Message__c = logE.Core_Message__c + ' - Retry Started';
                                    }Else{
                                        log.Core_Message__c = logE.Core_Message__c + ' - Retry Ended';
                                    }                    
                                    log.Core_Next_Scheduled_Run__c = System.now();
                                    System.debug('###Failed Again:::');
                                    logEntries.add(log);
                                }
                                
                            }
                            else if(sr.isSuccess())
                            {	
                                System.debug('###Sucess:::');
                                logEntries.add(new Core_Log_Entry__c(Core_Message__c = InsertSuccess +' - After Retry', Core_Origin__c = 'Opportunity Creation', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Project__c = Project, Core_sObjectId__c = sr.getId()));
                                
                            }
                        }
                
                        //////////////////////////////////Insert Opp end
                        
                        
                        Core_DDR_Design_Handler.OpportunityShare(lstInsertOpportunities);
                        
                        List<Core_Design_Registration__c> lstUpdateOppInDDR = new List<Core_Design_Registration__c>();
                        
                        for(Opportunity opp: lstInsertOpportunities)
                        {
                            //add Opp Ids to create OLIs
                            insertOppIds.add(opp.id);
                            
                            //add Opp Id to DR to update the opportunity lookup in DR
                            Core_Design_Registration__c tempDR = new Core_Design_Registration__c(Id = Opp.Core_Design_Registration_Id__c, Core_Opportunity_Id__c = Opp.Id);
                            
                            tempDR.RecordTypeId = Label.Core_DDR_Design_Locked_Record_Type_ID;
                            
                            lstUpdateOppInDDR.add(tempDR);                        
                        }
                        
                        if(lstUpdateOppInDDR.size() > 0)
                        {
                            update lstUpdateOppInDDR;
                        }
                    }                
                    //Call OLI creation future method
                    if(insertOppIds.size() > 0)
                    {  
                        Core_DDR_Design_Handler.insertOppLineItems(insertOppIds, DDRids);  
                    }              
                }       
        //////////////////////////////////////Stop    
    		}
            catch(Exception e)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                system.debug('processAfterUpdate->'+myMsg);
                if(logSwitch.get('Core_DDR_LogEntry_Check') != null && logSwitch.get('Core_DDR_LogEntry_Check').Is_Selected__c)
                {
                    String ddrId = '';
                    if(lstInsertOpportunities.size() > 0){
                        ddrId = lstInsertOpportunities[0].Core_Design_Registration_Id__c;
                    }
                    Core_Log_Entry__c ExcepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage().abbreviate(254), Core_Origin__c = 'Opportunity Creation', Core_Severity__c = 'High', Core_When__c = System.Now(), Core_Project__c = Project, Core_Details__c = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getStackTraceString(), Core_sObjectId__c = ddrId);
                    insert ExcepLog;
                }
            }
		}
}
    /***************Retry Logic for Oppo End******************/
}