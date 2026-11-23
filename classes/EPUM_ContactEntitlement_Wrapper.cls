/******************************************************************************************************
* Class Name  : EPUM_ContactEntitlement_Wrapper 
* Version     : 1.0 
* Created Date: 04-13-2020
* Modification Log :
* Developer  Hemavathi        
* Date   04/13/2020
* Description : This class is used for displaying contact entitlements
* -----------------------------------------------------------------------------------------------------
*******************************************************************************************************/
public without sharing class EPUM_ContactEntitlement_Wrapper {		
        public final String CATEGORY_DEFAULT = 'Entitlements';
        public final String SUBCATEGORY_DEFAULT = '';
        public final String ENTITLE_HELPTEXT_DEFAULT= '';
        public final String SUBCAT_HELPTEXT_DEFAULT='';
        @AuraEnabled public Boolean selected { get; set; }
    	@AuraEnabled public String status { get; set; }
    	@AuraEnabled public String recstatus { get; set; }
    	@AuraEnabled public Boolean readOnly { get; set; }
    	@AuraEnabled public Core_AuraProcessingMessage auraProcessingMessage { get; set; }
		@AuraEnabled public Core_Contact_Entitlement__c ContactEntitlement;
		@AuraEnabled public Boolean isSelected = false;
		@AuraEnabled public String entitlementId;
		@AuraEnabled public String entitlementNameStr;
    	@AuraEnabled public String strEntName;
        @TestVisible private String strCategory = '';
       // @AuraEnabled public String contactStatus = '';//subhadeep
        public String category { 
            get {
                if (String.isBlank(strCategory)){
                    return CATEGORY_DEFAULT;
                }                    
                else{
                    return strCategory;
                }                        
            }
        }
        
        @AuraEnabled public String strEntitleHelpText= '';
        @TestVisible @AuraEnabled public String entitlehelpText{ 
            get {
                if (String.isBlank(strEntitleHelpText)){
                    return ENTITLE_HELPTEXT_DEFAULT;
                }                    
                else{
                    return strEntitleHelpText;
                }   
            }
        }
        @AuraEnabled public String strSubCatHelpText= '';
        @AuraEnabled public String subCatHelpText{ 
            get {
                if (String.isBlank(strSubCatHelpText)){
                    return SUBCAT_HELPTEXT_DEFAULT;
                }                    
                else{
                    return strSubCatHelpText;
                }
                    
            }
        }
        private String  strSubCategory= '';
        @AuraEnabled public String subcategory { 
            get {
                if (String.isBlank(strSubCategory)){
                    return SUBCATEGORY_DEFAULT;
                }                    
                else{
                    return strSubCategory;
                }   
            }
        }

		public EPUM_ContactEntitlement_Wrapper(){}
		public EPUM_ContactEntitlement_Wrapper(Core_Entitlement__c objEntitlement,String strSubCatHelpText1) {
			entitlementId = objEntitlement.Id;
			strCategory   = objEntitlement.Core_Category__c;
			entitlementNameStr  = objEntitlement.Core_Display_Name__c;
			strSubCategory = objEntitlement.Core_Sub_Category__c ;
			strEntitleHelpText    = objEntitlement.Core_Help_Text__c  ; 
			strSubCatHelpText    = strSubCatHelpText1;
            strEntName = objEntitlement.Name;
		}  
	



}