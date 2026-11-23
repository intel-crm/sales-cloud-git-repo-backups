public without sharing class BusinessDays {
    public static Map<String,Id> mapRecTypeId = new Map<String,Id>();
    public static List<RecordType> rtList = new List<RecordType>();
    public static Id paymentDocumentRecordTypeId;
    public static Id submitForApprovalRecordTypeId;
    static{
        rtList = [select Id,DeveloperName from RecordType where sObjectType= 'Core_MDF_Claim_VAT_Info__c'];
        for(RecordType rt:rtList){
            mapRecTypeId.put(rt.DeveloperName, rt.Id);
        }
        paymentDocumentRecordTypeId = mapRecTypeId.get('Core_MDF_Payment_Document');
        submitForApprovalRecordTypeId = mapRecTypeId.get('Core_MDF_Submit_for_Approvals');
    }
    
    
    public static Boolean isWeekendDay(Date dateParam)
   {
      boolean result     = false;
      Date startOfWeek   = dateParam.toStartOfWeek();
      Integer dayOfWeek  = dateParam.day() - startOfWeek.day();
      result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
      return result;
   } 
   
   
   public static Date addBusinessDays(Date startDate, integer businessDaysToAdd )
   {
      //Add or decrease in businessDaysToAdd days 
      Date finalDate = startDate;
      integer direction = businessDaysToAdd < 0 ? -1 : 1;
      while(businessDaysToAdd != 0)
       {
           finalDate = finalDate.AddDays(direction);
           if (!isWeekendDay(finalDate))
           {
               businessDaysToAdd -= direction;
               
           }
       }

       return finalDate;
   }
}