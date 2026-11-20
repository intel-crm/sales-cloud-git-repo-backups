/**************************************************************************************
Apex Class Name:  CST_FlowApexActionController
Test Class Name: CST_UtilityClass_Test 
***************************************************************************************/
public class CST_FlowApexActionController {
    
    @InvocableMethod(label = 'Get Security Map Regions')
    public static List<FlowOutput> getSecurity(List<Id> feedbackBy) {
        
        system.debug('Feedback by size:'+feedbackBy.size());
        Set<Id> feedbackBySet = new Set<Id>(feedbackBy);
        system.debug('feedbackBySet ::'+feedbackBySet);
        List<FlowOutput> flowOutput = new List<FlowOutput>();
        FlowOutput output = new FlowOutput();
        list<String> secMapRegionList = new list<string>();
        
        List<AggregateResult> securityMap = [Select Region__c, count(Manager__r.name) from SPM_Security_Mapping__c where Manager__c in : feedbackBySet and 
                                             Role__c='Regional Lead' group by Region__c limit 2000];
        if(securityMap.size()>0){
            for(AggregateResult ar : securityMap) {
                if(!secMapRegionList.contains((String)ar.get('Region__c'))) {
                    secMapRegionList.add((String)ar.get('Region__c'));
                }
            }
        }
        output.listOfRARegions = secMapRegionList;
        for(integer i=1 ; i <= feedbackBy.size(); i++) {
            if(!flowOutput.contains(output)) {
                flowOutput.add(output);
            }
            else if(flowOutput.contains(output) || secMapRegionList.isEmpty() ) {
                flowOutput.add(null);
            }
        }
        system.debug('flowOutput ::'+flowOutput);
        return flowOutput;
    }
    
    public class FlowOutput {
        @InvocableVariable()
        public List<String> listOfRARegions;
    }
}