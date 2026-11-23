public without sharing class Core_OppChildViewController { //TWC3123-5376: codescan fix: added without sharing
    
    // Solution group and its child opportunities
    public Opportunity solutionGroup{get;set;} 
    public string accId{get;set;}
    public String newOppId{get;set;} 
    public String selectedRecordType{get;set;}
    public String newOppUrl;
    public String selectedRecordType2{get;set;}
    public List<Opportunity> childOpps;
    public Map<String, String> urlparams{get;set;}
    public String theme{get;set;}
    
    public boolean isNewOppClicked { get; set; }
  
    
    public void setSelectedRecordType2() {
        this.selectedRecordType2 = this.selectedRecordType.escapeHtml4();
    }
    
    
    
    public Core_OppChildViewController(ApexPages.StandardController stdController) {
        // Get a reference to the master opportunity, which we should be on
        this.solutionGroup = (Opportunity) stdController.getRecord();
        accId = String.valueOf(solutionGroup.AccountId).escapeHtml4();
        newOppId='';
        urlparams = ApexPages.currentPage().getParameters();
        theme = UserInfo.getUiThemeDisplayed(); 
        
       
        List<SelectOption> recordTypeOptions = new List<SelectOption>();
        string OppObjName = 'Opportunity';
        string dealOpp = 'Deal Opportunity';
        string designOpp = 'Design Opportunity';
        Set<string> santizedRecTypeNames = new Set<string>();
        santizedRecTypeNames.add(String.escapeSingleQuotes(dealOpp));
        santizedRecTypeNames.add(String.escapeSingleQuotes(designOpp));
        for(RecordType rt : [Select name, Id from RecordType where SobjectType = :String.escapeSingleQuotes(OppObjName) and Name In :santizedRecTypeNames])
        {
            recordTypeOptions.add(new SelectOption(rt.Id,rt.name));
        }
        SelectOption defaultOption = recordTypeOptions[0];
        this.selectedRecordType2 = String.escapeSingleQuotes(defaultOption.getValue());
    }
    
    // Getter method for our sub-opportunity list
    public List<Opportunity> getChildOpps() {
        
        // Pull all sub-opportunity data for all 3 tabs in a single query
        List<Opportunity> oppList = [select Id, Name, StageName, Amount, TotalOpportunityQuantity, CloseDate,
                                     (select Product2.Name from OpportunityLineItems order by Product2.Name),
                                     (select Core_Feature_Type__c, Core_Feature_Name__c from Opportunity_Features__r order by Core_Feature_Type__c),
                                     (select Name, User.Id from OpportunityTeamMembers order by Name)
                                     from Opportunity
                                     where Core_Solution_Group__r.Id = :String.escapeSingleQuotes(solutionGroup.Id)
                                     order by Name];
        
        if (oppList.size() > 0)
            return oppList;
        else
            return null;
    }
    
    // Getter method for the URL for the "New Sub Opportunity" button
    public String getNewOppUrl() {
       
        //if(theme == 'Theme3'){   
        //
        string url = '/006/e?CF' + Label.Core_Opp_Solution_Group_Field_Id + '=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(solutionGroup.Name), 'UTF-8') +
            '&CF' + Label.Core_Opp_Solution_Group_Field_Id + '_lkid=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(solutionGroup.Id), 'UTF-8') +
            '&retURL=%2F' + EncodingUtil.urlEncode(String.escapeSingleQuotes(solutionGroup.Id), 'UTF-8') +
            '&accid=' + EncodingUtil.urlEncode(String.escapeSingleQuotes(solutionGroup.AccountId), 'UTF-8') +
            '&RecordType=' + EncodingUtil.urlEncode(this.selectedRecordType2, 'UTF-8') +
            '&ent=Opportunity';       
        return url;
	// }
        //return '';
    }
    

    
    // Action method doesn't actually need to do anything
    public PageReference newOpp() {
        isNewOppClicked = false;
        return null;
    }
    
    
    
    
    
    // Override the save method
    public PageReference save() {
        
        if (solutionGroup.Core_Solution_Group__c != null) {
            
            // We need to flip what the user actually picked, so we store that as the child of the opportunity they were on,
            // instead of as the parent.  Also check to make sure they're not trying to create a circular reference.
            Id newChildOppId = String.escapeSingleQuotes(solutionGroup.Core_Solution_Group__c);
            
            if (newChildOppId != String.escapeSingleQuotes(solutionGroup.Id)) {
                Opportunity newChildOpp = [select Core_Solution_Group__c from Opportunity where Id = :newChildOppId];
                newChildOpp.Core_Solution_Group__c = String.escapeSingleQuotes(solutionGroup.Id);
                update newChildOpp; 
            }
        }
        
        solutionGroup.Core_Solution_Group__c = null;
        return ApexPages.currentPage();
    }
    
    
    public void setIsNewOppClickedTotrue()
    {
        isNewOppClicked = true;
    }
    
    public List<SelectOption> getRecordTypeOptions() {
        List<SelectOption> recordTypeOptions = new List<SelectOption>();
        string OppObjName = 'Opportunity';
        string dealOpp = 'Deal Opportunity';
        string designOpp = 'Design Opportunity';
        Set<string> santizedRecTypeNames = new Set<string>();
        santizedRecTypeNames.add(String.escapeSingleQuotes(dealOpp));
        santizedRecTypeNames.add(String.escapeSingleQuotes(designOpp));
        
        for(RecordType rt : [Select Name, Id from RecordType where SobjectType = :String.escapeSingleQuotes(OppObjName) and Name In :santizedRecTypeNames])
        {
            string key = string.valueOf(rt.Id);
            recordTypeOptions.add(new SelectOption(key.escapeHtml4(),rt.name.escapeHtml4()));
        }
        return recordTypeOptions;
        
    }
/**********************************************--------------LWC Conversion Methods-------------*****************************************************/   
    // Getter method for our sub-opportunity list
    @AuraEnabled(cacheable=true)
    public static List<childRecordsWrapper> getChildOpptys(Id oppId) {
        List<childRecordsWrapper> wrprList = new List<childRecordsWrapper>();
        
        // Pull all sub-opportunity data for all 3 tabs in a single query
        List<Opportunity> oppList = [select Id, Name, StageName, Amount, TotalOpportunityQuantity, CloseDate,
                                     (select Product2.Name from OpportunityLineItems order by Product2.Name),
                                     (select Core_Feature_Type__c, Core_Feature_Name__c from Opportunity_Features__r order by Core_Feature_Type__c),
                                     (select Name, User.Id,OpportunityId from OpportunityTeamMembers order by Name)
                                     from Opportunity
                                     where Core_Solution_Group__r.Id = :oppId
                                     order by Name];
        
        if (!oppList.IsEmpty()) {
            for(Opportunity opp : oppList) {
                childRecordsWrapper wrpr = new childRecordsWrapper();
                wrpr.Id                   = opp.Id;
                wrpr.OppName              = opp.Name;
                wrpr.OppURL               = '/lightning/r/' + opp.Id + '/view';
                wrpr.StageName            = opp.StageName;
                wrpr.Amount               = opp.Amount;
                wrpr.TotalOppQuantity     = opp.TotalOpportunityQuantity;
                wrpr.CloseDate            = opp.CloseDate;
                wrpr.OpportunityLineItems = opp.OpportunityLineItems;
                wrpr.OpportunityFeatures  = opp.Opportunity_Features__r;
                
                List<OpportunityTeamMemberWrapper> otmWrprList = new List<OpportunityTeamMemberWrapper>();
                for(OpportunityTeamMember otm : opp.OpportunityTeamMembers) {
                    OpportunityTeamMemberWrapper otmwrpr = new OpportunityTeamMemberWrapper();
                    otmwrpr.Id       = otm.Id;
                    otmwrpr.OppId    = otm.OpportunityId;
                    otmwrpr.UserName = otm.Name;
                    otmwrpr.UserId   = otm.User.Id;
                    otmwrpr.UserURL  = '/lightning/r/' + otm.User.Id + '/view';
                    otmWrprList.add(otmwrpr);    
                }
                wrpr.OpportunityTeamMembers = otmWrprList;
                wrprList.add(wrpr);
            }
            return wrprList;
        }
        else
            return null;
    }
    
    @AuraEnabled
    public static boolean updateOpportunity(String oppDataString) {
        boolean savedData = false;
        try {
            List<Opportunity> oppList = (List<Opportunity>)System.JSON.deserializeStrict(oppDataString, List<Opportunity>.Class);
            if(oppList.size()>0) {
                system.debug('AA oppList--'+oppList);
                Database.update(oppList,true);
                savedData = true;
            }
            return savedData;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
                
                
    public class childRecordsWrapper {
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string OppURL;
        @AuraEnabled
        public string OppName;
        @AuraEnabled
        public string StageName;
        @AuraEnabled
        public decimal Amount;
        @AuraEnabled
        public decimal TotalOppQuantity;
        @AuraEnabled
        public date CloseDate;
        @AuraEnabled
        public List<OpportunityLineItem> OpportunityLineItems;
        @AuraEnabled
        public List<Core_Opportunity_Features__c> OpportunityFeatures;
        @AuraEnabled
        public List<OpportunityTeamMemberWrapper> OpportunityTeamMembers;
    }
    public class OpportunityTeamMemberWrapper {
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string OppId;
        @AuraEnabled
        public string UserName;
        @AuraEnabled
        public string UserId;
        @AuraEnabled
        public string UserURL;
    }    
}