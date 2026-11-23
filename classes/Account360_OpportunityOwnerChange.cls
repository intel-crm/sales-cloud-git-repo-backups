public class Account360_OpportunityOwnerChange {
    public class InputData{
        @InvocableVariable
        public Id accountOwnerId;
        @InvocableVariable
        public Id priorAccountOwnerId;
    }
    @InvocableMethod
    public static void invokeAccount360OpportunityOwnerChange(List<InputData> inputData)
    {
       Set<Id> priorAccIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        for(InputData inp : inputData){
            if(inp != null){
                priorAccIds.add(inp.priorAccountOwnerId);
                accIds.add(inp.accountOwnerId);
            }
            
        }
        
        System.debug('priorAccIds...'+priorAccIds);
        System.debug('accIds...'+accIds);
    }
    
        

}