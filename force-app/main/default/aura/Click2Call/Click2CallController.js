({
    doInit : function(component, event, helper) {
        
        /*helper.fetchProjects(component,event,helper);*/
        helper.fetchdidnumbers(component,event,helper);
        
        
        /*var action = component.get("c.clickToCall");
        action.setParams({ 'recordId' : component.get("v.recordId") }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                component.set("v.Ids",response.getReturnValue()); 
            } else if(state === 'ERROR'){
                     var errors = response.getError();
                    var errorMessage='';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        errorMessage = errors[0].message;
                    }
                } else {
                  
                    errorMessage = "Unknown error, contact your system admin";
                    console.log("Unknown error");
                }
                          var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error",
                                "type": "error",
                                "message": errorMessage
                            });
                            toastEvent.fire();
                    }
             helper.closeQuick(component, event);
        });  
        $A.enqueueAction(action); */

    },
    call : function(component, event, helper) {
         console.log("v.project after selecting:", component.get("v.selectedproject"));
        var action = component.get("c.clickToCall");
        action.setParams({ 'recordId' : component.get("v.recordId"),
                          'Project' : component.get("v.selectedproject")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "type": "success",
                    "message": 'Call Initiated successfully'
                });
                toastEvent.fire();
               // component.set("v.Ids",response.getReturnValue()); 
            } else if(state === 'ERROR'){
                     var errors = response.getError();
                    var errorMessage='';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        errorMessage = errors[0].message;
                    }
                } else {
                  
                    errorMessage = "Unknown error, contact your system admin";
                    console.log("Unknown error");
                }
                          var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error",
                                "type": "error",
                                "message": errorMessage
                            });
                            toastEvent.fire();
                    }
             helper.closeQuick(component, event);
        });  
        $A.enqueueAction(action);
        
        
    },
     closeModal : function(component, event, helper) {
        component.set("v.showModal", false);
    },
})