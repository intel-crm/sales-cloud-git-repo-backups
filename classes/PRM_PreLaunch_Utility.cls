public class PRM_PreLaunch_Utility {
    
    
    public static PRM_PreLaunch_Model.WithoutSubComponent getOnBoardingSteps(String type)
    {
        switch on type{
            when 'partner-grouping'{
                return  GetPartnerGroupComponentData();
            }
            when 'partner-role'{
                return  GetPartnerRoleComponentData();
            }
            when 'link-data'{
                return GetLinkComponentData();
            }
            when else{
                return  GetAllComponentData();
            }
            
        }
        
        
    }
    
    private static PRM_PreLaunch_Model.WithoutSubComponent GetPartnerGroupComponentData(){
        
        PRM_PreLaunch_Model.WithoutSubComponent woSubComponent=new PRM_PreLaunch_Model.WithoutSubComponent();
        
        PRM_PreLaunch_Model.Step stepPartnerGroup=new PRM_PreLaunch_Model.Step();
        stepPartnerGroup.completed=false;
        stepPartnerGroup.title=Label.PreLaunchPGTitle;
        stepPartnerGroup.component=Label.PreLaunchPGComponent;
        stepPartnerGroup.description=Label.PreLaunchPGDescription;
        stepPartnerGroup.completedTitle=Label.PreLaunchPGCompltTitle;
        stepPartnerGroup.completedDescription=Label.PreLaunchPGCompltDescription;
        stepPartnerGroup.modalTitle='AMAX US Division - 123457';
        stepPartnerGroup.stepId='XXXXXX-unique-step-id';
        
        List<PRM_PreLaunch_Model.Step> steps=new List<PRM_PreLaunch_Model.Step>();
        steps.Add(stepPartnerGroup);
        woSubComponent.steps=steps;
        return GetCommonComponentAttributes(woSubComponent);    
        
    }
    
    private static PRM_PreLaunch_Model.WithoutSubComponent GetPartnerRoleComponentData(){
        PRM_PreLaunch_Model.WithoutSubComponent woSubComponent=new PRM_PreLaunch_Model.WithoutSubComponent();
        
        PRM_PreLaunch_Model.Step stepPartnerGroup=new PRM_PreLaunch_Model.Step();
        stepPartnerGroup.completed=false;
        stepPartnerGroup.title=Label.PreLaunchPartnerRolConfTitle;
        stepPartnerGroup.component=Label.PreLaunchPRComponentName;
        stepPartnerGroup.description=Label.PreLaunchPRDescription;
        stepPartnerGroup.completedTitle=Label.PreLaunchPRCompltTitle;
        stepPartnerGroup.completedDescription=Label.PreLaunchPRCompltDescription;
        stepPartnerGroup.modalTitle='AMAX Engineering Corporation';
        stepPartnerGroup.stepId='XXXXXX-unique-step-id';
        
        List<PRM_PreLaunch_Model.Step> steps=new List<PRM_PreLaunch_Model.Step>();
        steps.Add(stepPartnerGroup);
        woSubComponent.steps=steps;
        return GetCommonComponentAttributes(woSubComponent);    
        
    }
    private static PRM_PreLaunch_Model.WithoutSubComponent GetLinkComponentData(){return new  PRM_PreLaunch_Model.WithoutSubComponent();}
    private static PRM_PreLaunch_Model.WithoutSubComponent GetAllComponentData(){
        PRM_PreLaunch_Model.WithoutSubComponent woSubComponents= new PRM_PreLaunch_Model.WithoutSubComponent();
        List<PRM_PreLaunch_Model.Step> step=new List<PRM_PreLaunch_Model.Step>();
        step.addAll(GetPartnerRoleComponentData().steps);
        step.addAll(GetPartnerGroupComponentData().steps);
        woSubComponents.steps=step;
        return GetCommonComponentAttributes(woSubComponents); 
    }
    
    private static PRM_PreLaunch_Model.WithoutSubComponent GetCommonComponentAttributes(PRM_PreLaunch_Model.WithoutSubComponent woSubComponent){
        woSubComponent.body=Label.PreLaunchWithoutSubCompBody;
        woSubComponent.faIcon='';
        woSubComponent.imageUrl='';
        woSubComponent.title=Label.PreLaunchWithoutSubCompTitle;
        woSubComponent.type='linear';
        return woSubComponent;
    }
    
    
}