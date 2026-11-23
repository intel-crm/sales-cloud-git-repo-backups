public class Core_CCV_Clone_Controller {

    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}

     // add the instance for the variables being passed by id on the url
    private Core_CCV__c ccv {get;set;}
    
    // set the id of the record that is created -- ONLY USED BY THE TEST CLASS
    public ID newRecordId {get;set;}

    // initialize the controller
    public Core_CCV_Clone_Controller(ApexPages.StandardController controller) {

        //initialize the stanrdard controller
        this.controller = controller;
        
        // load the current record
        ccv = (Core_CCV__c)controller.getRecord();

    }

    // method called from the VF's action attribute to clone the CCV
    public PageReference cloneWithItems() {

         // setup the save point for rollback
         Savepoint sp = Database.setSavepoint();
         Core_CCV__c newCCV;

         try {
             
             // Don't want to auto-create value maps during a clone.
             Core_CCVHandler.valueMapBypass = true;
             ccv = [select Id, Name, Core_Account__c, Core_Opportunity__c, Core_Business_Condition__c, Core_Customer_Major_Products__c, Core_Customer_Strategy__c, Core_Intel_Hurdles__c from Core_CCV__c where id = :ccv.id];
             newCCV = ccv.clone(false);
             insert newCCV;
             Core_CCVHandler.valueMapBypass = false;

             // set the id of the new po created for testing
             newRecordId = newCCV.id;

             List<Core_Value_Chain__c> itemsVC = new List<Core_Value_Chain__c>();
             for (Core_Value_Chain__c vc : [SELECT Id, Name, Core_CCV__c, Core_Challenges__c, Core_Function__c, Core_Proposals__c, Core_KPI__c, Core_Goals__c FROM Core_Value_Chain__c WHERE Core_CCV__c = :ccv.id]) {
                  Core_Value_Chain__c newVC = vc.clone(false);
                  newVC.Core_CCV__c = newCCV.id;
                  itemsVC.add(newVC);
             }
             if (itemsVC.size() > 0)
                 insert itemsVC;

             List<Core_Capability_Matrix__c> itemsCM = new List<Core_Capability_Matrix__c>();
             for (Core_Capability_Matrix__c cm : [SELECT Id, Name, Core_CCV__c, Core_Company__c, Core_Other__c, Core_People__c, Core_Products_Services__c, Core_Programs__c FROM Core_Capability_Matrix__c WHERE Core_CCV__c = :ccv.id]) {
                  Core_Capability_Matrix__c newCM = cm.clone(false);
                  newCM.Core_CCV__c = newCCV.id;
                  itemsCM.add(newCM);
             }
             if (itemsCM.size() > 0)
                 insert itemsCM;          
             
             List<Core_Value_Map__c> itemsVM = new List<Core_Value_Map__c>();
             for (Core_Value_Map__c vm : [SELECT Id, Name, Core_CCV__c, Core_Customer_Value__c, Core_Intel_Performance_HIGH__c, Core_Intel_Performance_LOW__c, Core_Intel_Performance_MED__c FROM Core_Value_Map__c WHERE Core_CCV__c = :ccv.id]) {
                  Core_Value_Map__c newVM = vm.clone(false);
                  newVM.Core_CCV__c = newCCV.id;
                  itemsVM.add(newVM);
             }
             if (itemsVM.size() > 0)
                 insert itemsVM;   
             
             List<Core_Customer_Financials__c> itemsCF = new List<Core_Customer_Financials__c>();
             for (Core_Customer_Financials__c cf : [SELECT Id, Name, Core_CCV__c, Core_Customer_Profit__c, Core_Customer_Revenue__c, Core_Financials_Year__c FROM Core_Customer_Financials__c WHERE Core_CCV__c = :ccv.id]) {
                  Core_Customer_Financials__c newCF = cf.clone(false);
                  newCF.Core_CCV__c = newCCV.id;
                  itemsCF.add(newCF);
             }
             if (itemsCF.size() > 0)
                 insert itemsCF;   
             
             
             List<Core_Intel_Business_Summary__c> itemsIBS = new List<Core_Intel_Business_Summary__c>();
             for (Core_Intel_Business_Summary__c ibs : [SELECT Id, Name, Core_CCV__c, Core_CPU_Vol__c, Core_MSS__c, Core_CPU_Net_ASP__c, Core_Summary_Revenue__c, Core_Summary_Year__c FROM Core_Intel_Business_Summary__c WHERE Core_CCV__c = :ccv.id]) {
                  Core_Intel_Business_Summary__c newIBS = ibs.clone(false);
                  newIBS.Core_CCV__c = newCCV.id;
                  itemsIBS.add(newIBS);
             }
             if (itemsIBS.size() > 0)              
                 insert itemsIBS;   
             
             
         } catch (Exception e){

            // Reset Gating!
            Core_CCVHandler.valueMapBypass = false;

             // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }

        return new PageReference('/'+newCCV.id+'/e?retURL=%2F'+newCCV.id);

    }

}