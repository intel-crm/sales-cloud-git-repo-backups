({
    launchFlow : function(component) {

        var objectName = component.get("v.sObjectName");
        var action = "New";

        var flowName = this.getFlowName(objectName, action);

        if(!flowName){
            alert("No Flow configured.");
            return;
        }

        component.set("v.flowName", flowName);

        $A.createComponent(
            "lightning:flow",
            {
                "aura:id": "flow",
                "onstatuschange": component.getReference("c.handleStatusChange")
            },
            function(flowComponent, status, errorMessage){

                if(status === "SUCCESS"){

                    component.find("overlayLib").showCustomModal({

                        header: "Create Record",

                        body: flowComponent,

                        showCloseButton: true,

                        cssClass: "slds-modal_small",

                        closeCallback: function(){

                            console.log("Flow modal closed");

                        }

                    }).then(function(overlay){

                        flowComponent.startFlow(
                            flowName,
                            []
                        );

                    });

                }
                else if(status === "ERROR"){

                    console.log("Error creating flow component: " + errorMessage);

                }

            }
        );
    },


    handleStatusChange : function(component, event){

        var status = event.getParam("status");

        if(status === "FINISHED" ||
           status === "FINISHED_SCREEN"){

            var modal = component.find("overlayLib");

            modal.notifyClose();

            this.navigateToListView(component);
        }
    },


    getFlowName : function(objectName, action){

        var config = $A.get("$Label.c.Core_MDF_FlowLauncher_Config");

        var mappings = config.split(";");

        for(var i=0; i<mappings.length; i++){

            var pair = mappings[i].split("=");

            if(pair.length !== 2){
                continue;
            }

            if(pair[0].trim() === objectName + "|" + action){

                return pair[1].trim();
            }
        }

        return null;
    },


    navigateToListView : function(component){

        var navEvt = $A.get("e.force:navigateToObjectHome");

        if(navEvt){

            navEvt.setParams({

                scope : component.get("v.sObjectName")

            });

            navEvt.fire();
        }
    }
})