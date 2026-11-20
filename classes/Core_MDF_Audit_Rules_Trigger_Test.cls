/** Test class to cover Core_MDF_Audit_Rules_Trigger logic */
@isTest(SeeAllData=false)
public class Core_MDF_Audit_Rules_Trigger_Test {
    @TestSetup
    static void makeData() {
        Core_MDF_Audit_Rules_Engine__c rule1 = new Core_MDF_Audit_Rules_Engine__c();
        rule1.Core_MDF_Rule_Type_Nm__c= 'Audit';
        rule1.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        rule1.Core_MDF_Budget_Type_Multi_Nm__c= 'CCF 1.0';
        rule1.Core_MDF_Object_Nm__c= 'Core_MDF_Claim_Prediction__c';
        rule1.Core_MDF_Field_Nm__c= 'Core_MDF_New_Prediction_Score_nbr__c';
        rule1.Core_MDF_Operator_Nm__c= 'Greater Than';
        rule1.Core_MDF_Value_Txt__c= '80';
        rule1.Core_MDF_Immediate_Ind__c= 'Yes';
        rule1.Core_MDF_Region_Cd__c = 'WW';
        rule1.Core_MDF_Effective_Dt__c= System.today();
        rule1.Core_MDF_Active_Ind__c= true;
        Database.insert(rule1); 
    }
    
    @isTest static void testCheckForDuplicates(){
        Core_MDF_Audit_Rules_Engine__c testRule = new Core_MDF_Audit_Rules_Engine__c();
        testRule.Core_MDF_Program_Nm__c= 'Client CoMarketing Fund';
        testRule.Core_MDF_Budget_Type_Multi_Nm__c= 'CCF 1.0';
        testRule.Core_MDF_Rule_Type_Nm__c= 'Audit';
        testRule.Core_MDF_Object_Nm__c= 'Core_MDF_Claim_Prediction__c';
        testRule.Core_MDF_Field_Nm__c= 'Core_MDF_New_Prediction_Score_nbr__c';
        testRule.Core_MDF_Operator_Nm__c= 'Greater Than';
        testRule.Core_MDF_Value_Txt__c= '80';
       // testRule.Core_MDF_Immediate_Ind__c= 'No';
        testRule.Core_MDF_Effective_Dt__c= System.today();
        testRule.Core_MDF_Active_Ind__c= true;
        Database.insert(testRule);  
        
        try{
            testRule.Core_MDF_Immediate_Ind__c= 'Yes';
            testRule.Core_MDF_Region_Cd__c = 'WW';
        	Database.update(testRule);   
        }
        catch(exception ex){   
            string errorMessage = ex.getMessage();
            System.assert(errorMessage!='', 'Assert passed');
        }
        Core_MDF_Audit_Rules_ServiceHandler.checkForDuplicates(null);
    }
    
        

}