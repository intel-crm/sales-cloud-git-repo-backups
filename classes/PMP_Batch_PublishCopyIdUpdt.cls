global class  PMP_Batch_PublishCopyIdUpdt implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
       
       // query='SELECT Id, PMP_Working_Copy_Id__c,PMP_Is_Published_Ind__c,PMP_Partner_Offering_Lifecycle_Status_Nm__c  FROM PMP_Partner_Offering__c  where PMP_Published_Copy_Id_Txt__c = null';
      
        query=null;
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<PMP_Partner_Offering__c> scope){
        
        // List<PMP_Partner_Offering__c> offerings = new List<PMP_Partner_Offering__c> ();
        
        
        // for (PMP_Partner_Offering__c offering : scope){
            

        //     if((offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c =='Published' && offering.PMP_Working_Copy_Id__c == null) || 
        //         (offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c !='Published' && offering.PMP_Is_Published_Ind__c == false)){
                   
        //            PMP_Partner_Offering__c offeringNew0 = new PMP_Partner_Offering__c ();   
        //            offeringNew0.Id = offering.Id;
        //            offeringNew0.PMP_Published_Copy_Id_Txt__c = offering.Id;
        //            offerings.add(offeringNew0);

        //     } 

        //     if(offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c =='Published' && offering.PMP_Working_Copy_Id__c != null){
                    
        //         //For Published Copy        
        //         PMP_Partner_Offering__c offeringNew = new PMP_Partner_Offering__c ();   
        //         offeringNew.Id = offering.Id;
        //         offeringNew.PMP_Published_Copy_Id_Txt__c = offering.Id;
        //         offerings.add(offeringNew);
               
        //         //For Working Copy
        //         PMP_Partner_Offering__c offeringNew1 = new PMP_Partner_Offering__c ();
        //         offeringNew1.Id = offering.PMP_Working_Copy_Id__c;
        //         offeringNew1.PMP_Published_Copy_Id_Txt__c = offering.Id;
        //         offerings.add(offeringNew1);
                
               
        //     }   
               
            
        // }
        
        // MAP<Id,PMP_Partner_Offering__c> offMap = new MAP<Id,PMP_Partner_Offering__c>();
        
        // offMap.putall(offerings);
        // if(offMap.size()>0){
        //     update offMap.values();
        // }
        
        
        
    }    
    global void finish(Database.BatchableContext bc){
       
    }  
}