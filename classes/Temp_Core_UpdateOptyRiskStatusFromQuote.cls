public class Temp_Core_UpdateOptyRiskStatusFromQuote	 {  
    @future
    public static void AtRiskForTenderQuotes(Set<Id> sqIds){        
        Try{
            	 // List To Capture the Opportunities of respective Quotes
            	Set<Id> oppIds = new Set<Id>();
                //List to capture the quote id's
                Set<Id> quoteIds = new set<Id>();
            	list<OpportunityLineItem> opplinelist = new list<OpportunityLineItem>();
               // Get the list of QuotelineItems of the respective Quotes
                list<SBQQ__QuoteLine__c> quoteLineList = [Select Id,SBQQ__Product__c,SBQQ__Product__r.NAME,SBQQ__Quote__r.Pricing_Quote_Program_Nm__c,Pricing_Status_Nm__c,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__r.ApprovalStatus__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,Pricing_Quote_Program_Nm__c from SBQQ__QuoteLine__c 
                                                          where SBQQ__Quote__c IN : sqIds AND SBQQ__Quote__r.SBQQ__Opportunity2__c != NULL 
                                                          AND ((SBQQ__Quote__r.Pricing_Quote_Program_Nm__c = : system.label.Pricing_Tender_Quote_Program)AND (Pricing_Status_Nm__c = : system.label.Quote_Pricing_Status OR Pricing_Status_Nm__c = : system.label.Pricing_Status_Won))];
              //custom label - Pricing_Tender_Quote_Program = Tender, Quote_Pricing_Status = Approved or Pricing_Status_Won =Won                      
            for(SBQQ__QuoteLine__c qline : quoteLineList){
                quoteIds.add(qline.SBQQ__Quote__c);
                oppIds.add(qline.SBQQ__Quote__r.SBQQ__Opportunity2__c);
              }                 
                // Quote For loop to add all the Opportunities into set
               /* for(SBQQ__Quote__c qId : [SELECT Id,SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id IN : sqIds])
                { 
                    oppIds.add(qId.SBQQ__Opportunity2__c);
                } */       
               //oppIds.add(quoteLineList.SBQQ__Quote__r.SBQQ__Opportunity2__c);                 
                
                opplinelist = [SELECT Id,Core_At_Risk__c,Core_At_Risk_Status__c,Product2Id,Product2.NAME,UnitPrice,TotalPrice FROM OpportunityLineItem  WHERE OpportunityId IN : oppIds ];        
               
               list<OpportunityLineItem> oppupdatelist =new list<OpportunityLineItem>(); 
                if(quoteLineList.size() >0)
                {
                     // QuoteLine For Loop

                         for(SBQQ__QuoteLine__c quoteline : quoteLineList)
                            {
                                if(opplinelist.size()>0) //
                                {
                                    // OpportunityLine for Loop     
                                    for(OpportunityLineItem Oppline : opplinelist)   
                                    {
                                        
                                            if(Oppline.Product2Id == quoteLine.SBQQ__Product__c && Oppline.Core_At_Risk__c && (Oppline.Core_At_Risk_Status__c == system.label.At_Risk_Status_New || Oppline.Core_At_Risk_Status__c == system.label.At_Risk_Status_In_Progress))
                                               {
                                                   
                                                   system.debug('inside Tender if condition');     //                               
                                                   Oppline.Core_At_Risk_Status__c = system.label.At_Risk_Status_Closed;//
                                                   oppupdatelist.add(Oppline);
                                                   //At_Risk_Status_Closed =closed:support provided
                                               }    
                                    }
                                }// End if (opportunitylinelist)
                                else
                                {
                                    Continue;
                                }
                            }
                                  Database.SaveResult[] srList=  Database.update(oppupdatelist);  //
                                    // test the bug
                                  for (Database.SaveResult ur : srList) {
                                      if (ur.isSuccess()) {
                                          // Operation was successful, so get the ID of the record that was processed
                                          system.debug('updated record: '+ur.getid());
                                      }
                                      else {
                                          for(Database.Error err : ur.getErrors()) {
                                              System.debug('The following error has occurred.');                    
                                              System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                             // System.debug('fields that affected this error while updating : ' + err.getFields());
                                          }
                                      }
                                  }
                }            //  Database.update   partial   //updata 10 & 1 fail it will stop
                 } // End if (quoteLineList) 
        
        Catch (Exception e)
        {
             System.debug('Error--'+e.getMessage());
        }
    }
    @future 
    public static void AtRiskForPSGQuotes(Set<Id> sqIds)
    {
       Try{     
         
               // Get the list of QuotelineItems of the respective Quotes
                list<SBQQ__QuoteLine__c> quoteLineList = [Select Id,SBQQ__Product__c,SBQQ__Product__r.NAME,SBQQ__Quote__r.Pricing_Quote_Program_Nm__c,SBQQ__Quote__r.SBQQ__Status__c,SBQQ__Quote__r.ApprovalStatus__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,price_suggested_resale_amt__c,Pricing_Quote_Program_Nm__c from SBQQ__QuoteLine__c 
                                                          where SBQQ__Quote__c IN : sqIds AND SBQQ__Quote__r.SBQQ__Opportunity2__c != NULL 
                                                          AND SBQQ__Quote__r.Pricing_Quote_Program_Nm__c = :system.label.Pricing_PSG_Quote_Program AND SBQQ__Quote__r.SBQQ__Status__c = :system.label.Quote_Pricing_Status];
                
                // List To Capture the Opportunities of respective Quotes
                Set<Id> oppIds = new Set<Id>();
                 
               //List to capture the quote id's
                Set<Id> quoteIds = new set<Id>();
                
                for(SBQQ__QuoteLine__c qline : quoteLineList){
                quoteIds.add(qline.SBQQ__Quote__c);
                oppIds.add(qline.SBQQ__Quote__r.SBQQ__Opportunity2__c);
                  }             
                
               /* // Quote For loop to add all the Opportunities into set
                for(SBQQ__Quote__c qId : [SELECT Id,SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE Id IN : sqIds])
                {
                    oppIds.add(qId.SBQQ__Opportunity2__c);
                } */
           
           
                list<OpportunityLineItem> opplinelist = new list<OpportunityLineItem>();
                opplinelist = [SELECT Id,Core_At_Risk__c,Core_At_Risk_Status__c,Product2Id,Product2.NAME,UnitPrice,TotalPrice FROM OpportunityLineItem WHERE OpportunityId IN : oppIds ];        
                     
                list<OpportunityLineItem> oppupdatelist =new list<OpportunityLineItem>();  
                if(quoteLineList.size() >0)
                {
                         // QuoteLine For Loop
                         for(SBQQ__QuoteLine__c quoteline : quoteLineList)
                            {
                                if(opplinelist.size()>0)
                                {
                                        // OpportunityLine for Loop     
                                        for(OpportunityLineItem Oppline : opplinelist)
                                        {
                                            
                                                if(Oppline.Product2Id == quoteLine.SBQQ__Product__c && Oppline.Core_At_Risk__c && (Oppline.Core_At_Risk_Status__c == system.label.At_Risk_Status_New || Oppline.Core_At_Risk_Status__c == system.label.At_Risk_Status_In_Progress))
                                                   {
                                                       system.debug('inside PSG if condition');
                                                       Oppline.UnitPrice = quoteline.price_suggested_resale_amt__c;
                                                       Oppline.Core_At_Risk_Status__c = system.label.At_Risk_Status_Closed;
                                                       oppupdatelist.add(Oppline);
                                                   }    
                                        }
                                }// End if (opportunitylinelist)
                                else{
                                    Continue;
                                }
                            }
                    
                    
                                    Database.SaveResult[] srList=  Database.update(oppupdatelist);  //
                                    // test the bug
                                    for (Database.SaveResult ur : srList) {
                                        if (ur.isSuccess()) {
                                            // Operation was successful, so get the ID of the record that was processed
                                            system.debug('updated record: '+ur.getid());
                                        }
                                        else {
                                            for(Database.Error err : ur.getErrors()) {
                                                System.debug('The following error has occurred.');                    
                                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                                // System.debug('fields that affected this error while updating : ' + err.getFields());
                                            }
                                        }
                                    }
                }// End if (quoteLineList)
       }
        Catch (Exception e){
            System.debug('Error--'+e.getMessage());
        }
    }
}