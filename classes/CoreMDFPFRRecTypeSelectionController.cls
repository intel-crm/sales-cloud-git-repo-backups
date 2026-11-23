public class CoreMDFPFRRecTypeSelectionController {
    
    // ──────────────────────────────────────
    // Get Dropdown Values - Cached
    // ──────────────────────────────────────
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getDropdownValues() {
        
        List<Map<String, String>> dropdownValues = 
            new List<Map<String, String>>();
        
        dropdownValues.add(new Map<String, String>{
            'label' => 'Client',
            'value' => 'Client'
        });
        dropdownValues.add(new Map<String, String>{
            'label' => 'Data Center',
            'value' => 'Data_Center'
        });
        dropdownValues.add(new Map<String, String>{
            'label' => 'IPA',
            'value' => 'IPA'
        });
        
        return dropdownValues;
    }
}