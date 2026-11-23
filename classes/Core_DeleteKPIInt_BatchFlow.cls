global class Core_DeleteKPIInt_BatchFlow{

    @InvocableMethod(label='Get OldKPIStaging Records' description='Gets 90 days old KPI staging records')
    global static List < FlowOutput > getOldKPIStaging(){
         List <FlowOutput> outputs = new List <FlowOutput>();
         Date core_last_90_days=system.today().addDays(-90);
         List<Core_KPI_Staging__c> oldKPIStaging =  [SELECT Id, OwnerId, Name, CreatedDate FROM Core_KPI_Staging__c where createdDate <= :core_last_90_days]; 
         FlowOutput kPIOutput = new FlowOutput();
         kPIOutput.kPIStag = oldKPIStaging;
         outputs.add(kPIOutput);
         return outputs;
    }    
    
    global class FlowOutput {
        
        @InvocableVariable
        global List<Core_KPI_Staging__c> kPIStag;
        
    }
}