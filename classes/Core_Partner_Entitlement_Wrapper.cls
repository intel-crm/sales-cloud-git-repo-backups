public class Core_Partner_Entitlement_Wrapper {
        
        public final String CATEGORY_DEFAULT = 'Entitlements';
        public final String SUBCATEGORY_DEFAULT = '';
        public final String ENTITLE_HELPTEXT_DEFAULT= '';
        public final String SUBCAT_HELPTEXT_DEFAULT='';
        @AuraEnabled public Boolean selected { get; set; }
    	@AuraEnabled public String status { get; set; }
    	@AuraEnabled public Boolean readOnly { get; set; }
    	@AuraEnabled public Core_AuraProcessingMessage auraProcessingMessage { get; set; }
    	
        @TestVisible private String strCategory = '';
        public String category { 
            get 
            {
                if (String.isBlank(strCategory))
                    return CATEGORY_DEFAULT;
                else     
                    return strCategory;
            }
        }
        
        @AuraEnabled public String strEntitleHelpText= '';
        @TestVisible @AuraEnabled public String entitlehelpText{ 
            get 
            {
                if (String.isBlank(strEntitleHelpText))
                    return ENTITLE_HELPTEXT_DEFAULT;
                else     
                    return strEntitleHelpText;
            }
        }
        @AuraEnabled public String strSubCatHelpText= '';
        @AuraEnabled public String subCatHelpText{ 
            get 
            {
                if (String.isBlank(strSubCatHelpText))
                    return SUBCAT_HELPTEXT_DEFAULT;
                else     
                    return strSubCatHelpText;
            }
        }
        private String  strSubCategory= '';
        @AuraEnabled public String subcategory { 
            get 
            {
                if (String.isBlank(strSubCategory))
                    return SUBCATEGORY_DEFAULT;
                else     
                    return strSubCategory;
            }
        }
        
    	//private - it was private before
        @AuraEnabled public String strName = '';
        @AuraEnabled public String name { get {return strName;} } 
        
        @AuraEnabled public Id idEntitlement{get;set;}
    
    	public Core_Partner_Entitlement_Wrapper() {}
        
        public Core_Partner_Entitlement_Wrapper(Core_Entitlement__c objEntitlement,String strSubCatHelpText1) {
            idEntitlement = objEntitlement.Id;
            strCategory   = objEntitlement.Core_Category__c;
            strName       = objEntitlement.Core_Display_Name__c;
            strSubCategory = objEntitlement.Core_Sub_Category__c ;
            strEntitleHelpText    = objEntitlement.Core_Help_Text__c  ; 
            strSubCatHelpText    = strSubCatHelpText1;
        }        
        
        public Core_Partner_Entitlement_Wrapper(Id idEnt, String strEngCat, String strEngSubCat, String strEngName, Boolean blnSelected, String strEngEntitleHelpText, String strEngSubCatHelpText1) {
            idEntitlement = idEnt;
            strCategory   = strEngCat;
            strName       = strEngName;            
            selected      = blnSelected;
            strSubCategory =strEngSubCat;
            strEntitleHelpText=strEngEntitleHelpText;
            strSubCatHelpText    = strEngSubCatHelpText1;
            
        } 
        
        public Integer compareTo(Object compareTo) 
        {      
            Core_Partner_Entitlement_Wrapper rec = (Core_Partner_Entitlement_Wrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer greaterValue = 1;
            Integer lesserValue  = -1;
            if (category > rec.category){
                return greaterValue;
            }   
            
            if (category == rec.category){
                if (subcategory > rec.subcategory){
                    return greaterValue;
                }
                if (subcategory == rec.subcategory){
                    if (name> rec.name){
                        return greaterValue;
                    } 
                }
            }  
            return lesserValue ;
        }              
    }