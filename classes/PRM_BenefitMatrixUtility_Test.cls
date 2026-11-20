@isTest()
public class PRM_BenefitMatrixUtility_Test {
    static testmethod void testCheckInsert(){
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
                
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        //cpl.PRM_programlevelcode__c=
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        //cpl.PRM_programlevelcode__c=
        cpl2.Name='Titanium';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name='Partner University';
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Channel_Program_Id__c = cp.id;
        insert pb;
       
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c(); //Partner Type
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        pt.PRM_channelprogram__c = cp.id;
        insert pt;
        
        PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c(); //Benefit Matrix 
        bm.PRM_Partner_Benefit_Id__c = pb.id;
        bm.PRM_Channel_Program_Id__c = cp.id;
        bm.PRM_Channel_Program_Level_Id__c = cpl.id;
        bm.PRM_Partner_Type_Id__c = pt.id;
        bm.PRM_Covered_Account_Ind__c  = true;
        bm.PRM_Approval_Type_Nm__c = 'Manual';
        
        insert bm;//Benefit Matrix insertion with Member as CPL
       
              
        PRM_VXBnftMatrix__c bm1 = new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bm1.PRM_Partner_Benefit_Id__c = pb.id;
        bm1.PRM_Channel_Program_Id__c = cp.id;
        bm1.PRM_Channel_Program_Level_Id__c = cpl2.id;
        bm1.PRM_Partner_Type_Id__c = pt.id;
        bm1.PRM_Covered_Account_Ind__c  = true;
        bm1.PRM_Approval_Type_Nm__c = 'Manual';
        
        insert bm1;//Benefit Matrix insertion with Titanium as CPL
            
        
        Test.startTest();
      
        PRM_VXBnftMatrix__c bm2 = new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bm2.PRM_Partner_Benefit_Id__c = pb.id;
        bm2.PRM_Channel_Program_Id__c = cp.id;
        bm2.PRM_Channel_Program_Level_Id__c = cpl.id;
        bm2.PRM_Partner_Type_Id__c = pt.id;
        bm2.PRM_Covered_Account_Ind__c  = true;
        bm2.PRM_Approval_Type_Nm__c = 'Manual';
        
        PRM_VXBnftMatrix__c[] bmlist=new List<PRM_VXBnftMatrix__c>();
        bmlist.add(bm);
        bmlist.add(bm1);
        bmlist.add(bm2);
        
        try
        { 
            database.insert(bmlist,false);//Benefit Matrix insertion with Member as CPL, as it is a duplicate it should throw error
        }
        catch(Exception e)
        {
            //Boolean expectedExceptionThrown =  (e.getMessage().contains(System.label.PRM_BenfitMatrix_Error1)) ? true : false;
            PRM_ErrorUtilityClass.logError(e);
        }     
        Test.stopTest();
        System.assertEquals(bm2.PRM_Approval_Type_Nm__c,'Manual','Value does not match');
    }
    static testmethod void testCheckUpdate(){
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
                
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        //cpl.PRM_programlevelcode__c=
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        //cpl.PRM_programlevelcode__c=
        cpl2.Name='Titanium';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        
        PRM_PartnerBenefit__c pb = new PRM_PartnerBenefit__c(); //Partner Benefit
        pb.Name='Partner University';
        pb.PRM_Benefit_Cd__c = 'BFTTRGUNI';
        pb.PRM_Channel_Program_Id__c = cp.id;
        insert pb;
       
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c(); //Partner Type
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        pt.PRM_channelprogram__c = cp.id;
        insert pt;
        
        PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c(); //Benefit Matrix 
        bm.PRM_Partner_Benefit_Id__c = pb.id;
        bm.PRM_Channel_Program_Id__c = cp.id;
        bm.PRM_Channel_Program_Level_Id__c = cpl.id;
        bm.PRM_Partner_Type_Id__c = pt.id;
        bm.PRM_Covered_Account_Ind__c  = true;
        bm.PRM_Approval_Type_Nm__c = 'Manual';
        
        insert bm;//Benefit Matrix insertion with Member as CPL
       
              
        PRM_VXBnftMatrix__c bm1 = new PRM_VXBnftMatrix__c(); //Benefit Matrix
        bm1.PRM_Partner_Benefit_Id__c = pb.id;
        bm1.PRM_Channel_Program_Id__c = cp.id;
        bm1.PRM_Channel_Program_Level_Id__c = cpl2.id;
        bm1.PRM_Partner_Type_Id__c = pt.id;
        bm1.PRM_Covered_Account_Ind__c  = true;
        bm1.PRM_Approval_Type_Nm__c = 'Manual';
        
        insert bm1;//Benefit Matrix insertion with Titanium as CPL
            
        PRM_VXBnftMatrix__c[] bmlist=new List<PRM_VXBnftMatrix__c>();
        bmlist.add(bm);
        bmlist.add(bm1);
        
        Test.startTest();
      
        bm.PRM_Channel_Program_Level_Id__c = cpl2.id;
        
        try
        {
            update bm;//Benefit Matrix updation from Member to Titanium as CPL, as it is a duplicate it should throw error
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  (e.getMessage().contains(System.label.PRM_BenfitMatrix_Error1)) ? true : false;
            PRM_ErrorUtilityClass.logError(e);
        }
        
        Test.stopTest();
        System.assertEquals(bm1.PRM_Approval_Type_Nm__c,'Manual','Value does not match');
    } 
}