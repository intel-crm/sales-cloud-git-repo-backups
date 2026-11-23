global class UCD_ACM_GroupNameDynamicPicklist extends VisualEditor.DynamicPickList {
    
    public static String GlobalCustName = '';
    public static String Int1CustName = '';
    public static String Int2CustName = '';
    
    public UCD_ACM_GroupNameDynamicPicklist(String accId) {
		Account acc = [SELECT ID, Core_Unified_Global_Customer_Name__c, Core_Unified_Intermediate_Customer_Name__c, Core_Unified_Intermdt_Customer_2_Name__c
                      FROM Account WHERE ID = :accId];
        GlobalCustName = acc.Core_Unified_Global_Customer_Name__c;
        Int1CustName = acc.Core_Unified_Intermediate_Customer_Name__c;
        Int2CustName = acc.Core_Unified_Intermdt_Customer_2_Name__c;
        getValues();
    }

    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        String label = '';
        String value = '';
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();

        if (GlobalCustName != null) {
            label = GlobalCustName;
            value = GlobalCustName;
        }
        VisualEditor.DataRow pv1 = new VisualEditor.DataRow(label, value);

        if (Int1CustName != null && GlobalCustName != Int1CustName) {
            label = Int1CustName;
            value = Int1CustName;
        }
        VisualEditor.DataRow pv2 = new VisualEditor.DataRow(label, value);

        if (Int2CustName != null && GlobalCustName != Int2CustName && Int1CustName != Int2CustName) {
            label = Int2CustName;
            value = Int2CustName;
        }
        VisualEditor.DataRow pv3 = new VisualEditor.DataRow(label, value);

        myValues.addRow(pv1);
        myValues.addRow(pv2);
        myValues.addRow(pv3);
        return myValues;
    }
}