public with sharing class UpdateMetadataAction{
    
    
@AuraEnabled(cacheable=true)
    public static boolean updateMetadata()
    {
        boolean isFlag=false; 
           string customLabelStartDate =System.Label.startDateLabel;
        string customLabelEndDate =System.Label.endDateLabel;
        If(!String.isBlank(customLabelStartDate) && !String.isBlank(customLabelEndDate)){
         date dateStr = Date.today();
         date customLabelStartValue = date.parse(System.Label.startDateLabel);
         date customLabelEndValue = date.parse(System.Label.endDateLabel);
        system.debug('customLabelStartValue'+customLabelStartValue);
        system.debug('customLabelEndValue'+customLabelEndValue);
        system.debug('dateStr'+dateStr);
        
        if(dateStr>=customLabelStartValue && dateStr <= customLabelEndValue)
        { 
            isFlag=true;
}
        
        System.debug('>>>>' + isFlag);
        /*List<TestingFlowPageLayout__mdt> recordsToUpdate=[SELECT id,value__c from TestingFlowPageLayout__mdt];
        system.debug('checkData'+recordsToUpdate);
             if(recordsToUpdate!=null && !recordsToUpdate.isEmpty())  
{
  for(TestingFlowPageLayout__mdt recToUpdate:recordsToUpdate)
        {
            addValue=recToUpdate.value__c;
         }  
}*/
        	
   
        
    //  list<string> lstLabel = customLabelValue.split(';');
      //     system.debug('addValue1'+lstLabel[0]);
      //    system.debug('addValue2'+lstLabel[1]);
       //   system.debug('addValue3'+lstLabel[2]);
        }      
       return isFlag;  
    }
}