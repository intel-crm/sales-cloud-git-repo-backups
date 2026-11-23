public without sharing class Core_MDF_Create_Budget1 {    
    
    public static Id createBudget(Campaign campObj){  
        PartnerMarketingBudget budget = setCommontFields(campObj);
        database.insert(budget);  
        return budget.Id;
    }
    
    public static PartnerMarketingBudget setCommontFields(Campaign campObj){
        PartnerMarketingBudget budget = new PartnerMarketingBudget();
            budget.Title = campObj.Name + ' Budget';
            budget.Description=campObj.Description;
            budget.StartDate = campObj.StartDate;
            budget.EndDate = campObj.EndDate;
            budget.Core_MDF_Budget_Partner__c = campObj.Core_MDF_Account__c;
            budget.Core_MDF_Program__c = campObj.Core_MDF_Channel_Program__c;
            budget.Core_MDF_Budget_Type__c = campObj.Core_MDF_Budget_Type_txt__c;
            Id recordtype = Schema.SObjectType.PartnerMarketingBudget.getRecordTypeInfosByDeveloperName().get('Core_MDF_Intel_Partner_Alliance').getRecordTypeId(); 
            budget.RecordTypeId = recordtype;
            budget.Amount = campObj.Core_MDF_Budget_Amount_amt__c; 
            budget.Core_MDF_Budget_Status__c ='Released';
            return budget;
    }

}