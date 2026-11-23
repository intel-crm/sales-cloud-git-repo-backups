@RestResource(urlMapping='/prelaunch/withoutsubcomp/*')
global class PRM_PreLaunch {
    
    @HttpGet
    global static PRM_PreLaunch_Model.WithoutSubComponent preLaunchWithoutSubComp()
    {
        String type = String.isNotBlank(RestContext.request.params.get('stepId')) ? RestContext.request.params.get('stepId') : '';
        System.debug('type'+type);
        //boolean isCompleted = String.isNotBlank(RestContext.request.params.get('completed')) ? Boolean.valueOf(RestContext.request.params.get('completed')) : false;   
        return PRM_PreLaunch_Utility.getOnBoardingSteps(type);
    }

    
}