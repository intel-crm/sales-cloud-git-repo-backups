/****************************************************************************************************
Apex Class Name : PSG_ActiveProductExtAttrHandler_Test
Version         : 1.0 
Created Date    : 07/15/2021
Function        : test class for PSG_ActiveProductExtAttrHandler
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya D                    07/15/2021               Created
*****************************************************************************************************/
@isTest
public class Core_PSG_ActiveProductExtAttrHandlerTest {
    @isTest static void createUpdateExtAttrToActiveProductsTest(){
        List<Product2> prods=new  List<Product2>();
        List<Core_Product_Ext_Attribute__c> extAttrList = new List<Core_Product_Ext_Attribute__c>();
        Product2 p=new Product2();
        p.core_OPN__c='INTELPROD';
        p.Name='Intel Prod 1';
        p.Core_Hierarchy_ID__c='59';
        p.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p.IsActive=true;
        p.Core_Product_org__c = 'Sales';
        p.Core_Item_Class_Nm__c = 'IC';
        p.Core_Item_Signal_Cd__c ='AC';
        prods.add(p);
        Product2 p1=new Product2();
        p1.core_OPN__c='INTELPROD';
        p1.Name='Intel Prod 2';
        p1.Core_Hierarchy_ID__c='43';
        p1.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p1.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p1.IsActive=true;
        p1.Core_Product_org__c = 'Sales';
        p1.Core_Item_Class_Nm__c = 'IC';
        p1.Core_Item_Signal_Cd__c ='AC';
        prods.add(p1);
        Test.startTest();
        insert prods;
        p1.Core_Sales_Visible_Flag__c = false;	
        p1.Core_Sales_Visible_Flag_User_Edit__c =false; 
        p.Core_Sales_Visible_Flag__c = true;	
        p.Core_Sales_Visible_Flag_User_Edit__c =false; 
        update prods;
        Core_Product_Ext_Attribute__c extendedAttribute = new Core_Product_Ext_Attribute__c();
        extendedAttribute.Core_Product_Id__c=p.id;
        extendedAttribute.Core_Prod_Tool_Type_Nm__c='BASE';
        extendedAttribute.Core_SW_Lic_Type_Nm__c='FIXED';
        extendedAttribute.Core_SW_Lic_Enforcement_Method_Nm__c='File';
        extendedAttribute.Core_SW_Prod_Web_Dsc__c='Desc';
        extendedAttribute.Core_SW_Prod_Max_Rehost_Cnt__c=0;
        extendedAttribute.Core_SW_Lic_File_Data_Encryption_Std_Cd__c='3DES';
        extendedAttribute.Core_SW_Lic_Generator_Parameter_Txt__c='-a';
        extAttrList.add(extendedAttribute);
        insert extAttrList;
        System.assert(prods!=null, 'Product inserted');
        Test.stopTest();
    }            
    @isTest static void createUpdateExtAttrToActiveProductsTest1(){
        List<Product2> prods=new  List<Product2>();
        List<Core_Product_Ext_Attribute__c> extAttrList = new List<Core_Product_Ext_Attribute__c>();
        Product2 p=new Product2();
        p.core_OPN__c='INTELPROD';
        p.Name='Intel Prod 1';
        p.Core_Hierarchy_ID__c='59';
        p.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p.IsActive=true;
        p.Core_Product_org__c = 'Sales';
        p.Core_Item_Class_Nm__c = 'IC';
        p.Core_Item_Signal_Cd__c ='AC';
        prods.add(p);
        Product2 p1=new Product2();
        p1.core_OPN__c='INTELPROD';
        p1.Name='Intel Prod 2';
        p1.Core_Hierarchy_ID__c='43';
        p1.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p1.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p1.IsActive=false;
        p1.Core_Product_org__c = 'Sales';
        prods.add(p1);
        Test.startTest();
        insert prods;
        Product2 p2=new Product2();
        p2=p1;
        p1.Core_Sales_Visible_Flag__c = false;	
        p1.Core_Sales_Visible_Flag_User_Edit__c =false; 
        p.Core_Sales_Visible_Flag__c = true;	
        p.Core_Sales_Visible_Flag_User_Edit__c =false; 
        update prods;
        List<Product2> oldprods=new  List<Product2>();
        List<Product2> prodListToUpdate=new  List<Product2>();
        oldprods.add(p1);
        oldprods.add(p1);
        if(prods != null && oldprods!= null){		
            for(Product2 psgProdRecord : prods){
                If (  psgProdRecord.Core_Sales_Visible_Flag_User_Edit__c==true )
                {
                    Integer result = prodListToUpdate.indexOf(psgProdRecord);
                    If(result>0)
                    {	
                        psgProdRecord.Core_Sales_Visible_Flag__c = psgProdRecord.Core_Sales_Visible_Flag__c;	
                        psgProdRecord.Core_Sales_Visible_Flag_User_Edit__c =false; 
                        prodListToUpdate.add(psgProdRecord);
                    }
                    else
                    {
                        psgProdRecord.Core_Sales_Visible_Flag__c = psgProdRecord.Core_Sales_Visible_Flag__c;  
                        psgProdRecord.Core_Sales_Visible_Flag_User_Edit__c =false; 
                        prodListToUpdate.add(psgProdRecord);
                    }								   
                }			
            }
        }
        insert prodListToUpdate;   
        Core_Product_Ext_Attribute__c extendedAttribute = new Core_Product_Ext_Attribute__c();
        extendedAttribute.Core_Product_Id__c=p.id;
        extendedAttribute.Core_Prod_Tool_Type_Nm__c='BASE';
        extendedAttribute.Core_SW_Lic_Type_Nm__c='FIXED';
        extendedAttribute.Core_SW_Lic_Enforcement_Method_Nm__c='File';
        extendedAttribute.Core_SW_Prod_Web_Dsc__c='Desc';
        extendedAttribute.Core_SW_Prod_Max_Rehost_Cnt__c=0;
        extendedAttribute.Core_SW_Lic_File_Data_Encryption_Std_Cd__c='3DES';
        extendedAttribute.Core_SW_Lic_Generator_Parameter_Txt__c='-a';
        extAttrList.add(extendedAttribute);
        insert extAttrList; 
        SBQQ__ProductOption__c prodoption = new SBQQ__ProductOption__c();
        prodoption.SBQQ__Number__c = 5;
        prodoption.SBQQ__ConfiguredSKU__c = p.id;
        prodoption.SBQQ__OptionalSKU__c = p.id ;
        prodoption.SBQQ__Bundled__c = true;
        prodoption.SBQQ__Type__c ='Accessory';
        insert prodoption;
        p1.IsActive=true;
        update p1;
        Test.stopTest();
    }
    @isTest static void updateSignalCodeOnAllProducts(){
        List<Product2> prodListToUpdate = new List<Product2>();
        List<Product2> prodListToUpdate2 = new List<Product2>();	
        Product2 p4=new Product2();
        p4.core_OPN__c='INTELPROD';
        p4.Name='Intel Prod 5';
        p4.Core_Hierarchy_ID__c='43';
        p4.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p4.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p4.IsActive=false;
        p4.Core_Product_org__c = 'Sales';
        prodListToUpdate.add(p4);
        Product2 p5=new Product2();
        p5.core_OPN__c='INTELPROD';
        p5.Name='Intel Prod 6';
        p5.Core_Hierarchy_ID__c='43';
        p5.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p5.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p5.IsActive=false;
        p5.Core_Product_org__c = 'Sales';
        prodListToUpdate.add(p5);
        insert prodListToUpdate;  
        Test.startTest();
        for(Product2 psgProdRecord : prodListToUpdate){
            Integer result = prodListToUpdate.indexOf(psgProdRecord);
            If(result>0)
            {	
                Product2 prod = new Product2();							
                prod = prodListToUpdate.get(result);						
                if (prod.Core_Sales_Visible_Flag_User_Edit__c== false)
                {
                    prod.Core_Sales_Visible_Flag_User_Edit__c= false;
                    prod.Core_Sales_Visible_Flag__c = false; 
                    prodListToUpdate.set(result,prod);
                }
                else
                {
                    prod.Core_Sales_Visible_Flag_User_Edit__c= false;
                    prod.Core_Sales_Visible_Flag__c = true; 
                    prodListToUpdate.set(result,prod);
                }
            }
            else
            {
                psgProdRecord.Core_Sales_Visible_Flag_User_Edit__c= false;
                psgProdRecord.Core_Sales_Visible_Flag__c = true; 
                prodListToUpdate2.add(psgProdRecord);
                
            }
        }
        
        
        update prodListToUpdate2;		
        update prodListToUpdate;             
        Test.stopTest();
    }
    @isTest static void updateProductsWithoutSignalCode(){
        List<Product2> newList= new List<Product2>();
        Product2 p2_new=new Product2();
        p2_new.core_OPN__c='INTELPROD';
        p2_new.Name='Intel Prod 151';
        p2_new.Core_Hierarchy_ID__c='59';
        p2_new.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p2_new.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p2_new.IsActive=true;
        p2_new.Core_Product_org__c = 'Sales';
        p2_new.Core_Item_Class_Nm__c = 'IC';
        p2_new.Core_Item_Signal_Cd__c ='AC';
        Product2 p3_new=new Product2();
        p3_new.core_OPN__c='INTELPROD';
        p3_new.Name='Intel Prod 161';
        p3_new.Core_Hierarchy_ID__c='43';
        p3_new.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p3_new.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p3_new.IsActive=false;
        p3_new.Core_Product_org__c = 'Sales';
        newList.add(p2_new);
        newList.add(p3_new);
        Test.startTest();
        insert newList;
        p2_new.Core_Item_Signal_Cd__c = null;
        update p2_new;
        Test.stopTest();
    }	
    @isTest static void updateSignalCodeOnActiveProduct(){
        List<Product2> newList= new List<Product2>();
        Product2 p2_new=new Product2();
        p2_new.core_OPN__c='INTELPROD';
        p2_new.Name='Intel Prod 15';
        p2_new.Core_Hierarchy_ID__c='59';
        p2_new.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p2_new.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p2_new.IsActive=true;
        p2_new.Core_Product_org__c = 'Sales';
        p2_new.Core_Item_Class_Nm__c = 'IC';
        p2_new.Core_Item_Signal_Cd__c ='AC';
        Product2 p3_new=new Product2();
        p3_new.core_OPN__c='INTELPROD';
        p3_new.Name='Intel Prod 16';
        p3_new.Core_Hierarchy_ID__c='43';
        p3_new.Core_Product_Type__c=Label.PSG_Product_Type_Identifier;
        p3_new.Core_Code_Name__c=Label.PSG_Product_Type_Identifier;
        p3_new.IsActive=false;
        p3_new.Core_Product_org__c = 'Sales';
        newList.add(p2_new);
        newList.add(p3_new);
        Test.startTest();
        insert newList;
        Map<String,Product2> opnSignalCodeMap=new Map<String,Product2>();
        List<Product2> releaseProdList=new List<Product2>();
        Set<String> opnSet=new Set<String>();
        List<Product2> preReleaseSignalCodeList=new List<Product2>();
        List<Core_Log_Entry__c> captureQueryErr = new List<Core_Log_Entry__c>();
        if(newList != null){
            for(Product2 prod : newList){               
                if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.core_OPN__c!=null && prod.isActive && prod.Core_Hierarchy_ID__c =='43' && prod.Core_Product_Org__c=='Sales' ){
                    releaseProdList.add(prod);
                    opnSet.add(prod.core_OPN__c);
                }
            }               
        }
        if(!opnSet.isEmpty() || opnSet!=null){
            for(Product2 prodRec : [Select id,Name,core_OPN__c,Core_Product_Id__c,Core_Item_Class_Nm__c,Core_Item_Signal_Cd__c from Product2 where core_OPN__c IN :opnSet and Core_Hierarchy_ID__c = '59' and Core_Product_Type__c = :Label.PSG_Product_Type_Identifier and Core_Product_Org__c='Sales' ORDER BY CreatedDate DESC]){
                if(!opnSignalCodeMap.containsKey(prodRec.Core_OPN__c)){
                    opnSignalCodeMap.put(prodRec.core_OPN__c,prodRec);
                }
            }
        }
        for(Product2 prod:releaseProdList){ 
            if(opnSignalCodeMap.get(prod.Core_OPN__c).Core_Item_Class_Nm__c !=null && opnSignalCodeMap.get(prod.Core_OPN__c).Core_Item_Signal_Cd__c != null ){
                prod.Core_Item_Class_Nm__c = opnSignalCodeMap.get(prod.Core_OPN__c).Core_Item_Class_Nm__c;
                prod.Core_Item_Signal_Cd__c = opnSignalCodeMap.get(prod.Core_OPN__c).Core_Item_Signal_Cd__c;
            } 
        }
        update  newList;
        Test.stopTest();
    }
}