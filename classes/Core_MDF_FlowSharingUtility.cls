public class Core_MDF_FlowSharingUtility {
    
    public static Map<String,String> fetchRecordTypeMetaData(){
       Map<String,String> mapOfRecordTypes = new Map<String,String>();
       for(Core_MDF_ClaimActAllocRecTypeMapping__mdt recTypeMetaData:[Select Id,Core_MDF_Region_cd__c,Core_MDF_Channel_Program_txt__c,Core_MDF_Allocation_RecordType_txt__c,Core_MDF_Claim_RecordType_txt__c,Core_MDF_Enable_Fund_Reservation_chk__c 
       from Core_MDF_ClaimActAllocRecTypeMapping__mdt]){
          mapOfRecordTypes.put(recTypeMetaData.Core_MDF_Channel_Program_txt__c,recTypeMetaData.Core_MDF_Region_cd__c);  
       }
       return mapOfRecordTypes;
    }
    /*
    @InvocableMethod(label='Check If Program Retail' description='Returns true if program is retail')
    public static List<String> isSubRegionPresent(List<String> ProgramName) {
        system.debug('ProgramName.size()::'+ProgramName.size());
        Integer i = ProgramName.size();
        Integer j = 0;
        Map<String,String> mapOfRecordTypes = new Map<String,String>();
        List<String> returnBooleanList = new List<String>();
        mapOfRecordTypes = fetchRecordTypeMetaData();
        system.debug('programName::'+programName);
        system.debug('programName[0]::'+programName[0]);
        system.debug('mapOfRecordTypes::'+mapOfRecordTypes);
        if(mapOfRecordTypes.get(programName[0])!=null){
            for(j = 0; j<i; j++){
                returnBooleanList.add('true');
            }
            system.debug('returnBooleanList.size()::'+returnBooleanList.size());
            return returnBooleanList;
        }else{
            for(j = 0; j<i; j++){
                returnBooleanList.add('false');
            }
            system.debug('returnBooleanList.size()::'+returnBooleanList.size());
            return returnBooleanList;
        }
    }*/
    @InvocableMethod(label='Check If Program Retail' description='Returns true if program is retail')
    public static Void isSubRegionPresent(List<Core_MDF_Partner_Group_Mapping__c> pgmList) {
        system.debug('pgm::'+pgmList);
        system.debug('ProgramName.size()::');
    }
}