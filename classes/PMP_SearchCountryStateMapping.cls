public with sharing class PMP_SearchCountryStateMapping extends PMP_SearchWrapperStore{
    static Map<String, Set<Integer>> cache;
    @AuraEnabled(cacheable = true) 
    public static List<Option> getDependentMap() {
        
        cache = new Map<String, Set<Integer>>();
        List<Option> objResults = new List<Option>();
           
        Schema.DescribeFieldResult countryResult = Contact.MailingCountryCode.getDescribe();
		Schema.sObjectField ctrlField = countryResult.getSObjectField();
		Schema.DescribeFieldResult stateResult = Contact.MailingStateCode.getDescribe();
		Schema.sObjectField theField = stateResult.getSObjectField();
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
       
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<Option> controllingValues = new List<Option>();
        Map<String, Option> tempMap = new Map<String,Option>();
            
        for (Schema.PicklistEntry ple : contrEntries) {
                                   
            Option opt = new Option();
            opt.label = ple.getLabel();
            opt.value = ple.getValue();
            opt.children = new List<Option>();
            objResults.add(opt);
            //objResults.put(opt, new List<Options>());
            controllingValues.add(opt);
            tempMap.put(ple.getLabel(), opt);
            
        }
        
       
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String value = plew.value;
            
            for(Integer index : validForToIndices(plew.validFor)){
                	List<Option> optList = controllingValues.get(index).children;
                    Option opt = new Option();
                    opt.label = label;
                    opt.value = value;
                    optList.add(opt);
                    //objResults.put(controllingValues.get(i), optList);
                    objResults.get(index).children = optList;
            }
                        
        }
        //system.debug('country/state');
        //system.debug(objResults.keySet().size());
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    public static Set<Integer> validForToIndices(String validFor) {

        Set<Integer> indices = cache.get(validFor);
        if (indices == null) {
            indices = new Set<Integer>();

            String validForBits = base64ToBits(validFor);
            for (Integer i = validForBits.indexOf('1'); i >= 0; i = validForBits.indexOf('1', i + 1)) {
                indices.add(i);
            }

            cache.put(validFor, indices);
        }

        return indices;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public String parent {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
}