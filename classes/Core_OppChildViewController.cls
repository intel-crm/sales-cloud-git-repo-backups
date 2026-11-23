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
    // public List<SelectOption> recordTypeOptions {get;set;}
    
    public boolean isNewOppClicked { get; set; }
        
    public void setSelectedRecordType2() {
        system.debug('INSIDE SELECTED RECORDTYPE FUNCTION'+this.selectedRecordType);
        this.selectedRecordType2 = this.selectedRecordType.escapeHtml4();
        system.debug('SELECTED RECORDTYPE2 LINE 19:'+this.selectedRecordType2);
    }
    
    
    
    public Core_OppChildViewController(ApexPages.StandardController stdController) {
        // Get a reference to the master opportunity, which we should be on
        this.solutionGroup = (Opportunity) stdController.getRecord();
        accId = solutionGroup.AccountId;
        newOppId='';
        urlparams = ApexPages.currentPage().getParameters();
        theme = UserInfo.getUiThemeDisplayed(); 
        
       
        List<SelectOption> recordTypeOptions = new List<SelectOption>();
        string OppObjName = 'Opportunity';
        string dealOpp = 'Deal Opportunity';
        string designOpp = 'Design Opportunity';
        Set<string> santizedRecTypeNames = new Set<string>();
        santizedRecTypeNames.add(dealOpp.escapeHtml4());
        santizedRecTypeNames.add(designOpp.escapeHtml4());
        for(RecordType rt : [Select name, Id from RecordType where SobjectType = :OppObjName.escapeHtml4() and Name In :santizedRecTypeNames])
        {
            recordTypeOptions.add(new SelectOption(rt.Id,rt.name));
        }
        system.debug('RECORDTYPE OPTIONS:'+recordTypeOptions);
        SelectOption defaultOption = recordTypeOptions[0];
        system.debug('SELECTED RECORDTYPE DEFAULT:'+defaultOption);
        this.selectedRecordType2 = defaultOption.getValue().escapeHtml4();
         system.debug('SELECTED RECORDTYPE LINE 45:'+selectedRecordType2);
    }
    
    // Getter method for our sub-opportunity list
    public List<Opportunity> getChildOpps() {
        
        // Pull all sub-opportunity data for all 3 tabs in a single query
        List<Opportunity> oppList = [select Id, Name, StageName, Amount, TotalOpportunityQuantity, CloseDate,
                                     (select Product2.Name from OpportunityLineItems order by Product2.Name),
                                     (select Core_Feature_Type__c, Core_Feature_Name__c from Opportunity_Features__r order by Core_Feature_Type__c),
                                     (select Name, User.Id from OpportunityTeamMembers order by Name)
                                     from Opportunity
                                     where Core_Solution_Group__r.Id = :solutionGroup.Id
                                     order by Name];
        
        if (oppList.size() > 0)
            return oppList;
        else
            return null;
    }
    
    // Getter method for the URL for the "New Sub Opportunity" button
    public String getNewOppUrl() {
        system.debug('OPP URL:'+this.selectedRecordType2);
        //if(theme == 'Theme3'){          
        return '/006/e?CF' + Label.Core_Opp_Solution_Group_Field_Id + '=' + EncodingUtil.urlEncode(solutionGroup.Name, 'UTF-8') +
            '&CF' + Label.Core_Opp_Solution_Group_Field_Id + '_lkid=' + solutionGroup.Id +
            '&retURL=%2F' + solutionGroup.Id +
            '&accid=' + solutionGroup.AccountId +
            '&RecordType=' + this.selectedRecordType2 +
            '&ent=Opportunity';
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
            Id newChildOppId = solutionGroup.Core_Solution_Group__c;
            
            if (newChildOppId != solutionGroup.Id) {
                Opportunity newChildOpp = [select Core_Solution_Group__c from Opportunity where Id = :newChildOppId];
                newChildOpp.Core_Solution_Group__c = solutionGroup.Id;
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
        for(RecordType rt : [Select Name, Id from RecordType where SobjectType = 'Opportunity' and Name In ('Deal Opportunity', 'Design Opportunity')])
        {
            recordTypeOptions.add(new SelectOption(rt.Id,rt.name));
        }
        return recordTypeOptions;
        
    }
    
    
}