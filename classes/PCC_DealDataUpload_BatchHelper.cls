public class PCC_DealDataUpload_BatchHelper {
public static List<Opportunity> createOppRecords(List<Core_Design_Registration__c> DDRList) {
        List<Opportunity> oppTBC = new List<Opportunity>();
        List<id> ownerList = new List<id>();
        Map<id,id> ownerManagerMap = new Map<id,id>();
        for(Core_Design_Registration__c ddr: DDRList) {
            ownerList.add(ddr.Core_Accepted_By_Id__c);
        }
     for(Core_Design_Registration__c ddr: DDRList){
          String systemDate = String.valueOf(System.now());
            String timeStamp = systemDate.replaceAll('[^0-9]', '');
            Opportunity createOpp = new Opportunity(AccountID = ddr.Core_End_Customer_Account_Id__c);
            createOpp.Name = ddr.Core_Design_Registration_Nm__c.length()>100? ddr.Core_Design_Registration_Nm__c.substring(0, 100)+' ' + timeStamp : ddr.Core_Design_Registration_Nm__c +' ' + timeStamp;
            Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Opportunity').getRecordTypeId();
            createOpp.RecordTypeId = recordTypeId;
            createOpp.Core_Design_Registration_Id__c = ddr.id;
            createOpp.Core_Sales_Group__c = 'Regional Sales';
            createOpp.Core_Military_Aerospace_Govmt_End_Use__c = ddr.Core_Military_Aerospace_Gvrnmt_Use_Ind__c;
            createOpp.Core_Commissionable__c = 'No';
            createOpp.Core_Opportunity_Type__c = 'Deal: Sell-through';
            createOpp.Core_Product_Segment__c = ddr.Core_Product_Segment_Nm__c;
            createOpp.Core_Product_Application__c = ddr.Core_Product_Application_Nm__c;
            createOpp.Core_Consumption_Market__c = ddr.Core_Vertical_Market_Nm__c;
            createOpp.Core_Manufacturing_Geo__c = ddr.Core_Manufacturing_Region_Cd__c;
           // createOpp.Core_Intel_Platform__c = ddr.Core_Intel_Platform_Nm__c;
            createOpp.Core_Status_Update__c = 'Converted from Deal DDR for Partner Led Deal Oppty - '+ ddr.Name;
            createOpp.Core_Opportunity_Coverage_Nm__c ='Partner-Led Opportunity';
            createOpp.Core_Coverage_Type_Nm__c = 'Deal Registration'; //Deal Registration
            if (ddr.Core_FPGA_Quote_Comments_Txt__c == null)
                createOpp.Description = ddr.Core_Design_Registration_Dsc__c;
            else
                createOpp.Description = 'Description:\n---------------\n' + ddr.Core_Design_Registration_Dsc__c + '\n\nFPGA Quote Comments:\n--------------------------------\n' + ddr.Core_FPGA_Quote_Comments_Txt__c;
            createOpp.OwnerID = ddr.Core_Accepted_By_Id__c;
            createOpp.Core_Technical_Owner__c = ddr.OwnerId;
            createOpp.Core_Channel_Opportunity_Ind__c = true;
            createOpp.CloseDate = (ddr.Core_Opportunity_Decision_Dt__c < system.today() ? system.today() : ddr.Core_Opportunity_Decision_Dt__c);
            createOpp.Core_Compliance_Status__c = 'N/A';
            createOpp.Core_Compliance_Sub_Status__c = 'Completed';
            //createOpp.Decision_Date__c = ddr.Core_Opportunity_Decision_Dt__c;
           // createOpp.CloseDate = ddr.Core_Opportunity_Decision_Dt__c;
            createOpp.Core_Exclude_From_KPIs__c = true;
            createOpp.StageName = 'Qualify';
            
            //Added as per Sunil request // commenting out need to verify for PCC Deal
           // createOpp.Core_Date_Submitted_for_Approval__c = ddr.Core_Opportunity_Decision_Dt__c;
            //createOpp.Core_Approval_Status__c = 'Approved';
           // createOpp.Core_Approved_Date__c = ddr.Core_Opportunity_Decision_Dt__c;
          //  createOpp.Core_Approved_By__c = ownerManagerMap.get(ddr.Core_Accepted_By_Id__c);

            oppTBC.add(createOpp);
        }
        
        //system.debug('oppTBC: '+oppTBC);
        
        if(oppTBC.size()>0) {
            Database.SaveResult[] result = Database.insert(oppTBC, false); 
            system.debug('result: '+result);
        }
        
        return oppTBC;
     }
    
      public static void oppSharing(List<Opportunity> oppList) {
          List<OpportunityTeamMember> TOTBC = new List<OpportunityTeamMember>();
          List<Opportunity> newOppList = new List<Opportunity>();
		  Map<Id, Id> mapTeamMemberIdOpportunityId = new Map<Id, Id>();

       	  Core_DDR_Design_Handler_Utility.OpportunityShare(oppList);

       //Create OTMs
        for(OpportunityTeamMember oTMList : [SELECT Id, Name, UserId, OpportunityId,TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId IN: oppList]) {
            mapTeamMemberIdOpportunityId.put(oTMList.UserId, oTMList.OpportunityId);
        }
        
        for(Opportunity opp: [select id,Core_Technical_Owner__c,OwnerId from Opportunity where id in: oppList]) {
            newOppList.add(opp);
        }
          
          for(Opportunity opp: newOppList) {
              
              //TO Sharing
              if(!mapTeamMemberIdOpportunityId.containsKey(opp.Core_Technical_Owner__c)
               || (mapTeamMemberIdOpportunityId.containskey(opp.Core_Technical_Owner__c) && mapTeamMemberIdOpportunityId.get(opp.Core_Technical_Owner__c)!=opp.id)) {
               OpportunityTeamMember otm1  = new OpportunityTeamMember();
                   otm1.TeamMemberRole         = 'Technical Owner (100%)';
                   otm1.UserId                 = opp.Core_Technical_Owner__c;
                   otm1.OpportunityId          = opp.Id;
                   otm1.OpportunityAccessLevel = 'Edit';
                   otm1.Core_Description_of_Contribution__c = 'Partner'; 
                   TOTBC.add(otm1);
               }
              
                if(!mapTeamMemberIdOpportunityId.containsKey(opp.OwnerId)
               || (mapTeamMemberIdOpportunityId.containskey(opp.OwnerId) && mapTeamMemberIdOpportunityId.get(opp.OwnerId)!=opp.id)) {
                OpportunityTeamMember otm2  = new OpportunityTeamMember();
                   otm2.TeamMemberRole         = 'Opportunity Owner (100%)';
                   otm2.UserId                 = opp.OwnerId;
                   otm2.OpportunityId          = opp.Id;
                   otm2.OpportunityAccessLevel = 'All';
                   otm2.Core_Description_of_Contribution__c = 'Opportunity Owner (100%)'; 
                   TOTBC.add(otm2);
               }
              
          }
          
          if(TOTBC.size()>0) {
            Database.UpsertResult[] result = Database.upsert(TOTBC, false);
            //system.debug('result: '+result);
        }
          
      }
    
    
       public static void createOLI(List<Opportunity> oppList, List<Core_Design_Registration__c> DDRList) {
        Map<Id, Opportunity> ddrToOpp = new Map<Id, Opportunity>();
        Map<string, PriceBookEntry> mapProductNameTOPricebookEntry = new map<string, PriceBookEntry>();
        List<Core_Design_Registration_Product__c> approvedDRLI = new List<Core_Design_Registration_Product__c>();
        List<OpportunityLineItem> oliTBC = new List<OpportunityLineItem>();
        Map<id,Opportunity> oppMap = new Map<id,Opportunity>();
        
        Pricebook2 priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Partner Price Book' and IsActive=true];//Added isactive check
        
        for(Opportunity opp : [select id,Core_Design_Registration_Id__c,Core_Approved_Date__c,Core_Commissionable__c,Decision_Date__c from Opportunity where id in : oppList]) {
            ddrToOpp.put(opp.Core_Design_Registration_Id__c, opp);
            oppMap.put(opp.id,opp);
        }        
        
        //Removed AND isActive = true
        for(PricebookEntry iPBE : [SELECT Id, UnitPrice, Product2Id, Product2.Name FROM PricebookEntry WHERE Pricebook2Id =: priceBook.id ]) {
            mapProductNameTOPricebookEntry.put(iPBE.Product2Id, iPBE);
        }
        
        List<Core_Design_Registration_Product__c> DRPList = [SELECT id, Name,Core_Design_Registration_Id__c, Core_Design_Product_Status_Nm__c, Core_Product_Id__r.Name, Core_Design_Registration_Id__r.Core_Opportunity_Decision_Dt__c, 
                                                     Core_Product_Id__c, Core_Full_Year_Qty__c, Core_Target_Resale_Amt__c, Core_Product_Id__r.IsActive 
                                                     FROM Core_Design_Registration_Product__c 
                                                     WHERE Core_Design_Registration_Id__c IN: DDRList]; //AND Core_Product_Id__r.IsActive = true
        
        for(Core_Design_Registration_Product__c ddrProd : DRPList) {            
            if(ddrProd.Core_Design_Product_Status_Nm__c == 'Approved') {
                approvedDRLI.add(ddrProd);
            }   
        }
        
        //add list of OLIs for OLI creation
        for(Core_Design_Registration_Product__c ddrli : approvedDRLI) {  
            if(ddrToOpp.containskey(ddrli.Core_Design_Registration_Id__c)) {
                OpportunityLineItem createOppLineItem = new OpportunityLineItem(OpportunityId = ddrToOpp.get(ddrli.Core_Design_Registration_Id__c).Id);
                createOppLineItem.Core_Design_Registration_Product_Id__c = ddrli.Id;
                createOppLineItem.UnitPrice = ddrli.Core_Target_Resale_Amt__c;
                createOppLineItem.Quantity = ddrli.Core_Full_Year_Qty__c;
                createOppLineItem.Product2ID = ddrli.Core_Product_Id__c;   
                createOppLineItem.PricebookEntryId = mapProductNameTOPricebookEntry.containsKey(ddrli.Core_Product_Id__c)?mapProductNameTOPricebookEntry.get(ddrli.Core_Product_Id__c).id : null;
                createOppLineItem.Failed_DDR_RecordID__c = ddrli.Core_Design_Registration_Id__c;
                
                oliTBC.add(createOppLineItem);           
            }
        }
        
        //system.debug('oliTBC: '+oliTBC);
        
        if(oliTBC.size()>0) {  
            Database.SaveResult[] result = Database.insert(oliTBC, false);  
            //system.debug('result: '+result);
        }
        
    }
        public static void createOppPartner(List<Opportunity> oppList) {
        List<Core_Opportunity_Partner__c> oppPartnerListTBC = new List<Core_Opportunity_Partner__c>();
        
        for(Opportunity opp : [select id, Core_Design_Registration_Id__r.Core_Partner_Account_Id__c from Opportunity where id in: oppList]) {
            if(opp.id != null) {
                system.debug('inside if: '+opp.id);
                Core_Opportunity_Partner__c op = new Core_Opportunity_Partner__c(Core_Opportunity__c = opp.id, Core_Partner_Type__c = 'Distributor', Core_Partner_Role__c = 'Co-Design');
                op.Core_Partner__c = opp.Core_Design_Registration_Id__r.Core_Partner_Account_Id__c;
                oppPartnerListTBC.add(op);    
            }    
        }
        
        //system.debug('oppPartnerListTBC: '+oppPartnerListTBC);
        
        if(oppPartnerListTBC.size()>0) {  
            Database.SaveResult[] lstDesignProductUpdate = Database.insert(oppPartnerListTBC, false);         
            //system.debug('lstDesignProductUpdate: '+lstDesignProductUpdate);
        }
    }
    
     public static Map<id,id> updateOppStatus(List<Opportunity> oppList) {
        List<Opportunity> updateOppList = new List<Opportunity>();
        List<OpportunityLineItem> updateOppLIList = new List<OpportunityLineItem>();
        Map<id,id> resultMap = new Map<id,id>();
        
        for(Opportunity opp: oppList) {
            opp.StageName = 'Production Win';
            updateOppList.add(opp);
            resultMap.put(opp.id,opp.Core_Design_Registration_Id__c);
        }
        
        for(OpportunityLineItem oli: [select id, Opportunity.Decision_Date__c, Core_Design_Registration_Product_Id__r.Core_Full_Year_Qty__c,Core_Design_Registration_Product_Id__r.Core_Target_Resale_Amt__c,Core_Design_Registration_Product_Id__r.Core_Design_Registration_Id__r.Core_Opportunity_Decision_Dt__c  from OpportunityLineItem where OpportunityId in :oppList]) {
            oli.Core_Status__c = 'Production Win';
                
                //Added per Sunil request
                //oli.Core_Approved_BU_Short_Name__c = oli.Opportunity.Decision_Date__c < Date.newInstance(2021,01,01) ? 'IOTG':'NEX NESG';
                //oli.Core_Approved_BU_Product_Segment__c = oli.Opportunity.Decision_Date__c < Date.newInstance(2021,01,01) ? 'IOTG-All' : oli.Opportunity.Decision_Date__c < Date.newInstance(2023,01,01) ? 'NEX IOTG-All' :'NEX NESG-All';
                //oli.Core_Approved_Quantity__c = oli.Core_Design_Registration_Product_Id__r.Core_Full_Year_Qty__c;
                //oli.Core_Approved_Sales_Price__c = oli.Core_Design_Registration_Product_Id__r.Core_Target_Resale_Amt__c;
                //oli.Core_Approved_Total_Price__c = oli.Core_Design_Registration_Product_Id__r.Core_Target_Resale_Amt__c * oli.Core_Design_Registration_Product_Id__r.Core_Full_Year_Qty__c;
                //oli.Core_Claim_Date__c = (Datetime) oli.Core_Design_Registration_Product_Id__r.Core_Design_Registration_Id__r.Core_Opportunity_Decision_Dt__c; //Added post WW44
        updateOppLIList.add(oli);
        }
        
        if(updateOppList.size()>0) {
            Database.SaveResult[] result = Database.update(updateOppList, false);  
            //system.debug('result: '+result);
        }
        
        if(updateOppLIList.size()>0) {
            Database.SaveResult[] result = Database.update(updateOppLIList, false);  
            //system.debug('result: '+result);
        }
        
        return resultMap;
    }
    
    
}